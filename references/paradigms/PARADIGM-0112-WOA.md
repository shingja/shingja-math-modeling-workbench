# PARADIGM-0112 鲸鱼优化WOA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0112 |
| 类别/子类 | ①优化 / 群智能 |
| 难度 | 低 |
| 适用题型关键词[] | 鲸鱼优化, WOA, 气泡网捕食, 包围猎物, 螺旋更新, 全局优化 |
| confidence | high |
| source | matlab/optim/whale_optimization.m |

## 数学形式

WOA 模拟座头鲸气泡网捕食行为，包含三种位置更新机制，以概率 $p=0.5$ 切换包围与螺旋攻击:

**机制1 — 包围猎物 (Encircling Prey, |A| < 1):**
$$\mathbf{D} = |\mathbf{C} \cdot \mathbf{X}^*(t) - \mathbf{X}(t)|$$
$$\mathbf{X}(t+1) = \mathbf{X}^*(t) - \mathbf{A} \cdot \mathbf{D}$$

**机制2 — 气泡网攻击 (Bubble-net Attacking, 螺旋更新):**
$$\mathbf{D}' = |\mathbf{X}^*(t) - \mathbf{X}(t)|$$
$$\mathbf{X}(t+1) = \mathbf{D}' \cdot e^{bl} \cdot \cos(2\pi l) + \mathbf{X}^*(t)$$

**机制3 — 搜索猎物 (Search for Prey, |A| \geq 1):**
$$\mathbf{D} = |\mathbf{C} \cdot \mathbf{X}_{rand}(t) - \mathbf{X}(t)|$$
$$\mathbf{X}(t+1) = \mathbf{X}_{rand}(t) - \mathbf{A} \cdot \mathbf{D}$$

**系数向量:**
$$\mathbf{A} = 2a \cdot \mathbf{r} - a, \quad a = 2 - 2t/T_{max}$$
$$\mathbf{C} = 2 \cdot \mathbf{r}$$

**变量表:**
- $\mathbf{X}^*(t)$ — 当前最优鲸鱼位置 (猎物)
- $\mathbf{X}_{rand}(t)$ — 随机选择的鲸鱼位置
- $\mathbf{A}$ — 系数向量，$|\mathbf{A}|<1$ 包围，$|\mathbf{A}|\geq 1$ 探索
- $\mathbf{C}$ — 随机权重 ($0 \leq C \leq 2$)
- $b$ — 螺旋形状常数 (通常 $b=1$)
- $l$ — $[-1, 1]$ 均匀随机数
- $a$ — 从 2 线性递减至 0

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| obj_func | function_handle | — | 接受向量返回标量 | — (问题定义) |
| dim | int | — | [1, 100] | 低 |
| lb | double[] | — | 变量下界 | 低 |
| ub | double[] | — | 变量上界 | 低 |
| n_whales | int | 30 | [10, 100] | 中 — 太少→信息少，太多→计算浪费 |
| max_iter | int | 500 | [100, 2000] | 低 |
| b | double | 1.0 | [0.5, 2.0] | 低 — 控制螺旋紧密程度 |
| 时间复杂度 | — | — | O(n_whales × dim × max_iter) | — |

**注:** WOA 核心参数极少，仅需种群规模与螺旋常数 $b$。

## MATLAB 实现

函数签名:
```matlab
[best_pos, best_score, convergence] = whale_optimization(obj_func, dim, lb, ub, n_whales, max_iter)
```

锚点: `matlab/optim/whale_optimization.m` — 自写实现，基于 Mirjalili & Lewis (2016) 原始版本。含包围、螺旋攻击、随机搜索三机制及边界截断处理。

- `best_pos` — 最优鲸鱼位置 (1×dim)
- `best_score` — 最优适应度值
- `convergence` — 每代最优值记录

## Python 备选

```python
from mealpy import WOA
problem = {
    "fit_func": obj_func,
    "lb": lb,
    "ub": ub,
    "minmax": "min",
}
model = WOA.Whale(epoch=500, pop_size=30)
best_position, best_fitness = model.solve(problem)
```

或 scikit-opt:
```python
from sko import WOA
woa = WOA(func=obj_func, dim=dim, lb=lb, ub=ub, max_iter=500)
best_x, best_y = woa.run()
```

## 选型决策树

- **用 WOA** — 连续优化，多模态目标，螺旋机制提供良好局部求精能力；可分离函数表现优异
- **用 PSO (PARADIGM-0106)** — 单模态或弱多模态，追求最快收敛
- **用 DE (PARADIGM-0108)** — 非可分离旋转函数，需要旋转不变性保证
- **用 GWO (PARADIGM-0110)** — 参数更少，但早熟风险更高
- **用 SSA (PARADIGM-0113)** — 存在欺骗性局部最优，需要三角色机制
- **Trade-off:** WOA 在可分离多模态问题上优于 PSO/GWO，但在旋转函数上逊于 DE。螺旋机制增加约 10% 计算开销。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 搜索空间等高线 (contour) | 定位多模态景观 |
| process | 鲸鱼位置散点 + 螺旋路径可视化 | 展示包围→螺旋攻击过渡 |
| result | 收敛曲线 (线性 Y 轴) | 观察探索→开发阶段切换点 |

## 常见坑

1. **50/50 切换概率固定:** 包围与螺旋攻击的 $p=0.5$ 等概率切换是任意的 — 对某些问题应偏向包围 (探索) 或螺旋 (开发)。自适应 $p$ 变体可提升性能
2. **随机搜索阶段过长:** $|\mathbf{A}|\geq 1$ 时进行随机搜索探索，在简单问题上可能长期游荡浪费评估次数。可设置 $|\mathbf{A}|\geq 1$ 持续代数上限后强制收敛
3. **边界截断导致边界堆积:** 位置更新后越界的解被直接截断到边界 → 种群在边界处聚集，搜索单一化。可改用反射边界或随机重置
4. **高维旋转函数退化:** WOA 位置更新本质上是坐标轴对齐的 — 对于旋转后的基准函数 (如 Rotated Rastrigin)，性能大幅下降
5. **b 值的影响:** $b$ 控制螺旋紧密程度 — $b$ 过小→螺旋过于紧密 (几乎线性下降)，$b$ 过大→螺旋过于松散 (近似随机)。默认 $b=1$ 在多数问题上合理

## 失效条件/反例 (强制小节)

- **条件1: 旋转基准函数 (非可分离)** → WOA 的坐标轴对齐位置更新在旋转后性能大幅下降，无法有效利用变量间相关性。**表现:** 收敛曲线在简单旋转后变得平坦，最终解距全局最优甚远 → 改用 DE (PARADIGM-0108)，因其差分变异具有旋转不变性
- **条件2: 离散或排列问题 (如调度、TSP)** → WOA 算子是连续型的，对离散变量做取整/映射会破坏螺旋与包围的搜索结构。**表现:** 解质量随机徘徊，收敛曲线无下降趋势 → 改用 GA (PARADIGM-0105) 或 ACO (PARADIGM-0107)

## 文献

1. Mirjalili S. & Lewis A. (2016) "The Whale Optimization Algorithm." *Advances in Engineering Software*, 95:51-67. DOI: [10.1016/j.advengsoft.2016.01.008](https://doi.org/10.1016/j.advengsoft.2016.01.008)

## 来源溯源

`matlab/optim/whale_optimization.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 对比 (群智能) | PARADIGM-0106 (PSO) |
| 对比 (群智能) | PARADIGM-0110 (GWO) |
| 对比 (群智能) | PARADIGM-0113 (SSA) |
