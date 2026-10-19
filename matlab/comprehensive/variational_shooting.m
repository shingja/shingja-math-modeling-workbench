% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [sol_x, sol_y, converged, n_iter, trajectory] = variational_shooting(ode_func, a, b, ya, yb, options)
%% VARIATIONALSHOOTING  Shooting method for Euler-Lagrange BVP.
%  Solves y'' = f(x, y, y') with y(a)=ya, y(b)=yb via RK4 integration
%  and secant root-finding on the unknown initial slope s = y'(a).
%  Paradigm: PARADIGM-0808
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Elsgolts, L. (2003) Differential Equations and the
%             Calculus of Variations. Dover. ISBN: 978-0486432403.
%             Press, W.H. et al. (2007) Numerical Recipes, 3rd ed.
%             Cambridge University Press. Ch. 18.
%
%  Input:
%      ode_func - Function handle f(x, y, y_prime) returning y'' = f(x, y, y')
%      a, b     - Domain boundaries [a, b]
%      ya, yb   - Boundary values y(a)=ya, y(b)=yb
%
%  Options:
%      options.s0       - Initial guess for y'(a) (default: (yb-ya)/(b-a))
%      options.s1       - Second guess for y'(a) (default: s0 + 0.1)
%      options.n_steps  - Number of integration steps (default: 1000)
%      options.max_iter - Maximum shooting iterations (default: 50)
%      options.tol      - Convergence tolerance on y(b) (default: 1e-8)
%      options.seed     - RNG seed (default: 42)
%
%  Output:
%      sol_x      - Spatial grid (n_steps+1 × 1)
%      sol_y      - Solution y(x) (n_steps+1 × 1)
%      converged  - Boolean: did shooting converge?
%      n_iter     - Number of iterations used
%      trajectory - Struct with iteration history (s_k, error_k)

arguments
    ode_func function_handle
    a (1,1) double
    b (1,1) double
    ya (1,1) double
    yb (1,1) double
    options.s0 (1,1) double = NaN
    options.s1 (1,1) double = NaN
    options.n_steps (1,1) double {mustBeInteger, mustBePositive} = 1000
    options.max_iter (1,1) double {mustBeInteger, mustBePositive} = 50
    options.tol (1,1) double {mustBePositive} = 1e-8
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

assert(a < b, 'Domain: a=%.4f must be less than b=%.4f.', a, b);

%% Default initial slope guesses using linear approximation
if isnan(options.s0)
    s0 = (yb - ya) / (b - a);
else
    s0 = options.s0;
end

if isnan(options.s1)
    s1 = s0 + 0.1 * abs(yb - ya) / (b - a);
    if abs(s1 - s0) < 1e-10
        s1 = s0 + 0.1;
    end
else
    s1 = options.s1;
end

assert(s1 ~= s0, 'Initial guesses s0 and s1 must be distinct.');

%% Integration grid
h = (b - a) / options.n_steps;
x = linspace(a, b, options.n_steps + 1)';

%% First shot with s0
[~, y_shot0] = rk4_integrate(ode_func, a, b, ya, s0, options.n_steps);
F0 = y_shot0(end) - yb;

%% Second shot with s1
[~, y_shot1] = rk4_integrate(ode_func, a, b, ya, s1, options.n_steps);
F1 = y_shot1(end) - yb;

%% Track iterations
iter_history_s = [s0; s1];
iter_history_err = [F0; F1];

%% Secant iteration
s_old = s0;
s_cur = s1;
F_old = F0;
F_cur = F1;

converged = false;
n_iter = 2;
tol = options.tol;
max_iter = options.max_iter;

for k = 3:max_iter
    % Secant update: s_new = s_cur - F_cur * (s_cur - s_old) / (F_cur - F_old)
    if abs(F_cur - F_old) < eps
        % Degenerate: perturb
        s_new = s_cur + 0.1 * abs(s_cur - s_old);
    else
        s_new = s_cur - F_cur * (s_cur - s_old) / (F_cur - F_old);
    end

    % Bracket check: if too far, use bisection-like damping
    if abs(s_new - s_cur) > 10 * abs(s_cur - s_old)
        s_new = s_cur + sign(s_new - s_cur) * abs(s_cur - s_old);
    end

    % Integrate with new slope
    [~, y_shot] = rk4_integrate(ode_func, a, b, ya, s_new, options.n_steps);
    F_new = y_shot(end) - yb;

    % Record
    iter_history_s(end+1) = s_new;   %#ok<AGROW>
    iter_history_err(end+1) = F_new;  %#ok<AGROW>
    n_iter = k;

    % Check convergence
    if abs(F_new) < tol
        converged = true;
        s_cur = s_new;
        break;
    end

    % Update for next iteration
    s_old = s_cur;
    F_old = F_cur;
    s_cur = s_new;
    F_cur = F_new;

    % Check stagnation
    if abs(s_cur - s_old) < tol * 1e-3
        converged = true;
        break;
    end
end

% Save results (cross-platform): save(fullfile(pwd, 'shooting_results.mat'), 'sol_x', 'sol_y');

%% Final solution
sol_x = x;
[~, sol_y] = rk4_integrate(ode_func, a, b, ya, s_cur, options.n_steps);

%% Convergence check
if ~converged
    warning('VARIATIONALSHOOTING:NotConverged', ...
        'Shooting did not converge in %d iterations. Final |error| = %.2e.', ...
        max_iter, abs(sol_y(end) - yb));
end

%% Verify boundary conditions
err_a = abs(sol_y(1) - ya);
err_b = abs(sol_y(end) - yb);
assert(err_a < tol * 10, ...
    'VARIATIONALSHOOTING:BCViolation', ...
    'Left BC not satisfied: |y(a)-ya| = %.2e.', err_a);
assert(err_b < max(tol * 100, 1e-6), ...
    'VARIATIONALSHOOTING:BCViolation', ...
    'Right BC not satisfied after %d iterations: |y(b)-yb| = %.2e.', n_iter, err_b);

%% Assemble trajectory
trajectory.s = iter_history_s;
trajectory.error = iter_history_err;
trajectory.n_iter = n_iter;
trajectory.converged = converged;
trajectory.final_error = abs(sol_y(end) - yb);

%% Nested: RK4 integrator for second-order ODE system
function [x_out, y_out] = rk4_integrate(fcn, x0, xf, y0, yprime0, n_steps)
    % Convert y'' = f(x, y, y') to first-order system:
    %   u1 = y,  u2 = y'
    %   u1' = u2, u2' = f(x, u1, u2)
    h_step = (xf - x0) / n_steps;
    x_out = linspace(x0, xf, n_steps + 1)';
    u = [y0; yprime0];
    y_out = zeros(n_steps + 1, 1);
    y_out(1) = y0;

    for i = 1:n_steps
        xi = x_out(i);

        k1 = h_step * [u(2); fcn(xi, u(1), u(2))];
        k2 = h_step * [u(2) + k1(2)/2; fcn(xi + h_step/2, u(1) + k1(1)/2, u(2) + k1(2)/2)];
        k3 = h_step * [u(2) + k2(2)/2; fcn(xi + h_step/2, u(1) + k2(1)/2, u(2) + k2(2)/2)];
        k4 = h_step * [u(2) + k3(2);   fcn(xi + h_step,   u(1) + k3(1),   u(2) + k3(2))];

        u = u + (k1 + 2*k2 + 2*k3 + k4) / 6;
        y_out(i + 1) = u(1);
    end
end

%% Self-test
function self_test()
    % Brachistochrone problem (cycloid).
    % For a particle sliding from (0,0) to (x_b, y_b) under gravity,
    % the optimal path satisfies the cycloid equation.
    % Here we solve y'' = -(1 + (y')^2)/(2*(h - y)) as a simplified case.

    % Test with a simple harmonic oscillator BVP:
    % y'' = -y, y(0)=0, y(pi/2)=1 → solution: y = sin(x), y'(0) = 1
    harmonic_fcn = @(x, y, yp) -y;
    a_test = 0;
    b_test = pi/2;
    ya_test = 0;
    yb_test = 1;

    [sol_x, sol_y, flag, n_iter, ~] = variational_shooting(...
        harmonic_fcn, a_test, b_test, ya_test, yb_test, ...
        n_steps=500, tol=1e-8, max_iter=30);

    % Analytical solution: y = sin(x)
    y_analytical = sin(sol_x);
    max_err = max(abs(sol_y - y_analytical));

    assert(flag, ...
        'Self-test failed: shooting did not converge for harmonic oscillator.');
    assert(max_err < 1e-3, ...
        'Self-test failed: max error %.6f exceeds tolerance against sin(x).', max_err);
    assert(n_iter <= 20, ...
        'Self-test failed: converged in %d iterations (expected <= 20).', n_iter);

    % Test boundary conditions
    assert(abs(sol_y(1) - 0) < 1e-6, ...
        'Self-test failed: y(a) = %.6f, expected 0.', sol_y(1));
    assert(abs(sol_y(end) - 1) < 1e-4, ...
        'Self-test failed: y(b) = %.6f, expected 1.', sol_y(end));

    disp('VARIATIONALSHOOTING self-test passed.');
end
end
