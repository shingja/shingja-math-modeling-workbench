# PARADIGM-0115 目标规划Goal Programming⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0115 |
| 类别/子类 | ①优化 / 多目标决策 |
| 难度 | 低 |
| 适用题型关键词[] | 目标规划, Goal Programming, 多目标, fgoalattain, 偏差变量, Charnes&Cooper |
| confidence | high |
| source | Charnes & Cooper (1961) Wiley |

## 数学形式

**标准目标规划:**
$$\min \sum_{j=1}^{M} (w_j^+ d_j^+ + w_j^- d_j^-)$$
$$\text{s.t.} \; f_j(\mathbf{x}) + d_j^- - d_j^+ = g_j \quad \forall j$$
$$d_j^+, d_j^- \geq 0, \quad \mathbf{x} \in \mathcal{X}$$

- $g_j$ — 第 $j$ 个目标值 (Goal)
- $d_j^+, d_j^-$ — 正/负偏差变量
- $w_j^+$ — 超额偏差的惩罚权重
- $w_j^-$ — 不足偏差的惩罚权重

**目标达成法 (Goal Attainment Method, fgoalattain):**
$$\min_{\mathbf{x}, \lambda} \; \lambda$$
$$\text{s.t.} \; f_j(\mathbf{x}) - w_j\lambda \leq g_j \quad \forall j$$

- $\lambda$ — 目标达成松弛变量
- $w_j$ — 目标 $j$ 的相对重要度 (权重)

**优先级 (Preemptive/lexicographic Goal Programming):**
按优先级分层: 先最小化 $P_1$ 级偏差，固定后在满足 $P_1$ 约束下优化 $P_2$，依此类推。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| goals (g_j) | double[] | — | 各目标范围 | 极高 — 决定解的位置 |
| weights (w_j) | double[] | 等权 | ≥0 | 高 — 反映决策者偏好 |
| 目标函数形式 | — | 线性 | 线性/非线性 | — |

## MATLAB 实现

```matlab
% fgoalattain (目标达成法)
fun = @(x) [f1(x); f2(x); f3(x)];  % 多目标函数
x0 = [1; 1];
goal = [100; 50; 10];       % 目标值
weight = abs(goal);          % 权重 (通常取 |goal|)

[x_opt, fval, attainfactor] = fgoalattain(fun, x0, goal, weight, ...
    [], [], [], [], lb, ub, @nonlcon);

% attainfactor < 0 → 超额达成
% attainfactor = 0 → 恰好达成
% attainfactor > 0 → 未达成

% 自写目标规划 (线性加权偏差)
% min sum(w_p*d_plus + w_m*d_minus)
% s.t. f_j(x) + d_minus - d_plus = goal_j
% 构造为 LP 问题用 linprog 求解
```

锚点: `fgoalattain` (Optimization Toolbox)

## Python 备选

```python
from scipy.optimize import minimize
# 自建偏差变量 → NLP
import cvxpy as cp  # 凸目标规划用 CVXPY
```

## 选型决策树

- **目标规划** — 多目标有明确的目标值 (来自管理层/标准), 侧重"偏差最小化"
- **加权和优化** — 不需要目标值, 只需相对权重
- **TOPSIS** — 有限离散方案评价 (非连续优化)
- **ε-约束法 (PARADIGM-1211)** — 需要 Pareto 前沿而非单个折衷解
- **不要用 GP** — 目标值设定不合理时偏差主要由量纲差异决定

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 目标值 vs 单独最优值的对比表 | 展示目标可达性 |
| result | 各目标达成度雷达图 | 偏差可视化 |
| result | Pareto 前沿 + 目标点标记 | 最优解位置 |

## 常见坑

1. **目标值 (goal) 设定不当**: Goal 太野心 → 全部未达成; Goal 太低 → 无损失。应设在单独最优值和当前值的区间内
2. **量纲影响权重**: 若第1目标量纲 [0,1]，第2目标 [0,10000]，等权 w 导致 fgoalattain 被第2目标支配 → 权重应归一化: $w_j = 1/|g_j|$
3. **局部最优**: fgoalattain 在多峰目标下陷于局部最优 → 多起点或配合 GA

## 失效条件/反例 (强制小节)

- **条件1: 目标间存在强冲突 + 目标值位于不可达区域** → 表现: fgoalattain 的最小化 $\lambda$ 在目标冲突的所有方向上"拉扯"，结果对权重极度敏感 — 权重微小变化导致解在 Pareto 前沿上大幅跳跃。**应对**: 改用 ε-约束法 (固定一个目标，优化另一个) 生成 Pareto 前沿，从中人工/TOPSIS 选点
- **条件2: 线性 GP 中偏差变量和目标函数的量纲混合** → 表现: $f_1$(利润, 万元) 和 $f_2$(排放, 吨) 的 $d^+, d^-$ 不可直接加和 — min 万元 + 吨 无物理意义。**应对**: 对所有偏差变量做归一化: $d_j / g_j$ 或 $d_j / (f_j^{\max} - f_j^{\min})$

## 文献

1. Charnes A. & Cooper W.W. (1961). *Management Models and Industrial Applications of Linear Programming*. Wiley.
2. Ignizio J.P. (1985). *Introduction to Linear Goal Programming*. Sage. ISBN: 978-0803925649

## 来源溯源

MATLAB `fgoalattain`; 多目标优化教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-1211 (ε-约束法) |
| 替代 | PARADIGM-0302 (TOPSIS, 离散方案) |
| 前置 | PARADIGM-0101 (LP) |
