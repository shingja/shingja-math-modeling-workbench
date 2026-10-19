# 参考资料导航⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


本目录采用渐进式加载。先确定当前阶段，只读取对应角色入口；遇到具体任务再读取一份或少量参考文件。

## 根目录

- `SKILL_ROOT`：本仓库根目录，只读。
- `PROJECT_ROOT`：用户项目目录，所有产物写入这里。

任何参考文档中的相对路径均以其所属 `SKILL.md` 目录为基准。角色文档通过 `../../..` 回到 `SKILL_ROOT`。

## 四个代号

| 代号 | 阶段 | 入口 | 固定交付物 |
|---|---|---|---|
| **Linger** | 建模分析 | `roles/Linger/SKILL.md` | `题目分析报告.md`、`术语表格.md` |
| **Tide** | 代码实现 | `roles/Tide/SKILL.md` | Python/MATLAB 代码、结果表格、三类图、复现清单 |
| **Gloom** | 论文撰写 | `roles/Gloom/SKILL.md` | 论文初稿、图表与引用 |
| **Yearn** | 终审交付 | `roles/Gloom/SKILL.md` + W2 / 提交包 | `完整论文.docx`、提交包、复盘 |

## 按任务加载

| 任务 | 读取 |
|---|---|
| 选模型 | `roles/Linger/references/建模设计理论.md` |
| 查具体算法 | `算法索引.md`，再读取一个匹配的 `../assets/*.md`（含新增的 08-机理建模） |
| Python/MATLAB 实现 | `roles/Tide/references/工作流程.md` |
| MATLAB 工具箱与出图 | `roles/Tide/references/MATLAB规范.md` |
| 可视化 | `roles/Tide/references/可视化规范.md` |
| 论文结构 | `roles/Gloom/references/章节模板.md` |
| Word 格式 | `roles/Gloom/references/论文格式规范.md`（含一等奖论文格式特征） |
| 英文 MCM/ICM | `roles/Gloom/references/英文化工作流.md`（对接模块 shingja-mathmodeling-polishing） |

## 自研模块（按需加载）

| 场景 | 模块 | 加载时机 |
|------|------|---------|
| 出图与成图门禁 | `../modules/shingja-mathmodeling-figure.md` | 出图后 / 图被门禁拦下 |
| 论文润色 / 英文化 | `../modules/shingja-mathmodeling-polishing.md` | 初稿完成 / 英文化阶段 |
| 统计审查 | `../modules/shingja-mathmodeling-statistics.md` | 模型定型后 |
| 论文预审 | `../modules/shingja-mathmodeling-review.md` | 初稿完成 / 终检前 |
| 文献检索与核验 | `../modules/shingja-mathmodeling-search.md` | 需要理论依据 / 参考文献定稿 |

## 工具

| 工具 | 入口 |
|---|---|
| 双引擎论文搜索 | `../tools/paper_search/SKILL.md` |
| PDF | `../tools/pdf/SKILL.md` |
| Excel | `../tools/xlsx/SKILL.md` |
| DOCX | `../tools/docx/SKILL.md` |

外部论文只在确有需要时搜索和读取，并保留来源。
