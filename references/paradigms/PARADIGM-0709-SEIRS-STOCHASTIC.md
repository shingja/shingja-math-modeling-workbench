# PARADIGM-0709 随机传染病模型SEIRS⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0709 |
| 类别/子类 | ⑦综合 / 传染病建模 |
| 难度 | 高 |
| 适用题型关键词[] | SEIRS, 随机传染病, 随机微分方程, 人口流动, 疫情预测, ode45, Gillespie, 分支过程 |
| confidence | medium |
| source | Allen (2010) Springer |

## 数学形式

**确定性 SEIRS (基线):**
$$\frac{dS}{dt} = -\beta \frac{SI}{N} + \omega R$$
$$\frac{dE}{dt} = \beta \frac{SI}{N} - \sigma E$$
$$\frac{dI}{dt} = \sigma E - \gamma I$$
$$\frac{dR}{dt} = \gamma I - \omega R$$

**基本再生数:**
$$R_0 = \frac{\beta}{\gamma}$$

**随机化方案 1 — SDE (环境噪声, 连续状态):**
$$dS = \left(-\beta\frac{SI}{N} + \omega R\right)dt + \eta_S dW_t$$

**随机化方案 2 — Gillespie 算法 (人口噪声, 离散状态):**
每个反应通道 $k$ 的倾向函数 $a_k$ 决定下一个反应时间:
$$\Delta t \sim \text{Exp}(\sum a_k), \quad \text{选择反应 } k \text{ 以概率 } \frac{a_k}{\sum a_j}$$

**随机化方案 3 — 参数随机化:**
$$\beta_t \sim \text{Lognormal}(\mu_\beta, \sigma_\beta^2)$$

**有效再生数 (时变):**
$$R_t = R_0 \cdot \frac{S(t)}{N}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| beta (传染率) | double | 0.3 | [0.01, 5] | 极高 — 决定 R₀ |
| sigma (潜伏率) | double | 1/5.2 | [1/14, 1] | 高 — 影响潜伏峰值 |
| gamma (恢复率) | double | 1/7 | [1/30, 1] | 高 — 影响持续期 |
| omega (免疫衰减) | double | 0 | [0, 0.1] | 中 — ω>0 允许重复感染 |
| noise_level | double | 0.01 | [0, 0.5] | 高 — 决定随机波动 |
| 求解方法 (SDE) | — | — | ode45+随机项 / Euler-Maruyama | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[t, S, E, I, R, R0] = seirs_stochastic(beta, sigma, gamma, omega, ...
    N, I0, tspan, noise_type, noise_level)
% noise_type: 'gillespie', 'sde', 'parametric'
```

锚点: `ode45` + 自写随机项-见S5:seirs_stochastic.m

```matlab
% SDE 方案: Euler-Maruyama
dt = 0.1;
t = tspan(1):dt:tspan(2);
n_steps = length(t);
S = zeros(n_steps,1); E = zeros(n_steps,1);
I = zeros(n_steps,1); R = zeros(n_steps,1);
S(1)=S0; E(1)=E0; I(1)=I0; R(1)=R0;

for k = 1:n_steps-1
    % 确定项 (ode45 右侧)
    dS_det = -beta*S(k)*I(k)/N + omega*R(k);
    dE_det = beta*S(k)*I(k)/N - sigma*E(k);
    dI_det = sigma*E(k) - gamma*I(k);
    dR_det = gamma*I(k) - omega*R(k);
    
    % 随机项 (SDE)
    dW = sqrt(dt) * randn;
    S(k+1) = S(k) + dS_det*dt + noise_level*S(k)*dW;
    % ... 其他仓室
end
```

## Python 备选

```python
from scipy.integrate import solve_ivp
import numpy as np

# Gillespie 用 GillesPy2
import gillespy2
```

## 选型决策树

- **确定性 SEIR (PARADIGM-0804)** — 大人口 (N > 10^6)，随机涨落可忽略
- **SDE 方案** — 环境噪声/参数不确定性主导
- **Gillespie** — 小人口 (N < 1000)，离散个体事件重要
- **Agent-Based Model (ABM)** — 个体异质性 (年龄/空间分布) 关键

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | I(t) 多条随机轨迹 (spaghetti plot) | 展示不确定性区间 |
| result | I 峰值分布直方图 | 多次模拟的峰值统计 |
| result | R_t 时效曲线 | 干预效果评估 |

## 常见坑

1. **确定性模型与随机模型的峰值差异**: 确定性模型给出唯一峰值；但随机模拟的峰值分布可能严重偏斜 (正偏) — 平均值 > 确定性预测
2. **Gillespie 在大人口下极慢**: O(事件数) — N=10^6 时数百万事件，一天都跑不完 → 用 tau-leaping 近似
3. **SDE 的负值截断**: Euler-Maruyama 可能产生负人口 → 需反射边界或 log 变换

## 失效条件/反例 (强制小节)

- **条件1: 人口异质性极大 (超级传播者事件)** → 表现: 均质混合假设 ($\beta SI/N$) 忽略了传播的异质性 — 少数个体贡献绝大多数传播，均质模型低估疫情峰值和方差。**应对**: 引入网络模型 (根据度分布分配传播率) 或负二项传播核 (Over-dispersion parameter $k$)
- **条件2: 干预措施时变 (封城/口罩/疫苗动态)** → 表现: $\beta$ 和 $\gamma$ 在疫情不同阶段变化剧烈 — 固定参数的 SEIRS 预测严重失真。**应对**: 使用分段 $\beta(t)$ 函数 (sigmoid/step) 或贝叶斯时变参数推断

## 文献

1. Allen L.J.S. (2010). *An Introduction to Stochastic Processes with Applications to Biology*, 2nd ed. Springer. ISBN: 978-1439818824
2. Anderson R.M. & May R.M. (1991). *Infectious Diseases of Humans: Dynamics and Control*. Oxford University Press. ISBN: 978-0198540403

## 来源溯源

ode45 + 自写随机项 seirs_stochastic.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0804 (SEIR) |
| 前置 | PARADIGM-0810 (SIR扩展) |
| 组合 (参数估计) | PARADIGM-0614 (MCMC) |
