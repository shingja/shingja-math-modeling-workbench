# PARADIGM-0508 非负矩阵分解NMF⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0508 |
| 类别/子类 | ⑤统计 / 矩阵分解 |
| 难度 | 中 |
| 适用题型关键词[] | NMF, 非负矩阵分解, 主题分解, 盲源分离, 图像分解, nnmf, 部分表示 |
| confidence | high |
| source | Lee & Seung (1999) Nature |

## 数学形式

**NMF 分解 (秩 k):**
$$\mathbf{V}_{m\times n} \approx \mathbf{W}_{m\times k} \mathbf{H}_{k\times n}$$

其中 $\mathbf{V}, \mathbf{W}, \mathbf{H} \geq 0$ (所有元素非负)。

**优化目标 (Frobenius 范数):**
$$\min_{\mathbf{W}, \mathbf{H} \geq 0} \|\mathbf{V} - \mathbf{W}\mathbf{H}\|_F^2$$

**乘性更新规则 (Multiplicative Update, Lee-Seung):**

$$\mathbf{H} \leftarrow \mathbf{H} \odot \frac{\mathbf{W}^T\mathbf{V}}{\mathbf{W}^T\mathbf{W}\mathbf{H}}$$

$$\mathbf{W} \leftarrow \mathbf{W} \odot \frac{\mathbf{V}\mathbf{H}^T}{\mathbf{W}\mathbf{H}\mathbf{H}^T}$$

其中 $\odot$ 为逐元素乘，分式为逐元素除。

**K-L 散度版本:**
$$\min D_{KL}(\mathbf{V} \| \mathbf{W}\mathbf{H}) = \sum_{i,j} \left(V_{ij}\log\frac{V_{ij}}{(\mathbf{W}\mathbf{H})_{ij}} - V_{ij} + (\mathbf{W}\mathbf{H})_{ij}\right)$$

**非负性 → 部分表示 (Parts-based Representation):**
NMF 倾向于产生稀疏的、基于部分的表示 (不像 PCA/SVD 的全局全息表示)。

**选择秩 k:** 无监督 → 用 Cophenetic correlation (稳定性)，或 RSS elbow。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| k (分解秩) | int | 5 | [2, 50] | 极高 — 决定分解粒度和可解释性 |
| algorithm | str | 'als' | 'als','mult' | 低 |
| n_replicates | int | 5 | [1, 20] | 中 — 防止局部最优 |
| 复杂度 | — | — | O(m·n·k·iter) | — |

## MATLAB 实现

```matlab
% Statistics and Machine Learning Toolbox / 自写
k = 5;
[W, H] = nnmf(V, k, ...
    'Algorithm', 'als', ...      % 交替最小二乘 (更快)
    'Replicates', 5, ...         % 多起点防局部最优
    'Options', statset('Display', 'iter'));

% 重建与残差
V_approx = W * H;
residual = norm(V - V_approx, 'fro');

% 检查分解质量: Cophenetic correlation
% 多次运行 NMF 看聚类稳定性

% 自写乘性更新
function [W, H] = nmf_mult(V, k, max_iter, tol)
    [m, n] = size(V);
    W = rand(m, k); H = rand(k, n);
    for iter = 1:max_iter
        % 更新 H
        H = H .* (W' * V) ./ (W' * W * H + eps);
        % 更新 W
        W = W .* (V * H') ./ (W * H * H' + eps);
        % 归一化
        W = W ./ sum(W, 1);
        if norm(V - W*H, 'fro') < tol, break; end
    end
end
```

锚点: `nnmf` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.decomposition import NMF
nmf = NMF(n_components=k, init='nndsvda', random_state=42, max_iter=1000)
W = nmf.fit_transform(V)  # m×k
H = nmf.components_       # k×n
```

## 选型决策树

- **NMF** — 数据非负 (图像像素/词频/光谱) + 需要可解释的"部分"表示
- **PCA/SVD (PARADIGM-0504/PARADIGM-0610)** — 可含负值分量 + 全局表示
- **LDA (PARADIGM-0613)** — 主题建模且需要概率框架 (Dirichlet先验)
- **ICA (独立成分分析)** — 盲源分离 (独立 vs 非负约束)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | RSS vs k 曲线 | 选分解秩 |
| result | 基矩阵 W 可视化 (每列=基图像/主题) | 人脸分解/谱分解 |
| result | H 各成分贡献堆叠图 | 每个样本的成分混合 |

## 常见坑

1. **非唯一性**: NMF 解不唯一 ($\mathbf{W}\mathbf{H} = \mathbf{W}\mathbf{Q}\mathbf{Q}^{-1}\mathbf{H}$ 对任意非负 monomial Q) → 不同初始化解可能完全不同 — 多起点取最小重构误差
2. **秩 k 的选择主观**: 无客观最优准则 → 用 Cophenetic correlation 或 RSS elbow + 可解释性
3. **ALS vs Multiplicative**: ALS 收敛快但可能陷入局部最优; Multiplicative 更鲁棒但慢

## 失效条件/反例 (强制小节)

- **条件1: 数据含零或接近零的值过多 (稀疏矩阵)** → 表现: 乘性更新中分母接近 0 → 除零导致 NaN/Inf → NMF 数值发散。**应对**: 对稀疏列/行加微小扰动 ($+\varepsilon$)，或使用正则化 NMF
- **条件2: 数据生成机制天然不满足非负性 (如中心化数据含负值)** → 表现: V 中有负值 → NMF 无定义 (约束违反)。**应对**: 若数据可含负值，不要用 NMF → 改用 PCA (PARADIGM-0504) 或 ICA；或使用 Semi-NMF (允许 W 含负值)

## 文献

1. Lee D.D. & Seung H.S. (1999). "Learning the parts of objects by non-negative matrix factorization." *Nature*, 401(6755):788-791. DOI: [10.1038/44565](https://doi.org/10.1038/44565)
2. Cichocki A., Zdunek R., Phan A.H. & Amari S. (2009). *Nonnegative Matrix and Tensor Factorizations*. Wiley. ISBN: 978-0470746660

## 来源溯源

MATLAB `nnmf` + 自写乘性更新

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0504 (PCA) |
| 替代 | PARADIGM-0610 (SVD) |
| 组合 | PARADIGM-0613 (LDA, 主题模型) |
