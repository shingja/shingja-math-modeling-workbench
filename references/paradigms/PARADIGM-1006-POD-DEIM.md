# PARADIGM-1006-POD-DEIM POD/DEIM: 降阶模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1006-POD-DEIM |
| 类别/子类 | ⑩代理模型 / 降阶 |
| 难度 | 高 |
| 适用题型关键词[] | 降阶模型, SVD截断, 快照法, 参数化PDE, 实时仿真 |
| confidence | medium |
| source | 文献1987_POD / 题解反推_Rom类 |

## 数学形式

**POD (Proper Orthogonal Decomposition) = 主成分分析在状态空间的应用**:

1. **快照矩阵** $\mathbf{S} \in \mathbb{R}^{N \times n_s}$: $N$ = 状态维数 (FEM 网格点数), $n_s$ = 快照数 (采样参数下的 PDE 解)

2. **SVD 截断**:
   $$\mathbf{S} = \mathbf{U} \boldsymbol{\Sigma} \mathbf{V}^T$$
   保留前 $r$ 个奇异值/向量 ($r \ll N$):
   $$\mathbf{U}_r \in \mathbb{R}^{N \times r}$$

3. **Galerkin 投影**: 原状态 $\mathbf{u}(t) \approx \mathbf{U}_r \mathbf{a}(t)$, 其中 $\mathbf{a} \in \mathbb{R}^r$ 为降阶坐标
   将 $\mathbf{U}_r^T$ 投影到原 ODE/PDE 上, 得到 $r$ 维降阶方程组

4. **DEIM (Discrete Empirical Interpolation)** 处理非线性项:
   $$\mathbf{N}(\mathbf{u}) \approx \mathbf{U}_r^{\text{NL}} (\mathbf{P}^T \mathbf{U}_r^{\text{NL}})^{-1} \mathbf{P}^T \mathbf{N}(\mathbf{u})$$
   仅评估 $\mathbf{N}$ 在选定的 $m$ 个插值点 ($m \ll N$)

| 变量 | 含义 |
|------|------|
| $N$ | 原状态维数 (全阶) |
| $n_s$ | 快照数 (参数采样) |
| $r$ | POD 基数量 (降阶维数, 通常 5-50) |
| $\mathbf{U}_r$ | POD 基 (前 $r$ 左奇异向量) |
| 能量保留比 | $\sum_{i=1}^{r} \sigma_i^2 / \sum_{i=1}^{N} \sigma_i^2$ (典型取 99.9%) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 能量保留比 | float | 0.999 | 0.95-0.9999 | 高—决定 $r$, 平衡精度和加速 |
| POD 模态数 $r$ | int | (由能量比定) | 2-100 | 高—太大无加速, 太小精度差 |
| DEIM 插值点数 $m$ | int | $\approx r$ | $r$ - $2r$ | 中—处理非线性成本 |
| 快照采样分布 | enum | LHS | LHS/均匀/自适应 | 高—采样不足则 POD 基无代表性 |

**在线阶段复杂度**: $O(r^3 + m \cdot \text{eval\_nonlinear})$ vs 全阶 $O(N^3)$
**加速比**: $r/N$ 可达 $10^2$ - $10^4$

## MATLAB 实现

```matlab
% POD-ROM + DEIM 实现
% 自写SVD截断-见S5:pod_rom.m

% 实现步骤:
% 1. 生成参数采样点 (LHS)
% 2. 全阶求解各采样点, 收集快照 → S
% 3. [U, S_svd, ~] = svd(S, 'econ')
% 4. 能量累积: cumsum(diag(S_svd).^2)/sum(diag(S_svd).^2)
% 5. 选择 r: 能量 > 0.999 的最小 r
% 6. U_r = U(:, 1:r)
% 7. Galerkin投影: a_dot = U_r' * f(U_r * a, t) (降阶ODE)
% 8. (可选) DEIM: 对非线性项快照做SVD, 贪心选插值点
% 9. 在线阶段: ode45 求解降阶 ODE, 映射回全阶: u ≈ U_r * a
```

**锚点工具箱**: `svd` (内置), `ode45` (ODE求解器)
**辅助**: `lhsdesign` (快照实验设计)

## Python 备选

```python
import numpy as np
from scipy.linalg import svd
from scipy.integrate import solve_ivp

# POD 基提取
U, s, Vt = svd(S, full_matrices=False)
energy = np.cumsum(s**2) / np.sum(s**2)
r = np.searchsorted(energy, 0.999) + 1
Ur = U[:, :r]

# Galerkin ROM
def reduced_dynamics(t, a):
    u = Ur @ a
    du_full = f_full(t, u)  # 全阶右端
    return Ur.T @ du_full

# 在线求解
a0 = Ur.T @ u0
sol = solve_ivp(reduced_dynamics, [0, T], a0, method='RK45')
u_rom = Ur @ sol.y  # 重构
```

备选: `PyMOR` (降阶模型专用库, 含 POD/DEIM/系统理论方法)

## 选型决策树

- **参数化 PDE + 需反复求解 (多次 query)** → POD-ROM (一次离线, 多次在线)
- **仅需一次求解** → POD 离线开销不值得, 直接全阶求解
- **线性问题 ($f(\mathbf{u}) = A\mathbf{u}$)** → POD 在线可直接对角化, 极快
- **强非线性 ($f(\mathbf{u})$ 含 $u^2$, $\sin(u)$ 等)** → 需 DEIM 超降阶, 否则在线仍评估全阶非线性
- **非参数化 (单一配置)** → POD 可用但无意义 (一次求解不需要 ROM)
- **与 PINN 结合** → POD 提供降阶基, PINN 学习降阶坐标动态 (非侵入式 ROM)

## 典型图型

- **raw**: 奇异值衰减曲线 (log scale), 累积能量曲线
- **process**: POD 模态可视化 (前 $r$ 个模态的空间分布, 2D contour)
- **result**: ROM vs FOM 对比 (某时刻状态剖面), 时间演化误差曲线, 计算时间对比表

## 常见坑

1. **快照采样不足—POD 基无代表性**: 参数空间某区域未采样 → ROM 在该区域失效。用贪心/自适应采样确保全覆盖
2. **$r$ 选太少**: 99.9% 能量看似足够, 对于含长尾的系统 (湍流) 可能需 $r$ 远大于此 → 验证: ROM 与 FOM 的相对误差
3. **DEIM 插值点选择不当**: 贪心算法选点对噪声敏感 → 检查插值矩阵条件数
4. **离线成本高**: 快照需要 $n_s$ 次全阶求解, 若 $n_s$ 过大 ROM 失去意义 → set $n_s$ proportional to $r$

## 失效条件/反例 (强制小节)

- **条件1**: 参数空间高维 ($d > 5$) → 快照覆盖整个参数空间需要维数灾难般的采样量; POD 基泛化能力在未采样区域崩溃。**替代**: 局部 POD (参数空间分区), 或改用非侵入式方法 (如 RBF 插值 POD 系数)
- **条件2**: 快照集合的低秩性不满足 (奇异值衰减慢) → 无显著降阶效果, 需 $r$ 接近 $N$ 才能保持精度, ROM 名存实亡。**替代**: 换表征方法 (autoencoder 降阶, 可捕获非线性流形) 或接受全阶
- **条件3**: 强非线性 + 非线性项占主导 → DEIM 即使降低了非线性评估成本, 但 $m$ (插值点数) 常需远大于 $r$, 加速比有限。且 Galerkin 投影原本就需假设线性/弱非线性。**替代**: 非侵入式 ROM (NiROM, 用 RBF/NN 直接学习 POD 系数与参数映射)
- **条件4**: 仅需单次 PDE 求解 → POD 离线 (快照生成 + SVD) 的成本 > 直接求解, 建设 ROM 无意义。**替代**: 直接全阶求解

## 文献

1. Sirovich, L. (1987). Turbulence and the dynamics of coherent structures. I-III. *Quarterly of Applied Mathematics*, 45(3), 561-590. DOI: [10.1090/qam/910462](https://doi.org/10.1090/qam/910462)
2. Chaturantabut, S., & Sorensen, D. C. (2010). Nonlinear model reduction via discrete empirical interpolation. *SIAM Journal on Scientific Computing*, 32(5), 2737-2764. DOI: [10.1137/090766498](https://doi.org/10.1137/090766498)

## 来源溯源

- 论文三元组: Sirovich 1987, POD snapshot method + Lumley 1967 turbulence; Chaturantabut 2010, DEIM
- 开源仓库: [PyMOR](https://github.com/pymor/pymor)

## 关联范式卡

组合: PARADIGM-1005-PINN (非侵入式 ROM: PINN 学习降阶动态)
替代: 全阶求解 (单次), Autoencoder ROM (非线性流形)
前置: SVD/PCA (PARADIGM-0508-PCA), ODE/PDE (PARADIGM-0701-ODE)
