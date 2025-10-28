import 'dart:ui'; // Required for ImageFilter
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HydrationStatsChart extends StatelessWidget {
  final List<double> weeklyData;

  const HydrationStatsChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    const double blur = 5.0; // Adjust the blur intensity here

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Slightly more rounded
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        // This makes the card transparent so the blur is visible
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        clipBehavior: Clip.antiAlias, // Ensures the blur stays inside the rounded corners
        child: Stack(
          children: [
            // Layer 1: The blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: BoxDecoration(color: Colors.transparent),
              ),
            ),
            // Layer 2: The actual chart content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chart Title and Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hydration Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // The Chart
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        maxY: 100,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) =>
                                  getBottomTitles(context, value, meta),
                              reservedSize: 38,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 25,
                              getTitlesWidget: (value, meta) =>
                                  getLeftTitles(context, value, meta),
                              reservedSize: 42,
                            ),
                          ),
                        ),
                        barGroups: List.generate(weeklyData.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyData[index],
                                color: const Color(0xff8d84e8),
                                width: 20,
                                borderRadius: BorderRadius.circular(5),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 100,
                                  color: const Color(0xff8d84e8).withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBottomTitles(BuildContext context, double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      fontWeight: FontWeight.bold,
      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
    );

    Widget text;
    switch (value.toInt()) {
      case 0: text = Text('Mon', style: style); break;
      case 1: text = Text('Tue', style: style); break;
      case 2: text = Text('Web', style: style); break;
      case 3: text = Text('Thu', style: style); break;
      case 4: text = Text('Fri', style: style); break;
      case 5: text = Text('Sat', style: style); break;
      case 6: text = Text('Sun', style: style); break;
      default: text = const Text(''); break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 16, child: text);
  }

  Widget getLeftTitles(BuildContext context, double value, TitleMeta meta) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      fontWeight: FontWeight.bold,
      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
    );
    if (value % 25 == 0) {
      return Text(value.toInt().toString(), style: style, textAlign: TextAlign.left);
    }
    return const Text('');
  }
}