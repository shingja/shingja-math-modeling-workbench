# PARADIGM-0702-INVENTORY-EOQ 存贮论EOQ/(s,S)/报童/多周期⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0702-INVENTORY-EOQ |
| 类别/子类 | ⑦决策与博弈 / 存贮论 |
| 难度 | 中 |
| 适用题型关键词[] | 经济订货批量, EOQ, (s,S)策略, 报童模型, 库存优化, 多周期库存, 订货点, 安全库存, 提前期, 缺货成本 |
| confidence | high |
| source | 补强Ch25 / 教材1998_SilverPyke / 题解反推_存贮论类 |

## 数学形式

**经济订货批量 (EOQ — Economic Order Quantity)**:

总成本函数 (年):

$$TC(Q) = \frac{KD}{Q} + \frac{hQ}{2} + cD$$

其中 $KD/Q$ = 年订货成本, $hQ/2$ = 年均持有成本, $cD$ = 年采购成本。

最优订货批量:

$$Q^* = \sqrt{\frac{2KD}{h}}$$

最优年成本:

$$TC^* = \sqrt{2KDh} + cD$$

最优订货周期: $T^* = Q^* / D$ (年)。

**报童模型 (Newsvendor Model, 单周期随机需求)**:

设需求量 $X \sim F(\cdot)$ (CDF), 单位进货成本 $c$, 单位售价 $p$, 单位残值 $s$, 缺货惩罚 $g$。

过订成本 (overage): $c_o = c - s$ (订多了每单位损失)
欠订成本 (underage): $c_u = p - c + g$ (订少了每单位机会损失)

最优订货量 $Q^*$ 满足临界分位数 (Critical Fractile):

$$F(Q^*) = \frac{c_u}{c_u + c_o} = \frac{p - c + g}{(p - c + g) + (c - s)}$$

即 $Q^* = F^{-1}\left( \frac{c_u}{c_u + c_o} \right)$。

期望利润:

$$\mathbb{E}[\Pi(Q)] = (p - c) Q - (p - s) \mathbb{E}[\max(0, Q - X)] - g \mathbb{E}[\max(0, X - Q)]$$

**$(s, S)$ 策略 (多周期定期盘点)**:

- 每个盘点期检查库存位置 $I_t$
- 若 $I_t \leq s$ (订货点), 则订货至 $S$ (目标库存水平), 订货量 $Q = S - I_t$
- 若 $I_t > s$, 不订货

$s$ 和 $S$ 通过动态规划或启发式 (如 $s = \mu_{L+R} + z_{\alpha} \sigma_{L+R}$, $S = s + Q^*$) 确定。

**$(Q, R)$ 策略 (连续盘点)**:

- 库存位置降至 $R$ (再订货点) 时, 订货固定量 $Q$
- $R = \mu_L + z_{\alpha} \sigma_L$, $Q = \sqrt{2KD/h}$ (近似)

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $D$ | 年需求量 | >0 |
| $K$ | 每次订货固定成本 | >0 |
| $h$ | 单位年持有成本 | >0 |
| $c$ | 单位采购成本 | >0 |
| $p$ | 单位售价 | $>c$ |
| $s$ | 单位残值 | $<c$ |
| $g$ | 单位缺货惩罚 | $\geq 0$ |
| $c_u$ | 欠订成本 (underage) | $p - c + g$ |
| $c_o$ | 过订成本 (overage) | $c - s$ |
| $Q^*$ | 最优订货量 | 决策变量 |
| $s$ (策略) | 订货点 | 依服务水平 |
| $S$ (策略) | 最大库存水平 | $\geq s$ |
| $L$ | 提前期 (lead time) | $\geq 0$ |
| $\mu_{L+R}, \sigma_{L+R}$ | 提前期+盘点期内需求均值/标准差 | 需求预测输出 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 年需求量 $D$ | float | — | >0 | 极高—$Q^* \propto \sqrt{D}$, 需求预测误差放大 |
| 订货成本 $K$ | float | — | >0 | 中—$Q^* \propto \sqrt{K}$ |
| 持有成本率 $h$ | float | — | >0 | 中—$Q^* \propto 1/\sqrt{h}$ |
| 提前期 $L$ | float | 0 | $\geq 0$ | 高—直接影响再订货点 $R$ 和安全库存 |
| 需求标准差 $\sigma$ | float | — | $\geq 0$ | 极高—决定安全库存, 标准差低估导致高缺货率 |
| 目标服务水平 $\alpha$ | float | 0.95 | 0.80-0.99 | 高—$\alpha \to 1$ 时安全库存 $z_{\alpha} \to \infty$, 持有成本暴增 |
| 缺货惩罚 $g$ | float | 0 | $\geq 0$ | 高—直接改变报童分位数 |
| 残值 $s$ | float | 0 | $<c$ | 中—影响过订成本 |

**EOQ 解析解复杂度**: $O(1)$
**报童模型**: $O(1)$ (已知分位数函数) 或 $O(N)$ (经验分布排序)
**$(s,S)$ 动态规划**: $O(L \cdot S_{\text{max}}^2)$ 取决于离散化精度, 启发式 $O(1)$
**多产品联合补货**: $O(n^3)$ (联合优化), $O(n)$ (分解近似)

## MATLAB 实现

```matlab
% === EOQ 计算 ===
% 自写-见S5:inventory_optimize.m
function [Q_opt, TC_opt, T_opt] = eoq_solver(D, K, h, c)
    % D: 年需求量
    % K: 每次订货固定成本
    % h: 单位年持有成本
    % c: 单位采购成本 (不影响 Q*, 仅影响 TC)
    Q_opt = sqrt(2 * K * D / h);
    TC_opt = sqrt(2 * K * D * h) + c * D;
    T_opt = Q_opt / D;  % 最优订货周期 (年)
end

% === 报童模型 ===
function [Q_opt, expected_profit] = newsvendor_solver(c, p, s, g, demand_dist)
    % demand_dist: 需求分布对象 (如 makedist('Normal', mu, sigma))
    cu = p - c + g;  % 欠订成本
    co = c - s;       % 过订成本
    critical_ratio = cu / (cu + co);
    Q_opt = icdf(demand_dist, critical_ratio);
    
    % 期望利润 (数值积分验证)
    expected_profit = (p - c) * Q_opt - ...
        (p - s) * integral(@(x) max(0, Q_opt - x) .* pdf(demand_dist, x), 0, Q_opt) - ...
        g * integral(@(x) max(0, x - Q_opt) .* pdf(demand_dist, x), Q_opt, inf);
end

% === (s, S) 策略动态规划 ===
function [s_opt, S_opt, cost] = sS_policy_solver(D_dist, K, h, g, L, N_periods)
    % D_dist: 每期需求分布
    % L: 提前期 (期数)
    % N_periods: 规划期数
    % 状态空间离散化 + 后向归纳
    % [自写-见S5:inventory_optimize.m]
end

% === (Q, R) 连续盘点 ===
function [Q_opt, R_opt] = QR_policy_solver(D, sigma_D, K, h, g, L, alpha)
    Q_opt = sqrt(2 * K * D / h);  % EOQ 近似
    z = norminv(alpha);
    mu_L = L * D;
    sigma_L = sqrt(L) * sigma_D;
    R_opt = mu_L + z * sigma_L;
end
```

**锚点工具箱**: 无直接内置存贮论函数; `fmincon`/`fminsearch` 可用于数值优化验证
**自写 (S5)**: `inventory_optimize.m` — EOQ + Newsvendor + (s,S) DP + (Q,R) 连续盘点 + 敏感性分析

## Python 备选

```python
import numpy as np
from scipy.stats import norm
from scipy.optimize import minimize_scalar

# EOQ
def eoq(D, K, h, c=0):
    Q_opt = np.sqrt(2 * K * D / h)
    TC_opt = np.sqrt(2 * K * D * h) + c * D
    return Q_opt, TC_opt

# 报童模型
def newsvendor(c, p, s, g, dist):
    """dist: scipy.stats 分布对象"""
    cu = p - c + g
    co = c - s
    critical_ratio = cu / (cu + co)
    Q_opt = dist.ppf(critical_ratio)
    return Q_opt

# 报童模型 (经验分布, 非参数)
def newsvendor_empirical(demand_samples, c, p, s, g):
    cu = p - c + g; co = c - s
    cr = cu / (cu + co)
    Q_opt = np.quantile(demand_samples, cr)
    return Q_opt

# (s, S) 策略 -- 模拟优化
def sS_simulation(s, S, demand_stream, K, h, g, c, L=0):
    inv = S  # 初始库存
    total_cost = 0
    for d in demand_stream:
        if inv <= s:
            total_cost += K + c * (S - inv)  # 订货成本
            inv = S
        inv -= d
        if inv < 0:
            total_cost += g * abs(inv)  # 缺货惩罚
            inv = 0
        total_cost += h * inv  # 持有成本
    return total_cost
```

备选库: `scipy.optimize` (数值优化 s, S), `cvxpy` (报童凸优化), `pulp` (整数/批量订货约束)

## 选型决策树

- **需求确定 + 无限期 + 不允许缺货** → EOQ (解析解, 基准模型)
- **需求确定 + 有限生产率** → 经济生产批量 (EPQ, $Q^* = \sqrt{2KD/h \cdot P/(P-D)}$)
- **需求随机 + 单周期 + 订货一次** → 报童模型 (Newsvendor), 需求分布需已知或可估计
- **需求随机 + 多周期 + 定期盘点 + 固定订货成本** → $(s, S)$ 策略 (DP 或启发式)
- **需求随机 + 多周期 + 连续盘点** → $(Q, R)$ 策略
- **需求分布未知 (仅有历史样本)** → 报童经验分位数 (样本分位数, Data-driven Newsvendor)
- **多产品联合补货** → 联合补货模型 (Joint Replenishment Problem, JRP)
- **需求有明显季节性/趋势** → EOQ 失效 → 动态批量 (Wagner-Whitin 或 Silver-Meal 启发式)
- **供应不确定 (随机提前期/随机产量)** → 鲁棒库存模型或仿真实证
- **多级供应链 (多仓库/多零售商)** → 级库存 (echelon stock) 策略, 见供应链管理相关文献

## 典型图型

- **raw**: 需求直方图 + 分布拟合 (报童模型基础)
- **process**: EOQ 成本分解图 ($TC$ vs $Q$ — 订货成本曲线、持有成本曲线、总成本曲线, 标注 $Q^*$); 报童期望利润 vs $Q$ + 标注 $Q^*$
- **result**: $(s,S)$ 策略模拟轨迹 (库存水平 vs 时间, 标注订货时刻); 安全库存 vs 服务水平 ($z_{\alpha} \sigma_L$)
- **进阶**: 灵敏度龙卷风图 (输入参数对 $Q^*$ 的影响), 多策略成本对比柱状图

## 常见坑

1. **EOQ 假设需求恒定 — 在季节/趋势需求下误用**: 年总成本除以 12 得到月均 → 若夏季需求为冬季 3 倍, EOQ 导致夏季缺货、冬季积压。检测: 需求变异系数 $C_V > 0.3$ 应警惕
2. **报童模型错用假定分布**: 假设需求为正态分布 (负值截断), 实际为 Gamma/对数正态 (右偏, 重尾) → 最优订货量偏差可达 30-50%。务必绘制 Q-Q plot 检验
3. **混淆周期盘点与连续盘点**: $(s,S)$ 是周期盘点 (每 $R$ 期检查一次), $(Q,R)$ 是连续盘点 → 实现错用导致安全库存公式不对 (连续盘点只需覆盖 $L$ 提前期, 周期盘点需覆盖 $L+R$)
4. **忽略订货成本 $K$ 的跳跃**: 若 EOQ 给出 $Q^* = 200$ 但供应商最小起订量 = 500 (或批量折扣) → $K$ 不再是固定成本, EOQ 解不可用, 需枚举比较
5. **安全库存公式 $z_{\alpha} \sigma_L$ 中 $\sigma_L$ 计算错误**: 若每期需求独立且同分布, $\sigma_L = \sqrt{L} \sigma_1$ (或 $\sqrt{L+R}$ 对周期盘点), 不是 $L \sigma_1$

## 失效条件/反例 (强制小节)

- **条件1**: 需求分布误设 (假设正态, 实际重尾) — 报童模型的最优订货量由 $F^{-1}$ (临界分位数) 决定, 正态分布的尾部远轻于实际 (如 Pareto/对数正态), 导致 $Q^*$ 被严重低估。**表现**: 若真实需求有 5% 概率超过正态假设下 99.9% 分位数, 缺货率从目标 5% 飙升至 15-20%, 缺货惩罚成本暴涨。**检测**: Q-Q plot (正态概率图) 或 Shapiro-Wilk 检验; 计算样本峰度 (kurtosis > 3 提示重尾)。**替代**: 使用数据驱动报童 (样本分位数法), 或保守假设需求服从重尾分布 (如 Weibull/Gamma 拟合)
- **条件2**: EOQ 在非平稳需求 (季节性/趋势) 下被套用 — EOQ 假设年需求率 $D$ 恒定且无限期, 若需求呈上升趋势或季性波动, 单一 $Q^*$ 无法适应。**表现**: 旺季前库存耗尽 (缺货), 淡季库存积压 (过期/损耗), 平均总成本远高于动态策略。**检测**: 时序图 (需求 vs 月份) + 季节性分解 (STL)。**替代**: 动态批量 (Dynamic Lot Sizing)—Wagner-Whitin 算法 (精确, $O(T^2)$), 或 Silver-Meal 启发式 ($O(T)$)
- **条件3**: 订货成本 $K$ 在 $(s,S)$ 动态规划中被忽略或近似 — 若 $K = 0$, 则 $s = S$ (order-up-to/base-stock 策略退化为每期补货至 $S$); 但 $K > 0$ 时, 不加区分的 $(s,S)$ 启发式近似可能导致频繁小额订货。**表现**: $s$ 设得太高导致几乎每期都触发订货 (batching failure)。**检测**: 计算模拟中每期订货频率 = (订货次数) / (总期数), 若接近 1 且 $K$ 非零说明策略退化
- **条件4**: 多产品场景下分别独立优化忽略联合补货收益 — 若多个产品共享同一供应商/运输, 合并订货可分摊固定成本 $K$, 但独立 EOQ 会给出不同订货周期导致 $K$ 重复计取。**替代**: 联合补货模型 (JRP)—共同周期 $T$, 或 Kannenberg 启发式

## 文献

1. Silver, E. A., Pyke, D. F., & Peterson, R. (1998). *Inventory Management and Production Planning and Scheduling* (3rd ed.). Wiley. ISBN: 978-0471119470.
2. Zipkin, P. H. (2000). *Foundations of Inventory Management*. McGraw-Hill. ISBN: 978-0256113792.
3. Nahmias, S. & Olsen, T. L. (2015). *Production and Operations Analysis* (7th ed.). Waveland Press. ISBN: 978-1478623069.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第25章 存贮论
- 论文三元组: Harris 1913 (EOQ 原始论文, "How many parts to make at once"), Silver 1998 Inventory Management
- 开源仓库: [scm-optimization](https://github.com/search?q=inventory+optimization+python) (多个 Python 库存优化库)

## 关联范式卡

组合: PARADIGM-0601-QUEUING-ADV (排队+库存联合优化—报童与 M/M/c 结合), PARADIGM-0105-INTERP-FIT (需求分布拟合/参数估计)
替代: PARADIGM-0308-DP (多周期库存 → 动态规划精确解), PARADIGM-0307-MDP (随机需求多期决策 → 马尔可夫决策过程)
前置: PARADIGM-0103-PROBSTAT (概率分布/条件期望/分位数—报童模型核心)
