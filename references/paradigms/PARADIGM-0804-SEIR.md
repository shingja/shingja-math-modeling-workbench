# PARADIGM-0804 SEIR传染病模型(含潜伏期)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0804 |
| 类别/子类 | ⑧机理建模 / 传染病动力学 |
| 难度 | 中 |
| 适用题型关键词[] | SEIR模型, 传染病, 潜伏期, 基本再生数, ODE, SIR, 仓室模型, 疫情预测 |
| confidence | high |
| source | 培训模块28 SEIR.mlx |

## 数学形式

**SEIR 仓室模型 (4 ODEs, 常人口 N = S + E + I + R = const)**

$$\frac{dS}{dt} = -\frac{\beta S I}{N}$$

$$\frac{dE}{dt} = \frac{\beta S I}{N} - \sigma E$$

$$\frac{dI}{dt} = \sigma E - \gamma I$$

$$\frac{dR}{dt} = \gamma I$$

**基本再生数 (Basic Reproduction Number)**

$$R_0 = \frac{\beta}{\gamma}$$

**有效再生数 (Effective Reproduction Number)**

$$R_t = R_0 \cdot \frac{S(t)}{N}$$

**流行阈值 (Epidemic Threshold)**

$$R_0 > 1 \Rightarrow \text{疾病扩散};\quad R_0 < 1 \Rightarrow \text{疾病消亡}$$

**关键时间尺度**

- 平均潜伏期: $T_E = \frac{1}{\sigma}$
- 平均感染期: $T_I = \frac{1}{\gamma}$
- 平均世代间隔: $T_g = T_E + T_I$

**扩展: 加入人口动力学 (vital dynamics)**

$$\frac{dS}{dt} = \mu N - \frac{\beta S I}{N} - \mu S$$

$$\frac{dE}{dt} = \frac{\beta S I}{N} - \sigma E - \mu E$$

$$\frac{dI}{dt} = \sigma E - \gamma I - \mu I$$

$$\frac{dR}{dt} = \gamma I - \mu R$$

其中 $\mu$ 为人均出生/死亡率。

**扩展: 加入疫苗接种**

$$\frac{dS}{dt} = -\frac{\beta S I}{N} - v S$$

$$\frac{dR}{dt} = \gamma I + v S$$

其中 $v$ 为接种率。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| β (transmission rate) | scalar | 0.3 | (0, ∞) day⁻¹ | 极高 — R₀ ∝ β，决定爆发与否 |
| σ (incubation rate) | scalar | 1/5.2 | (0, ∞) day⁻¹ | 高 — 影响潜伏期长度和峰值延迟 |
| γ (recovery rate) | scalar | 1/14 | (0, ∞) day⁻¹ | 高 — R₀ ∝ 1/γ |
| μ (birth/death rate) | scalar | 0 | (0, 1) day⁻¹ | 低 (短期模拟≈0) |
| v (vaccination rate) | scalar | 0 | [0, 1] day⁻¹ | 中 — 影响群体免疫阈值 |
| N (total population) | scalar | 10⁶ | (0, ∞) | 低 (仅影响尺度) |
| S₀, E₀, I₀, R₀ (initial) | vector | [N-1; 1; 0; 0] | ≥0, sum=N | 中 — I₀ 太小则爆发延迟 |

| 输出 | 量纲 |
|------|------|
| y(:,1) = S(t) | 人数 |
| y(:,2) = E(t) | 人数 |
| y(:,3) = I(t) | 人数 |
| y(:,4) = R(t) | 人数 |
| R₀ | 无量纲 |

**计算复杂度**: O(T/Δt) 由 ode45 自适应步长控制，4维 ODE 求解 trivial (< 0.1s)。

## MATLAB 实现

**函数签名** (培训模块28 SEIR.mlx):

```matlab
% 主求解
[t, y] = ode45(@(t,y) seir_ode(t, y, beta, sigma, gamma, N), tspan, [S0; E0; I0; R0]);

% ODE 右侧函数
function dydt = seir_ode(~, y, beta, sigma, gamma, N)
    S = y(1); E = y(2); I = y(3); R = y(4);
    dydt = zeros(4,1);
    dydt(1) = -beta * S * I / N;
    dydt(2) =  beta * S * I / N - sigma * E;
    dydt(3) =  sigma * E - gamma * I;
    dydt(4) =  gamma * I;
end

% 绘制
plot(t, y(:,1:4), 'LineWidth', 1.5);
legend('S', 'E', 'I', 'R');
xlabel('Time (days)'); ylabel('Population');
```

**锚点工具箱函数**: `ode45`, `ode23s` (stiff 情形, 如 β 很大).

## Python 备选

```python
from scipy.integrate import solve_ivp
import numpy as np

def seir_ode(t, y, beta, sigma, gamma, N):
    S, E, I, R = y
    dS = -beta * S * I / N
    dE =  beta * S * I / N - sigma * E
    dI =  sigma * E - gamma * I
    dR =  gamma * I
    return [dS, dE, dI, dR]

sol = solve_ivp(seir_ode, [0, T], [N-1, 1, 0, 0],
                args=(beta, sigma, gamma, N),
                method='RK45', dense_output=True)
# 库备选: epimodel, pyross
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 疾病有明显的潜伏期 (COVID-19, 麻疹, 埃博拉) | SEIR | E 仓室建模潜伏期，比 SIR 更准确 |
| 疾病无潜伏期或潜伏期极短 (流感, 诺如) | SIR | 少一个 ODE，参数更易估计 |
| 免疫力不持久 (RSV, 季节性流感) | SEIRS | R→S 反馈描述免疫力衰退 |
| 年龄结构对传播至关重要 | 年龄结构 SEIR (PDE) | 接触矩阵刻画异质性混合 |
| 空间扩散效应显著 | 集合种群 SEIR / 反应扩散 PDE | 空间异质性不可忽略 |
| 小种群随机效应 | Gillespie 算法 / SDE | 确定性 ODE 在 N 小时失真 |
| 需要评估疫苗接种策略 | SEIR + 接种 | 见 PARADIGM-0805 |
| 仅有病例时序数据，需联合估计参数 | 状态空间 SEIR + MCMC / EKF | 解决部分可观测性 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 初始仓室柱状图 | bar(['S','E','I','R'], [S0,E0,I0,R0]) |
| process | S/E/I/R 时序曲线 | 推荐 I(t) 使用对数坐标；叠加 R_t 轨迹于次坐标 |
| process | I-S 相图 | 显示流行轨迹在相空间的闭环 |
| result | 峰值对比表 | 不同干预情景下 I_max 高度与到达时间对比 |
| result | R₀ 敏感性 | R₀ 对 β, γ 的单因素/双因素参数扫描热力图 |

## 常见坑

1. **R₀ 不是疾病的固有常数**: β 随行为、密度、季节变化，报告 R₀ 时应标注对应场景假设
2. **均匀混合假设**: 真实接触网络有家庭/学校/工作场所结构化，导致初始增长慢于指数，SEIR 会高估初期传播速度
3. **参数可辨识性**: 疫情早期 β 和 σ 无法同时从发病率数据唯一估计 (仅有指数增长斜率 dI/dt ≈ rI, r 对应 β 和 σ 的某种组合)
4. **报告延迟**: 观测病例数滞后真实感染数，直接拟合会低估 β → 使用反卷积或状态空间 SEIR
5. **数值刚性问题**: β 很大时 (如麻疹 R₀≈15) ODE 系统可能变 stiff → 替换 ode45 为 ode23s/ode15s
6. **初始敏感 I₀**: I₀ = 1 vs I₀ = 10 可能导致峰值时间偏移数天→数十天，特别是 N 很大时; 建议进行 I₀ 敏感性分析

## 失效条件/反例 (强制小节)

- **条件1: 种群非均匀混合** (家庭结构、学校/工作场所聚集) → **表现**: 同质 SEIR 高估峰值幅度、低估疫情持续时间，因为忽略了接触网络的局域饱和效应。应对: 使用网络/多群组 SEIR 或基于个体的传播模型 (agent-based model)
- **条件2: 免疫力随时间衰减** (可再次感染) → **表现**: SEIR 假设 R 为吸收态 (永久免疫)，若实际存在免疫力衰退，模型将低估长期病例数和周期性爆发可能。应对: 使用 SEIRS (R→S 速率 ω)，见 PARADIGM-0805
- **条件3: 疫情驱动的行为变化** (高流行率引致社交距离) → **表现**: 恒定 β 违反实际，模型在疫情高峰后下降过快或过慢。应对: 使用 β(t) = β₀ · f(I) 行为响应函数，或分段 β
- **条件4: 输入病例持续存在** → **表现**: SEIR 闭合系统在 I→0 后无法再起，若有持续境外输入，模型预测 elimination 而实际反复爆发。应对: 加入输入项 +ε 到 E 或 I 仓室

## 文献

1. Kermack WO, McKendrick AG (1927). "A contribution to the mathematical theory of epidemics." *Proceedings of the Royal Society A*, 115(772):700-721. DOI: [10.1098/rspa.1927.0118](https://doi.org/10.1098/rspa.1927.0118)
2. Hethcote HW (2000). "The mathematics of infectious diseases." *SIAM Review*, 42(4):599-653. DOI: [10.1137/S0036144500371907](https://doi.org/10.1137/S0036144500371907)
3. Anderson RM, May RM (1991). *Infectious Diseases of Humans: Dynamics and Control.* Oxford University Press. ISBN: 978-0198540403

## 来源溯源

培训模块28 SEIR.mlx

## 关联范式卡

- 组合: PARADIGM-0805 (SEIRS+疫苗, 免疫力衰退扩展), PARADIGM-0808 (变分法/最优控制, 最优干预策略)
- 替代: PARADIGM-0807 (差分方程, 离散时间模型, 数据为日/周频时更适用)
- 前置: PARADIGM-0708 (系统动力学, ODE 建模通用框架)
