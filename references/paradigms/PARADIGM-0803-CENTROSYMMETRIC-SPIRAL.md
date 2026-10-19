# PARADIGM-0803 中心对称盘出螺线 (Centrosymmetric Exit Spiral)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0803 |
| 类别/子类 | ⑧机理 / 几何定义 |
| 难度 | 低 |
| 适用题型关键词[] | 中心对称, 盘出螺线, E(θ)=-P(θ), θ+π偏移, 螺线几何 |
| confidence | high |
| source | T01 板凳龙闹元宵 (2024国赛A题) 实战验证 |

## 核心约定

**盘出螺线 = 中心对称像, 非θ+π偏移**: $E(\theta) = -P(\theta) \neq P(\theta+\pi)$

## 数学形式

$P(\theta) = (b\theta\cos\theta, b\theta\sin\theta)$ (盘入螺线)

$P(\theta+\pi) = (-b(\theta+\pi)\cos\theta, -b(\theta+\pi)\sin\theta) = -P(\theta) - (b\pi\cos\theta, b\pi\sin\theta)$

**偏差**: $P(\theta+\pi) - (-P(\theta)) = -(b\pi\cos\theta, b\pi\sin\theta)$, 模长 $b\pi$

**每圈偏差**: $b\pi \approx 0.85$m (当 $p=1.7$m, $b=0.27$)

## 常见陷阱

1. **θ+π近似**: 偏差累积 → 盘出路径整体偏移
2. **未在代码中区分**: `spiral_point(theta+pi)` vs `-spiral_point(theta)` (T01 v2.3修正)

## MATLAB锚点

`P_exit = -spiral_point(theta, b)`, 非 `spiral_point(theta+pi, b)`
