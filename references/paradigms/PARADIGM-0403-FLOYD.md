# PARADIGM-0403 Floyd-Warshall全源最短路⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0403 |
| 类别/子类 | ④图论与网络 / 最短路径 |
| 难度 | 低 |
| 适用题型关键词[] | Floyd-Warshall, 全源最短路径, 传递闭包, 动态规划, 距离矩阵, 路径重构 |
| confidence | high |
| source | matlab/graph/floyd_warshall.m |

## 数学形式

**动态规划递推 (DP Recurrence):**

$$d_{ij}^{(k)} = \min\left(d_{ij}^{(k-1)},\; d_{ik}^{(k-1)} + d_{kj}^{(k-1)}\right)$$

其中 $k=1,2,\ldots,n$ 为允许作为中间节点的顶点集合 $\{1,2,\ldots,k\}$。

**初始化:**

$$d_{ij}^{(0)} = \begin{cases}
0 & i = j \\
w(i,j) & (i,j) \in E \\
\infty & \text{otherwise}
\end{cases}$$

**路径重构 (Predecessor Matrix):**

$$\text{pred}[i][j] = \begin{cases}
i & \text{if } i \neq j \text{ and } (i,j) \in E \\
\text{NIL} & \text{otherwise}
\end{cases}$$

更新: 若 $d_{ik}^{(k-1)} + d_{kj}^{(k-1)} < d_{ij}^{(k-1)}$，则 $\text{pred}[i][j] = \text{pred}[k][j]$。

**负环检测:**

$$\exists i: d_{ii} < 0 \Rightarrow \text{存在负权环}$$

**变量表:**
- $d_{ij}^{(k)}$ — 从 $i$ 到 $j$ 且仅经过顶点 $\{1..k\}$ 的最短路径长度
- $\text{pred}[i][j]$ — 从 $i$ 到 $j$ 最短路径上 $j$ 的前驱节点
- $n = |V|$ — 顶点数
- 时间复杂度: $O(n^3)$，空间复杂度: $O(n^2)$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| adj_matrix | double[,] | — | n×n 矩阵，对角线=0，无边=Inf | — (输入数据) |
| 时间复杂度 | — | — | O(n³) (固定，三重循环) | — |
| 空间复杂度 | — | — | O(n²) (距离矩阵 + 前驱矩阵) | — |
| n 上限 (实用) | — | — | n≤500 (约 1.25 亿次操作) | 高 — 超出则不可行 |

## MATLAB 实现

函数签名:
```matlab
[dist, pred] = floyd_warshall(adj_matrix)
```

锚点: `matlab/graph/floyd_warshall.m` — 自写实现，三重循环标准版，支持路径重构与负环检测。

检测负环:
```matlab
if any(diag(dist) < 0)
    warning('负权环存在 — 最短路径无下界');
end
```

路径重构:
```matlab
path = reconstruct_path(pred, i, j);  % 从 pred 矩阵回溯
```

## Python 备选

```python
# SciPy 高效实现 (C 底层)
from scipy.sparse.csgraph import floyd_warshall
dist_matrix = floyd_warshall(csgraph=adj_matrix, directed=True)

# NetworkX
import networkx as nx
dist = nx.floyd_warshall_numpy(G)  # 返回 numpy 数组
paths = dict(nx.floyd_warshall(G))  # 返回距离 + 路径

# 纯 Python 自写 (教学用途)
import numpy as np
def floyd_warshall(adj_matrix):
    n = len(adj_matrix)
    dist = adj_matrix.copy()
    pred = np.full((n, n), -1)
    for i in range(n):
        for j in range(n):
            if i != j and dist[i, j] < np.inf:
                pred[i, j] = i
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if dist[i, k] + dist[k, j] < dist[i, j]:
                    dist[i, j] = dist[i, k] + dist[k, j]
                    pred[i, j] = pred[k, j]
    return dist, pred
```

## 选型决策树

- **用 Floyd-Warshall** — 需要全源最短路径，图规模小 (V≤500)，实现简单
- **用 V×Dijkstra (PARADIGM-0401)** — 稀疏图 (E≪V²)，重复 Dijkstra 比 Floyd O(V³) 快得多: O(V·(V+E)log V) vs O(V³)
- **用 Johnson 算法** — 中等规模带负权边的全源最短路径: O(V² log V + VE)
- **用传递闭包 (PARADIGM-0407)** — 仅需知道节点间是否可达 (布尔运算)，不需具体距离值
- **用近似/分层方法** — 超大规模图 (V>10000)，O(V³) 内存和时间均不可接受
- **Trade-off:** Floyd 对稠密图 (E≈V²) 计算全源最优，代码极简无需堆；稀疏图或只需少数源点时不适用

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 邻接矩阵热力图 (heatmap) | 浅色=近，深色=远/不通，对角线=0 |
| process | 距离矩阵演化图 (k=0, k=1, k=final 三子图) | 展示中间节点集的逐步扩大效果 |
| result | 最终距离矩阵热力图 + 示例路径追踪 (graph + highlight) | 选一对节点展示重构出的具体路径 |

## 常见坑

1. **O(n³) 不可并行化瓶颈:** n>500 时 >1.25 亿次运算，MATLAB 三重循环解释执行极慢。缓解: 用向量化 (parfor 仅能外层并行)、或改用 SciPy C 实现
2. **Inf 加法溢出:** `d[i,k] + d[k,j]` 当二者之一为 Inf 时：在 MATLAB 中 Inf+finite=Inf (安全)，但某些语言产生 NaN → 每次加法前需判断 `if d[i,k] != INF and d[k,j] != INF`
3. **负环传播:** 检测到 $d_{ii}<0$ 后，含负环节点的所有路径距离变为 $-\infty$，不应使用结果。需在检测后标记受影响节点并报告
4. **整数溢出:** 使用 `int('inf')` 或 `1e9` 表示无穷时，多次加法可能溢出 → 用 `double('Inf')` 或充分大的浮点数
5. **前驱矩阵初始化遗漏:** 若忘记初始化 pred[i][j]=i (当 i≠j 且边存在)，路径重构返回空路径 — 需在初始化时正确设置

## 失效条件/反例 (强制小节)

- **条件1: 超大规模稀疏图 (V>1000 且 E=O(V))** → Floyd 固定 O(V³) 时间不可接受 (V=1000 即 10 亿次运算)，而 V×Dijkstra 仅需 O(V² log V) 约 1000 万次。**表现:** MATLAB 中三重循环运行数小时无结果 → 改用 V×Dijkstra (PARADIGM-0401) 或 Johnson 算法
- **条件2: 仅需少量节点对的最短路径 (如 10 对 / 1000 节点图)** → Floyd 强行计算全部 100 万对，其中 99.999% 的结果被浪费。**表现:** 内存和运算时间远超必要 → 改用按需 Dijkstra 或 A* (每对独立运行)
- **条件3: V>10000 的内存需求** → O(V²) 距离矩阵为双精度 800MB (10000² × 8 bytes)，超出普通桌面内存且无法在 GPU 上使用。**表现:** MATLAB `Out of memory` 错误 → 改用分层/landmark 近似方法 (如 highway hierarchies)

## 文献

1. Floyd R.W. (1962) "Algorithm 97: Shortest Path." *Communications of the ACM*, 5(6):345. DOI: [10.1145/367766.368168](https://doi.org/10.1145/367766.368168)
2. Warshall S. (1962) "A theorem on Boolean matrices." *Journal of the ACM*, 9(1):11-12. DOI: [10.1145/321105.321107](https://doi.org/10.1145/321105.321107)

## 来源溯源

`matlab/graph/floyd_warshall.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (单源/稀疏图) | PARADIGM-0401 (Dijkstra) |
| 组合 (布尔闭包) | PARADIGM-0407 (传递闭包) |
| 前置 (路径规划) | PARADIGM-0401 (Dijkstra) |
