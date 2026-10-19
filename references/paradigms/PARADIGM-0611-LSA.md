# PARADIGM-0611 潜在语义分析LSA⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0611 |
| 类别/子类 | ⑥机器学习 / 文本降维 |
| 难度 | 中 |
| 适用题型关键词[] | LSA, 潜在语义分析, LSI, 语义索引, TF-IDF, 文本降维, 文档相似度, 概念空间 |
| confidence | high |
| source | Deerwester et al. (1990) JASIS |

## 数学形式

**步骤 1: 构建词-文档矩阵 (Term-Document Matrix)**

$$\mathbf{A}_{m\times n} = [a_{ij}], \quad a_{ij} = \text{TF-IDF}(t_i, d_j)$$

**TF-IDF 计算:**
$$\text{TF}(t,d) \cdot \text{IDF}(t) = f_{t,d} \cdot \log\frac{N}{1 + |\{d: t \in d\}|}$$

**步骤 2: 截断 SVD**
$$\mathbf{A} \approx \mathbf{U}_k \mathbf{\Sigma}_k \mathbf{V}_k^T$$

**步骤 3: 语义空间映射**
- 词向量 (Term Embedding): $\mathbf{U}_k\mathbf{\Sigma}_k$ (k 维)
- 文档向量 (Document Embedding): $\mathbf{V}_k\mathbf{\Sigma}_k$ (k 维)

**文档相似度 (余弦):**
$$\text{sim}(d_i, d_j) = \frac{\mathbf{v}_i^T\mathbf{v}_j}{\|\mathbf{v}_i\| \cdot \|\mathbf{v}_j\|}$$

**查询映射:**
$$\mathbf{q}_k = \mathbf{q}^T \mathbf{U}_k \mathbf{\Sigma}_k^{-1}$$

**主题数 k 选择:** 通常 k ∈ [50, 300] (太大引入噪声, 太小丢失语义)

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| k (主题/概念数) | int | 100 | [10, 500] | 极高 — 过小丢失信息, 过大引入噪声 |
| IDF 平滑 | bool | true | — | 低 |
| 构建词-文档矩阵 | — | — | O(m·n) 非零元素 | — |
| SVD 截断 | — | — | O(m·n·k) | — |

## MATLAB 实现

函数签名 (自写):
```matlab
[doc_vectors, term_vectors, sigma] = lsa(documents, k)
% documents: cell array of strings 或词-文档稀疏矩阵
% k: 主题数
```

锚点: 自写-见S5:lsa.m

```matlab
% 步骤1: 构建 TF-IDF 矩阵
[~, A] = tfidf(documents);  % 或 CountVectorizer 等效

% 步骤2: 截断 SVD
[U, S, V] = svds(A, k);  % 稀疏SVD

% 步骤3: 文档-概念空间
doc_vecs = V * S;  % n×k, 每行=文档的k维语义向量

% 相似度查询
query_vec = query_tfidf * U / S;  % 查询映射到概念空间
similarities = doc_vecs * query_vec' ./ (vecnorm(doc_vecs,2,2) * norm(query_vec));
```

## Python 备选

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
from sklearn.pipeline import make_pipeline

pipeline = make_pipeline(
    TfidfVectorizer(stop_words='english', max_features=5000),
    TruncatedSVD(n_components=100, random_state=42)
)
doc_embeddings = pipeline.fit_transform(documents)
```

## 选型决策树

- **LSA** — 文档相似度/语义检索，可解释概念维度 (SVD 分解)
- **pLSA (PARADIGM-0612)** — 概率框架 + 生成模型，避免 SVD 的正交性约束
- **LDA (PARADIGM-0613)** — 需要 Dirichlet 先验的贝叶斯主题模型
- **Word2Vec/BERT** — 需要词级/上下文语义，LSA 是文档级

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 词-文档矩阵稀疏图 (spy) | 非零元素分布 |
| process | 奇异值下降图 + 累积能量 | 选 k |
| result | 文档 2D 散点图 (t-SNE on doc_vecs) | 展示语义聚类 |

## 常见坑

1. **停用词污染**: 高频无意义词 (the, a, is) 主导 SVD 前几个分量 → 必须去除停用词并应用 sublinear TF scaling
2. **k 的选取**: 太小 (k<20) 丢失细粒度语义, 太大 (k>300) 引入噪声+过拟合 → 用困惑度 (perplexity) 或保留方差 ≥ 80%
3. **多义词问题**: 一个词有多个含义，SVD 将其压缩到单一向量 (均值语义) → LDA 等概率模型更好处理

## 失效条件/反例 (强制小节)

- **条件1: 文档集极小 (n < 30) 且文档极短 (如微博/短信)** → 表现: 词-文档矩阵极度稀疏 + 行/列方差不足，SVD 前几个分量被少数高频词支配，语义结构淹没。**应对**: 使用外部预训练词向量 (Word2Vec/GloVe) 做文档级平均，而非从头训练 LSA
- **条件2: 大量新文档需要实时更新语义空间** → 表现: LSA 需要 O(mn²) 的 SVD 重新训练，不能增量更新。**应对**: 使用增量 SVD / Online LSA 或改用动态主题模型 (DTM)

## 文献

1. Deerwester S., Dumais S.T., Furnas G.W., Landauer T.K. & Harshman R. (1990). "Indexing by latent semantic analysis." *Journal of the American Society for Information Science*, 41(6):391-407. DOI: [10.1002/(SICI)1097-4571(199009)41:6<391::AID-ASI1>3.0.CO;2-9](https://doi.org/10.1002/(SICI)1097-4571(199009)41:6<391::AID-ASI1>3.0.CO;2-9)
2. Manning C.D., Raghavan P. & Schutze H. (2008). *Introduction to Information Retrieval*. Cambridge. Chapter 18. ISBN: 978-0521865715

## 来源溯源

自写 lsa.m; 信息检索教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 前置 | PARADIGM-0610 (SVD) |
| 替代 | PARADIGM-0613 (LDA) |
| 组合 | PARADIGM-0903 (文本挖掘管道) |
