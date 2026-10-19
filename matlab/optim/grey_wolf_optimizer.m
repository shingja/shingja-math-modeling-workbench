% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [alpha_pos, alpha_score, convergence] = grey_wolf_optimizer(obj_func, dim, lb, ub, varargin)
%GREY_WOLF_OPTIMIZER 灰狼优化算法 (Grey Wolf Optimizer, GWO)
%   [ALPHA_POS, ALPHA_SCORE, CONVERGENCE] = GREY_WOLF_OPTIMIZER(OBJ_FUNC, DIM, LB, UB)
%
%   Source: Mirjalili, S., Mirjalili, S.M., Lewis, A. (2014).
%          Grey Wolf Optimizer. Advances in Engineering Software, 69, 46-61.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Mirjalili et al. (2014) Algorithm 1
%
%   输入:
%       obj_func  - 目标函数句柄 f = obj_func(x), x 为 1×dim 向量
%       dim       - 搜索空间维度
%       lb        - 下界 (标量或 1×dim 向量)
%       ub        - 上界 (标量或 1×dim 向量)
%
%   可选参数 (名值对):
%       'SearchAgents'  - 狼群规模 (默认: 30)
%       'MaxIterations' - 最大迭代次数 (默认: 200)
%       'Display'       - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       alpha_pos   - 最优位置 (1×dim)
%       alpha_score - 最优目标函数值
%       convergence - 收敛曲线 (1×MaxIterations)
%
%   示例:
%       f = @(x) sum(x.^2);
%       [pos, score] = grey_wolf_optimizer(f, 10, -100, 100, 'MaxIterations', 100);

%% 依赖检查
% 仅使用 MATLAB 内置函数，无需额外工具箱

%% 参数解析
p = inputParser;
p.addParameter('SearchAgents', 30, @(v) isscalar(v) && v > 0);
p.addParameter('MaxIterations', 200, @(v) isscalar(v) && v > 0);
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.parse(varargin{:});
opts = p.Results;

SearchAgents_no = opts.SearchAgents;
Max_iter = opts.MaxIterations;

% 展开标量边界
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

%% 初始化狼群位置
Positions = zeros(SearchAgents_no, dim);
for i = 1:SearchAgents_no
    Positions(i, :) = lb + rand(1, dim) .* (ub - lb);
end

% 初始化 Alpha, Beta, Delta
Alpha_pos = zeros(1, dim);
Alpha_score = inf;

Beta_pos = zeros(1, dim);
Beta_score = inf;

Delta_pos = zeros(1, dim);
Delta_score = inf;

convergence = zeros(1, Max_iter);

%% 主循环
for iter = 1:Max_iter
    % 评估所有狼
    for i = 1:SearchAgents_no
        % 边界约束
        Positions(i, :) = max(lb, min(ub, Positions(i, :)));

        fitness = obj_func(Positions(i, :));

        % 更新 Alpha, Beta, Delta
        if fitness < Alpha_score
            Alpha_score = fitness;
            Alpha_pos = Positions(i, :);
        end

        if fitness > Alpha_score && fitness < Beta_score
            Beta_score = fitness;
            Beta_pos = Positions(i, :);
        end

        if fitness > Alpha_score && fitness > Beta_score && fitness < Delta_score
            Delta_score = fitness;
            Delta_pos = Positions(i, :);
        end
    end

    % 线性衰减参数 a: 2 → 0
    a = 2 - iter * (2 / Max_iter);

    % 更新每个狼的位置
    for i = 1:SearchAgents_no
        for j = 1:dim
            % Alpha 引导
            r1 = rand(); r2 = rand();
            A1 = 2 * a * r1 - a;
            C1 = 2 * r2;
            D_alpha = abs(C1 * Alpha_pos(j) - Positions(i, j));
            X1 = Alpha_pos(j) - A1 * D_alpha;

            % Beta 引导
            r1 = rand(); r2 = rand();
            A2 = 2 * a * r1 - a;
            C2 = 2 * r2;
            D_beta = abs(C2 * Beta_pos(j) - Positions(i, j));
            X2 = Beta_pos(j) - A2 * D_beta;

            % Delta 引导
            r1 = rand(); r2 = rand();
            A3 = 2 * a * r1 - a;
            C3 = 2 * r2;
            D_delta = abs(C3 * Delta_pos(j) - Positions(i, j));
            X3 = Delta_pos(j) - A3 * D_delta;

            Positions(i, j) = (X1 + X2 + X3) / 3;
        end
    end

    convergence(iter) = Alpha_score;

    if strcmp(opts.Display, 'iter') && mod(iter, 20) == 0
        fprintf('Iter %4d: Best = %10.4e\n', iter, Alpha_score);
    end
end

if strcmp(opts.Display, 'iter')
    fprintf('Final: Best = %10.4e\n', Alpha_score);
end
end

%% Self-test
function self_test()
    % Test minimize sphere function f(x) = sum(x.^2) in 2D
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [pos, score] = grey_wolf_optimizer(fun, 2, -10, 10, ...
        'SearchAgents', 20, 'MaxIterations', 50);
    assert(score < 2.0, 'Test failed: sphere should find near-zero solution.');
    assert(length(pos) == 2, 'Test failed: solution should be 1x2.');
    disp('grey_wolf_optimizer self-test passed.');
end
