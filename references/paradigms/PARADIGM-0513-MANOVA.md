# PARADIGM-0513 多元方差分析MANOVA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0513 |
| 类别/子类 | ⑤统计 / 多元假设检验 |
| 难度 | 中 |
| 适用题型关键词[] | MANOVA, 多元方差分析, 多因变量, Wilks' Lambda, Pillai, Hotelling, 组间差异 |
| confidence | high |
| source | Johnson & Wichern (2007) Pearson |

## 数学形式

**模型 (单因素 MANOVA):**
$$\mathbf{Y}_{ij} = \boldsymbol{\mu} + \boldsymbol{\tau}_i + \boldsymbol{\varepsilon}_{ij}, \quad i=1,\ldots,g \text{ (组)}, j=1,\ldots,n_i$$

其中 $\mathbf{Y}_{ij} \in \mathbb{R}^p$ (p 个因变量)。

**假设:**
$$H_0: \boldsymbol{\tau}_1 = \boldsymbol{\tau}_2 = \cdots = \boldsymbol{\tau}_g = \mathbf{0}$$
$$H_1: \text{至少一个 } \boldsymbol{\tau}_i \neq \mathbf{0}$$

**SSCP 矩阵分解:**
$$\mathbf{T} = \mathbf{B} + \mathbf{W}$$

- **总 (Total):** $\mathbf{T} = \sum_{i,j} (\mathbf{Y}_{ij} - \bar{\mathbf{Y}})(\mathbf{Y}_{ij} - \bar{\mathbf{Y}})^T$
- **组间 (Between):** $\mathbf{B} = \sum_i n_i (\bar{\mathbf{Y}}_i - \bar{\mathbf{Y}})(\bar{\mathbf{Y}}_i - \bar{\mathbf{Y}})^T$
- **组内 (Within):** $\mathbf{W} = \sum_{i,j} (\mathbf{Y}_{ij} - \bar{\mathbf{Y}}_i)(\mathbf{Y}_{ij} - \bar{\mathbf{Y}}_i)^T$

**四种检验统计量 (基于 $\mathbf{W}^{-1}\mathbf{B}$ 的特征值 $\lambda_k$):**

1. **Wilks' Lambda (最常用):**
   $$\Lambda = \frac{|\mathbf{W}|}{|\mathbf{B} + \mathbf{W}|} = \prod_k \frac{1}{1+\lambda_k}$$

2. **Pillai's Trace (最鲁棒):**
   $$V = \text{tr}(\mathbf{B}(\mathbf{B}+\mathbf{W})^{-1}) = \sum_k \frac{\lambda_k}{1+\lambda_k}$$

3. **Hotelling-Lawley Trace:**
   $$T = \text{tr}(\mathbf{W}^{-1}\mathbf{B}) = \sum_k \lambda_k$$

4. **Roy's Maximum Root:**
   $$\theta = \frac{\lambda_1}{1+\lambda_1}$$

**MANOVA 假设:**
- 多元正态性: $\boldsymbol{\varepsilon}_{ij} \sim \mathcal{N}_p(\mathbf{0}, \mathbf{\Sigma})$
- 方差-协方差矩阵同质性: $\mathbf{\Sigma}_1 = \cdots = \mathbf{\Sigma}_g$
- 观测独立

**Post-hoc:** 若 MANOVA 显著 → 做单变量 ANOVA (每个因变量) + 多重比较校正 (Bonferroni)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| g (组数) | int | — | [2, 10] | 高 |
| p (因变量数) | int | — | [2, 20] | 高 — p>n 时不可用 |
| n_i (每组样本) | int | — | ≥ p | 高 |
| alpha | double | 0.05 | (0, 0.2) | 低 |

## MATLAB 实现

```matlab
% Statistics and Machine Learning Toolbox
% manova1 (单因素)
[d, p_val, stats] = manova1(Y, group);
% Y: n×p 矩阵 (多因变量)
% group: 分组变量 (n×1)

% 查看各检验统计量
disp(stats);

% 若显著 → 单变量 follow-up
for j = 1:p
    [p_j, tbl] = anova1(Y(:,j), group, 'off');
    fprintf('变量 %d: p = %.4f\n', j, p_j);
end

% 自写 Wilks' Lambda (备选)
function [Lambda, F_approx, p_val] = manova_wilks(Y, group)
    groups = unique(group);
    g = length(groups);
    [n, p] = size(Y);
    
    % 总均值
    grand_mean = mean(Y);
    
    % SSCP 分解
    T = (Y - grand_mean)' * (Y - grand_mean);  % Total
    W = zeros(p, p);  % Within
    B = zeros(p, p);  % Between
    for i = 1:g
        idx = (group == groups(i));
        Y_i = Y(idx, :);
        n_i = sum(idx);
        mean_i = mean(Y_i);
        W = W + (Y_i - mean_i)' * (Y_i - mean_i);
        B = B + n_i * (mean_i - grand_mean)' * (mean_i - grand_mean);
    end
    
    % Wilks' Lambda
    Lambda = det(W) / det(T);
    % F 近似 (Bartlett)
    % ...
end
```

锚点: `manova1` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
from statsmodels.multivariate.manova import MANOVA
manova = MANOVA(endog=Y, exog=group)
print(manova.mv_test())
```

## 选型决策树

- **MANOVA** — 多因变量 (相关) + 分类自变量 + 检验组间差异
- **ANOVA × p (单变量逐个)** — 因变量独立时可接受，相关时第一类错误膨胀
- **ANCOVA** — 加入连续协变量控制
- **PERMANOVA** — 非参数 (不依赖正态假设)，用距离矩阵 (如 Bray-Curtis)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 各组 2D 散点图 (前两因变量) + 置信椭圆 | 可视化分离 |
| result | 各检验统计量条形对比图 | Wilks/Pillai/Hotelling |
| result | 单变量 follow-up ANOVA p 值图 | Bonferroni 线 |

## 常见坑

1. **Box's M 检验拒绝 (协方差齐性违例)**: 各组 $\Sigma_i$ 不等 → Wilks' Lambda 的 Type I error 膨胀。改用 Pillai's Trace (对此假设违例最鲁棒)
2. **p 个因变量高度相关 → 冗余**: 增加 p 不增加 MANOVA 的区分力 (信息已包含在第一个变量中)
3. **n_i < p**: 组内样本数小于因变量数 → W 奇异 → MANOVA 不可用。先做 PCA 降维

## 失效条件/反例 (强制小节)

- **条件1: $n_i < p$ 对某些组 (组内样本少于因变量数)** → 表现: 组内 SSCP 矩阵 $\mathbf{W}$ 奇异 → Wilks' Lambda = 0/0 未定义 → MANOVA 不可计算。**应对**: 合并小样本组，或先用 PCA 降维至 $p < \min(n_i)$，或使用正则化判别分析 (RDA)
- **条件2: 严重违反正态性 + 小样本 (离群点)** → 表现: 非正态分布下 Wilks' Lambda 的 F 近似不准确 → p 值失真 (过于乐观或保守)。**应对**: 使用 PERMANOVA (基于距离矩阵的非参数检验，adonis) 或使用稳健 MANOVA (基于 MCD 估计)

## 文献

1. Johnson R.A. & Wichern D.W. (2007). *Applied Multivariate Statistical Analysis*, 6th ed. Pearson. ISBN: 978-0131877153
2. Tabachnick B.G. & Fidell L.S. (2019). *Using Multivariate Statistics*, 7th ed. Pearson. Chapter 7. ISBN: 978-0134790541

## 来源溯源

MATLAB `manova1`; 多元统计教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0509 (t检验/ANOVA) |
| 前置 | PARADIGM-0503 (分布检验) |
| 组合 | PARADIGM-0901 (判别分析) |
