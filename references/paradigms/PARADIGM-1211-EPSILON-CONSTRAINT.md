# PARADIGM-1211 ε-约束法多目标⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1211 |
| 类别/子类 | ⑫多目标决策进阶 / 标量化方法 |
| 难度 | 中 |
| 适用题型关键词[] | ε-约束, 多目标优化, 标量化, fmincon, Pareto前沿生成, Haimes |
| confidence | high |
| source | Haimes et al. (1971) IEEE TAC |

## 数学形式

**问题转化:**

对 $M$ 个目标最小化 $f_1(\mathbf{x}), f_2(\mathbf{x}), \ldots, f_M(\mathbf{x})$:

**ε-约束法 — 保留一个目标, 约束化其余:**
$$\min_{\mathbf{x}} \; f_j(\mathbf{x})$$
$$\text{s.t.} \; f_k(\mathbf{x}) \leq \varepsilon_k \quad \forall k \neq j$$
$$\mathbf{x} \in \mathcal{X}$$

**定理:** $\mathbf{x}^*$ 是 Pareto 最优解 $\iff$ 存在某个 $\varepsilon$ 值和某个 $j$ 使得 $\mathbf{x}^*$ 是 ε-约束问题的唯一最优解 (或对所有 $j$ 都是解)。

**Pareto 前沿生成流程:**
1. 计算 Payoff 表: 单独优化每个目标 $f_k^* = \min f_k(\mathbf{x})$
2. 确定每个目标的取值区间: $[f_k^{\min}, f_k^{\max}]$
3. 网格化 $\varepsilon$ 值遍历求解

**增强 ε-约束法 (AUGMECON, Mavrotas 2009):**
避免弱 Pareto 解:
$$\min \; f_j(\mathbf{x}) - \delta \sum_{k\neq j} \frac{s_k}{r_k}$$
$$\text{s.t.} \; f_k(\mathbf{x}) + s_k = \varepsilon_k, \; s_k \geq 0$$

其中 $\delta$ 为小正数 ($10^{-6}\sim 10^{-3}$), $r_k$ 为目标范围。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| grid_points | int | 10 | [5, 50] | 高 — 前沿分辨率∝点数 |
| epsilon_values | double[] | — | f_k 范围 | 高 |
| n_obj (M) | int | — | [2, 5] | 极高 — M>5网格爆炸 |
| 复杂度 | — | — | O(grid^(M-1)×单目标求解) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[pareto_x, pareto_f] = epsilon_constraint(obj_funs, n_vars, lb, ub, ...
    n_grid, solver_options)
```

锚点: `fmincon` (Optimization Toolbox) + 自写-见S5:epsilon_constraint.m

```matlab
% 双目标示例
% 步骤1: 单独优化
f1_opt = fmincon(@(x) obj1(x), x0, [], [], [], [], lb, ub, @nonlcon);
f1_min = obj1(f1_opt);
f2_max_at_f1opt = obj2(f1_opt);

f2_opt = fmincon(@(x) obj2(x), x0, [], [], [], [], lb, ub, @nonlcon);
f2_min = obj2(f2_opt);
f1_max_at_f2opt = obj1(f2_opt);

% 步骤2: ε-约束网格
n_grid = 20;
epsilons = linspace(f2_min, f2_max_at_f1opt, n_grid);
pareto_f = zeros(n_grid, 2);

for i = 1:n_grid
    % min f1 s.t. f2 ≤ ε_i
    nonlcon_eps = @(x) deal([obj2(x) - epsilons(i); nonlcon(x)], []);
    x_i = fmincon(@obj1, x0, [], [], [], [], lb, ub, @nonlcon_eps);
    pareto_f(i,:) = [obj1(x_i), obj2(x_i)];
end
% 去除被支配解
pareto_f = pareto_f(nd Pareto fronts, :);
plot(pareto_f(:,1), pareto_f(:,2), 'o-');
```

## Python 备选

```python
from scipy.optimize import minimize
# 或 pymoo
from pymoo.factory import get_algorithm
```

## 选型决策树

- **ε-约束法** — 需要生成均匀 Pareto 前沿，或对目标有明确上限约束
- **加权和法** — 目标有天然加权解释且是凸优化 (Pareto 前沿凸)，更简单
- **NSGA-II (PARADIGM-1201)** — 目标数 2-3, 需要一次运行生成整个前沿
- **MOEA/D (PARADIGM-1203)** — 目标数 > 3, 基于分解的方法更有效

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | Payoff 表 (矩阵) | 各目标范围 |
| result | Pareto 前沿散点图 (每个ε一个解) | 含可行区域标识 |
| result | 平行坐标图 (M>2时) | 多维目标权衡 |

## 常见坑

1. **网格密度不够**: grid 太疏遗漏重要的 Pareto 前沿转折 → 至少 15-20 个点
2. **弱 Pareto 解**: ε-约束法可能产生被支配的弱 Pareto 解 → 使用增强版 (AUGMECON) 的微小惩罚项
3. **M > 3 时网格爆炸**: M=4, grid=10 → 1000 次 fmincon → 只在目标重要的维度上做网格，其他固定

## 失效条件/反例 (强制小节)

- **条件1: fmincon 在 ε 约束下不可行** → 表现: 对于给定的 ε_k，没有可行解满足所有约束 → fmincon 返回 infeasible，Pareto 前沿上出现"空洞"。**应对**: 自适应 ε 网格 — 跳过不可行区域，或在可行域边界上取值
- **条件2: 非凸 Pareto 前沿 (凹的权衡曲线)** → 表现: ε-约束法理论上可生成任意前沿 (不依赖凸性)，但如果 fmincon 陷入局部最优 → 返回的 Pareto 点不是真正的 non-dominated 解。**应对**: 多起点 (MultiStart) fmincon 或在 GA 生成全球解后用 fmincon 精化

## 文献

1. Haimes Y.Y., Lasdon L.S. & Wismer D.A. (1971). "On a bicriterion formulation of the problems of integrated system identification and system optimization." *IEEE Trans SMC*, 1(3):296-297. DOI: [10.1109/TSMC.1971.4308298](https://doi.org/10.1109/TSMC.1971.4308298)
2. Mavrotas G. (2009). "Effective implementation of the epsilon-constraint method in multi-objective mathematical programming problems." *Applied Mathematics and Computation*, 213(2):455-465.

## 来源溯源

fmincon + 自写 epsilon_constraint.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-1201 (NSGA2) |
| 替代 | PARADIGM-0711 (NSGA2+TOPSIS) |
| 前置 | PARADIGM-0103 (NLP) |
