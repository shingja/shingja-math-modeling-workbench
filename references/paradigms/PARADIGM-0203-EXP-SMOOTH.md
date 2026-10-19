# PARADIGM-0203-EXP-SMOOTH 指数平滑(Holt/Holt-Winters)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0203-EXP-SMOOTH |
| 类别/子类 | ②预测 / 时间序列 |
| 难度 | 低 |
| 适用题型关键词[] | 指数平滑, Holt, Holt-Winters, 趋势, 季节性, 加权平均, 平滑系数 |
| confidence | high |
| source | matlab/predict/exponential_smoothing.m |

## 数学形式

**简单指数平滑 (SES) — 仅水平项:**

$$\ell_t = \alpha \cdot y_t + (1-\alpha) \cdot \ell_{t-1}, \quad 0 < \alpha < 1$$

预测: $\hat{y}_{t+h|t} = \ell_t$

**Holt 线性趋势法 — 水平 + 趋势:**

$$\begin{aligned}
\ell_t &= \alpha \cdot y_t + (1-\alpha) \cdot (\ell_{t-1} + b_{t-1}) \\
b_t &= \beta \cdot (\ell_t - \ell_{t-1}) + (1-\beta) \cdot b_{t-1}
\end{aligned}$$

预测: $\hat{y}_{t+h|t} = \ell_t + h \cdot b_t$

**Holt-Winters 加法季节 — 水平 + 趋势 + 季节:**

$$\begin{aligned}
\ell_t &= \alpha \cdot (y_t - s_{t-m}) + (1-\alpha) \cdot (\ell_{t-1} + b_{t-1}) \\
b_t &= \beta \cdot (\ell_t - \ell_{t-1}) + (1-\beta) \cdot b_{t-1} \\
s_t &= \gamma \cdot (y_t - \ell_{t-1} - b_{t-1}) + (1-\gamma) \cdot s_{t-m}
\end{aligned}$$

预测: $\hat{y}_{t+h|t} = \ell_t + h \cdot b_t + s_{t - m + h_m^+}$, 其中 $h_m^+ = \lfloor (h-1) \bmod m \rfloor + 1$

**Holt-Winters 乘法季节 — 比例季节:**

$$\begin{aligned}
\ell_t &= \alpha \cdot \frac{y_t}{s_{t-m}} + (1-\alpha) \cdot (\ell_{t-1} + b_{t-1}) \\
b_t &= \beta \cdot (\ell_t - \ell_{t-1}) + (1-\beta) \cdot b_{t-1} \\
s_t &= \gamma \cdot \frac{y_t}{(\ell_{t-1} + b_{t-1})} + (1-\gamma) \cdot s_{t-m}
\end{aligned}$$

预测: $\hat{y}_{t+h|t} = (\ell_t + h \cdot b_t) \cdot s_{t - m + h_m^+}$

**参数估计:** 平滑系数 $(\alpha, \beta, \gamma)$ 通过最小化一步预测误差平方和 (SSE) 估计:

$$\text{SSE} = \sum_{t=1}^{n} (y_t - \hat{y}_{t|t-1})^2$$

**变量表:**
- $\ell_t$ — $t$ 时刻水平 (level) 分量
- $b_t$ — $t$ 时刻趋势 (trend/slope) 分量
- $s_t$ — $t$ 时刻季节 (seasonal) 分量
- $\alpha$ — 水平平滑系数, 控制新观测对水平的权重
- $\beta$ — 趋势平滑系数, 控制趋势更新速度
- $\gamma$ — 季节平滑系数, 控制季节分量更新速度
- $m$ — 季节周期长度 (如 $m=4$ 季度, $m=12$ 月度, $m=7$ 星期)
- $h$ — 预测步数 (horizon)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| data (时间序列) | double[] | — | 实数, n≥2m | 高 — 乘法模型要求正值 |
| method | string | 'hw_add' | 'ses' / 'holt' / 'hw_add' / 'hw_mult' | 高 — 误选模型导致系统性偏倚 |
| seasonal_period (m) | int | 12 | ≥2 | 高 — 错误周期严重退化 |
| alpha (水平平滑) | float | 最优估计 | (0, 1) | 高 — 过大过拟合噪声, 过小反应迟钝 |
| beta (趋势平滑) | float | 最优估计 | (0, 1) | 中 |
| gamma (季节平滑) | float | 最优估计 | (0, 1) | 中 (仅 H-W 模型) |
| forecast_horizon | int | 1 | 1-2m | 高 — 超出 2m 预测区间爆炸 |
| 时间复杂度 | — | — | O(n) 递归 | — |
| 空间复杂度 | — | — | O(n + m) 存储分量 | — |

## MATLAB 实现

函数签名:
```matlab
[forecast, fitted, alpha, beta, gamma] = exponential_smoothing(data, horizon, method, seasonal_period)
```

锚点: `matlab/predict/exponential_smoothing.m` — 自写完整实现。

核心流程:
```matlab
% method 可选: 'ses' (简单), 'holt' (双参数趋势), 'hw_add' (Holt-Winters加法), 'hw_mult' (Holt-Winters乘法)

switch lower(method)
    case 'ses'
        % 仅估计 alpha
        obj_fun = @(p) sum((data(2:end) - ses_smooth(data(1), p, data)).^2);
        alpha = fminbnd(obj_fun, 0.01, 0.99);
        [~, fitted] = ses_smooth(data(1), alpha, data);
        forecast = fitted(end) * ones(1, horizon);

    case 'holt'
        % 估计 alpha, beta
        obj_fun = @(p) sum((data(3:end) - holt_smooth(data(1), data(2)-data(1), p(1), p(2), data)).^2);
        p_opt = fminsearch(obj_fun, [0.3, 0.1]);
        [~, fitted] = holt_smooth(data(1), data(2)-data(1), p_opt(1), p_opt(2), data);
        % ... 向前预测

    case {'hw_add', 'hw_mult'}
        % 估计 alpha, beta, gamma, 初始季节分量用前 m 期均值法
        % ... 完整 Holt-Winters 三参数估计
end
```

初始值设定: $\ell_0 = y_1$, $b_0 = y_2 - y_1$, $s_{-m+1:t=0}$ 由前 $m$ 期距平法初始化。

## Python 备选

```python
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# 加法 Holt-Winters
model = ExponentialSmoothing(y, seasonal_periods=m, trend='add', seasonal='add')
result = model.fit(optimized=True)
forecast = result.forecast(steps=horizon)
print(result.summary())

# 乘法 Holt-Winters (要求 y > 0)
model_mult = ExponentialSmoothing(y_positive, seasonal_periods=m,
                                   trend='add', seasonal='mul')
result_mult = model_mult.fit()
forecast_mult = result_mult.forecast(steps=horizon)
```

备选: `statsmodels.tsa.holtwinters.SimpleExpSmoothing` (SES), `statsmodels.tsa.holtwinters.Holt` (Holt)

## 选型决策树

- **用 SES** — 数据无明显趋势和季节, 围绕水平随机波动
- **用 Holt** — 数据有线性趋势但无季节
- **用 Holt-Winters 加法** — 趋势 + 季节, 季节幅度不随水平变化 (季节波动绝对量恒定)
- **用 Holt-Winters 乘法** — 趋势 + 季节, 季节幅度随水平增长 (季节波动比例恒定)
- **用 ARIMA (PARADIGM-0202)** — 数据量充足 (n>30), 自相关结构复杂, 需要可靠置信区间
- **用 GM(1,1) (PARADIGM-0201)** — 数据极少 (n=4-10), 近似纯指数趋势
- **用 LSTM (PARADIGM-0204)** — 大数据量 (n>500), 非线性模式
- **用 TBATS** — 多季节周期 (如日+周) — 超出 Holt-Winters 能力
- **Trade-off:** 指数平滑比 ARIMA 更稳健 (对短序列和小参数变化不敏感), 实现更简单, 但缺乏严格的统计推断框架, 置信区间依赖状态空间近似。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 折线图 — 原始时序 | 直观展示数据形态 |
| process | 3/4 子图 (subplot) — 原始 + 拟合 (overlay) + 分量分解 (水平/趋势/季节) | 评估各分量估计质量 |
| result | 折线图 — 历史 + 拟合 + 预测 + 预测区间 (shaded) | 突出预测趋势 |

## 常见坑

1. **初始值设置不当:** $\ell_0, b_0, s_0$ 的初始值对早期拟合影响大, 简单取法 (如首观测值) 导致前几期残差偏大。**处理:** 使用前几个完整季节周期的平均值作为初始值, 或使用优化方法估计初始值
2. **季节周期 $m$ 判断错误:** 错误周期 (如月度数据设 $m=4$) 导致季节分量完全错误。**处理:** 使用 ACF 图或频谱分析确定周期, 或尝试多个 $m$ 比较 AIC
3. **乘法模型遇零/负值:** Holt-Winters 乘法要求 $y_t > 0$, 零值导致除法无定义, 负值导致符号翻转。**处理:** 使用加法模型代替
4. **长步预测发散:** 预测区间随 $h$ 增大呈喇叭形扩张, $h > m$ 时预测值趋于线性外推。**处理:** 将预测用途限制在短期 ($h \leq m$)
5. **平滑系数边界:** $\alpha \to 1$ 退化为朴素预测 (naive), $\alpha \to 0$ 退化为均值预测。**处理:** 始终使用优化估计而非手动设定

## 失效条件/反例 (强制小节)

- **条件1: 存在多个季节周期 (如日周期 + 周周期)** → 单一 Holt-Winters 只能捕获一个季节周期, 另一周期残差呈现明显自相关。**表现:** 残差 ACF 在另一周期处出现显著尖峰, 预测系统性偏倚。**替代:** 使用 TBATS 模型 (支持多周期) 或 STL 分解 + 分步预测
- **条件2: 长期预测 ($h > 2m$)** → 预测间隔急剧膨胀 (指数平滑缺乏长期均值回归机制), 趋势线性外推在长期不可靠。**表现:** 预测在 2-3 个季节周期后与真实值的偏离超过 50%, 置信区间宽至丧失实用价值。**替代:** 转为情景分析 (scenario-based) 或使用带外生变量的因果模型 (regression with ARIMA errors)
- **条件3: 数据包含结构性突变 (level shift 或 trend change)** → 平滑系数在突变后需长时间适应, 突变期间预测严重滞后。**表现:** 突变点后若干期残差符号一致为正 (或负), 预测值"追赶"真实值。**替代:** 使用阻尼趋势 (damped trend) 或考虑 intervention model

## 文献

1. Hyndman, R.J., Koehler, A.B., Ord, J.K., & Snyder, R.D. (2008). *Forecasting with Exponential Smoothing: The State Space Approach*. Springer. ISBN 978-3540719168. DOI: [10.1007/978-3-540-71918-2](https://doi.org/10.1007/978-3-540-71918-2)
2. Hyndman, R.J., & Athanasopoulos, G. (2018). *Forecasting: Principles and Practice*, 2nd Edition. OTexts. ISBN 978-0987507117. 在线版: [https://otexts.com/fpp3/](https://otexts.com/fpp3/)

## 来源溯源

- 自写实现: `matlab/predict/exponential_smoothing.m`
- 算法起源: Holt (1957) "Forecasting seasonals and trends by exponentially weighted moving averages", Winters (1960) "Forecasting sales by exponentially weighted moving averages"

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (长序列/统计推断) | PARADIGM-0202 (ARIMA) |
| 替代 (短序列/指数趋势) | PARADIGM-0201 (GM11) |
| 替代 (大数据/非线性) | PARADIGM-0204 (LSTM预测) |
| 组合 (残差建模) | PARADIGM-0202 — ES 去趋势/去季节后 ARIMA 拟合残差 |
