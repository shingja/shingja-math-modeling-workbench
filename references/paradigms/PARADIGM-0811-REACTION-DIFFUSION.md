# PARADIGM-0811 反应扩散方程⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0811 |
| 类别/子类 | ⑧机理建模与PDE / 反应扩散系统 |
| 难度 | 高 |
| 适用题型关键词[] | 反应扩散, Turing模式, 扩散驱动不稳定, pdepe, FDM, 图灵斑图, 形态发生, 空间格局 |
| confidence | medium |
| source | Turing (1952) Phil Trans R Soc B |

## 数学形式

**一般反应-扩散系统 (两物种):**
$$\frac{\partial u}{\partial t} = D_u \nabla^2 u + f(u,v)$$
$$\frac{\partial v}{\partial t} = D_v \nabla^2 v + g(u,v)$$

**Turing 不稳定性条件:**

1. 齐次稳态 $(u^*,v^*)$ 在没有扩散时稳定:
   $$f_u + g_v < 0, \quad f_u g_v - f_v g_u > 0$$

2. 加入扩散后不稳定 (需 $D_v \gg D_u$):
   $$D_v f_u + D_u g_v > 2\sqrt{D_u D_v (f_u g_v - f_v g_u)}$$

**Turing 模式波长:**
$$k_{\text{peak}} \approx \sqrt{\frac{f_u g_v - f_v g_u}{D_u D_v}}$$

**数值求解 (FDM, 1D):**
$$\frac{u_i^{n+1} - u_i^n}{\Delta t} = D_u \frac{u_{i+1}^n - 2u_i^n + u_{i-1}^n}{\Delta x^2} + f(u_i^n, v_i^n)$$

稳定性条件: $\Delta t \leq \frac{\Delta x^2}{2\max(D_u, D_v)}$

**经典 Turing 系统:**
- **Schnakenberg:** $f = \alpha - u + u^2 v, \quad g = \beta - u^2 v$
- **Gierer-Meinhardt:** $f = \rho\frac{u^2}{v} - \mu_u u, \quad g = \rho u^2 - \mu_v v$
- **Gray-Scott:** $f = -uv^2 + F(1-u), \quad g = uv^2 - (F+k)v$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| Du | double | 0.1 | [1e-4, 10] | 极高 — Turing条件 |
| Dv | double | 1.0 | [1, 100] | 极高 — Dv/Du>临界值 |
| Nx | int | 100 | [50, 500] | 高 — 空间分辨率 |
| dt | double | 0.001 | [1e-5, 0.1] | 高 — CFL稳定性 |
| 复杂度 | — | — | O(Nt·Nx) 1D; O(Nt·Nx·Ny) 2D | — |

## MATLAB 实现

```matlab
% pdepe (1D 反应扩散)
m = 0;  % 平板/柱/球对称
x = linspace(0, L, Nx);
t = linspace(0, T, Nt);

sol = pdepe(m, @pdefun, @icfun, @bcfun, x, t);
u = sol(:,:,1); v = sol(:,:,2);

% 自写 1D FDM (更灵活)
function [U, V] = reaction_diffusion_1d(Nx, T, dt, Du, Dv, f, g)
    dx = 1/(Nx-1);
    U = zeros(Nx,1); V = zeros(Nx,1);
    % ...初始条件...
    for n = 1:floor(T/dt)
        U_new = U + dt*(Du*laplacian_1d(U,dx) + f(U,V));
        V_new = V + dt*(Dv*laplacian_1d(V,dx) + g(U,V));
        U = U_new; V = V_new;
    end
end
```

锚点: `pdepe` (MATLAB内置) + 自写FDM-见S5:reaction_diffusion_1d.m

## Python 备选

```python
import numpy as np
from scipy.integrate import solve_ivp

# 1D 线方法 (Method of Lines)
def rhs(t, y, Nx, dx, Du, Dv):
    U = y[:Nx]; V = y[Nx:]
    Lu = Du * (np.roll(U,-1) - 2*U + np.roll(U,1)) / dx**2
    Lv = Dv * (np.roll(V,-1) - 2*V + np.roll(V,1)) / dx**2
    return np.concatenate([Lu + f(U,V), Lv + g(U,V)])
```

## 选型决策树

- **反应扩散** — 空间格局/模式形成、种群扩散、生态入侵、肿瘤生长
- **纯 ODE (PARADIGM-0804)** — 空间均匀假设，忽略扩散
- **Agent-Based** — 个体异质性和局部交互很重要时
- **pdepe** — 1D 抛物型/椭圆型 PDE → MATLAB 内置方便

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | u(x,t) 瀑布图 (waterfall/u(x)随时间) | 模式演化 |
| result | 最终稳态空间模式 (stripes/spots) | Turing 斑图 |
| result | 色散关系 $\lambda(k)$ 曲线 | 展示不稳定波段 |

## 常见坑

1. **CFL 不稳定**: dt 太大 → FDM 数值爆炸 → $\Delta t \leq \Delta x^2/(2\max(D_u,D_v))$
2. **Turing 参数空间狭窄**: 随机试验大概率找不到 Turing 模式 → 先用线性稳定性分析找参数区间
3. **1D vs 2D 模式差异**: 1D 仅产生 stripes; 2D 产生 spots+stripes+labyrinths (取决于非线性项)

## 失效条件/反例 (强制小节)

- **条件1: 反应项 Jacobian 不满足 Turing 条件** → 表现: 无论扩散系数如何选择，空间均匀稳态始终稳定 — 无模式形成。检查: $f_u>0$ 且 $g_v<0$ ("activator-inhibitor" 必须有不同扩散率)。**应对**: 重新设计反应项以符合 Activator-Inhibitor 结构 (慢扩散自激活+快扩散抑制子)
- **条件2: 计算域太小 ($L$ 小于 Turing 波长的 1/2)** → 表现: 域大小不能容纳一个完整的 Turing 模式波长，齐次稳态在有限域上稳定 — 定性上未观察到模式。**应对**: $L \geq 2\pi/k_{\text{peak}}$，或使用周期性边界条件

## 文献

1. Turing A.M. (1952). "The chemical basis of morphogenesis." *Phil Trans R Soc B*, 237(641):37-72. DOI: [10.1098/rstb.1952.0012](https://doi.org/10.1098/rstb.1952.0012)
2. Murray J.D. (2003). *Mathematical Biology II: Spatial Models and Biomedical Applications*, 3rd ed. Springer. ISBN: 978-0387952284

## 来源溯源

pdepe + 自写FDM; 数学生物学PDE章节

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0809 (PDE FDM求解器) |
| 组合 | PARADIGM-0706 (元胞自动机, 离散模拟) |
| 组合 | PARADIGM-0813 (对流扩散) |
