# PARADIGM-0705 Bootstrap重采样⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0705 |
| 类别/子类 | ⑦综合 / 统计推断 |
| 难度 | 低 |
| 适用题型关键词[] | Bootstrap, 自助法, 重采样, 置信区间, 标准误, 非参数推断, bootstrp, bias correction |
| confidence | high |
| source | Efron & Tibshirani (1994) CRC |

## 数学形式

**Bootstrap 原理:**
用样本的经验分布 $\hat{F}$ 替代真实分布 $F$，从 $\hat{F}$ 中有放回重采样:

$$\hat{\theta}^*_b = \hat{\theta}(X_b^*), \quad X_b^* \sim \hat{F}, \quad b = 1,\ldots,B$$

**Bootstrap 标准误:**
$$SE_B(\hat{\theta}) = \sqrt{\frac{1}{B-1}\sum_{b=1}^{B}\left(\hat{\theta}^*_b - \bar{\theta}^*\right)^2}$$

**Bootstrap 置信区间 (百分位法):**
$$CI_{1-\alpha} = \left[\hat{\theta}^*_{(\alpha/2)}, \hat{\theta}^*_{(1-\alpha/2)}\right]$$

**BCa (Bias-Corrected and Accelerated) 区间:**
$$CI_{1-\alpha} = \left[\hat{\theta}^*_{(\alpha_1)}, \hat{\theta}^*_{(\alpha_2)}\right]$$

其中 $\alpha_1, \alpha_2$ 经偏差修正和加速度因子调整。

**B=B 的选择规则:** $B \geq 1000$ 为标准误; $B \geq 2000$ 为 BCa 置信区间。

**对偶变量 (Antithetic Variates):** 减少方差 — 每对重采样使用互补概率。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| B (重复次数) | int | 1000 | [200, 10000] | 高 — 少则估计不稳定 |
| alpha (显著性) | double | 0.05 | (0, 0.5) | 低 |
| 样本量 n | int | — | [10, ∞) | 极高 — n<20 Bootstrap 不可靠 |
| 复杂度 | — | — | O(B·n·T_stat) | — |

## MATLAB 实现

```matlab
% Statistics and Machine Learning Toolbox
% 基础 Bootstrap
boot_samples = bootstrp(1000, @mean, data);

% Bootstrap 置信区间
ci = bootci(1000, {@mean, data}, 'Alpha', 0.05, 'Type', 'bca');

% 自定义统计量
boot_results = bootstrp(2000, @(x) prctile(x, 75), data);

% 自写完整 Bootstrap
function [se, ci, boot_dist] = bootstrap_ci(data, statistic, B, alpha)
    n = length(data);
    boot_stats = zeros(B, 1);
    rng(42);
    for b = 1:B
        idx = randi(n, [n, 1]);  % 有放回抽样
        boot_stats(b) = statistic(data(idx));
    end
    
    se = std(boot_stats);
    ci = prctile(boot_stats, [alpha/2, 1-alpha/2] * 100);
    boot_dist = boot_stats;
end
```

锚点: `bootstrp` / `bootci` (Statistics and Machine Learning Toolbox)

## Python 备选

```python
import numpy as np
from scipy.stats import bootstrap
# SciPy bootstrap
res = bootstrap((data,), np.mean, n_resamples=2000,
                confidence_level=0.95, method='BCa', random_state=42)
print(f"CI: [{res.confidence_interval.low}, {res.confidence_interval.high}]")

# 自写简洁版
def bootstrap_ci(data, stat_fn, B=2000, alpha=0.05):
    n = len(data)
    boot_stats = [stat_fn(np.random.choice(data, n, replace=True))
                  for _ in range(B)]
    lo = np.percentile(boot_stats, alpha/2*100)
    hi = np.percentile(boot_stats, (1-alpha/2)*100)
    return np.std(boot_stats), (lo, hi)
```

## 选型决策树

- **Bootstrap** — 统计量分布未知，无法解析求 SE/CI，低维数据
- **Jackknife** — 方差估计的确定性替代，B=1000 太重时用 (n 次)
- **Delta Method** — 有解析导数 → 直接用不需重采样
- **Bootstrap 假设检验** — Bootstrap-t / Bootstrap F 检验替代传统 t/F (不依赖正态)

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| result | Bootstrap 分布直方图 + CI 标注 | 展示抽样分布形态 |
| result | QQ plot (bootstrap vs 正态) | 诊断正态性假设 |

## 常见坑

1. **n < 20 时 Bootstrap 不可靠**: 经验分布 $\hat{F}$ 过于粗糙，重采样只能生成原始样本中出现的值 → 分布形状截断
2. **重采样依赖**: 时序数据的 Bootstrap 必须保留时间结构 → 用 Block Bootstrap (Moving Block / Circular Block)
3. **离群点放大**: 若样本含极端离群点，Bootstrap 样本中离群点出现 0/1/多次的概率变异性大 → 方差估计波动

## 失效条件/反例 (强制小节)

- **条件1: 时间序列/空间自相关数据 (非 IID)** → 表现: 标准 IID Bootstrap 打乱依存结构 → 方差严重低估 (忽略正相关) 或高估 (忽略负相关), CI 过窄不可靠。**应对**: 使用 Block Bootstrap / Stationary Bootstrap 或 Sieve Bootstrap (对 ARMA 模型)
- **条件2: 极值统计 (如估计分布的 99.9% 分位数)** → 表现: Bootstrap 样本只能在已有的最大观测值范围内变化，无法外推到超过样本最大值 — 分位数 CI 上界被截断。**应对**: 使用极值理论 (EVT) 参数的 Bootstrap 或 GPD 尾部分布外推

## 文献

1. Efron B. & Tibshirani R.J. (1994). *An Introduction to the Bootstrap*. CRC Press. ISBN: 978-0412042317
2. Davison A.C. & Hinkley D.V. (1997). *Bootstrap Methods and Their Application*. Cambridge University Press. ISBN: 978-0521574716

## 来源溯源

MATLAB `bootstrp` / `bootci`; 统计推断教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (参数估计) | PARADIGM-0503 (分布拟合) |
| 组合 (回归诊断) | PARADIGM-0501 (预处理) |
| 前置 | PARADIGM-0509 (t检验) |
