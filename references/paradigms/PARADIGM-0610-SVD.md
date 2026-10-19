# PARADIGM-0610 SVD奇异值分解⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0610 |
| 类别/子类 | ⑥机器学习 / 矩阵分解 |
| 难度 | 中 |
| 适用题型关键词[] | SVD, 奇异值分解, 矩阵分解, 降维, 信息压缩, svd, 协同过滤, 伪逆 |
| confidence | high |
| source | Golub & Van Loan (2013) Johns Hopkins |

## 数学形式

**全 SVD:**
$$\mathbf{A}_{m\times n} = \mathbf{U}_{m\times m} \mathbf{\Sigma}_{m\times n} \mathbf{V}^T_{n\times n}$$

其中 $\mathbf{U}^T\mathbf{U} = \mathbf{I}_m$, $\mathbf{V}^T\mathbf{V} = \mathbf{I}_n$, $\mathbf{\Sigma} = \text{diag}(\sigma_1, \sigma_2, \ldots, \sigma_r, 0, \ldots, 0)$ 且 $\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0$。

**截断 SVD (k-秩近似, Eckart-Young 定理):**
$$\mathbf{A}_k = \mathbf{U}_k \mathbf{\Sigma}_k \mathbf{V}_k^T = \arg\min_{\text{rank}(\mathbf{B})\leq k} \|\mathbf{A} - \mathbf{B}\|_F^2$$

**信息保留比例:**
$$\frac{\sum_{i=1}^{k} \sigma_i^2}{\sum_{i=1}^{r} \sigma_i^2}$$

**Moore-Penrose 伪逆:**
$$\mathbf{A}^+ = \mathbf{V}\mathbf{\Sigma}^+\mathbf{U}^T, \quad \text{其中 } \Sigma_{ii}^+ = \begin{cases} 1/\sigma_i & \sigma_i > \varepsilon \\ 0 & \sigma_i \leq \varepsilon \end{cases}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| economy_flag | bool | true | — | — (控制分解尺寸) |
| k (截断秩) | int | — | [1, min(m,n)] | 高 — 平衡压缩率与精度 |
| tol (奇异值阈值) | double | 1e-12 | — | 中 — 决定数值秩 |
| 时间复杂度 | — | — | O(mn·min(m,n)) | — |

## MATLAB 实现

```matlab
% 全 SVD
[U, S, V] = svd(A);

% 经济 SVD (m>>n 时使用)
[U, S, V] = svd(A, 'econ');

% 奇异值分析
sigma = diag(S);
cum_energy = cumsum(sigma.^2) / sum(sigma.^2);
plot(cum_energy);  % 确定截断秩 k

% 截断 SVD
k = find(cum_energy >= 0.95, 1);  % 保留 95% 能量
A_k = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';

% 伪逆
A_pinv = pinv(A);  % 或 V * pinv(S) * U'
```

锚点: `svd` (MATLAB 内置)

## Python 备选

```python
import numpy as np
from scipy.linalg import svd
U, sigma, Vt = svd(A, full_matrices=False)

# 截断 SVD (sklearn 高效实现)
from sklearn.decomposition import TruncatedSVD
svd = TruncatedSVD(n_components=k, random_state=42)
A_reduced = svd.fit_transform(A)
```

## 选型决策树

- **SVD** — 通用矩阵分解：降维、去噪、伪逆、协同过滤、潜在语义分析
- **PCA (PARADIGM-0504)** — 专用于协方差矩阵的特征分析，本质 = SVD on 中心化数据
- **NMF (PARADIGM-0508)** — 需要非负约束和可解释分量 (如主题建模)
- **QR 分解** — 要解线性方程组而非降维时优先用 QR (更快)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 矩阵可视化 (imagesc) | 展示原始矩阵结构 |
| process | 奇异值下降图 (semilogy) | 拐点 = 数值秩 |
| process | 累积能量曲线 | 确定截断 k |

## 常见坑

1. **大矩阵 O(mn²)**: m,n > 10000 时全 SVD 内存/时间不可接受 → 用截断 SVD 或 Randomized SVD
2. **奇异值阈值截断**: 过小的 tol 保留噪声 → 需结合累积能量曲线选取 k
3. **稀疏矩阵用 svds**: 稀疏矩阵用 `svds(A, k)` 而非 `svd(full(A))`

## 失效条件/反例 (强制小节)

- **条件1: 矩阵极度稀疏且非零元素无结构** → 表现: 奇异值衰减慢 (前 k 个奇异值之和占比较低)，截断 SVD 需要很大 k 才能重构，降维效果差。**应对**: 使用非负矩阵分解 (NMF) 或 Deep Factorization Machines 在稀疏设定下工作
- **条件2: 流式/增量数据 (Streaming Data)** → 表现: 标准 SVD 是批量算法，每条新数据到达即需重算全矩阵 SVD O(mn²)，不可行。**应对**: 使用增量 SVD (如 Brand 算法, MATLAB 中 `incrementalSVD` 或自写) 或随机投影近似更新

## 文献

1. Golub G.H. & Van Loan C.F. (2013). *Matrix Computations*, 4th ed. Johns Hopkins University Press. ISBN: 978-1421407944
2. Eckart C. & Young G. (1936). "The approximation of one matrix by another of lower rank." *Psychometrika*, 1(3):211-218. DOI: [10.1007/BF02288367](https://doi.org/10.1007/BF02288367)

## 来源溯源

MATLAB `svd`; 数值线性代数教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (降维) | PARADIGM-0504 (PCA) |
| 组合 (文本) | PARADIGM-0611 (LSA) |
| 组合 (协同过滤) | PARADIGM-0903 (文本挖掘管道) |
| 替代 (非负分解) | PARADIGM-0508 (NMF) |
