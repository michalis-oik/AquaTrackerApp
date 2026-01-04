import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water_tracking_app/utils/glassmorphism_card.dart';

class SettingsPage extends StatefulWidget {
  final int currentGoal;
  final String currentIcon;
  final Function(int) onGoalUpdated;
  final Function(String) onIconUpdated;

  const SettingsPage({
    super.key, 
    required this.currentGoal, 
    required this.currentIcon,
    required this.onGoalUpdated,
    required this.onIconUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  late double _goalValue;
  late String _selectedIcon;
  final User? _user = FirebaseAuth.instance.currentUser;

  final List<String> animalIcons = ['👤', '🦊', '🦄', '🐻', '🐱', '🦁', '🐰', '🐼', '🐨', '🐯', '🐘', '🦒'];

  @override
  void initState() {
    super.initState();
    _goalValue = widget.currentGoal.toDouble();
    _selectedIcon = widget.currentIcon;
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
                colors: [colorScheme.primary.withAlpha(179), colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  _buildProfileSection(context),
                  const SizedBox(height: 30),

                  _buildSectionTitle('CHOOSE YOUR AVATAR'),
                  const SizedBox(height: 15),
                  _buildAvatarSelection(context),
                  const SizedBox(height: 30),

                  _buildSectionTitle('HYDRATION GOALS'),
                  const SizedBox(height: 15),
                  _buildGoalAdjuster(context),
                  const SizedBox(height: 30),

                  _buildSectionTitle('PREFERENCES'),
                  const SizedBox(height: 15),
                  _buildSettingTile(
                    icon: Icons.notifications_active_rounded,
                    title: 'Reminders',
                    subtitle: 'Stay hydrated with alerts',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: colorScheme.primary,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildSectionTitle('ACCOUNT'),
                  const SizedBox(height: 15),
                  _buildSettingTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    titleColor: Colors.redAccent,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
                      }
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2D3142).withOpacity(0.5), letterSpacing: 1.2),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
              color: Colors.white,
            ),
            child: Center(
              child: Text(_selectedIcon, style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user?.displayName ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                Text(_user?.email ?? 'anonymous', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        children: animalIcons.map((icon) {
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIcon = icon);
              widget.onIconUpdated(icon);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? colorScheme.primary : Colors.transparent, width: 2),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalAdjuster(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Intake Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_goalValue.toInt()} ml', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _goalValue,
            min: 1000,
            max: 5000,
            onChanged: (val) => setState(() => _goalValue = val),
            onChangeEnd: (val) => widget.onGoalUpdated(val.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, String? subtitle, Widget? trailing, Color? titleColor, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF928FFF), size: 20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor ?? const Color(0xFF2D3142))),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
