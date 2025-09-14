import 'dart:ui';
import 'package:flutter/material.dart';

// A simple extension to make the original code work without changes.
// Using .withOpacity() is generally more idiomatic in Flutter.
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
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent, // Assuming this is inside another widget with a background
      body: Stack(
        children: [
          // This is the background that will be blurred
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
                children: [
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
                      // Change sigmaX/sigmaY here to control the blur amount.
                      // You WILL now see this change.
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        padding: const EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                          // The container's color must be semi-transparent to see the blur
                          color: colorScheme.surface.withValues(alpha: 0.25),
                          border: Border.all(
                            color: colorScheme.surface.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          // The border radius is now controlled by the parent ClipRRect
                          // but you can add it here too if your border needs it.
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Today's Progress",
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Icon(
                              Icons.water_drop,
                              color: colorScheme.onSurface,
                              size: 60,
                            ),
                            const SizedBox(height: 10),
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