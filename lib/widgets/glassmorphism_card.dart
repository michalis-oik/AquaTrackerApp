// A reusable card with the glassmorphism effect.

import 'dart:ui';

import 'package:flutter/material.dart';

class GlassmorphismCard extends StatelessWidget {
  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius = 25.0,
    this.blur = 15.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.25),
            border: Border.all(color: colorScheme.surface.withValues(alpha: 0.4), width: 1.5),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child, // The content passed to the widget goes here
        ),
      ),
    );
  }
}