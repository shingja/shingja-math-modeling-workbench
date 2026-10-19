# PARADIGM-0306 秩和比法 (Rank Sum Ratio)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0306 |
| 类别/子类 | ③评价 / 非参数排序 |
| 难度 | 低 |
| 适用题型关键词[] | 秩和比, RSR, 非参数, 编秩, 分档, 排序分档, 秩次, Probit, 非参数统计, 综合排序, 分档评价, rank sum ratio |
| confidence | medium |
| source | 田凤调 (1995) 秩和比法及其应用. 中国卫生统计, 12(1). |

## 数学形式

### 1. 编秩

设有 m 个评价对象, n 个评价指标, 原始矩阵 $X = (x_{ij})_{m \times n}$.

**高优指标** (越大越好): 按升序编秩 $R_{ij} = 1, 2, \ldots, m$ (最小值秩=1, 最大值秩=m)

**低优指标** (越小越好): 按降序编秩 $R_{ij} = 1, 2, \ldots, m$ (最大值秩=1, 最小值秩=m)

**均数秩** (处理并列值): 相同值取平均秩. 如第2/3名并列 → 均赋秩 2.5.

### 2. 计算秩和比 (RSR)

$$RSR_i = \frac{\sum_{j=1}^n R_{ij}}{m \cdot n}$$

对于加权 RSR:

$$WRSR_i = \frac{\sum_{j=1}^n w_j \cdot R_{ij}}{m}$$

其中 $w_j$ 为指标权重, $\sum w_j = 1$.

### 3. 确定 RSR 分布

将 RSR 值从小到大排序, 计算:
- 频数 $f$
- 累积频数 $\sum f$
- 平均秩次 $\bar{R}$
- 累积频率 $p = \frac{\bar{R}}{m} \times 100\%$

### 4. Probit 变换

根据累积频率 p 查标准正态离差表得到 Probit (概率单位):

$$Probit = u_p + 5$$

其中 $u_p$ 为标准正态分布的百分位数. 可按 $\text{Probit} = \text{norminv}(p) + 5$ 计算.

### 5. 回归分档与排序

建立回归方程: $RSR = a + b \times Probit$, 据此将 RSR 分为 3 档 (差/中/好), 5 档或 7 档.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 评价对象数 m | int | — | ≥5 (推荐≥10) | 高 — m 小则排序随机性大 |
| 指标数 n | int | — | ≥3 (推荐≥5) | 高 — n 小则秩和信息量不足 |
| 编秩方向 dirs | vector (n) | 全高优 | {"high", "low"} | 高 — 方向错误导致排序颠倒 |
| 权重向量 w | vector (n) | 等权 | Σw_j=1 | 中 — 权重影响加权 RSR |
| 分档数 | int | 3 或 5 | {3, 5, 7} | 中 — 分档太细则边界模糊 |
| Probit 变换 | — | norminv 查表 | p∈(0,1) | 低 — 标准变换 |

**复杂度**: 空间 O(mn), 时间 O(mn + m log m) — 排序主导, 极快.

## MATLAB 实现

```matlab
% ===== PARADIGM-0306-RSR: 自写-见S5:rsr_eval.m =====
function [RSR, WRSR, ranking, classification] = rsr_eval(X, dirs, w, n_class)
    % X: m×n 原始数据矩阵
    % dirs: 1×n, 'h'=high (高优/越大越好), 'l'=low (低优/越小越好)
    % w: 1×n 权重向量 (默认等权)
    % n_class: 分档数 {3, 5, 7} (默认 3)
    % RSR: m×1 秩和比
    % WRSR: m×1 加权秩和比
    % ranking: m×1 排序索引 (1最优)
    % classification: m×1 分档标签

    [m, n] = size(X);

    if nargin < 2 || isempty(dirs), dirs = repmat('h', 1, n); end
    if nargin < 3 || isempty(w), w = ones(1, n) / n; end
    if nargin < 4 || isempty(n_class), n_class = 3; end

    % --- Step 1: 编秩 ---
    R = zeros(m, n);
    for j = 1:n
        [~, order] = sort(X(:, j));  % 升序索引
        if dirs(j) == 'h' || dirs(j) == 'H'
            % 高优: 最小值得秩1, 最大值得秩m
            [~, rank_j] = sort(order);
        else
            % 低优: 最大值得秩1, 最小值得秩m
            [~, rank_j] = sort(order, 'descend');
        end
        % 处理并列 (tied rank): 取平均秩
        [~, ~, ic] = unique(X(:, j));
        for u = 1:max(ic)
            idx = find(ic == u);
            if length(idx) > 1
                rank_j(idx) = mean(rank_j(idx));
            end
        end
        R(:, j) = rank_j;
    end

    % --- Step 2: 计算秩和比 ---
    RSR = sum(R, 2) / (m * n);
    WRSR = (R * w(:)) / m;  % 加权: 等价公式

    % --- Step 3: 排序 ---
    [~, ranking] = sort(RSR, 'descend');

    % --- Step 4: 确定 RSR 分布 ---
    [sorted_RSR, idx_rsr] = sort(RSR);
    freq = ones(m, 1);             % 频数 (简单情形)
    cum_freq = cumsum(freq);
    avg_rank = (cum_freq + (cum_freq - freq + 1)) / 2;  % 平均秩次
    p = avg_rank / m;              % 累积频率
    p(end) = 1 - 1/(4*m);         % 修正最后一个

    % --- Step 5: Probit 变换 ---
    u = norminv(p);
    Probit = u + 5;

    % --- Step 6: 回归分档 ---
    % RSR = a + b * Probit
    b_hat = (sorted_RSR' * Probit - m * mean(sorted_RSR) * mean(Probit)) / ...
            (Probit' * Probit - m * mean(Probit)^2);
    a_hat = mean(sorted_RSR) - b_hat * mean(Probit);

    % 按 Probit 值分段 (等间距)
    prob_min = min(Probit); prob_max = max(Probit);
    edges = linspace(prob_min, prob_max, n_class + 1);
    edges(1) = -inf; edges(end) = inf;

    classification = zeros(m, 1);
    [~, rank_order] = sort(ranking);
    sorted_rsr_full = RSR;
    for i = 1:m
        prob_i = norminv((rank_order(i)) / m) + 5;
        for c = 1:n_class
            if prob_i >= edges(c) && prob_i < edges(c+1)
                classification(i) = c;
                break;
            end
        end
    end

    % 输出
    class_labels = {'差', '中', '好';
                    '差', '中下', '中', '中上', '好';
                    '极差', '差', '中下', '中', '中上', '好', '极好'};
    fprintf('=== RSR 评价结果 ===\n');
    for i = 1:m
        fprintf('方案 %d: RSR=%.4f | 排名=%.0f | 档次=%s\n', ...
            i, RSR(i), find(ranking==i), ...
            class_labels{n_class==[3,5,7], classification(i)});
    end
end
```

## Python 备选

```python
import numpy as np
from scipy.stats import norm  # norm.ppf 用于 Probit 变换

def rsr_eval(X: np.ndarray, dirs: np.ndarray = None,
             w: np.ndarray = None, n_class: int = 3) -> dict:
    """秩和比法 (需 scipy 做 Probit 变换)"""
    m, n = X.shape

    if dirs is None:
        dirs = np.full(n, 'h')
    if w is None:
        w = np.ones(n) / n

    # 编秩
    R = np.zeros((m, n))
    for j in range(n):
        order = np.argsort(X[:, j])
        if dirs[j] == 'h':
            rank_j = np.argsort(order) + 1
        else:
            rank_j = np.argsort(order)[::-1] + 1
        R[:, j] = rank_j.astype(float)

    # 秩和比
    RSR = R.sum(axis=1) / (m * n)
    WRSR = (R @ w) / m

    ranking = np.argsort(np.argsort(-RSR)) + 1

    # Probit 分布与分档
    sorted_idx = np.argsort(RSR)
    p = (np.arange(1, m + 1)) / m
    p[-1] = 1 - 1/(4*m)

    Probit = norm.ppf(p) + 5

    # 简单分档 (等间距 Probit)
    edges = np.linspace(Probit.min(), Probit.max(), n_class + 1)
    edges[0], edges[-1] = -np.inf, np.inf

    classification = np.zeros(m, dtype=int)
    for i, pi in enumerate(Probit):
        for c in range(n_class):
            if edges[c] <= pi < edges[c+1]:
                classification[sorted_idx[i]] = c + 1
                break

    return {'RSR': RSR, 'WRSR': WRSR, 'ranking': ranking,
            'classification': classification}
```

## 选型决策树

```
需要综合多指标对方案排序/分档, 数据分布未知
│
├─ 需要非参数排序 (不假设分布) → RSR ✓ (本范式)
│   ├─ 仅需排序 → 直接用 RSR 值排序
│   ├─ 需要分档 → RSR + Probit 分档 (3/5/7 档)
│   └─ 指标量级差异大但不想归一化 → RSR 天然免疫量纲 (秩变换)
│
├─ 需要精确距离度量 → TOPSIS (PARADIGM-0302)
├─ 数据分布正态 → 标准化+加权求和即可, 无需秩变换
├─ 模糊定性评价 → 模糊综合评价 (PARADIGM-0304)
└─ 有参考序列 → 灰色关联分析 (PARADIGM-0305)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| RSR 排序 | 横向条形图 — 方案 RSR 值降序 (带排名) | 可叠加分档颜色 (红/黄/绿) |
| 正态性检验 | Q-Q 图 — Probit vs RSR | 判断回归线性假设是否满足 |
| 分档展示 | 箱线图 — 各档次 RSR 分布 | 验证分档区分度 |
| 权重灵敏度 | tornado 图 — 各指标权重 ±20% 对 RSR 排名影响 | 识别关键指标 |

## 常见坑

1. **编秩丢失量级信息**: 原始值 [100, 99, 2, 1] 编秩后变为 [4, 3, 2, 1], 100 与 99 的量级差异 (仅 1%) 与 99 与 2 的量级差异 (约 50 倍) 在秩中均为"差 1 位". 当量级差异本身具有评价意义时, RSR 不适合.
2. **Probit 正态假定**: RSR 分档依赖"RSR 服从正态分布"的假设, 否则 Probit 变换无效. 需要对 RSR 做正态性检验 (Shapiro-Wilk 或 Q-Q 图). 非正态时不宜分档, 仅用排序.
3. **分档边界的主观性**: 3 档 (差/中/好) 的分界点由 Probit 等间距或等频数决定, 两种方式可能给出不同的分档归属. 论文中需说明分档方法并做稳健性分析.
4. **权重赋予时机**: 加权应在编秩之前还是编秩之后存在争议. 田凤调原文的加权公式为 WRSR = (1/m·n) Σ w_j·R_ij, 即对秩加权. 此做法将权重视为"秩的重要性乘数", 而非"原值的重要性乘数".
5. **并列值的处理不一致**: 多个方案在同一指标并列时, 应使用平均秩. 若忽略并列处理 (直接用排序序号), 会人为制造虚假差异.

## 失效条件/反例 (强制小节)

- **条件1 — 指标数 m < 3**: 秩和比的信息熵由指标数和样本数共同决定. 当仅 1-2 个指标时, RSR_i 完全由这 1-2 个秩决定, 排序等同于单指标排序 (两个指标时退化为秩和排序), RSR 方法本身失去"综合多指标"的意义. 案例: 仅用"GDP"和"人均收入"两个指标评价城市, RSR 排序与直接按秩和排序恒等, 方法冗余.
- **条件2 — 连续变量编秩导致关键差异被抹平**: 原始指标变异系数 (CV) 高达 200%, 但编秩后所有指标的秩分布完全相同 (1~m 均匀分布). 若 90% 的指标差异实际由 1-2 个指标驱动 (如 GDP 贡献 80% 的方差), 但 RSR 为所有指标赋等秩权, 将严重低估高方差指标的重要性. 此时应先用变异系数法 (PARADIGM-0307) 或熵权法 (PARADIGM-0303) 计算权重, 再用加权 RSR.
- **条件3 — Probit 分档的非正态失败**: 当 RSR 分布严重偏态 (如大部分方案集中在极小区间, 少数方案离群), Probit 变换的线性假设失败 — Q-Q 图呈 S 型弯曲. 此时 3 档分界点无统计依据, 强行分档会把约 80% 的方案划入同一档, 分档功能形同虚设. 应放弃分档, 仅报告排序.

## 文献

1. 田凤调. (1995). 秩和比法及其应用. 中国卫生统计, 12(1), 7-10.
2. 田凤调. (2003). 秩和比法的应用水平有待提高. 中国卫生统计, 20(1), 51-52.
3. 王艳, 薛文通. (2008). 秩和比法在食品感官评价中的应用. 食品科学, 29(9), 92-95.
4. Cheng, W., et al. (2010). Rank sum ratio method for comprehensive evaluation. *Chinese Journal of Health Statistics*, 27(3), 268-270.
5. Conover, W. J. (1999). *Practical Nonparametric Statistics* (3rd ed.). Wiley.

## 来源溯源

秩和比法 (RSR) 由中国卫生统计学奠基人之一田凤调教授于 1988 年提出, 1995 年系统总结于《中国卫生统计》. 该方法根植于非参数统计的思想 — 用秩 (rank) 替代原始数值进行分析, 免除对数据分布的假定. 田凤调将其与 Probit 概率单位法结合, 创建了"编秩-算RSR-排序-分档"的完整评价流程. RSR 在中国卫生统计领域获得广泛认可 (医院绩效评价、公共卫生评估), 并逐步推广至教育评价、管理科学等领域. 其优势在于完全非参数 (无分布假设)、免疫量纲、计算极为简单, 适合基层单位使用.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 同级对比 — 距离型评价 | PARADIGM-0302 (TOPSIS) |
| 同级对比 — 灰色评价 | PARADIGM-0305 (灰色关联分析) |
| 上游 — 客观赋权 (加权 RSR) | PARADIGM-0303 (熵权法) |
| 上游 — 客观赋权 (加权 RSR) | PARADIGM-0307 (变异系数法) |
| 上游 — 主观赋权 (加权 RSR) | PARADIGM-0301 (AHP) |
| 非参数基础理论 | Spearman 秩相关, Kruskal-Wallis 检验 |
