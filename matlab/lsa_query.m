% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
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

%% Self-test
function self_test()
    % Test on known LSA model
    rng(42, 'twister');
    X = [3 0 1; 0 2 1; 1 0 2; 0 3 0]';
    model = lsa_train(X, 2, 'tf');
    q_vec = lsa_query(model, [1; 0; 0; 0]);
    assert(length(q_vec) == 2, 'Test failed: query vector should be in k=2 space.');
    disp('lsa_query self-test passed.');
end
