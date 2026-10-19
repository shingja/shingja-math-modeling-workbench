# PARADIGM-0117 代理优化surrogateopt⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0117 |
| 类别/子类 | ①优化 / 代理模型优化 |
| 难度 | 中 |
| 适用题型关键词[] | surrogateopt, 代理优化, 昂贵函数, 黑箱优化, 径向基代理, 整数/边界约束, Gutmann |
| confidence | high |
| source | Gutmann (2001) J Global Opt |

## 数学形式

**代理优化框架:**
1. 在 $N_{\text{init}}$ 个初始点上评估目标函数
2. 构建代理模型 $\hat{f}(\mathbf{x})$ (RBF 插值近似 $f(\mathbf{x})$)
3. 定义 Merit Function 平衡 Exploration vs Exploitation
4. 优化 Merit Function 找到下一个采样点 $\mathbf{x}_{\text{new}}$
5. 在 $\mathbf{x}_{\text{new}}$ 上评估真实 $f$，更新代理模型
6. 重复步骤 2-5 直到评估预算用完

**RBF 代理模型:**
$$\hat{f}(\mathbf{x}) = \sum_{i=1}^{N} \lambda_i \phi(\|\mathbf{x} - \mathbf{x}_i\|) + p(\mathbf{x})$$

其中 $\phi$ 为径向基函数 (Cubic: $\phi(r)=r^3$; Thin-plate: $\phi(r)=r^2\log r$), $p$ 为多项式尾项。

**Merit Function (自适应采样):**
$$M(\mathbf{x}) = \hat{f}(\mathbf{x}) - \alpha \cdot s(\mathbf{x})$$

其中 $s(\mathbf{x})$ 为预测不确定性 (与已采样点距离)，$\alpha$ 权衡探索-利用。

**特点:**
- 与 Bayesian Optimization 类似但用 RBF 而非 Gaussian Process
- 更适合离散变量和中等维度 (n<=10)
- 可并行评估 (多点采样)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| max_evals | int | 200×n | [50, ∞) | 高 — 评估预算 |
| initial_points | int | 20 | [5,100] | 中 — 初始代理精度 |
| Integer_indices | int[] | [] | — | 中 — 离散变量 |
| 代理模型 | — | RBF | — | — |
| 复杂度 | — | — | O(N·eval_cost + N³·iter) | — |

## MATLAB 实现

```matlab
% 定义目标函数 (假设评估昂贵, 如仿真)
fun = @(x) expensive_simulation(x);

lb = [1; 1; 1]; ub = [100; 100; 100];
intcon = [1, 3];  % 变量 1 和 3 为整数

options = optimoptions('surrogateopt', ...
    'MaxFunctionEvaluations', 200, ...
    'PlotFcn', 'surrogateoptplot', ...
    'InitialPoints', 20, ...
    'UseParallel', true);

[x_opt, fval, exitflag, output] = surrogateopt(fun, lb, ub, intcon, options);

% 查看代理模型的提升曲线
% output 中有每次评估后的最佳目标值
```

锚点: `surrogateopt` (Global Optimization Toolbox)

## Python 备选

```python
# scikit-optimize (Bayesian Opt + RBF)
from skopt import gp_minimize
# 或 pySOT (Surrogate Optimization Toolbox)
from pySOT import RBFInterpolant, CubicKernel
```

## 选型决策树

- **surrogateopt** — 函数评估昂贵 + 存在整数变量 + 中等维度 n<=10
- **Bayesian Opt (PARADIGM-1002 EGO)** — 昂贵 + 连续 + 提供不确定性量化 (GP)
- **MultiStart (PARADIGM-0116)** — 评估便宜 + 不需要代理模型
- **GA (PARADIGM-0105)** — 高度非凸 + 评估昂贵 & 可大量并行
- **不要 surrogateopt** — 评估便宜 (<0.1s) → 代理模型构建开销 > 直接评估收益

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | surrogateopt 迭代图 (best fval vs eval) | 收敛曲线 |
| result | 代理模型响应面 vs 真实函数 | 1D/2D 对比 |

## 常见坑

1. **初始点不够**: 代理模型建立不准 → merit function 引导到错误区域 → 加大 InitialPoints
2. **离散变量太多时代理不准确**: RBF 假设连续平滑 → 整数变量破坏平滑性 → surrogateopt 专门处理了整数，但不保证全局最优
3. **并行评估需足够 worker**: surrogateopt 的多点采样需并行池来加速

## 失效条件/反例 (强制小节)

- **条件1: 维度 n > 20** → 表现: RBF 代理在高维空间的插值需要指数多的初始点 (curse of dimensionality) → 代理模型预测不可靠，merit function 的探索-利用平衡歪曲。**应对**: 使用 Active Subspace 降维，或将高维变量分组建模
- **条件2: 目标函数存在尖锐不连续 (如阶跃，IF-THEN 逻辑)** → 表现: RBF 假设函数连续平滑，在尖锐间断处预测严重偏离真实值 → surrogateopt 的 merit function 在间断附近给出来回矛盾的采样建议。**应对**: 使用 GA/PSO 等不依赖平滑假设的元启发式算法

## 文献

1. Gutmann H.M. (2001). "A radial basis function method for global optimization." *Journal of Global Optimization*, 19(3):201-227. DOI: [10.1023/A:1011255519438](https://doi.org/10.1023/A:1011255519438)
2. Regis R.G. & Shoemaker C.A. (2007). "A stochastic radial basis function method for the global optimization of expensive functions." *INFORMS J Computing*, 19(4):497-509.

## 来源溯源

MATLAB `surrogateopt` (R2020a+)

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-1002 (EGO, 贝叶斯优化) |
| 替代 | PARADIGM-0116 (MultiStart) |
| 替代 | PARADIGM-0105 (GA) |
