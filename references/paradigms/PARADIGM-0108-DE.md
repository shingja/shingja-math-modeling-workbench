# PARADIGM-0108 差分进化DE⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0108 |
| 类别/子类 | ①优化 / 进化算法 |
| 难度 | 中 |
| 适用题型关键词[] | 差分进化, 进化算法, 连续优化, 全局优化, 变异, 交叉, 选择 |
| confidence | high |
| source | matlab/optim/differential_evolution.m |

## 数学形式

**标准 DE/rand/1/bin 策略:**

**变异 (Mutation):**
$$\mathbf{v}_i = \mathbf{x}_{r1} + F \cdot (\mathbf{x}_{r2} - \mathbf{x}_{r3})$$

其中 $r1, r2, r3$ 为互异且不同于 $i$ 的随机索引。

**交叉 (Crossover / Binomial):**
$$u_{i,j} = \begin{cases} v_{i,j} & \text{if } \text{rand}(0,1) \leq CR \text{ or } j = j_{rand} \\ x_{i,j} & \text{otherwise} \end{cases}$$

**选择 (Selection / Greedy):**
$$\mathbf{x}_i^{G+1} = \begin{cases} \mathbf{u}_i & \text{if } f(\mathbf{u}_i) \leq f(\mathbf{x}_i^G) \\ \mathbf{x}_i^G & \text{otherwise} \end{cases}$$

**变量表:**
- $\mathbf{x}_i^G$ — 第 $G$ 代第 $i$ 个体 ($d$ 维)
- $\mathbf{v}_i$ — 变异向量 (donor vector)
- $\mathbf{u}_i$ — 试验向量 (trial vector)
- $F \in [0, 2]$ — 缩放因子，控制差分扰动幅度
- $CR \in [0, 1]$ — 交叉概率
- $j_{rand}$ — 随机维度索引，确保至少一维来自 $\mathbf{v}_i$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| obj_func | function_handle | — | 接受向量返回标量 | — (问题定义) |
| lb | double[] | — | 变量下界 | 中 — 搜索空间定义 |
| ub | double[] | — | 变量上界 | 中 |
| pop_size | int | 10×dim | [5×dim, 20×dim] | 高 — <5×dim→多样性不足；>20×dim→浪费 |
| max_gen | int | 200×dim | [50×dim, 500×dim] | 低 |
| F | double | 0.8 | [0.4, 1.0] | 高 — 过小收敛慢，过大→随机搜索 |
| CR | double | 0.9 | [0.1, 1.0] | 高 — 过高→贪婪收敛，过低→搜索慢 |
| 时间复杂度 | — | — | O(pop_size × dim × max_gen) 每代 | — |

## MATLAB 实现

函数签名:
```matlab
[x_best, f_best, convergence] = differential_evolution(obj_func, lb, ub, pop_size, max_gen, F, CR)
```

锚点: `matlab/optim/differential_evolution.m` — 自写实现，基于 Storn & Price (1997) DE/rand/1/bin 经典策略。含边界反射处理 (boundary reflection)。

- `x_best` — 最优解向量 (1×dim)
- `f_best` — 最优目标函数值
- `convergence` — 每代最优值记录

## Python 备选

```python
from scipy.optimize import differential_evolution
result = differential_evolution(obj_func, bounds=list(zip(lb, ub)),
                                strategy='best1bin', maxiter=max_gen,
                                popsize=pop_size, mutation=(0.5, 1.5),
                                recombination=CR, seed=42)
# result.x, result.fun, result.success
```

或自定义实现:
```python
import numpy as np
def de(obj_func, lb, ub, pop_size=50, max_gen=1000, F=0.8, CR=0.9):
    dim = len(lb)
    pop = np.random.uniform(lb, ub, (pop_size, dim))
    fitness = np.apply_along_axis(obj_func, 1, pop)
    # ... 迭代主循环 (变异-交叉-选择)
```

## 选型决策树

- **用 DE** — 连续域全局优化，非凸、不可微、黑箱目标函数；旋转不变性好
- **用 GA (PARADIGM-0105)** — 离散/组合变量，或需要约束处理灵活性
- **用 PSO (PARADIGM-0106)** — 低维 (dim<30)、单模态倾向，快速收敛可接受
- **用 GWO (PARADIGM-0110)** — 简单实现、参数少，但可能早熟
- **用 surrogateopt** — 目标函数评估昂贵 (如 CFD 仿真)，需要代理模型
- **用 fmincon (多起点)** — 梯度可用，局部优化可保证
- **Trade-off:** DE 鲁棒性最好 (旋转不变性) 但收敛速度中等；PSO 收敛更快但易早熟；GWO 最简单但多样性差

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 目标函数等高线图 (contour) | 2D 展示搜索景观 |
| process | 种群散点图演化 (generations 1, mid, final) | 三子图展示种群收敛过程 |
| result | 收敛曲线 (best + mean fitness vs generation) | 双线: 最优+均值，观察多样性 |

## 常见坑

1. **F 值选择:** F<0.4 → 搜索步长过小，种群多样性丧失，收敛至局部最优；F>1.0 → 近似随机搜索，收敛极慢。推荐 F∈[0.5, 0.9] 先试
2. **CR 值选择:** CR 过高 → 试验向量大部分来自变异向量，搜索过于激进；CR 过低 → 维度更新太少，收敛缓慢。可分离问题 CR 宜小 (0.1-0.5)，不可分离宜大 (0.9)
3. **种群规模不足:** pop_size < 5×dim → 多样性不足，算法本质退化为多个独立爬山。推荐 pop_size = 10×dim
4. **边界处理:** 简单截断 (clamping) 会导致种群在边界堆积；推荐边界反射或周期性映射
5. **Stagnation (停滞):** 所有个体收敛到同一区域但非最优 → 重启部分种群或增大 F

## 失效条件/反例 (强制小节)

- **条件1: 高度约束问题 (多个等式约束)** → DE 变异操作频繁产生不可行解，修复率超 90%，搜索效率崩溃。**表现:** 种群中几乎所有个体不可行，收敛曲线平坦且远离可行域 → 改用 surrogateopt 或 fmincon 多起点法
- **条件2: 离散/类别决策变量** → DE 设计用于连续空间，对离散变量做四舍五入 (rounding) 会破坏搜索结构，差分向量失去意义。**表现:** 种群快速陷入某离散点无法逃离，最终解质量差 → 改用 GA (PARADIGM-0105)

## 文献

1. Storn R. & Price K. (1997) "Differential Evolution — A Simple and Efficient Heuristic for Global Optimization over Continuous Spaces." *Journal of Global Optimization*, 11:341-359. DOI: [10.1023/A:1008202821328](https://doi.org/10.1023/A:1008202821328)
2. Price K., Storn R. & Lampinen J. (2005) *Differential Evolution: A Practical Approach to Global Optimization*. Springer. ISBN 978-3540209508

## 来源溯源

`matlab/optim/differential_evolution.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (离散/组合) | PARADIGM-0105 (GA) |
| 对比 (群智能) | PARADIGM-0106 (PSO) |
| 对比 (群智能) | PARADIGM-0110 (GWO) |
