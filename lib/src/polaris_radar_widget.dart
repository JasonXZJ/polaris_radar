import 'dart:math' as math;

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
    this.touchData,
    this.selectedDataSetIndex,
    this.interactive = true,
  });

  final PolarisRadarData data;

  /// 数据切换时的动画时长
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  /// 触摸交互配置
  final PolarisRadarTouchData? touchData;

  /// 外部控制选中的数据集索引。
  ///
  /// `null` 表示未选中任何数据集，所有数据集正常显示。
  final int? selectedDataSetIndex;

  /// 是否启用触摸交互，默认 true。
  ///
  /// 设为 false 时点击图表无响应，但 [selectedDataSetIndex] 仍生效。
  final bool interactive;

  @override
  State<PolarisRadarChart> createState() => _PolarisRadarChartState();
}

class _PolarisRadarChartState extends State<PolarisRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late _PolarisRadarDataTween _tween;
  PolarisTouchResponse? _touchedResponse;

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

  void _handleTapUp(TapUpDetails details) {
    if (!widget.interactive || widget.touchData == null) return;
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    final data = _tween.lerp(_animation.value);
    if (data.dataSets.isEmpty || data.axisLabels.length < 3) return;

    final size = renderBox.size;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) * 0.72;
    final n = data.axisCount;
    final step = 2 * math.pi / n;
    final maxV = data.effectiveMax;
    final minV = data.minValue;
    final range = maxV - minV;
    final threshold = widget.touchData!.touchSpotThreshold;
    final edgeThreshold = widget.touchData!.edgeTouchThreshold;

    PolarisTouchResponse? bestVertexHit;
    var bestVertexDist = threshold;

    PolarisTouchResponse? bestEdgeHit;
    var bestEdgeDist = edgeThreshold;

    for (var dsIdx = 0; dsIdx < data.dataSets.length; dsIdx++) {
      final ds = data.dataSets[dsIdx];

      // 预计算该数据集的所有顶点坐标
      final vertices = List<Offset>.generate(n, (axIdx) {
        final angle = step * axIdx - math.pi / 2;
        final ratio = range == 0
            ? 0.0
            : ((ds.dataEntries[axIdx] - minV) / range).clamp(0.0, 1.0);
        return Offset(
          cx + radius * ratio * math.cos(angle),
          cy + radius * ratio * math.sin(angle),
        );
      });

      // Phase 1: 顶点命中测试
      for (var axIdx = 0; axIdx < n; axIdx++) {
        final dist = (vertices[axIdx] - localPos).distance;
        if (dist < bestVertexDist) {
          bestVertexDist = dist;
          bestVertexHit = PolarisTouchResponse(
            dataSetIndex: dsIdx,
            axisIndex: axIdx,
            value: ds.dataEntries[axIdx],
            axisLabel: data.axisLabels[axIdx],
            dataSetLabel: ds.label,
            localPosition: vertices[axIdx],
          );
        }
      }

      // Phase 2: 边缘命中测试（仅无顶点命中时执行）
      if (bestVertexHit != null) continue;

      for (var axIdx = 0; axIdx < n; axIdx++) {
        final a = vertices[axIdx];
        final b = vertices[(axIdx + 1) % n];
        final dist = _distToSegment(localPos, a, b);
        if (dist < bestEdgeDist) {
          bestEdgeDist = dist;
          bestEdgeHit = PolarisTouchResponse(
            dataSetIndex: dsIdx,
            axisIndex: null,
            value: null,
            axisLabel: null,
            dataSetLabel: ds.label,
            localPosition: localPos,
          );
        }
      }
    }

    final bestHit = bestVertexHit ?? bestEdgeHit;

    setState(() {
      _touchedResponse =
          (bestHit != null && bestHit.axisIndex != null) ? bestHit : null;
    });
    widget.touchData!.onTouch?.call(bestHit);
  }

  /// 计算点 p 到线段 ab 的最短距离
  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = Offset(b.dx - a.dx, b.dy - a.dy);
    final ap = Offset(p.dx - a.dx, p.dy - a.dy);
    final dot = ap.dx * ab.dx + ap.dy * ab.dy;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = (dot / len2).clamp(0.0, 1.0);
    final closest = Offset(a.dx + t * ab.dx, a.dy + t * ab.dy);
    return (p - closest).distance;
  }

  @override
  Widget build(BuildContext context) {
    final td = widget.touchData;
    final isInteractive = widget.interactive && td != null;

    // 交互关闭时清除瞬时触摸状态
    if (!widget.interactive && _touchedResponse != null) {
      _touchedResponse = null;
    }

    // 仅顶点命中时显示 tooltip（axisIndex != null）
    final showTooltip = _touchedResponse != null &&
        _touchedResponse!.axisIndex != null &&
        td?.showTooltip == true;

    Widget chart = AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final currentData = _tween.lerp(_animation.value);
        return CustomPaint(
          size: Size.infinite,
          painter: PolarisRadarPainter(
            data: currentData,
            touchedResponse: _touchedResponse,
            touchData: td,
            selectedDataSetIndex: widget.selectedDataSetIndex,
          ),
        );
      },
    );

    if (isInteractive) {
      chart = GestureDetector(
        onTapUp: _handleTapUp,
        child: Stack(
          children: [
            chart,
            if (showTooltip)
              Positioned(
                left: _touchedResponse!.localPosition.dx + 12,
                top: _touchedResponse!.localPosition.dy - 20,
                child: _RadarTooltip(
                  response: _touchedResponse!,
                  textStyle: td.tooltipTextStyle,
                ),
              ),
          ],
        ),
      );
    }

    return chart;
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
    this.isSelected = false,
    this.onTap,
    this.selectedTextStyle,
  });

  final PolarisDataSet dataSet;
  final double lineWidth;
  final TextStyle? textStyle;
  final double spacing;
  final bool isSelected;
  final VoidCallback? onTap;
  final TextStyle? selectedTextStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = isSelected
        ? (selectedTextStyle ??
            textStyle ??
            const TextStyle(color: Colors.white, fontSize: 13))
        : (textStyle ?? const TextStyle(color: Colors.white70, fontSize: 13));

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: lineWidth,
          height: 16,
          child: CustomPaint(
            painter: _LegendLinePainter(
              dataSet: dataSet,
              dimmed: !isSelected,
            ),
          ),
        ),
        SizedBox(width: spacing),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dataSet.lineStyle.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Text(
          dataSet.label,
          style: effectiveTextStyle,
        ),
      ],
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: isSelected
              ? BoxDecoration(
                  color: dataSet.lineStyle.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: dataSet.lineStyle.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                )
              : null,
          child: content,
        ),
      );
    }

    return content;
  }
}

class _LegendLinePainter extends CustomPainter {
  const _LegendLinePainter({required this.dataSet, this.dimmed = false});

  final PolarisDataSet dataSet;
  final bool dimmed;

  @override
  void paint(Canvas canvas, Size size) {
    final style = dataSet.lineStyle;
    final color = dimmed
        ? style.color.withValues(alpha: style.color.a * 0.4)
        : style.color;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
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
      ..color = dimmed
          ? style.color.withValues(alpha: style.color.a * 0.4)
          : style.color
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
  bool shouldRepaint(_LegendLinePainter old) =>
      old.dataSet != dataSet || old.dimmed != dimmed;
}

// ── Tooltip ───────────────────────────────────────────────────────────────────

class _RadarTooltip extends StatelessWidget {
  const _RadarTooltip({
    required this.response,
    this.textStyle,
  });

  final PolarisTouchResponse response;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
    final label = response.axisLabel ?? '';
    final value = response.value?.toStringAsFixed(1) ?? '';
    final dsLabel = response.dataSetLabel ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value${dsLabel.isNotEmpty ? ' ($dsLabel)' : ''}',
        style: style,
      ),
    );
  }
}
