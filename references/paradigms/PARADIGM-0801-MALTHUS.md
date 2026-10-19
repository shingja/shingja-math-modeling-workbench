# PARADIGM-0801 Malthus 指数增长模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0801 |
| 类别/子类 | ⑧机理建模 / 种群动力学 |
| 难度 | 低 |
| 适用题型关键词[] | Malthus模型, 指数增长, 种群增长, 增长率, 微分方程, 无限制增长, 人口预测, 细菌繁殖, 倍增时间, 指数衰减 |
| confidence | high |
| source | Malthus (1798) An Essay on the Principle of Population; 已有 matlab/mechanism/malthus_model.m |

## 数学形式

**Malthus 增长模型 (指数增长 / 指数衰减)**

**微分方程** (一阶线性 ODE):

$$\frac{dN}{dt} = rN$$

其中:
- $N(t)$ 为 t 时刻的种群数量/人口/生物量
- $r$ 为人均增长率 (per capita growth rate), 量纲 [time⁻¹]
  - $r > 0$: 指数增长 (无限制增长)
  - $r = 0$: 恒定不变
  - $r < 0$: 指数衰减 (种群走向灭绝)

**解析解**:

$$N(t) = N_0 \cdot e^{rt}$$

其中 $N_0 = N(0)$ 为初始种群数量。

**推导** (变量分离):
$$\frac{dN}{N} = r\,dt \quad \Rightarrow \quad \int_{N_0}^{N(t)} \frac{dN}{N} = \int_0^t r\,d\tau$$
$$\ln\left(\frac{N(t)}{N_0}\right) = rt \quad \Rightarrow \quad N(t) = N_0 e^{rt}$$

**关键时间尺度**:

**倍增时间** (Doubling Time, $r > 0$):
$$T_d = \frac{\ln 2}{r} \approx \frac{0.693}{r}$$

在 $t = T_d, 2T_d, 3T_d, \ldots$ 时，$N(t) = 2N_0, 4N_0, 8N_0, \ldots$ (几何级数增长)。

**半衰期** (Half-Life, $r < 0$):
$$T_{1/2} = \frac{\ln 2}{|r|} \approx \frac{0.693}{|r|}$$

在 $t = T_{1/2}, 2T_{1/2}, \ldots$ 时，$N(t) = N_0/2, N_0/4, \ldots$

**离散时间版本** (差分方程):
$$N_{t+1} = (1 + r)N_t$$
$$N_t = N_0 (1 + r)^t$$

当 $|r| \ll 1$ 时，离散形式近似连续形式: $(1+r)^t \approx e^{rt}$。

**参数估计 (对数变换线性回归)**:
对 $N(t) = N_0 e^{rt}$ 取自然对数:
$$\ln N(t) = \ln N_0 + r \cdot t$$

使用最小二乘法估计参数:
$$(\hat{\ln N_0}, \hat{r}) = \arg\min_{\alpha, r} \sum_{i=1}^m \left[\ln N_i - (\alpha + r t_i)\right]^2$$

等价于 `polyfit(t, log(N_data), 1)` 的斜率。

**确定性 vs 随机性**:

纯确定性: $dN/dt = rN$

加入环境随机性 (几何布朗运动):
$$dN = rN\,dt + \sigma N\,dW_t$$

其中 $dW_t \sim \mathcal{N}(0, dt)$ 为 Wiener 过程，$\sigma$ 为波动率。解:
$$N(t) = N_0 \exp\left((r - \sigma^2/2)t + \sigma W_t\right)$$

随机版本中，即使 $r > 0$ 也有非零灭绝概率 (当 $\sigma^2 > 2r$ 时以概率 1 灭绝)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| r (增长率) | scalar | 0.02 | (-∞, ∞) year⁻¹ | 极高 — r 的微小误差按 $e^{rt}$ 指数放大 |
| N₀ (初始种群) | scalar | 100 | (0, ∞) | 中 — 影响曲线尺度，不影响增长形态 |
| T (模拟时长) | scalar | 50 | (0, ∞) year | 低 — 控制 x 轴范围 |
| tspan | vector | [0, 50] | [0, ∞) | 低 — ode45 自适应步长，仅需起止+输出点 |

| 输出 | 量纲 |
|------|------|
| N(t) | 与 N₀ 同量纲 (个体数/人口数/生物量) |
| 对数坐标斜率 = r | [time⁻¹] |
| T_d (倍增时间) | 与 t 同量纲 (年/小时/代) |

**计算复杂度**: 解析解 $O(1)$，ODE 数值解 $O(T/\Delta t) \approx O(100)$ 取值点。可忽略不计。

## MATLAB 实现

**方法1: 解析解 (推荐 — 简单精确)**

```matlab
% 参数
N0 = 100;       % 初始种群
r = 0.02;       % 增长率 (年⁻¹)
T = 50;         % 模拟时长
t = linspace(0, T, 200);

% 解析解
N = N0 * exp(r * t);

% 倍增时间
Td = log(2) / r;
fprintf('倍增时间: %.2f 年\n', Td);

% 半衰期 (若 r < 0)
if r < 0
    Thalf = log(2) / abs(r);
    fprintf('半衰期: %.2f 年\n', Thalf);
end

% 对数坐标检验线性性 (方法验证)
figure;
semilogy(t, N, 'b-', 'LineWidth', 2);
xlabel('t (年)'); ylabel('N(t) (对数坐标)');
title(sprintf('Malthus模型: N(t)=%.0f·e^{%.3f·t}, 倍增时间=%.1f年', N0, r, Td));
grid on;

% 若在对数坐标中为直线 → 验证指数增长正确
```

**方法2: ODE 数值解 (已有 matlab/mechanism/malthus_model.m)**

```matlab
% Malthus ODE 右侧
function dNdt = malthus_ode(~, N, r)
    dNdt = r * N;
end

% 主脚本
r = 0.02;
N0 = 100;
tspan = [0 50];

[t, N] = ode45(@(t, N) malthus_ode(t, N, r), tspan, N0);

% 绘图
plot(t, N, 'b-', 'LineWidth', 2);
xlabel('t (年)'); ylabel('N(t)');
title('Malthus 指数增长模型');
grid on;
```

**锚点工具箱函数**: `ode45` (ODEs 数值求解), `ode15s` (若 ODE 刚性问题, 但 Malthus 模型 $dN/dt = rN$ 非刚).

**方法3: 数据拟合求 r 和 N₀**

```matlab
% 给定观测数据 (t_data, N_data)
t_data = [0; 10; 20; 30; 40; 50];
N_data = [100; 122; 150; 182; 223; 272];

% 对数线性回归
p = polyfit(t_data, log(N_data), 1);
r_hat = p(1);
N0_hat = exp(p(2));

fprintf('估计增长率 r = %.4f\n', r_hat);
fprintf('估计初值 N₀ = %.1f\n', N0_hat);

% 拟合曲线 vs 观测
t_fine = linspace(0, 50, 100);
N_fit = N0_hat * exp(r_hat * t_fine);
plot(t_data, N_data, 'ro', t_fine, N_fit, 'b-');
legend('观测', '拟合 Malthus');
```

**方法4: 带环境噪声的随机 Malthus**

```matlab
% 几何布朗运动模拟 (Euler-Maruyama)
N0 = 100; r = 0.02; sigma = 0.05; dt = 0.1;
T = 50; n_steps = T / dt;
N = zeros(n_steps+1, 1); N(1) = N0;
t = (0:n_steps)' * dt;

rng(42);
for i = 1:n_steps
    dW = sqrt(dt) * randn;
    N(i+1) = N(i) + r * N(i) * dt + sigma * N(i) * dW;
end

plot(t, N); xlabel('t'); ylabel('N(t)');
title(sprintf('随机Malthus: r=%.2f, σ=%.2f', r, sigma));
```

## Python 备选

```python
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import solve_ivp
from scipy.optimize import curve_fit

# 解析解
N0, r = 100, 0.02
t = np.linspace(0, 50, 200)
N = N0 * np.exp(r * t)
Td = np.log(2) / r
print(f"倍增时间: {Td:.2f} 年")

# ODE 数值解
def malthus_ode(t, N, r):
    return r * N

sol = solve_ivp(malthus_ode, [0, 50], [N0], args=(r,), 
                method='RK45', t_eval=t)
# sol.y[0] → N(t)

# 数据拟合
t_data = np.array([0, 10, 20, 30, 40, 50])
N_data = np.array([100, 122, 150, 182, 223, 272])

def malthus_fit(t, N0, r):
    return N0 * np.exp(r * t)

popt, pcov = curve_fit(malthus_fit, t_data, N_data, p0=[100, 0.02])
print(f"r = {popt[1]:.4f}, N0 = {popt[0]:.1f}")
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 短期预测 (t < T_d/2) | Malthus | 短期近似准确，资源限制未显现 |
| 资源有限 (存在环境容量 K) | Logistic (PARADIGM-0802) | 指数增长不可持续，Logistic 引入密度制约 |
| 种群衰减 (r < 0) | Malthus (衰减) | 对于数量单调减少的过程仍然有效 |
| 有年龄结构 | Leslie (PARADIGM-0803) | Malthus 假设所有个体等价的同质种群 |
| 有时滞效应 | 时滞 Logistic | Malthus 无时滞，实际种群响应有延迟 |
| 多物种相互作用 | Lotka-Volterra | Malthus 是单物种模型 |
| 细菌/细胞培养 (对数生长期) | Malthus | 对数生长期 (log phase) 完美符合指数增长 |
| 有观测数据，需短期预测 | Malthus 拟合 | 简单拟合 + 短期外推是最快的 baseline |
| 人口增长趋势分析 | Logistic / Leslie | Malthus 长期高估; 1800-2020 世界人口约 T_d ≈ 50 年但正在放缓 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 观测散点图 | (t, N_data) scatter plot |
| process | 对数线性检验图 | semilogy(t, N) — 验证指数性 (应成直线) |
| result | N(t) 双坐标图 | 左 y 轴 N(t), 右 y 轴 log₁₀ N(t) — 清晰显示指数特性 |
| result | 增长速率 dN/dt vs N | 线性关系 dN/dt = rN — 验证密度无关假设 |
| result | 敏感性分析 (r ± 10%) | 外推 50-100 年展示指数放大的不确定性 |
| result | 多国/多种群对比 | 不同 r 值的曲线叠加, 不同颜色 |

## 常见坑

1. **指数增长不可持续**: Malthus 在 1798 年即提出指数增长的不可持续性——粮食线性增长 vs 人口指数增长的矛盾。任何有资源限制的系统，长期预测必须改用 Logistic。建模时务必在结果讨论中声明"本模型在短期 (t < T_d) 内近似有效"。
2. **r 的对数线性回归偏差**: `polyfit(t, log(N), 1)` 假设 log(N) 的误差为同方差正态分布，但若 N 的测量误差为同方差 (如计数误差 ±5 个)，则 log(N) 的异方差性导致 OLS 非最优 → 使用非线性最小二乘 `nlinfit` + 原始尺度拟合，或加权最小二乘。
3. **时间单位一致性**: 如果 r 的单位是 year⁻¹，tspan 必须为年。若数据以日/月/小时给出，需统一转换。倍增时间 T_d 的单位与 r 的时间单位倒数一致。
4. **初值敏感性**: 指数函数 $N_0 e^{rt}$ 对 r 的敏感性远超 $N_0$——相对误差 $\Delta N/N \approx t \cdot \Delta r$。在 $t=50$ 年，$r$ 的 1% 误差导致 $N$ 约 50% 误差。务必报告 r 的置信区间。
5. **零或负值的对数问题**: 若 $N(t)=0$ 或负值 (不可能但有观测噪声/传感器误差时出现)，`log(N_data)` 返回 -Inf 或 NaN。预处理中剔除零值或加小正数偏移。
6. **遗忘初始瞬态**: 若数据起始于非零增长阶段 (如细菌培养的对数期而非延迟期)，Malthus 可拟合对数期，但不能解释之前的延迟期 (lag phase) 和之后的平稳期 (stationary phase)。需明确模型适用的时间窗口。

## 失效条件/反例 (强制小节)

- **条件1: 存在有限环境容量 K (资源限制)** → **表现**: 当种群接近承载能力时，人均增长率 $r$ 不再恒定，而是随密度递减。Malthus 模型预测 $N(t) \to \infty$ 与生物/物理现实矛盾。在接近 K 之前的过渡期，Malthus 预测的系统性正偏差随时间指数放大——预测值与真实值的相对误差 $(N_{malthus} - N_{true})/N_{true}$ 在 $t > \ln(K/N_0)/r$ 后快速增长。**应对**: 当目视观测数据出现 S 型曲线拐点时，改用 Logistic 模型 (PARADIGM-0802) $dN/dt = rN(1-N/K)$。短期 ($t \ll \ln(K/N_0)/r$) 仍可用 Malthus。

- **条件2: Allee 效应显著 (小种群的合作效应)** → **表现**: Malthus 模型中 $r$ 恒定，意味着不论种群多小，增长率都不变。存在 Allee 效应 (如繁殖需要最低密度才能找到配偶，或合作捕食/防御) 的种群在低密度时人均增长率反而降低甚至变负——这会加速灭绝，Malthus 低估了灭绝风险。在 $N < N_{Allee}$ (Allee 阈值) 时，Malthus 预测缓慢衰减，但实际种群可能崩溃。**应对**: 使用带 Allee 效应的修正: $dN/dt = rN(N - A)(1 - N/K)$，其中 $A > 0$ 为 Allee 阈值; 或至少用 Logistic + Allee 修正。

- **条件3: 增长率 r 不是常数 (环境变化/政策干预/季节效应)** → **表现**: Malthus 假设 $r$ 时不变。当环境条件改变 (如气候变暖、化肥投放、计划生育政策) 时，生长率实质是时变函数 $r(t)$。强制使用恒定 r 拟合时变数据 → 残差呈现系统性模式 (自相关)，拟合优度 R² 虚低。同时，基于恒定 r 的长期外推置信区间不可靠 (因为忽略了 r 的时变方差)。**应对**: (1) 使用分段 Malthus (不同时期拟合不同 r); (2) 使用 $r(t)$ 函数模型的 ODE: $dN/dt = r(t) \cdot N$; (3) 在报告中明确标注"假设 r 在预测期内保持当前值"。

## 文献

1. Malthus TR (1798). *An Essay on the Principle of Population.* London: J. Johnson. (经典原著, 首次提出指数增长与线性增长矛盾)
2. Murray JD (2002). *Mathematical Biology: I. An Introduction*, 3rd ed. Springer. Chapter 1. ISBN: 978-0387952239
3. Kot M (2001). *Elements of Mathematical Ecology.* Cambridge University Press. Chapter 1. ISBN: 978-0521802130
4. Hastings A (1997). *Population Biology: Concepts and Models.* Springer. ISBN: 978-0387948626

## 来源溯源

Malthus (1798) An Essay on the Principle of Population; 已有 matlab/mechanism/malthus_model.m; 培训模块 mechanism-population.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 扩展/替代 | PARADIGM-0802 (Logistic增长, 环境容量K限制的指数增长) |
| 替代 | PARADIGM-0803 (Leslie矩阵, 年龄结构化的种群增长) |
| 扩展 | PARADIGM-0804 (SEIR, 传染病传播本质是指数增长过程的SIR建模) |
| 前置 | PARADIGM-0807 (差分方程迭代器, 离散时间Malthus $N_{t+1}=(1+r)N_t$) |
