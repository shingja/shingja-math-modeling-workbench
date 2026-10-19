# PARADIGM-0103 非线性规划 (Nonlinear Programming)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0103 |
| 类别/子类 | ①优化 / 非线性规划 |
| 难度 | 高 |
| 适用题型关键词[] | 非线性规划, fmincon, SQP, 内点法, KKT条件, 局部最优, 全局最优, 非线性约束, Lagrange乘子, 参数估计, 最优控制, 轨迹优化, 工程优化, 经济均衡, 反应器设计 |
| confidence | medium |
| source | Nocedal & Wright (2006), Numerical Optimization, Springer |

## 数学形式

一般非线性规划 (NLP):

$$\min_{\mathbf{x}} \; f(\mathbf{x})$$
$$\text{s.t.} \; \mathbf{c}(\mathbf{x}) \leq \mathbf{0}, \quad \mathbf{c}_{eq}(\mathbf{x}) = \mathbf{0}$$
$$\mathbf{lb} \leq \mathbf{x} \leq \mathbf{ub}$$

其中 $f: \mathbb{R}^n \to \mathbb{R}$, $\mathbf{c}: \mathbb{R}^n \to \mathbb{R}^m$, $\mathbf{c}_{eq}: \mathbb{R}^n \to \mathbb{R}^p$ 至少有一个是非线性函数.

**KKT 条件 (一阶必要条件)**:

若 $\mathbf{x}^*$ 为局部最优解且满足约束规范 (LICQ), 则存在 Lagrange 乘子 $\boldsymbol{\lambda}$ 和 $\boldsymbol{\mu}$ 使得:

$$\nabla f(\mathbf{x}^*) + \nabla \mathbf{c}(\mathbf{x}^*)^T \boldsymbol{\lambda} + \nabla \mathbf{c}_{eq}(\mathbf{x}^*)^T \boldsymbol{\mu} = \mathbf{0}$$
$$\mathbf{c}(\mathbf{x}^*) \leq \mathbf{0}, \quad \mathbf{c}_{eq}(\mathbf{x}^*) = \mathbf{0}$$
$$\boldsymbol{\lambda} \geq \mathbf{0}, \quad \lambda_i c_i(\mathbf{x}^*) = 0 \quad (\text{互补松弛})$$

**fmincon 两大算法族**:

1. **SQP (Sequential Quadratic Programming)** — 默认算法. 每步求解 QP 子问题逼近原 NLP:
   $$\min_{\mathbf{d}} \frac{1}{2}\mathbf{d}^T \mathbf{H}_k \mathbf{d} + \nabla f(\mathbf{x}_k)^T \mathbf{d}$$
   $$\text{s.t.} \; \nabla \mathbf{c}(\mathbf{x}_k)^T \mathbf{d} + \mathbf{c}(\mathbf{x}_k) \leq \mathbf{0}$$
   用 BFGS 近似 Hessian. 适合中小规模 ($n \leq 100$).

2. **内点法 (Interior-Point)** — `'interior-point'`. 引入障碍函数将不等式约束化为障碍项:
   $$\min_{\mathbf{x},\mathbf{s}} f(\mathbf{x}) - \mu \sum_i \ln(s_i) \quad \text{s.t.} \; \mathbf{c}(\mathbf{x}) + \mathbf{s} = \mathbf{0}, \; \mathbf{s} \geq \mathbf{0}$$
   适合大规模 ($n > 100$) 和稀疏问题.

3. **Active-Set**: 适合中小规模, 对初始点附近活跃集变化敏感.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| x0 | double[] | — | 初始点, 长度 n | **极高**: 非凸问题结果依赖 x0 |
| fun | function_handle | — | 目标函数 f(x) | 高 |
| nonlcon | function_handle | [] | 非线性约束函数 [c, ceq] | 高 |
| A | double[,] | [] | 线性不等式矩阵 | 中 |
| b | double[] | [] | 线性不等式右端 | 中 |
| Aeq | double[,] | [] | 线性等式矩阵 | 中 |
| beq | double[] | [] | 线性等式右端 | 中 |
| lb | double[] | [] | 下界 | 中 |
| ub | double[] | [] | 上界 | 中 |
| Algorithm | char | 'sqp' | 'sqp' \| 'interior-point' \| 'active-set' | 高: 影响收敛性与速度 |
| GradObj | char | 'off' | 'on' \| 'off' | 高: 提供梯度大幅加速 |
| GradConstr | char | 'off' | 'on' \| 'off' | 高: 提供约束梯度大幅加速 |

**复杂度**: 每次迭代 $O(n^3)$ 若 Hessian 稠密; 实际问题依赖稀疏性和梯度可用性. 收敛速度一般为超线性 (SQP) 或二次 (精确 Hessian).

## MATLAB 实现

```matlab
% === fmincon 非线性规划 ===
% 目标函数
fun = @(x) x(1)^2 + x(2)^2 + 3*x(1)*x(2) - sin(x(1));

% 非线性约束: c(x) <= 0, ceq(x) = 0
nonlcon = @(x) deal(...
    [x(1)^2 + x(2)^2 - 10;      % c1: 在圆内
     -x(1) - x(2) + 1],         % c2: x1+x2 >= 1
    [] );                        % 无等式约束

x0 = [0; 0];
lb = [-5; -5];
ub = [5; 5];

% 提供梯度可显著改善收敛
opts = optimoptions('fmincon', ...
    'Algorithm', 'sqp', ...
    'Display', 'iter-detailed', ...
    'SpecifyObjectiveGradient', false, ...
    'CheckGradients', true, ...     % 开发阶段验证梯度
    'OptimalityTolerance', 1e-6);

[x, fval, exitflag, output, lambda] = fmincon(fun, x0, [], [], [], [], lb, ub, nonlcon, opts);

% exitflag 解读:
%  1: 一阶最优性满足
%  2: 步长/自变量变化小于容差
%  0: 超过最大迭代/函数计算次数
% -1: 被输出函数或绘图函数终止
% -2: 找不到可行点
```

## Python 备选

```python
# SciPy minimize (开源)
from scipy.optimize import minimize, NonlinearConstraint
res = minimize(fun, x0, method='SLSQP', constraints=[
    {'type': 'ineq', 'fun': c_fun},
    {'type': 'eq', 'fun': ceq_fun}
], bounds=Bounds(lb, ub))

# CasADi + IPOPT (推荐, 开源, 高性能)
import casadi as ca
# 支持自动微分, 适合大规模和最优控制

# pyomo (大规模建模, 支持多种求解器后端)
```

## 选型决策树

```
问题是否凸?
├─ 是 → fmincon (任何算法即可, 结果可靠)
└─ 否 → 目标/约束是否光滑且梯度可用?
    ├─ 是 → 多起点 fmincon + GlobalSearch/MultiStart
    └─ 否 → 是否有整数变量?
        ├─ 是 → PARADIGM-0105 (GA) 或 PARADIGM-0106 (PSO)
        └─ 否 → PARADIGM-0109 (SA) 或 surrogateopt 全局搜索
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 建模 | 三维曲面 + 可行域边界 | 展示目标函数地形与约束交集 |
| 求解过程 | 迭代轨迹图 (contour + 路径) | 展示 x_k 序列在等高线图上的移动 |
| 收敛分析 | 最优性残差 vs 迭代次数 (semilogy) | 验证收敛速率 |
| 结果验证 | KKT 残差条形图 | 展示梯度条件/互补松弛/约束违反 |
| 灵敏度 | Lagrange 乘子 $\lambda$ 柱状图 | 哪条约束紧, 影子价格多大 |

## 常见坑

1. **初始点敏感**: 非凸问题不同 x0 收敛到不同局部最优. 对策: `MultiStart` 或 `GlobalSearch` (全局优化工具箱) 跑 20~50 个随机起点
2. **梯度误差**: 有限差分梯度对病态问题误差大, 导致收敛慢或发散. 对策: 解析提供梯度 (GradObj/GradConstr='on'), 或用 AD (自动微分) 工具
3. **不可行检测困难**: 约束互相矛盾时 fmincon 可能返回 `exitflag=-2` 但无进一步诊断. 对策: 先解可行性问题 $\min 0$ s.t. 约束, 定位冲突约束
4. **数值缩放**: 变量量纲差异过大 (如 $x_1 \sim 10^{-6}$, $x_2 \sim 10^6$) 导致 Hessian 条件数极大. 对策: 标准化变量到 [0,1] 或 [-1,1]
5. **SQP Hessian 近似退化**: BFGS 更新在非凸区域可能产生不定 Hessian, SQP 子问题无解. 对策: 切换 interior-point 或使用阻尼 BFGS

## 失效条件/反例 (强制小节)

- **条件1: 目标函数高度非凸且存在大量局部最优 — 陷入局部最优**. 当目标函数的非凸程度严重, 局部最优数量随维度指数增长时, 任何基于梯度的局部搜索方法 (SQP/IP/Active-Set) 都无法保证全局最优. 典型场景: **蛋白质折叠自由能极小化** — 维度 n=100+, 局部极小点 > $10^{10}$, 梯度法几乎确定落入最近局部谷底. 判别: 用 50 个随机 x0 分别求解, 若最优值和次优值差距 > 30% 或解分布极度分散, 说明多起点 NLP 不足以全局寻优. 对策: 换用 PARADIGM-0105 (GA), PARADIGM-0106 (PSO) 或 surrogateopt 进行全局搜索, 再以 fmincon 精修.

- **条件2: 初始点选择不当导致收敛到无意义解或发散**. 对于带等式约束的非凸问题 (如轨迹优化), 满足 $c_{eq}(x)=0$ 的点可能构成低维流形. 若 x0 远离该流形, SQP 的 QP 子问题可能不可行或线搜索找不到满足充分下降条件的步长. 典型场景: **火箭轨迹优化** — 6 自由度动力学约束 $c_{eq}(x)=0$ 需精确满足, x0 偏离可行域 > 20% 时 SQP 发散. 判别: 检查第一次迭代的 QP 子问题是否可行 (`output.stepsize` 为 0 且 exitflag $\neq$ 1). 对策: 用打靶法 (shooting) 或直接配点法 (direct collocation) 将等式约束融入状态方程, 或先用 GA 找一个可行初始点.

- **条件3: 梯度不可用且问题维度 $n > 50$ — 有限差分慢且不准确**. fmincon 默认用前向有限差分计算梯度, 每步需 $n+1$ 次函数评估. 维度 $n=100$ 时, 每次迭代调用 101 次目标函数; 若单次函数评估耗时长 (如 CFD 模拟 1s/次), 100 次迭代则需 $\approx 10,000$ 秒. 同时有限差分对噪声敏感, 导数误差 $\approx 10^{-4}$ 可能导致收敛停滞. 判别: 函数评估时间 $\times n >$ 可接受迭代时间. 对策: 使用 surrogateopt (不需梯度) 或提供解析梯度.

## 文献

1. Nocedal, J. & Wright, S.J. (2006). *Numerical Optimization*, 2nd ed. Springer. — 非线性优化圣经, 覆盖 SQP/IP/信赖域/线搜索
2. Bazaraa, M.S., Sherali, H.D., & Shetty, C.M. (2006). *Nonlinear Programming*, 3rd ed. Wiley. — 理论与对偶
3. Gill, P.E., Murray, W., & Wright, M.H. (1981). *Practical Optimization*. Academic Press. — SQP/Active-Set 实现细节
4. Byrd, R.H., Hribar, M.E., & Nocedal, J. (1999). "An Interior Point Algorithm for Large-Scale Nonlinear Programming". *SIAM J. Optim.*

## 来源溯源

- Karush (1939) 硕士论文 → Kuhn & Tucker (1951) KKT 条件完整形式
- Wilson (1963) SQP 雏形 → Han (1976) & Powell (1978) 现代 SQP 框架
- Karmarkar (1984) 线性内点法 → Byrd et al. (1999) 非线性内点法
- MATLAB fmincon: 前身 constr (1980s) → fmincon (1993, Optimization Toolbox 1.0)

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前驱 — 无约束版本 | PARADIGM-0100 (fminunc) |
| 前驱 — 线性版本 | PARADIGM-0101 (linprog) |
| 前驱 — 整数版本 | PARADIGM-0102 (intlinprog) |
| 替代 — 全局优化 | PARADIGM-0105 (GA) |
| 替代 — 全局优化 | PARADIGM-0106 (PSO) |
| 增强 — 多起点策略 | GlobalSearch / MultiStart |
