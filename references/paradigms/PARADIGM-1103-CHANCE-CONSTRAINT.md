# PARADIGM-1103-CHANCE-CONSTRAINT 机会约束规划⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1103-CHANCE-CONSTRAINT |
| 类别/子类 | ⑪鲁棒/随机优化 / 概率约束 |
| 难度 | 高 |
| 适用题型关键词[] | 概率约束, 可靠性优化, 随机规划, 置信水平, 机会约束 |
| confidence | medium |
| source | 论文1959_ChanceConstraint / 题解反推_StochProg类 |

## 数学形式

**机会约束规划 (Chance-Constrained Programming)**:

$$\min_{\mathbf{x}} f(\mathbf{x})$$
$$\text{s.t.} \quad \Pr[g_i(\mathbf{x}, \boldsymbol{\xi}) \leq 0] \geq 1 - \varepsilon_i, \quad i = 1, \ldots, m$$

其中 $\varepsilon_i$ 为允许的违背概率 (例如 $\varepsilon = 0.05 \rightarrow$ 95% 置信水平)。

**联合机会约束** (所有约束同时满足):
$$\Pr[g_i(\mathbf{x}, \boldsymbol{\xi}) \leq 0, \; \forall i] \geq 1 - \varepsilon$$

**线性机会约束的解析等价** ($\boldsymbol{\xi} \sim \mathcal{N}(\boldsymbol{\mu}, \boldsymbol{\Sigma})$):
$$\Pr[\boldsymbol{\xi}^T \mathbf{x} \leq b] \geq 1 - \varepsilon \iff \boldsymbol{\mu}^T \mathbf{x} + \Phi^{-1}(1-\varepsilon) \sqrt{\mathbf{x}^T \boldsymbol{\Sigma} \mathbf{x}} \leq b$$
其中 $\Phi^{-1}$ 为标准正态分位数

**场景法 (Monte Carlo 近似)**:
用 $K$ 个场景逼近: 约束 $g_i(\mathbf{x}, \boldsymbol{\xi}_k) \leq 0$ 应在至少 $(1-\varepsilon)K$ 个场景中满足

| 变量 | 含义 | 典型值 |
|------|------|--------|
| $1-\varepsilon$ | 置信水平 | 0.90, 0.95, 0.99 |
| $\boldsymbol{\xi}$ | 随机参数向量 | — |
| $\Phi^{-1}(1-\varepsilon)$ | 标准正态分位数 | 1.645 ($\varepsilon=0.05$) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $\varepsilon_i$ (允许违背概率) | float | 0.05 | 0.01-0.20 | 极高—更小更保守 |
| 随机参数分布假设 | enum | Normal | Normal/LogNormal/Uniform/Empirical | 高—决定等价形式 |
| 场景数 $K$ (场景法) | int | 10000 | 1000-50000 | 中 |
| 联合 vs 单个约束 | enum | 单个 | — | 中—联合更严格 |

**复杂度**: 场景法下变为确定性优化 (LP/NLP/MINLP), 场景数 = 约束数 $\times K$

## MATLAB 实现

```matlab
% 机会约束规划 + Monte Carlo 校验
% fmincon + 自写蒙特卡洛校验

% 自写-见S5:chance_constraint_opt.m

% 策略:
% 1. 生成 K 个随机参数场景 (基于假设分布)
% 2. 将机会约束转化为确定性约束:
%    - 对线性约束: 利用正态假设等价 (二阶锥)
%    - 对一般约束: 场景法 — 每个场景都加约束 (K巨大)
%    - 或: 使用采样平均近似 (SAA), 固定场景集优化
% 3. 用 fmincon 求解确定性等价问题
% 4. 后验验证: 用大量外样本验证实际满足概率

% 示例: 线性机会约束
% Pr(xi'x <= b) >= 1-eps, xi ~ N(mu, Sigma)
epsilon = 0.05;
z_eps = norminv(1 - epsilon);  % 1.645
% 确定性等价约束:
% mu'*x + z_eps * sqrt(x'*Sigma*x) <= b
% 这是一个二阶锥约束, fmincon 直接处理
```

**锚点工具箱**: `fmincon` (Optimization Toolbox), `linprog` (若线性等价)
**MC 校验**: 自写场景生成 + 计数

## Python 备选

```python
import numpy as np
from scipy.optimize import minimize
from scipy.stats import norm

def chance_constraint_opt(x0, fun, cons_scenarios, epsilon=0.05):
    """场景法机会约束优化"""
    K, m = cons_scenarios.shape
    min_satisfied = int((1 - epsilon) * K)
    
    def constraint_func(x):
        # 统计每个场景下约束违背数
        violations = np.sum(cons_scenarios(x) > 0)
        return min_satisfied - violations  # >= 0 表示满足机会约束
    
    cons = [{'type': 'ineq', 'fun': constraint_func}]
    res = minimize(fun, x0, constraints=cons, method='SLSQP')
    return res
```

备选: `cvxpy` (含概率约束建模), `PySP` (随机规划)

## 选型决策树

- **约束需概率保证 (以概率 $1-\varepsilon$ 满足)** → 机会约束规划
- **关注目标函数的不确定性** → CVaR (PARADIGM-1101), 或随机规划 with recourse
- **全免疫 + 无分布假设** → 鲁棒对应 (PARADIGM-1102)
- **$\boldsymbol{\xi}$ 有多元正态分布 + 约束线性** → 解析等价 (二阶锥), 精确求解
- **$\boldsymbol{\xi}$ 无参数分布 + 有历史数据** → 场景法 (SAA/场景规划)
- **联合机会约束 vs 单个**: 联合更严格 (所有约束同时满足) → 除非有理由放宽, 否则默认单个

## 典型图型

- **raw**: 随机参数分布 (直方图/密度图, 多条约束)
- **process**: 确定性等价 vs 场景法: 目标值对比, 可行域可视化 (2D)
- **result**: 验证: 外样本 Monte Carlo 违背率 vs 目标 $\varepsilon$; 保守/激进方案对比

## 常见坑

1. **正态假设不成立**: 若 $\boldsymbol{\xi}$ 实际为厚尾分布 (t分布, 对数正态), $\Phi^{-1}$ 分位数低估真实尾部 → 验证: 用经验分位数替代, 后验违反率
2. **场景法约束爆炸**: $K=10000$ 场景使问题 size 增加 $K$ 倍 → 用采样平均逼近 (SAA): 固定中等 $K$ 场景优化, 后验独立验证
3. **联合机会约束极难求解**: $m$ 个约束联合满足, 解析等价通常不存在 → 保守近似 (Bonferroni: $\varepsilon_i = \varepsilon / m$) 或场景法
4. **$\varepsilon$ 选择主观**: 取 $\varepsilon=0.05$ 无理由 → 敏感性: $\varepsilon = 0.01, 0.05, 0.10$, 比较解的代价和验证违背率

## 失效条件/反例 (强制小节)

- **条件1**: 随机参数分布完全未知 (仅有区间) → 机会约束需要概率模型; 没有分布信息则退化为鲁棒优化 (所有可能都满足)。**替代**: 鲁棒对应 (PARADIGM-1102, distribution-free)
- **条件2**: 约束数 $m > 50$ + 联合机会约束 → Bonferroni 近似 $\varepsilon_i = \varepsilon/m$ 极度保守, 而联合机会约束无法解析等价; 场景法的验证要求极高 ($K \gg m/\varepsilon$)。**替代**: 取最关键的 constraint 用机会约束, 其余用鲁棒盒式约束
- **条件3**: 约束高度非线性 + 分布非正态 + 无解析等价 → 场景法是唯一选择, 但需 $K$ 个 NLP 约束, 随 $K$ 增加求解困难。**替代**: 采用外部采样算法 (Augmented Probability Constraints), 或简化约束 (线性化/凸近似)
- **条件4**: $\varepsilon = 0$ (硬约束, 零容忍) → 机会约束退化为对所有可能实现的约束, 等效于鲁棒优化 (最坏情况)。若此时不确定性无边 → 无解。**替代**: 用 $\varepsilon$ 非零, 或鲁棒对应用有界不确定性集

## 文献

1. Charnes, A., & Cooper, W. W. (1959). Chance-constrained programming. *Management Science*, 6(1), 73-79. DOI: [10.1287/mnsc.6.1.73](https://doi.org/10.1287/mnsc.6.1.73)
2. Prekopa, A. (1995). *Stochastic Programming*. Springer. ISBN: 978-0-7923-3482-6.

## 来源溯源

- 论文三元组: Charnes 1959, chance-constrained programming, probabilistic constraints
- 教学用例: 水库调度 (入流不确定), 库存管理 (需求不确定)

## 关联范式卡

组合: PARADIGM-1101-CVAR (目标尾部风险 + 约束概率保证)
替代: PARADIGM-1102-ROBUST-COUNTERPART (无分布), 随机规划 with recourse
