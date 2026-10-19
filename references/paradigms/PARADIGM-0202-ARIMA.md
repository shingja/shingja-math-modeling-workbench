# PARADIGM-0202-ARIMA ARIMA时间序列⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0202-ARIMA |
| 类别/子类 | ②预测 / 时间序列 |
| 难度 | 中 |
| 适用题型关键词[] | ARIMA, 时间序列, Box-Jenkins, 差分, 自回归, 移动平均, ACF, PACF, 季节性 |
| confidence | high |
| source | MATLAB Econometrics Toolbox / matlab/predict/arima_fit.m |

## 数学形式

**ARIMA(p,d,q) 模型:**

$$\Phi(B)(1-B)^d y_t = \Theta(B)\varepsilon_t, \quad \varepsilon_t \sim \text{WN}(0, \sigma^2)$$

其中 $B$ 为滞后算子 ($B y_t = y_{t-1}$)。

**AR(p) — 自回归部分:**

$$\Phi(B) = 1 - \phi_1 B - \phi_2 B^2 - \cdots - \phi_p B^p$$

**MA(q) — 移动平均部分:**

$$\Theta(B) = 1 + \theta_1 B + \theta_2 B^2 + \cdots + \theta_q B^q$$

**差分阶数:** $(1-B)^d y_t$ — $d$ 阶差分使序列平稳。

**季节性 SARIMA(p,d,q)(P,D,Q)_s:**

$$(1-B)^d (1-B^s)^D y_t = \frac{\Theta(B) \Theta_s(B^s)}{\Phi(B) \Phi_s(B^s)} \varepsilon_t$$

其中 $\Phi_s(B^s) = 1 - \Phi_1 B^s - \cdots - \Phi_P B^{sP}$, $\Theta_s(B^s) = 1 + \Theta_1 B^s + \cdots + \Theta_Q B^{sQ}$。

**定阶准则:**

$$\text{AIC} = -2 \ln L + 2k, \quad \text{BIC} = -2 \ln L + k \ln n$$

其中 $L$ 为似然函数值, $k = p+q+P+Q+1$ 为参数个数, $n$ 为样本量。

**平稳性检验 — ADF 检验:**

$$\Delta y_t = \alpha + \beta t + \gamma y_{t-1} + \sum_{i=1}^{p} \delta_i \Delta y_{t-i} + \varepsilon_t$$

原假设 $H_0: \gamma = 0$ (存在单位根, 非平稳), 若拒绝则序列平稳。

**变量表:**
- $y_t$ — $t$ 时刻观测值
- $d$ — 差分阶数 (通常 $d=0,1,2$)
- $p$ — AR 阶数 (偏自相关截尾点)
- $q$ — MA 阶数 (自相关截尾点)
- $\phi_i$ — AR 系数; 平稳性要求特征根在单位圆外
- $\theta_i$ — MA 系数; 可逆性要求特征根在单位圆外
- $s$ — 季节周期 (如 $s=12$ 为月度年周期, $s=4$ 为季度)
- $P, D, Q$ — 季节性 AR/差分/MA 阶数

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| p (AR阶数) | int | 估计值 | 0-10 | 高 — 过高过拟合, 过低欠拟合 |
| d (差分阶数) | int | ADF确定 | 0-2 | 高 — 欠差分非平稳, 过差对方差膨胀 |
| q (MA阶数) | int | 估计值 | 0-10 | 高 — 同 p |
| P, D, Q (季节) | int | 估计值 | 0-2 | 中 — 仅对季节数据敏感 |
| s (季节周期) | int | 12 (月) / 4 (季) | ≥2 | 高 — 错误周期严重退化预测 |
| forecast_horizon | int | 由用户指定 | 1-50 | 高 — 置信区间随步长膨胀 |
| 时间复杂度 | — | — | O(n) 拟合 (MLE) | — |
| 空间复杂度 | — | — | O(n) | — |

## MATLAB 实现

函数签名:
```matlab
[EstMdl, y_fore, MSE, res_diag] = arima_fit(y, p, d, q, horizon, seasonal_order)
```

锚点: MATLAB Econometrics Toolbox `arima` / `estimate` / `forecast`。

核心调用:
```matlab
% 模型设定
Mdl = arima('ARLags', 1:p, 'D', d, 'MALags', 1:q, ...
            'SARLags', 1:P, 'Seasonality', s, 'SMALags', 1:Q);

% 参数估计 (最大似然)
EstMdl = estimate(Mdl, y);

% 预测
[y_fore, y_MSE] = forecast(EstMdl, horizon, 'Y0', y);

% 残差诊断
res = infer(EstMdl, y);
[h_pValue, ~, ~, Qstat] = lbqtest(res, 'Lags', min(20, length(res)/4));
```

**自写封装:** `matlab/predict/arima_fit.m` — 整合 ADF 检验 → 自动定阶 (AIC 网格搜索) → 估计 → 预测 → 残差诊断的完整流程。

**自动定阶备选:** `auto_arima` 在 MATLAB 中需自写 — 网格搜索 $(p, q) \in \{0,1,\ldots,5\}^2$，以最小 AIC 为准。

## Python 备选

```python
from statsmodels.tsa.arima.model import ARIMA
import pmdarima as pm

# 方式1: 手动定阶
model = ARIMA(y, order=(p, d, q), seasonal_order=(P, D, Q, s))
result = model.fit()
forecast = result.forecast(steps=horizon)
print(result.summary())

# 方式2: 自动定阶 (推荐)
auto_model = pm.auto_arima(y, seasonal=True, m=s,
                           start_p=0, max_p=5,
                           start_q=0, max_q=5,
                           trace=True, error_action='ignore',
                           suppress_warnings=True, stepwise=True)
preds = auto_model.predict(n_periods=horizon)
```

备选: `statsmodels.tsa.statespace.SARIMAX` (支持外生变量), `sktime` (统一 API)

## 选型决策树

- **用 ARIMA** — 单变量时间序列, n>30, 存在趋势和自相关结构, 无外部解释变量
- **用 SARIMA** — 数据含明显季节性周期 (月/季/周)
- **用 VAR/VARMAX** — 多变量时间序列, 变量间互相影响
- **用 GM(1,1) (PARADIGM-0201)** — 数据极少 (n=4-10), 近似指数趋势
- **用 Holt-Winters (PARADIGM-0203)** — 中短期 (n=10-30), 简单趋势+季节, 更稳健
- **用 LSTM (PARADIGM-0204)** — 大数据 (n>500), 非线性模式, 多变量输入
- **Trade-off:** ARIMA 理论完备, 置信区间可靠, 但要求序列平稳且样本量充足。对短序列/非线性/多变量场景, 根据数据特征选择替代方案。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 折线图 + 趋势/季节/残差分解 (STL) 四子图 | 展示序列整体结构与成分 |
| process | 2×2 子图 — ACF 柱状图 + PACF 柱状图 + 残差时序图 + Q-Q 图 | 定阶 + 模型诊断 |
| result | 折线图 — 历史数据 + 向前预测值 + 95% 置信区间 (shaded area / fan) | 预测与不确定性可视化 |

## 常见坑

1. **非平稳序列未差分:** 直接对非平稳序列建模 → 伪回归 (spurious regression)，预测无意义。**处理:** 先做 ADF 检验，$p>0.05$ 则需差分。
2. **过度差分:** $d$ 过大 → 引入不必要的 MA 结构, 方差增大, 预测精度下降。**处理:** ADF 检验确定最小 $d$, 一般 $d\leq2$。
3. **定阶主观性:** 纯靠 ACF/PACF 目视判别容易出错 (不同人有不同解读)。**处理:** 使用 auto_arima 或 AIC/BIC 网格搜索客观定阶。
4. **残差非白噪声:** 残差仍有自相关结构 → 模型未充分提取信息, Ljung-Box 检验 $p<0.05$ 拒绝白噪声。**处理:** 增加 $p$ 或 $q$, 或考虑非线性模型。
5. **异方差:** 残差方差不恒定 → 置信区间不可靠。**处理:** Box-Cox 变换或 GARCH 建模误差方差。

## 失效条件/反例 (强制小节)

- **条件1: 存在结构断点/制度转换 (regime change)** → ARIMA 参数假设恒定, 断点后预测系统偏倚。**表现:** 断点前后残差符号一致 (正/负), Chow 检验显著, 预测值趋势与实际背离。**替代:** 使用滚动窗口 ARIMA (rolling window) 或马尔可夫机制转换模型 (MS-AR)
- **条件2: 长记忆过程 / 分数阶积分 ($d$ 非整数)** → ARIMA(p,d,q) 整数阶差分无法恰当捕捉长程依赖, 模型欠拟合或过参数化。**表现:** ACF 衰减极慢 (双曲衰减而非指数衰减), AIC 持续递减不收敛。**替代:** ARFIMA 模型 (分数阶差分)
- **条件3: 序列过短 ($n < 20$)** → MLE 估计不可靠, 参数标准误极大, 预测区间虚宽。**表现:** 参数估计值不稳定 (不同子样本估计差异大), 预测区间覆盖范围过宽丧失实用价值。**替代:** 使用 GM(1,1) (PARADIGM-0201) 或指数平滑 (PARADIGM-0203)

## 文献

1. Box, G.E.P., Jenkins, G.M., Reinsel, G.C., & Ljung, G.M. (2015). *Time Series Analysis: Forecasting and Control*, 5th Edition. Wiley. ISBN 978-1118675021.
2. Hyndman, R.J., & Athanasopoulos, G. (2018). *Forecasting: Principles and Practice*, 2nd Edition. OTexts. ISBN 978-0987507117. 在线版: [https://otexts.com/fpp3/](https://otexts.com/fpp3/)

## 来源溯源

- 工具箱路径: MATLAB Econometrics Toolbox `arima` / `estimate` / `forecast`
- 自写封装: `matlab/predict/arima_fit.m`
- 算法起源: Box & Jenkins (1970) *Time Series Analysis: Forecasting and Control*

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (短序列/指数) | PARADIGM-0201 (GM11) |
| 替代 (中短期/季节) | PARADIGM-0203 (指数平滑) |
| 替代 (非线性/大数据) | PARADIGM-0204 (LSTM预测) |
| 组合 (残差建模) | PARADIGM-0201 — 灰色-ARIMA 混合模型 |
| 前置 (平稳性检验) | PARADIGM-1301 (ADF检验) |
