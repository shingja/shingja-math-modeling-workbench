# PARADIGM-0701 蒙特卡洛模拟⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0701 |
| 类别/子类 | ⑦综合 / 随机模拟 |
| 难度 | 中 |
| 适用题型关键词[] | 蒙特卡洛, MCMC, Metropolis-Hastings, Gibbs采样, 随机模拟, 贝叶斯推断, 重要性采样, 高维积分, 后验采样 |
| confidence | high |
| source | 培训模块12 MCMC.mlx |

## 数学形式

**Monte Carlo 积分：**
$$\mathbb{E}[f(X)] = \int f(x)\pi(x)dx \approx \frac{1}{N}\sum_{i=1}^{N}f(X_i), \quad X_i \sim \pi(x)$$

**MCMC 细致平衡条件 (Detailed Balance)：**
$$\pi(x)Q(x \to y) = \pi(y)Q(y \to x)$$

**Metropolis-Hastings 接受率：**
$$\alpha(x \to y) = \min\left(1, \frac{\pi(y)Q(y \to x)}{\pi(x)Q(x \to y)}\right)$$

**Gibbs 采样：**
逐维条件采样 $$X_i^{(t+1)} \sim \pi\left(x_i \mid X_1^{(t+1)}, \ldots, X_{i-1}^{(t+1)}, X_{i+1}^{(t)}, \ldots, X_d^{(t)}\right)$$

**收敛诊断：**
- Gelman-Rubin $$\hat{R}$$：多链间方差与链内方差之比，$$\hat{R} < 1.01$$ 收敛
- 有效样本量 (ESS)：$$N_{\text{eff}} = \frac{N}{1 + 2\sum_{k=1}^{\infty}\rho_k}$$，其中 $$\rho_k$$ 为滞后 $$k$$ 自相关

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| target_pdf | 函数句柄 | — | 任意可归一化密度 | 极高 (定义目标) |
| proposal_pdf | 函数句柄 | Gaussian | 对称/非对称 | 高 (影响混合效率) |
| n_samples | 整数 | 10000 | [1000, 1e6] | 中 (精度 vs 计算成本) |
| burn_in | 整数 | n_samples/5 | [0, n_samples/2) | 高 (不足则后验污染) |
| thin | 整数 | 1 | [1, 100] | 中 (降低自相关) |
| n_chains | 整数 | 3 | [2, 8] | 中 (诊断用，R-hat 要求 ≥2) |
| proposal_scale | 浮点数 | 1.0 | [0.01, 10] | 高 (决定接受率 20%-50% 最优) |
| 维度 d | 整数 | — | [1, ~50] | 极高 (维数灾难影响效率) |

**计算复杂度：** $$O(N \cdot d)$$ 每链；高维 (d > 50) 下随机游走 MH 效率急剧下降。
**量纲：** 采样值继承 target 分布量纲；接受率无量纲 [0,1]；ESS 无量纲 (样本数等效)。

## MATLAB 实现

**函数签名：**
```matlab
[samples, accept_rate, diagnostics] = mcmc_sampler(target_pdf, proposal_pdf, ...
    n_samples, burn_in, thin, init, proposal_scale)
```

**MH 专用：**
```matlab
[samples, accept_rate] = metropolis_hastings(log_target, proposal_sd, ...
    n_samples, init)
```

**Gibbs 专用：**
```matlab
[samples] = gibbs_sampler(conditional_samplers, n_samples, burn_in, thin)
```

**收敛诊断：**
```matlab
[R_hat, ESS] = mcmc_diagnostics(chains)  % Gelman-Rubin + 有效样本量
```

锚点：自写 (培训模块12 MCMC.mlx)，依赖基础 MATLAB 无额外 Toolbox。

## Python 备选

**PyMC (概率编程，推荐)：**
```python
import pymc as pm
with pm.Model() as model:
    mu = pm.Normal('mu', mu=0, sigma=10)
    sigma = pm.HalfNormal('sigma', sigma=5)
    y = pm.Normal('y', mu=mu, sigma=sigma, observed=data)
    trace = pm.sample(2000, tune=1000, chains=4, target_accept=0.9)
```

**emcee (仿射不变系综采样器)：**
```python
import emcee
sampler = emcee.EnsembleSampler(nwalkers, ndim, log_prob_fn)
sampler.run_mcmc(initial_pos, n_steps, progress=True)
samples = sampler.get_chain(discard=burn_in, thin=thin, flat=True)
```

**Stan via cmdstanpy (HMC/NUTS，高维首选)：**
```python
import cmdstanpy
model = cmdstanpy.CmdStanModel(stan_file='model.stan')
fit = model.sample(data=input_data, chains=4, iter_sampling=2000)
```

## 选型决策树

- **目标分布低维 (d < 5)** + 可解析 → 用数值积分 (quadrature) 而非 MCMC
- **目标分布中维 (5 ≤ d ≤ 50)** + 无梯度信息 → MH/Gibbs (MATLAB 自写 或 Python emcee)
- **目标分布高维 (d > 50)** + 有梯度 → HMC/NUTS (Stan / PyMC)，随机游走 MH 效率太差
- **目标分布多峰 (multi-modal)** → 并行回火 (parallel tempering) 或 SMC
- **仅需近似后验** → 变分推断 (Variational Inference, PyMC 内置 ADVI) 替代 MCMC
- **贝叶斯模型含离散变量** → Gibbs 采样 (处理混合离散-连续) 或 NUTS 不支持时用 MH

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 目标分布等高线图 (2D) / 单变量边际曲线 | 展示采样目标形态 |
| process | Trace plot (采样轨迹) + 自相关函数 (ACF) + 运行均值收敛图 | 诊断混合与收敛 |
| result | 后验直方图 + 95% HDI 区间 + Gelman-Rubin R-hat 多链对比图 | 最终推断结果 |

## 常见坑

1. **混合不良 (Poor Mixing)**：链陷在局部模态，R-hat >> 1.01 — 用多链 + 分散初始点；调整 proposal_scale 使接受率在 20%-50%
2. **Burn-in 不足**：后验被初始瞬态污染 — 检查 trace plot 确定合适的 burn-in，一般取总迭代的 20%
3. **高自相关**：大量迭代但有效样本量极低 — 用 thinning (间隔采样) 或换更好的 proposal (如自适应 MH)
4. **多峰目标**：基本 MH 可能无法在模态间跳跃 — 用并行回火 (parallel tempering) 或增加 proposal 方差
5. **维度灾难**：d > 50 时随机游走 MH 探索空间效率 O(d²) 下降 — 必须换 HMC/NUTS

## 失效条件/反例 (强制小节)

- **条件1: 目标分布极高维 (d > 100) 且强相关** → 表现: 随机游走 MH 探索空间以 O(d²) 速度减慢，有效样本量趋近于零，trace 呈漂移而非快速混合。应改用 HMC/NUTS (Stan/PyMC) 或变分推断。
- **条件2: 目标存在孤立窄峰，模态间概率桥接近零** → 表现: 链永久陷入单一模态，R-hat 看似收敛 (单链内稳定) 但不同链困在不同模态，多链 R-hat 巨大。应改用并行回火 (parallel tempering) 或序贯蒙特卡洛 (SMC)。
- **条件3: 目标分布未归一化且积分未知 (常见于贝叶斯)** → 表现: 无法直接评估 π(x)，MH 用比值 π(y)/π(x) 规避，但 proposal 若不对称需计算 Q(x→y)/Q(y→x) 比率。若 Q 选择不当（如截断正态），接受率公式错误导致采样偏差。
- **条件4: 后验几乎无信息 (prior-dominated) 且样本量极小** → 表现: 后验与先验几乎一致，ESS 表面上足够但实际上没有学到数据信息，trace 看似收敛但参数不确定区间不随数据增加而缩小。

## 文献

1. Robert, C. P. & Casella, G. (2004). *Monte Carlo Statistical Methods*, 2nd ed. Springer. ISBN: 978-0387212398. DOI: 10.1007/978-1-4757-4145-2
2. Gelman, A., Carlin, J. B., Stern, H. S. & Rubin, D. B. (2013). *Bayesian Data Analysis*, 3rd ed. CRC Press. ISBN: 978-1439840955
3. Brooks, S., Gelman, A., Jones, G. L. & Meng, X.-L. (2011). *Handbook of Markov Chain Monte Carlo*. Chapman & Hall/CRC. ISBN: 978-1420079418

## 来源溯源

培训模块12 MCMC.mlx — 含 MH/Gibbs 完整实现与收敛诊断

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 组合 | PARADIGM-0501 (贝叶斯推断) | MCMC 是贝叶斯后验采样的核心工具 |
| 替代 | PARADIGM-0708 (系统动力学) | 确定性仿真 vs 随机采样，适用场景不同 |
| 替代 | PARADIGM-0706 (元胞自动机) | 离散规则演化 vs 连续分布采样 |
| 前置 | PARADIGM-0202 (概率分布) | 需理解目标分布与 proposal 分布 |
