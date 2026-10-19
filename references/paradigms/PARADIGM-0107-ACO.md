# PARADIGM-0107 蚁群算法ACO⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0107 |
| 类别/子类 | ①优化 / 群智能 |
| 难度 | 中 |
| 适用题型关键词[] | 蚁群算法, TSP, 路径优化, 信息素, 启发式算法, 组合优化, 路径规划 |
| confidence | high |
| source | matlab/optim/ant_colony_tsp.m |

## 数学形式

**转移概率 (Transition Probability):**

$$p_{ij}^k(t) = \frac{[\tau_{ij}(t)]^\alpha \cdot [\eta_{ij}]^\beta}{\sum_{l \in \mathcal{N}_i^k} [\tau_{il}(t)]^\alpha \cdot [\eta_{il}]^\beta}$$

**信息素更新 (Pheromone Update):**

$$\tau_{ij}(t+1) = (1-\rho) \cdot \tau_{ij}(t) + \sum_{k=1}^{m} \Delta \tau_{ij}^k$$

其中 $\Delta \tau_{ij}^k = Q / L_k$ 若蚂蚁 $k$ 经过边 $(i,j)$，否则 $0$。

**启发式信息 (Visibility):**

$$\eta_{ij} = \frac{1}{d_{ij}}$$

**变量表:**
- $\tau_{ij}$ — 边 $(i,j)$ 上的信息素浓度
- $\eta_{ij}$ — 启发式因子 (能见度)，取距离倒数
- $\alpha$ — 信息素重要度因子 ($\alpha \geq 0$)
- $\beta$ — 启发式信息重要度因子 ($\beta \geq 0$)
- $\rho$ — 信息素挥发系数 ($0 < \rho < 1$)
- $Q$ — 信息素常数 (总释放量)
- $L_k$ — 第 $k$ 只蚂蚁的路径总长度
- $\mathcal{N}_i^k$ — 蚂蚁 $k$ 在节点 $i$ 的可行邻域

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| dist_matrix | double[,] | — | 非负对称矩阵 | — (输入数据) |
| n_ants | int | 50 | [10, 200] | 中 — 太少探索不足，太多计算量大 |
| n_iters | int | 200 | [50, 1000] | 低 — 收敛后增加迭代收益递减 |
| alpha | double | 1.0 | [0.5, 5.0] | 高 — α过大→过早收敛；α过小→退化随机搜索 |
| beta | double | 2.0 | [1.0, 5.0] | 高 — β过大→贪婪选择；β过小→忽略距离信息 |
| rho | double | 0.5 | [0.1, 0.9] | 高 — ρ过大→信息素挥发快，收敛慢；ρ过小→信息素积累，早熟停滞 |
| Q | double | 1.0 | [1, 100] | 中 — 影响信息素增量幅度 |
| 时间复杂度 | — | — | O(n_iters × n_ants × n²) | — |
| 空间复杂度 | — | — | O(n²) (信息素矩阵) | — |

## MATLAB 实现

函数签名:
```matlab
[best_route, min_dist, convergence] = ant_colony_tsp(dist_matrix, n_ants, n_iters, alpha, beta, rho)
```

锚点: `matlab/optim/ant_colony_tsp.m` — 自写实现，基于 Dorigo (1996) Ant System 经典版本。

- `best_route` — 最优访问顺序 (1×n)
- `min_dist` — 最优路径总距离
- `convergence` — 每代最优距离记录 (1×n_iters)，用于收敛曲线绘制

## Python 备选

```python
from sko import ACO_TSP
aco = ACO_TSP(func=distance_func, n_dim=n_cities,
              size_pop=n_ants, max_iter=n_iters,
              alpha=1.0, beta=2.0, rho=0.5)
best_points, best_distance = aco.run()
```

或纯 numpy 自定义实现:
```python
import numpy as np
def aco_tsp(dist_matrix, n_ants=50, n_iters=200, alpha=1.0, beta=2.0, rho=0.5):
    n = len(dist_matrix)
    pheromone = np.ones((n, n)) / n
    eta = 1.0 / (dist_matrix + 1e-10)  # visibility
    # ... 迭代主循环
```

## 选型决策树

- **用 ACO** — TSP 及路径规划问题，规模 50~500 节点，寻求近似最优
- **用 Dijkstra (PARADIGM-0401)** — 单源最短路径，非巡回
- **用 GA (PARADIGM-0105)** — 组合优化但参数少调、非路径类
- **用 DE (PARADIGM-0108)** — 连续优化而非组合优化
- **用精确 DP/Held-Karp** — 小规模 TSP (n<20) 需要精确解
- **用 LKH 启发式** — 超大规模 TSP (n>1000)，ACO 收敛退化
- **Trade-off:** ACO 在 TSP 类问题上表现优异但参数敏感；对非路径类组合优化 (调度、背包) 需自定义构造图，难度上升

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 距离矩阵热力图 (heatmap) | 展示城市间距离分布 |
| process | 收敛曲线 (best distance vs iteration) | Y 轴对数尺度，观察停滞 |
| result | 路线图 (scatter + line plot) | 城市散点 + 最优路径连线，起点突出 |

## 常见坑

1. **参数调优依赖经验:** $\alpha, \beta, \rho$ 三个参数高度问题相关 — $\alpha$ 过高导致过早收敛到次优解，$\alpha$ 过低退化为随机搜索；建议网格搜索或使用 Max-Min AS 自适应策略
2. **信息素停滞 (Pheromone Stagnation):** 所有蚂蚁走同一条路径 → 搜索完全停滞，用精英策略 (Elitist AS) 或限制信息素范围 [$\tau_{min}$, $\tau_{max}$]
3. **O(n²·m) 每代复杂度:** n>500 时单代运算慢，可考虑候选集 (candidate list) 加速邻域搜索
4. **距离矩阵对称性:** 非对称 TSP ($d_{ij} \neq d_{ji}$) 时信息素更新需区分方向，标准实现需修改
5. **初始信息素设置:** 均匀初始化可能导致初始几代无方向性随机游走 → 可用贪心路径预初始化

## 失效条件/反例 (强制小节)

- **条件1: 大规模图 >1000 节点** → 蚁群退化为随机游走，每代探索效率极低，收敛到较差局部最优。**表现:** 收敛曲线过早平坦，最终解远离已知下界 → 改用 DE 或 LKH 启发式
- **条件2: 问题非路径类 (如 0-1 背包、调度)** → 蚂蚁构造解的"图"需要人工设计 (构造图)，且路径质量与解质量对应关系不直接。**表现:** 信息素反馈误导搜索方向，解质量不如 GA 或 SA → 改用 GA (PARADIGM-0105) 或模拟退火

## 文献

1. Dorigo M., Maniezzo V. & Colorni A. (1996) "Ant system: optimization by a colony of cooperating agents." *IEEE Transactions on Systems, Man, and Cybernetics, Part B*, 26(1):29-41. DOI: [10.1109/3477.484436](https://doi.org/10.1109/3477.484436)
2. Dorigo M. & Stutzle T. (2004) *Ant Colony Optimization*. MIT Press. ISBN 978-0262042192

## 来源溯源

`matlab/optim/ant_colony_tsp.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (连续优化) | PARADIGM-0108 (DE) |
| 组合 (进化算法) | PARADIGM-0105 (GA) |
| 对比 (群智能) | PARADIGM-0106 (PSO) |
| 前置 (精确最短路径) | PARADIGM-0401 (Dijkstra) |
