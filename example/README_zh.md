[English](README.md) | **中文**

# polaris_radar 示例

本示例演示了 polaris_radar 雷达图组件库的全部功能。

## 屏幕截图

<img src="screenshots/full_demo_chart.png" width="320" alt="全功能展示" />

*全功能展示页 — 6 轴雷达图及图例、触摸反馈。*

<img src="screenshots/full_demo_controls1.png" width="320" alt="操作按钮 1" />

*操作按钮区域 — 可滚动参数设置面板（上方）。*

<img src="screenshots/full_demo_controls2.png" width="320" alt="操作按钮 2" />

*操作按钮区域 — 可滚动参数设置面板（中部）。*

<img src="screenshots/full_demo_controls3.png" width="320" alt="操作按钮 3" />

*操作按钮区域 — 可滚动参数设置面板（下方）。*

<img src="screenshots/thumbnail_list.png" width="320" alt="缩略图列表" />

*缩略图卡片列表 — 内嵌缩略雷达图。*

## 页面说明

### 首页

列表形式的入口页，包含两个导航选项：

- **完整功能演示** — 以交互式控制面板探索雷达图所有参数
- **缩略图列表** — 类"我的报告"风格卡片列表，内嵌缩略雷达图

### 完整功能演示

交互式 6 轴雷达图，底部实时控制面板覆盖：

| 分类 | 控制项 |
|---|---|
| **基础设置** | 网格形状（圆形/多边形）、网格圈数、标题外移、数据切换 |
| **网格与背景** | 背景色、网格/轴线粗细与颜色 |
| **标签样式** | 轴标题/刻度数字显隐、字号与颜色 |
| **数据集** | 填充色与透明度、线条色与粗细、顶点形状与大小、虚线开关 |

功能特点：
- 三个数据集（角色 A、角色 B、平均值）各有独立样式
- 触摸交互 — 点击顶点显示 tooltip 数据值
- 图例选择 — 点击图例项可高亮/淡化数据集
- 数据/参数变化时平滑动画过渡

### 缩略图列表页

类"我的报告"风格卡片列表：

- 缩略雷达图（80×80）嵌入样式化卡片
- 魔法属性主题，6 轴属性（光、暗、火、冰、风、雷）
- 每轴等级标签（L1–L5），颜色编码
- 非交互模式 + 极小文字适配缩略图

## 运行方式

```bash
cd example
flutter run -d chrome
```

或其他支持的平台：

```bash
flutter run -d macos
flutter run -d ios
```
