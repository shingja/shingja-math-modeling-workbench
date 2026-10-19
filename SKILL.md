---
name: math-modeling
version: 1.0.0
description: 当用户要求数学建模、建模竞赛、建模分析、代码求解、结果可视化或生成数学建模论文时使用。覆盖优化/预测/评价/图论/统计/机器学习(含CV目标检测)/机理建模/综合/代理模型/鲁棒优化/MCDM共12大类164张范式卡，MATLAB-Python双语言。支持完整四段流程(Linger 徘徊-建模 / Tide 潮起-求解 / Gloom 沉郁-写作 / Yearn 心生惦念-终审交付)、6道门禁(M1/P1/C1/P2/W1/W2)、联合校准闭环、机理优化+CV检测双实战经验库(数值卫生/诚实披露/多轮审计/外部对标/提交包规范/CV检测管线)。触发词：数学建模、math modeling、建模竞赛、优化问题、预测模型、评价模型、图论分析、CUMCM、MCM、ICM、Linger、Tide、Gloom、Yearn、模型建立与求解、计算机视觉、目标检测、YOLO、图像识别、缺陷检测。
paths:
  - "**/*.m"
  - "**/*.mat"
  - "**/*.py"
  - "**/*.ipynb"
  - "**/*.md"
  - "**/*.tex"
  - "**/*.docx"
  - "**/*.xlsx"
  - "**/*.csv"
---
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


# 数学建模 Skill v1.0.0⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

> **当前版本: 1.0.0 (2026-10-19)** — 调用时先回显此版本号与 SKILL_ROOT 路径(见嵌套 shim 加载协议)。
> 若回显版本与此不符, 说明加载了旧版本; 回退与发布流程见 `docs/仓库与发布.md`, 历史版本以 git 提交为准。

四段工作流 + 联合校准闭环 + 机理优化/CV 双实战经验库。12 大类 164 张范式卡（含 CV 目标检测 3 张），MATLAB 228 个 .m，6 道门禁。

## 四个代号

公开界面用四个代号命名四段流程，内部角色目录与功能一一对应：

| 代号 | 中文 | 功能 |
|---|---|---|
| **Linger** | 徘徊 | 读题、盘点附件、拆子问题、选型、写假设 |
| **Tide** | 潮起 | 求解、仿真、出图、写复现清单 |
| **Gloom** | 沉郁 | 证据链、论文写作、排版、图表引用 |
| **Yearn** | 心生惦念 | 终审、W2 门禁、提交包、AI 声明、复盘 |

用户说「Linger」= 只做建模；「Tide」= 只写代码；「Gloom」= 只写论文；「Yearn」= 终审并整理提交包。

## 快速开始

```
完整建模。题目路径: D:\...\选题A\
```
或单阶段:
```
Linger: 只做建模。题目: ...  |  Tide: 只写代码。  |  Gloom: 只写论文。  |  Yearn: 终审与提交包。
优化已有代码。           |     评估产出。     |     查 NSGA-II 算法。
```

## 核心能力

| 能力 | 说明 |
|------|------|
| 算法库 | 12 大类 164 张范式卡（含 CV 目标检测 0623-0625）+ INDEX + keyword_router；MATLAB 228 个 .m（算法子集 validate 通过率 98.3%） |
| 四段代号 | Linger 徘徊 (分析选型) → Tide 潮起 (求解出图) → Gloom 沉郁 (撰写排版) → Yearn 心生惦念 (终审交付) |
| 联合校准 | modeling×coding 闭环，calibration_score 收敛判定，C1 门禁 |
| M-Loop | 指标目标卡→model_quality_score→不达标自动迭代寻优→库内耗尽升级全网方法搜索→对比终局(C1-D6) |
| 6 道门禁 | M1→P1→**C1**→P2→W1→W2（硬 3：C1/W1/W2；软 3：M1/P1/P2） |
| 可视化 | 24 图表函数，色觉友好色板，300DPI SVG+PNG 双格式 |
| 论文 | Word+LaTeX 双模板，2026 CUMCM 官方规范对齐（电子版/纸质版双结构） |
| 属性测试 | 31 不变量测试，seed 复现，SHA-256 结果绑定 |
| 实战经验库 | `references/lessons/`：机理优化复盘 + CV 目标检测复盘 + 避坑手册×2 + 诚实披露/多轮审计/外部对标/提交包四协议 |

## 路由表

| 用户意图 | 加载入口 | 前置条件 |
|---------|---------|:------:|
| 完整建模/完成整题 | Linger → Tide → Gloom | 顺序执行 |
| 只做题目分析/选模型 | `references/roles/Linger/SKILL.md` | 否 |
| 只写代码/跑结果/出图 | `references/roles/Tide/SKILL.md` | 需模型说明 |
| 只写或修改论文 | `references/roles/Gloom/SKILL.md` | 需题目+结果 |
| 联合修正/校准 | `protocols/joint_calibration_protocol.md` | 需握手包+结果 |
| **指标不达标/模型迭代寻优** | `protocols/model_improvement_loop_protocol.md` (M-Loop) + `tools/model_quality_score.py` | 需指标目标卡+运行结果 |
| **库内耗尽/全网方法搜索** | `protocols/external_search_protocol.md` (四层搜索含赛题级, 只检不禁+声明义务) | M-Loop ≥2轮无改善 |
| Subagent 质检调度 | `protocols/Subagent调度.md` | 按门禁节点派发 |
| 吸收新算法/建范式卡 | `references/paradigms/_TEMPLATE.md` + `references/paradigms/` | 需审计通过 |
| 查知识图谱/算法选型 | `references/paradigms/INDEX.md` + `keyword_router.json` | 需题型关键词 |
| **CV/目标检测/图像题** | `references/lessons/实战复盘_CV目标检测.md` + 范式卡 0623-0625 | 题型含图像/检测关键词 |
| 评估已有产物 | `tools/evaluate/SKILL.md` | 需 PROJECT_ROOT |
| 优化已有代码/图表 | Tide (优化模式) | 需已有代码 |
| 优化已有论文初稿 | Gloom (优化模式) | 需已有初稿 |
| 快速模式 (自动决策) | 所有阶段 (跳过交互) | 否 |
| 回溯决策/查看记录 | `protocols/decision_log_protocol.md` | 需 decision_log.json |
| 冻结数值/防篡改 | `protocols/frozen_numbers_protocol.md` | 需Tide产出 |
| 交互式选择 | `protocols/interactive_mode_protocol.md` | 关键决策点触发 |
| 数值异常诊断/避坑 | `references/lessons/避坑手册_Tide.md` + `避坑手册_Gloom.md` | 指标异常/交付前 |
| 诚实披露/AI合规写作 | `references/lessons/诚实披露协议.md` + `AI工具使用详情模板.md` | 论文阶段 |
| 论文格式基线 | `references/lessons/论文格式基线_CUMCM规范与实测.md` | 生成论文前 |
| 多轮审计冲刺 | `references/lessons/多轮审计迭代协议.md` | 论文终检后 |
| 外部方案对标 | `references/lessons/外部对标协议.md` | M1 前/答辩准备 |
| 提交包打包 | `references/lessons/提交包规范.md` | 全部产出冻结后 |
| 选题/题型参考 | `references/lessons/CUMCM题目与论文库索引.md` | 赛前/选题 |
| 训练题库 | `references/lessons/训练题库与资料索引.md` | 训练/练手 |
| 本地算法资源 | `references/lessons/本地算法资源差异清单.md` | 查缺补漏/LOCAL_*_ROOT |
| 复盘参考 | `references/lessons/实战复盘_机理优化.md` + `实战复盘_CV目标检测.md` | 训练/复盘 |

## 12 大类算法

| 大类 | 算法数 | 代表算法 |
|------|:-----:|------|
| ① 优化 | 18 | LP/IP/NLP/DP/GA/PSO/SA/ACO/DE/GWO/WOA/SSA/TS/IA/目标规划/多起点/代理优化/双层规划 |
| ② 预测 | 11 | GM(1,1)/ARIMA/指数平滑/LSTM/SVR/XGBoost/Prophet/状态空间/GARCH/VAR/插值 |
| ③ 评价 | 11 | AHP/TOPSIS/EWM/模糊/灰色关联/RSR/CV/DEA/主观/区间/改进TOPSIS |
| ④ 图论 | 9 | Dijkstra/Bellman-Ford/Floyd/MST/最大流/CPM/欧拉-哈密顿/匈牙利 |
| ⑤ 统计 | 20 | 预处理/离群/分布/PCA/因子/聚类/CCA/NMF/检验/PLS/MANOVA/MK/Hurst/Cox/DID/Moran/对应分析 |
| ⑥ ML | 27 | RF/AdaBoost/隔离森林/DT/SVM/感知机/KNN/朴素贝叶斯/逻辑回归/SVD/LSA/PLSA/LDA/MCMC/PageRank/CatBoost/FP-Growth/CNN/GBDT/Stacking/CV目标检测基线/CV集成后处理/CV频域-边缘增强 |
| ⑦ 综合 | 19 | 蒙特卡洛/马尔科夫/排队论/博弈论/元胞自动机/可靠性/存贮论/系统动力学/Bootstrap/组合模式 |
| ⑧ 机理 | 19 | Malthus/Logistic/Leslie/SEIR/SEIRS/Lotka-Volterra/差分/变分/PDE/反应扩散/对流扩散/热传导/化学/神经 |
| ⑨ 经典 | 7 | 判别分析/联合分析/文本挖掘/缺失插补/特征选择 |
| ⑩ 代理模型 | 6 | Kriging/GPR/EGO/RSM/RBF/POD-DEIM |
| ⑪ 鲁棒优化 | 5 | CVaR/鲁棒对应/机会约束/随机规划/Wasserstein-DRO |
| ⑫ MCDM | 12 | NSGA-II/III/MOEA-D/VIKOR/CRITIC/BWM/PROMETHEE/DEMATEL-ANP/Shapley/DEA/ε约束/MABAC |

范式卡总数 164（含概念卡与 Python 备选卡）；算法卡口径以 `tests/manifest.json` impl_type 分布为准。

## 6 道门禁

| 门禁 | 时机 | 检查重点 | 硬/软 |
|------|------|------|:--:|
| M1 | Linger完成 | 子问题覆盖、假设依据、可实现性、外部对标、数据拓扑 | 软 |
| P1 | 核心求解链首次跑通 | 最小可运行、退出码、关键结果 | 软 |
| **C1** | P1 通过后, P2 之前 | calibration_score、修正记录、哈希绑定、多模型选优、**指标达成度 D6(M-Loop)** | 硬 |
| P2 | 代码冻结后 | 独立复现、输入哈希、量纲边界、提交包重跑验证 | 软 |
| W1 | 证据大纲完成 | 每结论有证据路径 | 硬 |
| W2 | 论文终检 | 当届规则、数值一致性、双格式一致性 | 硬 |

W2 需区分电子版/纸质版结构：电子版首页=摘要页（无承诺书/编号页）；纸质版=承诺书→编号页→摘要页。`gates/W2_format_check.m` 用 `--mode electronic|paper` 切换。提交打包另见 `references/lessons/提交包规范.md`（S1 提交门禁）。

## 目录结构

```
SKILL_ROOT/
├── SKILL.md              (本文件)
├── VERSION               (1.0.0, 唯一版本准据)
├── README.md / README_EN.md / AGENTS.md / CHANGELOG.md
├── modules/              (自研能力模块: figure/polishing/statistics/review/search + README)
├── protocols/            (协议层: 联合校准/M-Loop/全网搜索/交接/Subagent调度/冻结数值/决策日志/交互模式)
├── docs/                 (教程/已知问题/指标/仓库与发布手册; history/ 历史归档含 audit/)
├── references/
│   ├── roles/             (Linger/Tide/Gloom 角色说明)
│   ├── lessons/           (实战复盘/避坑手册/四协议/格式基线/AI模板/题目论文库/训练题库/资源差异)
│   ├── paradigms/         (范式卡 + INDEX + keyword_router.json)
│   └── 算法索引.md
├── matlab/                (228 .m: optim/eval/predict/graph/stats/ml/mechanism/simulation/
│   │                       surrogate/robust/mcdm/cluster/decomp/interp/preprocess/
│   │                       templates/figures/utils + tests/property)
├── tools/                 (docx/latex/pdf/xlsx/paper_search/evaluate/joint_calibrate/handshake_validate/
│   │                       result_claim_bind/model_ensemble_select/model_quality_score)
├── gates/                 (C1_joint_calibration_check.m / W1_writing_check.m / W2_format_check.m)
└── tests/                 (13 python 套件 + validate_m_files.py + smoke_2024/ 端到端冒烟)
```

## 三级递进质量目标

| 级别 | Linger | Tide | Gloom |
|------|--------|--------|--------|
| T3 生存 | 1页简化 | 核心子问题 | 门控全过 |
| T2 标准 | 完整9节 | 全部代码+CSV+基本图 | 三线表+OMML+灵敏度 |
| T1 竞赛 | T2+文献+灵敏 | T2+多版本+出版级图 | 润色模块 + 预审模块 + 多轮审计 |

训练模式默认 T1 竞赛级。比赛模式按剩余时间自动降级。

## 自研模块（按需加载，见 `modules/README.md`）

| 场景 | 模块 |
|------|-------|
| 出图与成图门禁 | `modules/shingja-mathmodeling-figure.md` |
| 论文润色 / 英文化 | `modules/shingja-mathmodeling-polishing.md` |
| 统计审查 | `modules/shingja-mathmodeling-statistics.md` |
| 论文预审 / 多轮审计 | `modules/shingja-mathmodeling-review.md` |
| 文献检索与引用核验 | `modules/shingja-mathmodeling-search.md` |

模块全部随仓库分发（作者 shingja），本 Skill **不依赖任何外部技能**。模块回答"检查什么、什么算不合格"；阶段划分与门禁判定以本文件为准。

## 版本历史

v0.1.0 (2026-10-08): 版本线重编——内部序号 4.4.0 → 0.1.0(首发前统一走 0.x), 仓库迁至 shingja/shingja-math-modeling-workbench(私有); 内容与 v4.4.0 一致
v4.4.0 (2026-08-17): CV 计算机视觉实战范式化——CV 目标检测 3 范式卡(基线+延训/集成后处理/FSF-FIM 架构增强) + `实战复盘_CV目标检测.md`(题目画像/无负样本二分类/训练充分性/WBF-TTA-阈值-Severity/提交包工程/审计教训/环境坑清单/检查链) + 三角色 SKILL.md CV 特例步骤与硬性门控 + INDEX/路由表/CV 子路线 + Gloom格式教材指针; 只检不禁保持不变
v4.3.1 (2026-08-16): 全网方法搜索协议改"只检不禁"(赛题级搜索放开, 检查覆盖/效果/结果更优, 风险仅提示, 合规落声明侧)
v4.3.0 (2026-08-16): 全网方法搜索协议(四层搜索)+方案对比终局(取最优+其余转对比分析)
v4.2.0 (2026-08-16): M-Loop 模型迭代闭环(指标目标卡+model_quality_score+C1-D6+四层方案评审)
v4.1.0 (2026-08-16): 本地教材资源增量并入（EM/Apriori/SA/GA/MC/回归诊断 6 实现 + 2 范式卡 + 论文格式基线 + AI 模板 + 题库/论文库索引）
v4.0.0 (2026-08-16): 机理优化实战经验全量范式化（数值卫生/诚实披露/多轮审计/外部对标/提交包规范）+ 版本号统一 + 路由与数字修正 + W2 电子/纸质双结构 + 测试对齐
v3.2.0 (2026-08): Python 模板 + 范式卡自动化 (未入 CHANGELOG 的过渡版)
v3.0.0 (2026-07-29): 联合校准闭环 + 150 算法 + C1 门禁 + 2026 规范对齐
v2.2.1: MATLAB 覆盖率 89.9% + Batch A/B/C 增量
v2.1.0: 建模-编程协作协议 + 算法库大幅扩充
完整记录见 CHANGELOG.md 和 docs/history/
