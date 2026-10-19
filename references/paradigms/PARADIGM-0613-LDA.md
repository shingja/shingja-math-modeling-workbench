# PARADIGM-0613 潜在狄利克雷分配LDA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0613 |
| 类别/子类 | ⑥机器学习 / 贝叶斯主题模型 |
| 难度 | 高 |
| 适用题型关键词[] | LDA, 潜在狄利克雷分配, 主题建模, 文本分析, 变分推断, Gibbs采样, Dirichlet先验 |
| confidence | high |
| source | Blei et al. (2003) JMLR |

## 数学形式

**生成过程 (每篇文档 $d$):**
1. 抽样主题分布 $\theta_d \sim \text{Dir}(\alpha)$
2. 对文档中的每个词 $w_{dn}$:
   - 抽样主题 $z_{dn} \sim \text{Multinomial}(\theta_d)$
   - 抽词 $w_{dn} \sim \text{Multinomial}(\phi_{z_{dn}})$

**联合概率:**
$$P(\mathbf{w}, \mathbf{z}, \theta, \phi \mid \alpha, \eta) = \prod_{k=1}^{K} P(\phi_k \mid \eta) \prod_{d=1}^{D} P(\theta_d \mid \alpha) \prod_{n=1}^{N_d} P(z_{dn} \mid \theta_d) P(w_{dn} \mid \phi_{z_{dn}})$$

**后验推断 (Collapsed Gibbs 采样):**
$$P(z_i = k \mid \mathbf{z}_{-i}, \mathbf{w}) \propto \frac{n_{d,k}^{(-i)} + \alpha_k}{\sum_k (n_{d,k}^{(-i)} + \alpha_k)} \cdot \frac{n_{k,w}^{(-i)} + \eta}{\sum_w (n_{k,w}^{(-i)} + \eta)}$$

其中 $n_{d,k}$ 为文档 $d$ 中主题 $k$ 的计数，$n_{k,w}$ 为主题 $k$ 中词 $w$ 的计数。

**Perplexity (评估指标):**
$$\text{Perplexity} = \exp\left(-\frac{\sum_d \log P(\mathbf{w}_d)}{\sum_d N_d}\right)$$

**参数:**
- $\alpha$ — 文档-主题 Dirichlet 先验 (小 → 稀疏, 大 → 均匀)
- $\eta$ — 主题-词 Dirichlet 先验
- $K$ — 主题数

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| K | int | 20 | [5, 200] | 极高 — 影响主题粒度和可解释性 |
| alpha | double | 0.1 | (0, 10) | 中 — 控制文档主题稀疏性 |
| eta | double | 0.01 | (0, 10) | 低 |
| n_iter | int | 1000 | [200, 5000] | 高 — Gibbs 需收敛 |
| 时间复杂度 (Gibbs) | — | — | O(K·nnz·iter) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[theta, phi, perplexity] = lda_gibbs(counts, K, alpha, eta, n_iter, burn_in)
% counts: m×n 词-文档稀疏矩阵
% theta: K×n 文档-主题分布
% phi: m×K 主题-词分布
```

锚点: 自写-见S5:lda_gibbs.m

```matlab
% Collapsed Gibbs 核心
for iter = 1:n_iter
    for each token (d, w)  % 遍历每个词
        % 减 1 (排除当前词)
        n_d_k(z_current) = n_d_k(z_current) - 1;
        n_k_w(z_current, w) = n_k_w(z_current, w) - 1;
        
        % 采样新主题
        p_z = (n_d_k + alpha) .* (n_k_w(:,w)' + eta) ./ ...
              (sum(n_k_w,2) + W*eta);
        p_z = p_z / sum(p_z);
        z_new = randsample(K, 1, true, p_z);
        
        % 加回去
        n_d_k(z_new) = n_d_k(z_new) + 1;
        n_k_w(z_new, w) = n_k_w(z_new, w) + 1;
    end
    % 每隔若干轮记录 perplexity
end
```

## Python 备选

```python
from gensim.models import LdaModel
import gensim.corpora as corpora

dictionary = corpora.Dictionary(tokenized_docs)
corpus = [dictionary.doc2bow(doc) for doc in tokenized_docs]

lda = LdaModel(corpus, num_topics=20, id2word=dictionary,
               alpha='auto', eta='auto', passes=10, random_state=42)
# 主题词
for topic in lda.print_topics():
    print(topic)
```

## 选型决策树

- **LDA** — 标准主题建模，需贝叶斯框架 + 泛化到未见文档
- **pLSA (PARADIGM-0612)** — 小文档集，不需要贝叶斯框架
- **NMF (PARADIGM-0508)** — 非概率分解，实现简单
- **动态主题模型 DTM** — 时间序列文档，主题随时间演化

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| process | Perplexity vs K 曲线 | 选主题数 |
| result | 主题-词 Top-10 柱状图 | 每个主题的特征词 |
| result | 文档-主题分布热力图 + t-SNE | 展示文档聚类 |

## 常见坑

1. **主题数 K 选择**: 无客观最优 → 使用 perplexity elbow + 主题一致性 (Topic Coherence) 双重验证
2. **Gibbs 收敛慢**: 需 burn_in ≥ 500 + 间隔采样 (thin) → 变分推断 (VB) 更快但近似
3. **短文本 LDA**: 每条文档 < 20 词时主题推断不可靠 → 用 Biterm Topic Model (BTM) 或聚合短文本为"伪文档"

## 失效条件/反例 (强制小节)

- **条件1: 短文本 (< 20 词/文档, 如微博/Tweet)** → 表现: 单条文档的词不足以可靠估计 $\theta_d$，Gibbs 采样在各主题间随机跳转不收敛，最终每个文档被"分派"到随机主题。**应对**: 使用 BTM (Biterm Topic Model) 在词对级别建模，或聚合同类短文本为伪长文档
- **条件2: 文档集语言混合 (无语言检测)** → 表现: LDA 将不同语言映射到同一个"主题"，实际主题被语言信号覆盖 — 主题 = 语言而非语义。**应对**: 单语言预处理 + 去除非目标语言文本，或使用 Polylingual Topic Model (PLTM)

## 文献

1. Blei D.M., Ng A.Y. & Jordan M.I. (2003). "Latent Dirichlet allocation." *Journal of Machine Learning Research*, 3:993-1022.
2. Griffiths T.L. & Steyvers M. (2004). "Finding scientific topics." *PNAS*, 101(S1):5228-5235. DOI: [10.1073/pnas.0307752101](https://doi.org/10.1073/pnas.0307752101)

## 来源溯源

自写 lda_gibbs.m; 主题模型经典论文

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0611 (LSA) |
| 替代 | PARADIGM-0612 (pLSA) |
| 组合 (采样) | PARADIGM-0614 (MCMC) |
| 组合 | PARADIGM-0903 (文本挖掘管道) |
