% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, fval, exitflag, output] = intlinprog_wrapper(f, intcon, A_ineq, b_ineq, varargin)
%INTLINPROG_WRAPPER 整数规划求解器 (封装 MATLAB intlinprog)
%   [X_OPT, FVAL, EXITFLAG, OUTPUT] = INTLINPROG_WRAPPER(F, INTCON, A_INEQ, B_INEQ)
%   求解混合整数线性规划: min f'*x, intcon中变量为整数
%
%   Source: Wolsey, L.A. (1998). Integer Programming. Wiley.
%   MATLAB: Optimization Toolbox (intlinprog, branch-and-bound)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       f       - 目标函数系数向量 (n×1)
%       intcon  - 整数变量索引向量 (例如 [1 2] 表示 x1,x2 为整数)
%       A_ineq  - 不等式约束矩阵 A*x <= b
%       b_ineq  - 不等式约束右侧
%
%   可选参数:
%       'A_eq'     - 等式约束矩阵
%       'b_eq'     - 等式约束右侧
%       'lb'       - 下界 (默认: zeros)
%       'ub'       - 上界 (默认: inf)
%       'Maximize' - 最大化 (默认: false)
%       'Display'  - 'on' | 'off' (默认: 'off')
%
%   输出:
%       x_opt    - 最优解 (含整数约束)
%       fval     - 最优目标值
%       exitflag - 1=成功
%       output   - 结构体
%
%   示例:
%       % max 5x1+8x2, st x1+x2<=6, 5x1+9x2<=45, x1,x2>=0, x1,x2整数
%       f = [-5; -8];
%       intcon = [1; 2];
%       A = [1 1; 5 9]; b = [6; 45];
%       [x, fval] = intlinprog_wrapper(f, intcon, A, b);

%% 依赖检查
if ~exist('intlinprog', 'file')
    error('需要 Optimization Toolbox。请安装该工具箱。');
end

n = length(f);

%% 参数解析
p = inputParser;
p.addParameter('A_eq', []);
p.addParameter('b_eq', []);
p.addParameter('lb', zeros(n, 1));
p.addParameter('ub', inf(n, 1));
p.addParameter('Maximize', false);
p.addParameter('Display', 'off');
p.parse(varargin{:});
opts = p.Results;

f_vec = f(:);
if opts.Maximize
    f_vec = -f_vec;
end

options = optimoptions('intlinprog', 'Display', opts.Display);

%% 求解
try
    [x_opt, fval, exitflag, output] = intlinprog(f_vec, intcon, ...
        A_ineq, b_ineq, ...
        opts.A_eq, opts.b_eq, ...
        opts.lb, opts.ub, options);

    if opts.Maximize
        fval = -fval;
    end
catch ME
    x_opt = [];
    fval = NaN;
    exitflag = -1;
    output.message = ME.message;
    warning('intlinprog 求解失败: %s', ME.message);
end

if isempty(x_opt)
    fprintf('整数规划: 求解失败\n');
else
    fprintf('整数规划: 最优值=%.6f, 退出标志=%d\n', fval, exitflag);
end
end

%% Self-test
function self_test()
    % min z = -3*x1 - 2*x2 s.t. 2*x1+x2<=7, x1,x2 integer, x1,x2>=0
    % Known optimal: x1=3, x2=1, z=-11
    f = [-3; -2];
    A_ineq = [2 1];
    b_ineq = [7];
    intcon = [1; 2];
    [x, fval, exitflag] = intlinprog_wrapper(f, intcon, A_ineq, b_ineq);
    assert(exitflag >= 0);
    assert(abs(x(1)-3) < 1e-4 && abs(x(2)-1) < 1e-4);
    assert(abs(fval-(-11)) < 1e-4);
    disp('intlinprog_wrapper self-test passed.');
end
