# PARADIGM-0620 Stacking模型融合⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0620 |
| 类别/子类 | ⑥机器学习 / 集成学习 |
| 难度 | 中 |
| 适用题型关键词[] | Stacking, 模型融合, 元学习, 集成, 多模型组合, 混合模型, Stacked Generalization |
| confidence | medium |
| source | Wolpert (1992) Neural Networks |

## 数学形式

**两层 Stacking 框架:**

**Level-0 (基学习器):** $f_1, f_2, \ldots, f_K$

基学习器在训练集上做 K-fold 交叉验证产出 Level-1 特征:
$$\mathbf{z}_i = [f_1^{(-k(i))}(\mathbf{x}_i), f_2^{(-k(i))}(\mathbf{x}_i), \ldots, f_K^{(-k(i))}(\mathbf{x}_i)]$$

其中 $f_j^{(-k(i))}$ 为第 $j$ 个基模型在样本 $i$ 所属的fold之外训练的预测器(避免数据泄漏)。

**Level-1 (元学习器):**
$$\hat{y} = g(\mathbf{z}), \quad \text{通常是简单模型 (如线性回归/逻辑回归)}$$

**加权平均 (简单融合):**
$$\hat{y} = \sum_{j=1}^{K} w_j f_j(\mathbf{x}), \quad \sum w_j = 1, w_j \geq 0$$

其中 $w_j$ 可通过验证集上优化或 CV 评分确定。

**选择多样性:** 基学习器应在结构上异构 — 树模型 + 核模型 + 线性模型 + 深度学习 — 确保错误不相关。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| K (基学习器数) | int | 5 | [2, 10] | 中 — 太多稀释 |
| n_folds | int | 5 | [3, 10] | 中 — 控制CV稳定性 |
| meta_learner | 模型 | 线性回归/逻辑回归 | — | 中 — 简单模型防过拟合 |
| 训练复杂度 | — | — | O(K·n·T_avg·n_folds) | — |

## MATLAB 实现

```matlab
% 手动 Stacking 框架 (自写)
function y_pred = stacking_predict(models, meta_model, X_train, y_train, X_test, n_folds)
    n_models = length(models);
    n_train = size(X_train, 1);
    
    % Level-0: 交叉验证生成 meta 特征
    Z_train = zeros(n_train, n_models);
    cv = cvpartition(n_train, 'KFold', n_folds);
    
    for j = 1:n_models
        for fold = 1:n_folds
            idx_train = training(cv, fold);
            idx_val = test(cv, fold);
            
            model_j_fold = train_model(models{j}, X_train(idx_train,:), y_train(idx_train));
            Z_train(idx_val, j) = predict(model_j_fold, X_train(idx_val,:));
        end
    end
    
    % Level-1: 训练元学习器
    meta_model_fit = train_model(meta_model, Z_train, y_train);
    
    % 用全部数据重训基模型 + 预测测试集
    Z_test = zeros(size(X_test,1), n_models);
    for j = 1:n_models
        model_j_full = train_model(models{j}, X_train, y_train);
        Z_test(:,j) = predict(model_j_full, X_test);
    end
    
    y_pred = predict(meta_model_fit, Z_test);
end
```

锚点: 自写-见S5:stacking.m

## Python 备选

```python
from sklearn.ensemble import StackingClassifier, StackingRegressor
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier

base_learners = [
    ('rf', RandomForestClassifier(n_estimators=100)),
    ('svm', SVC(probability=True)),
    ('knn', KNeighborsClassifier(n_neighbors=5))
]
stack = StackingClassifier(
    estimators=base_learners,
    final_estimator=LogisticRegression(),
    cv=5,
    stack_method='predict_proba'  # 使用概率输出
)
stack.fit(X_train, y_train)
```

## 选型决策树

- **Stacking** — 多个异构模型 (树+线性+核)，各模型各有优势，期望互补
- **加权平均** — 模型输出直接加权，更简单，需人工调权重或用 CV
- **Bagging (PARADIGM-0601-RF)** — 同质模型 (多棵树) 并行训练
- **Boosting (PARADIGM-0619-GBDT)** — 同质模型串行训练，关注残差
- **不用 Stacking** — 基模型高度相关 (如两个RF) → 几乎等价于单模型，无增益

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 各基模型预测值分布 | 展示多样性 |
| process | Stacking 结构图 (流程图) | Level-0→Level-1 |
| result | 各模型+Stacking 性能对比柱状图 | 展示增益 |

## 常见坑

1. **数据泄漏**: Level-0 预测在训练基模型的同批数据上 → 元学习器收到的是过拟合的信号 → 必须用 K-fold CV 分离
2. **过复杂元学习器**: 用复杂模型 (如GBDT/XGBoost) 做 Level-1 → 过度拟合 Level-0 的预测 → Level-1 用线性模型/简单逻辑回归即可
3. **同质基模型**: 多个同类型模型 (如 RF×3) → 预测高度相关，Stacking 无增益

## 失效条件/反例 (强制小节)

- **条件1: 基模型高度相关 (如 RF+ExtraTrees+GBDT 三个树模型)** → 表现: 三个树模型的预测 $\rho > 0.9$，Level-1 特征近乎共线，元学习器无法从三个几乎相同的输入中学到额外信息 — Stacking 性能 $\approx$ 单模型最佳。**应对**: 选择异构基模型 (线性+树+核+神经网络)，确保模型族不同
- **条件2: 样本量 n < 500** → 表现: K-fold CV 分割后 Level-0 每折训练样本少 → 基模型性能差 → Level-1 输入信号弱。且元学习器在 n 个 Level-1 样本上训练也易过拟合。**应对**: 小样本不用 Stacking，改用简单加权平均或贝叶斯模型平均 (BMA)

## 文献

1. Wolpert D.H. (1992). "Stacked generalization." *Neural Networks*, 5(2):241-259. DOI: [10.1016/S0893-6080(05)80023-1](https://doi.org/10.1016/S0893-6080(05)80023-1)
2. Breiman L. (1996). "Stacked regressions." *Machine Learning*, 24(1):49-64. DOI: [10.1007/BF00117832](https://doi.org/10.1007/BF00117832)

## 来源溯源

自写 stacking.m; 或 Python备选-见S5

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0601 (RF) |
| 前置 | PARADIGM-0605 (SVM) |
| 前置 | PARADIGM-0619 (GBDT) |
| 组合 (调参) | PARADIGM-1002 (EGO) |
