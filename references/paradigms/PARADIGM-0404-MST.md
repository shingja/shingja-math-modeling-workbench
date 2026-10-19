# PARADIGM-0404 最小生成树Prim/Kruskal⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0404 |
| 类别/子类 | ④图论与网络 / 最小生成树 |
| 难度 | 低 |
| 适用题型关键词[] | 最小生成树, MST, Prim, Kruskal, 网络设计, 布线优化, 聚类辅助, 连通成本最小 |
| confidence | high |
| source | Prim(1957) Bell System Tech J; Kruskal(1956) Proc AMS |

## 数学形式

**问题定义:**
无向连通图 $G=(V,E)$，边权 $w(e) \geq 0$，求一棵生成树 $T \subseteq E$ 满足 $\sum_{e \in T} w(e)$ 最小。

**Prim 算法 (稠密图 O(V²)):**
维护已选节点集 $S$，每次选取连接 $S$ 与 $V\setminus S$ 的最小权边:

$$e^* = \arg\min_{e=(u,v): u\in S, v\notin S} w(e)$$

$$S \leftarrow S \cup \{v\}, \quad T \leftarrow T \cup \{e^*\}$$

**Kruskal 算法 (稀疏图 O(E log E)):**
按权重升序排列所有边，依次添加不构成环的边 (并查集判断):

$$\text{Sort}(E) \text{ by } w; \quad \text{Union-Find for connectivity}$$

**割性质 (Cut Property):**
对任意割集 $[S, V\setminus S]$，横跨该割的最小权边必属于某棵 MST。

**变量表:**
- $w(e)$ — 边权重 (如距离、费用、阻抗)
- Union-Find $\alpha(n)$ — 近乎常数均摊时间

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| adj_matrix | double[,] | — | n×n 对称非负 | — |
| method | str | 'auto' | 'prim','kruskal','auto' | 低 — auto 根据 E/V² 选择 |
| 时间复杂度 (Prim 堆) | — | — | O(E log V) | — |
| 时间复杂度 (Kruskal) | — | — | O(E log E) | — |
| 空间复杂度 | — | — | O(V+E) | — |

## MATLAB 实现

函数签名 (Graph toolbox + 自写):
```matlab
% MATLAB 内置 (Prim)
G = graph(s, t, weights);
[T, pred] = minspantree(G);
% 可视化
plot(T, 'EdgeLabel', T.Edges.Weight);

% 自写 Kruskal
[mst_edges, total_weight] = kruskal_mst(adj_matrix);
```

锚点: `minspantree` (MATLAB Graph toolbox) + 自写-见S5:kruskal_mst.m

**输出:**
- `T` — graph 对象，仅含 MST 的边
- `total_weight` — MST 总权重

## Python 备选

```python
# NetworkX
import networkx as nx
G = nx.from_numpy_array(adj_matrix)
# Kruskal
mst = nx.minimum_spanning_tree(G, algorithm='kruskal')
# Prim
mst = nx.minimum_spanning_tree(G, algorithm='prim')
total_weight = mst.size(weight='weight')

# scipy
from scipy.sparse.csgraph import minimum_spanning_tree
mst_sparse = minimum_spanning_tree(csr_matrix(adj_matrix))
```

## 选型决策树

- **Kruskal** — 稀疏图 (E << V²)，需排序+并查集，适合边列表输入
- **Prim (堆)** — 稠密图 (E ≈ V²)，堆实现 O(E log V)，适合邻接矩阵输入
- **Prim (朴素 O(V²))** — 极稠密图或 V < 1000，无堆开销
- **不要用** — 有向图中 MST 定义不同 (最小树形图/Arborescence，需朱刘算法 Chu-Liu/Edmonds)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 完整加权无向图 | 节点+边权重热力标注 |
| process | Kruskal 步骤: 已选边逐步上色，并查集森林演化 | 动画展示 |
| result | MST 高亮在原图上 | 非 MST 边灰度淡化 |

## 常见坑

1. **非连通图**: 若图不连通，MST 不存在 — 得到的是最小生成森林 (MSF)。需预处理检查连通分量数
2. **浮点权重→唯一性问题**: 浮点舍入可能使"相等"边顺序不唯一，导致不同运行产生不同 MST。用 `sortrows` 带容差排序
3. **MST 不用于聚类**: 虽然去掉 MST 的最长 k-1 条边可得到 k 聚类，但这不是鲁棒的聚类算法 (对噪声敏感)

## 失效条件/反例 (强制小节)

- **条件1: 权重动态变化 (如网络流量实时变化)** → 表现: 静态 MST 随权重变化失效，每次重算 O(E log E) 浪费。**应对**: 使用动态 MST 算法 (Dynamic Connectivity / Holm-de Lichtenberg-Thorup)，或改用 Steiner Tree 变种
- **条件2: 约束 MST (如带度约束、容量约束)** → 表现: 标准 Prim/Kruskal 求出的 MST 可能违反度约束 (某节点度数 > 限制)。**应对**: 度约束 MST 是 NP-hard，需用启发式 (如贪心边交换) 或转换为 Flow 问题

## 文献

1. Prim R.C. (1957). "Shortest connection networks and some generalizations." *Bell System Technical Journal*, 36(6):1389-1401. DOI: [10.1002/j.1538-7305.1957.tb01515.x](https://doi.org/10.1002/j.1538-7305.1957.tb01515.x)
2. Kruskal J.B. (1956). "On the shortest spanning subtree of a graph and the traveling salesman problem." *Proceedings of the American Mathematical Society*, 7(1):48-50. DOI: [10.2307/2033241](https://doi.org/10.2307/2033241)
3. Cormen T.H. et al. (2009). *Introduction to Algorithms*, 3rd ed. Chapter 23. ISBN: 978-0262033848

## 来源溯源

MATLAB `minspantree` + 自写 kruskal_mst.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (最短路) | PARADIGM-0401 (Dijkstra) |
| 组合 (网络流) | PARADIGM-0405 (最大流) |
| 组合 (Steiner树延伸) | PARADIGM-0402 (Bellman-Ford, 约束MST) |
