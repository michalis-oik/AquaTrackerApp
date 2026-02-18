import 'package:flutter/material.dart';
import 'package:water_tracking_app/widgets/glassmorphism_card.dart';

class RemindersPage extends StatefulWidget {
  final int currentIntake;
  final int dailyGoal;

  const RemindersPage({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
  });

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final List<Map<String, dynamic>> records = [
    {
      'time': '05:00 PM',
      'label': 'Next time',
      'amount': '200 ml',
      'isUpcoming': true,
      'icon': Icons.alarm_rounded,
      'color': Colors.deepPurpleAccent,
    },
    {
      'time': '03:00 PM',
      'label': 'Water',
      'amount': '200 ml',
      'isUpcoming': false,
      'icon': Icons.local_drink_rounded,
      'color': Colors.lightBlueAccent,
    },
    {
      'time': '01:00 PM',
      'label': 'Coffee',
      'amount': '200 ml',
      'isUpcoming': false,
      'icon': Icons.coffee_rounded,
      'color': Colors.orangeAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient matching the app theme
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
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderButton(Icons.chevron_left, () {}),
                      Text(
                        "Reminders",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      _buildHeaderButton(Icons.more_horiz, () {}),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Circular Progress (Liquid Visualization)
                        _buildLiquidProgressIndicator(context),

                        const SizedBox(height: 30),

                        // Today Selector & Time Range
                        _buildTimeFilterSection(context),

                        const SizedBox(height: 40),

                        // Records List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's records",
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: records.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 15),
                                itemBuilder: (context, index) {
                                  return _buildRecordCard(
                                    context,
                                    records[index],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom nav
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

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(10),
        borderRadius: 50,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLiquidProgressIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double percentage = (widget.currentIntake / widget.dailyGoal).clamp(
      0.0,
      1.0,
    );

    return SizedBox(
      width: 280,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withAlpha(51),
                width: 10,
              ),
            ),
          ),

          // Outer progress arc
          SizedBox(
            width: 210,
            height: 210,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Liquid Container
          ClipOval(
            child: Container(
              width: 170,
              height: 170,
              color: colorScheme.surface.withAlpha(77),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 170 * percentage,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withAlpha(153),
                            colorScheme.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.currentIntake}/${widget.dailyGoal}ml",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            bottom: 40,
            child: Icon(
              Icons.favorite,
              color: Colors.orange.shade300,
              size: 28,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 40,
            child: Icon(
              Icons.water_drop,
              color: Colors.blue.shade300,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Today",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPillContainer("09:00 AM"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("-  2h  -", style: TextStyle(color: Colors.grey)),
            ),
            _buildPillContainer("11:00 PM"),
          ],
        ),
      ],
    );
  }

  Widget _buildPillContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildRecordCard(BuildContext context, Map<String, dynamic> record) {
    return GlassmorphismCard(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: record['isUpcoming']
                  ? record['color'].withAlpha(204)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              record['icon'],
              color: record['isUpcoming'] ? Colors.white : record['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['time'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  record['label'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            record['amount'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Icon(
            record['isUpcoming']
                ? Icons.hourglass_top_rounded
                : Icons.more_vert,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
