% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, y_opt, F_opt, exitflag] = bilevel_opt(options)
%% BILEVEL_OPT Bilevel optimization via KKT-condition replacement (MPEC).
%  Paradigm: PARADIGM-0118-BILEVEL. Category: Optimization. v3.0.0.
%  Reference: Dempe S. (2002) Foundations of Bilevel Programming. Springer.
%  Solves:  min_{x,y} F(x,y)   s.t.   y in argmin_y f(x,y),  g(x,y) <= 0
%  by replacing the lower-level problem with its KKT conditions, then
%  solving the resulting Mathematical Program with Equilibrium Constraints
%  (MPEC) via fmincon.
%  Default example: Stackelberg leader-follower game.
%    Leader:   min_x  (x-1)^2 + (y-0.5)^2
%    Follower: min_y  0.5*(y - 2*x + 1.5)^2
%    Known equilibrium: x* = 1, y* = 0.5
%  Input:  options.lower_fun   - handle to lower-level objective f(x,y)
%          options.lower_grad  - handle to gradient of f w.r.t. y
%          options.upper_fun   - handle to upper-level objective F(x,y)
%          options.x0          - initial guess [x; y] (default [0; 0])
%          options.constraint  - handle to g(x,y) <= 0 (default none)
%          options.seed        - random seed (default 42)
%  Output: x_opt, y_opt - optimal leader and follower decisions
%          F_opt        - upper-level objective value at optimum
%          exitflag     - 1 converged, 0 max-iter/feval, -1 failed

arguments
    options.lower_fun function_handle = ...
        @(x, y) 0.5 * (y - 2*x + 1.5)^2
    options.lower_grad function_handle = ...
        @(x, y) (y - 2*x + 1.5)
    options.upper_fun function_handle = ...
        @(x, y) (x - 1)^2 + (y - 0.5)^2
    options.x0 (:, 1) double = [0; 0]
    options.constraint function_handle = function_handle.empty()
    options.seed (1,1) double = 42
end
rng(options.seed, 'twister');

% Extract options with short names
f_lower = options.lower_fun;                                % L01
grad_y  = options.lower_grad;                               % L02
F_upper = options.upper_fun;                                % L03
x0      = options.x0;                                       % L04
g_con   = options.constraint;                               % L05

% Determine dimensions
n_x = 1;                                                     % L06  leader variable dimension
n_y = 1;                                                     % L07  follower variable dimension
n_total = n_x + n_y;                                         % L08

if length(x0) ~= n_total
    x0 = [0; 0];                                             % L09  reset to default if mismatch
end

% --- Objective: minimize upper-level F(x,y) ---
obj_fun = @(z) F_upper(z(1), z(2));                          % L10

% --- KKT stationarity constraint for lower level ---
% The follower solves min_y f(x,y)  =>  d/dy f(x,y) = 0  (unconstrained case)
kkt_eq = @(z) grad_y(z(1), z(2));                            % L11

% --- Inequality constraints ---
% If no user-supplied constraint, the lower level is unconstrained
if isempty(g_con)
    % No inequality constraints
    nonlcon_fun = @(z) deal([], kkt_eq(z));                  % L12
else
    % User-supplied constraint g(x,y) <= 0, plus KKT complementarity
    nonlcon_fun = @(z) bilevel_nonlcon(z, g_con, kkt_eq);    % L13
end

% --- Set up and run fmincon ---
opts = optimoptions('fmincon', ...
    'Display', 'off', ...
    'Algorithm', 'sqp', ...
    'MaxIterations', 1000, ...
    'MaxFunctionEvaluations', 5000, ...
    'OptimalityTolerance', 1e-8, ...
    'StepTolerance', 1e-12, ...
    'ConstraintTolerance', 1e-8);                            % L14

[z_opt, F_opt, ef_fmin, output] = fmincon(obj_fun, x0, ...
    [], [], [], [], [], [], nonlcon_fun, opts);              % L15

x_opt = z_opt(1);                                            % L16
y_opt = z_opt(2);                                            % L17

% --- Convergence assessment ---
if ef_fmin > 0
    exitflag = 1;                                            % L18
elseif ef_fmin == 0
    exitflag = 0;                                            % L19
    warning('bilevel_opt:MaxIterReached', ...
        'fmincon reached max iterations/function evaluations.');
else
    exitflag = -1;                                           % L20
    warning('bilevel_opt:NotConverged', ...
        'fmincon exitflag=%d; bilevel solution may be unreliable.', ef_fmin);
end

% --- Verify KKT residual at solution ---
kkt_residual = abs(kkt_eq(z_opt));                           % L21
if kkt_residual > 1e-6
    warning('bilevel_opt:KKTViolation', ...
        'KKT residual = %.2e > 1e-6 at reported solution.', kkt_residual);
    if exitflag == 1
        exitflag = 0;                                        % L22  downgrade convergence
    end
end

end

%% Helper: nonlinear constraint with complementarity ------------------------
function [c_ineq, c_eq] = bilevel_nonlcon(z, g_con, kkt_eq)
% Build nonlinear constraints for the MPEC:
%   c_ineq <= 0  are the user constraints g(x,y) <= 0
%   c_eq  == 0   is the KKT stationarity condition
    c_ineq = g_con(z(1), z(2));                              % L inner1
    c_eq   = kkt_eq(z(1), z(2));                             % L inner2
end

%% Self-test ================================================================
function self_test()
% Stackelberg leader-follower game with known equilibrium (x*=1, y*=0.5).
% Leader:   min_x (x-1)^2 + (y-0.5)^2
% Follower: min_y 0.5*(y - 2*x + 1.5)^2  -> y* = 2x - 1.5
% Substituting: min_x (x-1)^2 + (2x-2)^2 = 5*(x-1)^2 -> x*=1, y*=0.5

    [x_star, y_star, F_star, ef] = bilevel_opt('seed', 42);

    % Assert 1: optimization converged
    assert(ef == 1, sprintf('Bilevel optimization failed (exitflag=%d).', ef));

    % Assert 2: x* within 0.1 of known optimum 1.0
    assert(abs(x_star - 1.0) < 0.1, ...
        sprintf('x* = %.6f differs from 1.0 by > 0.1.', x_star));

    % Assert 3: y* within 0.1 of known optimum 0.5
    assert(abs(y_star - 0.5) < 0.1, ...
        sprintf('y* = %.6f differs from 0.5 by > 0.1.', y_star));

    % Assert 4: upper-level objective at optimum is near zero
    assert(F_star < 0.05, ...
        sprintf('F(x*,y*) = %.6f; expected near 0 at equilibrium (1, 0.5).', F_star));

    % Assert 5: verify lower-level optimality: y* should approximately equal 2*x* - 1.5
    y_implied = 2 * x_star - 1.5;
    assert(abs(y_star - y_implied) < 0.05, ...
        sprintf('y*=%.6f but 2*x*-1.5=%.6f; lower-level KKT violated.', y_star, y_implied));

    fprintf('bilevel_opt self-test passed. (x*=%.6f, y*=%.6f, F*=%.6f)\n', ...
        x_star, y_star, F_star);
end
