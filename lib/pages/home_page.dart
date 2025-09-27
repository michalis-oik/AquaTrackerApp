import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_tracking_app/utils/calendarDayBox.dart';

// --- UPDATED EXTENSION ---
// This version now correctly handles a double for opacity, just as you wanted.
// It's more intuitive and works like the old `withOpacity`.
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
  int _currentWaterIntake = 800;
  final int _dailyGoal = 2210;

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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // Calculations for the display boxes
    final double percentageOfGoal = (_currentWaterIntake / _dailyGoal) * 100;
    final double percentageDifference = percentageOfGoal - 100;
    
    final String sign = percentageDifference >= 0 ? '+' : '';
    final String goalStatusText = "$sign${percentageDifference.toStringAsFixed(0)}%";
    
    final Color goalStatusColor = percentageDifference >= 0 
        ? Colors.green.shade400 
        : colorScheme.onSurface.withValues(alpha: 0.8);


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Now using the clean, correct syntax
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Removed bottom padding for edge-to-edge scroll
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static Top Row
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
                          // Glassmorphism Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(alpha: 0.25),
                                  border: Border.all(color: colorScheme.surface.withValues(alpha: 0.4), width: 1.5),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Column(
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
                                                Text(
                                                  "${_currentWaterIntake}ml",
                                                  style: textTheme.titleLarge?.copyWith(
                                                    color: colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Total Drunk",
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                  ),
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
                                                Text(
                                                  goalStatusText,
                                                  style: textTheme.titleLarge?.copyWith(
                                                    color: colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Goal Progress",
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Add Water Button (now inside the scroll view)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addWater,
                              icon: const Icon(Icons.add),
                              label: const Text("Add 250ml"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                           const SizedBox(height: 20), // Padding at the very bottom
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