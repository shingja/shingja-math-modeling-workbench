# PARADIGM-0114 禁忌搜索 (Tabu Search)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0114 |
| 类别/子类 | ①优化 / 元启发式 |
| 难度 | 中 |
| 适用题型关键词[] | 禁忌搜索, Tabu列表, 禁忌长度, 藐视准则, 邻域搜索, 集中搜索, 分散搜索, TSP, VRP, 调度, 排课, 图着色, 二次分配, 频率记忆, 长期记忆, 路径重连 |
| confidence | medium |
| source | Glover (1989), Tabu Search — Part I, ORSA Journal on Computing |

## 数学形式

禁忌搜索是确定性元启发式, 核心思想是: 使用自适应记忆 (Tabu 列表) 引导邻域搜索, 禁止重复访问近期探索过的解, 从而逃脱局部最优.

**基础框架**:

1. **初始化解** $\mathbf{x}_0$ → 当前解 $\mathbf{x} = \mathbf{x}_0$, 最优解 $\mathbf{x}^* = \mathbf{x}_0$

2. **邻域生成**: 生成当前解的邻域 $\mathcal{N}(\mathbf{x}) = \{\mathbf{x}_1', \mathbf{x}_2', \ldots, \mathbf{x}_k'\}$

3. **最优允许移动**: 从 $\mathcal{N}(\mathbf{x})$ 中选择:
   - 不在 Tabu 列表中的最佳候选解
   - 或满足 **藐视准则 (Aspiration Criterion)** 的候选解, 即使它在 Tabu 列表中

4. **移动执行**: $\mathbf{x} \leftarrow \mathbf{x}_{best\_allowed}$; 更新最优解 $\mathbf{x}^*$

5. **Tabu 更新**: 将执行的移动 (或移动的逆) 加入 Tabu 列表 (FIFO 队列), 固定长度 $L$

**Tabu 列表管理**:

- **形式**: FIFO 队列, 容量 = $L$ (禁忌长度)
- **Tabu 任期 (Tenure)**: 每个 Tabu 移动在 "刑期" 满后自动移除
- **记录内容**: 可记录 (a) 完整的访问解 (内存大) (b) 移动的属性 (如 TSP 中加入 Tabu 的边) (c) 目标函数值的变化

**藐视准则 (Aspiration Criterion)**:

若 Tabu 列表中的候选解 $\mathbf{x}'$ 满足:
$$f(\mathbf{x}') < f(\mathbf{x}^*) \quad (\text{比已知最优解更好})$$

则忽略其 Tabu 状态, 允许执行此移动. 这防止 Tabu 列表 "错误地" 禁止了通往全局最优的路径.

**频率记忆 (Frequency-Based Memory)**:

- **短期记忆**: Tabu 列表 — 避免循环 (最近 $L$ 步)
- **长期记忆**: (a) **转移频率** — 记录每对 $(s, a)$ 转移次数, 惩罚频繁出现的移动 (分散搜索) (b) **驻留频率** — 记录解成分被选择的频率, 奖励低频成分 (集中搜索)

**分散搜索 (Diversification)**: 当搜索停滞时, 利用长期记忆生成远离当前搜索区域的新起点. 常见策略: 选择低频转移对应的边/移动构造新解.

**路径重连 (Path Relinking)**: 在精英解之间构造路径, 沿路径搜索更优解. 从引导解 $\mathbf{x}_{guide}$ 反向生成通向初始解 $\mathbf{x}_{init}$ 的中间解.

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| TabuLength ($L$) | int | 7 | 3~sqrt(n)~50 | **极高**: 过短循环, 过长限制搜索 |
| MaximIter | int | 1000 | 200~10000 | 高 |
| NeighborhoodSize | int | 50 | 10~500 | 高: 影响每步搜索质量 |
| AspirationEnabled | bool | true | true\|false | 高: 不开可能错失全局最优 |
| DiversificationTrigger | int | 50 (无改进步数) | 20~200 | 中: 触发分散搜索 |
| LongTermMemoryWeight | double | 0.1 | 0~0.5 | 中: 频率惩罚强度 |

**时间复杂度**: 每迭代 $O(k \times C)$, $k$ 为邻域大小, $C$ 为单次评估.
**Tabu 列表操作**: $O(1)$ 带哈希或 $O(L)$ 线性扫描.
**空间复杂度**: $O(L \times m)$, $m$ 为每条 Tabu 记录的存储开销.

## MATLAB 实现

```matlab
% === 自写-见S5:tabu_search.m ===
% 通用禁忌搜索框架 (组合优化)

function [best_x, best_f, trace] = tabu_search(cost_fun, init_fun, ...
                                                neighbor_fun, tabu_tenure, max_iter, opts)
% tabu_search - 禁忌搜索求解器
%
% 输入:
%   cost_fun     - @(x) 代价函数
%   init_fun     - @() 初始解生成器
%   neighbor_fun - @(x) 邻域生成, 返回 {x1, x2, ...} cell
%   tabu_tenure  - 禁忌长度
%   max_iter     - 最大迭代次数
%   opts         - 选项 (aspiration, diversification, etc.)
%
% 输出:
%   best_x - 最优解
%   best_f - 最优值
%   trace  - 收敛轨迹

% 解编码: 问题相关 — 排列 vector (TSP) | 指标向量 (指派) | 0-1 vector (背包)

% 初始化
current_x = init_fun();
current_f = cost_fun(current_x);
best_x = current_x;
best_f = current_f;

% Tabu 列表 — 存储禁止的移动属性
% 对 TSP: 存储 (city_i, city_j) 交换对被禁止
tabu_list = {};           % cell array 存储 tabu 条目
tabu_iter = [];           % 对应的进入迭代号

trace = zeros(max_iter, 2);  % [iter, best_f]

for iter = 1:max_iter
    % 1. 生成邻域
    neighbors = neighbor_fun(current_x);
    n_neighbors = length(neighbors);

    % 2. 评估邻域并选择最优允许移动
    best_candidate_f = inf;
    best_candidate_idx = 1;
    best_candidate_tabu = false;

    for i = 1:n_neighbors
        cand_f = cost_fun(neighbors{i});

        % 检查是否在 Tabu 列表中
        is_tabu = check_tabu(neighbors{i}, tabu_list);

        % 藐视准则: 即使 tabu, 若比历史最优更好则接受
        if is_tabu && (opts.aspiration && cand_f < best_f)
            is_tabu = false;  % 藐视!
        end

        if ~is_tabu && cand_f < best_candidate_f
            best_candidate_f = cand_f;
            best_candidate_idx = i;
        end
    end

    % 3. 执行移动
    current_x = neighbors{best_candidate_idx};
    current_f = best_candidate_f;

    % 4. 更新全局最优
    if current_f < best_f
        best_f = current_f;
        best_x = current_x;
    end

    % 5. Tabu 列表更新
    move_attr = extract_move_attribute(current_x, neighbors{best_candidate_idx});
    tabu_list{end+1} = move_attr;
    tabu_iter(end+1) = iter;

    % 6. Tabu 任期管理: 移除过期条目
    expired = tabu_iter < (iter - tabu_tenure);
    tabu_list(expired) = [];
    tabu_iter(expired) = [];

    % 7. 分散搜索触发 (如果长期无改善)
    if (iter - last_improve_iter) > opts.DiversificationTrigger
        current_x = diversification_restart(init_fun, tabu_list);
        current_f = cost_fun(current_x);
        last_improve_iter = iter;
    end

    trace(iter, :) = [iter, best_f];
end
end

function is_tabu = check_tabu(x, tabu_list)
    % 检查 x 的移动属性是否在 Tabu 列表中
    % 依赖于问题编码的哈希/匹配逻辑
    is_tabu = false;
    % ... 问题相关实现
end

function attr = extract_move_attribute(from_x, to_x)
    % 抽取移动的属性特征用于 Tabu 记录
    % 例如 TSP: 记录了哪些边被移除
    attr = struct();
    % ... 问题相关实现
end
```

## Python 备选

```python
import numpy as np
from collections import deque

# 完整实现在 S5: tabu_search.py

def tabu_search(cost_fun, init_fun, neighbor_fun, tabu_tenure=7, max_iter=1000):
    """禁忌搜索 Python 实现

    核心数据结构: deque 作为 Tabu 列表 (FIFO)
    """
    current_x = init_fun()
    current_f = cost_fun(current_x)
    best_x, best_f = current_x, current_f

    tabu_list = deque(maxlen=tabu_tenure)  # 自动 FIFO

    for it in range(max_iter):
        neighbors = neighbor_fun(current_x)
        best_cand_f, best_cand = float('inf'), None

        for cand in neighbors:
            cand_f = cost_fun(cand)
            is_tabu = hasattr_tabu(cand, tabu_list)
            if is_tabu and cand_f < best_f:  # 藐视准则
                is_tabu = False
            if not is_tabu and cand_f < best_cand_f:
                best_cand_f, best_cand = cand_f, cand

        if best_cand is None:  # 全部 Tabu 且不满足藐视准则
            break

        current_x, current_f = best_cand, best_cand_f
        tabu_list.append(extract_attr(current_x))

        if current_f < best_f:
            best_x, best_f = current_x, current_f

    return best_x, best_f

# 禁忌搜索的 Python 库较少 — 通常自实现
# OR-Tools 的路由求解器内部使用了 TS 思想
```

## 选型决策树

```
问题是否有自然邻域结构?
├─ 否 → TS 不适用 (TS 依赖邻域搜索), 考虑 GA/PSO
└─ 是 → 邻域大小能否控制在 ≤ 1000?
    ├─ 否 → 每步搜索邻域不可行, 考虑 SA 或采样子集
    └─ 是 → 组合优化类型?
        ├─ TSP / VRP / 路径 → TS 最佳选择之一
        ├─ 调度 / 排程 → TS 竞争性强, 与 GA 相当
        ├─ 图着色 / 分区 → TS 有效, 邻域定义直观
        ├─ 二次分配 (QAP) → TS 经典应用, 推荐
        └─ 连续优化 → TS 不适用 (邻域难以定义)
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 收敛过程 | Best-so-far vs 迭代 (semilogy) | TS 曲线通常平稳下降, 跳跃幅度小 |
| 搜索行为 | 目标值 vs 迭代 (散点叠加 Tabu 标注) | 无色点=接受, 红色点=被Tabu禁止 |
| Tabu 诊断 | Tabu 列表长度变化 | 验证 Tabu 任期是否合适 |
| 频率记忆 | 转移频率热力图 | 展示哪些移动频繁出现/被过度忽略 |
| 分散搜索 | 目标值轨迹 + 分散重启点标记 | 展示长期记忆的效果 |

## 常见坑

1. **禁忌长度 $L$ 设置不当**: 过短 ($L \leq 3$) → 无法防止循环: 解在局部最优附近 3-4 个解之间循环振荡. 过长 ($L \geq n/2$) → 几乎每次都找不到允许移动 (全部 Tabu), 搜索停滞. 对策: $L = 7$ 为经验默认值; 对于大规模问题, $L \approx \sqrt{n}$; 也可使用动态 $L$ — 在 $[L_{\min}, L_{\max}]$ 间周期变动
2. **邻域过大导致每步搜索不可行**: 全邻域评估的复杂度随问题规模呈 $O(n^2)$ 或更高扫描. 例如 TSP 的 2-opt 邻域大小 $\approx n^2/2$, $n=1000$ 时每步评估 500,000 个邻域. 对策: 采样子集 (如随机 100 个邻域) 或使用候选列表 (candidate list) 限制边数量
3. **未实现藐视准则**: 没有藐视准则时 Tabu 可能禁止了通往全局最优的唯一步骤. 判断: 实现基本 TS 和带藐视 TS, 对比最优值; 若后者显著更优 (> 10%), 藐视准则不可或缺
4. **移动作表过大**: 直接禁忌完整解 (f(x) 的哈希值) 效率极低 — 第一需要存储大量历史解, 第二哈希碰撞可能误判 Tabu. 对策: 禁忌移动属性而非完整解
5. **连续优化中误用**: TS 天然适合离散/组合优化. 连续优化中 "邻域" 大小难定义、Tabu 列表无意义. 强制使用 TS 连续优化性能远低于 PSO/CMA-ES

## 失效条件/反例 (强制小节)

- **条件1: 禁忌长度过短导致搜索循环 — TS 退化为受限贪心**. 当 $L$ 小于局部最优吸引盆中的移动步数时, TS 无法打破循环. 典型场景: **平面 TSP 100 城市, $L=3$** — 当搜索进入一个局部最优配置 (如矩形排列), 需要至少 4 步 2-opt 交换才能跳出; $L=3$ 的 Tabu 在 3 步后即 "忘记" 了初始移动, 搜索在第 4 步回到原点, 永久循环. 判别: 观察 `trace` 中 best_f 在最后 300 次迭代中是否 "永远" 不改善 (下降停滞). 同时检查邻域的 visited 模式是否出现周期性 (第 i 步与第 i-k 步相同). 对策: (a) 增大 $L$ 到 $\sqrt{n}$ 或更高 (b) 引入动态禁忌长度: $L = L_{\min} + \text{randint}(0, \Delta L)$ 每迭代随机微调, 打破确定性循环 (c) 用长期频率记忆惩罚频繁转移.

- **条件2: 邻域过大导致每迭代计算不可行 — 单步搜索时间超过可接受阈值**. 全邻域评估是禁忌搜索的标准做法, 但对大规模问题不可行. 典型场景: **VRP 500 客户** — 2-opt 邻域 $\approx C(500,2) = 124,750$, 每步评估全部约 12 秒; 1000 次迭代 = 12000 秒 (3.3 小时). 若竞赛期限 3 天 (72h), TS 单次运行占 12.5% 的时间, 无法承受. 判别: 运行前 10 步, 估算平均单步时间 $\times$ MaxIter. 若 > 30 min, TS 不可直接使用. 对策: (a) 对邻域随机采样 — 每步只评估 50~200 个随机邻域 (b) 候选列表 — 对 TSP 只考虑最近的 20 个邻居 (c) 增量评估 — 利用问题的结构, 只在上一解基础上评估变化的边, 避免重新评估整个解.

- **条件3: 连续优化/非组合问题 — 禁忌搜索完全不适用**. TS 基于离散邻域结构的定义, Tabu 机制依赖可计数的移动属性. 在连续优化中, "邻域" = $[x-\epsilon, x+\epsilon]$, 有无穷多个候选, Tabu 列表无法区分. 典型场景: **非线性函数优化** $\min f(x_1, x_2) = x_1^2 + x_2^2 + \sin(x_1 x_2)$, 试图用 TS: 将连续变量离散化为网格 (步长 $\delta=0.1$), 但网格点太多 ($50/0.1=500$ 点/维, 总状态 $\approx 2.5\times10^5$), TS 邻域生成和 Tabu 管理均崩溃. 判别: 是否有连续变量且不能被自然离散化. 对策: 换用 PARADIGM-0105 (GA) 或 PARADIGM-0106 (PSO) 处理连续优化. 仅对 TSP/VRP/调度/图着色/二次分配等组合优化使用 TS.

## 文献

1. Glover, F. (1989). "Tabu Search — Part I". *ORSA Journal on Computing*, 1(3), 190-206. — TS 开创性论文
2. Glover, F. (1990). "Tabu Search — Part II". *ORSA Journal on Computing*, 2(1), 4-32. — 进阶主题: 长期记忆/路径重连
3. Glover, F. & Laguna, M. (1997). *Tabu Search*. Kluwer Academic. — TS 全面教材
4. Gendreau, M. & Potvin, J.Y. (2019). *Handbook of Metaheuristics*, 3rd ed. Springer. Ch.2 — TS 系统综述

## 来源溯源

- Glover (1977) 在决策分析中提出 "禁忌搜索" 概念雏形; 1986 年美国空军资助项目中首次实现 TS
- Glover (1989-1990) ORSA Journal 两篇论文奠定 TS 理论基础
- Glover & Laguna (1997) 专著系统化 TS, 引入路径重连
- Cordeau & Laporte (2003) 将 TS 成功用于 VRP — 成为 VRP 最常用启发式之一
- TS 在 VRP/TSP/QAP 领域被广泛认可, 但在数学建模竞赛中使用率低于 GA/PSO (因实现复杂度较高)

## 关联范式卡

| 关系 | ID |
|------|-----|
| 互补 — 同为邻域搜索元启发式 | PARADIGM-0109 (SA) |
| 替代 — 进化计算替代 | PARADIGM-0105 (GA) |
| 替代 — 群智能替代 | PARADIGM-0106 (PSO) |
| 替代 — 多模态优化替代 | PARADIGM-0111 (IA) |
| 前置 — TSP 精确解 | PARADIGM-0102 (intlinprog — 小规模 TSP 的 MILP) |
