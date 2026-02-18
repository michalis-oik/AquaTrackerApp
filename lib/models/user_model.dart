import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String profileIcon;
  final int dailyGoal;
  final List<String> groups;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.profileIcon,
    required this.dailyGoal,
    required this.groups,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      displayName: data['displayName'] ?? 'User',
      profileIcon: data['profileIcon'] ?? '👤',
      dailyGoal: (data['dailyGoal'] as num?)?.toInt() ?? 2500,
      groups: List<String>.from(data['groups'] ?? []),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'profileIcon': profileIcon,
      'dailyGoal': dailyGoal,
      'groups': groups,
    };
  }
}
