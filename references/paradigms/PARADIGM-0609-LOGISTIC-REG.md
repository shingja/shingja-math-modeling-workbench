# PARADIGM-0609 逻辑斯谛回归⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0609 |
| 类别/子类 | ⑥机器学习 / 广义线性模型 |
| 难度 | 低 |
| 适用题型关键词[] | 逻辑回归, Logistic Regression, 二元分类, 概率输出, 广义线性模型, fitglm, 风险预测 |
| confidence | high |
| source | Cox (1958) JRSS |

## 数学形式

**模型 (sigmoid 函数):**
$$P(Y=1 \mid \mathbf{x}) = \frac{1}{1 + e^{-(\beta_0 + \beta^T\mathbf{x})}} = \sigma(\beta_0 + \beta^T\mathbf{x})$$

**对数几率 (Log-Odds):**
$$\log\frac{P(Y=1)}{P(Y=0)} = \beta_0 + \beta^T\mathbf{x}$$

**极大似然估计 (MLE):**
$$\ell(\beta) = \sum_{i=1}^{n} \left[y_i \log p_i + (1-y_i) \log(1-p_i)\right]$$

其中 $p_i = \sigma(\beta_0 + \beta^T\mathbf{x}_i)$。

**正则化 (防止过拟合):**
- L1 (Lasso): $-\ell(\beta) + \lambda\|\beta\|_1$ → 稀疏解
- L2 (Ridge): $-\ell(\beta) + \lambda\|\beta\|_2^2$ → 收缩系数

**Wald 检验:**
$$z_j = \frac{\hat{\beta}_j}{SE(\hat{\beta}_j)} \sim \mathcal{N}(0,1)$$

**变量表:**
- $\beta$ — 系数向量，$\beta_j$ 的含义: $x_j$ 增加 1 单位，Odds 乘以 $e^{\beta_j}$
- $p$ — 预测概率 ∈ [0,1]

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| Distribution | str | 'binomial' | 'binomial'(二分类),'multinomial'(多分类) | — |
| Link | str | 'logit' | 'logit','probit','comploglog' | 中 |
| lambda (正则化) | double | 0 | [0, ∞) | 高 — L1/L2 强度 |
| 训练复杂度 | — | — | O(n·p²) IRLS | — |
| 预测复杂度 | — | — | O(p) | — |

## MATLAB 实现

```matlab
% 二分类逻辑回归
mdl = fitglm(X, Y, ...
    'Distribution', 'binomial', ...
    'Link', 'logit');

% 系数与显著性
disp(mdl.Coefficients);  % Estimate, SE, tStat, pValue

% 预测概率
p_pred = predict(mdl, X_test);
y_pred = round(p_pred);  % 0.5 阈值

% 正则化 (Lasso 逻辑回归)
[B, FitInfo] = lassoglm(X, Y, 'binomial', ...
    'CV', 10, 'Alpha', 0.5);  % Elastic Net
lassoPlot(B, FitInfo, 'PlotType', 'CV');

% 多分类 (多项逻辑回归)
mdl_multi = fitglm(X, categorical(Y), ...
    'Distribution', 'multinomial');
```

锚点: `fitglm` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.linear_model import LogisticRegression
lr = LogisticRegression(penalty='l2', C=1.0, solver='lbfgs',
                        max_iter=1000, random_state=42)
lr.fit(X_train, y_train)
y_pred = lr.predict(X_test)
y_proba = lr.predict_proba(X_test)[:, 1]
```

## 选型决策树

- **逻辑回归** — 需要概率输出 + 系数解释 (OR值) + 特征-结果单调关系
- **SVM (PARADIGM-0605)** — 只需分类标签不要概率，非线性决策边界
- **朴素贝叶斯 (PARADIGM-0608)** — 高维稀疏特征 (文本)，但对相关特征鲁棒性差
- **线性判别分析 (PARADIGM-0901)** — 特征服从正态分布时 (LDA 更强假设)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 单变量 vs 对数几率散点图 | 验证线性假设 |
| result | Sigmoid 函数曲线 + 数据点 | 决策边界 = 0.5 |
| result | ROC + AUC + 校准曲线 | 展示概率质量 |
| result | 系数森林图 (Forest Plot) | OR 值 95% CI |

## 常见坑

1. **完全分离 (Complete Separation)**: 某特征完全可分开两类 → β 估计发散 (趋于无穷)，MATLAB 报 warning → 用 Firth 修正或 L2 正则化
2. **多重共线性**: 高相关特征导致系数符号不稳定，SE 膨胀 → 先做 VIF 检验 + 去除高度相关变量
3. **类别不平衡**: 截距项偏斜，少数类概率整体偏低 → 调整阈值 (不一定 0.5) 或用 `'Prior','empirical'`

## 失效条件/反例 (强制小节)

- **条件1: 非线性决策边界 (如环形分布)** → 表现: 逻辑回归假设对数几率是特征的线性函数，环形数据的内外圈无法用一条直线分离 — AUC ≈ 0.5 (等同于随机)。**应对**: 添加多项式特征/交互项 ($x_1^2, x_2^2, x_1x_2$) 使决策边界弯曲，或换用核 SVM/RF
- **条件2: 特征远多于样本 (p >> n)** → 表现: MLE 不存在唯一解 (参数不可识别)。**应对**: 使用 L1 正则化 (Lasso 逻辑回归) 或先用 PCA 降维，或在 `fitglm` 中减小特征集

## 文献

1. Cox D.R. (1958). "The regression analysis of binary sequences." *Journal of the Royal Statistical Society: Series B*, 20(2):215-242. DOI: [10.1111/j.2517-6161.1958.tb00292.x](https://doi.org/10.1111/j.2517-6161.1958.tb00292.x)
2. Hosmer D.W., Lemeshow S. & Sturdivant R.X. (2013). *Applied Logistic Regression*, 3rd ed. Wiley. ISBN: 978-0470582473

## 来源溯源

MATLAB `fitglm`; 培训模块 ML-GLM

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0605 (SVM) |
| 替代 | PARADIGM-0901 (LDA判别分析) |
| 组合 (降维) | PARADIGM-0504 (PCA) |
| 组合 (变量选择) | PARADIGM-0905 (特征选择) |
