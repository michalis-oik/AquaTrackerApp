import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:water_tracking_app/models/user_model.dart';
import 'package:water_tracking_app/models/group_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get uid => _auth.currentUser?.uid;

  // Reference to user's daily consumption
  DocumentReference _getDailyDoc(String date) {
    return _db.collection('users').doc(uid).collection('consumption').doc(date);
  }

  // Update water intake for today and sync to groups
  Future<void> updateWaterIntake(int newIntake) async {
    if (uid == null) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Update user's personal consumption
    await _getDailyDoc(today).set({
      'intake': newIntake,
      'timestamp': FieldValue.serverTimestamp(),
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    // 2. Proactively sync to groups
    await syncIntakeToGroups(newIntake);
  }

  // Sync current intake to all groups the user is in (force-push)
  Future<void> syncIntakeToGroups(int currentIntake) async {
    if (uid == null) return;
    try {
      final groupsQuery = await _db
          .collection('groups')
          .where('members', arrayContains: uid)
          .get();

      final batch = _db.batch();
      for (var doc in groupsQuery.docs) {
        batch.update(doc.reference, {
          'memberIntakes.$uid': currentIntake,
          'lastActivity': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint("!!!! Error force-syncing intake to groups: $e");
    }
  }

  // Stream current day's intake
  Stream<DocumentSnapshot> getTodayConsumptionStream() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _getDailyDoc(today).snapshots();
  }

  // Initial fetch for a specific date
  Future<int> getIntakeForDate(String date) async {
    if (uid == null) return 0;

    final doc = await _getDailyDoc(date).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['intake'] ?? 0;
    }
    return 0;
  }

  // Fetch data for the entire week
  Future<Map<String, int>> getWeeklyConsumption(List<String> dates) async {
    if (uid == null) return {};

    Map<String, int> weeklyData = {};
    for (String date in dates) {
      int intake = await getIntakeForDate(date);
      weeklyData[date] = intake;
    }
    return weeklyData;
  }

  // Update user's daily goal
  Future<void> updateDailyGoal(int newGoal) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'dailyGoal': newGoal,
      'lastSettingsUpdate': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // Update user's profile icon
  Future<void> updateProfileIcon(String icon) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'profileIcon': icon,
    }, SetOptions(merge: true));
  }

  // Stream user settings
  Stream<UserModel?> getUserModelStream() {
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      return doc.exists ? UserModel.fromSnapshot(doc) : null;
    });
  }

  // --- Group Logic ---

  Future<String> createGroup(String name, int goal) async {
    if (uid == null) return "";

    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String randomSuffix = List.generate(
      3,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
    String cleanName = name.replaceAll(' ', '');
    String prefix = (cleanName.substring(
      0,
      min(3, cleanName.length),
    )).toUpperCase();
    if (prefix.length < 3) {
      prefix = (prefix + 'AAA').substring(0, 3);
    }
    String inviteCode = "$prefix$randomSuffix";

    int currentIntake = await getIntakeForDate(_todayStr);

    DocumentReference groupRef = _db.collection('groups').doc();
    final newGroup = GroupModel(
      id: groupRef.id,
      name: name.trim(),
      adminId: uid!,
      dailyGoal: goal,
      members: [uid!],
      memberIntakes: {uid!: currentIntake},
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    await groupRef.set(newGroup.toMap());

    // Add group to user's list
    await _db.collection('users').doc(uid).update({
      'groups': FieldValue.arrayUnion([groupRef.id]),
    });

    return groupRef.id;
  }

  Future<bool> joinGroupByCode(String code) async {
    if (uid == null) return false;

    final query = await _db
        .collection('groups')
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    String groupId = query.docs.first.id;
    List members = query.docs.first['members'] ?? [];
    if (members.contains(uid)) return true;

    int currentIntake = await getIntakeForDate(_todayStr);

    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([uid]),
      'memberIntakes.$uid': currentIntake,
    });

    await _db.collection('users').doc(uid).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });

    return true;
  }

  Future<bool> leaveGroup(String groupId) async {
    if (uid == null) return false;

    try {
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;

      if (groupDoc['adminId'] == uid) return false;

      await _db.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([uid]),
      });

      await _db.collection('users').doc(uid).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });

      return true;
    } catch (e) {
      debugPrint("Error leaving group: $e");
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    if (uid == null) return false;

    try {
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;

      if (groupDoc['adminId'] != uid) return false;

      List members = groupDoc['members'] ?? [];

      for (String memberId in members) {
        await _db.collection('users').doc(memberId).update({
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }

      await _db.collection('groups').doc(groupId).delete();
      return true;
    } catch (e) {
      debugPrint("Error deleting group: $e");
      return false;
    }
  }

  Future<bool> updateGroupName(String groupId, String newName) async {
    if (uid == null || newName.trim().isEmpty) return false;

    try {
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists || groupDoc['adminId'] != uid) return false;

      await _db.collection('groups').doc(groupId).update({
        'name': newName.trim(),
      });
      return true;
    } catch (e) {
      debugPrint("Error updating group name: $e");
      return false;
    }
  }

  Future<bool> updateGroupGoal(String groupId, int newGoal) async {
    if (uid == null || newGoal <= 0) return false;

    try {
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists || groupDoc['adminId'] != uid) return false;

      await _db.collection('groups').doc(groupId).update({
        'dailyGoal': newGoal,
      });
      return true;
    } catch (e) {
      debugPrint("Error updating group goal: $e");
      return false;
    }
  }

  Stream<List<GroupModel>> getGroupsStream() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GroupModel.fromSnapshot(doc))
              .toList();
        });
  }

  Stream<List<UserModel>> getGroupMembersStream(List<String> memberIds) {
    if (memberIds.isEmpty) return Stream.value([]);

    return _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: memberIds)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();
        })
        .handleError((error) {
          debugPrint("!!!! Member Data Query Error: $error");
          return <UserModel>[];
        });
  }

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- Reminders Logic ---

  Stream<List<Map<String, dynamic>>> getRemindersStream() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': data['id'],
              'time': data['time'],
              'label': data['label'],
              'amount': data['amount'],
              'isUpcoming': data['isUpcoming'],
              'icon': IconData(data['iconCode'], fontFamily: 'MaterialIcons'),
              'color': Color(data['colorValue']),
              'docId': doc.id,
            };
          }).toList();
        });
  }

  Future<void> saveReminder(Map<String, dynamic> reminder) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(reminder['id'].toString())
        .set(
          {
              ...reminder,
              'iconCode': (reminder['icon'] as IconData).codePoint,
              'colorValue': (reminder['color'] as Color).value,
              'timestamp': FieldValue.serverTimestamp(),
            }
            ..remove('icon')
            ..remove('color'),
        );
  }

  Future<void> deleteReminder(int id) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc(id.toString())
        .delete();
  }
}
