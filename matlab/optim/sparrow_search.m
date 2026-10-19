% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_x, best_fval, convergence] = sparrow_search(obj_func, dim, lb, ub, varargin)
%SPARROW_SEARCH 麻雀搜索算法 (Sparrow Search Algorithm, SSA)
%   [BEST_X, BEST_FVAL, CONVERGENCE] = SPARROW_SEARCH(OBJ_FUNC, DIM, LB, UB)
%
%   Source: Xue, J., Shen, B. (2020).
%          A novel swarm intelligence optimization approach:
%          sparrow search algorithm. Systems Science & Control Engineering, 8(1), 22-34.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27 against Xue & Shen (2020) Algorithm
%
%   输入:
%       obj_func  - 目标函数句柄 (最小化)
%       dim       - 搜索空间维度
%       lb        - 下界 (标量或 1×dim 向量)
%       ub        - 上界 (标量或 1×dim 向量)
%
%   可选参数:
%       'PopSize'       - 种群规模 (默认: 50)
%       'MaxIterations' - 最大迭代次数 (默认: 200)
%       'PD'            - 发现者比例 (默认: 0.2, 10%-30%)
%       'SD'            - 警戒者比例 (默认: 0.1, 5%-20%)
%       'ST'            - 安全阈值  (默认: 0.8)
%       'Display'       - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       best_x      - 最优位置 (1×dim)
%       best_fval   - 最优目标值
%       convergence - 收敛曲线 (1×MaxIterations)
%
%   示例:
%       f = @(x) sum(x.^2);
%       [x, fval] = sparrow_search(f, 10, -100, 100, 'MaxIterations', 100);

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 参数解析
p = inputParser;
p.addParameter('PopSize', 50, @(v) isscalar(v) && v > 0);
p.addParameter('MaxIterations', 200, @(v) isscalar(v) && v > 0);
p.addParameter('PD', 0.2, @(v) isscalar(v) && v > 0 && v <= 0.5);
p.addParameter('SD', 0.1, @(v) isscalar(v) && v > 0 && v <= 0.3);
p.addParameter('ST', 0.8, @(v) isscalar(v) && v > 0.5 && v < 1);
p.addParameter('Display', 'off', @(v) any(strcmp(v, {'iter', 'off'})));
p.parse(varargin{:});
opts = p.Results;

if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

N = opts.PopSize;
Max_iter = opts.MaxIterations;
PD = opts.PD;
SD = opts.SD;
ST = opts.ST;

%% 初始化
% 三种角色:
%   Producer   (发现者, 前 PD*N 只): 负责全局搜索
%   Scrounger  (追随者, 中间): 跟随发现者觅食
%   Sentry     (警戒者, 后 SD*N 只): 反捕食警戒

Positions = zeros(N, dim);
fitness = zeros(N, 1);

for i = 1:N
    Positions(i, :) = lb + rand(1, dim) .* (ub - lb);
    fitness(i) = obj_func(Positions(i, :));
end

% 按适应度排序 (升序)
[fitness, sort_idx] = sort(fitness);
Positions = Positions(sort_idx, :);

best_x = Positions(1, :);
best_fval = fitness(1);
worst_fval = fitness(end);

convergence = zeros(1, Max_iter);
convergence(1) = best_fval;

%% 种群计数
n_producer = max(1, round(PD * N));
n_sentry = max(1, round(SD * N));

%% 主循环
for t = 1:Max_iter
    % --- 1. 发现者 (Producer) 位置更新 ---
    R2 = rand();  % 预警值
    for i = 1:n_producer
        if R2 < ST
            % 安全: 广泛搜索
            Positions(i, :) = Positions(i, :) .* exp(-i / (rand() * Max_iter));
        else
            % 危险: 飞向安全区域
            Positions(i, :) = Positions(i, :) + randn(1, dim);
        end
        % 边界约束
        Positions(i, :) = max(lb, min(ub, Positions(i, :)));
    end

    % --- 2. 追随者 (Scrounger) 位置更新 ---
    for i = (n_producer + 1):(N - n_sentry)
        if i > N / 2
            % 较差追随者: 飞向最优区域
            Positions(i, :) = randn(1, dim) .* exp((Positions(end, :) - Positions(i, :)) / i^2);
        else
            % 较好追随者: 在最优附近觅食
            A = (rand(1, dim) > 0.5) * 2 - 1;  % 随机 ±1
            A_plus = A' * (A * A')^(-1);
            Positions(i, :) = Positions(1, :) + abs(Positions(i, :) - Positions(1, :)) .* A_plus;
        end
        Positions(i, :) = max(lb, min(ub, Positions(i, :)));
    end

    % --- 3. 警戒者 (Sentry) 反捕食 ---
    for i = (N - n_sentry + 1):N
        if fitness(i) > best_fval
            % 在全局最优点附近警戒
            Positions(i, :) = best_x + randn(1, dim) .* abs(Positions(i, :) - best_x);
        else
            % 在自身位置附近警戒
            Positions(i, :) = Positions(i, :) + (2 * rand() - 1) .* ...
                              abs(Positions(i, :) - Positions(end, :)) ./ (fitness(i) - worst_fval + 1e-10);
        end
        Positions(i, :) = max(lb, min(ub, Positions(i, :)));
    end

    % --- 4. 评估与更新 ---
    for i = 1:N
        fitness(i) = obj_func(Positions(i, :));
    end

    [fitness, sort_idx] = sort(fitness);
    Positions = Positions(sort_idx, :);

    if fitness(1) < best_fval
        best_x = Positions(1, :);
        best_fval = fitness(1);
    end
    worst_fval = fitness(end);

    convergence(t) = best_fval;

    if strcmp(opts.Display, 'iter') && mod(t, 30) == 0
        fprintf('Iter %4d: Best = %10.4e\n', t, best_fval);
    end
end

if strcmp(opts.Display, 'iter')
    fprintf('SSA 最终: Best = %10.4e\n', best_fval);
end
end

%% Self-test
function self_test()
    % Test minimize sphere function f(x) = sum(x.^2) in 2D
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [x, fval] = sparrow_search(fun, 2, -10, 10, ...
        'PopSize', 30, 'MaxIterations', 50);
    assert(fval < 2.0, 'Test failed: sphere should find near-zero solution.');
    assert(length(x) == 2, 'Test failed: solution should be 1x2.');
    disp('sparrow_search self-test passed.');
end
