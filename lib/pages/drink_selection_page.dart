import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:water_tracking_app/utils/glassmorphism_card.dart';

extension ColorValues on Color {
  Color withValues({double? opacity}) {
    if (opacity == null) return this;
    return withAlpha((opacity * 255).round().clamp(0, 255));
  }
}

class DrinkSelectionPage extends StatefulWidget {
  final int initialIntake;
  final int dailyGoal;
  final Map<String, dynamic> initialSelectedDrink;
  final Function(int) onDrinkAdded;

  const DrinkSelectionPage({
    super.key,
    required this.initialIntake,
    required this.dailyGoal,
    required this.initialSelectedDrink,
    required this.onDrinkAdded,
  });

  @override
  State<DrinkSelectionPage> createState() => _DrinkSelectionPageState();
}

class _DrinkSelectionPageState extends State<DrinkSelectionPage> {
  late int _currentIntake;
  late Map<String, dynamic> _selectedDrink;

  final List<Map<String, dynamic>> drinks = const [
    {'name': 'Water', 'icon': Icons.water_drop, 'color': Color(0xFF4FC3F7), 'defaultAmount': 200},
    {'name': 'Kompot', 'icon': Icons.wine_bar_outlined, 'color': Color(0xFFFFB74D), 'defaultAmount': 150},
    {'name': 'Coffee', 'icon': Icons.coffee_rounded, 'color': Color(0xFFFFEE58), 'defaultAmount': 100},
    {'name': 'Wine', 'icon': Icons.wine_bar, 'color': Color(0xFFEF5350), 'defaultAmount': 200},
    {'name': 'Milk', 'icon': Icons.egg_outlined, 'color': Color(0xFFBDBDBD), 'defaultAmount': 250},
    {'name': 'Juice', 'icon': Icons.local_drink_rounded, 'color': Color(0xFFE57373), 'defaultAmount': 200},
  ];

  @override
  void initState() {
    super.initState();
    _currentIntake = widget.initialIntake;
    _selectedDrink = widget.initialSelectedDrink;
  }

  void _addDrink() {
    int amount = _selectedDrink['defaultAmount'] as int;
    setState(() {
      _currentIntake += amount;
    });
    widget.onDrinkAdded(amount);
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
          // Background Gradient matching Home
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircularButton(context, Icons.chevron_left, () => Navigator.pop(context, _selectedDrink)),
                      Text(
                        "Select Drink",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      _buildCircularButton(context, Icons.share_outlined, () {}),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Circular Progress/Liquid Visualization
                        _buildLiquidProgressIndicator(context),

                        const SizedBox(height: 30),
                        
                        // Action row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _addDrink,
                              child: GlassmorphismCard(
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                borderRadius: 30,
                                child: Text(
                                  "Drink ${_selectedDrink['defaultAmount']} ml",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
                              ),
                              child: Icon(
                                _selectedDrink['name'] == 'Water' ? Icons.water_drop : _selectedDrink['icon'], 
                                color: colorScheme.onSurface, 
                                size: 24
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Grid Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Drinks to intake",
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: drinks.length,
                                itemBuilder: (context, index) {
                                  final drink = drinks[index];
                                  final isSelected = _selectedDrink['name'] == drink['name'];
                                  return _buildDrinkCard(context, drink, isSelected);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildCircularButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(10),
        borderRadius: 50,
        child: Icon(icon, color: colorScheme.onSurface, size: 20),
      ),
    );
  }

  Widget _buildLiquidProgressIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double percentage = (_currentIntake / widget.dailyGoal).clamp(0.0, 1.0);

    return SizedBox(
      width: 220,
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
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 10),
            ),
          ),
          
          // Outer progress arc (using a simple circular indicator)
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
              color: colorScheme.surface.withValues(alpha: 0.3),
              child: Stack(
                children: [
                   // Liquid fill
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
                            colorScheme.primary.withValues(alpha: 0.6),
                            colorScheme.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Center Text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_currentIntake/${widget.dailyGoal}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          "ml",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Heart and Water Drop icons
          Positioned(
            left: 5,
            bottom: 40,
            child: Icon(Icons.favorite, color: Colors.orange.shade300, size: 28),
          ),
          Positioned(
            right: 5,
            bottom: 40,
            child: Icon(Icons.water_drop, color: Colors.blue.shade300, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCard(BuildContext context, Map<String, dynamic> drink, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDrink = drink;
        });
      },
      child: GlassmorphismCard(
        padding: const EdgeInsets.all(8),
        borderRadius: 20,
        blur: isSelected ? 20 : 10,
        child: Container(
          decoration: isSelected ? BoxDecoration(
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(20),
          ) : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Icon(drink['icon'], size: 36, color: drink['color']),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.add, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                drink['name'],
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onSurface
                ),
              ),
              Text(
                "${drink['defaultAmount']} ML",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6), 
                  fontSize: 10
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
