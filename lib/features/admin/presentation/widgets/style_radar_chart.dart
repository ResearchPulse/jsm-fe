import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Represents a single journal's stylistic series plotted on the radar chart.
class RadarDataset {
  final String id;
  final String name;
  final Color color;
  final List<double> values;
  final List<String> rawDisplayValues;

  const RadarDataset({
    required this.id,
    required this.name,
    required this.color,
    required this.values,
    required this.rawDisplayValues,
  });

  /// Factory helper to build a normalized dataset from an API profile map.
  factory RadarDataset.fromProfile(Map<String, dynamic> profile, Color color) {
    final name = profile['journal_name']?.toString() ?? 'Tạp chí';
    final id = profile['journal_id']?.toString() ?? name;
    final metrics = profile['sentence_metrics'] as Map<String, dynamic>?;
    final stance = profile['stance'] as Map<String, dynamic>?;
    final moves = profile['cars_moves'] as Map<String, dynamic>?;

    final meanLen = (metrics?['mean_length'] as num?)?.toDouble() ?? 22.0;
    final lexDensity = (metrics?['lexical_density'] as num?)?.toDouble() ?? 0.55;
    final hedges = (metrics?['hedges_per_1k'] as num?)?.toDouble() ?? 15.0;
    final boosters = (metrics?['boosters_per_1k'] as num?)?.toDouble() ?? 10.0;
    final neutral = (stance?['neutral'] as num?)?.toDouble() ?? 0.65;

    final m1 = (moves?['territory'] as num?)?.toDouble() ?? 0.90;
    final m2 = (moves?['niche'] as num?)?.toDouble() ?? 0.85;
    final m3 = (moves?['occupying'] as num?)?.toDouble() ?? 0.88;
    final carsScore = (m1 + m2 + m3) / 3.0;

    // Normalization logic: Scale each metric between 0.1 and 1.0 for visual balance
    final normLen = ((meanLen - 12.0) / 20.0).clamp(0.1, 1.0);
    final normLex = ((lexDensity - 0.35) / 0.35).clamp(0.1, 1.0);
    final normHedge = (hedges / 32.0).clamp(0.1, 1.0);
    final normBooster = (boosters / 24.0).clamp(0.1, 1.0);
    final normNeutral = neutral.clamp(0.1, 1.0);
    final normCars = carsScore.clamp(0.1, 1.0);

    return RadarDataset(
      id: id,
      name: name,
      color: color,
      values: [normLen, normLex, normHedge, normBooster, normNeutral, normCars],
      rawDisplayValues: [
        '${meanLen.toStringAsFixed(1)} từ',
        '${(lexDensity * 100).toStringAsFixed(0)}%',
        '${hedges.toStringAsFixed(1)}/1k',
        '${boosters.toStringAsFixed(1)}/1k',
        '${(neutral * 100).toStringAsFixed(0)}%',
        '${(carsScore * 100).toStringAsFixed(0)}%',
      ],
    );
  }
}

/// Interactive 6-Axis Multi-Series Radar Chart for style fingerprint comparison.
class StyleRadarChart extends StatelessWidget {
  final List<RadarDataset> datasets;
  final double height;
  final bool showLegend;

  static const List<String> axisTitles = [
    'Độ dài câu',
    'Mật độ từ vựng',
    'Rào đón (Hedges)',
    'Khẳng định (Boosters)',
    'Trung lập (Stance)',
    'Khung CARS',
  ];

  static const List<String> axisSubtitles = [
    'Sentence Length',
    'Lexical Density',
    'Hedging Intensity',
    'Booster Intensity',
    'Neutral Stance',
    'Move Completeness',
  ];

  const StyleRadarChart({
    super.key,
    required this.datasets,
    this.height = 360,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Chọn tạp chí để hiển thị biểu đồ Radar',
            style: TextStyle(color: AppColors.textSubtle, fontSize: 13),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showLegend) ...[
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: datasets.map((ds) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ds.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ds.color.withAlpha(120), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: ds.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ds.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: chartWidth,
              height: height,
              child: CustomPaint(
                painter: _StyleRadarPainter(
                  datasets: datasets,
                  axisTitles: axisTitles,
                  axisSubtitles: axisSubtitles,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StyleRadarPainter extends CustomPainter {
  final List<RadarDataset> datasets;
  final List<String> axisTitles;
  final List<String> axisSubtitles;

  _StyleRadarPainter({
    required this.datasets,
    required this.axisTitles,
    required this.axisSubtitles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Reserve margin for text labels around vertices
    final maxRadius = (math.min(size.width, size.height) / 2) - 44.0;
    if (maxRadius <= 20) return;

    final ringPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final ringLevels = [0.2, 0.4, 0.6, 0.8, 1.0];
    const totalAxes = 6;
    final angleStep = (2 * math.pi) / totalAxes;
    // Start pointing straight UP (-pi / 2)
    const startAngle = -math.pi / 2;

    // 1. Draw concentric hexagonal grid rings
    for (final level in ringLevels) {
      final r = maxRadius * level;
      final path = Path();
      for (int i = 0; i < totalAxes; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, ringPaint);
    }

    // 2. Draw radial axis lines from center to outer ring
    final axisLinePaint = Paint()
      ..color = AppColors.border.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < totalAxes; i++) {
      final angle = startAngle + i * angleStep;
      final outerX = center.dx + maxRadius * math.cos(angle);
      final outerY = center.dy + maxRadius * math.sin(angle);
      canvas.drawLine(center, Offset(outerX, outerY), axisLinePaint);

      // Draw axis labels
      _drawAxisLabel(canvas, center, maxRadius, angle, i);
    }

    // 3. Draw dataset polygons & vertices
    for (final dataset in datasets) {
      if (dataset.values.length < totalAxes) continue;

      final polyPath = Path();
      final points = <Offset>[];

      for (int i = 0; i < totalAxes; i++) {
        final angle = startAngle + i * angleStep;
        final val = dataset.values[i].clamp(0.05, 1.0);
        final r = maxRadius * val;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        final pt = Offset(x, y);
        points.add(pt);

        if (i == 0) {
          polyPath.moveTo(x, y);
        } else {
          polyPath.lineTo(x, y);
        }
      }
      polyPath.close();

      // Transparent polygon fill
      final fillPaint = Paint()
        ..color = dataset.color.withAlpha(38)
        ..style = PaintingStyle.fill;
      canvas.drawPath(polyPath, fillPaint);

      // Solid outline stroke
      final strokePaint = Paint()
        ..color = dataset.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(polyPath, strokePaint);

      // Draw vertex markers with white center
      final dotFill = Paint()..color = Colors.white;
      final dotStroke = Paint()
        ..color = dataset.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (final pt in points) {
        canvas.drawCircle(pt, 4.0, dotFill);
        canvas.drawCircle(pt, 4.0, dotStroke);
      }
    }
  }

  void _drawAxisLabel(Canvas canvas, Offset center, double radius, double angle, int index) {
    final title = axisTitles[index];
    final subtitle = axisSubtitles[index];

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: '$title\n',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        TextSpan(
          text: subtitle,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSubtle,
            height: 1.1,
          ),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label slightly outside the vertex
    final labelDistance = radius + 22.0;
    final lx = center.dx + labelDistance * math.cos(angle);
    final ly = center.dy + labelDistance * math.sin(angle);

    final offset = Offset(
      lx - (textPainter.width / 2),
      ly - (textPainter.height / 2),
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _StyleRadarPainter oldDelegate) {
    if (oldDelegate.datasets.length != datasets.length) return true;
    for (int i = 0; i < datasets.length; i++) {
      if (oldDelegate.datasets[i].id != datasets[i].id ||
          oldDelegate.datasets[i].color != datasets[i].color) {
        return true;
      }
    }
    return false;
  }
}
