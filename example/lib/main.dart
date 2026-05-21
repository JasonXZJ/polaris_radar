import 'package:flutter/material.dart';
import 'pages/full_demo_page.dart';
import 'pages/thumbnail_list_page.dart';

void main() => runApp(const PolarisRadarExampleApp());

class PolarisRadarExampleApp extends StatelessWidget {
  const PolarisRadarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polaris Radar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text('Polaris Radar Demo'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.donut_large, color: Color(0xFF4FC3F7)),
            title: const Text(
              '完整功能演示',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              '多数据集 · 动画 · 触摸交互 · 图例联动',
              style: TextStyle(color: Color(0xFF666F8A), fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF666F8A)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FullDemoPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_list, color: Color(0xFFFFC107)),
            title: const Text(
              '列表小图例演示',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              '把雷达图作为列表卡片缩略图（魔法属性）',
              style: TextStyle(color: Color(0xFF666F8A), fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF666F8A)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThumbnailListPage()),
            ),
          ),
        ],
      ),
    );
  }
}
