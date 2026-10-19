# PARADIGM-0407 欧拉/哈密顿路径⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0407 |
| 类别/子类 | ④图论与网络 / 路径遍历 |
| 难度 | 中 |
| 适用题型关键词[] | 欧拉回路, 哈密顿圈, 中国邮递员, TSP, 一笔画, 遍历路径, 邮路优化, 垃圾收集路线 |
| confidence | high |
| source | Euler(1736); Hamilton(1859); 组合优化经典问题 |

## 数学形式

**欧拉回路 (Eulerian Circuit):**
经过每条边恰好一次的闭合回路。

**存在性充要条件 (无向图):**
$$\forall v \in V: \deg(v) \equiv 0 \pmod{2} \quad \text{且图连通}$$

**存在性充要条件 (有向图):**
$$\forall v \in V: \deg_{\text{in}}(v) = \deg_{\text{out}}(v) \quad \text{且图强连通}$$

**欧拉路径 (Eulerian Path):**
经过每条边恰好一次的非闭合路径 — 恰有两个奇度节点 (起点/终点)。

**Hierholzer 算法 O(E):**
1. 从起点开始 DFS，持续遍历未访问的边
2. 当走到"死胡同"(无未访问出边)，将该节点压入栈
3. 回溯继续探索，最终栈的逆序即为欧拉回路

**哈密顿回路 (Hamiltonian Cycle):**
经过每个节点恰好一次的闭合回路 — **NP-完全问题**，充要条件未知。

**充分条件 (Dirac 定理, 1952):**
若 $n \geq 3$ 且 $\forall v: \deg(v) \geq n/2$，则存在哈密顿回路。

**变量表:**
- $\deg(v)$ — 节点度数
- $n$ — 节点数
- 欧拉: 多项式时间 P；哈密顿: NP-complete

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| adj_matrix | double[,] | — | n×n 邻接矩阵 | — |
| mode | str | 'euler' | 'euler' / 'hamilton' | — |
| 欧拉算法复杂度 | — | — | O(E) Hierholzer | — |
| 哈密顿算法复杂度 | — | — | NP-完全 | — |

## MATLAB 实现

函数签名 (自写):
```matlab
% 欧拉回路
[circuit, feasible] = eulerian_circuit(adj_matrix)
% feasible=false 若奇度节点数 > 0

% 中国邮递员问题 (CPP): 求最短欧拉回路 (非欧拉图需复制边)
[route, total_dist] = chinese_postman(adj_matrix)

% 哈密顿回路 (回溯/动态规划 O(2^n·n²))
[cycle, found] = hamiltonian_cycle_held_karp(adj_matrix)
```

锚点: 自写-见S5:eulerian_circuit.m, chinese_postman.m

## Python 备选

```python
# NetworkX
import networkx as nx
G = nx.from_numpy_array(adj_matrix)

# 欧拉回路
if nx.is_eulerian(G):
    circuit = list(nx.eulerian_circuit(G))

# 哈密顿回路 (无内置，需自写或使用 TSP 求解器)
# approach: 转为 TSP (全连接，原边权=0或小值)
from python_tsp.exact import solve_tsp_dynamic_programming
```

## 选型决策树

- **欧拉回路** — 边遍历问题 (邮递员、扫雪路线、管道检测)，多项式时间可解
- **中国邮递员 CPP** — 原图非欧拉 (奇度节点>0)→ 复制边使其欧拉化，需求最短总路程
- **哈密顿回路/TSP** — 点遍历问题 (物流配送、旅行商)，NP-hard → 小规模精确解 (Held-Karp O(n²·2^n))，大规模用启发式 (GA/PARADIGM-0105, PSO/PARADIGM-0106)
- **不要混淆**: 邮递员走"所有边"→ 欧拉；旅行商走"所有城市"→ 哈密顿

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 图结构 (标注节点度数) | 红色=奇度节点 |
| process | 欧拉回路逐步遍历动画 | 已遍历边着色 |
| result | 最优遍历路径高亮 | 标注总长度 |

## 常见坑

1. **哈密顿=NP-完全**: n > 20 不宜求精确解，建模论文中明确说明用启发式并给出 n 的规模
2. **有向欧拉判定不同**: 入度=出度，非无向图的度数为偶。混用会导致误判
3. **中国邮递员需 Floyd 预处理**: 奇度节点配对需求最短路径权重 (在完全图上做最小权完美匹配)

## 失效条件/反例 (强制小节)

- **条件1: 哈密顿回路 n > 30** → 表现: Held-Karp DP 需要 O(n²·2^n) 时间和空间，n=30 时 2^30 ≈ 10^9 状态，内存和时间均不可接受。**应对**: 转为 TSP 用元启发式 (GA/PSO/ACO) 求解，或在建模中降维/聚类后再求局部哈密顿
- **条件2: 中国邮递员在有向图/混合图上** → 表现: 无向图 CPP 是 P 问题，但有向/混合图 CPP 是 NP-hard，需转为最小费用流问题。**应对**: 有向图 CPP → 找入度-出度不平衡节点，求解运输问题 (Transportation Problem) 确定复制边

## 文献

1. Euler L. (1736). "Solutio problematis ad geometriam situs pertinentis." *Commentarii Academiae Scientiarum Petropolitanae*, 8:128-140. (柯尼斯堡七桥问题)
2. Edmonds J. & Johnson E.L. (1973). "Matching, Euler tours and the Chinese postman." *Mathematical Programming*, 5:88-124. DOI: [10.1007/BF01580113](https://doi.org/10.1007/BF01580113)
3. Applegate D.L., Bixby R.E., Chvatal V. & Cook W.J. (2006). *The Traveling Salesman Problem: A Computational Study*. Princeton University Press. ISBN: 978-0691129938

## 来源溯源

自写 eulerian_circuit.m / chinese_postman.m; 图论教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (TSP求解) | PARADIGM-0105 (GA) |
| 组合 (TSP求解) | PARADIGM-0106 (PSO) |
| 组合 (TSP求解) | PARADIGM-0107 (ACO) |
| 前置 | PARADIGM-0401 (Dijkstra) |
