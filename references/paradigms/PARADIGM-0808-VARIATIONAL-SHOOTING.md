# PARADIGM-0808-VARIATIONAL-SHOOTING 变分法打靶法+Euler-Lagrange⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0808-VARIATIONAL-SHOOTING |
| 类别/子类 | ⑧机理建模 / 变分法 |
| 难度 | 高 |
| 适用题型关键词[] | 变分法, Euler-Lagrange方程, 打靶法, 边值问题, 泛函极值, 最优控制, 最速降线, 极小曲面 |
| confidence | high |
| source | 补强Ch18 / 教材2003_Elsgolts / 题解反推_变分法类 |

## 数学形式

**泛函极值问题**:

$$\min_{y(x)} J[y] = \int_{x_0}^{x_1} F(x, y, y') \, dx$$

$$\text{s.t. } y(x_0) = y_0, \quad y(x_1) = y_1 \quad \text{(固定端点)}$$

**Euler-Lagrange 方程 (必要条件)**:

$$\frac{\partial F}{\partial y} - \frac{d}{dx} \left( \frac{\partial F}{\partial y'} \right) = 0$$

展开形式:

$$F_y - F_{y'x} - F_{y'y} y' - F_{y'y'} y'' = 0$$

**特殊情况的首次积分**:

1. $F$ 不显含 $y$: $\frac{\partial F}{\partial y'} = \text{const}$ (Beltrami 恒等式前身)
2. $F$ 不显含 $x$: $F - y' \frac{\partial F}{\partial y'} = C$ (Beltrami 恒等式)

**打靶法 (Shooting Method) 求解边值问题**:

将两点边值问题 (BVP) 转化为初值问题 (IVP):

$$\begin{cases} y'' = g(x, y, y') \\ y(x_0) = y_0 \\ y'(x_0) = s \quad \text{(射击参数, 待定)} \end{cases}$$

定义残差函数: $\phi(s) = y(x_1; s) - y_1$。

用 Newton 法/割线法寻根: $s_{k+1} = s_k - \frac{\phi(s_k)}{\phi'(s_k)}$。

**最优控制中的变分法 (Pontryagin 极大值原理前置)**:

$$J = \Phi(x(t_f), t_f) + \int_{t_0}^{t_f} L(x, u, t) \, dt$$

Hamiltonian: $H(x, u, \lambda, t) = L + \lambda^T f(x, u, t)$。

协态方程: $\dot{\lambda} = -\partial H / \partial x$。

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $y(x)$ | 极值曲线 (待求函数) | $[x_0, x_1] \to \mathbb{R}$ |
| $F$ | Lagrange 函数 (被积函数) | 连续二阶可微 |
| $y'$ | $dy/dx$ | — |
| $s$ | 打靶参数 (初始斜率) | 扫描范围需覆盖解 |
| $\phi(s)$ | 打靶残差 | 寻根使之为 0 |
| $\lambda$ | 协态变量 (伴随变量) | — |
| $u$ | 控制变量 | — |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 初始猜测 $s_0$ | float | 0.0 | — | 极高—不好猜测导致发散或收敛到错误解 |
| 打靶容差 `tol` | float | 1e-6 | 1e-10~1e-3 | 中 |
| 积分步长 $h$ | float | 0.01 | 0.001-0.1 | 高—太大精度不够, 太小累积舍入误差 |
| 最大打靶迭代 `max_iter` | int | 50 | 10-200 | 低 |
| Newton 法中 $\phi'(s)$ 差分步长 | float | $\sqrt{\varepsilon_{\text{mach}}}$ | 1e-8~1e-4 | 中—太小数值噪声, 太大截断误差 |
| 端点条件 $y(x_1) = y_1$ | float | — | — | 定解条件 |

**Euler-Lagrange 解析推导**: $O(1)$ (符号计算)
**打靶法每步**: $O(N_{\text{steps}})$ = $O((x_1 - x_0)/h)$, 每次 IVP 积分
**总复杂度**: $O(K \cdot N_{\text{steps}})$, $K$ 为打靶迭代次数
**非线性 BVP 多解**: 打靶法一次收敛到一个解, 多解需多初始猜测并行

## MATLAB 实现

```matlab
% === 打靶法 (Shooting Method) for BVP ===
% 自写-见S5:shooting_method.m
function [x, y, s_final] = shooting_method(odefun, xspan, y0, y1_target, s0, tol)
    % odefun: @(x, y) [y(2); ...] 一阶系统
    % xspan: [x0, x1]
    % y0: 左端点 y(x0)
    % y1_target: 右端点目标值 y(x1) = y1_target
    % s0: 初始斜率猜测
    % tol: 收敛容差
    
    s = s0;
    for iter = 1:50
        % 1. 用猜测 s 积分 IVP
        [~, Y] = ode45(odefun, xspan, [y0; s]);
        y1_actual = Y(end, 1);
        
        % 2. 计算残差
        phi = y1_actual - y1_target;
        if abs(phi) < tol
            break;
        end
        
        % 3. 割线法更新 s (或 Newton 法用变分方程)
        % 扰动 s 计算数值导数
        [~, Y_pert] = ode45(odefun, xspan, [y0; s + 1e-6]);
        phi_pert = Y_pert(end, 1) - y1_target;
        dphi = (phi_pert - phi) / 1e-6;
        
        s = s - phi / dphi;  % Newton 步
    end
    
    [x, Y] = ode45(odefun, linspace(xspan(1), xspan(2), 200), [y0; s]);
    y = Y(:, 1);
    s_final = s;
end

% === 多重打靶法 (Multiple Shooting) 对刚性/长区间 BVP ===
% 将长区间分段, 每段内打靶, 段间添加连续性约束
% 自写-见S5:shooting_method.m (multiple_shooting 子函数)

% === 锚点工具箱 ===
% bvp4c / bvp5c: MATLAB 内置 BVP 求解器 (有限差分/配置法)
% bvpinit + bvp4c 是打靶法的推荐替代
solinit = bvpinit(linspace(0, 1, 10), @(x) [0; 0]);
sol = bvp4c(@bvp_ode, @bvp_bc, solinit);
```

**锚点工具箱**: `bvp4c` / `bvp5c` (MATLAB 内置 BVP 求解器, 推荐用于稳定 BVP)
**自写 (S5)**: `shooting_method.m` — 单打靶 + 多重打靶 + Euler-Lagrange 符号推导辅助

## Python 备选

```python
import numpy as np
from scipy.integrate import solve_ivp, solve_bvp

# 打靶法 (手写)
def shooting(odefun, xspan, y0, y1_target, s0, tol=1e-6, max_iter=50):
    s = s0
    for _ in range(max_iter):
        sol = solve_ivp(odefun, xspan, [y0, s], method='RK45')
        y1_actual = sol.y[0, -1]
        phi = y1_actual - y1_target
        if abs(phi) < tol:
            break
        # 数值导数
        sol_pert = solve_ivp(odefun, xspan, [y0, s + 1e-6], method='RK45')
        phi_pert = sol_pert.y[0, -1] - y1_target
        dphi = (phi_pert - phi) / 1e-6
        s -= phi / dphi
    return s

# scipy BVP 求解器 (推荐)
def bvp_ode(x, y):
    return np.vstack([y[1], -np.exp(y[0])])  # 例: y'' = -e^y

def bvp_bc(ya, yb):
    return np.array([ya[0], yb[0]])  # y(0)=0, y(1)=0

x = np.linspace(0, 1, 20)
y_init = np.zeros((2, x.size))
sol = solve_bvp(bvp_ode, bvp_bc, x, y_init)

# Euler-Lagrange 符号推导
import sympy as sp
x, y, yp = sp.symbols('x y yp')
F = yp**2 + y**2  # 例: F = (y')^2 + y^2
EL = sp.diff(F, y) - sp.diff(sp.diff(F, yp), x) - sp.diff(sp.diff(F, yp), y)*yp - sp.diff(sp.diff(F, yp), yp)*sp.Derivative(yp, x)
sp.simplify(EL)
```

备选库: `sympy.physics.mechanics` (力学变分原理), `cvxpy` (凸最优控制 → 离散化+凸规划)

## 选型决策树

- **BVP 非刚性 + 解曲线单调** → 单打靶 (简单, 收敛快)
- **BVP 刚性 / 解曲线震荡 / 长区间** → 多重打靶 (multiple shooting) 或 `bvp4c` (内置配置法)
- **Euler-Lagrange 可解析推导** → 先用符号计算得 ODE, 再用打靶/配置法数值求解
- **最优控制 (含控制变量约束)** → 直接法 (配点法 → NLP) 或间接法 (Pontryagin + 打靶)
- **变分法 + 不等式约束** → 需用最优控制理论 (Pontryagin) 或转为互补问题
- **高维 BVP ($\dim > 4$)** → 配置法优于打靶 (打靶的初值敏感性在高维中急剧恶化)
- **前端/内边界层问题** → 自适应网格 `bvp5c` 或 `bvp4c` 优于均匀打靶

## 典型图型

- **raw**: 打靶迭代中不同 $s$ 值的积分曲线族 (多条 IVP 轨迹, 颜色表示迭代序)
- **process**: $\phi(s)$ (残差函数) vs $s$, 显示零点位置、Newton 迭代路径
- **result**: 极值曲线 $y(x)$ 与边界条件标记、Hamiltonian 沿轨迹常数检验 (Beltrami 验证)
- **进阶**: 打靶区域收敛盆地图 ($s_0$ 着色 → 吸引到哪个解), 多重打靶的分段配置可视化

## 常见坑

1. **初始猜测 $s_0$ 远离真解导致发散**: 打靶法的收敛半径可能很小, 特别是非线性强时。对策: 连续性方法 (continuation)—先解简化版问题, 逐步增加非线性
2. **打靶方程刚性**: IVP 积分时使用固定步长 RK4 会积累误差 → 须用自适应步长 `ode45`/`solve_ivp`
3. **$\phi'(s) \approx 0$ 在零点处**: Newton 法步长无穷大 → 用割线法 (secant) 或二分法-Brent 混合
4. **混淆局部极值**: Euler-Lagrange 仅给驻点 (必要条件), 不保证极小 — Jacobi 条件 (共轭点检验) 和 Legendre 条件 ($F_{y'y'} \geq 0$) 需单独验证
5. **横截条件 (transversality) 处理错误**: 当端点不在固定位置 (如终端自由) 时, 自然边界条件不是 $y(x_1) = y_1$ 而是 $\partial F / \partial y'|_{x_1} = 0$ — 边界条件用错导致整条曲线错误

## 失效条件/反例 (强制小节)

- **条件1**: BVP 刚性 (stiff) 或对初始值极敏感 — 如 $y'' = 100y$, 在 $[0, 1]$ 上解为双曲正弦, 初始斜率微小扰动导致终点值的指数级放大。打靶法的 $\phi(s)$ 呈现极端陡峭, Newton 迭代发散或收敛到数值噪声解。**表现**: 很小的 $s$ 变化 (1e-6) 导致 $\phi(s)$ 变化数十倍, 割线斜率不可靠。**替代**: 多重打靶法 (将区间分 $N$ 段, 每段独立打靶 + 段间连续性约束) 或内置配置法 `bvp4c`/`solve_bvp`
- **条件2**: 横截条件 (边界条件) 定义不清或不正确 — 当右端点自由 (终端时间/状态可变) 时, 自然边界条件是 $\partial F / \partial y'|_{x_1} = 0$, 而非人为指定的 $y(x_1) = y_1$。**表现**: 用错边界条件得到的"解"不满足原始泛函极值, 或出现无穷多"解"(解非唯一)。**检查**: 确认原始问题是固定端点还是自由端点, 自由端点需推导 transversality condition
- **条件3**: $F_{y'y'} = 0$ (退化泛函) — Euler-Lagrange 方程退化为代数方程而非二阶 ODE, 打靶法的 ODE 形式不存在。**表现**: 变分问题降阶, 不能用 $y'' = g(x,y,y')$ 形式表达。**替代**: 直接处理退化形式 (代数约束 + 一阶 ODE), 或转为 DAE (微分-代数方程) 求解
- **条件4**: Euler-Lagrange 解为局部极大值而非极小 — 打靶法求得驻点后不做二阶变分检验, 可能将鞍点/极大点误报为最优解。**检测**: Legendre 条件 ($F_{y'y'} \geq 0$ 必要, $>0$ 充分), Jacobi 条件 (无共轭点)

## 文献

1. Elsgolts, L. D. (2003). *Differential Equations and the Calculus of Variations*. Dover Publications. ISBN: 978-0486432335.
2. Gelfand, I. M. & Fomin, S. V. (2000). *Calculus of Variations*. Dover Publications. ISBN: 978-0486414485.
3. Ascher, U. M., Mattheij, R. M. M., & Russell, R. D. (1995). *Numerical Solution of Boundary Value Problems for Ordinary Differential Equations*. SIAM. ISBN: 978-0898713541.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第18章 变分法建模
- 论文三元组: Ascher 1995, BVP numerical methods, shooting + collocation comparison
- 开源仓库: [scipy.integrate.solve_bvp](https://docs.scipy.org/doc/scipy/reference/generated/scipy.integrate.solve_bvp.html)

## 关联范式卡

组合: PARADIGM-0807-DIFFEQ-ITERATOR (差分法作为变分问题的离散化替代), PARADIGM-0604-OPT-CTRL (最优控制—Pontryagin 极大值原理)
替代: PARADIGM-0809-PDE-FDM (PDE 数值解—边值问题在 PDE 中的推广), PARADIGM-0403-ODE-RK (ODE IVP 求解—打靶的基础步)
前置: PARADIGM-0801-MECHANISM-MODELING (机理建模基础—从物理原理到泛函), PARADIGM-0102-NONLINEAR-EQ (非线性方程求根—Newton 法)
