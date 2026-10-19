# PARADIGM-0408 匈牙利算法二分图匹配⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0408 |
| 类别/子类 | ④图论与网络 / 匹配 |
| 难度 | 中 |
| 适用题型关键词[] | 匈牙利算法, 二分图匹配, 指派问题, 最大匹配, 最小费用, 完美匹配, 任务分配 |
| confidence | high |
| source | matlab/graph/hungarian.m |

## 数学形式

**指派问题 (Assignment Problem):**

$$\begin{aligned}
\min \quad & \sum_{i=1}^{n} \sum_{j=1}^{n} c_{ij} \cdot x_{ij} \\
\text{s.t.} \quad & \sum_{i=1}^{n} x_{ij} = 1 \quad \forall j \in \{1,\ldots,n\} \\
& \sum_{j=1}^{n} x_{ij} = 1 \quad \forall i \in \{1,\ldots,n\} \\
& x_{ij} \in \{0, 1\}
\end{aligned}$$

**对偶变量 (Dual / Potentials):**
- $u_i$ — 行势 (row potential)
- $v_j$ — 列势 (column potential)
- 互补松弛条件: $x_{ij}=1 \Rightarrow c_{ij} - u_i - v_j = 0$

**算法步骤 (Kuhn-Munkres):**
1. **行归约:** 每行减去该行最小值，$\hat{c}_{ij} = c_{ij} - \min_j c_{ij}$
2. **列归约:** 每列减去该列最小值
3. **覆盖零:** 用最少行线 + 列线覆盖所有零元素
4. **矩阵调整:** 若覆盖线数 < $n$: 找出未覆盖元素最小值 $\delta$，未覆盖元素减 $\delta$，被两条线交叉覆盖的元素加 $\delta$，重复步骤 3
5. **提取指派:** 从约简矩阵中选取 $n$ 个不同行不同列的零元素

**时间复杂度:** $O(n^3)$。

**变量表:**
- $c_{ij}$ — 将任务 $j$ 分配给工人 $i$ 的费用
- $x_{ij}$ — 二分指派指示变量 (0/1)
- $u_i$, $v_j$ — 对偶变量 (影子价格)
- $n$ — 工人数 = 任务数 (方阵情况)
- 若 $n \neq m$ (矩形): 补零行/列填充为方阵

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| cost_matrix | double[,] | — | n×n (方阵) 或 n×m (矩形，补零) | — (输入数据) |
| 最大化/最小化 | string | 'min' | 'min' / 'max' | — (通过取负或 max-cost 转换) |
| infeasible_penalty | double | 1e10 | 远大于正常费用值 | 中 — 太大导致数值问题，太小可能被选入 |
| 时间复杂度 | — | — | O(n³) | — |
| 空间复杂度 | — | — | O(n²) (费用矩阵 + 增广矩阵) | — |
| n 上限 (实用) | — | — | n≤5000 | 高 — 超出需改用近似或分布式算法 |

## MATLAB 实现

函数签名:
```matlab
[assignment, cost] = hungarian(cost_matrix)
```

锚点: `matlab/graph/hungarian.m` — 自写 Kuhn-Munkres 实现，支持方阵与矩形矩阵。

- `assignment` — 指派向量 (1×n)，`assignment(i)=j` 表示工人 $i$ 分配任务 $j$，0 表示未匹配
- `cost` — 总费用 (标量)

矩形矩阵处理 (n≠m):
```matlab
% 自动补零行/列
n = max(size(cost_matrix, 1), size(cost_matrix, 2));
padded = zeros(n);
padded(1:size(cost_matrix,1), 1:size(cost_matrix,2)) = cost_matrix;
[assignment, cost] = hungarian(padded);
% 裁剪假匹配 (补零行/列产生的)
assignment(assignment > size(cost_matrix,2)) = 0;
```

最大化问题转换:
```matlab
% 方法1: 取负
[assignment, ~] = hungarian(-profit_matrix);

% 方法2: max-profit 变换
max_val = max(profit_matrix(:));
[assignment, ~] = hungarian(max_val - profit_matrix);
```

## Python 备选

```python
# SciPy (推荐)
from scipy.optimize import linear_sum_assignment
row_ind, col_ind = linear_sum_assignment(cost_matrix)
total_cost = cost_matrix[row_ind, col_ind].sum()

# munkres 库
from munkres import Munkres
m = Munkres()
indexes = m.compute(cost_matrix)
total_cost = sum(cost_matrix[i][j] for i, j in indexes)

# NetworkX 二分图匹配
import networkx as nx
from networkx.algorithms import bipartite
G = nx.Graph()
G.add_nodes_from(workers, bipartite=0)
G.add_nodes_from(tasks, bipartite=1)
G.add_weighted_edges_from([(w, t, c) for w, t, c in edges])
matching = bipartite.minimum_weight_full_matching(G)
```

## 选型决策树

- **用匈牙利算法** — 标准一对一指派问题 (n 个工人 → n 个任务)，最小化总费用
- **用最大流 (PARADIGM-0405)** — 二分图最大匹配 (不关心费用，仅最大化匹配数)
- **用 MILP (PARADIGM-0102)** — 存在额外约束 (如工人 i 不能与工人 k 同时做某类任务、任务有先后顺序)
- **用广义指派 (MILP/启发式)** — 一个工人可执行多个任务 (one-to-many)，NP-hard
- **用拍卖算法 (Auction)** — 超大规模 (n>5000)，匈牙利 O(n³) 不可接受，拍卖算法可并行
- **Trade-off:** 匈牙利是精确算法，多项式时间 O(n³) 保证最优解；MILP 更灵活但求解慢；拍卖算法快但近似

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 费用矩阵热力图 (heatmap) | 浅色=低费用 (好匹配)，深色=高费用/不可行 |
| process | 约简矩阵演化图 (row→column→cover→adjust 四子图) | 展示零元素逐步暴露过程 |
| result | 二分图匹配图 (bipartite layout + matched edges) | 工人节点列左，任务节点列右，匹配边着色加粗，附总费用标注 |

## 常见坑

1. **矩形矩阵补零产生"零费用假匹配":** n≠m 时补零行/列可能被选为实际匹配 → 费用=0 但不真实。解: 补零后裁剪，或使用大值 M 填充而非零 (但 M 需小于二倍正常最小费用)
2. **不可行指派处理:** 工人不能做某任务时不能用 0 (会被优先选) 或 Inf (算法崩溃) → 用充分大的 M (如 max(cost)×10)，确保不被选入最优解
3. **最大化问题取负陷阱:** `hungarian(-profit)` 中若 profit 全正，-profit 全负 → 部分算法实现假设费用≥0 可能出错。解: 用 `max(profit) - profit` 变换保持非负
4. **多个最优解:** 匈牙利只返回一个最优解，但可能有多个同费用指派。若需枚举所有 → 后续用分支定界
5. **浮点费用比较:** 归约过程中零判断 `== 0` 因浮点误差遗漏 → 用容差 `abs(value) < 1e-10`

## 失效条件/反例 (强制小节)

- **条件1: 指派约束为软约束 (如工人可做 2 个任务)** → 匈牙利强制 1-to-1 匹配，无法表达容量 >1，产生不可行解。**表现:** 硬性忽略超额任务，或实际需要 3 个工人做 4 个任务时无法分配 → 改用广义指派问题 (MILP 或贪心+局部搜索)
- **条件2: 存在额外组合约束 (如任务 j 和 k 不能由同一工人做，或任务有先后依赖)** → 匈牙利假设任务间独立，忽略此类约束。**表现:** 输出的指派违反了实际业务规则 → 改用约束规划 (Constraint Programming) 或 MILP 显式建模约束
- **条件3: 超大规模 n>5000** → O(n³) 匈牙利需约 1250 亿次运算 (5000³)，在普通机器上数小时不收敛。**表现:** MATLAB/NumPy 内存不足或运行时间不可接受 → 改用拍卖算法 (可分布式并行) 或贪心近似 + 局部搜索

## 文献

1. Kuhn H.W. (1955) "The Hungarian method for the assignment problem." *Naval Research Logistics Quarterly*, 2(1-2):83-97. DOI: [10.1002/nav.3800020109](https://doi.org/10.1002/nav.3800020109)
2. Munkres J. (1957) "Algorithms for the assignment and transportation problems." *Journal of the Society for Industrial and Applied Mathematics*, 5(1):32-38. DOI: [10.1137/0105003](https://doi.org/10.1137/0105003)

## 来源溯源

`matlab/graph/hungarian.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (二分匹配) | PARADIGM-0405 (最大流) |
| 替代 (线性约束) | PARADIGM-0101 (LP) |
| 替代 (组合优化) | PARADIGM-0107 (ACO) |
