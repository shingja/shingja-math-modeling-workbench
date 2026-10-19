# PARADIGM-0201-GM11 灰色预测GM(1,1)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0201-GM11 |
| 类别/子类 | ②预测 / 灰色系统 |
| 难度 | 低 |
| 适用题型关键词[] | 灰色预测, GM(1,1), 小样本预测, 累加生成, 灰色模型, 指数趋势, 时间序列 |
| confidence | high |
| source | 培训模块10 / matlab/predict/gm11.m |

## 数学形式

**原始序列与1-AGO:**

设原始非负序列 $X^{(0)} = \{x^{(0)}(1), x^{(0)}(2), \ldots, x^{(0)}(n)\}$，对其进行一次累加生成 (1-AGO):

$$X^{(1)}(k) = \sum_{i=1}^{k} X^{(0)}(i), \quad k = 1, 2, \ldots, n$$

**白化方程 (Whitening Equation):**

$$\frac{dX^{(1)}}{dt} + a \cdot X^{(1)} = b$$

其中 $a$ 为发展系数 (development coefficient)，$b$ 为灰作用量 (grey action quantity)。

**参数估计 (最小二乘法):**

$$\begin{bmatrix} a \\ b \end{bmatrix} = (\mathbf{B}^T \mathbf{B})^{-1} \mathbf{B}^T \mathbf{Y}$$

其中:

$$\mathbf{B} = \begin{bmatrix}
-\frac{1}{2}[X^{(1)}(1) + X^{(1)}(2)] & 1 \\
-\frac{1}{2}[X^{(1)}(2) + X^{(1)}(3)] & 1 \\
\vdots & \vdots \\
-\frac{1}{2}[X^{(1)}(n-1) + X^{(1)}(n)] & 1
\end{bmatrix}, \quad
\mathbf{Y} = \begin{bmatrix} X^{(0)}(2) \\ X^{(0)}(3) \\ \vdots \\ X^{(0)}(n) \end{bmatrix}$$

**预测公式 (时间响应函数):**

$$\hat{X}^{(1)}(k+1) = \left(X^{(0)}(1) - \frac{b}{a}\right) \cdot e^{-ak} + \frac{b}{a}, \quad k = 0, 1, 2, \ldots$$

**逆累加还原 (Inverse AGO):**

$$\hat{X}^{(0)}(k+1) = \hat{X}^{(1)}(k+1) - \hat{X}^{(1)}(k) = (1 - e^{a})\left(X^{(0)}(1) - \frac{b}{a}\right) \cdot e^{-ak}$$

**变量表:**
- $X^{(0)}$ — 原始非负序列
- $X^{(1)}$ — 一次累加生成序列 (1-AGO)
- $a$ — 发展系数, 控制模型增长/衰减趋势; $-a \leq 0.3$ 适合中长期预测, $0.3 < -a \leq 0.5$ 仅适合短期, $-a > 0.5$ 不宜预测
- $b$ — 灰作用量, 反映数据变化的外部驱动
- $\mathbf{B}$ — 数据矩阵, $n-1$ 行 × 2 列
- $\mathbf{Y}$ — 数据向量

**精度检验:**
- 残差检验: $\varepsilon(k) = \frac{|X^{(0)}(k) - \hat{X}^{(0)}(k)|}{X^{(0)}(k)} \times 100\%$
- 后验差比值: $C = S_2 / S_1$, 其中 $S_1$ 为原始序列标准差, $S_2$ 为残差标准差
- 小误差概率: $P = P\{|\varepsilon(k) - \bar{\varepsilon}| < 0.6745 S_1\}$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| data (原始序列) | double[] | — | 非负实数, n≥4 | 高 — 数据必须非负且近似指数 |
| forecast_horizon | int | 1 | 1-5 | 高 — 预测步长越大误差越大 |
| 级比检验阈值 | double | (e^{-2/(n+1)}, e^{2/(n+1)}) | — | 中 — 不通过则需平移变换 |
| a (发展系数) | double | 估计值 | |a| < 2 | 高 — 超范围模型失效 |
| 时间复杂度 | — | — | O(n) 参数估计 | — |
| 空间复杂度 | — | — | O(n) | — |

## MATLAB 实现

函数签名:
```matlab
[predictions, a, b, relative_err] = gm11(data, forecast_horizon)
```

锚点: `matlab/predict/gm11.m` — 自写实现，包含级比检验、参数估计、残差检验、后验差检验。

- `data`: 原始非负序列 (行向量或列向量)
- `forecast_horizon`: 预测步数 (正整数)
- `predictions`: 包含拟合值 + 预测值的完整序列
- `a`: 发展系数
- `b`: 灰作用量
- `relative_err`: 各点相对误差 (%)

内部流程:
1. 级比检验 $\lambda(k) = X^{(0)}(k-1) / X^{(0)}(k)$，若不通过则执行数据平移变换
2. 1-AGO 累加生成
3. 构造 $\mathbf{B}$ 矩阵与 $\mathbf{Y}$ 向量
4. 最小二乘求解 $[a, b]^T$
5. 时间响应函数预测
6. 逆累加还原
7. 残差检验与后验差检验

## Python 备选

```python
import numpy as np

def gm11(data, forecast_horizon=1):
    """灰色预测GM(1,1)"""
    X0 = np.array(data, dtype=float)
    # 1-AGO
    X1 = np.cumsum(X0)
    n = len(X0)
    # 构造 B 矩阵和 Y 向量
    Z = -0.5 * (X1[:-1] + X1[1:])
    B = np.column_stack([Z, np.ones(n - 1)])
    Y = X0[1:].reshape(-1, 1)
    # 最小二乘估计
    ab = np.linalg.inv(B.T @ B) @ B.T @ Y
    a, b = ab[0, 0], ab[1, 0]
    # 时间响应函数
    X1_pred = (X0[0] - b / a) * np.exp(-a * np.arange(n + forecast_horizon)) + b / a
    # 逆累加还原
    X0_pred = np.diff(X1_pred, prepend=0)
    # 计算相对误差
    fitted = X0_pred[:n]
    rel_err = np.abs((X0 - fitted) / X0) * 100
    return X0_pred, a, b, rel_err
```

备选: `greytheory` 包 (PyPI):
```python
from greytheory import GreyTheory
model = GreyTheory()
model.gm11(data)
pred = model.forecast(steps=3)
```

## 选型决策树

- **用 GM(1,1)** — 短序列 (n=4-10), 近似指数趋势, 小样本数据贫乏
- **用 ARIMA (PARADIGM-0202)** — 长序列 (n>30), 复杂自相关结构, 有季节性
- **用 Holt-Winters (PARADIGM-0203)** — 趋势+季节, 中短期 (n=10-30), 简单稳健
- **用 LSTM (PARADIGM-0204)** — 大量数据 (n>500), 非线性模式, 多变量输入
- **用 GM(2,1)** — 非单调趋势, GM(1,1) 精度不够
- **用 GM(1,N)** — 多因素灰色关联预测
- **Trade-off:** GM(1,1) 计算量极小, 对样本量要求最低, 但仅适合近似指数规律的数据。对振荡序列、周期序列完全失效。

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 双Y轴折线图 — 原始序列 + 1-AGO 序列 | 展示累加后的指数平滑效果 |
| process | 折线图 overlay — 原始数据点 + 拟合曲线 + 残差柱状图 (subplot) | 评估拟合精度 |
| result | 折线图 — 历史数据 + 预测值 + 灰色置信区间带 (fill) | 突出预测趋势与不确定性 |

## 常见坑

1. **数据非负性要求:** GM(1,1) 要求原始序列 $\geq 0$，出现负数时 1-AGO 序列可能非单调。**处理:** 加常数平移 (如加 min+1)，预测后回减
2. **级比检验不通过:** 建模前必须检查级比 $\lambda(k) \in (e^{-2/(n+1)}, e^{2/(n+1)})$，不通过则模型精度无保证。**处理:** 数据平移变换或取对数预处理
3. **发展系数 a 过大:** $|a| > 0.5$ 时模型仅适合极短期 (1-2步) 预测，$|a| > 1$ 时基本失效。**处理:** 缩短预测步长或更换方法
4. **背景值构造:** 传统 GM(1,1) 用均值生成 $\frac{1}{2}[X^{(1)}(k) + X^{(1)}(k+1)]$ 近似 $\int_k^{k+1} X^{(1)}(t) dt$ 引入误差。**改进:** 使用背景值优化 (如梯形公式或智能优化)
5. **仅短期有效:** 误差随预测步数指数增长，超过 3 步的预测通常不可靠

## 失效条件/反例 (强制小节)

- **条件1: 非单调或振荡数据** → GM(1,1) 假设指数规律，对周期性、锯齿形数据拟合残差 >20%，a 参数接近 0 或不显著。**表现:** 拟合值几乎为常数或反向波动，后验差比 C > 0.65 (不合格)。**替代:** 使用 ARIMA (PARADIGM-0202) 或指数平滑 (PARADIGM-0203)
- **条件2: 数据存在突变点/结构断点** → 单一 GM(1,1) 无法捕捉制度转换 (regime change)，突变点后预测严重偏离。**表现:** 突变点处残差急剧增大，整体平均相对误差 >10%。**替代:** 使用新陈代谢 GM(1,1) (滚动窗口剔除旧数据) 或干预 ARIMA (intervention ARIMA)
- **条件3: 数据含零值** → $X^{(0)}(k)=0$ 导致级比 $\lambda(k)=\infty$ 或参数矩阵奇异。**表现:** 矩阵求逆失败或 a 参数异常。**替代:** 对零值做微小正数替换 ($10^{-6}$) 或使用灰色 Verhulst 模型

## 文献

1. 邓聚龙 (1990). 《灰色系统理论教程》. 华中理工大学出版社. ISBN 978-7560904818.
2. Liu, S., & Lin, Y. (2010). *Grey Systems: Theory and Applications*. Springer. ISBN 978-3642161575. DOI: [10.1007/978-3-642-16158-2](https://doi.org/10.1007/978-3-642-16158-2)

## 来源溯源

- 培训模块源路径: `培训模块10 GM(1,1).mlx`
- 算法起源: 邓聚龙 1982, "The Control Problems of Grey Systems", Systems & Control Letters

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 (长序列/复杂) | PARADIGM-0202 (ARIMA) |
| 替代 (趋势+季节) | PARADIGM-0203 (指数平滑) |
| 替代 (非线性/大数据) | PARADIGM-0204 (LSTM预测) |
| 组合 (灰色+ARIMA) | PARADIGM-0202 — 灰色-ARIMA 混合模型 (先GM去趋势再ARIMA拟合残差) |
