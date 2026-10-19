# PARADIGM-0710 Lotka-Volterra捕食者-猎物⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0710 |
| 类别/子类 | ⑦综合 / 种群动力学 |
| 难度 | 低 |
| 适用题型关键词[] | Lotka-Volterra, 捕食者-猎物, 种群竞争, 生态模型, 相平面, 周期解, ode45 |
| confidence | high |
| source | Lotka (1925); Volterra (1926) |

## 数学形式

**经典 Lotka-Volterra 捕食者-猎物:**
$$\frac{dx}{dt} = \alpha x - \beta xy$$
$$\frac{dy}{dt} = \delta xy - \gamma y$$

其中:
- $x$ — 猎物 (Prey) 数量
- $y$ — 捕食者 (Predator) 数量
- $\alpha$ — 猎物自然增长率
- $\beta$ — 捕食率 (predation rate)
- $\delta$ — 猎物到捕食者生物量转换率
- $\gamma$ — 捕食者自然死亡率

**相平面分析 — 守恒量 (首次积分):**
$$V(x,y) = \delta x - \gamma \ln x + \beta y - \alpha \ln y = \text{const}$$

**平衡点:**
- 平凡平衡: $(0,0)$ (鞍点)
- 共存平衡: $(x^*, y^*) = (\gamma/\delta, \alpha/\beta)$ (中心)

**线性化 Jacobian:**
$$J = \begin{bmatrix} \alpha - \beta y^* & -\beta x^* \\ \delta y^* & \delta x^* - \gamma \end{bmatrix}$$

**竞争模型 (Lotka-Volterra Competition):**
$$\frac{dx_1}{dt} = r_1 x_1\left(1 - \frac{x_1 + \alpha_{12}x_2}{K_1}\right)$$
$$\frac{dx_2}{dt} = r_2 x_2\left(1 - \frac{x_2 + \alpha_{21}x_1}{K_2}\right)$$

竞争系数 $\alpha_{ij}$ 决定共存与排斥。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| alpha (猎物增长率) | double | 1.0 | (0, 5) | 高 — 决定猎物增长 |
| beta (捕食率) | double | 0.1 | (0, 1) | 极高 — 耦合强度 |
| delta (转化率) | double | 0.02 | (0, beta) | 高 — 能量转换效率 |
| gamma (捕食者死亡率) | double | 0.5 | (0, 5) | 高 — 决定捕食者持续 |
| ODE 求解 | — | — | ode45 非刚性 | — |

## MATLAB 实现

```matlab
% 定义 ODE
lv_ode = @(t, z) [alpha*z(1) - beta*z(1)*z(2);
                   delta*z(1)*z(2) - gamma*z(2)];

[t, z] = ode45(lv_ode, tspan, [x0; y0]);

x = z(:,1); y = z(:,2);

% 相平面
plot(x, y); xlabel('Prey'); ylabel('Predator');
hold on; plot(gamma/delta, alpha/beta, 'ro'); % 平衡点

% 种群时间序列
subplot(2,1,1); plot(t, x, 'b', t, y, 'r');
legend('Prey', 'Predator');

% 相平面多初值 (展示中心结构)
for x0 = [0.5, 1, 2, 3] * gamma/delta
    for y0 = [0.5, 1, 2] * alpha/beta
        [~, z] = ode45(lv_ode, tspan, [x0; y0]);
        plot(z(:,1), z(:,2)); hold on;
    end
end
```

锚点: `ode45` (MATLAB内置)

## Python 备选

```python
from scipy.integrate import solve_ivp

def lv(t, z, alpha, beta, delta, gamma):
    x, y = z
    return [alpha*x - beta*x*y, delta*x*y - gamma*y]

sol = solve_ivp(lv, t_span, [x0, y0], args=(alpha, beta, delta, gamma),
                method='RK45', dense_output=True)
```

## 选型决策树

- **Lotka-Volterra** — 基础捕食-被捕食动力学，周期震荡
- **Rosenzweig-MacArthur** — 加入功能响应 (Functional Response) Type II/III
- **竞争模型** — 多物种竞争 (共存/排斥判定)
- **食物网 (Food Web)** — 三营养级以上 → 复杂网络

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 零等倾线 (Nullcline) 相交图 | 平衡点和稳定性 |
| result | 时间序列: x(t), y(t) 双轴图 | 相位差 (prey peaks first) |
| result | 相平面 (多初值闭环) | 周期性保守系统的中心结构 |

## 常见坑

1. **经典 LV 是保守系统 (无阻尼)**: 小幅扰动不解体的→ 任何数值误差使轨道漂移→ ode45 默认容差下长时模拟失真
2. **种群数为负**: 欧拉法大步长可能产生负值→ 用小步长或用 ode45
3. **共存平衡点是中心 (非焦点)**: 模型无阻尼→ 真实生态有阻尼 (密度制约、时间延迟)

## 失效条件/反例 (强制小节)

- **条件1: 引入时间延迟 (如捕食者消化时间 τ)** → 表现: Hutchinson 方程 $dx/dt = \alpha x(1-x(t-\tau)/K)$ — 延迟可使共存平衡点失稳出现极限环甚至混沌。经典 LV 无法描述 → 需用延迟微分方程 DDE (dde23)。**应对**: 用 dde23 求解含延迟的系统
- **条件2: Allee 效应 (小种群灭绝风险)** → 表现: 猎物低于临界密度 $A$ 时增长率为负 → LV 预测的周期振荡在低密度时物种应已灭绝，经典 LV 无法预测灭绝。**应对**: 引入 Allee 阈值项: $\alpha x \to \alpha x(x-A)/(K-A)$

## 文献

1. Lotka A.J. (1925). *Elements of Physical Biology*. Williams & Wilkins.
2. Volterra V. (1926). "Fluctuations in the abundance of a species considered mathematically." *Nature*, 118:558-560. DOI: [10.1038/118558a0](https://doi.org/10.1038/118558a0)
3. Murray J.D. (2002). *Mathematical Biology*, 3rd ed. Springer. Chapter 3. ISBN: 978-0387952239

## 来源溯源

ode45 + 自写 lv_ode.m; 数学生物学教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0806 (Lotka-Volterra ODE 详细版) |
| 替代 | PARADIGM-0802 (Logistic) |
| 组合 (ODE) | PARADIGM-0807 (微分方程迭代器) |
