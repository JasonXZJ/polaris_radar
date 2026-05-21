import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polaris_radar/polaris_radar.dart';

void main() {
  group('RadarLineStyle', () {
    test('default constructor', () {
      const style = RadarLineStyle();
      expect(style.color, const Color(0xFF555555));
      expect(style.width, 1.5);
      expect(style.dashArray, isNull);
    });

    test('custom constructor', () {
      const style = RadarLineStyle(
        color: Color(0xFF4FC3F7),
        width: 2.0,
        dashArray: [6, 4],
      );
      expect(style.color, const Color(0xFF4FC3F7));
      expect(style.width, 2.0);
      expect(style.dashArray, [6, 4]);
    });

    test('lerp', () {
      const a = RadarLineStyle(color: Color(0xFF000000), width: 1.0);
      const b = RadarLineStyle(color: Color(0xFFFFFFFF), width: 3.0);
      final t0 = a.lerp(b, 0.0);
      expect(t0.color, const Color(0xFF000000));
      expect(t0.width, 1.0);
      final t1 = a.lerp(b, 1.0);
      expect(t1.color, const Color(0xFFFFFFFF));
      expect(t1.width, 3.0);
    });

    test('lerp dashArray picks based on t', () {
      const a = RadarLineStyle(dashArray: [2, 2]);
      const b = RadarLineStyle(dashArray: [6, 4]);
      expect(a.lerp(b, 0.0).dashArray, [2, 2]);
      expect(a.lerp(b, 0.4).dashArray, [2, 2]);
      expect(a.lerp(b, 0.5).dashArray, [6, 4]);
      expect(a.lerp(b, 1.0).dashArray, [6, 4]);
    });
  });

  group('PolarisDataSet', () {
    test('default constructor', () {
      const ds = PolarisDataSet(dataEntries: [10, 20, 30]);
      expect(ds.label, '');
      expect(ds.fillColor, isNull);
      expect(ds.pointShape, RadarPointShape.circle);
      expect(ds.pointSize, 4.0);
      expect(ds.lineStyle.width, 2.0);
    });

    test('custom constructor', () {
      const ds = PolarisDataSet(
        label: '测试',
        dataEntries: [50, 60, 70, 80, 90, 100],
        fillColor: Color(0x264FC3F7),
        lineStyle: RadarLineStyle(color: Color(0xFF4FC3F7), width: 2.5),
        pointShape: RadarPointShape.square,
        pointSize: 5.0,
      );
      expect(ds.label, '测试');
      expect(ds.dataEntries, [50, 60, 70, 80, 90, 100]);
      expect(ds.pointShape, RadarPointShape.square);
      expect(ds.pointSize, 5.0);
    });

    test('copyWith', () {
      const ds = PolarisDataSet(dataEntries: [10, 20, 30]);
      final copied = ds.copyWith(label: '新标签', dataEntries: [40, 50, 60]);
      expect(copied.label, '新标签');
      expect(copied.dataEntries, [40, 50, 60]);
      expect(copied.pointShape, RadarPointShape.circle); // unchanged
    });

    test('lerp', () {
      const a = PolarisDataSet(dataEntries: [0, 0, 0], pointSize: 2.0);
      const b = PolarisDataSet(dataEntries: [100, 100, 100], pointSize: 8.0);
      final mid = a.lerp(b, 0.5);
      expect(mid.dataEntries[0], closeTo(50, 0.01));
      expect(mid.dataEntries[1], closeTo(50, 0.01));
      expect(mid.pointSize, closeTo(5.0, 0.01));
    });
  });

  group('PolarisRadarData', () {
    test('accepts 2 axisLabels', () {
      // 目前没有硬性断言，少于 3 个不会抛错
      final data = PolarisRadarData(
        axisLabels: ['A', 'B'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2])],
      );
      expect(data.axisCount, 2);
    });

    test('dataEntries length mismatch is allowed at construction', () {
      // 数据长度校验不在构造函数中
      final data = PolarisRadarData(
        axisLabels: ['力量', '敏捷', '智力', '耐力', '防御', '魔力'],
        dataSets: [
          const PolarisDataSet(dataEntries: [1, 2, 3]),
        ],
      );
      expect(data.axisCount, 6);
      expect(data.dataSets.first.dataEntries.length, 3);
    });

    test('axisCount returns labels length', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      expect(data.axisCount, 3);
    });

    test('effectiveMax uses explicit maxValue', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        maxValue: 200,
        dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
      );
      expect(data.effectiveMax, 200);
    });

    test('effectiveMax auto-calculates from data', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [10, 50, 30])],
      );
      expect(data.effectiveMax, 50);
    });

    test('effectiveMax returns 100 when all values are negative infinity', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        maxValue: null,
        dataSets: [
          const PolarisDataSet(dataEntries: []),
        ],
      );
      expect(data.effectiveMax, 100);
    });

    test('tickCount default is 5', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      expect(data.tickCount, 5);
    });

    test('backgroundColor default is transparent', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      expect(data.backgroundColor, Colors.transparent);
    });

    test('gridShape default is circle', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      expect(data.gridShape, RadarGridShape.circle);
    });

    test('custom tickLabels', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        tickCount: 3,
        tickLabels: const ['0', '33', '66', '100'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      expect(data.tickLabels, ['0', '33', '66', '100']);
    });

    test('copyWith', () {
      final data = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
      );
      final copied = data.copyWith(
        tickCount: 8,
        gridShape: RadarGridShape.polygon,
      );
      expect(copied.tickCount, 8);
      expect(copied.gridShape, RadarGridShape.polygon);
      expect(copied.axisLabels, ['A', 'B', 'C']); // unchanged
    });

    test('lerp uses other tickCount (no interpolation)', () {
      final a = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [1, 2, 3])],
        tickCount: 3,
      );
      final b = PolarisRadarData(
        axisLabels: ['A', 'B', 'C'],
        dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        tickCount: 6,
      );
      // lerp 直接取 other.tickCount，不插值
      expect(a.lerp(b, 0.0).tickCount, 6);
      expect(a.lerp(b, 1.0).tickCount, 6);
    });
  });

  group('PolarisTouchResponse', () {
    test('constructor', () {
      final response = PolarisTouchResponse(
        dataSetIndex: 0,
        axisIndex: 2,
        value: 80.0,
        axisLabel: '力量',
        dataSetLabel: '角色 A',
        localPosition: const Offset(100, 100),
      );
      expect(response.dataSetIndex, 0);
      expect(response.axisIndex, 2);
      expect(response.value, 80.0);
      expect(response.axisLabel, '力量');
      expect(response.dataSetLabel, '角色 A');
    });
  });

  group('PolarisRadarTouchData', () {
    test('default showTooltip is true', () {
      const td = PolarisRadarTouchData();
      expect(td.showTooltip, isTrue);
      expect(td.touchSpotThreshold, 12.0);
      expect(td.highlightRadiusFactor, 1.8);
    });
  });
}
