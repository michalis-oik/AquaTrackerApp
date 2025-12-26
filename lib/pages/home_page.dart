import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_tracking_app/utils/calendarDayBox.dart';
import 'package:water_tracking_app/utils/glassmorphism_card.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:water_tracking_app/utils/hydrationStatsChart.dart';
import 'package:water_tracking_app/pages/drink_selection_page.dart';

extension ColorValues on Color {
  Color withValues({double? opacity}) {
    if (opacity == null) return this;
    // We convert the double (0.0 to 1.0) to an integer alpha value (0 to 255) internally.
    return withAlpha((opacity * 255).round().clamp(0, 255));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State management variables
  int _currentWaterIntake = 0;
  final int _dailyGoal = 2210;

  Map<String, dynamic> _selectedDrink = {'name': 'Water', 'icon': Icons.water_drop, 'color': Colors.blue, 'defaultAmount': 250};
  
  List<double> myHydrationWeeklyData = [55, 38, 70, 48, 48, 70, 75];

  List<Map<String, String>> _weekDays = [];
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
      });
    }
  }

  void _addWater() {
    setState(() {
      _currentWaterIntake += 250;
    });
  }
  
  Widget _buildWaterTrackerCardContent(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    
    final double percentageOfGoal = (_currentWaterIntake / _dailyGoal) * 100;
    final double percentageDifference = percentageOfGoal - 100;
    
    final String sign = percentageDifference >= 0 ? '+' : '';
    final String goalStatusText = "$sign${percentageDifference.toStringAsFixed(0)}%";
    
    final Color goalStatusColor = percentageDifference >= 0 
        ? Colors.green.shade400 
        : colorScheme.onSurface.withValues(alpha: 0.8);

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
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Calendardaybox(
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.surface.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.water_drop_outlined, color: colorScheme.primary, size: 28),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${_currentWaterIntake}ml",
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.surface.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.track_changes_outlined, color: goalStatusColor, size: 28),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Stay hydrated, stay healthy!",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7)
                ),
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  // Elevated Button with shadow
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        // The borderRadius here MUST MATCH the button's borderRadius
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.5), // Glow color
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(-2, 5), // changes position of shadow
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
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        ),
                        child: Text(
                          "Drink ${_selectedDrink['name']}\n(${_selectedDrink['defaultAmount']}ml)",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentWaterIntake += (_selectedDrink['defaultAmount'] as int);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Use a SizedBox to give the Stack a predictable size, 
                  // making it easier to position the small icon.
                  SizedBox(
                    width: 40,  // Adjust size as needed
                    height: 40, // Must be the same as width for a circle
                    child: Stack(
                      // This allows the small icon to "poke out" without being cut off.
                      clipBehavior: Clip.none, 
                      children: [
                        // --- 1. Your Main Circular Button (the bottom layer) ---
                        // This is the same code you had, now as the first child of the Stack.
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.5),
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
                              padding: const EdgeInsets.all(4), // Increased padding for a better look
                              elevation: 0,
                            ),
                            child: _selectedDrink['name'] == 'Water'
                                ? Image.asset(
                                    'assets/icons/glass-waterIcon.png',
                                    color: colorScheme.onPrimary, // Match the foregroundColor
                                    width: 20,
                                    height: 20,
                                  )
                                : Icon(
                                    _selectedDrink['icon'],
                                    color: colorScheme.onPrimary,
                                    size: 20,
                                  ),
                            onPressed: () async {
                              final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DrinkSelectionPage(
                                  initialIntake: _currentWaterIntake,
                                  dailyGoal: _dailyGoal,
                                  initialSelectedDrink: _selectedDrink,
                                  onDrinkAdded: (amount) {
                                    setState(() {
                                      _currentWaterIntake += amount;
                                    });
                                  },
                                ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                _selectedDrink = result;
                              });
                            }
                            },
                          ),
                        ),

                        // --- 2. The Small "Repick" Icon (the top layer) ---
                        Positioned(
                          right: -3,  // Position it 0 pixels from the right edge of the Stack
                          bottom: 3, // Position it 0 pixels from the bottom edge of the Stack
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.all(2), // Space around the inner icon
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.secondary, // A contrasting color
                                // Optional: Add a small border to make it pop
                                border: Border.all(color: colorScheme.primary, width: 1),
                              ),
                              child: Icon(
                                Icons.swap_horiz,
                                color: colorScheme.primary,
                                size: 7,
                                // --- ADD THIS SHADOWS PROPERTY ---
                                shadows: [
                                  Shadow(
                                    color: colorScheme.primary, // The same color as the icon
                                    blurRadius: 0.5,           // A very small blur radius
                                  ),
                                  // You can even add a second layer for more "boldness"
                                  Shadow(
                                    color: colorScheme.primary,
                                    blurRadius: 1.0,
                                  ),
                                ],
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
        // Text(
        //   "${_dailyGoal}ml",
        //   style: textTheme.headlineSmall?.copyWith(
        //     color: colorScheme.primary,
        //     fontWeight: FontWeight.bold
        //   ),
        // ),
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 10.0,
          // percent should be between 0.0 and 1.0 and I want it to see from currentintake to dailygoal. if current intake is > daily goal then put 1.0
          percent:(_currentWaterIntake / _dailyGoal).clamp(0.0, 1.0), // value between 0.0 and 1.0
          animation: true,
          animationDuration: 80,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.3),
          progressColor: colorScheme.primary,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_dailyGoal}ml",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "${(_dailyGoal - _currentWaterIntake).clamp(0, double.infinity).toStringAsFixed(0)}ml",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.7),
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
                  // Static Top Row (remains the same)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.primary,
                            child: Icon(Icons.person, color: colorScheme.onPrimary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                "John Doe",
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
                        child: Icon(Icons.notifications_none, color: colorScheme.onPrimary, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Scrollable Content Area
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
                          HydrationStatsChart(weeklyData: myHydrationWeeklyData),
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