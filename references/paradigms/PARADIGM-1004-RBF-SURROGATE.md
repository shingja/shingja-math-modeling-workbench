# PARADIGM-1004-RBF-SURROGATE RBF代理模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1004-RBF-SURROGATE |
| 类别/子类 | ⑩代理模型 / 参数化代理 |
| 难度 | 中 |
| 适用题型关键词[] | 径向基函数, 代理模型, 插值, 多维非线性, 确定性仿真 |
| confidence | high |
| source | 文献2003_RBF / 题解反推_Surrogate类 |

## 数学形式

**RBF 插值模型**:
$$\hat{y}(\mathbf{x}) = \sum_{i=1}^{n} w_i \phi(\|\mathbf{x} - \mathbf{x}_i\|) + P(\mathbf{x})$$

其中 $\phi(r)$ 为径向基函数, $P(\mathbf{x})$ 为多项式尾项 (常为线性).

**常用 RBF 核**:
- Gaussian: $\phi(r) = \exp(-(r/\varepsilon)^2)$ — 局部, 光滑参数 $\varepsilon$
- Multiquadric (MQ): $\phi(r) = \sqrt{1 + (r/\varepsilon)^2}$ — 全局, 最常用
- Inverse MQ: $\phi(r) = 1/\sqrt{1 + (r/\varepsilon)^2}$ — 局部
- Thin-Plate Spline: $\phi(r) = r^2 \log(r)$ — 无形状参数, 条件正定

**求解**: 插值条件 + 正交性约束
$$\begin{bmatrix} \boldsymbol{\Phi} & \mathbf{P} \\ \mathbf{P}^T & \mathbf{0} \end{bmatrix} \begin{bmatrix} \mathbf{w} \\ \mathbf{c} \end{bmatrix} = \begin{bmatrix} \mathbf{y} \\ \mathbf{0} \end{bmatrix}$$
其中 $\Phi_{ij} = \phi(\|\mathbf{x}_i - \mathbf{x}_j\|)$, $P_{ik} = p_k(\mathbf{x}_i)$

| 变量 | 含义 |
|------|------|
| $\phi(r)$ | 径向基函数 |
| $\varepsilon$ | 形状参数 (影响基函数宽度) |
| $n$ | 训练样本数 |
| $P(\mathbf{x})$ | 多项式尾项 (确保适定性) |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| RBF 类型 | enum | 'multiquadric' | gaussian/mq/imq/tps/cubic | 高—决定全局/局部特性 |
| 形状参数 $\varepsilon$ | float | $[1, 2]$ | 0.1-10 | 极高—决定光滑度和条件数 |
| 多项式阶数 | int | 1 (线性) | 0/1/2 | 中—补充低阶趋势 |
| $\varepsilon$ 自适应 | bool | true | — | 高—LOOCV 优化 $\varepsilon$ |

**时间复杂度**: $O(n^3)$ (求解线性系统)
**空间复杂度**: $O(n^2)$

**优势**: 相比 GPR 无需核函数梯度和超参数优化; 相比 RSM 基于距离而非多项式, 高维更鲁棒

## MATLAB 实现

```matlab
% 自写 RBF 代理模型
% 自写-见S5:rbf_surrogate.m

% 实现步骤:
% 1. 选择 RBF 类型 (gaussian/mq/imq/tps/cubic)
% 2. 计算距离矩阵, 填充 Φ_ij = phi(||x_i - x_j||)
% 3. 构建多项式矩阵 P (线性尾项: [1, x1, x2, ...])
% 4. 解扩展线性系统: A*w_ext = [y; 0]
% 5. 预测: phi_test = phi(||x_new - x_i||) → y_hat = sum(w_i * phi_i) + P(x_new)*c
% 6. (可选) LOOCV 优化 ε
```

**锚点工具箱**: 无内置 RBF 代理; 需自写
**相关**: `fitrgp` (可近似但本质是 GPR), `scatteredInterpolant` (内置插值但不适合做代理模型的参数控制)

## Python 备选

```python
import numpy as np
from scipy.spatial.distance import cdist
from scipy.linalg import solve

class RBF:
    def __init__(self, kernel='multiquadric', eps=1.0):
        self.kernel = kernel
        self.eps = eps
    
    def _phi(self, r):
        if self.kernel == 'gaussian':
            return np.exp(-(r / self.eps)**2)
        elif self.kernel == 'multiquadric':
            return np.sqrt(1 + (r / self.eps)**2)
        # ... 更多核
    
    def fit(self, X, y):
        self.X = X
        D = cdist(X, X)
        Phi = self._phi(D)
        P = np.column_stack([np.ones(len(X)), X])  # 线性尾项
        # 组装和求解扩展系统
        A = np.block([[Phi, P], [P.T, np.zeros((P.shape[1],)*2)]])
        w_ext = solve(A, np.r_[y, np.zeros(P.shape[1])])
        self.w = w_ext[:len(X)]
        self.c = w_ext[len(X):]
    
    def predict(self, X_new):
        D_new = cdist(X_new, self.X)
        Phi_new = self._phi(D_new)
        P_new = np.column_stack([np.ones(len(X_new)), X_new])
        return Phi_new @ self.w + P_new @ self.c
```

备选: `SMT` (Surrogate Modeling Toolbox, 含 RBF+Kriging), `pyKriging`

## 选型决策树

- **中等维度 ($d \leq 15$) + 确定性仿真** → RBF (MQ) 代理 (精确插值, 无跨距噪声)
- **$d > 15$** → MQ 核在此维度性能下降但优于 RSM; 考虑 GPR (PARADIGM-1001) 或降维
- **含噪声观测** → 不用 RBF (插值会过拟合噪声) → 换 GPR (噪声建模) 或正则化 RBF
- **$n > 2000$** → $O(n^3)$ 线性系统求解困难 → 紧支撑 RBF 或 分区 RBF
- **需要不确定性量化** → GPR (PARADIGM-1001) > RBF (RBF 不提供预测方差)

## 典型图型

- **raw**: 训练点距离直方图 (辅助选 $\varepsilon$)
- **process**: RBF 基函数形状图 (各基函数的中心=训练点, 权重=柱高)
- **result**: 预测 vs 实际散点图, 残差面 (2D)

## 常见坑

1. **形状参数 $\varepsilon$ 决定一切**: $\varepsilon$ 太小→条件数大, 数值不稳定; $\varepsilon$ 太大→太平滑, 欠拟合。用 LOOCV 或 Rippa 方法自适应选择
2. **MQ 在 $n > 500$ 时密集矩阵病态**: 条件数与 $\varepsilon$ 和最小点间距相关 → 用紧支撑 RBF (Wendland 函数)
3. **高斯核在 $\varepsilon$ 较大时退化为常数**: 远距离点贡献 $\phi \approx 0$, 解消失 → 取 $\varepsilon \approx$ 平均点间距
4. **RBF 插值通过所有训练点**: 若数据含噪声会造成严重过拟合 → 添加正则化 ($\lambda I$), 平滑预测

## 失效条件/反例 (强制小节)

- **条件1**: 训练数据含显著观测噪声 (信噪比 < 10) → RBF 精确插值通过所有含噪声点, 预测面剧烈波动, 过拟合不可接受。**替代**: GPR (PARADIGM-1001, 含噪声模型) 或正则化 RBF (ridge-augmented)
- **条件2**: $n > 2000$ (大样本) → $O(n^3)$ 矩阵求逆不可行; 紧支撑 RBF 可扩展到 ~10^4 但需精心调参数。**替代**: 分区/局部 RBF 或 GPR 稀疏近似 (SVGP)
- **条件3**: 输入空间包含离散/类别变量 → RBF 基于欧氏距离, 对类别变量无意义。**替代**: 树模型(随机森林) 代理, 或用 GPR + 自定义核
- **条件4**: 目标函数含多个不同尺度特征 (局部精细+全局趋势) → 固定 $\varepsilon$ 无法同时捕获不同尺度; 单 $\varepsilon$ 的 RBF 拟合不足。**替代**: 多尺度 RBF (变形状参数) 或 GPR ARD 核

## 文献

1. Buhmann, M. D. (2003). *Radial Basis Functions: Theory and Implementations*. Cambridge University Press. ISBN: 978-0-521-63338-2.
2. Forrester, A. I. J., Sobester, A., & Keane, A. J. (2008). *Engineering Design via Surrogate Modelling: A Practical Guide*. Wiley. ISBN: 978-0-470-06068-1.

## 来源溯源

- 论文三元组: Hardy 1971 (MQ introduction), RBF surrogate, multiquadric interpolation
- 开源仓库: [SMT](https://github.com/SMTorg/smt) (Surrogate Modeling Toolbox)

## 关联范式卡

组合: PARADIGM-1002-EGO (RBF + 直接搜索用于优化)
替代: PARADIGM-1001-GPR (含不确定性), PARADIGM-1003-RSM (低维多项式)
