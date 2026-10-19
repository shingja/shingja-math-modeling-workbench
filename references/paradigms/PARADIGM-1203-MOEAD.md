# PARADIGM-1203-MOEAD MOEA/D: 基于分解的多目标进化算法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1203-MOEAD |
| 类别/子类 | ⑫多目标决策进阶 / 多目标进化优化 |
| 难度 | 高 |
| 适用题型关键词[] | 分解法, 标量化, 权重向量, 邻域协同, 高维收敛 |
| confidence | high |
| source | 论文2007_MOEAD / 题解反推_Decomposition类 |

## 数学形式

**核心思想**: 将多目标问题分解为 $N$ 个标量优化子问题, 通过邻域协同同时求解。

**三类分解方法**:

1. **加权和 (Weighted Sum)**:
   $$\min g^{ws}(\mathbf{x}|\boldsymbol{\lambda}) = \sum_{i=1}^{M} \lambda_i f_i(\mathbf{x})$$
   仅适用于凸 Pareto 前沿, 否则无法到达前沿非凸区域

2. **切比雪夫 (Tchebycheff)** (最常用):
   $$\min g^{te}(\mathbf{x}|\boldsymbol{\lambda}, \mathbf{z}^*) = \max_{1 \leq i \leq M} \{ \lambda_i |f_i(\mathbf{x}) - z_i^*| \}$$
   其中 $\mathbf{z}^* = (z_1^*, \ldots, z_M^*)$ 为理想点, $\sum \lambda_i = 1, \lambda_i \geq 0$

3. **PBI (Penalty-based Boundary Intersection)**:
   $$\min g^{pbi}(\mathbf{x}|\boldsymbol{\lambda}, \mathbf{z}^*) = d_1 + \theta d_2$$
   $d_1$ = 沿参考方向投影距离, $d_2$ = 垂直偏离距离, $\theta$ = 惩罚因子

**邻域结构**: 权重向量 $\boldsymbol{\lambda}^i$ 的邻域 $B(i)$ = 与其欧氏距离最近的 $T$ 个权重向量的索引集合

| 变量 | 含义 | 典型值 |
|------|------|--------|
| $N$ | 子问题数 = 权重向量数 | 100-300 |
| $T$ | 邻域大小 | $0.1N$ (~10-30) |
| $\theta$ | PBI惩罚因子 | 5.0 |
| $\delta$ | 邻域选择概率 | 0.9 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 子问题数 `N` | int | 200 | 100-500 | 中—决定前沿近似精度 |
| 邻域大小 `T` | int | 20 | 5-50 | 高—太大损失多样性, 太小收敛慢 |
| $\delta$ (邻域选择概率) | float | 0.9 | 0.7-1.0 | 中—平衡探索与利用 |
| $n_r$ (后代替换上限) | int | 2 | 1-5 | 中—防止极早收敛 |
| 分解方法 | enum | 'tchebycheff' | ws/tch/pbi | 高—ws不支持非凸前沿 |
| PBI $\theta$ | float | 5.0 | 1.0-10.0 | 中 |

**时间复杂度**: $O(M N T)$ 每代 (远优于 NSGA-II 的 $O(M N^2)$)
**空间复杂度**: $O(N T)$

## MATLAB 实现

```matlab
% 自写 MOEA/D 主循环 (含权重向量生成 + 邻域 + 分解标量化)
% 自写-见S5:moead_optimizer.m

% 可利用 gamultiobj 的底层函数辅助:
% gamultiobj 基于 NSGA-II, 不是 MOEA/D; 需完全自实现
```

**锚点工具箱**: 无内置 MOEA/D, 需自写
**权重向量生成**: 可用 Simplex-Lattice Design (与 NSGA-III 参考点同理)

## Python 备选

```python
from pymoo.algorithms.moo.moead import MOEAD
from pymoo.util.ref_dirs import get_reference_directions

ref_dirs = get_reference_directions("uniform", 3, n_partitions=12)
algorithm = MOEAD(ref_dirs, n_neighbors=20, prob_neighbor_mating=0.9)
res = minimize(problem, algorithm, ('n_gen', 200), seed=1)
```

备选: `Platypus.MOEAD`

## 选型决策树

- **高维 ($M \geq 5$) + 收敛速度优先** → MOEA/D (分解法收敛最快)
- **非凸 Pareto 前沿** → 用切比雪夫/PBI 分解, **禁止**加权和
- **2-3 目标 + 需要完整前沿** → NSGA-II (PARADIGM-1201), MOEA/D 即可但 NSGA-II 更成熟
- **>5 目标 + 需要均匀前沿** → NSGA-III (PARADIGM-1202) vs MOEA/D (均可, MOEA/D 收敛更快但前沿分布可能不均匀)
- **计算预算充裕** → 可并联 MOEA/D + NSGA-III, 比较 HV/IGD 选取
- **单次评估昂贵** → MOEA/D 的子问题并行评估天然适用

## 典型图型

- **raw**: 权重向量在单纯形上的分布
- **process**: 各代各子问题目标值热力图 (权重向量 $\times$ 代数), IDEAL点追踪
- **result**: Pareto 前沿散点图 (2D/3D), 各子问题收敛曲线 (多线图)

## 常见坑

1. **加权和分解仅适用于凸前沿**: 非凸区域无法到达 → 统一用切比雪夫分解
2. **权重向量数与前沿形状不匹配**: 单纯形分布不适合 disconnected 前沿 → 用两阶段自适应权重
3. **邻域过小导致信息孤岛**: $T$ 太小各子问题独立演化 → 设为 $0.1N$ 起步
4. **$n_r$ 过大导致多样崩溃**: 少数优良解快速复制到全邻域 → $n_r \leq 2$

## 失效条件/反例 (强制小节)

- **条件1**: Pareto 前沿严重退化 (有效维数远小于 $M$) → 大量权重向量映射到相同或附近的 Pareto 最优解, 多样性崩溃, 前沿近似低效。**替代**: 先 PCA/降维, 再用低维 MOEA
- **条件2**: Pareto 前沿不连续且碎片化 → 切比雪夫函数将多个前沿碎片映射到同一标量化最优, 中间区域无法覆盖。**替代**: 含聚类/小生境的 NSGA-II/III
- **条件3**: 目标函数含强约束 → 约束加权切比雪夫对不可行解惩罚设计困难, 可行域探索不足。**替代**: 可行性优先的约束 NSGA-II
- **条件4**: 目标数量 $M$ 极低 (2个) 且前沿为单一连续性区域 → MOEA/D 的邻域协同无显著优势, 但也不会失败—只是过度工程。直接用 NSGA-II 即可

## 文献

1. Zhang, Q., & Li, H. (2007). MOEA/D: A multiobjective evolutionary algorithm based on decomposition. *IEEE Transactions on Evolutionary Computation*, 11(6), 712-731. DOI: [10.1109/TEVC.2006.882433](https://doi.org/10.1109/TEVC.2006.882433)
2. Miettinen, K. (1999). *Nonlinear Multiobjective Optimization*. Springer. ISBN: 978-0-7923-8278-2.

## 来源溯源

- 论文三元组: Zhang 2007, MOEA/D, decomposition-based + neighborhood mating
- 开源仓库: [MOEA/D主页](https://dces.essex.ac.uk/staff/zhang/webofmoead.htm), [PlatEMO](https://github.com/BIMK/PlatEMO)

## 关联范式卡

组合: PARADIGM-1204-VIKOR (前沿后验选择)
替代: PARADIGM-1201-NSGA2 (低维, 更通用), PARADIGM-1202-NSGA3 (高维, 参考点引导)
前置: PARADIGM-0301-GA (GA基础)
