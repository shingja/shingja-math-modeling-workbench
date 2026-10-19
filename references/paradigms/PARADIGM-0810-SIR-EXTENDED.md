# PARADIGM-0810 SIR扩展(带出生/死亡/季节)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0810 |
| 类别/子类 | ⑧机理建模与PDE / 传染病动力学 |
| 难度 | 中 |
| 适用题型关键词[] | SIR扩展, 出生死亡, 季节传播, 基本再生数, 地方病, ode45, 疫苗接种, Anderson&May |
| confidence | high |
| source | Anderson & May (1991) Oxford |

## 数学形式

**SIR 带出生和死亡 (人口动态):**
$$\frac{dS}{dt} = \mu N - \beta \frac{SI}{N} - \mu S$$
$$\frac{dI}{dt} = \beta \frac{SI}{N} - \gamma I - \mu I$$
$$\frac{dR}{dt} = \gamma I - \mu R$$

其中 $\mu$ 为出生率 (= 死亡率, 保持总人口恒定)。

**基本再生数:**
$$R_0 = \frac{\beta}{\gamma + \mu}$$

**地方病平衡 (Endemic Equilibrium):**
$$S^* = \frac{N}{R_0}, \quad I^* = \frac{\mu N}{\beta}(R_0 - 1)$$

**带季节性 (季节性传播率):**
$$\beta(t) = \beta_0(1 + \beta_1 \cos(2\pi t / T))$$

其中 $T=365$ (天) 或 $T=12$ (月)。

**带疫苗接种:**
$$\frac{dS}{dt} = \mu N - \beta \frac{SI}{N} - (\mu + \nu)S, \quad \nu=\text{接种率}$$
临界接种覆盖: $p_c = 1 - 1/R_0$

**带年龄结构:**
$$\frac{\partial S(a,t)}{\partial t} + \frac{\partial S(a,t)}{\partial a} = -\lambda(a,t)S(a,t) - \mu(a)S(a,t)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| beta0 | double | 0.3 | [0.01,5] | 极高 — R₀∝β |
| gamma | double | 1/7 | [1/30,1] | 高 |
| mu | double | 1/(70*365) | [0,0.1] | 中 — mu<<gamma时近似守恒 |
| nu (接种率) | double | 0 | [0,1] | 高 — ν>pc 消除传播 |
| beta1 (季节振幅) | double | 0 | [0,0.5] | 高 — 引入周期解 |

## MATLAB 实现

```matlab
% SIR 带人口动态
sir_bd = @(t, y, beta, gamma, mu, N) [
    mu*N - beta*y(1)*y(2)/N - mu*y(1);
    beta*y(1)*y(2)/N - gamma*y(2) - mu*y(2);
    gamma*y(2) - mu*y(3)
];

% 带季节
beta_seasonal = @(t) beta0 * (1 + beta1 * cos(2*pi*t/365));
sir_season = @(t, y) [
    mu*N - beta_seasonal(t)*y(1)*y(2)/N - mu*y(1);
    beta_seasonal(t)*y(1)*y(2)/N - gamma*y(2) - mu*y(2);
    gamma*y(2) - mu*y(3)
];

[t, y] = ode45(sir_season, [0, 3650], [N-1; 1; 0]);
I = y(:,2);

% 寻找地方病平衡
S_star = N / R0;
I_star = mu*N/beta0 * (R0 - 1);
```

锚点: `ode45` (MATLAB内置)

## Python 备选

```python
from scipy.integrate import solve_ivp
sir_season = lambda t, y: [
    mu*N - beta0*(1+b1*np.cos(2*np.pi*t/365))*y[0]*y[1]/N - mu*y[0],
    beta0*(1+b1*np.cos(2*np.pi*t/365))*y[0]*y[1]/N - gamma*y[1] - mu*y[1],
    gamma*y[1] - mu*y[2]
]
```

## 选型决策树

- **SIR 基础** — 不考虑出生/死亡/季节 → 只有一次爆发
- **SIR + 人口动态** — 长期模拟 (数年-数十年)，需考虑人口更替 → 产生地方病平衡
- **SIR + 季节** — 流感/手足口等季节性明显 → 周期爆发
- **SEIRS (PARADIGM-0805)** — 有潜伏期+免疫衰减 → 更完整

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | I(t) 长时序 (含季节周期) | 展示定期爆发 |
| result | S-I 相平面 (多轨道→螺旋向平衡) | 展示阻尼震荡 |
| result | R₀ 与 I* 关系图 | 疫苗接种阈值标注 |

## 常见坑

1. **mu 选择不当**: mu 太小 (如10^-9) 时人口动态几乎无影响 → 退化为标准 SIR
2. **季节性频率共振**: 季节频率与系统自然频率 (≈1/γ) 接近时共振放大 → 与观测的真实爆发周期比较
3. **确定性 vs 随机**: 小人口时确定性方程失准 → Gillespie 仿真更合适 (PARADIGM-0709)

## 失效条件/反例 (强制小节)

- **条件1: 群体异质性 (年龄/社交网络) 主导传播** → 表现: 均质混合假设 $\beta SI/N$ 忽略了接触模式的社会结构 → 疫苗临界覆盖 $p_c$ 在年龄结构人群中与均质预测差 >10%。**应对**: 用年龄分层模型 (WAIFW 接触矩阵) 或网络传染病模型
- **条件2: 干预措施时效 (封城/社交距离动态)** → 表现: 固定参数的 SIR 在干预实施后预测完全不可靠 — 需要分段或连续变化的 $\beta(t)$。**应对**: 用分段常数 $\beta$ (按干预阶段) 或贝叶斯时变 $\beta_t$ 推断 (EpiEstim 框架)

## 文献

1. Anderson R.M. & May R.M. (1991). *Infectious Diseases of Humans: Dynamics and Control*. Oxford University Press. ISBN: 978-0198540403
2. Keeling M.J. & Rohani P. (2008). *Modeling Infectious Diseases in Humans and Animals*. Princeton University Press. ISBN: 978-0691116174

## 来源溯源

ode45; 传染病动力学经典教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0804 (SEIR) |
| 前置 | PARADIGM-0805 (SEIRS疫苗) |
| 随机版 | PARADIGM-0709 (SEIRS随机) |
