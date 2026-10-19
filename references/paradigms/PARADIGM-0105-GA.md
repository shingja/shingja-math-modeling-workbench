# PARADIGM-0105 遗传算法 (Genetic Algorithm)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0105 |
| 类别/子类 | ①优化 / 元启发式 |
| 难度 | 中 |
| 适用题型关键词[] | 遗传算法, GA, 选择, 交叉, 变异, 适应度, 编码, 种群, 进化计算, 全局优化, 黑箱优化, 多目标优化, 特征选择, 参数标定, 函数优化, 组合优化, 调度, 布局设计, 神经网络结构搜索 |
| confidence | high |
| source | Holland (1975), Adaptation in Natural and Artificial Systems; Goldberg (1989), Genetic Algorithms, Addison-Wesley |

## 数学形式

GA 模拟自然选择和遗传机制, 在解空间中搜索最优解. 核心算子:

**1. 编码 (Encoding)**:
- **实数编码**: $\mathbf{x} = (x_1, x_2, \ldots, x_n) \in \mathbb{R}^n$
- **二进制编码**: $\mathbf{x} = (b_1 b_2 \ldots b_L)_2$, 每个 $b_i \in \{0, 1\}$
- **排列编码**: $\mathbf{x}$ 为序列 $(p_1, p_2, \ldots, p_n)$, $p_i$ 互异—用于 TSP/调度

**2. 选择 (Selection)**:

**轮盘赌**: $P(\text{选个体} i) = f_i / \sum_j f_j$

**锦标赛**: 随机选 $k$ 个体, 适应度最高者胜出. $k=2$ (二元锦标赛) 最常用

**3. 交叉/重组 (Crossover)**:

实数编码 — **模拟二进制交叉 (SBX)**:
$$\bar{x}_i = 0.5\left[(1+\beta)x_i^{(1)} + (1-\beta)x_i^{(2)}\right]$$

其中 $\beta$ 服从多项式概率分布. SBX 是 `ga` 默认交叉算子.

二进制编码 — 单点交叉、两点交叉、均匀交叉

**4. 变异 (Mutation)**:

实数编码 — **高斯变异**: $x_i' = x_i + \sigma \cdot \mathcal{N}(0, 1)$, $\sigma$ 与变量范围成比例

二进制编码 — **位翻转**: 以概率 $p_m$ 翻转每个 bit

**5. 精英保留 (Elitism)**:
每代保留最优的 $N_{elite}$ 个体直接进入下一代, 保证最优解不退化.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| PopulationSize | int | 200 (nvars$\leq$5), 200+10$\times$(nvars-5) | 50~500 (实数) | **极高**: 太小早熟, 太大浪费 |
| EliteCount | int | ceil(0.05$\times$PopulationSize) | 1~0.1$\times$PopSize | 中: Trade-off 多样性 |
| CrossoverFraction | double | 0.8 | 0.5~0.95 | 高: 太大降低多样性 |
| Generations | int | 100$\times$nvars | 50~1000 | 高: 太少未收敛 |
| StallGenLimit | int | 50 | 10~100 | 中: 自适应早停 |
| FunctionTolerance | double | 1e-6 | 1e-10~1e-3 | 低 |
| CreationFcn | char | 'gacreationuniform' | 初始种群创建函数 | 低 |
| SelectionFcn | char | 'selectionstochunif' | 选择算子 | 中 |
| CrossoverFcn | char | 'crossoverscattered' | 交叉算子 | 高: 影响搜索行为 |
| MutationFcn | char | 'mutationgaussian' | 变异算子 | 高: 影响多样性维持 |
| UseParallel | bool | false | parallel pool | 中: 适合评估代价大 |

**复杂度**: 每代 $O(P \times C)$, $P$ 为种群规模, $C$ 为单个适应度评估代价. 对于昂贵黑箱 (每次评估 > 1s), 建议 PopulationSize $\leq 100$.

## MATLAB 实现

```matlab
% === ga 遗传算法 ===
nvars = 10;                     % 决策变量数
lb = -5 * ones(1, nvars);
ub = 5 * ones(1, nvars);

% 目标函数 (最小化)
fun = @(x) sum(x.^2 - 10*cos(2*pi*x) + 10);  % Rastrigin 函数

% 求解器选项
opts = optimoptions('ga', ...
    'PopulationSize', 150, ...
    'MaxGenerations', 300, ...
    'EliteCount', ceil(0.05*150), ...
    'CrossoverFraction', 0.8, ...
    'Display', 'iter', ...
    'PlotFcn', @gaplotbestf, ...       % 最佳适应度进化曲线
    'UseParallel', false);

% 对整数变量使用混合整数 GA — 设置 IntCon
% opts_int = optimoptions('ga', opts_above, ...
%     'PopulationType', 'doubleVector');

[x, fval, exitflag, output, population, scores] = ga(fun, nvars, ...
    [], [], [], [], lb, ub, [], opts);

% 带非线性约束的 GA:
% nonlcon = @(x) deal(c, ceq);
% [x, fval] = ga(fun, nvars, A, b, Aeq, beq, lb, ub, nonlcon, opts);

% 自定义种群创建/选择/交叉/变异:
% 可替换 CreationFcn, SelectionFcn, CrossoverFcn, MutationFcn
```

## Python 备选

```python
# DEAP (推荐, 灵活)
from deap import base, creator, tools, algorithms
# 支持自定义编码、算子、并行评估

# PyGAD (易用)
import pygad
ga_instance = pygad.GA(num_generations=100, num_parents_mating=50,
                        fitness_func=fitness_func, sol_per_pop=100,
                        num_genes=nvars, gene_type=float)
ga_instance.run()

# Optuna (贝叶斯+GA混合, 超参优化首选)
import optuna
# 适合昂贵黑箱, 内置TPE/CMA-ES/NSGA-II

# scikit-opt:
# from sko.GA import GA   (中文友好, 教学用途)
```

## 选型决策树

```
问题是否可表达为明确的数学形式 (梯度可用)?
├─ 是 → PARADIGM-0101 (LP) / PARADIGM-0103 (NLP)
└─ 否 → 评估函数是否昂贵 (每次 > 10s)?
    ├─ 是 → surrogateopt 或 BO (贝叶斯优化), 不要用 GA
    └─ 否 → 是否有整数/混合变量?
        ├─ 是 → ga + IntCon, 或 PARADIGM-0102 (MILP) 如果线性
        └─ 否 → 维度?
            ├─ ≤ 10 → ga (可靠, 收敛性好)
            ├─ 10~50 → PSO (PARADIGM-0106, 通常更快)
            └─ > 50 → CMA-ES 或差分进化 (particleswarm 可能更好)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 收敛过程 | Best/Worst/Mean Fitness vs Generation | 三条曲线展示种群进化趋势 |
| 多样性监控 | 种群标准差在各代的变化曲线 | 诊断早熟收敛 — 标准差骤降 |
| 探索 vs 开发 | 解空间散点图 (各代种群分布) | PCA 降维到 2D, 动画展示探索范围 |
| 最终解 | 目标函数曲面 + 最终种群散点 (GA 找到的位置) | 验证解是否接近全局最优 |
| Pareto 前沿 | 2D/3D Pareto 前沿图 (gamultiobj) | 多目标优化结果 |

## 常见坑

1. **早熟收敛**: 种群多样性过早丧失, 所有个体趋同. 对策: (a) 增大 PopulationSize (b) 提高 MutationFcn 的变异率 (c) 使用 `mutationadaptfeasible` 自适应变异 (d) 引入迁移 (migration) 算子
2. **适应度尺度缩放不当**: 超级个体 (适应度远高于平均) 在轮盘赌中占绝对优势, 导致选择压力过大. 对策: 使用 `fitscalingrank` (排名尺度) 替代 `fitscalingprop` (比例尺度)
3. **编码导致 Hamming cliff**: 二进制编码中 7 (0111) 到 8 (1000) 需要同时翻转 4 个 bit, 变异概率极低. 对策: 使用 Gray 码或实数编码
4. **约束处理不当**: GA 默认惩罚函数法对等式约束效果差. 可改用 `ga` 的 `NonlinearConstraintAlgorithm='penalty'` 或增广拉格朗日法
5. **随机种子未固定导致结果不可复现**: 在竞赛/论文中务必使用 `rng('default')` 或 `rng(42)` 固定随机种子

## 失效条件/反例 (强制小节)

- **条件1: 早熟收敛 — 种群多样性完全丧失, 陷入劣质局部最优**. 当初始种群包含一个 "欺骗性" 较优解 (如 Rastrigin 函数某局部谷底), GA 在 10 代以内所有个体趋同, 后续无变异能跳出. 典型场景: **30 维 Rastrigin 函数** $\min \sum_{i=1}^{30} [x_i^2 - 10\cos(2\pi x_i) + 10]$, 它有 $\approx 10^{30}$ 个局部最优. GA 默认参数通常在 $\sim$50 代内收敛到函数值约 $10\sim50$ 的局部最优, 而非全局最优 0. 判别: 观察 `gaplotdistance` (个体间平均距离) 在早期迭代骤降至接近 0, 与 `gaplotbestf` 改善停滞同步出现. 对策: (a) 使用 `mutationadaptfeasible` (b) PopulationSize 提高到 500+ (c) 加入岛屿模型 + 迁移 (d) 换用 PARADIGM-0106 (PSO) 在连续多峰问题上通常表现更好.

- **条件2: 编码不当导致搜索效率极低 — Hamming cliff 与非法解爆炸**. 二进制编码处理连续变量时, 字符串长度 $L$ 与精度 $\epsilon$ 关系为 $L = \log_2((ub-lb)/\epsilon + 1)$. 当要求精度高 (如 $10^{-8}$) 时, $L$ 可达 $25\sim30$ bit/变量, 搜索空间 $2^{nL}$ 急剧膨胀. 典型场景: **参数标定** — 8 个连续参数, 每参数 20 bit, 搜索空间 $2^{160} \approx 10^{48}$. 二进制 GA 连可行解都难找到. 判别: 二进制编码下 BestFitness 在初始 30 代几乎无改善. 对策: 立即切换为实数编码 (`PopulationType='doubleVector'`), 实数 GA 在连续优化中远超二进制 GA.

- **条件3: 适应度评估极其昂贵 — 计算预算不足以支撑种群搜索**. 单次适应度评估需要 CFD/FEM/仿真 (每次 $\sim$30 min), 种群 100 个体 $\times$ 100 代 = 10,000 次评估, 耗时 $\sim$ 208 天. 典型场景: **翼型气动优化** — 每次 CFD 评估 20 min, GA 完全不可行. 判别: 估算总计算时间 = PopulationSize $\times$ Generations $\times$ (单次评估时间). 若 > 48h (竞赛场景), GA 不适用. 对策: 换用 surrogateopt (代理模型优化) — 用少量真实评估 (50~100 次) 构建 Kriging/GP 代理模型, 在代理模型上优化, 大幅减少真实评估次数.

## 文献

1. Holland, J.H. (1975). *Adaptation in Natural and Artificial Systems*. University of Michigan Press. — GA 奠基之作
2. Goldberg, D.E. (1989). *Genetic Algorithms in Search, Optimization, and Machine Learning*. Addison-Wesley. — GA 早期经典教材
3. Deb, K. (2001). *Multi-Objective Optimization Using Evolutionary Algorithms*. Wiley. — NSGA-II 与多目标进化
4. Michalewicz, Z. (1996). *Genetic Algorithms + Data Structures = Evolution Programs*, 3rd ed. Springer.

## 来源溯源

- Holland (1962) 在密歇根大学首次提出 "遗传算法" 概念 → Holland (1975) 专著建立 schema 定理
- De Jong (1975) 博士论文首次系统性测试 GA 在函数优化上的表现 (De Jong 测试函数集)
- Goldberg (1989) 教材普及 GA → Koza (1992) 遗传编程 → Deb et al. (2002) NSGA-II 多目标
- MATLAB: ga 始于 Genetic Algorithm Toolbox (1990s) → 集成入 Global Optimization Toolbox

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 — 较简单替代 | PARADIGM-0106 (PSO) |
| 替代 — 组合优化替代 | PARADIGM-0109 (SA) |
| 替代 — 组合优化替代 | PARADIGM-0114 (TS) |
| 互补 — 人工免疫替代 | PARADIGM-0111 (IA) |
| 升级 — 多目标版本 | gamultiobj |
| 升级 — 代理模型加速 | surrogateopt |
