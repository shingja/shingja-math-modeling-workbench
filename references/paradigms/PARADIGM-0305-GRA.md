# PARADIGM-0305 灰色关联分析 (Grey Relational Analysis)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0305 |
| 类别/子类 | ③评价 / 灰色系统 |
| 难度 | 低 |
| 适用题型关键词[] | 灰色关联分析, GRA, 邓氏关联度, 灰色系统, 参考序列, 分辨系数, 关联度, 灰色关联, 无量纲化, 初值化, 比较序列, grey relational |
| confidence | high |
| source | 邓聚龙 (1990) 灰色系统理论教程. 华中理工大学出版社. |

## 数学形式

### 1. 确定参考序列和比较序列

- 参考序列 (理想/标准序列): $X_0 = \{x_0(1), x_0(2), \ldots, x_0(n)\}$
- 比较序列 (待评价对象): $X_i = \{x_i(1), x_i(2), \ldots, x_i(n)\}, \quad i = 1, 2, \ldots, m$

### 2. 无量纲化处理

**初值化** (除以序列第一个值):
$$x_i'(k) = \frac{x_i(k)}{x_i(1)}$$

**均值化** (除以序列均值):
$$x_i'(k) = \frac{x_i(k)}{\frac{1}{n}\sum_{k=1}^n x_i(k)}$$

**区间化** (min-max):
$$x_i'(k) = \frac{x_i(k) - \min x_i}{\max x_i - \min x_i}$$

选择原则: 初值化适用于增长趋势分析, 均值化适用于截面比较, 区间化适用于量纲差异大的情形.

### 3. 计算灰色关联系数

$$\xi_i(k) = \frac{\min_i \min_k \Delta_i(k) + \rho \cdot \max_i \max_k \Delta_i(k)}{\Delta_i(k) + \rho \cdot \max_i \max_k \Delta_i(k)}$$

其中:
- 绝对差序列: $\Delta_i(k) = |x_0'(k) - x_i'(k)|$
- $\rho \in (0, 1)$ 为分辨系数, 通常取 $\rho = 0.5$

### 4. 计算灰色关联度

$$r_i = \frac{1}{n} \sum_{k=1}^n \xi_i(k)$$

$r_i$ 越大, 比较序列 $X_i$ 与参考序列 $X_0$ 的几何形状越接近.

### 5. 关联度排序

按 $r_i$ 降序排列, 关联度最大者为最优方案.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 参考序列 X0 | vector (1×n) | max/min 各指标 | — | 极高 — 参考序列决定关联方向 |
| 比较序列 Xi | matrix (m×n) | — | 实数 | 极高 — 数据质量核心 |
| 无量纲化方法 | string | "mean" | {"init", "mean", "range"} | 高 — 不同方法关联序可能不同 |
| 分辨系数 ρ | float | 0.5 | (0, 1) | 中 — ρ→1 时关联度普遍接近1, ρ→0 时仅由最小差决定 |
| 样本数 n | int | — | ≥4 (灰色系统最少数据) | 高 — n<4 无统计意义 |

**复杂度**: 空间 O(mn), 时间 O(mn) — 全为逐元素计算, 极为高效.

## MATLAB 实现

```matlab
% ===== PARADIGM-0305-GRA: 自写-见S5:grey_relational.m =====
function [r, xi] = grey_relational(X, X0, rho, norm_method)
    % X: m×n 比较序列矩阵 (m个方案, n个指标)
    % X0: 1×n 参考序列 (默认: 各指标最优值)
    % rho: 分辨系数 (默认 0.5)
    % norm_method: 无量纲化方法 — 'init'|'mean'|'range' (默认 'mean')
    % r: m×1 灰色关联度
    % xi: m×n 灰色关联系数矩阵

    [m, n] = size(X);

    if nargin < 2 || isempty(X0)
        % 默认参考序列: 效益型取max, 成本型取min (此处简化为全取max)
        X0 = max(X, [], 1);
    end
    if nargin < 3 || isempty(rho)
        rho = 0.5;
    end
    if nargin < 4 || isempty(norm_method)
        norm_method = 'mean';
    end

    % --- Step 1: 合并参考序列与比较序列以便统一无量纲化 ---
    X_all = [X0; X];  % (m+1)×n

    % --- Step 2: 无量纲化 ---
    switch norm_method
        case 'init'   % 初值化
            X_norm = X_all ./ X_all(1, :);
        case 'mean'   % 均值化 (推荐)
            X_norm = X_all ./ mean(X_all, 1);
        case 'range'  % 区间化
            x_min = min(X_all, [], 1);
            x_max = max(X_all, [], 1);
            X_norm = (X_all - x_min) ./ (x_max - x_min);
        otherwise
            X_norm = X_all ./ mean(X_all, 1);
    end

    X0_norm = X_norm(1, :);
    Xi_norm = X_norm(2:end, :);

    % --- Step 3: 计算绝对差序列 ---
    delta = abs(Xi_norm - X0_norm);  % m×n

    % --- Step 4: 计算关联系数 ---
    delta_min = min(delta(:));
    delta_max = max(delta(:));

    xi = (delta_min + rho * delta_max) ./ (delta + rho * delta_max);

    % --- Step 5: 计算关联度 (等权平均) ---
    r = mean(xi, 2);
end
```

## Python 备选

```python
import numpy as np

def grey_relational(X: np.ndarray, X0: np.ndarray = None,
                    rho: float = 0.5,
                    norm_method: str = 'mean') -> tuple:
    """灰色关联分析 (纯 numpy)"""
    m, n = X.shape

    if X0 is None:
        X0 = X.max(axis=0)

    # 合并, 统一无量纲化
    X_all = np.vstack([X0, X])  # (m+1)×n

    if norm_method == 'init':
        X_norm = X_all / X_all[0, :]
    elif norm_method == 'mean':
        X_norm = X_all / X_all.mean(axis=0)
    elif norm_method == 'range':
        x_min = X_all.min(axis=0)
        x_max = X_all.max(axis=0)
        X_norm = (X_all - x_min) / (x_max - x_min + 1e-10)
    else:
        X_norm = X_all / X_all.mean(axis=0)

    X0_norm = X_norm[0, :]
    Xi_norm = X_norm[1:, :]

    # 绝对差序列
    delta = np.abs(Xi_norm - X0_norm)

    delta_min = delta.min()
    delta_max = delta.max()

    xi = (delta_min + rho * delta_max) / (delta + rho * delta_max)

    r = xi.mean(axis=1)
    return r, xi
```

## 选型决策树

```
需要评估方案与理想参考序列的几何相似程度
│
├─ 数据量较少 (4 ≤ n < 20), 分布未知 → GRA ✓ (本范式)
│   ├─ 参考序列易定义 (如各指标最优值) → 邓氏关联度
│   ├─ 需要加权 → 加权灰色关联度 r_i = (1/n)Σ w_k·ξ_i(k)
│   └─ 数据序列趋势更重要 → 斜率灰色关联度 (改进型)
│
├─ 数据量大, 分布已知 → 优先统计方法
│   ├─ 正态 → 欧氏距离 / 马氏距离 / TOPSIS (PARADIGM-0302)
│   └─ 非正态 → 秩和比法 (PARADIGM-0306)
│
├─ 权重已知 + 需要综合排序 → GRA-TOPSIS 结合
│   └─ 灰色-TOPSIS (关联度代替欧氏距离)
│
└─ 主因素分析 (找主要影响因素) → 灰色关联度排序
    └─ 比较各因素与目标变量的关联度, 筛选主要因素
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 序列对比 | 多折线图 — 参考序列 + 入选比较序列 | 直观展示几何相似度 |
| 关联度排序 | 横向条形图 — 各方案 r_i 降序 | 标注关联系数值 |
| 关联系数热力图 | heatmap — 方案×指标 ξ_ij | 颜色映射关联系数 (0~1), 识别弱项指标 |
| 分辨系数灵敏度 | 折线图 — r_i 随 ρ 变化 | ρ∈[0.1, 0.9], 检验排序稳健性 |

## 常见坑

1. **无量纲化方法选择的根本性影响**: 初值化依赖第一个值的选择 (如第一年数据), 若第一年为异常值则整个序列变形. 均值化对序列长度敏感. 区间化受极值影响. 建议同时使用两种方法, 若排序一致则结论稳健.
2. **分辨系数 ρ 的"魔术数字"**: ρ=0.5 是邓聚龙推荐的缺省值, 但无理论证明其最优性. ρ 越趋向于 1, 所有关联度趋近于 1, 丧失区分度; ρ 越趋向于 0, 关联度仅由最小绝对差决定. 必须做 ρ 灵敏度分析.
3. **参考序列定义的主观性**: 若参考序列取为"各指标理论最优值", 则所有方案关联度仅反映与理想的差距, 不反映方案间的相对优劣. 应根据评价目标选择参考序列类型: 理想最优 / 行业平均 / 特定标杆.
4. **灰色"少数据"假设被误用**: GRA 设计用于少数据、贫信息场景 (n≥4). 若数据充足 (n>30), 灰色关联分析与 Pearson 相关系数在排序上可能存在矛盾, 此时应优先选用统计方法.
5. **绝对关联度与相对关联度混淆**: 邓氏关联度为相对量, 仅在给定 m 个方案内可比. 增加或删除一个方案会改变 $\max\Delta$ 和 $\min\Delta$, 从而影响所有方案的关联度绝对值.

## 失效条件/反例 (强制小节)

- **条件1 — 样本量 n < 4**: 灰色系统理论宣称适用于"少数据贫信息"场景, 但其数学基础要求序列至少 4 个数据点. 当 n=2 或 3 时, 关联系数仅由 2-3 个点决定, 无量纲化 (如初值化) 将每个点除以第一点, 导致只有 n-1 个有效差分, 统计意义为零. 案例: 仅有 2 年数据的城市空气质量评价, GRA 的关联度无法反映任何趋势相似性.
- **条件2 — 数据序列方差严重异质**: 序列 A 的波动幅度是序列 B 的 100 倍. 均值化处理后, A 归一化到均值 1 附近, 但其离均差仍是 B 的 100 倍. 在关联系数公式中, A 的各点 Δ_i(k) 主导了 $\max\Delta$, 导致 B 的关联度被整体拉高 (因为 B 的所有 Δ 远小于 maxΔ). 此时关联度不能公平比较. 需要在无量纲化前先做标准化 (Z-score) 统一方差.
- **条件3 — 分辨系数 ρ 取极端值**: 当 ρ → 1 时, $\xi_i(k) \approx \frac{\max\Delta}{\Delta_i(k) + \max\Delta}$, 若 $\max\Delta$ 由少数异常点产生, 则所有正常点的关联系数趋近 1, 关联度 r_i 无法区分方案. 当 ρ → 0 时, $\xi_i(k) \approx \frac{\min\Delta}{\Delta_i(k)}$, 仅最小差处的点有区分作用, 其余点信息全部丢失. 必须做 ρ∈{0.1, 0.3, 0.5, 0.7, 0.9} 的灵敏度检验.

## 文献

1. 邓聚龙. (1990). 灰色系统理论教程. 华中理工大学出版社. (奠基性教材)
2. Deng, J. L. (1989). Introduction to grey system theory. *Journal of Grey System*, 1(1), 1-24. (首次国际发表)
3. 刘思峰, 党耀国, 方志耕. (2004). 灰色系统理论及其应用 (第三版). 科学出版社.
4. Zhu, C., & Li, N. (2014). Study on grey relational analysis and its application. *Advanced Materials Research*, 962, 1757-1760.
5. Kuo, Y., Yang, T., & Huang, G. W. (2008). The use of grey relational analysis in solving multiple attribute decision-making problems. *Computers & Industrial Engineering*, 55(1), 80-93.

## 来源溯源

灰色系统理论由华中科技大学 (原华中理工大学) 邓聚龙教授于 1982 年创立. 其核心思想是用"灰色"描述部分信息已知、部分信息未知的系统, 区别于"白色" (全知) 和"黑色" (全未知) 系统. 灰色关联分析是灰色系统理论中最重要的方法论工具之一, 通过比较序列几何形状的相似程度来判断关联程度. 该方法尤其适合中国的工程评价场景, 因其对数据要求低 (4 个以上样本即可), 且无分布假设. 邓聚龙提出的"邓氏关联度"是 GRA 的最基本形式, 后续发展出绝对关联度、相对关联度、T 型关联度等多个变体.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 同级对比 — 距离型综合评价 | PARADIGM-0302 (TOPSIS) |
| 同级对比 — 模糊评价 | PARADIGM-0304 (模糊综合评价) |
| 同级对比 — 非参数排序 | PARADIGM-0306 (秩和比法) |
| 组合使用 — 灰色-TOPSIS | GRA + TOPSIS (关联度代替距离) |
| 因素筛选 — 用关联度排序 | 预筛选指标 → 后续建模 |
| 灰色预测下游 | GM(1,1) 灰色预测 (非本 Skill, 需自建) |
