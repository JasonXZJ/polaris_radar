import 'package:flutter/material.dart';
import 'package:polaris_radar/polaris_radar.dart';

class FullDemoPage extends StatefulWidget {
  const FullDemoPage({super.key});

  @override
  State<FullDemoPage> createState() => _FullDemoPageState();
}

class _FullDemoPageState extends State<FullDemoPage> {
  static const _axisLabels = ['力量', '敏捷', '智力', '耐力', '防御', '魔力'];

  static const _dataA = [80.0, 60.0, 70.0, 50.0, 90.0, 40.0];
  static const _dataB = [55.0, 85.0, 65.0, 75.0, 45.0, 95.0];
  static const _avgData = [65.0, 55.0, 60.0, 55.0, 65.0, 50.0];

  static const _dataA2 = [50.0, 90.0, 40.0, 80.0, 60.0, 70.0];
  static const _dataB2 = [75.0, 45.0, 95.0, 55.0, 85.0, 65.0];
  static const _avgData2 = [60.0, 55.0, 70.0, 50.0, 65.0, 55.0];

  bool _toggled = false;
  int? _selectedDataSetIndex;
  bool _interactive = true;
  String _touchInfo = '点击数据点查看数值';

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
        title: const Text('完整功能演示'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app,
                  color: Color(0xFF4FC3F7), size: 16),
              SizedBox(
                height: 20,
                child: Switch(
                  value: _interactive,
                  onChanged: (v) => setState(() => _interactive = v),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
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
                      selectedDataSetIndex: _selectedDataSetIndex,
                      interactive: _interactive,
                      duration: const Duration(milliseconds: 500),
                      touchData: PolarisRadarTouchData(
                        onTouch: (response) {
                          setState(() {
                            _selectedDataSetIndex = response?.dataSetIndex;
                            if (response != null && response.axisIndex != null) {
                              _touchInfo = '${response.dataSetLabel ?? ''} - '
                                  '${response.axisLabel ?? ''}: '
                                  '${response.value?.toStringAsFixed(1) ?? ''}';
                            } else if (response != null) {
                              _touchInfo =
                                  '选中: ${response.dataSetLabel ?? ''}';
                            } else {
                              _touchInfo = '点击数据点查看数值';
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.dataSets.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: RadarLegendItem(
                                dataSet: entry.value,
                                isSelected: _selectedDataSetIndex == entry.key,
                                onTap: () {
                                  setState(() {
                                    _selectedDataSetIndex =
                                        _selectedDataSetIndex == entry.key
                                            ? null
                                            : entry.key;
                                  });
                                },
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF4FC3F7), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _touchInfo,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
