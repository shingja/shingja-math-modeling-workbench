% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [top_words, scores] = lda_top_words(model, topic_idx, n_words)
% LDA_TOP_WORDS 获取主题下概率最高的词
if nargin < 3 || isempty(n_words), n_words = 10; end
[scores, top_words] = maxk(model.phi(topic_idx, :), n_words);
end

%% Self-test
function self_test()
    % Test with LDA output from lda_train
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = lda_train(X, 2, 0.1, 0.01, 50, 10);
    [top_words, scores] = lda_top_words(model, 1, 3);
    assert(length(top_words) <= 3, 'Test failed: top_words should have at most 3 entries.');
    disp('lda_top_words self-test passed.');
end
