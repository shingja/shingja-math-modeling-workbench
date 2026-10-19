<div align="center">
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->

<img src="imgs/banner.svg" alt="shingja's Math Modeling Workbench · USTB — Linger / Tide / Gloom / Yearn" width="100%">

# shingja's Math Modeling Workbench · USTB⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

**Linger · Tide · Gloom · Yearn — 徘徊、潮起、沉郁、心生惦念。**

面向北京科技大学同学，也适合任何想学习数学建模的人。四段 Agent 工作流——不是答案生成器，也不是论文代写工具：把一道赛题拆成 Linger、Tide、Gloom、Yearn 四段，每段有固定交付物、独立质检和返工闭环。

> 版权归 shingja 所有。非商业使用免费；转载必须署名并保留许可，禁止商用、冒充原创或暗示背书。详见 [NOTICE.md](NOTICE.md)。

[![Version](https://img.shields.io/badge/version-1.0.0-blue?style=flat-square)](VERSION)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-4B8BBE?style=flat-square)](SKILL.md)
[![CI](https://github.com/shingja/shingja-math-modeling-workbench/actions/workflows/ci.yml/badge.svg)](https://github.com/shingja/shingja-math-modeling-workbench/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-ff6b9d?style=flat-square)](LICENSE)
[![MATLAB](https://img.shields.io/badge/MATLAB-22d3ee?style=flat-square)](matlab/)
[![Python](https://img.shields.io/badge/Python-22d3ee?style=flat-square)](tools/)

[![Stars](https://img.shields.io/github/stars/shingja/shingja-math-modeling-workbench?style=social)](https://github.com/shingja/shingja-math-modeling-workbench/stargazers)
[![Forks](https://img.shields.io/github/forks/shingja/shingja-math-modeling-workbench?style=social)](https://github.com/shingja/shingja-math-modeling-workbench/forks)

[安装](#快速开始) · [四个代号](#四个代号) · [工作流](#工作流) · [能力](#能力范围) · [示例](#示例图表) · [FAQ](#常见问题) · [贡献](CONTRIBUTING.md) · [许可](#许可双许可) · [English](README_EN.md)

<img src="imgs/divider.svg" alt="" width="100%">

</div>

当前版本：[`1.0.0`](VERSION)（首个公开版本）

> [!NOTE]
> 本仓库**不生成答案**。它做流程编排与质量把关——把一道赛题拆成建模、求解、写作、交付四段，
> 每段带独立质检门禁，产出可复现的代码、出版级图表与合规的论文骨架。
> 模型选择、代码实现与文字论述仍由你和队友完成；使用 AI 必须按当届竞赛规则声明。

## 核心成果

| 维度 | 成果 |
|---|---|
| 算法 | 12 类 · 164 张范式卡 · 228 个 MATLAB `.m` + Python 等价实现 |
| 流程 | Linger → Tide → Gloom → Yearn，6 道门禁，M-Loop 返工闭环 |
| 出图 | Okabe-Ito 色板 · 300 DPI · SVG + PNG · 布局 / 设计双门禁 |
| 论文 | 官方模板 · OMML 可编辑公式 · 三线表 · 图表交叉引用 · AI 声明 |
| 实战 | 2026 校赛 / 国赛复盘 · CV 目标检测管线 · 避坑手册 ×2 |

## 四个代号

**Linger · Tide · Gloom · Yearn** 是这条流水线的四段节奏。

| 代号 | 中文 | 功能 |
|---|---|---|
| **Linger** | 徘徊 | 读题、盘点附件、拆子问题、选型、写假设——先把问题想透 |
| **Tide** | 潮起 | 求解、仿真、出图、写复现清单——把想法推起来 |
| **Gloom** | 沉郁 | 证据链、论文写作、排版、图表引用——把结果说清楚 |
| **Yearn** | 心生惦念 | 终审、W2 门禁、提交包、AI 声明、复盘——交出去之后还惦记 |

> 代号是公开层命名；内部角色目录仍为 `references/roles/Linger|Tide|Gloom`，其中 Yearn 复用 Gloom 与 W2 / 提交包流程，功能不变。

## 这是什么

- **四段流水线**：Linger → Tide → Gloom → Yearn，每段有固定交付物和结构化交接协议。
- **6 道门禁**：`M1` / `P1` / `C1` / `P2` / `W1` / `W2`；其中 `C1`、`W1`、`W2` 是硬门禁，不通过就返工。
- **12 类算法库**：优化、预测、评价、图论、统计、机器学习（含 CV 目标检测）、机理、综合、代理模型、鲁棒优化、MCDM、经典。
- **双语言**：MATLAB 与 Python 等价实现，按你队里的环境选。
- **可复现**：随机种子、输入 SHA-256、依赖版本、唯一复现命令全部落盘。
- **论文合规**：官方模板驱动、OMML 可编辑公式、三线表、图表交叉引用、AI 使用声明、提交包元数据清理。

## 适合谁

| 你的情况 | 先读 |
|---|---|
| 北科大同学，或任何想系统学数学建模的人 | [核心成果](#核心成果) → [四个代号](#四个代号) → [快速开始](#快速开始) |
| 第一次参赛，不知道从哪下手 | [它解决什么问题](#它解决什么问题) → [工作流](#工作流) → [快速开始](#快速开始) |
| 队里负责建模 | **Linger** · [角色与交付物](#角色与交付物) · `M1` 门禁 |
| 队里负责编程 | **Tide** · [能力范围](#能力范围) · [示例图表](#示例图表) · `P1` `C1` `P2` |
| 队里负责论文 | **Gloom** · [角色与交付物](#角色与交付物) · `W1` · [常见问题](#常见问题) |
| 队里负责终审与提交 | **Yearn** · `W2` · 提交包 · AI 声明 |
| 想把现有代码或论文救回来 | [工作流](#工作流) 里的“只跑其中一段” |
| 只想看看它能不能用 | [示例图表](#示例图表) → [验证](#验证) |

## 它解决什么问题

| 常见痛点 | 本仓库的做法 |
|---|---|
| 三个人各干各的，交接就掉信息 | 四段固定交付物 + 结构化交接协议（`protocols/model-to-code-handoff.md`） |
| 图丑、编号乱、正文与结果对不上 | 出图门禁：色板 / 300 DPI / 双格式 / 版面与设计自动校验（`modules/shingja-mathmodeling-figure.md`） |
| 模型“看起来显著”但站不住 | 统计审查清单：前提、多重比较、效应量、误差棒含义（`modules/shingja-mathmodeling-statistics.md`） |
| 跑出来的数对不上、复现不了 | 随机种子 + 输入 SHA-256 + 依赖版本 + 唯一复现命令写入 `复现清单.json` |
| 临交稿才发现没声明 AI 使用 | 内置 AI 工具使用详情模板与提交包检查（身份信息 / 元数据清理） |
| 说不清“哪一步是谁做的” | 6 道门禁 + Subagent 只读质检，每次交接留痕 |

## 工作流

<p align="center">
  <img src="imgs/workflow.svg" alt="Linger / Tide / Gloom / Yearn 四段流水线与质量门禁" width="100%">
</p>

```mermaid
flowchart LR
    P["题目 / 附件"] --> L["① Linger · 徘徊<br/>选型 · 假设 · 验证方案"]
    L -->|M1| T["② Tide · 潮起<br/>求解 · 出图 · 复现清单"]
    T -->|"P1 → C1 → P2"| G["③ Gloom · 沉郁<br/>证据链 · 论文初稿"]
    G -->|W1| Y["④ Yearn · 心生惦念<br/>终审 · 提交包 · 复盘"]
    Y -->|W2| D["完整论文 + 支撑材料"]
    T -.->|"M-Loop：指标不达标则迭代"| L
```

也可以只跑其中一段：只跑 Linger、Tide、Gloom 或 Yearn，或“优化已有代码 / 论文”。

## 角色与交付物

| 阶段 | 代号 | 中文 | 核心任务 | 门禁 | 固定交付物 |
|:--:|---|---|---|:--:|---|
| ① | **Linger** | 徘徊 | 读题、盘点附件、拆子问题、选模型、设计验证 | `M1` | `题目分析报告.md`、`术语表格.md` |
| ② | **Tide** | 潮起 | MATLAB / Python 实现与运行，出结果表与图 | `P1` `C1` `P2` | 代码、结果表、三类候选图、总体建模流程图、`results/复现清单.json` |
| ③ | **Gloom** | 沉郁 | 按证据链构建论证，生成论文初稿（Word / LaTeX） | `W1` | 论文初稿、图表与交叉引用 |
| ④ | **Yearn** | 心生惦念 | 终审、格式门禁、提交包、AI 声明、复盘 | `W2` | `完整论文.docx`、提交包、复盘记录 |

<details>
<summary><b>门禁的判定标准（点开）</b></summary>

| 门禁 | 时机 | 检查重点 | 硬 / 软 |
|:--:|---|------|:--:|
| `M1` | Linger 完成 | 子问题覆盖、假设依据、可实现性、外部对标 | 软（Subagent 质检） |
| `P1` | 核心求解链首次跑通 | 最小可运行、退出码、关键结果 | 软 |
| `C1` | P1 通过后、P2 之前 | 校准分、修正记录、哈希绑定、指标达成度 | **硬**（`gates/C1_joint_calibration_check.m`） |
| `P2` | 代码冻结后 | 独立复现、输入哈希、量纲边界、提交包重跑 | 软 |
| `W1` | Gloom 完成 | 每条结论都有证据路径 | **硬** |
| `W2` | Yearn 终检 | 当届规则、数值一致性、双格式一致性 | **硬**（`gates/W2_format_check.m`，电子版 / 纸质版双模式） |

</details>

## 能力范围

- **算法库**：12 大类 **164 张范式卡**（优化 / 预测 / 评价 / 图论 / 统计 / 机器学习含 CV 目标检测 / 机理 / 综合 / 代理模型 / 鲁棒优化 / MCDM / 经典），**228 个 MATLAB `.m`** + 等价 Python 实现，按题目关键词路由。
- **双语言**：MATLAB 与 Python 等价支持，按你的环境选，依赖动态检查。
- **可复现**：种子、输入哈希、依赖版本、运行时间、唯一复现命令全部落盘。
- **出版级出图**：Okabe-Ito 色觉友好色板、300 DPI、SVG + PNG、灰度预览，导出前跑**布局与设计双门禁**（不合格直接报错）。
- **论文合规**：当届官方模板驱动、OMML 可编辑公式、三线表、图表交叉引用核对、AI 使用详情、提交包身份信息与元数据清理。
- **实战经验库**：2026 校赛 / 国赛复盘（含 CV 目标检测管线）、避坑手册 ×2、诚实披露协议、多轮审计协议、外部对标协议。

<details>
<summary><b>12 大类算法一览（点开）</b></summary>

| 大类 | 代表算法 |
|---|---|
| ① 优化 | LP / IP / NLP / 动态规划 / GA / PSO / SA / ACO / DE / GWO / WOA / 禁忌搜索 / 多起点 / 双层规划 |
| ② 预测 | GM(1,1) / ARIMA / 指数平滑 / LSTM / SVR / XGBoost / Prophet / 状态空间 / GARCH / VAR |
| ③ 评价 | AHP / TOPSIS / 熵权 / 模糊综合 / 灰色关联 / RSR / DEA / 区间评价 |
| ④ 图论 | Dijkstra / Bellman-Ford / Floyd / 最小生成树 / 最大流 / 关键路径 / 欧拉-哈密顿 / 匈牙利 |
| ⑤ 统计 | 预处理 / 离群 / 分布拟合 / PCA / 因子 / 聚类 / CCA / NMF / 检验 / PLS / MANOVA / MK / Hurst / Cox / DID |
| ⑥ 机器学习 | RF / AdaBoost / 隔离森林 / SVM / KNN / 朴素贝叶斯 / 逻辑回归 / LSA / LDA / MCMC / PageRank / CatBoost / CNN / 目标检测三卡 |
| ⑦ 综合 | 蒙特卡洛 / 马尔科夫 / 排队论 / 博弈论 / 元胞自动机 / 可靠性 / 存贮论 / 系统动力学 / Bootstrap |
| ⑧ 机理 | Malthus / Logistic / Leslie / SEIR / SEIRS / Lotka-Volterra / 变分 / PDE / 反应扩散 / 热传导 |
| ⑨ 经典 | 判别分析 / 联合分析 / 文本挖掘 / 缺失插补 / 特征选择 |
| ⑩ 代理模型 | Kriging / GPR / EGO / 响应面 / RBF / POD-DEIM |
| ⑪ 鲁棒优化 | CVaR / 鲁棒对应 / 机会约束 / 随机规划 / Wasserstein-DRO |
| ⑫ MCDM | NSGA-II / NSGA-III / MOEA-D / VIKOR / CRITIC / BWM / PROMETHEE / Shapley / ε-约束 / MABAC |

</details>

## 示例图表

以下图**由本仓库自己的出图规范生成**（`matlab/figures/` 与 `references/roles/Tide/scripts/plot_style.py`），
**数据为合成数据**，仅用于展示样式与门禁标准。

| | |
|---|---|
| ![多目标优化与评价](imgs/demo-01-optimization-evaluation.png)<br>多目标 Pareto 前沿 · 熵权-TOPSIS 排序 | ![预测与机理](imgs/demo-02-forecast-mechanism.png)<br>区间预测 · SEIR 机理曲线 |
| ![机器学习与统计](imgs/demo-03-ml-statistics.png)<br>混淆矩阵 · ROC 对比 | ![鲁棒与灵敏度](imgs/demo-04-sensitivity-convergence.png)<br>Sobol 灵敏度 · 算法收敛 |

每张图导出前自动检查：标题长度、图例项数、标记密度、柱状图零基线、版面溢出、灰度可读性。不合格直接报错。

## 快速开始

### Claude Code

```bash
# 1. 放到 skills 目录（目录名必须是 math-modeling）
git clone https://github.com/shingja/shingja-math-modeling-workbench.git math-modeling

# 2. 可选：获取官方 docx/pdf/xlsx 工具（第三方，本仓库不分发）
python tools/fetch_official_tools.py

# 3. 可选：跑一遍自检
python -m unittest discover -s tests -v
```

克隆到 `~/.claude/skills/`（或项目级 skills 目录）即被加载。触发词：数学建模、建模竞赛、CUMCM、MCM、优化问题、预测模型、评价模型、Linger、Tide、Gloom、Yearn、Linger、Tide、Gloom 等。

```text
完整建模。题目路径：D:\项目\选题A\
Linger：只做建模分析，输出题目分析报告和术语表格。
Tide：只写代码，用 MATLAB 实现现有模型并出图。
Gloom：根据现有结果生成完整论文.docx。
Yearn：终审论文与提交包，列出未通过项。
```

### Codex / 其它 Agent

根目录 [`AGENTS.md`](AGENTS.md) 是通用 agent 入口；主指令始终是 [`SKILL.md`](SKILL.md)。
任何能读本地文件的 agent，按 `AGENTS.md` → `SKILL.md` → 角色文件的顺序加载即可。

<details>
<summary><b>目录结构（点开）</b></summary>

```text
math-modeling/
├── SKILL.md              # 主入口：路由表 + 流程 + 门禁
├── AGENTS.md             # 通用 agent 入口（Codex 等）
├── VERSION               # 唯一版本准据
├── modules/              # 自研能力模块（shingja-mathmodeling-*）
├── protocols/            # 协议层：联合校准 / M-Loop / 全网搜索 / 交接 / 调度 …
├── assets/               # 12 大类算法说明
├── references/
│   ├── roles/            # Linger / Tide / Gloom
│   ├── paradigms/        # 范式卡 + 索引 + 关键词路由
│   └── lessons/          # 实战复盘、避坑手册、四协议、模板
├── matlab/               # 228 个 .m（算法 + 模板 + 属性测试）
├── tools/                # docx / xlsx / pdf / latex / 论文搜索 / 质量评分 / 完整性与出图
├── gates/                # C1 / W1 / W2 硬门禁脚本
├── imgs/                 # README 图（本仓库自产）
├── docs/                 # 教程、已知问题、仓库与发布手册、历史归档
└── tests/                # 回归测试 + 端到端冒烟
```

</details>

## 验证

```bash
python -m unittest discover -s tests -v          # 全套回归测试
python tests/test_skill_integrity.py -v          # 版本号与引用一致性
python tests/test_privacy.py -v                  # 隐私与身份信息扫描
python tools/manifest.py --verify                # 内容哈希校验（防篡改）
```

## 边界

- 生成的论文**仅供参考**，结构与格式必须以目标竞赛当届官方规则与模板为准。
- 不伪造数据、不编造结果；数值必须来自真实运行，异常与不确定必须显式披露。
- 使用 AI 工具时，**声明义务由使用者承担**（内置 `AI工具使用详情模板.md` 可复用）。
- 题目、附件与官方模板的版权属于原权利人；本仓库只提供方法与工具。

## 常见问题

**它会替我写论文吗？**
不会。它做流程编排与质量检查——门禁、复现清单、图表规范、AI 合规声明；
模型选择、代码实现与文字论述仍由你和队友完成，AI 使用须按当届规则声明。

**支持哪些竞赛？**
CUMCM、MCM/ICM、APMCM、MathorCup 等；格式与规则以当届官方文件为准，仓库只提供流程与模板基线。

**必须用 MATLAB 吗？**
不。MATLAB 与 Python 双语言等价支持，按你的环境选。

**为什么 `tools/docx`、`tools/pdf`、`tools/xlsx` 是空的？**
它们是 Anthropic 官方工具，本仓库不分发第三方代码。运行
`python tools/fetch_official_tools.py` 自行获取（不影响核心流程）。

**可以商用吗？**
不可以，除非取得书面授权。详见上方「许可」。

**怎么防止被抄？**
许可与 NOTICE 已明确：转载必须署名并保留许可，禁止商用、冒充原创或暗示背书。作者保留内容完整性与取证权利；具体校验与取证方法不公开。

## 路线图

- `1.0.0`：首个公开版本（2026-10-19）
- 后续：`1.1.0` 起补 M1/P1/P2 硬门禁脚本化、CI 全覆盖、示例库（公开真题完整跑通记录）
- 已知问题与版本规划见 [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md)

## 贡献

欢迎 issue 与 PR。动手前先读 [CONTRIBUTING.md](CONTRIBUTING.md) 与 [CLA.md](CLA.md)：
PR 必须附测试证据与 CLA 声明行。不接受第三方受版权内容、个人/队伍信息与当届赛题内容。

## 许可（双许可）

**非商业使用免费**（默认许可：[PolyForm Noncommercial 1.0.0](LICENSE) 标准全文）：

- ✅ 个人学习、训练、参赛（含正式比赛）使用与修改
- ✅ 教学、论文、博客、视频等非商业场合引用与演示
- ✅ **允许转载 / 搬运**，条件：署名 + 来源链接 + 保留许可 + 不移除版权标识 + 不暗示背书
- ❌ 禁止任何商业使用（付费课程、付费社群或资料、商业交付、以本内容为卖点的付费产品）
- ❌ 禁止移除署名与版权标识；禁止将内容声称为自己的原创

**商业使用**需事先取得书面授权，通过 GitHub [@shingja](https://github.com/shingja) 联系。

完整条款：[LICENSE](LICENSE)（PolyForm Noncommercial 1.0.0 标准全文，逐字未改）
+ [NOTICE.md](NOTICE.md)（Required Notice 行、署名与版权标识要求、名称与背书限制、商用授权说明）。
本仓库**不内嵌第三方代码**：`tools/docx|pdf|xlsx` 由使用者运行
`python tools/fetch_official_tools.py` 从 Anthropic 官方仓库自行获取，遵循其自带许可。

## 版权与完整性

- 源文件带**可见归属行**（作者 · 仓库 · 许可）；不得移除、遮挡、篡改或伪造。
- 发布包附逐文件 SHA-256 清单，可用 `python tools/manifest.py --verify` 校验内容未被改动。
- 具体的版权校验、扫描与取证方法属于作者内部规则，不在公开仓库披露。
- 发现搬运、冒充原创或移除版权标识：通过 GitHub 私密渠道报告，作者保留追究权利。

## 自研模块

出图 `shingja-mathmodeling-figure` · 润色 `shingja-mathmodeling-polishing` · 统计审查 `shingja-mathmodeling-statistics` · 预审 `shingja-mathmodeling-review` · 检索 `shingja-mathmodeling-search`。全部随仓库分发，不依赖外部技能，详见 [modules/](modules/README.md)。

## 作者 · 联系

| 平台 | 联系方式 |
|---|---|
| GitHub | [@shingja](https://github.com/shingja) |
| Bilibili | [月亮的森林岛](https://space.bilibili.com/3494356073843142) |
| 抖音 | [Sh1ngjA](https://www.douyin.com/user/self) |
| 小红书 | [主页](https://www.xiaohongshu.com/user/profile/6957bcb6000000000300e029) |
| QQ | `793811299` |
| 邮箱 | [gy79790920@126.com](mailto:gy79790920@126.com) |

只通过 GitHub issue 或以上公开渠道联系；安全问题见 [SECURITY.md](SECURITY.md)。

## Star 历史

<a href="https://star-history.com/#shingja/shingja-math-modeling-workbench&Date">
  <img src="https://api.star-history.com/svg?repos=shingja/shingja-math-modeling-workbench&type=Date" alt="Star 历史" width="70%">
</a>

## 相关项目

- **[shingja 的工科生手册](https://github.com/shingja/ustb-engineering-handbook-shingja)** — 面向北科工科生的竞赛与项目手册；工具、模板、复盘与提交检查。

## 致谢

- [AnySearch Skill](https://github.com/anysearch-ai/anysearch-skill)：学术垂直搜索参考。
- [Nature Skills](https://github.com/Yuan1z0825/nature-skills)：科学可视化与写作方法参考。

---

<div align="center">

<img src="imgs/divider.svg" alt="" width="100%">

*不必要做的不做，必要做的尽快做。*

如果这个项目对你有帮助，**点一个 Star** 是最直接的支持 —— 也让更多备赛的同学找到它。

<sub>© 2026 shingja · github.com/shingja · 双许可见 LICENSE</sub>

[↑ 回到顶部](#shingjas-math-modeling-workbench--ustb)

</div>
