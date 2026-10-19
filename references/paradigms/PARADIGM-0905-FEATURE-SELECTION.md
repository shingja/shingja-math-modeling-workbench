# PARADIGM-0905 特征选择(Filter/Wrapper/Embedded)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0905 |
| 类别/子类 | ⑨经典与杂项 / 特征工程 |
| 难度 | 中 |
| 适用题型关键词[] | 特征选择, Feature Selection, Filter, Wrapper, Embedded, 变量筛选, 降维, Guyon&Elisseeff |
| confidence | high |
| source | Guyon & Elisseeff (2003) JMLR |

## 数学形式

**三大范型:**

**1. Filter (过滤法):** 独立于学习器，按统计量打分排序

- **Pearson 相关系数 (连续):**
  $$r_j = \frac{\sum (x_{ij} - \bar{x}_j)(y_i - \bar{y})}{\sqrt{\sum (x_{ij} - \bar{x}_j)^2 \sum (y_i - \bar{y})^2}}$$

- **互信息 (MI, 捕捉非线性):**
  $$I(X_j; Y) = \sum_{x,y} p(x,y) \log\frac{p(x,y)}{p(x)p(y)}$$

- **ANOVA F-statistic (分类):**
  $$F_j = \frac{\text{组间方差}}{\text{组内方差}} = \frac{\sum_k n_k(\bar{x}_{jk} - \bar{x}_j)^2 / (K-1)}{\sum_k \sum_{i \in k} (x_{ij} - \bar{x}_{jk})^2 / (n-K)}$$

- **卡方检验 (分类特征+分类目标):**
  $$\chi^2_j = \sum \frac{(O - E)^2}{E}$$

**2. Wrapper (包装法):** 用学习器性能评估子集

- **前向选择 (Forward Selection):** 从空集开始逐步添加最佳变量
- **后向消除 (Backward Elimination):** 从全集开始逐步删除最差变量
- **递归特征消除 (RFE):** 训练模型 → 删除最不重要特征 → 重复
  $$\mathbf{w}^* = \arg\min_{\mathbf{w}} \sum_i L(y_i, f(\mathbf{x}_i^{(S)}; \mathbf{w}))$$

**3. Embedded (嵌入法):** 特征选择嵌入在模型训练中

- **Lasso (L1 正则化):**
  $$\min_{\boldsymbol{\beta}} \| \mathbf{y} - \mathbf{X}\boldsymbol{\beta} \|_2^2 + \lambda \|\boldsymbol{\beta}\|_1$$

  许多 $\beta_j$ 被压缩为 0 → 自动特征选择

- **随机森林特征重要性 (PARADIGM-0601):**
  $$\text{VI}_j = \frac{1}{B}\sum_{b=1}^{B}(\text{err}_{b,\text{perm}} - \text{err}_{b,\text{original}})$$

- **Elastic Net:** L1 + L2 组合 → 组选择

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| k (保留特征数) | int | — | [1, p] | 高 |
| method | str | 'filter' | 'filter','wrapper','embedded' | 高 |
| filter_criterion | str | 'fstat' | 'corr','mi','fstat','chi2' | 中 |
| 复杂度 (Filter) | — | — | O(n·p) | — |
| 复杂度 (RFE) | — | — | O(p²·T_train) | — |
| 复杂度 (Lasso) | — | — | O(n·p·iter) | — |

## MATLAB 实现

```matlab
% === Filter 方法 ===
% Pearson
r = corr(X, Y);
[~, idx] = sort(abs(r), 'descend');
selected = idx(1:k);

% ANOVA F-statistic (分类)
for j = 1:p
    [p_val(j), tbl] = anova1(X(:,j), Y, 'off');
    F_stat(j) = tbl{2,5};
end
[~, idx] = sort(F_stat, 'descend');

% === Wrapper: RFE ===
% 用线性模型系数做 RFE
selected = 1:p;
ranking = [];
for iter = 1:(p-k)
    mdl = fitlm(X(:,selected), Y);
    [~, worst] = min(abs(mdl.Coefficients.Estimate(2:end))); % 除截距
    ranking = [ranking, selected(worst)];
    selected(worst) = [];
end

% === Embedded: Lasso ===
[B, FitInfo] = lasso(X, Y, 'CV', 10);
idxLambda1SE = FitInfo.Index1SE;
selected = find(B(:, idxLambda1SE) ~= 0);

% === 综合特征选择工具函数 ===
function [selected, scores] = feature_selection(X, Y, method, opts)
    switch method
        case 'filter'
            scores = abs(corr(X, Y));
            [~, idx] = sort(scores, 'descend');
            selected = idx(1:opts.k);
        case 'wrapper_rfe'
            % RFE 实现
            % ...
        case 'embedded_lasso'
            [B, info] = lasso(X, Y, 'CV', 5);
            selected = find(B(:, info.Index1SE));
    end
end
```

锚点: 自写-见S5:feature_selection.m (filter + wrapper + embedded 统一接口)

## Python 备选

```python
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif
from sklearn.feature_selection import RFE, RFECV
from sklearn.linear_model import LassoCV

# Filter
selector = SelectKBest(f_classif, k=20)
X_new = selector.fit_transform(X, y)

# RFE
rfe = RFE(estimator=LogisticRegression(), n_features_to_select=20)
X_new = rfe.fit_transform(X, y)

# Lasso embedded
lasso = LassoCV(cv=5).fit(X, y)
selected = np.where(lasso.coef_ != 0)[0]
```

## 选型决策树

- **Filter** — p > 10000，需要快速初筛 → 然后精细
- **Wrapper (RFE)** — 学习器已定 (如 SVM)，直接用它的性能评价子集
- **Embedded (Lasso/RF importance)** — 模型训练中自然做特征选择，高效
- **组合策略:** Filter (筛到 p=500) → Embedded (筛到 p=50) → Wrapper (精筛到 p=10)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 特征相关性矩阵 heatmap | 识别冗余 |
| process | 特征得分排序柱状图 (Filter) | 选择阈值 |
| result | 不同 k 下模型性能 vs k 曲线 | 选择最佳 k |

## 常见坑

1. **Filter 忽略特征交互**: 单个不显著的变量组合后可能显著 → Filter 筛掉后 Wrapper 无法恢复
2. **多重共线性 + Filter**: 多个高度相关的特征都得分高 → 选中冗余 → 用 VIF 先去共线性
3. **Wrapper 过拟合**: 搜索空间 = $2^p$ → 穷举不可能。RFE/前向选择可能陷入局部最优 → 用 Genetic Algorithm 做 Wrapper 搜索

## 失效条件/反例 (强制小节)

- **条件1: Filter 的 Pearson 相关性仅能检测线性关系** → 表现: 强非线性关系 (如 $y = |x - 0.5|$) 的 $r \approx 0$ → Filter 将关键变量排在最低 → 下游模型失去核心信息。**应对**: 使用互信息 (MI) 或最大信息系数 (MIC) 做 Filter (捕获非线性)
- **条件2: 前向选择 Wrapper 中早期选了非最优变量** → 表现: 前向选择是贪婪的 — 选入的变量在后续步骤中不再被移除，若早期误选高噪声变量，它永远占据位置挤出真正重要变量。**应对**: 使用 Floating Search (SFFS/SFBS) 允许已选变量被踢出，或直接用 RFE + Cross-Validation

## 文献

1. Guyon I. & Elisseeff A. (2003). "An introduction to variable and feature selection." *Journal of Machine Learning Research*, 3:1157-1182.
2. Tibshirani R. (1996). "Regression shrinkage and selection via the lasso." *JRSS B*, 58(1):267-288. (Lasso)

## 来源溯源

自写 feature_selection.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0501 (预处理) |
| 前置 | PARADIGM-0502 (离群点) |
| 组合 | PARADIGM-0601 (RF重要性) |
| 组合 | PARADIGM-0609 (Lasso逻辑回归) |
