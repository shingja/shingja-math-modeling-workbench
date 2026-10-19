# PARADIGM-0102 整数规划 (Integer Programming)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0102 |
| 类别/子类 | ①优化 / 整数规划 |
| 难度 | 中 |
| 适用题型关键词[] | 整数规划, MILP, branch-and-bound, Gomory割平面, 选址, 排程, 背包, 指派, 0-1规划, 设施选址, 生产调度, 车辆路径, 网络设计, 集合覆盖 |
| confidence | high |
| source | Wolsey (1998), Integer Programming, Wiley |

## 数学形式

MILP 标准型:

$$\min \; \mathbf{c}^T \mathbf{x}$$
$$\text{s.t.} \; \mathbf{A}\mathbf{x} \leq \mathbf{b}, \quad \mathbf{A}_{eq}\mathbf{x} = \mathbf{b}_{eq}$$
$$\mathbf{lb} \leq \mathbf{x} \leq \mathbf{ub}$$
$$x_i \in \mathbb{Z} \quad (\text{部分或全部变量为整数})$$

其中:
- 纯整数规划 (Pure IP): 所有决策变量取整数值
- 混合整数规划 (MILP): 部分变量为整数, 部分为连续
- 0-1 规划 (Binary IP): $x_i \in \{0, 1\}$

核心求解框架 — Branch-and-Bound (分支定界):
1. **LP Relaxation**: 松弛整数约束, 求解 LP, 得下界 (min 问题)
2. **Branching**: 选非整数变量 $x_i = \hat{x}_i \notin \mathbb{Z}$, 分两支 $x_i \leq \lfloor\hat{x}_i\rfloor$ 和 $x_i \geq \lceil\hat{x}_i\rceil$
3. **Bounding**: 若节点 LP 最优值 $\geq$ 当前上界, 剪枝 (prune)
4. **Cutting Planes (割平面)**: 在根节点或各节点加入 Gomory 割, 收紧 LP 松弛, 减少分支

Gomory 割平面: 从单纯形表的非整数行 $x_{B_i} + \sum_{j \in NB} \bar{a}_{ij} x_j = \bar{b}_i$ 构造有效不等式:
$$\sum_{j \in NB} (\bar{a}_{ij} - \lfloor\bar{a}_{ij}\rfloor) x_j \geq (\bar{b}_i - \lfloor\bar{b}_i\rfloor)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| f | double[] | — | 目标系数向量 | 高: 影响最优解方向 |
| intcon | int[] | — | 整数变量索引列表, 1:nvars 的子集 | 高: 决定问题难度 |
| A | double[,] | — | 不等式约束矩阵 | 中 |
| b | double[] | — | 不等式约束右端 | 中 |
| Aeq | double[,] | — | 等式约束矩阵 (可选) | 中 |
| beq | double[] | — | 等式约束右端 (可选) | 中 |
| lb | double[] | — | 下界向量 | 低: 默认0对Binary IP关键 |
| ub | double[] | — | 上界向量 | 低: 默认inf() |
| x0 | double[] | [] | 初始点 (可选) | 低: 仅加速, 不影响解 |
| options | optimoptions | — | 求解器选项 | 中: MaxTime, MaxNodes, RelativeGapTolerance |

**时间复杂度**: NP-hard. 最坏指数级 $O(2^n)$, 实际取决于整数变量数与 LP 松弛紧度.
**变量规模建议**: 整数变量 $\leq 200$, 0-1 变量 $\leq 500$.
**关键容差**: IntegerTolerance (默认 $10^{-6}$), RelativeGapTolerance (默认 $10^{-4}$).

## MATLAB 实现

```matlab
% === intlinprog 整数规划 ===
f = [ones(2,1)];           % 目标系数
intcon = 1:2;              % 整数变量索引
A = [1, 0; 0, 1; -1, -1];
b = [5; 5; -1];
lb = [1; 1];
ub = [inf; inf];

% 求解器选项
opts = optimoptions('intlinprog', ...
    'Display', 'iter', ...
    'MaxTime', 300, ...
    'RelativeGapTolerance', 1e-4);

[x, fval, exitflag, output] = intlinprog(f, intcon, A, b, [], [], lb, ub, opts);

% 0-1 规划: 设置 lb=zeros, ub=ones
% 逻辑约束编码:
% x1 => x2  编码为  x1 <= x2
% x1 XOR x2 编码为  x1 + x2 = 1
% 至少选k个  编码为  sum(x) >= k
```

## Python 备选

```python
# PuLP (推荐, 开源)
from pulp import *
prob = LpProblem("MILP", LpMinimize)
x = LpVariable.dicts("x", range(n), cat='Integer')
prob += lpSum(c[i]*x[i] for i in range(n))
prob.solve(PULP_CBC_CMD(msg=True))

# OR-Tools (Google, 高性能)
from ortools.linear_solver import pywraplp
solver = pywraplp.Solver.CreateSolver('SCIP')
# SCIP 比 CBC 快约 3~5x, 适合大规模 MILP

# Gurobi (商业, 需许可证, 学术免费)
# 速度通常比 intlinprog 快 5~50x
```

## 选型决策树

```
是否全部为线性?
├─ 否 → PARADIGM-0103 (NLP)
└─ 是 → 是否有整数约束?
    ├─ 否 → linprog (简单 LP)
    └─ 是 → 整数变量数量?
        ├─ ≤ 200 → intlinprog (MATLAB 内置)
        ├─ 200~1000 → Gurobi / OR-Tools SCIP
        └─ > 1000 → 考虑启发式 PARADIGM-0105/0106
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 建模 | 网络流图 / 选址方案图 | 展示决策变量与约束的物理含义 |
| 求解过程 | Branch-and-Bound 树 | 展示分支过程, 标注剪枝节点 |
| 结果分析 | 甘特图 (排程) / 地图散点图 (选址) | 可视化整数解的实际意义 |
| 对比分析 | 松弛LP vs 整数解 | 展示整数约束的代价 (integrality gap) |

## 常见坑

1. **整数约束忘记设置**: intlinprog 必须指定 `intcon`, 否则等价于 `linprog`, 结果为连续解
2. **LP 松弛 Gap 过大**: 对选址/排程类问题, 若松弛解与整数解差距大, B&B 搜索树爆炸. 对策: 加入紧割平面、自定义分支优先级
3. **0-1 约束未设置 ub=1**: 若只设 `lb=0` 不设 `ub=1`, 解可能 $x_i > 1$, 违反 0-1 语义
4. **逻辑约束线性化错误**: Big-M 法中 M 值过大导致数值不稳定, M 值过小则可能误剪可行解. $M = \max_i\{x_i^{ub}\} + 1$
5. **默认 IntegerTolerance 过松**: 某些问题 $10^{-6}$ 可能产生 $x_i = 3.0000000001$, 调小或后处理 `round(x)`

## 失效条件/反例 (强制小节)

- **条件1: 连续松弛 Gap 过大导致 B&B 搜索爆炸**. 当 LP 松弛的最优值与整数最优值差距过大 (如松弛解 0, 整数解 1000), Branch-and-Bound 树可能需要探索 $2^n$ 个节点. 典型场景: **大规模集合覆盖问题** (n > 100), LP 松弛的解全为分数且积分性间隙 (integrality gap) 极大. 判别: 求解根节点 LP 后检查 `output.numnodes`, 若 60s 内节点数 > $10^5$ 则宣告 B&B 不可行, 应换用列生成 (column generation) 或启发式方法 (PARADIGM-0105/0106).

- **条件2: 非线性目标/约束强制线性化导致模型严重失真**. 实际问题中目标函数若非线性 (如二次成本、分段定价、固定成本), 强行线性化后模型与原问题产生本质偏离. 典型场景: **投资组合优化** 中 $\min \mathbf{x}^T \Sigma \mathbf{x}$ 被线性化为 $\min \mathbf{c}^T \mathbf{x}$, 丢失了协方差结构和风险分散效应. 判别: 将线性化解的变量代入原始非线性目标, 计算相对误差. 若 >20%, 线性化不可接受, 应换用 PARADIGM-0103 (fmincon) 或 PARADIGM-0105 (GA) 直接处理非线性.

- **条件3: 大规模 0-1 变量时出现对称性问题**. 当多个 0-1 变量在约束和目标中完全对称 (如集装箱装载、考试排考), B&B 在各对称分支上重复等价搜索. 典型场景: **排考问题** 考场 1 和考场 2 完全等价, B&B 在 swap 对称解上消耗 90% 时间. 对策: 加入对称破缺约束 (symmetry breaking): $x_1 \geq x_2 \geq \cdots$ 或使用 Orbital Branching.

## 文献

1. Wolsey, L.A. (1998). *Integer Programming*. Wiley. — 整数规划经典教材, 覆盖 B&B、割平面、分解算法
2. Schrijver, A. (1998). *Theory of Linear and Integer Programming*. Wiley. — 理论与算法细节
3. Conforti, M., Cornuéjols, G., & Zambelli, G. (2014). *Integer Programming*. Springer. — 现代进阶教材
4. Nemhauser, G.L. & Wolsey, L.A. (1988). *Integer and Combinatorial Optimization*. Wiley.

## 来源溯源

- 数学: Dantzig (1947) 提出单纯形法 → Dantzig, Fulkerson & Johnson (1954) 用整数规划解 TSP → Gomory (1958) 割平面
- 算法: Land & Doig (1960) Branch-and-Bound → Balas (1965) 隐枚举法 (0-1 IP) → Karmarkar (1984) 内点法推进 LP 松弛
- MATLAB: intlinprog 始于 R2014a, 底层使用 CPLEX 衍生引擎

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前驱 — LP 基础 | PARADIGM-0101 (linprog) |
| 升级 — 非线性版本 | PARADIGM-0103 (fmincon) |
| 替代 — 大规模不可解时 | PARADIGM-0105 (GA) |
| 替代 — 大规模不可解时 | PARADIGM-0106 (PSO) |
| 特定应用 — TSP/VRP | PARADIGM-0114 (TS) |
