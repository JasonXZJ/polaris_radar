**English** | [中文](README_zh.md)

# polaris_radar Example

A comprehensive demo application showcasing all features of the polaris_radar chart library.

## Screenshots

![Full demo chart](screenshots/full_demo_chart.png)
Full demo page — 6-axis radar chart with legend and touch feedback.

![Controls panel 1](screenshots/full_demo_controls1.png)
Controls panel — scrollable parameter settings (top).

![Controls panel 2](screenshots/full_demo_controls2.png)
Controls panel — scrollable parameter settings (middle).

![Controls panel 3](screenshots/full_demo_controls3.png)
Controls panel — scrollable parameter settings (bottom).

![Thumbnail cards](screenshots/thumbnail_list.png)
Thumbnail card list — miniature radar charts.

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
