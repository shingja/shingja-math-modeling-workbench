# shingja-mathmodeling-figure — 出图与成图门禁⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


> **模块** `shingja-mathmodeling-figure` · 版本 1.0.0 · 作者 [shingja](https://github.com/shingja)
> **许可**：同仓库 [LICENSE](../LICENSE)（源码可见非开源；禁商用、禁二次发布、禁止移除署名与版权标识）
> **落地实现**：`references/roles/Tide/scripts/plot_style.py`、`figure_audit.py`、`matlab/figures/`

## 一、出图顺序（先想清楚，再动手）

1. **一句话结论**：这张图要证明什么。写不出来就不要画。
2. **证据层级**：主面板（结论）+ 辅助面板（支撑/对照）+ 后备证据（放附录）。
3. **图型选择**：按"数据关系"选，不按"好不好看"选——分布用箱线/小提琴，趋势用折线+区间，关系用散点+拟合，排序用点图/条图，多目标用 Pareto 前沿，敏感性用 Sobol/龙卷风，混淆用矩阵+ROC。
4. **面板结构**：显式声明主/次面板与非对称比例；面板编号用 `add_panel_labels`。
5. **样式基线**：统一走 `plot_style.apply_publication_style()`，不手搓 rcParams。
6. **导出**：`plot_style.export_figure()` 双格式（SVG + PNG）+ 灰度预览。

## 二、硬规则（违反即不合格，导出会被门禁拦下）

| 规则 | 阈值 | 理由 |
|---|---|---|
| 面板标题长度 | ≤ 28 显示宽度（中文按 2 计） | 长论述移到图注 |
| 图例项数 | ≤ 5（单轴与共享图例同限） | 超过就改为直接标注或拆图 |
| 折线标记密度 | 点数 > 25 必须设 `markevery` 或无标记 | 避免"毛毛虫" |
| 柱状图基线 | 必须从零起 | 截断轴会放大差异 |
| 已标数值的小矩阵 | 不再加 colorbar | 冗余编码 |
| 产物路径 | **禁止写回 `SKILL_ROOT`**，只写 `PROJECT_ROOT` | 路径隔离，`export_figure` 会直接报错 |

## 三、色彩与可读性

- 色板：Okabe-Ito 色觉友好序列（`PALETTE`），主色 `#0072B2`，对比色 `#D55E00`。
- 每张图导出灰度预览，确认**去色后仍可区分**系列。
- 不用彩虹色图（jet/rainbow）表达连续量；顺序量用单向色图，发散量用双色中点图。
- 中文标签必须确认字体可用（缺字会静默变成方块）；跨语言交付优先用英文标签。

## 四、导出与命名

```python
from plot_style import apply_publication_style, publication_subplots, export_figure
apply_publication_style(language="zh", width="double")     # single / double / report
fig, axes = publication_subplots(1, 2, width="double", aspect=0.46)
...                                                          # 绘图
export_figure(fig, PROJECT_ROOT / "figures" / "result_pareto", grayscale_preview=False)
```

- 命名前缀固定：`raw_*` 原始数据图、`process_*` 过程图、`result_*` 结果图；总体建模流程图单独一张，属必交产物。
- 同一结论的多版本图（优化前/后）用同一坐标范围，否则视为误导。

## 五、出图后自检（写进复现清单）

- [ ] 每张图能一句话说出结论，且正文有对应引用（图号—结论—数据三者对齐）。
- [ ] 轴标签含单位；数值与 `results/` 表格一致（不是手抄）。
- [ ] 图注自足：读者不看正文也能看懂图在说什么。
- [ ] 灰度预览可读；打印黑白不失信息。
- [ ] 复现清单记录出图脚本、随机种子、数据文件 SHA-256。

## 六、与Gloom衔接

Gloom只接收**通过门禁**的图；被拦下的图返回Tide修，不允许"先写论文后补图"。图表在正文中的编号、题注与交叉引用由Gloom统一维护，Tide不直接改论文。
