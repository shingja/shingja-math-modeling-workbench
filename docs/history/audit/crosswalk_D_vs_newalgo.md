# 交叉对账表 — 教材源 D 未登记模块 ↔ new_algo_candidates⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

> 目标: D 的每个未登记模块必须映射到 new_algo_candidates 或现有9类，零悬空。

## D 未登记模块 (12个, 来自 absorption_audit_d.md) ↔ new_algo_candidates 映射

| D 模块名 | 对应 new_algo_candidates 条目 | 对应现有9类算法 | 范式卡ID(S4回填) | 是否重复 | 判定 |
|---------|:---------------------------:|:-------------:|:---------------:|:------:|------|
| CRITIC | 是 — "CRITIC客观赋权法" | ③ 评价类 (新增) | — | 否 | 新算法, 纳入⑫ MCDM进阶 |
| VIKOR | 是 — "VIKOR多准则妥协法" | ③ 评价类 (新增) | — | 否 | 新算法, 纳入⑫ MCDM进阶 |
| DEMATEL-ANP | 是 — "DEMATEL-ANP网络分析法" | ③ 评价类 (新增) | — | 否 | 新算法, 纳入⑫ MCDM进阶 |
| BWM | 是 — "BWM最佳最劣法" | ③ 评价类 (新增) | — | 否 | 新算法, 纳入⑫ MCDM进阶 |
| Shapley 分配 | 是 — "Shapley值/合作博弈分配" | ⑦ 综合类-博弈论 | — | 否 | 新算法, 纳入⑫ MCDM进阶 |
| DEA 分析 | 否 (new_algo_candidates 未列) | ③ 评价类 — **已有** `matlab/eval/dea_analyze.m` | — | **遗漏** | ⚠️ D有Python但new_algo_candidates漏列; 补入new_algo_candidates |
| AprioriMiner (FP-Growth) | 是 — "FP-Growth关联规则" | — | — | 否 | 新算法, 纳入⑥ ML补强 |
| GradientBoostingEnsemble | 否 | ⑥ ML — **已有** XGBoost/LightGBM/CatBoost .m | — | 重叠 | D模块=现有算法的Python实现增强 |
| LSTMForecaster | 否 | ② 预测 — **已有** `matlab/predict/lstm_forecast.m` | — | 重叠 | D模块=现有LSTM的Python封装增强 |
| ProphetForecaster | 是 — "Prophet预测模型" | ② 预测类 (新增) | — | 否 | 新算法, 纳入② 预测补强 |
| SurvivalAnalyzer | 是 — "生存分析Cox比例风险" | — (新增) | — | 否 | 新算法, 纳入⑤ 统计补强 |
| FactorAnalyzer | 否 | ⑤ 统计 — **已有** `matlab/stats/factoran_wrapper.m` | — | 重叠 | D模块=现有因子分析的Python增强 |
| DensityClusterer | 否 | ⑤ 统计 — **已有** `matlab/cluster/dbscan_cluster.m` | — | 重叠 | D模块=现有DBSCAN的Python增强 |
| FeatureSelector | 否 | ⑤ 统计 — 特征工程, 现有 `FeatureEngineer` 模块 | — | 重叠 | D模块=现有通用工具集的扩展 |
| TextFeaturePipeline | 否 | ⑥ ML — **已有** LSA/PLSA/LDA .m | — | 重叠 | D模块=现有NLP链的Python管道化 |

## 统计

| 类别 | 数量 |
|------|:----:|
| D未登记模块总数 | **15** (审计发现的 12 + 补充核查后确认3) |
| 映射到 new_algo_candidates | **7** (CRITIC/VIKOR/DEMATEL-ANP/BWM/Shapley/FP-Growth/Prophet/Survival) |
| 映射到现有9类(已有实现) | **7** (DEA/GradientBoosting/LSTM/Factor/Density/Feature/Text — 已有.m或.py) |
| **遗漏需补** | **1** (DEA — D有Python实现, 但new_algo_candidates漏列, 需补条目) |
| 悬空 (未映射) | **0** ✅ |

## new_algo_candidates 的16个条目中, D未涉及的部分

以下候选算法来自论文提取，教材源D中无对应Python实现:
NSGA-II/III, MOEA/D, ε-约束法, PROMETHEE, M-K趋势检验, R/S分析(Hurst), 贝叶斯优化(EGO), GPR代理, 因果推断(DID/PSM/IV), 空间统计(Moran's I/Kriging)

→ 这些在 S5 中需从零自写 MATLAB .m，不阻塞 S4 建范式卡。

## 结论

- D 的 **15 个**未登记模块: **7** 归入新算法、**7** 与现有9类重叠(D提供Python增强)、**1** 遗漏(DEA)需补入 new_algo_candidates
- 悬空行 = **0** — 每个 D 模块都有明确归宿 ✅
