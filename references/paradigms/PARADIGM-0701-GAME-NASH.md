# PARADIGM-0701-GAME-NASH 博弈论双矩阵纳什均衡+Lemke-Howson⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0701-GAME-NASH |
| 类别/子类 | ⑦决策与博弈 / 博弈论 |
| 难度 | 高 |
| 适用题型关键词[] | 纳什均衡, 双矩阵博弈, Lemke-Howson, 混合策略, 支付矩阵, 非合作博弈, 策略优化, 均衡求解 |
| confidence | high |
| source | 补强Ch07 / 论文1964_LemkeHowson / 题解反推_博弈论类 |

## 数学形式

**双矩阵博弈 (Bimatrix Game)**:

行玩家 (Player 1) 有 $m$ 个纯策略, 列玩家 (Player 2) 有 $n$ 个纯策略。
支付矩阵: $\mathbf{A} \in \mathbb{R}^{m \times n}$ (Player 1), $\mathbf{B} \in \mathbb{R}^{m \times n}$ (Player 2)。

混合策略: $\mathbf{x} \in \Delta_m = \{\mathbf{x} \geq \mathbf{0} : \sum_i x_i = 1\}$, $\mathbf{y} \in \Delta_n$。

期望支付: $u_1(\mathbf{x}, \mathbf{y}) = \mathbf{x}^T \mathbf{A} \mathbf{y}$, $u_2(\mathbf{x}, \mathbf{y}) = \mathbf{x}^T \mathbf{B} \mathbf{y}$。

**纳什均衡条件**:

混合策略对 $(\mathbf{x}^*, \mathbf{y}^*)$ 是纳什均衡当:

$$\mathbf{x}^{*T} \mathbf{A} \mathbf{y}^* \geq \mathbf{x}^T \mathbf{A} \mathbf{y}^*, \quad \forall \mathbf{x} \in \Delta_m$$
$$\mathbf{x}^{*T} \mathbf{B} \mathbf{y}^* \geq \mathbf{x}^{*T} \mathbf{B} \mathbf{y}, \quad \forall \mathbf{y} \in \Delta_n$$

等价最优响应条件:

$$\text{supp}(\mathbf{x}^*) \subseteq \arg\max_i (\mathbf{A} \mathbf{y}^*)_i, \quad \text{supp}(\mathbf{y}^*) \subseteq \arg\max_j (\mathbf{x}^{*T} \mathbf{B})_j$$

**线性互补问题 (LCP) 形式**:

令 $\mathbf{u} = \mathbf{A} \mathbf{y} - \mathbf{1}_m v_1$, $\mathbf{v} = \mathbf{B}^T \mathbf{x} - \mathbf{1}_n v_2$, 构造 LCP$(M, q)$:

$$\mathbf{w} = M\mathbf{z} + \mathbf{q}, \quad \mathbf{w} \geq 0, \quad \mathbf{z} \geq 0, \quad \mathbf{w}^T\mathbf{z} = 0$$

**Lemke-Howson 互补旋转算法**:

1. 构造两个多面体 $P_1 = \{(\mathbf{x}, v_1) : \mathbf{B}^T \mathbf{x} \leq \mathbf{1}_n v_1, \, \mathbf{x} \geq 0, \, \sum x_i = 1\}$, $P_2 = \{(\mathbf{y}, v_2) : \mathbf{A} \mathbf{y} \leq \mathbf{1}_m v_2, \, \mathbf{y} \geq 0, \, \sum y_j = 1\}$
2. 对每个 $(\mathbf{x}, v_1) \in P_1$ 定义标签集 $L_1 = \{i : x_i = 0\} \cup \{m + j : (\mathbf{B}^T \mathbf{x})_j = v_1\}$
3. 从人工均衡出发, 交替旋转标签直至找到完全标记点

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $\mathbf{A}_{m \times n}$ | Player 1 支付矩阵 | 实数矩阵 |
| $\mathbf{B}_{m \times n}$ | Player 2 支付矩阵 | 实数矩阵 |
| $\mathbf{x}$ | Player 1 混合策略 | 单纯形 $\Delta_m$ |
| $\mathbf{y}$ | Player 2 混合策略 | 单纯形 $\Delta_n$ |
| $v_1, v_2$ | 均衡支付值 | 标量 |
| $\text{supp}(\mathbf{x})$ | 支撑集 (正概率策略) | $\{1, \ldots, m\}$ 子集 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 行策略数 $m$ | int | — | 2-50 | 中—计算量随策略数多项式增长 |
| 列策略数 $n$ | int | — | 2-50 | 中 |
| 支付矩阵 $\mathbf{A}, \mathbf{B}$ | float[][] | — | 任意实数 | 极高—支付结构决定均衡存在性与唯一性 |
| 退化容忍 $\varepsilon$ | float | 1e-8 | 1e-12~1e-6 | 高—退化时易出现数值不稳定 |
| LCP 初始射线方向 (Lemke) | int | 1 | 1 到 $m+n$ | 中—不同选择可能收敛到不同均衡 |

**Lemke-Howson 时间复杂度**: 最坏指数级 ($O(2^{\min(m,n)})$), 但实际中多为多项式
**LCP 互补旋转复杂度**: 每步 $O((m+n)^2)$ (基础旋转)
**枚举支撑集验证**: $O(2^{m+n} \cdot (m+n)^3)$, 仅小规模可行

## MATLAB 实现

```matlab
% === Lemke-Howson 算法 (双矩阵纳什均衡) ===
% 自写-见S5:lemke_howson.m
function [x, y, v1, v2] = lemke_howson(A, B)
    % A: m×n Player 1 支付矩阵
    % B: m×n Player 2 支付矩阵
    % x: m×1 Player 1 混合策略
    % y: n×1 Player 2 混合策略
    % v1, v2: 均衡支付值
    
    % 1. 确保 A, B 非负 (加常数偏置不影响均衡, 但 LCP 需要非负)
    A_shift = A - min(A(:)) + 1;
    B_shift = B - min(B(:)) + 1;
    
    % 2. 构造互补旋转表
    % 3. Lemke-Howson 主循环 (pivoting)
    % [具体实现见S5]
end

% === 简单枚举 (小规模验证) ===
% 枚举所有可能的支撑集并验证均衡条件
function equilibria = enumerate_nash_small(A, B)
    [m, n] = size(A);
    equilibria = {};
    for s1 = 1:(2^m - 1)  % 行玩家支撑集
        for s2 = 1:(2^n - 1)  % 列玩家支撑集
            % 解等支付方程组, 检查是否为均衡
        end
    end
end

% === 锚点参考 ===
% Optimization Toolbox: linprog 可用于求解零和博弈 (单人LP)
% 非零和双矩阵: 需自写 Lemke-Howson 或调用 Gambit
```

**锚点工具箱**: `linprog` (Optimization Toolbox, 零和博弈专用)
**自写 (S5)**: `lemke_howson.m` — Lemke-Howson 完整实现 + 支撑集枚举备用

## Python 备选

```python
import nashpy as nash
import numpy as np

A = np.array([[3, 0], [5, 1]])  # Player 1 支付
B = np.array([[3, 5], [0, 1]])  # Player 2 支付

game = nash.Game(A, B)

# Lemke-Howson 求解 (可能返回不同均衡)
equilibria = list(game.lemke_howson_enumeration())
for eq in equilibria:
    print(f"x* = {eq[0]}, y* = {eq[1]}")

# 支撑集枚举 (小规模)
eq_support = list(game.support_enumeration())

# 不动点迭代 (近似)
eq_fp = game.fictitious_play(iterations=10000)
```

备选库: `gambit` (通过 Python 绑定, 支持所有均衡概念), `pygambit` (原生 Gambit)

## 选型决策树

- **2 玩家 + 策略数 ≤ 20** → Lemke-Howson (精确, 标准方法)
- **2 玩家 + 策略数 > 50 + 只需一个均衡** → 不动点迭代 (fictitious play, 收敛慢但稳定)
- **零和博弈 (A = -B^T)** → 线性规划 `linprog` (单纯形法, $O((m+n)^3)$)
- **n > 2 玩家** → Gambit 的 simplicial subdivision 或全局 Newton (PPAD-完全, 无多项式算法)
- **不完全信息博弈** → Harsanyi 变换 + Bayesian Nash Equilibrium
- **演化博弈/种群博弈** → 复制子动力学 (Replicator Dynamics) 见 PARADIGM-0720-REPLICATOR
- **需要所有均衡** → 支撑集枚举 (仅 $m, n \leq 10$) 或 polyhedral homotopy
- **大规模 + 近似可接受** → 反事实遗憾最小化 (CFR, 适用于序列博弈)

## 典型图型

- **raw**: 支付矩阵热力图 ($\mathbf{A}, \mathbf{B}$ 并排)
- **process**: Lemke-Howson 路径图 (在单纯形上的旋转轨迹)
- **result**: 混合策略概率条形图 ($\mathbf{x}^*, \mathbf{y}^*$)、最优响应对应图
- **进阶**: 支付空间路径 (fictitious play 收敛轨迹)、均衡支付散点 (多个初始点 → 多个均衡)

## 常见坑

1. **退化均衡 (Degeneracy)**: 支撑集大小超过对应策略数, Lemke-Howson 可能出现循环 (cycling), 需 Bland's rule 或 lexicographic perturbation
2. **多均衡时初始选择偏倚**: Lemke-Howson 以不同初始标签开始可能收敛到不同均衡, 且不是所有均衡可达
3. **支付矩阵平移破坏 LCP 结构**: Lemke-Howson 要求 $\mathbf{A}, \mathbf{B} > 0$ (或至少每行每列非全零), 不当平移可能改变均衡或导致 LCP 无解
4. **严格均衡不存在时 (非严格均衡)**: 检验均衡时不可仅检查最优响应 — 弱被支配策略可能出现在支撑集
5. **纯策略均衡被混合策略掩盖**: 部分支付矩阵同时存在纯策略和混合策略均衡, 求解器可能只返回一个

## 失效条件/反例 (强制小节)

- **条件1**: 支付矩阵存在退化均衡 — 当某个策略的期望支付等于均衡支付但不在支撑集内, Lemke-Howson 的互补旋转可能陷入循环 (cycling), 表现为算法在有限顶点间无限循环不终止。**检测**: 连续 100 步迭代后标签模式开始重复。**替代**: Bland's 反循环规则 (最小指标规则) 或 lexicographic perturbation
- **条件2**: $n > 2$ 玩家 — 双矩阵博弈公式化为 $(\mathbf{A}, \mathbf{B})$ 对, 不适用于三人及以上博弈。n-player 纳什均衡求解是 PPAD-完全的, 不存在已知多项式算法。**替代**: simplicial subdivision 算法 (Gambit), 或转化为多智能体强化学习问题
- **条件3**: 非零和博弈 + 支付矩阵含有零行/列 — Lemke-Howson 要求构造的 LCP 矩阵正定, 零行/列导致 LCP 退化。**预处理**: Garica-Zangwill 扰动或加小正数 $\delta > 0$ 偏置
- **条件4**: 期望找到 Pareto-最优均衡 (而非任意均衡) — Lemke-Howson 不保证返回"最优"均衡 (如囚徒困境中的合作均衡)。**替代**: 枚举所有均衡后筛选, 或使用均衡精炼 (equilibrium refinement) 概念

## 文献

1. von Neumann, J. & Morgenstern, O. (1944). *Theory of Games and Economic Behavior*. Princeton University Press. ISBN: 978-0691119934.
2. Lemke, C. E. & Howson, J. T. (1964). Equilibrium points of bimatrix games. *Journal of the Society for Industrial and Applied Mathematics*, 12(2), 413-423. DOI: [10.1137/0112033](https://doi.org/10.1137/0112033).
3. Nisan, N., Roughgarden, T., Tardos, E., & Vazirani, V. V. (Eds.). (2007). *Algorithmic Game Theory*. Cambridge University Press. ISBN: 978-0521872829.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第7章 对策论/博弈论
- 论文三元组: Lemke & Howson 1964, bimatrix equilibrium, complementary pivoting
- 开源仓库: [Nashpy](https://github.com/drvinceknight/Nashpy), [Gambit](https://github.com/gambitproject/gambit)

## 关联范式卡

组合: PARADIGM-0705-DECISION-TREE (博弈结果作为决策树效用输入), PARADIGM-0720-REPLICATOR (演化稳定策略检验)
替代: PARADIGM-0101-LP (零和博弈 → 线性规划), PARADIGM-0317-DES (大规模博弈仿真)
前置: PARADIGM-0103-PROBSTAT (概率基础—混合策略期望), PARADIGM-0101-LP (线性规划基础—对偶/LCP)
