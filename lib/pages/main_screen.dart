import 'package:flutter/material.dart';
import 'package:water_tracking_app/pages/home_page.dart';
import 'package:water_tracking_app/pages/drink_selection_page.dart';
import 'package:water_tracking_app/pages/reminders_page.dart';
import 'package:water_tracking_app/pages/leaderboard_page.dart';
import 'package:water_tracking_app/pages/settings_page.dart';



class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  bool _isDrinkSelectionOpen = false;
  
  // Shared state for the app
  int _currentWaterIntake = 0;
  final int _dailyGoal = 2210;
  Map<String, dynamic> _selectedDrink = {
    'name': 'Water', 
    'icon': Icons.water_drop, 
    'color': const Color(0xFF4FC3F7), 
    'defaultAmount': 200
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _isDrinkSelectionOpen = false;
      }
    });
  }

  void _addWater(int amount) {
    setState(() {
      _currentWaterIntake += amount;
    });
  }

  void _toggleDrinkSelection() {
    setState(() {
      if (!_isDrinkSelectionOpen) {
        _previousIndex = _selectedIndex;
        _isDrinkSelectionOpen = true;
        _selectedIndex = 2;
      } else {
        _isDrinkSelectionOpen = false;
        _selectedIndex = _previousIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBody(),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _isDrinkSelectionOpen
                  ? DrinkSelectionPage(
                      key: const ValueKey('drink_selection'),
                      initialIntake: _currentWaterIntake,
                      dailyGoal: _dailyGoal,
                      initialSelectedDrink: _selectedDrink,
                      onDrinkAdded: _addWater,
                      onDrinkSelected: (drink) {
                        setState(() {
                          _selectedDrink = drink;
                        });
                      },
                      onClose: _toggleDrinkSelection,
                    )
                  : const SizedBox.shrink(key: ValueKey('no_drink_selection')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBody() {
    Widget page;
    switch (_selectedIndex) {
      case 0:
      case 2: // Keep Home as background for index 2 if using overlay
        page = HomePage(
          key: const ValueKey('home_page'),
          currentIntake: _currentWaterIntake,
          dailyGoal: _dailyGoal,
          selectedDrink: _selectedDrink,
          onAddWater: () => _addWater(_selectedDrink['defaultAmount'] as int),
          onSelectDrinkTap: _toggleDrinkSelection,
        );
        break;
      case 1:
        page = RemindersPage(
          key: const ValueKey('reminders_page'),
          currentIntake: _currentWaterIntake,
          dailyGoal: _dailyGoal,
        );
        break;
      case 3:
        page = LeaderboardPage(
          key: const ValueKey('leaderboard_page'),
          myIntake: _currentWaterIntake,
        );
        break;
      case 4:
        page = SettingsPage(
          key: const ValueKey('settings_page'),
          currentGoal: _dailyGoal,
        );
        break;
      default:
        page = Container(key: const ValueKey('empty_page'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: page,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildNavItem(0, Icons.home_rounded, "Home")),
          Expanded(child: _buildNavItem(1, Icons.alarm_rounded, "Reminders")),
          Expanded(child: _buildCenterActionItem()),
          Expanded(child: _buildNavItem(3, Icons.emoji_events_rounded, "Ranking")),
          Expanded(child: _buildNavItem(4, Icons.settings_rounded, "Settings")),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index && !_isDrinkSelectionOpen;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? colorScheme.primary : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterActionItem() {
    final bool isActive = _isDrinkSelectionOpen;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _toggleDrinkSelection,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isActive ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : const Color(0xFF928FFF),
                borderRadius: BorderRadius.circular(16),
                border: isActive 
                    ? Border.all(color: Colors.white, width: 2) 
                    : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? colorScheme.primary : const Color(0xFF928FFF)).withAlpha(isActive ? 160 : 120),
                    blurRadius: isActive ? 20 : 15,
                    spreadRadius: isActive ? 4 : 2,
                    offset: isActive ? const Offset(0, 0) : const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.785398,
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: isActive ? 34 : 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
