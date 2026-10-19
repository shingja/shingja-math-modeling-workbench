% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_best, f_best, history, exitflag] = simulated_annealing(obj_func, lb, ub, varargin)
%SIMULATED_ANNEALING 模拟退火算法 (Simulated Annealing, SA)
%   [X_BEST, F_BEST, HISTORY, EXITFLAG] = SIMULATED_ANNEALING(OBJ_FUNC, LB, UB)
%   连续空间全局优化。以温度 T 控制搜索, 按 Metropolis 准则以概率
%   exp(-Δf/T) 接受劣解, 温度按 CoolingRate 几何降温, 兼顾全局探索
%   与局部精化; T 降至阈值 Tf 时收敛。
%
%   Source: Kirkpatrick, S., Gelatt, C.D., Vecchi, M.P. (1983).
%          Optimization by simulated annealing. Science, 220(4598),
%          671-680. DOI: 10.1126/science.220.4598.671
%          教材: 数模加油站《智能优化-模拟退火算法》Matlab/SA.m
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 球函数 2 维收敛
%
%   输入:
%       obj_func - 目标函数句柄 f = obj_func(x), x 为 1×dim 向量 (最小化)
%       lb       - 下界 (标量或 1×dim 向量)
%       ub       - 上界 (标量或 1×dim 向量)
%
%   可选参数 (名值对):
%       'X0'          - 初始点 1×dim (默认: 界内随机)
%       'T0'          - 初始温度 (默认: 100)
%       'Tf'          - 终止温度, T<Tf 时收敛 (默认: 1e-8)
%       'CoolingRate' - 降温系数 (0, 1) (默认: 0.9)
%       'MaxIter'     - 最大温度层数 (默认: 300)
%       'MovePerTemp' - 每层温度的扰动次数 (默认: 20)
%       'Seed'        - 随机种子 (默认: 42)
%       'Display'     - 'iter' | 'off' (默认: 'off')
%
%   输出:
%       x_best   - 最优解 1×dim
%       f_best   - 最优目标函数值
%       history  - struct: fval_history (1×T 最优值曲线),
%                  temperature_history (1×T 温度曲线)
%       exitflag - 1: 温度降至 Tf 收敛; 0: 达到 MaxIter 温度层数; -1: 异常
%
%   示例:
%       f = @(x) sum(x.^2);
%       [x, fval] = simulated_annealing(f, -10, 10, 'Display', 'iter');
%
%   注意:
%       - 扰动幅度随温度收缩 (T/T0 比例), 降温过快 (CoolingRate 接近 0.5)
%         易陷入局部极小; 过慢则耗时, 0.85~0.95 为常用区间。
%       - 组合优化 (如 TSP) 需自行定义邻域扰动, 本实现为连续空间版本。
%       - 随机算法: 结果依赖 Seed, 建议多次运行取最优。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('obj_func', @(x) isa(x, 'function_handle'));
p.addRequired('lb', @(x) isnumeric(x));
p.addRequired('ub', @(x) isnumeric(x));
p.addParameter('X0', [], @(x) isempty(x) || isnumeric(x));
p.addParameter('T0', 100, @(x) isscalar(x) && x > 0);
p.addParameter('Tf', 1e-8, @(x) isscalar(x) && x > 0);
p.addParameter('CoolingRate', 0.9, @(x) isscalar(x) && x > 0 && x < 1);
p.addParameter('MaxIter', 300, @(x) isscalar(x) && x > 0);
p.addParameter('MovePerTemp', 20, @(x) isscalar(x) && x > 0);
p.addParameter('Seed', 42, @(x) isscalar(x) && x >= 0);
p.addParameter('Display', 'off', @(x) any(strcmp(x, {'iter', 'off'})));
p.parse(obj_func, lb, ub, varargin{:});
opts = p.Results;

lb = lb(:)'; ub = ub(:)';
dim = length(ub);
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end
if any(ub <= lb)
    error('simulated_annealing:BadBounds', '上界必须严格大于下界。');
end
rng(opts.Seed, 'twister');

%% 初始化
if isempty(opts.X0)
    x_cur = lb + rand(1, dim) .* (ub - lb);
else
    x_cur = opts.X0;
end
x_cur = max(lb, min(ub, x_cur));
f_cur = obj_func(x_cur);
x_best = x_cur;
f_best = f_cur;

T = opts.T0;
history.fval_history = zeros(1, opts.MaxIter);
history.temperature_history = zeros(1, opts.MaxIter);
exitflag = 0;
iter = opts.MaxIter;

%% 退火主循环
for iter = 1:opts.MaxIter
    % ---- 内层: 当前温度下的 Metropolis 扰动链 ----
    for m = 1:opts.MovePerTemp
        % 扰动幅度随温度收缩 (高温大步长探索, 低温小步长精化)
        amp = max(T / opts.T0, 1e-3) * 0.2 .* (ub - lb);
        x_new = x_cur + amp .* randn(1, dim);
        x_new = max(lb, min(ub, x_new));          % 边界回弹
        f_new = obj_func(x_new);
        delta = f_new - f_cur;

        % Metropolis 接受准则: 优解必收, 劣解按概率 exp(-delta/T) 收
        if delta < 0 || rand() < exp(-delta / T)
            x_cur = x_new;
            f_cur = f_new;
            if f_cur < f_best
                x_best = x_cur;
                f_best = f_cur;
            end
        end
    end

    history.fval_history(iter) = f_best;
    history.temperature_history(iter) = T;

    % ---- 收敛判断: 温度降至阈值 ----
    if T < opts.Tf
        exitflag = 1;
        break;
    end

    if strcmp(opts.Display, 'iter') && (iter == 1 || mod(iter, 30) == 0)
        fprintf('Iter %4d: T = %8.2e, Best = %12.6e\n', iter, T, f_best);
    end

    T = T * opts.CoolingRate;                     % 几何降温
end

if iter == opts.MaxIter && exitflag == 0
    exitflag = 0;   % 达到最大温度层数仍未降至 Tf
end

history.fval_history = history.fval_history(1:iter);
history.temperature_history = history.temperature_history(1:iter);

if strcmp(opts.Display, 'iter')
    fprintf('Final: Best = %12.6e (exitflag=%d)\n', f_best, exitflag);
end

%% 收敛语义检查
if exitflag < 0
    warning('simulated_annealing:DidNotConverge', '退火过程异常, 检查目标函数。');
end
end

%% Self-test
function self_test()
    % 球函数 f(x) = sum(x.^2), 2 维 (向量边界), 最优 (0,0), f*=0
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    [x, fval, ~, exitflag] = simulated_annealing(fun, [-10 -10], [10 10], ...
        'Seed', 42, 'T0', 100, 'Tf', 1e-8, 'MaxIter', 300, 'MovePerTemp', 20);
    assert(exitflag >= 0, 'Test failed: SA should terminate normally.');
    assert(fval < 1.0, sprintf('Test failed: fval=%.4f should be < 1.0.', fval));
    assert(length(x) == 2, 'Test failed: solution should be 1x2.');
    assert(all(x >= -10) && all(x <= 10), 'Test failed: solution out of bounds.');
    disp('simulated_annealing self-test passed.');
end
