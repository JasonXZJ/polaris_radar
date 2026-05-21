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

  static const _bgPresets = [
    Color(0xFF0D1117),
    Color(0xFF161C2E),
    Color(0xFF1A2332),
    Color(0xFF2E3A55),
    Color(0xFF4A5163),
    Color(0xFFFFFFFF),
  ];

  static const _labelColorPresets = [
    Color(0xFFFFFFFF),
    Color(0xFFCCCCCC),
    Color(0xFF666F8A),
    Color(0xFF333333),
    Color(0xFF4FC3F7),
    Color(0xFFFFC107),
    Color(0xFFEF5350),
    Color(0xFF4CAF50),
  ];

  static const _linePresets = [
    Color(0xFF4FC3F7),
    Color(0xFFFFC107),
    Color(0xFFEF5350),
    Color(0xFF4CAF50),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
    Color(0xFF26C6DA),
    Color(0xFF8D6E63),
  ];

  // ── 数据 ──
  bool _toggled = false;
  int? _selectedDataSetIndex;
  bool _interactive = true;
  String _touchInfo = '点击数据点查看数值';

  // ── 基础设置 ──
  RadarGridShape _gridShape = RadarGridShape.circle;
  int _tickCount = 5;
  double _titlePositionFactor = 0.20;

  // ── 网格与背景 ──
  Color _bgColor = const Color(0xFF161C2E);
  Color _gridLineColor = const Color(0xFF2E3A55);
  double _gridLineWidth = 1.0;
  Color _axisLineColor = const Color(0xFF2E3A55);
  double _axisLineWidth = 1.0;

  // ── 标签样式 ──
  bool _showAxisLabels = true;
  double _axisLabelSize = 14;
  Color _axisLabelColor = Colors.white;
  bool _showTickLabels = true;
  double _tickLabelSize = 9;
  Color _tickLabelColor = const Color(0xFF666F8A);

  // ── 数据集样式 ──
  int _editingDataSetIndex = 0;
  final _fillColors = [const Color(0xFF4FC3F7), const Color(0xFFFFC107), const Color(0xFFEF5350)];
  final _fillOpacities = [0.15, 0.18, 0.0];
  final _lineColors = [const Color(0xFF4FC3F7), const Color(0xFFFFC107), const Color(0xFFEF5350)];
  final _lineWidths = [2.0, 2.5, 2.0];
  final _pointShapes = [RadarPointShape.circle, RadarPointShape.square, RadarPointShape.triangle];
  final _pointSizes = [4.5, 4.5, 4.5];
  final _dashEnabled = [false, false, true];

  PolarisDataSet _buildDataSet(int index, List<double> entries) => PolarisDataSet(
        label: const ['角色 A', '角色 B', '平均值'][index],
        dataEntries: entries,
        fillColor: _fillColors[index].withValues(alpha: _fillOpacities[index]),
        lineStyle: RadarLineStyle(
          color: _lineColors[index],
          width: _lineWidths[index],
          dashArray: _dashEnabled[index] ? [6, 4] : null,
        ),
        pointShape: _pointShapes[index],
        pointSize: _pointSizes[index],
      );

  PolarisRadarData get _chartData => PolarisRadarData(
        axisLabels: _axisLabels,
        maxValue: 100,
        minValue: 0,
        tickCount: _tickCount,
        gridShape: _gridShape,
        backgroundColor: _bgColor,
        gridLineStyle: RadarLineStyle(
          color: _gridLineColor,
          width: _gridLineWidth,
        ),
        axisLineStyle: RadarLineStyle(
          color: _axisLineColor,
          width: _axisLineWidth,
        ),
        tickLabelStyle: _showTickLabels
            ? TextStyle(color: _tickLabelColor, fontSize: _tickLabelSize)
            : null,
        axisLabelStyle: _showAxisLabels
            ? TextStyle(
                color: _axisLabelColor,
                fontSize: _axisLabelSize,
                fontWeight: FontWeight.w500,
              )
            : null,
        titlePositionFactor: _titlePositionFactor,
        dataSets: [
          _buildDataSet(0, _toggled ? _dataA2 : _dataA),
          _buildDataSet(1, _toggled ? _dataB2 : _dataB),
          _buildDataSet(2, _toggled ? _avgData2 : _avgData),
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            // ── 雷达图 ──
            SizedBox(
              height: 220,
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
                              _touchInfo = '选中: ${response.dataSetLabel ?? ''}';
                            } else {
                              _touchInfo = '点击数据点查看数值';
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.dataSets.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
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
                                lineWidth: 30,
                                textStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // ── 触摸反馈 ──
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF4FC3F7), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _touchInfo,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            // ── 控制面板 ──
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle('📐 基础设置'),
                  _buildSwitchRow('交互模式', _interactive,
                      (v) => setState(() => _interactive = v)),
                  const SizedBox(height: 4),
                  _buildDataToggle(),
                  const SizedBox(height: 8),
                  _buildSegmentedControl(
                    '网格形状',
                    RadarGridShape.values,
                    _gridShape,
                    (v) => setState(() => _gridShape = v),
                    labeler: (v) => v == RadarGridShape.circle ? '圆形' : '多边形',
                  ),
                  const SizedBox(height: 8),
                  _buildSlider('网格圈数', _tickCount.toDouble(), 2, 8,
                      (v) => setState(() => _tickCount = v.round())),
                  _buildSlider('标题外移', _titlePositionFactor, 0.0, 0.4,
                      (v) => setState(() => _titlePositionFactor = v)),

                  const SizedBox(height: 16),
                  _buildSectionTitle('🎨 网格与背景'),
                  _buildColorRow('背景色', _bgColor, _bgPresets,
                      (c) => setState(() => _bgColor = c)),
                  _buildSlider('网格线粗细', _gridLineWidth, 0.5, 3.0,
                      (v) => setState(() => _gridLineWidth = v)),
                  _buildColorRow('网格线色', _gridLineColor, _linePresets,
                      (c) => setState(() => _gridLineColor = c)),
                  _buildSlider('轴线粗细', _axisLineWidth, 0.5, 3.0,
                      (v) => setState(() => _axisLineWidth = v)),
                  _buildColorRow('轴线色', _axisLineColor, _linePresets,
                      (c) => setState(() => _axisLineColor = c)),

                  const SizedBox(height: 16),
                  _buildSectionTitle('📝 标签样式'),
                  _buildSwitchRow('轴标题', _showAxisLabels,
                      (v) => setState(() => _showAxisLabels = v)),
                  if (_showAxisLabels)
                    _buildSlider('字号', _axisLabelSize, 6, 22,
                        (v) => setState(() => _axisLabelSize = v)),
                  if (_showAxisLabels)
                    _buildColorRow('颜色', _axisLabelColor, _labelColorPresets,
                        (c) => setState(() => _axisLabelColor = c)),
                  _buildSwitchRow('刻度数字', _showTickLabels,
                      (v) => setState(() => _showTickLabels = v)),
                  if (_showTickLabels)
                    _buildSlider('字号', _tickLabelSize, 4, 16,
                        (v) => setState(() => _tickLabelSize = v)),
                  if (_showTickLabels)
                    _buildColorRow('颜色', _tickLabelColor, _labelColorPresets,
                        (c) => setState(() => _tickLabelColor = c)),

                  const SizedBox(height: 16),
                  _buildSectionTitle('📊 数据集'),
                  _buildDataSetSelector(),
                  const SizedBox(height: 8),
                  _buildColorRow('填充色', _fillColors[_editingDataSetIndex], _linePresets,
                      (c) => setState(() => _fillColors[_editingDataSetIndex] = c)),
                  _buildSlider(
                    '填充透明度',
                    _fillOpacities[_editingDataSetIndex],
                    0.0, 0.5,
                    (v) => setState(() => _fillOpacities[_editingDataSetIndex] = v),
                  ),
                  _buildColorRow('线条色', _lineColors[_editingDataSetIndex], _linePresets,
                      (c) => setState(() => _lineColors[_editingDataSetIndex] = c)),
                  _buildSlider('线条粗细', _lineWidths[_editingDataSetIndex], 0.5, 5.0,
                      (v) => setState(() => _lineWidths[_editingDataSetIndex] = v)),
                  const SizedBox(height: 8),
                  _buildSegmentedControl(
                    '顶点形状',
                    [RadarPointShape.circle, RadarPointShape.square, RadarPointShape.diamond, RadarPointShape.triangle],
                    _pointShapes[_editingDataSetIndex],
                    (v) => setState(() => _pointShapes[_editingDataSetIndex] = v),
                    labeler: (v) {
                      switch (v) {
                        case RadarPointShape.circle: return '●';
                        case RadarPointShape.square: return '■';
                        case RadarPointShape.diamond: return '◆';
                        case RadarPointShape.triangle: return '▲';
                        default: return '';
                      }
                    },
                  ),
                  _buildSlider('顶点大小', _pointSizes[_editingDataSetIndex], 0.0, 10.0,
                      (v) => setState(() => _pointSizes[_editingDataSetIndex] = v)),
                  _buildSwitchRow('虚线', _dashEnabled[_editingDataSetIndex],
                      (v) => setState(() => _dashEnabled[_editingDataSetIndex] = v)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI 构建辅助 ──

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDataToggle() {
    return Row(
      children: [
        const SizedBox(width: 8),
        _buildToggleChip('数据 A', !_toggled, () => setState(() => _toggled = false)),
        const SizedBox(width: 8),
        _buildToggleChip('数据 B', _toggled, () => setState(() => _toggled = true)),
      ],
    );
  }

  Widget _buildToggleChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4FC3F7) : const Color(0xFF2E3A55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0D1117) : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDataSetSelector() {
    return Row(
      children: [
        const SizedBox(width: 8),
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildToggleChip(
              const ['角色 A', '角色 B', '平均值'][i],
              _editingDataSetIndex == i,
              () => setState(() => _editingDataSetIndex = i),
            ),
          ),
      ],
    );
  }

  Widget _buildSegmentedControl<T>(
    String label,
    List<T> values,
    T selected,
    ValueChanged<T> onChanged, {
    required String Function(T) labeler,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ...values.map((v) {
            final isSelected = v == selected;
            return GestureDetector(
              onTap: () => onChanged(v),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4FC3F7) : const Color(0xFF2E3A55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  labeler(v),
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0D1117) : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(
      String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF4FC3F7),
                inactiveTrackColor: const Color(0xFF2E3A55),
                thumbColor: const Color(0xFF4FC3F7),
                overlayColor: const Color(0x334FC3F7),
                valueIndicatorColor: const Color(0xFF4FC3F7),
                valueIndicatorTextStyle: const TextStyle(color: Color(0xFF0D1117)),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: (max - min) <= 1
                    ? ((max - min) / 0.02).round().clamp(1, 100)
                    : ((max - min) / 0.1).round().clamp(1, 100),
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              value == value.roundToDouble()
                  ? value.toInt().toString()
                  : value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(
      String label, Color selected, List<Color> colors, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          const SizedBox(width: 4),
          ...colors.map((c) {
            final isSelected = c.toARGB32() == selected.toARGB32();
            return GestureDetector(
              onTap: () => onChanged(c),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: const Color(0xFF4FC3F7),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
