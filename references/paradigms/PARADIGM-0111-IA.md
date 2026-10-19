# PARADIGM-0111 免疫算法 (Immune Algorithm)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0111 |
| 类别/子类 | ①优化 / 人工免疫 |
| 难度 | 高 |
| 适用题型关键词[] | 免疫算法, 克隆选择, 亲和力成熟, 阴性选择, 危险理论, 人工免疫系统, 多模态优化, 抗原识别, 抗体, 免疫记忆, 疫苗算子, 异常检测, 模式识别 |
| confidence | low |
| source | de Castro & Timmis (2002), Artificial Immune Systems, Springer |

## 数学形式

免疫算法受生物免疫系统启发, 模拟抗体识别和清除抗原的过程.

**核心理念对照**:
| 生物免疫 | 优化问题 |
|---------|---------|
| 抗原 (Antigen) | 目标问题/目标函数 |
| 抗体 (Antibody) | 候选解 $\mathbf{x}$ |
| 亲和力 (Affinity) | 适应度/目标函数值的映射 |
| B细胞克隆 | 在好解附近生成更多搜索点 |
| 超变异 (Hypermutation) | 高亲和力抗体变异率低, 低亲和力抗体变异率高 |
| 免疫记忆 | 精英保留, 维护最优解集合 |

**克隆选择算法 (CLONALG) 主流程**:

1. **初始化**: 随机生成抗体种群 $\mathcal{P} = \{\mathbf{x}_1, \ldots, \mathbf{x}_N\}$

2. **亲和力评估**: 对每个抗体计算 $aff(\mathbf{x}_i) = -f(\mathbf{x}_i)$ (最大化亲和力 = 最小化目标)

3. **克隆选择**: 按亲和力排序, 选前 $n_{select}$ 个最优抗体进入克隆池

4. **克隆增殖**: 抗体 $i$ 的克隆数与其归一化亲和力成正比:
   $$N_i^{clone} = \text{round}\left(\beta \cdot N \cdot \frac{aff_i}{\sum_{j=1}^{n_{select}} aff_j}\right)$$

   其中 $\beta$ 为克隆规模因子, 典型值 0.1~0.5.

5. **超变异 (Somatic Hypermutation)**: 对克隆体进行变异, 变异率与亲和力成反比:
   $$\alpha_i = \exp(-\rho \cdot \hat{aff}_i)$$

   其中 $\hat{aff}_i$ 为归一化亲和力, $\rho$ 为衰减参数. 高亲和力 → 小变异 (精细搜索), 低亲和力 → 大变异 (探索).

   变异算子: $\mathbf{x}' = \mathbf{x} + \alpha_i \cdot \mathcal{N}(0, 1) \cdot (\mathbf{ub} - \mathbf{lb})$

6. **免疫记忆更新**: 将变异后的最优抗体加入记忆集 $\mathcal{M}$, 淘汰旧记忆细胞

7. **多样性维持**: 随机生成新抗体补充种群, 替代低亲和力抗体

**阴性选择算法** (用于异常检测, 非优化):

生成检测器集 $\mathcal{D}$, 对每个检测器 $\mathbf{d}$, 若它匹配任何自身样本 (self), 则淘汰. 剩余检测器用于识别非己 (non-self / 异常).

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| PopSize | int | 100 | 50~300 | 高 |
| NumSelect | int | ceil(0.3$\times$PopSize) | 克隆选择数量 | 高: 太小失去多样性 |
| CloneFactor ($\beta$) | double | 0.3 | 0.1~1.0 | **极高**: 直接决定克隆总数 |
| HypermutationRho ($\rho$) | double | 5.0 | 1~20 | 高: 太大变异过小, 太小变异过大 |
| ReplacementRate | double | 0.2 | 0.05~0.5 | 中: 控制新鲜血液比例 |
| MemorySize | int | ceil(0.1$\times$PopSize) | 记忆集大小 | 中 |
| MaxGenerations | int | 300 | 100~2000 | 高 |
| StallGenLimit | int | 50 | 15~100 | 中 |

**时间复杂度**: 每代 $O(N + N^{clone} \times C)$, $N^{clone}$ 为克隆总数. 由于克隆增殖, IA 的单代计算开销比 GA 大约 3~10 倍.

## MATLAB 实现

```matlab
% === 自写-见S5:immune_algorithm.m ===
% 克隆选择免疫算法

function [best_x, best_f, trace] = immune_algorithm(fun, nvars, lb, ub, opts)
% immune_algorithm - 克隆选择免疫优化算法
%
% 输入:
%   fun   - @(x) 目标函数句柄 (最小化)
%   nvars - 决策变量维数
%   lb    - 下界 1xnvars
%   ub    - 上界 1xnvars
%   opts  - 选项结构体 (PopSize, MaxGen, CloneFactor, Rho, ...)
%
% 输出:
%   best_x - 最优抗体
%   best_f - 最优目标值
%   trace  - 收敛轨迹 [gen, best_f, mean_f, diversity]

% 参数提取
PopSize   = getfield(opts, 'PopSize', 100);
MaxGen    = getfield(opts, 'MaxGen', 300);
nSelect   = getfield(opts, 'NumSelect', ceil(0.3*PopSize));
beta      = getfield(opts, 'CloneFactor', 0.3);
rho       = getfield(opts, 'HypermutationRho', 5.0);
replRate  = getfield(opts, 'ReplacementRate', 0.2);
memSize   = getfield(opts, 'MemorySize', ceil(0.1*PopSize));

% 初始化种群 (实数编码)
pop = rand(PopSize, nvars) .* (ub - lb) + lb;
fit = zeros(PopSize, 1);
for i = 1:PopSize
    fit(i) = fun(pop(i,:));
end

memory_x = [];   % 免疫记忆集
memory_f = [];
trace = zeros(MaxGen, 4);

for gen = 1:MaxGen
    % 1. 亲和力计算 (归一化到 [0,1], 0=最优)
    aff = 1 ./ (1 + fit);  % 适应度越高亲和力越大
    aff_norm = (aff - min(aff)) / (max(aff) - min(aff) + eps);

    % 2. 克隆选择: 选亲和力最高的 nSelect 个抗体
    [~, idx] = sort(fit);
    selected = pop(idx(1:nSelect), :);
    selected_f = fit(idx(1:nSelect));
    selected_aff = aff(idx(1:nSelect));

    % 3. 克隆增殖: 亲和力高的克隆更多
    clone_factors = round(beta * PopSize * selected_aff / sum(selected_aff));
    clone_factors(clone_factors < 1) = 1;  % 至少保留一个

    clones = [];
    for i = 1:nSelect
        n_clones = clone_factors(i);
        clones_i = repmat(selected(i,:), n_clones, 1);
        % 4. 超变异: 亲和力反比变异率
        alpha_i = exp(-rho * aff_norm(idx(i)));  % 高亲和力 → 小变异
        noise = alpha_i * randn(n_clones, nvars) .* (ub - lb) * 0.1;
        clones_i = clones_i + noise;
        clones_i = max(min(clones_i, ub), lb);  % 边界裁剪
        clones = [clones; clones_i];
    end

    % 5. 评估克隆体
    n_clones_tot = size(clones, 1);
    clone_fit = zeros(n_clones_tot, 1);
    for i = 1:n_clones_tot
        clone_fit(i) = fun(clones(i,:));
    end

    % 6. 更新免疫记忆
    all_x = [pop; clones; memory_x];
    all_f = [fit; clone_fit; memory_f];
    [sorted_f, sorted_idx] = sort(all_f);
    memory_x = all_x(sorted_idx(1:memSize), :);
    memory_f = sorted_f(1:memSize);

    % 7. 种群更新 + 多样性注入
    pop = all_x(sorted_idx(1:PopSize*(1-replRate)), :);
    % 随机生成新抗体替换最差的
    n_new = ceil(PopSize * replRate);
    new_pop = rand(n_new, nvars) .* (ub - lb) + lb;
    pop = [pop(1:PopSize-n_new, :); new_pop];

    % 评估新种群
    for i = 1:PopSize
        fit(i) = fun(pop(i,:));
    end

    best_f = min(fit);
    % 记录轨迹: [代, 最优值, 均值, 种群多样性(标准差)]
    trace(gen, :) = [gen, best_f, mean(fit), mean(std(pop))];
end

best_x = memory_x(1,:);
best_f = memory_f(1);
end
```

## Python 备选

```python
import numpy as np

# 完整实现在 S5: immune_algorithm.py
# 核心结构同上 MATLAB 版本

def immune_algorithm(fun, nvars, lb, ub, pop_size=100, max_gen=300):
    """克隆选择免疫算法 — Python 实现

    关键: 每代克隆计算开销约为 GA 的 5~10 倍.
    仅当需要多模态解或多个多样化解时推荐使用.
    """
    # ... (完整代码见 S5)
    pass

# scikit-opt 有简化版 IA 实现
# from sko.IA import IA
```

## 选型决策树

```
是否需要多个不同最优解 (多模态)?
├─ 是 → IA 的免疫记忆机制天然支持, 优于 GA/PSO 的单最优
└─ 否 → 是否需要迭代中维持解集合的高多样性 (niching)?
    ├─ 是 → IA 或 多群 GA (island model)
    └─ 否 → 其他算法 (GA/PSO/SA) 通常计算效率更高
是否已有先验知识 (疫苗)?
├─ 是 → IA 可编码为 "疫苗算子" 注入初始种群, 加速收敛
└─ 否 → 常规初始化
计算预算?
├─ 充裕 (>50000 评估) → IA 可行
└─ 紧张 (<10000 评估) → 不要用 IA, 选 GA 或 PSO
```

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| 亲和力分布 | 抗体亲和力分布直方图 (各代) | 监控亲和力成熟过程 — 峰值右移 |
| 收敛过程 | 最优/均值亲和力 vs 代数 | 与 GA 的 Best/Mean 收敛图类似 |
| 多样性 | 记忆集大小 + 种群标准差距时间 | 免疫记忆维持的多样性量化 |
| 多模态 | 多个记忆细胞在解空间散点图 | IA 特有 — 展示收敛到的多个峰 |
| 克隆规模 | 各亲和力等级的克隆数饼图 | 展示搜索资源的分配策略 |

## 常见坑

1. **计算开销极大**: 克隆增殖 + 超变异导致每代函数评估数远超 GA. 经验值: IA 一代 $\approx$ GA 5-10 代的计算量. 务必监控 `funccount` 而非 `generations`
2. **参数耦合严重**: 克隆因子 $\beta$、超变异衰减 $\rho$、选择比例、替换率四个参数相互作用, 参数不当导致无法收敛或不探索. 对策: 先用默认值 $\beta=0.3, \rho=5$, 再逐步调优
3. **亲和力归一化不稳定**: 当种群中所有个体适应度接近时, 分母 $\to 0$ 导致数值问题. 对策: `aff_norm = (aff - min(aff)) / (max(aff) - min(aff) + eps)`
4. **免疫记忆集过大**: 记忆集维持太大导致种群多样性丧失 (记忆集占据了所有 "精英名额"). 对策: `MemorySize <= 0.15 * PopSize`
5. **阴性选择误用**: 阴性选择算法本质是异常检测分类器, 不是优化器. 勿用它做函数优化

## 失效条件/反例 (强制小节)

- **条件1: 计算预算不足 — 克隆增殖导致评估量指数增长, IA 尚未收敛即耗尽预算**. 克隆因子 $\beta=0.3$ 下, $N=100, n_{select}=30$, 总克隆数 $\approx 30 \times 10 = 300$ (每抗体平均 10 个克隆). 加上原始种群评估, 每代约 400 次评估. 若 MaxGen=300, 总评估 = 120,000 次. 典型场景: **20 维参数标定**, 单次评估 0.5s (ODE 仿真), IA 需 120,000 次评估 = 16.7 小时, 竞赛场景不可接受. 判别: 预计评估数 = PopSize $\times$ (1 + CloneFactor $\times$ NumSelect $\times$ 平均克隆数) $\times$ MaxGen. 若 > 20000 评估目预算紧张, IA 不可行. 对策: 减少 CloneFactor 到 0.1 以下, 缩减小 MaxGen 到 100, 或换用 GA/PSO (每代评估数为 PopSize, 计算量小一个数量级).

- **条件2: 参数设置不当导致 IA 退化为随机搜索或贪心 — 失去免疫特色**. 当超变异衰减参数 $\rho$ 过小 (如 $\rho=0.1$) 时, $\alpha_i = \exp(-0.1 \times \hat{aff}_i) \approx 1$, 所有抗体接受相同程度的强变异, 等价于 (克隆 + 随机搜索). 当 $\rho$ 过大 (如 $\rho=20$) 时, $\alpha_i \approx 0$, 克隆体几乎不变异, 等价于精英多重复制, 多样性瞬间丧失. 典型场景: $\rho=0.1$ 时, IA 在 100 代的改善仅靠随机 hit, 不如随机重启贪心; $\rho=20$ 时, IA 收敛到初始种群最优值后不再改善. 判别: 检查各亲和力等级的超变异率 — 最高亲和力的变异率应在 $10^{-3}\sim10^{-2}$ 量级, 最低亲和力 $10^{-1}\sim10^{0}$ 量级. 对策: $\rho$ 值应在 [2, 10] 范围内, 推荐计算 $\rho$ 使得 $\exp(-\rho \times 1.0) = 0.01$ → $\rho \approx 4.6$.

- **条件3: 缺乏先验知识时 IA 相对于 GA/PSO 无明显优势 — 仅增加复杂度**. 在绝大多数单目标连续优化基准上 (Rastrigin, Ackley, Rosenbrock, Sphere), IA 的最优解质量和收敛速度与 GA/PSO 无统计显著差别, 但实现复杂度高出 2-3 倍. 典型场景: **数学建模竞赛中 10 维以内连续优化**, 使用 GA 或 PSO 在 100 行内完成; IA 需要约 200 行实现, 增加出错概率, 调试时间增加一倍, 且结论相同. 判别: 对比 IA vs GA 在小规模测试函数上的结果; 若 30 次试验效果无统计显著优势 (t-test p > 0.05), IA 不值得. 对策: 仅当 (a) 需要多个全局/局部最优解 (b) 已有先验可编码为疫苗 (c) 需要异常检测 (阴性选择) 时使用 IA.

## 文献

1. de Castro, L.N. & Timmis, J. (2002). *Artificial Immune Systems: A New Computational Intelligence Approach*. Springer. — 人工免疫系统经典教材
2. de Castro, L.N. & Von Zuben, F.J. (2002). "Learning and Optimization Using the Clonal Selection Principle". *IEEE Trans. Evolutionary Computation*, 6(3), 239-251. — CLONALG 算法论文
3. Dasgupta, D. & Nino, L.F. (2008). *Immunological Computation: Theory and Applications*. CRC Press.
4. Forrest, S., Perelson, A.S., Allen, L., & Cherukuri, R. (1994). "Self-Nonself Discrimination in a Computer". *IEEE Symp. Security and Privacy*. — 阴性选择算法 (用于入侵检测)

## 来源溯源

- Farmer, Packard & Perelson (1986) 首次将免疫网络理论引入计算 → Bersini & Varela (1990) 首次免疫算法
- Forrest et al. (1994) 阴性选择算法 (计算机安全) → de Castro & Von Zuben (2002) CLONALG (优化)
- 危险理论: Matzinger (1994) 免疫学 → Aickelin et al. (2002) 危险理论算法 (DCA)
- 数学建模中 IA 使用率低 (< 5%), 多数场景被 GA/PSO 替代

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 — 通常计算效率更高 | PARADIGM-0105 (GA) |
| 替代 — 通常收敛更快 | PARADIGM-0106 (PSO) |
| 替代 — 组合优化替代 | PARADIGM-0109 (SA) |
| 互补 — 多目标可结合 | gamultiobj (免疫记忆维持多样性) |
| 互补 — 异常检测场景 | 阴性选择作为分类器 (非优化) |
