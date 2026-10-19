# PARADIGM-0503 概率分布与统计推断 (fitdist/mle)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0503 |
| 类别/子类 | ⑤统计 / 分布拟合 |
| 难度 | 中 |
| 适用题型关键词[] | 概率分布, 分布拟合, MLE, 最大似然, fitdist, K-S检验, QQ图, 参数估计, 分布假设检验, 随机变量建模 |
| confidence | high |
| source | 数理统计教材 (Casella & Berger, Hogg et al.); MATLAB Statistics and Machine Learning Toolbox 文档 |

## 数学形式

**极大似然估计 (MLE)**:
$$\hat{\theta}_{\text{MLE}} = \arg\max_{\theta} \prod_{i=1}^{n} f(x_i \mid \theta)$$

等价于最大化对数似然:
$$\ell(\theta) = \sum_{i=1}^{n} \ln f(x_i \mid \theta)$$

**Kolmogorov-Smirnov 单样本检验**:
$$D_n = \sup_x |F_n(x) - F(x)|$$

其中 $F_n(x)$ 为经验累积分布函数 (ECDF), $F(x)$ 为理论 CDF。$D_n$ 越大, 拟合越差。p 值 < 0.05 时拒绝"数据来自该分布"的原假设。

**Anderson-Darling 检验** (对尾部差异更敏感):
$$A^2 = -n - \sum_{i=1}^{n} \frac{2i-1}{n} \left[ \ln F(x_{(i)}) + \ln(1 - F(x_{(n+1-i)})) \right]$$

**常用分布族**:
- 正态 (Normal): $f(x) = \frac{1}{\sigma\sqrt{2\pi}} \exp\left(-\frac{(x-\mu)^2}{2\sigma^2}\right)$
- 对数正态 (Lognormal): $\ln X \sim N(\mu, \sigma^2)$
- Weibull: $f(x) = \frac{k}{\lambda}\left(\frac{x}{\lambda}\right)^{k-1} \exp\left(-(x/\lambda)^k\right)$, $x \geq 0$
- Gamma: $f(x) = \frac{\beta^\alpha}{\Gamma(\alpha)} x^{\alpha-1} e^{-\beta x}$, $x > 0$
- 指数 (Exponential): $f(x) = \lambda e^{-\lambda x}$, $x \geq 0$ (Gamma 的特例: $\alpha=1$)
- t 分布: $f(x) = \frac{\Gamma((\nu+1)/2)}{\sqrt{\nu\pi}\,\Gamma(\nu/2)} \left(1 + \frac{x^2}{\nu}\right)^{-(\nu+1)/2}$

**信息准则 (模型选择)**:
- AIC = $-2\ell(\hat{\theta}) + 2k$ (Akaike Information Criterion)
- BIC = $-2\ell(\hat{\theta}) + k\ln n$ (Bayesian Information Criterion)
- AIC/BIC 越小, 模型在拟合优度与复杂度间的权衡越好

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| distname | string/cell | — | Normal/Lognormal/Weibull/Gamma/Exponential/tLocationScale/BirnbaumSaunders/... | 高 — 选定分布族 |
| censoring | logical | [] | 与数据等长 | 高 — 忽略删失导致偏倚 |
| freq | numeric | [] | 正整数 | 低 — 频数数据 |
| alpha (CI) | numeric | 0.05 | 0.01~0.10 | 低 |
| nboot (Bootstrap) | integer | 1000 | 100~10000 | 中 — 过少 CI 不稳定 |

- 时间复杂度: MLE 拟合通常 $O(kn)$ (k 为参数个数, 依赖迭代优化收敛); K-S 检验 $O(n\log n)$
- 空间复杂度: $O(n)$
- 输入量纲: 连续正实数 (Weibull, Gamma, Lognormal 等要求正数); 正态和 t 分布可接受实数

## MATLAB 实现

```matlab
% ===== 单分布拟合 =====
pd = fitdist(X, 'Normal');                   % 拟合正态分布
pd.mu                                       % 均值
pd.sigma                                    % 标准差
ci = paramci(pd);                            % 95% 置信区间

% ===== 多分布比较 =====
distributions = {'Normal', 'Lognormal', 'Weibull', 'Gamma', 'Exponential'};
results = table();
for i = 1:length(distributions)
    pd = fitdist(X, distributions{i});
    [h, p] = kstest(X, 'CDF', pd);           % K-S 检验
    nll = negloglik(pd);                      % 负对数似然
    aic = 2*nll + 2*pd.NumParameters;         % AIC
    bic = 2*nll + pd.NumParameters*log(n);    % BIC
    results = [results; table(distributions(i), nll, aic, bic, p, ...
        'VariableNames', {'Distribution', 'NLL', 'AIC', 'BIC', 'KS_p'})];
end
disp(sortrows(results, 'AIC'));

% ===== Weibull 专项 =====
pd_wbl = fitdist(X, 'Weibull');
[wbl_shape, wbl_scale] = deal(pd_wbl.A, pd_wbl.B);
% 或使用专用函数
parmhat = wblfit(X);
wblplot(X);                                  % Weibull 概率图

% ===== QQ 图 =====
qqplot(X, pd);                               % 通用 QQ 图
probplot('normal', X);                       % 正态概率图
probplot('weibull', X);                      % Weibull 概率图

% ===== ECDF =====
[f_ecdf, x_ecdf] = ecdf(X);
stairs(x_ecdf, f_ecdf); hold on;
plot(x_ecdf, cdf(pd, x_ecdf));              % 叠合理论 CDF

% ===== 删失数据 =====
% 假设 cens 为 0/1 向量, 1=删失
pd_cens = fitdist(X(cens==0), 'Weibull');   % 简单做法: 仅用未删失数据
% 完整删失 MLE 可用 mle() 函数
[phat, pci] = mle(X, 'Censoring', cens, 'Distribution', 'Weibull');

% ===== GMM 混合分布 =====
GMModel = fitgmdist(X, 2);                   % 2成分高斯混合
```

## Python 备选

```python
from scipy import stats
import numpy as np
import matplotlib.pyplot as plt

# 拟合
params = stats.norm.fit(X)                   # (mu, sigma)
params = stats.weibull_min.fit(X)            # Weibull

# K-S 检验
stats.kstest(X, 'norm', args=params)

# 多分布比较
dist_names = ['norm', 'lognorm', 'weibull_min', 'gamma', 'expon']
for name in dist_names:
    dist = getattr(stats, name)
    params = dist.fit(X)
    D, p = stats.kstest(X, name, args=params)
    print(f"{name}: D={D:.4f}, p={p:.4f}")

# QQ 图
stats.probplot(X, dist='norm', plot=plt)
```

## 选型决策树

```
数据取值范围?
  ├─ (-∞, +∞) → 正态, t分布
  ├─ [0, +∞) → Lognormal, Weibull, Gamma, Exponential
  ├─ [0, 1] → Beta
  └─ 正整数 → Poisson, 负二项, Geometric
目标?
  ├─ 仅描述数据 → 多个分布各拟合, 选AIC/BIC最小者
  ├─ 假设检验 → K-S 或 AD 检验
  └─ 可靠性/生存分析 → Weibull (最常用)
数据可视化辅助?
  ├─ QQ图: 点沿对角线 → 分布拟合好
  ├─ Weibull概率图: wblplot
  └─ ECDF + 理论CDF叠合
小样本 (n<50)?
  → 优先参数少的分布 (如Exponential 1参数) 以防过拟合
  → AICc = AIC + 2k(k+1)/(n-k-1) 对小样本修正
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 探索 | 直方图 + 核密度估计 (ksdensity) | 观察分布形状 (单峰/双峰/偏态) |
| 比较 | 多分布 PDF 叠合图 | 在直方图上叠合 3-5 条候选分布 PDF 曲线 |
| 诊断 | QQ 图 (qqplot) | 诊断尾部拟合质量; 两端偏离=厚尾, S形=偏态 |
| 诊断 | Weibull 概率图 (wblplot) | 在 Weibull 坐标纸上点近似直线则拟合好 |
| 比较 | ECDF + 理论 CDF 叠合 | 全分布范围的拟合直观展示 |
| 模型选择 | AIC/BIC 条形图 | 柱状图对比各分布的信息准则值 |

## 常见坑

1. **p-hacking**: 对同一个数据集多次尝试不同分布直到 K-S 检验不显著 (p > 0.05), 这利用了多重检验 — 至少有一个分布"看起来"通过检验纯属偶然。
2. **删失数据忽略**: 如果数据包含"大于某阈值"或"小于检测限"的删失观测, 直接用 fitdist 会系统偏倚。需要用 mle() 的 'Censoring' 选项或生存分析方法。
3. **混合分布误判**: 数据明显双峰 (如男/女性别混合的身高), 却强行拟合单一分布 — 任何单一分布都会被 K-S 拒绝。这时拟合的 $\mu$ 可能是两个子群体的不对应任何真实总体的折衷值。
4. **小样本下的分布误判**: n=20 时, 正态和 Gamma 的 K-S 差异不够大, K-S 检验的检验力 (power) 不足, 容易接受错误分布。
5. **尾部行为外推**: 使用拟合分布做极值预测 (如"百年一遇") 时, 尾部 1% 的拟合误差可导致 10 倍以上的外推误差。K-S 检验对中央部分敏感, 对尾部不敏感 — 需要 Anderson-Darling 检验或专门尾部诊断。

## 失效条件/反例 (强制小节)

- **条件1 — 小样本 n < 30 → MLE 估计偏倚, 分布族难以确定**: 当样本量不足时, MLE 估计的方差大, 置信区间宽。更严重的是 K-S 检验的检验力不足, 即使数据明显偏离某分布, 检验也无法拒绝 (假阴性)。例如 n=15 的均匀分布数据用正态分布拟合, K-S p 值可能仍 > 0.05。此时应: (1) 报告 AICc (小样本修正 AIC), (2) 结合领域知识指定分布族 (如可靠性工程用 Weibull), (3) 避免过度解读 p 值。
- **条件2 — 混合分布 → 单分布拟合残差大, K-S 拒绝所有候选, 需用 GMM**: 若数据由两个或多个子群体混合 (如两种失效模式下的寿命数据), 任何单一分布族的拟合都会被 K-S 检验拒绝。K-S 统计量 $D_n$ 对混合造成的双峰或多峰结构高度敏感。此时需使用 `fitgmdist(X, k)` 拟合 k 成分高斯混合模型 (GMM), 并通过 BIC 选择成分数 k。注意 GMM 的参数估计使用 EM 算法, 需多起点避免局部最优。
- **条件3 — 删失数据 → 普通 MLE 忽略删失机制, 估计偏差**: 若数据包含右删失 (如"300 小时后仍未失效"), 直接用 fitdist 将删失观测等同于未删失观测, 会导致参数系统性低估 (对 Weibull, 尺度参数 $\lambda$ 偏低, 即错误推断产品更不可靠)。正确做法是用 `mle()` 的 Censoring 参数, 或使用 `fitcox` / `ecdf` 的 Kaplan-Meier 估计。数学背景: 删失数据的似然函数为 $\prod_{i \in \text{uncensored}} f(t_i) \times \prod_{i \in \text{censored}} S(C_i)$, 其中 $S$ 为生存函数, 忽略了 $S(C_i)$ 项即产生偏差。

## 文献

1. Casella, G., & Berger, R. L. (2002). *Statistical Inference* (2nd ed.). Duxbury.
2. Hogg, R. V., McKean, J. W., & Craig, A. T. (2018). *Introduction to Mathematical Statistics* (8th ed.). Pearson.
3. Stephens, M. A. (1974). EDF Statistics for Goodness of Fit and Some Comparisons. *Journal of the American Statistical Association*, 69(347), 730-737.
4. Akaike, H. (1974). A New Look at the Statistical Model Identification. *IEEE Transactions on Automatic Control*, 19(6), 716-723.
5. MATLAB Documentation: `fitdist`, `mle`, `kstest`, `ecdf`, `wblfit`, `wblplot`, `probplot`, `fitgmdist`.

## 来源溯源

- 原始来源: MLE 方法由 Fisher (1912, 1922) 系统化提出; K-S 检验由 Kolmogorov (1933) 和 Smirnov (1948) 发展
- MATLAB 实现: `fitdist` 在 Statistics and Machine Learning Toolbox 中实现, 支持 20+ 种参数分布族, 内部使用 fminsearch/fmincon 优化负对数似然
- Weibull 分布由 Waloddi Weibull (1951) 推广于材料强度建模, `wblfit` 和 `wblplot` 为可靠性工程提供专用支持
- GMM (`fitgmdist`) 使用 EM 算法 (Dempster et al., 1977) 估计参数

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — 数据预处理 (标准化/异常去除后拟合) | PARADIGM-0501 / PARADIGM-0502 |
| 后置 — 假设检验 (t检验, ANOVA) | PARADIGM-0511~0515 |
| 后置 — 生存分析 (删失数据的分布建模) | PARADIGM-0524 |
| 互补 — 可靠性分析 (Weibull 寿命建模) | PARADIGM-0524 (Cox) |
| 互补 — Bootstrap 置信区间替代大样本渐近 | PARADIGM-0531 |
