# PARADIGM-0210 VAR向量自回归⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0210 |
| 类别/子类 | ②预测 / 多变量时间序列 |
| 难度 | 中 |
| 适用题型关键词[] | VAR, 向量自回归, 多变量预测, 脉冲响应, 方差分解, varm, estimate, Sims |
| confidence | high |
| source | Sims (1980) Econometrica |

## 数学形式

**VAR(p) 模型:**
$$\mathbf{y}_t = \mathbf{c} + \Phi_1 \mathbf{y}_{t-1} + \Phi_2 \mathbf{y}_{t-2} + \cdots + \Phi_p \mathbf{y}_{t-p} + \boldsymbol{\varepsilon}_t$$

其中 $\mathbf{y}_t \in \mathbb{R}^K$ (K 个时间序列), $\Phi_i \in \mathbb{R}^{K\times K}$, $\boldsymbol{\varepsilon}_t \sim \text{WN}(\mathbf{0}, \Sigma)$。

**估计 (OLS, 方程逐个):**
$$\hat{\Phi} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{Y}$$

**稳定性条件:** 所有特征根 $\lambda$ 满足 $|\mathbf{I} - \Phi_1 z - \cdots - \Phi_p z^p| = 0 \implies |z| > 1$。

**脉冲响应函数 (IRF):**
外生冲击在第 $j$ 个方程的影响向各变量的传播:
$$\Psi_h = \sum_{i=1}^{p} \Phi_i \Psi_{h-i}, \quad \Psi_0 = \mathbf{I}$$

**预测误差方差分解 (FEVD):**
变量 $j$ 的冲击对变量 $k$ 的 $h$ 步预测误差方差的贡献比例:
$$\text{FEVD}_{jk}(h) = \frac{\sum_{l=0}^{h-1} (e_k^T \Psi_l P e_j)^2}{\sum_{l=0}^{h-1} e_k^T \Psi_l \Sigma \Psi_l^T e_k}$$

**滞后阶数选择:** AIC/BIC/Hannan-Quinn 准则最小化

**变量表:**
- $K$ — 变量数 → 待估参数 = $K + pK^2$ (可能很大)
- Cholesky 分解用于 IRF 的正交化 (识别假设: 变量顺序影响结果)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| p (滞后阶数) | int | AIC选择 | [1,12] | 高 — 过小遗漏动态; 过大过拟合 |
| K (变量数) | int | — | [2,10] | 极高 — 参数∝K² |
| 估计方法 | — | OLS | — | — |
| 复杂度 | — | — | O(T·K²·p) | — |

## MATLAB 实现

```matlab
% Econometrics Toolbox
% 构建 VAR 模型
p = 4;  % 滞后阶数
Mdl = varm(K, p);
% 估计
EstMdl = estimate(Mdl, Y);  % Y: T×K

% 查看结果
summarize(EstMdl);

% 预测
n_forecast = 10;
[Y_forecast, Y_MSE] = forecast(EstMdl, n_forecast, Y);

% 脉冲响应
armairf(EstMdl.AR, {}, 'InnovCov', EstMdl.Covariance);

% 自写 IRF (更灵活)
function irf = var_irf(Phi, Sigma, horizon, chol_order)
    K = size(Phi,1); p = size(Phi,2)/K;
    P = chol(Sigma, 'lower');  % Cholesky
    irf = zeros(K, K, horizon);
    irf(:,:,1) = P;  % 冲击矩阵
    % 构建 VAR(1) 伴随形式
    % ... 递推计算 ...
end
```

锚点: `varm` / `estimate` (Econometrics Toolbox)

## Python 备选

```python
from statsmodels.tsa.api import VAR
model = VAR(Y)
results = model.fit(maxlags=8, ic='aic')
print(results.summary())
# 预测 & IRF
forecast = results.forecast(Y.values[-results.k_ar:], steps=10)
irf = results.irf(10)
irf.plot(orth=False)
```

## 选型决策树

- **VAR** — 多个时间序列互相影响，无理论约束 (数据驱动)
- **ARIMA (PARADIGM-0202)** — 单个时间序列
- **SVAR (Structural VAR)** — 有经济理论的约束 (短期/长期识别限制)
- **VECM** — 变量间存在协整关系 (长期均衡)
- **Bayesian VAR** — $K$ 大 ($K > 10$) + 参数多 → 需要先验收缩

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | AIC/BIC vs lag p 曲线 | 选滞后阶数 |
| result | IRF 脉冲响应图 (subplot K×K) | 加 95% Bootstrap CI |
| result | FEVD 方差分解堆叠面积图 | 各变量贡献比例 |

## 常见坑

1. **参数爆炸**: K=5, p=4 → 105 参数，T=200 → 过拟合严重。用 AIC/BIC 选 p，或 Bayesian VAR
2. **非平稳变量 → 伪回归**: 变量应经检验后差分至平稳或使用协整 VECM
3. **Cholesky 分解的顺序依赖性**: IRF 的正交化假设取决于变量排列顺序 → 敏感性分析: 交换顺序重算

## 失效条件/反例 (强制小节)

- **条件1: K 太大 (K > 20) + T 不足** → 表现: 参数 $\propto pK^2$ → p=2, K=20 → 840 参数，T=200 时 OLS 的 SE 极大，预测不可靠。**应对**: 使用 Bayesian VAR (Minnesota 先验) 或 FAVAR (Factor-Augmented VAR, 先降维再 VAR)
- **条件2: 结构断点 (如政策改革前后)** → 表现: 训练期/测试期的 $\Phi_i$ 不同 — VAR 预测在断点后系统性偏离。**应对**: 使用 TVP-VAR (Time-Varying Parameter VAR) 允许系数随时间缓慢变化，或 Markov-Switching VAR

## 文献

1. Sims C.A. (1980). "Macroeconomics and reality." *Econometrica*, 48(1):1-48. DOI: [10.2307/1912017](https://doi.org/10.2307/1912017)
2. Lutkepohl H. (2005). *New Introduction to Multiple Time Series Analysis*. Springer. ISBN: 978-3540401728

## 来源溯源

MATLAB `varm` / `estimate`; 时间序列经济学

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0202 (ARIMA) |
| 组合 | PARADIGM-0209 (GARCH) |
| 组合 | PARADIGM-0505 (协整) |
