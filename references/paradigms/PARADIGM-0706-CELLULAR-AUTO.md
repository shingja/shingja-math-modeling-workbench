# PARADIGM-0706 元胞自动机(交通NaSch/火灾/疏散)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0706 |
| 类别/子类 | ⑦综合 / 微观仿真 |
| 难度 | 中 |
| 适用题型关键词[] | 元胞自动机, NaSch模型, 交通流, 火灾模拟, 疏散模拟, 离散仿真, 涌现行为, 人群动力学, 传染病网格, 土地利用变化 |
| confidence | high |
| source | matlab/simulation/cellular_automata.m |

## 数学形式

**元胞自动机定义：**
$$CA = (\mathcal{L}, S, \mathcal{N}, f)$$

其中：
- $$\mathcal{L}$$：离散格点 (1D/2D/3D)
- $$S$$：有限状态集
- $$\mathcal{N}$$：邻域定义 (von Neumann / Moore / 扩展)
- $$f: S^{|\mathcal{N}|} \to S$$：局部状态转移规则

**NaSch 交通流模型 (四步更新)：**
$$\begin{aligned}
\text{Step 1 — 加速:}&\quad v_n \leftarrow \min(v_n + 1, v_{\max}) \\
\text{Step 2 — 减速(避碰):}&\quad v_n \leftarrow \min(v_n, d_n - 1) \\
\text{Step 3 — 随机慢化:}&\quad v_n \leftarrow \max(v_n - 1, 0) \text{ with prob } p_{\text{slow}} \\
\text{Step 4 — 位置更新:}&\quad x_n \leftarrow x_n + v_n
\end{aligned}$$

其中 $$v_n$$ 为车速，$$d_n = x_{n+1} - x_n$$ 为与前车间距，$$p_{\text{slow}}$$ 为随机慢化概率。

**火灾蔓延概率：**
$$P_{\text{ignite}}(i,j) = 1 - \prod_{k \in \mathcal{N}(i,j)} (1 - p_{k})^{s_k}$$

其中 $$s_k = 1$$ 表示邻胞 $$k$$ 燃烧中，$$p_k$$ 为基础点燃概率。

**行人疏散 Floor Field 模型：**
$$p_{ij} = \frac{\exp(k_S \cdot S_{ij} + k_D \cdot D_{ij})}{\sum_{(i',j')\in\Omega}\exp(k_S \cdot S_{i'j'} + k_D \cdot D_{i'j'})}$$

其中 $$S_{ij}$$ 为静态 floor field (距出口最短距离的负值)，$$D_{ij}$$ 为动态 floor field (行人遗留轨迹)，$$k_S, k_D$$ 为耦合系数。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| grid_size | 向量 | [100, 100] | [10, 500] 每维 | 中 (分辨率影响精度) |
| init_state | 矩阵 | — | 离散状态值 | 高 (初始条件决定演化) |
| rule_func | 函数句柄 | — | NaSch/fire/evacuation | 极高 (定义系统行为) |
| n_steps | 整数 | 500 | [100, 10000] | 低 (足够观测稳态即可) |
| v_max (NaSch) | 整数 | 5 | [1, 10] | 高 (决定最大流量) |
| p_slow (NaSch) | 浮点数 | 0.3 | [0, 1] | 高 (决定交通相变位置) |
| p_ignite (火灾) | 浮点数 | 0.3 | [0, 1] | 极高 (蔓延速度) |
| k_S (疏散) | 浮点数 | 1.0 | [0.1, 10] | 高 (静态场 vs 动态场权重) |
| k_D (疏散) | 浮点数 | 0.5 | [0, 5] | 中 (跟从行为强度) |
| boundary | 枚举 | periodic | periodic/open/absorbing | 高 (封闭/开放系统) |

**计算复杂度：** $$O(N \cdot |\mathcal{L}| \cdot |\mathcal{N}|)$$，其中 $$N$$ 为步数，$$|\mathcal{L}|$$ 为格点数。典型 200×200 网格 1000 步可在数秒完成。
**量纲：** 位置离散 (cell)，速度离散 (cell/step)，时间离散 (step)。需校准 step 与实际时间的映射。

## MATLAB 实现

**函数签名：**
```matlab
[states_history, metrics] = cellular_automata(grid_size, init_state, rule_func, ...
    n_steps, rule_params)
```

**NaSch 交通流专用：**
```matlab
[flow, density, velocity] = nasch_traffic(road_length, density_range, v_max, ...
    p_slow, n_steps, n_runs)
% 返回基本图 (流量-密度关系)
```

**火灾蔓延专用：**
```matlab
[burned_area, spread_rate] = fire_ca(grid_size, p_ignite, p_growth, ...
    init_fire, n_steps, wind_direction)
```

**疏散模拟专用：**
```matlab
[evac_time, flow_rate] = evacuation_ca(room_size, n_pedestrians, exits, ...
    k_S, k_D, n_runs)
```

锚点：自写 `matlab/simulation/cellular_automata.m`，无需额外 Toolbox。

## Python 备选

**NumPy 自定义实现：**
```python
import numpy as np
def ca_step(grid, rule_func, neighborhood='Moore'):
    new_grid = grid.copy()
    for i, j in np.ndindex(grid.shape):
        neighbors = get_neighbors(grid, i, j, neighborhood)
        new_grid[i, j] = rule_func(grid[i, j], neighbors)
    return new_grid
```

**CellPyLib 库：**
```python
import cellpylib as cpl
cellular_automaton = cpl.init_simple(rows=100, cols=100, val=0)
cellular_automaton = cpl.evolve(cellular_automaton, timesteps=500,
                                 apply_rule=cpl.evolve.game_of_life_rule)
```

## 选型决策树

- **交通流** → NaSch CA 可得基本图 (流量-密度关系)，简单直观。需连续速度/加速度 → 跟驰模型 (car-following, 如 IDM)；需解析结果 → LWR 宏观连续模型。
- **火灾蔓延** → 概率 CA 可处理异质燃料和风场。需精确热传导和流体力学 → FDS (Fire Dynamics Simulator, 基于 CFD)；仅需统计规律 → 经验模型。
- **行人疏散** → Floor Field CA 可处理大型人群。需个体差异和复杂决策 → Agent-based model (ABM) 或社会力模型 (social force model)。
- **空间连续 (如流体扩散梯度)** → CA 引入格点各向异性，六边形网格可减轻但非根本解决 → 改用 PDE/FDM。
- **仅需宏观涌现 (不需微观轨迹)** → 可考虑均值场近似替代 CA。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 初始网格配置热力图 / 初始道路上车辆分布 | 展示初始状态 |
| process | 时间快照序列 (t=0, t=T/4, t=T/2, t=T) 网格动画帧 | 展示动态演化过程 |
| result | 交通: 基本图 (流量 vs 密度) + 时空图 (space-time diagram)；火灾: 燃烧面积 vs 时间曲线；疏散: 疏散时间分布直方图 + 出口流量时变曲线 | 关键指标汇总 |

## 常见坑

1. **网格分辨率不足** → 动力学产生人为块状效应 (block artifact)，火灾形状呈阶梯状。提高分辨率或用六边形网格缓解。
2. **边界条件影响巨大** → 周期性边界 (toroidal) 与开放/吸收边界产生定性不同的结果。必须在论文中明确声明边界类型。
3. **概率 CA 需大量 ensemble** → 单次实现具有误导性，需多次运行 (n_runs ≥ 100) 报告均值和方差。
4. **同步更新造成冲突** → 两粒子同时选同一目标格，需冲突解决规则 (随机选择 / 速度优先 / 密度限制)，否则粒子消失或叠加。
5. **参数随意取值缺乏校准** → p_slow、p_ignite 等参数需从实测数据标定，否则模型只具定性意义。

## 失效条件/反例 (强制小节)

- **条件1: 系统需要连续空间分辨率 (如流体动力学中的扩散梯度)** → 表现: CA 离散性引入格点各向异性 (lattice anisotropy)，扩散前沿呈八边形而非圆形；六边形网格可部分缓解但本质仍是近似。应改用 PDE + 有限差分/有限元法。
- **条件2: Agent 异质性是一阶效应 (如行人不同速度、年龄、决策规则)** → 表现: 经典 CA 将所有 agent 视为同质，疏散时间分布过窄、低估极端拥堵事件。在 CA 框架内扩展 (每 cell 附加属性) 会增加复杂度，此时应改用 Agent-based model (ABM)。
- **条件3: 系统存在长程相互作用 (非局部效应)** → 表现: CA 仅考虑局部邻域 (Moore 最多 8 邻胞)，长程作用被忽略。如火灾热辐射对远处可燃物的预热效应在 CA 中无法体现。需改用基于物理的连续模型或增加远场作用项。
- **条件4: 离散状态不足以描述连续渐变过程** → 表现: CA 状态集为有限离散值，对于需连续变化的量 (如温度 25.3°C → 28.7°C) 需人为分箱，分箱阈值选择影响结果。应改用 ODE/PDE 连续变量或耦合格子 Boltzmann 方法 (LBM)。

## 文献

1. Wolfram, S. (2002). *A New Kind of Science*. Wolfram Media. ISBN: 978-1579550080
2. Nagel, K. & Schreckenberg, M. (1992). "A cellular automaton model for freeway traffic". *Journal de Physique I*, 2(12): 2221-2229. DOI: 10.1051/jp1:1992277
3. Schadschneider, A., Chowdhury, D. & Nishinari, K. (2010). *Stochastic Transport in Complex Systems: From Molecules to Vehicles*. Elsevier. ISBN: 978-0444528537

## 来源溯源

`matlab/simulation/cellular_automata.m` — NaSch / 火灾蔓延 / 行人疏散 CA 实现

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 替代 | PARADIGM-0708 (系统动力学) | 微观 CA vs 宏观 SD，粒度不同 |
| 替代 | PARADIGM-0809 (偏微分方程) | 离散 CA vs 连续 PDE，空间表示不同 |
| 组合 | PARADIGM-0701 (MCMC) | 概率 CA 的 ensemble 分析可用 MCMC |
| 前置 | PARADIGM-0301 (图论基础) | 邻域结构本质上是图的特例 |
