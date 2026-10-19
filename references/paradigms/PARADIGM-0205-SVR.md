# PARADIGM-0205 SVR支持向量回归⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0205 |
| 类别/子类 | ②预测 / 机器学习回归 |
| 难度 | 中 |
| 适用题型关键词[] | SVR, 支持向量回归, epsilon-insensitive, 核函数, RBF, 不敏感带, 结构风险最小化, Support Vector Regression, 小样本预测, 非线性回归, 管道回归 |
| confidence | medium |
| source | Smola & Scholkopf (2004). "A tutorial on support vector regression." Statistics and Computing, 14(3), 199-222. |

## 数学形式

### 原始问题 (Primal)

给定训练数据 $\{(x_i, y_i)\}_{i=1}^{n},\ x_i \in \mathbb{R}^p,\ y_i \in \mathbb{R}$，SVR 求解：

$$\min_{w,b,\xi,\xi^*} \frac{1}{2}\|w\|^2 + C\sum_{i=1}^{n}(\xi_i + \xi_i^*)$$

$$\text{s.t.} \begin{cases} y_i - (w \cdot \phi(x_i) + b) \leq \varepsilon + \xi_i \\ (w \cdot \phi(x_i) + b) - y_i \leq \varepsilon + \xi_i^* \\ \xi_i, \xi_i^* \geq 0 \end{cases}$$

其中 $\phi(\cdot)$ 为特征映射，$\varepsilon$ 为不敏感带宽，$C$ 为惩罚参数。

### 对偶问题 (Dual)

$$\max_{\alpha,\alpha^*} -\frac{1}{2}\sum_{i,j}(\alpha_i-\alpha_i^*)(\alpha_j-\alpha_j^*)K(x_i,x_j) - \varepsilon\sum_i(\alpha_i+\alpha_i^*) + \sum_i y_i(\alpha_i-\alpha_i^*)$$

$$\text{s.t.} \sum_i (\alpha_i - \alpha_i^*) = 0,\quad 0 \leq \alpha_i,\alpha_i^* \leq C$$

回归函数：$f(x) = \sum_{i=1}^{n} (\alpha_i - \alpha_i^*)K(x_i, x) + b$

### 常用核函数

| 核函数 | 表达式 $K(x_i,x_j)$ | 适用场景 |
|--------|---------------------|---------|
| Linear | $x_i^T x_j$ | 高维稀疏, $p \gg n$ |
| RBF (默认) | $\exp(-\gamma\|x_i-x_j\|^2)$ | 通用非线性 |
| Polynomial | $(\gamma x_i^T x_j + r)^d$ | 显式多项式关系 |
| Sigmoid | $\tanh(\gamma x_i^T x_j + r)$ | 类神经网络, 不建议首用 |

### 损失函数 (Epsilon-Insensitive Loss)

$$L_\varepsilon(y, f(x)) = \max(0, |y - f(x)| - \varepsilon)$$

只有残差超过 $\varepsilon$ 的样本才产生损失，形成"管道"效应 — 管道内样本不参与模型构建（稀疏解）。

### 结构风险最小化 vs 经验风险最小化

SVR 最小化结构风险 $R[f] = \frac{1}{2}\|w\|^2 + C \cdot R_{emp}[f]$，第一项控制模型复杂度（防止过拟合），第二项为经验误差。这区别于传统回归 (OLS, 神经网络) 的经验风险最小化。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| C (BoxConstraint) | double | 1.0 (自动: iqr(y)/1.349) | (0, ∞) | 极高 — 控制过拟合-欠拟合平衡 |
| ε (Epsilon) | double | 自动: iqr(y)/13.49 | (0, ∞) | 高 — 过大欠拟合, 过小支持向量过多 |
| KernelFunction | string | 'rbf' | 'linear'/'rbf'/'polynomial'/'gaussian' | 极高 — 决定模型假设空间 |
| KernelScale (γ for RBF) | double | 自动: 1/p (默认) | (0, ∞) | 高 — γ小→平滑, γ大→复杂/过拟合 |
| PolynomialOrder | int | 3 | 2~5 | 中 — 仅 polynomial 核生效 |
| Standardize | bool | true | true/false | 中 — 建议始终标准化 |
| Solver | string | 'SMO' | 'SMO'/'ISDA'/'L1QP' | 低 — SMO 为默认高效选择 |
| 训练复杂度 | — | O(n^2) ~ O(n^3) | — | n>10000 不可行 (见失效条件) |
| 预测复杂度 | — | O(n_{SV} \cdot p) | — | 支持向量数 × 特征维数 |

**量纲注意**：SVR 对特征量纲敏感（核距离计算），Standardize=true 必须开启。输出保持原始量纲，无需反变换。

## MATLAB 实现

```matlab
%% ===== SVR 完整建模 =====
% 数据准备
X = data(:, 1:end-1);  % 特征矩阵 n×p
y = data(:, end);       % 目标列

% 标准化 (fitrsvm 内置, 但建议手动做以复盘)
[X_scaled, mu, sigma] = zscore(X);
[y_scaled, mu_y, sigma_y] = zscore(y);  % 可选: y标准化后还原

% 训练 SVR 模型
% 关键: 使用 fitrsvm (Statistics and Machine Learning Toolbox)
svrModel = fitrsvm(X, y, ...
    'KernelFunction', 'rbf', ...       % 核函数
    'BoxConstraint', 1.0, ...          % C 惩罚参数
    'Epsilon', iqr(y)/13.49, ...       % ε 不敏感带宽 (经验默认)
    'KernelScale', 'auto', ...         % γ 自动选择
    'Standardize', true, ...           % 内部标准化
    'Verbose', 0);

% 预测
y_pred = predict(svrModel, X_test);

% 模型评估
residuals = y_test - y_pred;
RMSE = sqrt(mean(residuals.^2));
MAE = mean(abs(residuals));
R2 = 1 - sum(residuals.^2) / sum((y_test - mean(y_test)).^2);

% 超参数调优 (Bayesian Optimization)
svrOpt = fitrsvm(X, y, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName', 'expected-improvement-plus', ...
           'MaxObjectiveEvaluations', 30, ...
           'ShowPlots', false));

% 查看最优参数
best_C = svrOpt.BoxConstraint;
best_Eps = svrOpt.Epsilon;
best_KS = svrOpt.KernelScale;

% 提取支持向量信息
alpha = svrModel.Alpha;        % (α_i - α_i*) 对偶系数
sv_idx = svrModel.SupportVectors;  % 支持向量在原空间的索引
bias = svrModel.Bias;          % 截距 b

fprintf('支持向量数: %d / %d (%.1f%%)\n', ...
    length(alpha), n, 100*length(alpha)/n);
```

## Python 备选

```python
# Python备选-见S5:svr_tune.py
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import GridSearchCV, cross_val_score
from sklearn.pipeline import Pipeline

pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('svr', SVR(kernel='rbf'))
])

param_grid = {
    'svr__C': [0.1, 1, 10, 100],
    'svr__epsilon': [0.01, 0.05, 0.1, 0.2],
    'svr__gamma': ['scale', 'auto', 0.01, 0.1, 1]
}

grid = GridSearchCV(pipe, param_grid, cv=5, scoring='neg_mean_squared_error', n_jobs=-1)
grid.fit(X_train, y_train)
best_model = grid.best_estimator_
```

## 选型决策树

```
问题: 回归预测
│
├── n < 100？ → 不建议任何ML方法, 考虑简单回归或机理模型
│
├── n = 100~10000？
│   ├── p >> n (高维)？ → 线性核 SVR 或 Lasso/Ridge
│   ├── 已知线性关系？ → 线性核 SVR (优于OLS, 因结构风险最小化)
│   ├── 非线性关系？ → RBF核 SVR (本范式)
│   ├── 需要稀疏解/支持向量信息？ → SVR ✓ (只有SVR提供支持向量)
│   └── 需要概率输出/置信区间？ → GP回归 (fitrgp), SVR不原生支持
│
└── n > 10000？
    └── 考虑 XGBoost/LightGBM (PARADIGM-0206) 或 神经网络, SVR不可行
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 数据探索 | 散点图 (y vs 各特征) | 初步判断非线性程度 |
| 模型诊断 | 预测值 vs 真实值 散点图 | y=x 对角线参考, R^2 标识 |
| 模型诊断 | 残差 vs 预测值 散点图 | 零线附近随机分布 = 良好 |
| 模型诊断 | 残差 QQ-Plot | 正态性检查 (SVR不假设正态, 但残差对称性有意义) |
| 超参调优 | C-ε 等高线热力图 | 二维网格搜索可视化 |
| 解释 | 支持向量标记图 (选2D投影) | 管道边界 ±ε, 支持向量高亮 |

## 常见坑

1. **未标准化**：RBF核依赖欧氏距离，量纲差异导致某些特征主导核计算。必须 Standardize=true。
2. **C 和 ε 同时调大/调小**：C 大→过拟合 (管道窄, 支持向量多)，ε 大→欠拟合 (管道宽, 支持向量少)。二者需联合搜索。
3. **SVR 不支持概率输出**：与 GP 回归不同，SVR 无原生预测方差。需要置信区间→改用 fitrgp (PARADIGM-0204)。
4. **核函数滥用 RBF**：p >> n 时线性核效果更好且更快；先试 linear，不够再换 rbf。
5. **SMO 求解器对 C 极大时收敛慢**：C > 1e6 时 SMO 可能迭代很多步，考虑先用 log-scale 网格搜索小范围 C。
6. **支持向量比例过高 (>80%)**：暗示 ε 太小或噪声大，模型几乎用到了全部训练点，丧失了稀疏性优势。

## 失效条件/反例 (强制小节)

- **条件1: 样本量 n > 10000** → SVR 求解的二次规划问题 (对偶空间 n×n Gram 矩阵) 时间复杂度 O(n^2) ~ O(n^3)，内存需求 O(n^2)。超过一万样本时训练时间从分钟级暴涨到小时/天级，且内存溢出风险高。此场景应改用 XGBoost/LightGBM (PARADIGM-0206) 或 Mini-batch 神经网络。实测: n=5000 时 RBF SVR 约 10s~1min；n=50000 可达数小时。

- **条件2: 多输出回归 (MIMO)** → SVR 是单输出模型，对每个输出维度需独立训练一个 SVR，无法捕捉输出维度间的相关性 (如多个传感器的联合分布、多维时间序列的协方差结构)。应改用 Multi-output GP (fitrgp) 或 神经网络多输出层。

- **条件3: 特征维度极高 p >> n 且 RBF 核** → 此时线性核已足够 (高维空间天然线性可分概率高)，RBF 核不仅引入过拟合风险 (模型复杂度 >> 样本信息量)，还失去线性核的系数可解释性 (w 可表示各特征重要性)。先试 linear SVR + L1/L2 正则化交叉检验，RBF 仅当线性模型交叉验证 R^2 < 0.5 时考虑。

- **条件4: 标签含严重离群点且标准差 >> 均值** → ε 管道的对称性使其对离群点敏感 (离群点必然落于管道外产生 ξ 损失)。C 过大时离群点主导 w 方向；C 过小时模型过于平滑而忽略真实趋势。此场景应先用 robust 预处理 (winsorize/remove outliers) 或用 ε-insensitive 的 robust 变体 (Huber-SVR)。

## 文献

1. Smola, A. J., & Scholkopf, B. (2004). A tutorial on support vector regression. *Statistics and Computing*, 14(3), 199-222. (核心参考文献)
2. Vapnik, V. (1998). *Statistical Learning Theory*. Wiley. (SVM/SVR 理论基础)
3. Cherkassky, V., & Ma, Y. (2004). Practical selection of SVM parameters and noise estimation for regression. *Neural Networks*, 17(1), 113-126. (C 和 ε 经验默认值来源)
4. Drucker, H., et al. (1997). Support vector regression machines. *NeurIPS 1997*. (SVR 首次提出)
5. MATLAB Documentation: fitrsvm — https://www.mathworks.com/help/stats/fitrsvm.html

## 来源溯源

- **理论根源**: Vapnik-Chervonenkis 统计学习理论 (VC维, 结构风险最小化原则)
- **算法核心**: Boser-Guyon-Vapnik (1992) 核技巧引入 SVM → Drucker et al. (1997) 推广到回归 → Smola-Scholkopf (2004) 系统化教程
- **ν-SVR 变体**: Scholkopf et al. (2000) 引入 ν 参数自动控制 ε 和 C 的比例 (ν ∈ (0,1] 代替 ε)，但 MATLAB fitrsvm 不原生支持 ν-SVR，需自写或 Python sklearn.svm.NuSVR
- **LS-SVM 变体**: Suykens-Vandewalle (1999) 最小二乘 SVM，将不等式约束改为等式约束，求解线性方程组而非 QP，速度快但稀疏性丧失

## 关联范式卡

| 关系 | ID |
|------|-----|
| 同为机器学习回归, 输出概率 | PARADIGM-0204 (GP回归 fitrgp) |
| 大样本替代方案 | PARADIGM-0206 (XGBoost/LightGBM) |
| 经典统计回归基线 | PARADIGM-0201 (多元线性回归 fitlm) |
| 正则化线性回归对比 | PARADIGM-0202 (Ridge/Lasso/ElasticNet) |
| 模型解释工具 | PARADIGM-0306 (Permutation Importance) |
| 核方法同源 | PARADIGM-0301 (SVM分类 fitcsvm) |
| 超参调优通用方法 | PARADIGM-0401 (贝叶斯优化) |
