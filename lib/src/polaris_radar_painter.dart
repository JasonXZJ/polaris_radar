import 'dart:math';

import 'package:flutter/material.dart';

import 'polaris_radar_data.dart';

// ── TextPainter 跨帧缓存 ─────────────────────────────────────────────────────

/// 缓存 tick / axis 标签的 [TextPainter]，避免每帧重复 layout。
///
/// key 同时包含文本、样式与布局约束；TextStyle 与 String 自带 ==，
/// 因此即使外部 data 实例变化但文本/样式不变，仍能命中。
class PolarisLabelCache {
  final Map<_LabelKey, TextPainter> _map = {};

  TextPainter axisLabel(String text, TextStyle style) {
    return _map.putIfAbsent(_LabelKey(text, style, maxWidth: 80, center: true),
        () {
      return TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 80);
    });
  }

  TextPainter tickLabel(String text, TextStyle style) {
    return _map.putIfAbsent(_LabelKey(text, style), () {
      return TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
    });
  }

  void dispose() {
    for (final tp in _map.values) {
      tp.dispose();
    }
    _map.clear();
  }
}

class _LabelKey {
  const _LabelKey(this.text, this.style,
      {this.maxWidth = double.infinity, this.center = false});

  final String text;
  final TextStyle style;
  final double maxWidth;
  final bool center;

  @override
  bool operator ==(Object other) =>
      other is _LabelKey &&
      other.text == text &&
      other.style == style &&
      other.maxWidth == maxWidth &&
      other.center == center;

  @override
  int get hashCode => Object.hash(text, style, maxWidth, center);
}

/// 雷达图核心绘制器。
///
/// 绘制顺序：
///   1. 背景填充
///   2. 同心网格圈（含刻度标签）
///   3. 轴线
///   4. 轴标题
///   5. 各数据集（填充 → 边框 → 顶点标记）
class PolarisRadarPainter extends CustomPainter {
  PolarisRadarPainter({
    required this.data,
    this.touchedResponse,
    this.touchData,
    this.selectedDataSetIndex,
    this.labelCache,
  });

  final PolarisRadarData data;
  final PolarisTouchResponse? touchedResponse;
  final PolarisRadarTouchData? touchData;
  final int? selectedDataSetIndex;
  final PolarisLabelCache? labelCache;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dataSets.isEmpty || data.axisLabels.length < 3) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(cx, cy) * 0.72;
    final center = Offset(cx, cy);
    final n = data.axisCount;
    final step = 2 * pi / n;

    _drawBackground(canvas, center, radius, n, step);
    _drawGridTicks(canvas, center, radius, n, step);
    _drawAxisLines(canvas, center, radius, n, step);
    _drawTickLabels(canvas, center, radius);
    _drawAxisLabels(canvas, size, center, radius, n, step);
    _drawDataSets(canvas, center, radius, n, step);
  }

  // ── 1. 背景 ──────────────────────────────────────────────────────────────────

  void _drawBackground(
    Canvas canvas,
    Offset center,
    double radius,
    int n,
    double step,
  ) {
    if (data.backgroundColor == Colors.transparent) return;
    final paint = Paint()
      ..color = data.backgroundColor
      ..style = PaintingStyle.fill;

    if (data.gridShape == RadarGridShape.circle) {
      canvas.drawCircle(center, radius, paint);
    } else {
      canvas.drawPath(_polygonPath(center, radius, n, step), paint);
    }
  }

  // ── 2. 同心网格圈 ─────────────────────────────────────────────────────────────

  void _drawGridTicks(
    Canvas canvas,
    Offset center,
    double radius,
    int n,
    double step,
  ) {
    final style = data.gridLineStyle;
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke;

    for (var i = 1; i <= data.tickCount; i++) {
      final r = radius * i / data.tickCount;
      if (data.gridShape == RadarGridShape.circle) {
        if (style.dashArray != null) {
          final p = Path()
            ..addOval(Rect.fromCircle(center: center, radius: r));
          canvas.drawPath(_dashPath(p, style.dashArray!), paint);
        } else {
          canvas.drawCircle(center, r, paint);
        }
      } else {
        final p = _polygonPath(center, r, n, step);
        canvas.drawPath(
          style.dashArray != null ? _dashPath(p, style.dashArray!) : p,
          paint,
        );
      }
    }
  }

  // ── 3. 轴线 ──────────────────────────────────────────────────────────────────

  void _drawAxisLines(
    Canvas canvas,
    Offset center,
    double radius,
    int n,
    double step,
  ) {
    final style = data.axisLineStyle;
    final paint = Paint()
      ..color = style.color
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < n; i++) {
      final angle = step * i - pi / 2;
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (style.dashArray != null) {
        final p = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(end.dx, end.dy);
        canvas.drawPath(_dashPath(p, style.dashArray!), paint);
      } else {
        canvas.drawLine(center, end, paint);
      }
    }
  }

  // ── 4. 刻度数字 ───────────────────────────────────────────────────────────────

  void _drawTickLabels(Canvas canvas, Offset center, double radius) {
    final style = data.tickLabelStyle;
    if (style == null) return;

    final customLabels = data.tickLabels;
    final range = data.effectiveMax - data.minValue;
    for (var i = 0; i <= data.tickCount; i++) {
      final r = radius * i / data.tickCount;

      final text = (customLabels != null && i < customLabels.length)
          ? customLabels[i]
          : _formatTick(data.minValue + range * i / data.tickCount);

      if (text.isEmpty) continue;

      final tp = labelCache?.tickLabel(text, style) ??
          (TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
          )..layout());

      tp.paint(canvas, Offset(center.dx + 4, center.dy - r - tp.height));
    }
  }

  String _formatTick(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  // ── 5. 轴标题 ─────────────────────────────────────────────────────────────────

  void _drawAxisLabels(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    int n,
    double step,
  ) {
    final style = data.axisLabelStyle;
    if (style == null) return;

    for (var i = 0; i < n; i++) {
      final angle = step * i - pi / 2;
      final labelRadius = radius * (1 + data.titlePositionFactor);

      final tp = labelCache?.axisLabel(data.axisLabels[i], style) ??
          (TextPainter(
            text: TextSpan(text: data.axisLabels[i], style: style),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout(maxWidth: 80));

      final ax = center.dx + labelRadius * cos(angle);
      final ay = center.dy + labelRadius * sin(angle);
      tp.paint(canvas, Offset(ax - tp.width / 2, ay - tp.height / 2));
    }
  }

  // ── 6. 数据集 ─────────────────────────────────────────────────────────────────

  bool _isDimmed(int idx) =>
      selectedDataSetIndex != null && idx != selectedDataSetIndex;

  void _drawDataSets(
    Canvas canvas,
    Offset center,
    double radius,
    int n,
    double step,
  ) {
    final maxV = data.effectiveMax;
    final minV = data.minValue;
    final range = maxV - minV;

    final points = <List<Offset>>[];
    for (final ds in data.dataSets) {
      final offsets = <Offset>[];
      for (var i = 0; i < n; i++) {
        final angle = step * i - pi / 2;
        final ratio = range == 0
            ? 0.0
            : ((ds.dataEntries[i] - minV) / range).clamp(0.0, 1.0);
        offsets.add(Offset(
          center.dx + radius * ratio * cos(angle),
          center.dy + radius * ratio * sin(angle),
        ));
      }
      points.add(offsets);
    }

    // 先画所有填充（底层），再画边框和点（顶层）
    for (var idx = 0; idx < data.dataSets.length; idx++) {
      _drawFill(canvas, center, radius, data.dataSets[idx], points[idx],
          dimmed: _isDimmed(idx));
    }
    for (var idx = 0; idx < data.dataSets.length; idx++) {
      _drawBorder(canvas, data.dataSets[idx], points[idx],
          dimmed: _isDimmed(idx));
      _drawPoints(canvas, data.dataSets[idx], points[idx], dataSetIndex: idx,
          dimmed: _isDimmed(idx));
    }
  }

  void _drawFill(
    Canvas canvas,
    Offset center,
    double radius,
    PolarisDataSet ds,
    List<Offset> offsets, {
    bool dimmed = false,
  }) {
    final fill = ds.fillColor;
    if ((fill == null || fill == Colors.transparent) && ds.fillGradient == null) {
      return;
    }

    final path = _offsetsToPath(offsets);
    final paint = Paint()..style = PaintingStyle.fill;

    if (ds.fillGradient != null) {
      paint.shader = ds.fillGradient!.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
      if (dimmed) {
        paint.color = Colors.white.withValues(alpha: 0.1);
      }
    } else {
      paint.color = dimmed ? fill!.withValues(alpha: fill.a * 0.1) : fill!;
    }
    canvas.drawPath(path, paint);
  }

  void _drawBorder(
    Canvas canvas,
    PolarisDataSet ds,
    List<Offset> offsets, {
    bool dimmed = false,
  }) {
    final style = ds.lineStyle;
    final paint = Paint()
      ..color = dimmed
          ? style.color.withValues(alpha: style.color.a * 0.25)
          : style.color
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _offsetsToPath(offsets);
    canvas.drawPath(
      style.dashArray != null ? _dashPath(path, style.dashArray!) : path,
      paint,
    );
  }

  void _drawPoints(
    Canvas canvas,
    PolarisDataSet ds,
    List<Offset> offsets, {
    int dataSetIndex = 0,
    bool dimmed = false,
  }) {
    if (ds.pointShape == RadarPointShape.none) return;

    final paint = Paint()
      ..color = dimmed
          ? ds.lineStyle.color.withValues(alpha: ds.lineStyle.color.a * 0.25)
          : ds.lineStyle.color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < offsets.length; i++) {
      final pt = offsets[i];
      final isHighlighted = touchedResponse != null &&
          touchedResponse!.dataSetIndex == dataSetIndex &&
          touchedResponse!.axisIndex == i;

      if (isHighlighted) {
        final td = touchData;
        final hlPaint = Paint()
          ..color = td?.highlightColor ?? ds.lineStyle.color
          ..style = PaintingStyle.fill;
        // 外发光效果
        final glowPaint = Paint()
          ..color = (td?.highlightColor ?? ds.lineStyle.color).withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        final glowSize = ds.pointSize * (td?.highlightRadiusFactor ?? 1.8) * 1.6;
        _drawPointShape(canvas, pt, glowSize, glowPaint, ds.pointShape);
        // 高亮放大的顶点
        _drawPointShape(
          canvas,
          pt,
          ds.pointSize * (td?.highlightRadiusFactor ?? 1.8),
          hlPaint,
          ds.pointShape,
        );
      } else {
        _drawPointShape(canvas, pt, ds.pointSize, paint, ds.pointShape);
      }
    }
  }

  void _drawPointShape(
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

  // ── 辅助 ──────────────────────────────────────────────────────────────────────

  Path _offsetsToPath(List<Offset> offsets) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    return path..close();
  }

  Path _polygonPath(Offset center, double radius, int n, double step) {
    final path = Path()
      ..moveTo(
        center.dx + radius * cos(-pi / 2),
        center.dy + radius * sin(-pi / 2),
      );
    for (var i = 1; i < n; i++) {
      final a = step * i - pi / 2;
      path.lineTo(center.dx + radius * cos(a), center.dy + radius * sin(a));
    }
    return path..close();
  }

  /// 将任意 [Path] 转换为虚线路径。
  /// [dashArray] 交替表示 "实线长度, 间距长度, ..." 并循环。
  Path _dashPath(Path source, List<double> dashArray) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      var draw = true;
      var i = 0;
      while (distance < metric.length) {
        final len = dashArray[i % dashArray.length];
        final end = (distance + len).clamp(0.0, metric.length);
        if (draw) dest.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += len;
        draw = !draw;
        i++;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(PolarisRadarPainter old) =>
      old.data != data ||
      old.touchedResponse != touchedResponse ||
      old.touchData != touchData ||
      old.selectedDataSetIndex != selectedDataSetIndex;
}
