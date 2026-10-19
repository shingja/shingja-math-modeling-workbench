# PARADIGM-0211 插值方法汇总⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0211 |
| 类别/子类 | ②预测 / 插值与拟合 |
| 难度 | 低 |
| 适用题型关键词[] | 插值, 样条, spline, pchip, interp1, 分段插值, 平滑, de Boor, 缺失值填充 |
| confidence | high |
| source | de Boor (1978) Springer |

## 数学形式

**问题:** 给定 $\{(x_i, y_i)\}_{i=1}^n$ ($x_1 < x_2 < \cdots < x_n$), 求 $\hat{y} = f(x)$ 在任意 $x \in [x_1, x_n]$ 处的值。

**线性插值 (Linear):**
$$f(x) = y_i + \frac{y_{i+1} - y_i}{x_{i+1} - x_i}(x - x_i), \quad x \in [x_i, x_{i+1}]$$

**三次样条 (Cubic Spline, interp1 'spline'):**
- $f(x), f'(x), f''(x)$ 在节点处连续
- 自然边界: $f''(x_1) = f''(x_n) = 0$
- 节点间三次多项式

**保形 (Shape-Preserving) 插值 (pchip):**
$$f(x) = \text{分段三次 Hermite 插值}$$
- 保持数据单调性: 节点间无 overshoot
- $f'(x_i)$ 由相邻差分的加权调和平均决定

**外推 (Extrapolation):**
默认不推荐，若必须: 线性外推 $\hat{y} = y_1 + (x-x_1)\frac{y_2-y_1}{x_2-x_1}$

**Grind 插值 (2D/3D):**
`interp2` / `interp3` / `griddata` — 二维/三维/散点插值

**插值 vs 拟合:**
- 插值: 通过所有已知点 → 适合精确测量数据
- 拟合: 不通过所有点 → 适合含噪声数据

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| method | str | 'linear' | 'linear','nearest','spline','pchip','makima' | 高 |
| extrap | str/bool | false | false,'linear',标量 | 中 — 外推不靠谱 |
| 复杂度 | — | — | O(log n) 二分搜索+O(1) 计算 | — |

## MATLAB 实现

```matlab
% 1D 插值
x = 0:0.5:10; y = sin(x);
xq = 0:0.1:10;  % 查询点

y_linear = interp1(x, y, xq, 'linear');
y_spline = interp1(x, y, xq, 'spline');
y_pchip = interp1(x, y, xq, 'pchip');  % 保形
y_makima = interp1(x, y, xq, 'makima');  % 改进Akima

% 对比
plot(x, y, 'ko', xq, y_spline, 'b-', xq, y_pchip, 'r--');
legend('Data', 'Spline', 'PCHIP');

% 2D 插值 (网格)
[Xq, Yq] = meshgrid(xq, yq);
Zq = interp2(X, Y, Z, Xq, Yq, 'spline');

% 散点插值 (非网格)
F = scatteredInterpolant(x_scattered, y_scattered, z_scattered, 'natural');
zq = F(xq, yq);

% 样条工具箱
pp = spline(x, y);    % 分段多项式形式
yq = ppval(pp, xq);   % 求值
dy = fnder(pp);       % 一阶导数
I = fnint(pp);        % 积分
```

锚点: `interp1` / `spline` / `pchip` / `interp2` / `griddata` (MATLAB 内置)

## Python 备选

```python
import numpy as np
from scipy.interpolate import interp1d, CubicSpline, PchipInterpolator

f_linear = interp1d(x, y, kind='linear')
f_spline = CubicSpline(x, y, bc_type='natural')
f_pchip = PchipInterpolator(x, y)
# 2D
from scipy.interpolate import griddata
```

## 选型决策树

- **线性插值** — 快速 + 不会 overshoot，适合点间线性近似
- **spline** — 需要光滑导数 + 自然曲率，但不保单调性
- **pchip** — 需要保形 (不产生 overshoot/undershoot)，保守型
- **makima** — pchip 的改进版 (在跳跃处更平滑)
- **不要插值 (outliers present)** — 噪声数据 → 用平滑样条或 Lowess

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | 多种方法插值结果对比图 | 展示 overshoot/光滑性差异 |
| process | 插值误差 vs 节点密度图 | 展示收敛阶 |

## 常见坑

1. **外推无保证 (extrap)**: 默认 NaN → 明确需要外推时设 'extrap'，但外推误差极大
2. **Runge 现象 (等距节点+高阶多项式)**: 端点震荡 → 用 spline 代替全局多项式
3. **样条在急剧变化处 overshoot**: spline 可能产生人造极值 → 用 pchip
4. **外插值方法 naive**: 默认线性外推可能与内部插值方法不一致

## 失效条件/反例 (强制小节)

- **条件1: 含噪声的测量数据 (非精确值)** → 表现: 插值严格通过每个数据点 → 噪声被完美"拟合"，插值曲线震荡剧烈 (尤其是 spline)。**应对**: 使用平滑样条 `csaps` (cubic smoothing spline) 或 Lowess 局部加权回归，而非精确插值
- **条件2: 严重不均匀节点分布 (一侧密一侧疏)** → 表现: pchip 在稀疏区域可能产生线性形变; spline 在稀疏区域可能产生大振幅 overshoot → 插值在疏区间不可靠。**应对**: 使用 'makima' (改进 Akima, 对不均匀分布更鲁棒) 或重构均匀网格

## 文献

1. de Boor C. (1978). *A Practical Guide to Splines*. Springer. ISBN: 978-0387953663
2. Fritsch F.N. & Carlson R.E. (1980). "Monotone piecewise cubic interpolation." *SIAM J Numerical Analysis*, 17(2):238-246. (pchip 基础)

## 来源溯源

MATLAB `interp1` / `spline` / `pchip`; 数值分析教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0208 (State-Space, 时序缺失补值) |
| 组合 | PARADIGM-0904 (缺失数据插补) |
| 组合 | PARADIGM-0501 (数据预处理) |
