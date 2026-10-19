# PARADIGM-0616 CatBoost有序Boosting⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0616 |
| 类别/子类 | ⑥机器学习 / 梯度提升 |
| 难度 | 中 |
| 适用题型关键词[] | CatBoost, 有序boosting, 类别特征, 梯度提升, 排序提升, 无偏估计, Ordered TS |
| confidence | medium |
| source | Prokhorenkova et al. (2018) NeurIPS |

## 数学形式

**Ordered Boosting 核心思想:**
传统 GBDT 对所有样本用同一个模型计算梯度 → 梯度估计有偏 (用到了标签信息) → 过拟合。

CatBoost 使用 Ordered Boosting: 对每个样本 $i$，只用前 $i-1$ 个样本训练的模型计算梯度:

$$g_i = \frac{\partial L(y_i, F_{i-1}(x_i))}{\partial F_{i-1}(x_i)}$$

其中 $F_{i-1}$ 仅用样本 1,...,i-1 训练。

**Ordered Target Statistics (类别特征编码):**
$$\hat{x}_k^i = \frac{\sum_{j=1}^{p} [x_{j,k}=x_{i,k}] \cdot y_j + a \cdot p}{\sum_{j=1}^{p} [x_{j,k}=x_{i,k}] + a}$$

其中 $p$ 为先验 (全局均值), $a$ 为平滑参数。使用排序原则避免数据泄漏。

**对称树 (Symmetric Tree):**
所有同层节点使用相同分裂规则 → 推理极快 (CPU 向量化)。

**变量表:**
- Ordered Boosting → 降低梯度偏差
- Ordered TS → 无偏编码高基数类别特征
- Symmetric Tree → 平衡树，不剪枝

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| iterations | int | 1000 | [100, 5000] | 中 |
| learning_rate | double | 0.03 | [0.001, 0.5] | 高 — 与其他模型一致 |
| depth | int | 6 | [3, 12] | 中 — 对称树较浅 |
| l2_leaf_reg | double | 3.0 | [1, 10] | 中 |
| 训练复杂度 | — | — | O(n·p·depth·iter) | — |

## MATLAB 实现

```matlab
% MATLAB 无官方 CatBoost 实现
% 替代方案: 使用 fitensemble 加 LSBoost 做梯度提升
% 或通过 Python 互操作调用 CatBoost

% === Python 备选 (推荐) ===
% py.catboost.CatBoostRegressor/CatBoostClassifier
```

锚点: Python备选-见S5

## Python 备选

```python
from catboost import CatBoostClassifier, CatBoostRegressor, Pool

# 分类
model = CatBoostClassifier(
    iterations=1000,
    learning_rate=0.03,
    depth=6,
    l2_leaf_reg=3.0,
    cat_features=categorical_indices,  # 直接指定类别特征
    random_seed=42,
    verbose=100
)
model.fit(X_train, y_train, eval_set=(X_val, y_val),
          early_stopping_rounds=50)

# 特征重要性
importances = model.get_feature_importance()
```

## 选型决策树

- **CatBoost** — 大量类别特征 (>10个)，高基数 (cardinality > 100)，需要即开即用的默认参数
- **XGBoost (PARADIGM-0206)** — 数值特征为主，可精细控制正则化
- **LightGBM** — 超大样本 (n > 10^6)，GOSS 采样加速
- **GBDT (PARADIGM-0619)** — 标准梯度提升基线
- **Trade-off:** CatBoost 对类别特征开箱即用，调参量小，但训练稍慢于 LightGBM

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | 训练/验证 Loss 随迭代下降 | early stopping 点 |
| result | 特征重要性 SHAP summary plot | 全局+局部解释 |
| result | SHAP dependence plot | 关键特征边际效应 |

## 常见坑

1. **类别特征编码**: 不要预先 One-Hot 编码 (会丢失 Ordered TS 优势) → 直接传 `cat_features` 索引
2. **GPU vs CPU**: CatBoost 的 GPU 训练优势在大数据 (>10^5) 上方显现，小数据 CPU 反而快
3. **Ordered Boosting 开销**: 比普通 GBDT 多 ~50% 训练时间 — 若类别特征少可尝试 `boosting_type='Plain'`

## 失效条件/反例 (强制小节)

- **条件1: 纯数值特征 + 无类别特征** → 表现: CatBoost 的 Ordered TS 和 Ordered Boosting 机制无增益，训练反而比 LightGBM/XGBoost 慢 30-50%。**应对**: 纯数值问题时优先用 LightGBM (速度) 或 XGBoost (精细控制)
- **条件2: 样本量 n < 1000** → 表现: Ordered Boosting 基于排序的划分在极小样本下数据量不足，梯度方差大，性能不如简单正则化的 GBDT 或 RF。**应对**: n < 1000 时使用随机森林或带强正则的 XGBoost

## 文献

1. Prokhorenkova L., Gusev G., Vorobev A., Dorogush A.V. & Gulin A. (2018). "CatBoost: unbiased boosting with categorical features." *NeurIPS 2018*. arXiv: [1706.09516](https://arxiv.org/abs/1706.09516)
2. Dorogush A.V., Ershov V. & Gulin A. (2018). "CatBoost: gradient boosting with categorical features support." arXiv: [1810.11363](https://arxiv.org/abs/1810.11363)

## 来源溯源

Python备选-见S5; CatBoost 官方文档

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0206 (XGBoost/LightGBM) |
| 替代 | PARADIGM-0619 (GBDT) |
| 替代 | PARADIGM-0601 (RF) |
