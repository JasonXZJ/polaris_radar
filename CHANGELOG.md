## 1.0.0

- Initial stable release.
- Radar chart widget with implicit animations (`PolarisRadarChart`).
- `PolarisRadarData` / `PolarisDataSet` data model with `==` / `hashCode` deep comparison.
- Per-dataset borders: solid or dashed (`RadarLineStyle.dashArray`).
- Vertex marker shapes: `circle` / `square` / `diamond` / `triangle` / `none`.
- Grid shapes: circle or polygon (`RadarGridShape`).
- Legend widget `RadarLegendItem` with selection highlighting.
- Touch interaction: vertex hit / edge hit / tooltip overlay.
- `selectedDataSetIndex` for external dataset highlight control.
- `duration: Duration.zero` skips animation pipeline (static rendering).
- `PolarisLabelCache` caches TextPainter across frames, reducing repaint cost in thumbnail scenarios.
