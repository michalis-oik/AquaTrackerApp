import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- IMPORT a package for date formatting
import 'package:water_tracking_app/utils/calendarDayBox.dart';

// This extension is fine, but Flutter's built-in `withOpacity` is often more readable.
// For example, `colorScheme.onSurface.withOpacity(0.7)`
// I'll keep your version to avoid breaking changes.
extension ColorValues on Color {
  Color withValues({int? alpha}) {
    return withAlpha(alpha ?? this.alpha);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- STATE MANAGEMENT START ---
  // These variables will now drive our UI
  int _currentWaterIntake = 800; // Example starting value
  final int _dailyGoal = 2210; // The user's daily goal

  // State for the dynamic calendar
  List<Map<String, String>> _weekDays = [];
  int _selectedIndex = 0; // Index of the selected day
  int _currentDayIndex = 0; // Index of today's date
  // --- STATE MANAGEMENT END ---

  @override
  void initState() {
    super.initState();
    _generateWeekDays(); // Generate the calendar days when the widget is first created
  }

  // --- NEW: A method to dynamically generate the past 7 days ---
  void _generateWeekDays() {
    _weekDays = [];
    DateTime now = DateTime.now();

    // Find the index of today (0=Mon, 6=Sun) to correctly highlight it
    _currentDayIndex = now.weekday - 1;
    _selectedIndex = _currentDayIndex;

    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: _currentDayIndex - i));
      _weekDays.add({
        'dayOfWeek': DateFormat('E').format(date), // 'E' gives short day name (e.g., "Mon")
        'dayOfMonth': DateFormat('d').format(date), // 'd' gives the day number
      });
    }
  }

  // --- NEW: A method to add water and update the state ---
  void _addWater() {
    setState(() {
      // Add a standard glass of water (250ml)
      _currentWaterIntake += 250;
      // Optional: Prevent intake from exceeding the goal if you want
      // if (_currentWaterIntake > _dailyGoal) {
      //   _currentWaterIntake = _dailyGoal;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // --- NEW: Calculate the progress for the indicator ---
    double progress = _currentWaterIntake / _dailyGoal;
    if (progress > 1.0) progress = 1.0; // Cap progress at 100%

    return Scaffold(
      backgroundColor: Colors.transparent, // Keeps the gradient from main.dart visible
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row with profile and notifications (No changes here)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.primary,
                            child: Icon(
                              Icons.person,
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
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
                        child: Icon(
                          Icons.notifications_none,
                          color: colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

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
                          border: Border.all(
                            color: colorScheme.surface.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // --- UPDATED: Dynamic Date ---
                              "Today, ${DateFormat('d MMMM yyyy').format(DateTime.now())}",
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // --- UPDATED: Dynamic Calendar Row ---
                            Row(
                              children: List.generate(_weekDays.length, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedIndex = index;
                                        });
                                      },
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
                            
                            const SizedBox(height: 25), // Increased spacing

                            // --- UPDATED: Water intake text driven by state ---
                            Text(
                              "$_currentWaterIntake / $_dailyGoal ml",
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // --- NEW: Progress Indicator ---
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 12,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(), // Pushes the button to the bottom

                  // --- NEW: Add Water Button ---
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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