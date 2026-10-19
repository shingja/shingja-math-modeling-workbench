% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
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
    % Test on known LSA model
    rng(42, 'twister');
    X = [3 0 1; 0 2 1; 1 0 2; 0 3 0]';
    model = lsa_train(X, 2, 'tf');
    q_vec = lsa_query(model, [1; 0; 0; 0]);
    [top_docs, scores] = lsa_search(model, q_vec, 2);
    assert(length(top_docs) <= 2, 'Test failed: should return at most 2 docs.');
    disp('lsa_search self-test passed.');
end
