## 1.0.0

- Initial stable release.
- 雷达图 widget with implicit animations (`PolarisRadarChart`).
- `PolarisRadarData` / `PolarisDataSet` 数据模型，支持 `==` / `hashCode` 深比较。
- 每条数据集独立边框：实线 / 虚线（`RadarLineStyle.dashArray`）。
- 顶点标记形状：`circle` / `square` / `diamond` / `triangle` / `none`。
- 网格形状：圆形 / 多边形（`RadarGridShape`）。
- 图例组件 `RadarLegendItem`，支持选中高亮。
- 触摸交互：顶点命中 / 边命中 / tooltip 浮层。
- `selectedDataSetIndex` 外部控制图集高亮。
- `duration: Duration.zero` 时跳过动画链路（静态渲染）。
- `PolarisLabelCache` 跨帧缓存 TextPainter，减少缩略图场景重绘开销。
