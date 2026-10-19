# PARADIGM-0809-PDE-FDM-SOLVER PDE有限差分FTCS/Crank-Nicolson/ADI⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0809-PDE-FDM-SOLVER |
| 类别/子类 | ⑧机理建模 / PDE数值解 |
| 难度 | 高 |
| 适用题型关键词[] | 偏微分方程, 有限差分, FTCS, Crank-Nicolson, ADI, 稳定性, 收敛性, von Neumann, 热传导, 扩散方程, 波动方程 |
| confidence | high |
| source | 补强Ch20 / 教材2007_LeVeque / 题解反推_PDE数值解类 |

## 数学形式

**一维热传导方程 (扩散方程)**:

$$\frac{\partial u}{\partial t} = \alpha \frac{\partial^2 u}{\partial x^2}, \quad x \in [0, L], \; t \geq 0$$

初始条件 $u(x, 0) = u_0(x)$; 边界条件 Dirichlet / Neumann / Robin。

**FTCS (Forward Time Central Space)**:

$$\frac{u_j^{n+1} - u_j^n}{\Delta t} = \alpha \frac{u_{j+1}^n - 2u_j^n + u_{j-1}^n}{\Delta x^2}$$

显式格式 (直接推进):

$$u_j^{n+1} = u_j^n + r \left(u_{j+1}^n - 2u_j^n + u_{j-1}^n\right), \quad r = \frac{\alpha \Delta t}{\Delta x^2}$$

**Crank-Nicolson (C-N, 隐式)**:

$$\frac{u_j^{n+1} - u_j^n}{\Delta t} = \frac{\alpha}{2} \left( \frac{u_{j+1}^n - 2u_j^n + u_{j-1}^n}{\Delta x^2} + \frac{u_{j+1}^{n+1} - 2u_j^{n+1} + u_{j-1}^{n+1}}{\Delta x^2} \right)$$

矩阵形式 (三对角 Thomass 算法求解):

$$-\frac{r}{2} u_{j-1}^{n+1} + (1+r) u_j^{n+1} - \frac{r}{2} u_{j+1}^{n+1} = \frac{r}{2} u_{j-1}^n + (1-r) u_j^n + \frac{r}{2} u_{j+1}^n$$

**ADI (Alternating Direction Implicit, 二维)**:

在 $n \to n+\frac{1}{2}$ 半时间步: $x$ 方向隐式, $y$ 方向显式
在 $n+\frac{1}{2} \to n+1$ 半时间步: $y$ 方向隐式, $x$ 方向显式

每次只需解三对角系统, $O(N_x N_y)$ 每时间步。

**von Neumann 稳定性分析**:

假设 $u_j^n = \xi^n e^{i k j \Delta x}$ ($\xi$ 为放大因子)。

$$|\xi(k)| \leq 1 \quad \forall k \;\Leftrightarrow\; \text{格式稳定}$$

- FTCS: $\xi = 1 - 4r \sin^2(k\Delta x / 2)$, 稳定条件 $r \leq 1/2$
- Crank-Nicolson: $\xi = \frac{1 - 2r \sin^2(k\Delta x / 2)}{1 + 2r \sin^2(k\Delta x / 2)}$, $|\xi| \leq 1$ 无条件稳定

**空间精度与截断误差**:

$$\tau_{\text{FTCS}} = O(\Delta t) + O(\Delta x^2), \quad \tau_{\text{C-N}} = O(\Delta t^2) + O(\Delta x^2)$$

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $\alpha$ | 扩散系数/热扩散率 | $>0$ |
| $\Delta t$ | 时间步长 | 受稳定性约束 |
| $\Delta x$ | 空间步长 | $L/N_x$ |
| $r$ | 网格比 = $\alpha \Delta t / \Delta x^2$ | FTCS: $\leq 1/2$ (1D) |
| $u_j^n$ | 格点 $(x_j, t_n)$ 近似解 | — |
| $\xi$ | von Neumann 放大因子 | $\vert\xi\vert \leq 1$ 稳定 |
| $N_x, N_y$ | 空间网格点数 | 50-1000 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 网格比 $r$ | float | 0.4 | FTCS: (0, 0.5]; C-N: (0, $\infty$) | 极高—FTCS 超过 0.5 立即爆炸 |
| 空间网格数 $N_x$ | int | 100 | 20-5000 | 高—精度 vs 计算量权衡 |
| 时间步长 $\Delta t$ | float | $0.4\Delta x^2/\alpha$ | CFL 条件约束 | 极高—决定稳定性 |
| 扩散系数 $\alpha$ | float | 1.0 | >0 | 高—直接进入 $r$, 通过网格比影响稳定 |
| 边界条件类型 | enum | Dirichlet | D/N/R | 高—Neumann 需单侧差分, 精度降阶 |
| 初始条件光滑性 | — | — | — | 中—间断导致 C-N 振荡 |

**FTCS 每时间步**: $O(N_x)$ (显式, 逐点更新)
**Crank-Nicolson 每时间步**: $O(N_x)$ (三对角 Thomass 算法)
**ADI 每时间步**: $O(N_x N_y)$ (两个三对角系统)
**总时间步数**: $N_t = T / \Delta t$
**FTCS 总复杂度**: $O(N_x \cdot N_t)$, 由于 $N_t \propto N_x^2$ (稳定性约束), 实际 $O(N_x^3)$ 在 1D
**C-N 总复杂度**: $O(N_x \cdot N_t)$, 可取大 $\Delta t$ 使 $N_t \ll N_x$, 实际 $O(N_x \cdot C)$

## MATLAB 实现

```matlab
% === 1D FTCS 热传导求解器 ===
% 自写-见S5:pde_fdm_solver.m
function u = heat_ftcs(alpha, L, T, Nx, Nt, u0_func, bc_left, bc_right)
    dx = L / (Nx - 1);
    dt = T / Nt;
    r = alpha * dt / dx^2;
    
    if r > 0.5
        warning('FTCS 不稳定: r = %.4f > 0.5, 考虑减小 dt 或用 Crank-Nicolson', r);
    end
    
    x = linspace(0, L, Nx);
    u = u0_func(x);  % 初始条件
    
    for n = 1:Nt
        u_new = u;
        for j = 2:Nx-1
            u_new(j) = u(j) + r * (u(j+1) - 2*u(j) + u(j-1));
        end
        % 边界条件
        u_new(1) = bc_left;    % Dirichlet
        u_new(end) = bc_right;
        u = u_new;
    end
end

% === 1D Crank-Nicolson ===
function u = heat_crank_nicolson(alpha, L, T, Nx, Nt, u0_func, bc_left, bc_right)
    dx = L / (Nx - 1);
    dt = T / Nt;
    r = alpha * dt / dx^2;
    
    x = linspace(0, L, Nx)';
    u = u0_func(x);
    
    % 构造三对角矩阵 A (左端) 和 B (右端)
    a = -r/2 * ones(Nx-2, 1);
    b_main = (1 + r) * ones(Nx-2, 1);
    c = -r/2 * ones(Nx-2, 1);
    A = spdiags([a b_main c], [-1 0 1], Nx-2, Nx-2);
    
    aB = r/2 * ones(Nx-2, 1);
    bB = (1 - r) * ones(Nx-2, 1);
    cB = r/2 * ones(Nx-2, 1);
    B = spdiags([aB bB cB], [-1 0 1], Nx-2, Nx-2);
    
    for n = 1:Nt
        rhs = B * u(2:end-1);
        rhs(1) = rhs(1) + r/2 * bc_left + r/2 * bc_left;   % 边界贡献
        rhs(end) = rhs(end) + r/2 * bc_right + r/2 * bc_right;
        u(2:end-1) = A \ rhs;  % 三对角求解
    end
end

% === 锚点工具箱 (仅用于对比验证) ===
% pdepe: MATLAB 内置 1D PDE 求解器 (Method of Lines + 自适应网格)
% sol = pdepe(m, @pdefun, @icfun, @bcfun, xmesh, tspan);
```

**锚点工具箱**: `pdepe` (MATLAB 内置 1D 抛物/椭圆 PDE 求解器, 方法线与自适应网格, 仅用于对比验证)
**自写 (S5)**: `pde_fdm_solver.m` — FTCS + Crank-Nicolson + ADI (2D) + von Neumann 稳定性分析器

## Python 备选

```python
import numpy as np
from scipy.sparse import diags
from scipy.sparse.linalg import spsolve

# 1D FTCS
def heat_ftcs(alpha, L, T, Nx, Nt, u0, bc_l, bc_r):
    dx = L / (Nx - 1); dt = T / Nt
    r = alpha * dt / dx**2
    assert r <= 0.5, f"FTCS 不稳定: r={r:.4f}"
    u = u0.copy()
    for _ in range(Nt):
        u_new = u.copy()
        u_new[1:-1] = u[1:-1] + r * (u[2:] - 2*u[1:-1] + u[:-2])
        u_new[0], u_new[-1] = bc_l, bc_r
        u = u_new
    return u

# 1D Crank-Nicolson
def heat_cn(alpha, L, T, Nx, Nt, u0, bc_l, bc_r):
    dx = L / (Nx - 1); dt = T / Nt
    r = alpha * dt / dx**2
    # 三对角矩阵
    main_diag_A = (1 + r) * np.ones(Nx - 2)
    off_diag_A = (-r / 2) * np.ones(Nx - 3)
    A = diags([off_diag_A, main_diag_A, off_diag_A], [-1, 0, 1], format='csr')
    
    main_diag_B = (1 - r) * np.ones(Nx - 2)
    off_diag_B = (r / 2) * np.ones(Nx - 3)
    B = diags([off_diag_B, main_diag_B, off_diag_B], [-1, 0, 1], format='csr')
    
    u = u0.copy()
    for _ in range(Nt):
        rhs = B @ u[1:-1]
        rhs[0] += r/2 * (bc_l + bc_l)
        rhs[-1] += r/2 * (bc_r + bc_r)
        u[1:-1] = spsolve(A, rhs)
    return u

# 2D ADI
# 见 pde_fdm_solver.m S5 实现
```

备选库: `scipy.integrate.solve_ivp` (方法线, 1D PDE 半离散后为 ODE 系统), `FiPy` (有限体积法, 非结构化网格), `FEniCSx` (有限元, 复杂几何)

## 选型决策树

- **1D 扩散/热传导 + 精度要求不高 + 快速原型** → FTCS (实现最简单, 但 $\Delta t$ 受严格约束)
- **1D 扩散 + 无条件稳定 + 二阶时间精度** → Crank-Nicolson (标准选择, 一般无脑选这个)
- **1D 对流-扩散 (对流占优)** → 迎风格式 (upwind) 或 Lax-Wendroff, C-N 会产生振荡
- **1D 波动方程** → CTCS (Central Time Central Space), CFL 条件 $c\Delta t / \Delta x \leq 1$
- **2D 扩散** → ADI (效率高, $O(N_x N_y)$ 每时间步) 或 Douglas-Gunn
- **复杂几何 / 非结构网格** → 有限元法 (FEM) 而非有限差分, 见 `FEniCSx`
- **非线性 PDE** → C-N + Newton 迭代 或 IMEX (Implicit-Explicit) 分裂格式
- **只需稳态解 (椭圆 PDE)** → 直接迭代法 (Jacobi/Gauss-Seidel/SOR), 不需时间步进
- **MATLAB 内置方案对比** → `pdepe` 仅作验证用 (黑箱, 建模比赛中建议展示自写方法)

## 典型图型

- **raw**: 初始条件 $u(x,0)$ 的线图
- **process**: 时间演化 3D 曲面图 (waterfall/surf)—$x$ 轴, $t$ 轴, $u(x,t)$ 轴; 或多时刻快照叠加
- **result**: 稳态解 $u(x, T)$ + 解析解对比 (如有); von Neumann $|\xi(k)|$ vs $k\Delta x$ 图 (稳定性验证)
- **进阶**: 网格收敛分析 (双对数图—误差 vs $\Delta x$), 能量守恒/衰减验证 ($\int u^2 dx$ vs $t$)

## 常见坑

1. **FTCS 时间步长超出稳定限**: $r > 0.5$ (1D) 或 $r > 0.25$ (2D) → 高频傅里叶模指数增长, 几秒内 NaN。强制在代码第一行检查 $r$ 并抛出断言
2. **Crank-Nicolson 在间断初始条件处振荡**: C-N 无数值耗散, 高频分量不衰减 → 间断附近出现 Gibbs 现象 (锯齿)。对策: 前几步用隐式 Euler (L-稳定, 全阻尼) 平滑过渡到 C-N
3. **Neumann 边界条件实现错误**: 需用单侧差分 (一阶精度 $\partial u / \partial x|_0 \approx (u_1 - u_0)/\Delta x$) 或镜像虚点法 (二阶精度)
4. **对流方程 (一阶空间导数) 用中心差分导致不稳定**: $\partial u / \partial t + c \partial u / \partial x = 0$ 用 FTCS 格式无条件不稳定 (von Neumann $\xi = 1 - i r \sin(k\Delta x)$, $|\xi| > 1$) → 必须用迎风 (upwind) 格式
5. **时间步长与空间步长独立设置导致 $r$ 恶化**: 编写代码时将 $\Delta t$ 作为导出量 ($\Delta t = r_{\text{target}} \cdot \Delta x^2 / \alpha$) 而非自由参数

## 失效条件/反例 (强制小节)

- **条件1**: FTCS 格式且 $r = \alpha \Delta t / \Delta x^2 > 0.5$ (1D) — von Neumann 稳定性分析表明放大因子 $|\xi| = |1 - 4r \sin^2(k\Delta x/2)|$ 在高频 ($k\Delta x \approx \pi$) 时超过 1, 高频模态以指数速度放大。**表现**: 几至几十个时间步后解中出现锯齿状高频噪声, 随后振幅指数增长至 $\pm 10^{20}$ 量级, 最终 NaN/Inf。**检测**: 每一步检查 $\max(|u|)$ 是否异常增长。**替代**: 降低 $\Delta t$ 使 $r \leq 0.5$, 或改用 Crank-Nicolson (无条件稳定)
- **条件2**: Crank-Nicolson 格式 + 间断初始条件 (如阶跃函数 $u(x,0) = 1_{[0, L/2]}$) — C-N 无数值耗散 (阻尼为零), 高频 Fourier 分量不衰减, 间断两侧产生持久的格点级锯齿振荡 (spurious oscillations)。**表现**: 初始光滑解演化看起来有"噪音", 峰/谷交替出现且不随网格加密而消失。**检测**: 总变差 (TV) 不随 C-N 单调递减 (对于线性扩散, TV 应递减)。**替代**: 前 5-10 个时间步用全隐式 Euler ($O(\Delta t)$, L-稳定, 强阻尼) 平滑间断, 之后切换到 C-N; 或使用 $\theta$-格式 ($\theta = 0.55$ 比 0.5 引入少量数值耗散)
- **条件3**: 对流占优 ($Pe = c L / \alpha \gg 1$, Peclet 数大) — 中心差分 (含 C-N) 的截断误差产生数值色散, 解出现非物理的振荡 (wiggles)。**表现**: 陡峭前缘/锋面后方出现幅度 5-10% 的波纹状振荡。**替代**: 迎风格式 (upwind, 一阶耗散) 或 MUSCL/TVD 高分辨率格式
- **条件4**: 非线性扩散系数 $\alpha(u)$ — C-N 的直接线性化 (lagging $\alpha(u^n)$) 可能在锋面处突破稳定限。**表现**: 看似稳定的 $r$ 值下仍产生局部振荡或非物理解。**替代**: Newton-Krylov 完全隐式或 IMEX 分裂

## 文献

1. LeVeque, R. J. (2007). *Finite Difference Methods for Ordinary and Partial Differential Equations: Steady-State and Time-Dependent Problems*. SIAM. ISBN: 978-0898716290.
2. Strikwerda, J. C. (2004). *Finite Difference Schemes and Partial Differential Equations* (2nd ed.). SIAM. ISBN: 978-0898716399.
3. Morton, K. W. & Mayers, D. F. (2005). *Numerical Solution of Partial Differential Equations* (2nd ed.). Cambridge University Press. ISBN: 978-0521607933.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第20章 偏微分方程数值解
- 论文三元组: LeVeque 2007, FDM for ODE/PDE, SIAM
- 开源仓库: [py-pde](https://github.com/zwicker-group/py-pde) (Python PDE 求解器), [Clawpack](http://www.clawpack.org/) (有限体积法, 双曲 PDE)

## 关联范式卡

组合: PARADIGM-0801-MECHANISM-MODELING (物理模型 → PDE), PARADIGM-0808-VARIATIONAL-SHOOTING (变分法二阶 BVP → 有限差分离散化)
替代: PARADIGM-0603-FEM (有限元法—复杂几何/非结构网格), PARADIGM-0317-DES (随机 PDE → 蒙特卡洛仿真)
前置: PARADIGM-0104-LINEAR-ALG (线性代数—三对角/稀疏矩阵求解), PARADIGM-0106-NUMERICAL-INT (数值积分/微分基础)
