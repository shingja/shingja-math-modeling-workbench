% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, fval, exitflag, output] = fmincon_wrapper(fun, x0, A_ineq, b_ineq, varargin)
%FMINCON_WRAPPER 非线性规划求解器 (封装 MATLAB fmincon)
%   [X_OPT, FVAL, EXITFLAG, OUTPUT] = FMINCON_WRAPPER(FUN, X0, A_INEQ, B_INEQ)
%   求解: min fun(x) subject to A_ineq*x <= b_ineq, lb <= x <= ub,
%         c_ineq(x) <= 0, c_eq(x) = 0
%
%   Source: Nocedal, J., Wright, S.J. (2006). Numerical Optimization, 2nd ed. Springer.
%   MATLAB: Optimization Toolbox (fmincon, SQP / interior-point)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       fun     - 目标函数句柄 @(x) f(x)
%       x0      - 初始点 (n×1)
%       A_ineq  - 线性不等式约束矩阵 (默认: [])
%       b_ineq  - 线性不等式约束右侧 (默认: [])
%
%   可选参数:
%       'A_eq'        - 线性等式约束矩阵 (默认: [])
%       'b_eq'        - 线性等式约束右侧 (默认: [])
%       'lb'          - 下界向量 (默认: [])
%       'ub'          - 上界向量 (默认: [])
%       'NonlinCon'   - 非线性约束函数 @(x) [c, ceq], c<=0, ceq=0 (默认: [])
%       'Algorithm'   - 'sqp' | 'interior-point' | 'active-set' (默认: 'sqp')
%       'Display'     - 'on' | 'off' (默认: 'off')
%       'MaxIter'     - 最大迭代次数 (默认: 400)
%
%   输出:
%       x_opt    - 最优解
%       fval     - 最优目标值
%       exitflag - 1=一阶最优条件满足
%       output   - 结构体: iterations, funcCount, algorithm
%
%   示例:
%       fun = @(x) (x(1)-2)^2 + (x(2)-3)^2;  % min (x1-2)²+(x2-3)²
%       x0 = [0; 0];
%       [x, fval] = fmincon_wrapper(fun, x0, [], []);

%% 依赖检查
if ~exist('fmincon', 'file')
    error('需要 Optimization Toolbox。请安装该工具箱。');
end

n = length(x0);

%% 参数解析
p = inputParser;
p.addParameter('A_eq', []);
p.addParameter('b_eq', []);
p.addParameter('lb', []);
p.addParameter('ub', []);
p.addParameter('NonlinCon', []);
p.addParameter('Algorithm', 'sqp');
p.addParameter('Display', 'off');
p.addParameter('MaxIter', 400);
p.parse(varargin{:});
opts = p.Results;

%% 构建选项
options = optimoptions('fmincon', ...
    'Algorithm', opts.Algorithm, ...
    'Display', opts.Display, ...
    'MaxIterations', opts.MaxIter);

%% 求解
try
    if isempty(opts.A_eq)
        A_eq = [];
        b_eq = [];
    else
        A_eq = opts.A_eq;
        b_eq = opts.b_eq;
    end

    if isempty(opts.NonlinCon)
        [x_opt, fval, exitflag, output] = fmincon(fun, x0, ...
            A_ineq, b_ineq, A_eq, b_eq, ...
            opts.lb, opts.ub, [], options);
    else
        [x_opt, fval, exitflag, output] = fmincon(fun, x0, ...
            A_ineq, b_ineq, A_eq, b_eq, ...
            opts.lb, opts.ub, opts.NonlinCon, options);
    end
catch ME
    x_opt = [];
    fval = NaN;
    exitflag = -1;
    output.message = ME.message;
    warning('fmincon 求解失败: %s', ME.message);
end

if isempty(x_opt)
    fprintf('非线性规划: 求解失败\n');
else
    fprintf('非线性规划: 最优值=%.6f, 迭代=%d, 函数评估=%d\n', ...
            fval, output.iterations, output.funcCount);
end
end

%% Self-test
function self_test()
    % min (x1-3)^2 + (x2+1)^2 subject to x1^2+x2^2 <= 4
    % Known approx optimal: near (1.9, -0.6)
    fun = @(x) (x(1)-3)^2 + (x(2)+1)^2;
    nonlcon = @(x) deal(x(1)^2 + x(2)^2 - 4, []);
    x0 = [0; 0];
    [x, fval, exitflag] = fmincon_wrapper(fun, x0, nonlcon);
    assert(exitflag >= 0);
    assert(x(1)^2 + x(2)^2 <= 4 + 1e-4, 'Constraint violated');
    assert(fval > 0, 'Objective should be positive');
    disp('fmincon_wrapper self-test passed.');
end
