% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, fval, attainfactor, exitflag, output] = fgoalattain_wrapper(fun, x0, goal, weight, varargin)
%FGOALATTAIN_WRAPPER 目标规划求解器 (封装 MATLAB fgoalattain)
%   [X_OPT, FVAL, ATTAINFACTOR] = FGOALATTAIN_WRAPPER(FUN, X0, GOAL, WEIGHT)
%   求解多目标规划: 使 fun(x) 尽可能接近 goal, 按 weight 权衡各目标。
%
%   Source: Gembicki, F.W. (1974). Vector Optimization for Control
%          with Performance and Parameter Sensitivity Indices. PhD Thesis.
%   MATLAB: Optimization Toolbox (fgoalattain, SQP)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       fun    - 多目标函数句柄 @(x) [f1(x); f2(x); ...], 返回 k×1 向量
%       x0     - 初始点 (n×1)
%       goal   - 各目标的目标值 (k×1)
%       weight - 各目标的权重 (k×1), 默认等权
%
%   可选参数:
%       'A_ineq'   - 线性不等式约束 A*x <= b
%       'b_ineq'   - 线性不等式约束右侧
%       'A_eq'     - 线性等式约束
%       'b_eq'     - 线性等式约束右侧
%       'lb'       - 下界
%       'ub'       - 上界
%       'NonlinCon' - 非线性约束 @(x) [c, ceq]
%       'Display'  - 'on' | 'off' (默认: 'off')
%
%   输出:
%       x_opt        - 最优解
%       fval         - 各目标在最优解处的值 (k×1)
%       attainfactor - 达标因子 (0=恰好达标, <0=超额达标, >0=未达标)
%       exitflag     - 1=成功
%       output       - 结构体
%
%   示例:
%       % 两个目标: f1=x^2 (target=4, weight=1), f2=(x-2)^2 (target=1, weight=1)
%       fun = @(x) [x^2; (x-2)^2];
%       [x, fval] = fgoalattain_wrapper(fun, 0, [4; 1], [1; 1]);

%% 依赖检查
if ~exist('fgoalattain', 'file')
    error('需要 Optimization Toolbox。请安装该工具箱。');
end

%% 参数解析
p = inputParser;
p.addParameter('A_ineq', []);
p.addParameter('b_ineq', []);
p.addParameter('A_eq', []);
p.addParameter('b_eq', []);
p.addParameter('lb', []);
p.addParameter('ub', []);
p.addParameter('NonlinCon', []);
p.addParameter('Display', 'off');
p.parse(varargin{:});
opts = p.Results;

goal = goal(:);
weight = weight(:);

options = optimoptions('fgoalattain', 'Display', opts.Display);

%% 求解
try
    if isempty(opts.NonlinCon)
        [x_opt, fval, attainfactor, exitflag, output] = fgoalattain(...
            fun, x0, goal, weight, ...
            opts.A_ineq, opts.b_ineq, ...
            opts.A_eq, opts.b_eq, ...
            opts.lb, opts.ub, [], options);
    else
        [x_opt, fval, attainfactor, exitflag, output] = fgoalattain(...
            fun, x0, goal, weight, ...
            opts.A_ineq, opts.b_ineq, ...
            opts.A_eq, opts.b_eq, ...
            opts.lb, opts.ub, opts.NonlinCon, options);
    end
catch ME
    x_opt = [];
    fval = NaN;
    attainfactor = NaN;
    exitflag = -1;
    output.message = ME.message;
    warning('fgoalattain 求解失败: %s', ME.message);
end

if isempty(x_opt)
    fprintf('目标规划: 求解失败\n');
else
    fprintf('目标规划: attainfactor=%.4f (0=达标, <0=超额), 迭代=%d\n', ...
            attainfactor, output.iterations);
    fprintf('  目标值: '); fprintf('%.4f ', goal); fprintf('\n');
    fprintf('  实际值: '); fprintf('%.4f ', fval); fprintf('\n');
end
end

%% Self-test
function self_test()
    % Multi-objective: min (x1-2)^2 + (x2-1)^2 with goals [0,0]
    fun = @(x) [(x(1)-2)^2; (x(2)-1)^2];
    x0 = [0; 0];
    goal = [0; 0];
    weight = [1; 1];
    [x, fval, exitflag] = fgoalattain_wrapper(fun, x0, goal, weight);
    assert(exitflag >= 0);
    assert(abs(x(1)-2) < 0.5 && abs(x(2)-1) < 0.5);
    disp('fgoalattain_wrapper self-test passed.');
end
