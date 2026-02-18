import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String adminId;
  final int dailyGoal;
  final List<String> members;
  final Map<String, int> memberIntakes;
  final String inviteCode;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.dailyGoal,
    required this.members,
    required this.memberIntakes,
    required this.inviteCode,
    this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data, String id) {
    return GroupModel(
      id: id,
      name: data['name'] ?? 'Team',
      adminId: data['adminId'] ?? '',
      dailyGoal: (data['dailyGoal'] as num?)?.toInt() ?? 5000,
      members: List<String>.from(data['members'] ?? []),
      memberIntakes: Map<String, int>.from(
        (data['memberIntakes'] as Map<dynamic, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      ),
      inviteCode: data['inviteCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory GroupModel.fromSnapshot(DocumentSnapshot doc) {
    return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'dailyGoal': dailyGoal,
      'members': members,
      'memberIntakes': memberIntakes,
      'inviteCode': inviteCode,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
