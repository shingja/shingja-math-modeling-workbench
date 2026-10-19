% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [top_topics, scores] = plsa_doc_topics(model, doc_idx, n_topics)
% PLSA_DOC_TOPICS 获取文档的主题分布
%
%   输入:
%       doc_idx  - 文档索引
%       n_topics - 返回的主题数 (默认全部)

P_z_given_d = model.P_z_given_d(doc_idx, :);
[scores, top_topics] = sort(P_z_given_d, 'descend');

if nargin >= 3 && ~isempty(n_topics)
    n_topics = min(n_topics, length(scores));
    top_topics = top_topics(1:n_topics);
    scores = scores(1:n_topics);
end

%% Self-test
function self_test()
    % Test with PLSA output
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = plsa_train(X, 2, 30, 1e-4);
    [topics, scores] = plsa_doc_topics(model, 1, 2);
    assert(length(topics) <= 2, 'Test failed: topics should have at most 2 entries.');
    disp('plsa_doc_topics self-test passed.');
end
