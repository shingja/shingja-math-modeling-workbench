# PARADIGM-0601 随机森林 (Bagging Tree Ensemble)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0601 |
| 类别/子类 | ⑥机器学习 / 集成学习 |
| 难度 | 中 |
| 适用题型关键词[] | 随机森林, Random Forest, Bagging, 特征随机选择, 集成学习, OOB误差, 特征重要性, 分类, 回归, 变量筛选 |
| confidence | high |
| source | Breiman(2001) Machine Learning; 培训模块 ML-ensemble |

## 数学形式

**Bagging (Bootstrap Aggregating) 框架**

对 $b = 1, 2, \ldots, B$ (共 $B$ 棵树):

1. **Bootstrap 采样**: 从训练集 $\mathcal{D} = \{(\mathbf{x}_i, y_i)\}_{i=1}^n$ 有放回抽取 $n$ 个样本，得到 $\mathcal{D}_b^*$。未被抽中的样本构成 OOB (Out-Of-Bag) 集合。

2. **随机特征选择**: 在每个节点的分裂时，从全部 $p$ 个特征中随机选取 $m = \lfloor\sqrt{p}\rfloor$ (分类) 或 $m = \lfloor p/3\rfloor$ (回归) 个候选特征，仅在这 $m$ 个特征中寻找最优分裂。

3. **训练决策树 $T_b$**: 在 $\mathcal{D}_b^*$ 上训练一棵不经剪枝的完全生长决策树，每个节点使用随机特征子集的最优分裂 (CART 准则)。

**分类 (多数投票)**:
$$\hat{y} = \arg\max_{c} \sum_{b=1}^{B} \mathbf{1}\{T_b(\mathbf{x}) = c\}$$

**回归 (平均)**:
$$\hat{y} = \frac{1}{B} \sum_{b=1}^{B} T_b(\mathbf{x})$$

**OOB 误差 (无偏泛化估计)**:
$$\epsilon_{\text{OOB}} = \frac{1}{n} \sum_{i=1}^{n} L\left(y_i, \frac{1}{|\mathcal{B}_i|} \sum_{b \in \mathcal{B}_i} T_b(\mathbf{x}_i)\right)$$

其中 $\mathcal{B}_i$ 为未使用样本 $i$ 的树的索引集合，$L$ 为损失函数 (分类: 0-1 损失; 回归: MSE)。

**特征重要性 (Permutation Importance)**:
$$\text{VI}(j) = \frac{1}{B} \sum_{b=1}^{B} \left[ \epsilon_{\text{OOB}, b}^{(j \text{ permuted})} - \epsilon_{\text{OOB}, b}^{(\text{original})} \right]$$

**泛化误差上界** (Breiman, 2001):
$$PE^* \leq \frac{\bar{\rho}(1 - s^2)}{s^2}$$

其中 $\bar{\rho}$ 为树间平均相关系数，$s$ 为单树强度 (strength)。随机特征选择通过降低 $\bar{\rho}$ 来降低泛化误差。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_estimators (B) | int | 100 | [10, 1000] | 中 — >200 后边际增益递减，但增加计算成本 |
| max_features (m) | int/str | sqrt(p) (分类), p/3 (回归) | [1, p] | 高 — 过小则单树太弱，过大则树间相关性高 |
| min_leaf_size | int | 1 (分类), 5 (回归) | [1, n/10] | 中 — 控制树深度和过拟合，小样本时影响大 |
| max_num_splits | int | n-1 (不限制) | [1, n-1] | 低 — 随机森林对树深度不敏感 |
| bootstrap_fraction | float | 1.0 | (0, 2.0) | 低 — 标准 Bagging 用 1.0 |
| p (特征数) | int | — | [1, ∞) | 高 — 决定 m 的取值和搜索空间维度 |
| n (样本量) | int | — | [1, ∞) | 高 — 决定 Bootstrap 多样性和树稳定性 |

| 输出 | 量纲 |
|------|------|
| predictions | 与 y 同量纲 (类别标签或实数值) |
| oobError | (0, 1) 分类误差率 或 MSE |
| feature_importance | 无量纲 (相对重要性得分，总和归一化) |
| oobPermutedPredictorImportance | 与 OOB 误差同量纲 (增量) |

**计算复杂度**: $O(B \cdot n \cdot p \cdot \log n)$ 训练时间；$O(B \cdot \log n)$ 单样本预测时间。可并行 (每棵树独立)。

## MATLAB 实现

**函数签名** (Statistics and Machine Learning Toolbox):

```matlab
% Method 1: fitensemble (推荐，更灵活)
rng(42);  % 可重复性
Mdl = fitensemble(X, Y, 'Bag', 100, 'Tree', ...
    'Type', 'classification', ...  % 或 'regression'
    'NPrint', 'Regression', ...    % 不训练时打印
    'Options', statset('UseParallel', true));

% 预测
y_pred = predict(Mdl, X_test);

% OOB 误差
oob_err = oobLoss(Mdl);  % 分类: 分类误差; 回归: MSE

% 特征重要性
imp = predictorImportance(Mdl);
bar(imp); xlabel('Feature Index'); ylabel('Importance');

% ===== Method 2: TreeBagger (更简单直接) =====
% 分类
rf = TreeBagger(100, X, Y, ...
    'Method', 'classification', ...
    'OOBPredictorImportance', 'on', ...
    'MinLeafSize', 5, ...
    'NumPredictorsToSample', 'all');  % TreeBagger 默认 sqrt(p) 分类, p/3 回归

% 回归
rf = TreeBagger(100, X, Y, ...
    'Method', 'regression', ...
    'OOBPredictorImportance', 'on');

% 预测
[y_pred, scores] = predict(rf, X_test);
y_pred = str2double(y_pred);  % 分类时需转换 cell→double

% OOB 误差
oob_err = oobError(rf);
plot(oob_err);  % 随树数量增加 OOB 误差收敛曲线

% 特征重要性
imp = rf.OOBPermutedPredictorDeltaError;
bar(imp);
```

**锚点工具箱函数**: `fitensemble`, `TreeBagger` (Statistics and Machine Learning Toolbox). 基学习器: `templateTree`.

**关键参数说明**:
- `NumPredictorsToSample`: TreeBagger 中 `'all'` 表示自动使用 `ceil(sqrt(p))` (分类) 或 `ceil(p/3)` (回归); 手动指定整数则用固定值
- `MinLeafSize`: 回归默认 5, 分类默认 1; 增大可防过拟合但降低训练速度的敏感性
- `OOBPredictorImportance='on'`: 启用 OOB 排列重要性计算，训练略慢但获得无偏特征重要性

## Python 备选

```python
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
import numpy as np

# 分类
rf = RandomForestClassifier(
    n_estimators=100,
    max_features='sqrt',     # 分类默认
    min_samples_leaf=1,
    oob_score=True,          # 启用 OOB
    random_state=42,
    n_jobs=-1                # 全核并行
)
rf.fit(X_train, y_train)
y_pred = rf.predict(X_test)
y_proba = rf.predict_proba(X_test)
print(f"OOB Score: {rf.oob_score_:.4f}")
imp = rf.feature_importances_

# 回归
rf = RandomForestRegressor(
    n_estimators=100,
    max_features=1/3,        # 回归默认: 使用 1/3 的特征
    min_samples_leaf=5,
    oob_score=True,
    random_state=42,
    n_jobs=-1
)
rf.fit(X_train, y_train)
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 特征 p > 100, 需特征筛选 | 随机森林 | 内置特征重要性，可直接排序筛选 |
| 非线性关系为主，变量交互复杂 | 随机森林 | 树模型自然捕捉交互，不需要显式指定交互项 |
| 样本量 n < 200 | 谨慎使用 | Bootstrap 重采样多样性不足，考虑自适应提升或正则化线性模型 |
| 需要概率输出 (校准良好) | 随机森林 + Platt Scaling | 投票比例有概率含义但需校准 |
| 解释性要求高 (如医疗/金融) | 单棵决策树 + 剪枝 | 随机森林是黑箱；可搭配 SHAP/LIME |
| 数据有大量缺失值 | 随机森林 | 天然支持缺失值 (代理分裂 surrogates) |
| 类别数量极不平衡 | 随机森林 + class_weight='balanced' | 需加权或 SMOTE 预处理 |
| 需要增量学习 (流式数据) | 不适合 | 随机森林不支持在线更新；考虑 Hoeffding Tree |
| 高维稀疏数据 (文本 TF-IDF) | 线性模型/GBDT | 随机分割在稀疏空间效率低下 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 特征分布箱线图 | 展示各特征在不同类别的分布差异 |
| process | OOB 误差 vs 树数量 | 判断 B 是否足够 (曲线是否收敛) |
| process | 特征重要性排序柱状图 | bar(imp) 降序排列，标注 top-10 |
| result | ROC 曲线 (分类) | 含 AUC 值和 95% CI |
| result | 预测 vs 真实散点图 (回归) | 叠加 y=x 参考线和 R² |
| result | 部分依赖图 (PDP) | 关键特征对预测的边际效应曲线 |
| result | 混淆矩阵 | heatmap 标注精度/召回率 |

## 常见坑

1. **OOB 误差 ≠ 测试集误差**: OOB 是内部交叉验证的近似，不替代真正独立的 hold-out 测试集。小样本时 OOB 可能乐观。
2. **特征重要性偏差**: 对高基数类别特征 (many levels) 和连续特征，排列重要性有偏 — 类别多的特征获得虚高重要性。使用条件排列重要性修正。
3. **过拟合噪声标签**: 虽然随机森林理论不过拟合 (Breiman 证明)，但在高噪声小样本下仍会过拟合 — 每棵树完美拟合 Bootstrap 样本中的噪声。
4. **B 的设置**: B < 50 时 OOB 误差可能不稳定 (方差大); B > 500 时继续增加几乎无改进但训练时间线性增长。
5. **max_features = p (即 Bagging)**: 当特征全部相关时 (如时间序列的滞后项)，随机特征选择的去相关效果失效，随机森林退化为普通 Bagging。
6. **分类不平衡**: 默认 Bootstrap 样本的类别分布与原数据相同 — 稀有类在每棵树中可能完全缺失，导致对该类的预测性能极差。

## 失效条件/反例 (强制小节)

- **条件1: 特征 p 巨大 (>10000) 但真正相关的特征极少 (<10)** → **表现**: 随机特征子集 $m = \lfloor\sqrt{p}\rfloor \approx 100$ 中包含真正信号特征的概率极低 ($\approx 10/10000 \times 100 \approx 0.1$)。每棵树几乎学不到信号，单树强度 $s$ 极低，整体退化为随机猜测。**应对**: 先用过滤式特征选择 (如互信息、F 统计量) 降维至 p < 1000，再训练随机森林。

- **条件2: 样本量 n < 50 (小样本)** → **表现**: Bootstrap 采样在 n 很小时多样性不足 — 任意两棵树的训练集重叠度高达 $\approx 1 - (1 - 1/n)^n \to 1 - 1/e \approx 0.632$。树间相关性 $\bar{\rho}$ 很高，集成几乎没有提升方差的效果，泛化误差 PE* 接近单棵树。另外，小样本下 OOB 估计的方差大，不可信。**应对**: 使用 RBF-SVM (小样本强泛化) 或贝叶斯方法; 若必须用 RF，设置 min_leaf_size >= max(5, n/10) 强制剪枝，并做重复交叉验证而非依赖 OOB。

- **条件3: 高度不平衡的二分类 (某类占比 < 5%)** → **表现**: Bootstrap 样本中缺少数类的概率高 — 若少数类仅 k 个样本，每棵树不包含任何少数类样本的概率为 $(1 - k/n)^n \approx e^{-k}$。当 k=5 时约 0.7% 的树包含少数类，投票机制被多数类淹没。OOB 误差报告看似 95% 准确率，实则完全无法识别少数类。**应对**: 使用 `'Prior','empirical'` (TreeBagger) 或 `class_weight='balanced_subsample'` (sklearn)，配合 SMOTE 过采样或代价敏感学习。

## 文献

1. Breiman L (2001). "Random forests." *Machine Learning*, 45(1):5-32. DOI: [10.1023/A:1010933404324](https://doi.org/10.1023/A:1010933404324)
2. Breiman L (1996). "Bagging predictors." *Machine Learning*, 24(2):123-140. DOI: [10.1007/BF00058655](https://doi.org/10.1007/BF00058655)
3. Hastie T, Tibshirani R, Friedman J (2009). *The Elements of Statistical Learning*, 2nd ed. Springer. Chapter 15. ISBN: 978-0387848570
4. Strobl C, Boulesteix AL, Zeileis A, Hothorn T (2007). "Bias in random forest variable importance measures: Illustrations, sources and a solution." *BMC Bioinformatics*, 8:25. DOI: [10.1186/1471-2105-8-25](https://doi.org/10.1186/1471-2105-8-25)

## 来源溯源

Breiman L (2001) Machine Learning 45(1); 培训模块 ML-ensemble (集成学习).

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0602 (AdaBoost, 自适应提升, 更关注难分类样本) |
| 替代 | PARADIGM-0618 (CNN, 网格数据深度学习, 图像/序列场景) |
| 组合 | PARADIGM-0504 (PCA, 降维后训练随机森林, 处理高维共线特征) |
| 组合 | PARADIGM-1002 (EGO, 贝叶斯优化RF超参数) |
| 前置 | PARADIGM-0501 (数据预处理, 缺失值/标准化/编码) |
