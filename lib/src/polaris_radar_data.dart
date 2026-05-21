import 'dart:ui';

import 'package:flutter/material.dart';

/// 雷达图整体网格形状
enum RadarGridShape { circle, polygon }

/// 数据点顶点标记形状
enum RadarPointShape { none, circle, square, diamond, triangle }

/// 描述一条线的颜色、粗细与虚线模式。
///
/// [dashArray] 为 null 时画实线；
/// 传入如 `[6, 3]` 则交替 6px 实 / 3px 空。
class RadarLineStyle {
  const RadarLineStyle({
    this.color = const Color(0xFF555555),
    this.width = 1.5,
    this.dashArray,
  });

  final Color color;
  final double width;

  /// null = 实线；非 null = 虚线间隔列表（循环使用）
  final List<double>? dashArray;

  RadarLineStyle lerp(RadarLineStyle other, double t) => RadarLineStyle(
        color: Color.lerp(color, other.color, t)!,
        width: lerpDouble(width, other.width, t)!,
        dashArray: t < 0.5 ? dashArray : other.dashArray,
      );

  static const RadarLineStyle transparent = RadarLineStyle(
    color: Colors.transparent,
    width: 0,
  );
}

/// 一条雷达折线的完整描述。
///
/// - [dataEntries] 长度必须与 [PolarisRadarData.axisLabels] 相同
/// - [lineStyle] 控制边框颜色、粗细、是否虚线
/// - [pointShape] 控制顶点标记形状
/// - [pointSize] 标记半径（逻辑像素）
/// - [fillColor] 填充色（建议带透明度）；与 [fillGradient] 二选一
/// - [label] 图例文字
class PolarisDataSet {
  const PolarisDataSet({
    required this.dataEntries,
    this.fillColor,
    this.fillGradient,
    this.lineStyle = const RadarLineStyle(
      color: Color(0xFF4FC3F7),
      width: 2,
    ),
    this.pointShape = RadarPointShape.circle,
    this.pointSize = 4.0,
    this.label = '',
  });

  final List<double> dataEntries;
  final Color? fillColor;
  final Gradient? fillGradient;
  final RadarLineStyle lineStyle;
  final RadarPointShape pointShape;
  final double pointSize;
  final String label;

  PolarisDataSet lerp(PolarisDataSet other, double t) {
    final len = other.dataEntries.length;
    return PolarisDataSet(
      dataEntries: List.generate(len, (i) {
        final a = i < dataEntries.length ? dataEntries[i] : 0.0;
        return lerpDouble(a, other.dataEntries[i], t)!;
      }),
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      fillGradient: Gradient.lerp(fillGradient, other.fillGradient, t),
      lineStyle: lineStyle.lerp(other.lineStyle, t),
      pointShape: t < 0.5 ? pointShape : other.pointShape,
      pointSize: lerpDouble(pointSize, other.pointSize, t)!,
      label: other.label,
    );
  }

  PolarisDataSet copyWith({
    List<double>? dataEntries,
    Color? fillColor,
    Gradient? fillGradient,
    RadarLineStyle? lineStyle,
    RadarPointShape? pointShape,
    double? pointSize,
    String? label,
  }) =>
      PolarisDataSet(
        dataEntries: dataEntries ?? this.dataEntries,
        fillColor: fillColor ?? this.fillColor,
        fillGradient: fillGradient ?? this.fillGradient,
        lineStyle: lineStyle ?? this.lineStyle,
        pointShape: pointShape ?? this.pointShape,
        pointSize: pointSize ?? this.pointSize,
        label: label ?? this.label,
      );
}

/// 雷达图所有配置项。
///
/// [axisLabels] 决定轴数量（至少 3），每条 [PolarisDataSet.dataEntries]
/// 的长度必须与之对应。
class PolarisRadarData {
  const PolarisRadarData({
    required this.dataSets,
    required this.axisLabels,
    this.maxValue,
    this.minValue = 0,
    this.tickCount = 5,
    this.tickLabels,
    this.tickLabelStyle,
    this.axisLabelStyle,
    this.gridLineStyle = const RadarLineStyle(
      color: Color(0xFF3A3A3A),
      width: 1,
    ),
    this.axisLineStyle = const RadarLineStyle(
      color: Color(0xFF3A3A3A),
      width: 1,
    ),
    this.backgroundColor = Colors.transparent,
    this.gridShape = RadarGridShape.circle,
    this.titlePositionFactor = 0.18,
  });

  final List<PolarisDataSet> dataSets;

  /// 各轴标题，同时决定雷达轴数量（至少 3 个）
  final List<String> axisLabels;

  /// 数据最大值，null 时自动取所有数据点最大值
  final double? maxValue;

  /// 数据最小值，默认 0（圆心代表此值）
  final double minValue;

  /// 同心圆/多边形圈数
  final int tickCount;

  /// 自定义刻度标签，为 null 时自动根据 [minValue] / [maxValue] 等分生成
  final List<String>? tickLabels;

  /// 刻度数字文字样式
  final TextStyle? tickLabelStyle;

  /// 轴标题文字样式
  final TextStyle? axisLabelStyle;

  /// 同心网格线样式
  final RadarLineStyle gridLineStyle;

  /// 从圆心到边缘的轴线样式
  final RadarLineStyle axisLineStyle;

  /// 雷达图背景色
  final Color backgroundColor;

  /// 网格形状：圆形 or 多边形
  final RadarGridShape gridShape;

  /// 轴标题距离雷达边缘的额外比例（0 = 紧贴，0.2 = 再向外 20%）
  final double titlePositionFactor;

  int get axisCount => axisLabels.length;

  double get effectiveMax {
    if (maxValue != null) return maxValue!;
    var m = double.negativeInfinity;
    for (final ds in dataSets) {
      for (final v in ds.dataEntries) {
        if (v > m) m = v;
      }
    }
    return m == double.negativeInfinity ? 100 : m;
  }

  PolarisRadarData lerp(PolarisRadarData other, double t) {
    return PolarisRadarData(
      dataSets: List.generate(other.dataSets.length, (i) {
        if (i < dataSets.length) return dataSets[i].lerp(other.dataSets[i], t);
        return other.dataSets[i];
      }),
      axisLabels: other.axisLabels,
      maxValue: lerpDouble(
        maxValue ?? effectiveMax,
        other.maxValue ?? other.effectiveMax,
        t,
      ),
      minValue: lerpDouble(minValue, other.minValue, t)!,
      tickCount: other.tickCount,
      tickLabels: other.tickLabels,
      tickLabelStyle: TextStyle.lerp(tickLabelStyle, other.tickLabelStyle, t),
      axisLabelStyle: TextStyle.lerp(axisLabelStyle, other.axisLabelStyle, t),
      gridLineStyle: gridLineStyle.lerp(other.gridLineStyle, t),
      axisLineStyle: axisLineStyle.lerp(other.axisLineStyle, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      gridShape: other.gridShape,
      titlePositionFactor:
          lerpDouble(titlePositionFactor, other.titlePositionFactor, t)!,
    );
  }

  PolarisRadarData copyWith({
    List<PolarisDataSet>? dataSets,
    List<String>? axisLabels,
    double? maxValue,
    double? minValue,
    int? tickCount,
    List<String>? tickLabels,
    TextStyle? tickLabelStyle,
    TextStyle? axisLabelStyle,
    RadarLineStyle? gridLineStyle,
    RadarLineStyle? axisLineStyle,
    Color? backgroundColor,
    RadarGridShape? gridShape,
    double? titlePositionFactor,
  }) =>
      PolarisRadarData(
        dataSets: dataSets ?? this.dataSets,
        axisLabels: axisLabels ?? this.axisLabels,
        maxValue: maxValue ?? this.maxValue,
        minValue: minValue ?? this.minValue,
        tickCount: tickCount ?? this.tickCount,
        tickLabels: tickLabels ?? this.tickLabels,
        tickLabelStyle: tickLabelStyle ?? this.tickLabelStyle,
        axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
        gridLineStyle: gridLineStyle ?? this.gridLineStyle,
        axisLineStyle: axisLineStyle ?? this.axisLineStyle,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        gridShape: gridShape ?? this.gridShape,
        titlePositionFactor: titlePositionFactor ?? this.titlePositionFactor,
      );
}

// ── 触摸交互 ──────────────────────────────────────────────────────────────────

/// 触摸回调类型。
///
/// [response] 为 `null` 表示触摸在空白区域（未命中任何数据点）。
typedef PolarisTouchCallback = void Function(PolarisTouchResponse? response);

/// 触摸命中的数据点信息。
class PolarisTouchResponse {
  /// 创建一个触摸响应。
  const PolarisTouchResponse({
    this.dataSetIndex,
    this.axisIndex,
    this.value,
    this.axisLabel,
    this.dataSetLabel,
    required this.localPosition,
  });

  /// 被触摸的数据集索引。
  final int? dataSetIndex;

  /// 被触摸的轴索引。
  final int? axisIndex;

  /// 触摸点的数据值。
  final double? value;

  /// 轴标签文字。
  final String? axisLabel;

  /// 数据集标签文字。
  final String? dataSetLabel;

  /// 触摸在图表坐标系中的位置。
  final Offset localPosition;
}

/// 雷达图触摸交互配置。
class PolarisRadarTouchData {
  /// 创建一个触摸配置。
  const PolarisRadarTouchData({
    this.onTouch,
    this.touchSpotThreshold = 12.0,
    this.edgeTouchThreshold = 15.0,
    this.highlightColor,
    this.highlightRadiusFactor = 1.8,
    this.showTooltip = true,
    this.tooltipTextStyle,
  });

  /// 触摸回调。
  final PolarisTouchCallback? onTouch;

  /// 顶点触摸命中阈值（逻辑像素），默认 12.0。
  final double touchSpotThreshold;

  /// 边缘触摸命中阈值（逻辑像素），默认 15.0。
  ///
  /// 点击数据集的连线时，距离线段小于此值即命中。
  final double edgeTouchThreshold;

  /// 高亮颜色，默认使用该数据集的线条颜色。
  final Color? highlightColor;

  /// 高亮时顶点放大的倍数，默认 1.8。
  final double highlightRadiusFactor;

  /// 是否显示 tooltip 浮层。
  final bool showTooltip;

  /// Tooltip 文字样式。
  final TextStyle? tooltipTextStyle;
}
