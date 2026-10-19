# PARADIGM-0805 SEIRS+疫苗接种/时滞SIR⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0805 |
| 类别/子类 | ⑧机理建模 / 传染病动力学 |
| 难度 | 中 |
| 适用题型关键词[] | SEIRS模型, 疫苗接种, 时滞, 免疫力衰退, 脉冲接种, 周期性爆发, 疾病控制 |
| confidence | high |
| source | MATLAB ode45 + 自写-见S5:seirs_vaccine.m |

## 数学形式

### SEIRS 模型 (免疫力衰退)

$$\frac{dS}{dt} = -\frac{\beta S I}{N} + \omega R$$

$$\frac{dE}{dt} = \frac{\beta S I}{N} - \sigma E$$

$$\frac{dI}{dt} = \sigma E - \gamma I$$

$$\frac{dR}{dt} = \gamma I - \omega R$$

其中 $\omega$ 为免疫力衰退率 (平均免疫持续期 = $1/\omega$)。

### 连续疫苗接种

$$\frac{dS}{dt} = -\frac{\beta S I}{N} - v S + \omega R$$

$$\frac{dR}{dt} = \gamma I + v S - \omega R$$

其中 $v$ 为连续接种率。

### 脉冲接种 (Impulsive Vaccination)

在离散时刻 $t_k$ 将易感者按比例 $p$ 转移至康复仓室:

$$S(t_k^+) = (1-p) \cdot S(t_k^-)$$

$$R(t_k^+) = R(t_k^-) + p \cdot S(t_k^-)$$

### 群体免疫阈值 (Herd Immunity Threshold)

$$p_c = 1 - \frac{1}{R_0}$$

当疫苗接种覆盖率 $> p_c$ 时，传播无法持续。

### 时滞 SIR 模型 (Delay Differential Equation)

$$\frac{dS}{dt} = -\frac{\beta S(t) I(t-\tau)}{N}$$

$$\frac{dI}{dt} = \frac{\beta S(t) I(t-\tau)}{N} - \gamma I$$

其中 $\tau$ 为时滞参数。当 $\tau$ 足够大时，Hopf 分岔导致持续的周期性振荡。

### 季节性传播率

$$\beta(t) = \beta_0 \left(1 + \alpha \cos\frac{2\pi t}{365}\right)$$

其中 $\alpha \in (0,1)$ 为季节性振幅。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| β₀ (base transmission rate) | scalar | 0.3 | (0, ∞) day⁻¹ | 极高 — R₀ ∝ β₀ |
| σ (incubation rate) | scalar | 1/5.2 | (0, ∞) day⁻¹ | 高 |
| γ (recovery rate) | scalar | 1/14 | (0, ∞) day⁻¹ | 高 |
| ω (waning immunity rate) | scalar | 1/365 | (0, 1) day⁻¹ | 中 — ω=0 退化为 SEIR |
| v (continuous vaccination rate) | scalar | 0 | [0, 1] day⁻¹ | 中 |
| p (pulse vaccination fraction) | scalar | 0 | [0, 1] | 高 — 决定是否达群体免疫 |
| t_k (pulse times vector) | vector | [] | (0, T) day | 中 — 脉冲频率影响控制效果 |
| α (seasonality amplitude) | scalar | 0 | [0, 1) | 中 — 引发年度双峰 |
| τ (time delay) | scalar | 0 | (0, ∞) day | 极高 — 大 τ 引发 Hopf 分岔 |
| N (total population) | scalar | 10⁶ | (0, ∞) | 低 |

| 输出 | 量纲 |
|------|------|
| y(:,1:4) = S,E,I,R | 人数 |
| R_eff(t) = R₀ · S(t)/N | 无量纲 |
| 累计接种人数 | 人数 |
| 流行最终规模 (Final size) | 人数/比例 |

**计算复杂度**: 普通 ODE < 0.1s; DDE 约 O(T/τ·N_grid) 取决于历史函数分辨率; 脉冲 ODE 与事件检测有关。

## MATLAB 实现

**SEIRS + 连续疫苗接种** (自写-见S5:seirs_vaccine.m):

```matlab
function dydt = seirs_vaccine_ode(~, y, beta, sigma, gamma, omega, v, N)
    S = y(1); E = y(2); I = y(3); R = y(4);
    dydt = zeros(4,1);
    dydt(1) = -beta * S * I / N - v * S + omega * R;
    dydt(2) =  beta * S * I / N - sigma * E;
    dydt(3) =  sigma * E - gamma * I;
    dydt(4) =  gamma * I + v * S - omega * R;
end

% 主求解
[t, y] = ode45(@(t,y) seirs_vaccine_ode(t, y, beta, sigma, gamma, omega, v, N), ...
               tspan, [S0; E0; I0; R0]);
```

**脉冲接种**: 使用 `ode45` 配合事件检测或手动分段积分。

```matlab
% 分段积分法
t_all = []; y_all = [];
y_current = [S0; E0; I0; R0];
t_start = 0;
for k = 1:length(pulse_times)
    t_k = pulse_times(k);
    [t_seg, y_seg] = ode45(@(t,y) seirs_vaccine_ode(t,y,beta,sigma,gamma,omega,0,N), ...
                           [t_start, t_k], y_current);
    t_all = [t_all; t_seg(1:end-1)]; y_all = [y_all; y_seg(1:end-1,:)];
    % 施加脉冲
    y_current = y_seg(end,:)';
    y_current(1) = (1 - p) * y_current(1);  % S → (1-p)S
    y_current(4) = y_current(4) + p * y_seg(end,1);  % R → R + p·S
    t_start = t_k;
end
[t_seg, y_seg] = ode45(@(t,y) seirs_vaccine_ode(t,y,beta,sigma,gamma,omega,0,N), ...
                       [t_start, T], y_current);
t_all = [t_all; t_seg]; y_all = [y_all; y_seg];
```

**时滞 DDE**: 使用 `dde23`.

```matlab
% 历史函数 (t < 0 时的状态)
history = @(t) [N-1; 0; 1; 0];

% DDE 右侧
function dydt = delayed_sir(t, y, Z, beta, gamma, N)
    S = y(1); I_lag = Z(3);  % Z 为延迟状态 y(t-τ)
    dydt = zeros(2,1);
    dydt(1) = -beta * S * I_lag / N;
    dydt(2) =  beta * S * I_lag / N - gamma * y(2);
end

sol = dde23(@(t,y,Z) delayed_sir(t,y,Z,beta,gamma,N), tau, history, [0, T]);
```

## Python 备选

```python
from scipy.integrate import solve_ivp
import numpy as np

def seirs_vaccine_ode(t, y, beta, sigma, gamma, omega, v, N):
    S, E, I, R = y
    dS = -beta * S * I / N - v * S + omega * R
    dE =  beta * S * I / N - sigma * E
    dI =  sigma * E - gamma * I
    dR =  gamma * I + v * S - omega * R
    return [dS, dE, dI, dR]

# 脉冲接种: 使用 solve_ivp 的事件检测 (events)
def pulse_event(t, y, beta, sigma, gamma, omega, v, N):
    return t - pulse_times[current_pulse_idx]
pulse_event.terminal = False
pulse_event.direction = 0

# DDE: pip install ddeint
from ddeint import ddeint
def delayed_sir(Y, t, beta, gamma, N, tau):
    S, I = Y(t)
    I_delayed = Y(t - tau)[1]
    dS = -beta * S * I_delayed / N
    dI =  beta * S * I_delayed / N - gamma * I
    return [dS, dI]
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 免疫力为暂时性 (流感、RSV) | SEIRS | ω > 0 允许 R→S |
| 需评估疫苗接种策略 | SEIRS + 接种 | 连续或脉冲接种均可建模 |
| 固定日期的免疫接种日 (如年度流感疫苗) | 脉冲 SEIRS | 脉冲 ODE 刻画离散干预 |
| 潜伏期存在 + 免疫力衰退 | SEIRS | S→E→I→R→S |
| 时滞效果显著 (信息延迟、潜伏期建模为延迟) | DDE-SIR | dde23 / ddeint |
| 单一血清型，无交叉免疫 | 单株 SEIRS | 标准模型即可 |
| 多血清型 (登革热、流感) | 多株模型 | 单株 SEIRS 遗漏血清型替换现象 |
| 需优化年龄靶向接种策略 | 年龄结构 SEIRS | 同质模型无法区分年龄段 |
| 疫苗非 100% 有效 (leaky) | SEIRS + 易感性因子 ε | 接种者仍以降低后的易感性进入 S |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 初始仓室分布柱状图 | 含接种比例的 S/E/I/R 初始值 |
| process | 多情景 S/E/I/R 时序曲线叠加 | 无疫苗 / 50%覆盖 / 80%覆盖 三条曲线对比; 推荐 I(t) 对数值 |
| process | R_eff(t) 轨迹 | 次坐标叠加于 I(t) 图上 |
| process | 脉冲接种时间点标记 | 垂直线标记每次脉冲接种时刻 |
| result | 群体免疫阈值可视化 | 横轴 v, 纵轴流行最终规模 → 阈值截断曲线 |
| result | 流行病规模 vs 接种覆盖率 | 临界覆盖率 p_c 标识 |
| result | 分岔图 (DDE) | 横轴 τ, 纵轴 I 的振幅 — Hopf 分岔点标识 |

## 常见坑

1. **脉冲接种需正确处理**: ODE 求解器默认不知脉冲时刻，若步长跨过脉冲节点则轨迹错误。必须用 'Events' 选项或固定步长分段积分，不可简单在整个区间上连续积分
2. **DDE 历史函数误差**: dde23/ddeint 需要 $t \in [-\tau, 0]$ 的历史状态; 错误的历史函数 (如设为常数而非实际流行趋势) 会偏置早期动力学，尤其影响 Hpoff 分岔检测
3. **ω 不可辨识**: 免疫力衰退率 ω 难以从短期时间序列估计，因为 ω 的效应在流行结束后才显著 → 需要血清流行病学 (seroprevalence) 横断面数据联合约束
4. **季节性 β 的 α 估计噪声大**: α 需要至少 2-3 个完整流行周期 (年) 的数据，若仅有单季数据则 α 完全不可估计
5. **脉冲频率 vs 幅度权衡**: 高频低覆盖脉冲和低频高覆盖脉冲可能产生相同稳态，但瞬态动态不同 → 需同时报告稳态和瞬态指标
6. **DDE 数值稳定性**: 大 τ 或大 β 时 DDE 可能刚化，标准 dde23 步长过小; 检查解的光滑性，必要时使用隐式方法或减小 τ

## 失效条件/反例 (强制小节)

- **条件1: 疫苗为 leaky 型 (降低易感性但非完全免疫) 而非 all-or-nothing** → **表现**: 标准模型假设接种者完全免疫 (进入 R)，高估疫苗有效性。实际 leaky 疫苗使接种者以降低后的感染概率仍可被感染。应对: 引入接种仓室 V，V 到 E 的传播率为 (1-ε)β，其中 ε < 1 为疫苗效能
- **条件2: 多种血清型存在交叉免疫** (登革热、流感等多血清型疾病) → **表现**: 单株 SEIRS 遗漏血清型替换现象 — 接种针对一种血清型的疫苗可能导致其他血清型发病率上升 (replacement)，模型给出乐观的控制预估。应对: 使用多株 (multi-strain) 模型，每株独立建模并设定交叉免疫矩阵
- **条件3: 年龄结构接触模式对接种靶向至关重要** (老人 vs 儿童的接触率差异) → **表现**: 同质模型无法优化年龄靶向接种策略，可能推荐均匀接种而实际最优策略是优先接种特定年龄段。应对: 使用年龄结构 SEIRS 模型，引入接触矩阵 (如 POLYMOD 矩阵)
- **条件4: 时滞 τ 选择过大且无数据支持** → **表现**: τ 过大产生人工周期性振荡，DDE 的 Hopf 分岔值 τ_c 与实际生物学时滞不匹配，导致虚假的持续性爆发预测。应对: τ 应从流行病学机制出发并基于世代间隔数据校准; 对 τ 进行敏感性分析，确认分岔位置是否在生物合理范围内
- **条件5: 脉冲接种的时刻 t_k 设定不合理** → **表现**: 脉冲在流行高峰时施加效果最好，在低谷时施加浪费; 若 t_k 全部设在流行低谷期，模型预测疫苗无效而实际是时机不当。应对: 扫描脉冲相位，报告最优脉冲时机

## 文献

1. Hethcote HW (2000). "The mathematics of infectious diseases." *SIAM Review*, 42(4):599-653. DOI: [10.1137/S0036144500371907](https://doi.org/10.1137/S0036144500371907)
2. Keeling MJ, Rohani P (2008). *Modeling Infectious Diseases in Humans and Animals.* Princeton University Press. ISBN: 978-0691116174
3. Shulgin B, Stone L, Agur Z (1998). "Pulse vaccination strategy in the SIR epidemic model." *Bulletin of Mathematical Biology*, 60:1123-1148. DOI: [10.1006/bulm.1998.0054](https://doi.org/10.1006/bulm.1998.0054)

## 来源溯源

MATLAB ode45 + 自写-见S5:seirs_vaccine.m

## 关联范式卡

- 组合: PARADIGM-0808 (变分法/最优控制, 最优疫苗分配与脉冲时机优化)
- 替代: PARADIGM-0804 (SEIR, 当免疫力永久且无接种需求时退化至此)
- 前置: PARADIGM-0804 (SEIR), PARADIGM-0708 (系统动力学/ODE建模框架), PARADIGM-0807 (差分方程, 离散时间替代)
