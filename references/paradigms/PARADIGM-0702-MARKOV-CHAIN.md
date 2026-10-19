# PARADIGM-0702 马尔科夫链⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0702 |
| 类别/子类 | ⑦综合 / 随机过程 |
| 难度 | 中 |
| 适用题型关键词[] | 马尔科夫链, Markov Chain, 状态转移, 平稳分布, 吸收态, 随机过程, eig, dtmc |
| confidence | high |
| source | Norris (1997) Cambridge |

## 数学形式

**离散时间马尔科夫链 (DTMC):**
$$P(X_{n+1} = j \mid X_n = i, X_{n-1}, \ldots) = P(X_{n+1} = j \mid X_n = i) = p_{ij}$$

**转移概率矩阵 (行随机):**
$$\mathbf{P} = [p_{ij}]_{N\times N}, \quad \sum_{j} p_{ij} = 1, \quad p_{ij} \geq 0$$

**Chapman-Kolmogorov 方程:**
$$p_{ij}^{(m+n)} = \sum_{k} p_{ik}^{(m)} p_{kj}^{(n)}, \quad \mathbf{P}^{(n)} = \mathbf{P}^n$$

**平稳分布 $\pi$ (存在若遍历):**
$$\pi \mathbf{P} = \pi, \quad \sum_i \pi_i = 1$$

求解: $\pi$ 是 $\mathbf{P}^T$ 的特征值 $\lambda=1$ 对应的左特征向量。

**吸收马尔科夫链:**
- 瞬态 (Transient): 最终必被吸收
- 吸收态 (Absorbing): $p_{ii}=1$

**基本矩阵 (Fundamental Matrix):**
$$\mathbf{N} = (\mathbf{I} - \mathbf{Q})^{-1}$$, 其中 $\mathbf{Q}$ 为瞬态间转移子矩阵
- $[\mathbf{N}]_{ij}$ = 从瞬态 $i$ 出发被吸收前访问瞬态 $j$ 的期望次数
- 吸收时间期望 = $\mathbf{N} \cdot \mathbf{1}$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| P (转移矩阵) | double[,] | — | N×N 行随机矩阵 | 极高 — 定义模型 |
| pi_0 (初始分布) | double[] | uniform | 概率向量 | 中 — 影响短期动态 |
| 求平稳分布 | — | — | O(N³) eig | — |
| n步转移 | — | — | O(N³ log n) 矩阵幂 | — |

## MATLAB 实现

```matlab
% 方法1: Econometrics Toolbox dtmc 对象
mc = dtmc(P);  % 转移矩阵
pi_stationary = asymptotics(mc);  % 平稳分布
% 可视化
graphplot(mc, 'LabelEdges', true);

% 方法2: 自写特征向量法
[V, D] = eig(P');  % 左特征向量
[~, idx] = min(abs(diag(D) - 1));  % 找 lambda=1
pi = V(:, idx)';
pi = pi / sum(pi);  % 归一化

% n步转移
P_n = P^n;  % 或 mpower(P, n)

% 吸收链: 基本矩阵
% 假设状态重排为: 瞬态在前, 吸收态在后
n_transient = k;
Q = P(1:k, 1:k);
N = inv(eye(k) - Q);  % 基本矩阵
t_absorb = N * ones(k, 1);  % 吸收时间期望
B = N * P(1:k, k+1:end);  % 吸收概率
```

锚点: `eig` (MATLAB内置) / `dtmc` (Econometrics Toolbox)

## Python 备选

```python
import numpy as np
# 平稳分布
eigvals, eigvecs = np.linalg.eig(P.T)
pi = eigvecs[:, np.argmin(np.abs(eigvals - 1.0))]
pi = np.real(pi / np.sum(pi))

# quantecon 库
import quantecon as qe
mc = qe.MarkovChain(P)
pi = mc.stationary_distributions[0]
```

## 选型决策树

- **马尔科夫链** — 离散状态时序，状态转移概率稳定 (时齐)
- **隐马尔科夫模型 HMM** — 状态不可观察，只能观测到发射信号
- **马尔科夫决策过程 MDP** — 加入行动和奖励 → 强化学习
- **连续时间马尔科夫链 CTMC** — 时间连续，指数分布停留时间

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 状态转移有向图 (graphplot) | 边权重=p_{ij} |
| result | 平稳分布柱状图 | 长期各状态概率 |
| result | 分布演化 (subplot 多帧) | P^n 矩阵热力图随时间 |

## 常见坑

1. **非遍历链**: 不可约+非周期才是遍历的 → 多平稳分布或震荡 (周期性，$p_{ij}^{(n)}$ 不收敛)
2. **数值 P^n 发散**: P 有大于1的特征值 (非行随机) → 检查行和=1
3. **吸收链数值奇异**: $\mathbf{I}-\mathbf{Q}$ 接近奇异时 $\mathbf{N}$ 不稳定 → 检查是否所有瞬态真的可达吸收态

## 失效条件/反例 (强制小节)

- **条件1: 状态空间极大 (N > 10^4)** → 表现: eig(P') O(N³) 内存和时间爆炸，存储 $P_{N\times N}$ 需 800MB (float64)。**应对**: 使用稀疏转移矩阵的幂迭代或投影方法 (如 PageRank 的幂迭代)，或降维/状态聚合
- **条件2: 转移概率时变 (非时齐)** → 表现: 标准时齐马尔科夫链的平稳分布不存在，P^n 预测在转移机制发生变化后迅速失效。**应对**: 使用分段时齐马尔科夫链或时变转移概率模型，结合变化点检测

## 文献

1. Norris J.R. (1997). *Markov Chains*. Cambridge University Press. ISBN: 978-0521633963
2. Kemeny J.G. & Snell J.L. (1960). *Finite Markov Chains*. Van Nostrand. ISBN: 978-0387900926

## 来源溯源

MATLAB `eig` + `dtmc`; 随机过程教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 (MCMC) | PARADIGM-0614 (MCMC) |
| 组合 (排队论) | PARADIGM-0703 (排队基础) |
| 组合 (系统动力学) | PARADIGM-0708 (系统动力学) |
