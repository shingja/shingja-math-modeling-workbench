% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% test_ml_algorithms.m
% 10 个新增 ML 算法 MATLAB 实现的单元测试
% v2.1.0 — 2026-07-27
%
% 用法: matlab -batch "cd('matlab/'); test_ml_algorithms;"

clc; clear; close all;
fprintf('========================================\n');
fprintf('  ML 算法 MATLAB 实现 — 单元测试\n');
fprintf('  v2.1.0\n');
fprintf('========================================\n\n');

pass_count = 0;
fail_count = 0;

%% ===== 1. 感知机测试 =====
fprintf('[1/10] 感知机 (Perceptron) ... ');

try
    % 线性可分数据
    X = [3 3; 4 3; 1 1];
    y = [1; 1; -1];
    [w, b, n_iter] = perceptron(X, y, 1.0, 1000);

    % 验证：所有样本应被正确分类
    pred = sign(X * w + b);
    assert(all(pred == y), '感知机未正确分类线性可分数据');
    assert(n_iter > 0, '应至少迭代一次');
    assert(size(w,1) == size(X,2), '权重维度错误');

    fprintf('PASS (收敛于 %d 次迭代)\n', n_iter);
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 2. KNN 测试 =====
fprintf('[2/10] k近邻法 (KNN) ... ');

try
    X_train = [1 1; 1 2; 2 2; 5 5; 5 6; 6 5];
    y_train = [1; 1; 1; 2; 2; 2];
    X_test = [1.5 1.5; 5.5 5.5; 3 3];
    y_expected = [1; 2; 1];

    pred = knn_predict(X_train, y_train, X_test, 3, 'euclidean');
    assert(isequal(pred, y_expected), sprintf('KNN 结果错误，期望 [1;2;1], 得到 [%d;%d;%d]', pred));

    % 曼哈顿距离测试
    pred_m = knn_predict(X_train, y_train, X_test(1:2,:), 3, 'manhattan');
    assert(length(pred_m) == 2, '输出维度错误');

    fprintf('PASS\n');
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 3. 朴素贝叶斯测试 =====
fprintf('[3/10] 朴素贝叶斯 (Naive Bayes) ... ');

try
    rng(42);
    X1 = randn(50, 3) + 1;
    X2 = randn(50, 3) - 1;
    X = [X1; X2];
    y = [ones(50,1); 2*ones(50,1)];

    % 高斯朴素贝叶斯
    model = naive_bayes_train(X, y, 'gaussian');
    [pred, proba] = naive_bayes_predict(model, X);
    acc = mean(pred == y);
    assert(acc > 0.80, sprintf('高斯NB精度过低: %.2f', acc));
    assert(all(size(proba) == [100, 2]), sprintf('概率矩阵维度错误: %dx%d', size(proba)));

    % 伯努利朴素贝叶斯
    X_bin = double(X > 0);
    model_bnb = naive_bayes_train(X_bin, y, 'bernoulli');
    pred_bnb = naive_bayes_predict(model_bnb, X_bin);

    fprintf('PASS (Gaussian: %.1f%%, Bernoulli: %.1f%%)\n', ...
        acc*100, mean(pred_bnb == y)*100);
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 4. 逻辑斯谛回归测试 =====
fprintf('[4/10] 逻辑斯谛回归 (Logistic Regression) ... ');

try
    rng(42);
    n = 100; d = 5;
    X = randn(n, d);
    true_w = [1; -0.5; 0.8; -1.2; 0.3];
    y = double(X * true_w + 0.5 * randn(n,1) > 0) + 1;

    model = logistic_regression_train(X, y, ...
        'learning_rate', 0.05, 'max_iter', 500, ...
        'regularization', 'l2', 'lambda', 0.01, 'verbose', false);

    [pred, proba] = logistic_regression_predict(model, X);
    acc = mean(pred == y);
    assert(acc > 0.70, sprintf('逻辑回归精度过低: %.2f', acc));
    assert(size(proba,2) == 2, sprintf('概率矩阵列数错误: %d', size(proba,2)));

    % 多分类 Softmax
    y_multi = [ones(30,1); 2*ones(30,1); 3*ones(40,1)];
    X_multi = randn(100, 3);
    model_multi = logistic_regression_train(X_multi, y_multi, ...
        'multi_class', 'softmax', 'max_iter', 300);
    pred_multi = logistic_regression_predict(model_multi, X_multi);

    fprintf('PASS (二分类: %.1f%%, Softmax: %.1f%%)\n', ...
        acc*100, mean(pred_multi == y_multi)*100);
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 5. SVD 测试 =====
fprintf('[5/10] 奇异值分解 (SVD) ... ');

try
    A = randn(50, 30);
    k = 10;

    [U, S, V, ev] = svd_decompose(A, k, 'full');
    assert(size(U,2) == k && size(V,2) == k, 'SVD 输出维度错误');
    assert(abs(sum(ev) - 1) < 1e-10, '方差解释率之和不等于1');

    % 随机化 SVD
    [U_r, S_r, V_r, ~] = svd_decompose(A, k, 'randomized');
    A_approx = U_r * S_r * V_r';
    rel_error = norm(A - A_approx, 'fro') / norm(A, 'fro');
    assert(rel_error < 0.65, sprintf('随机化SVD重构误差过大: %.3f', rel_error));

    fprintf('PASS (完整: %.1f%%能量, 随机化: rel.err=%.3f)\n', ...
        sum(ev)*100, rel_error);
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 6. PageRank 测试 =====
fprintf('[6/10] PageRank ... ');

try
    % 4节点有向图: 1→2, 2→3, 3→1, 3→4, 4→1
    A = [0 0 1 1; 1 0 0 0; 0 1 0 0; 0 0 1 0];
    [PR, n_iter] = pagerank(A, 0.85);
    assert(abs(sum(PR) - 1) < 1e-10, 'PageRank 向量未归一化');
    assert(all(PR > 0), 'PageRank 值应全为正');
    assert(n_iter <= 100, '应在100次内收敛');

    % 验证：节点3 (被1,2引用) + 指向4 = 应有较高分
    [~, top_node] = max(PR);
    fprintf('PASS (%d 次迭代, 最高分节点: %d, PR=%.3f)\n', ...
        n_iter, top_node, max(PR));
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 7. LSA 测试 =====
fprintf('[7/10] 潜在语义分析 (LSA) ... ');

try
    X = [3 0 1 0 2; 0 2 0 1 0; 1 0 4 0 0; 0 0 0 3 1; 0 5 0 0 0; 0 0 0 0 4];
    k = 2;

    model = lsa_train(X, k, 'tfidf');
    assert(model.k == k, '主题数不匹配');
    assert(size(model.U,2) == k, '词-语义矩阵维度错误');
    assert(size(model.V,2) == k, '文档-语义矩阵维度错误');

    % 文档相似度
    sim = lsa_similarity(model, 'doc', 1, 2);
    assert(abs(sim) <= 1 + 1e-6, '相似度应在[-1,1]内');

    % 查询映射
    q = [1; 0; 1; 0; 0; 0];
    q_vec = lsa_query(model, q);
    [top_docs, scores] = lsa_search(model, q_vec, 3);
    assert(~isempty(top_docs), '查询应返回结果');

    fprintf('PASS (文档1-2相似度: %.3f, 查询命中: %d篇)\n', ...
        sim, length(top_docs));
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 8. PLSA 测试 =====
fprintf('[8/10] 概率潜在语义分析 (PLSA) ... ');

try
    rng(42);
    X = [5 3 0 0 1 0; 1 2 4 0 0 0; 0 0 3 5 2 0; 0 0 0 1 0 4; 2 0 0 0 3 1];
    K = 2;

    model = plsa_train(X, K, 100, 1e-3);

    % 验证概率归一化
    assert(all(abs(sum(model.P_z_given_d, 2) - 1) < 1e-5), ...
        '文档-主题分布未归一化');
    assert(all(abs(sum(model.P_w_given_z, 2) - 1) < 1e-5), ...
        '主题-词分布未归一化');

    % 获取主题词
    [words1, ~] = plsa_top_words(model, 1, 3);
    [words2, ~] = plsa_top_words(model, 2, 3);

    fprintf('PASS (似然: %.2f, 主题1词: [%s])\n', ...
        model.log_likelihood_history(end), num2str(words1'));
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 9. LDA 测试 =====
fprintf('[9/10] 潜在狄利克雷分配 (LDA) ... ');

try
    rng(42);
    X = [5 3 0 0 1 0 0 0;
         1 2 4 0 0 0 0 0;
         0 0 3 5 2 0 0 0;
         0 0 0 1 0 4 0 0;
         2 0 0 0 3 0 1 0];
    K = 3;

    model = lda_train(X, K, 0.5, 0.1, 500, 100);

    assert(all(abs(sum(model.theta, 2) - 1) < 1e-5), ...
        '文档主题分布未归一化');
    assert(all(abs(sum(model.phi, 2) - 1) < 1e-5), ...
        '主题词分布未归一化');

    [w1, ~] = lda_top_words(model, 1, 3);
    topics = lda_doc_topics(model, 1);
    assert(length(topics) == K, '文档主题向量长度应等于K');

    fprintf('PASS (主题1 Top3词: [%s])\n', num2str(w1'));
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 10. MCMC 测试 =====
fprintf('[10/10] 马尔可夫链蒙特卡洛 (MCMC) ... ');

try
    rng(42);

    % MH: 从二维标准正态采样
    target_logpdf = @(x) -0.5 * sum(x.^2);
    proposal_samp = @(x) x + 0.2 * randn(size(x));
    proposal_logpdf = @(x_new, x_old) 0;

    [samples_mh, accept_rate, diag] = metropolis_hastings(...
        target_logpdf, proposal_samp, proposal_logpdf, [0; 0], 2000, 500);

    sample_mean = mean(samples_mh, 1);
    assert(all(abs(sample_mean) < 0.5), ...
        sprintf('MH采样均值偏离零: [%.3f, %.3f]', sample_mean));
    assert(size(samples_mh, 1) == 2000, '采样数量不对');
    assert(accept_rate > 0.1 && accept_rate < 0.95, ...
        sprintf('接受率异常: %.2f', accept_rate));

    % Gibbs: 二元正态
    rho = 0.7;
    sampler1 = @(x2) rho * x2 + sqrt(1 - rho^2) * randn();
    sampler2 = @(x1) rho * x1 + sqrt(1 - rho^2) * randn();
    [samples_gibbs] = gibbs_sampler({sampler1, sampler2}, [0; 0], 2000, 500);
    assert(size(samples_gibbs, 1) == 2000, 'Gibbs采样数量不对');

    % ESS 检查
    assert(diag.ESS > 10, sprintf('有效样本量过低: %.0f', diag.ESS));

    fprintf('PASS (MH接受率: %.2f, ESS: %.0f)\n', ...
        accept_rate, diag.ESS);
    pass_count = pass_count + 1;
catch ME
    fprintf('FAIL: %s\n', ME.message);
    fail_count = fail_count + 1;
end

%% ===== 结果汇总 =====
fprintf('\n========================================\n');
fprintf('  测试结果: %d 通过 / %d 失败 / %d 总计\n', ...
    pass_count, fail_count, pass_count + fail_count);
if fail_count == 0
    fprintf('  ALL TESTS PASSED\n');
else
    fprintf('  WARNING: %d tests FAILED\n', fail_count);
end
fprintf('========================================\n');
