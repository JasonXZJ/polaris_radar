# polaris_radar

A highly customizable Flutter radar chart library with zero external dependencies.

## Features

- **Per-dataset borders** — solid or dashed (`dashArray`) per data series
- **Custom vertex markers** — `circle` / `square` / `diamond` / `triangle`
- **Grid shapes** — circular or polygon
- **Implicit animations** — smooth transitions when data changes
- **Legend widget** — `RadarLegendItem` matches line style and marker shape automatically
- **Zero dependencies** — pure Flutter, no external packages required

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  polaris_radar:
    path: ../polaris_radar   # or pub.dev version once published
```

## Usage

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
      // Solid blue line, circle markers
      PolarisDataSet(
        label: '角色 A',
        dataEntries: [80, 60, 70, 50, 90, 40],
        fillColor: Colors.blue.withOpacity(0.15),
        lineStyle: RadarLineStyle(color: Colors.blue, width: 2),
        pointShape: RadarPointShape.circle,
        pointSize: 4.5,
      ),
      // Dashed red line, triangle markers
      PolarisDataSet(
        label: '平均值',
        dataEntries: [65, 55, 60, 55, 65, 50],
        fillColor: Colors.transparent,
        lineStyle: RadarLineStyle(
          color: Colors.red,
          width: 2,
          dashArray: [6, 4],   // 6px dash, 4px gap
        ),
        pointShape: RadarPointShape.triangle,
        pointSize: 4.5,
      ),
    ],
  ),
  duration: const Duration(milliseconds: 500),
)
```

### Legend

```dart
RadarLegendItem(
  dataSet: myDataSet,
  lineWidth: 36,
  textStyle: TextStyle(color: Colors.white70, fontSize: 13),
)
```

## API reference

### `PolarisRadarData`

| Property | Type | Description |
|---|---|---|
| `axisLabels` | `List<String>` | Axis titles — also determines axis count (≥ 3) |
| `dataSets` | `List<PolarisDataSet>` | One entry per data series |
| `maxValue` | `double?` | Max value; auto-detected if null |
| `minValue` | `double` | Min value (center). Default `0` |
| `tickCount` | `int` | Number of concentric rings |
| `gridShape` | `RadarGridShape` | `circle` or `polygon` |
| `backgroundColor` | `Color` | Fill color of the radar background |
| `gridLineStyle` | `RadarLineStyle` | Concentric grid ring style |
| `axisLineStyle` | `RadarLineStyle` | Radial axis line style |
| `tickLabelStyle` | `TextStyle?` | Tick number text style |
| `axisLabelStyle` | `TextStyle?` | Axis title text style |
| `titlePositionFactor` | `double` | Extra padding beyond radar edge (0 = tight) |

### `PolarisDataSet`

| Property | Type | Description |
|---|---|---|
| `dataEntries` | `List<double>` | Values — must match `axisLabels` length |
| `fillColor` | `Color?` | Polygon fill color |
| `fillGradient` | `Gradient?` | Polygon fill gradient (overrides `fillColor`) |
| `lineStyle` | `RadarLineStyle` | Border color, width, dash pattern |
| `pointShape` | `RadarPointShape` | Marker shape at each vertex |
| `pointSize` | `double` | Marker radius in logical pixels |
| `label` | `String` | Legend label text |

### `RadarLineStyle`

| Property | Type | Description |
|---|---|---|
| `color` | `Color` | Line color |
| `width` | `double` | Line width |
| `dashArray` | `List<double>?` | `null` = solid; `[6, 4]` = 6px dash + 4px gap |

### Enums

```dart
enum RadarGridShape  { circle, polygon }
enum RadarPointShape { none, circle, square, diamond, triangle }
```

## License

MIT
