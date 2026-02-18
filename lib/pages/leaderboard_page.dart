import 'package:flutter/material.dart';
import 'package:water_tracking_app/services/database_service.dart';
import 'package:water_tracking_app/models/group_model.dart';
import 'package:water_tracking_app/models/user_model.dart';
import 'package:water_tracking_app/widgets/leaderboard/group_goal_card.dart';
import 'package:water_tracking_app/widgets/leaderboard/podium_widget.dart';
import 'dart:async';

class LeaderboardPage extends StatefulWidget {
  final int myIntake;
  final String myAvatar;
  const LeaderboardPage({
    super.key,
    required this.myIntake,
    required this.myAvatar,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final DatabaseService _db = DatabaseService();

  List<GroupModel> _userGroups = [];
  Map<String, List<UserModel>> _groupMembers = {};

  StreamSubscription? _groupsSubscription;
  final Map<String, StreamSubscription> _memberSubscriptions = {};
  bool _isLoading = true;
  final Map<String, List<String>> _groupMemberLists = {};

  @override
  void initState() {
    super.initState();
    _setupGroupsListener();
    _db.syncIntakeToGroups(widget.myIntake);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _setupGroupsListener() {
    _groupsSubscription = _db.getGroupsStream().listen(
      (groups) {
        if (!mounted) return;

        setState(() {
          _userGroups = groups;
          _isLoading = false;
          if (groups.isEmpty) {
            _clearSubSubscriptions();
          }
        });

        if (groups.isNotEmpty) {
          _syncSubSubscriptions(groups);
        }
      },
      onError: (err) {
        debugPrint("Groups stream error: $err");
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  void _clearSubSubscriptions() {
    for (var sub in _memberSubscriptions.values) {
      sub.cancel();
    }
    _memberSubscriptions.clear();
  }

  void _syncSubSubscriptions(List<GroupModel> groups) {
    Set<String> activeGroupIds = groups.map((g) => g.id).toSet();

    _memberSubscriptions.removeWhere((id, sub) {
      if (!activeGroupIds.contains(id)) {
        sub.cancel();
        return true;
      }
      return false;
    });

    for (var group in groups) {
      String id = group.id;
      List<String> members = group.members;

      bool membersChanged = false;
      if (_groupMemberLists.containsKey(id)) {
        List<String> oldMembers = _groupMemberLists[id]!;
        if (oldMembers.length != members.length ||
            !oldMembers.every((m) => members.contains(m))) {
          membersChanged = true;
        }
      }

      bool needsRefresh =
          !_memberSubscriptions.containsKey(id) || membersChanged;

      if (needsRefresh) {
        _memberSubscriptions[id]?.cancel();

        _groupMemberLists[id] = members;
        _setupMemberDataListener(id, members);
      }
    }
  }

  void _setupMemberDataListener(String groupId, List<String> memberIds) {
    _memberSubscriptions[groupId] = _db.getGroupMembersStream(memberIds).listen(
      (memberData) {
        if (mounted) {
          setState(() {
            _groupMembers[groupId] = memberData;
          });
        }
      },
      onError: (e) => debugPrint("Member data error: $e"),
    );
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    _clearSubSubscriptions();
    super.dispose();
  }

  // --- UI Methods ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withAlpha(179),
                  colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(colorScheme, textTheme),
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_userGroups.isEmpty)
                  _buildEmptyState(textTheme)
                else
                  Expanded(
                    child: DefaultTabController(
                      length: _userGroups.length,
                      key: ValueKey('leaderboard_tabs_${_userGroups.length}'),
                      child: Column(
                        children: [
                          _buildTabBar(colorScheme),
                          const SizedBox(height: 15),
                          Expanded(
                            child: TabBarView(
                              children: _userGroups
                                  .map((group) => _buildGroupView(group))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Leaderboard',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _showJoinGroupDialog,
                icon: Icon(Icons.add_link, color: colorScheme.primary),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _showCreateGroupDialog,
                  icon: Icon(
                    Icons.group_add_rounded,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No Teams Yet", style: textTheme.titleLarge),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              child: const Text("Create a Team"),
            ),
            TextButton(
              onPressed: _showJoinGroupDialog,
              child: const Text("Join with Code"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.4),
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        tabs: _userGroups.map((group) {
          bool isGroupAdmin = group.adminId == _db.uid;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group.name),
                if (isGroupAdmin) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star, size: 14),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupView(GroupModel group) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isAdmin = group.adminId == _db.uid;
    List<UserModel> membersData = _groupMembers[group.id] ?? [];

    List<Map<String, dynamic>> memberSlots = membersData.map((m) {
      bool isMe = m.uid == _db.uid;
      int memberIntake = isMe
          ? widget.myIntake
          : (group.memberIntakes[m.uid] ?? 0);

      return {
        'uid': m.uid,
        'name': isMe ? 'You' : m.displayName,
        'intake': memberIntake,
        'avatar': m.profileIcon,
        'isMe': isMe,
        'isAdmin': m.uid == group.adminId,
        'personalGoal': m.dailyGoal,
      };
    }).toList();

    int currentTotal = memberSlots.fold(
      0,
      (sum, m) => sum + (m['intake'] as int),
    );
    double progress = (currentTotal / group.dailyGoal).clamp(0.0, 1.0);

    memberSlots.sort(
      (a, b) => (b['intake'] as int).compareTo(a['intake'] as int),
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        const SizedBox(height: 10),
        GroupGoalCard(
          title: 'Team Daily Progress',
          currentIntake: currentTotal,
          dailyGoal: group.dailyGoal,
          progress: progress,
        ),
        const SizedBox(height: 15),
        _buildGroupInviteRow(group, isAdmin),
        const SizedBox(height: 20),
        _buildRankingHeader(colorScheme),
        const SizedBox(height: 10),
        if (memberSlots.isNotEmpty) PodiumWidget(memberSlots: memberSlots),
        const SizedBox(height: 30),
        ...memberSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          int personalGoal = member['personalGoal'] ?? 2500;
          if (personalGoal <= 0) personalGoal = 2500;
          int percentage = ((member['intake'] as int) / personalGoal * 100)
              .toInt();
          return _buildMemberTile(member, index + 1, percentage);
        }),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildGroupInviteRow(GroupModel group, bool isAdmin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Center(
            child: SelectableText(
              "Invite Code: ${group.inviteCode}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onPressed: () =>
              _showGroupOptions(group.id, group.name, isAdmin, group.dailyGoal),
        ),
      ],
    );
  }

  Widget _buildRankingHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hydration Rankings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(
    Map<String, dynamic> member,
    int rank,
    int percentage,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isMe = member['isMe'] ?? false;
    bool isAdmin = member['isAdmin'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? colorScheme.primary.withOpacity(0.08)
            : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMe
              ? colorScheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? colorScheme.primary : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 22,
            child: Text(
              member['avatar'] ?? '👤',
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member['name'] ?? '',
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 5),
                      Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                    ],
                  ],
                ),
                Text(
                  'Goal progress: $percentage%',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member['intake']}ml',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Total drunk',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  Future<void> _showCreateGroupDialog() async {
    String groupName = "";
    int goal = 5000;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Team Name'),
              onChanged: (val) => groupName = val,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Team Daily Goal (ml)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) => goal = int.tryParse(val) ?? 5000,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (groupName.isNotEmpty) {
                await _db.createGroup(groupName, goal);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showJoinGroupDialog() async {
    String code = "";
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a Team'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Team Invite Code'),
          onChanged: (val) => code = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (code.isNotEmpty) {
                bool success = await _db.joinGroupByCode(code);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (!success)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid Invite Code')),
                    );
                }
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(
    String groupId,
    String groupName,
    bool isAdmin,
    int currentGoal,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (isAdmin) ...[
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Edit Team Name'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditNameDialog(groupId, groupName);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.flag,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Edit Daily Goal'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditGoalDialog(groupId, currentGoal);
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: Icon(
                  isAdmin ? Icons.delete_outline : Icons.exit_to_app,
                  color: Colors.red,
                ),
                title: Text(
                  isAdmin ? 'Delete Team' : 'Leave Team',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (isAdmin)
                    _confirmDeleteGroup(groupId, groupName);
                  else
                    _confirmLeaveGroup(groupId, groupName);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog(String groupId, String oldName) async {
    String newName = oldName;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Team Name'),
        content: TextField(
          onChanged: (v) => newName = v,
          controller: TextEditingController(text: oldName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.updateGroupName(groupId, newName);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditGoalDialog(String groupId, int oldGoal) async {
    String goalText = oldGoal.toString();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Daily Goal'),
        content: TextField(
          onChanged: (v) => goalText = v,
          controller: TextEditingController(text: oldGoal.toString()),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              int? n = int.tryParse(goalText);
              if (n != null) await _db.updateGroupGoal(groupId, n);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeaveGroup(String id, String name) async {
    return showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Leave Team'),
        content: Text('Leave "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.leaveGroup(id);
              if (mounted) Navigator.pop(c);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteGroup(String id, String name) async {
    return showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Delete "$name" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _db.deleteGroup(id);
              if (mounted) Navigator.pop(c);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
