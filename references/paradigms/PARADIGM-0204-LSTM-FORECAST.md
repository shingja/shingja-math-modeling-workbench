# PARADIGM-0204-LSTM-FORECAST LSTM预测⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0204-LSTM-FORECAST |
| 类别/子类 | ②预测 / 深度学习 |
| 难度 | 高 |
| 适用题型关键词[] | LSTM, 长短期记忆, 时间序列预测, 循环神经网络, 深度学习, 序列建模 |
| confidence | high |
| source | matlab/predict/lstm_forecast.m / MATLAB DL Toolbox |

## 数学形式

**LSTM 单个时间步的计算 (LSTM Cell):**

遗忘门 (Forget Gate):
$$f_t = \sigma(\mathbf{W}_f \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_f)$$

输入门 (Input Gate):
$$i_t = \sigma(\mathbf{W}_i \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_i)$$

输出门 (Output Gate):
$$o_t = \sigma(\mathbf{W}_o \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_o)$$

候选记忆单元 (Candidate Cell State):
$$\tilde{\mathbf{c}}_t = \tanh(\mathbf{W}_c \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_c)$$

记忆单元更新 (Cell State Update):
$$\mathbf{c}_t = f_t \odot \mathbf{c}_{t-1} + i_t \odot \tilde{\mathbf{c}}_t$$

隐藏状态输出 (Hidden State):
$$\mathbf{h}_t = o_t \odot \tanh(\mathbf{c}_t)$$

其中:
- $\sigma(x) = \frac{1}{1 + e^{-x}}$ — sigmoid 激活, 输出 $(0,1)$, 控制门开度
- $\tanh(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}$ — tanh 激活, 输出 $(-1,1)$, 编码信息
- $\odot$ — Hadamard 逐元素乘积
- $[\cdot, \cdot]$ — 向量拼接

**训练 — 通过时间的反向传播 (BPTT):**

损失函数 (MSE):
$$\mathcal{L} = \frac{1}{N} \sum_{i=1}^{N} (y_i - \hat{y}_i)^2$$

参数更新 (Adam 优化器):
$$\begin{aligned}
m_t &= \beta_1 m_{t-1} + (1-\beta_1) \nabla \mathcal{L} \\
v_t &= \beta_2 v_{t-1} + (1-\beta_2) (\nabla \mathcal{L})^2 \\
\hat{m}_t &= m_t / (1-\beta_1^t) \\
\hat{v}_t &= v_t / (1-\beta_2^t) \\
\theta_{t+1} &= \theta_t - \eta \cdot \hat{m}_t / (\sqrt{\hat{v}_t} + \epsilon)
\end{aligned}$$

**变量表:**
- $\mathbf{x}_t \in \mathbb{R}^{d_x}$ — $t$ 时刻输入特征向量
- $\mathbf{h}_t \in \mathbb{R}^{d_h}$ — $t$ 时刻隐藏状态 (hidden_size / hidden_units)
- $\mathbf{c}_t \in \mathbb{R}^{d_h}$ — $t$ 时刻记忆单元状态
- $f_t, i_t, o_t \in \mathbb{R}^{d_h}$ — 遗忘门, 输入门, 输出门向量
- $\mathbf{W}_f, \mathbf{W}_i, \mathbf{W}_o, \mathbf{W}_c \in \mathbb{R}^{d_h \times (d_h + d_x)}$ — 各门权重矩阵
- $\mathbf{b}_f, \mathbf{b}_i, \mathbf{b}_o, \mathbf{b}_c \in \mathbb{R}^{d_h}$ — 各门偏置向量
- $\eta$ — 学习率; $\beta_1, \beta_2$ — Adam 动量参数

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| hidden_units | int | 128 | 32-512 | 高 — 过小欠拟合, 过大过拟合 |
| num_layers | int | 2 | 1-5 | 高 — 过深梯度消失, 难训练 |
| max_epochs | int | 200 | 50-1000 | 中 — 超过收敛点无益 |
| learning_rate ($\eta$) | float | 0.001 | 1e-5-0.1 | 高 — 过大不收敛, 过小收敛慢 |
| batch_size | int | 64 | 16-256 | 中 — 影响梯度估计质量 |
| sequence_length (lookback) | int | 24 | 5-200 | 高 — 核心超参, 见常见坑 |
| dropout_rate | float | 0.2 | 0-0.5 | 中 — 正则化防过拟合 |
| 梯度裁剪阈值 | float | 1.0 | 0.5-5.0 | 中 — 防梯度爆炸 |
| 时间复杂度 | — | — | O(max_epochs $\times$ batch_size $\times$ sequence_length $\times$ $d_h^2$) | — |
| 空间复杂度 | — | — | O(num_layers $\times$ $d_h \times$ (sequence_length + batch_size)) | — |

## MATLAB 实现

函数签名:
```matlab
net = lstm_forecast(X_train, Y_train, hidden_units, num_layers, max_epochs);
[pred, CI] = predict(net, X_test);
```

锚点: `matlab/predict/lstm_forecast.m` — 自写实现, 封装 MATLAB Deep Learning Toolbox `lstmLayer` + `trainingOptions` + `trainNetwork`。

核心调用:
```matlab
% 定义 LSTM 网络
layers = [ ...
    sequenceInputLayer(input_size)
    lstmLayer(hidden_units, 'OutputMode', 'sequence')
    dropoutLayer(0.2)
    lstmLayer(hidden_units, 'OutputMode', 'last')
    fullyConnectedLayer(output_size)
    regressionLayer
];

% 训练选项
options = trainingOptions('adam', ...
    'MaxEpochs', max_epochs, ...
    'MiniBatchSize', 64, ...
    'InitialLearnRate', 0.001, ...
    'GradientThreshold', 1, ...
    'Shuffle', 'never', ...
    'Plots', 'training-progress', ...
    'Verbose', 0);

% 训练
net = trainNetwork(X_train, Y_train, layers, options);

% 预测
pred = predict(net, X_test);
```

**数据预处理 (关键):**
```matlab
% 标准化 (z-score)
mu = mean(X_train); sigma = std(X_train);
X_norm = (X - mu) ./ sigma;

% 构建滑动窗口序列
[XTrain_seq, YTrain_seq] = create_sequences(X_norm, Y_norm, sequence_length);
```

**备选:** MATLAB `nlarx` (非线性自回归网络, System Identification Toolbox) 可用于简单非线性预测。

## Python 备选

```python
# TensorFlow/Keras 实现
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

model = Sequential([
    LSTM(128, return_sequences=True, input_shape=(seq_length, n_features)),
    Dropout(0.2),
    LSTM(64, return_sequences=False),
    Dropout(0.2),
    Dense(32, activation='relu'),
    Dense(1)
])

model.compile(optimizer='adam', loss='mse')
history = model.fit(X_train, y_train, epochs=200,
                    batch_size=64, validation_split=0.1,
                    callbacks=[EarlyStopping(patience=15)])

pred = model.predict(X_test)
```

```python
# PyTorch 实现
import torch.nn as nn

class LSTMForecast(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers, output_size):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers,
                            batch_first=True, dropout=0.2)
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out, (h_n, c_n) = self.lstm(x)
        return self.fc(out[:, -1, :])

model = LSTMForecast(input_size=n_features, hidden_size=128,
                     num_layers=2, output_size=1)
```

备选: `darts` (统一时序 API, 支持多种深度学习模型), `sktime` (与 sklearn 兼容)

## 选型决策树

- **用 LSTM** — 大量数据 (n > 500), 存在长程非线性依赖, 多变量输入, 需要捕获复杂时序模式
- **用 ARIMA (PARADIGM-0202)** — 中等样本 (30 < n < 500), 线性自相关为主, 需要统计推断和可靠置信区间
- **用指数平滑 (PARADIGM-0203)** — 短序列 (10 < n < 30), 趋势+季节为主, 追求简单可解释
- **用 GM(1,1) (PARADIGM-0201)** — 极短序列 (4-10), 近似指数趋势
- **用 Transformer** — 超长序列 (>1000 步), 需要全局注意力 (LSTM 的长程依赖能力有限于 200-300 步)
- **用 GRU** — 与 LSTM 效果相近但结构更简单 (门数少), 数据量较小时优先
- **Trade-off:** LSTM 表达能力强但黑箱难解释, 需要大量数据和 GPU, 超参调优成本高。对建模竞赛, 数据足够 (n > 500) 时优先尝试 LSTM, 但始终用 ARIMA/ES 做基线比较。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 多变量时序折线图 (subplot 按特征分) | 展示所有输入特征的时间演化 |
| process | 双曲线图 — training loss + validation loss (epoch 横轴), 下子图 actual vs predicted 散点 overlay | 诊断训练收敛与拟合质量 |
| result | 折线图 — 实际值 + 训练拟合 + 测试多步预测, 预测段加阴影不确定区间 | 对比历史拟合与未来预测 |

## 常见坑

1. **数据量不足 (n < 200):** LSTM 参数量大 (上万个权重), 小样本严重过拟合 — 训练 loss 持续下降但验证 loss 上升。**处理:** 减小 hidden_units (如 16-32), 增大 dropout (0.3-0.5), 使用 GRU 代替 LSTM, 或降级为 ARIMA/ES
2. **未做数据标准化:** 不同特征量级差几个数量级 → 梯度更新耦合, 某些门持续饱和, 梯度爆炸/消失。**处理:** 所有输入特征标准化到 [0,1] (min-max) 或 z-score, 目标变量同理
3. **回溯窗口 (lookback / sequence_length) 选择错误:** 太短 → 无法捕获足够历史信息 (欠拟合); 太长 → 信号稀释且训练缓慢 (过拟合风险)。**处理:** 用偏自相关 (PACF) 确定显著滞后阶数, 或用验证集网格搜索
4. **迭代多步预测的误差累积:** 单步预测精度可接受, 但将预测值反馈为输入做多步预测时误差迅速放大。**处理:** 训练专门的 multi-output 模型 (直接输出多步) 或使用 seq2seq 架构
5. **概念漂移 (concept drift):** 训练时数据模式与测试时不同 (如疫情前后), 模型预测系统偏倚。**处理:** 定期重训练, 或使用在线学习/增量更新

## 失效条件/反例 (强制小节)

- **条件1: 非平稳时间序列未差分** → LSTM 学习到的是数据的条件分布 (非平稳时虚假), 测试集趋势/水平偏移后预测崩溃。**表现:** 训练集拟合很好 (R² > 0.95), 但测试集预测围绕均值振荡, 无法跟踪趋势, R² 接近 0 甚至为负。**处理:** 先用 ADF 检验检查平稳性, 不平稳则差分处理, LSTM 拟合差分后的残差序列 (类似 ARIMA 思想)
- **条件2: 概念漂移 (数据生成过程变化)** → 训练好的 LSTM 在分布外数据上预测精度急剧下降, 残差呈现系统性偏倚 (始终高估或低估)。**表现:** 训练集 MAE 很低, 但部署后 MAE 随时间逐渐增大, 残差不再零均值。**替代:** 实施在线学习 (online learning) 或定期重训练策略; 若漂移剧烈, 改用基于物理的机理模型而非纯数据驱动
- **条件3: 极稀有事例预测 (rare event)** → 目标事件在训练集中占比极低 (如 <1%), LSTM 倾向于"总是预测均值"来最小化 MSE, 对稀有峰值完全失效。**表现:** 预测值几乎是常数 (接近全局均值), 在真实事件爆发时误差极大, 无法预警。**替代:** 使用加权损失函数 (加大事件区间权重) 或改用异常检测 (anomaly detection) 框架; 若事件有统计规律, 考虑 point process 模型

## 文献

1. Hochreiter, S., & Schmidhuber, J. (1997). Long Short-Term Memory. *Neural Computation*, 9(8), 1735-1780. DOI: [10.1162/neco.1997.9.8.1735](https://doi.org/10.1162/neco.1997.9.8.1735)
2. Goodfellow, I., Bengio, Y., & Courville, A. (2016). *Deep Learning*. MIT Press. ISBN 978-0262035613. 在线版: [https://www.deeplearningbook.org/](https://www.deeplearningbook.org/)

## 来源溯源

- 自写实现: `matlab/predict/lstm_forecast.m`
- 工具链: MATLAB Deep Learning Toolbox `lstmLayer` / `trainNetwork`
- 算法起源: Hochreiter & Schmidhuber 1997, LSTM 解决 RNN 的梯度消失/爆炸问题

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (线性/统计推断) | PARADIGM-0202 (ARIMA) |
| 替代 (简单趋势/季节) | PARADIGM-0203 (指数平滑) |
| 替代 (短序列/指数) | PARADIGM-0201 (GM11) |
| 前置 (RNN 基础) | PARADIGM-0301 (RNN) — 建议先理解普通 RNN 再学 LSTM |
| 组合 (混合模型) | PARADIGM-0202 — LSTM-ARIMA 混合 (ARIMA 拟合线性部分, LSTM 拟合残差) |
| 替代 (超长序列) | Transformer (序列到序列注意力, >1000 步) |
