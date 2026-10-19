# 自研模块（shingja-mathmodeling-*）⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


> 版本 0.1.0 · 作者 [shingja](https://github.com/shingja) · 许可见 [LICENSE](../LICENSE)

本目录是 math-modeling Skill 的**自研能力模块**：把出图、润色、统计审查、论文预审、文献检索这五类"周边能力"写成仓库自带的协议文档，不再依赖任何外部技能。

模块是**协议**（怎么判断、怎么检查、什么算不合格），不是可执行技能；执行仍走 [`SKILL.md`](../SKILL.md) 的 四段流程与门禁。

## 模块索引

| 模块 | 何时加载 | 主要服务阶段 | 落地实现 |
|---|---|---|---|
| [`shingja-mathmodeling-figure`](shingja-mathmodeling-figure.md) | 需要出正式图、或图被门禁拦下 | Tide / Gloom | `references/roles/Tide/scripts/plot_style.py`、`matlab/figures/` |
| [`shingja-mathmodeling-polishing`](shingja-mathmodeling-polishing.md) | 论文初稿完成、或需要英文化 | Gloom | `references/roles/Gloom/references/` |
| [`shingja-mathmodeling-statistics`](shingja-mathmodeling-statistics.md) | 模型定型后、统计结论进论文前 | Linger / Gloom | `tools/evaluate/` |
| [`shingja-mathmodeling-review`](shingja-mathmodeling-review.md) | 初稿完成、终检前、答辩准备 | Gloom | `tools/evaluate/`、`references/lessons/多轮审计迭代协议.md` |
| [`shingja-mathmodeling-search`](shingja-mathmodeling-search.md) | 需要理论依据、参考文献定稿 | Linger / Gloom | `tools/paper_search/` |

## 使用规则

1. **按需加载**：只在对应场景读取单个模块，不要一次全读（渐进式加载是本 Skill 的基本约束）。
2. **模块不改变流程**：模块给出的是"检查什么、什么算不合格"，阶段划分与门禁判定以 `SKILL.md` 为准。
3. **模块不产生数据**：任何数值必须来自 `PROJECT_ROOT` 下的真实运行；模块只做判断与改写，不生成结果。
4. **模块不替代当届规则**：竞赛官方规则与模板优先于本目录的任何通用规范。

## 维护

- 新增模块：命名统一 `shingja-mathmodeling-<主题>.md`，并在上表登记。
- 修改后必须跑 `python -m unittest discover -s tests -v`（回归测试）。
- 命名、作者与许可条款属于署名信息，禁止移除。
