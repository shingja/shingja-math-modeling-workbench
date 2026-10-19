# PARADIGM-0711 NSGA-II+TOPSIS组合模式⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0711 |
| 类别/子类 | ⑦综合 / 多目标优化组合 |
| 难度 | 高 |
| 适用题型关键词[] | NSGA-II, TOPSIS, 多目标优化, Pareto前沿, 组合模式, 决策, gamultiobj, 理想解 |
| confidence | high |
| source | Deb (2002) IEEE TEVC + Hwang & Yoon (1981) Springer |

## 数学形式

**阶段 1: NSGA-II 多目标优化**

Pareto 支配: $\mathbf{x} \prec \mathbf{y}$ 若 $\forall i: f_i(\mathbf{x}) \leq f_i(\mathbf{y})$ 且 $\exists j: f_j(\mathbf{x}) < f_j(\mathbf{y})$

**非支配排序:** 将种群分为前沿 $F_1$ (非支配), $F_2$ (被 $F_1$ 支配), ...

**拥挤度距离 (Crowding Distance):**
$$d_i = \sum_{m=1}^{M} \frac{f_m^{(i+1)} - f_m^{(i-1)}}{f_m^{\max} - f_m^{\min}}$$

**选择:** 二元锦标赛 — 先比 rank (非支配层)，再比 crowding distance

**阶段 2: TOPSIS 决策 (从 Pareto 前沿中选最优折衷解)**

**归一化 Pareto 前沿:**
$$r_{ij} = \frac{f_{ij}}{\sqrt{\sum_{k=1}^{N_P} f_{kj}^2}}$$

**加权归一化:**
$$v_{ij} = w_j \cdot r_{ij}$$

**理想解 $A^+$ 和负理想解 $A^-$:**
$$A^+ = (\min_i v_{i1}, \ldots, \min_i v_{iM}), \quad A^- = (\max_i v_{i1}, \ldots, \max_i v_{iM})$$
(假设所有目标最小化)

**相对贴近度:**
$$C_i = \frac{d_i^-}{d_i^+ + d_i^-}, \quad d_i^+ = \|v_i - A^+\|, \quad d_i^- = \|v_i - A^-\|$$

**最终方案:** $\mathbf{x}^* = \arg\max_i C_i$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| pop_size | int | 100 | [50, 500] | 中 — 影响前沿覆盖 |
| n_generations | int | 200 | [50, 1000] | 高 — 需足够收敛 |
| crossover_prob | double | 0.9 | [0.6, 1.0] | 中 |
| mutation_prob | double | 1/n_var | [0.01, 0.5] | 中 |
| TOPSIS_weights | double[] | 等权 | 用户设定 | 极高 — 改变最终选择 |

## MATLAB 实现

函数签名 (自写):
```matlab
[best_solution, pareto_front, pareto_scores, topsis_scores] = ...
    nsga2_topsis(obj_funs, n_vars, lb, ub, weights, options)
```

锚点: `gamultiobj` (Global Optimization Toolbox) + 自写 TOPSIS-见S5:nsga2_topsis.m

```matlab
% 阶段 1: NSGA-II (gamultiobj)
opts = optimoptions('gamultiobj', ...
    'PopulationSize', 100, ...
    'MaxGenerations', 200, ...
    'ParetoFraction', 0.35, ...
    'PlotFcn', @gaplotpareto);
[pareto_sols, pareto_vals] = gamultiobj(obj_fun, n_vars, [], [], [], [], lb, ub, opts);

% 阶段 2: TOPSIS 从 Pareto 前沿选最优
% 归一化
r = pareto_vals ./ sqrt(sum(pareto_vals.^2, 1));
% 加权
v = r .* weights;
% 理想/负理想解
A_plus = min(v, [], 1);  % 假设最小化
A_minus = max(v, [], 1);
% 距离
d_plus = sqrt(sum((v - A_plus).^2, 2));
d_minus = sqrt(sum((v - A_minus).^2, 2));
% 贴近度
C = d_minus ./ (d_plus + d_minus);
[~, best_idx] = max(C);
best_solution = pareto_sols(best_idx, :);
```

## Python 备选

```python
# pymoo for NSGA-II
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize
# TOPSIS
from pymcdm.methods import TOPSIS
topsis = TOPSIS()
pref = topsis(pareto_front, weights, types)
```

## 选型决策树

- **NSGA-II + TOPSIS** — 标准组合: 先生成 Pareto 前沿，再从前沿中多属性决策
- **NSGA-II only** — 仅需展示 Pareto 前沿，最终决策由人工
- **加权和→单目标** — 目标可线性加权聚合时 (如均质量纲)，更简单
- **ε-约束法 (PARADIGM-1211)** — 将一个目标约束化，转化为单目标

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | Pareto 前沿进化过程 (多帧) | 前沿推进轨迹 |
| result | 2D/3D Pareto 前沿 + TOPSIS 最优解标记 | 理想/负理想点连线 |
| result | TOPSIS 贴近度柱状图 | 前沿候选方案排序 |

## 常见坑

1. **gamultiobj 默认用小种群 → Pareto 前沿稀疏**: PopSize < 50 时前沿点数少 → 增大到 100-200
2. **目标函数量纲差异**: 一个目标值域 [0,1] 另一个 [0,10^6] → TOPSIS 归一化前被大值目标主导
3. **Pareto 前沿不平滑**: 突变+交叉参数不当时前沿参差不齐 → 调整 crossover fraction

## 失效条件/反例 (强制小节)

- **条件1: 目标数 M > 5 → 绝大多数解都非支配** → 表现: "维度灾难" — 随着 M 增加，种群中非支配解比例呈指数增长 → 选择压力消失，(1+1/M)^pop_size 效率急剧下降。**应对**: 改用 NSGA-III (基于参考点) 或 MOEA/D (基于分解)，两者在 Many-objective (M>5) 下更有效
- **条件2: 目标间存在强冲突 (一个降低必然导致另一个升高) + 等权 TOPSIS** → 表现: 等权 TOPSIS 在 Pareto 前沿上选出的解可能极端偏向某一目标，不符合实际决策偏好。**应对**: 用 CRITIC/熵权法客观赋权或引入 AHP 主观权重

## 文献

1. Deb K., Pratap A., Agarwal S. & Meyarivan T. (2002). "A fast and elitist multiobjective genetic algorithm: NSGA-II." *IEEE Trans Evolutionary Computation*, 6(2):182-197. DOI: [10.1109/4235.996017](https://doi.org/10.1109/4235.996017)
2. Hwang C.L. & Yoon K. (1981). *Multiple Attribute Decision Making: Methods and Applications*. Springer. ISBN: 978-3540105589

## 来源溯源

gamultiobj + 自写 TOPSIS nsga2_topsis.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-1201 (NSGA2) |
| 前置 | PARADIGM-0302 (TOPSIS) |
| 替代 | PARADIGM-1211 (ε-约束法) |
