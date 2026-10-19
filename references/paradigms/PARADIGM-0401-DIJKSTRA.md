# PARADIGM-0401 Dijkstra最短路⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0401 |
| 类别/子类 | ④图论与网络 / 最短路径 |
| 难度 | 低 |
| 适用题型关键词[] | Dijkstra, 最短路径, 非负权重, 路径规划, 贪心算法, 物流网络, 导航 |
| confidence | high |
| source | matlab/graph/dijkstra.m + MATLAB Graph toolbox |

## 数学形式

**初始化:**

$$d[s] = 0, \quad d[v] = \infty \quad \forall v \neq s$$

**迭代更新 (Relaxation):**

$$d[v] = \min(d[v], \; d[u] + w(u, v)) \quad \forall v \in \text{Neighbors}(u)$$

**优先队列实现步骤:**
1. 将所有节点标记为未访问，$d[s]=0$
2. While 存在未访问节点: 选取 $d[u]$ 最小的未访问节点 $u$
3. 标记 $u$ 为已访问
4. 对 $u$ 的每个邻居 $v$: 若 $d[u] + w(u,v) < d[v]$，则更新 $d[v] = d[u] + w(u,v)$

**正确性依赖:** 非负边权保证贪心选择性质 — 一旦节点被标记为已访问，其 $d$ 值即为真正的最短距离，不会再被后续路径改进。

**变量表:**
- $d[v]$ — 从源点 $s$ 到节点 $v$ 的当前最短距离估计
- $w(u,v)$ — 边 $(u,v)$ 的权重 (非负)
- $s$ — 源点
- $\text{pred}[v]$ — 路径前驱节点，用于路径重构
- 优先队列 (Binary Heap) 实现复杂度: $O((V+E)\log V)$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| adj_matrix | double[,] | — | 非负 n×n 矩阵，Inf 表示无边 | — (输入数据) |
| source | int | — | [1, n] | 低 — 仅改变起点，不影响算法正确性 |
| target | int | — | [1, n] 或 [] (全源) | 低 — 指定终点可提前终止 |
| 时间复杂度 (Binary Heap) | — | — | O((V+E)log V) | — |
| 时间复杂度 (Fibonacci Heap) | — | — | O(E + V log V) | — |
| 时间复杂度 (无堆/稠密图) | — | — | O(V²) | — |
| 空间复杂度 | — | — | O(V) (距离数组 + 前驱数组) | — |

## MATLAB 实现

函数签名 (Graph toolbox):
```matlab
G = graph(s, t, weights);
[path, dist] = shortestpath(G, source, target);
```

函数签名 (自写):
```matlab
[dist, path, pred] = dijkstra(adj_matrix, source)
```

锚点: `matlab/graph/dijkstra.m` — 自写实现，基于优先队列 (最小堆) 版本，支持提前终止 (找到 target 即停止)。

- `dist` — 从 source 到各节点的最短距离 (1×n 向量)
- `path` — 从 source 到 target 的最短路径节点序列 (若指定 target)
- `pred` — 前驱数组，用于重构任意节点到 source 的最短路径

## Python 备选

```python
# SciPy 全源
from scipy.sparse.csgraph import dijkstra
dist_matrix, predecessors = dijkstra(csgraph=adj_matrix, directed=True,
                                      indices=source, return_predecessors=True)

# NetworkX 单源
import networkx as nx
G = nx.from_numpy_array(adj_matrix)
path = nx.shortest_path(G, source=source, target=target,
                         weight='weight', method='dijkstra')
length = nx.shortest_path_length(G, source=source, target=target,
                                  weight='weight', method='dijkstra')
```

## 选型决策树

- **用 Dijkstra** — 单源最短路径，所有边权非负，图规模适中 (V<1e6)
- **用 A\*** — 有启发式信息 (如地理坐标)，可加速搜索到目标节点
- **用 Floyd-Warshall (PARADIGM-0403)** — 需要所有节点对的最短路径，且图规模小 (V<500)
- **用 Bellman-Ford** — 边权可为负值 (如汇率套利、成本节省)
- **用 Contraction Hierarchies** — 超大规模路网 (V>1e7)，允许预处理
- **Trade-off:** Dijkstra 对非负权重是最优单源算法；稠密图 (E≈V²) 时不用堆的 O(V²) 实现反而比堆 O(E log V) 更快

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 加权有向/无向图 (scatter + edge labels) | 节点位置 + 边权重标注 |
| process | Dijkstra 展开过程图 (多子图或动画帧) | 已访问节点着色，frontier 边界高亮，距离表逐步更新 |
| result | 最短路径高亮图 (graph plot + highlight) | 最短路径上的边加粗着色，非路径边灰度淡化；附距离分布直方图 |

## 常见坑

1. **负权边导致错误:** 即使图中仅有一条负权边，Dijkstra 也可能产生错误的最短路径 (因为一旦节点被"永久标记"，其距离不会再被负权边修正)。排查: 用 Bellman-Ford 结果交叉验证
2. **稠密图中堆反而慢:** E≈V² 时堆操作开销超过收益，O(V²) 简单数组实现约快 2-5 倍。判别: 若 E/V² > 0.5，关闭堆实现
3. **浮点权重相等性判断:** `d[u]+w < d[v]` 中浮点舍入误差可能导致应更新而未更新。使用容差: `(d[u]+w) < d[v] - 1e-12` 再更新
4. **Inf 与加法溢出:** 邻接矩阵用 Inf 表示无边时，`d[u] + w(u,v)` 若 d[u]=Inf 产生 Inf+finite = Inf (MATLAB) 或 NaN (某些语言)，需在松弛前判断 `if d[u] < Inf`
5. **多源查询效率差:** 需要对多个不同源点求最短路径时重复运行 Dijkstra 浪费 — 考虑预处理 (如 Contraction Hierarchies)

## 失效条件/反例 (强制小节)

- **条件1: 图中存在负权边** → Dijkstra 的贪心选择失效。节点已被"永久标记"后，其距离可能因经过负权边的路径进一步减小，但算法已不再检查。**表现:** 算法返回一条"最短路径"，但实际存在更短路径 (经过负权边未检测到) → 改用 Bellman-Ford (O(VE)) 或 Johnson 算法实现全源带负权
- **条件2: 动态图 (边权随时间变化，如实时交通路网)** → 静态 Dijkstra 每次重新运行效率低且路径可能在行驶中途过时。**表现:** 计算出的路径在出发时最优，但途中拥堵变化导致实际并非最优 → 改用 D*-Lite 或时间依赖最短路径 (TDSP) 算法

## 文献

1. Dijkstra E.W. (1959) "A note on two problems in connexion with graphs." *Numerische Mathematik*, 1:269-271. DOI: [10.1007/BF01386390](https://doi.org/10.1007/BF01386390)
2. Cormen T.H., Leiserson C.E., Rivest R.L. & Stein C. (2009) *Introduction to Algorithms*, 3rd Edition. MIT Press. ISBN 978-0262033848 (Chapter 24: Single-Source Shortest Paths)

## 来源溯源

`matlab/graph/dijkstra.m` + MATLAB Graph toolbox `shortestpath`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (全源最短路径) | PARADIGM-0403 (Floyd) |
| 替代 (负权图) | Bellman-Ford (待补充) |
| 组合 (交通网络) | PARADIGM-0405 (最大流) |
| 组合 (指派匹配) | PARADIGM-0408 (匈牙利) |
