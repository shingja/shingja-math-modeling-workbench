% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function sim = lsa_similarity(model, mode, idx1, idx2)
% LSA_SIMILARITY 在潜在语义空间中计算相似度

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

%% Self-test
function self_test()
    % Test on known LSA model
    rng(42, 'twister');
    X = [3 0 1; 0 2 1; 1 0 2; 0 3 0]';
    model = lsa_train(X, 2, 'tf');
    sim = lsa_similarity(model, 'doc', 1, 2);
    assert(abs(sim) <= 1 + 1e-6, 'Test failed: cosine similarity should be in [-1,1].');
    disp('lsa_similarity self-test passed.');
end
