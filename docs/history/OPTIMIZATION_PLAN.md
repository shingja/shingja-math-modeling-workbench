# OPTIMIZATION_PLAN.md — math-modeling v2.2.1 → v3.0.0⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


> **生成时间**: 2026-07-28  
> **作者**: 主 Agent (建模教练+架构师视角)  
> **状态**: 待确认 (S2 产出，等待审批后进入 S3)

---

## 0. 基线快照 (Baseline)

| 指标 | v2.2.1 | 来源 |
|------|--------|------|
| VERSION | 2.2.1 | `VERSION` 文件 |
| MATLAB .m 文件数 | 82 | `find matlab -name '*.m'` |
| 算法总数 | 114 (含通用工具集 8 模块) | `references/算法索引.md` |
| MATLAB 覆盖率 | 89.9% (10 个未覆盖) | `CHANGELOG_v2.2.1.md` |
| 测试脚本 | 3 个 batch .m + 10 个 .py | `tests/` |
| run_all 入口 | 无 | — |
| manifest.json | 无 | — |
| coverage_report | 无 | — |
| 范式卡系统 | 无 | — |
| 联合修正协议 | 无 | — |
| 知识图谱 | 无 | — |
| 门禁数量 | 5 (M1/P1/P2/W1/W2) | `references/Subagent调度.md` |
| 算法大类 | 9 | `references/算法索引.md` |
| 资产文件 | 10 (01-09 + README) | `assets/` |
| 参考文档 | 25 | `find references -name '*.md'` |
| tools/ 工具链 | 6 子工具 (docx/latex/pdf/xlsx/paper_search/evaluate) | `tools/` |
| Git 仓库 | 否 (工作目录非 git repo) | — |

---

## 1. 缺口清单 (Gap Matrix)

### 1.1 MATLAB 覆盖率缺口 (10 个未覆盖 → 目标 0)

| # | 算法 | 类别 | MATLAB | Python | 缺口原因 | 优先级 |
|---|------|------|:------:|:------:|------|:------:|
| 1 | 秩和比法(RSR) | 评价 | ❌ | ❌ | 无实现 | P0 |
| 2 | 主观赋权法(德尔菲) | 评价 | ❌ | ❌ | 方法论，难自动化 | P2 |
| 3 | PDE 扩散/波动 | 机理 | ❌ | ❌ | 需自写 FTCS/Crank-Nicolson | P0 |
| 4 | 差分方程 | 机理 | ❌ | ❌ | 通用迭代器 | P0 |
| 5 | 博弈论(双矩阵) | 综合 | ❌ | ❌ | Lemke-Howson 自写 | P0 |
| 6 | 变分法(打靶法) | 综合 | ❌ | ❌ | Euler-Lagrange+shooting | P1 |
| 7 | 存贮论(EOQ/s,S/报童/多周期) | 综合 | ❌ | ❌ | 无内置 | P0 |
| 8 | 系统动力学 | 综合 | ❌ | ❌ | 存量-流量 Euler 积分 | P1 |
| 9 | 改进 TOPSIS | 评价 | ❌ | ❌ | 方法论组合 | P1 |
| 10 | 可靠性分析(Weibull/FTA) | 综合 | ❌ | ❌ | wblfit+wblplot+自写FTA | P0 |

**P0 = 6 个必须补, P1 = 3 个高优先级, P2 = 1 个可降级。**

### 1.2 范式卡缺口

当前: **0 张范式卡**。目标: 所有算法≥1 张，≥150 张。

### 1.3 测试缺口

| 项目 | 现状 | 目标 |
|------|------|------|
| run_all.m | 不存在 | 需创建 |
| run_all.py | 不存在 | 需创建 |
| tests/manifest.json | 不存在 | 需创建 |
| coverage_report.json | 不存在 | 需创建 |
| 属性测试 | 不存在 | 需创建 |

### 1.4 Gloom规范缺口

| 项目 | 现状 | 官方要求 |
|------|------|---------|
| 门控第1条 (摘要页结构) | "首页为摘要页" | 需修正为: 第1页承诺书+第2页编号页+第3页摘要页 |
| 提交时间 | 未记录 | 2026-09-10 18:00 ~ 09-13 20:00 |
| AI 使用详情文档 | 自动生成草稿 | 需核对2026版 AIGC 规定全文 |

---

## 2. 改动清单 (Change Inventory)

### S3: 吸收审计 (Absorption Audit)
- **产出**: `references/absorption_audit.md` (逐文件审计表)
- **产出**: `references/dedup_map.json` (PDF 去重映射)
- **产出**: `references/new_algo_candidates.md` (论文中提取的新算法清单)
- **教材源 A**: 读取往届题目+优秀论文，做"论文-题目-算法"三元组抽取
- **教材源 B**: 30章教材逐章提取范式卡要素，按哈希去重 (1).pdf 副本
- **教材源 C**: 28模块逐个核对 MATLAB/Python 双实现
- **教材源 D**: ML/通用模块/可视化教程逐目录审计
- **预估工作量**: 大量文件读取 (30章+28模块+250+论文采样)

### S4: 范式卡建设
- **产出**: `references/paradigms/` 目录 (≥150 张范式卡)
- **产出**: `references/paradigms/INDEX.md` (类别+题型双视图)
- **产出**: `references/paradigms/keyword_router.json` (题型关键词→范式卡ID权重)
- **模板**: 统一 11 字段范式卡模板
- **优先级**: 先补齐现有 9 类缺口，再加 §3 新类

### S5: MATLAB 覆盖率提升 (89.9% → ≥97%)
- **P0 必补** (6个): RSR、PDE扩散/波动FTCS/Crank-Nicolson、差分方程迭代器、博弈论Lemke-Howson、存贮论EOQ/s,S/报童/多周期、可靠性Weibull/FTA
- **P1 高优先** (3个): 变分法打靶法、系统动力学、改进TOPSIS
- **P2 可降级** (1个): 主观赋权法
- **新类算法** (§3.1-3.6): 代理模型/鲁棒优化/多目标进阶/机理补强/综合补强/统计ML补强
- **每文件**: 含 `arguments` 块 + `rng(seed,'twister')` + `fullfile` + exitflag校验 + 自测
- **产出**: 新增 .m 文件，全部登记到 `tests/manifest.json`

### S6: Tide增强
- **产出**: `matlab/templates/` 9 类题型起手模板
- **产出**: `matlab/figures/` 可视化函数库扩容 (桑基/雷达/小提琴/置信椭圆/收敛动画/geoplot)
- **产出**: 数值健壮性层 (条件数/VIF/fallback链)
- **产出**: 属性测试体系 (`tests/property/`)

### S7: 联合修正闭环
- **产出**: `references/joint_calibration_protocol.md`
- **产出**: `tools/joint_calibrate.py` (calibration_score 计算)
- **产出**: 新增 C1 门禁 (在 P1 与 P2 之间)
- **产出**: 模型修正记录模板

### S8: Gloom对齐
- **产出**: 门控第1条修正 (承诺书+编号页+摘要页→第3页起编页码)
- **产出**: 官方时间/提交要求补录
- **产出**: paper_format.py + LaTeX template + validate 同步修改

### S9: 触发词/路由优化
- **产出**: 更新 SKILL.md description (中英文/题型词/算法词/动作词)
- **产出**: 路由表补全 (联合修正/吸收审计/知识图谱/补MATLAB)
- **产出**: 知识图谱 `references/knowledge_graph.json` (节点+边)

### S10: 文档与版本
- **产出**: `CHANGELOG_v3.0.0.md`
- **产出**: 更新 VERSION=3.0.0
- **产出**: 更新 README.md
- **产出**: 更新 SKILL.md (版本号+新增能力描述)

### S11: 全量测试
- **产出**: `tests/run_all.m` + `tests/run_all.py`
- **产出**: `tests/manifest.json` (所有算法+测试映射)
- **产出**: `tests/coverage_report.json`
- **产出**: 端到端冒烟 (2024 国赛 B 或 C 题)

### S12: 交付
- **产出**: `OPTIMIZATION_REPORT.md`

---

## 3. 新算法类详细规划 (9类 → 12类)

### 3.1 新类⑩: 代理模型/仿真优化 (Surrogate Modeling)
| # | 算法 | MATLAB锚点 | 难度 |
|---|------|-----------|:----:|
| 1 | Kriging/GPR | `fitrgp` (Statistics Toolbox) | 中 |
| 2 | RBF代理 | 自写 (rbfcreate/rbfpredict) | 中 |
| 3 | 多项式响应面(RSM) | `fitlm` + polyfeatures | 低 |
| 4 | EGO/贝叶斯优化 | 自写 EI+`fitrgp` | 高 |
| 5 | PINN | Python (Deep Learning Toolbox 可选) | 高 |
| 6 | POD/DEIM 降阶 | 自写 SVD 截断 | 高 |

### 3.2 新类⑪: 鲁棒/随机/分布鲁棒优化
| # | 算法 | MATLAB锚点 | 难度 |
|---|------|-----------|:----:|
| 1 | 两阶段随机规划 | `linprog` + 自写场景树 | 高 |
| 2 | 机会约束规划 | `fmincon` + 自写概率约束 | 高 |
| 3 | CVaR 优化 | `linprog` + 自写 | 中 |
| 4 | 分布鲁棒(Wasserstein球) | `fmincon` + 自写 | 高 |
| 5 | 鲁棒对应(Robust Counterpart) | `linprog`/`fmincon` + Bertsimas-Sim | 中 |

### 3.3 新类⑫: 多目标与决策进阶 (MCDM Advanced)
| # | 算法 | MATLAB锚点 | 难度 |
|---|------|-----------|:----:|
| 1 | NSGA-II | 自写 (`gamultiobj` 备选) | 高 |
| 2 | NSGA-III | 自写 | 高 |
| 3 | MOEA/D | 自写 | 高 |
| 4 | ε-约束法 | `fmincon` + 自写 | 中 |
| 5 | Shapley值 | 自写 | 中 |
| 6 | BWM 最佳最劣法 | 自写 LP | 低 |
| 7 | CRITIC | 自写 | 低 |
| 8 | VIKOR | 自写 | 低 |
| 9 | PROMETHEE | 自写 | 中 |
| 10 | DEMATEL-ANP | 自写 | 中 |

### 3.4-3.6: 补强已有类 (详见 §1.1 缺口 + 以下新增)
- **机理补强**(4→10): SEIRS、带疫苗接种SIR、带时滞SIR、反应扩散、对流扩散、二维热传导
- **综合补强**(5→12): 排队论 M/M/1/M/M/c/M/G/1 + Little自写、元胞自动机交通NaSch/火灾MATLAB版
- **统计/ML补强**: Bootstrap/交叉验证体系、因果推断DID/PSM/IV、生存分析Kaplan-Meier/Cox (`fitcox`/`ecdf`)、空间统计Moran's I/克里金(`geopredict`)、时间序列ARIMAX/GARCH (`estimate`/`garch`)、Prophet思想自写

---

## 4. 风险矩阵

| 风险 | 概率 | 影响 | 缓解措施 |
|------|:----:|:----:|------|
| 破坏现有82个.m文件 | 低 | 致命 | 铁律0.1: 备份优先，增量改动 |
| PINN/RL等深度学习算法依赖GPU | 中 | 高 | 标为"Python备选"，MATLAB用DL Toolbox可选 |
| 教材源PDF去重工作量过大 | 中 | 中 | 按内容哈希自动去重脚本，不必手动逐页 |
| 端到端冒烟超时 | 中 | 中 | 选简单题(如2024C)，T2级别即可 |
| 知识图谱构建复杂 | 中 | 低 | 先JSON后可视化，graphify借鉴 |
| Gloom官方规范获取不完整 | 低 | 高 | 先基于团队资料中的2026规范PDF，标注为"已核验" |
| 无git分支保护 | 高 | 中 | 全量备份替代git分支(branch不可用) |

---

## 5. 回滚方案

```powershell
# 回滚到 v2.2.1 基线
rm -rf "<skills 目录>\math-modeling"
cp -r "<skills 目录>\math-modeling.backup-v2.2.1-<ts>" \
      "<skills 目录>\math-modeling"
echo "Rollback complete. VERSION restored to 2.2.1."
```

每步执行前备份受影响文件为 `*.backup-v2.2.1-<YYYYMMDD-HHMMSS>`。

---

## 6. 不确定性项 (已全部拍板)

| ID | 决策 | 判定 | 状态 |
|----|------|------|:----:|
| D1 | 论文三元组抽取 | 分层全采: 2023-2025国家奖全采; 2018-2022每题型(A/B/C/D/E)各1篇国奖; 2003-2017每年抽2篇。每篇产"题目-算法组合-可迁移要素-是否含库外新算法"四元组。索引骨架100%覆盖论文文件名，禁止漏登。 | [已决] |
| D2 | PINN/RL深度 | "调用范式+最小可跑示例+训练循环关键超参表+失效条件"，不重写完整训练框架。MATLAB用DL Toolbox给最小示例，复杂训练标Python备选。范式卡必含"何时上PINN/RL、何时传统模型更划算"trade-off。 | [已决] |
| D3 | 知识图谱 | JSON + INDEX.md 双索引强制交付；交互式HTML为S9可选增强，不阻塞主线。 | [已决] |
| D4 | 端到端冒烟题 | 主冒烟: 2024国赛B(优化+统计)。降级阶梯: B(T1)→B(T2)→C(T2)→C(T1单问)。在OPTIMIZATION_REPORT记录最终级别及原因。禁止因冒烟失败粉饰或跳过闭环验证。 | [已决] |
| D5 | 范式卡详细度 | 分级: 核心算法(优化/预测/评价/多目标/代理/鲁棒)~2000字含完整推导+反例/失效条件；边缘算法~500字但"数学形式+MATLAB锚点+选型决策树+失效条件"四块不可省。**失效条件/反例小节对所有卡强制存在**。 | [已决] |

### 口径修正 (FIX-1, FIX-2)

**FIX-1** 覆盖率分母统一: DoD ≥97% 以**最终算法总数(≥150)**为分母，非旧114。coverage_report.json 结构: `{算法ID, 类别, matlab:{有/无, 路径, 锚点函数或"自写"}, python:{有/无}, 范式卡:{有/无, ID}, 测试:{有/无}, 状态}`, 含 `by_category` 与 `overall` 两个百分比。

**FIX-2** 无git备份强化: S1 真实落盘独立目录 `math-modeling.backup-v2.2.1-<UTC>`，OPTIMIZATION_REPORT 给出绝对路径与文件数校验。每S步改动前，对将被改文件做单文件 `*.backup-v2.2.1-<ts>`。

---

## 7. 自检清单 (Plan 级别)

- [x] 现状基线已建立 (VERSION/文件数/覆盖率/测试状态)
- [x] 缺口清单完整 (MATLAB/Python/范式卡/测试/规范)
- [x] 改动清单覆盖全部 12 个 S 步骤
- [x] 新算法类规划具体 (12类 ≥150算法)
- [x] 风险矩阵已评估
- [x] 回滚方案可用
- [x] 不确定性项已全部拍板 (D1-D5 + FIX-1/FIX-2)
- [x] 铁律 0.1-0.7 已纳入设计
- [x] Plan 已批准 → 进入 S3

---

**状态**: S2 完成，S3 进行中。
