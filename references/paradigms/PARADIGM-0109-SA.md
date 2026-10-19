# PARADIGM-0109 模拟退火 (Simulated Annealing)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0109 |
| 类别/子类 | ①优化 / 元启发式 |
| 难度 | 中 |
| 适用题型关键词[] | 模拟退火, SA, Metropolis准则, 退温策略, 全局优化, 组合优化, TSP, VLSI布局, 调度, 图着色, 函数优化, 非线性规划, 多极值, 退火计划, 接受概率 |
| confidence | high |
| source | Kirkpatrick, Gelatt & Vecchi (1983), Optimization by Simulated Annealing, Science |

## 数学形式

模拟退火受固体退火物理过程启发: 将固体加热到高温后缓慢冷却, 原子获得足够能量跳出局部平衡, 最终达到全局最低能量态 (晶体).

**Metropolis 准则** (核心接受机制):

从当前解 $\mathbf{x}$ 生成候选解 $\mathbf{x}'$ (邻域操作), 接受概率为:

$$P(\text{接受 } \mathbf{x}') = \begin{cases}
1, & \text{若 } f(\mathbf{x}') \leq f(\mathbf{x}) \quad (\text{改进, 总是接受}) \\
\exp\left(-\dfrac{f(\mathbf{x}') - f(\mathbf{x})}{T}\right), & \text{若 } f(\mathbf{x}') > f(\mathbf{x}) \quad (\text{恶化, 概率接受})
\end{cases}$$

其中 $T$ 为当前温度. 接受劣解的概率随 $T$ 降低而衰减.

**退温策略 (Cooling Schedule)**:

1. **指数退温** (最常用): $T_{k+1} = \alpha \cdot T_k$, $\alpha \in [0.7, 0.99]$
2. **对数退温**: $T_k = T_0 / \ln(k+1)$  — 理论保证收敛到全局最优, 但速度极慢
3. **线性退温**: $T_k = T_0 - k \cdot \Delta T$, $\Delta T = (T_0 - T_{\min}) / K$
4. **快速退火 (Fast Annealing)**: $T_k = T_0 / k$ — Cauchy 分布采样邻域

**初始温度 $T_0$ 选择**:

经验法则: 设定 $T_0$ 使得初始接受劣解的概率 $\approx 0.8$, 即:

$$T_0 \approx -\frac{\bar{\Delta}f_{\text{max}}}{\ln(0.8)}$$

其中 $\bar{\Delta}f_{\text{max}}$ 为初始随机游走中目标函数变差的平均最大值.

**冷却链长 (Markov Chain Length)**:

在每个温度 $T_k$ 下进行 $L_k$ 次 Metropolis 迭代. $L_k$ 可固定 (如 $L_k = 100n$) 或自适应 (如 $L_k$ 随接受率变化).

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| InitialTemperature | double | 100 | 取决于问题尺度 | **极高**: 决定初始探索能力 |
| TemperatureFcn | function_handle | @temperatureexp | 退温函数 | 高: 指数 $\alpha$ 0.7~0.99 |
| MaxIterations | int | Inf (适应性) | 100~100000 | 高: = MaxFunEvals |
| MaxFunctionEvaluations | int | 3000$\times$nvars | 1000~100000 | 高: 预算约束 |
| ReannealInterval | int | 100 | 10~500 | 中: 再退火触发间隔 |
| FunctionTolerance | double | 1e-6 | 1e-9~1e-3 | 低 |
| TolFun | double | 1e-6 | — | 低 |
| AcceptanceFcn | function_handle | @acceptancesa | Metropolis 准则 | 低: 非标准冷却可用 Boltzmann/快速 |
| AnnealingFcn | function_handle | @annealingfast | 邻域生成 | **高**: 决定搜索效率 |
| Display | char | 'off' | 'off'\|'iter'\|'diagnose'\|'final' | — |

**时间复杂度**: $O(K \times L)$, $K$ 为退温步数, $L$ 为每步链长. 总函数评估数 = $\sum_k L_k \geq$ MaxFunctionEvaluations.
**理论收敛**: 对数退温 + 无限链长 = 概率 1 收敛到全局最优 (Hajek 定理). 但需要无限时间, 实践中不可行.

## MATLAB 实现

```matlab
% === simulannealbnd 模拟退火 ===
nvars = 5;
lb = -10 * ones(1, nvars);
ub = 10 * ones(1, nvars);

% 目标函数
fun = @(x) x(1)^2 + x(2)^2 + exp(-x(1)^2 - x(2)^2) * sin(3*x(1)*x(2));

% 初始解
x0 = rand(1, nvars) .* (ub - lb) + lb;

% 求解器选项
opts = optimoptions('simulannealbnd', ...
    'InitialTemperature', 100, ...
    'TemperatureFcn', @temperatureexp, ...     % 或 temperatureboltz, temperaturefast
    'AnnealingFcn', @annealingfast, ...        % 或 annealingboltz
    'ReannealInterval', 100, ...               % 每 100 步重新排序参数灵敏度
    'MaxFunctionEvaluations', 3000*nvars, ...
    'Display', 'iter', ...
    'PlotFcn', {@saplotbestf, @saplottemperature});

[x, fval, exitflag, output] = simulannealbnd(fun, x0, lb, ub, opts);

% 输出 output 中包含:
% output.iterations       - 退火迭代次数
% output.funccount        - 总函数评估次数
% output.temperature      - 最终温度

% === 组合优化中的 SA (自实现框架) ===
% 对于 TSP/调度等组合问题, 需自定义 annealing 函数
% 思路: 将 x 映射到排列编码, 邻域操作为 swap/2-opt/insert
```

## Python 备选

```python
# SciPy dual_annealing (开源, 推荐)
from scipy.optimize import dual_annealing
res = dual_annealing(fun, bounds=list(zip(lb, ub)),
                      maxiter=1000, initial_temp=5230.)

# Simanneal (专门 SA 库)
# from simanneal import Annealer
# 适合自定义组合优化

# Nevergrad (FB 出品)
# import nevergrad as ng
# 内置多种 SA 变体
```

## 选型决策树

```
问题类型?
├─ 组合优化 (TSP/调度/VRP/图着色)
│   └─ → SA 是最经典选择, 邻域结构容易设计
├─ 连续优化 (n ≤ 30)
│   └─ → SA 可用但通常慢于 PSO/GA
└─ 带大量局部最优的连续非凸优化
    └─ → SA 优于 fmincon, 但可能慢于 surrogateopt
函数评估是否极其昂贵?
├─ 是 → 不要用 SA! 其适合多评估, 换用 surrogateopt
└─ 否 → SA 可用
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 退火过程 | 温度 $T$ 递减曲线 (semilogy) + 接受概率变化 | 展示冷却过程 |
| 收敛过程 | Best-so-far vs 函数评估次数 | SA 特有阶梯型, 长期不动后突然跳跃 |
| 搜索行为 | 当前目标值 vs 迭代 (叠加散点) | 高温期大幅波动 (红色), 低温期收敛 (蓝色) |
| 参数诊断 | 接受率 vs 温度 | 高温期约 80%, 低温期趋近 0% |
| 再退火 | 再退火前后温度脉冲 + 目标值改善 | 展示 reannealing 机制 |

## 常见坑

1. **初温设置不当**: $T_0$ 太小 → 退化为贪心, 无法跳出局部最优; $T_0$ 太大 → 在高温期浪费 "评估预算". 对策: 运行 100 步随机游走, 引入 $\bar{\Delta}f_{\text{max}}$ 经验法则
2. **冷却太快**: $\alpha < 0.7$ 导致过早冻结 (quenching), 几乎等价贪心算法. 对策: $\alpha \geq 0.85$
3. **冷却太慢**: $\alpha > 0.99$ 导致计算时间不可行, 预算耗尽前未达低温. 对策: 根据 MaxFunctionEvaluations 反推 $\alpha \approx \exp(\ln(T_{\min}/T_0)/K)$
4. **邻域结构不当**: 邻域过大 → 随机搜索, 邻域过小 → 搜索效率低. 对策: 自适应邻域大小 — 接受率 < 20% 时缩小邻域, > 60% 时扩大
5. **直接用 SA 解 MILP**: 连续 SA 无法遵守整数约束. 对策: 对整数变量定制 annealing 函数, 只生成整数候选解

## 失效条件/反例 (强制小节)

- **条件1: 冷却太快导致退化为贪心 — 全局搜索完全失败**. 当退温参数 $\alpha$ 设置过低 ($\alpha < 0.7$) 或初温 $T_0$ 过小, 系统在早期就被 "冻结", 此后 Metropolis 准则中 $\exp(-\Delta E/T)$ 对任何 $\Delta E > 0$ 都趋近于 0, 仅接受改进解. 典型场景: **TSP 规模 100 城市**, $\alpha=0.5$, $T_0=10$, 仅前 20 步有轻微波动, 之后完全等价 2-opt 局部搜索, 用 5000 次评估得到的 tour length 比随机重启 2-opt 多 25%. 判别: 检查 `saplottemperature` 曲线 — 若温度在总预算的前 10% 即降至 $T_{\min}$, 宣告退火失效. 对策: 增大 $\alpha$ 到 0.85~0.95, 同时增大 $T_0$, 确保高温期至少消耗 30% 评估预算.

- **条件2: 冷却太慢导致计算不可行 — 在高温期耗尽预算**. 若 $\alpha > 0.99$ 且 MaxFunctionEvaluations 有限 (如 5000), 温度下降缓慢, 系统在整个预算中都在高温区 "浪费" 大量的随机移动. 典型场景: **连续优化 20 维**, $\alpha=0.995$, MaxFunctionEvaluations=3000. 在最开始 1000 次评估内 $T \approx T_0$, SA 几乎随机游走; budget 耗尽时温度仍高, 最终 Best 值甚至不如初始随机游走的最优值. 判别: 检查 final temperature — 若 > $0.3T_0$, 预算不足. 对策: 通过预算反推 $\alpha$: $\alpha = \exp(\ln(T_{\min}/T_0) / K)$ 其中 $K$ 为退温步数 $\approx$ MaxFunEvals $/$ 链长. 设定 $T_{\min}/T_0 = 10^{-4}$, 例如 5000 评估、链长 50, 100 退温步 → $\alpha = \exp(\ln(10^{-4})/100) \approx 0.91$.

- **条件3: 连续优化选用 SA 而忽略更有效的替代方案 — 效率对比劣势**. 在连续函数优化中, SA 的收敛速度通常明显慢于 PSO (PARADIGM-0106) 和 CMA-ES. 典型场景: **20 维 Ackley 函数**, 同样 5000 次评估: PSO 找到的最优值 $\approx 0.1$, SA 找到的最优值 $\approx 2.5$; SA 需约 20,000 次评估才能与 PSO 持平. 判别: 运行 SA 100 次评估作为基准, 再运行 PSO 100 次评估对比. 若 PSO 在同等评估数下的 Best-so-far 低于 SA 一个数量级以上, SA 不适用于此连续优化. 对策: 换用 PSO; SA 更适合组合优化 (TSP/VRP/调度) 场景.

## 文献

1. Kirkpatrick, S., Gelatt, C.D., & Vecchi, M.P. (1983). "Optimization by Simulated Annealing". *Science*, 220(4598), 671-680. — SA 奠基论文
2. Cerny, V. (1985). "Thermodynamical Approach to the Traveling Salesman Problem". *J. Optimization Theory and Applications*. — 独立提出 SA
3. Hajek, B. (1988). "Cooling Schedules for Optimal Annealing". *Mathematics of Operations Research*. — SA 收敛性理论 (对数退温)
4. van Laarhoven, P.J.M. & Aarts, E.H.L. (1987). *Simulated Annealing: Theory and Applications*. Springer.

## 来源溯源

- Metropolis et al. (1953) 提出 Metropolis 采样算法 (Los Alamos, 计算物理)
- Kirkpatrick et al. (1983) 将 Metropolis 算法映射到组合优化, 创造 "模拟退火" 术语
- Cerny (1985) 独立发现相同方法用于 TSP
- Hajek (1988) 证明对数退温 + 无限链长 → 概率 1 全局最优
- MATLAB: simulannealbnd 始于 R2006a, 集成于 Global Optimization Toolbox

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 — 连续优化替代 | PARADIGM-0106 (PSO) |
| 替代 — 进化计算替代 | PARADIGM-0105 (GA) |
| 互补 — 组合优化互补 | PARADIGM-0114 (TS) |
| 互补 — 精修阶段 | PARADIGM-0103 (fmincon) |
| 增强 — 并行退火 | 独立链并行 + 交换 (parallel tempering) |
