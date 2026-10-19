# PARADIGM-0511 因子分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0511 |
| 类别/子类 | ⑤统计与数据分析 / 降维 |
| 难度 | 中 |
| 适用题型关键词[] | 因子分析, 潜在因子, 方差旋转, Varimax, 共同度, 载荷矩阵, 潜在变量 |
| confidence | high |
| source | matlab/stats/factoran_wrapper.m |

## 数学形式

### 正交因子模型

$$X = \Lambda F + \varepsilon$$

其中：
- $X \in \mathbb{R}^{p \times 1}$：观测变量（$p$ 个）
- $\Lambda \in \mathbb{R}^{p \times m}$：因子载荷矩阵
- $F \in \mathbb{R}^{m \times 1}$：公共因子（$m$ 个，$m \ll p$）
- $\varepsilon \in \mathbb{R}^{p \times 1}$：特殊因子（唯一因子）

**假设**：
- $\mathbb{E}[F] = 0$, $\text{Cov}(F) = I_m$（正交因子）
- $\mathbb{E}[\varepsilon] = 0$, $\text{Cov}(\varepsilon) = \Psi = \text{diag}(\psi_1, \ldots, \psi_p)$
- $\text{Cov}(F, \varepsilon) = 0$

### 协方差结构

$$\Sigma = \Lambda \Lambda^T + \Psi$$

### 共同度 (Communality)

变量 $x_i$ 的方差分解：
$$\text{Var}(x_i) = \underbrace{\sum_{j=1}^{m} \lambda_{ij}^2}_{h_i^2 \text{ (共同度)}} + \psi_i \text{ (唯一方差)}$$

### 估计方法

**极大似然估计 (MLE)**：假设 $X \sim N(0, \Sigma)$，最大化似然函数，需满足唯一性条件。

**主因子法**：用 $\hat{\Psi}$ 迭代估计。

### 方差最大旋转 (Varimax)

正交旋转矩阵 $T$（$T T^T = I$），旋转后载荷 $\tilde{\Lambda} = \Lambda T$。

Varimax 最大化准则（简化列，使每列载荷两极分化）：
$$V = \sum_{j=1}^{m} \left[ p \sum_{i=1}^{p} \left(\frac{\tilde{\lambda}_{ij}}{h_i}\right)^4 - \left(\sum_{i=1}^{p} \frac{\tilde{\lambda}_{ij}^2}{h_i^2}\right)^2 \right]$$

### 因子得分估计

Thompson 回归法：
$$\hat{F} = \Lambda^T (\Lambda \Lambda^T + \Psi)^{-1} X$$

Bartlett 加权最小二乘法：
$$\hat{F} = (\Lambda^T \Psi^{-1} \Lambda)^{-1} \Lambda^T \Psi^{-1} X$$

### 适用性检验

**KMO (Kaiser-Meyer-Olkin) 统计量**：
$$\text{KMO}_i = \frac{\sum_{j \neq i} r_{ij}^2}{\sum_{j \neq i} r_{ij}^2 + \sum_{j \neq i} a_{ij}^2}$$

其中 $r_{ij}$ 为相关系数，$a_{ij}$ 为偏相关系数。KMO $> 0.6$ 可接受，$> 0.8$ 适合。

**Bartlett 球形检验**：
$$H_0: \Sigma = \sigma^2 I \quad \text{(变量不相关)}$$
检验统计量：$\chi^2 = -\left(n - 1 - \frac{2p+5}{6}\right) \ln|\hat{R}| \sim \chi^2(p(p-1)/2)$

### 因子数确定

平行分析 (Horn's Parallel Analysis)：
- 生成随机数据矩阵，计算其特征值
- 保留 $\lambda_i^{\text{real}} > \lambda_i^{\text{random}}$ (95% 分位) 的因子

**变量表**：
| 符号 | 含义 | 维度 |
|------|------|------|
| $X$ | 观测变量向量 | $p \times 1$ |
| $\Lambda$ | 载荷矩阵 | $p \times m$ |
| $F$ | 公共因子 | $m \times 1$ |
| $\varepsilon$ | 特殊因子 | $p \times 1$ |
| $\Psi$ | 唯一方差对角阵 | $p \times p$ |
| $h_i^2$ | 共同度 | 标量 |
| $m$ | 因子数 | 标量 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| `X` | double matrix | — | $n \times p$, 连续变量 | 高（须标准化） |
| `m` | int | — | $1 \leq m \leq p-1$ | **极高**（核心超参） |
| `Rotate` | string | `'varimax'` | varimax / promax / quartimax / equamax / none | 高（影响可解释性） |
| `Method` | string | MLE (默认) | mle / principal | 中（MLE 更统计严谨） |
| `MaxIter` | int | 200 | $\geq 50$ | 低 |

**时间复杂度**：$O(p^3 + n \cdot p \cdot m)$ (MLE + 得分)；$O(p^3)$ (主因子)
**空间复杂度**：$O(p^2) + O(n \cdot m)$

## MATLAB 实现

函数签名：
```matlab
[Lambda, Psi, T, stats, F] = factoran_wrapper(X, m, 'Rotate', 'varimax', 'Method', 'mle')
```

锚点工具箱函数：`factoran` (Statistics and Machine Learning Toolbox)

实现位置：`matlab/stats/factoran_wrapper.m`

```matlab
function [Lambda, Psi, T, stats, F] = factoran_wrapper(X, m, varargin)
    % Factor Analysis wrapper with rotation and diagnostics
    % X: n×p data matrix
    % m: number of common factors
    % Returns: Lambda (loading matrix p×m), Psi (uniqueness vector p×1),
    %          T (rotation matrix), stats (fit info), F (factor scores n×m)
    
    p = inputParser;
    addParameter(p, 'Rotate', 'varimax');
    addParameter(p, 'Method', 'mle');  % Maximum Likelihood
    addParameter(p, 'MaxIter', 200);
    parse(p, varargin{:});
    
    % Standardize
    X_std = zscore(X);
    
    % Factor analysis
    [Lambda, Psi, T, stats, F] = factoran(X_std, m, ...
        'Rotate', p.Results.Rotate, ...
        'Maxit', p.Results.MaxIter);
    
    % Communality
    h2 = sum(Lambda.^2, 2)';  % row sums
    fprintf('Communalities: ');
    fprintf('%.3f ', h2);
    fprintf('\n');
    
    % Variance explained by each factor
    var_exp = sum(Lambda.^2, 1) / size(X,2) * 100;
    fprintf('Variance explained: ');
    fprintf('%.1f%% ', var_exp);
    fprintf('\n');
end
```

**KMO 和 Bartlett 检验（调用辅助函数）**：
```matlab
% KMO
R = corr(X);
R_inv = inv(R);
A = -diag(1./sqrt(diag(R_inv))) * R_inv * diag(1./sqrt(diag(R_inv)));
A(1:p+1:end) = 0;  % anti-image correlation (zero diagonal)
R2 = R.^2; A2 = A.^2;
R2(1:p+1:end) = 0; A2(1:p+1:end) = 0;
kmo = sum(R2(:)) / (sum(R2(:)) + sum(A2(:)));
fprintf('KMO = %.4f\n', kmo);

% Bartlett's test of sphericity
[n, p] = size(X);
R_det = det(R);
chi2 = -(n - 1 - (2*p + 5)/6) * log(R_det);
df = p * (p - 1) / 2;
p_bartlett = 1 - chi2cdf(chi2, df);
fprintf('Bartlett χ² = %.4f, df = %d, p = %.4e\n', chi2, df, p_bartlett);
```

**Promax 斜交旋转（因子相关）**：
```matlab
[Lambda, Psi] = factoran(X_std, m, 'Rotate', 'promax');
```

## Python 备选

```python
from sklearn.decomposition import FactorAnalysis
from sklearn.preprocessing import StandardScaler
from factor_analyzer import FactorAnalyzer, calculate_kmo, calculate_bartlett_sphericity
import numpy as np
import pandas as pd

# Standardize
X_std = StandardScaler().fit_transform(X)

# --- Adequacy tests ---
kmo_all, kmo_model = calculate_kmo(X_std)
chi2, p_bartlett = calculate_bartlett_sphericity(X_std)
print(f'KMO = {kmo_model:.4f}')
print(f'Bartlett: χ² = {chi2:.2f}, p = {p_bartlett:.4e}')

# --- Factor Analysis with rotation ---
fa = FactorAnalyzer(n_factors=m, rotation='varimax', method='minres')
fa.fit(X_std)

loadings = fa.loadings_              # p×m rotated loading matrix
communalities = fa.get_communalities()  # p×1
eigenvalues = fa.get_eigenvalues()[0]   # p×1
factor_scores = fa.transform(X_std)     # n×m

# Variance explained
var_exp = fa.get_factor_variance()
print('Explained variance per factor:', var_exp[0])
print('Cumulative variance:', var_exp[2])

# --- Promax (oblique) rotation ---
fa_oblique = FactorAnalyzer(n_factors=m, rotation='promax', method='minres')
fa_oblique.fit(X_std)

# sklearn alternative (no rotation, no diagnostics)
from sklearn.decomposition import FactorAnalysis
fa_sk = FactorAnalysis(n_components=m, random_state=42)
fa_sk.fit(X_std)
loadings_sk = fa_sk.components_.T
scores_sk = fa_sk.transform(X_std)
```

**平行分析 (Parallel Analysis)**：
```python
from factor_analyzer.factor_analyzer import calculate_parallel_analysis

# Get suggested number of factors via parallel analysis
fa_pa = FactorAnalyzer(rotation=None, method='minres')
fa_pa.fit(X_std)
ev_real, _ = fa_pa.get_eigenvalues()

# Parallel analysis simulation
n_rep = 100
ev_random = np.zeros((n_rep, X_std.shape[1]))
np.random.seed(42)
for i in range(n_rep):
    X_sim = np.random.normal(size=X_std.shape)
    fa_sim = FactorAnalyzer(rotation=None, method='minres')
    fa_sim.fit(X_sim)
    ev_random[i, :] = fa_sim.get_eigenvalues()[0]

ev_95 = np.percentile(ev_random, 95, axis=0)
n_factors = np.sum(ev_real > ev_95)
print(f'Parallel analysis suggests {n_factors} factors')
```

## 选型决策树

```
变量背后是否存在不可直接观测的潜变量？
├── 是 → 需要测量误差模型？
│   ├── 是 → 因子分析 (FA) ✓
│   │   ├── 探索性 (不确定因子结构) → EFA
│   │   ├── 验证性 (有先验因子假设) → CFA (结构方程模型 SEM)
│   │   └── 因子相关？ → Promax 斜交旋转
│   └── 否 → PCA (无误差项)
├── 否 (纯降维/压缩) → PCA (PARADIGM-0504)
└── 混合类型变量 → FAMD (混合数据因子分析)
```

**EFA 适用性预检查清单**：
1. KMO > 0.6（整体），各变量 KMO > 0.5
2. Bartlett 球形检验 $p < 0.05$
3. $n \geq 100$ 或 $n/p \geq 5$（最低 $n/p \geq 3$）
4. 变量间有中等以上相关（$|r| > 0.3$ 的占多数）
5. 无可接受的 Heywood 案例（共同度 $\leq 1$，唯一方差 $\geq 0$）

**替代算法对比**：
| 算法 | 适用场景 | 与 FA 区别 |
|------|----------|------------|
| PCA | 降维、压缩、去噪 | 无误差项；方差分解不含 $\Psi$；不可旋转解释 |
| ICA (独立成分分析) | 盲源分离 | 假设非高斯独立源，非正态因子 |
| CFA (验证性因子分析) | 验证先验结构 | 部分载荷固定为 0；模型拟合检验 |
| SEM (结构方程模型) | 因子间因果路径 | FA + 回归路径，完整因果建模 |
| NMF (非负矩阵分解) | 非负数据 | 载荷和得分均 $\geq 0$，更易解释 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 相关系数矩阵热图 | 检查变量间是否充分相关（FA 前提）；标注 Bartlett p 值 |
| raw | KMO 条形图（按变量） | 展示各变量抽样充分性，标注 0.5 和 0.6 阈值 |
| process | 碎石图 + 平行分析叠加 | 实际特征值 vs 随机 95% 分位线，交点即建议因子数 |
| process | 旋转前/后载荷热图 (2面板) | 左=未旋转，右=Varimax 旋转后，观察"简单结构"是否出现 |
| result | 因子载荷 biplot (varimax) | 变量在旋转后因子空间的投影，箭头长度 = 共同度 |
| result | 因子得分散点图 (F1 vs F2) | 按潜类别着色（若已知），观察分离度 |
| result | 路径图 (path diagram) | 潜变量 → 观测变量的箭头图，标注载荷值和唯一方差 |

## 常见坑

1. **Heywood 案例**：共同度 $h_i^2 > 1$ 或 $\psi_i < 0$ → 模型无效，可能是 $m$ 过大或样本太小 → 减小 $m$，或改用主因子法（约束 $\psi_i \geq 0$），或使用 Bayesian FA
2. **小样本不稳定**：$n < 100$ 或 $n/p < 5$ → 载荷估计标准误大，旋转后结构不稳定，KMO 普遍偏低 → 报告载荷自举 (bootstrap) 置信区间，或用正则化 FA
3. **旋转选择影响结论**：Varimax（正交，因子独立）vs Promax（斜交，允许相关）→ 社会科学中因子通常相关 (0.3-0.5)；若强制正交，载荷分布被扭曲 → 先跑 Promax，检查因子间相关矩阵：若 $|r| > 0.3$，用斜交旋转
4. **因子数确定主观**：仅靠特征值 $>1$ 可能高估（尤其 $p > 20$）→ 平行分析 (Horn) 是最可靠的方法之一；辅助参考 MAP (Minimum Average Partial)、BIC
5. **变量标准化方式**：基于相关矩阵 = z-score 标准化（暗含各变量等权）；基于协方差矩阵 = 保留量纲差异 → 通常用相关矩阵（标准化），除非变量量纲有实际意义且应保留
6. **因子命名主观**：Varimax 旋转后的载荷分布可能仍然模糊（某一变量在多个因子上载荷 > 0.4，即"交叉载荷"）→ 移除高交叉载荷变量重跑；或在论文中坦诚报告并讨论

## 失效条件/反例 (强制小节)

- **条件1：变量几乎不相关 (KMO < 0.5，Bartlett $p > 0.05$)** → **表现**：相关矩阵接近单位阵，不存在潜在共同因子结构；FA 强制提取因子会得到低共同度（$h^2 < 0.2$），载荷分散无规律，旋转后仍无清晰结构；伪因子得分无预测力 → FA 不适用，直接用初始变量做后续分析；或重新设计测量工具/变量选择
- **条件2：变量间存在强非线性关系** → **表现**：FA 的线性模型 $\Sigma = \Lambda\Lambda^T + \Psi$ 无法捕捉二次/交互/阈值效应；Pearson 相关低估非线性依赖，因子结构被削弱或扭曲；共同度偏低，残差相关矩阵中出现大量非零值 → 使用非线性因子分析 (NLFA)、核方法，或考虑对变量做适当变换使其关系线性化
- **条件3：有序分类/二分类变量当连续变量处理** → **表现**：二分类或 Likert 量表（< 5 级）下 Pearson 相关系数被衰减 (attenuation)，载荷估计系统性偏低，共同度严重低估；例如真实载荷 0.7 可能被估计为 0.45 → 使用多分格相关系数 (polychoric correlation) 矩阵 + 加权最小二乘 (WLS) 估计，或项目反应理论 (IRT) 模型

## 文献

1. Thurstone L.L. (1947) *Multiple Factor Analysis*. University of Chicago Press. ISBN 978-0226801006.
2. Harman H.H. (1976) *Modern Factor Analysis*, 3rd Edition. University of Chicago Press. ISBN 978-0226316524.
3. Fabrigar L.R. & Wegener D.T. (2012) *Exploratory Factor Analysis*. Oxford University Press. ISBN 978-0199734177.
4. Kaiser H.F. (1974) "An index of factorial simplicity", *Psychometrika*, 39(1): 31–36. DOI: [10.1007/BF02291575](https://doi.org/10.1007/BF02291575)

## 来源溯源

matlab/stats/factoran_wrapper.m

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 替代 | PARADIGM-0504 | PCA — 纯降维无误差项时优先 PCA |
| 组合 | PARADIGM-0509 | 对因子得分做 ANOVA/t 检验，比较潜变量均值差异 |
| 组合 | PARADIGM-0506 | 对因子得分做聚类，发现潜在类别/人群分型 |
| 组合 | PARADIGM-0501 | 以因子得分作为回归自变量，避免多重共线性 |
