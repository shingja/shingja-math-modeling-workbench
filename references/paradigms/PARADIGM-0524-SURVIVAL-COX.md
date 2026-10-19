# PARADIGM-0524  生存分析 — Cox 比例风险模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0524 |
| 类别/子类 | ⑤统计 / 生存分析 |
| 难度 | 高 |
| 适用题型关键词[] | Cox回归, 生存分析, 比例风险, 危险率, 删失, 删失数据, Kaplan-Meier, 生存曲线, log-rank检验, 预后因素, 事件-时间, 中位生存期, 风险比 |
| confidence | medium |
| source | Cox, D.R. (1972) Regression Models and Life-Tables, *Journal of the Royal Statistical Society B*, 34(2), 187-202; Kaplan, E.L. & Meier, P. (1958) *JASA*, 53(282), 457-481 |

## 数学形式

**Cox 比例风险模型 (Cox PH)**:
$$h(t \mid \mathbf{X}) = h_0(t) \cdot \exp(\boldsymbol{\beta}^T \mathbf{X})$$

其中:
- $h(t)$: 风险函数 (hazard function) — 在存活到时刻 $t$ 条件下, 下一瞬间发生事件的瞬时率
- $h_0(t)$: 基线风险函数 (baseline hazard) — **完全非参数**, 任意非负函数! 这是 Cox 模型的半参数特性
- $\exp(\boldsymbol{\beta}^T \mathbf{X})$: 比例风险乘子 (proportional hazards multiplier) — 不同个体的风险比恒定于时间

**风险比 (Hazard Ratio, HR)**:
$$HR_j = \exp(\beta_j)$$

含义: 协变量 $X_j$ 每增加 1 单位, 风险是原来的 $\exp(\beta_j)$ 倍。$HR > 1$ = 危险因素; $HR < 1$ = 保护因素。

**部分似然 (Partial Likelihood)** — 无需指定 $h_0(t)$:
$$L(\boldsymbol{\beta}) = \prod_{i: \delta_i = 1} \frac{\exp(\boldsymbol{\beta}^T \mathbf{X}_i)}{\sum_{j \in R(t_i)} \exp(\boldsymbol{\beta}^T \mathbf{X}_j)}$$

其中 $R(t_i)$ 为在时刻 $t_i$ 仍处于风险中的所有个体集合 (alive + uncensored at $t_i$)。分子是该事件个体的风险贡献; 分母是风险集中所有个体的风险之和。最大化 $L(\boldsymbol{\beta})$ (通常最大化对数部分似然) 可得 $\hat{\boldsymbol{\beta}}$。

**Kaplan-Meier 生存函数** (非参数估计, 不依赖模型):
$$\hat{S}(t) = \prod_{t_i \leq t} \left( 1 - \frac{d_i}{n_i} \right)$$

其中 $d_i$ 为时刻 $t_i$ 发生的事件数, $n_i$ 为时刻 $t_i$ 的风险人数 (尚未发生事件且未删失)。

**Log-rank 检验** (两组生存曲线比较):
$$\chi^2_{\text{log-rank}} = \sum_{k} \frac{(O_{1k} - E_{1k})^2}{E_{1k}} \sim \chi^2_1$$

其中 $O_{1k}$ 和 $E_{1k}$ 为组 1 在时刻 $k$ 的观测和期望事件数。

**Schoenfeld 残差** (检验 PH 假设):
对每个协变量 $j$, 在每个事件时间 $t_i$:
$$\text{Schoenfeld residual}_{ij} = X_{ij} - \frac{\sum_{\ell \in R(t_i)} X_{\ell j} \exp(\hat{\boldsymbol{\beta}}^T \mathbf{X}_\ell)}{\sum_{\ell \in R(t_i)} \exp(\hat{\boldsymbol{\beta}}^T \mathbf{X}_\ell)}$$

若 PH 成立, Schoenfeld 残差应与时间无关 (无趋势)。对残差做时间回归: p < 0.05 → PH 假设违。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 时间 T | numeric vector | — | (0, +∞) | 高 — 需精确事件时间 |
| 事件指示 $\delta$ | binary (0/1) | — | 0=删失, 1=事件 | 高 — 误标删失致偏 |
| 协变量矩阵 X | numeric matrix | — | 连续/二分类 | 中 — 连续变量需标准化 |
| 比例风险假设检验 | 检验 | Schoenfeld residuals | — | 高 — 若 PH 不成立需换模型 |
| 分层变量 strata | categorical | — | — | 中 — 分层 Cox: 每层不同 $h_0$ |
| 事件数 per covariate | integer | > 10 | 5~20 | 高 — 少于 10 需 Firth 惩罚 |

- 时间复杂度: $O(np)$ (Newton-Raphson 迭代解部分似然), 每次迭代需对风险集求和
- 空间复杂度: $O(n + p^2)$
- 输入量纲: T 为时间单位 (天/月/年), X 可为任意量纲 (但直接影响 HR 解释)

## MATLAB 实现

```matlab
% ===== Cox 比例风险模型 (Statistics and Machine Learning Toolbox R2021a+) =====

% 数据准备
T = survival_time;           % 生存时间向量 (n×1)
delta = event_indicator;     % 事件指示符: 1=事件, 0=右删失
X = [age, biomarker1, biomarker2, treatment];  % 协变量矩阵 (n×p)

% Cox 模型拟合 (fitcox, R2021a+)
mdl = fitcox(X, [T, delta]);
disp(mdl);

% 提取结果
beta = mdl.Coefficients.Estimate;   % 回归系数
HR = exp(beta);                      % 风险比
pvals = mdl.Coefficients.pValue;     % p 值
CI = mdl.Coefficients.SE;            % 标准误

% 旧版函数 (R2008a+)
% [b, logl, H, stats] = coxphfit(X, [T, delta]);

% ===== Kaplan-Meier 生存曲线 =====
[f, x, flo, fup] = ecdf(T, 'Censoring', ~delta, ...
                        'Function', 'survivor');
stairs(x, f, 'LineWidth', 2);
hold on;
stairs(x, flo, '--', 'Color', [0.5 0.5 0.5]);
stairs(x, fup, '--', 'Color', [0.5 0.5 0.5]);
xlabel('时间'); ylabel('生存概率 S(t)');
title('Kaplan-Meier 生存曲线');

% ===== 分组 KM 曲线 + log-rank 检验 =====
% 假设 group 为分组变量 (0/1)
group0 = (group == 0);
group1 = (group == 1);

[f0, x0] = ecdf(T(group0), 'Censoring', ~delta(group0), 'Function', 'survivor');
[f1, x1] = ecdf(T(group1), 'Censoring', ~delta(group1), 'Function', 'survivor');
stairs(x0, f0, 'b', 'LineWidth', 2); hold on;
stairs(x1, f1, 'r', 'LineWidth', 2);
legend('Control', 'Treatment');

% ===== Schoenfeld 残差检验 PH 假设 =====
% fitcox 自动输出或手工计算
% 对 fitcox 的结果 md1, 可通过 plotResiduals 检查
% 手工: 对事件时间回归 Schoenfeld 残差, p<0.05 表示 PH 违
```

## Python 备选

```python
from lifelines import CoxPHFitter, KaplanMeierFitter
from lifelines.statistics import logrank_test
import pandas as pd

data = pd.DataFrame({'T': T, 'E': delta, 'age': age, 'bm': biomarker, 'trt': treatment})

# Cox PH
cph = CoxPHFitter()
cph.fit(data, duration_col='T', event_col='E')
cph.print_summary()                         # HR, p, CI, concordance

# 检验比例风险假设 (Schoenfeld残差)
cph.check_assumptions(data, p_value_threshold=0.05)

# Kaplan-Meier
kmf = KaplanMeierFitter()
kmf.fit(T, event_observed=delta)
kmf.plot_survival_function()

# Log-rank 检验
results = logrank_test(T[group==0], T[group==1], 
                        delta[group==0], delta[group==1])
print(f'log-rank p = {results.p_value:.4f}')
```

备选: `statsmodels` (PH 回归), `scikit-survival` (机器学习风格 API)

## 选型决策树

```
事件-时间数据?
  ├─ 有协变量 (预后因子分析) → Cox 比例风险模型
  │    ├─ PH 假设通过 → Cox PH (标准方法)
  │    ├─ PH 假设违 → 分层 Cox (strata) 或 AFT (加速失效时间模型)
  │    └─ 协变量随时间变化 → 时间相依 Cox (time-dependent covariate)
  ├─ 无协变量 (纯描述) → Kaplan-Meier + log-rank 检验
  ├─ 竞争风险 (多种结局) → Fine-Gray 子分布风险模型
  └─ 参数模型 (已知分布) → Weibull/Exponential/Log-logistic AFT (wblfit)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 描述 | Kaplan-Meier 生存曲线 (分组) | 阶梯下降曲线 + 删失标记 (+), 阴影区表示 CI |
| 诊断 | log-log 生存曲线 | $\log[-\log S(t)]$ vs $\log(t)$, 平行→PH成立 |
| 诊断 | Schoenfeld 残差 vs 时间散点图 | 无趋势→PH成立; 有趋势→PH违 |
| 结果 | 森林图 (Forest Plot) | 各协变量 HR + 95%CI 水平排列, 标记 p 值 |
| 预测 | 基线生存函数 | 协变量取均值时的预测生存曲线 |
| 验证 | 校准图 (Calibration plot) | 预测生存概率 vs 观测生存概率 |

## 常见坑

1. **删失机制非独立 (Informative Censoring)**: 若删失与预后相关 (如病情恶化者更可能失访), KM 估计和 Cox 回归均有偏。需检查删失模式: 比较删失个体与未删失个体的基线协变量分布, 或做敏感性分析 (如将删失视为事件的最坏/最好情况)。
2. **比例风险假设违且未处理**: 两条生存曲线交叉 → PH 不成立, 报告的 HR 是"平均"效应, 可能掩盖时间变化的重要模式 (如治疗初期有害后期有益)。必须检查 Schoenfeld 残差, 若 p < 0.05, 考虑分层 Cox 或 AFT 模型。
3. **事件数不足**: 经验法则: 每个协变量需要约 10 个事件 (Events Per Variable, EPV >= 10)。若 n=50, 事件仅 20 个, 则最多 2 个协变量。超出则过拟合, $\beta$ 估计不稳定, 标准误膨胀。解决方案: Firth 惩罚 Cox 或 LASSO Cox (降维)。
4. **连续变量 HR 误导性解释**: $\exp(\beta)$ 是"每单位"增加的风险比 — 若 biomarker 取值范围 [0, 100], 报告"每单位 HR=1.02 (p<0.001)"看似变化微小, 但对 100 单位的变化 HR = 1.02^{100} = 7.24。此时应报告标准化 HR 或按临床截断值 (如四分位距) 报告。
5. **基线生存函数被误解**: Cox 模型的基线生存函数 $S_0(t)$ 仅在协变量均取参考值时有意义, 不可直接作为"总体生存率"报告。

## 失效条件/反例 (强制小节)

- **条件1 — 比例风险假设不成立 → Schoenfeld 残差检验 p < 0.05, 风险比随时间变化, 需用时变协变量或分层 Cox**: PH 假设是 Cox 模型的核心: 两个个体的风险比不随时间改变。检验方法: (a) Schoenfeld 残差 vs 时间做回归, p < 0.05 则 PH 违; (b) log-log 生存曲线图, 若两条线不平行则 PH 违; (c) 引入时间-协变量交互项, 检验交互项系数是否为零。若 PH 违, 替代方案: (1) 分层 Cox (strata): 对违反 PH 的协变量分层, 允许每层有独立的 $h_0(t)$, 但不估计该协变量的效应; (2) 时变协变量 Cox: $h(t|X(t)) = h_0(t) \exp(\beta X(t))$, 允许协变量效应随时间变化; (3) AFT 模型 (加速失效时间模型): 直接建模 $\log T$, 无 PH 假设。
- **条件2 — 删失比例过大 (>50%) → 有效样本不足以估计 $\beta$, 标准误膨胀**: 若总样本的 >50% 为删失 (未观察到事件), 则真正提供信息的仅 <50% 个体。此时: (1) EPV (事件数 per 变量) 极低, 参数不可靠; (2) 部分似然中风险集在后期主要由删失个体构成, 信息量递减; (3) $\beta$ 的标准误与 $1/\sqrt{m}$ 成正比 ($m$ 为事件数), SE 膨胀。解决方案: 延长随访时间获取更多事件; 或使用参数模型 (Weibull/Exponential) 利用全部信息; 或 Bayesian Cox (引入信息先验稳定估计)。
- **条件3 — 协变量间共线性 → $\beta$ 估计不稳定, 符号反转, 需先做 VIF 筛选**: Cox 回归的目标函数是对数部分似然, 其 Hessian 矩阵条件数反映共线性程度。高共线性 (VIF > 10) 会导致: (a) $\beta$ 符号反转 (如一个已知保护因素的 HR > 1); (b) 标准误极大, p 值不显著 (尽管真实有影响); (c) 单个协变量显著但联合显著。解决方案: (1) 先计算 VIF, 移除 VIF > 10 的协变量之一; (2) 对高相关变量做 PCA 合成; (3) 使用 LASSO Cox ($\ell_1$ 惩罚部分似然) 自动选变量。

## 文献

1. Cox, D. R. (1972). Regression models and life-tables. *Journal of the Royal Statistical Society: Series B (Methodological)*, 34(2), 187-202.
2. Kaplan, E. L., & Meier, P. (1958). Nonparametric estimation from incomplete observations. *Journal of the American Statistical Association*, 53(282), 457-481.
3. Schoenfeld, D. (1982). Partial residuals for the proportional hazards regression model. *Biometrika*, 69(1), 239-241. (Schoenfeld 残差的起源)
4. Harrell, F. E. (2015). *Regression Modeling Strategies* (2nd ed.). Springer. Chapter 18: Cox Proportional Hazards Regression Model.
5. Therneau, T. M., & Grambsch, P. M. (2000). *Modeling Survival Data: Extending the Cox Model*. Springer.

## 来源溯源

- 原始来源: Cox (1972) 提出比例风险模型和部分似然方法 — 这被认为是 20 世纪统计学最重要的贡献之一
- Kaplan & Meier (1958) 提出 KM 估计器 — 非参数生存函数估计的标准方法
- Schoenfeld (1982) 引入残差诊断 — 成为检验 PH 假设的标准工具
- MATLAB 实现: `fitcox` (R2021a+)、`coxphfit` (R2008a+), 均在 Statistics and Machine Learning Toolbox 中
- 广泛应用于: 癌症临床试验预后分析, 机械可靠性寿命分析, 客户流失预测, 信用违约时间

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — 数据预处理 (异常值 + 缺失) | PARADIGM-0501 / PARADIGM-0502 |
| 前置 — 分布拟合 (Weibull 参数模型备选) | PARADIGM-0503 |
| 前置 — 共线性诊断 (VIF) | PARADIGM-0504 (PCA) |
| 互补 — 竞争风险 (Fine-Gray) | 见 Fine-Gray 文献 |
| 关联 — 因果推断 (DID, 政策评估中事件-时间设计) | PARADIGM-0525 |
| 关联 — Weibull 分析 (完全参数生存模型) | PARADIGM-0503 (wblfit) |
