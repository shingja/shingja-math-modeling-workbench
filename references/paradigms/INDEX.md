# 范式卡索引 (Paradigm Index)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


> 版本: v4.0.0 | S4建卡 + S5实战补充 (T01+T02)
> 双视图: ①按12大类; ②按题型(A/B/C/D/E)
> 
> **S5新增 (2026-07-29)**: 
> ⑧机理: PARADIGM-0801(链式约束) PARADIGM-0802(S曲线) PARADIGM-0803(中心对称)
> ④图论: PARADIGM-0401(碰撞检测)
> ⑥ML:   PARADIGM-0601(投票集成)
> ⑤统计: PARADIGM-0501(卡方关联) PARADIGM-0502(K-means多准则) PARADIGM-0503(Mann-Whitney)

> **S6新增 (2026-08-16)**:
> ⑥ML: PARADIGM-0621(EM算法/GMM) PARADIGM-0622(Apriori关联规则)
> 配套 .m: matlab/stats/em_algorithm.m, matlab/ml/apriori_association.m,
> matlab/optim/simulated_annealing.m, matlab/optim/genetic_algorithm.m,
> matlab/simulation/monte_carlo.m, matlab/stats/regression_diagnostics.m

> **S7新增 (2026-08-17, CV实战)**:
> ⑥ML: PARADIGM-0623(CV目标检测基线+延训) PARADIGM-0624(CV集成后处理WBF/TTA) PARADIGM-0625(CV频域-边缘增强FSF/FIM)
> 配套: Python 专属(ultralytics), 实战产物见 references/lessons/实战复盘_CV目标检测.md
> (实战产出一套脚本/权重/CSV, 本地留存)

> **编号复用说明**: 范式卡目录中部分编号被多张卡共用（同号 = 同主题不同视角，文件以卡名后缀区分，查询时以卡名后缀区分）。已知复用编号:
> 0401(BENCH-COLLISION/DIJKSTRA), 0501(CHI2-ASSOCIATION/PREPROCESS), 0502(KMEANS-SILHOUETTE/OUTLIER), 0503(DISTRIBUTIONS/MANNWHITNEY-CLASSIFY), 0601(QUEUING-ADV/RF/VOTING-CLASSIFIER), 0701(GAME-NASH/MCMC), 0702(INVENTORY-EOQ/MARKOV-CHAIN), 0801(CHAIN-CONSTRAINT/MALTHUS), 0802(LOGISTIC/S-CURVE-DUAL-ARC), 0803(CENTROSYMMETRIC-SPIRAL/LESLIE)。
> 下方各节表格仅列出代表性卡片；各大类实际卡数以文末「统计」表（按 `references/paradigms/` 实测文件数）为准。

---

## 视图一: 按 12 大类

### ① 优化算法 (15 cards)

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0101-LP | 线性规划 | 低 | `linprog` | high |
| PARADIGM-0102-IP | 整数规划 | 中 | `intlinprog` | high |
| PARADIGM-0103-NLP | 非线性规划 | 中 | `fmincon` | high |
| PARADIGM-0104-DP | 动态规划 | 高 | 自写 | high |
| PARADIGM-0105-GA | 遗传算法 | 中 | `ga` | high |
| PARADIGM-0106-PSO | 粒子群优化 | 中 | `particleswarm` | high |
| PARADIGM-0107-ACO | 蚁群算法 | 中 | 自写 | high |
| PARADIGM-0108-DE | 差分进化 | 中 | 自写 | high |
| PARADIGM-0109-SA | 模拟退火 | 中 | `simulannealbnd` | high |
| PARADIGM-0110-GWO | 灰狼优化 | 中 | 自写 | high |
| PARADIGM-0111-IA | 免疫算法 | 中 | 自写 | high |
| PARADIGM-0112-WOA | 鲸鱼优化 | 中 | 自写 | high |
| PARADIGM-0113-SSA | 麻雀搜索 | 中 | 自写 | high |
| PARADIGM-0114-TS | 禁忌搜索 | 中 | 自写 | high |
| PARADIGM-0115-GOAL-PROG | 目标规划 | 中 | `fgoalattain` | high |

### ② 预测算法

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0201-GM11 | 灰色预测GM(1,1) | 低 | 自写 | high |
| PARADIGM-0202-ARIMA | ARIMA | 中 | `arima`/`estimate` | high |
| PARADIGM-0203-EXP-SMOOTH | 指数平滑 | 低 | 自写 | high |
| PARADIGM-0204-LSTM-FORECAST | LSTM预测 | 高 | `lstmLayer` | medium |
| PARADIGM-0205-SVR | 支持向量回归 | 中 | `fitrsvm` | high |
| PARADIGM-0206-XGBOOST-LGBM | XGBoost/LightGBM | 中 | 自写/Python备选 | medium |
| PARADIGM-0207-PROPHET | Prophet预测 | 中 | 自写-见S5 | medium |
| PARADIGM-0208-STATE-SPACE | 状态空间/Kalman | 高 | `ssm`/`estimate` | medium |

### ③ 评价算法

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0301-AHP | 层次分析法 | 低 | `eig` | high |
| PARADIGM-0302-TOPSIS | TOPSIS法 | 低 | 自写 | high |
| PARADIGM-0303-EWM | 熵权法 | 低 | 自写 | high |
| PARADIGM-0304-FUZZY-EVAL | 模糊综合评价 | 中 | 自写 | high |
| PARADIGM-0305-GRA | 灰色关联分析 | 低 | 自写 | high |
| PARADIGM-0306-RSR | 秩和比法 | 低 | 自写 | high |
| PARADIGM-0307-CV-WEIGHT | 变异系数法 | 低 | 自写 | high |
| PARADIGM-0308-DEA | 数据包络分析 | 高 | 自写 | high |

### ④ 图论与网络

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0401-DIJKSTRA | Dijkstra | 低 | `shortestpath` | high |
| PARADIGM-0402-BELLMAN-FORD | Bellman-Ford | 中 | 自写 | high |
| PARADIGM-0403-FLOYD | Floyd-Warshall | 低 | 自写 | high |
| PARADIGM-0404-MST | 最小生成树Prim/Kruskal | 低 | `minspantree` | high |
| PARADIGM-0405-MAXFLOW | Ford-Fulkerson最大流 | 中 | `maxflow` | high |
| PARADIGM-0406-CPM | 关键路径法 | 中 | 自写 | high |
| PARADIGM-0407-EULER-HAMILTON | 欧拉/哈密顿路径 | 高 | 自写 | high |
| PARADIGM-0408-HUNGARIAN | 匈牙利匹配 | 中 | 自写 | high |

### ⑤ 统计与数据处理

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0501-PREPROCESS | 数据预处理 | 低 | `normalize`/`fillmissing` | high |
| PARADIGM-0502-OUTLIER | 异常值检测 | 低 | `isoutlier`/`boxplot` | high |
| PARADIGM-0503-DISTRIBUTIONS | 概率分布与统计推断 | 中 | `fitdist`/`mle` | high |
| PARADIGM-0504-PCA | 主成分分析 | 中 | `pca` | high |
| PARADIGM-0505-FACTOR | 因子分析 | 中 | `factoran` | high |
| PARADIGM-0506-CLUSTER | 聚类(K-Means/层次/DBSCAN) | 中 | `kmeans`/`linkage` | high |
| PARADIGM-0507-CCA | 典型相关分析 | 高 | 自写 | high |
| PARADIGM-0508-NMF | 非负矩阵分解 | 中 | `nnmf` | high |
| PARADIGM-0509-TTEST | 假设检验(t/χ²/ANOVA) | 中 | `ttest`/`anova1` | high |
| PARADIGM-0510-PLS | 偏最小二乘PLS | 中 | `plsregress` | high |
| PARADIGM-0511-BOOTSTRAP-CV | Bootstrap+交叉验证 | 中 | `bootstrp`/`crossval` | medium |
| PARADIGM-0522-MK-TREND | Mann-Kendall趋势 | 低 | 自写-见S5 | medium |
| PARADIGM-0523-HURST-RS | R/S Hurst指数 | 低 | 自写-见S5 | medium |
| PARADIGM-0524-SURVIVAL-COX | 生存分析Cox | 高 | `fitcox` | medium |
| PARADIGM-0525-DID | 因果推断DID | 高 | `fitlm`+自写 | medium |
| PARADIGM-0526-MORAN-KRIGING | 空间Moran-Kriging | 高 | `geopredict`+自写 | medium |

### ⑥ 机器学习

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0601-RF | 随机森林 | 中 | `fitensemble` | high |
| PARADIGM-0602-ADABOOST | AdaBoost | 中 | `fitensemble` | high |
| PARADIGM-0603-ISOLATION-FOREST | 隔离森林 | 中 | 自写 | high |
| PARADIGM-0604-DT | 决策树 | 低 | `fitctree` | high |
| PARADIGM-0605-SVM | 支持向量机 | 中 | `fitcsvm` | high |
| PARADIGM-0606-PERCEPTRON | 感知机 | 低 | 自写 | high |
| PARADIGM-0607-KNN | K近邻 | 低 | `fitcknn` | high |
| PARADIGM-0608-NAIVE-BAYES | 朴素贝叶斯 | 低 | `fitcnb` | high |
| PARADIGM-0609-LOGISTIC-REG | 逻辑斯谛回归 | 低 | `fitglm` | high |
| PARADIGM-0610-SVD | 奇异值分解 | 中 | `svd` | high |
| PARADIGM-0611-LSA | 潜在语义分析 | 中 | 自写 | high |
| PARADIGM-0612-PLSA | 概率潜在语义 | 高 | 自写 | high |
| PARADIGM-0613-LDA | 潜在狄利克雷分配 | 高 | 自写 | high |
| PARADIGM-0614-MCMC | 马尔可夫链蒙特卡洛 | 高 | 自写 | high |
| PARADIGM-0615-PAGERANK | PageRank | 中 | 自写 | high |
| PARADIGM-0616-CATBOOST | CatBoost | 中 | 自写/Python备选 | medium |
| PARADIGM-0617-FP-GROWTH | FP-Growth关联规则 | 中 | 自写-见S5 | medium |
| PARADIGM-0618-CNN | 卷积神经网络CNN | 高 | `trainNetwork` | medium |
| PARADIGM-0621-EM | EM算法/高斯混合模型 | 高 | 自写-见S6:[stats/em_algorithm.m] | high |
| PARADIGM-0622-APRIORI | Apriori关联规则 | 中 | 自写-见S6:[ml/apriori_association.m] | high |
| PARADIGM-0623-CV-DET-BASELINE | CV目标检测基线+分阶段延训(YOLO) | 中 | Python专属(ultralytics) | high |
| PARADIGM-0624-CV-ENSEMBLE | CV集成与后处理(WBF/TTA/逐类阈值/Severity) | 中 | Python专属(ultralytics) | high |
| PARADIGM-0625-CV-FSF-FIM | CV频域-边缘架构增强(FSF/FIM) | 高 | Python专属(torch.fft) | medium |

### ⑦ 综合算法

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0701-MCMC | 蒙特卡洛模拟 | 中 | 自写 | high |
| PARADIGM-0702-MARKOV-CHAIN | 马尔科夫链 | 中 | `eig`/`dtmc` | high |
| PARADIGM-0703-QUEUING-ADV | 排队论(含Little/M/G/1) | 中 | [S5:matlab/simulation/queuing_theory.m] | high |
| PARADIGM-0704-GAME-NASH | 博弈论(零和/双矩阵/纳什) | 高 | [S5:matlab/comprehensive/lemke_howson.m] | high |
| PARADIGM-0705-CELLULAR-AUTO | 元胞自动机(NaSch/火灾/疏散) | 中 | 自写 | high |
| PARADIGM-0706-RELIABILITY | 可靠性(Weibull/FTA) | 中 | `wblfit`+[S5:matlab/comprehensive/reliability_fta.m] | medium |
| PARADIGM-0707-INVENTORY-EOQ | 存贮论(EOQ/s,S/报童) | 中 | [S5:matlab/comprehensive/inventory_eoq.m] | high |
| PARADIGM-0708-SYSTEM-DYNAMICS | 系统动力学 | 中 | [待补-见S5:system_dynamics.m] | medium |

### ⑧ 机理建模

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0801-MALTHUS | Malthus指数增长 | 低 | `ode45` | high |
| PARADIGM-0802-LOGISTIC | Logistic增长 | 低 | `ode45` | high |
| PARADIGM-0803-LESLIE | Leslie矩阵 | 中 | 自写 | high |
| PARADIGM-0804-SEIR | SEIR传染病 | 中 | `ode45` | high |
| PARADIGM-0805-SEIRS-VACCINE | SEIRS+疫苗/时滞 | 高 | `ode45`+自写 | medium |
| PARADIGM-0806-LOTKA-VOLTERRA | 捕食者-猎物 | 中 | `ode45` | high |
| PARADIGM-0807-DIFFEQ-ITERATOR | 差分方程迭代器 | 中 | [S5:matlab/mechanism/difference_eq.m] | high |
| PARADIGM-0808-VARIATIONAL-SHOOTING | 变分法打靶法 | 高 | [S5:matlab/comprehensive/variational_shooting.m] | high |
| PARADIGM-0809-PDE-FDM-SOLVER | PDE有限差分(FTCS/CN/ADI) | 高 | [S5:matlab/mechanism/pde_ftcs.m] | high |

### ⑨ 综合算法(经典)

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-0901-DISCRIMINANT | 判别分析 | 中 | `fitcdiscr` | high |

### ⑩ 代理模型/仿真优化 (v3.0新增)

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-1001-GPR | Kriging/GPR | 中 | `fitrgp` | medium |
| PARADIGM-1002-EGO | EGO/贝叶斯优化 | 高 | `bayesopt`+自写 | medium |
| PARADIGM-1003-RSM | 多项式响应面 | 低 | `fitlm` | medium |
| PARADIGM-1004-RBF-SURROGATE | RBF代理模型 | 中 | 自写-见S5 | medium |
| PARADIGM-1005-PINN | 物理信息神经网络 | 高 | Python备选-见S5 | low |
| PARADIGM-1006-POD-DEIM | POD/DEIM降阶模型 | 高 | 自写-见S5 | medium |

### ⑪ 鲁棒/随机优化 (v3.0新增)

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-1101-CVAR | CVaR优化 | 高 | `linprog`+自写 | medium |
| PARADIGM-1102-ROBUST-COUNTERPART | 鲁棒对应(Bertsimas-Sim) | 高 | `linprog`/`fmincon`+自写 | medium |
| PARADIGM-1103-STOCHASTIC-PROG | 两阶段随机规划 | 高 | `linprog`+自写场景 | medium |
| PARADIGM-1104-CHANCE-CONSTRAINT | 机会约束规划 | 高 | `fmincon`+自写 | medium |
| PARADIGM-1105-WASSERSTEIN-DRO | Wasserstein分布鲁棒 | 高 | 自写-见S5 | low |

### ⑫ 多目标决策进阶 (v3.0新增)

| ID | 算法名 | 难度 | MATLAB锚点 | 置信度 |
|----|-------|:----:|-----------|:------:|
| PARADIGM-1201-NSGA2 | NSGA-II | 高 | `gamultiobj`+自写 | medium |
| PARADIGM-1202-NSGA3 | NSGA-III | 高 | 自写-见S5 | medium |
| PARADIGM-1203-MOEAD | MOEA/D | 高 | 自写-见S5 | medium |
| PARADIGM-1204-VIKOR | VIKOR | 低 | 自写-见S5 | medium |
| PARADIGM-1205-CRITIC | CRITIC赋权 | 低 | 自写-见S5 | medium |
| PARADIGM-1206-BWM | BWM最佳最劣法 | 低 | 自写-见S5 | medium |
| PARADIGM-1207-PROMETHEE | PROMETHEE | 中 | 自写-见S5 | medium |
| PARADIGM-1208-DEMATEL-ANP | DEMATEL-ANP | 中 | 自写-见S5 | medium |
| PARADIGM-1209-SHAPLEY | Shapley值 | 中 | 自写-见S5 | medium |
| PARADIGM-1210-DEA | DEA数据包络 | 高 | 自写 | high |
| PARADIGM-1211-EPSILON-CONSTRAINT | ε-约束法 | 中 | `fmincon` | medium |

---

## 视图二: 按题型关键词

### A题 (物理/工程)
优化(GALP/NLP) → 微分方程(ODE/PDE) → 机理建模 → 灵敏度分析 → 多目标

### B题 (优化/决策/生产)
整数规划 → 动态规划 → 统计检验 → 博弈论 → NSGA-II

### C题 (数据分析/统计/预测)
数据预处理 → 统计推断 → 回归/分类(回归诊断) → EM/GMM聚类 → 时间序列(ARIMA/Prophet) → 评价(TOPSIS/AHP)

### D题 (几何/空间/图论 + CV图像/目标检测)
图论(Dijkstra/匹配) → 几何建模 → 优化 → 数值计算

**CV子路线 (CV 检测实战验证)**: 数据拓扑(图像尺寸/标注格式/类分布/负样本) → 目标检测基线(YOLO+预训练, 0623) → 训练充分性诊断与分阶段延训 → 架构增强(FSF/FIM, 0625) → 集成后处理(WBF/TTA/逐类阈值/Severity Top-K, 0624) → 黑箱提交CSV。详见 lessons/实战复盘_CV目标检测.md

### E题 (开放数据/综合)
EDA → 特征工程 → 时空统计 → 机器学习 → 关联规则(Apriori/FP-Growth) → 综合评价

---

## 统计

> 按 `references/paradigms/` 实测 PARADIGM-*.md 文件数与卡内 confidence 字段统计（2026-08-17，共 164 张卡）。

| 大类 | high+medium | low | 不合格 | 待建 |
|------|:----------:|:---:|:-----:|:---:|
| ① 优化 | 17 | 1 | 0 | 0 |
| ② 预测 | 11 | 0 | 0 | 0 |
| ③ 评价 | 11 | 0 | 0 | 0 |
| ④ 图论 | 9 | 0 | 0 | 0 |
| ⑤ 统计 | 20 | 0 | 0 | 0 |
| ⑥ ML | 27 | 0 | 0 | 0 |
| ⑦ 综合 | 19 | 0 | 0 | 0 |
| ⑧ 机理 | 19 | 0 | 0 | 0 |
| ⑨ 经典 | 7 | 0 | 0 | 0 |
| ⑩ 代理模型 | 6 | 0 | 0 | 0 |
| ⑪ 鲁棒优化 | 5 | 0 | 0 | 0 |
| ⑫ MCDM进阶 | 12 | 0 | 0 | 0 |
| **合计** | **163** | **1** | **0** | **0** |

---

*此文件在 S4 Agent 建卡完成后由生成脚本自动更新。当前为手工预估框架。*
