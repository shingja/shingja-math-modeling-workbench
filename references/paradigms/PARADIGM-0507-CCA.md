# PARADIGM-0507 典型相关分析CCA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0507 |
| 类别/子类 | ⑤统计 / 多元相关 |
| 难度 | 中 |
| 适用题型关键词[] | CCA, 典型相关, 多元相关, 两组变量关系, 最大相关投影, Hotelling |
| confidence | high |
| source | Hotelling (1936) Biometrika |

## 数学形式

**问题:** 寻找两组变量 $\mathbf{X} \in \mathbb{R}^p$ 和 $\mathbf{Y} \in \mathbb{R}^q$ 的线性组合 $U = \mathbf{a}^T\mathbf{X}$ 和 $V = \mathbf{b}^T\mathbf{Y}$ 最大化相关系数。

**目标:**
$$\max_{\mathbf{a}, \mathbf{b}} \; \rho = \text{Corr}(\mathbf{a}^T\mathbf{X}, \mathbf{b}^T\mathbf{Y})$$

$$\rho = \frac{\mathbf{a}^T \mathbf{\Sigma}_{XY} \mathbf{b}}{\sqrt{\mathbf{a}^T \mathbf{\Sigma}_{XX} \mathbf{a} \cdot \mathbf{b}^T \mathbf{\Sigma}_{YY} \mathbf{b}}}$$

**广义特征值问题:**
$$\mathbf{\Sigma}_{XX}^{-1} \mathbf{\Sigma}_{XY} \mathbf{\Sigma}_{YY}^{-1} \mathbf{\Sigma}_{YX} \mathbf{a} = \rho^2 \mathbf{a}$$
$$\mathbf{\Sigma}_{YY}^{-1} \mathbf{\Sigma}_{YX} \mathbf{\Sigma}_{XX}^{-1} \mathbf{\Sigma}_{XY} \mathbf{b} = \rho^2 \mathbf{b}$$

**典型相关系数:** $\rho_1 \geq \rho_2 \geq \cdots \geq \rho_r$，$r = \min(p, q)$。

**显著性检验 (Bartlett $\chi^2$):**
$$\Lambda_k = \prod_{i=k}^{r} (1 - \rho_i^2)$$
$$-\left(n - 1 - \frac{p+q+1}{2}\right) \ln \Lambda_k \sim \chi^2_{(p-k+1)(q-k+1)}$$

**冗余指数 (Redundancy Index):**
衡量一组变量能解释另一组变量多少方差。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| p (X 维数) | int | — | [1, n/2] | 高 — p,q 大需大 n |
| q (Y 维数) | int | — | [1, n/2] | 高 |
| n_components | int | min(p,q) | [1, min(p,q)] | 高 |
| 复杂度 | — | — | O(n(p+q)²+(p+q)³) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[A, B, rho, p_values, redundancy] = cca(X, Y, n_components)
% A: p×k 载荷 (X侧)
% B: q×k 载荷 (Y侧)
% rho: k×1 典型相关系数
```

锚点: 自写-见S5:cca.m

```matlab
function [A, B, r, pvals] = cca(X, Y)
    [n, p] = size(X); q = size(Y, 2);
    
    % 中心化 + 协方差矩阵
    Xc = X - mean(X); Yc = Y - mean(Y);
    Sxx = (Xc' * Xc) / (n-1);
    Syy = (Yc' * Yc) / (n-1);
    Sxy = (Xc' * Yc) / (n-1);
    
    % 广义特征值
    [A, D2] = eig(Sxx \ (Sxy / Syy * Sxy'));
    r = sqrt(diag(D2));
    [r, idx] = sort(r, 'descend');
    A = A(:, idx);
    
    % Y侧载荷
    B = Syy \ Sxy' * A;
    % 归一化
    for k = 1:min(p,q)
        A(:,k) = A(:,k) / sqrt(A(:,k)' * Sxx * A(:,k));
        B(:,k) = B(:,k) / sqrt(B(:,k)' * Syy * B(:,k));
    end
    
    % Bartlett 检验
    k = min(p,q);
    pvals = zeros(k,1);
    for i = 1:k
        Lambda = prod(1 - r(i:k).^2);
        chi2 = -(n - 1 - (p+q+1)/2) * log(Lambda);
        df = (p-i+1) * (q-i+1);
        pvals(i) = 1 - chi2cdf(chi2, df);
    end
end
```

## Python 备选

```python
from sklearn.cross_decomposition import CCA
cca = CCA(n_components=2)
X_c, Y_c = cca.fit_transform(X, Y)
print(cca.x_weights_, cca.y_weights_)
```

## 选型决策树

- **CCA** — 研究两组变量间的关联结构 (如基因表达 vs 临床表现)
- **PCA (PARADIGM-0504)** — 仅一组变量的降维
- **PLS (PARADIGM-0510)** — 预测导向 (用 X 预测 Y)，CCA 是相关导向
- **RDA (冗余分析)** — Y 侧也有约束时

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 典型变量散点图 (U_k vs V_k) | k=1,2 子图 |
| result | 典型相关系数碎石图 | 选显著分量 |
| result | 典型载荷热力图 | X 和 Y 各变量对典型变量的贡献 |

## 常见坑

1. **n 不足: n < p+q** → 协方差矩阵奇异 → PCA 先降维或正则化 CCA
2. **典型相关系数虚高**: 小 n 大 p 时 $\rho_1$ 接近 1 即使是随机数据 → 需 Bartlett 检验
3. **多重共线性**: X 或 Y 内高度相关 → $\Sigma_{XX}^{-1}$ 不稳定 → 用 Ridge CCA (正则化)

## 失效条件/反例 (强制小节)

- **条件1: n < p+q (样本少于总变量数)** → 表现: 典型相关系数 $\rho_1 \approx 1$ 即使两组变量完全独立 → 样本内完全拟合但毫无泛化意义。**应对**: 使用正则化 CCA (Ridge CCA: $\Sigma_{XX} + \lambda_X I$) 或稀疏 CCA (L1 惩罚) 减少有效参数
- **条件2: 一组变量含离散类别 (如性别、区域)** → 表现: CCA 的 Pearson 相关性假设连续变量，对二值/多值类别变量的相关系数被低估 → 典型变量的载荷和相关性失真。**应对**: 将类别变量哑变量化 (One-Hot)，或使用非线性 CCA (Kernel CCA)

## 文献

1. Hotelling H. (1936). "Relations between two sets of variates." *Biometrika*, 28(3/4):321-377. DOI: [10.2307/2333953](https://doi.org/10.2307/2333953)
2. Hardoon D.R., Szedmak S. & Shawe-Taylor J. (2004). "Canonical correlation analysis: An overview with application to learning methods." *Neural Computation*, 16(12):2639-2664.

## 来源溯源

自写 cca.m; 多元统计教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0510 (PLS) |
| 前置 | PARADIGM-0504 (PCA) |
| 组合 | PARADIGM-0501 (预处理) |
