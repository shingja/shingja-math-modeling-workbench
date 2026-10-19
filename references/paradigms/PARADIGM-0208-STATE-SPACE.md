# PARADIGM-0208-STATE-SPACE 状态空间模型/Kalman滤波⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0208-STATE-SPACE |
| 类别/子类 | ②预测 / 状态空间 |
| 难度 | 高 |
| 适用题型关键词[] | 状态空间, 卡尔曼滤波, 动态线性模型, 不可观测分量, 贝叶斯推断 |
| confidence | high |
| source | 教材第2章 / 文献2012_StateSpace / 题解反推_StateSpace类 |

## 数学形式

**状态空间模型 (SSM)**:
$$\text{观测方程: } \mathbf{y}_t = \mathbf{Z}_t \boldsymbol{\alpha}_t + \boldsymbol{\varepsilon}_t, \quad \boldsymbol{\varepsilon}_t \sim \mathcal{N}(0, \mathbf{H}_t)$$
$$\text{状态方程: } \boldsymbol{\alpha}_{t+1} = \mathbf{T}_t \boldsymbol{\alpha}_t + \mathbf{R}_t \boldsymbol{\eta}_t, \quad \boldsymbol{\eta}_t \sim \mathcal{N}(0, \mathbf{Q}_t)$$

**Kalman 滤波 (递推)**:

预测步:
$$\hat{\boldsymbol{\alpha}}_{t|t-1} = \mathbf{T}_t \hat{\boldsymbol{\alpha}}_{t-1|t-1}$$
$$\mathbf{P}_{t|t-1} = \mathbf{T}_t \mathbf{P}_{t-1|t-1} \mathbf{T}_t^T + \mathbf{R}_t \mathbf{Q}_t \mathbf{R}_t^T$$

更新步 (Kalman 增益):
$$\mathbf{v}_t = \mathbf{y}_t - \mathbf{Z}_t \hat{\boldsymbol{\alpha}}_{t|t-1} \quad \text{(新息)}$$
$$\mathbf{F}_t = \mathbf{Z}_t \mathbf{P}_{t|t-1} \mathbf{Z}_t^T + \mathbf{H}_t$$
$$\mathbf{K}_t = \mathbf{P}_{t|t-1} \mathbf{Z}_t^T \mathbf{F}_t^{-1}$$
$$\hat{\boldsymbol{\alpha}}_{t|t} = \hat{\boldsymbol{\alpha}}_{t|t-1} + \mathbf{K}_t \mathbf{v}_t$$
$$\mathbf{P}_{t|t} = \mathbf{P}_{t|t-1} - \mathbf{K}_t \mathbf{F}_t \mathbf{K}_t^T$$

**光滑 (RTS Smoother)**: 已知全观测序列, 后向递推 $\hat{\boldsymbol{\alpha}}_{t|T}$

| 变量 | 含义 |
|------|------|
| $\boldsymbol{\alpha}_t$ | 不可观测状态向量 ($m \times 1$) |
| $\mathbf{y}_t$ | 观测向量 ($p \times 1$) |
| $\mathbf{Z}_t$ | 观测矩阵 (设计矩阵) |
| $\mathbf{T}_t$ | 状态转移矩阵 |
| $\mathbf{Q}_t$ | 状态扰动协方差 |
| $\mathbf{H}_t$ | 观测噪声协方差 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 状态维数 $m$ | int | — | 1-10 | 高—太大估计不稳定 |
| 初始状态先验 | struct | 扩散先验 | 扩散/共轭/固定 | 中—影响早期滤波 |
| 参数估计方法 | enum | MLE (EM/L-BFGS) | EM/BFGS/Bayes (MCMC) | 中 |
| 时变 vs 时不变参数 | enum | 时不变 | — | 高—时变需更多数据 |

**滤波复杂度**: $O(T \cdot m^3)$ 每次 (Kalman 滤波); 参数估计需多次滤波迭代
**空间复杂度**: $O(T \cdot m^2)$ (存储所有 $\mathbf{P}_{t|t}$ for smoothing)

## MATLAB 实现

```matlab
% 状态空间模型 (Econometrics Toolbox)
% 定义 SSM
Mdl = ssm(@(params) paramMap(params, y, Z));

% 参数映射函数
function [A, B, C, D, Mean0, Cov0, StateType] = paramMap(params, y, Z)
    A = params(1);           % 状态转移系数
    B = params(2);           % 状态扰动载荷
    C = Z;                   % 观测矩阵
    D = params(3);           % 观测噪声标准差
    Mean0 = 0;
    Cov0 = params(4)^2;
    StateType = 0;           % 0: 平稳, 1: 常数, 2: 非平稳
end

% 估计
[EstMdl, estParams] = estimate(Mdl, y, params0);

% 滤波和光滑
[alpha_hat, logL] = filter(EstMdl, y);         % Kalman 滤波
alpha_smooth = smooth(EstMdl, y);              % RTS 光滑

% 预测
[yFcast, yMSE] = forecast(EstMdl, horizon, y);
```

**锚点工具箱**: `ssm`/`estimate` (Econometrics Toolbox)
**底层函数**: `filter` (Kalman), `smooth` (RTS), `forecast` (预测)

## Python 备选

```python
import statsmodels.api as sm
import numpy as np

# 构建自定义状态空间模型
class MySSM(sm.tsa.statespace.MLEModel):
    def __init__(self, endog):
        super().__init__(endog, k_states=2, k_posdef=1, 
                         initialization='diffuse')
        self['design', 0, 0] = 1.0
        self['transition', 0, 0] = 1.0
        # ... 设置矩阵
    
    def update(self, params, **kwargs):
        self['transition', 1, 0] = params[0]
        # ...

model = MySSM(y)
results = model.fit()
# 滤波和平滑
filtered = results.filter()
smoothed = results.smooth()
forecast = results.forecast(steps=12)
```

备选: `pykalman` (简单但功能有限), `filterpy` (Kalman 滤波基础)

## 选型决策树

- **含不可观测状态 (趋势, 季节, 周期, 回归系数) + 需推断** → SSM (最灵活)
- **简单指数平滑/ARIMA 可捕捉 → 不必要 SSM** → 用更简单的 (PARADIGM-0201 等)
- **需要在线预测 (流数据)** → Kalman 滤波天然适用 (递推)
- **参数时变 (在线学习)** → SSM + discount factor
- **SSM vs ARIMA**: ARIMA 是 SSM 的特例; SSM 扩展: 缺数据/混合频率/多变量/时变参数
- **SSM vs Prophet**: Prophet 更易用于业务预测 + 节假日; SSM 更灵活建模统计结构

## 典型图型

- **raw**: 观测时序 + 缺失段标记
- **process**: 状态滤波值 (alpha) 时序 (含 ±2SD 置信区间), 新息 (v_t) 自相关检验图
- **result**: 预测 + 预测区间 ribbon 图, 趋势分量分解 (含置信区间)

## 常见坑

1. **初始状态设定影响早期估计**: Diffuse prior (方差→∞) 使初始状态无信息, 早期置信带极宽 → 引用前期观测作为粗略初始值
2. **状态向量维数过高 + 不可识别**: 多个不可观测分量可替换性导致参数冗余 → 谨慎增加分量, 检验参数显著性
3. **局部最优陷阱**: MLE 的 EM 算法或 BFGS 可能停在多峰的局部最优 → 多起点 + 检查对数似然
4. **扩散初始需恰定**: 对非平稳分量 (random walk) 必须用扩散初始化, 否则滤波偏倚

## 失效条件/反例 (强制小节)

- **条件1**: 状态空间模型参数不可识别 (不同的参数值产生相同的似然) → MLE 不唯一, 置信区间巨大, 预测无意义。常见因: 状态分量冗余, 或无约束参数过多。**替代**: 减少状态分量至可识别数, 或加参数约束/先验 (Bayesian SSM)
- **条件2**: 观测数 $T < 20$ → 参数估计方差极大 (MLE 需要足够的信噪比分离), Kalman 滤波本身在短序列无统计优势。**替代**: 简单平滑/ARIMA (PARADIGM-0201) 或 Bayes 强先验
- **条件3**: 观测噪声极度非高斯 (重尾/不对称) → Kalman 滤波基于正态假设, 重尾噪声导致滤波极度非高效, 异常值可能严重偏倚状态估计。**替代**: 稳健 Kalman (Student-t 噪声), 粒子滤波 (SIR/PF for 任意分布)
- **条件4**: 系统非线性强 (非高斯+非线性) → 扩展 Kalman (EKF = Jacobi 线性化) 在强非线性下发散; 无迹 Kalman (UKF) 稍好但仍有偏。**替代**: 粒子滤波 (Particle Filter), 或 PINN 状态估计

## 文献

1. Durbin, J., & Koopman, S. J. (2012). *Time Series Analysis by State Space Methods* (2nd ed.). Oxford University Press. ISBN: 978-0-19-964117-8.
2. Harvey, A. C. (1989). *Forecasting, Structural Time Series Models and the Kalman Filter*. Cambridge University Press. ISBN: 978-0-521-40573-2.

## 来源溯源

- 教材源路径: 数学建模算法与应用 第2章 预测
- 论文三元组: Kalman 1960 original filter + Durbin 2012 Book Form
- MATLAB 文档: [ssm](https://www.mathworks.com/help/econ/ssm.html)

## 关联范式卡

组合: PARADIGM-0205-GARCH (SSM for 波动率)
替代: PARADIGM-0201-ARIMA (特例: ARIMA = SSM), PARADIGM-0207-PROPHET (更简单分解)
