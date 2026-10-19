# PARADIGM-0707 可靠性分析(Weibull/FTA)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0707 |
| 类别/子类 | ⑦综合 / 可靠性工程 |
| 难度 | 中 |
| 适用题型关键词[] | 可靠性分析, Weibull分布, 故障树分析, FTA, 寿命数据分析, 失效率, MTBF, MTTF, 可用度, 维修性, 可靠性框图, 截尾数据 |
| confidence | high |
| source | MATLAB wblfit + 自写-见S5:fta_analyze.m |

## 数学形式

**Weibull 分布：**
概率密度函数 (PDF)：
$$f(t) = \frac{\beta}{\eta}\left(\frac{t}{\eta}\right)^{\beta-1} \exp\left(-\left(\frac{t}{\eta}\right)^\beta\right), \quad t \geq 0$$

可靠度函数：
$$R(t) = \exp\left(-\left(\frac{t}{\eta}\right)^\beta\right)$$

故障率 (失效率 / Hazard)：
$$h(t) = \frac{f(t)}{R(t)} = \frac{\beta}{\eta}\left(\frac{t}{\eta}\right)^{\beta-1}$$

其中 $$\beta$$ 为形状参数，$$\eta$$ 为尺度参数 (特征寿命)。$$R(t)$$ 为可靠度，失效率函数 (ROCOF)。$$\beta > 0$$ 为形状参数，$$\eta > 0$$ 为尺度参数 (特征寿命)。

**形状参数** $$\beta$$ **的物理意义：**
- $$\beta < 1$$：早期失效期 (infant mortality)，故障率递减
- $$\beta = 1$$：随机失效期 (指数分布特例)，故障率恒定
- $$\beta > 1$$：耗损失效期 (wear-out)，故障率递增

**故障树分析 (FTA)：**
系统可靠度：
$$\begin{aligned}
\text{串联:}&\quad R_{\text{system}} = \prod_{i} R_i \\
\text{并联:}&\quad R_{\text{system}} = 1 - \prod_{i} (1 - R_i) \\
\text{顶事件概率:}&\quad P(TE) = \bigcup_{j=1}^{m} MCS_j
\end{aligned}$$

其中 $$MCS_j$$ 为最小割集 (minimal cut set)，$$TE$$ 为顶事件 (top event)。

**Birnbaum 重要性度量：**
$$I_B(i) = \frac{\partial P(TE)}{\partial p_i} = P(TE \mid C_i \text{ failed}) - P(TE \mid C_i \text{ working})$$

**MTTF (Mean Time To Failure)：**
$$\text{MTTF} = \int_0^\infty R(t)dt = \eta \cdot \Gamma\left(1 + \frac{1}{\beta}\right)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 寿命数据 | 向量 | — | (0, ∞) | 极高 (数据质量决定一切) |
| censoring | 逻辑向量 | 全 0 (完整) | {0, 1}^n | 极高 (忽略截尾则严重偏差) |
| β (形状) | 浮点数 | 待估计 | (0, 10] | 高 (决定失效机制) |
| η (尺度) | 浮点数 | 待估计 | (0, ∞) | 中 (单位相关) |
| 置信水平 α | 浮点数 | 0.05 | (0, 0.2] | 低 (惯例 0.05) |
| tree_struct | 结构体 | — | 逻辑门组合 | 极高 (FTA 结构) |
| component_R | 向量 | — | [0, 1]^m | 高 (输入不可靠则输出不可靠) |

**计算复杂度：**
- Weibull MLE 拟合：$$O(n \cdot k)$$，其中 $$n$$ 为样本量，$$k$$ 为 MLE 迭代次数
- FTA 最小割集枚举：组合爆炸，大型树需用 Monte Carlo 仿真或 BDD 加速

**量纲：**
- $$t, \eta$$：时间 (小时/天/年/循环数)，必须一致
- $$\beta$$：无量纲
- $$h(t)$$：故障数/时间 (如 failures/hour)
- $$R(t), P(TE)$$：概率 [0, 1]，无量纲

## MATLAB 实现

**Weibull 拟合：**
```matlab
% Statistics and Machine Learning Toolbox
[param_est, param_CI] = wblfit(data, alpha, censoring);
wblplot(data);  % Weibull 概率图 — 检验拟合优度
```

**FTA 故障树分析：**
```matlab
[top_prob, cut_sets, importance] = fta_analyze(tree_struct, component_reliabilities);
% tree_struct: 含 .gates (逻辑门) 和 .events (基本事件)
% top_prob: 顶事件发生概率
% cut_sets: 最小割集列表
% importance: Birnbaum/Fussell-Vesely 重要性度量
```

**系统可靠性计算：**
```matlab
R_system = system_reliability(config_matrix, component_R);
% config_matrix: 描述串并联结构
```

锚点：`wblfit`/`wblplot` (Statistics and Machine Learning Toolbox) + 自写 FTA `fta_analyze.m`。

## Python 备选

**Weibull 分析 (scipy + reliability)：**
```python
from scipy.stats import weibull_min
from reliability.Fitters import Fit_Weibull_2P
from reliability.Probability_plotting import Weibull_probability_plot

fit = Fit_Weibull_2P(failures=data, right_censored=censored)
# 输出: beta, eta, log-likelihood, AICc, BIC

Weibull_probability_plot(failures=data)
```

**FTA 分析：**
```python
# reliability 库内置 FTA
from reliability.FTA import Fault_Tree
tree = Fault_Tree(gate_connections, basic_events, event_probabilities)
```

**生存分析 (lifelines)：**
```python
from lifelines import WeibullFitter
wf = WeibullFitter()
wf.fit(durations=T, event_observed=E)
wf.plot()
```

## 选型决策树

- **寿命/失效时间数据分析** → Weibull 分布拟合 (首选)：比指数更灵活，比对数正态更直观
- **指数分布 (β=1 验证后)** → 简单系统无老化/磨合效应可用指数，Weibull 退化为特例
- **系统级可靠性 + 已知组件结构** → 故障树分析 (FTA)
- **可修系统 (考虑维修)** → 更新过程 (renewal process) 或 NHPP (非齐次 Poisson 过程)
- **竞争风险 (多种失效模式并存)** → 竞争风险模型 (competing risks) 或混合 Weibull
- **组件依赖复杂 (CCF 不容忽略)** → 贝叶斯网络 (Bayesian network) 或动态故障树 (DFT)
- **无参数假设 / n < 10** → 非参数 Kaplan-Meier + 对数秩检验

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | Weibull 概率图 (WPP, wblplot) | 检验 Weibull 假设是否成立 (直线性) |
| process | 浴盆曲线 (Bathtub curve) — h(t) 三段: 早期失效 / 随机 / 耗损 | 展示故障率随时间变化 |
| result | R(t) 可靠度曲线 + 95% CI 阴影 | 最终可靠度估计与不确定度 |
| result | 故障树逻辑图 + 割集概率 (Pareto 排序) | 识别关键失效路径 |

## 常见坑

1. **截尾数据 (Censoring) 被忽略** → 仅用已失效样本的失效时间，忽略仍在运行的样本 (右截尾)，导致 β/η 估计严重偏差 (低估可靠性)。必须用 MLE with censoring 或 Kaplan-Meier。
2. **小样本 (n < 10)** → Weibull 参数置信区间极宽，拟合不可靠。改用非参数方法 (Kaplan-Meier) 并谨慎解释。
3. **FTA 假设基本事件独立** → 共因失效 (CCF, Common Cause Failure) 违反独立性，严重低估顶事件概率。需识别 CCF 并在树中建模或使用 β-factor model 修正。
4. **Weibull 外推超出数据范围** → 用短期试验数据外推长期可靠性 (如 1000h 试验推 10 年)，β 估计的微小误差被放大。必须在报告中声明外推假设。
5. **混合失效模式用单一 Weibull** → WPP 图上出现弯折 (kink)，单一拟合残差大。应使用混合 Weibull 或竞争风险模型。

## 失效条件/反例 (强制小节)

- **条件1: 失效模式不独立 (共因失效、级联失效、负载共享)** → 表现: FTA 顶事件概率被严重低估 (数量级误差)；例如两个冗余组件共有同一电源，FTA 按独立并联计算可靠性为 0.99²→0.9999，实际 CCF 下仅约 0.99。应改用动态故障树 (DFT)、贝叶斯网络或显式建模 CCF (β-factor / alpha-factor)。
- **条件2: 数据含多种失效模式 (如早期缺陷 + 正常耗损混合)** → 表现: 单一 Weibull 拟合存在系统性偏差，WPP 图上可见明显弯折 (kink)，残差图呈非随机模式。应改用混合 Weibull (2-3 成分)、竞争风险模型，或对数据分段 (筛查早期失效后单独拟合耗损段)。
- **条件3: 失效时间含周期/间歇性运行 (非连续工作时间)** → 表现: 用连续 Weibull 拟合间歇性 (如飞机发动机每次起降) 的失效数据，$$h(t)$$ 被错误平滑。应使用离散 Weibull 或按循环数 (cycles) 而非连续时间分析。
- **条件4: 系统可修且修复时间不忽略** → 表现: 用 可靠度 $$R(t)$$ 分析可修系统会给出过悲观的可用度估计。应改用可用度 $$A = \text{MTTF}/(\text{MTTF}+\text{MTTR})$$ 或 Markov 可修系统模型。

## 文献

1. O'Connor, P. D. T. & Kleyner, A. (2012). *Practical Reliability Engineering*, 5th ed. Wiley. ISBN: 978-0470979815
2. Meeker, W. Q. & Escobar, L. A. (1998). *Statistical Methods for Reliability Data*. Wiley. ISBN: 978-0471143284

## 来源溯源

MATLAB Statistics and Machine Learning Toolbox `wblfit`/`wblplot` + 自写-见S5:fta_analyze.m

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 组合 | PARADIGM-0509 (假设检验) | 检验 Weibull 拟合优度 (K-S, A-D) 与参数显著性 |
| 组合 | PARADIGM-0701 (MCMC) | 复杂层次可靠性模型的贝叶斯推断 |
| 替代 | PARADIGM-0604 (生存分析/COX) | 关注协变量 (环境因素) 对失效的影响时 |
| 前置 | PARADIGM-0201 (概率论基础) | 需理解条件概率、联合分布 |
