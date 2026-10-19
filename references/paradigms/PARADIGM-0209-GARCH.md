# PARADIGM-0209 GARCH波动率模型⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0209 |
| 类别/子类 | ②预测 / 波动率建模 |
| 难度 | 中 |
| 适用题型关键词[] | GARCH, 波动率, 异方差, 金融时间序列, 风险预测, garch, estimate, 收益率 |
| confidence | high |
| source | Bollerslev (1986) J Econometrics |

## 数学形式

**GARCH(p,q) 模型:**
$$r_t = \mu + \varepsilon_t, \quad \varepsilon_t = \sigma_t z_t, \quad z_t \sim \text{IID}(0,1)$$

$$\sigma_t^2 = \omega + \sum_{i=1}^{q} \alpha_i \varepsilon_{t-i}^2 + \sum_{j=1}^{p} \beta_j \sigma_{t-j}^2$$

**GARCH(1,1) (最常用):**
$$\sigma_t^2 = \omega + \alpha \varepsilon_{t-1}^2 + \beta \sigma_{t-1}^2$$

**平稳性条件:**
$$\alpha + \beta < 1$$

**无条件方差 (长期均值):**
$$\sigma^2_{\text{LR}} = \frac{\omega}{1 - \alpha - \beta}$$

**半衰期 (Half-Life, 冲击衰减):**
$$\tau = \frac{\ln 0.5}{\ln(\alpha + \beta)}$$

**波动率集聚 (Volatility Clustering) 参数:**
$\alpha$ — 近期冲击的敏感度 (news impact)
$\beta$ — 波动的持续性 (persistence)

**扩展模型:**
- **GJR-GARCH** (杠杆效应): 正负冲击不对称
- **EGARCH**: $\log\sigma_t^2$ 避免非负约束
- **GARCH-M**: 波动率进入均值方程 (风险溢价)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| p | int | 1 | [0,5] | 中 — p=1 通常足够 |
| q | int | 1 | [0,5] | 中 — q>1 可有额外 ARCH 效应 |
| 分布假设 | str | 'Gaussian' | 'Gaussian','t','GED' | 高 — 厚尾更真实 |
| 估计方法 | — | MLE | — | — |

## MATLAB 实现

```matlab
% Econometrics Toolbox
% 估计 GARCH(1,1)
Mdl = garch(1,1);
EstMdl = estimate(Mdl, returns);

% 查看估计结果
disp(EstMdl);
% omega, alpha, beta

% 预测未来波动率
n_forecast = 10;
[V_forecast, ~] = forecast(EstMdl, n_forecast, returns);

% 条件方差 (过滤)
V_in_sample = infer(EstMdl, returns);
plot(sqrt(V_in_sample));  % 波动率

% GJR-GARCH (杠杆效应)
Mdl_gjr = garch('GARCHLags', 1, 'ARCHLags', 1, 'LeverageLags', 1);
EstMdl_gjr = estimate(Mdl_gjr, returns);

% t 分布 GARCH
Mdl_t = garch(1,1);
Mdl_t.Distribution = struct('Name', 't', 'DoF', NaN);  % 估计自由度
EstMdl_t = estimate(Mdl_t, returns);
```

锚点: `garch` / `estimate` (Econometrics Toolbox)

## Python 备选

```python
# arch 库
from arch import arch_model
model = arch_model(returns, vol='Garch', p=1, q=1, dist='t')
res = model.fit(update_freq=0)
print(res.summary())
# 预测
forecasts = res.forecast(horizon=10)
```

## 选型决策树

- **GARCH(1,1)** — 标准金融波动率建模基线
- **GJR-GARCH / T-GARCH** — 检测到杠杆效应 (负面消息冲击 > 正面)
- **EGARCH** — 需要灵活的不对称性 + 对数正性保证
- **ARIMA (PARADIGM-0202)** — 仅均值预测不需要波动率
- **HAR-RV** — 有高频数据可实现波动率 (Realized Volatility)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 收益率时序 + 波动率聚类 | 视觉检测 ARCH 效应 |
| process | ACF of squared returns (ARCH效应检验) | 选取 p,q |
| result | 条件波动率时序 + 预测区间 | 叠加原收益率 |
| result | News Impact Curve | 正负冲击不对称 |

## 常见坑

1. **数据非平稳**: GARCH 假定收益率平稳。若存在结构断点 → 分段估计或用 IGARCH
2. **GARCH(1,1) 过度系数的边界**: $\alpha+\beta \approx 1$ → 近 IGARCH → 波动冲击近乎永续 → 冲击半衰期极长
3. **厚尾被忽略**: 正态假设低估极端事件 → VaR/ES 估计偏乐观 → 用 t 分布或 GED

## 失效条件/反例 (强制小节)

- **条件1: 没有 ARCH 效应 (残差平方无自相关)** → 表现: $\alpha \approx 0$ (不显著)，GARCH 模型退化 → $\sigma_t^2 \approx \omega/(1-\beta)$ 常数。浪费了参数且无预测价值。**应对**: 先做 ARCH-LM 检验，若无 ARCH 效应则使用常数方差模型 (ARIMA) 即可
- **条件2: 危机/新冠病毒等结构性断点** → 表现: 训练期 $\alpha+\beta\approx0.95$，危机期间 $\alpha+\beta\to 1$ (IGARCH) → 模型参数在断点前后不一致 → 预测波动率严重低估危机期的风险。**应对**: 使用滚动窗口估计或 Markov-Switching GARCH (允许参数在不同 regimes 间切换)

## 文献

1. Bollerslev T. (1986). "Generalized autoregressive conditional heteroskedasticity." *Journal of Econometrics*, 31(3):307-327. DOI: [10.1016/0304-4076(86)90063-1](https://doi.org/10.1016/0304-4076(86)90063-1)
2. Engle R.F. (1982). "Autoregressive conditional heteroscedasticity with estimates of the variance of United Kingdom inflation." *Econometrica*, 50(4):987-1007. (ARCH 的起源)

## 来源溯源

MATLAB `garch` / `estimate`; 时间序列计量经济学

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0202 (ARIMA) |
| 组合 | PARADIGM-0210 (VAR) |
| 组合 | PARADIGM-0503 (分布拟合) |
