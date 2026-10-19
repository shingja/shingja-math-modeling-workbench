# PARADIGM-0901 判别分析LDA/QDA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0901 |
| 类别/子类 | ⑨经典与杂项 / 分类方法 |
| 难度 | 低 |
| 适用题型关键词[] | LDA, 判别分析, QDA, 线性判别, Fisher, 分类, fitcdiscr, 贝叶斯分类 |
| confidence | high |
| source | Fisher (1936) Annals of Eugenics |

## 数学形式

**线性判别分析 (LDA):**

假设各类服从多元正态 $\mathcal{N}(\boldsymbol{\mu}_k, \mathbf{\Sigma})$ (相同协方差矩阵)。

**后验概率 (贝叶斯规则):**
$$P(G=k \mid \mathbf{x}) = \frac{\pi_k f_k(\mathbf{x})}{\sum_{j=1}^{K} \pi_j f_j(\mathbf{x})}$$

其中 $\pi_k$ 为类先验，$f_k$ 为密度函数。

**判别函数 (线性):**
$$\delta_k(\mathbf{x}) = \mathbf{x}^T\mathbf{\Sigma}^{-1}\boldsymbol{\mu}_k - \frac{1}{2}\boldsymbol{\mu}_k^T\mathbf{\Sigma}^{-1}\boldsymbol{\mu}_k + \log\pi_k$$

**决策边界:** $\delta_k(\mathbf{x}) = \delta_j(\mathbf{x})$ → 线性超平面。

**Fisher 视角 — 最大化类间方差 / 类内方差比:**
$$\max_{\mathbf{w}} \frac{\mathbf{w}^T\mathbf{S}_B\mathbf{w}}{\mathbf{w}^T\mathbf{S}_W\mathbf{w}}$$

其中 $\mathbf{S}_B$ 为类间散度矩阵，$\mathbf{S}_W$ 为类内散度矩阵。

**二次判别分析 (QDA):**
放松相同协方差假设 → $\mathbf{\Sigma}_k$ 每类不同:
$$\delta_k(\mathbf{x}) = -\frac{1}{2}\log|\mathbf{\Sigma}_k| - \frac{1}{2}(\mathbf{x}-\boldsymbol{\mu}_k)^T\mathbf{\Sigma}_k^{-1}(\mathbf{x}-\boldsymbol{\mu}_k) + \log\pi_k$$

决策边界 → 二次曲面 (椭圆/双曲线/抛物面)。

**参数估计:**
- $\hat{\boldsymbol{\mu}}_k = \bar{\mathbf{x}}_k$
- $\hat{\mathbf{\Sigma}} = \frac{1}{n-K}\sum_{k=1}^{K} \sum_{i: g_i=k} (\mathbf{x}_i - \bar{\mathbf{x}}_k)(\mathbf{x}_i - \bar{\mathbf{x}}_k)^T$ (LDA 池化)
- $\hat{\mathbf{\Sigma}}_k$ = 各类独立估计 (QDA)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| DiscrimType | str | 'linear' | 'linear','quadratic','diaglinear' | 高 — 决定边界复杂度 |
| Prior | str | 'empirical' | 'empirical','uniform',自定义 | 中 |
| Gamma (正则化) | double | 0 | [0, 1] | 中 — p>n时需要 |
| 训练复杂度 | — | — | O(n·p²+p³) | — |
| 预测复杂度 | — | — | O(K·p) | — |

## MATLAB 实现

```matlab
% Statistics and Machine Learning Toolbox
% LDA
lda = fitcdiscr(X, Y, 'DiscrimType', 'linear', ...
    'Prior', 'empirical', 'CrossVal', 'on', 'KFold', 10);

% 预测
y_pred = predict(lda.Trained{1}, X_test);
[~, posterior] = predict(lda.Trained{1}, X_test);

% QDA
qda = fitcdiscr(X, Y, 'DiscrimType', 'quadratic');

% 正则化判别 (p>n时)
lda_reg = fitcdiscr(X, Y, 'DiscrimType', 'linear', ...
    'Gamma', 0.5, 'Delta', 1e-4);  % 收缩估计

% 查看系数
coeff = lda.Coeffs;  % 线性判别系数

% 可视化判别空间
[Z, scores] = predict(lda, X);
gscatter(scores(:,1), scores(:,2), Y);  % 前两个判别轴
```

锚点: `fitcdiscr` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis, QuadraticDiscriminantAnalysis
lda = LinearDiscriminantAnalysis(solver='eigen', shrinkage='auto')
lda.fit(X_train, y_train)
y_pred = lda.predict(X_test)
# QDA
qda = QuadraticDiscriminantAnalysis(reg_param=0.0)
```

## 选型决策树

- **LDA** — 正态分布 (近似成立) + 同协方差 + 线性决策边界 → 参数少/小样本好
- **QDA** — 各类协方差显著不同 + 足够样本 (每类 > p) → 更灵活边界
- **逻辑回归 (PARADIGM-0609)** — 不假设正态分布 + 需要概率 + 线性可分离
- **SVM (PARADIGM-0605)** — 非线性 + 不需要分布假设
- **不要 LDA/QDA** — 高度离散/类别特征 → 用树/朴素贝叶斯

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 2D 散点图 + 各类椭圆 | 展示正态性和协方差 |
| result | 判别轴散点图 (gscatter) | 展示类分离 |
| result | 混淆矩阵 + ROC | 分类性能 |

## 常见坑

1. **LDA 的等协方差假设违例**: 各类 $\Sigma_k$ 差异大 → LDA 决策边界偏差 → 用 QDA 或 Box's M 检验后决定
2. **p > n 时 LDA 不可用**: $\Sigma$ 奇异 → 使用正则化 `Gamma` 参数或降维
3. **正态性违例**: LDA 对正态性中度违例尚稳健，但严重违例时用 RF 或 SVM

## 失效条件/反例 (强制小节)

- **条件1: p > n (特征远多于样本)** → 表现: $\mathbf{\Sigma}$ 和 $\mathbf{\Sigma}_k$ 均奇异 (不满秩)，LDA/QDA 无定义 → `fitcdiscr` 报错。**应对**: 使用正则化判别 (Gamma/Delta 参数) 或先 PCA 降维至 p < n
- **条件2: 类别分布严重不平衡 + QDA + 小样本少见类** → 表现: 少见类的 $\hat{\mathbf{\Sigma}}_k$ 用极少样本估计 → 高度不稳定 → QDA 对该类的决策边界剧烈震荡，预测方差极大。**应对**: 对少见类用 LDA (池化协方差) 或 shrunk QDA；或者对少数类过采样

## 文献

1. Fisher R.A. (1936). "The use of multiple measurements in taxonomic problems." *Annals of Eugenics*, 7(2):179-188. DOI: [10.1111/j.1469-1809.1936.tb02137.x](https://doi.org/10.1111/j.1469-1809.1936.tb02137.x)
2. Hastie T., Tibshirani R. & Friedman J. (2009). *The Elements of Statistical Learning*, 2nd ed. Springer. Chapter 4. ISBN: 978-0387848570

## 来源溯源

MATLAB `fitcdiscr`; 经典分类教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0609 (逻辑回归) |
| 替代 | PARADIGM-0605 (SVM) |
| 组合 | PARADIGM-0504 (PCA降维后LDA) |
