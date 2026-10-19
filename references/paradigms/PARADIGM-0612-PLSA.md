# PARADIGM-0612 概率潜在语义分析pLSA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0612 |
| 类别/子类 | ⑥机器学习 / 主题模型 |
| 难度 | 中 |
| 适用题型关键词[] | pLSA, 概率潜在语义, 主题模型, EM算法, 文档生成, 概率分解 |
| confidence | medium |
| source | Hofmann (1999) UAI |

## 数学形式

**生成模型:**
$$P(d, w) = P(d) \sum_{z} P(w \mid z) P(z \mid d)$$

- $P(d)$ — 文档先验
- $P(z \mid d)$ — 文档的主题分布
- $P(w \mid z)$ — 主题的词分布

**对数似然:**
$$\ell = \sum_{d} \sum_{w} n(d,w) \log \sum_{z} P(w \mid z) P(z \mid d)$$

**EM 算法:**
- **E 步:** $P(z \mid d,w) = \frac{P(w \mid z) P(z \mid d)}{\sum_{z'} P(w \mid z') P(z' \mid d)}$
- **M 步:** $P(w \mid z) \propto \sum_d n(d,w) P(z \mid d,w)$; $P(z \mid d) \propto \sum_w n(d,w) P(z \mid d,w)$

**与 LSA 的区别:** pLSA 是概率模型 (非负)，LSA 是几何模型 (SVD，值可负)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| K (主题数) | int | 20 | [5, 200] | 高 |
| max_iter | int | 200 | [50, 1000] | 中 |
| tol | double | 1e-4 | [1e-6, 1e-2] | 低 |
| 时间复杂度 | — | — | O(K·nnz·iter) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[P_w_z, P_z_d, loglik] = plsa(counts, K, max_iter, tol)
% counts: m×n 词-文档共现矩阵
% P_w_z: m×K 词-主题分布
% P_z_d: K×n 文档-主题分布
```

锚点: 自写-见S5:plsa.m

**关键 EM 循环:**
```matlab
for iter = 1:max_iter
    % E-step
    P_z_given_dw = P_w_z * P_z_d;  % 未归一化
    P_z_given_dw = bsxfun(@rdivide, P_z_given_dw, sum(P_z_given_dw, 1));
    
    % M-step
    for z = 1:K
        wz = counts .* squeeze(P_z_given_dw(z,:,:));
        P_w_z(:,z) = sum(wz, 2);
        P_z_d(z,:) = sum(wz, 1);
    end
    P_w_z = normalize(P_w_z, 1, 'norm', 1);  % 列归一
    P_z_d = normalize(P_z_d, 1, 'norm', 1);  % 列归一
    
    % 检查收敛
    if abs(loglik_new - loglik_old) < tol, break; end
end
```

## Python 备选

```python
# pLSA 无官方 sklearn 实现，需自写或使用 gensim
# 一般直接用 LDA (gensim) 替代
from gensim.models import LdaModel
import gensim.corpora as corpora
```

## 选型决策树

- **pLSA** — 需要概率解释 (非负分量) + 中等文档集
- **LSA (PARADIGM-0611)** — 纯几何相似度，不需要概率框架
- **LDA (PARADIGM-0613)** — 需要 Dirichlet 先验 + 泛化到未见文档 + 避免过拟合
- **NMF (PARADIGM-0508)** — 非概率非负分解，计算简单

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | 对数似然随 EM 迭代上升曲线 | 验证收敛 |
| result | 各主题 Top-10 词条 WordCloud | 展示主题含义 |
| result | 文档-主题分布热力图 | 展示文档主题混合 |

## 常见坑

1. **EM 局部最优**: 不同随机初始化得到不同主题 → 多起点运行选最优
2. **过拟合 (参数=K(m+n)+K*m)**: pLSA 参数随文档数线性增长 → 文档多时改用 LDA
3. **未见文档推理**: pLSA 无天然方法处理新文档 → 需"fold-in"近似或直接用 LDA

## 失效条件/反例 (强制小节)

- **条件1: 文档数极大 (n > 10^5)** → 表现: pLSA 参数 $K \times n$ (文档-主题分布) 随文档数线性增长，内存 O(K·n) 不可接受，且每个文档参数独立导致严重过拟合 — 测试文档无参数。**应对**: 必须改用 LDA (参数与文档数无关，只有 K×m 个参数)
- **条件2: EM 初始化不当 → 退化解** → 表现: 若 $P(w \mid z)$ 和 $P(z \mid d)$ 初始化为均匀分布，EM 在平坦区域难以逃脱 → 多个主题退化成相同内容 (主题重复)。**应对**: 使用随机初始化 + 多起点 + 选最大似然结果；或使用 LDA 的变分推断避免此问题

## 文献

1. Hofmann T. (1999). "Probabilistic latent semantic indexing." *Proceedings of the 22nd Annual International ACM SIGIR Conference (UAI)*, 50-57. DOI: [10.1145/312624.312649](https://doi.org/10.1145/312624.312649)
2. Blei D.M., Ng A.Y. & Jordan M.I. (2003). "Latent Dirichlet allocation." *Journal of Machine Learning Research*, 3:993-1022. (LDA 的改进动机)

## 来源溯源

自写 plsa.m; 主题模型经典论文

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0611 (LSA) |
| 替代 | PARADIGM-0613 (LDA) |
| 替代 | PARADIGM-0508 (NMF) |
