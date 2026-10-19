# PARADIGM-0813 对流扩散方程迎风格式⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0813 |
| 类别/子类 | ⑧机理建模与PDE / 对流扩散 |
| 难度 | 高 |
| 适用题型关键词[] | 对流扩散, 迎风格式, 污染物扩散, Peclet数, 数值振荡, FDM, Upwind, LeVeque |
| confidence | high |
| source | LeVeque (2002) Cambridge |

## 数学形式

**1D 稳态对流扩散:**
$$u\frac{dC}{dx} = D\frac{d^2C}{dx^2} + S$$

**Peclet 数 (衡量对流 vs 扩散):**
$$Pe = \frac{uL}{D}$$

**中心差分问题 (Pe > 2 时振荡):**
$$\frac{C_{i+1} - C_{i-1}}{2\Delta x}$$
在 Pe > 2 时产生非物理的负浓度振荡。

**迎风格式 (Upwind, 一阶):**
根据流向选择单侧差分:
- 若 $u > 0$: $\frac{C_i - C_{i-1}}{\Delta x}$
- 若 $u < 0$: $\frac{C_{i+1} - C_i}{\Delta x}$

**指数格式 (精确, 1D 稳态):**
$$C(x) = C_0 + (C_L - C_0)\frac{e^{Pe \cdot x/L} - 1}{e^{Pe} - 1}$$

**瞬态对流扩散 (BTCS + Upwind):**
$$\frac{C_i^{n+1} - C_i^n}{\Delta t} + u \cdot \text{Upwind}(C^{n+1}) = D\frac{C_{i+1}^{n+1} - 2C_i^{n+1} + C_{i-1}^{n+1}}{\Delta x^2}$$

**数值扩散 vs 物理扩散:** 一阶迎风格式引入人工粘度 $\propto u\Delta x/2$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| u (流速) | double | 1.0 | (-∞,∞) | 极高 — 决定 Pe |
| D (扩散系数) | double | 0.01 | [0,∞) | 极高 — Pe = uL/D |
| dx | double | 0.01 | [1e-4,0.5] | 高 — 网格 Peclet |
| scheme | str | 'upwind' | 'cds','upwind','quick','exponential' | 中 |

## MATLAB 实现

```matlab
% 1D 瞬态对流扩散 (迎风隐式)
function C = advection_diffusion_1d(Nx, T_end, u, D, S_fn, bc)
    dx = 1/(Nx-1);
    dt = min(0.1*dx/abs(u), 0.5*dx^2/D);
    Nt = ceil(T_end / dt);
    C = zeros(Nx, 1);
    
    for n = 1:Nt
        % 构建三对角矩阵 (迎风)
        a = zeros(Nx,1); b = zeros(Nx,1); c = zeros(Nx,1); rhs = C;
        
        for i = 2:Nx-1
            if u > 0  % 迎风 = 后差
                a(i) = -D/dx^2;
                b(i) = 1/dt + u/dx + 2*D/dx^2;
                c(i) = -(D/dx^2 + u/dx);
            else  % 迎风 = 前差
                a(i) = -(D/dx^2 - u/dx);
                b(i) = 1/dt - u/dx + 2*D/dx^2;
                c(i) = -D/dx^2;
            end
            rhs(i) = C(i)/dt + S_fn(i, n*dt);
        end
        C = tridiag_solve(a, b, c, rhs);
    end
end

% 网格 Peclet 检测
Pe_grid = abs(u) * dx / D;
if Pe_grid > 2
    warning('Grid Peclet = %.2f > 2, use upwind or refine grid', Pe_grid);
end
```

锚点: 自写-见S5:advection_diffusion_1d.m

## Python 备选

```python
import numpy as np
from scipy.sparse import diags
from scipy.sparse.linalg import spsolve

# 迎风隐式格式
def upwind_implicit_step(C, u, D, dx, dt):
    N = len(C)
    if u > 0:
        diag = 1/dt + u/dx + 2*D/dx**2
        lower = -D/dx**2 - u/dx
        upper = -D/dx**2
    else:
        diag = 1/dt - u/dx + 2*D/dx**2
        lower = -D/dx**2
        upper = -D/dx**2 + u/dx
    A = diags([lower, diag, upper], [-1, 0, 1], shape=(N,N))
    return spsolve(A, C/dt)
```

## 选型决策树

- **Upwind (一阶)** — Pe > 2, 计算效率要求高，接受数值扩散
- **中心差分** — Pe < 2, 精度要求高 → 无人工粘度
- **QUICK (三阶)** — Pe 中等到大, 需要平衡精度和稳定性
- **指数格式** — 1D 稳态精确求解 (无数值扩散/振荡)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | 中心差分 vs 迎风对比 (同一 Pe) | 展示振荡 vs 数值扩散 |
| result | C(x) 稳态剖面 | 对解析解验证 |
| result | C(x,t) waterfall | 对流传播+扩散平滑 |

## 常见坑

1. **中心差分在 Pe>2 时非物理解**: 产生负浓度或振荡 → 必须改用迎风或 QUICK
2. **一阶迎风数值扩散严重**: 陡峭前缘被抹平 → 用 QUICK 格式或细化网格
3. **边界层分辨率**: 出口边界在 Pe 大时边界层厚度 $\sim D/u$，网格需在此细化

## 失效条件/反例 (强制小节)

- **条件1: 高 Peclet 数 (Pe > 100) + 粗网格** → 表现: 即使迎风格式也产生显著数值扩散 (人工粘度 ∝ uΔx/2)，实际物理扩散项被数值扩散淹没 → 浓度剖面过度平滑，峰值低估 > 30%。**应对**: 细化网格使 Pe_grid < 2，或使用高阶格式 (QUICK/MUSCL/Flux Limiter)
- **条件2: 非线性对流 (Burgers 方程, u 依赖于 C)** → 表现: 波阵面变陡 (shock formation)，线性迎风格式无法捕捉激波 → 激波处产生振荡 (Gibbs)。**应对**: 使用 TVD (Total Variation Diminishing) 格式或 Godunov 型有限体积法

## 文献

1. LeVeque R.J. (2002). *Finite Volume Methods for Hyperbolic Problems*. Cambridge University Press. ISBN: 978-0521009249
2. Patankar S.V. (1980). *Numerical Heat Transfer and Fluid Flow*. Hemisphere. ISBN: 978-0891165224

## 来源溯源

自写 advection_diffusion_1d.m; 计算流体力学教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0809 (PDE FDM求解器) |
| 组合 | PARADIGM-0811 (反应扩散) |
| 组合 | PARADIGM-0812 (热传导2D) |
