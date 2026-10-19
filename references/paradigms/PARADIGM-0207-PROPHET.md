# PARADIGM-0207 Prophet 时间序列预测⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0207 |
| 类别/子类 | ②预测 / 时间序列分解 |
| 难度 | 低 |
| 适用题型关键词[] | Prophet, Facebook, 加法模型, 趋势, 季节性, 节假日效应, 变点检测, 时间序列预测, 日度数据, 周期性预测, 业务预测, 缺失值自动处理 |
| confidence | medium |
| source | Taylor, S. J., & Letham, B. (2018). "Forecasting at scale." The American Statistician, 72(1), 37-45. |

## 数学形式

### 加法分解模型

Prophet 将时间序列 $y(t)$ 分解为三个可解释成分的加法：

$$y(t) = g(t) + s(t) + h(t) + \varepsilon_t,\quad \varepsilon_t \sim \mathcal{N}(0, \sigma^2)$$

**1. 趋势项 $g(t)$ — 分段逻辑/线性增长**

*线性趋势 (默认, 适用于非饱和增长)*：

$$g(t) = (k + \mathbf{a}(t)^T\boldsymbol{\delta}) \cdot t + (m + \mathbf{a}(t)^T\boldsymbol{\gamma})$$

- $k$: 基础增长率
- $\boldsymbol{\delta} \in \mathbb{R}^S$: S 个变点处的增长率变化向量 ($\delta_j \sim \text{Laplace}(0, \tau)$)
- $\mathbf{a}(t) \in \{0,1\}^S$: 指示向量, $a_j(t) = 1$ 若 $t \geq$ 第 j 个变点
- $\boldsymbol{\gamma}$ 使趋势连续: $\gamma_j = -s_j\delta_j$ (调整偏移量)
- $\tau$ (changepoint_prior_scale): 控制变点灵活度的超参数

*逻辑趋势 (适用于饱和增长, 如市场渗透)*：

$$g(t) = \frac{C(t)}{1 + \exp(-(k + \mathbf{a}(t)^T\boldsymbol{\delta})(t - (m + \mathbf{a}(t)^T\boldsymbol{\gamma})))}$$

$C(t)$ 为随时间变化的饱和容量 (carrying capacity)。

**2. 季节项 $s(t)$ — 傅里叶级数建模**

$$s(t) = \sum_{n=1}^{N} \left(a_n \cos\left(\frac{2\pi n t}{P}\right) + b_n \sin\left(\frac{2\pi n t}{P}\right)\right)$$

- $P$: 周期 (365.25 年季节性, 7 周季节性, 1 日季节性)
- $N$: 傅里叶阶数 (默认年 N=10, 周 N=3, 日 N=4)
- $\beta = [a_1, b_1, \ldots, a_N, b_N]^T$ 服从 $\beta \sim \mathcal{N}(0, \sigma^2)$ (seasonality_prior_scale 控制)
- 多个季节项叠加: $s_{yearly}(t) + s_{weekly}(t) + s_{daily}(t)$

**3. 节假日效应 $h(t)$ — 哑变量回归**

$$h(t) = Z(t)\boldsymbol{\kappa} = \sum_{i=1}^{L} \kappa_i \cdot \mathbb{1}_{[t \in D_i]}$$

- $D_i$: 第 i 个节假日窗口 (含前后影响的日期集合, 如 春节 [-3, +3] 天)
- $\kappa_i$: 第 i 个节假日效应量 ($\kappa_i \sim \mathcal{N}(0, \nu^2)$)
- $\nu$ (holidays_prior_scale): 控制节假日效应强度的超参数

### 参数估计 (Stan 概率编程 / L-BFGS)

Prophet 采用贝叶斯框架，所有参数联合优化 MAP (Maximum a Posteriori)：

$$\max_{\theta} \underbrace{\log p(\mathbf{y}|\theta)}_{\text{似然}} + \underbrace{\log p(\theta)}_{\text{Laplace/正态先验}}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| changepoint_prior_scale (τ) | double | 0.05 | [0.001, 0.5] | 极高 — 大值趋势更灵活, 易过拟合噪声 |
| seasonality_prior_scale (σ) | double | 10.0 | [0.01, 100] | 高 — 大值季节波动幅度更大 |
| holidays_prior_scale (ν) | double | 10.0 | [0.01, 100] | 中 — 仅节假日数据非零时敏感 |
| seasonality_mode | string | 'additive' | 'additive'/'multiplicative' | 高 — 乘性适合季节振幅随时间增大 |
| n_changepoints | int | 25 | 0~50 | 中 — 0=禁用趋势变点; 大值趋势分段多 |
| changepoint_range | double | 0.8 | [0, 1] | 中 — 0.8=仅前80%历史含变点, 后20%趋势外推 |
| yearly_seasonality (N_y) | int/bool | 'auto' (N=10) | 0~20 | 中 — N=0关闭年周期; N>10可捕获精细年模式 |
| weekly_seasonality (N_w) | int/bool | 'auto' (N=3) | 0~6 | 低 — 日度以上频率建议开启 |
| daily_seasonality (N_d) | int/bool | 'auto' (N=4) | 0~8 | 低 — 仅小时级数据需要 |
| uncertainty_samples | int | 1000 | 100~5000 | 低 — 影响不确定性区间宽度精度 |
| growth | string | 'linear' | 'linear'/'logistic' | 高 — logistic 需指定 cap (饱和值) |
| 训练复杂度 | — | O(L-BFGS 迭代 x n) | n=历史点数 | 极快, 秒级 (n~10^5 仍秒级) |
| 预测复杂度 | — | O(n_future x N_season) | — | 闭式前向计算, 瞬时 |

**量纲注意**：输入数据必须为两列 DataFrame: `ds` (datetime 类型) + `y` (数值类型)。ds 为 Prophet 特有的列名要求。y 建议在合理数值范围 (避免极大/极小导致数值不稳定)。缺失值 (NaN) 可自动处理, 不需填充。

## MATLAB 实现

```matlab
%% ===== Prophet 在 MATLAB 中的路径 =====
% MATLAB 无原生 Prophet (2024b), 三种路线:

% 路线1: 自写分解 (推荐建模竞赛)
% 使用自写-见S5:prophet_predict.m
addpath('路径到自写');

[forecast, components] = prophet_predict(dates, values, forecast_periods, ...
    'changepoint_prior_scale', 0.05, ...
    'seasonality_prior_scale', 10, ...
    'yearly_seasonality', true, ...
    'weekly_seasonality', true, ...
    'plot', true);

% 路线2: Python 回调 (高精度, 但依赖环境)
% 保存数据 -> 调用 Python Prophet -> 读回结果
% 详见 Python备选

% 路线3: 简化手动分解 (教学/理解用)
% 1. LOESS 提取趋势 (smooth)
% 2. 季节分解 (STL 或 X11)
% 3. 节假日哑变量回归
% 4. 残差建模

%% ===== 自写简化 Prophet 核心逻辑 (教学用) =====
function [y_forecast, trend, seasonal, holiday] = simple_prophet(dates, y, periods)
    n = length(y);
    t = (1:n)';

    % 1. 趋势提取: 变点检测 + 分段线性回归
    % 使用 findchangepts (Signal Processing Toolbox)
    cp = findchangepts(y, 'MaxNumChanges', 10, 'MinDistance', ceil(n*0.05));
    trend = piecewise_linear_trend(y, cp);

    % 2. 季节分解: 傅里叶级数拟合残差
    residual = y - trend;
    N_harmonics = 10;  % 年季节性傅里叶阶数
    P = 365;  % 周期 (天)
    seasonal = fit_fourier(residual, N_harmonics, P);

    % 3. 外推预测
    t_future = (n+1:n+periods)';
    trend_future = extrapolate_trend(trend, cp, periods);
    seasonal_future = seasonal(t_future);  % 周期性重复

    y_forecast = trend_future + seasonal_future;
end

%% ===== STL 分解备选 (MATLAB 原生方式) =====
% 使用 trenddecomp (Econometrics Toolbox, R2021b+)
% trenddecomp 提供多种趋势提取方法
try
    [T, S] = trenddecomp(y, 'STL', 12);  % 12=周期
    residual = y - T - S;

    % STL 输出可直接可视化
    figure;
    subplot(4,1,1); plot(dates, y); title('原始序列');
    subplot(4,1,2); plot(dates, T); title('趋势 (STL)');
    subplot(4,1,3); plot(dates, S); title('季节项 (STL)');
    subplot(4,1,4); plot(dates, residual); title('残差');
catch
    warning('trenddecomp 不可用, 改用 smooth + 周期平均');
end
```

## Python 备选

```python
# Python备选-见S5:prophet_predict.py
# pip install prophet (或 pip install fbprophet)

import pandas as pd
from prophet import Prophet
import matplotlib.pyplot as plt

# 数据准备 (列名必须为 ds, y)
df = pd.DataFrame({'ds': pd.to_datetime(dates), 'y': values})

# 创建模型
model = Prophet(
    growth='linear',                # 线性趋势 (默认)
    changepoint_prior_scale=0.05,   # 趋势灵活性
    seasonality_prior_scale=10.0,   # 季节强度
    holidays_prior_scale=10.0,      # 节假日效应强度
    seasonality_mode='additive',    # 加法模式
    yearly_seasonality='auto',      # 自动检测年周期
    weekly_seasonality='auto',
    daily_seasonality='auto',
    n_changepoints=25,              # 变点数
    changepoint_range=0.8,          # 变点历史范围
    uncertainty_samples=1000        # 不确定性采样数
)

# 添加中国节假日 (建模竞赛常用)
cn_holidays = pd.DataFrame({
    'holiday': 'spring_festival',
    'ds': pd.to_datetime(['2024-02-10', '2025-01-29']),
    'lower_window': -3,   # 前 3 天影响
    'upper_window': 4,    # 后 4 天影响
})
model.add_country_holidays(country_name='CN')  # 内置中国节假日

model.fit(df)

# 未来预测
future = model.make_future_dataframe(periods=365)  # 预测未来 365 天
forecast = model.predict(future)

# 输出: forecast['yhat'] (预测值), forecast['yhat_lower']/['yhat_upper'] (不确定性区间)

# 分解可视化
model.plot(forecast)       # 总预测 + 不确定性区间
model.plot_components(forecast)  # 趋势 + 各季节项 + 节假日效应分解

# 交叉验证
from prophet.diagnostics import cross_validation, performance_metrics
df_cv = cross_validation(model, initial='730 days', period='180 days', horizon='365 days')
df_metrics = performance_metrics(df_cv)  # MSE, RMSE, MAE, MAPE, MDAPE, SMAPE 等
```

## 选型决策树

```
问题: 单变量时间序列预测
│
├── 数据频率？
│   ├── 年度/月/周/日 → Prophet ✓ (设计初衷)
│   ├── 小时级 → Prophet 可选 (daily_seasonality=true)
│   └── 分钟/秒级 → ARIMA/LSTM (PARADIGM-0209/0210), Prophet 不支持
│
├── 数据特征？
│   ├── 明显趋势 + 强周期 (如电商日销售额, 年+周+节假日) → Prophet ✓ (最佳场景)
│   ├── 有节假日/事件效应 (如春节、双十一) → Prophet ✓ (原生节假日建模)
│   ├── 多季节模式叠加 (如年+周+日) → Prophet ✓ (傅里叶级数多周期叠加)
│   ├── 趋势有结构突变 (如疫情前后消费) → Prophet ✓ (自动变点检测)
│   ├── 纯白噪声/无趋势无周期 → Prophet 会过分解 (见失效条件)
│   └── 存在缺失值/不规则间隔 → Prophet ✓ (不需要等间隔, 自动处理 NaN)
│
├── 复杂度要求？
│   ├── 快速基线 + 可解释 → Prophet ✓ (3行代码, 组件分解可解释)
│   ├── 最高精度竞赛 → 考虑集成 Prophet+ARIMA+LGBM (多模型融合)
│   └── 需要外生变量 → 不能纯用 Prophet (见失效条件)
│
└── 预测区间？
    ├── 短期预测 (1~2 周期) → Prophet 表现最佳
    └── 超长期预测 (>10 周期, 趋势外推主导) → 不确定性大, 需保守 changepoint_range 参数
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 数据探索 | 原始序列折线图 (ds vs y) | 初步判断趋势/周期/异常点 |
| 预测结果 | 预测区间折线图 | 历史(黑点) + 预测(蓝线) + 不确定性带(蓝色阴影) |
| 模型解释 | 分解面板图 (Trend, Yearly, Weekly, Holidays) | 4 子图展示各成分贡献 |
| 模型诊断 | 变点标记图 (趋势线 + 红色虚线变点位置) | 验证变点对应历史事件 |
| 验证诊断 | 残差 vs ds 散点图 | 零线随机分布=良好; 结构化=有未建模信息 |
| 预测评估 | 回测覆盖图 (历史预测叠加) | 不同 cutoff 点的 horizon 预测叠加 |
| 竞赛对比 | 多模型预测线对比 (Prophet vs ARIMA vs ETS vs LSTM) | 比赛用美观布局 |

## 常见坑

1. **未设置 changepoint_range < 1.0**：默认 0.8 意味着最后 20% 历史不置变点 (趋势外推)。如果最后阶段有重大变化 (如最近的政策改变) 且你期望趋势调整, 将 changepoint_range 设为 1.0 允许全区间变点。
2. **seasonality_mode 选错**：波动幅度随时间增大 (如销售额随规模增长) → multiplicative；幅度稳定 → additive。判断标准: 早期和晚期的波动幅度比例 >2 倍 → multiplicative。
3. **节假日窗口未设**：仅标记当天 (lower_window=0, upper_window=0) 遗漏了节前/节后效应 (如春节的返乡-返程, 双十一预售-爆发-返场)。建议 春节前后 5 天, 双十一前 3 天后 2 天。
4. **changepoint_prior_scale 过大 → 趋势过拟合**：默认 0.05 已经比较保守。若值 ≥0.5, 趋势会"追踪"每个短期波动, 失去外推能力。建议 0.001 (刚性) ~ 0.5 (灵活) 内网格搜索。
5. **多季节 Fourier 阶数不足**：默认 yearly N=10 适合正常年周期。若数据有双峰年模式 (如春季+秋季两个高峰), 提高 N 到 15~20 以捕获更复杂形状。
6. **Prophet 预测的 yhat_lower 可能 < 0**：若原序列为正 (如销量), 用 logical growth + floor cap 或预测后裁剪 `max(0, yhat)`。
7. **不确定性区间只在趋势上**：Prophet 不确定性仅来源于趋势 (changepoint 采样), 不包含季节/残差的不确定性 — 因此预测区间可能偏窄。可按需扩宽或附加残差自举 (bootstrapping residuals)。

## 失效条件/反例 (强制小节)

- **条件1: 无趋势 + 无季节的纯白噪声序列 (如对数收益率、已一阶差分后的平稳序列)** → Prophet 的分解假设会导致模型强行将白噪声分解为虚构的趋势和季节项, 产生虚假"规律"且预测区间过宽。应改用 ARIMA (PARADIGM-0209) 或直接报告均值/方差 (白噪声最优预测是历史均值)。辨别方法: ADF 检验 p<0.01 且 ACF/PACF 结尾 → 白噪声/低阶 MA。

- **条件2: 序列受多个外生变量强驱动 (如股价受指数/财报/舆情影响, 气温受气压/湿度/日照影响)** → Prophet 是纯粹的单变量自回归分解模型, 无输入变量接口。此场景预测精度远低于带外生变量的 ARIMAX 或机器学习多变量模型 (XGBoost/LightGBM 含 lag features + 外生变量)。若仍需用 Prophet 风格, 考虑叠加回归: 先用 XGBoost 拟合外生变量权重, 再对残差用 Prophet 做季节分解。

- **条件3: 高频数据 (分钟/秒级)** → Prophet 设计的季节组分最高为日周期 (daily_seasonality)。分钟级数据中常见的日内多模态 (如早晚高峰)、跨天模式变化、非整数周期 (如 60 分钟 vs 按小时分段), Prophet 无法有效建模。此场景需: ARIMA/SARIMA (分钟到小时级) 或 LSTM/Seq2Seq (秒级, PARADIGM-0210)。

- **条件4: 历史长度 < 2 个主导周期** → 若数据长度不足 (如仅有 1 年日数据却要预测年周期), 傅里叶基函数因观测不足而无法正确拟合季节形态, 导致外推季节失真。更致命的是: changepoint 会在数据末端产生"趋势拐点幻觉"。此场景应改用 Holt-Winters (ETS) 或 naive/drift 方法。

## 文献

1. Taylor, S. J., & Letham, B. (2018). Forecasting at scale. *The American Statistician*, 72(1), 37-45. (Prophet 原始论文, 核心参考文献)
2. Harvey, A. C., & Peters, S. (1990). Estimation procedures for structural time series models. *Journal of Forecasting*, 9(2), 89-108. (结构时间序列 STL 理论基础)
3. Cleveland, R. B., Cleveland, W. S., McRae, J. E., & Terpenning, I. (1990). STL: A seasonal-trend decomposition procedure based on Loess. *Journal of Official Statistics*, 6(1), 3-73. (STL 分解原始文献)
4. Facebook (Meta) Prophet 官方文档: https://facebook.github.io/prophet/
5. Hyndman, R. J., & Athanasopoulos, G. (2018). *Forecasting: Principles and Practice*, 2nd edition. OTexts. (时间序列经典教材, Ch.12 讨论 Prophet)

## 来源溯源

- **理论根源**: Harvey & Peters (1990) 结构时间序列模型 (观测方程 + 状态转移), 结合贝叶斯先验化 → Prophet 的 MAP 估计
- **工程创新**: Facebook Core Data Science 团队 2017 年开源, 初衷为解决业务分析师"一键跑预测"的需求 — 自动化变点检测 + 季节 + 节假日, 参数全有业务语义
- **设计哲学**: 分析师友好 (Analyst-in-the-loop) — 参数不是晦涩的 AR/MA 阶数, 而是"趋势灵活性""季节强度"等业务人员可理解的量; 分解令业务解释直观
- **替代对比**: ETS (指数平滑) / ARIMA 是统计经典, 参数诠释严格但需要业务翻译; Prophet 直接输出趋势/季节/节假日效应, 牺牲部分统计严格性换取可解释性
- **概率编程**: 底层使用 Stan (probabilistic programming language), 提供后验不确定性。但也可用 L-BFGS 优化器做纯点估计 (无 MCMC 采样) 以提高速度

## 关联范式卡

| 关系 | ID |
|------|-----|
| 同为时间序列预测, 经典统计方法 | PARADIGM-0209 (ARIMA/SARIMA) |
| 同为时间序列预测, 深度学习 | PARADIGM-0210 (LSTM时序预测) |
| 多变量输入替代 | PARADIGM-0206 (XGBoost/LightGBM) |
| 经济计量时间序列补充 | PARADIGM-0208 (ARIMAX/VAR) |
| 数据预处理 (缺失值/异常检测) | PARADIGM-0402 (时序数据清洗) |
| 季节性检验 (增强Diagnosis) | PARADIGM-0403 (ADF/季节型检验) |
| 多模型融合/Stacking | PARADIGM-0501 (模型集成) |
