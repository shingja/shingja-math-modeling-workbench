# PARADIGM-0106 粒子群优化 (Particle Swarm Optimization)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0106 |
| 类别/子类 | ①优化 / 群智能 |
| 难度 | 中 |
| 适用题型关键词[] | 粒子群, PSO, 群体智能, 速度更新, 位置更新, 惯性权重, 全局优化, 连续优化, 函数优化, 参数辨识, 控制器整定, PID参数, 神经网络训练, 特征选择, 约束优化, 多峰函数, 工程设计优化 |
| confidence | high |
| source | Kennedy & Eberhart (1995), Particle Swarm Optimization, IEEE ICNN |

## 数学形式

PSO 模拟鸟群/鱼群的集体觅食行为. 每个粒子保存 $(\mathbf{x}_i, \mathbf{v}_i, \mathbf{pbest}_i)$ 三元组.

**标准 PSO 更新方程**:

**速度更新** (惯性 + 认知 + 社会):
$$\mathbf{v}_i^{(k+1)} = \underbrace{w \cdot \mathbf{v}_i^{(k)}}_{\text{惯性项}} + \underbrace{c_1 \cdot r_1 \cdot (\mathbf{pbest}_i - \mathbf{x}_i^{(k)})}_{\text{认知项 (个体历史最优)}} + \underbrace{c_2 \cdot r_2 \cdot (\mathbf{gbest} - \mathbf{x}_i^{(k)})}_{\text{社会项 (全局最优)}}$$

**位置更新**:
$$\mathbf{x}_i^{(k+1)} = \mathbf{x}_i^{(k)} + \mathbf{v}_i^{(k+1)}$$

其中:
- $w$: 惯性权重 — 控制前一速度的影响. $w$ 大 → 全局探索; $w$ 小 → 局部开发
- $c_1$: 认知加速系数 (self-adjustment weight)
- $c_2$: 社会加速系数 (social-adjustment weight)
- $r_1, r_2 \sim U(0,1)$: 随机因子, 增加搜索随机性

**惯性权重衰减策略** (常用):
$$w^{(k)} = w_{\max} - \frac{w_{\max} - w_{\min}}{K} \cdot k$$

典型设置: $w_{\max}=0.9$, $w_{\min}=0.4$, $K$ 为总迭代数. 初期大惯性探索, 后期小惯性精修.

**粒子速度钳制**:
$$|v_i| \leq v_{\max} = \gamma \cdot (ub_i - lb_i)$$

典型 $\gamma = 0.1 \sim 0.5$. 防止粒子 "飞出" 搜索空间.

**约束处理**: particleswarm 使用惩罚函数法, 也支持增广拉格朗日法.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| SwarmSize | int | min(100, 10$\times$nvars) | 20~500 | **极高**: 太小搜索不充分 |
| SelfAdjustmentWeight | double | 1.49 | 0~4 | 高: 影响个体探索强度 |
| SocialAdjustmentWeight | double | 1.49 | 0~4 | 高: 影响群体共享强度 |
| MaxIterations | int | 200$\times$nvars | 50~5000 | 高: 与收敛关系直接 |
| MinNeighborsFraction | double | 0.25 | 0~1 | 中: 0=全局, 1=局部版PSO |
| InitialSwarmSpan | double | 2000 | 1~10000 | 低: 初始散布程度 |
| FunctionTolerance | double | 1e-6 | 1e-10~1e-3 | 低 |
| StallIterLimit | int | 20 | 5~50 | 中: 自适应早停 |
| UseParallel | bool | false | — | 中: 适合评估昂贵时 |

**复杂度**: 每迭代 $O(S \times C)$, $S$ 为 SwarmSize, $C$ 为单次适应度评估代价. PSO 通常比 GA 收敛更快 (迭代数更少), 在连续优化上效率约为 GA 的 1.5~3 倍.

## MATLAB 实现

```matlab
% === particleswarm 粒子群优化 ===
nvars = 10;
lb = -5 * ones(1, nvars);
ub = 5 * ones(1, nvars);

% 目标函数
fun = @(x) sum(x.^2 - 10*cos(2*pi*x) + 10);  % Rastrigin

% 求解器选项
opts = optimoptions('particleswarm', ...
    'SwarmSize', 100, ...
    'MaxIterations', 300, ...
    'SelfAdjustmentWeight', 1.49, ...
    'SocialAdjustmentWeight', 1.49, ...
    'Display', 'iter', ...
    'PlotFcn', @pswplotbestf, ...
    'UseParallel', false);

% 基础调用
[x, fval, exitflag, output] = particleswarm(fun, nvars, lb, ub, opts);

% 带线性约束
% [x, fval] = particleswarm(fun, nvars, lb, ub);

% 带非线性约束 — 使用惩罚或增广拉格朗日
% opts.NonlinearConstraintAlgorithm = 'auglag';

% 惯性权重自适应: MATLAB particleswarm 内置自适应机制
% 初始 InertiaRange = [0.1, 1.1], 自适应调整
% 若需手动控制, 可自定义 hybrid function 联合 fmincon 精修
```

## Python 备选

```python
# PySwarms (推荐, 专为 PSO 设计)
import pyswarms as ps
optimizer = ps.single.GlobalBestPSO(n_particles=50, dimensions=nvars,
                                     options={'c1': 1.49, 'c2': 1.49, 'w': 0.9})
best_cost, best_pos = optimizer.optimize(fun, iters=100)

# scikit-opt (中文友好)
# from sko.PSO import PSO
# pso = PSO(func=fun, n_dim=nvars, pop=50, max_iter=100)

# DEAP (灵活, 可自定义粒子交互拓扑)
```

## 选型决策树

```
问题维度 n?
├─ n ≤ 10 → PSO 或 GA 均可, PSO 通常收敛更快
├─ 10 < n ≤ 50 → PSO 在连续优化上优于 GA
├─ 50 < n ≤ 100 → PSO 可能停滞, 考虑 CMA-ES 或差分进化
└─ n > 100 → PSO 通常失效, 考虑 cooperative coevolution
是否多峰?
├─ 是 → PSO + 环形拓扑 (local best) 避免过早收敛
└─ 否 (单峰凸) → fmincon / fminunc 更优
是否有昂贵黑箱约束?
├─ 是 → surrogateopt
└─ 否 → particleswarm
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 收敛过程 | 群体最优值 vs 迭代 (semilogy 更好) | PSO 收敛通常是阶跃式: 长时间停滞, 然后突然跳跃改善 |
| 粒子动态 | 粒子轨迹动画 (2D 等高线 + 粒子位置 + 速度向量) | 展示全局-局部搜索平衡 |
| 多样性诊断 | 粒子到 gbest 的平均距离 vs 迭代 | 距离骤降 = 粒子聚集 = 可能停滞 |
| 参数分析 | $c_1$/$c_2$ 参数敏感性 3D 曲面对 Optimal Solution | 指导参数选择 |
| 拓扑影响 | 不同拓扑 (star/ring/von Neumann) 的收敛曲线对比 | 全局 vs 局部 PSO |

## 常见坑

1. **速度爆炸**: 未设置速度上限时, 粒子可能加速到极大值, 飞出搜索空间. 必须设置合理的速度钳制, 或在位置更新后裁剪到 [lb, ub]
2. **惯性权重退化不当**: 线性衰减虽然常用, 但固定衰减率对某些问题太快 (陷入开发过早) 或太慢 (探索过多). 对策: 使用自适应惯性权重或在停滞时重置惯性
3. **$c_1$ + $c_2$ > 4 导致发散**: 理论分析表明, 当 $c_1+c_2 > 4$ 时粒子运动不稳定. Clerc & Kennedy 建议 $c_1=c_2=1.49$, 此时 $c_1+c_2 \approx 3 < 4$, 加上 constriction factor 确保收敛
4. **离散变量混用**: 标准 PSO 仅适用连续空间. 若有离散变量, 需要改造: (a) 离散 PSO — 速度映射为翻转概率 (b) 混合编码 PSO (c) 换用 GA/PARADIGM-0105
5. **边界处理不当**: MATLAB 的 particleswarm 默认将粒子位置限制在 [lb, ub]. 当最优解恰好落在边界上时需小心验证

## 失效条件/反例 (强制小节)

- **条件1: 高维 (>50) 连续优化 — PSO 收敛停滞或速度极慢**. PSO 的粒子速度更新本质上是在 $n$ 维空间中进行各向同性搜索, 维度升高时 gbest 提供的信息密度稀释. 典型场景: **神经网络 200 个权重直接优化** ($n=200$) — PSO 在前 100 代可能有轻微下降, 之后完全停滞, gbest 不再更新. 与 GA 对比: GA 的 SBX 交叉在高维空间中仍能产生有效子代, 但 PSO 的线性速度更新效率急剧下降. 判别: 观察输出 `pswplotbestf` 曲线, 若在总迭代数的 1/4 处即不再改善 (StallIter 持续触发), PSO 已失效. 对策: (a) 降维 — 用 PCA/自动编码器压缩变量空间 (b) 换用 CMA-ES (协方差矩阵自适应) — 天然适合高维 (c) 使用 cooperative coevolution — 将 n 维分为多组独立优化.

- **条件2: 离散变量或组合优化 — 标准 PSO 完全不适用**. PSO 的位置更新 $x_i+v_i$ 在连续空间中定义, 直接用于 TSP、背包、调度等离散组合问题会产生非法解. 典型场景: **TSP 问题** — 解为城市排列 $(p_1, \ldots, p_n)$, 实数 PSO 粒子位置取整 $\lfloor x_i \rfloor$ 后再投影到排列空间, 产生大量重复/缺失城市, 几乎不可行. 判断准则: 是否有超过一个分类/整数组合变量. 对策: 使用离散 PSO (DPSO) 改造 — 速度表示两元素交换的概率; 或直接换用 PARADIGM-0105 (GA, 天然支持排列编码) 或 PARADIGM-0109 (SA, 邻域搜索天然适合组合优化).

- **条件3: 多峰函数且山峰间距离远 — PSO 全群集体陷入同一局部最优**. 当全局最优藏在一个狭窄深谷中而粒子群聚在另一个谷底时, gbest 的引导会将所有粒子锚定在错误的局部最优. 典型场景: **6 峰驼背函数 (Six-hump camel back)** — 全局最优点在 $(0.0898, -0.7126)$ 和 $(-0.0898, 0.7126)$, 若初始粒子群都在正象限, gbest 通常指向 $(1.7, 0)$, 全部粒子被牵引至此, 即使 Rastrigin 函数粒子的多样化探索也无法跳出. 判断: 对同一问题运行 PSO 10 次, 若 8+ 次落入同一局部最优, 说明使用全局拓扑 (star) 的 PSO 早熟. 对策: 切换为局部拓扑 — `MinNeighborsFraction` 设为较高值 (如 0.8), 使粒子只与邻域交流, 延缓信息传播速度, 保持多样性. 环形或 von Neumann 拓扑通常比全局 star 拓扑更适合多峰函数.

## 文献

1. Kennedy, J. & Eberhart, R. (1995). "Particle Swarm Optimization". *Proc. IEEE International Conference on Neural Networks*, pp. 1942-1948. — PSO 开创性论文
2. Shi, Y. & Eberhart, R. (1998). "A Modified Particle Swarm Optimizer". *IEEE Congress on Evolutionary Computation*. — 引入惯性权重
3. Clerc, M. & Kennedy, J. (2002). "The Particle Swarm — Explosion, Stability, and Convergence". *IEEE Trans. Evolutionary Computation*, 6(1), 58-73. — PSO 收敛性理论分析
4. Poli, R., Kennedy, J., & Blackwell, T. (2007). "Particle Swarm Optimization: An Overview". *Swarm Intelligence*, 1(1), 33-57.

## 来源溯源

- Heppner & Grenander (1990) 鸟群觅食模拟 → Kennedy & Eberhart (1995) 首次提出 PSO → Shi & Eberhart (1998) 惯性权重改进
- Kennedy (1999) 社会心理学视角解释 PSO → Clerc (1999) 约束因子 (constriction coefficient)
- MATLAB: particleswarm 始于 R2014b, 内置于 Global Optimization Toolbox

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 — 进化计算替代 | PARADIGM-0105 (GA) |
| 替代 — 组合优化场景替代 | PARADIGM-0109 (SA) |
| 替代 — 组合优化场景替代 | PARADIGM-0114 (TS) |
| 互补 — 人工免疫替代 | PARADIGM-0111 (IA) |
| 增强 — 精修阶段 | PARADIGM-0103 (fmincon) — PSO + fmincon 混合 |
| 升级 — 多目标 | gamultiobj (暂无内置多目标 PSO) |
