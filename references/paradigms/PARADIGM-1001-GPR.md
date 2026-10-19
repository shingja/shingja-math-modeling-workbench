# PARADIGM-1001-GPR Kriging/高斯过程回归⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1001-GPR |
| 类别/子类 | ⑩代理模型 / 统计代理 |
| 难度 | 高 |
| 适用题型关键词[] | 代理模型, 黑箱优化, 空间插值, 不确定性量化, 昂贵仿真 |
| confidence | high |
| source | 教材第10章 / 论文2006_GPR / 题解反推_Surrogate类 |

## 数学形式

**高斯过程回归 (Kriging)**:
$$y(\mathbf{x}) = \mu + Z(\mathbf{x})$$
其中 $\mu$ 为趋势项, $Z(\mathbf{x}) \sim \mathcal{GP}(0, k(\mathbf{x}, \mathbf{x}'))$

**核函数 (协方差函数)**:
- Squared Exponential (RBF): $k(r) = \sigma^2 \exp(-r^2 / 2\ell^2)$
- Matern 5/2: $k(r) = \sigma^2 (1 + \sqrt{5}r/\ell + 5r^2/3\ell^2) \exp(-\sqrt{5}r/\ell)$
- Matern 3/2: $k(r) = \sigma^2 (1 + \sqrt{3}r/\ell) \exp(-\sqrt{3}r/\ell)$

**预测**:
$$f_* | \mathbf{X}, \mathbf{y}, \mathbf{x}_* \sim \mathcal{N}(\bar{f}_*, \mathbb{V}[f_*])$$
$$\bar{f}_* = \mathbf{k}_*^T (\mathbf{K} + \sigma_n^2 \mathbf{I})^{-1} \mathbf{y}$$
$$\mathbb{V}[f_*] = k(\mathbf{x}_*, \mathbf{x}_*) - \mathbf{k}_*^T (\mathbf{K} + \sigma_n^2 \mathbf{I})^{-1} \mathbf{k}_*$$

| 变量 | 含义 |
|------|------|
| $\mu$ | 均值函数 (常数/线性/二次) |
| $\ell$ | 长度尺度 (相关性衰减速度) |
| $\sigma^2$ | 信号方差 |
| $\sigma_n^2$ | 观测噪声方差 |
| $\mathbf{K}$ | $n \times n$ 协方差矩阵 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 核函数 | enum | 'squaredexponential' | SE/Matern32/Matern52/ARD | 高—决定光滑性假设 |
| 基函数 | enum | 'constant' | constant/linear/pureQuadratic | 中—趋势建模 |
| $\sigma_0$ (初始噪声) | float | 1.0 | 0.01-100 | 中 |
| 超参数优化 | bool | true | — | 高—自动学习 $\ell$, $\sigma$ |

**时间复杂度**: $O(n^3)$ (训练, $\mathbf{K}^{-1}$); $O(n)$ (预测)
**空间复杂度**: $O(n^2)$ (协方差矩阵)

**可扩展性**: $n > 5000$ 训练困难 → 稀疏GP/SVGP/VFE 近似

## MATLAB 实现

```matlab
% 内置 GPR 模型 (Statistics and Machine Learning Toolbox)
gprMdl = fitrgp(X, y, ...
    'KernelFunction', 'squaredexponential', ...
    'BasisFunction', 'constant', ...
    'FitMethod', 'exact', ...
    'PredictMethod', 'exact');
[y_pred, y_sd] = predict(gprMdl, X_test);
```

**锚点工具箱**: `fitrgp` (Statistics and Machine Learning Toolbox)
**备选**: 自写 Cholesky 分解 + 核矩阵 (不推荐, `fitrgp` 已内置)

## Python 备选

```python
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, Matern, ConstantKernel

kernel = ConstantKernel(1.0) * RBF(length_scale=1.0)
gp = GaussianProcessRegressor(kernel=kernel, n_restarts_optimizer=10)
gp.fit(X, y)
y_pred, y_std = gp.predict(X_test, return_std=True)
```

备选: `GPy`, `GPflow` (大规模, 含稀疏GP)

## 选型决策树

- **中小规模样本 ($n < 1000$) + 需要不确定性估计** → GPR (天然提供预测方差)
- **$n > 5000$ + 需要预测更快** → RBF代理 (PARADIGM-1004) 或 多项式响应面 (PARADIGM-1003)
- **需要序贯优化 (自适应采样)** → EGO/BayesOpt (PARADIGM-1002), GPR是其核心
- **仅需插值 (无噪声)** → Kriging ($\sigma_n^2 \rightarrow 0$) 精确通过训练点
- **需要纯预测 + 不需要不确定性** → 随机森林/GBRT 可能更简单且速度更快

## 典型图型

- **raw**: 训练点散点图 (标记位置)
- **process**: 均值预测 + 95% 置信带 (1D/2D), 不确定性热力图 (2D)
- **result**: 预测 vs 实际散点图 (测试集), 残差 vs 预测值

## 常见坑

1. **$n > 1000$ 时逆矩阵耗时**: $O(n^3)$ → 用 `FitMethod='sd'` (稀疏) 或 `'fic'` (全独立条件近似)
2. **核函数选择主导结果**: SE 过于光滑可能欠拟合突变 → 用 Matern 5/2 (2次可微, C2 连续)
3. **各维度长度尺度差异大**: 单 $\ell$ 忽略方向性 → 用 ARD (自动相关性确定) 核
4. **外推极差**: GPR 在训练域外预测方差暴涨 → 仅用于插值 (训练点凸包内)

## ⚠️ 数值卫生必查

1. **输入尺度比 > 10 必须先 StandardScaler**。实战: 尺度比 40x → 条件数 > 10¹² → Cholesky 失败 → R² = -6.09；标准化 + WhiteKernel → R² = 0.996。尺度差异直接病态化核矩阵 $\mathbf{K}$，先标准化再谈核函数。
2. **"尺度差异大→用ARD核"不能替代标准化**。ARD 长度尺度只能在核矩阵条件数可接受时有效学习；标准化是前提，ARD 只作为标准化后的补充（各维度相关性长度不同时）。
3. **预测 σ (`return_std`) 是认知不确定度，不等于制造/输入扰动 σ**。实战实测低估约 8x。公差分析必须用输入扰动 Monte Carlo（对输入加制造公差采样 → 传播到输出 σ），不得直接引用 `return_std` 当公差。
4. **R² < 0 时按负 R² 诊断清单排查实现缺陷**（标准化缺失、核矩阵病态、噪声项缺失、超参数不收敛等），清单见 `references/lessons/避坑手册_Tide.md`，不得直接判定"算法不可用"。

## 失效条件/反例 (强制小节)

- **条件1**: 训练样本 $n > 5000$ → $O(n^3)$ 逆矩阵不可行, 且协方差矩阵条件数变差, 数值不稳定。**替代**: 稀疏 GP (VFE/DTC/SVGP), 或用 RBF 代理 (PARADIGM-1004) + 局部拟合
- **条件2**: 输入维数 $d > 20$ → 核函数在高维空间中"所有点距离相等", 协方差矩阵全为噪声, GPR 退化。**替代**: 先降维 (PCA) 至 $d < 10$, 或用多项式响应面 (PARADIGM-1003) + 逐步回归
- **条件3**: 目标函数不连续 (阶跃/分段) → 核函数假设平滑性不成立, 预测振荡严重 (Gibbs现象)。**替代**: 树模型代理 (随机森林), 或用 Change-point GPR
- **条件4**: 外推需求 > 插值需求 → GPR 超出训练域预测方差迅速发散, 信噪比趋于0。**替代**: 多项式响应面在外推时更可预测, 或直接加边界样本

## 文献

1. Rasmussen, C. E., & Williams, C. K. I. (2006). *Gaussian Processes for Machine Learning*. MIT Press. ISBN: 978-0-262-18253-9. Available at: http://www.gaussianprocess.org/gpml/
2. Sacks, J., Welch, W. J., Mitchell, T. J., & Wynn, H. P. (1989). Design and analysis of computer experiments. *Statistical Science*, 4(4), 409-423. DOI: [10.1214/ss/1177012413](https://doi.org/10.1214/ss/1177012413)

## 来源溯源

- 教材源路径: 代理模型方法与应用
- 论文三元组: Rasmussen 2006, GPML, kernel methods + Bayesian nonparametrics
- 开源仓库: [GPy](https://github.com/SheffieldML/GPy), [GPflow](https://github.com/GPflow/GPflow)

## 关联范式卡

组合: PARADIGM-1002-EGO (GPR + EI 序贯优化), PARADIGM-1005-PINN (物理约束GP)
替代: PARADIGM-1004-RBF-SURROGATE (大规模), PARADIGM-1003-RSM (低维多项式)
