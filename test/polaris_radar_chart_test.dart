import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polaris_radar/polaris_radar.dart';

Widget wrapApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 300, height: 300, child: child),
    ),
  );
}

void main() {
  testWidgets('renders with minimal valid data', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders with 6-axis data', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['力量', '敏捷', '智力', '耐力', '防御', '魔力'],
          dataSets: [
            const PolarisDataSet(
              label: '角色 A',
              dataEntries: [80, 60, 70, 50, 90, 40],
            ),
          ],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders with multiple data sets', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [
            const PolarisDataSet(
              label: 'A',
              dataEntries: [10, 20, 30],
              fillColor: Color(0x264FC3F7),
            ),
            const PolarisDataSet(
              label: 'B',
              dataEntries: [30, 20, 10],
              fillColor: Color(0x26FFC107),
            ),
          ],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders with polygon grid', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          gridShape: RadarGridShape.polygon,
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders without tick labels when style is null', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          tickLabelStyle: null,
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders without axis labels when style is null', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          axisLabelStyle: null,
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('non-interactive by default', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
        interactive: false,
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('dashed line renders', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [
            const PolarisDataSet(
              dataEntries: [10, 20, 30],
              lineStyle: RadarLineStyle(
                color: Color(0xFFEF5350),
                width: 2.0,
                dashArray: [6, 4],
              ),
            ),
          ],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('renders with all point shapes', (tester) async {
    for (final shape in RadarPointShape.values) {
      if (shape == RadarPointShape.none) continue;
      await tester.pumpWidget(wrapApp(
        PolarisRadarChart(
          data: PolarisRadarData(
            axisLabels: ['A', 'B', 'C'],
            dataSets: [
              PolarisDataSet(
                dataEntries: [10, 20, 30],
                pointShape: shape,
                pointSize: 4.0,
              ),
            ],
          ),
        ),
      ));
      expect(find.byType(PolarisRadarChart), findsOneWidget);
    }
  });

  testWidgets('selectedDataSetIndex dims other sets', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [
            const PolarisDataSet(
              label: 'A',
              dataEntries: [10, 20, 30],
            ),
            const PolarisDataSet(
              label: 'B',
              dataEntries: [30, 20, 10],
            ),
          ],
        ),
        selectedDataSetIndex: 0,
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('custom tickLabels renders', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          tickCount: 3,
          tickLabels: const ['低', '中', '高', '最高'],
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });

  testWidgets('animation duration can be zero', (tester) async {
    await tester.pumpWidget(wrapApp(
      PolarisRadarChart(
        data: PolarisRadarData(
          axisLabels: ['A', 'B', 'C'],
          dataSets: [const PolarisDataSet(dataEntries: [10, 20, 30])],
        ),
        duration: Duration.zero,
      ),
    ));
    expect(find.byType(PolarisRadarChart), findsOneWidget);
  });
}
