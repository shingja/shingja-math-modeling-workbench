# PARADIGM-0622 Apriori 关联规则挖掘⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0622 |
| 类别/子类 | ⑥机器学习 / 关联规则与模式挖掘 |
| 难度 | 中 |
| 适用题型关键词[] | Apriori, 关联规则, 频繁项集, 支持度, 置信度, 提升度, 购物篮分析, 事务数据, 模式挖掘, 商品组合, 用药关联, 故障关联, 共现分析 |
| confidence | high |
| source | Agrawal et al. (1993) SIGMOD; 教材 通用算法模块/modeling/apriori.py (AprioriMiner); 自写-见S6:matlab/ml/apriori_association.m |

## 数学形式

**基本概念**: 设 $\mathcal{I} = \{i_1, \ldots, i_d\}$ 为项全集, 事务库 $\mathcal{T} = \{t_1, \ldots, t_n\}$, 每个事务 $t_j \subseteq \mathcal{I}$。

**支持度 (Support)**: 项集 $X$ 的事务覆盖比例
$$\text{supp}(X) = \frac{|\{t \in \mathcal{T} \mid X \subseteq t\}|}{n}$$

**置信度 (Confidence)**: 规则 $X \to Y$ 的条件概率
$$\text{conf}(X \to Y) = \frac{\text{supp}(X \cup Y)}{\text{supp}(X)}$$

**提升度 (Lift)**: 规则相关性度量
$$\text{lift}(X \to Y) = \frac{\text{supp}(X \cup Y)}{\text{supp}(X) \cdot \text{supp}(Y)} = \frac{\text{conf}(X \to Y)}{\text{supp}(Y)}$$

lift $> 1$ 正相关, $= 1$ 独立, $< 1$ 负相关 (应过滤)。

**Apriori 反单调性质** (剪枝的理论基础):

$$\forall X \subseteq Y : \text{supp}(Y) \leq \text{supp}(X)$$

即: 项集频繁 $\Rightarrow$ 所有子集频繁; 项集不频繁 $\Rightarrow$ 所有超集不频繁。

**算法框架** (逐层搜索):

1. 扫描一次得频繁 1-项集 $L_1$;
2. 对 $k = 2, 3, \ldots$: 由 $L_{k-1}$ 自连接生成候选 $C_k$ → 用反单调性质剪枝 (所有 $(k-1)$-子集须在 $L_{k-1}$ 中) → 扫描事务库对 $C_k$ 计数 → 得 $L_k$; 直至 $L_k$ 为空;
3. 对每个长度 $\geq 2$ 的频繁项集, 枚举前件/后件划分生成规则, 按 conf/lift 阈值过滤。

**复杂度**: 最坏候选数 $O(2^d)$ (不可行); 实际由支持度阈值控制。逐层需 $O(L)$ 次数据库扫描 ($L$ = 最长频繁项集长度), 与 FP-Growth (扫描 2 次) 相比, 长模式/大数据下效率低。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| transactions | cell 数组或 n×d logical | — | 项编号 1..d | 中 — 编码不一致会割裂规则 |
| MinSupport | float | 0.1 | (0, 1] | 极高 — 降低 10 倍, 频繁项集可能指数爆炸 |
| MinConfidence | float | 0.5 | (0, 1] | 高 — 仅影响规则生成 |
| MinLift | float | 1.0 | [0, ∞) | 中 — 滤除无相关/负相关规则 |
| MaxLength | int | Inf | [1, ∞) | 中 — 限制层数防止组合爆炸 |

| 输出 | 量纲 |
|------|------|
| freq_itemsets / supp | 1×L cell, 第 k 层为 k-项集 (1×k 行向量) 及其支持度 |
| rules | struct 数组: {antecedent, consequent, support, confidence, lift}, 按 lift 降序 |

**计算复杂度**: 第 k 层 $O(k \cdot |C_k| \cdot n)$ (候选计数主导), 总 $O(\sum_k k |C_k| n)$。MATLAB 中 logical 矩阵按列取交计数 (向量化), 中小规模 (n<10^4, d<10^2) 秒级。

## MATLAB 实现

**自写-见S6:matlab/ml/apriori_association.m** (MATLAB 无原生关联规则工具箱):

```matlab
function [freq_itemsets, supp, rules] = apriori_association(transactions, varargin)
% 可选: 'MinSupport'(0.1) 'MinConfidence'(0.5) 'MinLift'(1.0) 'MaxLength'(Inf)
% 示例 (购物篮: 5 种商品, 10 笔交易):
T = {[1 2 3], [1 2 3 5], [1 2], [2 3 4], [2 3], [3 4], [1 3], [2 4], [1 2 3 4], [1 3 4]};
[FI, SUPP, R] = apriori_association(T, 'MinSupport', 0.3, ...
    'MinConfidence', 0.7, 'MinLift', 0.9);
% R(1).antecedent / R(1).consequent / R(1).confidence / R(1).lift
```

## Python 备选

```python
from mlxtend.preprocessing import TransactionEncoder
from mlxtend.frequent_patterns import apriori, association_rules
import pandas as pd

te = TransactionEncoder()
df = pd.DataFrame(te.fit(T).transform(T), columns=te.columns_)
freq = apriori(df, min_support=0.3, use_colnames=True)
rules = association_rules(freq, metric='lift', min_threshold=0.9)
rules = rules[rules['confidence'] >= 0.7]
# 备选: 教材 通用算法模块/modeling/apriori.py 的 AprioriMiner (原生实现)
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 事务数据小 (n<10^4, d<10^2) 教学/快速验证 | Apriori | 实现直观, 逐层可解释 |
| 长频繁模式 / 大数据 | FP-Growth (0617) | 仅 2 次扫描, 无候选生成 |
| 连续数值属性 | 先离散化或改用聚类/决策树 | 关联规则要求离散项; 离散化割裂自然边界 |
| 规则爆炸 | 收紧 MinSupport / MinLift / MaxLength | 三个旋钮联合控制 |
| 时序敏感 (如药方随时间变化) | 加时间窗口或改用序列模式挖掘 | Apriori 是批处理静态模型 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 项频率排序条形图 (top-20) | 识别高频核心项 |
| raw | 事务长度分布直方图 | 判断稀疏/稠密程度 |
| process | MinSupport vs 频繁项集数曲线 | 展示阈值降低时的指数增长, 指导选阈值 |
| result | 规则气泡图 | x=support, y=confidence, 气泡大小/颜色=lift |
| result | 规则网络图 | 项为节点, 规则为有向边, 边粗=lift |
| result | top-K 规则表 | 按 lift 降序, 中文释义 |

## 常见坑

1. **MinSupport 过低组合爆炸**: 频繁项集上界 $2^d - 1$; d=500 且数据稠密时, 0.001 阈值可产生百万级 2-项集。从 0.05 起步逐步降。
2. **支持度-置信度权衡失效**: 高支持度低置信度 = 常见但不可靠; 低支持度高置信度 = 可靠但可能是巧合; 必须同时看 lift > 1。
3. **Simpson 悖论**: 高置信度规则在数据子集 (分时段/分群体) 中可能反转; 关键规则做分层复核。
4. **项编码不一致**: 同一商品两种写法会被当作两个项, 支持度被稀释; 先做全局标准化。
5. **lift 边界**: lift=1 恰为独立, 大量规则聚集在 1 附近无信息; MinLift 设 1.2~1.5 更实用。
6. **规则解读过度**: 关联 ≠ 因果; 论文中表述为"共现/关联", 不可写"导致"。

## 失效条件/反例 (强制小节)

- **条件1: MinSupport ≤ 0.001 且 d > 500, 数据稠密** → **表现**: 频繁 2-项集可达数十万, 3-项集数百万, 候选生成+计数时间/内存爆炸, MATLAB 抛 Out-of-Memory。**应对**: (1) 从 0.05 起逐步降; (2) MaxLength=3 截断; (3) 只保留 top-100 高频项; (4) 大数据改 FP-Growth (0617) 或 Spark。

- **条件2: 事务极短且项极多 (平均长度 < 2, d > 10^4)** → **表现**: 大部分项支持度低于阈值, 频繁 1-项集稀少, 高层频繁项集几乎不存在, 挖掘结果为空或仅有平凡规则。**应对**: 提高支持度阈值语义 (用绝对计数而非比例); 或用倒排索引先过滤; 必要时改用序列/会话分析。

- **条件3: 连续属性未恰当离散化** → **表现**: 等宽分桶把统计上连续的取值割裂 (如年龄 49/51 分桶不同), 真正关联被稀释, 产生大量低 lift 噪声规则。**应对**: 百分位自适应分桶、ChiMerge 基于检验的离散化, 或直接改用决策树 (0604)/回归类方法。

- **条件4: 规则基于的数据发生漂移** → **表现**: 促销季挖掘的"啤酒-尿布"式规则在常规时段 lift 大幅下降甚至反转; 旧规则误导决策。**应对**: 标注数据时段, 分时段挖掘对比; 定期重跑; 论文中声明规则时效性。

## 文献

1. Agrawal R, Imielinski T, Swami A (1993). "Mining association rules between sets of items in large databases." *Proc. 1993 ACM SIGMOD*, 207-216. DOI: [10.1145/170035.170072](https://doi.org/10.1145/170035.170072)
2. Agrawal R, Srikant R (1994). "Fast algorithms for mining association rules." *Proc. 20th VLDB*, 487-499. ISBN: 978-1558601530
3. Tan PN, Steinbach M, Kumar V (2016). *Introduction to Data Mining*, 2nd ed., Ch. 6. Pearson. ISBN: 978-0133128901

## 来源溯源

教材 `算法资料新1/通用算法模块/modeling/apriori.py` (AprioriMiner: 候选生成+剪枝+计数+规则生成, 支持 mlxtend 加速); 自写 S6:matlab/ml/apriori_association.m (logical 矩阵向量化计数)。

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0617 (FP-Growth, 大数据/长模式场景) |
| 前置 | PARADIGM-0501 (数据预处理与项编码标准化) |
| 组合 | PARADIGM-0601 (随机森林特征重要性验证规则) |
| 组合 | PARADIGM-0506 (聚类用于连续属性离散化) |
| 组合 | PARADIGM-0903 (文本共现分析场景) |
