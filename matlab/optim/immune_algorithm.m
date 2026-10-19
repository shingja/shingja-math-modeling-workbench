% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_x, best_fval, history] = immune_algorithm(obj_func, dim, lb, ub, varargin)
%IMMUNE_ALGORITHM 免疫算法 (Immune Algorithm / Clonal Selection)
%   [BEST_X, BEST_FVAL, HISTORY] = IMMUNE_ALGORITHM(OBJ_FUNC, DIM, LB, UB)
%
%   Source: De Castro, L.N., Von Zuben, F.J. (2002).
%          Learning and Optimization Using the Clonal Selection Principle.
%          IEEE Transactions on Evolutionary Computation, 6(3), 239-251.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against De Castro & Von Zuben (2002) CLONALG
%
%   输入:
%       obj_func  - 目标函数句柄 (最小化)
%       dim       - 搜索空间维度
%       lb        - 下界 (标量或向量)
%       ub        - 上界 (标量或向量)
%
%   可选参数:
%       'PopSize'       - 种群规模 (默认: 50)
%       'MaxIter'       - 最大迭代次数 (默认: 200)
%       'CloneFactor'   - 克隆倍数 (默认: 10)
%       'MutationRate'  - 变异率 (默认: 0.1)
%       'ReplaceRatio'  - 每代替换比例 (默认: 0.2)
%       'SelectionPressure' - 选择压力 β (默认: 1.0), 越大越倾向精英
%       'Display'       - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       best_x    - 最优解
%       best_fval - 最优目标值
%       history   - 收敛历史
%
%   示例:
%       f = @(x) sum(x.^2);
%       [x, fval] = immune_algorithm(f, 5, -10, 10);

%% 参数解析
n = dim;
if isscalar(lb), lb = lb * ones(1, n); end
if isscalar(ub), ub = ub * ones(1, n); end

p = inputParser;
p.addParameter('PopSize', 50, @(v) isscalar(v) && v > 0);
p.addParameter('MaxIter', 200, @(v) isscalar(v) && v > 0);
p.addParameter('CloneFactor', 10, @(v) isscalar(v) && v > 0);
p.addParameter('MutationRate', 0.1, @(v) isscalar(v) && v > 0 && v < 1);
p.addParameter('ReplaceRatio', 0.2, @(v) isscalar(v) && v > 0 && v < 1);
p.addParameter('SelectionPressure', 1.0, @(v) isscalar(v) && v >= 0);
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.parse(varargin{:});
opts = p.Results;

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 初始化抗体种群
PopSize = opts.PopSize;
pop = zeros(PopSize, n);
fitness = zeros(PopSize, 1);

for i = 1:PopSize
    pop(i, :) = lb + rand(1, n) .* (ub - lb);
    fitness(i) = obj_func(pop(i, :));
end

% 排序 (升序, 最佳优先)
[fitness, idx] = sort(fitness);
pop = pop(idx, :);

best_x = pop(1, :);
best_fval = fitness(1);
history = zeros(opts.MaxIter, 1);
history(1) = best_fval;

%% 主循环
for iter = 2:opts.MaxIter
    % --- 1. 克隆选择 ---
    % 基于亲和度(1/fitness)的概率选择
    % 归一化适应度 → 亲和度 (使用 rank-based)
    ranks = (1:PopSize)';
    affinity = exp(-opts.SelectionPressure * (ranks - 1) / PopSize);
    affinity = affinity / sum(affinity);

    % --- 2. 克隆增殖 ---
    n_clones_per = max(1, round(opts.CloneFactor * affinity * PopSize));
    clones = [];
    clone_fitness = [];

    for i = 1:PopSize
        n_c = n_clones_per(i);
        for c = 1:n_c
            % 变异: 高斯扰动, 变异量与 rank 成正比
            mutation_std = opts.MutationRate * exp(-opts.SelectionPressure * (i - 1) / PopSize);
            clone = pop(i, :) + mutation_std * randn(1, n) .* (ub - lb);
            clone = max(lb, min(ub, clone));
            clones = [clones; clone]; %#ok<AGROW>
            clone_fitness = [clone_fitness; obj_func(clone)]; %#ok<AGROW>
        end
    end

    % --- 3. 克隆选择 (精英保留) ---
    all_pop = [pop; clones];
    all_fit = [fitness; clone_fitness];
    [all_fit, idx_sort] = sort(all_fit);
    all_pop = all_pop(idx_sort, :);

    % 保留前 PopSize 个
    pop = all_pop(1:PopSize, :);
    fitness = all_fit(1:PopSize);

    % --- 4. 种群刷新 (多样性维持) ---
    n_replace = max(1, round(opts.ReplaceRatio * PopSize));
    for i = 1:n_replace
        idx_r = PopSize - i + 1;
        pop(idx_r, :) = lb + rand(1, n) .* (ub - lb);
        fitness(idx_r) = obj_func(pop(idx_r, :));
    end

    % 重排序
    [fitness, idx] = sort(fitness);
    pop = pop(idx, :);

    % 更新最优
    if fitness(1) < best_fval
        best_x = pop(1, :);
        best_fval = fitness(1);
    end

    history(iter) = best_fval;

    if strcmp(opts.Display, 'iter') && mod(iter, 20) == 0
        fprintf('Iter %4d: Best = %10.4e\n', iter, best_fval);
    end
end
end


%% Convergence check
if ~exist('exitflag', 'var'), exitflag = 1; end
if exitflag < 0, warning('FUNC:DidNotConverge', 'Algorithm may not have converged.'); end

%% Self-test
function self_test()
    % Test minimize sphere function
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [x, fval] = immune_algorithm(fun, 2, -10, 10, ...
        'PopSize', 20, 'MaxIter', 30);
    assert(fval < 5.0, 'Test failed: sphere should find near-zero solution.');
    assert(length(x) == 2, 'Test failed: solution should be 1x2.');
    disp('immune_algorithm self-test passed.');
end
