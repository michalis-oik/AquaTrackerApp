import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_tracking_app/utils/glassmorphism_card.dart';

extension ColorValues on Color {
  Color withValues({double? opacity}) {
    if (opacity == null) return this;
    return withAlpha((opacity * 255).round().clamp(0, 255));
  }
}

class DrinkSelectionPage extends StatelessWidget {
  const DrinkSelectionPage({super.key});

  final List<Map<String, dynamic>> drinks = const [
    {'name': 'Water', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'Coffee', 'icon': Icons.coffee, 'color': Colors.brown},
    {'name': 'Tea', 'icon': Icons.emoji_food_beverage, 'color': Colors.orange},
    {'name': 'Juice', 'icon': Icons.local_drink, 'color': Colors.orangeAccent},
    {'name': 'Soda', 'icon': Icons.local_bar, 'color': Colors.purple}, 
    {'name': 'Milk', 'icon': Icons.bedroom_baby, 'color': Colors.grey}, 
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surface.withValues(alpha: 0.2),
                          ),
                          child: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Repick Drink",
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: drinks.length,
                      itemBuilder: (context, index) {
                        final drink = drinks[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, drink);
                          },
                          child: GlassmorphismCard(
                            padding: const EdgeInsets.all(15),
                            borderRadius: 20,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (drink['color'] as Color).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    drink['icon'],
                                    size: 32,
                                    color: drink['color'],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  drink['name'],
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
