import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  final int myIntake;
  const LeaderboardPage({super.key, required this.myIntake});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<Map<String, dynamic>> _groups;

  @override
  void initState() {
    super.initState();
    _groups = [
      {
        'id': '1',
        'name': 'Hydration Heroes',
        'goal': 15000,
        'current': 12450 + (widget.myIntake > 2100 ? widget.myIntake - 2100 : 0),
        'members': [
          {'name': 'You', 'intake': widget.myIntake, 'avatar': '👤', 'isMe': true},
          {'name': 'Alex', 'intake': 2800, 'avatar': '🦊', 'isMe': false},
          {'name': 'Sarah', 'intake': 2400, 'avatar': '🦄', 'isMe': false},
          {'name': 'Mike', 'intake': 1950, 'avatar': '🐻', 'isMe': false},
          {'name': 'Elena', 'intake': 3200, 'avatar': '🐱', 'isMe': false},
        ],
      },
      {
        'id': '2',
        'name': 'Office Squad',
        'goal': 10000,
        'current': 6200 + (widget.myIntake > 2100 ? widget.myIntake - 2100 : 0),
        'members': [
          {'name': 'You', 'intake': widget.myIntake, 'avatar': '👤', 'isMe': true},
          {'name': 'John', 'intake': 1500, 'avatar': '🦁', 'isMe': false},
          {'name': 'Emily', 'intake': 2600, 'avatar': '🐰', 'isMe': false},
        ],
      },
    ];
    _tabController = TabController(length: _groups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient matching HomePage
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.group_add_rounded, color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                // Group Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    tabs: _groups.map((group) => Tab(text: group['name'])).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _groups.map((group) => _buildGroupView(group)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupView(Map<String, dynamic> group) {
    final double progress = (group['current'] / group['goal']).clamp(0.0, 1.0);
    final List<Map<String, dynamic>> members = List<Map<String, dynamic>>.from(group['members']);
    members.sort((a, b) => (b['intake'] as int).compareTo(a['intake'] as int));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 10),
        // Group Goal Card
        _buildGroupGoalCard(group, progress),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hydration Rankings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Top 3 Podium
        if (members.length >= 3) _buildPodium(members.take(3).toList()),
        const SizedBox(height: 25),
        // Full List
        ...members.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return _buildMemberTile(member, index + 1);
        }),
        const SizedBox(height: 120), // Extra space for floating nav bar
      ],
    );
  }

  Widget _buildGroupGoalCard(Map<String, dynamic> group, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
              const Text(
                'Team Daily Progress',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${group['current']}',
                style: const TextStyle(
                  color: Color(0xFF2D3142),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'ml',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const Spacer(),
              Text(
                'Goal: ${group['goal']} ml',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                height: 12,
                width: MediaQuery.of(context).size.width * 0.75 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Keep it up! 5 more members drinking will hit the goal!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> topThree) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumItem(topThree[1], 2, 80), // 2nd
        _buildPodiumItem(topThree[0], 1, 110), // 1st
        _buildPodiumItem(topThree[2], 3, 70), // 3rd
      ],
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> member, int rank, double height) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = rank == 1 ? const Color(0xFFFFD700) : (rank == 2 ? const Color(0xFFC4C4C4) : const Color(0xFFCD7F32));
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  member['avatar'],
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                ],
              ),
              child: Text(
                'Rank $rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          member['name'],
          style: TextStyle(
            fontWeight: member['isMe'] ? FontWeight.bold : FontWeight.bold,
            color: member['isMe'] ? colorScheme.primary : const Color(0xFF2D3142),
            fontSize: 14,
          ),
        ),
        Text(
          '${member['intake']} ml',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (rank == 1) const Icon(Icons.emoji_events, color: Colors.white, size: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member, int rank) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(member['isMe'] ? 0.7 : 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: member['isMe'] ? colorScheme.primary.withOpacity(0.5) : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.transparent : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? colorScheme.primary : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Center(
              child: Text(
                member['avatar'],
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'] == 'You' ? 'You' : member['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: member['isMe'] ? colorScheme.primary : const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 12, color: Colors.blue.shade300),
                    const SizedBox(width: 4),
                    Text(
                      'Hydrated',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member['intake']} ml',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D3142),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 10, color: Colors.green.shade600),
                    const SizedBox(width: 2),
                    Text(
                      '${(member['intake'] / 3000 * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
