import 'package:flutter/material.dart';
import 'package:polaris_radar/polaris_radar.dart';

const List<String> magicAxisLabels = [
  '力量',
  '敏捷',
  '智力',
  '耐力',
  '防御',
  '魔力',
];

const List<Color> magicTagColors = [
  Color(0xFF4A6B8A),
  Color(0xFF4E7A5C),
  Color(0xFF9B8158),
  Color(0xFF5A4E8C),
  Color(0xFF8B4E7E),
  Color(0xFF9C4A4A),
];

const List<String> magicTagLabels = [
  '力 L5',
  '敏 L5',
  '智 L5',
  '耐 L5',
  '防 L5',
  '魔 L5',
];

PolarisRadarData buildMagicThumbnailData() => PolarisRadarData(
      axisLabels: magicAxisLabels,
      maxValue: 100,
      minValue: 0,
      tickCount: 4,
      gridShape: RadarGridShape.circle,
      backgroundColor: const Color(0x00000000),
      gridLineStyle: const RadarLineStyle(color: Color(0xFF4A5163), width: 0.8),
      axisLineStyle: const RadarLineStyle(color: Color(0xFF4A5163), width: 0.8),
      tickLabelStyle: const TextStyle(
        color: Color(0xFF666F8A),
        fontSize: 2,
      ),
      axisLabelStyle: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 3,
      ),
      dataSets: [
        PolarisDataSet(
          label: '综合',
          dataEntries: [60, 70, 80, 65, 75, 85],
          fillColor: const Color(0x264FC3F7),
          lineStyle: const RadarLineStyle(
            color: Color(0xFF4FC3F7),
            width: 1.5,
          ),
          pointShape: RadarPointShape.none,
        ),
      ],
    );
