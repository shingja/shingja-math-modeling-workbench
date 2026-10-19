# PARADIGM-0604 决策树CART⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0604 |
| 类别/子类 | ⑥机器学习 / 分类回归树 |
| 难度 | 低 |
| 适用题型关键词[] | 决策树, CART, 分类树, 回归树, 可解释性, Gini index, 剪枝, fitctree |
| confidence | high |
| source | Breiman et al. (1984) Wadsworth |

## 数学形式

**CART 分类 (Gini 不纯度):**
$$Gini(D) = 1 - \sum_{k=1}^{K} p_k^2$$

其中 $p_k$ 为节点中类别 $k$ 的样本占比。分裂选择最小化加权 Gini:

$$\Delta Gini = Gini(D) - \left(\frac{|D_L|}{|D|}Gini(D_L) + \frac{|D_R|}{|D|}Gini(D_R)\right)$$

**CART 回归 (MSE 减少):**
$$\Delta MSE = MSE(D) - \left(\frac{|D_L|}{|D|}MSE(D_L) + \frac{|D_R|}{|D|}MSE(D_R)\right)$$

**剪枝 (Cost-Complexity Pruning):**
$$R_\alpha(T) = R(T) + \alpha|T|$$

其中 $R(T)$ 为训练误差，$|T|$ 为叶节点数，$\alpha$ 为复杂度惩罚系数 (通过交叉验证选择)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| MinLeafSize | int | 1(分类),4(回归) | [1, n/2] | 高 — 控制过拟合 |
| MaxNumSplits | int | n-1 | [1, n-1] | 中 — 限制树深 |
| SplitCriterion | str | 'gdi' | 'gdi','deviance','twoing' | 低 — Gini 与熵结果接近 |
| Prune | str | 'on' | 'on','off' | 高 — 不剪枝必过拟合 |
| 训练复杂度 | — | — | O(n·p·log n) 平均 | — |
| 预测复杂度 | — | — | O(tree_depth) | — |

## MATLAB 实现

```matlab
% 分类树
tree = fitctree(X, Y, ...
    'MinLeafSize', 5, ...
    'MaxNumSplits', 20, ...
    'SplitCriterion', 'gdi', ...
    'Prune', 'on', ...
    'CrossVal', 'on', ...
    'KFold', 10);

% 查看最佳剪枝水平
[~,~,~,bestlevel] = cvLoss(tree, 'SubTrees', 'all');
pruned_tree = prune(tree, 'Level', bestlevel);

% 预测与评估
y_pred = predict(pruned_tree, X_test);
imp = predictorImportance(pruned_tree);

% 可视化
view(pruned_tree, 'Mode', 'graph');
```

锚点: `fitctree` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor, plot_tree
tree = DecisionTreeClassifier(
    min_samples_leaf=5, max_depth=10,
    criterion='gini', random_state=42
)
tree.fit(X_train, y_train)
# 剪枝路径: cost_complexity_pruning_path
ccp_alphas = tree.cost_complexity_pruning_path(X_train, y_train)
```

## 选型决策树

- **决策树** — 需要完全可解释性 + 非线性关系 + 特征交互简单
- **随机森林 (PARADIGM-0601)** — 牺牲解释性换泛化性能
- **GBDT (PARADIGM-0619)** — 提升树性能通常优于单棵树，解释性用 SHAP
- **逻辑回归 (PARADIGM-0609)** — 线性决策边界足够时更优

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 决策树结构图 (view tree) | 节点标注分裂规则和样本数 |
| result | 特征重要性柱状图 | bar(imp) 降序 |
| result | 剪枝路径 (loss vs tree size) | 选择 elbow point |

## 常见坑

1. **不剪枝树完美拟合训练集**: 但测试集性能差 — 必须剪枝或限制深度
2. **类别特征高基数偏倚**: 多值的特征在分裂选择中占优 (纯统计原因，非真正重要)
3. **轴平行分裂限制**: 无法直接捕捉对角线决策边界 → 需要多次分裂近似

## 失效条件/反例 (强制小节)

- **条件1: 特征间存在强 XOR/异或关系** → 表现: 单棵决策树需要大量节点近似 XOR 边界 ($O(2^d)$ 节点)，树深极大且易过拟合。二维 XOR 至少需 3 个分裂 (4 个叶节点)。**应对**: 使用核 SVM 或多层神经网络
- **条件2: 极端类别不平衡 + 小样本** → 表现: MinLeafSize=1 时少数类样本很快被"分裂完毕"，但在高噪声区域可能纯属偶然分裂 (噪声被当作信号)。**应对**: 加大 MinLeafSize，使用代价敏感学习或 SMOTE

## 文献

1. Breiman L., Friedman J.H., Olshen R.A. & Stone C.J. (1984). *Classification and Regression Trees*. Wadsworth. ISBN: 978-0412048418
2. Quinlan J.R. (1993). *C4.5: Programs for Machine Learning*. Morgan Kaufmann. ISBN: 978-1558602380

## 来源溯源

MATLAB `fitctree` / `fitrtree`; 培训模块 ML-ensemble

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (集成) | PARADIGM-0601 (RF) |
| 组合 (集成) | PARADIGM-0602 (AdaBoost) |
| 组合 (集成) | PARADIGM-0619 (GBDT) |
| 替代 | PARADIGM-0605 (SVM) |
