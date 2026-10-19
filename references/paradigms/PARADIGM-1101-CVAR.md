# PARADIGM-1101-CVAR CVaR: 条件风险价值优化⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1101-CVAR |
| 类别/子类 | ⑪鲁棒/随机优化 / 风险度量 |
| 难度 | 中 |
| 适用题型关键词[] | 风险管理, 尾部风险, 投资组合, 损失分布, 场景规划, 随机规划 |
| confidence | high |
| source | 论文2000_CVaR / 题解反推_RiskOpt类 |

## 数学形式

**CVaR (Conditional Value-at-Risk)** = 超过 VaR 的期望损失, 衡量尾部风险。

对于损失函数 $L(\mathbf{x}, \boldsymbol{\xi})$ (随机参数 $\boldsymbol{\xi}$), 在置信水平 $\alpha$ 下:

$$\text{CVaR}_\alpha(\mathbf{x}) = \mathbb{E}[L(\mathbf{x}, \boldsymbol{\xi}) \mid L(\mathbf{x}, \boldsymbol{\xi}) \geq \text{VaR}_\alpha(\mathbf{x})]$$

**Rockafellar-Uryasev 线性化 (场景离散化)**:
给定 $K$ 个等概率场景 $\boldsymbol{\xi}_1, \ldots, \boldsymbol{\xi}_K$:

$$\min_{\mathbf{x}, \zeta, \mathbf{z}} \quad \zeta + \frac{1}{(1-\alpha)K} \sum_{k=1}^{K} z_k$$

$$\text{s.t.} \quad z_k \geq L(\mathbf{x}, \boldsymbol{\xi}_k) - \zeta, \; z_k \geq 0, \; \forall k$$

$$\mathbf{x} \in \mathcal{X}$$

- $\zeta$: VaR 的近似值 (优化变量)
- $z_k$: 场景 $k$ 超过 VaR 的损失量

| 变量 | 含义 | 典型值 |
|------|------|--------|
| $\alpha$ | 置信水平 | 0.90, 0.95, 0.99 |
| $K$ | 场景数 | 1000-10000 |
| $\zeta$ | 辅助变量 (≈VaR) | 优化决定 |
| $z_k$ | 场景 $k$ 的尾部损失 | $\geq 0$ |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $\alpha$ (置信水平) | float | 0.95 | 0.80-0.99 | 高—$\alpha \uparrow$ 则更关注极端尾部 |
| 场景数 $K$ | int | 5000 | 1000-50000 | 中—越多越精确但求解成本高 |
| 损失函数形式 | — | 线性 (如组合损失) | 线性/凸分段/二次 | 中—线性用 LP, 凸用 QP/NLP |
| 场景生成方法 | enum | Monte Carlo | MC/Historical/LHS | 中—影响尾部覆盖 |

**复杂度**: 若损失线性 + 决策变量在线性约束中 → LP, $O((K + n_{\text{vars}})^3)$
**若损失凸**: 仍为凸优化, 可用 NLP 求解器

## MATLAB 实现

```matlab
% CVaR 优化 (线性损失, LP 解法)
% linprog + 自写场景生成

% 示例: 投资组合 CVaR 最小化
% 给定: 场景收益率 r_k (K × n_assets)
% 损失: L(x, ξ_k) = -r_k * x (负收益 = 损失)

K = 5000;      % 场景数
n = 10;        % 资产数
alpha = 0.95;

% 变量: [x(1:n); zeta; z(1:K)]
% 目标: min zeta + 1/((1-alpha)*K) * sum(z)
f = [zeros(n,1); 1; ones(K,1)/((1-alpha)*K)];

% 不等式约束: -r*x - zeta <= z_k
A = [-R_scenarios, -ones(K,1), -eye(K)];  % R: K×n
b = zeros(K,1);

% 等式约束: sum(x) = 1 (全投资)
Aeq = [ones(1,n), 0, zeros(1,K)];
beq = 1;

% 下界: x >= 0, z >= 0, zeta free
lb = [zeros(n,1); -inf; zeros(K,1)];

[x_opt, cvar] = linprog(f, A, b, Aeq, beq, lb, []);
% cvar 即为最优 CVaR
```

**锚点工具箱**: `linprog` (Optimization Toolbox)
**场景生成**: 自写 Monte Carlo / Historical Bootstrap (或 `mvnrnd` for 多元正态)

## Python 备选

```python
import numpy as np
from scipy.optimize import linprog

def cvar_optimization(R_scenarios, alpha=0.95):
    K, n = R_scenarios.shape
    # 变量: [x(n); zeta; z(K)]
    c = np.hstack([np.zeros(n), 1.0, np.ones(K) / ((1-alpha)*K)])
    # 约束: -R @ x - zeta <= z
    A_ub = np.hstack([-R_scenarios, -np.ones((K,1)), -np.eye(K)])
    b_ub = np.zeros(K)
    # x >= 0, z >= 0 (zeta free in bounds)
    bounds = [(0, None)]*n + [(None, None)] + [(0, None)]*K
    # sum(x) = 1
    A_eq = np.hstack([np.ones((1,n)), [[0]], np.zeros((1,K))])
    b_eq = [1.0]
    res = linprog(c, A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=b_eq, bounds=bounds)
    return res.x[:n], res.fun
```

备选: `cvxportfolio` (投资组合优化), `cvxpy` (凸优化框架)

## 选型决策树

- **尾部风险管理 (worst-case focus)** → CVaR (关注分布的尾部)
- **对称风险管理 (波动率)** → 均值-方差 (Markowitz, `quadprog` 求解) = 方差作为风险度量; CVaR 替代方差
- **风险 + 稳健 (分布不确定)** → 分布鲁棒优化 (DR-CVaR) 或鲁棒对应 (PARADIGM-1102)
- **多目标 (风险-收益)** → 求有效前沿: 变化 $\lambda$ 在 $\min$ 风险 $+ \lambda$ 收益 上
- **VaR vs CVaR**: VaR 简单但非凸、不连贯 (sub-additivity 不满足); CVaR 凸优化、一致性风险度量 → CVaR 理论上更优

## 典型图型

- **raw**: 损失分布直方图, VaR/CVaR 位置标记
- **process**: 有效前沿曲线 (CVaR vs 期望收益), 各场景的尾部损失 boxplot
- **result**: 最优配置权重饼图, VaR vs CVaR 比较柱状图, 滚动窗口 CVaR 时序

## 常见坑

1. **场景数 $K$ 不足**: 极端尾部场景少, $1-\alpha = 5\%$ 只有 $0.05K$ 个尾部场景用于估计 → $K \geq 5000$ 至少
2. **CVaR 对 VaR 的估计偏差**: 场景法的 CVaR 估计在 $\alpha$ 接近 1 时样本偏小不可靠 → 或用极值理论 (EVT) 修正尾部
3. **LP 变量爆炸**: $K=5000$ 场景 + $n=100$ 变量 → $K$ 个辅助变量 $z_k$ 加大 LP 规模 → 用列生成/随机分解, 或 $K=500` 并 放松尾部
4. **历史场景不代表未来**: 回测偏差 → 场景生成需反映合理压力情景

## 失效条件/反例 (强制小节)

- **条件1**: 场景数 $K < 100$ → 尾部仅 $5$ 个点 (若 $\alpha=0.95$), CVaR 估计方差极大, 优化所得的 $\zeta$ 几乎任意, 不可靠。**替代**: $K \geq 5000$ 场景, 或用极值理论 (EVT) 拟合尾部
- **条件2**: 损失函数高度非线性且非凸 → RK-Uryasev 线性化仅适用于凸损失函数; 非凸损失函数下 {z_k} 约束破坏了 CVaR 的凸性, LP 不可用。**替代**: 鲁棒对应 (PARADIGM-1102, 线性化假设), 或直接 NLP 求解 (自写 `fmincon`)
- **条件3**: 极端事件概率极小 ($\alpha = 0.999$) 且无历史数据 → 无足够极端场景填充尾部, 场景法 CVaR 严重依赖少数场景的选择。**替代**: EVT + 极值分布拟合, 或鲁棒对应 (worst-case bound)
- **条件4**: 决策变量仅含整数约束 (离散决策) → LP 失效, 需 MIP 求解; $K$ 个场景 + 整数变量使 MIP 规模巨大, 可能不可解。**替代**: 场景缩减 (聚类到少场景), 或拉格朗日松弛

## 文献

1. Rockafellar, R. T., & Uryasev, S. (2000). Optimization of conditional value-at-risk. *Journal of Risk*, 2(3), 21-41. DOI: [10.21314/JOR.2000.038](https://doi.org/10.21314/JOR.2000.038)
2. Rockafellar, R. T., & Uryasev, S. (2002). Conditional value-at-risk for general loss distributions. *Journal of Banking & Finance*, 26(7), 1443-1471. DOI: [10.1016/S0378-4266(02)00271-6](https://doi.org/10.1016/S0378-4266(02)00271-6)

## 来源溯源

- 论文三元组: Rockafellar 2000, CVaR, convex risk measure + LP formulation
- 教学用例: 投资组合优化, 供应链风险备货

## 关联范式卡

组合: PARADIGM-1102-ROBUST-COUNTERPART (CVaR + 鲁棒不确定性集)
替代: 均值-方差 (Markowitz), VaR (非凸, 差), PARADIGM-1103-CHANCE-CONSTRAINT (机会约束)
