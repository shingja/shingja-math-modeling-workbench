# PARADIGM-0113 麻雀搜索SSA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0113 |
| 类别/子类 | ①优化 / 群智能 |
| 难度 | 中 |
| 适用题型关键词[] | 麻雀搜索, SSA, 发现者-加入者, 预警机制, 群智能, 全局优化 |
| confidence | high |
| source | matlab/optim/sparrow_search.m |

## 数学形式

SSA 模拟麻雀觅食与反捕食行为，将种群分为发现者 (Discoverer)、加入者 (Joiner) 和预警者 (Vigilance/Scout) 三种角色。

**发现者位置更新 (Discovery Phase):**
$$X_{i,j}^{t+1} = \begin{cases} X_{i,j}^t \cdot \exp\left(-\dfrac{i}{\alpha \cdot T_{max}}\right) & \text{if } R_2 < ST \\[8pt] X_{i,j}^t + Q \cdot \mathbf{L} & \text{if } R_2 \geq ST \end{cases}$$

其中 $R_2 \in [0,1]$ 为预警值，$ST \in [0.5, 1]$ 为安全阈值，$Q$ 为标准正态随机数，$\mathbf{L}$ 为全 1 向量。

**加入者位置更新 (Follower Phase):**
$$X_{i,j}^{t+1} = \begin{cases} Q \cdot \exp\left(\dfrac{X_{worst}^t - X_{i,j}^t}{i^2}\right) & \text{if } i > n/2 \\[8pt] X_P^{t+1} + |X_{i,j}^t - X_P^{t+1}| \cdot \mathbf{A}^+ \cdot \mathbf{L} & \text{if } i \leq n/2 \end{cases}$$

其中 $X_P$ 为发现者当前最优位置，$\mathbf{A}^+ = \mathbf{A}^T(\mathbf{A}\mathbf{A}^T)^{-1}$ ($\mathbf{A}$ 为随机 ±1 向量)。

**预警者位置更新 (Vigilance Phase, 10%-20% 种群):**
$$X_{i,j}^{t+1} = \begin{cases} X_{best}^t + \beta \cdot |X_{i,j}^t - X_{best}^t| & \text{if } f_i > f_{best} \\[8pt] X_{i,j}^t + K \cdot \left(\dfrac{|X_{i,j}^t - X_{worst}^t|}{(f_i - f_{worst}) + \varepsilon}\right) & \text{if } f_i = f_{best} \end{cases}$$

**变量表:**
- $T_{max}$ — 最大迭代次数
- $\alpha \in (0, 1]$ — 均匀随机数
- $R_2$ — 预警值
- $ST$ — 安全阈值 (Safety Threshold)
- $Q$ — 标准正态分布随机数
- $\beta$ — 步长控制参数 (标准正态)
- $K \in [-1, 1]$ — 均匀随机数，控制方向
- $\varepsilon$ — 极小常数，防止除零

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| obj_func | function_handle | — | 接受向量返回标量 | — (问题定义) |
| dim | int | — | [1, 100] | 低 |
| lb | double[] | — | 变量下界 | 低 |
| ub | double[] | — | 变量上界 | 低 |
| n_sparrows | int | 50 | [20, 200] | 中 — 三角色分配依赖总量 |
| max_iter | int | 500 | [100, 2000] | 低 |
| ST | double | 0.8 | [0.5, 1.0] | 高 — 过低→发现者频繁移动(过多探索)；过高→发现者保守 |
| PD | double | 0.2 | [0.1, 0.4] | 高 — 发现者比例，影响搜索广度 |
| SD | double | 0.1 | [0.05, 0.2] | 高 — 预警者比例，影响逃离局部最优能力 |
| 时间复杂度 | — | — | O(n_sparrows × dim × max_iter) 每代 | — |

## MATLAB 实现

函数签名:
```matlab
[best_pos, best_score, convergence] = sparrow_search(obj_func, dim, lb, ub, n_sparrows, max_iter, ST, PD, SD)
```

锚点: `matlab/optim/sparrow_search.m` — 自写实现，基于 Xue & Shen (2020) 原始版本。三角色 (发现者/加入者/预警者) 分工 + 预警反捕食机制。

- `best_pos` — 最优麻雀位置 (1×dim)
- `best_score` — 最优适应度值
- `convergence` — 每代最优值 + 预警触发记录

## Python 备选

自定义实现 (mealpy 可能已包含 SSA 变体):
```python
import numpy as np

def sparrow_search(obj_func, dim, lb, ub, n_sparrows=50,
                   max_iter=500, ST=0.8, PD=0.2, SD=0.1):
    # 初始化
    positions = np.random.uniform(lb, ub, (n_sparrows, dim))
    fitness = np.array([obj_func(p) for p in positions])

    # 按适应度排序
    idx = np.argsort(fitness)
    positions = positions[idx]
    fitness = fitness[idx]

    # 角色划分
    n_discoverer = int(n_sparrows * PD)
    n_vigilance = int(n_sparrows * SD)

    for t in range(max_iter):
        # 发现者更新...
        # 加入者更新...
        # 预警者更新...
        pass

    return positions[0], fitness[0]
```

## 选型决策树

- **用 SSA** — 连续优化，存在欺骗性局部最优，需要强探索-开发平衡的三角色机制
- **用 PSO (PARADIGM-0106)** — 低维 (dim<20)，单模态或弱多模态
- **用 DE (PARADIGM-0108)** — 高维 (dim>100)，需要旋转不变性保证
- **用 GWO (PARADIGM-0110)** — 需求简单，参数极少可接受早熟风险
- **用 WOA (PARADIGM-0112)** — 多模态 + 可分离函数，螺旋机制有利
- **用 surrogateopt** — 目标函数昂贵
- **Trade-off:** SSA 三角色机制对欺骗性局部最优 (deceptive local optima) 逃离能力强于 PSO/GWO/WOA，但参数更多 (ST/PD/SD)，且高维性能不如 DE

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 搜索空间 2D 等高线 (contour) | 标注已知局部最优位置 |
| process | 发现者/加入者/预警者三色散点图 (scatter, 多子图或帧) | 展示三角色的空间分布与演化 |
| result | 收敛曲线 + 预警触发标记 (stem overlay) | 标注预警事件，观察逃离作用 |

## 常见坑

1. **三参数调优 (ST, PD, SD):** ST=0.8, PD=0.2, SD=0.1 对多数问题有效，但具体问题需调整。PD 过大 → 发现者过多，加入者跟随不足，收敛慢；PD 过小 → 搜索广度不足。建议 SD 略大以增强反捕食逃离能力
2. **预警机制误逃离:** 预警者感知到"危险"后向最优位置靠近，若此时最优位置恰为局部最优 → 预警行为反将群体引入陷阱。需确保预警触发后方向判断正确
3. **加入者对最差解依赖:** 后一半加入者位置更新依赖 $X_{worst}$ — 若最差解质量极差，加入者更新无意义。考虑用中位数代替最差值
4. **发现者指数衰减过快:** 当 $R_2 < ST$ 时指数衰减 $\exp(-i/(\alpha T))$ — 排名靠后的发现者衰减极快，过早失去全局搜索能力
5. **边界处理:** 默认截断导致预警者频繁触发边界堆积 → 改用随机重置

## 失效条件/反例 (强制小节)

- **条件1: 极平坦目标函数 (Plateau 地貌)** → 发现者指数衰减机制导致种群过早收敛，加入者无法区分好位置与坏位置 (适应度全相近)，预警者也无"危险"可反应。**表现:** 收敛曲线初始几代即平坦，种群快速坍缩到初始最优附近 → 改用 DE 并设置大 F (F≥0.9) 或完全随机搜索 + 局部优化
- **条件2: 目标函数评估昂贵 (如 CFD 仿真)** → SSA 的三角色机制需要大量函数评估来维持角色间的信息交换，总数可能上千次。**表现:** 在有限预算下 (<200 次评估) 三角色未充分工作即终止 → 改用 surrogateopt 建立代理模型

## 文献

1. Xue J. & Shen B. (2020) "A novel swarm intelligence optimization approach: sparrow search algorithm." *Systems Science & Control Engineering*, 8(1):22-34. DOI: [10.1080/21642583.2019.1708830](https://doi.org/10.1080/21642583.2019.1708830)

## 来源溯源

`matlab/optim/sparrow_search.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 对比 (群智能) | PARADIGM-0106 (PSO) |
| 对比 (群智能) | PARADIGM-0110 (GWO) |
| 对比 (群智能) | PARADIGM-0112 (WOA) |
| 替代 (强高维) | PARADIGM-0108 (DE) |
