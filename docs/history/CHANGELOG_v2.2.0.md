# CHANGELOG v2.2.0 — 算法库 MATLAB 全量补全⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


## 概述

- **MATLAB 文件**: 37 → 67 (+30, +81%)
- **算法覆盖率**: 48/99 (48.5%) → 74/99 (74.7%) (+26pp)
- **新增目录**: `matlab/eval/`, `matlab/mechanism/`, `matlab/ml/`, `matlab/predict/`, `matlab/simulation/`
- **CatBoost 专项**: `assets/algorithms/machine_learning/catboost/` — 含 MATLAB 桥接 + Python demo + 参数速查
- **Python 源发现**: `通用算法模块/` 中 8 个已有 Python 实现被正式收录 (DEA/因子分析/GBDT/LSTM/DBSCAN/VIKOR/Apriori/Critic/Prophet/生存分析)

## 新增算法 (26)

### Batch 1: CatBoost + 优化类
| 算法 | MATLAB文件 | 来源 |
|------|-----------|------|
| CatBoost | `matlab/ml/catboost_train.m`, `catboost_predict.m`, `assets/.../catboost_demo.py`, `README.md` | Prokhorenkova et al. (2018) NeurIPS |
| 禁忌搜索 | `matlab/optim/tabu_search.m` | Glover (1989) ORSA |
| 灰狼优化(GWO) | `matlab/optim/grey_wolf_optimizer.m` | Mirjalili et al. (2014) AES |
| 免疫算法 | `matlab/optim/immune_algorithm.m` | De Castro & Von Zuben (2002) IEEE TEVC |
| 鲸鱼优化(WOA) | `matlab/optim/whale_optimization.m` | Mirjalili & Lewis (2016) AES |

### Batch 2: P0 ML + 预测
| 算法 | MATLAB文件 | 来源 |
|------|-----------|------|
| 随机森林 | `matlab/ml/random_forest_train.m`, `random_forest_predict.m` | Breiman (2001) |
| XGBoost | `matlab/ml/xgboost_train.m`, `xgboost_predict.m` | Chen & Guestrin (2016) KDD |
| LightGBM | `matlab/ml/lightgbm_train.m`, `lightgbm_predict.m` | Ke et al. (2017) NeurIPS |
| SVM/SVR | `matlab/ml/svm_train.m`, `svm_predict.m` | Cortes & Vapnik (1995) |
| 指数平滑 | `matlab/predict/exponential_smoothing.m` | Hyndman & Athanasopoulos (2018) |

### Batch 3: 统计+聚类+评价
| 算法 | MATLAB文件 | 来源 |
|------|-----------|------|
| 层次聚类 | `matlab/cluster/hierarchical_cluster.m` | Murtagh & Contreras (2012) |
| DBSCAN | `matlab/cluster/dbscan_cluster.m` | Ester et al. (1996) KDD |
| 麻雀搜索(SSA) | `matlab/optim/sparrow_search.m` | Xue & Shen (2020) |
| 秩和比法(RSR) | `matlab/eval/rank_sum_ratio.m` | 田凤调 (1993) |
| 变异系数法 | `matlab/eval/coefficient_variation.m` | 郭亚军 (2007) |

### Batch 4: 图论+LSTM+机理
| 算法 | MATLAB文件 | 来源 |
|------|-----------|------|
| Bellman-Ford | `matlab/graph/bellman_ford.m` | Bellman (1958) / Ford (1956) |
| 关键路径(CPM) | `matlab/graph/critical_path.m` | Kelley & Walker (1959) |
| 区间数评价 | `matlab/eval/interval_evaluation.m` | 徐泽水 (2004) |
| LSTM | `matlab/predict/lstm_forecast.m` | Hochreiter & Schmidhuber (1997) |
| ODE数值求解 | `matlab/mechanism/ode_solver.m` | Shampine & Reichelt (1997) |

### Batch 5: 综合+统计补齐
| 算法 | MATLAB文件 | 来源 |
|------|-----------|------|
| NMF | `matlab/decomp/nmf_decompose.m` | Lee & Seung (2001) NeurIPS |
| 典型相关分析(CCA) | `matlab/stats/cca_analyze.m` | Hotelling (1936) |
| 偏最小二乘(PLS) | `matlab/stats/pls_regress.m` | Wold et al. (2001) |
| 排队论 | `matlab/simulation/queuing_theory.m` | Gross et al. (2008) |
| 元胞自动机 | `matlab/simulation/cellular_automata.m` | Wolfram (2002) / Gardner (1970) |

## 实现方式统计

| 方式 | 算法数 | 代表 |
|------|:------:|------|
| MATLAB Native (内置工具箱) | 8 | RF, SVM, 层次聚类, DBSCAN, LSTM, CCA, PLS, ODE |
| MATLAB 纯自实现 | 13 | TS, GWO, 免疫, WOA, SSA, 指数平滑, RSR, CV, Bellman-Ford, CPM, 区间评价, NMF, 排队论, 元胞自动机 |
| Python Bridge | 4 | CatBoost, XGBoost, LightGBM, (LSTM备选) |

## 自主发现与修正

| 发现 | 处理 |
|------|------|
| `通用算法模块/` 含 DEA/factor_analysis/GBDT/LSTM/DBSCAN/VIKOR Python 实现 | 已收录为完整 Python 源, 修正审计漏标 |
| CatBoost 无原生 MATLAB | 采用 pyenv 桥接方案 (推荐), 标注 ONNX 备选 |
| SSA (麻雀搜索) 论文 2020 年发表 | 独立实现, 标注为较新算法 |
| LSTM MATLAB Deep Learning Toolbox 依赖 | 提供 Python 备选路径说明 |

## 未达标项 (需 v2.2.1 补齐)

剩余 25 算法中, **11 个已有 MATLAB 内置函数** (linprog/intlinprog/fmincon/fgoalattain/factoran/pdepe/fitcensemble/fitcdiscr), 仅需薄封装.
预计 v2.2.1 可达到 **89/99 = 89.9% ≈ 90%** 目标.

## 文件统计

- v2.1.0: 37 个 .m 文件
- v2.2.0: 67 个 .m 文件 + 4 个 CatBoost 文件
- 新增 30 个 MATLAB 实现 + CatBoost 完整集成包
