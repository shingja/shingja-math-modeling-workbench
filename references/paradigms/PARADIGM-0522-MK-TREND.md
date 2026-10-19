# PARADIGM-0522  Mann-Kendall 趋势检验⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0522 |
| 类别/子类 | ⑤统计 / 趋势检验 |
| 难度 | 中 |
| 适用题型关键词[] | Mann-Kendall, 趋势检验, 非参数, 单调趋势, Sen斜率, 水文气象, 环境趋势, 时间序列趋势, 气候变化, 水质趋势, 非参数检验 |
| confidence | high |
| source | Mann, H.B. (1945) Nonparametric Tests Against Trend, *Econometrica*, 13(3), 245-259; Kendall, M.G. (1975) *Rank Correlation Methods* (4th ed.), Charles Griffin |

## 数学形式

**Mann-Kendall 检验统计量 S**:
$$S = \sum_{i=1}^{n-1} \sum_{j=i+1}^{n} \operatorname{sgn}(x_j - x_i)$$
$$\operatorname{sgn}(\theta) = \begin{cases} +1, & \theta > 0 \\ 0, & \theta = 0 \\ -1, & \theta < 0 \end{cases}$$

即统计所有"后值大于前值"的对数 $P$ 与"后值小于前值"的对数 $M$, $S = P - M$。

**方差的结 (tie) 校正**:
$$\operatorname{Var}(S) = \frac{n(n-1)(2n+5) - \sum_{k=1}^{g} t_k(t_k-1)(2t_k+5)}{18}$$

其中 $g$ 为结组数, $t_k$ 为第 $k$ 组结中的观测数 (即相同值的个数)。相等观测 (结) 不贡献 S 但影响方差。当数据精度有限 (如水质检测限以下统一报告为 "<0.01") 时结校正至关重要。

**标准化检验统计量 Z** (渐近正态, 连续性校正):
$$Z = \begin{cases} \frac{S-1}{\sqrt{\operatorname{Var}(S)}}, & S > 0 \\ 0, & S = 0 \\ \frac{S+1}{\sqrt{\operatorname{Var}(S)}}, & S < 0 \end{cases}$$

$|Z| > Z_{1-\alpha/2}$ 时拒绝"无趋势"的零假设。双尾检验: $|Z| > 1.96$ 时在 5% 显著水平下趋势显著。

**Sen 斜率 (Theil-Sen Estimator)**:
$$\beta = \text{median}\left\{ \frac{x_j - x_i}{j - i} : 1 \leq i < j \leq n \right\}$$

对所有 $N = n(n-1)/2$ 对计算斜率后取中位数, 对异常值极度鲁棒 (崩溃点 29.3%), 远优于普通最小二乘对单个异常值的敏感性。

**预白化 (Pre-whitening, Yue & Wang 2004)** — 处理自相关:
$$Y_t = X_t - \rho X_{t-1}, \quad \rho = \text{AR(1) 系数}$$

先估计 AR(1) 系数 $\rho$, 若 $|\rho| > 0.1$ 则对序列做预白化, 然后再对 $Y_t$ 做 MK 检验。或使用 Hamed & Rao (1998) 方差校正:
$$\operatorname{Var}(S)^* = \operatorname{Var}(S) \cdot \frac{n}{n^*}$$
其中 $n^*$ 为有效样本量, 由序列的自相关函数估计。

**季节性 MK (Hirsch et al., 1982)**:
$$S_{\text{total}} = \sum_{k=1}^{K} S_k, \quad \operatorname{Var}(S_{\text{total}}) = \sum_{k=1}^{K} \operatorname{Var}(S_k)$$
其中 $S_k$ 为第 $k$ 个季节 (如每月) 内的 MK 统计量, 各季节间假设独立, 适用于月度/季度数据。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| alpha | numeric | 0.05 | 0.01~0.10 | 低 — 仅影响拒绝域 |
| tail | string | 'both' | both/right/left | 中 — 单/双尾影响功效 |
| prewhiten | logical | false | true/false | 高 — 存在自相关时必开启 |
| season | logical | false | true/false | 高 — 季节数据必须启用 |
| nseasons | integer | 12 | 2~52 | 中 — 月度=12, 季度=4, 周=52 |

- 时间复杂度: $O(n^2)$ (原始成对枚举), 可优化至 $O(n\log n)$ (归并排序计逆序数)
- 空间复杂度: $O(n)$ (仅存储 S), $O(n^2)$ (若存储所有 Sen 斜率对)
- 输入量纲: 任意; S 无量纲; Sen 斜率量纲 = [原量纲/时间步长]

## MATLAB 实现

```matlab
function [z, p, sen_slope, S] = mann_kendall(x, varargin)
% MANN_KENDALL  Mann-Kendall趋势检验 + Sen斜率估计
%   自写-见S5:mann_kendall.m
%   x: 一维时间序列 (列向量)
%   可选参数: 'alpha', 0.05, 'tail', 'both', 'prewhiten', false
%   输出: z (标准化统计量), p (p值), sen_slope, S (原始统计量)
%
%   Reference: Mann(1945) + Kendall(1975)
%   ID: PARADIGM-0522

    p_ = inputParser;
    addRequired(p_, 'x', @(v) isnumeric(v) && isvector(v));
    addParameter(p_, 'alpha', 0.05, @(v) v>0 && v<1);
    addParameter(p_, 'tail', 'both');
    addParameter(p_, 'prewhiten', false, @islogical);
    parse(p_, x, varargin{:});
    
    x = x(:);  % 转为列向量
    n = length(x);
    
    if n < 10
        warning('n=%d<10, 正态近似不可靠, 建议使用精确检验', n);
    end
    
    % 可选预白化
    if p_.Results.prewhiten
        rho = corr(x(1:end-1), x(2:end));
        if abs(rho) > 0.1
            x(2:end) = x(2:end) - rho * x(1:end-1);
        end
    end
    
    % 计算 S 统计量
    S_val = 0;
    for i = 1:n-1
        for j = i+1:n
            S_val = S_val + sign(x(j) - x(i));
        end
    end
    
    % 方差 (考虑结)
    [~, ~, ties] = unique(x);
    tie_counts = histcounts(ties, 1:max(ties)+1);
    tie_correction = sum(tie_counts(tie_counts > 1) .* ...
        (tie_counts(tie_counts > 1) - 1) .* ...
        (2 * tie_counts(tie_counts > 1) + 5));
    
    VarS = (n*(n-1)*(2*n+5) - tie_correction) / 18;
    
    % 标准化 Z
    if S_val > 0
        z = (S_val - 1) / sqrt(VarS);
    elseif S_val < 0
        z = (S_val + 1) / sqrt(VarS);
    else
        z = 0;
    end
    
    % p 值
    switch p_.Results.tail
        case 'both'
            p = 2 * (1 - normcdf(abs(z)));
        case 'right'
            p = 1 - normcdf(z);
        case 'left'
            p = normcdf(z);
    end
    
    % Sen 斜率
    slopes = [];
    for i = 1:n-1
        for j = i+1:n
            slopes(end+1) = (x(j) - x(i)) / (j - i);
        end
    end
    sen_slope = median(slopes);
    
    % 输出
    fprintf('\n===== Mann-Kendall 趋势检验 =====\n');
    fprintf('n = %d, S = %.2f, Var(S) = %.2f\n', n, S_val, VarS);
    fprintf('Z = %.4f, p = %.6f, Sen slope = %.6f\n', z, p, sen_slope);
    if p < p_.Results.alpha
        dir_str = iif(sen_slope > 0, '显著上升', '显著下降');
        fprintf('结论: α=%.2f 下%s趋势\n', p_.Results.alpha, dir_str);
    else
        fprintf('结论: α=%.2f 下趋势不显著\n', p_.Results.alpha);
    end
    
    S = S_val;
end
```

## Python 备选

```python
import numpy as np
from scipy import stats
import pymannkendall as mk

# pymannkendall 推荐
result = mk.original_test(x)                # 原始 MK
result = mk.hamed_rao_modification_test(x)  # 方差校正 MK
result = mk.yue_wang_modification_test(x)   # 预白化 MK
result = mk.seasonal_test(x, period=12)     # 季节性 MK

print(f"trend={result.trend}, p={result.p:.4f}, slope={result.slope:.4f}")

# 手工 Sen 斜率 (一行)
sen_slope = np.median([(x[j] - x[i]) / (j - i) 
                        for i in range(len(x)-1) 
                        for j in range(i+1, len(x))])
```

## 选型决策树

```
时间序列 → 趋势检验?
  ├─ 单调趋势 → MK 检验 (非参数, 首选)
  │    ├─ 无自相关 → 原始 MK (original_test)
  │    ├─ 正自相关 → 预白化 MK (yue_wang) 或方差校正 (hamed_rao)
  │    └─ 季节效应 → 季节性 MK (seasonal_test, period=12/4)
  ├─ 非单调趋势 (U/V型) → MK 不适用 → 分段检验或变点检测 (Pettitt)
  └─ 突变检测 → Pettitt 检验 / SNHT
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 原始数据 | 时间序列折线图 + LOESS 平滑 | 叠加局部加权回归平滑曲线, 观察整体趋势走向 |
| 趋势展示 | Sen 斜率直线叠加原始序列 | 在时间序列图上画 Sen 斜率拟合的直线, 展示趋势方向与幅度 |
| 诊断 | ACF 自相关图 | 判断是否需要预白化: 若 lag-1 自相关显著需启用 |
| 诊断 | 逐月/逐季箱线图 | 判断季节性: 若月间中位数差异明显需用季节性 MK |
| 多站点 | 趋势箭头地图 | 多个监测站点的 MK 趋势用向上/向下箭头标在地图上 |
| 结果 | 趋势显著性条形图(多指标) | 各指标 MK Z 值或 p 值并排比较 |

## 常见坑

1. **自相关未处理**: 正自相关的序列 (水利/气象序列极常见), MK 检验的假阳性率远高于名义水平。AR(1) 的 $\rho=0.5$ 时, 名义 5% 检验的实际拒绝率可达 30-50%。必须在检验前检查 ACF, 并启用预白化或方差校正。
2. **季节性未分离**: 月度气温数据包含周期性季节波动 — 若直接对原始月度序列做 MK, 冬季到夏季的系统性上升会使 S 统计量虚高, 得出"显著变暖"但实际无物理含义。需用季节性 MK: 每月分别计算 S 再汇总。
3. **结 (ties) 过多**: 水质浓度数据常有大量在检测限以下的结, 若忽略结校正, Var(S) 偏小, Z 偏大, 假阳性增加。结校正项 $\sum t_k(t_k-1)(2t_k+5)$ 必须正确计入。
4. **非单调趋势的误判**: 序列先升后降的倒 U 形 — MK 的成对符号在前半段产生正号, 后半段产生负号, 符号相消导致 $S \approx 0$, 结论为"无趋势"。这技术上正确 (无整体单调趋势), 但掩盖了实质性变化。应先做 LOESS 可视化, 识别转折点再分段检验。
5. **小样本的正态近似失效**: n < 10 时, S 的精确分布与正态近似差异显著, Z 检验的 p 值不可靠, 需查 MK 精确分布表或使用 bootstrap。

## 失效条件/反例 (强制小节)

- **条件1 — 强自相关 (AR(1) $\rho > 0.3$) → Var(S) 低估, 假阳性率飙升, 需预白化或方差校正**: MK 检验假设观测值独立。当序列存在正自相关时, 有效样本量远小于 n, $\operatorname{Var}(S)$ 被系统性低估, Z 虚高。仿真显示 AR(1) $\rho=0.4$ 时名义 5% 水平的 MK 检验实际拒绝率可达 25% 以上。解决方案: (1) 预白化 (Yue & Wang, 2004): 去除 AR(1) 成分后再检验; (2) 方差校正 (Hamed & Rao, 1998): 用自相关直接修正 $\operatorname{Var}(S)$, 其中有效样本量 $n^* = n \cdot \left(1 + 2\sum_{k=1}^{n-1}(1-k/n)\rho_k\right)^{-1}$。
- **条件2 — 非单调趋势 (U 型 / V 型) → MK 只能检测单调, 转折点前后符号相消 → 不显著**: MK 的 S 统计量是所有成对符号之和。若序列先单调上升后单调下降, 前半段正号与后半段负号相消, $S \approx 0$, 检验得出"无整体单调趋势"——技术上正确但掩盖了重要机制。识别方法: 做局部加权回归 (LOESS) 可视化, 或使用 Pettitt 检验找转折点, 再对分段分别做 MK。
- **条件3 — 季节效应未处理 → 需季节性 MK, 直接做年度均值损失信息**: 若数据有 12 个月乘 30 年 = 360 个点, 直接做 MK 则季节变化主导 S。压缩为 30 个年度均值则 n 过小且丢失季节内趋势差异 (如冬季变暖趋势强于夏季)。季节性 MK (Hirsch et al., 1982) 是标准方法: 每月独立计算 $S_k$, 汇总 $S_{\text{total}} = \sum S_k$, $\operatorname{Var}(S_{\text{total}}) = \sum \operatorname{Var}(S_k)$.

## 文献

1. Mann, H. B. (1945). Nonparametric Tests Against Trend. *Econometrica*, 13(3), 245-259.
2. Kendall, M. G. (1975). *Rank Correlation Methods* (4th ed.). Charles Griffin.
3. Sen, P. K. (1968). Estimates of the Regression Coefficient Based on Kendall's Tau. *Journal of the American Statistical Association*, 63(324), 1379-1389.
4. Hirsch, R. M., Slack, J. R., & Smith, R. A. (1982). Techniques of Trend Analysis for Monthly Water Quality Data. *Water Resources Research*, 18(1), 107-121. (季节性 MK 原始论文)
5. Hamed, K. H., & Rao, A. R. (1998). A Modified Mann-Kendall Trend Test for Autocorrelated Data. *Journal of Hydrology*, 204(1-4), 182-196.
6. Yue, S., & Wang, C. Y. (2004). The Mann-Kendall Test Modified by Effective Sample Size to Detect Trend in Serially Correlated Hydrological Series. *Water Resources Management*, 18(3), 201-218.

## 来源溯源

- 原始来源: Mann (1945) 在计量经济学中提出基于 Kendall's $\tau$ 的非参数趋势检验; Kendall (1975) 收录为标准方法
- 水文气象应用: Hirsch et al. (1982) 将该方法引入水质趋势分析, 引入季节性扩展, 成为 USGS 标准方法
- MATLAB 实现: 自写 `mann_kendall.m`, 基于符号运算, 无需特殊工具箱; Statistics Toolbox 不包含原生 MK 函数
- Sen 斜率由 Sen (1968) 提出, 是对所有成对斜率取中位数, 崩溃点高达 29.3%, 远优于 OLS

## 关联范式卡

| 关系 | ID |
|------|-----|
| 后置 — Hurst 指数 (长记忆分析验证趋势持续性) | PARADIGM-0523 |
| 前置 — 数据预处理 (异常值处理, 缺失插值) | PARADIGM-0501 / PARADIGM-0502 |
| 互补 — 时间序列建模 (ARIMA/GARCH) | PARADIGM-0202 |
| 互补 — 变点检测 (Pettitt/SNHT) | PARADIGM-0526 |
| 关联 — 相关性分析 (Spearman/Kendall $\tau$) | PARADIGM-0510 |
