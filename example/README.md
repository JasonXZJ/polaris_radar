**English** | [中文](README_zh.md)

# polaris_radar Example

A comprehensive demo application showcasing all features of the polaris_radar chart library.

## Screenshots

<img src="screenshots/full_demo_chart.png" width="320" alt="Full demo chart" />

*Full demo page — 6-axis radar chart with legend and touch feedback.*

<img src="screenshots/full_demo_controls1.png" width="320" alt="Controls panel 1" />

*Controls panel — scrollable parameter settings (top).*

<img src="screenshots/full_demo_controls2.png" width="320" alt="Controls panel 2" />

*Controls panel — scrollable parameter settings (middle).*

<img src="screenshots/full_demo_controls3.png" width="320" alt="Controls panel 3" />

*Controls panel — scrollable parameter settings (bottom).*

<img src="screenshots/thumbnail_list.png" width="320" alt="Thumbnail cards" />

*Thumbnail card list — miniature radar charts.*

## Pages

### Home

A list-based entry point with two navigation options:

- **完整功能演示 (Full Demo)** — Explore all chart parameters interactively
- **缩略图列表 (Thumbnail Cards)** — "My Reports" style card list with miniature radar charts

### Full Demo Page

An interactive 6-axis radar chart with real-time control panel covering:

| Category | Controls |
|---|---|
| **基础设置 (Basic)** | Grid shape (circle/polygon), tick count, title offset, data toggle |
| **网格与背景 (Grid & BG)** | Background color, grid/axis line width and color |
| **标签样式 (Labels)** | Axis/tick labels toggle, font size and color |
| **数据集 (Datasets)** | Fill color & opacity, line color & width, vertex shape & size, dash toggle |

Features:
- Three datasets (Character A, Character B, Average) with distinct styling
- Touch interaction — tap vertices to see tooltips with data values
- Legend with selection — tap legend items to highlight/dim datasets
- Smooth animation on data and parameter changes

### Thumbnail List Page

A "My Reports" style card list with:

- Miniature radar charts (80×80) rendered inside styled cards
- Magic attribute theme with 6-axis stats (Light, Dark, Fire, Ice, Wind, Thunder)
- Per-axis rating tags (L1–L5 scale) with color-coded labels
- Non-interactive charts with tiny labels optimized for small sizes

## How to run

```bash
cd example
flutter run -d chrome
```

Or other supported platforms:

```bash
flutter run -d macos
flutter run -d ios
```
