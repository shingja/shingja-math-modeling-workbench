% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function topics = lda_doc_topics(model, doc_idx)
% LDA_DOC_TOPICS 获取文档的主题分布
topics = model.theta(doc_idx, :);
end

%% Self-test
function self_test()
    % Test with LDA output from lda_train
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = lda_train(X, 2, 0.1, 0.01, 50, 10);
    topics = lda_doc_topics(model, 1);
    assert(length(topics) == 2, 'Test failed: doc_topics should have 2 entries.');
    disp('lda_doc_topics self-test passed.');
end
