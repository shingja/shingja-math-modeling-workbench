# PARADIGM-0807-DIFFEQ-ITERATOR 差分方程通用迭代器+蛛网图⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0807-DIFFEQ-ITERATOR |
| 类别/子类 | ⑧机理建模 / 差分方程 |
| 难度 | 中 |
| 适用题型关键词[] | 差分方程, 迭代, 蛛网图, 平衡点, 稳定性, 周期解, 分岔, 离散动力系统, 种群模型 |
| confidence | high |
| source | 补强Ch16 / 教材2015_Strogatz / 题解反推_差分方程类 |

## 数学形式

**一阶自治差分方程**:

$$x_{n+1} = f(x_n), \quad n = 0, 1, 2, \ldots$$

**平衡点 (不动点)**:

$$x^* = f(x^*)$$

**局部稳定性判据 (线性化)**:

$$|f'(x^*)| < 1 \Rightarrow \text{局部渐近稳定}$$
$$|f'(x^*)| > 1 \Rightarrow \text{不稳定}$$
$$|f'(x^*)| = 1 \Rightarrow \text{需高阶项判定 (临界情况)}$$

**周期-k 解**:

$$x_{n+k} = x_n, \quad \text{即 } f^k(x^*) = x^*, \quad f^j(x^*) \neq x^* \; (1 \leq j < k)$$

稳定性由 $|(f^k)'(x^*)| = |\prod_{i=0}^{k-1} f'(x_i^*)|$ 判定。

**蛛网图 (Cobweb Diagram) 构造**:

1. 在 $x_n$-$x_{n+1}$ 平面上绘制 $y = f(x)$ 和 $y = x$
2. 从初始点 $(x_0, 0)$ 垂直移动到 $(x_0, f(x_0))$
3. 水平移动到 $(f(x_0), f(x_0))$ (交 $y=x$)
4. 垂直移动到 $(f(x_0), f(f(x_0)))$ (交 $y=f(x)$)
5. 反复 → 可视化迭代轨迹

**高阶线性差分方程**:

$$x_{n+k} + a_1 x_{n+k-1} + \cdots + a_k x_n = 0$$

特征方程: $\lambda^k + a_1 \lambda^{k-1} + \cdots + a_k = 0$。

$|\lambda_i| < 1 \, \forall i$ → 渐近稳定; $\exists |\lambda_i| > 1$ → 不稳定。

**Logistic 映射 (典型非线性)**:

$$x_{n+1} = r x_n (1 - x_n), \quad 0 \leq x_n \leq 1, \; 0 \leq r \leq 4$$

| 变量 | 含义 | 典型范围 |
|------|------|---------|
| $x_n$ | 第 $n$ 步状态 | 取决于模型 |
| $f(x)$ | 递推函数 (迭代映射) | 连续可微最优 |
| $x^*$ | 平衡点/不动点 | $f(x^*) = x^*$ |
| $f'(x^*)$ | 平衡点处导数 | $<1$ 稳定, $>1$ 不稳定 |
| $r$ | Logistic 参数 | $[0, 4]$ |
| $k$ | 周期长度 | $1, 2, 4, \ldots$ |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 初始值 $x_0$ | float | — | 模型定义域 | 高—不同初始值可能收敛到不同吸引子 (多稳态) |
| 迭代步数 $N$ | int | 100 | 10-10000 | 中—需足够长观察渐近行为 |
| 暂态丢弃步数 `transient` | int | 20 | 0-$N$/2 | 高—丢弃不足可能误判周期/混沌 |
| 收敛容差 $\varepsilon$ | float | 1e-8 | 1e-12~1e-4 | 高—太大误判收敛, 太小永不停 |
| 函数参数 (如 Logistic $r$) | float | — | 分岔参数范围 | 极高—跨临界值触发分岔, 定性行为改变 |

**单步迭代复杂度**: $O(1)$ (仅需一次 $f$ 求值)
**$N$ 步迭代**: $O(N)$
**平衡点搜索**: 解 $f(x) = x$, 可用二分法/Newton 法 ($O(\log(1/\varepsilon))$), 或多初始点扫参

## MATLAB 实现

```matlab
% === 通用差分方程迭代器 ===
% 自写-见S5:diffeq_iterate.m
function [trajectory, fixed_pts, stability] = diffeq_iterate(f, x0, N, varargin)
    % f: function handle, f(x) 返回下一状态
    % x0: 初始值
    % N: 迭代步数
    % 可选: 'transient', transient_steps (丢弃前 transient 步)
    % 输出: trajectory (N+1)×1, fixed_pts (平衡点列表), stability (稳定性标记)
    
    p = inputParser;
    addParameter(p, 'transient', 0);
    addParameter(p, 'tolerance', 1e-8);
    parse(p, varargin{:});
    
    trajectory = zeros(N + 1, 1);
    trajectory(1) = x0;
    for n = 1:N
        trajectory(n + 1) = f(trajectory(n));
    end
    
    % 从暂态后数据检测周期
    tail = trajectory(p.Results.transient + 1:end);
    % 检测收敛/周期/混沌 (自相关分析)
    % ...
end

% === 蛛网图绘制 ===
function cobweb_plot(f, x0, N, xlims)
    x = linspace(xlims(1), xlims(2), 200);
    plot(x, f(x), 'b-', 'LineWidth', 1.5); hold on;
    plot(x, x, 'k--', 'LineWidth', 1);
    
    xn = x0;
    for i = 1:N
        xn1 = f(xn);
        plot([xn, xn], [xn, xn1], 'r-', 'LineWidth', 0.5);
        plot([xn, xn1], [xn1, xn1], 'r-', 'LineWidth', 0.5);
        xn = xn1;
    end
    xlabel('x_n'); ylabel('x_{n+1}');
    title('Cobweb Diagram');
end

% === 锚点参考 ===
% Leslie 种群模型已有 matlab/simulation/leslie_model.m
% Logistic 映射分岔图 — diffeq_iterate.m 中含 bifurcation_diagram 函数
```

**锚点工具**: `matlab/simulation/leslie_model.m` (Leslie 种群矩阵模型, 线性差分方程组)
**自写 (S5)**: `diffeq_iterate.m` — 通用迭代器 + 蛛网图 + 分岔图 + 周期检测

## Python 备选

```python
import numpy as np
import matplotlib.pyplot as plt

def diffeq_iterate(f, x0, N, transient=0):
    """通用差分方程迭代器"""
    traj = np.zeros(N + 1)
    traj[0] = x0
    for n in range(N):
        traj[n + 1] = f(traj[n])
    return traj[transient:]

def cobweb(f, x0, N, ax=None, xlim=(0, 1)):
    """绘制蛛网图"""
    if ax is None:
        fig, ax = plt.subplots()
    x = np.linspace(*xlim, 200)
    ax.plot(x, f(x), 'b-', lw=1.5)
    ax.plot(x, x, 'k--', lw=1)
    xn = x0
    for _ in range(N):
        xn1 = f(xn)
        ax.plot([xn, xn], [xn, xn1], 'r-', lw=0.5)
        ax.plot([xn, xn1], [xn1, xn1], 'r-', lw=0.5)
        xn = xn1
    return ax

# Logistic 映射分岔图
def logistic_bifurcation(r_range, n_iter=1000, n_discard=200):
    for r in r_range:
        x = 0.5
        traj = []
        for i in range(n_iter):
            x = r * x * (1 - x)
            if i >= n_discard:
                traj.append(x)
        plt.plot([r]*len(traj), traj, ',k', alpha=0.25)
```

备选库: `scipy.optimize.fixed_point` (不动点迭代), `sympy` (符号求平衡点与特征值)

## 选型决策树

- **一维自迭代 + 定性分析** → 蛛网图 + 导数稳定性判定 (直观, 首选)
- **一维自迭代 + 分岔分析** → 分岔图 (参数扫参) + Lyapunov 指数
- **线性高维差分方程组** → 系数矩阵特征值分析 ($|\lambda|_{\max} < 1$)
- **非线性高维差分方程组** → Newton-Raphson 不动点 + Jacobian 谱半径
- **连续过程的离散化 (Euler 法)** → 差分方程, 注意时间步长 $\Delta t$ 的选择影响稳定性
- **周期解/混沌判定** → 自相关函数 + 功率谱 + Lyapunov 指数
- **需要解析表达式** → `sympy.rsolve` 符号求解线性差分方程
- **微分方程建模 (连续)** → 应优先使用常微分方程 (ODE) 方法, 见 PARADIGM-0808 (变分法/打靶法)

## 典型图型

- **raw**: 时间序列折线图 ($x_n$ vs $n$)
- **process**: 蛛网图 (cobweb diagram)—$x_n$ vs $x_{n+1}$ 平面, $y=f(x)$ 曲线 + $y=x$ 对角 + 红色迭代轨迹
- **result**: 分岔图 (bifurcation diagram)—参数 $r$ 为横轴, $x_n$ (暂态后) 为纵轴; 或相图 ($x_n$ vs $x_{n-1}$)
- **进阶**: Lyapunov 指数 vs 参数, 周期-参数域着色图 (不同周期用不同颜色)

## 常见坑

1. **$|f'(x^*)| = 1$ 时线性化失效**: 用一阶导数判定临界情况不可靠, 需检查二阶/三阶导数 (如 $x_{n+1} = x_n - x_n^3$, $f'(0)=1$ 但 0 是渐近稳定)
2. **暂态未充分丢弃**: 将暂态行为误判为稳态 — 特别是近分岔点时暂态可能极长 (临界慢化, critical slowing down)
3. **平衡点遗漏**: $f(x) = x$ 的解可能在感兴趣区间外但通过迭代可达 — 搜索平衡点应在全定义域进行
4. **蛛网图对不连续函数失效**: 如分段定义 $f(x)$, 蛛网图在间断点产生虚假跳线 — 需在间断处断开
5. **多稳态区域初始值偏倚**: 不同 $x_0$ 收敛到不同吸引子 — 建议多初始点扫参并记录吸引盆

## 失效条件/反例 (强制小节)

- **条件1**: $f(x)$ 非光滑 (不连续或不可微) — 如分段函数 $f(x) = \lfloor 3.8x(1-x) \rfloor$。蛛网图的垂直线段在间断处失去意义, 且 $f'(x^*)$ 不存在, 线性化稳定性判据完全失效。**表现**: 蛛网图在间断处产生"跳跃"线, 迭代可能跳过精细结构。**替代**: 直接用迭代轨迹 (时间序列), 或分析分段点两侧的局部行为
- **条件2**: 高维差分方程 ($\dim > 2$) — 蛛网图本质上仅适用于 $(x_n, x_{n+1})$ 的 2D 映射可视化, 无法扩展到三维及以上系统。**表现**: 二维蛛网图不能展示高维耦合效应。**替代**: 相图 (2D/3D 投影)、Poincare 截面、时间序列 + 频谱分析
- **条件3**: $f(x)$ 在迭代过程中超出定义域 — 如 Logistic $x_{n+1} = 3.8 x_n (1-x_n)$, 若 $x_0$ 在 $[0,1]$ 内则安全, 但若 $f$ 未做域约束, 某些参数/初始值组合可能产生非法值 (如负种群或概率 >1)。**表现**: 迭代值发散至 NaN/Inf。**预防**: 在 $f(x)$ 内添加域检查或饱和处理
- **条件4**: 刚性系统 — 差分方程包含快慢时间尺度 (如 $x_{n+1} = 0.01 x_n$ 为慢, $y_{n+1} = 100 y_n$ 为快), 标准迭代步长固定, 慢变量几乎不变而快变量指数增长。**替代**: 多重时间尺度分析, 或转换回微分方程用刚性 ODE 求解器

## 文献

1. Strogatz, S. H. (2015). *Nonlinear Dynamics and Chaos: With Applications to Physics, Biology, Chemistry, and Engineering* (2nd ed.). CRC Press. ISBN: 978-0813349107.
2. Devaney, R. L. (2003). *An Introduction to Chaotic Dynamical Systems* (2nd ed.). Westview Press. ISBN: 978-0813340852.
3. May, R. M. (1976). Simple mathematical models with very complicated dynamics. *Nature*, 261(5560), 459-467. DOI: [10.1038/261459a0](https://doi.org/10.1038/261459a0).

## 来源溯源

- 教材源路径: 数学建模算法与应用 第16章 差分方程建模
- 论文三元组: May 1976, Logistic map chaos, Nature
- 开源仓库: [DynamicalSystems.jl](https://github.com/JuliaDynamics/DynamicalSystems.jl) (Julia, 动力学系统标准库)

## 关联范式卡

组合: PARADIGM-0808-VARIATIONAL-SHOOTING (差分方程作为变分问题离散化), PARADIGM-0605-LYAPUNOV (Lyapunov 指数判定混沌)
替代: PARADIGM-0403-ODE-RK (连续模型 → ODE 数值解, 非差分), PARADIGM-0317-DES (随机迭代 → 离散事件仿真)
前置: PARADIGM-0801-MECHANISM-MODELING (机理建模基础—从差分到微分), PARADIGM-0102-NONLINEAR-EQ (非线性方程求根—不动点搜索)
