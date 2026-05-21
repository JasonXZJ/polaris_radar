# polaris_radar

高度可定制的 Flutter 雷达图组件库，零外部依赖。

## 特性

- **数据集独立边框** — 每条数据可单独设置实线或虚线（`dashArray`）
- **自定义顶点标记** — 支持 `circle` / `square` / `diamond` / `triangle` 四种形状
- **网格形状** — 圆形或正多边形网格
- **隐式动画** — 数据更新时自动平滑过渡
- **内置图例组件** — `RadarLegendItem` 自动匹配线条样式与标记形状
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
    dataSets: [
      // 蓝色实线 + 圆形顶点标记
      PolarisDataSet(
        label: '角色 A',
        dataEntries: [80, 60, 70, 50, 90, 40],
        fillColor: Colors.blue.withOpacity(0.15),
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

### 图例组件

```dart
RadarLegendItem(
  dataSet: myDataSet,
  lineWidth: 36,
  textStyle: TextStyle(color: Colors.white70, fontSize: 13),
)
```

## API 参考

### `PolarisRadarData`

雷达图的全部配置项。

| 属性 | 类型 | 说明 |
|---|---|---|
| `axisLabels` | `List<String>` | 各轴标题，同时决定轴数量（至少 3 个） |
| `dataSets` | `List<PolarisDataSet>` | 数据集列表 |
| `maxValue` | `double?` | 数据最大值，为 null 时自动检测 |
| `minValue` | `double` | 最小值（圆心），默认 `0` |
| `tickCount` | `int` | 同心网格圈数 |
| `gridShape` | `RadarGridShape` | 网格形状：`circle` 或 `polygon` |
| `backgroundColor` | `Color` | 雷达图背景色 |
| `gridLineStyle` | `RadarLineStyle` | 同心网格线样式 |
| `axisLineStyle` | `RadarLineStyle` | 径向轴线样式 |
| `tickLabelStyle` | `TextStyle?` | 刻度数字文字样式 |
| `axisLabelStyle` | `TextStyle?` | 轴标题文字样式 |
| `titlePositionFactor` | `double` | 轴标题距雷达边缘的额外比例（0 = 紧贴边缘） |

### `PolarisDataSet`

单条数据集的完整描述。

| 属性 | 类型 | 说明 |
|---|---|---|
| `dataEntries` | `List<double>` | 数据值数组，长度必须与 `axisLabels` 一致 |
| `fillColor` | `Color?` | 多边形填充色 |
| `fillGradient` | `Gradient?` | 多边形填充渐变（优先于 `fillColor`） |
| `lineStyle` | `RadarLineStyle` | 边框颜色、粗细、虚线模式 |
| `pointShape` | `RadarPointShape` | 顶点标记形状 |
| `pointSize` | `double` | 标记半径（逻辑像素） |
| `label` | `String` | 图例标签文字 |

### `RadarLineStyle`

线条样式配置。

| 属性 | 类型 | 说明 |
|---|---|---|
| `color` | `Color` | 线条颜色 |
| `width` | `double` | 线条宽度 |
| `dashArray` | `List<double>?` | `null` = 实线；`[6, 4]` = 6px 实线 + 4px 间隔 |

### 枚举

```dart
enum RadarGridShape  { circle, polygon }
enum RadarPointShape { none, circle, square, diamond, triangle }
```

## 许可协议

MIT
