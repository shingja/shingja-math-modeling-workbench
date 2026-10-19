# PARADIGM-0603 隔离森林 (Isolation Forest)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0603 |
| 类别/子类 | ⑥机器学习 / 异常检测 |
| 难度 | 中 |
| 适用题型关键词[] | Isolation Forest, 隔离森林, 异常检测, 无监督, 路径长度, 异常分数, 离群点检测, 异常值识别, 欺诈检测, novelty detection |
| confidence | medium |
| source | Liu et al. (2008) ICDM; 自写-见S5:isolation_forest.m |

## 数学形式

**核心思想**: 异常点"少而不同"——容易通过随机分割被隔离 (深度浅)，而正常点需要更多分割才能隔离 (深度深)。

**iTree (Isolation Tree) 的构造**:

在给定数据集 $\mathcal{D}$ 上递归构建二叉树:

1. 若满足停止条件 (深度达上限 $h_{\max} = \lceil \log_2 n \rceil$ 或 $|\mathcal{D}| \leq 1$)，返回叶节点。
2. 随机选择一个特征 $q \in \{1, 2, \ldots, p\}$。
3. 随机选择一个分割点 $p \in [\min_q(\mathcal{D}), \max_q(\mathcal{D}))$。
4. 左子树: $\mathcal{D}_L = \{\mathbf{x} \in \mathcal{D} \mid x_q < p\}$; 右子树: $\mathcal{D}_R = \{\mathbf{x} \in \mathcal{D} \mid x_q \geq p\}$。
5. 递归构建左右子树。

**路径长度 $h(\mathbf{x})$**: 从根节点到 $\mathbf{x}$ 所在叶节点经过的边数。

**异常分数** ($s \in [0, 1]$, $s \to 1$ 表示异常):

$$s(\mathbf{x}, n) = 2^{-\frac{E[h(\mathbf{x})]}{c(n)}}$$

其中:
- $E[h(\mathbf{x})]$ 为 $\mathbf{x}$ 在所有 iTree 中的平均路径长度
- $c(n)$ 为二叉搜索树中不成功搜索的平均路径长度 (归一化常数):

$$c(n) = 2H(n-1) - \frac{2(n-1)}{n}$$

其中 $H(i) \approx \ln(i) + 0.5772156649$ (欧拉常数) 为调和数。

**异常判据**:
$$s(\mathbf{x}, n) \begin{cases}
\to 1 & \text{异常 (路径极短)} \\
\approx 0.5 & \text{正常 (路径接近平均)} \\
\to 0 & \text{极正常 (路径极长, 可能为异常簇中心)}
\end{cases}$$

**子采样 (subsampling) 策略**:

每棵 iTree 在随机的子样本 $\psi \ll n$ 上训练 (默认 $\psi = 256$)。子采样有两个作用:
1. 减少训练时间和内存
2. 防止 swamp (正常点过多掩盖异常信号) 和 masking (异常点过多互相掩盖) 效应

**时间复杂度**: 训练 $O(t \cdot \psi \cdot \log \psi)$; 预测 $O(t \cdot \log \psi)$; $t$ 为 iTree 数量。

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| t (num_trees) | int | 100 | [10, 500] | 低 — >100 后分数稳定，训练时间线性增加 |
| ψ (subsample_size) | int | 256 | [64, n] | 中 — 太小则树稳定性差；太大则 swamp/masking 效应增加，训练也变慢 |
| contamination | float | 0.1 | (0, 0.5) | 高 — 决定异常分数阈值，直接影响检出率/误报率 |
| h_max (max_depth) | int | ceil(log₂ ψ) | [1, ψ] | 低 — 默认值几乎是理论最优 |
| p (特征数) | int | — | [1, ∞) | 中 — 高维时随机选择特征多样化，但信号特征被稀释 |
| n (总样本量) | int | — | [1, ∞) | 低 — 子采样 ψ 固定为 256 时对 n 不敏感 |

| 输出 | 量纲 |
|------|------|
| anomaly_score | [0, 1] 无量纲 — 越大越异常 |
| is_outlier | {0, 1} 布尔型 — 基于 contamination 阈值 |
| avg_path_length | 树深层级数 — 原始路径长度 (调试用) |

**计算复杂度**: 训练 $O(t \cdot \psi \cdot \log \psi) \approx O(100 \times 256 \times 8) \approx 2 \times 10^5$ 操作，秒级完成。预测同理。内存 $O(t \cdot \psi)$。

## MATLAB 实现

**自写-见S5:isolation_forest.m** (MATLAB 无原生 Isolation Forest 工具箱，需自行实现 iTree 构建和异常分数计算)。

```matlab
% 核心函数签名
function [scores, trees] = isolation_forest(X, num_trees, subsample_size)
% INPUT:
%   X              - n×p 数据矩阵
%   num_trees      - 隔离树数量 (默认 100)
%   subsample_size - 子采样大小 (默认 min(n, 256))
% OUTPUT:
%   scores         - n×1 异常分数, s∈[0,1], s→1 异常
%   trees          - cell array of tree structures

% 对每棵树
for t = 1:num_trees
    % 随机子采样
    idx = randperm(n, subsample_size);
    X_sub = X(idx, :);
    % 递归构建隔离树
    trees{t} = build_tree(X_sub, 0, ceil(log2(subsample_size)));
end

% 计算异常分数
c_n = 2*(log(subsample_size-1) + 0.5772156649) - 2*(subsample_size-1)/subsample_size;
for i = 1:n
    avg_path = 0;
    for t = 1:num_trees
        avg_path = avg_path + path_length(trees{t}, X(i,:), 0);
    end
    avg_path = avg_path / num_trees;
    scores(i) = 2^(-avg_path / c_n);
end
end

% 递归构建隔离树 (iTree)
function node = build_tree(X_sub, depth, max_depth)
    n = size(X_sub, 1);
    % 停止条件
    if depth >= max_depth || n <= 1
        node = struct('type', 'leaf', 'size', n);
        return;
    end
    % 随机选特征
    q = randi(size(X_sub, 2));
    % 随机选分割点
    min_val = min(X_sub(:, q)); max_val = max(X_sub(:, q));
    if min_val == max_val
        node = struct('type', 'leaf', 'size', n);
        return;
    end
    p = min_val + rand * (max_val - min_val);
    % 分裂
    left_idx = X_sub(:, q) < p;
    node = struct('type', 'internal', ...
        'split_feature', q, 'split_value', p, ...
        'left', build_tree(X_sub(left_idx, :), depth+1, max_depth), ...
        'right', build_tree(X_sub(~left_idx, :), depth+1, max_depth), ...
        'size', n);
end

% 计算路径长度
function len = path_length(node, x, current_len)
    if strcmp(node.type, 'leaf')
        % 叶节点: 若 size > 1 则加惩罚项 c(node.size)
        if node.size <= 1
            len = current_len;
        else
            c = 2*(log(node.size-1) + 0.5772156649) - 2*(node.size-1)/node.size;
            len = current_len + c;
        end
    else
        if x(node.split_feature) < node.split_value
            len = path_length(node.left, x, current_len + 1);
        else
            len = path_length(node.right, x, current_len + 1);
        end
    end
end
```

**关键说明**: MATLAB 目前无原生 Isolation Forest 实现 (截至 R2024a)，上述自写代码需配合 S5 文件夹中的完整脚本。Python 的 sklearn 实现有更好的性能优化和边缘情况处理，建议对精度要求高的场景用 Python 备选。

## Python 备选

```python
from sklearn.ensemble import IsolationForest
import numpy as np

# 训练 (无需标签)
iso_forest = IsolationForest(
    n_estimators=100,
    max_samples=256,        # 子采样大小 ψ
    contamination=0.1,      # 预期异常比例 (关键超参数)
    max_features=1.0,       # 使用全部特征 (也可设为 <1.0 增加随机性)
    bootstrap=False,        # 无放回采样 (标准做法)
    random_state=42,
    n_jobs=-1
)

# 拟合
iso_forest.fit(X)

# 预测: 返回 1 (正常) 或 -1 (异常)
y_pred = iso_forest.predict(X)  # 1=正常, -1=异常

# 异常分数 (scores, 分数越低越异常，需取反对比)
scores = iso_forest.decision_function(X)  # 越大越正常
anomaly_scores = -scores  # 取反后越大越异常

# 自定义阈值判断异常
import numpy as np
threshold = np.percentile(anomaly_scores, 95)
outliers = anomaly_scores > threshold
```

## 选型决策树

| 场景 | 选择 | 理由 |
|------|------|------|
| 高维数据 (p > 100) 异常检测 | 隔离森林 | 随机特征选择天然适合高维，不需要距离度量 |
| 大规模数据 (n > 10⁵) | 隔离森林 | 子采样 ψ=256 使训练与 n 无关 (仅线性扫描) |
| 异常比例未知 | 隔离森林 + 分数直方图 | 分数分布自然呈现双峰，阈值可目视确定 |
| 异常比例 < 5% | 隔离森林 (默认) | 隔离森林假设异常稀少，低异常率时性能最佳 |
| 异常在低密度区域 (孤立点) | 隔离森林 | 本质就是通过低密度→浅路径来检测 |
| 异常成簇出现 (异常簇) | 隔离森林 / LOF | 异常簇对隔离森林有 masking 效应；LOF 更合适 |
| 需要可解释异常原因 | 隔离森林 + 特征分析 | 可通过查看哪些特征频繁被选为分裂特征来辅助解释 |
| 数据全为类别型特征 | 不适合 | 随机分割在类别间效果差，使用扩展版 SCiForest 或基于频率的方法 |
| 异常比例 > 10% | 不适合 / 降低 contamination | 隔离森林前提是异常稀少，高异常率下正常剖面被污染 |

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 数据散点图 (二维) | 用前两个特征可视化，标注疑似异常点 |
| process | 异常分数直方图 | histogram(scores); 观察双峰/长尾以确定阈值 |
| process | 平均路径长度分布 | 正常点聚集在 c(ψ) 附近，异常点显著偏离 |
| result | 异常分数散点图 (t-SNE/UMAP) | 高维数据降维投影，点大小或颜色映射异常分数 |
| result | 特征贡献分析 | 各特征被选为分裂特征的频率，高频特征指示异常维度 |
| result | contamination 敏感性曲线 | 不同 contamination 下的检出率 vs 误报率 |

## 常见坑

1. **contamination 参数的影响**: 设置过低→漏检真异常; 设置过高→正常样本被误报为异常。现实中异常比例未知，建议做分数的直方图目视确定自然断点，或进行 contamination 的敏感性分析。
2. **swamping 效应 (异常点过多互相掩盖)**: 当异常比例 > 10% 时，大量异常点使部分异常区域的密度看起来"正常"，路径长度趋近 c(ψ)。子采样 ψ 远小于 n 可部分缓解，但仍需限制 anomaly ratio。
3. **masking 效应 (异常簇)**: 当异常点聚集成密集簇时 (如系统性的数据录入错误造成的相似异常值)，其路径长度不短，被判定为正常。隔离森林等价于密度估计 (路径长度 ∝ -log density)，簇状异常被误判为正常区域。
4. **特征全部高度相关**: 若所有特征相关系数 > 0.9，随机选择任一特征产生的分割效果几乎相同，树间多样性大幅降低，异常分数的方差增加。
5. **确定性太低**: 单次训练结果可能不稳定——子采样和随机选择导致分数在训练间波动 ±0.05。建议增加 t 至 500 或取多次训练的分数均值。
6. **阈值选择**: scores > 0.5 并非绝对的异常判据——需根据 contamination 和分数分布的实际形状来定。通常 scores > 0.6 为强异常信号，但取决于 ψ 和数据分布。

## 失效条件/反例 (强制小节)

- **条件1: 特征全部高度相关 (平均 $|\rho| > 0.85$)** → **表现**: 随机选择一个特征和随机选分割点的策略在特征高度相关时失效——无论选哪个特征，分割的本质效果相同 (数据在相关特征上的相对排序几乎一致)。这意味着所有 iTree 的结构高度相似，集成失去了多样性。异常点与正常点在路径长度上的差异不显著 (方差比 < 1.5)，异常分数分布集中在 0.5 附近，无法有效区分异常。**应对**: (1) 先用 PCA 去相关降维; (2) 使用扩展版本 SCiForest (使用超平面分割而非轴对齐分割) 或 Extended Isolation Forest; (3) 使用 LOF/DBSCAN 等基于距离/密度的替代方法。

- **条件2: 异常比例 > 10% (异常点过多)** → **表现**: 隔离森林的核心假设是"异常点少而不同"。当异常比例过高时，大量异常点使某些区域被异常点占据。子采样 ψ=256 抽取到的样本中可能包含 $\approx 10\% \times 256 \approx 26$ 个异常点，这些异常点若分布集中，会被 iTree 认为是"稠密区域"而赋予正常路径长度。同时，少量正常点反而因被孤立而获得高异常分数 (角色反转)。最终异常分数分布呈多峰而非预期双峰，基于 contamination 的硬阈值误分类率极高。**应对**: (1) 降低 contamination 并仅标记 scores top-k% 为异常; (2) 使用半监督方法 (SVDD); (3) 若异常比例确实高，重新考虑是否应该作为分类问题处理 (标注异常与正常)。

- **条件3: 类别型特征为主 (> 80% 特征为 categorical)** → **表现**: 标准隔离树使用随机排序值分割 (axis-aligned split)，类别型特征的"随机值在 min 和 max 之间"缺乏有意义的排序——如颜色类别 {红, 蓝, 绿}，随机分割 p ∈ (红, 绿) 的含义不明确。分割质量随机，导致路径长度与异常性无关，异常分数近似随机分布。**应对**: (1) 对类别特征做独热编码 (但会增加维度); (2) 使用扩展版本 SCiForest 或基于频率的异常检测; (3) 对于混合数据，仅对连续特征使用隔离森林，类别特征用规则/频率分析。

## 文献

1. Liu FT, Ting KM, Zhou ZH (2008). "Isolation forest." *Proceedings of the 8th IEEE International Conference on Data Mining (ICDM)*, pp. 413-422. DOI: [10.1109/ICDM.2008.17](https://doi.org/10.1109/ICDM.2008.17)
2. Liu FT, Ting KM, Zhou ZH (2012). "Isolation-based anomaly detection." *ACM Transactions on Knowledge Discovery from Data (TKDD)*, 6(1):1-39. DOI: [10.1145/2133360.2133363](https://doi.org/10.1145/2133360.2133363)
3. Hariri S, Kind MC, Brunner RJ (2019). "Extended Isolation Forest." *IEEE Transactions on Knowledge and Data Engineering*, 33(4):1479-1489. DOI: [10.1109/TKDE.2019.2947676](https://doi.org/10.1109/TKDE.2019.2947676)

## 来源溯源

Liu et al. (2008) ICDM; sklearn.ensemble.IsolationForest 参考实现; 自写 S5:isolation_forest.m.

## 关联范式卡

| 关系 | ID |
|------|-----|
| 替代 | PARADIGM-0506 (K-Means 聚类, 可检测远离聚类中心的异常点) |
| 替代 | PARADIGM-0618 (CNN, 基于重构误差的异常检测, 图像数据) |
| 组合 | PARADIGM-0504 (PCA, 降维去相关后使用隔离森林) |
| 组合 | PARADIGM-0601 (随机森林, 先用隔离森林清洗异常样本再训练RF) |
| 前置 | PARADIGM-0501 (数据预处理, 标准化对隔离森林非必需但推荐保持一致) |
