# PARADIGM-0304 模糊综合评价 (Fuzzy Comprehensive Evaluation)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0304 |
| 类别/子类 | ③评价 / 模糊数学 |
| 难度 | 中 |
| 适用题型关键词[] | 模糊综合评价, FCE, 隶属函数, 模糊矩阵, 模糊合成算子, 最大隶属度, 去模糊化, 模糊数学, 模糊集, Zadeh, 隶属度, 模糊关系, 评语集, 因素集 |
| confidence | medium |
| source | Zadeh, L.A. (1965) Fuzzy Sets. *Information and Control*, 8(3), 338-353. |

## 数学形式

### 1. 确定因素集和评语集

- 因素集: $U = \{u_1, u_2, \ldots, u_n\}$ (n 个评价指标)
- 评语集: $V = \{v_1, v_2, \ldots, v_m\}$ (m 个等级, 如 {优, 良, 中, 差})

### 2. 构建隶属函数 (单因素评价)

对每个因素 $u_i$, 确定其对评语等级 $v_j$ 的隶属度 $r_{ij}$:

$$r_{ij} = \mu_{v_j}(x_i) \in [0, 1]$$

常用隶属函数:

**三角隶属函数**:
$$\mu(x) = \max\left( \min\left( \frac{x-a}{b-a}, \frac{c-x}{c-b} \right), 0 \right)$$

**梯形隶属函数**:
$$\mu(x) = \max\left( \min\left( \frac{x-a}{b-a}, 1, \frac{d-x}{d-c} \right), 0 \right)$$

### 3. 构造模糊评判矩阵

$$R = (r_{ij})_{n \times m}$$

### 4. 模糊合成运算

给定因素权重向量 $A = (a_1, \ldots, a_n)$ (满足 $\sum a_i = 1$), 模糊合成:

$$B = A \circ R = (b_1, b_2, \ldots, b_m)$$

其中 $\circ$ 为模糊合成算子:

| 算子 | 公式 | 特点 |
|------|------|------|
| M(∧, ∨) — 主因素决定型 | $b_j = \max_i(\min(a_i, r_{ij}))$ | 仅保留主因素, 丢失次要信息 |
| M(·, ∨) — 主因素突出型 | $b_j = \max_i(a_i \cdot r_{ij})$ | 权重乘入, 仍突出主因素 |
| M(·, +) — 加权平均型 | $b_j = \sum_i a_i \cdot r_{ij}$ | 保留全部信息, 最常用 |

### 5. 去模糊化 (获取标量分数)

**加权平均法** (最常用):
$$Score = \frac{\sum_{j=1}^m b_j \cdot s_j}{\sum_{j=1}^m b_j}$$

其中 $s_j$ 为评语等级 $v_j$ 的数值代表 (如 {优=95, 良=82, 中=67, 差=50}).

**最大隶属度原则**: 取 $b_j$ 最大值对应的评语等级. 仅在 $\max(b_j) > 0.5$ 且次大值 < 0.5×(1-最大值) 时有效.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 因素集 U | cell array (n) | — | — | 中 — 因素选择决定模型结构 |
| 评语集 V | cell array (m) | 5 级 | 3~7 级 | 中 — 分级太粗/太细影响区分度 |
| 隶属函数类型 | string | "triangular" | {"tri", "trapezoid", "gaussian"} | 高 — 不同函数型态影响隶属度矩阵 |
| 模糊合成算子 | string | "M(·,+)" | {"M(∧,∨)", "M(·,∨)", "M(·,+)"} | 极高 — 决定信息保留程度 |
| 权重向量 A | vector (n) | 等权 | Σ a_i=1, a_i>0 | 高 — 权重直接影响合成结果 |
| 评分向量 S | vector (m) | 等间距 | — | 中 — 影响去模糊化得分量级 |

**复杂度**: 空间 O(n·m), 时间 O(n·m) — 模糊矩阵合成运算均为矩阵运算, 极快.

## MATLAB 实现

```matlab
% ===== PARADIGM-0304-FUZZY-EVAL: 自写-见S5:fuzzy_eval.m =====
function [B, score, best_class] = fuzzy_eval(X_sample, A, params)
    % X_sample: 1×n 单样本在各因素的原始取值
    % A: 1×n 因素权重向量
    % params: 结构体, 包含:
    %   params.V_labels: 1×m cell — 评语集名称
    %   params.V_scores: 1×m — 评语等级代表分数
    %   params.mf_type: char — 隶属函数类型 ('tri', 'trap', 'gauss')
    %   params.mf_params: n×1 cell — 每个因素的隶属函数参数
    %       tri: [a, b, c] 三角隶属 3 参数
    %       trap: [a, b, c, d] 梯形隶属 4 参数
    %   params.operator: char — 模糊合成算子
    % B: 1×m 模糊综合评判向量
    % score: 标量 — 去模糊化综合得分
    % best_class: 最大隶属度对应评语等级索引

    n = length(X_sample);      % 因素数
    m = length(params.V_labels); % 评语等级数

    % --- Step 1: 计算单因素评判矩阵 R (n×m) ---
    R = zeros(n, m);
    for i = 1:n
        xi = X_sample(i);
        switch params.mf_type
            case 'tri'
                R(i, :) = tri_mf(xi, params.mf_params{i}, m);
            case 'trap'
                R(i, :) = trap_mf(xi, params.mf_params{i}, m);
            case 'gauss'
                R(i, :) = gauss_mf(xi, params.mf_params{i}, m);
        end
    end

    % --- Step 2: 模糊合成 B = A ∘ R ---
    switch params.operator
        case 'M_min_max'        % M(∧, ∨) 主因素决定型
            B = max(min(A', R), [], 1);
        case 'M_dot_max'        % M(·, ∨) 主因素突出型
            B = max(A' .* R, [], 1);
        case 'M_dot_plus'       % M(·, +) 加权平均型 (推荐)
            B = A * R;
        otherwise
            B = A * R;
    end

    % --- Step 3: 去模糊化 ---
    score = sum(B .* params.V_scores) / sum(B);

    % --- Step 4: 最大隶属度原则 ---
    [maxB, best_class] = max(B);

    % 有效性检验
    sortedB = sort(B, 'descend');
    if maxB < 0.5
        warning('最大隶属度 %.2f < 0.5, 最大隶属度原则不可靠, 请使用加权平均得分', maxB);
    end
    if sortedB(2) > 0.5 * (1 - maxB)
        warning('次大隶属度偏大, 存在多级模糊现象, 不宜机械取最大值');
    end

    fprintf('模糊综合得分: %.2f | 最佳等级: %s (隶属度: %.3f)\n', ...
        score, params.V_labels{best_class}, maxB);
end

function mu = tri_mf(x, params, m)
    % 三角隶属函数: params = [a_j, b_j, c_j] 对每个等级 j
    mu = zeros(1, m);
    for j = 1:m
        a = params(j, 1); b = params(j, 2); c = params(j, 3);
        if x <= a || x >= c
            mu(j) = 0;
        elseif x < b
            mu(j) = (x - a) / (b - a);
        else
            mu(j) = (c - x) / (c - b);
        end
    end
end

function mu = trap_mf(x, params, m)
    % 梯形隶属函数: params = [a_j, b_j, c_j, d_j]
    mu = zeros(1, m);
    for j = 1:m
        a = params(j, 1); b = params(j, 2);
        c = params(j, 3); d = params(j, 4);
        if x <= a || x >= d
            mu(j) = 0;
        elseif x >= b && x <= c
            mu(j) = 1;
        elseif x > a && x < b
            mu(j) = (x - a) / (b - a);
        else
            mu(j) = (d - x) / (d - c);
        end
    end
end

function mu = gauss_mf(x, params, m)
    % 高斯隶属函数: params = [mu_j, sigma_j]
    mu = zeros(1, m);
    for j = 1:m
        mu_j = params(j, 1); sigma_j = params(j, 2);
        mu(j) = exp(-((x - mu_j)^2) / (2 * sigma_j^2));
    end
end
```

**注**: 可配合 Fuzzy Logic Toolbox 内置 `trimf`, `trapmf`, `gaussmf` 函数替代自写隶属函数.

## Python 备选

```python
import numpy as np

def tri_mf(x, params):
    """三角隶属函数"""
    mu = np.zeros(len(params))
    for j, (a, b, c) in enumerate(params):
        if x <= a or x >= c:
            mu[j] = 0.0
        elif x < b:
            mu[j] = (x - a) / (b - a)
        else:
            mu[j] = (c - x) / (c - b)
    return mu

def fuzzy_eval(X_sample, A, V_scores, mf_type='tri',
               mf_params=None, operator='M_dot_plus'):
    """
    模糊综合评价 (纯 numpy, 无额外依赖)
    返回: B (模糊评判向量), score (综合得分), best_class_idx
    """
    n = len(X_sample)
    m = len(V_scores)

    # 构造单因素评判矩阵 R
    R = np.zeros((n, m))
    for i in range(n):
        xi = X_sample[i]
        if mf_type == 'tri':
            R[i] = tri_mf(xi, mf_params[i])
        # ... 可扩展 trap, gauss

    # 模糊合成
    if operator == 'M_min_max':
        B = np.max(np.minimum(A[:, None], R), axis=0)
    elif operator == 'M_dot_plus':
        B = A @ R
    else:
        B = A @ R

    # 去模糊化
    score = np.sum(B * V_scores) / np.sum(B)
    best_class = np.argmax(B)

    return B, score, best_class
```

## 选型决策树

```
评价问题中存在模糊性/不确定性/主观定性指标
│
├─ 评语等级有明确语言含义 (优/良/中/差) → 模糊综合评价 ✓ (本范式)
│   ├─ 单层评价 → 一级模糊综合评价, 直接使用本范式
│   └─ 多层次指标体系 → 多级模糊综合评价, 逐层合成
│
├─ 数据精确且指标独立 → 优先 TOPSIS (PARADIGM-0302) 或熵权+TOPSIS
├─ 隶属函数难以确定 → 考虑灰色关联分析 (PARADIGM-0305)
└─ 需群决策 (多位专家) → 模糊综合评价 + Delphi 收敛
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 隶属函数展示 | 折线图 — 每个因素的隶属函数曲线叠加 | 标注因素实际取值在曲线上位置 |
| 模糊评判向量 | 雷达图 — 每个方案的 B 向量 | 面积大小反映综合得分, 各方向反映等级隶属度 |
| 综合得分排序 | 横向条形图 — 各方案去模糊化得分 | 颜色映射最大隶属度等级 |
| 多级模糊综合 | 旭日图 / 桑基图 — 各级权重流向 | 展示因素→准则→目标的三级合成结构 |

## 常见坑

1. **隶属函数主观性过强**: 三角/梯形隶属函数的参数 (a, b, c, d) 完全由建模者设定, 缺乏客观校准. 不同人设定可能得出相反结论. 建议用数据分布 (如分位数) 锚定参数, 并在论文中做隶属函数灵敏度分析.
2. **最大隶属度原则滥用**: 最大隶属度原则仅在单峰且峰值突出的情况下有效. 当 $\max(b_j) < 0.5$ 或次大隶属度与最大值接近时, 强行用最大隶属度会导致误判. 应优先用加权平均去模糊化.
3. **算子选择的影响被低估**: M(∧, ∨) 算子只关心单个最优因素, 丢失大量信息, 当权重分布均匀或因素较多时结果严重失真. 竞赛中如无特殊理由, 推荐 M(·, +) 加权平均型.
4. **多级模糊综合的稀释效应**: 三级以上模糊综合时, 低层信息在逐级合成中被不断平滑, 最终结果趋向"中等". 这是模糊运算固有的信息稀释特性, 应限制层级 ≤2, 或顶层改用精确方法.
5. **评语等级间距不均匀**: 若评语集对应的分数间距不均 (如 {优=95, 良=85, 中=65, 差=30}), 加权平均得分会被人为扭曲. 建议等间距或使用层次分析法确定等级分值.

## 失效条件/反例 (强制小节)

- **条件1 — 模糊算子选错导致信息灾难**: M(∧, ∨) 算子 (主因素决定型) 为"一票否决"逻辑 — 仅保留权重因素中最小隶属度的最大值. 当有 10 个因素每个权重 0.1 时, 所有因素的隶属度先被 min(a_i, r_ij)=min(0.1, r_ij) 截断至 ≤0.1, 最终 B 所有元素 ≈0.1, 完全丢失区分度. 结论: 权重分散时绝对禁用 M(∧, ∨), 必须用 M(·, +).
- **条件2 — 隶属函数型态导致评价结论方向相反**: 某指标取值 60 分, 在三角隶属函数下对"良"的隶属度=0.7 对"中"=0.3 (倾向良), 但换用高斯隶属函数 (标准差较窄) 可能变为对"良"=0.3 对"中"=0.7 (倾向中). 两种函数均无错误, 但结论相反. 建议用至少两种隶属函数做稳健性检验.
- **条件3 — 多级模糊综合的逐级信息稀释**: 三级模糊综合中, 底层 15 个指标的原始隶属度信息, 经第一级合成压缩为 5 个二级指标, 再经第二级压缩为 2 个一级指标, 最终顶层 B 向量趋于均匀分布 [0.33, 0.34, 0.33]. 此时"中等"结论并非客观事实, 而是合成的信息论必然. 限制为 ≤2 级, 或顶层切入精确方法.

## 文献

1. Zadeh, L. A. (1965). Fuzzy Sets. *Information and Control*, 8(3), 338-353. (模糊集开创论文)
2. Zadeh, L. A. (1973). Outline of a new approach to the analysis of complex systems and decision processes. *IEEE Transactions on Systems, Man, and Cybernetics*, 3(1), 28-44.
3. 汪培庄. (1983). 模糊集合论及其应用. 上海科学技术出版社.
4. Chen, S. J., & Hwang, C. L. (1992). *Fuzzy Multiple Attribute Decision Making: Methods and Applications*. Springer-Verlag.
5. Wang, Y. M., & Elhag, T. M. S. (2006). Fuzzy TOPSIS method based on alpha level sets with an application to bridge risk assessment. *Expert Systems with Applications*, 31(2), 309-319.

## 来源溯源

模糊综合评价的理论根基是 Zadeh 于 1965 年提出的模糊集合论. Zadeh 引入隶属函数概念, 将经典集合的 {0, 1} 二值逻辑推广至 [0, 1] 连续统, 使"某城市空气质量为'良'"这类语言性判断得以数学化. 汪培庄 (1983) 等学者将模糊数学系统引入中国, 建立了模糊综合评价的标准化框架: 因素集-评语集-隶属函数-模糊合成-去模糊化, 成为中文评价问题建模的主流方法之一, 广泛应用于环境质量评价、教学质量评估、风险分析、满意度调查等场景.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 上游 — 主观赋权供模糊合成使用 | PARADIGM-0301 (AHP) |
| 上游 — 客观赋权供模糊合成使用 | PARADIGM-0303 (熵权法) |
| 同级对比 — 精确评价替代方案 | PARADIGM-0302 (TOPSIS) |
| 同级对比 — 灰色评价替代方案 | PARADIGM-0305 (灰色关联分析) |
| 组合使用 — 权重双重来源 | AHP-EWM 组合赋权 → 模糊综合评价 |
| 模糊扩展 — 区间直觉模糊 | IVIFS-TOPSIS (非本 Skill, 需自建) |
