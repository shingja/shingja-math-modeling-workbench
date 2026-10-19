# PARADIGM-0704 存贮论基础EOQ⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0704 |
| 类别/子类 | ⑦综合 / 存贮论 |
| 难度 | 低 |
| 适用题型关键词[] | EOQ, 经济订货批量, 库存优化, 订货成本, 持有成本, 安全库存, 报童模型 |
| confidence | high |
| source | Silver, Pyke & Peterson (1998) Wiley |

## 数学形式

**经典 EOQ (确定性需求):**
- 需求率: $D$ (单位/年)
- 每次订货固定成本: $K$ (元/次)
- 单位年持有成本: $h$ (元/单位·年)

**年总成本:**
$$TC(Q) = \frac{KD}{Q} + \frac{hQ}{2} + cD$$

**最优订货量:**
$$Q^* = \sqrt{\frac{2KD}{h}}$$

**最优订货周期:**
$$T^* = \frac{Q^*}{D} = \sqrt{\frac{2K}{hD}}$$

**年最小成本:**
$$TC^* = \sqrt{2KDh} + cD$$

**报童模型 (Newsvendor, 随机需求):**
需求 $X \sim F(\cdot)$, 订购量 $Q$:
$$Q^* = F^{-1}\left(\frac{c_u}{c_u + c_o}\right)$$

其中 $c_u$ = 缺货成本 (underage), $c_o$ = 过量成本 (overage)。

**临界比率 (Critical Ratio):**
$$CR = \frac{c_u}{c_u + c_o}$$

**含安全库存的 (s,S) 策略:**
- $s$ = 再订货点 (Reorder Point)
- $S$ = 最大库存水平

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| D (年需求) | double | — | >0 | 高 — Q* ∝ √D |
| K (订货成本) | double | — | >0 | 中 — Q* ∝ √K |
| h (持有成本) | double | — | >0 | 中 — Q* ∝ 1/√h |
| c_u (缺货成本) | double | — | >0 | 极高 — 决定报童CR |
| c_o (过量成本) | double | — | >0 | 极高 — 决定报童CR |

## MATLAB 实现

函数签名 (自写):
```matlab
% EOQ
[Q_star, T_star, TC_star] = eoq(D, K, h, c)

% 报童模型
[Q_star, expected_cost] = newsvendor(demand_dist, c_u, c_o)

% (s,S) 仿真
[total_cost, service_level] = inventory_simulation(D, lead_time, K, h, c_u, c_o)
```

锚点: 自写-见S5:eoq.m, newsvendor.m

```matlab
function [Q_star, T_star, TC_star] = eoq(D, K, h, c)
    Q_star = sqrt(2*K*D/h);
    T_star = Q_star / D;
    TC_star = sqrt(2*K*D*h) + c*D;
end

% 报童模型 (正态需求)
function Q_star = newsvendor_normal(mu, sigma, c_u, c_o)
    CR = c_u / (c_u + c_o);
    Q_star = norminv(CR, mu, sigma);
end
```

## Python 备选

```python
import numpy as np
from scipy.stats import norm

def eoq(D, K, h, c=0):
    Q = np.sqrt(2*K*D/h)
    T = Q/D
    TC = np.sqrt(2*K*D*h) + c*D
    return Q, T, TC

def newsvendor_normal(mu, sigma, c_u, c_o):
    CR = c_u / (c_u + c_o)
    return norm.ppf(CR, mu, sigma)
```

## 选型决策树

- **EOQ** — 确定性需求 + 稳定订货/持有成本
- **报童模型** — 单周期 + 随机需求 (时尚品、易腐品)
- **(s,S) / (r,Q)** — 多周期 + 随机需求 + 固定订货成本
- **动态规划库存** — 时变需求 + 有限期界
- **供应链契约** — 多方博弈 (供应商-零售商协调)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | TC(Q) 曲线 (订货/持有/总成本) | 展示 Q* 处最低 |
| result | 库存水平锯齿图 (时间序列) | EOQ 周期 |
| result | 报童模型: CR线 + 需求CDF | 展示 Q* 几何意义 |

## 常见坑

1. **EOQ 假设刚性需求**: 需求波动或趋势 → EOQ 不再最优 → 用动态 EOQ 或 Wagner-Whitin 算法
2. **忽略订货提前期**: EOQ 考虑 T* 周期，但未考虑提前期 LT → 需计算再订货点 $ROP = D\cdot LT$
3. **报童模型: 需求分布选择极度敏感**: 正态 vs Gamma 对极端分位数 Q* 影响极大

## 失效条件/反例 (强制小节)

- **条件1: 需求量身定制 (MTO/Make-to-Order 生产模式)** → 表现: 无库存持有成本，EOQ 模型给出 $Q^* = \sqrt{2KD/h}$ 但 h≈0 → Q*→∞ 无意义。**应对**: MTO 场景使用生产批量模型 (EPQ/EMQ) 或按订单生产，不需要 EOQ
- **条件2: 季节性需求剧烈波动** → 表现: 年需求 D 恒定假设不成立，静态 EOQ 在旺季库存不足 (缺货)，在淡季库存积压。**应对**: 使用动态批量 (Dynamic Lot Sizing) 的 Wagner-Whitin 算法或 Silver-Meal 启发式

## 文献

1. Silver E.A., Pyke D.F. & Peterson R. (1998). *Inventory Management and Production Planning and Scheduling*, 3rd ed. Wiley. ISBN: 978-0471119470
2. Zipkin P.H. (2000). *Foundations of Inventory Management*. McGraw-Hill. ISBN: 978-0256113792

## 来源溯源

自写 eoq.m / newsvendor.m; 运筹学存贮论章节

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (仿真) | PARADIGM-0701 (MCMC) |
| 组合 (优化) | PARADIGM-0101 (LP) |
| 组合 (博弈) | PARADIGM-0701-GAME-NASH |
