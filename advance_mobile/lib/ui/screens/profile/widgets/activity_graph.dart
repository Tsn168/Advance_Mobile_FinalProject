import 'package:flutter/material.dart';
import 'dart:math' as math;

class ActivityGraph extends StatelessWidget {
  final int totalRides;
  final double totalDistance;
  final int totalDurationMinutes;
  final int goalRides;

  const ActivityGraph({
    super.key,
    required this.totalRides,
    required this.totalDistance,
    required this.totalDurationMinutes,
    this.goalRides = 20, // Default goal of 20 rides a month
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (totalRides / goalRides).clamp(0.0, 1.0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "THIS MONTH'S ACTIVITY",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Circle Graph
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Center(
                        child: CustomPaint(
                          size: const Size(100, 100),
                          painter: _CircleGraphPainter(
                            percentage: percentage,
                            color: Colors.blue,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalRides',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              'RIDES',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatItem(
                      label: 'Distance',
                      value: '${totalDistance.toStringAsFixed(1)} km',
                      icon: Icons.directions_bike,
                    ),
                    const SizedBox(height: 16),
                    _StatItem(
                      label: 'Duration',
                      value: _formatDuration(totalDurationMinutes),
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${(percentage * 100).toInt()}% of monthly goal reached',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _CircleGraphPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  _CircleGraphPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at the top
      2 * math.pi * percentage,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleGraphPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
