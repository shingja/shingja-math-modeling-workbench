# PARADIGM-1105 Wasserstein分布鲁棒优化⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1105 |
| 类别/子类 | ⑪鲁棒优化进阶 / 分布鲁棒 |
| 难度 | 高 |
| 适用题型关键词[] | Wasserstein DRO, 分布鲁棒优化, 最优传输, 数据驱动, 模糊集, 鲁棒对等 |
| confidence | medium |
| source | Mohajerin Esfahani & Kuhn (2018) Math Prog |

## 数学形式

**分布鲁棒优化 (DRO) 框架:**
$$\min_{\mathbf{x} \in \mathcal{X}} \; \sup_{P \in \mathcal{P}} \; \mathbb{E}_P[\ell(\mathbf{x}, \xi)]$$

其中 $\mathcal{P}$ 为分布模糊集 (Ambiguity Set)。

**Wasserstein 模糊集:**
$$\mathcal{P} = \{P : W_p(P, \hat{P}_N) \leq \varepsilon\}$$

**Wasserstein 距离 (p=1 或 p=2):**
$$W_p(P, Q) = \left(\inf_{\pi \in \Pi(P,Q)} \int \|\xi - \zeta\|^p d\pi(\xi, \zeta)\right)^{1/p}$$

其中 $\Pi(P,Q)$ 为具有边缘分布 P 和 Q 的所有联合分布的集合。

**关键性质:**
- $\varepsilon = 0 \to$ 退化为经验分布 SAA (Sample Average Approximation)
- $\varepsilon \to \infty \to$ 退化为最坏情况鲁棒优化

**线性规划对等问题 (p=1, 仿射决策规则):**

Wasserstein DRO 可等价转化为有限维凸规划 (LP/SOCP)。对于特定损失函数类，鲁棒对等问题为:

$$\min_{\mathbf{x}, \lambda, s_i} \lambda\varepsilon + \frac{1}{N}\sum_{i=1}^{N} s_i$$
$$\text{s.t.} \; \sup_{\xi} \{\ell(\mathbf{x}, \xi) - \lambda\|\xi - \hat{\xi}_i\|\} \leq s_i$$

**有限样本保证 (Finite Sample Guarantee):**
若真实分布有界支撑且 $\varepsilon_N \sim O(N^{-1/\max\{d,2\}})$，则
$$P(\text{真实期望} \leq \text{DRO最优值}) \geq 1 - \beta$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| epsilon (Wasserstein 半径) | double | — | [0, ∞) | 极高 — 保守度 |
| p (Wasserstein 阶数) | int | 1 | 1,2 | 中 |
| N (样本数) | int | — | [10, ∞) | 高 — ε ∝ 1/√N |
| 复杂度 | — | — | LP大小∝ N | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[x_opt, worst_obj] = wasserstein_dro(Xi_hat, loss_fn, epsilon, p, n_vars)
```

锚点: 自写-见S5:wasserstein_dro.m

**核心思路:**
```matlab
% 对于线性损失 ℓ(x,ξ) = -ξ'x 的 newsvendor DRO
% 等价 LP 构造:
N = size(Xi_hat, 1);
% 变量: x, lambda, s_i
f = [cost_vec; epsilon; ones(N,1)/N];
% 约束: 对偶范数条件 sup_ξ { -ξ'x - λ||ξ-ξ̂_i|| } ≤ s_i
% → s_i ≥ -ξ̂_i'x + (||x||_* ≤ λ) 的对偶条件
% ...
[x_sol, fval] = linprog(f, A, b, Aeq, beq, lb, ub);
```

## Python 备选

```python
# CVXPY (凸优化)
import cvxpy as cp
# 或 RSOME (Robust Stochastic Optimization Made Easy)
from rsome import dro
```

## 选型决策树

- **Wasserstein DRO** — 有独立同分布样本，分布未知但一定接近经验分布
- **Moment-based DRO** — 仅知道均值和方差 (矩信息)
- **Phi-divergence DRO** — 基于似然比的模糊集 (如 KL-divergence ball)
- **经典鲁棒优化 (PARADIGM-1102)** — 仅知参数的不确定集 (区间/椭球)，不涉及分布

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 经验分布直方图 + Wasserstein ball 示意 | 模糊集可视化 |
| result | Out-of-sample 性能 vs ε 曲线 | 选择最佳 ε |
| result | DRO vs SAA vs Robust 对比 | 三种方法在测试集上的性能 |

## 常见坑

1. **ε 的选择**: 过小 → 退化为 SAA (无鲁棒性); 过大 → 过于保守 (代价远超实际风险)。用 k-fold 交叉验证或理论公式 $\varepsilon = D\sqrt{\frac{2}{N}\log\frac{1}{\beta}}$
2. **Wasserstein 的 curse of dimensionality**: 收敛速率 $\sim N^{-1/d}$ → d>10 时需要极大 N → 降维后使用
3. **计算复杂度**: 等价 LP/SOCP 的变量和约束数 ∝ N → N>10000 时求解困难

## 失效条件/反例 (强制小节)

- **条件1: 维度 d > 20 + 样本 N < 100** → 表现: Wasserstein ball 半径 $\varepsilon \propto N^{-1/d}$ 在高维下极大 → DRO 的模糊集几乎包含所有分布，优化在最坏分布下 ≈ 最坏情况鲁棒解 (极度保守)。**应对**: 先用 PCA 降维至 d<5，或改用矩约束 DRO (维度鲁棒)
- **条件2: 数据含离群点 (非 IID)** → 表现: Wasserstein 距离对离群点敏感 — 单个极端样本被赋予与正常样本相同的权重 1/N，拉动整个模糊集 → DRO 优化出过度保护离群点的解。**应对**: 先做离群点检测剔除，或使用 Wasserstein DRO 的鲁棒变种 (Median-of-Means DRO)

## 文献

1. Mohajerin Esfahani P. & Kuhn D. (2018). "Data-driven distributionally robust optimization using the Wasserstein metric: performance guarantees and tractable reformulations." *Mathematical Programming*, 171(1-2):115-166. DOI: [10.1007/s10107-017-1172-1](https://doi.org/10.1007/s10107-017-1172-1)
2. Gao R. & Kleywegt A.J. (2023). "Distributionally robust stochastic optimization with Wasserstein distance." *Mathematics of Operations Research*, 48(2):603-655.

## 来源溯源

自写 wasserstein_dro.m; 需 linprog 或 fmincon

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-1102 (鲁棒对等) |
| 替代 | PARADIGM-1103 (机会约束) |
| 替代 | PARADIGM-1104 (随机规划) |
