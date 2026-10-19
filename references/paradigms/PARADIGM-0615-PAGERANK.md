# PARADIGM-0615 PageRank⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0615 |
| 类别/子类 | ⑥机器学习 / 图排序 |
| 难度 | 中 |
| 适用题型关键词[] | PageRank, 网页排序, 随机游走, 节点重要性, 影响力, 网络中心性, 特征向量中心度 |
| confidence | high |
| source | Brin & Page (1998) WWW |

## 数学形式

**PageRank 定义 (随机冲浪模型):**
$$PR(u) = \frac{1-d}{N} + d \sum_{v \in B_u} \frac{PR(v)}{L(v)}$$

其中:
- $B_u$ — 链接到 $u$ 的页面集合
- $L(v)$ — 页面 $v$ 的出链数
- $d$ — 阻尼因子 (damping factor)，默认 0.85
- $N$ — 网页总数

**矩阵形式:**
$$\mathbf{PR} = \left(\frac{1-d}{N}\mathbf{1}\mathbf{1}^T + d \cdot \mathbf{P}^T\right) \mathbf{PR}$$

其中 $\mathbf{P}$ 为转移矩阵 ($P_{ij} = 1/L(i)$ 若 $i \to j$ 存在)。

**幂迭代:**
$$\mathbf{PR}^{(t+1)} = \frac{1-d}{N}\mathbf{1} + d \cdot \mathbf{P}^T \mathbf{PR}^{(t)}$$

收敛条件: $|\mathbf{PR}^{(t+1)} - \mathbf{PR}^{(t)}|_1 < \varepsilon$

**特征向量解释:** $\mathbf{PR}$ 是 Google 矩阵的主特征向量 ($\lambda=1$)。

**变量表:**
- $d$ — 阻尼因子: 以概率 $d$ 跟随链接，以 $1-d$ 随机跳转
- Dead End (悬垂节点): 出度为 0 的节点需特殊处理

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| d (阻尼因子) | double | 0.85 | [0.7, 0.95] | 中 — 影响收敛速度与排序稳定性 |
| tol | double | 1e-6 | [1e-8, 1e-4] | 低 |
| max_iter | int | 100 | [20, 500] | 低 |
| 幂迭代复杂度 | — | — | O(N²) 密; O(E·iter) 疏 | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[pr, converged, n_iter] = pagerank(adj_matrix, d, tol, max_iter)
% adj_matrix: N×N 邻接矩阵 (有向图)
% pr: N×1 PageRank 值，sum=1
```

锚点: 自写-见S5:pagerank.m

```matlab
% 核心幂迭代
N = size(adj, 1);
out_deg = sum(adj, 2);
out_deg(out_deg == 0) = N;  % 处理悬垂节点: 链接到所有节点
P = adj ./ out_deg;  % 列随机转移矩阵

pr = ones(N, 1) / N;  % 初始化
for iter = 1:max_iter
    pr_new = (1-d)/N + d * (P' * pr);
    if norm(pr_new - pr, 1) < tol
        break;
    end
    pr = pr_new;
end
```

## Python 备选

```python
import networkx as nx
G = nx.from_numpy_array(adj_matrix, create_using=nx.DiGraph)
pr = nx.pagerank(G, alpha=0.85, max_iter=100, tol=1e-6)
# 返回 dict {node: score}
```

## 选型决策树

- **PageRank** — 网页排序/引文网络/有向图节点全局影响力
- **度中心性 (Degree Centrality)** — 仅考虑局部连接 (入度)
- **介数中心性 (Betweenness)** — 考虑节点在最短路径上的位置
- **特征向量中心性** — PageRank 的特例 (d=1, 无随机跳转)，仅当图强连通时有定义
- **HITS (Hub/Authority)** — 区分权威和枢纽两种角色

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 有向网络图 (节点大小≈出度) | 展示链接结构 |
| result | 节点大小≈PageRank 值的网络图 | 排名可视化 |
| result | PageRank 直方图 + Top-10 表 | 分布特征 |

## 常见坑

1. **悬垂节点 (Dead Ends)**: 出度=0 → 概率泄漏 → 收敛到零向量。处理: 虚拟链接到所有节点
2. **Spider Traps**: 强连通分量无出边 → PageRank 全部集中在此→ 阻尼因子 $d$ 确保跳出
3. **阻尼因子调优**: d→1 收敛慢但更反映真实结构; d→0 趋于均匀分布无意义

## 失效条件/反例 (强制小节)

- **条件1: 图极度稀疏 + 悬垂节点比例 > 50%** → 表现: 绝大多数 PageRank 值由 $(1-d)/N$ 的均匀部分贡献，$d=0.85$ 下的链接结构信息淹没 — 所有节点 PR 接近 $1/N$，排序无区分度。**应对**: 先用图预处理去除悬垂节点链，或在 PageRank 基础上组合内容分数 (如 TF-IDF)
- **条件2: 动态图 + 需实时更新排序** → 表现: 静态 PageRank 在新节点/边出现后需重新幂迭代 O(E·iter)，不满足实时性。**应对**: 使用增量 PageRank 更新算法 (如 Monte Carlo PageRank) 或近似方法

## 文献

1. Brin S. & Page L. (1998). "The anatomy of a large-scale hypertextual Web search engine." *Proceedings of the 7th International WWW Conference*, 107-117. DOI: [10.1016/S0169-7552(98)00110-X](https://doi.org/10.1016/S0169-7552(98)00110-X)
2. Langville A.N. & Meyer C.D. (2006). *Google's PageRank and Beyond: The Science of Search Engine Rankings*. Princeton University Press. ISBN: 978-0691122021

## 来源溯源

自写 pagerank.m; WWW 经典论文

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (最短路径) | PARADIGM-0401 (Dijkstra) |
| 组合 (网络分析) | PARADIGM-0405 (最大流) |
