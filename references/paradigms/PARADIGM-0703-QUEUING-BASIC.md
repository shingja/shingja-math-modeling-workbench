# PARADIGM-0703 M/M/1排队基础⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0703 |
| 类别/子类 | ⑦综合 / 排队论 |
| 难度 | 低 |
| 适用题型关键词[] | 排队论, M/M/1, 等待队列, 服务台, 到达率, 服务率, 系统队长, 等待时间, 生灭过程 |
| confidence | high |
| source | Kleinrock (1975) Wiley |

## 数学形式

**M/M/1 假设:**
- 到达: Poisson 过程，速率 $\lambda$ (M=Markovian/Memoryless)
- 服务: 指数分布，速率 $\mu$
- 1 个服务台
- 无限队长 + FCFS 调度

**生灭过程 (Birth-Death Process):**
$$\lambda_n = \lambda, \quad \mu_n = \mu \quad (\forall n \geq 0)$$

**平稳分布 (几何分布):**
$$\pi_n = (1 - \rho)\rho^n, \quad \rho = \frac{\lambda}{\mu} < 1$$

其中 $\rho$ 为服务强度/利用率。

**关键性能指标:**
- 系统平均队长: $L = \frac{\rho}{1-\rho} = \frac{\lambda}{\mu-\lambda}$
- 队列平均等待队长: $L_q = \frac{\rho^2}{1-\rho}$
- 系统平均逗留时间 (Little's Law): $W = \frac{L}{\lambda} = \frac{1}{\mu-\lambda}$
- 队列平均等待时间: $W_q = \frac{L_q}{\lambda} = \frac{\rho}{\mu-\lambda}$

**Little's Law (普适):** $L = \lambda W$ (任何稳定排队系统)

**M/M/c 扩展 (多服务台):**
$$\pi_n = \begin{cases} \pi_0 \frac{(c\rho)^n}{n!} & n \leq c \\ \pi_0 \frac{c^c \rho^n}{c!} & n > c \end{cases}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| lambda | double | — | [0, ∞) | 极高 — 接近 μ 时 L,W 爆炸 |
| mu | double | — | >lambda | 极高 — 决定稳定性 |
| c (服务台数) | int | 1 | [1, ∞) | 中 — 多台缓解拥堵 |
| 计算复杂度 | — | — | O(c) 解析 | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[L, Lq, W, Wq, pi, feasible] = mmc_queue(lambda, mu, c, K)
% K: 可选，系统容量 (默认 Inf)
% feasible: false 若 ρ ≥ c (不稳定)
```

锚点: 自写-见S5:mmc_queue.m

```matlab
function [L, Lq, W, Wq, pi, feasible] = mmc_queue(lambda, mu, c, K)
    rho = lambda / (c * mu);
    if rho >= 1
        feasible = false;
        return;
    end
    feasible = true;
    
    % 计算 pi_0 (M/M/c 无限容量)
    sum_term = 0;
    for n = 0:c-1
        sum_term = sum_term + (c*rho)^n / factorial(n);
    end
    pi_0 = 1 / (sum_term + (c*rho)^c / (factorial(c)*(1-rho)));
    
    % 有限容量修正 (M/M/c/K)
    if nargin >= 4 && ~isinf(K)
        % K-截断的归一化
        for n = c+1:K
            pi_n = pi_0 * c^c * rho^n / factorial(c);
        end
        pi_0 = 1 / sum(pi);  % 重新归一化
    end
    
    Lq = pi_0 * (c*rho)^c * rho / (factorial(c)*(1-rho)^2);
    Wq = Lq / lambda;
    W = Wq + 1/mu;
    L = lambda * W;  % Little's Law
end
```

## Python 备选

```python
# ciw (Ciw 排队论库)
import ciw
N = ciw.create_network(
    arrival_distributions=[ciw.dists.Exponential(1/lambda)],
    service_distributions=[ciw.dists.Exponential(1/mu)],
    number_of_servers=[1]
)
ciw.seed(42)
Q = ciw.Simulation(N)
Q.simulate_until_max_time(1000)
recs = Q.get_all_records()
```

## 选型决策树

- **M/M/1 解析** — 简单排队场景，$\lambda$ 和 $\mu$ 稳定
- **M/M/c** — 多服务台 (银行柜台、收费站)
- **M/G/1** — 服务时间非指数 (如固定服务时间 M/D/1) → 需 Pollaczek-Khinchine 公式
- **排队网络** — 多队列串联/并联 (Jackson Network) → 仿真

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 到达时间间隔 / 服务时间直方图 | 验证分布假设 |
| result | L(ρ) 曲线 (ρ vs 平均队长) | 展示非线性增长 |
| result | 平稳分布 π_n 柱状图 | 状态概率 |

## 常见坑

1. **ρ → 1 爆炸**: 服务强度接近1时 L → ∞ → 系统崩溃。实际系统需留余量 ρ < 0.8
2. **Poisson 到达不成立**: 高峰期成批到达 → 用批量到达模型 (M^X/M/1)
3. **M/M/c 的 Erlang-C**: 等待概率 (而非队长) 在呼叫中心更常用

## 失效条件/反例 (强制小节)

- **条件1: 到达过程非平稳 (如早晚高峰)** → 表现: 固定 λ 的 M/M/1 在高峰期严重低估队长，低谷期高估。**应对**: 使用时变到达率的 Mt/M/1 或分段稳态模型 (Piecewise Stationary)
- **条件2: 服务时间方差极大 (如维修时间有时几分钟有时几小时)** → 表现: 指数分布假设 CV=1，实际 CV>>1 时 M/M/1 严重低估队长 (M/G/1 公式: L = ρ + ρ²(1+CV²)/[2(1-ρ)])。**应对**: 使用 M/G/1 模型 (需服务时间分布) 或仿真

## 文献

1. Kleinrock L. (1975). *Queueing Systems, Volume 1: Theory*. Wiley. ISBN: 978-0471491101
2. Gross D. & Harris C.M. (1998). *Fundamentals of Queueing Theory*, 3rd ed. Wiley. ISBN: 978-0471170839

## 来源溯源

自写 mmc_queue.m; 运筹学排队论章节

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (仿真) | PARADIGM-0701 (MCMC) |
| 组合 (优化) | PARADIGM-0102 (整数规划, 设施选址) |
| 前置 | PARADIGM-0702 (马尔科夫链) |
