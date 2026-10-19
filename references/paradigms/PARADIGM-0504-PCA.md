# PARADIGM-0504 主成分分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0504 |
| 类别/子类 | ⑤统计与数据分析 / 降维 |
| 难度 | 低 |
| 适用题型关键词[] | 主成分分析, PCA, 降维, 特征值, 方差解释, 载荷矩阵, 得分, 数据压缩 |
| confidence | high |
| source | matlab/decomp/pca_decomp.m |

## 数学形式

设有数据矩阵 $X \in \mathbb{R}^{n \times p}$（$n$ 个样本，$p$ 个特征），中心化后 $\tilde{X} = X - \mathbf{1}_n \bar{x}^T$。

**协方差矩阵**：
$$\Sigma = \frac{1}{n} \tilde{X}^T \tilde{X}$$

**特征分解**：
$$\Sigma = V \Lambda V^T, \quad \lambda_1 \geq \lambda_2 \geq \cdots \geq \lambda_p \geq 0$$

**主成分得分**（取前 $k$ 个主成分）：
$$Z = \tilde{X} V_k, \quad V_k \in \mathbb{R}^{p \times k}$$

**方差解释率**：
$$\text{PVE}_i = \frac{\lambda_i}{\sum_{j=1}^p \lambda_j}, \quad \text{CPVE}_k = \frac{\sum_{i=1}^k \lambda_i}{\sum_{j=1}^p \lambda_j}$$

**载荷 (loadings)**：
$$\ell_{ij} = \text{corr}(x_i, z_j) = \frac{v_{ij} \sqrt{\lambda_j}}{s_i}$$

其中 $s_i$ 为变量 $x_i$ 的标准差。

**变量表**：
| 符号 | 含义 | 维度 |
|------|------|------|
| $X$ | 原始数据矩阵 | $n \times p$ |
| $\tilde{X}$ | 中心化数据矩阵 | $n \times p$ |
| $\Sigma$ | 协方差矩阵 | $p \times p$ |
| $V$ | 特征向量矩阵 | $p \times p$ |
| $\Lambda$ | 特征值对角阵 | $p \times p$ |
| $Z$ | 主成分得分矩阵 | $n \times k$ |
| $\lambda_i$ | 第 $i$ 个特征值（方差） | 标量 |

**成分数选择准则**：
- Kaiser 准则：保留 $\lambda_i > 1$ 的成分（针对相关矩阵 PCA）
- 累积方差：$\text{CPVE}_k > 80\%$ 或 $85\%$
- 碎石图 (scree plot) 肘部拐点

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| `X` | double matrix | — | $n \times p$, 连续变量 | 高（须标准化） |
| `NumComponents` (`k`) | int | 全部 $p$ | $1 \leq k \leq \min(n, p)$ | 高（决定信息保留率） |
| `Centered` | bool | `true` | — | 低 |
| `'VariableWeights'` | vector | `1/p` (等权) | $w_i \geq 0$ | 中 |

**时间复杂度**：$O(\min(n^2 p, n p^2))$（SVD），$O(p^3)$（协方差+特征分解，当 $n \gg p$）
**空间复杂度**：$O(np) + O(p^2)$

## MATLAB 实现

函数签名：
```matlab
[coeff, score, latent, tsquared, explained] = pca_decomp(X, 'NumComponents', k, 'Centered', true)
```

锚点工具箱函数：`pca` (Statistics and Machine Learning Toolbox)

实现位置：`matlab/decomp/pca_decomp.m`

```matlab
function [coeff, score, latent, tsquared, explained] = pca_decomp(X, varargin)
    % PCA wrapper with standardization and diagnostics
    % X: n×p data matrix
    % Returns: coeff (loadings), score (PC scores), latent (eigenvalues),
    %          tsquared (Hotelling's T²), explained (% variance per PC)
    
    p = inputParser;
    addParameter(p, 'NumComponents', size(X,2));
    addParameter(p, 'Centered', true);
    parse(p, varargin{:});
    
    % Standardize (z-score) — critical step
    X_std = zscore(X);
    
    [coeff, score, latent, tsquared, explained, mu] = ...
        pca(X_std, 'NumComponents', p.Results.NumComponents, ...
                  'Centered', p.Results.Centered);
end
```

## Python 备选

```python
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import numpy as np

# Standardize
X_std = StandardScaler().fit_transform(X)

# PCA
pca = PCA(n_components=k)
scores = pca.fit_transform(X_std)      # PC scores
loadings = pca.components_.T            # eigenvectors
eigenvalues = pca.explained_variance_   # eigenvalues
explained = pca.explained_variance_ratio_ * 100

# Scree plot data
cumsum_var = np.cumsum(explained)
```

自定义实现（协方差+特征分解路径）：
```python
X_c = X - X.mean(axis=0)
cov_mat = X_c.T @ X_c / (X_c.shape[0] - 1)
eigenvalues, eigenvectors = np.linalg.eigh(cov_mat)
idx = np.argsort(eigenvalues)[::-1]
eigenvalues = eigenvalues[idx]
eigenvectors = eigenvectors[:, idx]
scores = X_c @ eigenvectors
```

## 选型决策树

```
特征是否连续且近似线性？
├── 是 → 目标是什么？
│   ├── 降维 + 保留最大方差 → PCA ✓
│   ├── 可视化 (2D/3D) → PCA (k=2 or 3)
│   ├── 去噪/压缩 → PCA (保留 95% 方差)
│   └── 可解释潜因子 → 因子分析 (PARADIGM-0511)
├── 否 (非线性流形) → kernel PCA / t-SNE / UMAP
└── 分类特征混合 → MCA (多重对应分析) / FAMD
```

**替代算法对比**：
| 算法 | 适用场景 | 与 PCA 区别 |
|------|----------|------------|
| t-SNE | 高维可视化 | 保留局部邻域，不保留全局结构 |
| Kernel PCA | 非线性降维 | 通过核技巧处理非线性关系 |
| Factor Analysis | 潜变量建模 | 含测量误差模型，可旋转 |
| Autoencoder | 深度学习场景 | 非线性、可堆叠 |
| Truncated SVD | 稀疏矩阵 | 不中心化，适用于文本/TF-IDF |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 相关系数矩阵热图 (corrheatmap) | 展示原始变量间共线性程度 |
| raw | 平行坐标图 (parallelcoords) | 标准化后变量分布概览 |
| process | 碎石图 (scree plot) | 方差解释率 vs 成分数，标注 Kaiser 线 ($\lambda = 1$) 和肘部 |
| process | 双标图 (biplot, PC1 vs PC2) | 得分散点 + 载荷向量箭头，展示变量贡献方向 |
| result | 累积方差解释率柱状图 | 标注 80% / 95% 阈值线 |
| result | 前 $k$ 个 PC 得分散点矩阵 | 检查聚类/异常点模式 |

## 常见坑

1. **未标准化数据**：高方差特征（如薪资，量级 $10^4$）主导第一主成分，低方差特征（如年龄，量级 $10^1$）被淹没 — 始终先 `zscore` 或使用相关矩阵 PCA
2. **异常值拉偏协方差**：单个极端值可显著改变特征向量方向 → 先检查 Mahalanobis 距离，或使用 Robust PCA
3. **过度解释成分**：载荷是线性组合权重，未必对应物理含义；载荷阈值 $\pm 0.4$ 为常用显著性参考，但并非统计检验
4. **$n \ll p$ 场景**（如基因表达 $n=50, p=10000$）：协方差矩阵估计极不稳定，特征值膨胀 → 考虑稀疏 PCA 或正则化协方差估计
5. **成分数选择主观**：Kaiser 准则 ($\lambda>1$) 基于相关矩阵 PCA；累积方差 80% 是经验阈值，不同领域有不同惯例
6. **PCA 对离散化敏感**：将连续变量分箱后再 PCA 会损失信息并引入伪结构

## 失效条件/反例 (强制小节)

- **条件1：强非线性流形结构**（如 Swiss roll、同心环）→ **表现**：PCA 保留全局方差最大方向但破坏局部邻域结构，Swiss roll 被压扁为二维平面，类间边界模糊；线性投影将原本可分的流形结构混合 → 使用 t-SNE、UMAP 或 kernel PCA
- **条件2：混合类型变量（连续+分类）** → **表现**：对分类变量做 one-hot 编码后 PCA，哑变量间的距离无实际意义，方差解释率被人为分散到多个哑变量上，得分图出现虚假边界 → 使用多重对应分析 (MCA) 或混合数据因子分析 (FAMD)
- **条件3：方差与信号不相关** → **表现**：当噪声方差远大于信号方差时（如低信噪比图像），PCA 保留噪声成分而非信号成分 → 需先用信号处理去噪，或使用 supervised PCA

## 文献

1. Jolliffe I.T. (2002) *Principal Component Analysis*, 2nd Edition. Springer Series in Statistics. ISBN 978-0387954424.
2. Pearson K. (1901) "On lines and planes of closest fit to systems of points in space", *Philosophical Magazine*, 2(11): 559–572. DOI: [10.1080/14786440109462720](https://doi.org/10.1080/14786440109462720)
3. Hotelling H. (1933) "Analysis of a complex of statistical variables into principal components", *Journal of Educational Psychology*, 24(6): 417–441. DOI: [10.1037/h0071325](https://doi.org/10.1037/h0071325)

## 来源溯源

matlab/decomp/pca_decomp.m

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 替代 | PARADIGM-0511 | 因子分析 — 当需要可解释潜因子（含测量误差）时优于 PCA |
| 前置 | — | PCA 常用于聚类 (PARADIGM-0506) 或分类前的特征降维预处理 |
| 组合 | PARADIGM-0506 | PCA 降维后做 K-Means 聚类，缓解高维诅咒 |
| 组合 | PARADIGM-0501 | PCA 去共线性后做主成分回归 (PCR) |
