# PARADIGM-0509 假设检验t检验+ANOVA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0509 |
| 类别/子类 | ⑤统计与数据分析 / 假设检验 |
| 难度 | 低 |
| 适用题型关键词[] | t检验, ANOVA, 假设检验, p值, 显著性, F检验, 多重比较, 方差分析 |
| confidence | high |
| source | matlab/stats/anova_oneway.m |

## 数学形式

### 单样本 t 检验
检验 $H_0: \mu = \mu_0$：
$$t = \frac{\bar{x} - \mu_0}{s / \sqrt{n}} \sim t(n-1)$$

### 双样本 t 检验（等方差假设）
检验 $H_0: \mu_1 = \mu_2$：
$$t = \frac{\bar{x}_1 - \bar{x}_2}{s_p \sqrt{\frac{1}{n_1} + \frac{1}{n_2}}}$$
其中合并标准差：
$$s_p^2 = \frac{(n_1 - 1)s_1^2 + (n_2 - 1)s_2^2}{n_1 + n_2 - 2}$$
自由度 $df = n_1 + n_2 - 2$。

### Welch t 检验（不等方差）
$$t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}$$
自由度（Satterthwaite 近似）：
$$df = \frac{\left(\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}\right)^2}{\frac{(s_1^2/n_1)^2}{n_1-1} + \frac{(s_2^2/n_2)^2}{n_2-1}}$$

### 单因素方差分析 (One-Way ANOVA)
检验 $H_0: \mu_1 = \mu_2 = \cdots = \mu_k$：

总平方和分解：$SS_T = SS_B + SS_W$

组间平方和：
$$SS_B = \sum_{i=1}^{k} n_i (\bar{x}_i - \bar{x})^2$$

组内平方和：
$$SS_W = \sum_{i=1}^{k} \sum_{j=1}^{n_i} (x_{ij} - \bar{x}_i)^2$$

F 统计量：
$$F = \frac{MS_B}{MS_W} = \frac{SS_B / (k-1)}{SS_W / (N-k)} \sim F(k-1, N-k)$$

### 多重比较（Post-Hoc）

Tukey HSD（Honestly Significant Difference）：
$$HSD = q_{\alpha}(k, N-k) \cdot \sqrt{\frac{MS_W}{n}}$$

其中 $q_{\alpha}$ 为学生化极差分布的上 $\alpha$ 分位点。

Bonferroni 校正：
$$\alpha_{\text{adj}} = \frac{\alpha}{m}, \quad m = \binom{k}{2}$$

### 效应量
Cohen's $d$（两样本）：
$$d = \frac{\bar{x}_1 - \bar{x}_2}{s_p}$$

$\eta^2$（ANOVA）：
$$\eta^2 = \frac{SS_B}{SS_T}$$

**变量表**：
| 符号 | 含义 |
|------|------|
| $\bar{x}$ | 样本均值 |
| $s$ | 样本标准差 |
| $n$ | 样本量 |
| $k$ | 组数 |
| $N$ | 总样本量 $\sum n_i$ |
| $SS_B$ | 组间平方和 |
| $SS_W$ | 组内平方和 |
| $MS_B$ | 组间均方 |
| $MS_W$ | 组内均方 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| `x`, `y` (ttest2) | double vector | — | 连续数据 | 中（正态性影响小样本） |
| `data` (anova1) | double vector | — | 连续数据 | 中 |
| `groups` (anova1) | categorical / cell | — | $k \geq 2$ 组 | — |
| `alpha` | double | 0.05 | $(0, 1)$ | **极高**（直接决定显著性结论） |
| `Vartype` (ttest2) | string | `'unequal'` (Welch) | equal / unequal | 中（不等方差假设更安全） |
| `CType` (multcompare) | string | `'tukey-kramer'` | tukey-kramer / bonferroni / lsd / dunn-sidak | 中（影响假阳性率） |

**时间复杂度**：$O(N)$（t 检验），$O(N + k^2)$（ANOVA + post-hoc）
**空间复杂度**：$O(N)$

## MATLAB 实现

函数签名：
```matlab
% t-test
[h, p, ci, stats] = ttest(x, mu0);                      % one-sample
[h, p, ci, stats] = ttest2(x, y, 'Vartype', 'unequal');  % two-sample Welch
[h, p, ci, stats] = ttest(x1, x2);                        % paired

% One-Way ANOVA
[p, tbl, stats] = anova1(data, groups);

% Multiple comparison (post-hoc)
[c, m, h, nms] = multcompare(stats, 'CType', 'tukey-kramer', 'Alpha', 0.05);
```

锚点工具箱函数：`ttest`, `ttest2`, `anova1`, `multcompare` (Statistics and Machine Learning Toolbox)

实现位置：`matlab/stats/anova_oneway.m`

```matlab
function [p, tbl, stats, c] = anova_oneway(data, groups, varargin)
    % ANOVA oneway wrapper with post-hoc and diagnostics
    % data: N×1 response vector
    % groups: N×1 categorical/string grouping variable
    % Returns: p (F-test p-value), tbl (ANOVA table),
    %          stats (for multcompare), c (Tukey comparison matrix)
    
    p = inputParser;
    addParameter(p, 'Alpha', 0.05);
    addParameter(p, 'CType', 'tukey-kramer');
    parse(p, varargin{:});
    
    % One-way ANOVA
    [p, tbl, stats] = anova1(data, groups, 'off');  % 'off' suppresses figure
    
    % Effect size (eta-squared)
    SS_between = tbl{2,2};
    SS_total = tbl{4,2};
    eta_sq = SS_between / SS_total;
    fprintf('η² = %.4f\n', eta_sq);
    
    % Post-hoc multiple comparisons
    [c, ~, ~, ~] = multcompare(stats, 'CType', p.Results.CType, ...
                                'Alpha', p.Results.Alpha, 'Display', 'off');
end
```

**配对 t 检验**：
```matlab
[h, p, ci, stats] = ttest(before, after);  % paired comparison
```

**非参数备选**：
```matlab
p_ranksum = ranksum(x, y);           % Mann-Whitney U (Wilcoxon rank-sum)
p_signrank = signrank(before, after); % Wilcoxon signed-rank (paired)
p_kruskal = kruskalwallis(data, groups); % Kruskal-Wallis (替代 ANOVA)
```

## Python 备选

```python
import numpy as np
from scipy import stats
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import statsmodels.api as sm
from statsmodels.formula.api import ols

# One-sample t-test
t_stat, p_val = stats.ttest_1samp(x, mu0)

# Two-sample t-test (Welch by default)
t_stat, p_val = stats.ttest_ind(x, y, equal_var=False)

# Paired t-test
t_stat, p_val = stats.ttest_rel(before, after)

# One-way ANOVA
f_stat, p_val = stats.f_oneway(*[data[groups==g] for g in np.unique(groups)])

# Effect size (eta-squared)
# Via OLS
model = ols('data ~ C(groups)', data=df).fit()
aov_table = sm.stats.anova_lm(model, typ=2)
eta_sq = aov_table['sum_sq'][0] / aov_table['sum_sq'].sum()
print(f'η² = {eta_sq:.4f}')

# Post-hoc Tukey HSD
tukey = pairwise_tukeyhsd(data, groups, alpha=0.05)
print(tukey)

# Non-parametric alternatives
stat_man, p_man = stats.mannwhitneyu(x, y, alternative='two-sided')
stat_ks, p_ks = stats.kruskal(*[data[groups==g] for g in np.unique(groups)])
stat_wsr, p_wsr = stats.wilcoxon(before, after)  # paired non-parametric

# Cohen's d (effect size)
d = (np.mean(x) - np.mean(y)) / np.sqrt(((len(x)-1)*np.var(x, ddof=1) +
      (len(y)-1)*np.var(y, ddof=1)) / (len(x)+len(y)-2))
```

## 选型决策树

```
比较几组的均值？
├── 2 组
│   ├── 独立样本
│   │   ├── 数据正态？ → t-test (Welch 优先，不假设等方差)
│   │   └── 数据非正态/有序 → Mann-Whitney U
│   └── 配对样本 → paired t-test / Wilcoxon signed-rank
├── 3+ 组
│   ├── 单因素 → One-Way ANOVA
│   │   ├── 正态 + 方差齐？ → ANOVA + Tukey HSD
│   │   ├── 方差不齐？ → Welch ANOVA + Games-Howell
│   │   └── 非正态？ → Kruskal-Wallis + Dunn's test
│   ├── 两因素 → Two-Way ANOVA（主效应 + 交互）
│   └── 重复测量 → Repeated Measures ANOVA / Mixed-effects
└── 多重比较校正
    ├── 探索性 (all pairs) → Tukey HSD
    ├── 少数对比 → Bonferroni (保守)
    └── 与对照组比较 → Dunnett
```

**替代算法对比**：
| 算法 | 适用场景 | 与 t/ANOVA 区别 |
|------|----------|----------------|
| Mann-Whitney U | 有序/非正态数据 | 基于秩，检验分布位置而非均值 |
| Kruskal-Wallis | 多组非正态 | 秩方差分析，不假设正态 |
| Welch ANOVA | 方差不齐 | 不假设等方差，同样检验均值 |
| Mixed-effects | 重复测量/嵌套 | 建模随机效应，处理非独立数据 |
| Bootstrap t-test | 分布未知 | 不依赖渐近分布，计算密集 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 分组箱线图 + 散点叠加 (boxplot + swarm) | 展示分布、中位数、离群值，每个数据点可见 |
| raw | 分组小提琴图 (violin plot) | 展示分布密度形状，适合大样本 |
| process | QQ-plot (qqplot) | 检验正态性假设，偏离对角线 = 非正态 |
| process | 残差 vs 拟合值图 (residual vs fitted) | 检验方差齐性；漏斗形 = 异方差 |
| process | 均值柱状图 + 误差棒 (SE 或 95% CI) | 直观比较组均值，标注显著性字母 (a, b, c) |
| result | Tukey 多重比较图 (multcompare 输出) | 各组均值差 + 置信区间，区间不含 0 = 显著 |
| result | 效应量森林图 | Cohen's d 或 $\eta^2$，标注 small/medium/large 阈值 |

## 常见坑

1. **多重 t 检验未校正**：$m$ 次独立 t 检验 (各 $\alpha = 0.05$) → 族系错误率 $1 - (1-\alpha)^m$；$m=10$ 时 $\approx 40\%$ 的假阳性概率 → 用 ANOVA + post-hoc 替代多次 t 检验，或多重比较校正 (Bonferroni / Holm / BH)
2. **p < 0.05 不等于实际重要性**：大样本下微小差异也可显著 → 始终报告效应量：Cohen's $d$ (两样本: 0.2 小, 0.5 中, 0.8 大)，$\eta^2$ (ANOVA: 0.01 小, 0.06 中, 0.14 大)
3. **正态性检验的检验**：Shapiro-Wilk 在小样本 (< 30) 功效低，大样本 (> 300) 对微小偏离也拒绝 → t 检验/ANOVA 对中等偏离 (偏度<2, 峰度<4) 相对稳健；$n>30$ 时 CLT 生效
4. **不等方差 + 不等样本量**：标准 t/ANOVA 膨胀第I类错误率（实际 $\alpha > 0.05$）→ 默认使用 Welch 校正；ANOVA 可用 `vartestn` (Levene / Bartlett) 预检
5. **伪重复 (pseudoreplication)**：把重复测量当独立样本 → 自由度膨胀，p 值偏小 → 重复测量用 paired / repeated measures / mixed-effects
6. **p-hacking**：事后选择检验、排除异常值、变换数据直至 p<0.05 → 预注册分析计划或用 Bonferroni 将 $\alpha$ 调至 0.01

## 失效条件/反例 (强制小节)

- **条件1：比例/计数数据用 t 检验** → **表现**：比例数据方差依赖于均值 ($\text{Var}(p) = p(1-p)/n$)，违反方差齐性假设；低期望计数时 t 分布近似差，p 值不准 → 使用卡方检验 ($\chi^2$) 或 logistic 回归；若为率 (rate) 数据，用 Poisson 回归
- **条件2：重复测量/嵌套设计按独立样本处理** → **表现**：10 个受试者各测 3 次 $\neq$ 30 个独立样本；伪重复导致自由度膨胀 ($df_{\text{claimed}} > df_{\text{true}}$)，标准误低估，p 值反保守（容易假阳性）→ 使用重复测量 ANOVA 或线性混合效应模型 (`fitlme`)
- **条件3：小样本 + 严重离群值** → **表现**：单个离群点可翻转显著性结论（$p$ 从 0.04 变为 0.20）；均值 ± 2SD 对离群值敏感 → 使用稳健方法：Yuen 修整均值 t 检验（修整 20% 尾部），或仅用非参数检验

## 文献

1. Fisher R.A. (1925) *Statistical Methods for Research Workers*. Oliver & Boyd, Edinburgh. ISBN 978-0874710225.
2. Snedecor G.W. & Cochran W.G. (1989) *Statistical Methods*, 8th Edition. Iowa State University Press. ISBN 978-0813815616.
3. Tukey J.W. (1949) "Comparing individual means in the analysis of variance", *Biometrics*, 5(2): 99–114. DOI: [10.2307/3001913](https://doi.org/10.2307/3001913)

## 来源溯源

matlab/stats/anova_oneway.m

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 组合 | PARADIGM-0501 | 回归分析中检验系数显著性 ($t$ 检验) 和模型显著性 ($F$ 检验) |
| 组合 | PARADIGM-0504 | PCA 后对主成分得分做 ANOVA 检验分组效果 |
| 组合 | PARADIGM-0506 | 聚类后用 ANOVA 检验簇间差异是否显著 |
| 替代 | PARADIGM-0511 | 因子分析替代 ANOVA 用于潜变量结构的方差分解 |
