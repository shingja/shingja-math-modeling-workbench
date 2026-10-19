% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [top_words, scores] = plsa_top_words(model, topic_idx, n_words)
% PLSA_TOP_WORDS 获取某主题下概率最高的词
%
%   输入:
%       topic_idx - 主题索引
%       n_words   - 返回的词汇数 (默认 10)

if nargin < 3 || isempty(n_words), n_words = 10; end

[scores, top_words] = maxk(model.P_w_given_z(topic_idx, :), n_words);

end

%% Self-test
function self_test()
    % Test with PLSA output
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = plsa_train(X, 2, 30, 1e-4);
    [top_words, scores] = plsa_top_words(model, 1, 2);
    assert(length(top_words) <= 2, 'Test failed: top_words should have at most 2 entries.');
    disp('plsa_top_words self-test passed.');
end
