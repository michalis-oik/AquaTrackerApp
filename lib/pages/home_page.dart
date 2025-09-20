import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_tracking_app/utils/calendarDayBox.dart'; // Make sure this path is correct

// A simple extension to make the original code work without changes.
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
  int _selectedIndex = 1; // 1 corresponds to Tuesday in our list

  final List<Map<String, String>> days = [
    {'dayOfWeek': 'Mon', 'dayOfMonth': '11'},
    {'dayOfWeek': 'Tue', 'dayOfMonth': '12'}, // This is our initial "current day"
    {'dayOfWeek': 'Wed', 'dayOfMonth': '13'},
    {'dayOfWeek': 'Thu', 'dayOfMonth': '14'},
    {'dayOfWeek': 'Fri', 'dayOfMonth': '15'},
    {'dayOfWeek': 'Sat', 'dayOfMonth': '16'},
    {'dayOfWeek': 'Sun', 'dayOfMonth': '17'},
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ... (Container with gradient remains the same)
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
                  // ... (Top Row with profile and notifications remains the same)
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
                              "Today, 12 June 2025",
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // --- REPLACEMENT CODE STARTS HERE ---
                            Row(
                              children: List.generate(days.length, (index) {
                                return Expanded(
                                  child: Padding(
                                    // Add some spacing between the items
                                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedIndex = index;
                                        });
                                      },
                                      child: Calendardaybox(
                                        dayOfWeek: days[index]['dayOfWeek']!,
                                        dayOfMonth: days[index]['dayOfMonth']!,
                                        isSelected: _selectedIndex == index,
                                        isCurrentDay: index == 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // --- REPLACEMENT CODE ENDS HERE ---
                            
                            const SizedBox(height: 15),
                            Text(
                              "800 / 2210ml",
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}