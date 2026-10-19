# PARADIGM-1201-NSGA2 NSGA-II: 非支配排序遗传算法⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1201-NSGA2 |
| 类别/子类 | ⑫多目标决策进阶 / 多目标进化优化 |
| 难度 | 高 |
| 适用题型关键词[] | 多目标优化, Pareto前沿, 工程设计, 资源分配, 冲突目标, 非支配排序 |
| confidence | high |
| source | 教材第12章 / 论文2002_NSGA2 / 题解反推_MOP类 |

## 数学形式

**多目标优化问题**:
$$\min_{\mathbf{x}} \mathbf{F}(\mathbf{x}) = [f_1(\mathbf{x}), f_2(\mathbf{x}), \ldots, f_M(\mathbf{x})]^T$$
$$\text{s.t. } g_j(\mathbf{x}) \leq 0, \; j=1,\ldots,J; \quad h_k(\mathbf{x}) = 0, \; k=1,\ldots,K$$

**核心机制**:
1. **非支配排序 (Non-dominated Sorting)**: 将种群划分为 Pareto 前沿层级 $F_1, F_2, \ldots$
   - $F_1$: 当前种群中不被任何其他个体支配的解集 (Pareto 前沿)
   - $n_p$ = 支配个体 $p$ 的个体数; $S_p$ = $p$ 支配的个体集合
2. **拥挤度距离 (Crowding Distance)**:
   $$d_i = \sum_{m=1}^{M} \frac{f_m^{i+1} - f_m^{i-1}}{f_m^{\max} - f_m^{\min}}$$
   边界个体 $d = \infty$
3. **二元锦标赛选择**: 先比较非支配层级 ($i_{\text{rank}}$), 层级相同时比较拥挤度 ($d_i$ 大者胜出)

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $M$ | 目标函数数量 | 2-5 |
| $N$ | 种群大小 | 50-200 |
| $G$ | 进化代数 | 100-500 |
| $p_c$ | 交叉概率 | 0.7-0.9 |
| $p_m$ | 变异概率 | $1/n_{\text{vars}}$ |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 种群大小 `N` | int | 100 | 50-500 | 高—太小早熟, 太大计算负担 |
| 交叉概率 `p_c` | float | 0.9 | 0.6-1.0 | 中 |
| 变异概率 `p_m` | float | 0.1 | 0.01-0.3 | 高—太大退化为随机搜索 |
| 交叉指数 $\eta_c$ | float | 20 | 5-50 | 中—控制子代分布范围 |
| 变异指数 $\eta_m$ | float | 20 | 5-100 | 中—控制变异步长 |
| 最大代数 `gen_max` | int | 250 | 100-1000 | 中 |

**时间复杂度**: $O(M N^2)$ 每代 (非支配排序主导)
**空间复杂度**: $O(N^2)$

## MATLAB 实现

```matlab
% 内置多目标遗传算法 (Global Optimization Toolbox)
options = optimoptions('gamultiobj', ...
    'PopulationSize', 100, ...
    'MaxGenerations', 250, ...
    'ParetoFraction', 0.35, ...
    'PlotFcn', @gaplotpareto);
[x, fval] = gamultiobj(@objective_func, n_vars, [], [], [], [], lb, ub, options);

% 自写 NSGA-II 完整实现 (含非支配排序 + 拥挤度)
% 自写-见S5:nsga2_optimizer.m
```

**锚点工具箱**: `gamultiobj` (Global Optimization Toolbox)
**备选**: `paretosearch` (Global Optimization Toolbox, v2017b+)

## Python 备选

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize
from pymoo.problems import get_problem

algorithm = NSGA2(pop_size=100)
problem = get_problem("zdt1")
res = minimize(problem, algorithm, ('n_gen', 200), seed=1)
# res.F: Pareto 前沿目标值; res.X: 决策变量
```

备选: `DEAP` + `selNSGA2`, `Platypus`

## 选型决策树

- **2-3 目标 + 连续变量** → NSGA-II (成熟稳定, 最先尝试)
- **4-5 目标** → NSGA-III (参考点法, 高维更均匀) 见 PARADIGM-1202
- **>5 目标 + 偏好已知** → MOEA/D (分解法, 收敛更快) 见 PARADIGM-1203
- **约束过多** → 约束处理NSGA-II (可行性优先规则)
- **昂贵黑箱评估** → EGO/BayesOpt (代理模型) 见 PARADIGM-1002
- **离散/组合** → NSGA-II + 定制交叉变异算子
- **需要偏好引导** → VIKOR/TOPSIS (后验评价) 见 PARADIGM-1204

## 典型图型

- **raw**: 散点图—目标空间初始种群分布
- **process**: Pareto 前沿迭代图 (GIF/animation), 各代 HV/IGD 收敛曲线
- **result**: Pareto 前沿散点图 (2D/3D), 平行坐标图 (高维目标), 选出方案标记

## 常见坑

1. **拥挤度在 >5 目标时失效 (维数灾难)**: 多数个体在边界获得 $\infty$ 拥挤度, 选择压力丧失 → 换 NSGA-III
2. **约束处理不当**: 直接用罚函数破坏非支配排序结构 → 用可行性优先规则 (可行解永远优于不可行解)
3. **种群多样性丧失**: 变异率过低 → 引入多样性维护策略
4. **目标量纲差异大**: 拥挤度被大尺度目标主导 → 目标归一化
5. **前沿不连续**: 锦标赛选择偏好聚类 → 增大种群或引入小生境

## 失效条件/反例 (强制小节)

- **条件1**: $M > 5$ (目标维数高) → 拥挤度距离定义在高维空间失效, 多数个体拥挤度变为 $\infty$, 选择压力崩溃, Pareto 前沿分布极不均匀。**替代**: NSGA-III (PARADIGM-1202)
- **条件2**: 目标函数评估极其昂贵 (单次 >10秒) → NSGA-II 需数千次评估, 计算不可行。**替代**: EGO/BayesOpt (PARADIGM-1002) 或 RBF代理 (PARADIGM-1004)
- **条件3**: 决策变量全离散且约束稠密 → 标准 SBX/多项式变异不适合。**替代**: 定制离散交叉变异 + NSGA-II 框架
- **条件4**: 可行域极小 (< 1% 搜索空间) → 初始种群难以找到可行解, 算法退化。**替代**: 约束放松初始化 + 可行性修复算子

## 文献

1. Deb, K., Pratap, A., Agarwal, S., & Meyarivan, T. (2002). A fast and elitist multiobjective genetic algorithm: NSGA-II. *IEEE Transactions on Evolutionary Computation*, 6(2), 182-197. DOI: [10.1109/4235.996017](https://doi.org/10.1109/4235.996017)
2. Coello Coello, C. A., Van Veldhuizen, D. A., & Lamont, G. B. (2007). *Evolutionary Algorithms for Solving Multi-Objective Problems* (2nd ed.). Springer. ISBN: 978-0-387-33254-3.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第11章
- 论文三元组: Deb 2002, NSGA-II, fast non-dominated sorting + crowding distance
- 开源仓库: [pymoo](https://github.com/anyoptimization/pymoo), [PlatEMO](https://github.com/BIMK/PlatEMO)

## 关联范式卡

组合: PARADIGM-1204-VIKOR (Pareto解集后验排序), PARADIGM-1205-CRITIC (客观权重确定)
替代: PARADIGM-1202-NSGA3 (>5目标), PARADIGM-1203-MOEAD (分解法), PARADIGM-1002-EGO (昂贵评估)
前置: PARADIGM-0301-GA (遗传算法基础, 建议先掌握)
