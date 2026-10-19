# PARADIGM-0614 MCMC/Gibbs采样⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0614 |
| 类别/子类 | ⑥机器学习 / 随机采样 |
| 难度 | 高 |
| 适用题型关键词[] | MCMC, Gibbs采样, Metropolis-Hastings, 后验采样, 贝叶斯推断, 参数估计, 随机模拟 |
| confidence | high |
| source | Metropolis et al. (1953) J Chem Phys |

## 数学形式

**Metropolis-Hastings:**
1. 从 proposal $Q(y \mid x^{(t)})$ 抽样候选 $y^*$
2. 计算接受率: $\alpha = \min\left(1, \frac{\pi(y^*)Q(x^{(t)} \mid y^*)}{\pi(x^{(t)})Q(y^* \mid x^{(t)})}\right)$
3. 以概率 $\alpha$ 接受: $x^{(t+1)} = y^*$; 否则 $x^{(t+1)} = x^{(t)}$

**Gibbs Sampling (MH 特例):**
逐维从条件分布采样:
$$x_i^{(t+1)} \sim \pi(x_i \mid x_1^{(t+1)}, \ldots, x_{i-1}^{(t+1)}, x_{i+1}^{(t)}, \ldots, x_d^{(t)})$$

**收敛诊断 (Gelman-Rubin $\hat{R}$):**
$$\hat{R} = \sqrt{\frac{\hat{V}}{W}}$$, 其中 $\hat{V}$ = 链间方差，$W$ = 链内方差。$\hat{R} < 1.01$ 表明收敛。

**有效样本量 ESS:**
$$N_{\text{eff}} = \frac{N}{1 + 2\sum_{k=1}^{\infty}\rho_k}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_samples | int | 10000 | [1000, 1e6] | 中 — 精度 vs 成本 |
| burn_in | int | 2000 | [0, n/2] | 高 — 不足则污染 |
| thin | int | 1 | [1, 100] | 中 — 降低自相关 |
| proposal_scale | double | 1.0 | [0.01, 10] | 极高 — 决定接受率 |

## MATLAB 实现

函数签名 (自写):
```matlab
[samples, accept_rate, R_hat] = mcmc_sampler(target_logpdf, ...
    proposal_sampler, n_samples, burn_in, thin, init)
% Gibbs 专用
[samples] = gibbs_sampler(conditional_samplers, n_samples, burn_in)
```

锚点: 自写-见S5:mcmc_sampler.m, gibbs_sampler.m

## Python 备选

```python
import pymc as pm
with pm.Model() as model:
    mu = pm.Normal('mu', 0, 10)
    y = pm.Normal('y', mu, 1, observed=data)
    trace = pm.sample(2000, tune=1000, chains=4)
```

## 选型决策树

- **Gibbs** — 条件分布已知且有解析形式 (如共轭先验)
- **MH** — 条件分布无解析形式，可设计 proposal
- **HMC/NUTS** — 高维 (d > 50) + 梯度可用
- **重要性采样** — 不需要 MCMC 链，样本独立但高维效率低

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | Trace plot + 自相关图 | 诊断混合 |
| result | 后验直方图 + 95% HDI | 参数推断 |

## 常见坑

1. **Proposal Scale**: 太小 → 接受率高但混合慢; 太大 → 拒绝率高。最优接受率: 23.4% (随机游走 MH 高维)
2. **Burn-in 不足**: 初始瞬态污染后验 → 多链 trace plot 判别
3. **多峰目标**: 基本 MH 困在单峰 → 并行回火 (Parallel Tempering)

## 失效条件/反例 (强制小节)

- **条件1: 高维强相关 (d > 100) 随机游走 MH** → 表现: 探索空间以 O(d²) 减速，有效样本量接近零，trace 漂移而非混合。**应对**: 使用 HMC/NUTS (Stan/PyMC) 利用梯度信息
- **条件2: 多峰间概率桥为零 (模态隔离)** → 表现: 不同链收敛到不同模态，$\hat{R}$ 极大 — 看似"未收敛"实则各链困在各自模态。**应对**: 并行回火 (Parallel Tempering) 在不同温度间跳跃

## 文献

1. Metropolis N., Rosenbluth A.W., Rosenbluth M.N., Teller A.H. & Teller E. (1953). "Equation of state calculations by fast computing machines." *J Chemical Physics*, 21(6):1087-1092. DOI: [10.1063/1.1699114](https://doi.org/10.1063/1.1699114)
2. Gelman A. et al. (2013). *Bayesian Data Analysis*, 3rd ed. CRC Press. ISBN: 978-1439840955

## 来源溯源

自写 mcmc_sampler.m / gibbs_sampler.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (主题模型) | PARADIGM-0613 (LDA) |
| 替代 (确定性) | PARADIGM-0708 (系统动力学) |
| 详细版 | PARADIGM-0701 (MCMC蒙特卡洛) |
