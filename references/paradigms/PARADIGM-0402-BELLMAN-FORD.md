# PARADIGM-0402 Bellman-Ford含负权⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0402 |
| 类别/子类 | ④图论与网络 / 最短路径 |
| 难度 | 中 |
| 适用题型关键词[] | Bellman-Ford, 负权边, 负环检测, 套利, 汇率, 最短路含负权, 分布式路由 |
| confidence | high |
| source | Bellman(1958) QAM; Ford(1956) RAND Report |

## 数学形式

**核心迭代 (Relaxation):**

对所有边 $(u,v)$ 执行 $|V|-1$ 轮松弛:

$$d[v] = \min(d[v], \; d[u] + w(u,v)) \quad \forall (u,v) \in E$$

**初始化:**
$$d[s] = 0, \quad d[v] = \infty \; (v \neq s), \quad \text{pred}[v] = \text{null}$$

**动态规划解释:**
令 $d^{(k)}[v]$ 为最多使用 $k$ 条边从 $s$ 到 $v$ 的最短路径:
$$d^{(k)}[v] = \min\left(d^{(k-1)}[v], \; \min_{u:(u,v)\in E} \{d^{(k-1)}[u] + w(u,v)\}\right)$$

**负环检测 (第 $|V|$ 轮):**
若第 $V$ 轮仍有任何 $d[v]$ 减小，则图中存在源点可达的负权环 (负环)。

**变量表:**
- $d[v]$ — 从源点 $s$ 到 $v$ 的当前最短距离估计
- $w(u,v)$ — 边 $(u,v)$ 权重 (可为负值)
- $\text{pred}[v]$ — 前驱节点，用于路径重构
- 时间复杂度: $O(VE)$，空间复杂度: $O(V)$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| adj_matrix | double[,] | — | n×n，可含负值 | — (输入数据) |
| source | int | — | [1, n] | 低 — 仅改变起点 |
| 时间复杂度 | — | — | O(VE) | — |
| 空间复杂度 | — | — | O(V) | — |
| 稠密图最坏 | — | — | O(V³) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[dist, path, pred, has_neg_cycle] = bellman_ford(adj_matrix, source)
```

锚点: 自写-见S5:bellman_ford.m

**输出说明:**
- `dist` — 1×n 距离向量 (含负环则部分节点为 -Inf)
- `has_neg_cycle` — 布尔值，true 表示存在源点可达的负环
- `path` — 从 source 到各节点的前驱链重构路径

```matlab
% 负环检测专用模式
[dist, has_neg_cycle, neg_cycle_nodes] = bellman_ford(adj_matrix, source);
if has_neg_cycle
    fprintf('检测到负环，涉及节点: ');
    disp(neg_cycle_nodes);
end
```

## Python 备选

```python
# NetworkX
import networkx as nx
G = nx.from_numpy_array(adj_matrix, create_using=nx.DiGraph)
try:
    path = nx.bellman_ford_path(G, source, target, weight='weight')
    length = nx.bellman_ford_path_length(G, source, target, weight='weight')
except nx.NetworkXUnbounded:
    print("检测到负环!")

# scipy (仅含非负)
from scipy.sparse.csgraph import bellman_ford
dist_matrix = bellman_ford(csgraph=adj_matrix, directed=True, indices=source)
```

## 选型决策树

- **用 Bellman-Ford** — 图中含负权边，或需检测负环 (如汇率套利、金融工程)
- **用 Dijkstra (PARADIGM-0401)** — 所有边权非负，Bellman-Ford 时间复杂度 O(VE) 比 Dijkstra O((V+E)log V) 差
- **用 Floyd-Warshall (PARADIGM-0403)** — 全源+负权，稠密图 O(V³) 与 Bellman-Ford 对每个源点运行 O(V²E) 比较
- **用 SPFA** — 期望更快 (O(E)) 但不稳定，最坏 O(VE)；建模竞赛建议用标准 Bellman-Ford
- **Trade-off:** Bellman-Ford 比 Dijkstra 慢但通用；只有确认负权存在时才用

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 加权有向图 (边标权重，负边红色标注) | 展示负权边位置 |
| process | 逐轮距离表更新热力图 (round × node) | 展示 $d^{(k)}$ 的收敛过程 |
| result | 最短路径高亮 + 负环位置标记 | 若检测到负环则标红 |

## 常见坑

1. **无向负边等同于负环**: 无向图中一条负权边 $(u,v)$ 即构成负环 $u \to v \to u$，算法必检测出负环。解决方案: 用有向图建模
2. **SPFA 在特定图上退化为指数**: 竞赛中部分题目 SPFA 被刻意卡到 O(2^V)，稳扎稳打用标准 Bellman-Ford
3. **负环距离定义为 -Inf**: 算法可能输出距离为 -Inf (表示通过负环可获得任意小距离)，论文中需明确标注

## 失效条件/反例 (强制小节)

- **条件1: 图规模极大 (V > 10^5, E > 10^6) 且含负权** → 表现: O(VE) 时间不可接受 (10^11 次操作)。即使 SPFA 也可能退化。**应对**: 若负权边极少，可先用 Dijkstra 忽略负权求近似解，再对负权邻域精确修正 (Johnson 算法思路)；或分析问题是否可转化为非负权
- **条件2: 负环检测在分布式/并行环境下通信开销大** → 表现: 每轮需要所有节点同步距离信息，网络延迟淹没了计算时间。**应对**: 使用异步分布式 Bellman-Ford (距离向量路由协议 RIP 的原理)，容忍收敛慢但通信局部化

## 文献

1. Bellman R. (1958). "On a routing problem." *Quarterly of Applied Mathematics*, 16(1):87-90. DOI: [10.1090/qam/102435](https://doi.org/10.1090/qam/102435)
2. Ford L.R. (1956). *Network Flow Theory*. RAND Corporation Paper P-923.
3. Cormen T.H., Leiserson C.E., Rivest R.L. & Stein C. (2009). *Introduction to Algorithms*, 3rd ed. MIT Press. Chapter 24.1. ISBN: 978-0262033848

## 来源溯源

自写实现 bellman_ford.m; 经典教材算法导论第24章

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (非负权) | PARADIGM-0401 (Dijkstra) |
| 替代 (全源+负权) | PARADIGM-0403 (Floyd) |
| 组合 (套利检测) | PARADIGM-0405 (最大流) |
| 组合 (网络设计) | PARADIGM-0404 (MST) |
