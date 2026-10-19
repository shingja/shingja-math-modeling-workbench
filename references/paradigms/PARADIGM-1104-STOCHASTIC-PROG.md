# PARADIGM-1104 两阶段随机规划⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1104 |
| 类别/子类 | ⑪鲁棒优化进阶 / 随机规划 |
| 难度 | 高 |
| 适用题型关键词[] | 两阶段随机规划, 场景树, 期望值约束, 追索, linprog, 随机优化, Birge&Louveaux |
| confidence | medium |
| source | Birge & Louveaux (2011) Springer |

## 数学形式

**两阶段随机线性规划:**

$$\min_{\mathbf{x}} \; \mathbf{c}^T\mathbf{x} + \mathbb{E}_\xi[Q(\mathbf{x}, \xi)]$$
$$\text{s.t.} \; A\mathbf{x} = \mathbf{b}, \quad \mathbf{x} \geq 0$$

其中第二阶段追索函数:

$$Q(\mathbf{x}, \xi) = \min_{\mathbf{y}} \; \mathbf{q}(\xi)^T\mathbf{y}$$
$$\text{s.t.} \; W(\xi)\mathbf{y} = \mathbf{h}(\xi) - T(\xi)\mathbf{x}, \quad \mathbf{y} \geq 0$$

- $\mathbf{x}$ — 第一阶段决策 (here-and-now)
- $\mathbf{y}$ — 第二阶段追索决策 (wait-and-see)
- $\xi$ — 随机参数 (如需求、价格)
- $W$ — 追索矩阵

**场景近似 (S 个场景):**
$$\min_{\mathbf{x}, \mathbf{y}_s} \; \mathbf{c}^T\mathbf{x} + \sum_{s=1}^{S} p_s \cdot \mathbf{q}_s^T\mathbf{y}_s$$
$$\text{s.t.} \; A\mathbf{x} = \mathbf{b}, \quad T_s\mathbf{x} + W_s\mathbf{y}_s = \mathbf{h}_s \quad \forall s$$

**完整追索 (Complete Recourse):** $W$ 对任意右侧约束都有可行解。

**场景树生成:**
- Monte Carlo 抽样
- 场景缩减 (Kantorovich 距离 / 快速前向选择)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| S (场景数) | int | 100 | [10, 10000] | 极高 — S↑精度↑但LP变大 |
| 概率分布 | — | 正态/经验 | — | 高 |
| LP 变量数 | — | — | $n_x + S\cdot n_y$ | — |
| 复杂度 | — | — | LP O((n_x+S·n_y)³) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[x_opt, y_scenarios, obj_val] = two_stage_lp(c, q_s, A, b, T_s, W_s, h_s, p_s)
```

锚点: `linprog` (Optimization Toolbox) + 自写场景树-见S5:two_stage_lp.m

```matlab
% 构造扩展 LP
% 变量: [x; y_1; y_2; ...; y_S]
n_x = length(c); n_y = size(W_s, 2); S = length(p_s);
n_total = n_x + S * n_y;

% 目标: c'*x + sum_s p_s * q_s' * y_s
f = [c; kron(p_s, q_s(1,:)')];  % 简化，实际需按场景构建

% 约束: Ax=b (第一阶段)
% 以及 T_s*x + W_s*y_s = h_s 对所有 s
Aeq = [A, zeros(size(A,1), S*n_y); ...
       kron(ones(S,1), T_s(1,:)), blkdiag(W_s)];  % 简化
beq = [b; kron(ones(S,1), h_s)];

[x_sol, fval] = linprog(f, [], [], Aeq, beq, zeros(n_total,1));
x_opt = x_sol(1:n_x);
```

## Python 备选

```python
from scipy.optimize import linprog
# 或 Pyomo (支持随机规划扩展)
import pyomo.environ as pyo
# PySP: Pyomo Stochastic Programming
```

## 选型决策树

- **两阶段随机规划** — 第一阶段决策不可逆 (如建设投资)，第二阶段可调整 (如运营)
- **Chance Constraints (PARADIGM-1103)** — 约束的概率形式更直观时
- **Robust Optimization (PARADIGM-1102)** — 对分布未知 (最坏情况)，不依赖场景概率
- **多阶段随机规划** — >2 阶段决策序列 (用 SDDP 算法)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 场景树图 (节点+分支概率) | 多阶段展开 |
| result | x 最优值分布 (violin) | 不同场景的差异 |
| result | EVPI / VSS 条形图 | 随机解的价值 |

## 常见坑

1. **场景数爆炸**: 多阶段+多随机变量 → 10 变量×10 节点 = 10^10 场景。用场景缩减或 SDDP
2. **In-sample vs Out-of-sample**: 场景集拟合过度 → 保留测试场景评估真正的期望性能
3. **固定追索 vs 随机追索**: W 固定→ 问题保持 LP 结构; W 随机→ 变为更复杂的 Stochastic LP

## 失效条件/反例 (强制小节)

- **条件1: 随机变量维度 > 5 + 场景树生成** → 表现: 多维随机变量的联合分布难以离散化 — 每维 10 个节点 → 10^5 场景，LP 规模爆炸 10^5×n_y。**应对**: 使用 SDDP (Stochastic Dual Dynamic Programming) 处理多阶段+多维，或重要性采样缩减场景
- **条件2: 分布假设错误 → 追索决策在稀有事件中不可行** → 表现: 场景集中缺少极端事件 (tail events)，优化出的 x 在极端场景下第二阶段不可行 (无追索)。**应对**: 使用分布鲁棒优化 (PARADIGM-1105 Wasserstein DRO) 或极端场景压力测试

## 文献

1. Birge J.R. & Louveaux F. (2011). *Introduction to Stochastic Programming*, 2nd ed. Springer. ISBN: 978-1461402367
2. Shapiro A., Dentcheva D. & Ruszczynski A. (2009). *Lectures on Stochastic Programming*. SIAM. ISBN: 978-0898716870

## 来源溯源

linprog + 自写场景树 two_stage_lp.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-1102 (鲁棒对等) |
| 替代 | PARADIGM-1103 (机会约束) |
| 组合 | PARADIGM-1105 (Wasserstein DRO) |
