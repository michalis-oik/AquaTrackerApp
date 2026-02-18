import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_tracking_app/widgets/calendar_day_box.dart';
import 'package:water_tracking_app/widgets/glassmorphism_card.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:water_tracking_app/widgets/hydration_stats_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final int currentIntake;
  final int historyIntake;
  final int dailyGoal;
  final Map<String, dynamic> selectedDrink;
  final VoidCallback onAddWater;
  final VoidCallback onSelectDrinkTap;
  final Function(DateTime) onDateSelected;
  final List<double> weeklyData;
  final DateTime selectedDate;
  final String profileIcon;

  const HomePage({
    super.key,
    required this.currentIntake,
    required this.historyIntake,
    required this.dailyGoal,
    required this.selectedDrink,
    required this.onAddWater,
    required this.onSelectDrinkTap,
    required this.onDateSelected,
    required this.weeklyData,
    required this.selectedDate,
    required this.profileIcon,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _weekDays = [];
  int _selectedIndex = 0;
  int _currentDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    _weekDays = [];
    DateTime now = DateTime.now();
    _currentDayIndex = now.weekday - 1;
    _selectedIndex = _currentDayIndex;

    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: _currentDayIndex - i));
      _weekDays.add({
        'dayOfWeek': DateFormat('E').format(date),
        'dayOfMonth': DateFormat('d').format(date),
        'fullDate': date,
      });
      // Synchronize initial selected index based on selectedDate prop
      if (DateFormat('yyyy-MM-dd').format(date) ==
          DateFormat('yyyy-MM-dd').format(widget.selectedDate)) {
        _selectedIndex = i;
      }
    }
  }

  Widget _buildWaterTrackerCardContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Use historyIntake for the top row card
    final double percentageOfGoal =
        (widget.historyIntake / widget.dailyGoal) * 100;
    final double percentageDifference = percentageOfGoal - 100;

    final String sign = percentageDifference >= 0 ? '+' : '';
    final String goalStatusText =
        "$sign${percentageDifference.toStringAsFixed(0)}%";

    final Color goalStatusColor = percentageDifference >= 0
        ? Colors.green.shade400
        : colorScheme.onSurface.withAlpha(204);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today, ${DateFormat('d MMMM yyyy').format(DateTime.now())}",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: List.generate(_weekDays.length, (index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onDateSelected(
                      _weekDays[index]['fullDate'] as DateTime,
                    );
                  },
                  child: CalendarDayBox(
                    dayOfWeek: _weekDays[index]['dayOfWeek']!,
                    dayOfMonth: _weekDays[index]['dayOfMonth']!,
                    isSelected: _selectedIndex == index,
                    isCurrentDay: _currentDayIndex == index,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(38),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.surface.withAlpha(51)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${widget.historyIntake}ml",
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Drunk",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(179),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withAlpha(38),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.surface.withAlpha(51)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.track_changes_outlined,
                      color: goalStatusColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        goalStatusText,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Goal Progress",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(179),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyGoalCardContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daily Drink Target",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Stay hydrated, stay healthy!",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha(179),
                ),
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withAlpha(128),
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(-2, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                        ),
                        onPressed: widget.onAddWater,
                        child: Text(
                          "Drink ${widget.selectedDrink['name']}\n(${widget.selectedDrink['defaultAmount']}ml)",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withAlpha(128),
                                spreadRadius: 2,
                                blurRadius: 15,
                                offset: const Offset(2, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(4),
                              elevation: 0,
                            ),
                            onPressed: widget.onSelectDrinkTap,
                            child: widget.selectedDrink['name'] == 'Water'
                                ? Image.asset(
                                    'assets/icons/glass-waterIcon.png',
                                    color: colorScheme.onPrimary,
                                    width: 20,
                                    height: 20,
                                  )
                                : Icon(
                                    widget.selectedDrink['icon'],
                                    color: colorScheme.onPrimary,
                                    size: 20,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: -3,
                          bottom: 3,
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.secondary,
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.swap_horiz,
                                color: colorScheme.primary,
                                size: 7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 10.0,
          percent: (widget.currentIntake / widget.dailyGoal).clamp(0.0, 1.0),
          animation: true,
          animationDuration: 600,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: colorScheme.primary.withAlpha(77),
          progressColor: colorScheme.primary,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.dailyGoal}ml",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${(widget.dailyGoal - widget.currentIntake).clamp(0, double.infinity).toStringAsFixed(0)}ml",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.primary,
                            child: Text(
                              widget.profileIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                              Text(
                                FirebaseAuth
                                        .instance
                                        .currentUser
                                        ?.displayName ??
                                    "User",
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: colorScheme.primary,
                        child: Icon(
                          Icons.notifications_none,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          GlassmorphismCard(
                            child: _buildWaterTrackerCardContent(context),
                          ),
                          const SizedBox(height: 20),
                          GlassmorphismCard(
                            child: _buildDailyGoalCardContent(context),
                          ),
                          const SizedBox(height: 20),
                          HydrationStatsChart(weeklyData: widget.weeklyData),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
