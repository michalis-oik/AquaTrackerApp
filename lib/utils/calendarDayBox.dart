import 'package:flutter/material.dart';

// Assuming the ColorValues extension is available here or in a shared file
extension ColorValues on Color {
  Color withValues({int? alpha}) {
    return withAlpha(alpha ?? this.alpha);
  }
}

class Calendardaybox extends StatelessWidget {
  final String dayOfWeek;
  final String dayOfMonth;
  final bool isSelected;
  final bool isCurrentDay;

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

    // Height can remain constant for a consistent look
    const double height = 60;

    // Use LayoutBuilder to get the width from the parent (Expanded)
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth will be the width provided by the Expanded widget
        final double width = constraints.maxWidth;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: boxColor,
            // Dynamically calculate the radius to maintain the pill shape
            borderRadius: BorderRadius.circular(width / 2),
            border: isCurrentDay && !isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: circleColor,
                  child: Text(
                    dayOfMonth,
                    style: textTheme.titleSmall!.copyWith(
                      color: dayOfMonthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}