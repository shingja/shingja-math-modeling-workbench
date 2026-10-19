# PARADIGM-0812 二维热传导FDM⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0812 |
| 类别/子类 | ⑧机理建模与PDE / 热传导 |
| 难度 | 中 |
| 适用题型关键词[] | 二维热传导, FDM, 有限差分, 热方程, 稳态/瞬态, Dirichlet/Neumann, 散热片 |
| confidence | high |
| source | Carslaw & Jaeger (1959) Oxford |

## 数学形式

**二维瞬态热传导方程:**
$$\frac{\partial T}{\partial t} = \alpha \left(\frac{\partial^2 T}{\partial x^2} + \frac{\partial^2 T}{\partial y^2}\right) + S(x,y,t)$$

其中 $\alpha = k/(\rho c_p)$ 为热扩散率，$S$ 为热源项。

**稳态 (Laplace/Poisson 方程):**
$$\frac{\partial^2 T}{\partial x^2} + \frac{\partial^2 T}{\partial y^2} = -\frac{S}{k}$$

**FDM 离散 (5点中心差分):**
$$\frac{T_{i,j}^{n+1} - T_{i,j}^n}{\Delta t} = \alpha \left[\frac{T_{i+1,j}^n - 2T_{i,j}^n + T_{i-1,j}^n}{\Delta x^2} + \frac{T_{i,j+1}^n - 2T_{i,j}^n + T_{i,j-1}^n}{\Delta y^2}\right]$$

**CFL 稳定性 (显式):**
$$\Delta t \leq \frac{1}{2\alpha} \left(\frac{1}{\Delta x^2} + \frac{1}{\Delta y^2}\right)^{-1}$$

(隐式格式无条件稳定但需解线性方程组)

**边界条件:**
- **Dirichlet:** $T_{\text{boundary}} = T_0$ (固定温度)
- **Neumann:** $\partial T/\partial n = q$ (固定热流)
- **Robin:** $\partial T/\partial n + h(T-T_\infty) = 0$ (对流换热)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| alpha (热扩散率) | double | 1.0 | (0, ∞) | 极高 — 决定时间尺度 |
| Nx, Ny | int | 50 | [20, 500] | 高 — 空间分辨率 |
| dt | double | CFL | (0, CFL_max] | 极高 — 超过CFL爆炸 |
| 热源 S | 函数 | 0 | — | 高 |
| 复杂度 | — | — | O(Nt·Nx·Ny) | — |

## MATLAB 实现

```matlab
% 2D 热传导 FDM (自写)
function T = heat2d_fdm(Nx, Ny, T_end, alpha, S_fn, bc, T0)
    dx = 1/(Nx-1); dy = 1/(Ny-1);
    dt = 0.4 * min(dx^2, dy^2) / (2*alpha);  % CFL
    Nt = ceil(T_end / dt);
    
    T = T0 * ones(Ny, Nx);  % 初始
    T_new = T;
    
    for n = 1:Nt
        for i = 2:Nx-1
            for j = 2:Ny-1
                d2Tdx2 = (T(j,i+1) - 2*T(j,i) + T(j,i-1)) / dx^2;
                d2Tdy2 = (T(j+1,i) - 2*T(j,i) + T(j-1,i)) / dy^2;
                T_new(j,i) = T(j,i) + dt * (alpha*(d2Tdx2 + d2Tdy2) + S_fn(i,j));
            end
        end
        % 施加边界条件
        T_new = apply_bc(T_new, bc);
        T = T_new;
    end
end
% 更快的向量化版本:
function T = heat2d_fdm_vectorized(Nx, Ny, T_end, alpha, S, bc, T0)
    % 使用矩阵运算 (meshgrid + 卷积) 加速内部节点
end
```

锚点: 自写-见S5:heat2d_fdm.m

## Python 备选

```python
import numpy as np
def heat2d_fdm(Nx, Ny, T_end, alpha, S_fn, bc, T0):
    dx = dy = 1/(Nx-1)
    dt = 0.4 * min(dx**2, dy**2) / (2*alpha)
    T = np.full((Ny, Nx), T0, dtype=float)
    for _ in range(int(T_end/dt)):
        T[1:-1,1:-1] += dt * (
            alpha * ((np.roll(T,1,1)+np.roll(T,-1,1)-2*T)/dx**2 +
                     (np.roll(T,1,0)+np.roll(T,-1,0)-2*T)/dy**2)[1:-1,1:-1]
            + S_fn)
    return T
```

## 选型决策树

- **2D 热传导** — 固体散热/导热、建筑热分析、芯片温度
- **1D 热传导** — 简化场景 → 更快
- **稳态求解** — 不关心瞬态过程时直接用 Poisson 方程 (更高效)
- **FEM (有限元)** — 复杂几何 (非矩形) 时 FDM 受限于规则网格

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | 温度等值面动画 (surf/contourf 逐帧) | 热扩散过程 |
| result | 稳态温度分布 (surf) | 最终温度场 |
| result | 中心点温度 time-history 曲线 | 验证稳态 |

## 常见坑

1. **CFL 爆炸**: 显式 Euler 时间步长超限 → 必须检查并设安全因子 (0.4)
2. **Neumann BC 精度**: 一阶近似误差 O(Δx) 污染全局精度 → 使用虚拟节点 (Ghost Node) 实现二阶
3. **各向异性**: $\alpha_x \neq \alpha_y$ (如纤维方向) → 单独处理 x,y 方向扩散项

## 失效条件/反例 (强制小节)

- **条件1: 包含相变 (熔化/凝固) — Stefan 问题** → 表现: 相变界面上的潜热释放/吸收使热方程在界面处不可微，标准 FDM 在移动界面上发散 (Gibbs 现象)。**应对**: 使用焓法 (Enthalpy Method) 或 Front-tracking 方法在移动边界上特殊处理
- **条件2: 极不规则几何 (如散热器鳍片)** → 表现: 矩形 FDM 网格无法精确表示曲面边界 → 边界采用阶梯近似产生 O(1) 误差，热流计算严重偏差。**应对**: 使用有限元 (FEM) 或浸入边界法 (IBM)，MATLAB PDE Toolbox 支持三角网格

## 文献

1. Carslaw H.S. & Jaeger J.C. (1959). *Conduction of Heat in Solids*, 2nd ed. Oxford University Press. ISBN: 978-0198533689
2. LeVeque R.J. (2007). *Finite Difference Methods for Ordinary and Partial Differential Equations*. SIAM. ISBN: 978-0898716290

## 来源溯源

自写 heat2d_fdm.m; 传热学/数值传热教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0809 (PDE FDM求解器) |
| 组合 | PARADIGM-0813 (对流扩散) |
