% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, fval, exitflag, output] = linprog_wrapper(f, A_ineq, b_ineq, varargin)
%LINPROG_WRAPPER 线性规划求解器 (封装 MATLAB linprog)
%   [X_OPT, FVAL, EXITFLAG, OUTPUT] = LINPROG_WRAPPER(F, A_INEQ, B_INEQ)
%   求解标准形式: min f'*x  subject to A_ineq*x <= b_ineq
%
%   Source: Dantzig, G. (1963). Linear Programming and Extensions.
%   MATLAB: Optimization Toolbox (linprog, dual-simplex / interior-point)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       f       - 目标函数系数向量 (n×1), 最小化
%       A_ineq  - 不等式约束矩阵 (m×n), A*x <= b
%       b_ineq  - 不等式约束右侧 (m×1)
%
%   可选参数 (名值对):
%       'A_eq'     - 等式约束矩阵 (默认: [])
%       'b_eq'     - 等式约束右侧 (默认: [])
%       'lb'       - 下界向量 (默认: zeros(n,1))
%       'ub'       - 上界向量 (默认: inf(n,1))
%       'Maximize' - 是否最大化 (默认: false = 最小化)
%       'Algorithm' - 'dual-simplex' | 'interior-point' (默认: 'dual-simplex')
%       'Display'  - 'on' | 'off' (默认: 'off')
%
%   输出:
%       x_opt    - 最优解 (n×1)
%       fval     - 最优目标函数值
%       exitflag - 1=成功, 0=达最大迭代, -1=无解
%       output   - 结构体: iterations, algorithm, message
%
%   示例:
%       f = [-1; -2];                          % max x1+2x2 → min -x1-2x2
%       A = [2 1; 1 3]; b = [10; 15];
%       lb = [0; 0];
%       [x, fval] = linprog_wrapper(f, A, b, 'lb', lb);

%% 依赖检查
if ~exist('linprog', 'file')
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
p.addParameter('Algorithm', 'dual-simplex');
p.addParameter('Display', 'off');
p.parse(varargin{:});
opts = p.Results;

%% 最大化转最小化
f_vec = f(:);
if opts.Maximize
    f_vec = -f_vec;
end

%% 构建选项
options = optimoptions('linprog', ...
    'Algorithm', opts.Algorithm, ...
    'Display', opts.Display);

%% 求解
try
    [x_opt, fval, exitflag, output] = linprog(f_vec, ...
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
    warning('linprog 求解失败: %s', ME.message);
end

%% 结果摘要
if isempty(x_opt)
    fprintf('线性规划: 求解失败\n');
else
    fprintf('线性规划: 最优值=%.6f, 退出标志=%d, 迭代=%d\n', ...
            fval, exitflag, output.iterations);
end
end

%% Self-test
function self_test()
    % min z = -x1 - 2*x2 subject to 2x1+x2<=10, x1+3x2<=15, x1,x2>=0
    % Known optimal: x1=3, x2=4, z=-11
    f = [-1; -2];
    A_ineq = [2 1; 1 3];
    b_ineq = [10; 15];
    [x, fval, exitflag] = linprog_wrapper(f, A_ineq, b_ineq);
    assert(exitflag >= 0, 'LP solver returned error flag.');
    assert(abs(x(1) - 3) < 1e-4, 'x1 should be 3.');
    assert(abs(x(2) - 4) < 1e-4, 'x2 should be 4.');
    assert(abs(fval - (-11)) < 1e-4, 'Optimal value should be -11.');
    disp('linprog_wrapper self-test passed.');
end
