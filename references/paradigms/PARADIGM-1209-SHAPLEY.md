# PARADIGM-1209-SHAPLEY Shapley值: 合作博弈分配⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-1209-SHAPLEY |
| 类别/子类 | ⑫多目标决策进阶 / 合作博弈与公平分配 |
| 难度 | 高 |
| 适用题型关键词[] | 公平分配, 合作收益, 联盟博弈, 边际贡献, 利益分配, 成本分摊 |
| confidence | medium |
| source | 论文1953_Shapley / 题解反推_Coalition类 |

## 数学形式

**核心思想**: 基于每个参与者在所有可能联盟中的边际贡献, 按公平公理分配总收益。

对于 $n$ 个参与者的合作博弈 $(N, v)$, 其中 $v: 2^N \rightarrow \mathbb{R}$ 为特征函数 (每个联盟 $S \subseteq N$ 的收益):

$$\phi_i(v) = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|! (n - |S| - 1)!}{n!} \left[ v(S \cup \{i\}) - v(S) \right]$$

**满足的公理**:
1. **效率性**: $\sum_{i \in N} \phi_i(v) = v(N)$ (总收益全部分配)
2. **对称性**: 若 $i$ 和 $j$ 在所有联盟中边际贡献相同, 则 $\phi_i = \phi_j$
3. **虚拟参与者**: 若 $i$ 对所有联盟边际贡献为 0, 则 $\phi_i = 0$
4. **可加性**: $\phi_i(v + w) = \phi_i(v) + \phi_i(w)$

| 变量 | 含义 |
|------|------|
| $N$ | 参与者集合, $n = |N|$ |
| $S$ | 联盟 (参与者子集) |
| $v(S)$ | 联盟 $S$ 的总收益 |
| $\phi_i(v)$ | 参与者 $i$ 的 Shapley 值 (公平分配份额) |
| 加权因子 | $\frac{|S|!(n-|S|-1)!}{n!}$ — 所有序排列中等概率权重 |

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| 特征函数 $v$ | callable/mapping | — | — | 极高—Shapley值完全由 $v$ 决定 |

**时间复杂度**: $O(2^n)$ (精确枚举所有联盟) — $n > 20$ 不可行
**空间复杂度**: $O(2^n)$

**近似方法**: MC-Shapley (随机排列采样); 复杂度 $O(K n)$, $K$ = 采样数 (建议 $K \geq 1000$)

## MATLAB 实现

```matlab
% 自写 Shapley 值计算 (精确 + MC近似)
% 自写-见S5:shapley_allocate.m

% 实现步骤:
% 1. 输入特征函数 v (function handle: v(S) = v_value(subset_indices))
% 2. 精确: 枚举所有 2^n 联盟, 累加边际贡献
% 3. MC近似 (n>15时): K次随机排列, 对每位累加前后联盟差
% 4. 输出公平分配向量
```

**锚点工具箱**: 无内置 Shapley; 可用 `nchoosek` 生成联盟子集; `perms`/`randperm` 用于 MC

## Python 备选

```python
import numpy as np
from itertools import combinations
import math

def shapley_value(v_func, n, mc_samples=None):
    if mc_samples is None:
        # 精确计算
        phi = np.zeros(n)
        for i in range(n):
            others = [j for j in range(n) if j != i]
            for r in range(len(others) + 1):
                for S_subset in combinations(others, r):
                    S = set(S_subset)
                    weight = (math.factorial(len(S)) * 
                              math.factorial(n - len(S) - 1) / math.factorial(n))
                    S_with_i = S | {i}
                    phi[i] += weight * (v_func(S_with_i) - v_func(S))
    else:
        # MC 近似
        phi = np.zeros(n)
        for _ in range(mc_samples):
            perm = np.random.permutation(n)
            prev_val = v_func(set())
            for pos, i in enumerate(perm):
                curr_set = set(perm[:pos+1])
                phi[i] += v_func(curr_set) - prev_val
                prev_val = v_func(curr_set)
        phi /= mc_samples
    return phi
```

备选: `shap` 库 (SHAP用于ML解释, 本质类似) 但合作博弈 Shapley 实现差异较大

## 选型决策树

- **利益/成本公平分配 (合作剩余分配)** → Shapley 值 (理论上最公平)
- **$n \leq 15$** → 精确计算; **$n > 15$** → MC 近似
- **仅需比例分配 + 无需公平公理** → 按贡献比例分配 ($\frac{v(\{i\})}{\sum v(\{j\})}$) 更简单但无公平性保证
- **核仁 vs Shapley**: 核仁(Nucleolus)最小化最大不满意但难计算; Shapley 基于边际贡献更直观 → 竞赛首选 Shapley
- **分配 + 稳定性** → 核+Shapley 双重验证: Shapley 给出分配方案, 检查是否在核中

## 典型图型

- **raw**: 联盟价值分布 (柱状图: 各联盟规模 vs 平均价值)
- **process**: 各参与者边际贡献分布 (boxplot/小提琴图, MC采样)
- **result**: Shapley 分配对比饼图; 与"等分/比例分/按投入分"的对比柱状图

## 常见坑

1. **特征函数构造是关键**: $v(S) = \sum_{i \in S} v(\{i\})$ (可加博弈) 时 Shapley = $v(\{i\})$, 无交互效应 → 检查超可加性 ($v(S \cup T) \geq v(S) + v(T)$ if $S \cap T = \emptyset$)
2. **$n$ 指数量级爆炸**: $n=10$ 时枚举 $2^{10}=1024$ 联盟可行; $n=20$ 时 $2^{20} \approx 10^6$ 仍可行但慢; $n \geq 25$ 必须 MC
3. **MC 近似误差**: 采样数不足导致排序不稳定 → $K \geq 1000$, 验证: 重复运行 MC 看 $\phi_i$ 标准差
4. **零参与者的 Shapley = 0** 的逆否定: Shapley = 0 不意味着零贡献, 只是边际贡献被对称性抵消

## 失效条件/反例 (强制小节)

- **条件1**: $n \geq 25$ 且必须精确解 → 指数复杂度使精确枚举不可行 ($2^{25} \approx 3.3 \times 10^7$), MC 近似可行但需大量采样。**替代**: MC-Shapley (Acceptable) 或简化为 Owen 值 (层级结构, 复杂度更低)
- **条件2**: 特征函数 $v(S)$ 非超可加 → Shapley 值仍可计算, 但公理语义退化 ("合作不一定有利"), 分配方案在核外的概率高, 缺乏稳定性。**替代**: 若博弈可能不合作, 改用非合作博弈均衡 (Nash)
- **条件3**: 参与者完全对称 → Shapley 值全相等, 无区分度。这不是失败但无信息增益 → 理由: 所有参与者贡献相同, 应均分
- **条件4**: 构建特征函数 $v(S)$ 本身就是模糊/争议的 → 不同的 $v$ 建模方式产生截然不同的分配, Shapley 计算的"公平"仅与 $v$ 定义一样好。需显式声明 $v$ 的定义方式并做敏感性分析

## 文献

1. Shapley, L. S. (1953). A value for n-person games. In *Contributions to the Theory of Games*, Volume II (Annals of Mathematics Studies, 28), 307-317. Princeton University Press. DOI: [10.1515/9781400881970-018](https://doi.org/10.1515/9781400881970-018)
2. Roth, A. E. (1988). *The Shapley Value: Essays in Honor of Lloyd S. Shapley*. Cambridge University Press. ISBN: 978-0-521-36177-8.

## 来源溯源

- 论文三元组: Shapley 1953, n-person game value, fair division axioms
- 教学用例: 供应链联盟收益分配, 碳排放配额分配, 合作减排成本分摊

## 关联范式卡

替代: 核心 (Nucleolus, 最小化最大不满意), 比例分配 (简单但不公平)
前置: 博弈论基础 (不要求专门范式卡, 概念即可)
