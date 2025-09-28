import 'package:flutter/material.dart';

// Your original Color extension, which is used in this file
extension ColorValues on Color {
  Color withValues({double? opacity}) {
    if (opacity == null) return this;
    return withAlpha((opacity * 255).round().clamp(0, 255));
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

    // This logic remains exactly the same. When isSelected changes, these values change.
    final Color boxColor = isSelected ? colorScheme.primary : Colors.white.withValues(alpha: 0.8);
    final Color dayOfWeekColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.8);
    final Color circleColor = isSelected ? Colors.white.withValues(alpha: 0.25) : colorScheme.primary.withValues(alpha: 0.1);
    final Color dayOfMonthColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.9);

    const double height = 60;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // --- CHANGES START HERE ---

        return AnimatedContainer( // 1. Was 'Container'
          // 2. Add the duration for the animation
          duration: const Duration(milliseconds: 300), 
          // 3. (Optional but nice) Add a curve for smoother animation
          curve: Curves.easeInOut, 

          height: height,
          decoration: BoxDecoration(
            // AnimatedContainer will automatically animate this color change
            color: boxColor, 
            borderRadius: BorderRadius.circular(width / 2),
            border: isCurrentDay && !isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
            boxShadow: [
              if (isSelected) // Only show shadow when selected for a "pop" effect
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          // --- CHANGES END HERE ---
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayOfWeek,
                  style: textTheme.bodyMedium!.copyWith(
                    // Note: The text color will change instantly, not animate.
                    // Animating text color requires a different widget like TweenAnimationBuilder,
                    // but the background animation is the most important part.
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