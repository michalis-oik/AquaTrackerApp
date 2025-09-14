import 'package:flutter/material.dart';

class Calendardaybox extends StatelessWidget {
  final String dayOfWeek;
  final String dayOfMonth;
  final bool isSelected;
  final bool isCurrentDay; // For a special indicator like a border

  const Calendardaybox({
    super.key,
    required this.dayOfWeek,
    required this.dayOfMonth,
    this.isSelected = false,
    this.isCurrentDay = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final Color boxColor = isSelected ? colorScheme.primary : Colors.white;
    final Color dayOfWeekColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.8);
    final Color circleColor = isSelected ? Colors.white.withValues(alpha: 0.25) : colorScheme.primary.withValues(alpha: 0.1);
    final Color dayOfMonthColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.9);

    const double width = 43;
    const double height = 65;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: boxColor, 
        borderRadius: BorderRadius.circular(width / 2), 
        border: isCurrentDay && !isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayOfWeek,
              style: textTheme.bodyMedium!.copyWith(
                color: dayOfWeekColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 15,
              backgroundColor: circleColor, 
              child: Text(
                dayOfMonth,
                style: textTheme.titleMedium!.copyWith(
                  color: dayOfMonthColor, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}