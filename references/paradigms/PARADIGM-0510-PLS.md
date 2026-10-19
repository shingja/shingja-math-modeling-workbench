# PARADIGM-0510 偏最小二乘PLS⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0510 |
| 类别/子类 | ⑤统计 / 偏最小二乘回归 |
| 难度 | 中 |
| 适用题型关键词[] | PLS, 偏最小二乘, 降维回归, 多变量预测, plsregress, Wold, 小样本多变量 |
| confidence | high |
| source | Wold (1966); 多元统计教材 |

## 数学形式

**目标:** 在 X 空间和 Y 空间中同时寻找潜在变量 (Latent Variables / Scores) 使协方差最大。

**PLS 迭代 (NIPALS 算法):**

**输入:** $\mathbf{X}_{n \times p}$, $\mathbf{Y}_{n \times q}$ (均已中心化)

对第 $a$ 个成分 ($a=1,\ldots,A$):

1. 随机初始化 $\mathbf{u} = \mathbf{Y}$ 的某列 (或 $\mathbf{u}=\mathbf{y}$ 对单输出)
2. 重复至收敛:
   - **X-权重:** $\mathbf{w} \propto \mathbf{X}^T\mathbf{u}$
   - **X-得分:** $\mathbf{t} = \mathbf{X}\mathbf{w}$, $\mathbf{t} \leftarrow \mathbf{t}/\|\mathbf{t}\|$
   - **Y-权重:** $\mathbf{c} \propto \mathbf{Y}^T\mathbf{t}$
   - **Y-得分:** $\mathbf{u} = \mathbf{Y}\mathbf{c}$
3. **X-载荷:** $\mathbf{p} = \mathbf{X}^T\mathbf{t}$
4. **缩减 (Deflation):** $\mathbf{X} \leftarrow \mathbf{X} - \mathbf{t}\mathbf{p}^T$, $\mathbf{Y} \leftarrow \mathbf{Y} - b\mathbf{t}\mathbf{c}^T$

**最终回归系数 (A 个成分):**
$$\hat{\mathbf{B}} = \mathbf{W}(\mathbf{P}^T\mathbf{W})^{-1}\mathbf{C}^T$$

其中 $\mathbf{W}=[\mathbf{w}_1,\ldots,\mathbf{w}_A]$, $\mathbf{P}=[\mathbf{p}_1,\ldots,\mathbf{p}_A]$, $\mathbf{C}=[\mathbf{c}_1,\ldots,\mathbf{c}_A]$。

**成分数 A 选择:** 交叉验证 (预测残差平方和 PRESS) 最小值或 $Q^2 > 0.097$ 的阈值。

**变量重要性投影 (VIP):**
$$\text{VIP}_j = \sqrt{p \cdot \frac{\sum_{a=1}^{A} w_{aj}^2 \cdot \text{SSY}_a}{\sum_{a=1}^{A} \text{SSY}_a}}$$

VIP > 1 → 重要变量。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| ncomp (成分数) | int | CV选择 | [1, min(n-1,p)] | 极高 — 过多过拟合 |
| cv (交叉验证) | int | 10 | [5, n] | 中 |
| 复杂度 | — | — | O(n·p·A·iter) | — |

## MATLAB 实现

```matlab
% Statistics and Machine Learning Toolbox
ncomp = 5;  % 或通过 CV 选择
[XL, YL, XS, YS, BETA, PCTVAR, MSE, stats] = plsregress(X, Y, ncomp);

% 回归系数
beta_pls = BETA(2:end, :);  % 第一行为截距

% 预测
Y_pred = [ones(n_test,1), X_test] * BETA;

% 选择成分数 via CV
ncomp_max = min(size(X,1)-1, size(X,2));
mse_cv = zeros(ncomp_max, 1);
for a = 1:ncomp_max
    [~,~,~,~,~,~,MSE] = plsregress(X, Y, a, 'CV', 10);
    mse_cv(a) = mean(MSE(2,2,:));  % 取最终 CV MSE
end
[~, best_ncomp] = min(mse_cv);
plot(1:ncomp_max, mse_cv, 'o-');

% VIP 计算
W0 = stats.W ./ sqrt(sum(stats.W.^2, 1));  % 归一化权重
SSY = sum((Y - mean(Y)).^2);  % Y 总平方和
SSY_each = stats.Yresiduals;  % 或手动计算各成分贡献
% VIP = sqrt(p * sum(W0.^2 .* SSY_each, 2) / sum(SSY_each));
```

锚点: `plsregress` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from sklearn.cross_decomposition import PLSRegression
pls = PLSRegression(n_components=5, scale=True)
pls.fit(X_train, Y_train)
Y_pred = pls.predict(X_test)
```

## 选型决策树

- **PLS** — p > n 或 p 很大且多重共线性 + 需预测 Y (多变量)
- **PCA + 回归 (PCR)** — 类似但 PCA 降维不利用 Y 信息 (可能丢弃与 Y 最相关的成分)
- **Ridge/Lasso (PARADIGM-0501 中)** — p < n 中等，直接正则化回归
- **CCA (PARADIGM-0507)** — 研究关联而非预测

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | CV PRESS vs ncomp | 选最佳成分数 |
| result | Y_pred vs Y_true (多元 subplot) | 各 Y 变量 |
| result | VIP 柱状图 + 1.0 阈值线 | 识别重要 X |

## 常见坑

1. **成分数过多 → 过拟合**: A 选太大 PLS 退化为 OLS → 几乎完美拟合训练集但预测差。必须用 CV 选 A
2. **X 和 Y 的预处理**: 需先中心化 (plsregress 默认做)；是否标准化需根据变量量纲决定
3. **PLS1 vs PLS2**: 多输出 Y 共享成分 (PLS2) vs 每输出独立成分 (PLS1) — 若 Y 变量不相关，PLS1 可能更优

## 失效条件/反例 (强制小节)

- **条件1: X 和 Y 之间无线性关系 (纯非线性)** → 表现: PLS 的前几个成分提取的协方差不显著，CV PRESS 在 A=1 就平坦无下降 → PLS 无预测能力。**应对**: 使用核 PLS (KPLS) 或回归前对 X 做非线性变换 (多项式/样条基扩展)
- **条件2: X 中噪声变量占绝大部分 (> 90% 为噪声)** → 表现: PLS 成分被噪声变量污染 (通过协方差最大化引入噪声)，VIP 将随机高值赋给噪声变量 → 模型在测试集上性能与随机猜测无差异。**应对**: 先用变量筛选 (PARADIGM-0905) 去除噪声变量，或使用稀疏 PLS (sPLS with L1 penalty)

## 文献

1. Wold H. (1966). "Estimation of principal components and related models by iterative least squares." In: *Multivariate Analysis*, Academic Press, 391-420.
2. Wold S., Sjostrom M. & Eriksson L. (2001). "PLS-regression: a basic tool of chemometrics." *Chemometrics and Intelligent Laboratory Systems*, 58(2):109-130.

## 来源溯源

MATLAB `plsregress`; 化学计量学/多元统计

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0507 (CCA) |
| 替代 | PARADIGM-0504 (PCA回归) |
| 组合 | PARADIGM-0905 (特征选择) |
