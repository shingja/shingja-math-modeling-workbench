% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function model = lda_train(X, K, alpha, beta, n_iter, burn_in)
% LDA_TRAIN 潜在狄利克雷分配 (Latent Dirichlet Allocation, Gibbs采样)
%
%   算法来源：Blei, Ng & Jordan (2003), "Latent Dirichlet Allocation",
%             JMLR, 3, 993-1022
%   算法复杂度：O(K * N * T)，K=主题数，N=总词数，T=Gibbs迭代次数
%
%   输入参数:
%       X        - 文档-词频矩阵 [n_docs, n_terms]
%       K        - 主题数 (默认 10)
%       alpha    - 文档-主题 Dirichlet 先验 (默认 0.1 = 50/K)
%       beta     - 主题-词 Dirichlet 先验 (默认 0.01)
%       n_iter   - Gibbs 采样迭代次数 (默认 1000)
%       burn_in  - 预热期迭代数 (默认 100)
%
%   输出参数:
%       model - 结构体
%         .theta       - 文档-主题分布 [n_docs, K]
%         .phi         - 主题-词分布 [K, n_terms]
%         .topic_counts - 每个主题的总词数 [K, 1]
%         .perplexity   - 最终困惑度
%
%   示例:
%       X = [3 0 1 0 2; 0 2 0 1 0; 1 2 0 0 0; 0 0 3 0 1; 0 0 0 3 0];
%       model = lda_train(X, 3, 0.1, 0.01, 500, 50);
%
%   参考文献:
%       Blei, D.M., Ng, A.Y. & Jordan, M.I. (2003). Latent Dirichlet
%       Allocation. JMLR.
%       Griffiths, T.L. & Steyvers, M. (2004). Finding scientific topics.
%       PNAS.

%% 参数默认值
[n_docs, n_terms] = size(X);
if nargin < 2 || isempty(K), K = 10; end
if nargin < 3 || isempty(alpha), alpha = 50 / K; end
if nargin < 4 || isempty(beta), beta = 0.01; end
if nargin < 5 || isempty(n_iter), n_iter = 1000; end
if nargin < 6 || isempty(burn_in), burn_in = 100; end

%% 将词频矩阵展开为词序列
% 为每个文档构建词列表和对应的词索引
doc_word_list = cell(n_docs, 1);  % 每个文档的词列表
n_total_words = 0;

for d = 1:n_docs
    [~, cols, vals] = find(X(d,:));  % 该文档中的非零词
    words_in_doc = [];
    for w = 1:length(cols)
        words_in_doc = [words_in_doc; repmat(cols(w), vals(w), 1)];
    end
    doc_word_list{d} = words_in_doc;
    n_total_words = n_total_words + length(words_in_doc);
end

%% 初始化
% 为每个词随机分配主题
z = cell(n_docs, 1);  % 每个文档中每个词的主题分配
for d = 1:n_docs
    n_w = length(doc_word_list{d});
    z{d} = randi(K, n_w, 1);
end

% 计数矩阵
n_dk = zeros(n_docs, K);   % 文档d中主题k的计数
n_kw = zeros(K, n_terms);  % 主题k中词w的计数
n_k = zeros(K, 1);         % 主题k的总计数

for d = 1:n_docs
    words = doc_word_list{d};
    for i = 1:length(words)
        topic = z{d}(i);
        word = words(i);
        n_dk(d, topic) = n_dk(d, topic) + 1;
        n_kw(topic, word) = n_kw(topic, word) + 1;
        n_k(topic) = n_k(topic) + 1;
    end
end

%% 坍缩 Gibbs 采样
for iter = 1:n_iter
    for d = 1:n_docs
        words = doc_word_list{d};
        n_w = length(words);

        for i = 1:n_w
            word = words(i);
            old_topic = z{d}(i);

            % 移除当前词的分配
            n_dk(d, old_topic) = n_dk(d, old_topic) - 1;
            n_kw(old_topic, word) = n_kw(old_topic, word) - 1;
            n_k(old_topic) = n_k(old_topic) - 1;

            % 计算每个主题的条件概率
            p_topic = zeros(K, 1);
            for k = 1:K
                % P(z_i = k | z_{-i}, w) ∝
                %   (n_dk(d,k) + alpha) * (n_kw(k,word) + beta) / (n_k(k) + V*beta)
                p_topic(k) = (n_dk(d,k) + alpha) * ...
                    (n_kw(k, word) + beta) / (n_k(k) + n_terms * beta);
            end

            % 采样新主题（手动离散采样，无需 Statistics Toolbox）
            p_topic = p_topic / sum(p_topic);
            cdf = cumsum(p_topic);
            new_topic = find(cdf > rand, 1, 'first');

            % 更新
            z{d}(i) = new_topic;
            n_dk(d, new_topic) = n_dk(d, new_topic) + 1;
            n_kw(new_topic, word) = n_kw(new_topic, word) + 1;
            n_k(new_topic) = n_k(new_topic) + 1;
        end
    end

    % 进度
    if mod(iter, 100) == 0
        fprintf('LDA Gibbs 采样: 迭代 %d/%d\n', iter, n_iter);
    end
end

%% 估计参数（后验期望）
% phi: 主题-词分布
phi = zeros(K, n_terms);
for k = 1:K
    phi(k, :) = (n_kw(k, :) + beta) / (n_k(k) + n_terms * beta);
end

% theta: 文档-主题分布
theta = zeros(n_docs, K);
for d = 1:n_docs
    theta(d, :) = (n_dk(d, :) + alpha) / (sum(n_dk(d,:)) + K * alpha);
end

%% 存储模型
model.theta = theta;
model.phi = phi;
model.topic_counts = n_k;
model.K = K;
model.alpha = alpha;
model.beta = beta;
model.n_iter = n_iter;

end


function [top_words, scores] = lda_top_words(model, topic_idx, n_words)
% LDA_TOP_WORDS 获取主题下概率最高的词
if nargin < 3 || isempty(n_words), n_words = 10; end
[scores, top_words] = maxk(model.phi(topic_idx, :), n_words);
end


function topics = lda_doc_topics(model, doc_idx)
% LDA_DOC_TOPICS 获取文档的主题分布
topics = model.theta(doc_idx, :);
end


function ppx = lda_perplexity(model, X_test)
% LDA_PERPLEXITY 计算留出数据的困惑度
%
%   困惑度 = exp(-log_likelihood / total_word_count)
%   困惑度越低模型越好

[n_docs, n_terms] = size(X_test);
K = model.K;

log_lik = 0;
total_words = 0;

for d = 1:n_docs
    [~, cols, vals] = find(X_test(d,:));
    for wi = 1:length(cols)
        w = cols(wi);
        count = vals(wi);

        % P(w | d) = sum_k P(w|z=k) * P(z=k|d)
        prob = model.theta(d, :) * model.phi(:, w);

        if prob > 1e-300
            log_lik = log_lik + count * log(prob);
        end
        total_words = total_words + count;
    end
end

ppx = exp(-log_lik / total_words);

end

%% Self-test
function self_test()
    % Test LDA with tiny corpus (3 docs, 4 words)
    rng(42, 'twister');
    X = [3 0 1 0; 0 2 0 1; 1 1 0 0];
    model = lda_train(X, 2, 0.1, 0.01, 100, 10);
    assert(size(model.theta, 1) == 3, 'Test failed: theta should have 3 docs.');
    assert(size(model.phi, 1) == 2, 'Test failed: phi should have 2 topics.');
    [top_words, scores] = lda_top_words(model, 1, 3);
    assert(length(top_words) <= 3, 'Test failed: top_words should have at most 3 entries.');
    topics = lda_doc_topics(model, 1);
    assert(length(topics) == 2, 'Test failed: doc_topics should have 2 entries.');
    disp('lda_train self-test passed.');
end
