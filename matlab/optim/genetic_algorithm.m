% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_best, f_best, history, exitflag] = genetic_algorithm(obj_func, dim, lb, ub, varargin)
%GENETIC_ALGORITHM 遗传算法 (Genetic Algorithm, GA) — 实数编码自实现
%   [X_BEST, F_BEST, HISTORY, EXITFLAG] = GENETIC_ALGORITHM(OBJ_FUNC, DIM, LB, UB)
%   实数编码遗传算法: 均匀初始化种群 → 轮盘赌选择 (按适应度比例) →
%   算术交叉 (Pc) → 高斯变异 (Pm, 步长随代数收缩) → 精英保留。
%   不依赖 Sheffield gatbx 工具箱与 Global Optimization Toolbox。
%
%   Source: Holland, J.H. (1975). Adaptation in Natural and Artificial
%          Systems. University of Michigan Press.
%          Goldberg, D.E. (1989). Genetic Algorithms in Search,
%          Optimization and Machine Learning. Addison-Wesley.
%          教材: 数模加油站《智能优化-遗传优化》Matlab/ (Sheffield gatbx 工具箱参考)
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 球函数 2 维收敛
%
%   输入:
%       obj_func - 目标函数句柄 f = obj_func(x), x 为 1×dim 向量 (最小化)
%       dim      - 搜索空间维度
%       lb       - 下界 (标量或 1×dim 向量)
%       ub       - 上界 (标量或 1×dim 向量)
%
%   可选参数 (名值对):
%       'PopSize'           - 种群规模 (默认: 50)
%       'MaxGenerations'    - 最大代数 (默认: 200)
%       'CrossoverProb'     - 交叉概率 (默认: 0.8)
%       'MutationProb'      - 变异概率 (默认: 0.1)
%       'EliteCount'        - 精英保留个数 (默认: 2)
%       'TolFun'            - 停滞判据: 最优值变化阈值 (默认: 1e-8)
%       'StallGen'          - 连续停滞代数, 超过则收敛 (默认: 30)
%       'Seed'              - 随机种子 (默认: 42)
%       'Display'           - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       x_best   - 最优个体 1×dim
%       f_best   - 最优目标函数值
%       history  - struct: fval_history (1×T 每代最优值曲线)
%       exitflag - 1: 连续 StallGen 代停滞收敛; 0: 达到 MaxGenerations
%
%   示例:
%       f = @(x) sum((x - 1).^2);
%       [x, fval] = genetic_algorithm(f, 5, -10, 10, 'Display', 'iter');
%
%   注意:
%       - 实数编码适合连续优化; 二进制编码可通过对变量离散化实现,
%         数模中连续问题优先用本实现。
%       - 轮盘赌选择对适应度尺度敏感 (负值已平移处理); 精英保留防止最优丢失。
%       - 随机算法: 结果依赖 Seed, 建议多次运行取最优。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('obj_func', @(x) isa(x, 'function_handle'));
p.addRequired('dim', @(x) isscalar(x) && x > 0 && mod(x, 1) == 0);
p.addRequired('lb', @(x) isnumeric(x));
p.addRequired('ub', @(x) isnumeric(x));
p.addParameter('PopSize', 50, @(x) isscalar(x) && x > 0);
p.addParameter('MaxGenerations', 200, @(x) isscalar(x) && x > 0);
p.addParameter('CrossoverProb', 0.8, @(x) isscalar(x) && x >= 0 && x <= 1);
p.addParameter('MutationProb', 0.1, @(x) isscalar(x) && x >= 0 && x <= 1);
p.addParameter('EliteCount', 2, @(x) isscalar(x) && x >= 0 && mod(x, 1) == 0);
p.addParameter('TolFun', 1e-8, @(x) isscalar(x) && x >= 0);
p.addParameter('StallGen', 30, @(x) isscalar(x) && x > 0);
p.addParameter('Seed', 42, @(x) isscalar(x) && x >= 0);
p.addParameter('Display', 'off', @(x) any(strcmp(x, {'iter', 'off'})));
p.parse(obj_func, dim, lb, ub, varargin{:});
opts = p.Results;

% 展开标量边界
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end
if any(ub <= lb)
    error('genetic_algorithm:BadBounds', '上界必须严格大于下界。');
end
if opts.EliteCount > opts.PopSize
    error('genetic_algorithm:BadEliteCount', 'EliteCount 不能超过 PopSize。');
end
rng(opts.Seed, 'twister');

%% 初始化种群 (均匀分布)
pop = lb + rand(opts.PopSize, dim) .* (ub - lb);
fitness = arrayfun(@(i) obj_func(pop(i, :)), (1:opts.PopSize)');
[f_best, best_idx] = min(fitness);
x_best = pop(best_idx, :);

history.fval_history = zeros(1, opts.MaxGenerations);
exitflag = 0;
stall = 0;

%% 进化主循环
for gen = 1:opts.MaxGenerations
    % ---- 适应度尺度化 (最小化问题, 平移+取倒数作轮盘赌权重) ----
    f_max = max(fitness);
    w = (f_max - fitness) + eps;
    w = w / sum(w);                 % 选择概率, 归一化
    cumw = cumsum(w);

    % ---- 精英保留 ----
    [sorted_f, sorted_idx] = sort(fitness);
    new_pop = pop(sorted_idx(1:opts.EliteCount), :);
    new_fit = sorted_f(1:opts.EliteCount);

    % ---- 选择 + 交叉 + 变异, 补齐种群 ----
    while size(new_pop, 1) < opts.PopSize
        % 轮盘赌选择两个父代
        par = zeros(2, dim);
        for q = 1:2
            r = rand();
            pick = find(cumw >= r, 1, 'first');
            if isempty(pick), pick = opts.PopSize; end
            par(q, :) = pop(pick, :);
        end

        % 算术交叉: 子代 = alpha*p1 + (1-alpha)*p2
        if rand() < opts.CrossoverProb
            alpha = rand();
            child = alpha * par(1, :) + (1 - alpha) * par(2, :);
        else
            child = par(1, :);
        end

        % 高斯变异: 步长随代数收缩 (前期探索, 后期精化)
        if rand() < opts.MutationProb
            sigma_m = 0.1 * (ub - lb) .* (1 - gen / opts.MaxGenerations);
            child = child + sigma_m .* randn(1, dim);
        end

        % 边界回弹
        child = max(lb, min(ub, child));
        new_pop(end+1, :) = child; %#ok<AGROW>
        new_fit(end+1) = obj_func(child); %#ok<AGROW>
    end

    pop = new_pop;
    fitness = new_fit;

    % ---- 更新最优与停滞判据 ----
    [gen_best, gen_best_idx] = min(fitness);
    if gen_best < f_best
        f_best = gen_best;
        x_best = pop(gen_best_idx, :);
        stall = 0;
    else
        stall = stall + 1;
    end
    history.fval_history(gen) = f_best;

    if stall >= opts.StallGen
        exitflag = 1;
        break;
    end

    if strcmp(opts.Display, 'iter') && (gen == 1 || mod(gen, 20) == 0)
        fprintf('Gen %4d: Best = %12.6e\n', gen, f_best);
    end
end

history.fval_history = history.fval_history(1:gen);

if strcmp(opts.Display, 'iter')
    fprintf('Final: Best = %12.6e (exitflag=%d)\n', f_best, exitflag);
end

%% 收敛语义检查
if exitflag < 0
    warning('genetic_algorithm:DidNotConverge', '遗传算法未正常收敛。');
end
end

%% Self-test
function self_test()
    % 球函数 f(x) = sum(x.^2), 2 维, 最优 (0,0), f*=0
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [x, fval, ~, exitflag] = genetic_algorithm(fun, 2, -10, 10, ...
        'Seed', 42, 'PopSize', 30, 'MaxGenerations', 100, ...
        'EliteCount', 2, 'StallGen', 30);
    assert(exitflag >= 0, 'Test failed: GA should terminate normally.');
    assert(fval < 0.5, sprintf('Test failed: fval=%.4f should be < 0.5.', fval));
    assert(length(x) == 2, 'Test failed: solution should be 1x2.');
    assert(all(x >= -10) && all(x <= 10), 'Test failed: solution out of bounds.');
    disp('genetic_algorithm self-test passed.');
end
