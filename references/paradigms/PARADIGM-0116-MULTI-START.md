# PARADIGM-0116 多起点全局优化MultiStart/GlobalSearch⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0116 |
| 类别/子类 | ①优化 / 全局优化 |
| 难度 | 中 |
| 适用题型关键词[] | 多起点, MultiStart, GlobalSearch, 全局优化, 局部最优陷阱, fmincon, 多峰函数 |
| confidence | high |
| source | Ugray et al. (2007) INFORMS J Computing |

## 数学形式

**问题:** 全局优化 (非凸, 多局部最优)
$$\min_{\mathbf{x}} f(\mathbf{x}), \quad \mathbf{x} \in \mathbb{R}^n$$

**MultiStart 策略:**
1. 生成 $K$ 个起始点 (均匀/散布): $\mathbf{x}_0^{(1)}, \ldots, \mathbf{x}_0^{(K)}$
2. 从每个 $\mathbf{x}_0^{(k)}$ 启动局部求解器 (如 fmincon)
3. 收集所有局部解 $\mathbf{x}^{*(k)}$
4. 全局最优: $\mathbf{x}^*_{\text{global}} = \arg\min_k f(\mathbf{x}^{*(k)})$

**GlobalSearch (智能分散搜索):**
1. 从 $\mathbf{x}_0$ 生成 trial points (scatter search + 过滤)
2. 对前景 trial points 启动局部求解器
3. 使用 Basin-Hopping 机制 — 接受差解一定概率跳出盆地

**Sobol 序列 (低差异, Quasi-random):**
相比于随机采样，覆盖更均匀 → 降低遗漏全局最优盆地概率

**起始点数建议:** $K = 10 \times n$ (维度)
对非光滑或高度多峰: $K = 50 \times n$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_start_points | int | 10×n | [5, 500] | 高 — K越大越可能找到全局最优 |
| solver | str | 'fmincon' | 局部求解器 | 中 |
| start_method | str | 'sobol' | 'random','sobol','lhs' | 中 |
| 复杂度 | — | — | O(K × 局部求解O(·)) | — |

## MATLAB 实现

```matlab
% 定义问题
fun = @(x) peaks(x(1), x(2));  % 多峰测试函数
lb = [-3; -3]; ub = [3; 3];
x0 = [0; 0];

% 方法 1: MultiStart
ms = MultiStart('Display', 'iter', 'UseParallel', true);
problem = createOptimProblem('fmincon', 'objective', fun, ...
    'x0', x0, 'lb', lb, 'ub', ub);
[x_opt, f_opt, flag, solutions] = run(ms, problem, 50);  % 50 个起点

% 方法 2: GlobalSearch
gs = GlobalSearch('Display', 'iter', 'NumTrialPoints', 1000);
[x_opt_gs, f_opt_gs] = run(gs, problem);

% 查看所有局部解
fvals = [solutions.Fval];
[~, idx] = min(fvals);
fprintf('全局最优: f(%g,%g) = %g\n', solutions(idx).X, solutions(idx).Fval);

% 绘制多起点分布
figure;
for k = 1:length(solutions)
    plot(solutions(k).X(1), solutions(k).X(2), 'o'); hold on;
end
```

锚点: `MultiStart` / `GlobalSearch` (Global Optimization Toolbox)

## Python 备选

```python
from scipy.optimize import basinhopping, differential_evolution
# MultiStart 等效: scipy.optimize.shgo 或自写循环
from scipy.optimize import minimize
import numpy as np

best_x, best_f = None, np.inf
for k in range(50):
    x0 = np.random.uniform(lb, ub)
    res = minimize(fun, x0, bounds=list(zip(lb, ub)), method='L-BFGS-B')
    if res.fun < best_f:
        best_f, best_x = res.fun, res.x
```

## 选型决策树

- **MultiStart** — 已知函数多峰，K 个均匀散布起点 + 局部求解器
- **GlobalSearch** — 希望智能筛选起点 (避免在差盆地上浪费)
- **GA (PARADIGM-0105)** — 高度非凸/非光滑/离散 + 不需要梯度
- **Bayesian Opt (PARADIGM-1002)** — 函数评估昂贵 (如一次仿真几分钟)
- **Surrogate Opt (PARADIGM-0117)** — 评估昂贵 + 可并发 + 边界/整数约束

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 目标函数 2D 等高线图 | 多峰结构 |
| process | 起点 (scatter) + 各起点收敛路径 (quiver) | 展示盆地 |
| result | 各局部解目标值排序柱状图 | 全局 vs 次优 |

## 常见坑

1. **起始点未充分散布**: 随机采样可能遗漏重要盆地 → 用 Sobol 序列
2. **MultiStart 并行但评估次数线性增长**: 大部分起点去往相同盆地浪费 → GlobalSearch 自带盆地过滤
3. **边界框定不好**: lb,ub 太宽 → 采样分散; 太窄 → 错过全局最优盆地

## 失效条件/反例 (强制小节)

- **条件1: 维度 n > 50 (高维全局优化)** → 表现: Sobol 序列在 50 维空间覆盖度不足 — 起始点间平均距离与盆地直径之比随维度呈指数增长，MultiStart 几乎等概率落在任何盆地 (如同随机搜索)。**应对**: n>50 时用 surrogateopt (代理模型) 或降低维度 (活性子空间/变量筛选)
- **条件2: 盆地极小且被大片"高原"包围** → 表现: 局部求解器的收敛条件在高原上停滞 (梯度≈0) → 起点无法被梯度信息"导入"盆地，MultiStart 在高原终止而非真正局部最优。**应对**: 使用 GA 或 PSO 等无梯度方法在高原阶段探索，接近盆地后切换到 fmincon 精化

## 文献

1. Ugray Z., Lasdon L., Plummer J., Glover F., Kelly J. & Marti R. (2007). "Scatter search and local NLP solvers: A multistart framework for global optimization." *INFORMS J Computing*, 19(3):328-340. DOI: [10.1287/ijoc.1060.0175](https://doi.org/10.1287/ijoc.1060.0175)
2. Sobol I.M. (1967). "On the distribution of points in a cube and the approximate evaluation of integrals." *USSR Computational Mathematics and Mathematical Physics*, 7(4):86-112.

## 来源溯源

MATLAB `MultiStart` / `GlobalSearch`

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0105 (GA) |
| 替代 | PARADIGM-0117 (surrogateopt) |
| 替代 | PARADIGM-0106 (PSO) |
| 前置 | PARADIGM-0103 (NLP fmincon) |
