import 'package:flutter/material.dart';

class Calendardaybox extends StatelessWidget {
  const Calendardaybox({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    const double width = 50;
    const double height = 70; 

    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width / 1.5), 
          topRight: Radius.circular(width / 1.5),

          bottomLeft: Radius.circular(width / 1.5),
          bottomRight: Radius.circular(width / 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
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
              'Mon',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.5),
              child: Text(
                '23', 
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 14,
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