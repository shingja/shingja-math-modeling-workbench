# PARADIGM-0801 曲线链式约束求解 (Chain Constraint on Curve)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0801 |
| 类别/子类 | ⑧机理 / 运动学约束 |
| 难度 | 高 |
| 适用题型关键词[] | 链式约束, 刚体链, 曲线运动, 板凳龙, 蛇形机器人, 车队编队, 弦长约束, 多体运动学, Brent二分法 |
| confidence | high |
| source | T01 板凳龙闹元宵 (2024国赛A题) 实战验证; Press (2007) Numerical Recipes §9.3 Brent方法 |

## 核心约定

**链方向 ≠ 运动方向**: `chain_direction = -head_direction`

盘入时龙头向内(θ减小), 沿链向龙尾方向θ增大(向外)。此约定是整个模型正确性的基础。

## 数学形式

**阿基米德螺线**: $r(\theta) = b\theta$, 直角坐标 $x = b\theta\cos\theta, y = b\theta\sin\theta$

**弦长约束 (精确)**:
$$d(\theta_i, \theta_{i+1}) = b\sqrt{\theta_i^2 + \theta_{i+1}^2 - 2\theta_i\theta_{i+1}\cos(\theta_i - \theta_{i+1})} = L_i$$

**弧长公式 (辅助)**:
$$s(\theta) = \frac{b}{2}\left[\theta\sqrt{\theta^2+1} + \operatorname{arcsinh}(\theta)\right]$$

**时间推进**: $s = vt$ → 弧长反解确定 $\theta_0(t)$

## 数值方法

Brent二分法 (scipy.optimize.brentq) 求解非线性方程:
$$f(\theta_{i+1}) = d(\theta_i, \theta_{i+1}) - L_i = 0$$

**Hot-start加速**: 用上一时间步的θ数组作为当前步fsolve初始猜测。

**紧区间策略**: $\Delta\theta \approx L_i / (b\sqrt{\theta_i^2+1})$ 缩小搜索区间。

## 常见陷阱

1. **弧长偏移近似**: $s(\theta_{i+1}) \approx s(\theta_i) \pm L_i$ 在曲率大处不可接受 (T01偏差29s)
2. **链方向混淆**: 错误假设沿链方向与龙头运动方向相同 → 龙身出现在龙头前方
3. **θ→0奇点**: 螺线原点附近曲率→∞, 弦长约束可能无解

## MATLAB锚点

`brentq` → MATLAB `fzero`; `fsolve` → MATLAB `fsolve`
