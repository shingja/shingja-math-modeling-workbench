# PARADIGM-0405 Ford-Fulkerson最大流⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0405 |
| 类别/子类 | ④图论与网络 / 网络流 |
| 难度 | 中 |
| 适用题型关键词[] | 最大流, Ford-Fulkerson, 增广路, 残留网络, 最小割, Edmonds-Karp, 网络流 |
| confidence | high |
| source | matlab/graph/maxflow_ford_fulkerson.m + MATLAB Graph toolbox |

## 数学形式

**流守恒约束 (Flow Conservation):**

$$\sum_{v:(u,v)\in E} f(u,v) - \sum_{v:(v,u)\in E} f(v,u) = \begin{cases}
|f| & u = s \text{ (源点)} \\
0 & u \neq s, t \\
-|f| & u = t \text{ (汇点)}
\end{cases}$$

**容量约束 (Capacity Constraints):**

$$0 \leq f(u,v) \leq c(u,v) \quad \forall (u,v) \in E$$

**残留容量 (Residual Capacity):**

$$c_f(u,v) = c(u,v) - f(u,v) + f(v,u)$$

**增广路 (Augmenting Path):** 在残留网络 $G_f$ 中从 $s$ 到 $t$ 的一条简单路径，瓶颈容量 $\Delta = \min_{(u,v) \in P} c_f(u,v)$。

**最大流-最小割定理 (Max-Flow Min-Cut):**

$$\text{max flow value} = \min_{S: s\in S, t\notin S} \sum_{u\in S, v\notin S} c(u,v)$$

**Edmonds-Karp:** BFS 寻找最短增广路 (按边数)，复杂度 $O(VE^2)$。

**变量表:**
- $f(u,v)$ — 边 $(u,v)$ 上的流量
- $c(u,v)$ — 边 $(u,v)$ 的容量
- $c_f(u,v)$ — 残留容量 (还可增加多少流)
- $s$ — 源点 (source)
- $t$ — 汇点 (sink)
- $|f|$ — 流的值 (从源点流出的总量)
- $G_f$ — 残留网络

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| capacity_matrix | double[,] | — | 非负 n×n 矩阵，无向边=0 | — (输入数据) |
| source | int | — | [1, n] | 低 — 仅改变起点 |
| sink | int | — | [1, n], source≠sink | 低 — 仅改变终点 |
| 算法变体 | string | 'Edmonds-Karp' | 'FF-DFS' / 'Edmonds-Karp' / 'Dinic' | 高 — FF-DFS 可能指数级慢 |
| 时间复杂度 (FF-DFS) | — | — | 伪多项式: O(E × max_flow)，最坏指数 | — |
| 时间复杂度 (Edmonds-Karp) | — | — | O(VE²) | — |
| 时间复杂度 (Dinic) | — | — | O(V²E) (一般) / O(E√V) (单位容量) | — |
| 空间复杂度 | — | — | O(V²) (容量矩阵 + 流矩阵 + 残留网络) | — |

## MATLAB 实现

函数签名 (Graph toolbox):
```matlab
G = digraph(s, t, weights);
[mf, GF, cs, ct] = maxflow(G, source, sink);
```

函数签名 (自写 Edmonds-Karp):
```matlab
[max_flow, flow_matrix] = maxflow_ford_fulkerson(capacity_matrix, source, sink)
```

锚点: `matlab/graph/maxflow_ford_fulkerson.m` — 自写 Edmonds-Karp 实现 (BFS 增广)。

- `max_flow` — 最大流值 (标量)
- `flow_matrix` — 每条边上的实际流量 (n×n 矩阵)
- `GF` — 残留网络有向图 (MATLAB Graph toolbox)
- `cs, ct` — 最小割的源侧/汇侧节点集

## Python 备选

```python
# NetworkX
import networkx as nx
G = nx.DiGraph()
G.add_weighted_edges_from([(u, v, cap) for u, v, cap in edges], weight='capacity')
flow_value, flow_dict = nx.maximum_flow(G, source, sink, capacity='capacity')

# SciPy
from scipy.sparse.csgraph import maximum_flow
mf = maximum_flow(csgraph=adj_matrix, source=source, sink=sink)

# 最小割
cut_value, partition = nx.minimum_cut(G, source, sink, capacity='capacity')
```

## 选型决策树

- **用最大流** — 资源分配有容量约束 (运输网络、网络可靠性、指派匹配)
- **用二分图匹配→最大流** — 添加超级源点/超级汇点，边容量=1
- **用最小费用最大流** — 同时优化流量和费用 (每条边有单位费用)
- **用多商品流 (LP)** — 多种资源共享同一网络，相互竞争容量
- **用 LP (PARADIGM-0101)** — 除容量外还有额外线性约束 (如节点容量)
- **Trade-off:** Edmonds-Karp 实现简单且多项式保证；Dinic 在实践和大规模图中更快 (尤其是单位容量网络)；FF-DFS 仅用于教学

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 有向图 (边标注 capacity) | 源点/汇点特殊标识，边宽与容量成比例 |
| process | 残留网络 + 增广路高亮 (每轮一子图) | 展示 BFS 搜索路径，瓶颈边标注 Δ |
| result | 最终流量图 (边标注 flow/capacity) + 最小割虚线 | 割线分开源侧/汇侧，验证 max flow = min cut |

## 常见坑

1. **DFS 增广 (原始 FF) 导致指数爆炸:** 若每次取增广路容量极小 (如 1)，可能需要指数次增广。Edmonds-Karp 使用 BFS 保证多项式时间 — 千万避免单纯的 DFS
2. **容量值极大导致增广次数多:** 若最大流=10⁹ 且每次增广=1，需 10⁹ 次 BFS → 使用容量缩放 (capacity scaling) 或 Dinic
3. **无向边建模错误:** 无向边必须拆为两条有向边各带相同容量，而非只一条。否则流量只能单向流动
4. **多重边合并:** 两节点间有多条平行边时不能简单合并容量 (除非确保流量可任意分配) → 保留多重边或用超源/超汇技巧
5. **节点容量约束:** 标准最大流只约束边容量 → 若节点有处理上限 (如中转站)，需拆点为入点+出点，中间加容量边

## 失效条件/反例 (强制小节)

- **条件1: 流量必须为整数 (如不可分割的货车数量)** → FF 以整数容量增广为整数解 (保证)，但若容量本身为分数，BFS 路径选择可能导致非整数最优解需特殊处理。**表现:** 算法仍输出分数流量，实际分配需向下取整可能违反需求约束 → 使用整数最大流 (intlinprog) 或加整数约束
- **条件2: 多种商品共享同一网络 (多商品流)** → 单商品最大流无视不同商品对同一带宽的竞争。**表现:** 各商品独立求解最大流之和远超网络总容量 → 使用多商品流 LP 模型或分解方法 (如 Benders 分解)
- **条件3: 容量存在不确定性 (如交通流量随机波动)** → 确定性最大流高估网络在随机条件下的可靠通过量。**表现:** 设计出的网络在容量波动时频繁拥堵 → 改用随机流 (stochastic flow) 或鲁棒优化模型

## 文献

1. Ford L.R. & Fulkerson D.R. (1956) "Maximal flow through a network." *Canadian Journal of Mathematics*, 8:399-404. DOI: [10.4153/CJM-1956-045-5](https://doi.org/10.4153/CJM-1956-045-5)
2. Ahuja R.K., Magnanti T.L. & Orlin J.B. (1993) *Network Flows: Theory, Algorithms, and Applications*. Prentice Hall. ISBN 978-0136175490

## 来源溯源

`matlab/graph/maxflow_ford_fulkerson.m` + MATLAB Graph toolbox `maxflow`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (最短路径) | PARADIGM-0401 (Dijkstra) |
| 组合 (二分匹配) | PARADIGM-0408 (匈牙利) |
| 替代 (线性约束) | PARADIGM-0101 (LP) |
