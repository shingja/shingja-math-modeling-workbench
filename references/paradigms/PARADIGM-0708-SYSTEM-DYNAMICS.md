# PARADIGM-0708 系统动力学(存量-流量Euler积分)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0708 |
| 类别/子类 | ⑦综合 / 系统仿真 |
| 难度 | 中 |
| 适用题型关键词[] | 系统动力学, 存量-流量, Euler积分, 反馈回路, 延迟, Vensim, Stella, 政策模拟, 资源管理, 人口模型, 经济增长, 可持续发展, 生态系统 |
| confidence | high |
| source | 自写-见S5:system_dynamics.m |

## 数学形式

**存量方程 (Stock Equation) — Euler 积分形式：**
$$S(t + \Delta t) = S(t) + \Delta t \cdot \sum_i \left(\text{inflow}_i(t) - \text{outflow}_i(t)\right)$$

等价于 ODE 系统的 Euler 数值积分：
$$\frac{d\mathbf{S}}{dt} = \mathbf{f}(\mathbf{S}, \mathbf{P}, t)$$

**反馈回路分类：**
- 正反馈 (Reinforcing, R)：变化被放大 → 指数增长/崩溃
  $$\frac{dS}{dt} = kS \;\Rightarrow\; S(t) = S_0 e^{kt}$$
- 负反馈 (Balancing, B)：系统趋稳 → 目标寻求/震荡
  $$\frac{dS}{dt} = k(G - S) \;\Rightarrow\; S(t) = G - (G - S_0)e^{-kt}$$

**一阶物料延迟 (Pipeline / Material Delay)：**
$$\frac{dO}{dt} = \frac{I - O}{\tau}$$

其中 $$I$$ 为流入率，$$O$$ 为流出率，$$\tau$$ 为平均延迟时间。

**一阶信息平滑 (Exponential Smoothing)：**
$$S_{\text{smooth}}(t) = \frac{1}{\tau} \int_{-\infty}^{t} x(s) \cdot e^{-(t-s)/\tau} ds$$

或等价 ODE：
$$\frac{dS_{\text{smooth}}}{dt} = \frac{x(t) - S_{\text{smooth}}(t)}{\tau}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| init_stocks | 向量 | — | [0, ∞) 按建模域 | 中 (长期行为不由初值决定) |
| flow_equations | 函数句柄 | — | 任意合法 f(S,P,t) | 极高 (定义系统结构) |
| params (P) | 结构体 | — | 物理约束内 | 高 (需校准) |
| tspan | 向量 | [0, 100] | 按系统时间尺度 | 低 (够长即可看到动态) |
| dt | 浮点数 | 0.25 | [0.01, 1] | 高 (太大则数值不稳定) |
| delay_tau | 浮点数 | 5 | [0.5, 50] | 高 (延迟改变系统响应模式) |
| n_scenarios | 整数 | 1 | [1, 20] | 低 (足够展示政策对比) |

**计算复杂度：** $$O(N_t \cdot N_{\text{stocks}} \cdot N_{\text{flows}})$$，其中 $$N_t$$ 为时间步数。典型模型 (5-20 stocks) 毫秒级完成。
**量纲：** 存量与流量的量纲必须一致。全部 variables 应在建模文档显式标注单位。

## MATLAB 实现

**函数签名：**
```matlab
[stocks_history, flows_history, t] = system_dynamics(init_stocks, flow_equations, ...
    params, tspan, dt)
% stocks_history: (n_steps × n_stocks) 矩阵，每行一个时间步
% flows_history: (n_steps × n_flows) 矩阵
% flow_equations: @(stocks, params, t) → flows 向量
```

**多情景对比：**
```matlab
scenarios = {'baseline', 'policy_A', 'policy_B'};
figure; hold on;
for s = 1:length(scenarios)
    [stocks, ~, t] = system_dynamics(init, @(S,p,t) flows_func(S,p,t,scenario), ...
                                      params.(scenarios{s}), tspan, dt);
    plot(t, stocks(:,1), 'DisplayName', scenarios{s});
end
legend;
```

**进阶 — 使用 ODE 求解器 (推荐用于 stiff 系统)：**
```matlab
[t, stocks] = ode45(@(t,S) stock_derivative(S, params, t), tspan, init_stocks);
```

锚点：自写-见S5:system_dynamics.m，依赖基础 MATLAB 无额外 Toolbox。

## Python 备选

**PySD (读取 Vensim 模型，推荐)：**
```python
import pysd
model = pysd.read_vensim('model.mdl')
stocks = model.run(params={'param1': value1}, return_timestamps=range(0, 100))
stocks['Stock1'].plot()
```

**自定义 ODE (scipy)：**
```python
import numpy as np
from scipy.integrate import solve_ivp

def system(t, stocks, params):
    S1, S2 = stocks
    inflow = params['rate'] * S1
    outflow = S2 / params['tau']
    return [inflow - outflow, outflow - ...]

sol = solve_ivp(system, [0, 100], [100.0, 0.0], args=(params,),
                method='RK45', dense_output=True)
```

## 选型决策树

- **聚合系统行为 + 反馈回路 + 中长期政策分析** → 系统动力学 (SD) 首选
- **个体层面细节 + 异质性重要** → Agent-based Model (ABM)，非 SD
- **空间分布是一阶效应** → 元胞自动机 (CA) 或空间 SD (stella spatial)
- **系统有解析解 + 追求理论证明** → 动力系统理论 (stability analysis, bifurcation)
- **传染病建模 (经典 SEIR)** → ODE 系统，本质与 SD 等价，但流行病学有专属工具
- **离散时间 + 年龄结构** → 差分方程 / Leslie 矩阵，比连续 SD 更自然
- **事件驱动 + 排队/库存** → 离散事件仿真 (DES)，非连续 SD

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 因果回路图 (Causal Loop Diagram, CLD) + 存量-流量图 (Stock-Flow Diagram) | 模型结构可视化 |
| process | 存量时间轨迹 (多情景叠加 + 策略干预点标注) | 系统行为随时间演化 |
| result | 相图 (Stock1 vs Stock2) + 关键参数灵敏度 Tornado 图 | 系统长期行为与参数重要性 |
| result | 反馈优势分析：各回路贡献分解堆叠图 | 识别主导回路 |

## 常见坑

1. **Euler 积分对 stiff 系统不稳定** → 表现为数值震荡或发散。Dt 减半测试确认后，换 RK4 或使用 `ode45`/`solve_ivp` 自适应步长。
2. **模型边界权衡** → 太宽：参数过多难校准；太窄：遗漏关键反馈导致行为不真实。用边界图 (boundary chart) 正式定义系统范围。
3. **Table Function (查表函数) 主观性** → 非线性关系 (如"污染→死亡率") 的形状主观设定，结果对它高度敏感。必须引用实证数据或进行 table function 敏感性分析。
4. **延迟结构选择不当** → 误用一阶延迟代表高阶流程 (如供应链多层传递)，系统响应过于平滑。运输延迟应串联多级 (3-5 级 pipeline delay)。
5. **量纲不一致** → 存量单位为"人数"，流入却写成年"比例"，导致数值无意义。所有方程必须通过量纲一致性检验 (dimensional consistency check)。

## 失效条件/反例 (强制小节)

- **条件1: 系统有显著随机性且极端事件影响大** → 表现: 确定性 SD 只能给出平均行为，遗漏金融危机/物种灭绝等尾部事件。应使用 SD + Monte Carlo 不确定性传播 (对关键参数采样后重复运行)，或改用离散事件仿真 (DES)/ABM 内嵌随机性。
- **条件2: Agent 异质性与空间结构是一阶效应** → 表现: SD 将个体聚合为连续存量，平均掉了关键异质性。例如疏散模型中 SD 预测"1000 人用 X 分钟离开"，但 ABM 发现 3 人因空间拥堵用时远超平均→安全关键误差。应改用 ABM，或 SD-ABM 混合 (宏观用 SD，微观用 ABM)。
- **条件3: 系统属事件驱动 (离散跳跃) 而非连续流** → 表现: SD 将批量到达/随机服务处理为连续流，削弱了排队效应和利用率波动。排队系统、库存管理 (s,S 策略) 应用离散事件仿真而非 SD。
- **条件4: 模型过于复杂且缺乏数据校准支撑** → 表现: 几十个 stock、上百个参数，自由度远超数据提供的信息量，模型可拟合任何数据但无预测力 (overfitting at system level)。应大幅简化结构，遵循"最小充分模型"原则 (minimum sufficient model)，用 sensitivity analysis 剔除不敏感参数。

## 文献

1. Sterman, J. D. (2000). *Business Dynamics: Systems Thinking and Modeling for a Complex World*. McGraw-Hill/Irwin. ISBN: 978-0072389154
2. Ford, A. (2010). *Modeling the Environment*, 2nd ed. Island Press. ISBN: 978-1597264730

## 来源溯源

自写-见S5:system_dynamics.m — Euler 积分 SD 仿真引擎 + 多情景对比框架

## 关联范式卡

| 关系 | ID | 说明 |
|------|-----|------|
| 替代 | PARADIGM-0706 (元胞自动机) | 宏观连续 SD vs 微观离散 CA |
| 组合 | PARADIGM-0701 (MCMC) | 对参数进行不确定性传播 |
| 组合 | PARADIGM-0804 (SEIR 传染病) | SEIR 本质是 SD 的流行病学特化 |
| 替代 | PARADIGM-0807 (差分方程) | 离散差分 vs 连续积分，离散系统更自然用差分 |
| 前置 | PARADIGM-0806 (常微分方程) | SD 的核心是 ODE 系统 |
