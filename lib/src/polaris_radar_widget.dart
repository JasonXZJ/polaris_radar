import 'package:flutter/material.dart';

import 'polaris_radar_data.dart';
import 'polaris_radar_painter.dart';

// ── Tween ────────────────────────────────────────────────────────────────────

class _PolarisRadarDataTween extends Tween<PolarisRadarData> {
  _PolarisRadarDataTween({
    required PolarisRadarData begin,
    required PolarisRadarData end,
  }) : super(begin: begin, end: end);

  @override
  PolarisRadarData lerp(double t) => begin!.lerp(end!, t);
}

// ── 主 Widget ─────────────────────────────────────────────────────────────────

/// 高度可定制的雷达图，支持：
///   • 每条数据集独立的实线 / 虚线边框
///   • 顶点标记形状：圆形 / 方形 / 菱形 / 三角形
///   • 圆形或多边形网格
///   • 隐式动画（数据更新时自动过渡）
///
/// ```dart
/// PolarisRadarChart(
///   data: PolarisRadarData(
///     axisLabels: ['力量', '敏捷', '智力', '耐力', '防御', '魔力'],
///     maxValue: 100,
///     dataSets: [
///       PolarisDataSet(
///         label: '角色A',
///         dataEntries: [80, 60, 70, 50, 90, 40],
///         fillColor: Colors.blue.withOpacity(0.2),
///         lineStyle: RadarLineStyle(color: Colors.blue, width: 2),
///         pointShape: RadarPointShape.circle,
///       ),
///     ],
///   ),
/// )
/// ```
class PolarisRadarChart extends StatefulWidget {
  const PolarisRadarChart({
    super.key,
    required this.data,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  final PolarisRadarData data;

  /// 数据切换时的动画时长
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  @override
  State<PolarisRadarChart> createState() => _PolarisRadarChartState();
}

class _PolarisRadarChartState extends State<PolarisRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late _PolarisRadarDataTween _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _tween = _PolarisRadarDataTween(begin: widget.data, end: widget.data);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didUpdateWidget(PolarisRadarChart old) {
    super.didUpdateWidget(old);

    if (old.data != widget.data) {
      // 以当前动画中间帧作为新起点，保证数值连续
      _tween = _PolarisRadarDataTween(
        begin: _tween.lerp(_animation.value),
        end: widget.data,
      );
      _controller
        ..duration = widget.duration
        ..forward(from: 0);
    }

    if (old.curve != widget.curve) {
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: PolarisRadarPainter(data: _tween.lerp(_animation.value)),
      ),
    );
  }
}

// ── 图例 Widget ───────────────────────────────────────────────────────────────

/// 单条图例项：线条预览 + 标签文字。
///
/// 自动根据 [dataSet.lineStyle.dashArray] 渲染实线或虚线，
/// 以及 [dataSet.pointShape] 渲染对应标记形状。
class RadarLegendItem extends StatelessWidget {
  const RadarLegendItem({
    super.key,
    required this.dataSet,
    this.lineWidth = 32,
    this.textStyle,
    this.spacing = 8,
  });

  final PolarisDataSet dataSet;
  final double lineWidth;
  final TextStyle? textStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: lineWidth,
          height: 16,
          child: CustomPaint(
            painter: _LegendLinePainter(dataSet: dataSet),
          ),
        ),
        SizedBox(width: spacing),
        Text(
          dataSet.label,
          style: textStyle ?? const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}

class _LegendLinePainter extends CustomPainter {
  const _LegendLinePainter({required this.dataSet});

  final PolarisDataSet dataSet;

  @override
  void paint(Canvas canvas, Size size) {
    final style = dataSet.lineStyle;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, cy)
      ..lineTo(size.width, cy);

    if (style.dashArray != null) {
      double d = 0;
      bool draw = true;
      int i = 0;
      final dest = Path();
      for (final metric in path.computeMetrics()) {
        while (d < metric.length) {
          final len = style.dashArray![i % style.dashArray!.length];
          final end = (d + len).clamp(0.0, metric.length);
          if (draw) dest.addPath(metric.extractPath(d, end), Offset.zero);
          d += len;
          draw = !draw;
          i++;
        }
      }
      canvas.drawPath(dest, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // 中点画标记
    final cx = size.width / 2;
    final pointPaint = Paint()
      ..color = style.color
      ..style = PaintingStyle.fill;
    _drawMarker(canvas, Offset(cx, cy), dataSet.pointSize, pointPaint,
        dataSet.pointShape);
  }

  void _drawMarker(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
    RadarPointShape shape,
  ) {
    switch (shape) {
      case RadarPointShape.none:
        return;
      case RadarPointShape.circle:
        canvas.drawCircle(center, size, paint);
      case RadarPointShape.square:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: size * 2, height: size * 2),
          paint,
        );
      case RadarPointShape.diamond:
        canvas.drawPath(
          Path()
            ..moveTo(center.dx, center.dy - size * 1.3)
            ..lineTo(center.dx + size, center.dy)
            ..lineTo(center.dx, center.dy + size * 1.3)
            ..lineTo(center.dx - size, center.dy)
            ..close(),
          paint,
        );
      case RadarPointShape.triangle:
        final h = size * 1.6;
        canvas.drawPath(
          Path()
            ..moveTo(center.dx, center.dy - h)
            ..lineTo(center.dx + size * 1.1, center.dy + size * 0.6)
            ..lineTo(center.dx - size * 1.1, center.dy + size * 0.6)
            ..close(),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_LegendLinePainter old) => old.dataSet != dataSet;
}
