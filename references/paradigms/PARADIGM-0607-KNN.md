# PARADIGM-0607 K近邻KNN⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0607 |
| 类别/子类 | ⑥机器学习 / 实例学习 |
| 难度 | 低 |
| 适用题型关键词[] | KNN, K近邻, k-Nearest Neighbors, 实例学习, 惰性学习, 分类, 回归, fitcknn |
| confidence | high |
| source | Cover & Hart (1967) IEEE Trans Info Theory |

## 数学形式

**KNN 分类 (多数投票):**
$$\hat{y} = \arg\max_{c} \sum_{i \in N_k(\mathbf{x})} \mathbf{1}\{y_i = c\}$$

**KNN 回归 (局部平均):**
$$\hat{y} = \frac{1}{k} \sum_{i \in N_k(\mathbf{x})} y_i$$

**加权 KNN (距离倒数加权):**
$$\hat{y} = \frac{\sum_{i \in N_k(\mathbf{x})} w_i y_i}{\sum_i w_i}, \quad w_i = \frac{1}{d(\mathbf{x}, \mathbf{x}_i) + \varepsilon}$$

其中 $N_k(\mathbf{x})$ 为 $\mathbf{x}$ 的 $k$ 个最近邻的索引集，$d$ 为距离度量。

**距离度量:**
- 欧氏距离: $d = \|\mathbf{x} - \mathbf{x}_i\|_2$
- 曼哈顿距离: $d = \|\mathbf{x} - \mathbf{x}_i\|_1$
- 马氏距离: $d = \sqrt{(\mathbf{x} - \mathbf{x}_i)^T \Sigma^{-1} (\mathbf{x} - \mathbf{x}_i)}$

**泛化误差界 (Cover & Hart):**
1-NN 误差 $\leq 2 \times$ Bayes 误差 (渐进)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| k | int | 5 | [1, n] | 极高 — k=1 过拟合，k太大欠拟合 |
| Distance | str | 'euclidean' | 'euclidean','cityblock','mahalanobis' | 中 — 影响近邻定义 |
| Standardize | bool | true | — | 高 — 量纲差异扭曲距离 |
| 训练复杂度 | — | — | O(1) (惰性) | — |
| 预测复杂度 | — | — | O(n·p) 暴力; O(k·log n) KD-tree | — |

## MATLAB 实现

```matlab
% 分类
knn = fitcknn(X, Y, ...
    'NumNeighbors', 5, ...
    'Distance', 'euclidean', ...
    'Standardize', true, ...
    'NSMethod', 'kdtree', ...  % 或 'exhaustive'
    'CrossVal', 'on', ...
    'KFold', 10);

% 通过交叉验证选最佳 k
k_values = 1:2:31;
cv_loss = zeros(size(k_values));
for i = 1:length(k_values)
    knn_cv = fitcknn(X, Y, 'NumNeighbors', k_values(i), ...
        'KFold', 10, 'Standardize', true);
    cv_loss(i) = kfoldLoss(knn_cv);
end
[~, best_idx] = min(cv_loss);
best_k = k_values(best_idx);

% 预测
y_pred = predict(knn.Trained{1}, X_test);
```

锚点: `fitcknn` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
knn = KNeighborsClassifier(n_neighbors=5, weights='distance',
                           metric='minkowski', p=2, n_jobs=-1)
knn.fit(X_train, y_train)
y_pred = knn.predict(X_test)
y_proba = knn.predict_proba(X_test)
```

## 选型决策树

- **KNN** — 极简单基线；数据局部结构清晰；懒学习 (无需训练时间)
- **SVM (PARADIGM-0605)** — 维度 p > 30，KNN 距离在高维下失效
- **决策树 (PARADIGM-0604)** — 需要特征重要性和可解释规则
- **不用 KNN** — p > 30 (维度灾难), n > 10^5 (预测慢), 含大量无关特征

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | CV 误差 vs k 值曲线 | 选最佳 k |
| result | 2D 决策区域着色 (Voronoi图) | 展示 k 的平滑效果 |
| result | 混淆矩阵 | 附 Precision/Recall |

## 常见坑

1. **维度灾难**: p > 30 时在高维空间几乎所有点等距 → KNN 退化
2. **特征未标准化**: 量纲大的特征主导距离计算 → 必须 `Standardize=true`
3. **k 值奇偶**: 二分类时 k 取偶数可能平票 → 用奇数 k 或加权投票
4. **预测慢**: 暴力搜索 O(n·p) 在大数据上慢 → 用 KD-tree (`NSMethod='kdtree'`)

## 失效条件/反例 (强制小节)

- **条件1: 特征维度 p > 30 且多数特征为噪声** → 表现: 距离在高维空间中失去区分度 (Distance Concentration)，所有点到查询点的距离趋于相等，k 个"近"邻实际上近似随机采样，分类退化为随机猜测。**应对**: 先用 PCA 或特征选择降维至 p < 10 再用 KNN
- **条件2: 类别极端不平衡且 k 相对于少数类太大** → 表现: 少数类样本的 k 近邻中几乎全是多数类，权重投票被淹没 — 对少数类 Precision/Recall ≈ 0。**应对**: 使用自适应 k (每个类别不同 k)、距离加权 + 类别权重，或对少数类过采样

## 文献

1. Cover T.M. & Hart P.E. (1967). "Nearest neighbor pattern classification." *IEEE Transactions on Information Theory*, 13(1):21-27. DOI: [10.1109/TIT.1967.1053964](https://doi.org/10.1109/TIT.1967.1053964)
2. Duda R.O., Hart P.E. & Stork D.G. (2000). *Pattern Classification*, 2nd ed. Wiley. Chapter 4. ISBN: 978-0471056690

## 来源溯源

MATLAB `fitcknn`; 经典模式识别教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0605 (SVM) |
| 替代 | PARADIGM-0604 (决策树) |
| 前置 | PARADIGM-0504 (PCA降维) |
