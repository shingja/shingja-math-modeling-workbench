# PARADIGM-0104 动态规划 (Dynamic Programming)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0104 |
| 类别/子类 | ①优化 / 动态规划 |
| 难度 | 高 |
| 适用题型关键词[] | 动态规划, Bellman方程, 最优子结构, 阶段划分, 状态转移, 背包问题, 最短路径, 序列决策, 资源分配, 生产库存, 投资组合, 水库调度, Viterbi算法, 编辑距离, LCS, 打家劫舍, 数字三角形 |
| confidence | medium |
| source | Bellman (1957), Dynamic Programming, Princeton University Press |

## 数学形式

**Bellman 最优性原理**: "An optimal policy has the property that whatever the initial state and initial decision are, the remaining decisions must constitute an optimal policy with regard to the state resulting from the first decision."

离散时间确定性 DP:

$$V_t(s_t) = \min_{a_t \in A(s_t)} \left[ r_t(s_t, a_t) + V_{t+1}\big(T(s_t, a_t)\big) \right]$$

其中:
- $s_t$: 第 $t$ 阶段的状态
- $a_t$: 第 $t$ 阶段的决策 (行动)
- $A(s_t)$: 状态 $s_t$ 下的可行决策集
- $T(s_t, a_t)$: 状态转移函数, $s_{t+1} = T(s_t, a_t)$
- $r_t(s_t, a_t)$: 即时收益 (代价)
- $V_t(s_t)$: 从状态 $s_t$ 到终点的最优值 (值函数)

边界条件: $V_{T+1}(s_{T+1}) = \phi(s_{T+1})$ (终端代价)

**最优策略**: $\pi_t^*(s_t) = \arg\min_{a_t} [r_t(s_t, a_t) + V_{t+1}(T(s_t, a_t))]$

**计算方向**:
- **前向 DP**: $V_{t+1}(s_{t+1}) = \min_{s_t, a_t: T(s_t, a_t)=s_{t+1}} [V_t(s_t) + r_t(s_t, a_t)]$
- **后向 DP** (更常用): 从终点递推到起点, $t=T, T-1, \ldots, 1$

**连续时间版 (HJB 方程)**: $-\partial_t V(t,s) = \min_{a} [r(t,s,a) + \nabla_s V(t,s) \cdot f(t,s,a)]$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| T | int | — | 阶段数, $T \geq 1$ | 高: 线性影响复杂度 |
| state_grid | double[,] | — | 状态离散网格, $N_s \times d$ | **极高**: 指数影响复杂度 |
| action_grid | double[,] | — | 决策离散网格, $N_a \times 1$ | 高: 乘积影响迭代时间 |
| trans_fun | function_handle | — | 状态转移 $s' = T(s, a, t)$ | 核心: 决定问题结构 |
| cost_fun | function_handle | — | 即时代价 $r(s, a, t)$ | 高: 决定值函数形状 |
| terminal_cost | function_handle | — | 终端代价 $\phi(s)$ | 中: 仅影响最后一阶段 |
| discount | double | 1.0 | 折扣因子 $0 < \gamma \leq 1$ | 低: $\gamma<1$ 保证收敛 |

**时间复杂度**: $O(T \times N_s \times N_a)$.
**空间复杂度**: $O(T \times N_s)$, 存储值函数表.
**维数灾难 (Curse of Dimensionality)**: 若状态维度 $d \geq 4$, 每维网格点数 $M$, 则 $N_s = M^d$ 呈指数增长, DP 不可行.

## MATLAB 实现

```matlab
% === 自写-见S5:dp_solver.m ===
% 通用离散确定性 DP 求解器

function [V, policy, path] = dp_solver(T, state_grid, action_grid, ...
                                         trans_fun, cost_fun, terminal_cost)
% dp_solver - 后向动态规划求解器
%
% 输入:
%   T           - 阶段数
%   state_grid  - 状态网格, Ns × d 矩阵
%   action_grid - 决策网格, Na × 1 向量
%   trans_fun   - @(s, a, t) 状态转移函数
%   cost_fun    - @(s, a, t) 即时代价
%   terminal_cost - @(s) 终端代价
%
% 输出:
%   V       - 值函数表, Ns × (T+1)
%   policy  - 最优策略表, Ns × T
%   path    - 从初始状态出发的最优轨迹

Ns = size(state_grid, 1);
Na = length(action_grid);

% 初始化值函数: V(:, T+1) = terminal_cost
V = zeros(Ns, T+1);
policy = zeros(Ns, T);

for s_idx = 1:Ns
    V(s_idx, T+1) = terminal_cost(state_grid(s_idx, :));
end

% 后向递推
for t = T:-1:1
    for s_idx = 1:Ns
        s = state_grid(s_idx, :);
        best_val = inf;
        best_a_idx = 1;
        for a_idx = 1:Na
            a = action_grid(a_idx);
            s_next = trans_fun(s, a, t);
            % 在状态网格中找到 s_next 的最近索引
            [~, s_next_idx] = min(vecnorm(state_grid - s_next, 2, 2));
            val = cost_fun(s, a, t) + V(s_next_idx, t+1);
            if val < best_val
                best_val = val;
                best_a_idx = a_idx;
            end
        end
        V(s_idx, t) = best_val;
        policy(s_idx, t) = best_a_idx;
    end
end

% 前向重构最优路径
path = zeros(T, size(state_grid, 2) + 1);  % [s, a] 每行
s_idx = 1;  % 假设初始状态为 grid 第一个点
for t = 1:T
    a_idx = policy(s_idx, t);
    path(t, :) = [state_grid(s_idx, :), action_grid(a_idx)];
    s_idx = knnsearch(state_grid, ...
        trans_fun(state_grid(s_idx, :), action_grid(a_idx), t));
end

end
```

## Python 备选

```python
import numpy as np

def dp_solver(T, state_grid, action_grid, trans_fun, cost_fun, terminal_cost):
    """后向动态规划求解器"""
    Ns, d = state_grid.shape
    Na = len(action_grid)
    V = np.zeros((Ns, T+1))
    policy = np.zeros((Ns, T), dtype=int)

    # 终端代价
    for i in range(Ns):
        V[i, T] = terminal_cost(state_grid[i])

    # 后向递推
    for t in range(T-1, -1, -1):
        for i in range(Ns):
            best_val, best_a = np.inf, 0
            for j, a in enumerate(action_grid):
                s_next = trans_fun(state_grid[i], a, t)
                i_next = np.argmin(np.linalg.norm(state_grid - s_next, axis=1))
                val = cost_fun(state_grid[i], a, t) + V[i_next, t+1]
                if val < best_val:
                    best_val, best_a = val, j
            V[i, t] = best_val
            policy[i, t] = best_a

    return V, policy
```

## 选型决策树

```
问题是否满足最优子结构?
├─ 否 → DP 不适用, 考虑 GA/PARADIGM-0105 或启发式
└─ 是 → 状态维度 d?
    ├─ d = 1 → DP 完美 (表格法, 复杂度可控)
    ├─ d = 2 → DP 可行 (网格 $100\times100 = 10^4$ 状态)
    ├─ d = 3 → DP 边界 (网格 $50^3 = 125,000$ 状态, 内存约 1MB)
    └─ d ≥ 4 → 维数灾难! 换用近似动态规划 (ADP) 或强化学习
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 建模 | 阶段-状态网络图 (directed acyclic graph) | 展示阶段划分、状态节点与决策弧 |
| 策略 | 值函数曲面 $V(t, s)$ 的 mesh/surf 图 | 展示值函数在状态空间中的形状 |
| 最优路径 | 状态轨迹图 (阶段 vs 状态) | 突出最优路径与次优路径对比 |
| 灵敏度 | 策略不变区域图 (状态空间分区) | 展示各区域由哪个决策主导 |

## 常见坑

1. **维数灾难**: 状态维度 $\geq 4$ 时表格法不可行. 务必修剪状态空间 (只保留可达状态) 或使用稀疏状态表示
2. **状态离散化误差**: 连续状态离散化为网格后, 插值误差导致最优性损失. 对策: 使用自适应网格细化, 在值函数曲率大的区域加密
3. **边界条件错误**: 终端代价和阶段代价的量纲/符号不一致. 对策: 统一检查代价的物理单位, 确保所有项可加
4. **循环依赖**: 无限时域问题中, 值迭代可能不收敛. 对策: $\gamma < 1$ 或策略迭代
5. **状态转移不在网格上**: 使用最近邻查找会导致累积误差. 对策: 双线性插值 (2D) 或重心插值, 提升精度

## 失效条件/反例 (强制小节)

- **条件1: 维数灾难 — 状态维度 $d \geq 4$ 时状态空间爆炸**. 设每维 50 个网格点: 4 维 = $50^4 = 6.25 \times 10^6$ 状态, 存储值函数表约 50 MB; 5 维 = $50^5 = 3.125 \times 10^8$ 状态, 约 2.5 GB. 典型场景: **水库群联合调度** — 5 个水库各有水位状态, $d=5$, 需联合优化. 网格法 DP 直接内存溢出. 判别: 估算需存储的状态数 $M^d$, 若 > $10^6$ 则宣告表格 DP 不可行. 对策: 换用近似动态规划 (ADP)、随机对偶动态规划 (SDDP, 水利领域专用) 或强化学习 (DQN/PPO).

- **条件2: 不满足最优子结构 — DP 解非全局最优**. Bellman 方程成立的前提是问题具有 **最优子结构**: 最优解的子路径也是子问题的最优解. 当存在 "锁定 (lock-in)" 效应或路径依赖时该假设不成立. 典型场景: **带时间窗的车辆路径问题 (VRPTW)** — 当前配送决定影响后续客户的可用时间窗, 贪心子路径选择可能导致后续不可行. 判别: 构造一个小规模算例, 比较 DP 解与穷举解的差异; 若 DP 最优值 > 穷举最优值, 最优子结构不成立. 对策: 将路径依赖信息编码进状态空间 (增大 d), 或放弃 DP 换用 PARADIGM-0102 (MILP) 或 PARADIGM-0105 (GA).

- **条件3: 随机 DP 中转移概率未知或估计不准 — 策略不可靠**. 随机动态规划需要状态转移概率 $P(s'|s, a)$. 在实际问题中这些概率常从有限数据估计, 小样本下估计方差大. 典型场景: **投资组合动态再平衡** — 用 5 年历史数据 (约 1250 个交易日) 估计资产收益的转移概率, 样本量 $\ll$ 状态空间导致大部分 $(s,a,s')$ 三元组从未出现. 判别: 检查 $(s,a)$ 对中至少有一个观测到的 $s'$ 的比例, 若 < 50%, 数据不足以支持 SDP. 对策: 使用模型预测控制 (MPC) 替代 SDP, 对短期确定性优化滚动求解.

## 文献

1. Bellman, R. (1957). *Dynamic Programming*. Princeton University Press. — DP 开创性著作
2. Bertsekas, D.P. (2017). *Dynamic Programming and Optimal Control*, 4th ed. Athena Scientific. — 现代确定性 DP 与随机 DP
3. Powell, W.B. (2011). *Approximate Dynamic Programming*, 2nd ed. Wiley. — 处理维数灾难的 ADP 方法
4. Puterman, M.L. (1994). *Markov Decision Processes*. Wiley. — MDP 理论基础

## 来源溯源

- Bellman (1952) 在 RAND 公司首次使用 "动态规划" 术语 (为规避国防部长对 "数学研究" 的偏见)
- Bellman (1957) 专著系统化 DP 理论 → Howard (1960) 策略迭代 → Bertsekas (1995) 神经动态规划
- 数学建模常用: 最短路 Dijkstra (1959) 可视为 DP 特例; Viterbi (1967) 算法为 HMM+DP

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前驱 — 0-1 背包 DP 特例 | PARADIGM-0102 (intlinprog) |
| 替代 — 全局 NLP | PARADIGM-0103 (fmincon) |
| 替代 — 大规模不可解时 | PARADIGM-0105 (GA) |
| 替代 — 连续最优控制 | ode45 + fmincon 组合 |
| 相关 — 图论最短路 | PARADIGM-0201 (shortestpath) |
