# PARADIGM-0816 增长模型统一框架(Malthus/Logistic/Leslie)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0816 |
| 类别/子类 | ⑧机理建模与PDE / 种群增长 |
| 难度 | 低 |
| 适用题型关键词[] | Malthus, Logistic, Leslie, 种群增长, 年龄结构, 人口预测, ode45, 环境容量 |
| confidence | high |
| source | 已有 S5 .m 文件集 |

## 数学形式

**Malthus 指数增长 (无约束):**
$$\frac{dN}{dt} = rN \quad \Rightarrow \quad N(t) = N_0 e^{rt}$$

**Logistic 增长 (密度制约):**
$$\frac{dN}{dt} = rN\left(1 - \frac{N}{K}\right) \quad \Rightarrow \quad N(t) = \frac{K}{1 + \left(\frac{K}{N_0}-1\right)e^{-rt}}$$

- $K$ — 环境容量 (Carrying Capacity)
- 拐点: $N = K/2$ (增长率最大)

**Leslie 矩阵 (年龄结构):**
$$\mathbf{n}(t+1) = \mathbf{L} \cdot \mathbf{n}(t)$$

$$\mathbf{L} = \begin{bmatrix}
F_1 & F_2 & \cdots & F_{m-1} & F_m \\
S_1 & 0 & \cdots & 0 & 0 \\
0 & S_2 & \cdots & 0 & 0 \\
\vdots & \vdots & \ddots & \vdots & \vdots \\
0 & 0 & \cdots & S_{m-1} & 0
\end{bmatrix}$$

- $F_i$ — 年龄 $i$ 的生育率
- $S_i$ — 年龄 $i$ 到 $i+1$ 的存活率
- 长期增长率: $\lambda$ (L 的主特征值)
- 稳定年龄分布: L 的主右特征向量

**von Bertalanffy (个体生长):**
$$\frac{dL}{dt} = k(L_\infty - L) \quad \Rightarrow \quad L(t) = L_\infty - (L_\infty - L_0)e^{-kt}$$

**Gompertz (肿瘤/死亡率):**
$$\frac{dN}{dt} = rN \ln\left(\frac{K}{N}\right)$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| r (内禀增长率) | double | 0.1 | [-1,5] | 极高 — 指数效应 |
| K (环境容量) | double | 1000 | >0 | 高 |
| Leslie F_i, S_i | double[] | — | F≥0, S∈[0,1] | 高 — λ 的敏感度 |
| N0 | double | 10 | >0 | 低 — 仅影响初始瞬态 |

## MATLAB 实现

```matlab
% Logistic (解析解)
t = linspace(0, 100);
N = K ./ (1 + (K/N0 - 1) * exp(-r*t));

% Logistic (ODE验证)
[t_ode, N_ode] = ode45(@(t,N) r*N*(1-N/K), [0,100], N0);

% Leslie 预测
n = zeros(m, T); n(:,1) = n0;
for t = 1:T-1
    n(:, t+1) = L * n(:, t);
end
total_N = sum(n, 1);

% 稳定年龄分布与 λ
[V, D] = eig(L);
[lambda, idx] = max(abs(diag(D)));
stable_age = V(:, idx);
stable_age = stable_age / sum(stable_age);
```

锚点: `ode45` (MATLAB内置) + 已有 S5 .m 文件

## Python 备选

```python
import numpy as np
from scipy.integrate import solve_ivp

# Logistic
sol = solve_ivp(lambda t,N: r*N*(1-N/K), [0,100], [N0], max_step=0.1)

# Leslie
for t in range(T-1):
    n[:, t+1] = L @ n[:, t]
```

## 选型决策树

- **Malthus** — 短期/无资源限制/萌芽阶段
- **Logistic** — 单一种群 + 密度制约 + 长期预测
- **Leslie** — 需要年龄/阶段结构的精细化预测 (人口学、渔业、害虫)
- **Lotka-Volterra (PARADIGM-0806)** — 需要考虑物种间交互 (捕食/竞争)
- **Gompertz** — 适合非对称 S 形 (拐点偏左)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 多种增长模型 N(t) 对比 (同参数) | Malthus/Logistic/Gompertz 形状差异 |
| result | Leslie 年龄金字塔 (堆叠柱状图) | 各年龄/阶段比例 |
| result | dN/dt vs N 的相平面图 | 展示 K/2 拐点 |

## 常见坑

1. **K 估计困难**: Logistic 对 K 敏感 — 缺乏长期数据时 K 不确定性大。用最大似然 + 剖面似然 CI
2. **Leslie 的零生育年龄**: 未成熟年龄组 $F_j=0$ 时死亡率 $S_j$ 只能延迟增长 → $\lambda$ 对这些参数敏感性有方向性
3. **Logistic 对称性**: 实际种群常不对称 (增长快于减速) → 用 Richards 模型 (额外参数控制不对称)

## 失效条件/反例 (强制小节)

- **条件1: 实际种群存在 Allee 效应 (小种群 Allee 阈值)** → 表现: 低于阈值密度时种群增长率变负 → Logistic 预测增长但实际走向灭绝。**应对**: 使用带 Allee 阈值的修正 Logistic: $rN(1-N/K)(N/A-1)$ ($A$=Allee阈值)
- **条件2: Leslie 矩阵参数时不变假设在管理中失效** → 表现: 捕捞/保护措施改变存活率 → 静态 Leslie 预测偏离实际轨迹。**应对**: 使用时变 Leslie 矩阵 $L(t)$ 或随机 Leslie 矩阵 (Monte Carlo)，或建立管理策略反馈模型

## 文献

1. Murray J.D. (2002). *Mathematical Biology*, 3rd ed. Springer. ISBN: 978-0387952239
2. Caswell H. (2001). *Matrix Population Models*, 2nd ed. Sinauer. ISBN: 978-0878930968

## 来源溯源

已有 S5 .m 文件; 数学生物学教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0801 (Malthus) |
| 前置 | PARADIGM-0802 (Logistic) |
| 前置 | PARADIGM-0803 (Leslie) |
| 组合 | PARADIGM-0710 (Lotka-Volterra) |
