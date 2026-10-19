# PARADIGM-0601-QUEUING-ADV 排队论M/G/1+Little定律+仿真⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0601-QUEUING-ADV |
| 类别/子类 | ⑥综合与机理 / 排队论 |
| 难度 | 高 |
| 适用题型关键词[] | 排队系统, M/G/1, Little定律, 服务台, 等待时间, 队列长度, 仿真, 到达率, 服务率, 系统容量 |
| confidence | high |
| source | 补强Ch06 / 论文1975_Kleinrock / 题解反推_排队论类 |

## 数学形式

**M/G/1 Pollaczek-Khinchin (P-K) 均值公式**:

$$\mathbb{E}[W_q] = \frac{\lambda \mathbb{E}[S^2]}{2(1 - \rho)} = \frac{\lambda (\sigma_S^2 + \mathbb{E}[S]^2)}{2(1 - \rho)}$$

其中 $\rho = \lambda \mathbb{E}[S] < 1$ (系统负载/利用率), $\sigma_S^2$ 为服务时间方差。

$$\mathbb{E}[L_q] = \lambda \mathbb{E}[W_q] \quad \text{(Little's Law 应用于队列)}$$

**Little 定律 (通用守恒律)**:

$$L = \lambda W, \quad L_q = \lambda W_q, \quad \mathbb{E}[N] = \lambda \mathbb{E}[T]$$

其中 $L$ = 系统平均顾客数, $\lambda$ = 有效到达率, $W$ = 系统平均逗留时间。

**M/M/c 模型 (Erlang-C 公式)**:

$$P(\text{排队}) = \frac{(c\rho)^c}{c!(1-\rho)} \left/ \left[ \sum_{n=0}^{c-1} \frac{(c\rho)^n}{n!} + \frac{(c\rho)^c}{c!(1-\rho)} \right] \right.$$

$$\mathbb{E}[W_q] = \frac{P(\text{排队})}{c\mu(1-\rho)}, \quad \rho = \frac{\lambda}{c\mu}$$

**M/G/1 P-K 变换公式 (Laplace 域)**:

$$\widetilde{W}_q(s) = \frac{s(1-\rho)}{s - \lambda + \lambda \widetilde{B}(s)}, \quad \widetilde{B}(s) = \mathbb{E}[e^{-sS}]$$

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $\lambda$ | 到达率 (Poisson) | 0.1-100 /单位时间 |
| $\mu$ | 服务率 (单台) | $\mu > \lambda/c$ |
| $c$ | 服务台数 | 1-50 |
| $\rho$ | 系统利用率 | 0 < $\rho$ < 1 |
| $\mathbb{E}[S]$ | 期望服务时间 | 取决于应用 |
| $\sigma_S^2$ | 服务时间方差 | 0 (M/D/c) 到 $\mathbb{E}[S]^2$ (M/M/c) 以上 |
| $\mathbb{E}[W_q]$ | 期望排队等待时间 | 输出量 |
| $\mathbb{E}[L_q]$ | 期望队列长度 | 输出量 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 到达率 $\lambda$ | float | 1.0 | >0 | 极高—主导 $\rho$, 接近饱和时指数级放大 |
| 服务率 $\mu$ (或服务时间分布) | float/dist | 1.2 | $\mu > \lambda/c$ | 极高—$\rho \to 1$ 时系统爆破 |
| 服务台数 $c$ | int | 1 | 1-100 | 高—每增加一台显著降低等待时间 |
| 服务时间方差 $\sigma_S^2$ | float | 1/$\mu^2$ | $\geq 0$ | 中—方差越大排队越长 (M/D < M/M < M/H₂) |
| 系统容量 $K$ (有限缓冲) | int | $\infty$ | 1-1000 | 高—容量限制引入丢包, 改变稳态分布 |
| 仿真时长 `T_sim` | float | 10000 | 1000-100000 | 中—需足够长消除瞬态偏倚 |

**M/G/1 P-K 公式复杂度**: $O(1)$ (解析解)
**M/M/c Erlang-C 复杂度**: $O(c)$ (求和截断)
**离散事件仿真 (DES) 复杂度**: $O(N_{\text{events}})$ = $O(\lambda T_{\text{sim}})$

## MATLAB 实现

```matlab
% === M/M/c 理论计算 (基础排队论) ===
% 锚点工具箱: matlab/simulation/queuing_theory.m (排队论基础仿真)
function [L, Lq, W, Wq, P_wait] = mmc_solver(lambda, mu, c)
    rho = lambda / (c * mu);
    % 计算 P0 (系统空闲概率)
    sum_term = 0;
    for n = 0:(c-1)
        sum_term = sum_term + (c*rho)^n / factorial(n);
    end
    last_term = (c*rho)^c / (factorial(c) * (1 - rho));
    P0 = 1 / (sum_term + last_term);
    % Erlang-C 排队概率
    P_wait = last_term * P0;
    % 期望队列长度与等待时间
    Lq = P_wait * rho / (1 - rho);
    Wq = Lq / lambda;
    L = Lq + lambda / mu;
    W = Wq + 1 / mu;
end

% === M/G/1 P-K 公式 ===
% 自写-见S5:queuing_advanced.m
function [Lq, Wq] = mg1_pk_solver(lambda, ES, ES2)
    rho = lambda * ES;
    if rho >= 1
        error('系统不稳定: ρ = %.4f ≥ 1', rho);
    end
    Wq = lambda * ES2 / (2 * (1 - rho));
    Lq = lambda * Wq;
end

% === 离散事件仿真 (DES) ===
% 自写-见S5:queuing_advanced.m
% 锚点参考: Simevents (Simulink 模块), 或手写 FEL (Future Event List) 循环
```

**锚点工具箱**: `matlab/simulation/queuing_theory.m` (基础 M/M/c 仿真)
**进阶自写 (S5)**: `queuing_advanced.m` — M/G/1 P-K 求解 + DES 通用框架 + Little 定律验证

## Python 备选

```python
import numpy as np
from scipy.special import factorial

# M/M/c Erlang-C
def mmc_solver(lmbda, mu, c):
    rho = lmbda / (c * mu)
    sum_term = sum((c*rho)**n / factorial(n) for n in range(c))
    last_term = (c*rho)**c / (factorial(c) * (1 - rho))
    P0 = 1 / (sum_term + last_term)
    P_wait = last_term * P0
    Lq = P_wait * rho / (1 - rho)
    Wq = Lq / lmbda
    L = Lq + lmbda / mu
    W = Wq + 1 / mu
    return L, Lq, W, Wq, P_wait

# M/G/1 P-K
def mg1_pk(lmbda, ES, ES2):
    rho = lmbda * ES
    assert rho < 1, f"Unstable: rho={rho:.3f}"
    Wq = lmbda * ES2 / (2 * (1 - rho))
    Lq = lmbda * Wq
    return Lq, Wq
```

备选库: `ciw` (离散事件仿真框架), `simpy` (通用 DES), `queueing-tool` (排队网络)

## 选型决策树

- **M/M/c 解析可解 + 到达/服务均为指数** → M/M/c Erlang-C 公式 (最简, 先尝试)
- **服务时间非指数但分布参数已知 (方差明确)** → M/G/1 P-K 公式 (只需求 $\mathbb{E}[S]$ 和 $\mathbb{E}[S^2]$)
- **到达过程非 Poisson (如批到达、突发流)** → 离散事件仿真 (DES) 别无选择
- **多节点串联/排队网络** → Jackson 网络 (乘积解) 或仿真
- **需要瞬态行为 (非稳态分析)** → DES 或流体近似
- **优化目标 (服务台数/容量决策)** → 排队论 + 成本模型联合优化, 见 PARADIGM-0702 (存贮论)
- **仿真规模大 (百万级事件)** → 优先用 `simpy`/`ciw` Python 框架, MATLAB 手写 FEL 在小规模下稳妥

**M/D/c vs M/M/c vs M/G/1 排队长度排序** (同 $\lambda$, $\mu$, $c$):
$$L_q^{M/D/c} < L_q^{M/M/c} < L_q^{M/H_2/c}$$

即: 确定性服务方差最小, 指数分布次之, 重尾分布方差最大, 排队最长。

## 典型图型

- **raw**: 到达间隔/服务时间直方图 + 分布拟合 (验证指数/一般分布假设)
- **process**: $\mathbb{E}[W_q]$ 随 $\rho$ 变化曲线 (多条 $c$ 值)、DES 瞬时队列长度轨迹
- **result**: $\rho$-$\mathbb{E}[W_q]$ 理论 vs 仿真对比图、$\mathbb{E}[L_q]$ vs $c$ (服务台灵敏度)
- **进阶**: Little 定律验证图 ($L$ vs $\lambda W$, 散点 + $y=x$ 参考线)

## 常见坑

1. **$\rho \geq 1$ 时直接套公式**: 稳态不存在, P-K/Eerlang-C 公式分母为零或负, 需先检查稳定性条件
2. **将 Little 定律当条件用而非验证用**: Little 定律是守恒律 (结果), 不是假设。常见错误: 用 $L=\lambda W$ 推导 $W$ 再反过来验证 $L$
3. **瞬态数据当稳态**: DES 前 20-30% 样本应作为预热 (warm-up) 丢弃, 否则低估/高估稳态指标
4. **服务时间分布误设为指数导致低估**: 真实系统中服务时间常有系数变异 $C_V > 1$ (重尾), 用 M/M/c 会严重低估排队
5. **M/G/1 P-K 只给均值**: 需要分位数/尾部分布时必须用 Laplace 逆变换或仿真, P-K 均值不能替代 SLA 分析

## 失效条件/反例 (强制小节)

- **条件1**: 到达过程非 Poisson — 突发性到达 (bursty traffic, 如网络数据包) 或批到达 → M/G/1 的 Poisson 假设被破坏, 队列长度预测偏差超 50%, 实际排队远长于理论值。**检测手段**: 到达间隔的系数变异 $C_V \neq 1$ (非指数)。**替代**: 离散事件仿真 (DES), 或用 G/G/1 近似 (Kingman 公式 $\mathbb{E}[W_q] \approx \frac{\rho}{1-\rho} \cdot \frac{C_A^2 + C_S^2}{2} \cdot \mathbb{E}[S]$)
- **条件2**: 有限缓冲 + 阻塞 — 系统容量 $K$ 有限, 顾客到达时满员即丢失 → Little 定律中 $\lambda$ 应是**有效**到达率 $\lambda_{\text{eff}} = \lambda (1 - P_{\text{loss}})$, 直接用名义 $\lambda$ 会导致 $L$ 严重高估。**模型修正**: 使用 M/M/c/K 有限容量模型或仿真统计有效到达率
- **条件3**: 服务时间分布未知且无法估计二阶矩 $\mathbb{E}[S^2]$ → P-K 公式无法直接应用。**替代**: 用 M/G/1 的分布鲁棒界 (如 $C_V$ 在 [0.5, 1.5] 间扫参), 或保守用 M/H₂ 重尾上界
- **条件4**: 顾客存在异质性 (如优先级分类) → 单类 M/G/1 不适用, 需 M/G/1 优先级排队 (non-preemptive/preemptive) 或仿真实例

## 文献

1. Kleinrock, L. (1975). *Queueing Systems, Volume 1: Theory*. Wiley. ISBN: 978-0471491101.
2. Gross, D. & Harris, C. M. (1998). *Fundamentals of Queueing Theory* (3rd ed.). Wiley. ISBN: 978-0471170839.
3. Shortle, J. F., Thompson, J. M., Gross, D., & Harris, C. M. (2018). *Fundamentals of Queueing Theory* (5th ed.). Wiley. ISBN: 978-1118943526.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第6章 排队论
- 论文三元组: Kleinrock 1975, Queueing Systems Vol.1, Little's Law + M/G/1 P-K
- 开源仓库: [Ciw](https://github.com/CiwPython/Ciw) (Python DES), [Queueing-tool](https://github.com/djordon/queueing-tool) (排队网络)

## 关联范式卡

组合: PARADIGM-0702-INVENTORY-EOQ (排队+库存联合优化), PARADIGM-0318-MC (MCMC 仿真排队系统)
替代: PARADIGM-0317-DES (通用离散事件仿真, 非 Markov 到达)
前置: PARADIGM-0103-PROBSTAT (概率论基础, 指数分布/Poisson过程/条件期望)
