# PARADIGM-0903 文本挖掘管道(TF-IDF到LSA/LDA)⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->


| 字段 | 内容 |
|------|------|
| ID | PARADIGM-0903 |
| 类别/子类 | ⑨经典与杂项 / 文本挖掘 |
| 难度 | 中 |
| 适用题型关键词[] | 文本挖掘, TF-IDF, LSA, LDA, 情感分析, 文本分类, 分词, NLP管道, Manning |
| confidence | high |
| source | Manning et al. (2008) Cambridge |

## 数学形式

**完整文本挖掘管道 (Pipeline):**

**步骤 1: 预处理**
- 分词 (Tokenization)
- 去停用词 (Stopword Removal)
- 词干提取/词形还原 (Stemming/Lemmatization)

**步骤 2: 特征工程 — TF-IDF**

**词频 (TF):**
$$\text{TF}(t,d) = f_{t,d}$$

**逆文档频率 (IDF):**
$$\text{IDF}(t) = \log\frac{N}{1 + |\{d: t \in d\}|}$$

**TF-IDF:**
$$\text{TF-IDF}(t,d) = \text{TF}(t,d) \times \text{IDF}(t)$$

**步骤 3: 向量空间模型 → 词-文档矩阵**
$$\mathbf{A}_{|V| \times N} = [\text{TF-IDF}(t,d)]$$

**步骤 4: 降维/主题建模**
- **LSA (SVD):** $\mathbf{A} \approx \mathbf{U}_k\mathbf{\Sigma}_k\mathbf{V}_k^T$ (见 PARADIGM-0611)
- **LDA (Gibbs):** $P(\mathbf{w}, \mathbf{z} \mid \alpha, \eta)$ (见 PARADIGM-0613)

**步骤 5: 下游任务**
- **文档聚类:** k-means on $\mathbf{V}_k$
- **文档分类:** SVM/Naive Bayes on document vectors
- **情感分析:** 词袋/词典法 or 机器学习

**情感词典法:**
$$\text{Sentiment}(d) = \sum_{t \in d} \text{polarity}(t)$$

**余弦相似度 (文档相似度):**
$$\text{sim}(d_i, d_j) = \frac{\mathbf{v}_i \cdot \mathbf{v}_j}{\|\mathbf{v}_i\| \cdot \|\mathbf{v}_j\|}$$

## 输入/输出/参数/量纲/复杂度

| 参数 | 类型 | 默认值 | 范围 | 灵敏度 |
|------|------|--------|------|--------|
| max_features | int | 5000 | [1000, 50000] | 高 — 特征空间大小 |
| min_df | int | 2 | [1, 10] | 中 — 去低频噪声 |
| ngram_range | [int,int] | [1,1] | [1,3] | 中 — 短语捕捉 |
| 管道复杂度 | — | — | O(ND·V/T + SVD cost) | — |

## MATLAB 实现

```matlab
% 文本预处理 + TF-IDF (Text Analytics Toolbox)
documents = tokenizedDocument(text_data);
documents = removeStopWords(documents);
documents = normalizeWords(documents, 'Style', 'lemma');
bag = bagOfWords(documents);
bag = removeInfrequentWords(bag, 2);
tfidf_mat = tfidf(bag);

% LSA
k = 100;
[U, S, V] = svds(tfidf_mat, k);
doc_vectors = V * S;  % 文档在 k 维语义空间

% 文档聚类
[idx, C] = kmeans(doc_vectors, 5);

% 情感分析 (Text Analytics Toolbox)
sentiment_scores = vaderSentimentScores(documents);
polarity = sentiment_scores.Compound;

% 或自写管道
function [doc_vectors, topics, features] = text_mining_pipeline(files_or_texts, k)
    % 步骤1: 预处理
    docs = preprocess_texts(files_or_texts);
    % 步骤2: TF-IDF
    [~, A] = tfidf_build(docs);
    % 步骤3: LSA
    [U, S, V] = svds(A, k);
    doc_vectors = V * S;
    % 步骤4: 主题关键词
    topics = extract_topic_keywords(U, features, 10);
end
```

锚点: 自写管道-见S5:text_mining_pipeline.m + Text Analytics Toolbox 辅助

## Python 备选

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD, LatentDirichletAllocation
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
    ('tfidf', TfidfVectorizer(max_features=5000, stop_words='english',
                              ngram_range=(1,2), min_df=2)),
    ('lsa', TruncatedSVD(n_components=100)),
    ('cls', LogisticRegression())
])
pipeline.fit(texts, labels)
```

## 选型决策树

- **TF-IDF + LSA** — 快速文档相似/聚类基线，语义降维
- **TF-IDF + LDA** — 需要可解释的文档-主题分布
- **Word2Vec/GloVe + 平均** — 语义更丰富的外部预训练词嵌入
- **BERT/Transformers** — 上下文语义 + SOTA 性能 (但计算开销大，建模竞赛酌情使用)
- **仅做情感** — 用 VADER (英文) 或词典法 (中文), 不需要 TF-IDF

## 典型图型

| 阶段 | 图型 | 说明 |
|------|------|------|
| raw | 词频 Top-20 柱状图 | 文本概况 |
| result | 文档 t-SNE/UMAP 散点图 (着色=聚类/主题) | 语义结构 |
| result | 主题 Top-10 词条 WordCloud | 各主题可解释性 |
| result | 情感分布柱状图 (正/中/负) | 情感概览 |

## 常见坑

1. **停用词+TF-IDF的选择**: 停用词去不干净 → 高频无意义词 (如"进行","可以") 主导 TF-IDF → 影响 SVD 的 top components
2. **中文分词**: 英文天然空格分词，中文需先 jieba 分词 → 分词错误传播到下游
3. **词频矩阵稀疏**: |V| × N 矩阵通常 95%+ 零 → 用稀疏矩阵存储

## 失效条件/反例 (强制小节)

- **条件1: 文档极短 (< 10 词/文档, 如标题)** → 表现: 99% 的文档对的余弦相似度为 0 (无共享词) → TF-IDF 向量空间几乎没有重叠信号，LSA/SVD 无法提取有意义的语义维度 → 降维后的文档向量无区分度。**应对**: 使用外部预训练词向量 (FastText/GloVe) 取文档级平均，或使用 Sentence-BERT 句子嵌入
- **条件2: 多语言混合语料** → 表现: TF-IDF 将同一语义的不同语言词视为不同特征 → 语种信号淹没语义信号 → LSA 第一维度 = 语种而非话题。**应对**: 先按语言分桶处理，或使用多语言 BERT (mBERT/XLM-R) 统一嵌入

## 文献

1. Manning C.D., Raghavan P. & Schutze H. (2008). *Introduction to Information Retrieval*. Cambridge University Press. ISBN: 978-0521865715
2. Blei D.M., Ng A.Y. & Jordan M.I. (2003). "Latent Dirichlet allocation." *JMLR*, 3:993-1022.

## 来源溯源

自写 text_mining_pipeline.m; IR教材

## 关联范式卡

| 关系 | ID |
|------|-----|
| 组合 | PARADIGM-0611 (LSA) |
| 组合 | PARADIGM-0613 (LDA) |
| 组合 | PARADIGM-0506 (K-Means聚类) |
