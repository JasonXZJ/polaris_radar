import 'package:flutter/material.dart';
import 'package:polaris_radar/polaris_radar.dart';

void main() => runApp(const PolarisRadarExampleApp());

class PolarisRadarExampleApp extends StatelessWidget {
  const PolarisRadarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polaris Radar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const RadarDemoPage(),
    );
  }
}

class RadarDemoPage extends StatefulWidget {
  const RadarDemoPage({super.key});

  @override
  State<RadarDemoPage> createState() => _RadarDemoPageState();
}

class _RadarDemoPageState extends State<RadarDemoPage> {
  static const _axisLabels = ['力量', '敏捷', '智力', '耐力', '防御', '魔力'];

  static const _dataA = [80.0, 60.0, 70.0, 50.0, 90.0, 40.0];
  static const _dataB = [55.0, 85.0, 65.0, 75.0, 45.0, 95.0];
  static const _avgData = [65.0, 55.0, 60.0, 55.0, 65.0, 50.0];

  static const _dataA2 = [50.0, 90.0, 40.0, 80.0, 60.0, 70.0];
  static const _dataB2 = [75.0, 45.0, 95.0, 55.0, 85.0, 65.0];
  static const _avgData2 = [60.0, 55.0, 70.0, 50.0, 65.0, 55.0];

  bool _toggled = false;

  PolarisRadarData get _chartData => PolarisRadarData(
        axisLabels: _axisLabels,
        maxValue: 100,
        minValue: 0,
        tickCount: 5,
        gridShape: RadarGridShape.circle,
        backgroundColor: const Color(0xFF161C2E),
        gridLineStyle: const RadarLineStyle(color: Color(0xFF2E3A55), width: 1),
        axisLineStyle: const RadarLineStyle(color: Color(0xFF2E3A55), width: 1),
        tickLabelStyle: const TextStyle(
          color: Color(0xFF666F8A),
          fontSize: 9,
        ),
        axisLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titlePositionFactor: 0.20,
        dataSets: [
          PolarisDataSet(
            label: '角色 A',
            dataEntries: _toggled ? _dataA2 : _dataA,
            fillColor: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
            lineStyle: const RadarLineStyle(
              color: Color(0xFF4FC3F7),
              width: 2.0,
            ),
            pointShape: RadarPointShape.circle,
            pointSize: 4.5,
          ),
          PolarisDataSet(
            label: '角色 B',
            dataEntries: _toggled ? _dataB2 : _dataB,
            fillColor: const Color(0xFFFFC107).withValues(alpha: 0.18),
            lineStyle: const RadarLineStyle(
              color: Color(0xFFFFC107),
              width: 2.5,
            ),
            pointShape: RadarPointShape.square,
            pointSize: 4.5,
          ),
          PolarisDataSet(
            label: '平均值',
            dataEntries: _toggled ? _avgData2 : _avgData,
            fillColor: Colors.transparent,
            lineStyle: const RadarLineStyle(
              color: Color(0xFFEF5350),
              width: 2.0,
              dashArray: [6, 4],
            ),
            pointShape: RadarPointShape.triangle,
            pointSize: 4.5,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final data = _chartData;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Polaris Radar'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _toggled = !_toggled),
            child: Text(
              _toggled ? '数据 A' : '数据 B',
              style: const TextStyle(color: Color(0xFF4FC3F7)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PolarisRadarChart(
                      data: data,
                      duration: const Duration(milliseconds: 500),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.dataSets
                          .map(
                            (ds) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: RadarLegendItem(
                                dataSet: ds,
                                lineWidth: 36,
                                textStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
}
