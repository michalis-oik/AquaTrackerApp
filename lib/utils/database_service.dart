import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get uid => _auth.currentUser?.uid;

  // Reference to user's daily consumption
  DocumentReference _getDailyDoc(String date) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('consumption')
        .doc(date);
  }

  // Update water intake for today
  Future<void> updateWaterIntake(int newIntake) async {
    if (uid == null) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    await _getDailyDoc(today).set({
      'intake': newIntake,
      'timestamp': FieldValue.serverTimestamp(),
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
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

  // Stream user settings (goal and groups)
  Stream<DocumentSnapshot> getUserSettingsStream() {
    return _db.collection('users').doc(uid).snapshots();
  }

  // --- Group Logic ---

  // Create a new group
  Future<String> createGroup(String name, int goal) async {
    if (uid == null) return "";
    
    // Generate a unique 6-character invite code
    String inviteCode = (uid!.substring(0, 3) + name.substring(0, min(3, name.length))).toUpperCase();
    
    DocumentReference groupRef = _db.collection('groups').doc();
    await groupRef.set({
      'name': name,
      'adminId': uid,
      'dailyGoal': goal,
      'members': [uid],
      'inviteCode': inviteCode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add group to user's list
    await _db.collection('users').doc(uid).update({
      'groups': FieldValue.arrayUnion([groupRef.id])
    });

    return groupRef.id;
  }

  // Join a group via invite code
  Future<bool> joinGroupByCode(String code) async {
    if (uid == null) return false;
    
    final query = await _db.collection('groups').where('inviteCode', isEqualTo: code.toUpperCase()).limit(1).get();
    
    if (query.docs.isEmpty) return false;
    
    String groupId = query.docs.first.id;
    
    // Check if already a member
    List members = query.docs.first['members'] ?? [];
    if (members.contains(uid)) return true;

    // Add to group
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([uid])
    });

    // Add group to user
    await _db.collection('users').doc(uid).update({
      'groups': FieldValue.arrayUnion([groupId])
    });

    return true;
  }

  // Leave a group (for non-admin members)
  Future<bool> leaveGroup(String groupId) async {
    if (uid == null) return false;
    
    try {
      // Get group data to check if user is admin
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;
      
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['adminId'] == uid) {
        // Admins should use deleteGroup instead
        return false;
      }
      
      // Remove user from group's members
      await _db.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([uid])
      });
      
      // Remove group from user's list
      await _db.collection('users').doc(uid).update({
        'groups': FieldValue.arrayRemove([groupId])
      });
      
      return true;
    } catch (e) {
      print("Error leaving group: $e");
      return false;
    }
  }

  // Delete a group (admin only)
  Future<bool> deleteGroup(String groupId) async {
    if (uid == null) return false;
    
    try {
      // Get group data to verify admin
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;
      
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['adminId'] != uid) {
        // Only admin can delete
        return false;
      }
      
      List members = groupData['members'] ?? [];
      
      // Remove group from all members' user documents
      for (String memberId in members) {
        await _db.collection('users').doc(memberId).update({
          'groups': FieldValue.arrayRemove([groupId])
        });
      }
      
      // Delete the group document
      await _db.collection('groups').doc(groupId).delete();
      
      return true;
    } catch (e) {
      print("Error deleting group: $e");
      return false;
    }
  }

  // Update group name (admin only)
  Future<bool> updateGroupName(String groupId, String newName) async {
    if (uid == null || newName.trim().isEmpty) return false;
    
    try {
      // Verify admin
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;
      
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['adminId'] != uid) return false;
      
      await _db.collection('groups').doc(groupId).update({
        'name': newName.trim(),
      });
      
      return true;
    } catch (e) {
      print("Error updating group name: $e");
      return false;
    }
  }

  // Update group daily goal (admin only)
  Future<bool> updateGroupGoal(String groupId, int newGoal) async {
    if (uid == null || newGoal <= 0) return false;
    
    try {
      // Verify admin
      final groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return false;
      
      final groupData = groupDoc.data() as Map<String, dynamic>;
      if (groupData['adminId'] != uid) return false;
      
      await _db.collection('groups').doc(groupId).update({
        'dailyGoal': newGoal,
      });
      
      return true;
    } catch (e) {
      print("Error updating group goal: $e");
      return false;
    }
  }

  // Stream groups the user is in (reactive to group changes)
  Stream<List<Map<String, dynamic>>> getGroupsSnapshotStream() {
    if (uid == null) return Stream.value([]);
    return _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Stream user document to get the list of group IDs (kept for backward compatibility if needed)
  Stream<DocumentSnapshot> getUserGroupsStream() {
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots();
  }

  // Fetch group details for a list of group IDs
  Future<List<Map<String, dynamic>>> getGroupsDetails(List<dynamic> groupIds) async {
    if (groupIds.isEmpty) return [];
    try {
      final groupFutures = groupIds.map((id) => _db.collection('groups').doc(id.toString()).get());
      final groupDocs = await Future.wait(groupFutures).timeout(const Duration(seconds: 5), onTimeout: () => []);

      return groupDocs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) {
            var gData = Map<String, dynamic>.from(doc.data()!);
            gData['id'] = doc.id;
            return gData;
          })
          .toList();
    } catch (e) {
      print("Error fetching groups details: $e");
      return [];
    }
  }

  // Stream members of a specific group
  Stream<List<Map<String, dynamic>>> getGroupMembersDataStream(List<dynamic> memberIds) {
    if (memberIds.isEmpty) return Stream.value([]);
    return _db.collection('users').where(FieldPath.documentId, whereIn: memberIds).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = Map<String, dynamic>.from(doc.data() ?? {});
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Helper to get today's string
  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Stream intake for a list of users for today
  Stream<Map<String, int>> getMembersIntakeStream(List<dynamic> memberIds) {
    if (memberIds.isEmpty) return Stream.value({});
    
    // We'll create a stream that combines individual user intake streams
    // For simplicity in a client-side POC, we poll every 5 seconds.
    // In a production app, we would use a collectionGroup query with listeners.
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      try {
        Map<String, int> intakeMap = {};
        final futures = memberIds.map((mId) async {
          var doc = await _db.collection('users').doc(mId.toString()).collection('consumption').doc(_todayStr).get();
          return MapEntry(mId.toString(), doc.exists ? (doc.data()?['intake'] ?? 0) as int : 0);
        });
        
        final entries = await Future.wait(futures);
        for (var entry in entries) {
          intakeMap[entry.key] = entry.value;
        }
        return intakeMap;
      } catch (e) {
        print("Error fetching members intake: $e");
        return {};
      }
    });
  }

  int min(int a, int b) => a < b ? a : b;
}
