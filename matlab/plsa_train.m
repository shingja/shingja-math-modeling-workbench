% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = plsa_train(X, K, max_iter, tol)
% PLSA_TRAIN 概率潜在语义分析 (Probabilistic Latent Semantic Analysis)
%
%   算法来源：Hofmann (1999), "Probabilistic Latent Semantic Analysis",
%             UAI'99, 289-296
%   算法复杂度：O(K * N * T)，K=主题数，N=总词数（非零元素），T=EM迭代次数
%
%   输入参数:
%       X        - 词-文档共现矩阵 [n_docs, n_terms]，值为词频
%       K        - 主题数量 (默认 10)
%       max_iter - EM 最大迭代次数 (默认 200)
%       tol      - 收敛容差 (默认 1e-4)
%
%   输出参数:
%       model - 结构体
%         .P_z_given_d  - P(z|d)，文档-主题分布 [n_docs, K]
%         .P_w_given_z  - P(w|z)，主题-词分布 [K, n_terms]
%         .P_z          - 主题先验 P(z) [K, 1]
%         .log_likelihood_history - 对数似然历史
%
%   示例:
%       X = [3 0 1 0 2; 0 2 0 1 0; 1 2 0 0 0; 0 0 3 0 1; 0 0 0 3 0];
%       model = plsa_train(X, 3);
%       [~, top_words] = maxk(model.P_w_given_z', 5);
%
%   参考文献:
%       Hofmann, T. (1999). Probabilistic Latent Semantic Analysis. UAI.

%% 参数默认值
[n_docs, n_terms] = size(X);
if nargin < 2 || isempty(K), K = min(10, min(n_docs, n_terms)); end
if nargin < 3 || isempty(max_iter), max_iter = 200; end
if nargin < 4 || isempty(tol), tol = 1e-4; end

%% 初始化参数（随机初始化 + 归一化）
% P(z|d): 文档-主题分布
P_z_given_d = rand(n_docs, K);
P_z_given_d = P_z_given_d ./ sum(P_z_given_d, 2);

% P(w|z): 主题-词分布
P_w_given_z = rand(K, n_terms);
P_w_given_z = P_w_given_z ./ sum(P_w_given_z, 2);

% P(z): 主题先验
P_z = ones(K, 1) / K;

% 找非零元素（稀疏加速）
[row_idx, col_idx, vals] = find(X);
n_nonzero = length(row_idx);

%% EM 算法
log_lik_history = zeros(max_iter, 1);

for iter = 1:max_iter
    % ---- E步: 计算后验 P(z | d, w) ----
    % 对每个非零共现 (d, w)
    P_z_given_dw = zeros(n_nonzero, K);

    for n = 1:n_nonzero
        d = row_idx(n);
        w = col_idx(n);

        % P(z | d,w) ∝ P(w|z) * P(z|d)
        joint = P_w_given_z(:, w) .* P_z_given_d(d, :)';
        P_z_given_dw(n, :) = joint' / (sum(joint) + eps);
    end

    % ---- M步: 更新参数 ----
    % 新的 P(w|z)
    P_w_given_z_new = zeros(K, n_terms);
    for n = 1:n_nonzero
        d = row_idx(n);
        w = col_idx(n);
        count = vals(n);
        P_w_given_z_new(:, w) = P_w_given_z_new(:, w) + ...
            count * P_z_given_dw(n, :)';
    end
    P_w_given_z_new = P_w_given_z_new ./ (sum(P_w_given_z_new, 2) + eps);

    % 新的 P(z|d)
    P_z_given_d_new = zeros(n_docs, K);
    for n = 1:n_nonzero
        d = row_idx(n);
        count = vals(n);
        P_z_given_d_new(d, :) = P_z_given_d_new(d, :) + ...
            count * P_z_given_dw(n, :);
    end
    P_z_given_d_new = P_z_given_d_new ./ (sum(P_z_given_d_new, 2) + eps);

    % 新的 P(z)
    P_z_new = sum(P_z_given_d_new, 1)' / n_docs;

    % ---- 对数似然计算 ----
    log_lik = 0;
    for n = 1:n_nonzero
        d = row_idx(n);
        w = col_idx(n);
        count = vals(n);
        prob = P_z_new' * (P_w_given_z_new(:, w) .* P_z_given_d_new(d, :)');
        prob = max(prob, 1e-300);
        log_lik = log_lik + count * log(prob);
    end
    log_lik_history(iter) = log_lik;

    % ---- 收敛检查 ----
    if iter > 1
        delta = abs(log_lik_history(iter) - log_lik_history(iter-1)) ...
                / max(1, abs(log_lik_history(iter-1)));
        if delta < tol
            log_lik_history = log_lik_history(1:iter);
            break;
        end
    end

    % 更新参数
    P_w_given_z = P_w_given_z_new;
    P_z_given_d = P_z_given_d_new;
    P_z = P_z_new;
end

%% 存储模型
model.P_z_given_d = P_z_given_d;
model.P_w_given_z = P_w_given_z;
model.P_z = P_z;
model.K = K;
model.log_likelihood_history = log_lik_history;

end


function [top_words, scores] = plsa_top_words(model, topic_idx, n_words)
% PLSA_TOP_WORDS 获取某主题下概率最高的词
%
%   输入:
%       topic_idx - 主题索引
%       n_words   - 返回的词汇数 (默认 10)

if nargin < 3 || isempty(n_words), n_words = 10; end

[scores, top_words] = maxk(model.P_w_given_z(topic_idx, :), n_words);

end


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

end

%% Self-test
function self_test()
    % Test with tiny 3-doc 4-word matrix
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = plsa_train(X, 2, 50, 1e-4);
    assert(size(model.P_z_given_d, 1) == 3, 'Test failed: P_z_given_d should have 3 docs.');
    assert(size(model.P_w_given_z, 2) == 4, 'Test failed: P_w_given_z should have 4 words.');
    [top_words, scores] = plsa_top_words(model, 1, 2);
    assert(length(top_words) <= 2, 'Test failed: top_words should have at most 2 entries.');
    [topics, scores2] = plsa_doc_topics(model, 1, 2);
    assert(length(topics) <= 2, 'Test failed: topics should have at most 2 entries.');
    disp('plsa_train self-test passed.');
end
