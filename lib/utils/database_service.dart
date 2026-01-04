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

  // Stream user settings (goal)
  Stream<DocumentSnapshot> getUserSettingsStream() {
    return _db.collection('users').doc(uid).snapshots();
  }
}
