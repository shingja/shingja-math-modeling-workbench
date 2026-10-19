# PARADIGM-0605 支持向量机SVM⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0605 |
| 类别/子类 | ⑥机器学习 / 核方法 |
| 难度 | 中 |
| 适用题型关键词[] | SVM, 支持向量机, SMO, 核方法, 最大间隔, 软间隔, 非线性分类, fitcsvm |
| confidence | high |
| source | Cortes & Vapnik (1995) Machine Learning |

## 数学形式

**硬间隔 (线性可分):**
$$\min_{\mathbf{w}, b} \frac{1}{2}\|\mathbf{w}\|^2 \quad \text{s.t.} \quad y_i(\mathbf{w}^T\mathbf{x}_i + b) \geq 1, \forall i$$

**软间隔 (线性不可分, C-SVM):**
$$\min_{\mathbf{w}, b, \xi} \frac{1}{2}\|\mathbf{w}\|^2 + C\sum_{i=1}^{n}\xi_i$$
$$\text{s.t.} \quad y_i(\mathbf{w}^T\mathbf{x}_i + b) \geq 1 - \xi_i, \quad \xi_i \geq 0$$

**对偶问题 (引入 Lagrange 乘子 $\alpha_i$):**
$$\max_{\alpha} \sum_{i=1}^{n}\alpha_i - \frac{1}{2}\sum_{i,j}\alpha_i\alpha_j y_i y_j \langle\mathbf{x}_i, \mathbf{x}_j\rangle$$
$$\text{s.t.} \quad 0 \leq \alpha_i \leq C, \quad \sum_i \alpha_i y_i = 0$$

**核技巧 (Kernel Trick):**
$$\langle\mathbf{x}_i, \mathbf{x}_j\rangle \to K(\mathbf{x}_i, \mathbf{x}_j)$$

常用核: RBF $K(x,z) = e^{-\gamma\|x-z\|^2}$; 多项式 $K(x,z) = (x^T z + c)^d$

**参数敏感度:**
- $C$: 大→硬间隔 (少容忍误分类)，小→软间隔
- $\gamma$ (RBF): 大→复杂边界 (易过拟合)，小→平滑边界

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| BoxConstraint (C) | double | 1 | (0, ∞) | 极高 — 决定 margin vs error 权衡 |
| KernelScale (γ) | double | 1/sqrt(p) | (0, ∞) | 极高 — RBF 弯曲度 |
| KernelFunction | str | 'rbf' | 'linear','rbf','polynomial' | 高 — 决定能否线性可分 |
| 训练复杂度 (SMO) | — | — | O(n²) ~ O(n³) | — |
| 支持向量数 | — | — | 0 ~ n | 决定了预测速度 |

## MATLAB 实现

```matlab
% 二分类 SVM
svm = fitcsvm(X, Y, ...
    'KernelFunction', 'rbf', ...
    'BoxConstraint', 1, ...
    'KernelScale', 'auto', ...
    'Standardize', true, ...
    'CrossVal', 'on', ...
    'KFold', 5);

% 预测
y_pred = predict(svm.Trained{1}, X_test);
[~, scores] = predict(svm.Trained{1}, X_test);

% 超参数优化
svm_opt = fitcsvm(X, Y, ...
    'OptimizeHyperparameters', 'auto', ...
    'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName', 'expected-improvement-plus'));

% 多分类: fitcecoc (Error-Correcting Output Codes)
multi_svm = fitcecoc(X, Y, 'Learners', templateSVM('KernelFunction','rbf'));
```

锚点: `fitcsvm` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.svm import SVC, SVR
svm = SVC(kernel='rbf', C=1.0, gamma='scale', probability=True)
svm.fit(X_train, y_train)
y_pred = svm.predict(X_test)
y_proba = svm.predict_proba(X_test)
```

## 选型决策树

- **SVM** — 小样本 (n < 1000)，高维特征 (p > n)，非线性分类
- **逻辑回归 (PARADIGM-0609)** — 需要概率输出 + 解释性，线性决策边界足够
- **随机森林 (PARADIGM-0601)** — n > 10000，特征交互复杂，需要特征重要性
- **核 SVM vs 神经网络**: 小样本用 SVM，大样本+GPU 用 NN

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 二维散点图 (类别着色) | 展示线性可分性 |
| result | 决策边界等高线 + 支持向量标记 | 间隔区域着色 |
| result | ROC 曲线 | 含 AUC 和 95% CI |

## 常见坑

1. **未标准化特征**: RBF 核依赖欧氏距离，量纲差异导致某些特征主导距离 → 必须 `Standardize=true`
2. **C 和 γ 协同调参**: 网格搜索 C=[0.1,10], γ=[0.001,1] 在 log 尺度上，不要单独调一个
3. **n > 10000 训练慢**: SMO O(n²) 在大样本下不实用 → 改用线性 SVM (liblinear) 或 Nyström 近似

## 失效条件/反例 (强制小节)

- **条件1: 样本量极大 (n > 10^5)** → 表现: 核矩阵 O(n²) 内存不足以存储，SMO 训练 O(n²)~O(n³) 时间不可接受。**应对**: 使用线性 SVM (复杂度 O(n·p)) 或随机 Fourier 特征近似 RBF 核 (Random Kitchen Sinks)，或换用 GBDT/神经网络
- **条件2: 强噪声+大量离群点** → 表现: 即使调大 C，离群支持向量仍支配决策边界 — SVM 对离群点敏感 (hinge loss 无界)。**应对**: 先执行离群点检测 (Isolation Forest / PARADIGM-0603) 剔除离群点，或使用 Robust SVM 变种 (Ramp loss)

## 文献

1. Cortes C. & Vapnik V. (1995). "Support-vector networks." *Machine Learning*, 20(3):273-297. DOI: [10.1007/BF00994018](https://doi.org/10.1007/BF00994018)
2. Scholkopf B. & Smola A.J. (2002). *Learning with Kernels*. MIT Press. ISBN: 978-0262194754
3. Platt J. (1998). "Sequential minimal optimization: A fast algorithm for training support vector machines." Microsoft Research Technical Report MSR-TR-98-14.

## 来源溯源

MATLAB `fitcsvm`; 培训模块 ML

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0604 (决策树) |
| 替代 | PARADIGM-0609 (逻辑回归) |
| 组合 (降维) | PARADIGM-0504 (PCA) |
| 组合 (SVR回归) | PARADIGM-0205 (SVR) |
