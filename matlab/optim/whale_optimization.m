% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_pos, best_score, convergence] = whale_optimization(obj_func, dim, lb, ub, varargin)
%WHALE_OPTIMIZATION 鲸鱼优化算法 (Whale Optimization Algorithm, WOA)
%   [BEST_POS, BEST_SCORE, CONVERGENCE] = WHALE_OPTIMIZATION(OBJ_FUNC, DIM, LB, UB)
%
%   Source: Mirjalili, S., Lewis, A. (2016).
%          The Whale Optimization Algorithm.
%          Advances in Engineering Software, 95, 51-67.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Mirjalili & Lewis (2016) Algorithm 1
%
%   输入:
%       obj_func  - 目标函数句柄 (最小化)
%       dim       - 搜索空间维度
%       lb        - 下界 (标量或向量)
%       ub        - 上界 (标量或向量)
%
%   可选参数:
%       'SearchAgents'  - 鲸群规模 (默认: 30)
%       'MaxIterations' - 最大迭代次数 (默认: 200)
%       'Display'       - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       best_pos     - 最优位置
%       best_score   - 最优目标值 (最小化)
%       convergence  - 收敛曲线
%
%   示例:
%       f = @(x) sum(x.^2);
%       [pos, score] = whale_optimization(f, 5, -100, 100);

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 参数解析
p = inputParser;
p.addParameter('SearchAgents', 30, @(v) isscalar(v) && v > 0);
p.addParameter('MaxIterations', 200, @(v) isscalar(v) && v > 0);
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.parse(varargin{:});
opts = p.Results;

SearchAgents_no = opts.SearchAgents;
Max_iter = opts.MaxIterations;

if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

%% 初始化
Positions = zeros(SearchAgents_no, dim);
for i = 1:SearchAgents_no
    Positions(i, :) = lb + rand(1, dim) .* (ub - lb);
end

best_score = inf;
best_pos = zeros(1, dim);
convergence = zeros(1, Max_iter);

%% 主循环
for t = 1:Max_iter
    % 评估并更新最优
    for i = 1:SearchAgents_no
        Positions(i, :) = max(lb, min(ub, Positions(i, :)));
        fitness = obj_func(Positions(i, :));

        if fitness < best_score
            best_score = fitness;
            best_pos = Positions(i, :);
        end
    end

    % 参数 a: 线性从 2 衰减到 0
    a = 2 - t * (2 / Max_iter);

    for i = 1:SearchAgents_no
        r1 = rand(); r2 = rand();
        A = 2 * a * r1 - a;
        C = 2 * r2;

        p = rand();  % 随机选择捕食策略
        l = -1 + 2 * rand();  % [-1, 1] 用于螺旋更新

        if p < 0.5
            % --- 包围猎物 (Encircling) ---
            if abs(A) < 1
                % 向当前最优移动 (Exploitation)
                D = abs(C * best_pos - Positions(i, :));
                Positions(i, :) = best_pos - A * D;
            else
                % 随机搜索 (Exploration)
                rand_idx = randi([1, SearchAgents_no]);
                X_rand = Positions(rand_idx, :);
                D = abs(C * X_rand - Positions(i, :));
                Positions(i, :) = X_rand - A * D;
            end
        else
            % --- 螺旋气泡网攻击 (Spiral Bubble-net) ---
            D_prime = abs(best_pos - Positions(i, :));
            Positions(i, :) = D_prime .* exp(l) .* cos(2 * pi * l) + best_pos;
            % 注意: 原始论文 cos 参数为 2*pi*l, exp(b*l) 中 b=1
        end
    end

    convergence(t) = best_score;

    if strcmp(opts.Display, 'iter') && mod(t, 20) == 0
        fprintf('Iter %4d: Best = %10.4e\n', t, best_score);
    end
end

if strcmp(opts.Display, 'iter')
    fprintf('Final: Best = %10.4e\n', best_score);
end
end

%% Self-test
function self_test()
    % Test minimize sphere function f(x) = sum(x.^2) in 2D
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [pos, score] = whale_optimization(fun, 2, -10, 10, ...
        'SearchAgents', 20, 'MaxIterations', 50);
    assert(score < 2.0, 'Test failed: sphere should find near-zero solution.');
    assert(length(pos) == 2, 'Test failed: solution should be 1x2.');
    disp('whale_optimization self-test passed.');
end
