[English](README.md) | **中文**

# polaris_radar

高度可定制的 Flutter 雷达图组件库，零外部依赖。

## 特性

- **数据集独立边框** — 每条数据可单独设置实线或虚线（`dashArray`）
- **自定义顶点标记** — 支持 `circle` / `square` / `diamond` / `triangle` / `none`
- **网格形状** — 圆形或正多边形网格
- **填充模式** — 纯色或渐变填充
- **触摸交互** — 点击检测顶点和边缘，支持高亮和 tooltip
- **内置图例组件** — `RadarLegendItem` 自动匹配线条样式与标记形状
- **数据集高亮** — `selectedDataSetIndex` 高亮选中数据集并淡化其余
- **自定义刻度标签** — 可覆盖自动生成的数字标签
- **隐式动画** — 数据更新时自动平滑过渡
- **零依赖** — 纯 Flutter 实现，无需额外包

## 快速开始

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  polaris_radar:
    path: ../polaris_radar   # 或从 pub.dev 引入
```

## 使用示例

```dart
import 'package:polaris_radar/polaris_radar.dart';

PolarisRadarChart(
  data: PolarisRadarData(
    axisLabels: ['力量', '敏捷', '智力', '耐力', '防御', '魔力'],
    maxValue: 100,
    tickCount: 5,
    gridShape: RadarGridShape.circle,
    backgroundColor: const Color(0xFF161C2E),
    gridLineStyle: const RadarLineStyle(color: Color(0xFF2E3A55), width: 1),
    axisLineStyle: const RadarLineStyle(color: Color(0xFF2E3A55), width: 1),
    tickLabelStyle: const TextStyle(color: Color(0xFF666F8A), fontSize: 9),
    axisLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
    dataSets: [
      // 蓝色实线 + 圆形顶点标记
      PolarisDataSet(
        label: '角色 A',
        dataEntries: [80, 60, 70, 50, 90, 40],
        fillColor: Colors.blue.withValues(alpha: 0.15),
        lineStyle: RadarLineStyle(color: Colors.blue, width: 2),
        pointShape: RadarPointShape.circle,
        pointSize: 4.5,
      ),
      // 红色虚线 + 三角形顶点标记
      PolarisDataSet(
        label: '平均值',
        dataEntries: [65, 55, 60, 55, 65, 50],
        fillColor: Colors.transparent,
        lineStyle: RadarLineStyle(
          color: Colors.red,
          width: 2,
          dashArray: [6, 4],   // 6px 实线, 4px 间隔
        ),
        pointShape: RadarPointShape.triangle,
        pointSize: 4.5,
      ),
    ],
  ),
  duration: const Duration(milliseconds: 500),
)
```

### 触摸交互

```dart
PolarisRadarChart(
  data: myData,
  touchData: PolarisRadarTouchData(
    onTouch: (response) {
      if (response != null) {
        print('${response.axisLabel}: ${response.value}');
      }
    },
  ),
)
```

### 图例组件

```dart
RadarLegendItem(
  dataSet: myDataSet,
  lineWidth: 36,
  textStyle: const TextStyle(color: Colors.white70, fontSize: 13),
)
```

## API 参考

### `PolarisRadarChart`

| 属性 | 类型 | 说明 |
|---|---|---|
| `data` | `PolarisRadarData` | 图表数据与配置 |
| `duration` | `Duration` | 数据切换动画时长（默认 300ms） |
| `curve` | `Curve` | 动画曲线（默认 `easeInOut`） |
| `touchData` | `PolarisRadarTouchData?` | 触摸交互配置 |
| `selectedDataSetIndex` | `int?` | 选中数据集索引，其余自动淡化 |
| `interactive` | `bool` | 是否启用触摸（默认 `true`） |

### `PolarisRadarData`

| 属性 | 类型 | 说明 |
|---|---|---|
| `axisLabels` | `List<String>` | 各轴标题，同时决定轴数量（至少 3 个） |
| `dataSets` | `List<PolarisDataSet>` | 数据集列表 |
| `maxValue` | `double?` | 数据最大值，为 null 时自动检测 |
| `minValue` | `double` | 最小值（圆心），默认 `0` |
| `tickCount` | `int` | 同心网格圈数 |
| `tickLabels` | `List<String>?` | 自定义刻度标签，为 null 时自动生成 |
| `gridShape` | `RadarGridShape` | 网格形状：`circle` 或 `polygon` |
| `backgroundColor` | `Color` | 雷达图背景色 |
| `gridLineStyle` | `RadarLineStyle` | 同心网格线样式 |
| `axisLineStyle` | `RadarLineStyle` | 径向轴线样式 |
| `tickLabelStyle` | `TextStyle?` | 刻度数字文字样式（null 隐藏） |
| `axisLabelStyle` | `TextStyle?` | 轴标题文字样式（null 隐藏） |
| `titlePositionFactor` | `double` | 轴标题距雷达边缘比例（0 = 紧贴） |

### `PolarisDataSet`

| 属性 | 类型 | 说明 |
|---|---|---|
| `dataEntries` | `List<double>` | 数据值数组，长度与 `axisLabels` 一致 |
| `fillColor` | `Color?` | 多边形填充色 |
| `fillGradient` | `Gradient?` | 多边形填充渐变（优先于 `fillColor`） |
| `lineStyle` | `RadarLineStyle` | 边框颜色、粗细、虚线模式 |
| `pointShape` | `RadarPointShape` | 顶点标记形状 |
| `pointSize` | `double` | 标记半径（逻辑像素） |
| `label` | `String` | 图例标签文字 |

### `RadarLineStyle`

| 属性 | 类型 | 说明 |
|---|---|---|
| `color` | `Color` | 线条颜色（默认 `0xFF555555`） |
| `width` | `double` | 线条宽度（默认 `1.5`） |
| `dashArray` | `List<double>?` | `null` = 实线；`[6, 4]` = 6px 实线 + 4px 间隔 |

### `PolarisRadarTouchData`

| 属性 | 类型 | 说明 |
|---|---|---|
| `onTouch` | `PolarisTouchCallback?` | 触摸回调，参数 `PolarisTouchResponse?` |
| `touchSpotThreshold` | `double` | 顶点命中半径（逻辑像素，默认 12） |
| `edgeTouchThreshold` | `double` | 边缘命中距离（逻辑像素，默认 15） |
| `highlightColor` | `Color?` | 高亮颜色（默认使用线条颜色） |
| `highlightRadiusFactor` | `double` | 高亮时顶点放大倍数（默认 1.8） |
| `showTooltip` | `bool` | 是否显示 tooltip（默认 `true`） |
| `tooltipTextStyle` | `TextStyle?` | Tooltip 文字样式 |

### `RadarLegendItem`

| 属性 | 类型 | 说明 |
|---|---|---|
| `dataSet` | `PolarisDataSet` | 要渲染的数据集 |
| `lineWidth` | `double` | 预览线宽度（默认 32） |
| `textStyle` | `TextStyle?` | 标签文字样式 |
| `spacing` | `double` | 线条与文字间距（默认 8） |
| `isSelected` | `bool` | 是否选中 |
| `onTap` | `VoidCallback?` | 点击回调 |
| `selectedTextStyle` | `TextStyle?` | 选中时文字样式 |

### 枚举

```dart
enum RadarGridShape  { circle, polygon }
enum RadarPointShape { none, circle, square, diamond, triangle }
```

## 屏幕截图

<img src="example/screenshots/full_demo_chart.png" width="320" alt="全功能展示" />

*全功能展示页 — 6 轴雷达图及图例、触摸反馈。*

<img src="example/screenshots/full_demo_controls1.png" width="320" alt="操作按钮 1" />

*操作按钮区域 — 可滚动参数设置面板（上方）。*

<img src="example/screenshots/full_demo_controls2.png" width="320" alt="操作按钮 2" />

*操作按钮区域 — 可滚动参数设置面板（中部）。*

<img src="example/screenshots/full_demo_controls3.png" width="320" alt="操作按钮 3" />

*操作按钮区域 — 可滚动参数设置面板（下方）。*

<img src="example/screenshots/thumbnail_list.png" width="320" alt="缩略图列表" />

*缩略图卡片列表 — 内嵌缩略雷达图。*

## Demo 示例

`example/` 目录包含完整功能演示应用：

- **完整功能演示** — 6 轴雷达图 + 3 个数据集，底部控制面板可实时调节所有参数
- **缩略图卡片列表** — 类"我的报告"风格卡片列表，内嵌缩略雷达图与魔法属性标签

## 许可协议

MIT
