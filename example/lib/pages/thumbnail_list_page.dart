import 'package:flutter/material.dart';
import 'package:polaris_radar/polaris_radar.dart';
import '../data/magic_theme.dart';

class ThumbnailListPage extends StatelessWidget {
  const ThumbnailListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final radarData = buildMagicThumbnailData();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('小图例展示'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => RepaintBoundary(child: _buildCard(radarData)),
      ),
    );
  }

  Widget _buildCard(PolarisRadarData radarData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2125),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '综合魔法等级',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'S7--大法师',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '2026年3月26日 11:03',
                style: TextStyle(
                  color: Color(0xFF666F8A),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < 3; row++)
                Padding(
                  padding: EdgeInsets.only(top: row > 0 ? 6 : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTag(magicTagLabels[row * 2], magicTagColors[row * 2]),
                      const SizedBox(width: 6),
                      _buildTag(magicTagLabels[row * 2 + 1], magicTagColors[row * 2 + 1]),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: PolarisRadarChart(
              data: radarData,
              interactive: false,
              duration: Duration.zero,
              touchData: const PolarisRadarTouchData(showTooltip: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      width: 56,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
