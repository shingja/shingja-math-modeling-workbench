# PARADIGM-0523  R/S Hurst 指数分析⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0523 |
| 类别/子类 | ⑤统计 / 长记忆分析 |
| 难度 | 中 |
| 适用题型关键词[] | Hurst指数, R/S分析, 重标极差, 长记忆, 分形, 自相似, 持续性, 反持续性, 水文分析, 金融市场, 时间序列记忆 |
| confidence | medium |
| source | Hurst, H.E. (1951) Long-term storage capacity of reservoirs, *Transactions of the American Society of Civil Engineers*, 116(1), 770-799; Mandelbrot, B.B. & Wallis, J.R. (1969) *Water Resources Research*, 5(5), 967-988 |

## 数学形式

**R/S 分析 (重标极差分析) 估计 Hurst 指数 $H \in (0, 1)$**:

1. 将时间序列 $\{x_1, \ldots, x_N\}$ 划分为 $\lfloor N/n \rfloor$ 个长度为 $n$ 的不重叠子区间
2. 对每个子区间 $m$:
   - 均值: $\bar{x}_m = \frac{1}{n}\sum_{i=1}^{n} x_i^{(m)}$
   - 累计离差: $Y_k = \sum_{i=1}^{k} (x_i^{(m)} - \bar{x}_m), \quad k = 1, 2, \ldots, n$
   - 极差: $R_m = \max_{1 \leq k \leq n} Y_k - \min_{1 \leq k \leq n} Y_k$
   - 标准差: $S_m = \sqrt{\frac{1}{n}\sum_{i=1}^{n} (x_i^{(m)} - \bar{x}_m)^2}$
   - 重标极差: $(R/S)_m = R_m / S_m$
3. 对 $n$ 取平均: $(R/S)_n = \frac{1}{\lfloor N/n \rfloor} \sum_{m=1}^{\lfloor N/n \rfloor} (R/S)_m$
4. **对数回归**: $\log(R/S)_n = H \cdot \log(n) + \text{const}$

**Hurst 指数物理解释**:
- $H = 0.5$: 随机游走 (白噪声) — 无记忆性, 过去不影响未来
- $0.5 < H < 1$: 持久性 (正相关性, 趋势延续) — 长记忆过程, 上升趋势后继上升
- $0 < H < 0.5$: 反持久性 (均值回复) — 反记忆, 上升后必下降, 波动剧烈但均值稳定

**Hurst 指数与分形维数关系**:
$$D = 2 - H$$
其中 $D$ 为分形维数。$H=0.5$ 时 $D=1.5$ (布朗运动); $H \rightarrow 1$ 则 $D \rightarrow 1$ (光滑趋势线)。

**方差比检验 (Lo-MacKinlay) 补充**:
$$VR(k) = \frac{\operatorname{Var}(x_t + \cdots + x_{t-k+1})}{k \cdot \operatorname{Var}(x_t)}$$

在随机游走假设下 $VR(k) = 1$; $VR(k) > 1$ 暗示正自相关 (与 $H > 0.5$ 对应)。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| n_min (最小子区间) | integer | 10 | 8~50 | 中 — 太小则 $R/S$ 波动大 |
| n_max (最大子区间) | integer | N/2 | N/3~N/2 | 中 — 需保证子区间数 >= 5 |
| n_vals (取值策略) | string | 'log-equal' | log-equal/custom | 低 — 决定回归点分布 |
| detrend | logical | false | true/false | 高 — 线性趋势使 H 高估 |

- 时间复杂度: $O(N \log N)$ (因多尺度重复计算各子区间)
- 空间复杂度: $O(N)$
- 输入: 一维等间隔时间序列; 输出 H (无量纲, 0~1), 回归 $R^2$

## MATLAB 实现

```matlab
function [H, R2, CI] = hurst_rs(x, varargin)
% HURST_RS  R/S分析估计Hurst指数
%   自写-见S5:hurst_rs.m
%   x: 一维时间序列 (列向量)
%   可选: 'n_min', 10, 'n_max', floor(N/2), 'detrend', false
%   输出: H, R2 (对数回归拟合优度), CI (H的95%置信区间)
%
%   Reference: Hurst(1951) + Mandelbrot(1969)
%   ID: PARADIGM-0523

    p = inputParser;
    addRequired(p, 'x', @(v) isnumeric(v) && isvector(v));
    addParameter(p, 'n_min', 10, @(v) v>=8);
    addParameter(p, 'n_max', [], @(v) isempty(v) || v>0);
    addParameter(p, 'detrend', false, @islogical);
    parse(p, x, varargin{:});
    
    x = x(:);
    N = length(x);
    
    if N < 50
        warning('N=%d<50, Hurst估计不可靠, 建议使用DFA', N);
    end
    
    % 可选去趋势
    if p.Results.detrend
        x = detrend(x);
    end
    
    % 生成对数等距的 n 序列
    n_max = p.Results.n_max;
    if isempty(n_max), n_max = floor(N/2); end
    n_min = p.Results.n_min;
    
    n_vals = unique(floor(logspace(log10(n_min), log10(n_max), 20)));
    n_vals = n_vals(n_vals >= n_min & n_vals <= n_max);
    
    RS = zeros(size(n_vals));
    
    for idx = 1:length(n_vals)
        n = n_vals(idx);
        m = floor(N / n);
        if m < 3, continue; end
        
        rs = zeros(m, 1);
        for k = 1:m
            seg = x((k-1)*n + 1 : k*n);
            seg_mean = mean(seg);
            Y = cumsum(seg - seg_mean);
            R = max(Y) - min(Y);
            S = std(seg);
            if S > 0
                rs(k) = R / S;
            end
        end
        RS(idx) = mean(rs(rs > 0));
    end
    
    % 去除无效点
    valid = RS > 0;
    log_n = log(n_vals(valid));
    log_RS = log(RS(valid));
    
    % 对数-对数回归
    X_reg = [ones(length(log_n), 1), log_n];
    b = X_reg \ log_RS;
    H = b(2);
    
    % 拟合优度 R²
    y_pred = X_reg * b;
    SS_res = sum((log_RS - y_pred).^2);
    SS_tot = sum((log_RS - mean(log_RS)).^2);
    R2 = 1 - SS_res / SS_tot;
    
    % H 的 95% 置信区间
    residuals = log_RS - y_pred;
    se_H = sqrt(sum(residuals.^2) / (length(log_n) - 2) / ...
                sum((log_n - mean(log_n)).^2));
    CI = [H - 1.96*se_H, H + 1.96*se_H];
    
    % 输出
    fprintf('\n===== R/S Hurst 指数分析 =====\n');
    fprintf('Hurst指数 H = %.4f  (95%% CI: [%.4f, %.4f])\n', H, CI(1), CI(2));
    fprintf('对数回归 R² = %.4f\n', R2);
    if H > 0.55
        fprintf('结论: 序列具有持久性 (长记忆, 趋势延续)\n');
    elseif H < 0.45
        fprintf('结论: 序列具有反持久性 (均值回复)\n');
    else
        fprintf('结论: 序列接近随机游走 (无长记忆)\n');
    end
end
```

## Python 备选

```python
import numpy as np

def hurst_rs(x):
    """R/S分析估计Hurst指数"""
    N = len(x)
    n_vals = np.unique(np.logspace(
        np.log10(10), np.log10(N//2), 20, dtype=int))
    RS = []
    for n in n_vals:
        m = N // n
        rs = []
        for k in range(m):
            seg = x[k*n:(k+1)*n]
            Y = np.cumsum(seg - np.mean(seg))
            R = np.max(Y) - np.min(Y)
            S = np.std(seg, ddof=1)
            if S > 0:
                rs.append(R / S)
        if rs:
            RS.append(np.mean(rs))
    
    # 对数回归
    valid = np.array(RS) > 0
    H = np.polyfit(np.log(n_vals[valid]), np.log(np.array(RS)[valid]), 1)[0]
    return H

# 备选库
# from nolds import hurst_rs  # NOLDS包含DFA等多种Hurst估计器
# from hurst import compute_Hc  # hurst包专门做Hurst指数
```

## 选型决策树

```
长记忆性检验?
  ├─ 长序列 N>200, 趋势已移除 → R/S (经典方法)
  ├─ 短序列 N<100 → DFA (去趋势波动分析, 更稳定)
  ├─ 非平稳 + 趋势 → DFA vs R/S (R/S对趋势敏感且高估H)
  │   → 先用DFA-1 (1阶去趋势), 比较R/S与DFA结果
  ├─ 多分形标度 → MF-DFA (多分形去趋势波动分析)
  └─ 仅检验预测可行性 → H > 0.5 意味统计学上可预测
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 原始数据 | 时间序列折线图 | 展示原始序列, 标注均值线 |
| process | $\log(R/S)$ vs $\log(n)$ 散点图 + 回归线 | 核心诊断图; 点沿直线→单分形标度; 斜率=H |
| process | 回归残差图 | 检验对数-对数回归的线性假设; 残差呈U型→标度变化 |
| 多组对比 | H 柱状图 (多序列) | 对比不同序列(如多站点/多股票)的 Hurst 指数 |
| 综合 | H 置信区间 (误差棒) | 各序列 $H \pm 1.96$ SE 的森林图 |

## 常见坑

1. **R/S 对非平稳趋势高度敏感**: 线性趋势使累计偏差 $Y_k$ 单调增长, 极差随 n 的增长速度超过 $\sqrt{n}$, 导致 $H \rightarrow 1$, 大幅高估 — 报告"强长记忆"实为趋势伪影。应先 detrend, 或改用 DFA。
2. **短序列 $R^2$ 差**: $N < 100$ 时 $\log(R/S)$ vs $\log(n)$ 散点图仅覆盖不到一个数量级的 n, 回归基于少于 10 个点, H 的标准误差约 0.2, 分类 H 的可靠性差。此时改用 DFA 或 Higuchi 方法。
3. **周期干扰**: 季节性周期 (如年度) 在 R/S 图中产生阶梯效应, 干扰对数线性关系, 产生长记忆伪影。应先做季节调整 (如 X-13-ARIMA 或简单去周期)。
4. **复合过程 (长记忆 + 短记忆)**: R/S 无法分离 AR 短记忆和分形长记忆。一个 AR(1) 短记忆过程可能产生 $H > 0.5$ 的估计, 但这是伪长记忆。需同时报告 AR 模型的残差检验, 或使用 ARFIMA 参数模型直接估计记忆参数 $d = H - 0.5$。
5. **子区间起始点偏倚**: 非重叠划分法对序列起始点敏感。改进: 使用滑动窗口或随机起始点多轮平均。

## 失效条件/反例 (强制小节)

- **条件1 — 序列过短 (n < 100) → log-log 回归点不足, H 估计误差大, 置信区间宽**: R/S 分析需要在至少一个数量级的 n 范围内做对数回归。当 $N < 100$ 时, $n$ 的范围仅从 10 到约 50, 对数轴覆盖不到 2 倍, 回归仅基于约 8-10 个点。此时 H 的标准误差约为 $1/\sqrt{k}$ (k 为回归点), 导致 95% CI 跨度可能超过 0.3, 无法可靠分类为"持久""随机"或"反持久"。替代方案: (1) DFA (去趋势波动分析, 对小样本更鲁棒); (2) Higuchi 分形维数估计器; (3) 若必须用 R/S, 必须报告 CI 且不做过强结论。
- **条件2 — 存在短期自相关 → H 估计偏大 (伪长记忆), 需先消除短期依赖**: R/S 分析无法区分 AR 短记忆和真正的分形长记忆。一个 AR(1) 过程 ($\phi=0.7$) 可能产生 $H \approx 0.65$ 的估计, 但这是伪长记忆 — 该过程的记忆在几何速度衰减。正确的诊断流程: (1) 先拟合 AR(p) 模型; (2) 对残差做 R/S, 若残差 H 仍远离 0.5 才是真正的长记忆; (3) 或直接用 ARFIMA(p,d,q) 模型估计长记忆参数 d。
- **条件3 — 非平稳序列 → R/S 统计量发散, 回归失效, H 无定义**: R/S 分析假设序列为平稳过程。对于带漂移的单位根过程 (随机游走), R/S 统计量随 n 的增长速度为 $O(\sqrt{n})$, 对数回归斜率趋于约 0.5 — 但这不表示"无记忆", 而是单位根主导了标度行为。对于含确定性趋势的非平稳序列, H 趋向 1 — 同样无物理含义。正确做法: 先做 ADF 检验 (adftest) 确认平稳性; 若非平稳, 差分后再做 R/S 或直接使用 DFA。

## 文献

1. Hurst, H. E. (1951). Long-term storage capacity of reservoirs. *Transactions of the American Society of Civil Engineers*, 116(1), 770-799.
2. Mandelbrot, B. B., & Wallis, J. R. (1969). Robustness of the rescaled range R/S in the measurement of noncyclic long run statistical dependence. *Water Resources Research*, 5(5), 967-988.
3. Mandelbrot, B. B. (1972). Statistical methodology for nonperiodic cycles: from the covariance to R/S analysis. *Annals of Economic and Social Measurement*, 1(3), 259-290.
4. Peng, C. K., et al. (1994). Mosaic organization of DNA nucleotides. *Physical Review E*, 49(2), 1685. (DFA 原始论文, 作为 R/S 的替代方法)
5. Lo, A. W. (1991). Long-term memory in stock market prices. *Econometrica*, 59(5), 1279-1313. (修正 R/S 处理短记忆)

## 来源溯源

- 原始来源: Hurst (1951) 在研究尼罗河水库最优蓄水量时发现 R/S 幂律标度, 提出 Hurst 现象
- Mandelbrot (1969, 1972) 将 R/S 推广为分形和长记忆分析的一般工具, 引入"Joseph 效应"(七年丰七年歉)
- MATLAB 实现: 自写 `hurst_rs.m`, 无需额外工具箱; 核心为累积累差 + 对数回归
- 水文界的传统工具; 1990年代后推广到金融 (分形市场假说), 环境科学, 地球物理

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 — Mann-Kendall 趋势检验 (先检测趋势, 再分析长记忆) | PARADIGM-0522 |
| 前置 — 平稳性检验 (ADF test) | PARADIGM-0202 (ARIMA) |
| 互补 — 去趋势波动分析 (DFA, 替代 R/S) | 见DFA文献 |
| 互补 — ARFIMA 模型 (参数化长记忆模型) | PARADIGM-0202 (ARIMA扩展) |
| 后置 — 时间序列预测 (H > 0.5 暗示可预测性) | PARADIGM-0202 / PARADIGM-0204 |
