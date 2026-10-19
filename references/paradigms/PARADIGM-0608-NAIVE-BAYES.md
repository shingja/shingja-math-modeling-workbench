# PARADIGM-0608 朴素贝叶斯⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0608 |
| 类别/子类 | ⑥机器学习 / 概率分类 |
| 难度 | 低 |
| 适用题型关键词[] | 朴素贝叶斯, Naive Bayes, 贝叶斯分类, 文本分类, 垃圾邮件过滤, 条件独立, fitcnb |
| confidence | high |
| source | Duda & Hart (1973) Wiley |

## 数学形式

**贝叶斯定理:**
$$P(C_k \mid \mathbf{x}) = \frac{P(\mathbf{x} \mid C_k) P(C_k)}{P(\mathbf{x})}$$

**朴素条件独立假设:**
$$P(\mathbf{x} \mid C_k) = \prod_{j=1}^{p} P(x_j \mid C_k)$$

**分类决策:**
$$\hat{y} = \arg\max_k P(C_k) \prod_{j=1}^{p} P(x_j \mid C_k)$$

**分布假设:**
- 高斯 NB (连续特征): $P(x_j \mid C_k) = \mathcal{N}(x_j \mid \mu_{jk}, \sigma_{jk}^2)$
- 多项式 NB (离散计数): $P(x_j \mid C_k) \propto \theta_{jk}^{x_j}$
- 伯努利 NB (二元特征): $P(x_j \mid C_k) = \theta_{jk}^{x_j}(1-\theta_{jk})^{1-x_j}$

**数值稳定 (对数空间):**
$$\log P(C_k \mid \mathbf{x}) \propto \log P(C_k) + \sum_{j=1}^{p} \log P(x_j \mid C_k)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| Distribution | str | 'normal' | 'normal','kernel','mn','mvmn' | 极高 — 必须匹配数据类型 |
| Prior | str/vector | 'empirical' | 'empirical','uniform',或自定义 | 中 — 反映先验知识 |
| 训练复杂度 | — | — | O(n·p) | — |
| 预测复杂度 | — | — | O(p·K) | — |

## MATLAB 实现

```matlab
% 高斯朴素贝叶斯 (连续特征)
nb = fitcnb(X, Y, ...
    'DistributionNames', 'normal', ...
    'Prior', 'empirical', ...
    'CrossVal', 'on', ...
    'KFold', 10);

% 核密度估计 NB (不假设正态)
nb = fitcnb(X, Y, ...
    'DistributionNames', 'kernel', ...
    'Width', 'auto');

% 预测 + 后验概率
y_pred = predict(nb.Trained{1}, X_test);
[~, posterior] = predict(nb.Trained{1}, X_test);

% 文本分类 (多项式)
nb_text = fitcnb(X_tfidf, Y, ...
    'DistributionNames', 'mn');  % 多项式
```

锚点: `fitcnb` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.naive_bayes import GaussianNB, MultinomialNB, BernoulliNB
# 连续特征
nb = GaussianNB(var_smoothing=1e-9)
# 文本/计数
nb = MultinomialNB(alpha=1.0)  # Laplace 平滑
# 二元特征
nb = BernoulliNB(alpha=1.0)
nb.fit(X_train, y_train)
y_pred = nb.predict(X_test)
y_proba = nb.predict_proba(X_test)
```

## 选型决策树

- **朴素贝叶斯** — 文本分类 (TF-IDF+多项式NB)，维度极高 p>1000，特征近似独立
- **逻辑回归 (PARADIGM-0609)** — 特征高度相关时 NB 的概率估计有偏
- **SVM (PARADIGM-0605)** — 需要 SOTA 文本分类性能
- **不用 NB** — 特征强相关 (如金融时间序列)，条件独立假设严重违例

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 各类别特征分布直方图 | 验证正态假设 |
| result | ROC 曲线 + 后验概率分布 | 校准度诊断 |
| result | 混淆矩阵 | 各类别性能 |

## 常见坑

1. **零概率问题**: 训练集中未出现的特征值使 $P(x_j \mid C_k)=0$ → 整项乘积为 0。必须 Laplace/Lidstone 平滑 (+α)
2. **正态假设违例**: 连续特征多峰/厚尾时 Gaussian NB 表现差 → 改用 `DistributionNames','kernel'`
3. **类先验不匹配**: 训练集类别分布与真实分布不同 → 手动指定 `Prior` 参数

## 失效条件/反例 (强制小节)

- **条件1: 特征存在强相关性 (如多重共线性)** → 表现: 条件独立假设 $\prod P(x_j|C_k)$ 将相关特征的"证据"重复计数 $m$ 次，后验概率严重偏离真实值 — 对相关特征 $x_1,x_2$，$P(x_1,x_2|C_k) \neq P(x_1|C_k)P(x_2|C_k)$。**表现**: 分类置信度异常偏高 (接近 0 或 1) 但准确率反而下降。**应对**: 先做特征选择去除冗余特征，或换用非朴素模型 (如线性判别分析)
- **条件2: 目标分布与训练分布发生协变量偏移 (Covariate Shift)** → 表现: $P(C_k)$ 和 $P(x_j \mid C_k)$ 在测试集上不再成立，Naive Bayes 无法自适应。**应对**: 使用重要性采样重新加权，或建立自适应更新机制

## 文献

1. Duda R.O. & Hart P.E. (1973). *Pattern Classification and Scene Analysis*. Wiley. ISBN: 978-0471223610
2. Manning C.D., Raghavan P. & Schutze H. (2008). *Introduction to Information Retrieval*. Cambridge University Press. Chapter 13. ISBN: 978-0521865715

## 来源溯源

MATLAB `fitcnb`; 经典模式识别教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0609 (逻辑回归) |
| 组合 (文本) | PARADIGM-0903 (文本挖掘管道) |
| 替代 | PARADIGM-0605 (SVM) |
