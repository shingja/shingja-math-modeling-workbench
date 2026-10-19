# PARADIGM-0406 关键路径法CPM⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0406 |
| 类别/子类 | ④图论与网络 / 项目管理 |
| 难度 | 中 |
| 适用题型关键词[] | 关键路径, CPM, 项目管理, 工序安排, 工期优化, PERT, AOE网, 最早/最晚开始时间 |
| confidence | high |
| source | Kelley & Walker (1959) Proc EJCC |

## 数学形式

**AOE 网 (Activity On Edge):**
- 节点 = 事件 (里程碑)
- 有向边 = 工序 (activity)，权重 = 工期

**最早开始时间 ES (正向递推):**
$$ES[v] = \max_{u \in \text{pred}(v)} \{ES[u] + w(u,v)\}, \quad ES[start] = 0$$

**最晚开始时间 LS (反向递推):**
$$LS[u] = \min_{v \in \text{succ}(u)} \{LS[v] - w(u,v)\}, \quad LS[end] = ES[end]$$

**总时差 (Total Float):**
$$TF(u,v) = LS[v] - ES[u] - w(u,v)$$

**关键路径:** $TF = 0$ 的边构成的路径 (从 start 到 end)
**关键路径上的任何延迟都直接导致总工期延迟。**

**总工期:** $T_{\text{total}} = ES[end]$

**变量表:**
- $ES[v], LS[v]$ — 节点 v 的最早/最晚发生时间
- $w(u,v)$ — 工序 $(u,v)$ 的工期
- $TF$ — 总时差 = 0 则为关键工序

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| activities | table | — | (from, to, duration) 三元组 | — |
| n_activities | int | — | [1, 10000] | — |
| 时间复杂度 | — | — | O(V+E) | — |
| 空间复杂度 | — | — | O(V+E) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[ES, LS, TF, critical_path, total_duration] = cpm(activities)
% activities: N×3 矩阵 [from_node, to_node, duration]
```

锚点: 自写-见S5:cpm.m

**核心代码片段:**
```matlab
% 正向递推
ES = zeros(n_nodes, 1);
for i = 1:n_nodes  % 拓扑顺序
    for each outgoing edge (i, j, w)
        ES(j) = max(ES(j), ES(i) + w);
    end
end

% 反向递推
LS = repmat(ES(end), n_nodes, 1);
for i = n_nodes:-1:1
    for each incoming edge (k, i, w)
        LS(k) = min(LS(k), LS(i) - w);
    end
end

% 总时差
TF = LS(to_nodes) - ES(from_nodes) - durations;
critical_path = find(abs(TF) < 1e-10);
```

## Python 备选

```python
# NetworkX
import networkx as nx
G = nx.DiGraph()
G.add_weighted_edges_from(activities)  # [(from, to, weight), ...]
# 关键路径需手动实现拓扑递推
order = list(nx.topological_sort(G))
# ES 正向
ES = {n: 0 for n in G.nodes()}
for u in order:
    for v in G[u]:
        ES[v] = max(ES[v], ES[u] + G[u][v]['weight'])
```

## 选型决策树

- **CPM** — 工期确定，需求关键路径和时差分析
- **PERT (Program Evaluation and Review Technique)** — 工期不确定 (三点估计: 乐观/最可能/悲观)，需求完工概率分布 → Beta 分布 + 期望工期
- **Gantt Chart** — 可视化时间计划，但无法自动识别关键路径
- **CPM + 资源约束 → RCPSP** — 引入资源限制后成为 NP-hard 资源约束项目调度问题，需用遗传算法/优先规则启发式

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | AOE 网有向图 (边权重=工期) | 标注 ES/LS |
| process | 正向递推动态表 (节点×ES) | 表格或热力图 |
| result | 关键路径加粗高亮 + Gantt 图 | 红色=关键, 灰色=非关键 |

## 常见坑

1. **AOE 网必须无环**: 工序依赖构成环路说明定义有误，需先做拓扑排序检测环
2. **CPM 假设资源无限**: 现实中资源冲突可能导致关键路径偏移，需说明模型假设
3. **并行工序的关键性传播**: 多条关键路径并存时，压缩单条不缩短工期，需同步压缩所有关键路径

## 失效条件/反例 (强制小节)

- **条件1: 工期高度不确定 (方差大)** → 表现: CPM 确定性分析给出的关键路径在随机扰动下可能不是真正的"关键" — 另一条总时差稍大的路径因方差更大而更可能成为"大概率关键路径"。**应对**: 改用 PERT 三点估计或蒙特卡洛模拟 (PERT + Monte Carlo)
- **条件2: 引入资源约束 (RCPSP)** → 表现: 标准 CPM 在资源不足时给出的工期不可实现 — 两道并行的关键工序抢占同一资源时，实际需要串行执行导致工期延长。**应对**: 资源约束项目调度问题用优先规则启发式或遗传算法

## 文献

1. Kelley J.E. & Walker M.R. (1959). "Critical-path planning and scheduling." *Proceedings of the Eastern Joint Computer Conference*, 160-173. DOI: [10.1145/1460299.1460318](https://doi.org/10.1145/1460299.1460318)
2. Moder J.J., Phillips C.R. & Davis E.W. (1983). *Project Management with CPM, PERT and Precedence Diagramming*, 3rd ed. Van Nostrand Reinhold. ISBN: 978-0442254155

## 来源溯源

自写 cpm.m; 运筹学教材项目管理章节

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0401 (Dijkstra) |
| 组合 (不确定工期) | PARADIGM-0705 (Bootstrap) |
| 组合 (资源优化) | PARADIGM-0105 (GA) |
