# PARADIGM-0713 GA优化LSTM混合⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0713 |
| 类别/子类 | ⑦综合 / 深度学习混合优化 |
| 难度 | 高 |
| 适用题型关键词[] | GA-LSTM, 遗传算法, LSTM, 超参数优化, 时间序列预测, 混合模型, 培训模块23 |
| confidence | medium |
| source | 培训模块23 GA-LSTM; GA: Holland; LSTM: Hochreiter & Schmidhuber (1997) |

## 数学形式

**阶段 1: 遗传算法优化 LSTM 超参数**

染色体编码: $[h, lr, b, d, e]$
- $h$ — 隐藏单元数 (如 [16, 256] 取整)
- $lr$ — 学习率 (如 [1e-5, 1e-1] log10 编码)
- $b$ — batch size (如 {16, 32, 64, 128})
- $d$ — dropout rate (如 [0, 0.5])
- $e$ — epochs

**适应度:** 验证集上的 MSE/MAE

**选择/交叉/变异:** 标准 GA 操作 (见 PARADIGM-0105)

**阶段 2: LSTM**

遗忘门: $f_t = \sigma(W_f \cdot [h_{t-1}, x_t] + b_f)$
输入门: $i_t = \sigma(W_i \cdot [h_{t-1}, x_t] + b_i)$
候选记忆: $\tilde{C}_t = \tanh(W_C \cdot [h_{t-1}, x_t] + b_C)$
记忆更新: $C_t = f_t \odot C_{t-1} + i_t \odot \tilde{C}_t$
输出门: $o_t = \sigma(W_o \cdot [h_{t-1}, x_t] + b_o)$
隐藏状态: $h_t = o_t \odot \tanh(C_t)$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| pop_size | int | 20 | [10, 50] | 高 — 每代开销大 |
| n_generations | int | 15 | [5, 50] | 高 — 总评估=LSTM训练×pop×gen |
| hidden_units_range | [int,int] | [16,256] | — | 极高 |
| learning_rate_range | [low,high] | [1e-5,1e-1] | — | 极高 |
| 单次 LSTM 训练时间 | — | — | 秒~分钟级 | — 决定总耗时 |

## MATLAB 实现

```matlab
% MATLAB Deep Learning Toolbox
% 定义 LSTM 网络结构
layers = [
    sequenceInputLayer(n_features)
    lstmLayer(hidden_units, 'OutputMode', 'sequence')
    dropoutLayer(dropout_rate)
    fullyConnectedLayer(1)
    regressionLayer
];

options = trainingOptions('adam', ...
    'MaxEpochs', epochs, ...
    'MiniBatchSize', batch_size, ...
    'InitialLearnRate', lr, ...
    'Plots', 'none', 'Verbose', false);

net = trainNetwork(X_train, Y_train, layers, options);
```

锚点: Python备选-见S5 (MATLAB 的 trainNetwork + lstmLayer 可用于固定结构，但 GA 超参数搜索开销大 → 推荐 Python 多进程并行)

## Python 备选

```python
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dropout, Dense
import numpy as np

# GA (使用 DEAP 库)
from deap import base, creator, tools, algorithms

def evaluate_individual(individual):
    h, lr, b, d = individual
    model = Sequential([
        LSTM(int(h), return_sequences=True, input_shape=(T, p)),
        Dropout(d),
        LSTM(int(h//2)),
        Dropout(d),
        Dense(1)
    ])
    model.compile(optimizer=tf.keras.optimizers.Adam(lr), loss='mse')
    model.fit(X_train, y_train, epochs=50, batch_size=int(b),
              validation_data=(X_val, y_val), verbose=0)
    y_pred = model.predict(X_test)
    mse = np.mean((y_test - y_pred)**2)
    return (mse,)
```

## 选型决策树

- **GA-LSTM** — 需要同时优化 LSTM 的架构和学习超参数
- **Grid Search LSTM** — 超参数范围小 (如仅调 lr 和 batch) → 网格搜索更可控
- **Bayesian Opt LSTM** — 训练费时 (如大数据) → 贝叶斯优化采样更少
- **AutoML / NAS** — 需要全自动神经架构搜索 (如 AutoKeras)
- **不要用 GA-LSTM** — 小样本时序 (n<500) → LSTM 本身已不适合，用传统时序模型

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | GA 适应度下降曲线 | 每代最佳/平均适应度 |
| result | 预测 vs 真实 (时序重叠图) | 多步预测对比 |
| result | 最优 LSTM 结构图 | 层/单元可视化 |

## 常见坑

1. **GA 评估 LSTM 极慢**: pop 20 × gen 15 × LSTM 训练 5min = 25 小时 → 用早停 (early stopping) + 减少 epochs + 并行评估
2. **随机种子影响大**: LSTM 的训练随机性 (初始化+dropout+shuffle) → 同一超参数的两次评估 MSE 差异大 → 对同一染色体评估 3 次取平均
3. **过拟合检测**: GA 可能在验证集上过拟合 (调参过拟合) → 保留 hold-out test set 不做 GA 适应度计算

## 失效条件/反例 (强制小节)

- **条件1: 样本量 n < 500 时用 GA-LSTM** → 表现: LSTM 需要大量数据训练 (n>1000 才稳定)，小样本下同超参数两次训练的 MSE 相差可 >50% — GA 的适应度景观被噪声主导，遗传搜索无法有效区分优劣个体。**应对**: 小样本使用 ARIMA/Holt-Winters 等传统时序模型，或迁移学习 (预训练 LSTM + fine-tune)
- **条件2: 无 GPU 环境 + 大数据** → 表现: CPU 训练 LSTM 极慢 (每代 pop_size × 训练时间)，全流程可能耗时数十小时，建模竞赛时间不允许。**应对**: 使用 XGBoost/LightGBM (PARADIGM-0206) 替代，或使用仅调少量参数的固定 LSTM 结构

## 文献

1. Hochreiter S. & Schmidhuber J. (1997). "Long short-term memory." *Neural Computation*, 9(8):1735-1780. DOI: [10.1162/neco.1997.9.8.1735](https://doi.org/10.1162/neco.1997.9.8.1735)
2. Holland J.H. (1992). *Adaptation in Natural and Artificial Systems*, 2nd ed. MIT Press. ISBN: 978-0262581110

## 来源溯源

Python备选-见S5; 培训模块23 GA-LSTM

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0105 (GA) |
| 前置 | PARADIGM-0204 (LSTM) |
| 替代 | PARADIGM-0712 (GWO-SVR) |
| 替代 | PARADIGM-0206 (XGBoost/LightGBM) |
