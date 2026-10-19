% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = lsa_train(X, k, weighting)
% LSA_TRAIN 潜在语义分析 (Latent Semantic Analysis / LSI)
%
%   算法来源：Deerwester et al. (1990), "Indexing by Latent Semantic
%             Analysis", JASIS, 41(6), 391-407
%   算法复杂度：O(m * n * k)，m=词汇数，n=文档数，k=主题数
%
%   输入参数:
%       X         - 词-文档矩阵 [n_terms, n_docs]，通常为 TF-IDF 加权
%       k         - 潜在语义维度/主题数 (默认 100)
%       weighting - 加权方式: 'tfidf'(默认), 'tf', 'binary', 'log_entropy'
%
%   输出参数:
%       model - 结构体
%         .U        - 词-语义矩阵 [n_terms, k]（词在语义空间的表示）
%         .S        - 奇异值对角矩阵 [k, k]
%         .V        - 文档-语义矩阵 [n_docs, k]（文档在语义空间的表示）
%         .term_representations - U * S，加权词向量
%         .doc_representations   - V * S，加权文档向量
%
%   示例:
%       % 5个文档，10个词的词频矩阵
%       X = [3 0 1 0 2; 0 2 0 1 0; 1 0 0 2 0; 0 0 3 0 1; ...
%            2 1 0 0 0; 0 0 0 3 0; 1 0 2 0 0; 0 0 0 0 4; ...
%            0 1 0 0 0; 0 0 0 1 1];
%       model = lsa_train(X, 3);
%       sim = lsa_similarity(model, 'doc', 1, 2);
%
%   参考文献:
%       Deerwester, S. et al. (1990). Indexing by Latent Semantic
%       Analysis. JASIS.

%% 参数默认值
[n_terms, n_docs] = size(X);
if nargin < 2 || isempty(k), k = min(100, min(n_terms, n_docs)); end
if nargin < 3 || isempty(weighting), weighting = 'tfidf'; end

k = min(k, min(n_terms, n_docs));

%% 加权处理
switch lower(weighting)
    case 'tfidf'
        X_weighted = compute_tfidf(X);
    case 'tf'
        X_weighted = X;
    case 'binary'
        X_weighted = double(X > 0);
    case 'log_entropy'
        X_weighted = compute_log_entropy(X);
    otherwise
        error('不支持的加权方式: %s', weighting);
end

%% 截断 SVD
[U, S, V] = svds(X_weighted, k);

model.U = U;
model.S = S;
model.V = V;
model.term_representations = U * S;     % [n_terms, k]
model.doc_representations = V * S;       % [n_docs, k]
model.k = k;
model.weighting = weighting;

end


function X_tfidf = compute_tfidf(X)
% 计算 TF-IDF 加权矩阵
%   TF-IDF = TF * IDF
%   IDF = log(N / (1 + df)) + 1  (平滑版本)

[n_terms, n_docs] = size(X);

% 文档频率
df = sum(X > 0, 2);

% IDF（平滑）
idf = log(n_docs ./ (1 + df)) + 1;

% TF-IDF
X_tfidf = X .* idf;

% L2 列归一化（每篇文档）
col_norms = sqrt(sum(X_tfidf.^2, 1));
col_norms(col_norms == 0) = 1;
X_tfidf = X_tfidf ./ col_norms;

end


function X_le = compute_log_entropy(X)
% Log-Entropy 加权

[n_terms, n_docs] = size(X);

% 局部权重：log(1 + tf)
X_log = log(1 + X);

% 全局权重（熵）：1 - entropy/entropy_max
p = X ./ max(sum(X, 2), 1e-9);  % 概率分布
p(p == 0) = 1;  % log(1) = 0
entropy = -sum(p .* log(p), 2) / log(n_docs);
global_weight = 1 - entropy;

X_le = X_log .* global_weight;

end


function sim = lsa_similarity(model, mode, idx1, idx2)
% LSA_SIMILARITY 在潜在语义空间中计算相似度
%
%   输入:
%       mode - 'term' 或 'doc'
%       idx1, idx2 - 两个待比较对象的索引
%
%   输出:
%       sim - 余弦相似度 [-1, 1]

switch lower(mode)
    case 'term'
        vec1 = model.term_representations(idx1, :);
        vec2 = model.term_representations(idx2, :);
    case 'doc'
        vec1 = model.doc_representations(idx1, :);
        vec2 = model.doc_representations(idx2, :);
    otherwise
        error('模式必须是 term 或 doc');
end

sim = dot(vec1, vec2) / (norm(vec1) * norm(vec2) + eps);

end


function query_vec = lsa_query(model, q)
% LSA_QUERY 将查询向量映射到潜在语义空间
%
%   输入:
%       q - 查询向量 [n_terms, 1] 或 [n_terms, n_queries]
%
%   输出:
%       query_vec - 查询在语义空间的表示 [k, 1] 或 [k, n_queries]
%
%   映射公式: q_lsa = S^{-1} * U' * q

query_vec = model.S \ (model.U' * q);

end


function [top_docs, scores] = lsa_search(model, query_vec, top_k)
% LSA_SEARCH 在语义空间中检索最相似的文档
%
%   输入:
%       query_vec - 查询在语义空间的表示 [k, 1]
%       top_k     - 返回的文档数 (默认 10)
%
%   输出:
%       top_docs  - 最相关文档的索引
%       scores    - 余弦相似度分数

if nargin < 3 || isempty(top_k), top_k = 10; end

% 文档与查询的余弦相似度
doc_vecs = model.doc_representations;  % [n_docs, k]
query_norm = norm(query_vec);
doc_norms = sqrt(sum(doc_vecs.^2, 2));

scores = (doc_vecs * query_vec) ./ (doc_norms * query_norm + eps);

[sort_scores, sort_idx] = sort(scores, 'descend');
top_k = min(top_k, length(sort_idx));
top_docs = sort_idx(1:top_k);
scores = sort_scores(1:top_k);

end

%% Self-test
function self_test()
    % Test with tiny doc-term matrix
    rng(42, 'twister');
    X = [3 0 1; 0 2 1; 1 0 2; 0 3 0]';  % 3 docs, 4 terms
    model = lsa_train(X, 2, 'tf');
    assert(size(model.U, 1) == 4, 'Test failed: U should have 4 rows (terms).');
    assert(size(model.V, 1) == 3, 'Test failed: V should have 3 rows (docs).');
    sim = lsa_similarity(model, 'doc', 1, 2);
    assert(abs(sim) <= 1 + 1e-6, 'Test failed: cosine similarity should be in [-1,1].');
    q_vec = lsa_query(model, [1; 0; 0; 0]);
    assert(length(q_vec) == 2, 'Test failed: query vector should be in k=2 space.');
    [top_docs, scores] = lsa_search(model, q_vec, 2);
    assert(length(top_docs) <= 2, 'Test failed: should return at most 2 docs.');
    disp('lsa_train self-test passed.');
end
