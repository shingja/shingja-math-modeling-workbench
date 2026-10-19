# PARADIGM-0206 XGBoost/LightGBM 梯度提升集成⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0206 |
| 类别/子类 | ②预测 / 梯度提升集成 |
| 难度 | 中 |
| 适用题型关键词[] | XGBoost, LightGBM, GBDT, 梯度提升, 决策树集成, 正则化提升, 特征重要性, Gradient Boosting, 结构化数据, 表格数据, Kaggle竞赛, 特征选择, SHAP |
| confidence | high |
| source | Chen & Guestrin (2016). "XGBoost: A Scalable Tree Boosting System." KDD 2016, pp. 785-794.; Ke et al. (2017). "LightGBM: A Highly Efficient Gradient Boosting Decision Tree." NeurIPS 2017. |

## 数学形式

### GBDT 通用框架 (加性模型)

给定数据 $\{(x_i, y_i)\}_{i=1}^n$，梯度提升树构建加性模型：

$$F_M(x) = \sum_{m=1}^M \eta \cdot h_m(x;\Theta_m)$$

其中 $h_m$ 为第 m 棵回归树，$\eta$ 为学习率 (shrinkage)，$M$ 为树的数量。

每步拟合残差梯度：

$$r_{im} = -\left[\frac{\partial L(y_i, F(x_i))}{\partial F(x_i)}\right]_{F=F_{m-1}}$$

$$h_m = \arg\min_h \sum_{i=1}^n (r_{im} - h(x_i))^2$$

### XGBoost 目标函数 (二阶泰勒展开 + 正则化)

$$\mathcal{L}^{(m)} = \sum_{i=1}^n \left[g_i f_m(x_i) + \frac{1}{2} h_i f_m^2(x_i)\right] + \gamma T + \frac{1}{2}\lambda \sum_{j=1}^T w_j^2$$

- $g_i = \partial_{\hat{y}^{(m-1)}} l(y_i, \hat{y}^{(m-1)})$ — 一阶梯度
- $h_i = \partial^2_{\hat{y}^{(m-1)}} l(y_i, \hat{y}^{(m-1)})$ — 二阶梯度 (Hessian)
- $\gamma T$ — 叶节点数惩罚
- $\lambda \|w\|^2$ — 叶权重 L2 正则化

叶节点最优权重 (闭式解)：

$$w_j^* = -\frac{\sum_{i \in I_j} g_i}{\sum_{i \in I_j} h_i + \lambda}$$

### LightGBM 核心技术

**GOSS (Gradient-based One-Side Sampling)**：保留大梯度样本 (训练不足的)，随机采样小梯度样本，减少数据量同时保持信息分布。

**EFB (Exclusive Feature Bundling)**：将互斥 (不同时非零) 特征捆绑，降低特征维度。基于图着色算法 (冲突率约束)。

**Leaf-wise 生长策略** (vs XGBoost Level-wise)：

```
Level-wise (XGBoost):           Leaf-wise (LightGBM):
       [ ]                          [ ]
     /     \                      /     \
   [ ]     [ ]                 [ ]     [*]  ← 选 loss 降低最大的叶分裂
  / \     / \                 / \     / \
 [ ] [ ] [ ] [ ]             [ ] [*] [ ] [ ]
 同步生长, 均匀             贪婪生长, 更快更深
```

### 正则化手段对比

| 正则化 | XGBoost | LightGBM |
|--------|---------|----------|
| L1 叶权重 (λ1) | alpha 参数 | lambda_l1 |
| L2 叶权重 (λ2) | lambda 参数 | lambda_l2 |
| 叶节点数惩罚 | gamma | min_gain_to_split |
| 最大深度 | max_depth | max_depth (leaf-wise 更敏感) |
| 最小叶样本 | min_child_weight | min_data_in_leaf |
| 列采样 | colsample_bytree/bylevel | feature_fraction |
| 行采样 | subsample | bagging_fraction |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_estimators (树数 M) | int | 100 | 50~1000+ | 高 — 与学习率联动, early_stopping 自动截断 |
| learning_rate (η) | double | 0.1 (XGB) / 0.1 (LGB) | 0.001~0.3 | 极高 — η小 → 需更多树; η大 → 过拟合风险 |
| max_depth | int | 6 (XGB) / -1 (LGB不限制) | 3~15 | 极高 — LGB leaf-wise 建议 5~8 防止过深 |
| subsample | double | 1.0 | 0.5~1.0 | 中 — 随机采样防过拟合, <1 引入随机性 |
| colsample_bytree | double | 1.0 | 0.3~1.0 | 中 — 特征采样增加树多样性 |
| reg_lambda (L2) | double | 1.0 (XGB) / 0.0 (LGB) | 0~10 | 中 — 大值使叶权重收缩 |
| reg_alpha (L1) | double | 0.0 | 0~10 | 低 — 高维稀疏特征时可引入稀疏性 |
| min_child_weight | double | 1 | 1~∞ | 中 — 大值防止过拟合, 小值允许更多分裂 |
| gamma / min_split_gain | double | 0 | 0~∞ | 高 — 控制分裂所需最小损失降低 |
| XGBoost 训练复杂度 | — | O(K·n·d·depth) | K=树数, d=特征数 | 近似线性, K 和 depth 为乘性因子 |
| LightGBM 训练复杂度 | — | O(K·n_bin·n_eff·depth) | n_bin=分箱数(≤255) | 直方图加速 + GOSS 下采样 |
| 预测复杂度 | — | O(K·depth) 每样本 | — | 极快, 树遍历 |
| 特征重要性类型 | — | weight/gain/cover/SHAP | — | gain 最常用; SHAP 最理论严谨 |

**量纲注意**：树模型完全不受特征量纲影响 (基于分裂点而非距离)，无需标准化。但**标签分布**影响 loss 计算: 回归建议确保标签在合理数值范围 (y缩放小范围可降低MSE数量级问题); 分类建议类别平衡处理 (scale_pos_weight/is_unbalance)。

## MATLAB 实现

```matlab
%% ===== XGBoost/LightGBM 在 MATLAB 中的路径 =====
% MATLAB 不原生支持 XGBoost/LightGBM (2024b 现状)
% 三种替代路线:

% 路线1: fitensemble (MATLAB内置, GBDT等价实现)
addpath('路径: 自写-见S5:xgboost_lgbm_bridge.py');
% 关键: 使用 LSBoost 方法 (Least-Squares Boosting)
ensModel = fitensemble(X, y, 'LSBoost', 300, 'Tree', ...
    'LearnRate', 0.1, ...
    'NumVariablesToSample', 'all', ...
    'KFold', 5);

% 预测
y_pred = predict(ensModel, X_test);

% 特征重要性
imp = predictorImportance(ensModel);
bar(imp);
xlabel('Feature Index'); ylabel('Importance');

% 路线2: Python 调用 (推荐生产)
% 使用 Python 环境调用 xgboost/lgbm, 数据通过 .mat 传递
% 详见: S5:xgboost_lgbm_bridge.py
% 核心思路: save('data.mat', 'X', 'y'); system('python bridge.py'); load('pred.mat');

% 路线3: 手动 Simple GBDT (教学用, 小数据)
% 自写-见S5:simple_gbdt.m — 理解原理, 不用于竞赛
```

**fitensemble 参数说明**：
- `'LSBoost'`：最小二乘提升，相当于 L2 loss 的 GBDT (MSE 回归)
- `'AdaBoostM2'`：分类任务的 AdaBoost 变体
- `'GentleBoost'`：二分类的 Gentle AdaBoost
- `TemplateTree('MaxNumSplits', max_depth)`：控制每棵树复杂度
- `'LearnRate'`：学习率 (shrinkage), 默认 0.1
- `'NumVariablesToSample'`：列采样，`'all'` 或整数

**fitensemble 局限性**：不支持二阶梯度、XGBoost 正则化项、LightGBM 的 GOSS/EFB、early_stopping、缺失值自动处理、GPU 加速。

## Python 备选

```python
# Python备选-见S5:xgboost_lgbm_bridge.py

# ===== XGBoost =====
import xgboost as xgb
from sklearn.model_selection import train_test_split, RandomizedSearchCV

X_train, X_valid, y_train, y_valid = train_test_split(X, y, test_size=0.2)

# DMatrix (XGBoost 原生高效格式)
dtrain = xgb.DMatrix(X_train, label=y_train, enable_categorical=True)
dvalid = xgb.DMatrix(X_valid, label=y_valid, enable_categorical=True)

params = {
    'objective': 'reg:squarederror',
    'eval_metric': 'rmse',
    'max_depth': 6,
    'learning_rate': 0.1,
    'subsample': 0.8,
    'colsample_bytree': 0.8,
    'reg_lambda': 1.0,
    'reg_alpha': 0.0,
    'min_child_weight': 1,
    'verbosity': 0
}

model = xgb.train(params, dtrain,
                  num_boost_round=1000,
                  evals=[(dtrain, 'train'), (dvalid, 'valid')],
                  early_stopping_rounds=50,
                  verbose_eval=False)

# ===== LightGBM =====
import lightgbm as lgb

lgb_train = lgb.Dataset(X_train, label=y_train,
                         categorical_feature=cat_cols)  # 原生类别支持!
lgb_valid = lgb.Dataset(X_valid, label=y_valid, reference=lgb_train)

params_lgb = {
    'objective': 'regression',
    'metric': 'rmse',
    'boosting_type': 'gbdt',
    'num_leaves': 31,         # 关键: 控制树复杂度 (<= 2^max_depth - 1)
    'learning_rate': 0.1,
    'feature_fraction': 0.8,
    'bagging_fraction': 0.8,
    'bagging_freq': 5,
    'lambda_l2': 0.0,        # L2 正则化
    'min_data_in_leaf': 20,
    'verbosity': -1
}

model_lgb = lgb.train(params_lgb, lgb_train,
                      num_boost_round=1000,
                      valid_sets=[lgb_train, lgb_valid],
                      callbacks=[lgb.early_stopping(50), lgb.log_evaluation(0)])

# ===== SHAP 模型解释 =====
import shap
explainer = shap.TreeExplainer(model_lgb)
shap_values = explainer.shap_values(X_valid)
shap.summary_plot(shap_values, X_valid)  # 全局特征重要性 + 方向
shap.dependence_plot("feature_name", shap_values, X_valid)  # 单特征效应
```

## 选型决策树

```
问题: 表格数据回归/分类
│
├── 样本量 n < 100？
│   └── 不建议 GBDT → 线性模型 (PARADIGM-0201/0202) 或 SVR (PARADIGM-0205)
│
├── 样本量 n = 100~10000？
│   ├── 需要可解释性？ → 线性模型 或 SVR (支持向量信息)
│   ├── 非线性关系 + 精度优先？ → XGBoost/LightGBM (本范式)
│   ├── 类别特征多？ → LightGBM (原生 categorical 支持)
│   └── 特征维度过高 (p > 10^4)？ → LightGBM (EFB 加速, 直方图 O(255·n))
│
└── 样本量 n > 10000？
    ├── 速度优先？ → LightGBM (leaf-wise + GOSS + EFB, 比 XGBoost 快 10~20x)
    ├── 精度优先 (足够时间调参)？ → XGBoost (level-wise 更保守, DART mode 防过拟合)
    ├── GPU 可用？ → 两者都支持GPU; XGBoost GPU 实现更成熟
    └── 分布式集群？ → LightGBM 分布式支持更好 (原生 parallel/voting)
```

**XGBoost vs LightGBM 选择速查**：

| 场景 | 推荐 | 原因 |
|------|------|------|
| 中小数据 (<10k), 高精度 | XGBoost | level-wise + 二阶 Hessian 正则化更稳健 |
| 大数据 (>10k), 速度要求 | LightGBM | leaf-wise 树更浅, GOSS+EFB 更快 |
| 高维稀疏特征 | LightGBM | 直方图算法天然处理稀疏, EFB 降维 |
| 类别特征多且基数高 | LightGBM | 原生 categorical, XGBoost 需 OneHot |
| 需要 SHAP 值解释 | 两者均可 | Tree SHAP 高效实现均可用 |
| 过度拟合问题严重 | XGBoost | DART (Dropouts meet Multiple Additive Regression Trees) 更保守 |
| 不平衡分类 | LightGBM | is_unbalance 参数 + scale_pos_weight |
| CatBoost 替代 | LightGBM | CatBoost 对类别特征最优但更慢; LGB 速度和类别处理平衡 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 模型诊断 | 训练/验证 Loss 曲线 (迭代 vs RMSE/LogLoss) | early_stopping 截断点可视化 |
| 模型解释 | 特征重要性 水平柱状图 (gain/weight/cover) | Top 20 特征直观排序 |
| 模型解释 | SHAP Summary Plot (蜂群图) | 全局特征方向 + 量值分布 |
| 模型解释 | SHAP Dependence Plot | 单特征边际效应 + 交互色 |
| 模型诊断 | 预测值 vs 真实值 散点图 | y=x 对角线 + R^2, RMSE 标注 |
| 调优报告 | 超参数敏感度线图 | 单参数变化 vs CV score |
| 模型对比 | 多模型柱状图 (RMSE/MAE/R^2) | XGBoost vs LGB vs rf vs 线性 横向比较 |

## 常见坑

1. **未使用 early_stopping**：树数设 1000 却不设验证集和 early_stopping，导致严重过拟合或浪费时间。**必须设** eval_set + early_stopping_rounds=30~100。
2. **LightGBM leaf-wise 不设 max_depth/num_leaves**：默认 num_leaves=31 (约 max_depth=5)，大数据默认可能过深。建议 max_depth ≤ 10，num_leaves ≤ 2^max_depth。
3. **类别特征未标记 categorical_feature**：(仅 LightGBM) 未标记则当作数值处理，Loss 明显偏高。XGBoost 需手动 OneHot + enable_categorical=True (1.6+)。
4. **学习率与树数不匹配**：η=0.01 但只设 n_estimators=100 → 欠拟合。粗则: η=0.1→200树, η=0.01→1000树, η=0.001→5000树。
5. **过度依赖默认参数**：GBDT 性能高度依赖调参。至少调: max_depth, learning_rate, subsample, colsample_bytree, reg_lambda (数据噪声大时加大)。
6. **缺失值处理不一致**：XGBoost 自动学习缺失值分裂方向 (sparse aware)，LightGBM 默认禁用 (use_missing=true 但零填充)。建议手动处理缺失值以保证一致性。
7. **重复编码 OHE + 类别原生处理**：LightGBM 标记 categorical 后继续做 OneHot → 特征膨胀，失去 sparse 优化效果。

## 失效条件/反例 (强制小节)

- **条件1: 样本量 n < 100** → GBDT 单棵树无法获得足够分裂信息。树深度被迫限制 (<3)，模型退化为几乎常数预测。此时逻辑回归/线性回归/Ridge 不仅更稳定，且可解释性远超树的特征重要性 (小样本树的重要性方差极大)。实测: n=50 时 CV 的 R^2 标准差可达 0.3~0.5，不可靠。

- **条件2: 标签含严重高噪声 (信噪比 SNR < 0.5)** → GBDT 的逐树残差拟合机制会逐步将噪声编码入模型。即使在验证集上 early_stopping 截断，被树结构离散化的噪声仍远高于线性模型对噪声的"平均化"。此时需退回到 Ridge/Lasso (PARADIGM-0202) 或大幅增大 min_child_weight/min_data_in_leaf 降低树复杂度，本质近似线性拟合。

- **条件3: 特征中存在"完美信息泄露"特征 (如 ID、时间戳、排序索引)** → 树模型对强信号极度敏感，几乎必然在第一棵树就用该特征分裂，造成看似良好但完全虚假的 CV 分数 (ID 泄露导致 LB shake)。必须事前特征工程中移除泄露特征；GBDT 不会自动识别泄露 (与线性模型不同, 树不惩罚大系数)。

- **条件4: 数据分布随时间漂移 (Covariate Shift) 且未做域适应** → GBDT 完全依赖训练集分布学习分裂点，当测试集输入分布漂移时树分裂完全失效 (不同于距离/核方法有局部语义)。LightGBM 的 leaf-wise 增长会放大此问题 (分裂更深更依赖局部统计)。此场景需时间序列交叉验证 (TimeSeriesSplit) 或在线学习框架。

- **条件5: 类别特征基数极高 (>10000 类别) + XGBoost** → XGBoost 的 OneHot 编码会将特征维度膨胀到万级以上，每棵树遍历全部特征的开销急剧上升。LightGBM 通过 histogram-based + 原生 categorical 高效处理 (仅 O(#bin) 而非 O(#category))。若必须 XGBoost，需先做 Target Encoding 或 Frequency Encoding 降维。

## 文献

1. Chen, T., & Guestrin, C. (2016). XGBoost: A Scalable Tree Boosting System. *KDD 2016*, pp. 785-794. (XGBoost 原始论文, 引用 15000+)
2. Ke, G., Meng, Q., Finley, T., et al. (2017). LightGBM: A Highly Efficient Gradient Boosting Decision Tree. *NeurIPS 2017*, pp. 3146-3154. (LightGBM 原始论文)
3. Friedman, J. H. (2001). Greedy function approximation: A gradient boosting machine. *Annals of Statistics*, 29(5), 1189-1232. (GBM 理论奠基)
4. Prokhorenkova, L., Gusev, G., Vorobev, A., et al. (2018). CatBoost: unbiased boosting with categorical features. *NeurIPS 2018*. (CatBoost 对比参考)
5. Lundberg, S. M., & Lee, S. I. (2017). A unified approach to interpreting model predictions. *NeurIPS 2017*, pp. 4765-4774. (SHAP 理论, Tree SHAP 算法)
6. MATLAB Documentation: fitensemble — https://www.mathworks.com/help/stats/fitensemble.html

## 来源溯源

- **理论根源**: Friedman (2001) GBM 函数空间梯度下降; Mason et al. (1999) Functional Gradient Descent
- **XGBoost 创新**: 二阶泰勒展开 (Hessian 提供曲率信息) + 显式正则化项 + 列块法 (Column Block, 缓存感知并行) + 稀疏感知分裂
- **LightGBM 创新**: GOSS 梯度采样 (保大信息样本) + EFB 互斥特征绑定 (降维不损信息) + Leaf-wise 贪婪生长 (更快收敛) + 直方图算法 (连续值分箱 255 bins)
- **Kaggle 生态**: 2015-2020 年间 GBDT 家族包揽绝大多数表格数据竞赛前 3 名。现状: XGBoost/LightGBM + CatBoost 三足鼎立, 集成/Stacking 常态搭配 NN/Linear。
- **树分解损失角**: 区别于神经网络的"所有参数联合优化"，树模型的逐树加性使其天然支持特征选择、缺失值处理、单调性约束。

## 关联范式卡

| 关系 | ID |
|------|-----|
| 同为机器学习回归, 小样本首选 | PARADIGM-0205 (SVR) |
| 同为机器学习回归, 概率输出 | PARADIGM-0204 (GP回归 fitrgp) |
| 经典统计回归基线 | PARADIGM-0201 (多元线性回归 fitlm) |
| 正则化线性回归对比 | PARADIGM-0202 (Ridge/Lasso/ElasticNet) |
| 随机森林对比 (Bagging vs Boosting) | PARADIGM-0208 (随机森林) |
| 模型解释 (SHAP 配合) | PARADIGM-0306 (Permutation Importance / SHAP) |
| 超参调优通用方法 | PARADIGM-0401 (贝叶斯优化) |
| 深度学习对比 | PARADIGM-0210 (MLP/全连接网络) |
