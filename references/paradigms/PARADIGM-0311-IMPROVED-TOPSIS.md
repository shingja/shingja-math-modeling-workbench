# PARADIGM-0311 改进TOPSIS(马氏距离+前景理论+动态)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0311 |
| 类别/子类 | ③评价 / TOPSIS改进 |
| 难度 | 高 |
| 适用题型关键词[] | 改进TOPSIS, 马氏距离, 前景理论, 动态TOPSIS, 相关性修正, 损失厌恶, 时序评价 |
| confidence | medium |
| source | 多篇改进TOPSIS论文综合 |

## 数学形式

**改进1: 马氏距离 TOPSIS (消除指标相关性):**
$$d(\mathbf{x}, \mathbf{y}) = \sqrt{(\mathbf{x} - \mathbf{y})^T \mathbf{\Sigma}^{-1} (\mathbf{x} - \mathbf{y})}$$

其中 $\mathbf{\Sigma}$ 为指标的协方差矩阵 (由数据估计)。

**优势:** 欧氏距离假设指标独立 → 相关指标被重复计数 → 马氏距离去相关化。

**改进2: 前景理论 TOPSIS (考虑参考依赖+损失厌恶):**
价值函数 (Kahneman & Tversky, 1979):
$$v(\Delta x) = \begin{cases} \Delta x^\alpha & \Delta x \geq 0 \\ -\lambda(-\Delta x)^\beta & \Delta x < 0 \end{cases}$$

将 TOPSIS 中的原始指标值 $x_{ij}$ 替换为前景价值 $v(x_{ij} - r_j)$:
- $r_j$ — 参考点 (如均值/中位数/目标值)
- $\alpha,\beta$ — 风险态度 (通常 0.88)
- $\lambda$ — 损失厌恶系数 (通常 2.25)

**改进3: 动态 TOPSIS (面板数据):**

对 $T$ 个时间截面的 TOPSIS 贴近度 $C_i(t)$:
$$\bar{C}_i = \sum_{t=1}^{T} w_t \cdot C_i(t), \quad w_t \text{ 由时间偏好决定}$$

或使用二次加权 (时间越近权重越大):
$$w_t = \frac{t}{\sum_{s=1}^{T} s}$$

**组合改进模型:**

三步: (1) 马氏距离代替欧氏 → (2) 前景价值代替原始值 → (3) 时间加权聚合

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| alpha (收益凹度) | double | 0.88 | [0.5, 1.0] | 高 |
| beta (损失凸度) | double | 0.88 | [0.5, 1.0] | 中 |
| lambda (损失厌恶) | double | 2.25 | [1.5, 4.0] | 极高 — 主导损失感知 |
| reference (参考点) | str | 'median' | 'mean','median','target' | 高 |
| Sigma (协方差) | — | 数据估计 | — | 极高 — n<m时不可逆 |

## MATLAB 实现

函数签名 (自写):
```matlab
[scores, ranking] = improved_topsis(X, weights, criteria_type, ...
    improvements, options)
% improvements: {'mahalanobis', 'prospect', 'dynamic'}
```

锚点: 自写-见S5:improved_topsis.m

```matlab
function C = improved_topsis(X, w, is_benefit, method, opts)
    [n, m] = size(X);
    
    if strcmp(method, 'mahalanobis')
        Sigma = cov(X);
        Sigma_inv = pinv(Sigma);  % 伪逆处理奇异性
        % 马氏距离下的 TOPSIS
        % ... 
    elseif strcmp(method, 'prospect')
        % 前景价值变换
        alpha = opts.alpha; beta = opts.beta; lambda = opts.lambda;
        ref = median(X, 1);  % 参考点
        V = zeros(size(X));
        for j = 1:m
            delta = X(:,j) - ref(j);
            V(delta >= 0, j) = delta(delta >= 0).^alpha;
            V(delta < 0, j) = -lambda * (-delta(delta < 0)).^beta;
        end
        X = V;
    elseif strcmp(method, 'dynamic')
        % 时间加权
        T = size(X, 3);  % n×m×T
        t_weights = (1:T) / sum(1:T);
        Ct = zeros(n, T);
        for t = 1:T
            Ct(:,t) = standard_topsis(X(:,:,t), w, is_benefit);
        end
        C = Ct * t_weights';
    end
end
```

## Python 备选

```python
import numpy as np
from scipy.spatial.distance import mahalanobis
# 马氏距离: scipy 内置
VI = np.linalg.pinv(np.cov(X.T))
mahal = mahalanobis(x, y, VI)
```

## 选型决策树

- **马氏距离 TOPSIS** — 指标间存在显著相关性 (同维度多重计数问题)
- **前景理论 TOPSIS** — 决策者行为非理性 (损失规避/参考依赖)
- **动态 TOPSIS** — 面板数据/时序评价 (多年份跟踪)
- **标准 TOPSIS (PARADIGM-0302)** — 无以上三个问题时标准版已够用

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 指标相关矩阵 heatmap | 揭示相关性 |
| result | 前景价值函数 v(Δx) 曲线 | S形不对称 |
| result | 贴近度时序曲线 (动态TOPSIS) | 排名迁移 |

## 常见坑

1. **马氏距离的 $\Sigma^{-1}$ 奇异性**: n < m 时协方差矩阵不可逆 → 用 pinv 或 shrinkage 估计 $\hat{\Sigma} = (1-\delta)\Sigma + \delta I$
2. **前景理论的参数主观性**: $\alpha,\beta,\lambda$ 来自行为经济学实验，不一定适用于工程决策 → 做参数敏感性分析
3. **三种改进叠加 → 黑箱**: 同时用三个改进导致每一改进的贡献无法分配 → 分别评估每一改进的效果

## 失效条件/反例 (强制小节)

- **条件1: 马氏距离在 n < m (样本少于指标) 时不可用** → 表现: $\Sigma$ 奇异 (不满秩) → 逆不存在。伪逆 $\Sigma^+$ 给出的马氏距离在零空间方向退化为 0 → 某些指标的差异被忽略。**应对**: 使用 Shrinkage 协方差估计或先用 PCA 降维使 m < n
- **条件2: 前景理论中参考点 $r_j$ 设为均值 → 损失/收益对等分布时无差异** → 表现: 若数据关于均值对称分布，前景价值变换的正负对称 → 变换后的值与原始值几乎线性 → 无增益。**应对**: 参考点应设为有行为意义的锚点 (如上一期值、目标值、行业标杆)

## 文献

1. Kahneman D. & Tversky A. (1979). "Prospect theory: An analysis of decision under risk." *Econometrica*, 47(2):263-292.
2. Mahalanobis P.C. (1936). "On the generalized distance in statistics." *Proceedings of the National Institute of Sciences of India*, 2(1):49-55.

## 来源溯源

自写 improved_topsis.m

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0302 (TOPSIS) |
| 互补 | PARADIGM-0304 (模糊评价) |
| 互补 | PARADIGM-0310 (区间评价) |
