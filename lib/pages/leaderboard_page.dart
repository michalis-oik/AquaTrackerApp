import 'package:flutter/material.dart';
import 'package:water_tracking_app/utils/database_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  final int myIntake;
  final String myAvatar;
  const LeaderboardPage({super.key, required this.myIntake, required this.myAvatar});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  
  List<Map<String, dynamic>> _userGroups = [];
  Map<String, List<Map<String, dynamic>>> _groupMembers = {};
  Map<String, Map<String, int>> _groupIntakes = {};
  
  StreamSubscription? _groupsSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _setupGroupsListener();

    // Absolute fallback: Show UI after 4 seconds no matter what
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _setupGroupsListener() {
    _groupsSubscription = _db.getUserGroupsStream().listen((userDoc) async {
      if (!mounted) return;
      
      List groupIds = [];
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        groupIds = data['groups'] as List? ?? [];
      }

      if (groupIds.isEmpty) {
        if (mounted) {
          setState(() {
            _userGroups = [];
            _isLoading = false;
            _updateTabController(0);
          });
        }
        return;
      }

      // Fetch details outside of the stream generator to prevent hangs
      final details = await _db.getGroupsDetails(groupIds);
      
      if (!mounted) return;

      setState(() {
        _userGroups = details;
        _isLoading = false;
        _updateTabController(_userGroups.length);
      });

      for (var group in details) {
        _setupMemberDataListener(group['id'], group['members']);
        _setupIntakeListener(group['id'], group['members']);
      }
    }, onError: (err) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _updateTabController(int newLength) {
    int oldIndex = _tabController.index;
    int safeLength = newLength > 0 ? newLength : 1;
    
    if (safeLength != _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: safeLength,
        vsync: this,
        initialIndex: (newLength > 0 && oldIndex < newLength) ? oldIndex : 0
      );
    }
  }

  void _setupMemberDataListener(String groupId, List memberIds) {
    _db.getGroupMembersDataStream(memberIds).listen((memberData) {
      if (mounted) {
        setState(() {
          _groupMembers[groupId] = memberData;
        });
      }
    });
  }

  void _setupIntakeListener(String groupId, List memberIds) {
    _db.getMembersIntakeStream(memberIds).listen((intakeMap) {
      if (mounted) {
        setState(() {
          _groupIntakes[groupId] = intakeMap;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showCreateGroupDialog() async {
    String groupName = "";
    int goal = 10000;
    
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
              decoration: const InputDecoration(labelText: 'Team Daily Goal (ml)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => goal = int.tryParse(val) ?? 10000,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (groupName.isNotEmpty) {
                await _db.createGroup(groupName, goal);
                if (context.mounted) Navigator.pop(context);
              }
            }, 
            child: const Text('Create')
          ),
        ],
      )
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (code.isNotEmpty) {
                bool success = await _db.joinGroupByCode(code);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Invite Code')));
                  }
                }
              }
            }, 
            child: const Text('Join')
          ),
        ],
      )
    );
  }

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
                colors: [colorScheme.primary.withAlpha(179), colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
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
                              icon: Icon(Icons.group_add_rounded, color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (_userGroups.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Teams Yet", style: textTheme.titleLarge),
                          const SizedBox(height: 10),
                          ElevatedButton(onPressed: _showCreateGroupDialog, child: const Text("Create a Team")),
                          TextButton(onPressed: _showJoinGroupDialog, child: const Text("Join with Code")),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurface.withOpacity(0.4),
                      indicatorColor: colorScheme.primary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      tabs: _userGroups.map((group) => Tab(text: group['name'])).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: _userGroups.map((group) => _buildGroupView(group)).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupView(Map<String, dynamic> group) {
    final colorScheme = Theme.of(context).colorScheme;
    String gId = group['id'];
    List membersData = _groupMembers[gId] ?? [];
    Map<String, int> intakes = _groupIntakes[gId] ?? {};
    
    int currentTotal = intakes.values.fold(0, (sum, val) => sum + val);
    int goal = group['dailyGoal'] ?? 10000;
    if (goal <= 0) goal = 10000;
    double progress = (currentTotal / goal).clamp(0.0, 1.0);

    List<Map<String, dynamic>> memberSlots = membersData.map((m) {
      String uid = m['uid'] ?? '';
      return {
        'name': uid == _db.uid ? 'You' : (m['displayName'] ?? 'User'),
        'intake': intakes[uid] ?? 0,
        'avatar': m['profileIcon'] ?? '👤',
        'isMe': uid == _db.uid,
      };
    }).toList();

    memberSlots.sort((a, b) => (b['intake'] as int).compareTo(a['intake'] as int));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 10),
        _buildGroupGoalCard(group, currentTotal, goal, progress),
        const SizedBox(height: 20),
        Center(child: SelectableText("Invite Code: ${group['inviteCode']}", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hydration Rankings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
            ),
            TextButton(
              onPressed: () {}, 
              child: Text('View All', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600))
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (memberSlots.isNotEmpty) _buildPodium(memberSlots),
        const SizedBox(height: 30),
        ...memberSlots.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          int groupGoal = group['dailyGoal'] ?? 2500;
          if (groupGoal <= 0) groupGoal = 2500;
          int percentage = ((member['intake'] as int) / groupGoal * 100).toInt();
          return _buildMemberTile(member, index + 1, percentage);
        }),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildGroupGoalCard(Map<String, dynamic> group, int current, int goal, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(51), // Translucent inside
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // Softer white outline
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Team Daily Progress',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$current', style: TextStyle(color: colorScheme.onSurface, fontSize: 32, fontWeight: FontWeight.bold)),
               Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text('ml', style: TextStyle(color: colorScheme.onSurface.withAlpha(128), fontSize: 16)),
              ),
              const Spacer(),
              Text('Goal: $goal ml', style: TextStyle(color: colorScheme.onSurface.withAlpha(153), fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                height: 12,
                width: (MediaQuery.of(context).size.width - 84) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPodium(List<Map<String, dynamic>> members) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        members.length >= 2 
            ? _buildPodiumItem(members[1], 2, 80) 
            : _buildEmptyPodiumItem(2, 80),
        
        // 1st Place
        members.isNotEmpty 
            ? _buildPodiumItem(members[0], 1, 110) 
            : _buildEmptyPodiumItem(1, 110),
        
        // 3rd Place
        members.length >= 3 
            ? _buildPodiumItem(members[2], 3, 70) 
            : _buildEmptyPodiumItem(3, 70),
      ],
    );
  }

  Widget _buildEmptyPodiumItem(int rank, double height) {
    // Making silver and bronze more distinct and visible
    final color = rank == 1 
        ? const Color(0xFFFFD700) // Gold
        : (rank == 2 
            ? const Color(0xFFA0A0A0) // Distinct Silver
            : const Color(0xFFB87333)); // Copper/Bronze
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 3, style: BorderStyle.solid),
          ),
          child: Center(
            child: Icon(Icons.person_outline, color: color.withOpacity(0.3), size: 30),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Waiting...', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), // Increased opacity for better visibility
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> member, int rank, double height) {
    final color = rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFFC4C4C4) : const Color(0xFFCD7F32));
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Center(
                child: Text(member['avatar'], style: const TextStyle(fontSize: 38)),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Rank $rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3142), fontSize: 16)),
        Text('${member['intake']} ml', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.6), color.withOpacity(0.1)], 
              begin: Alignment.topCenter, 
              end: Alignment.bottomCenter
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: rank == 1 ? const Icon(Icons.emoji_events, color: Colors.white, size: 28) : null,
        ),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int rank, int percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isMe = member['isMe'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isMe ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface.withAlpha(51),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: isMe ? colorScheme.primary.withOpacity(0.8) : Colors.white.withOpacity(0.5), 
          width: isMe ? 2.0 : 1.5
        ),
      ),
      child: Row(
        children: [
          Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 18)),
          const SizedBox(width: 20),
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(child: Text(member['avatar'], style: const TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorScheme.onSurface)),
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 12, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Hydrated', style: TextStyle(color: colorScheme.onSurface.withAlpha(102), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${member['intake']} ml', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorScheme.onSurface)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F9E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('↑ $percentage%', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
