# PARADIGM-0806 捕食者-猎物ODE系统⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0806 |
| 类别/子类 | ⑧机理建模与PDE / 种群动力学 |
| 难度 | 低 |
| 适用题型关键词[] | Lotka-Volterra, 捕食者-猎物, 种群动态, ode45, 相平面, 生态模型, 功能响应 |
| confidence | high |
| source | Lotka (1925) Elements of Physical Biology |

## 数学形式

**经典 Lotka-Volterra:**
$$\frac{dx}{dt} = \alpha x - \beta xy$$
$$\frac{dy}{dt} = \delta xy - \gamma y$$

**Rosenzweig-MacArthur (功能响应 Type II):**
$$\frac{dx}{dt} = rx\left(1-\frac{x}{K}\right) - \frac{axy}{1+ahx}$$
$$\frac{dy}{dt} = \frac{eaxy}{1+ahx} - dy$$

其中 $h$ 为处理时间 (handling time)，$a$ 为攻击率。

**稳定性分析:**
共存平衡点 $E^*=(x^*,y^*)$ 的 Jacobian:
$$J(E^*) = \begin{bmatrix} -r/K - \partial \phi/\partial x & -\partial \phi/\partial y \\ ea \partial \phi/\partial x & ea \partial \phi/\partial y - d \end{bmatrix}$$

$\text{tr}(J) < 0$ 且 $\det(J) > 0$ → 局部稳定。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| alpha/r | double | 1.0 | (0,5) | 高 |
| beta/a | double | 0.1 | (0,1) | 极高 |
| delta/e | double | 0.02 | (0,1) | 高 |
| gamma/d | double | 0.5 | (0,5) | 高 |
| K (环境容量) | double | — | (0,∞) | 高—决定稳定性 |

## MATLAB 实现

```matlab
% 定义 ODE 系统
lv = @(t, z, alpha, beta, delta, gamma) ...
    [alpha*z(1) - beta*z(1)*z(2);
     delta*z(1)*z(2) - gamma*z(2)];

[t, z] = ode45(@(t,z) lv(t,z,1.0,0.1,0.02,0.5), [0,100], [20;5]);

% 相平面 + 零等倾线
x_vals = linspace(0, max(z(:,1)), 100);
nullcline_prey = alpha/beta * ones(size(x_vals));  % dx/dt=0
nullcline_pred = gamma/delta * ones(size(x_vals)); % dy/dt=0
plot(z(:,1), z(:,2), 'b-', ...
     x_vals, nullcline_prey, 'r--', ...
     nullcline_pred, x_vals, 'g--');
```

锚点: `ode45` (MATLAB内置)

## Python 备选

```python
from scipy.integrate import solve_ivp
sol = solve_ivp(lambda t,z: [a*z[0]-b*z[0]*z[1], d*z[0]*z[1]-g*z[1]],
                [0,100], [20,5], method='RK45', max_step=0.1)
```

## 选型决策树

- **LV 经典** — 初步定性分析、教学演示
- **Rosenzweig-MacArthur** — 加入猎物密度制约 + 捕食者饱和，更接近真实
- **Leslie (PARADIGM-0803)** — 需要年龄结构而非总量
- **食物网** — 多物种级联效应 → 增大 ODE 维度

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 零等倾线相交图 | 平衡点位置 |
| result | 种群时间序列 (x+y 双y轴) | 相位差 |
| result | 相平面多轨道 | 展示中心/焦点结构 |

## 常见坑

1. **经典 LV 无阻尼**: 保守系统的中性稳定性 → ode45 长时模拟漂移
2. **负值截断**: Euler/Maruyama 步长过大 → 种群数可为负 → 用相对容差
3. **忽略功能响应**: 线性功能响应 ($\beta xy$) 假设捕食者可无限进食，现实有饱和

## 失效条件/反例 (强制小节)

- **条件1: 猎物存在强 Allee 效应** → 表现: 低于阈值密度猎物增长率变负 → 经典 LV 预测不收敛但实际灭绝。**应对**: 引入 Allee 阈值项: $\alpha x(x-A)/(K-A)$ (A=Allee阈值)
- **条件2: 空间异质性 (patchy 环境)** → 表现: ODE 假设均匀混合，实际猎物可躲入庇护所导致捕食效率大幅下降 → ODE 预测的振幅/相位错误。**应对**: 空间显式模型 — 反应-扩散方程 (PARADIGM-0811) 或元胞自动机 (PARADIGM-0706)

## 文献

1. Lotka A.J. (1925). *Elements of Physical Biology*. Williams & Wilkins.
2. Murray J.D. (2002). *Mathematical Biology*, 3rd ed. Springer. ISBN: 978-0387952239

## 来源溯源

ode45; 数学生物学经典模型

## 关联范式卡

| 关系 | ID |
|------|-----|
| 简化版 | PARADIGM-0710 (Lotka-Volterra综合) |
| 组合 | PARADIGM-0802 (Logistic) |
| 前置 | PARADIGM-0807 (ODE迭代器) |
