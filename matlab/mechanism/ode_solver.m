% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [t, y, sol] = ode_solver(ode_func, tspan, y0, varargin)
%ODE_SOLVER 常微分方程数值求解器 (Wrapper for MATLAB ode45/ode15s)
%   [T, Y, SOL] = ODE_SOLVER(ODE_FUNC, TSPAN, Y0)
%   统一接口，自动选择刚性/非刚性求解器。
%
%   Source: Shampine, L.F., Reichelt, M.W. (1997).
%          The MATLAB ODE Suite. SIAM Journal on Scientific Computing, 18(1), 1-22.
%   MATLAB: 内置 ode45/ode15s/ode23s (无需额外工具箱)
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       ode_func - ODE 函数句柄 dy/dt = odefunc(t, y)
%                  或带参数的 odefunc(t, y, p1, p2, ...)
%       tspan    - 时间区间 [t0, tf] 或 [t0, t1, ..., tf]
%       y0       - 初始条件向量 (n_states × 1)
%
%   可选参数:
%       'Solver'    - 求解器选择 (默认: 'auto')
%                     'auto' = 自动检测刚性
%                     'ode45' | 'ode15s' | 'ode23s' | 'ode113'
%       'RelTol'    - 相对容差 (默认: 1e-6)
%       'AbsTol'    - 绝对容差 (默认: 1e-9)
%       'MaxStep'   - 最大步长 (默认: [])
%       'Params'     - 传递给 ode_func 的额外参数 cell 数组
%       'Events'     - 事件函数句柄
%       'Refine'     - 插值细化因子 (默认: 4)
%       'StiffTest'  - 是否检测刚性 (默认: true)
%
%   输出:
%       t   - 时间点向量
%       y   - 状态矩阵 (n_points × n_states)
%       sol - 结构体, 可用 deval(sol, t) 插值任意时间点
%
%   示例:
%       % Lotka-Volterra 捕食者-猎物模型
%       lv = @(t,y) [y(1) - 0.1*y(1)*y(2); -0.5*y(2) + 0.02*y(1)*y(2)];
%       [t, y] = ode_solver(lv, [0, 100], [20; 20]);
%       plot(t, y);
%
%       % 带参数的 ODE
%       sir = @(t,y,beta,gamma) [-beta*y(1)*y(2); beta*y(1)*y(2)-gamma*y(2); gamma*y(2)];
%       [t, y] = ode_solver(sir, [0, 100], [0.99; 0.01; 0], 'Params', {0.3, 0.1});

%% 依赖检查
% 仅使用 MATLAB 内置 ode 套件，无需额外工具箱

%% 参数解析
p = inputParser;
p.addParameter('Solver', 'auto', @(v) any(strcmp(v, ...
    {'auto', 'ode45', 'ode15s', 'ode23s', 'ode113', 'ode23t', 'ode23tb'})));
p.addParameter('RelTol', 1e-6, @(v) isscalar(v) && v > 0);
p.addParameter('AbsTol', 1e-9, @(v) isscalar(v) && v > 0);
p.addParameter('MaxStep', [], @(v) isempty(v) || (isscalar(v) && v > 0));
p.addParameter('Params', {}, @iscell);
p.addParameter('Events', [], @(v) isempty(v) || isa(v, 'function_handle'));
p.addParameter('Refine', 4, @(v) isscalar(v) && v >= 1);
p.addParameter('StiffTest', true, @islogical);
p.parse(varargin{:});
opts = p.Results;

%% 构建 ode 选项
ode_opts = odeset(...
    'RelTol', opts.RelTol, ...
    'AbsTol', opts.AbsTol, ...
    'Refine', opts.Refine);

if ~isempty(opts.MaxStep)
    ode_opts = odeset(ode_opts, 'MaxStep', opts.MaxStep);
end

if ~isempty(opts.Events)
    ode_opts = odeset(ode_opts, 'Events', opts.Events);
end

%% 包装函数 (注入额外参数)
if isempty(opts.Params)
    ode_wrapper = ode_func;
else
    params = opts.Params;
    ode_wrapper = @(t, y) ode_func(t, y, params{:});
end

%% 刚性检测 (Stiffness Detection)
if strcmp(opts.Solver, 'auto') && opts.StiffTest
    % 试探性求解: 用 ode45 试一步, 若步长极小则切换 ode15s
    try
        [~, ~, ~, stats] = ode45(ode_wrapper, tspan, y0, ode_opts);
        avg_step = mean(diff(stats.x));
        t_range = tspan(end) - tspan(1);

        % 若平均步长过小 → 可能为刚性系统
        if avg_step < t_range * 1e-4 && length(stats.x) > 100
            use_solver = 'ode15s';
            fprintf('自动检测: 刚性系统 → 切换 ode15s\n');
        else
            use_solver = 'ode45';
        end
    catch
        % ode45 失败 → 尝试 ode15s
        use_solver = 'ode15s';
        fprintf('ode45 试探失败 → 尝试 ode15s (可能为刚性系统)\n');
    end
elseif strcmp(opts.Solver, 'auto')
    use_solver = 'ode45';
else
    use_solver = opts.Solver;
end

%% 求解
try
    sol = feval(use_solver, ode_wrapper, tspan, y0, ode_opts);
catch ME
    if strcmp(use_solver, 'ode45')
        fprintf('ode45 失败: %s → 尝试 ode15s\n', ME.message);
        use_solver = 'ode15s';
        sol = feval(use_solver, ode_wrapper, tspan, y0, ode_opts);
    else
        rethrow(ME);
    end
end

t = sol.x(:);
y = sol.y';

%% 输出摘要
fprintf('ODE 求解完成 (%s):\n', use_solver);
fprintf('  时间区间: [%.2f, %.2f]\n', t(1), t(end));
fprintf('  步数: %d\n', length(t));
fprintf('  状态维数: %d\n', size(y, 2));

% 计算并输出最终状态
fprintf('  终态 y(end) = ');
fprintf('%.4f ', y(end, :));
fprintf('\n');
end

%% Self-test
function self_test()
    % Test dy/dt = -y, known exact solution y(t)=exp(-t)
    odefun = @(t, y) -y;
    [t, y] = ode_solver(odefun, [0, 5], 1);
    assert(length(t) > 2, 'Test failed: should have multiple time points.');
    assert(abs(y(end) - exp(-5)) < 0.01, 'Test failed: y(5) should be approx exp(-5).');
    disp('ode_solver self-test passed.');
end
n%% Reproducibility
rng(42, 'twister');
