import 'package:flutter/material.dart';
import 'package:water_tracking_app/pages/home_page.dart';
import 'package:water_tracking_app/pages/drink_selection_page.dart';
import 'package:water_tracking_app/pages/reminders_page.dart';
import 'package:water_tracking_app/pages/leaderboard_page.dart';
import 'package:water_tracking_app/pages/settings_page.dart';
import 'package:water_tracking_app/utils/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui';



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
  int _dailyGoal = 2210; // Default, will be updated from Firebase
  Map<String, dynamic> _selectedDrink = {
    'name': 'Water', 
    'icon': Icons.water_drop, 
    'color': const Color(0xFF4FC3F7), 
    'defaultAmount': 200
  };
  
  DateTime _selectedDate = DateTime.now();
  int _currentWaterIntake = 0; // Always Today
  int _historyWaterIntake = 0; // Intake for the selected top-row date
  List<double> _weeklyIntakeData = [0, 0, 0, 0, 0, 0, 0];
  StreamSubscription? _todaySubscription;
  StreamSubscription? _historySubscription;
  StreamSubscription? _goalSubscription;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _setupTodayListener();
    _setupHistoryListener(_selectedDate);
    _setupGoalListener();
    _loadWeeklyData();
  }

  @override
  void dispose() {
    _todaySubscription?.cancel();
    _historySubscription?.cancel();
    _goalSubscription?.cancel();
    super.dispose();
  }

  void _setupGoalListener() {
    _goalSubscription = _databaseService.getUserSettingsStream().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('dailyGoal') && mounted) {
          setState(() {
            _dailyGoal = data['dailyGoal'] ?? 2210;
          });
          _loadWeeklyData(); // Refresh chart percentages
        }
      }
    });
  }

  void _setupTodayListener() {
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _todaySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_databaseService.uid)
        .collection('consumption')
        .doc(todayStr)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _currentWaterIntake = data['intake'] ?? 0;
          });
          _loadWeeklyData();
        }
      } else {
        if (mounted) setState(() => _currentWaterIntake = 0);
      }
    });
  }

  void _setupHistoryListener(DateTime date) {
    _historySubscription?.cancel();
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    _historySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_databaseService.uid)
        .collection('consumption')
        .doc(dateStr)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _historyWaterIntake = data['intake'] ?? 0;
          });
        }
      } else {
        if (mounted) setState(() => _historyWaterIntake = 0);
      }
    });
  }

  void _loadWeeklyData() async {
    DateTime now = DateTime.now();
    int currentDayIndex = now.weekday - 1;
    List<String> dates = [];
    
    for (int i = 0; i < 7; i++) {
      DateTime date = now.subtract(Duration(days: currentDayIndex - i));
      dates.add(DateFormat('yyyy-MM-dd').format(date));
    }

    Map<String, int> data = await _databaseService.getWeeklyConsumption(dates);
    
    if (mounted) {
      setState(() {
        _weeklyIntakeData = dates.map((d) {
          int intake = data[d] ?? 0;
          // Calculate percentage for the chart (assuming goal is 2210)
          return (intake / _dailyGoal * 100).clamp(0.0, 100.0);
        }).toList();
      });
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _setupHistoryListener(date);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _isDrinkSelectionOpen = false;
      }
    });
  }

  void _addWater(int amount) {
    _updateDatabaseIntake(_currentWaterIntake + amount, DateTime.now());
  }

  void _subtractWater(int amount) {
    int newIntake = (_currentWaterIntake - amount).clamp(0, 99999);
    _updateDatabaseIntake(newIntake, DateTime.now());
  }

  void _updateGoal(int newGoal) {
    _databaseService.updateDailyGoal(newGoal);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _showOnlyTodayError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You can only track intake for today!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateDatabaseIntake(int amount, DateTime date) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_databaseService.uid)
        .collection('consumption')
        .doc(dateStr)
        .set({
      'intake': amount,
      'timestamp': FieldValue.serverTimestamp(),
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
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
                      onDrinkRemoved: _subtractWater,
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
          historyIntake: _historyWaterIntake,
          dailyGoal: _dailyGoal,
          selectedDrink: _selectedDrink,
          onAddWater: () => _addWater(_selectedDrink['defaultAmount'] as int),
          onSelectDrinkTap: _toggleDrinkSelection,
          onDateSelected: _onDateChanged,
          weeklyData: _weeklyIntakeData,
          selectedDate: _selectedDate,
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
          onGoalUpdated: _updateGoal,
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
      height: 65,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index && !_isDrinkSelectionOpen;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSelected ? 5 : 0),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? colorScheme.primary : const Color(0xFF2D3142).withOpacity(0.4),
              size: isSelected ? 22 : 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : const Color(0xFF2D3142).withOpacity(0.4),
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isSelected) 
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
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
          duration: const Duration(milliseconds: 300),
          transform: isActive ? (Matrix4.identity()..scale(1.15)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : const Color(0xFF928FFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white, 
                  width: isActive ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? colorScheme.primary : const Color(0xFF928FFF)).withAlpha(isActive ? 160 : 100),
                    blurRadius: isActive ? 18 : 10,
                    spreadRadius: isActive ? 4 : 2,
                    offset: isActive ? Offset.zero : const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.785398,
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: isActive ? 28 : 24,
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
