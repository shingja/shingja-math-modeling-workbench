# PARADIGM-0602 AdaBoost (自适应提升)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0602 |
| 类别/子类 | ⑥机器学习 / 集成学习 |
| 难度 | 中 |
| 适用题型关键词[] | AdaBoost, 自适应提升, 弱学习器, 样本权重, 指数损失, 集成学习, 二分类, 自适应加权 |
| confidence | high |
| source | Freund & Schapire (1997) Journal of Computer and System Sciences; 培训模块 ML-ensemble |

## 数学形式

**AdaBoost (Adaptive Boosting) 算法框架**

**初始化**:
$$w_i^{(1)} = \frac{1}{n}, \quad i = 1, 2, \ldots, n$$

**对 $m = 1, 2, \ldots, M$ (迭代训练 M 个弱学习器)**:

**(1) 训练弱分类器**: 在权重分布 $w^{(m)}$ 下训练弱分类器 $G_m(\mathbf{x})$:
$$G_m = \arg\min_{G} \sum_{i=1}^{n} w_i^{(m)} \cdot \mathbf{1}\{G(\mathbf{x}_i) \neq y_i\}$$

**(2) 计算加权错误率**:
$$\epsilon_m = \frac{\sum_{i=1}^{n} w_i^{(m)} \mathbf{1}\{G_m(\mathbf{x}_i) \neq y_i\}}{\sum_{i=1}^{n} w_i^{(m)}}$$

若 $\epsilon_m > 0.5$，终止迭代 (弱学习器比随机猜测还差)。

**(3) 计算分类器权重**:
$$\alpha_m = \frac{1}{2} \ln\left(\frac{1 - \epsilon_m}{\epsilon_m}\right)$$

$\epsilon_m$ 越小 → $\alpha_m$ 越大 (准确的分类器获得更大投票权)。

**(4) 更新样本权重**:
$$w_i^{(m+1)} = w_i^{(m)} \cdot \exp\left(-\alpha_m \cdot y_i \cdot G_m(\mathbf{x}_i)\right)$$

- 分类正确 $(y_i \cdot G_m = +1)$: 权重乘以 $e^{-\alpha_m} < 1$ (降低)
- 分类错误 $(y_i \cdot G_m = -1)$: 权重乘以 $e^{+\alpha_m} > 1$ (升高)

**(5) 归一化权重**: $w_i^{(m+1)} = \frac{w_i^{(m+1)}}{\sum_{j} w_j^{(m+1)}}$

**最终强分类器**:
$$G(\mathbf{x}) = \text{sign}\left(\sum_{m=1}^{M} \alpha_m G_m(\mathbf{x})\right)$$

**与指数损失的关系** (Friedman et al., 2000):
$$\mathcal{L}_{\text{exp}} = \sum_{i=1}^{n} \exp\left(-y_i \sum_{m=1}^{M} \alpha_m G_m(\mathbf{x}_i)\right)$$

AdaBoost 等价于前向分步加法模型 (Forward Stagewise Additive Modeling) 以指数损失为目标函数的梯度下降。

**泛化误差上界** (Freund & Schapire, 1997):
$$\hat{P}(\text{error}) \leq \prod_{m=1}^{M} \left[2 \sqrt{\epsilon_m (1 - \epsilon_m)}\right] = \prod_{m=1}^{M} \sqrt{1 - 4\gamma_m^2}$$

其中 $\gamma_m = 0.5 - \epsilon_m$ 为弱学习器的"优势" (edge)。只要 $\gamma_m > 0$，训练误差随 M 指数衰减至 0。

**多分类扩展 (AdaBoost.M2)**:
使用伪损失 (pseudo-loss) 替代 0-1 误差，弱学习器输出每个类别的置信度:
$$\bar{\epsilon}_m = \frac{1}{2} \sum_{i=1}^{n} w_i^{(m)} \left(1 - G_m(\mathbf{x}_i, y_i) + \max_{y \neq y_i} G_m(\mathbf{x}_i, y)\right)$$

**回归扩展 (AdaBoost.R2 / LSBoost)**:
LSBoost 使用平方损失，每次迭代拟合残差:
$$r_i = y_i - F_{m-1}(\mathbf{x}_i)$$
$$F_m(\mathbf{x}) = F_{m-1}(\mathbf{x}) + \nu \cdot h_m(\mathbf{x})$$

其中 $h_m$ 为基学习器对残差的拟合，$\nu \in (0, 1]$ 为学习率 (shrinkage)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| M (n_learners) | int | 100 | [1, 1000] | 高 — 过小欠拟合，过大过拟合 (尤其在噪声数据上) |
| learn_rate ($\nu$) | float | 0.1 | (0, 1] | 极高 — 小学习率需要更多迭代次数，但泛化更好 |
| 弱学习器类型 | string | 'Tree' | 'Tree', 'Discriminant' | 中 — 树桩 (max_splits=1) 最标准 |
| max_splits (树深度) | int | 1 (树桩) | [1, n-1] | 高 — 深度 1 为经典 AdaBoost; 更深可捕捉交互 |
| method | string | 'AdaBoostM2' (分类) | 'AdaBoostM1', 'AdaBoostM2', 'LSBoost', 'RUSBoost' | — |
| p (特征数) | int | — | [1, ∞) | 中 — 高维稀疏时树桩效率下降 |

| 输出 | 量纲 |
|------|------|
| predictions | 与 y 同量纲 (类别标签或实数值) |
| scores | (0, 1) 置信度得分 (分类) |
| resubLoss | 训练集误分类率 |
| kfoldLoss | K 折交叉验证误分类率 |
| compact(Mdl) | 压缩模型 (去除训练数据) |

**计算复杂度**: $O(M \cdot T_{\text{base}})$，其中 $T_{\text{base}}$ 为基学习器训练时间。树桩的 $T_{\text{base}} = O(n \cdot p)$。不可并行 (序列依赖)。

## MATLAB 实现

**函数签名** (Statistics and Machine Learning Toolbox):

```matlab
% ===== 分类 (AdaBoostM2) =====
rng(42);

% 建立 AdaBoost 集成
Mdl = fitensemble(X, Y, 'AdaBoostM2', 100, 'Tree', ...
    'LearnRate', 0.1, ...
    'NPrint', 'Regression', ...
    'Options', statset('UseParallel', false));  % AdaBoost 不可并行

% 预测
y_pred = predict(Mdl, X_test);
[~, scores] = predict(Mdl, X_test);  % 获取分类置信度

% 交叉验证
cvm = crossval(Mdl, 'KFold', 5);
cv_err = kfoldLoss(cvm);

% 查看弱学习器权重
alpha = Mdl.TrainedWeights;  % 各轮迭代的学习器权重

% 查看训练误差随迭代变化
figure;
plot(resubLoss(Mdl, 'Mode', 'Cumulative'));
xlabel('Number of Learners'); ylabel('Resubstitution Error');

% ===== 回归 (LSBoost) =====
Mdl_reg = fitensemble(X, Y, 'LSBoost', 100, 'Tree', ...
    'LearnRate', 0.1);

% ===== 处理不平衡数据 (RUSBoost) =====
Mdl_rus = fitensemble(X, Y, 'RUSBoost', 100, 'Tree', ...
    'LearnRate', 0.1, ...
    'RatioToSmallest', [1 1]);  % 每类采样相同数量
```

**锚点工具箱函数**: `fitensemble` (Method='AdaBoostM2' 分类, 'LSBoost' 回归, 'RUSBoost' 不平衡分类). 基学习器: `templateTree`.

**关键参数说明**:
- `'AdaBoostM2'`: 多分类 AdaBoost，使用伪损失框架，支持任意类别数
- `'AdaBoostM1'`: 原始 AdaBoost，仅支持二分类且要求弱学习器加权误差 < 0.5
- `'LSBoost'`: 最小二乘提升 (Least-Squares Boosting)，适用于回归，使用残差拟合
- `'RUSBoost'`: 随机欠采样提升 (Random Undersampling Boosting)，处理不平衡数据
- `LearnRate`: 收缩参数，0.01-0.1 为常用范围；越小需要越多树但泛化更好
- `templateTree('MaxNumSplits', 1)`: 创建树桩模板 (单次分裂)

## Python 备选

```python
from sklearn.ensemble import AdaBoostClassifier, AdaBoostRegressor
from sklearn.tree import DecisionTreeClassifier

# 分类 (SAMME.R — 概率输出，效果通常优于 SAMME)
ada = AdaBoostClassifier(
    estimator=DecisionTreeClassifier(max_depth=1),  # 树桩
    n_estimators=100,
    learning_rate=0.1,
    algorithm='SAMME.R',  # 或 'SAMME' (离散AdaBoost)
    random_state=42
)
ada.fit(X_train, y_train)
y_pred = ada.predict(X_test)
y_proba = ada.predict_proba(X_test)

# 回归
ada_reg = AdaBoostRegressor(
    estimator=DecisionTreeRegressor(max_depth=3),
    n_estimators=100,
    learning_rate=0.1,
    loss='linear',  # 'linear', 'square', 'exponential'
    random_state=42
)
ada_reg.fit(X_train, y_train)

# 查看学习器权重
print(ada.estimator_weights_[:10])

# 查看各轮训练误差
import matplotlib.pyplot as plt
plt.plot(ada.staged_score(X_train, y_train))
plt.xlabel('n_estimators'); plt.ylabel('Accuracy');
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 二分类问题，追求高准确率 | AdaBoost | 指数损失对边界样本给予最强关注 |
| 数据标注质量高 (低噪声) | AdaBoost | 噪声极少时 AdaBoost 泛化性能卓越 |
| 需要快速训练，基学习器简单 (树桩) | AdaBoost + 树桩 | 树桩训练极快，100轮仅需数秒 |
| 多分类问题 | AdaBoost.M2 (SAMME) | M2/SAMME 支持多类，使用伪损失/概率 |
| 回归问题 | LSBoost | 平方损失梯度提升，连续目标变量拟合残差 |
| 数据含明显标签噪声 | 谨慎 / 不用 | 指数损失对误标样本权重指数增长，严重过拟合噪声 |
| 高维稀疏数据 (文本/基因) | XGBoost/线性模型 | 树桩无法捕捉稀疏特征中的信号 |
| 类别严重不平衡 | RUSBoost 或 SMOTEBoost | RUSBoost 在每轮随机欠采样多数类 |
| 需要概率校准输出 | SAMME.R (sklearn) | SAMME.R 输出经过良好校准的概率 |
| 需要特征重要性 | 随机森林 (PARADIGM-0601) | AdaBoost 的特征重要性不如 RF 稳定 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 类别分布饼图 | 检查类别平衡情况 |
| process | 训练/验证误差 vs 迭代次数 | 判断最佳 M (early stopping 点) |
| process | 学习器权重 $\alpha_m$ vs m | 早期学习器权重最高，后期递减趋近于 0 |
| process | 样本权重分布随时间变化 | 展示困难样本权重的累积过程 |
| result | ROC 曲线 + AUC | 分类任务标准评价 |
| result | 决策边界 (二维投影) | 展示 AdaBoost 的非线性决策边界 |
| result | 混淆矩阵 | 特别关注少数类的查全率 |

## 常见坑

1. **标签噪声灾难**: AdaBoost 指数损失对误标样本极为敏感 — 一个标签错误的 outlier 会在多轮迭代中获得指数级增长的权重，导致后续所有弱学习器都去拟合这一噪声点，严重损害泛化。实践中先做标签清洗或使用对数损失 (LogitBoost)。
2. **弱学习器过弱**: 若树桩加权误差 $\epsilon_m \approx 0.5$ (几乎随机)，则 $\alpha_m \approx 0$——该轮不贡献信息，且后续权重更新无意义。需确保弱学习器至少有 edge $\gamma_m = 0.5 - \epsilon_m > 0.01$。
3. **学习率与迭代次数的折中**: learn_rate=1.0 时 M=10 可能过拟合；learn_rate=0.01 时需 M=1000+。小学习率 + 大 M 泛化更好但训练慢 100 倍。
4. **非凸损失导致局部最优**: 指数损失在整个函数空间上是凸的 (Buhlmann & Yu, 2003)，但固定基学习器结构时 (如树桩) 可能陷入非最优加法展开。
5. **不可并行**: 与 Bagging/随机森林不同，AdaBoost 严格序列依赖，无法利用多核加速训练。
6. **特征尺度不敏感但缺失值敏感**: 树桩对单调变换不敏感，但缺失值会导致分裂不可靠 → 预处理缺失值。

## 失效条件/反例 (强制小节)

- **条件1: 标签噪声率 > 10% (误标注样本比例高)** → **表现**: AdaBoost 指数损失函数在 $y_i G(\mathbf{x}_i) < 0$ (分类错误) 时梯度为 $-y_i e^{-y_i F}$，绝对值随置信度 $|F|$ 指数增长。一个被误标的样本在多轮迭代后，若模型已正确"分类"它 (实际标签错误)，其权重反而指数爆炸，迫使后续学习器强行拟合此噪声点。训练误差收敛至 0，但测试误差随 M 继续增加而恶化。**应对**: (1) 使用 LogitBoost (对数损失) 或 GentleBoost，对噪声更鲁棒; (2) 设置较小的 M (early stopping) 和更小的 learn_rate; (3) AdaBoost.R2 中设置 `'RobustOpts','on'` 使用 Huber 损失替代二次损失。

- **条件2: 弱学习器 $\epsilon_m \approx 0.5$ (几乎无判别能力)** → **表现**: 当 $\epsilon_m \to 0.5$ 时，$\alpha_m = 0.5 \ln((1-\epsilon_m)/\epsilon_m) \to 0$，该轮集成无贡献。若后续轮次 $\epsilon_m$ 持续维持 0.5 附近，所有 $\alpha_m \approx 0$，最终强分类器退化为随机猜测。在高维稀疏数据 (如 TF-IDF 文本表示) 上，树桩 (单次分裂) 几乎无法找到有效特征界限，edge $\gamma_m \to 0$。**应对**: (1) 增加树桩深度 (max_splits=2-5) 捕捉特征交互; (2) 换用随机森林或 XGBoost/LightGBM; (3) 对高维数据先用 PCA/特征选择降维。

- **条件3: 训练数据极端不平衡且使用标准 AdaBoost.M2** → **表现**: 多数类样本量占绝对优势，初始权重平均分配后多数类权重总和远大于少数类。弱学习器通过忽略少数类即可获得加权误差 < 0.5，集成最终偏向多数类。少数类的分类准确率可能为 0。**应对**: 使用 `'RUSBoost'` (fitensemble) 在每轮随机欠采样多数类，或使用代价敏感 AdaBoost (对不同类的误分类设置不同代价权重)。

## 文献

1. Freund Y, Schapire RE (1997). "A decision-theoretic generalization of on-line learning and an application to boosting." *Journal of Computer and System Sciences*, 55(1):119-139. DOI: [10.1006/jcss.1997.1504](https://doi.org/10.1006/jcss.1997.1504)
2. Friedman J, Hastie T, Tibshirani R (2000). "Additive logistic regression: A statistical view of boosting." *The Annals of Statistics*, 28(2):337-407. DOI: [10.1214/aos/1016218223](https://doi.org/10.1214/aos/1016218223)
3. Hastie T, Tibshirani R, Friedman J (2009). *The Elements of Statistical Learning*, 2nd ed. Springer. Chapter 10. ISBN: 978-0387848570
4. Schapire RE, Freund Y (2012). *Boosting: Foundations and Algorithms.* MIT Press. ISBN: 978-0262526031

## 来源溯源

Freund & Schapire (1997) JCSS 55(1); 培训模块 ML-ensemble (集成学习).

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0601 (随机森林, Bagging 策略, 可并行训练, 更鲁棒) |
| 替代 | PARADIGM-0618 (CNN, 网格数据深度学习, 图像/序列场景) |
| 组合 | PARADIGM-0504 (PCA, 降维后训练以增强弱学习器判别能力) |
| 前置 | PARADIGM-0501 (数据预处理, 缺失值处理对 AdaBoost 至关重要) |
