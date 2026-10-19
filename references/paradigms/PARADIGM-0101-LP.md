# PARADIGM-0101 线性规划⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0101 |
| 类别/子类 | ①优化 / 线性规划 |
| 难度 | 低 |
| 适用题型关键词[] | 线性规划, 单纯形法, 内点法, 约束优化, 资源分配, 生产计划 |
| confidence | high |
| source | 教材第1章 / matlab/optim/linprog_wrapper.m |

## 数学形式

**标准型 (Standard Form):**

$$\begin{aligned}
\min \quad & \mathbf{c}^T \mathbf{x} \\
\text{s.t.} \quad & \mathbf{A}\mathbf{x} \leq \mathbf{b} \\
& \mathbf{x} \geq \mathbf{0}
\end{aligned}$$

**对偶问题 (Dual):**

$$\begin{aligned}
\max \quad & \mathbf{b}^T \mathbf{y} \\
\text{s.t.} \quad & \mathbf{A}^T \mathbf{y} \leq \mathbf{c} \\
& \mathbf{y} \geq \mathbf{0}
\end{aligned}$$

**变量表:**
- $\mathbf{x} \in \mathbb{R}^n$ — 决策变量
- $\mathbf{c} \in \mathbb{R}^n$ — 目标函数系数
- $\mathbf{A} \in \mathbb{R}^{m \times n}$ — 约束矩阵
- $\mathbf{b} \in \mathbb{R}^m$ — 右端常数
- $\mathbf{y} \in \mathbb{R}^m$ — 对偶变量/影子价格

**方法:** 单纯形法 (Simplex) 沿可行域顶点搜索；内点法 (Interior-point) 从内部逼近最优解。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| f (目标系数) | double[] | — | 实数 | 高 — c 变化直接影响最优解 |
| A (不等式约束) | double[,] | — | 实数矩阵 | 高 — 约束增减改变可行域 |
| b (不等式右端) | double[] | — | 实数 | 中 — 右端项变化平移约束边界 |
| Aeq (等式约束) | double[,] | [] | 实数矩阵 | 高 — 等式过约束导致不可行 |
| beq (等式右端) | double[] | [] | 实数 | 中 |
| lb (下界) | double[] | zeros(n,1) | 实数 | 低 — 通常 x≥0 |
| ub (上界) | double[] | Inf(n,1) | 实数 | 中 — 上界过紧限制可行域 |
| options.Algorithm | string | 'dual-simplex' | 'dual-simplex' / 'interior-point' | 中 — 大规模问题 interior-point 更快 |
| 时间复杂度 | — | — | O(n³) 最坏 (Simplex), O(n³.5) (IPM) | — |

## MATLAB 实现

函数签名:
```matlab
[x, fval, exitflag, output, lambda] = linprog_wrapper(f, A, b, Aeq, beq, lb, ub, options)
```

锚点: `matlab/optim/linprog_wrapper.m` — 封装 MATLAB Optimization Toolbox `linprog`，增加输入校验与中文错误提示。

- `exitflag=1` 收敛到最优解
- `exitflag=0` 达到最大迭代次数
- `exitflag<0` 问题不可行或无界
- `lambda` 返回 Lagrange 乘子 (影子价格)

## Python 备选

```python
from scipy.optimize import linprog
res = linprog(c, A_ub=A, b_ub=b, A_eq=Aeq, b_eq=beq,
              bounds=list(zip(lb, ub)), method='highs')
# res.x, res.fun, res.success
```

或使用 `pulp` 建模:
```python
import pulp as pl
prob = pl.LpProblem("LP", pl.LpMinimize)
x = [pl.LpVariable(f"x{i}", lowBound=0) for i in range(n)]
prob += pl.lpSum(c[i] * x[i] for i in range(n))
# ... 添加约束
prob.solve()
```

## 选型决策树

- **用 LP** — 目标函数和约束均为线性，变量连续
- **用 MILP (PARADIGM-0102)** — 存在整数变量 (如机器数量、选址0-1)
- **用 QP (PARADIGM-0103)** — 目标函数含二次项 $\mathbf{x}^T\mathbf{H}\mathbf{x}$
- **用 NLP (PARADIGM-0104)** — 目标或约束非线性 (如规模经济、指数衰减)
- **用 fmincon** — 一般非线性约束优化
- **Trade-off:** Simplex 对小规模 (n<1000) 稳定可靠；Interior-point 对大规模稀疏问题高效但可能返回边界附近非顶点解

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 约束可行域 2D/3D 图 (fill/patch) | 展示约束半平面交集，顶点标注 |
| process | 单纯形路径 (箭头线) | 从初始基可行解沿边走到最优顶点 |
| result | 柱状图 bar chart | 最优解各变量取值，影子价格对比 |

## 常见坑

1. **不可行约束 (Infeasibility):** 约束互相矛盾 → 可行域为空，`exitflag=-2`。排查: 检查是否有 a≤x≤b 且 b<a 的情况；松弛部分约束用大M法
2. **无界解 (Unbounded):** 缺少必要约束 → 目标可无限改进，`exitflag=-3`。排查: 是否忘记写 x≥0 或上界约束
3. **退化 (Degeneracy):** 多个约束交于一点 → Simplex 可能循环 (cycling)，使用 Bland 规则或扰动法
4. **量纲不一致:** 约束量级差异过大 (如 0.001 和 10000) → 数值不稳定，需先做 scaling
5. **等式约束过多:** 线性等式超定 → 可行域退化为低维子空间，注意 Aeq 秩检查

## 失效条件/反例 (强制小节)

- **条件1: 问题本质非线性 (如规模经济/边际递减)** → LP 线性假设给出错误最优解，真实最优可能位于可行域内部而非顶点。**表现:** 模型建议"全部资源集中分配给一个产品"，而实际最优应是分散分配 → 改用 fmincon 或建立非线性规划模型
- **条件2: 存在整数要求 (如机器台数、人员数量)** → LP 连续松弛给出分数解 (如 "生产 3.7 台机器") 在实际中无意义。**表现:** 取整后可能违反约束或远离最优 → 改用 intlinprog (MILP)

## 文献

1. Dantzig G.B. (1963) *Linear Programming and Extensions*. Princeton University Press. ISBN 978-0691059139
2. Vanderbei R.J. (2020) *Linear Programming: Foundations and Extensions*, 5th Edition. Springer. ISBN 978-3030394144

## 来源溯源

`matlab/optim/linprog_wrapper.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (整数变量) | PARADIGM-0102 (MILP) |
| 替代 (二次目标) | PARADIGM-0103 (QP) |
| 替代 (非线性) | PARADIGM-0104 (NLP) |
