# PARADIGM-1102-ROBUST-COUNTERPART Bertsimas-Sim鲁棒对应⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1102-ROBUST-COUNTERPART |
| 类别/子类 | ⑪鲁棒/随机优化 / 鲁棒优化 |
| 难度 | 高 |
| 适用题型关键词[] | 鲁棒优化, 参数不确定性, 保守决策, 保护水平, 预算不确定性集 |
| confidence | medium |
| source | 论文2004_RobustLP / 题解反推_RobustOpt类 |

## 数学形式

**核心思想**: 在系数不确定下找到对任意可行实现均满足约束的解——"免疫"不确定性。

对于标称 LP $\min \mathbf{c}^T\mathbf{x}$ s.t. $\mathbf{A}\mathbf{x} \leq \mathbf{b}$, 其中 $a_{ij} \in [\bar{a}_{ij} - \hat{a}_{ij}, \bar{a}_{ij} + \hat{a}_{ij}]$ (对称区间):

**Bertsimas-Sim 鲁棒对应**: 每约束 $i$ 有保护参数 $\Gamma_i \in [0, |J_i|]$ ($J_i$ 为第 $i$ 约束的不确定系数集合):

$$\min \mathbf{c}^T\mathbf{x}$$
$$\text{s.t.} \quad \bar{a}_i^T \mathbf{x} + \max_{\{S_i \cup \{t_i\} | S_i \subseteq J_i, |S_i| \leq \lfloor \Gamma_i \rfloor, t_i \in J_i\setminus S_i\}} \left\{ \sum_{j \in S_i} \hat{a}_{ij} |x_j| + (\Gamma_i - \lfloor \Gamma_i \rfloor) \hat{a}_{it_i} |x_{t_i}| \right\} \leq b_i$$

等价线性规划 (引入辅助变量 $p_i, q_{ij}$):
$$\min \mathbf{c}^T\mathbf{x}$$
$$\text{s.t.} \quad \bar{a}_i^T \mathbf{x} + \Gamma_i p_i + \sum_{j \in J_i} q_{ij} \leq b_i \quad \forall i$$
$$p_i + q_{ij} \geq \hat{a}_{ij} y_j \quad \forall i, j \in J_i$$
$$-y_j \leq x_j \leq y_j \quad \forall j$$
$$p_i, q_{ij}, y_j \geq 0$$

| 变量 | 含义 | 典型值 |
|------|------|--------|
| $\Gamma_i$ | 保护水平 (不确定预算) | $0$ (标称) ~ $|J_i|$ (完全鲁棒) |
| $\bar{a}_{ij}$ | 系数标称值 | — |
| $\hat{a}_{ij}$ | 系数最大偏差 | — |
| $p_i, q_{ij}$ | 鲁棒对应辅助变量 | — |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| $\Gamma$ (保护水平) | float[] | $0.5|J|$ | $0 - |J|$ | 极高—从0(风险中性)到$|J|$(最保守) |
| 系数扰动幅度 $\hat{a}$ | float[] | 标称的 10% | 1%-50% | 高 |
| 鲁棒对应形式 | enum | Bertsimas-Sim | B-S/盒装(box)/椭圆 | 高—盒装太保守, B-S可控 |

**复杂度**: 鲁棒对应的 LP 规模 = 原 LP 规模 + $O(\sum_i |J_i|)$ 的辅助约束和变量

## MATLAB 实现

```matlab
% Bertsimas-Sim 鲁棒对应 (LP 解法)
% linprog/fmincon + 自写

% 原问题: min c'x s.t. A*x <= b, lb <= x <= ub
% 鲁棒对应变量: [x; y; p; q(ij)]
% 
% 自写-见S5:robust_linear_program.m
% 
% 实现步骤:
% 1. 输入标称 A_bar, 最大偏差 A_hat, 保护水平 Gamma
% 2. 构造增广 LP: 加入 y_j, p_i, q_ij
% 3. 约束: A_bar*x + Gamma.*p + sum(q,2) <= b
%         p_i + q_ij >= A_hat_ij * y_j (∀i,j)
%        -y_j <= x_j <= y_j
% 4. linprog 求解
```

**锚点工具箱**: `linprog` (Optimization Toolbox)
**非鲁棒/非线性**: `fmincon` (若原问题非线性, 鲁棒对应也需 NLP)

## Python 备选

```python
from scipy.optimize import linprog
import numpy as np

def robust_lp(c, A_bar, A_hat, b, Gamma, lb=None, ub=None):
    m, n = A_bar.shape
    # 变量: [x_1..n, y_1..n, p_1..m, q_11..q_mn]
    # ...构造增广 LP 系数矩阵...
    n_vars = 2*n + m + m*n
    # A_ineq * vars <= b_ineq, bounds
    res = linprog(c_ext, A_ub=A_ineq, b_ub=b_ineq, bounds=bnds)
    return res.x[:n]
```

备选: `ROME` (Robust Optimization Made Easy, MATLAB 工具包), `cvxpy` + 自定义鲁棒对应

## 选型决策树

- **参数与不确定性边界已知 + 需免疫最坏情况** → 鲁棒对应 (确定性等价, 一条求解)
- **不确定参数有概率分布** → 机会约束规划 (PARADIGM-1103) 或 CVaR (PARADIGM-1101)
- **$\Gamma$ 未知** → 参数扫描: $\Gamma = 0, 1, 2, \ldots, |J|$ 绘制成本 vs 保护水平曲线, 选 elbow
- **完全鲁棒 (Soyster)** → $\Gamma = |J|$, 极度保守, 目标函数代价巨大 → B-S 优于 Soyster
- **椭圆不确定性集 vs 盒式**: 椭圆对应导致二阶锥 (SOCP), B-S 保持线性可解性

## 典型图型

- **raw**: 参数不确定性区间图 (标称 + 上下界)
- **process**: 目标函数值 vs $\Gamma$ (保护水平) 的 trade-off 曲线; 约束违背概率 vs $\Gamma$ (理论 bound)
- **result**: 鲁棒解与标称解的决策变量对比柱状图, 各场景下目标值箱线图 (MC验证)

## 常见坑

1. **$\Gamma$ 选择太保守**: $\Gamma$ 取最大值 $\rightarrow$ 解极度昂贵, 实际不确定性远比这小 → 从 $\Gamma=0$ 逐步加大, 找 elbow
2. **系数扰动方向不完全对称**: B-S 假设 $a \in [\bar{a} - \hat{a}, \bar{a} + \hat{a}]$; 若不对称 → 扩展为不对称 B-S, 增加线性不等式数
3. **目标函数系数也含不确定性**: 原始 B-S 仅约束系数鲁棒; 目标用 min-max 需额外步骤 (对偶转化)
4. **高维大量约束时 LP 规模爆炸**: 每约束增加 $|J|$ 个 $q_{ij}$ 和对应的约束 → 变量和约束数倍增

## 失效条件/反例 (强制小节)

- **条件1**: 不确定性区间 $\hat{a}$ 不可知（无专家判断或历史数据）→ 鲁棒对应的核心假设是"偏差量可量化"; 若区间纯属猜测, 保护水平 $\Gamma$ 无依据, 结果的信度与输入假设一样差。**替代**: 分布鲁棒优化 (DRO) 或直接 MC 采样优化
- **条件2**: 不确定参数数目极大 + 原始问题非 LP → 鲁棒对应可能需 SOCP/SDP 求解, 求解难度陡增; 且辅助变量爆炸 ($O(m \cdot n)$ 个 $q_{ij}$)。**替代**: 简单随机规划 (场景法) 或 并行 MC + 筛选
- **条件3**: 最优解高度依赖调参数 $\Gamma$ 的选取 → B-S 鲁棒把不确定性偏好折叠为单一标量 $\Gamma$, 若决策者对不确定性缺乏判断, 输出对 $\Gamma$ 过于敏感, 缺乏稳健性。**替代**: 多 $\Gamma$ 扫描 + elbow 法, 或换 CVaR (更自然的参数化)
- **条件4**: 含整数变量 (MILP) → 鲁棒对应可能将 MILP 变为非线性离散优化 (整数变量的 $|x_j|$ 绝对值难以线性化)。**替代**: 针对 MILP 的鲁棒分支定界专门方法, 或场景逼近

## 文献

1. Bertsimas, D., & Sim, M. (2004). The price of robustness. *Operations Research*, 52(1), 35-53. DOI: [10.1287/opre.1030.0065](https://doi.org/10.1287/opre.1030.0065)
2. Ben-Tal, A., El Ghaoui, L., & Nemirovski, A. (2009). *Robust Optimization*. Princeton University Press. ISBN: 978-0-691-14368-2.

## 来源溯源

- 论文三元组: Bertsimas 2004, Price of Robustness, budgeted uncertainty + LP tractability
- 教学用例: 生产计划(需求不确定), 物流网络(运输成本不确定)

## 关联范式卡

组合: PARADIGM-1101-CVAR (鲁棒+风险), PARADIGM-1103-CHANCE-CONSTRAINT (概率保证)
替代: 场景随机规划 (多场景), 分布鲁棒优化 (DRO)
前置: LP (PARADIGM-0101-LP)
