# MATLAB 增量更新日志 — v2.1.0 (Phase 2)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


生成日期：2026-07-27 | 基准版本：v2.0.0

## 新增 MATLAB 实现 (P0: 图论+统计+预处理，P1: 优化)

### P0 — 图论与网络 (5 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| Dijkstra 最短路 | `matlab/graph/dijkstra.m` | 纯 MATLAB（无工具箱依赖） |
| Floyd-Warshall 全源最短路 | `matlab/graph/floyd_warshall.m` | 纯 MATLAB |
| Kruskal 最小生成树 | `matlab/graph/kruskal.m` | Union-Find 内置实现 |
| Ford-Fulkerson 最大流 | `matlab/graph/maxflow_ford_fulkerson.m` | DFS 增广路径 |
| 匈牙利算法 (指派) | `matlab/graph/hungarian.m` | 纯 MATLAB |

### P0 — 统计分析 (1 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| 单因素方差分析 | `matlab/stats/anova_oneway.m` | Statistics and ML Toolbox (fcdf) |

### P0 — 聚类与降维 (2 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| K-Means 聚类 (k-means++ 初始化) | `matlab/cluster/kmeans_cluster.m` | 纯 MATLAB |
| 主成分分析 PCA (SVD) | `matlab/decomp/pca_decomp.m` | 纯 MATLAB (svd 内置) |

### P0 — 数据预处理 (2 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| 数据标准化 (5 方法) | `matlab/preprocess/normalize_data.m` | 纯 MATLAB |
| 缺失值填充 (5 方法) | `matlab/preprocess/fill_missing.m` | 纯 MATLAB |

### P0 — 插值与拟合 (2 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| Lagrange 插值 (重心形式) | `matlab/interp/interp_lagrange.m` | 纯 MATLAB |
| 三次样条插值 | `matlab/interp/interp_cubic_spline.m` | 纯 MATLAB |

### P1 — 智能优化 (2 新增)
| 算法 | 文件 | 依赖 |
|------|------|------|
| 蚁群优化 (TSP) | `matlab/optim/ant_colony_tsp.m` | 纯 MATLAB |
| 差分进化 (DE/rand/1/bin) | `matlab/optim/differential_evolution.m` | 纯 MATLAB |

## MATLAB 覆盖率变化

| 指标 | v2.0.0 | v2.1.0 |
|------|--------|--------|
| MATLAB 实现总数 | 55+ (含培训模块) | **69+** (含培训模块) |
| 图论与网络 MATLAB | 0/8 | **5/8** (63%) |
| 数据预处理 MATLAB | 0/3 | **2/3** (67%) |
| 聚类 MATLAB | 0/3 | **1/3** (33%) |
| 插值拟合 MATLAB | 0/2 | **2/2** (100%) |
| 方差分析 MATLAB | 0/1 | **1/1** (100%) |
| PCA MATLAB | 0/1 | **1/1** (100%) |
| 蚁群/DE MATLAB | 0/2 | **2/2** (100%) |

## 待补全 — P1/P2 清单

### P1 (建议补全)
- Bellman-Ford 最短路
- 关键路径 CPM
- Prim 最小生成树 (Kruskal 已有)
- SVM/SVR
- 指数平滑
- 因子分析
- DBSCAN 聚类
- 层次聚类

### P2 (可选)
- 禁忌搜索, GWO, WOA, SSA, 免疫算法
- RSR, 变异系数法, DEA, NMF, 典型相关, PLS
- 欧拉/哈密顿路径
- LSTM (MATLAB Deep Learning Toolbox 可用)

## 代码规范
- 所有函数遵循 snake_case 命名
- 完整 help 文档块（参数说明 + 示例 + 参考文献）
- 仅依赖 MATLAB 内置函数或官方工具箱
- 与 Python 版本语义一致，可交叉验证
