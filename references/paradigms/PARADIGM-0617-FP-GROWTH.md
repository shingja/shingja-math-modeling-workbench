# PARADIGM-0617 FP-Growth 频繁模式挖掘⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0617 |
| 类别/子类 | ⑥机器学习 / 关联规则 |
| 难度 | 高 |
| 适用题型关键词[] | FP-Growth, 频繁模式, 关联规则, FP-Tree, 频繁项集, 支持度, 置信度, Apriori, 购物篮分析, 事务数据, 模式挖掘 |
| confidence | medium |
| source | Han et al. (2000) SIGMOD; 自写-见S5:fp_growth.m |

## 数学形式

**关联规则基本概念**

设 $\mathcal{I} = \{i_1, i_2, \ldots, i_d\}$ 为所有项的集合, $\mathcal{T} = \{t_1, t_2, \ldots, t_n\}$ 为事务数据库, 每个事务 $t_j \subseteq \mathcal{I}$。

**支持度 (Support)**: 项集 $X$ 的事务覆盖比例
$$\text{supp}(X) = \frac{|\{t \in \mathcal{T} \mid X \subseteq t\}|}{n}$$

若 $\text{supp}(X) \geq \text{min\_sup}$, 则 $X$ 为频繁项集。

**置信度 (Confidence)**: 规则 $X \to Y$ 的可靠程度
$$\text{conf}(X \to Y) = \frac{\text{supp}(X \cup Y)}{\text{supp}(X)}$$

**提升度 (Lift)**: 规则的相关性度量
$$\text{lift}(X \to Y) = \frac{\text{supp}(X \cup Y)}{\text{supp}(X) \cdot \text{supp}(Y)} = \frac{\text{conf}(X \to Y)}{\text{supp}(Y)}$$

- lift $> 1$: 正相关 ($X$ 增加了 $Y$ 出现的概率)
- lift $= 1$: 独立
- lift $< 1$: 负相关

**FP-Growth 算法**

**阶段1: FP-Tree 构造**

1. 扫描 $\mathcal{T}$ 一次, 计算所有项的频数, 得频繁1-项集 (支持度 $\geq$ min\_sup)。按支持度降序排列频繁项列表 $L$。

2. 第二次扫描 $\mathcal{T}$: 对每个事务 $t$:
   - 保留 $t$ 中的频繁项, 按 $L$ 排序
   - 将排序后的事务插入 FP-Tree: 若当前节点已有共享前缀子节点, 沿共享路径递增计数; 否则创建新分支

**阶段2: FP-Growth 递归挖掘**

对 $L$ 中每个项 $i_k$ (从最不频繁的开始, 自底向上):
1. 收集 $i_k$ 的所有前缀路径 (条件模式基, conditional pattern base)
2. 在条件模式基上递归构建条件 FP-Tree
3. 在条件 FP-Tree 上递归挖掘, 生成包含 $i_k$ 的频繁项集

**Apriori 原理 (前项性质)**:
若 $X$ 频繁则其所有子集也频繁; 若 $X$ 不频繁则其所有超集也不频繁。
$$\forall X \subseteq Y : \text{supp}(Y) \leq \text{supp}(X)$$

**FP-Growth vs Apriori 复杂度对比**:
- Apriori: 每层生成候选 $\to$ 扫描数据库 $\to$ 计数; 对长频繁模式需要 $O(|L| \cdot n)$ 次数据库扫描
- FP-Growth: 仅扫描数据库 2 次; 将长频繁模式的搜索问题压缩为 FP-Tree 上的递归问题

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| min_sup (最小支持度) | float | 0.01 | (0, 1] | 极高 — 降低 10 倍可能使频繁项集数量指数爆炸 |
| min_conf (最小置信度) | float | 0.5 | (0, 1] | 高 — 仅影响规则生成, 不影响 FP-Tree 构建 |
| min_lift (最小提升度) | float | 1.0 | (0, $\infty$) | 中 — 过滤无相关性的规则 |
| max_len (最大项集长度) | int | $\infty$ | [1, $\infty$) | 低 — 限制频繁项集最大长度以防组合爆炸 |
| n (事务数) | int | — | [1, $\infty$) | 中 — FP-Tree 内存消耗随事务数线性增长 |
| d (不同项总数) | int | — | [1, $\infty$) | 高 — 项数多 + 事务短 $\to$ 共享前缀少, 压缩率低 |
| avg_trans_len (平均事务长度) | float | — | [1, d] | 高 — 事务越长 $\to$ 频繁项集越多 $\to$ 挖掘时间越长 |

| 输出 | 量纲 |
|------|------|
| frequent_itemsets | 项集列表 + 支持度 (count 或 %) |
| association_rules | $\{X \to Y,$ support, confidence, lift$\}$ 四元组 |
| fp_tree_size | 节点数 (内存占用指标) |

**计算复杂度**: FP-Tree 构造 $O(n \cdot \bar{l})$ ($\bar{l}$ 平均事务长度); 挖掘 $O(d \cdot F)$ ($F$ 为频繁项集总数, 由 min\_sup 决定)。最坏情况下 $F = O(2^d)$, 但实际 min\_sup 剪枝后远小。

## MATLAB 实现

**自写-见S5:fp_growth.m** (MATLAB 无原生关联规则/频繁模式挖掘工具箱, 需自建 FP-Tree 数据结构 + 递归挖掘)。

```matlab
% 核心函数签名
function [frequent_itemsets, rules] = fp_growth(transactions, min_sup, min_conf)
% INPUT:
%   transactions - cell array, 每个 cell 包含一个事务 (项索引的 vector)
%                  或 n-by-d 的 logical 矩阵 (稀疏格式)
%   min_sup      - 最小支持度 (小数 e.g. 0.01 或 整数计数)
%   min_conf     - 最小置信度 (小数 e.g. 0.5)
% OUTPUT:
%   frequent_itemsets - struct array with fields: items, support
%   rules             - struct array with fields: antecedent, consequent,
%                       support, confidence, lift

%% 阶段1: FP-Tree 构造
% 第一次扫描: 计算所有项的频数
[n_trans, n_items] = size(transactions);
item_counts = sum(transactions, 1);

% 筛选频繁项 (>= min_sup * n_trans)
freq_items = find(item_counts >= min_sup * n_trans);

% 按支持度降序排列 (构建 L 表)
[~, order] = sort(item_counts(freq_items), 'descend');
L = freq_items(order);

% 第二次扫描: 构建 FP-Tree
root = struct('item', 0, 'count', 0, 'parent', [], ...
    'children', containers.Map('KeyType', 'double', 'ValueType', 'any'), ...
    'node_link', []);
header_table = containers.Map('KeyType', 'double', 'ValueType', 'any');

for i = 1:n_trans
    t_items = find(transactions(i, :));
    t_freq = intersect(t_items, L, 'stable');
    [~, idx] = ismember(t_freq, L);
    [~, sort_idx] = sort(idx);
    t_freq_sorted = t_freq(sort_idx);

    current = root;
    for j = 1:length(t_freq_sorted)
        item = t_freq_sorted(j);
        if isKey(current.children, item)
            child = current.children(item);
            child.count = child.count + 1;
        else
            child = struct('item', item, 'count', 1, 'parent', current, ...
                'children', containers.Map('KeyType', 'double', 'ValueType', 'any'), ...
                'node_link', []);
            current.children(item) = child;
            if ~isKey(header_table, item)
                header_table(item) = child;
            else
                h = header_table(item);
                while ~isempty(h.node_link)
                    h = h.node_link;
                end
                h.node_link = child;
            end
        end
        current = child;
    end
end

%% 阶段2: FP-Growth 递归挖掘
frequent_itemsets = {};
for k = length(L):-1:1
    item = L(k);
    beta = {item};
    node = header_table(item);
    conditional_base = {};
    while ~isempty(node)
        support = node.count;
        prefix = [];
        p = node.parent;
        while p.item ~= 0
            prefix = [prefix, p.item];
            p = p.parent;
        end
        if ~isempty(prefix)
            conditional_base{end+1} = struct('prefix', prefix, 'support', support);
        end
        node = node.node_link;
    end
    % 递归处理条件模式基 -> 条件 FP-Tree -> 生成频繁项集
    % (完整递归实现在 S5:fp_growth.m 的 fp_growth_recursive 函数中)
end

%% 阶段3: 关联规则生成
rules = struct('antecedent', {}, 'consequent', {}, ...
    'support', {}, 'confidence', {}, 'lift', {});
for i = 1:length(frequent_itemsets)
    itemset = frequent_itemsets{i};
    k = length(itemset);
    if k < 2, continue; end
    for len = 1:(k-1)
        subsets = nchoosek(itemset, len);
        for s = 1:size(subsets, 1)
            antecedent = subsets(s, :);
            consequent = setdiff(itemset, antecedent);
            supp_ante = get_support(antecedent, transactions);
            supp_union = get_support(itemset, transactions);
            supp_cons = get_support(consequent, transactions);
            conf = supp_union / supp_ante;
            lift = supp_union / (supp_ante * supp_cons);
            if conf >= min_conf
                rules(end+1) = struct('antecedent', antecedent, ...
                    'consequent', consequent, 'support', supp_union, ...
                    'confidence', conf, 'lift', lift);
            end
        end
    end
end
```

**关键说明**: MATLAB 的 FP-Tree 实现核心难点在于 (1) 动态树结构的表示 (使用 `containers.Map` 或嵌套 struct) 和 (2) 条件 FP-Tree 的递归构建。完整的 S5:fp_growth.m 包含递归条件挖掘函数和规则生成优化。

**简化版 Apriori** (教学/验证用, 小数据集):

```matlab
% 简单暴力枚举 (仅 k=1,2 项集)
function [freq_sets, support] = apriori_simple(transactions, min_sup)
    % 适用于 n < 1000, d < 50 的教学场景
end
```

## Python 备选

```python
import pandas as pd
from mlxtend.frequent_patterns import fpgrowth, association_rules
from mlxtend.preprocessing import TransactionEncoder

# 事务数据 -> One-Hot 编码
transactions = [['A', 'B', 'C'],
                ['A', 'C', 'D', 'E'],
                ['B', 'D', 'C'],
                ['A', 'B', 'C', 'D']]

te = TransactionEncoder()
te_ary = te.fit(transactions).transform(transactions)
df = pd.DataFrame(te_ary, columns=te.columns_)

# FP-Growth 挖掘频繁项集
freq_itemsets = fpgrowth(df, min_support=0.5, use_colnames=True)
print(freq_itemsets)

# 生成关联规则
rules = association_rules(freq_itemsets, metric='confidence', min_threshold=0.7)
strong = rules[(rules['lift'] > 1.5) & (rules['confidence'] > 0.8)]
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 购物篮分析 / 商品推荐 | FP-Growth | 经典应用场景, 事务数据天然适合 |
| 长频繁模式 (项集长度 > 5) | FP-Growth | 无需候选生成, 优势远超 Apriori |
| 数据量小 (n < 1000, d < 50) | Apriori | 简单直接, 无需 FP-Tree 数据结构 |
| 事务数据稠密 (avg length > 20) | FP-Growth / Eclat | Eclat 在稠密数据上有时更快 |
| 数据稀疏 (事务短 + 项多) | 谨慎使用 | FP-Tree 压缩率低, 共享前缀极少 |
| 实时/增量更新 | 不适合 | FP-Growth 是批处理算法 |
| 连续值数据 | 不适合 | 需先离散化, 但离散化割裂自然边界 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 事务长度分布直方图 | 了解事务稀疏/稠密程度 |
| raw | 项频率排序条形图 (top-20) | 识别高频核心项 |
| process | FP-Tree 结构可视化 | 小规模数据的树结构图 |
| process | min_sup vs 频繁项集数量 | 展示 min_sup 降低时项集数的指数增长 |
| result | 关联规则气泡图 | support vs confidence vs lift 三维 |
| result | 关联规则网络图 | 项为节点, 规则为有向边, lift 映射边粗细 |
| result | top-K 规则表 | 按 lift 降序排列, 标注中文释义 |

## 常见坑

1. **min_sup 过低导致组合爆炸**: 频繁项集总数上界 $\sum_{k=1}^{d} \binom{d}{k} = 2^d - 1$, 实际由 min_sup 剪枝。若 min_sup=0.001 且 d=1000, 2-项集可能已数百万。建议从 0.05 开始逐步降低。
2. **项编码不一致**: 事务数据中同一项编码需全局统一 (空格/大小写/全半角标准化), 否则 FP-Tree 将同一项视为不同项。
3. **稀疏数据压缩率低**: 若事务平均长度 < 3 且项数 > 10000, FP-Tree 中几乎无共享前缀 $\to$ 退化为二维表, 优势消失。使用倒排索引 + Eclat 更合适。
4. **支持度 vs 置信度的权衡**: 高支持度低置信度 $\to$ 常见但不可靠; 低支持度高置信度 $\to$ 可靠但少见 (可能是巧合)。需同时考察 lift > 1。
5. **Simpson 悖论**: 高置信度规则可能在数据子集中反转方向 $\to$ 对关键规则做分层分析。

## 失效条件/反例 (强制小节)

- **条件1: min_sup 过低 ($\leq 0.001$ 且 $d > 500$)** $\to$ **表现**: 频繁项集数量指数爆炸。若 d=500 且数据稠密 (事务平均长度 $\approx$ 30), min_sup=0.001 产生的频繁 2-项集可能超 250000, 3-项集可达数百万。FP-Tree 内存消耗超可用 RAM, MATLAB 抛出 Out-of-Memory 错误。**应对**: (1) 从较大 min_sup (0.05) 开始, 按需降低; (2) 设置 max_len=3; (3) 仅保留支持度 top-100 的项; (4) 若必须低 min_sup, 改用分布式方案 (Spark MLlib) 或 Eclat。

- **条件2: 数据极度稀疏 (事务平均长度 < 2 且项数 $d > 10000$)** $\to$ **表现**: FP-Tree 依赖共享前缀压缩事务数据库。当事务极短 (1-2 项), 两个事务共享前缀的概率 $\approx \sum p_i^2 \approx 1/d \to 0$。FP-Tree 退化为关联列表, 节点数 $\approx$ 事务中项总数, 压缩率为 0。挖掘效率退化为 Apriori 级别 (甚至更差, 因树遍历开销大于单纯候选计数)。**应对**: (1) 使用 Apriori 或 Eclat; (2) 先用 min_sup 做激进过滤 (仅保留出现在 > 10% 事务中的项)。

- **条件3: 连续属性未恰当离散化** $\to$ **表现**: 等宽/等频离散化断点割裂统计模式。如年龄 49 和 51 被分入不同桶而购买行为无本质差异 $\to$ 同时包含两桶的事务极少 $\to$ 真正有意义的关联被稀释。离散化粒度不当 (太粗 $\to$ 信息损失; 太细 $\to$ 支持度分散) 也影响结果。**应对**: (1) 使用基于密度的离散化 (百分位数自适应分桶); (2) 使用 ChiMerge 等基于统计检验的离散化; (3) 改用定量关联规则方法或直接转向决策树/回归。

## 文献

1. Han J, Pei J, Yin Y (2000). "Mining frequent patterns without candidate generation." *Proc. 2000 ACM SIGMOD*, pp. 1-12. DOI: [10.1145/342009.335372](https://doi.org/10.1145/342009.335372)
2. Agrawal R, Imielinski T, Swami A (1993). "Mining association rules between sets of items in large databases." *Proc. 1993 ACM SIGMOD*, pp. 207-216. DOI: [10.1145/170035.170072](https://doi.org/10.1145/170035.170072)
3. Tan PN, Steinbach M, Kumar V (2016). *Introduction to Data Mining*, 2nd ed. Pearson. Ch. 6. ISBN: 978-0133128901

## 来源溯源

Han et al. (2000) SIGMOD; 自写 S5:fp_growth.m; Python mlxtend.frequent_patterns 参考实现.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0506 (K-Means 聚类, 另一种无监督模式发现, 对数值型数据) |
| 组合 | PARADIGM-0601 (随机森林, 特征重要性验证关联规则的预测能力) |
| 前置 | PARADIGM-0501 (数据预处理, 离散化/编码至关重要) |
