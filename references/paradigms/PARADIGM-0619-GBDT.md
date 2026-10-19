# PARADIGM-0619 GBDT梯度提升⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0619 |
| 类别/子类 | ⑥机器学习 / 梯度提升 |
| 难度 | 中 |
| 适用题型关键词[] | GBDT, 梯度提升, Gradient Boosting, LSBoost, 残差学习, 集成学习, fitensemble |
| confidence | high |
| source | Friedman (2001) Annals of Statistics |

## 数学形式

**GBDT 前向分步加法模型:**
$$F_m(\mathbf{x}) = F_{m-1}(\mathbf{x}) + \nu \cdot h_m(\mathbf{x})$$

其中 $h_m$ 为第 $m$ 棵基学习器 (通常是浅层决策树)，$\nu$ 为学习率 (shrinkage)。

**负梯度 (残差近似):**
对损失函数 $L(y, F)$，第 $m$ 轮的伪残差:
$$\tilde{y}_i = -\left[\frac{\partial L(y_i, F(\mathbf{x}_i))}{\partial F(\mathbf{x}_i)}\right]_{F=F_{m-1}}$$

**平方损失 (LSBoost) 下:**
$\tilde{y}_i = y_i - F_{m-1}(\mathbf{x}_i)$ (即普通残差)
$$h_m = \arg\min_h \sum_{i=1}^{n} (\tilde{y}_i - h(\mathbf{x}_i))^2$$

**其他常用损失:**
- **LAD (绝对损失，鲁棒):** $L(y,F) = |y-F|$, $\tilde{y} = \text{sign}(y-F)$
- **Huber (混合):** 离群点鲁棒性 + 可微性
- **Deviance (分类):** Logistic / Exponential loss

**Friedman 的改进:**
$$F_m(\mathbf{x}) = F_{m-1}(\mathbf{x}) + \nu \cdot \sum_{j=1}^{J} \gamma_{jm} \mathbf{1}\{\mathbf{x} \in R_{jm}\}$$

$\gamma_{jm}$ 单独优化每片叶子的最优值 (Line Search)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_learners | int | 100 | [50, 5000] | 高 — 过大会过拟合 |
| learning_rate (ν) | double | 0.1 | [0.001, 1.0] | 极高 — ν↓需↑迭代数 |
| max_splits | int | 10 | [1, 100] | 中 — 控制基学习器复杂度 |
| LossFunction | str | 'LSBoost' | 'LSBoost','LAD','Huber' | 中 — AD/Huber 对离群点鲁棒 |
| 训练复杂度 | — | — | O(n_learners·n·p·depth) | — |

## MATLAB 实现

```matlab
% LSBoost 回归
Mdl = fitensemble(X, Y, 'LSBoost', 500, 'Tree', ...
    'LearnRate', 0.1, ...
    'NPrint', 'off');

% 分类
Mdl = fitensemble(X, Y, 'AdaBoostM2', 200, 'Tree', ...
    'LearnRate', 0.1);

% 预测
y_pred = predict(Mdl, X_test);

% 损失曲线 → 判断迭代是否足够
L = resubLoss(Mdl, 'Mode', 'cumulative');
plot(L); xlabel('Number of trees'); ylabel('Training Loss');

% 交叉验证
Mdl_cv = fitensemble(X, Y, 'LSBoost', 500, 'Tree', ...
    'LearnRate', 0.1, ...
    'KFold', 5);
cv_loss = kfoldLoss(Mdl_cv, 'Mode', 'cumulative');
[~, best_n] = min(cv_loss);
```

锚点: `fitensemble` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.ensemble import GradientBoostingClassifier, GradientBoostingRegressor
gbdt = GradientBoostingRegressor(
    n_estimators=500, learning_rate=0.1,
    max_depth=4, subsample=0.8,
    random_state=42
)
gbdt.fit(X_train, y_train)
# 查看每轮损失
test_score = np.zeros(500)
for i, y_pred in enumerate(gbdt.staged_predict(X_test)):
    test_score[i] = mean_squared_error(y_test, y_pred)
```

## 选型决策树

- **GBDT** — 结构化数据的 SOTA 基线，特征交互复杂
- **XGBoost (PARADIGM-0206)** — 需要更好的正则化 + GPU 加速
- **CatBoost (PARADIGM-0616)** — 含大量类别特征
- **随机森林 (PARADIGM-0601)** — 样本量小 + 噪声高 (Bagging 更鲁棒)
- **AdaBoost (PARADIGM-0602)** — 二分类 + 弱学习器可快速训练

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | CV Loss vs n_trees | 选最佳迭代数 |
| result | 特征重要性 (predictorImportance) | 降序 |
| result | 预测 vs 真实 + 残差图 | 模型诊断 |

## 常见坑

1. **迭代数 too big**: 树数太多 + 学习率不小 → 过拟合。shrinkage 原理: ν 小 → 需要更多树 → 但整体泛化更好
2. **基学习器太深**: depth > 6 时 GBDT 容易过拟合，尤其在小样本下
3. **不验证集早停**: 不设验证集 → 不知何时停止 → resubLoss 持续下降但测试误差上升

## 失效条件/反例 (强制小节)

- **条件1: 超高噪声标签 (信噪比 < 0.1)** → 表现: GBDT 逐轮"学习噪声" — 残差中包含的主要是噪声而非信号，后期迭代的树在拟合纯噪声 → 测试误差随迭代上升 (过拟合)。**应对**: 1) 大幅降低 learning_rate 并配合 early stopping; 2) 使用随机森林 (Bagging 对噪声标签更鲁棒); 3) 增加 min_leaf_size 限制
- **条件2: 高维稀疏数据 (p > 10000, nnz << p)** → 表现: 树在稀疏特征上分裂效率低 — 每次分裂仅利用极少量非零信息，需要大量树才能捕捉交互。训练 O(n_learners·n·p·depth) 在 p 巨大时不可行。**应对**: 先用 L1 正则化线性模型做特征筛选，或换用 XGBoost 的稀疏感知算法 (Sparsity-aware Split Finding)

## 文献

1. Friedman J.H. (2001). "Greedy function approximation: A gradient boosting machine." *Annals of Statistics*, 29(5):1189-1232. DOI: [10.1214/aos/1013203451](https://doi.org/10.1214/aos/1013203451)
2. Friedman J.H. (2002). "Stochastic gradient boosting." *Computational Statistics & Data Analysis*, 38(4):367-378. DOI: [10.1016/S0167-9473(01)00065-2](https://doi.org/10.1016/S0167-9473(01)00065-2)

## 来源溯源

MATLAB `fitensemble`; Friedman 经典论文

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0206 (XGBoost/LightGBM) |
| 替代 | PARADIGM-0601 (RF) |
| 替代 | PARADIGM-0616 (CatBoost) |
| 前置 | PARADIGM-0604 (决策树) |
