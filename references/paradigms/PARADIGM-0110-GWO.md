# PARADIGM-0110 灰狼优化GWO⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0110 |
| 类别/子类 | ①优化 / 群智能 |
| 难度 | 低 |
| 适用题型关键词[] | 灰狼优化, GWO, 群智能, 全局优化, 包围猎物, 社会等级, 连续优化 |
| confidence | high |
| source | matlab/optim/grey_wolf_optimizer.m |

## 数学形式

**社会等级 (Social Hierarchy):** 种群按适应度降序排列: $\alpha$ (最优), $\beta$ (次优), $\delta$ (第三优)，其余为 $\omega$ 狼。$\omega$ 狼跟随前三者更新位置。

**包围猎物 (Encircling Prey):**
$$\mathbf{D} = |\mathbf{C} \cdot \mathbf{X}_p(t) - \mathbf{X}(t)|$$
$$\mathbf{X}(t+1) = \mathbf{X}_p(t) - \mathbf{A} \cdot \mathbf{D}$$

其中系数向量:
$$\mathbf{A} = 2a \cdot \mathbf{r}_1 - a$$
$$\mathbf{C} = 2 \cdot \mathbf{r}_2$$

$a$ 从 2 线性递减至 0: $a = 2 - 2t/T_{max}$

**位置更新 (由 α, β, δ 引导):**
$$\mathbf{D}_\alpha = |\mathbf{C}_1 \cdot \mathbf{X}_\alpha - \mathbf{X}|, \quad \mathbf{D}_\beta = |\mathbf{C}_2 \cdot \mathbf{X}_\beta - \mathbf{X}|, \quad \mathbf{D}_\delta = |\mathbf{C}_3 \cdot \mathbf{X}_\delta - \mathbf{X}|$$

$$\mathbf{X}_1 = \mathbf{X}_\alpha - \mathbf{A}_1 \cdot \mathbf{D}_\alpha, \quad \mathbf{X}_2 = \mathbf{X}_\beta - \mathbf{A}_2 \cdot \mathbf{D}_\beta, \quad \mathbf{X}_3 = \mathbf{X}_\delta - \mathbf{A}_3 \cdot \mathbf{D}_\delta$$

$$\mathbf{X}(t+1) = \frac{\mathbf{X}_1 + \mathbf{X}_2 + \mathbf{X}_3}{3}$$

**变量表:**
- $\mathbf{X}_\alpha, \mathbf{X}_\beta, \mathbf{X}_\delta$ — 前三最优狼位置
- $\mathbf{A}$ — 系数向量，$|\mathbf{A}|<1$ 包围，$|\mathbf{A}|\geq 1$ 探索
- $\mathbf{C}$ — 随机权重系数 ($0 \leq C \leq 2$)，模拟猎物接近难度
- $a$ — 线性衰减参数，控制探索→开发过渡
- $\mathbf{r}_1, \mathbf{r}_2$ — $[0,1]$ 均匀随机向量

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| obj_func | function_handle | — | 接受向量返回标量 | — (问题定义) |
| dim | int | — | [1, 200] | 低 — 但 dim>100 性能下降 |
| lb | double[] | — | 变量下界 | 低 |
| ub | double[] | — | 变量上界 | 低 |
| n_wolves | int | 30 | [10, 100] | 中 — 太少探索不足 |
| max_iter | int | 500 | [100, 2000] | 低 |
| 时间复杂度 | — | — | O(n_wolves × dim × max_iter) 每代 | — |

**注:** GWO 无需算法特定参数 (无惯性权重、无学习因子)，仅需种群规模。

## MATLAB 实现

函数签名:
```matlab
[alpha_pos, alpha_score, convergence] = grey_wolf_optimizer(obj_func, dim, lb, ub, n_wolves, max_iter)
```

锚点: `matlab/optim/grey_wolf_optimizer.m` — 自写实现，基于 Mirjalili et al. (2014) 原始版本。三狼引导 + 线性衰减 a。

- `alpha_pos` — α 狼最终位置 (1×dim)
- `alpha_score` — 最优适应度值
- `convergence` — 每代 α 狼适应度记录

## Python 备选

```python
from mealpy import GWO
problem = {
    "fit_func": obj_func,
    "lb": lb,
    "ub": ub,
    "minmax": "min",
}
model = GWO.Wolf(epoch=500, pop_size=30)
best_position, best_fitness = model.solve(problem)
```

或 scikit-opt:
```python
from sko import GWO
gwo = GWO(func=obj_func, dim=dim, lb=lb, ub=ub, max_iter=500)
best_x, best_y = gwo.run()
```

## 选型决策树

- **用 GWO** — 连续优化，追求实现简单、参数极少 (仅种群规模)，对收敛速度要求高于全局最优保证
- **用 PSO (PARADIGM-0106)** — 收敛更快但参数需调，对低维多模态可行
- **用 DE (PARADIGM-0108)** — 高维多模态 (>30 dim)，需要更好的多样性保持
- **用 WOA (PARADIGM-0112)** — 多模态且需要螺旋局部求精
- **用 surrogateopt** — 目标函数昂贵
- **Trade-off:** GWO 实现最简单 (参数最少)，但早熟风险最高；DE 最鲁棒但收敛较慢；PSO 在两者之间

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 搜索空间 2D/3D 曲面图 (surf/mesh) | 展示目标函数地貌 |
| process | α/β/δ 位置轨迹图 (scatter overlay) | 三领导狼在搜索空间的移动路径 |
| result | 收敛曲线 (对数 Y 轴) | 展示探索 (前期快速下降) → 开发 (后期平缓) |

## 常见坑

1. **过早收敛 (Premature Convergence):** GWO α/β/δ 三狼引导 → 所有 ω 狼向其均值靠拢，一旦三领导狼陷入局部最优，整个种群无法逃脱。多模态函数尤甚
2. **线性衰减 a 的限制:** $a=2-2t/T$ 线性策略固定了 50% 迭代用于探索、50% 用于开发，对于不同问题此比例不一定最优。可考虑非线性衰减变体 ($a=2(1-t^2/T^2)$)
3. **多样性崩溃:** 后期所有狼收敛到同一位置 → 无探索能力。可引入随机 ω 狼重新初始化或混沌映射
4. **高维退化 (dim>100):** 距离式位置更新受维度诅咒影响 — 高维空间中距离度量失效，狼群无法有效导航
5. **边界处理:** 越界截断导致边界堆积 → 可改用随机重置或反射

## 失效条件/反例 (强制小节)

- **条件1: 欺骗性目标函数 (孤立的窄峰最优)** → 最优解是平坦山谷中的孤立尖峰，GWO 的 α 引导机制使所有狼向局部最优靠拢，永远无法发现远处的真正最优。**表现:** 收敛曲线快速平坦化于局部最优，多次运行结果一致且差 → 改用 DE 且设置大 F (F≥0.9) 或重启策略
- **条件2: 高维问题 (dim>100)** → GWO 基于距离的位置更新在高维空间中失效 (维度诅咒)，狼群探索效率急剧下降。**表现:** 收敛曲线极慢，最终解远差于 DE 或 CMA-ES → 改用 DE (PARADIGM-0108) 或 CMA-ES

## 文献

1. Mirjalili S., Mirjalili S.M. & Lewis A. (2014) "Grey Wolf Optimizer." *Advances in Engineering Software*, 69:46-61. DOI: [10.1016/j.advengsoft.2013.12.007](https://doi.org/10.1016/j.advengsoft.2013.12.007)

## 来源溯源

`matlab/optim/grey_wolf_optimizer.m`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 对比 (群智能) | PARADIGM-0106 (PSO) |
| 替代 (强多模态) | PARADIGM-0108 (DE) |
| 对比 (群智能) | PARADIGM-0112 (WOA) |
