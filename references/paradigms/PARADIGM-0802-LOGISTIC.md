# PARADIGM-0802 Logistic 增长模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0802 |
| 类别/子类 | ⑧机理建模 / 种群动力学 |
| 难度 | 低 |
| 适用题型关键词[] | Logistic模型, S型曲线, 环境容量, 种群增长, 密度制约, Verhulst, 承载能力, 内禀增长率, sigmoid, 阻滞增长, 逻辑斯蒂 |
| confidence | high |
| source | Verhulst (1838) Correspondance Mathématique et Physique; 已有 matlab/mechanism/logistic_model.m |

## 数学形式

**Logistic 增长模型 (Verhulst 模型)**

**微分方程** (一阶非线性 ODE):

$$\frac{dN}{dt} = rN\left(1 - \frac{N}{K}\right)$$

其中:
- $N(t)$: t 时刻的种群数量
- $r > 0$: 内禀增长率 (intrinsic growth rate), 即 $N \ll K$ 时的最大人均增长率, 量纲 [time⁻¹]
- $K > 0$: 环境容量 / 承载能力 (carrying capacity), 与 N 同量纲

**三项解释**:
- $rN$: Malthus 增长项 ($N$ 小时主导)
- $(1 - N/K)$: 密度制约因子 (density-dependent regulation)
  - $N \ll K$: $(1-N/K) \approx 1$ → 近似指数增长 $dN/dt \approx rN$
  - $N \to K$: $(1-N/K) \to 0$ → 增长停滞 $dN/dt \to 0$
  - $N > K$: $(1-N/K) < 0$ → 负增长, 种群回落到 K

**解析解**:

$$N(t) = \frac{K}{1 + \left(\frac{K}{N_0} - 1\right) e^{-rt}}$$

令 $A = \frac{K - N_0}{N_0}$ (初始相对缺额):
$$N(t) = \frac{K}{1 + A e^{-rt}}$$

**推导** (变量分离):
$$\frac{dN}{N(1-N/K)} = r\,dt$$
$$\int_{N_0}^{N} \left[\frac{1}{N} + \frac{1/K}{1-N/K}\right] dN = rt$$
$$\ln\left(\frac{N}{N_0}\right) - \ln\left(\frac{K-N}{K-N_0}\right) = rt$$
$$N(t) = \frac{K}{1 + \frac{K-N_0}{N_0} e^{-rt}}$$

**关键特征点**:

**拐点 (Inflection Point)**: 增长率 $\frac{dN}{dt}$ 在 $N = K/2$ 时达到最大值 $rK/4$。曲线在此点由加速增长转为减速增长 (S 型曲线的转折)。

$$\frac{d^2N}{dt^2} = r\frac{dN}{dt}\left(1 - \frac{2N}{K}\right) = 0 \quad \Rightarrow \quad N_{\text{inflection}} = \frac{K}{2}$$

拐点时刻:
$$t_{\text{inflection}} = \frac{1}{r} \ln\left(\frac{K - N_0}{N_0}\right)$$

**最大增长率**:
$$\left(\frac{dN}{dt}\right)_{\max} = \frac{rK}{4}$$

**半饱和度时间**: 从任意起点到 $N = K/2$ 的时间.

**带有收获/捕捞的 Logistic 模型** (Schaefer 模型):

$$\frac{dN}{dt} = rN\left(1 - \frac{N}{K}\right) - H$$

其中 $H$ 为收获率 (常数或 $H = qEN$, $E$ 为努力量)。

最大可持续产量 (Maximum Sustainable Yield, MSY):
$$H_{\max} = \frac{rK}{4}, \quad N_{\text{MSY}} = \frac{K}{2}$$

**时滞 Logistic 模型** (Hutchinson-Wright):

$$\frac{dN}{dt} = rN(t)\left(1 - \frac{N(t-\tau)}{K}\right)$$

其中 $\tau$ 为时滞 (如从资源消耗到种群感受到密度压力之间的延迟)。时滞引入后可能出现衰减振荡甚至极限环。

**离散时间 Logistic** (May 模型):

$$N_{t+1} = r N_t (1 - N_t / K)$$

重新标度 $x_t = N_t/K$:
$$x_{t+1} = r x_t (1 - x_t)$$

该系统在 $r > 3$ 出现倍周期分岔 (period doubling), $r > 3.57$ 进入混沌。连续 Logistic **从不会混沌**——这是连续 vs 离散的基本数学性质差异。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| r (内禀增长率) | scalar | 0.02 | (0, ∞) year⁻¹ | 极高 — 决定趋近 K 的速度和拐点位置 |
| K (环境容量) | scalar | 1000 | (N₀, ∞) | 极高 — 决定长期渐进值和所有特征尺度 |
| N₀ (初始种群) | scalar | 10 | (0, K) | 高 — 若 N₀≪K 则初期近似指数, 若 N₀≈K 则无 S 型 |
| τ (时滞, 扩展) | scalar | 0 | [0, ∞) year | 高 — τ > 1/r 时产生振荡 |
| tspan | vector | [0, 100] | [0, ∞) | 低 — 需覆盖至曲线接近 K |
| H (收获率, 扩展) | scalar | 0 | [0, rK/4] | 中 — 过大则 N→0 (不可持续) |

| 输出 | 量纲 |
|------|------|
| N(t) | 与 K 同量纲 |
| dN/dt vs N | 抛物线, 最大 $rK/4$ |
| t_inflection | 与 t 同量纲 |
| r̂, K̂ (拟合值) | [time⁻¹], 与 N 同量纲 |

**计算复杂度**: 解析解 $O(1)$; ODE 数值解 $O(T/\Delta t) \approx O(100)$。可忽略不计。

## MATLAB 实现

**方法1: 解析解 (推荐)**

```matlab
% 参数
N0 = 10;        % 初始种群
r = 0.3;        % 内禀增长率
K = 1000;       % 环境容量
T = 50;         % 模拟时长
t = linspace(0, T, 200);

% Logistic 解析解
A = (K - N0) / N0;
N = K ./ (1 + A * exp(-r * t));

% 拐点时间
t_inflection = log(A) / r;
N_inflection = K / 2;

% 最大增长率
max_growth_rate = r * K / 4;

% 绘图
figure;
plot(t, N, 'b-', 'LineWidth', 2);
hold on;
yline(K, 'k--', sprintf('K = %.0f', K));
plot(t_inflection, N_inflection, 'ro', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r');
xlabel('t'); ylabel('N(t)');
title(sprintf('Logistic: r=%.2f, K=%.0f, inflection at t=%.1f', ...
    r, K, t_inflection));
legend('N(t)', 'K', '拐点', 'Location', 'best');
grid on;

fprintf('拐点时间: %.2f\n', t_inflection);
fprintf('最大增长率: %.2f\n', max_growth_rate);
```

**方法2: ODE 数值解 (已有 matlab/mechanism/logistic_model.m)**

```matlab
% Logistic ODE 右侧
function dNdt = logistic_ode(~, N, r, K)
    dNdt = r * N * (1 - N / K);
end

% 主脚本
r = 0.3; K = 1000; N0 = 10;
tspan = [0 50];

[t, N] = ode45(@(t, N) logistic_ode(t, N, r, K), tspan, N0);

plot(t, N, 'b-', 'LineWidth', 2);
xlabel('t'); ylabel('N(t)');
yline(K, 'k--');
grid on;
```

**方法3: 数据拟合 (非线性最小二乘)**

```matlab
% 给定观测数据
t_data = [0; 5; 10; 15; 20; 25; 30; 35; 40; 45; 50];
N_data = [10; 40; 150; 400; 650; 820; 915; 962; 985; 994; 998];

% Logistic 模型函数
logistic_fun = @(params, t) params(2) ./ ...
    (1 + (params(2)/params(3) - 1) * exp(-params(1) * t));
% params(1) = r, params(2) = K, params(3) = N0  (或直接给 N0 减少参数)

% 若 N0 已知，仅拟合 r 和 K
logistic_fun_2param = @(params, t) params(2) ./ ...
    (1 + (params(2)/N_data(1) - 1) * exp(-params(1) * t));
% params(1) = r, params(2) = K

% 初始猜测
r0_guess = 0.2;
K_guess = 1000;
params0 = [r0_guess, K_guess];

% 非线性最小二乘拟合
params_hat = nlinfit(t_data, N_data, logistic_fun_2param, params0);
r_hat = params_hat(1);
K_hat = params_hat(2);

fprintf('估计: r = %.4f, K = %.1f\n', r_hat, K_hat);

% 拟合曲线 vs 观测
t_fine = linspace(0, 50, 100);
N_fit = logistic_fun_2param(params_hat, t_fine);
plot(t_data, N_data, 'ro', t_fine, N_fit, 'b-');
legend('观测', '拟合 Logistic', 'Location', 'best');
```

**方法4: 带收获的 Logistic (Schaefer 模型)**

```matlab
function dNdt = schaefer_ode(~, N, r, K, q, E)
    dNdt = r * N * (1 - N / K) - q * E * N;
end

% 不同捕捞努力量下种群动态
r = 0.3; K = 1000; q = 0.1; E_values = [0, 0.5, 1.0, 1.5];
N0 = 1000; tspan = [0 50];
figure;
for i = 1:length(E_values)
    [t, N] = ode45(@(t,N) schaefer_ode(t,N,r,K,q,E_values(i)), tspan, N0);
    plot(t, N, 'DisplayName', sprintf('E=%.1f', E_values(i))); hold on;
end
xlabel('t'); ylabel('N(t)'); legend;
title('不同捕捞努力量下的 Schaefer Logistic');
yline(K * (1 - q*E_values(end)/r), 'k--'); % 平衡点
```

**锚点工具箱函数**: `ode45`, `nlinfit` (Statistics and Machine Learning Toolbox).

## Python 备选

```python
import numpy as np
from scipy.integrate import solve_ivp
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# 解析解
N0, r, K = 10, 0.3, 1000
t = np.linspace(0, 50, 200)
A = (K - N0) / N0
N = K / (1 + A * np.exp(-r * t))

# 拐点
t_inflection = np.log(A) / r
N_inflection = K / 2
print(f"拐点: t={t_inflection:.2f}, N={N_inflection:.1f}")

# ODE 数值解
def logistic_ode(t, N, r, K):
    return r * N * (1 - N / K)

sol = solve_ivp(logistic_ode, [0, 50], [N0], args=(r, K), t_eval=t)

# 数据拟合
t_data = np.array([0,5,10,15,20,25,30,35,40,45,50])
N_data = np.array([10,40,150,400,650,820,915,962,985,994,998])
N0_fixed = N_data[0]

def logistic_fit(t, r, K):
    return K / (1 + (K/N0_fixed - 1) * np.exp(-r * t))

popt, pcov = curve_fit(logistic_fit, t_data, N_data, p0=[0.2, 1000])
print(f"估计: r = {popt[0]:.4f}, K = {popt[1]:.1f}")
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 数据呈 S 型曲线 (先加速后减速) | Logistic | Logistic 是建模 S 型饱和增长的"标准答案" |
| 仅有短期数据 (未达拐点) | 需谨慎拟合 | r 和 K 可能不可辨识, 多组参数拟合观测同样好 |
| 有明确承载能力 K (物理/生物限制) | Logistic | K 有物理含义, 不是纯经验参数 |
| 增长率非单调 (有振荡/超调) | 时滞 Logistic / Lotka-Volterra | Logistic 增长曲线单调, 不产生振荡 |
| 多个种群竞争同一资源 | Lotka-Volterra 竞争模型 | 单种 Logistic 忽略种间相互作用 |
| 收获/捕捞/砍伐的最优策略 | Schaefer 模型 (Logistic+收获) | MSY 公式 $rK/4$ 直接给出可持续最大产量 |
| 指数增长阶段 (t 很短, N≪K) | Malthus (PARADIGM-0801) | Logistic 初期近似 Malthus, 可直接用 Malthus |
| Allee 效应 (小种群合作) | Logistic+Allee 修正 | 标准 Logistic 假设 N→0 时增长率最大, Allee 种群相反 |
| 细菌/细胞全生长周期 | 分段模型 | 延迟期 (lag)→对数期 (Malthus)→稳定期 (Logistic)→死亡期 |
| 技术扩散/创新采用/Market share | Logistic / Bass 模型 | 扩散过程本质也是 S 型曲线 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 观测散点图 (t, N_data) | 目视判断是否呈 S 型, 拐点位置 |
| process | N(t) 曲线 + K 参考线 + 拐点标注 | S 型完整展示 |
| process | dN/dt vs N 相图 | 抛物线, 最大值在 N=K/2, 两侧对称递减至 0 |
| process | 残差 vs t (拟合后) | 检验残差无系统性模式 (无自相关) |
| result | 多参数对比图 | 不同 r 或 K 值的曲线族叠加 |
| result | 拐点时间敏感性 | t_inflection 对 r 的敏感性曲线 |
| result | 预测外推 + 置信带 | 预测期 N(t) 的 95% 置信区间 |

## 常见坑

1. **r 和 K 的可辨识性问题**: 若数据仅包含 $N \ll K$ 的早期阶段，曲线接近指数 $N(t) \approx N_0 e^{rt}$，信息只足以估计 r，K 不可辨识 (任何足够大的 K 拟合效果几乎相同)。→ 必须确保数据覆盖拐点 ($N = K/2$) 之后才能可靠估计 K。
2. **确定性单一平衡假设**: Logistic 假设 $N = K$ 是唯一稳定平衡点，且增长曲线单调。真实种群可能因时滞、季节性、随机扰动而围绕 K 振荡。→ 若数据有振荡，不要强用 Logistic；考虑时滞 ODE 或周期模型。
3. **初始值 N₀ 的拟合陷阱**: 若 N₀ 也作为拟合参数，会产生三参数拟合 $(r, K, N_0)$，参数空间增加且 N₀ 与 r 高度相关 (N₀ 越大则需要越小的 r 来穿过相同数据点)。→ 固定 N₀ 为第一个观测值，减少至二参数拟合。
4. **K 的线性外推错误**: 不能用 Logistic 模型拟合到 80% K 后线性外推到 100% K——Logistic 是非线性的，最后 20% 趋近 K 的速度比线性慢得多。→ 使用完整的 Logistic 公式外推。
5. **浓度/密度的量纲一致性**: 若数据是浓度 (g/L) 而非数量，Logistic 依然适用，但 K 的含义变为最大浓度。务必在报告中明确量纲。
6. **$N_0 > K$ 的情况**: 若初始种群超过环境容量，Logistic 预测负增长率——这在生物学上可能是 transient dynamics (种群刚迁入不适合的环境)。模型仍有效，但需解释"种群向承载能力回退"。

## 失效条件/反例 (强制小节)

- **条件1: 时滞效应显著 ($\tau \cdot r > 0.37$, Hutchinson 条件)** → **表现**: 在真实种群中，密度对种群的反馈有延迟——资源消耗后种群不会立刻感知到密度压力，而是经过一代时间 (如昆虫的卵→成虫发育期) 才能响应。当 $\tau \cdot r > \pi/(2\sqrt{2}) \approx 1.11$，标准 Logistic 预测单调趋近 K，但真实系统出现围绕 K 的衰减振荡甚至持续振荡 (极限环)。若用 Logistic 拟合振荡数据 → 残差呈周期性自相关，K 的估计值实质是时间平均而非真正的承载能力。**应对**: 使用时滞 Logistic (Hutchinson-Wright 方程): $dN/dt = rN(t)(1-N(t-\tau)/K)$。参数估计需要 DDE (延迟微分方程) 求解器 (MATLAB `dde23`)。

- **条件2: Allee 效应 (小种群的合作行为) 被忽略** → **表现**: 某些种群 (如集群繁殖的海鸟、蜂群、狼群) 在密度极低时人均增长率不增反降——配偶难找、合作捕猎效率低、抵御天敌的群体效应失效。标准 Logistic 预测 $N \to 0$ 时 $dN/dt \to 0$ (以极慢的速度趋近灭绝)，而有 Allee 效应的种群在低于阈值 $A$ 时会主动崩溃 (增长速度变负)。忽略 Allee 效应 → 对濒危/小种群的灭绝风险评估过于乐观，保育措施的决策失误。**应对**: 使用带 Allee 效应的 Logistic: $dN/dt = rN(1-N/K)(N/A - 1)$，其中 $A < K/2$ 为 Allee 阈值。当 $N < A$ 时增长率为负。

- **条件3: 环境容量 K 不是常数 (时变环境)** → **表现**: Logistic 假设 K 恒定——资源供给、栖息地面积、气候条件固定。若环境在模拟期内变化 (如全球变暖使某些地区可耕面积扩大、水库建成增加渔业容量)，K 实质是 $K(t)$。用恒定 K 拟合时变数据 → 对 K 的估计是某种时间加权平均，预测外推产生结构性偏差 (若 K 随时间递增则低估未来种群; 若递减则高估)。此外，$r$ 和 $K(t)$ 的速率在数据中可能不可分离。**应对**: (1) 分段 Logistic (不同时段拟合不同 K); (2) 使用时变 Logistic: $dN/dt = rN(1-N/K(t))$，并用外部数据建模 $K(t)$ 的演变; (3) 在预测中使用多个 K 情景进行稳健性分析。

## 文献

1. Verhulst PF (1838). "Notice sur la loi que la population suit dans son accroissement." *Correspondance Mathématique et Physique*, 10:113-121.
2. Pearl R, Reed LJ (1920). "On the rate of growth of the population of the United States since 1790 and its mathematical representation." *Proceedings of the National Academy of Sciences*, 6(6):275-288. DOI: [10.1073/pnas.6.6.275](https://doi.org/10.1073/pnas.6.6.275)
3. Murray JD (2002). *Mathematical Biology: I. An Introduction*, 3rd ed. Springer. Chapter 1. ISBN: 978-0387952239
4. May RM (1976). "Simple mathematical models with very complicated dynamics." *Nature*, 261(5560):459-467. DOI: [10.1038/261459a0](https://doi.org/10.1038/261459a0) (离散 Logistic 的混沌行为)

## 来源溯源

Verhulst (1838); 已有 matlab/mechanism/logistic_model.m; 培训模块 mechanism-population.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0801 (Malthus模型, Logistic 是带密度制约的 Malthus 扩展) |
| 替代 | PARADIGM-0803 (Leslie矩阵, 年龄结构化的种群增长, Logistic 忽略年龄结构) |
| 组合 | PARADIGM-0804 (SEIR, 传染病传播也可嵌入 Logistic 密度制约出生率) |
| 扩展 | PARADIGM-0807 (差分方程迭代器, 离散 Logistic 的动力学分析) |
| 扩展 | PARADIGM-1004 (RBF代理模型, 用代理模型拟合复杂 Logistic 变体的似然函数) |
