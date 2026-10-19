# PARADIGM-0814 化学反应动力学ODE⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0814 |
| 类别/子类 | ⑧机理建模与PDE / 化学动力学 |
| 难度 | 中 |
| 适用题型关键词[] | 化学反应动力学, 质量作用定律, 速率方程, 刚性ODE, ode15s, Arrhenius, 催化 |
| confidence | high |
| source | Laidler (1987) Harper & Row |

## 数学形式

**质量作用定律 (Law of Mass Action):**

对反应 $\sum_i \nu_i A_i \to \sum_j \nu_j' B_j$:
$$r = k \prod_i [A_i]^{\nu_i}$$

其中 $k$ 为速率常数，$[A_i]$ 为浓度。

**Arrhenius 方程 (温度依赖):**
$$k(T) = A \cdot e^{-E_a/(RT)}$$

**反应网络 ODE 系统:**

对每个物种 $X_j$:
$$\frac{d[X_j]}{dt} = \sum_{\text{reactions}} \nu_{j,r} \cdot r_r$$

其中 $\nu_{j,r}$ 为物种 $j$ 在反应 $r$ 中的化学计量系数 (生成+，消耗-)。

**Michaelis-Menten 酶动力学:**
$$E + S \overset{k_1}{\underset{k_{-1}}{\rightleftharpoons}} ES \overset{k_{cat}}{\to} E + P$$

**准稳态近似 (QSSA) 下:**
$$\frac{d[P]}{dt} = \frac{V_{\max}[S]}{K_M + [S]}, \quad V_{\max}=k_{cat}[E]_0, \quad K_M=\frac{k_{-1}+k_{cat}}{k_1}$$

**刚性来源:** 速率常数跨多个数量级 (如 $k_1=10^6, k_{-1}=10^{-2}$) → ODE 系统刚性。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| k (速率常数) | double[] | — | (0, ∞) | 极高 — 决定时间尺度 |
| Ea (活化能) | double[] | — | >0 | 高 — 指数影响 k |
| solver | str | 'ode15s' | 'ode15s','ode23s','ode45' | 极高 — 刚性需 stiff solver |
| 反应模式 | — | — | 质量作用 / MM / Hill | — |

## MATLAB 实现

```matlab
% 酶动力学 Michaelis-Menten
mm_ode = @(t, y, Vmax, Km, S0) [
    -Vmax * y(1) / (Km + y(1));  % d[S]/dt
     Vmax * y(1) / (Km + y(1))   % d[P]/dt
];

[t, y] = ode15s(mm_ode, [0, 100], [S0; 0], [], Vmax, Km);

% 多反应网络 (刚性 → ode15s)
function dCdt = reaction_network(t, C, k, stoich_matrix)
    % stoich_matrix: n_species × n_reactions
    rates = zeros(n_reactions, 1);
    for r = 1:n_reactions
        rates(r) = k(r) * prod(C .^ reactant_orders(:,r));
    end
    dCdt = stoich_matrix * rates;
end

[t, C] = ode15s(@(t,C) reaction_network(t,C,k,S), [0,T], C0);
```

锚点: `ode15s` (MATLAB内置, 刚性ODE求解器)

## Python 备选

```python
from scipy.integrate import solve_ivp

def reaction_network(t, C, k, S):
    rates = k * np.prod(C ** reactant_orders, axis=1)
    return S @ rates

sol = solve_ivp(reaction_network, [0, T], C0, args=(k, S),
                method='BDF', rtol=1e-8)  # BDF for stiff
```

## 选型决策树

- **ode15s** — 刚性 (速率常数跨多个数量级)，精度要求中等到高
- **ode23s** — 刚性 + 低精度需求 (快速求解)
- **ode45** — 非刚性 (所有反应速率相近)
- **Gillespie (PARADIGM-0709)** — 小分子数，随机效应重要

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 反应网络图 (物种=节点, 反应=边) | 可视化网络拓扑 |
| result | 物种浓度时间序列 (semilogy) | 展示多时间尺度 |
| result | 相平面图 (如 [S] vs [ES]) | 展示 QSSA 有效性 |

## 常见坑

1. **刚性检测失败用 ode45**: ode45 在刚性系统上步长极小 (自适应步长在快慢时间尺度间振荡) → 极慢 → 用 ode15s
2. **质量守恒违反**: 数值误差累积 → 总质量漂移 → 检查 $\sum C_i(t)$ 守恒或增加 reltol
3. **QSSA 假设不成立**: 酶浓度不满足 $[E]_0 \ll [S]_0 + K_M$ 时 QSSA 不可用 → 需解完整 ODE

## 失效条件/反例 (强制小节)

- **条件1: 速率常数 $k$ 跨越 10 个数量级以上 (极端刚性)** → 表现: ode15s 的 BDF 公式阶数被迫降至 1 阶，步长极小 ($\sim$ min time scale)，积分 1 秒物理时间需数小时计算。**应对**: 用准稳态近似 (QSSA) 或部分平衡近似 (PEA) 消除最快反应，缩减为有效慢动力学
- **条件2: 空间非均匀 (如催化剂表面梯度)** → 表现: ODE 假设反应器内浓度均匀，实际催化反应表面浓度梯度 > 50% → 反应速率空间平均≠基于平均浓度的速率 (非线性平均偏差)。**应对**: 耦合反应-扩散方程 (PARADIGM-0811) 或使用 Thiele 模量进行效率因子修正

## 文献

1. Laidler K.J. (1987). *Chemical Kinetics*, 3rd ed. Harper & Row. ISBN: 978-0060438629
2. Fogler H.S. (2016). *Elements of Chemical Reaction Engineering*, 5th ed. Pearson. ISBN: 978-0133887518

## 来源溯源

ode15s; 化学反应工程教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0807 (ODE迭代器) |
| 组合 | PARADIGM-0811 (反应扩散) |
| 随机版 | PARADIGM-0709 (Gillespie) |
