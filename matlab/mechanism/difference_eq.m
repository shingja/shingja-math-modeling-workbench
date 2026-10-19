% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_history, converged, final_val, cobweb_data] = difference_eq(x0, n_iter, options)
%% DIFFERENCEEQ  General difference equation iterator for discrete maps.
%  Solves x_{n+1} = f(x_n, params) for arbitrary discrete dynamical system.
%  Paradigm: PARADIGM-0807
%  Category: Mechanism
%  Version: v3.0.0
%  Reference: Strogatz, S.H. (2015) Nonlinear Dynamics and Chaos, 2nd ed.
%             Westview Press. ISBN: 978-0813349107.
%
%  Input:
%      x0     - Initial value (scalar)
%      n_iter - Number of iterations
%
%  Options:
%      options.map_type - 'logistic' | 'linear_de' | 'custom'
%      options.r        - Logistic map parameter r (default: 3.7)
%      options.a        - Linear DE coefficient a (x_{n+1} = a*x_n + b)
%      options.b        - Linear DE coefficient b (default: 0)
%      options.custom_f - Function handle f(x, params) for custom map
%      options.params   - Additional parameters struct for custom_f
%      options.cobweb   - Generate cobweb plot data (default: false)
%      options.seed     - RNG seed (default: 42)
%
%  Output:
%      x_history   - Iteration history vector (n_iter+1 × 1)
%      converged   - Boolean: did the iteration converge?
%      final_val   - Final value after n_iter iterations
%      cobweb_data - Struct with x_line, y_line for cobweb diagram

arguments
    x0 (1,1) double
    n_iter (1,1) double {mustBeInteger, mustBePositive}
    options.map_type char = 'logistic'
    options.r (1,1) double = 3.7
    options.a (1,1) double = 0.5
    options.b (1,1) double = 0
    options.custom_f function_handle = @(x,p) x
    options.params struct = struct()
    options.cobweb (1,1) logical = false
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

%% Validate map_type
valid_maps = {'logistic', 'linear_de', 'custom'};
assert(any(strcmp(options.map_type, valid_maps)), ...
    'map_type must be one of: logistic, linear_de, custom.');

%% Select iteration function f(x)
switch options.map_type
    case 'logistic'
        r_val = options.r;
        assert(r_val >= 0 && r_val <= 4, 'Logistic parameter r must be in [0, 4].');
        f = @(x) r_val * x * (1 - x);
    case 'linear_de'
        a_val = options.a;
        b_val = options.b;
        f = @(x) a_val * x + b_val;
    case 'custom'
        f = @(x) options.custom_f(x, options.params);
end

%% Preallocate and iterate
x_history = zeros(n_iter + 1, 1);
x_history(1) = x0;
x_cur = x0;

converged = false;
conv_tol = 1e-8;

for k = 1:n_iter
    x_next = f(x_cur);

    % Check for blow-up
    if ~isfinite(x_next)
        warning('DIFFERENCEEQ:Divergence', ...
            'Iteration diverged at step %d. x = %.4e.', k, x_next);
        x_history(k+1:end) = NaN;
        converged = false;
        final_val = NaN;
        cobweb_data = struct('x_line', [], 'y_line', []);
        return;
    end

    x_history(k + 1) = x_next;

    % Convergence check (on last 10% of iterations)
    if k > 0.9 * n_iter
        if abs(x_next - x_cur) < conv_tol
            converged = true;
        end
    end

    x_cur = x_next;
end

%% Save results (cross-platform): save(fullfile(pwd, 'diffeq_results.mat'), 'x_history');

%% Convergence/validity check
if ~converged && options.map_type == 'linear_de' && abs(options.a) < 1
    % Linear DE with |a|<1 should converge to b/(1-a)
    expected_fixed = options.b / (1 - options.a);
    if abs(x_cur - expected_fixed) > 1e-4
        warning('DIFFERENCEEQ:NotConverged', ...
            'Linear DE with |a|<1 did not reach fixed point. Current: %.6f, Expected: %.6f.', ...
            x_cur, expected_fixed);
    end
end

final_val = x_history(end);

%% Generate cobweb data if requested
if options.cobweb
    cobweb_data = generate_cobweb(x_history, f);
else
    cobweb_data = struct('x_line', [], 'y_line', []);
end

%% Nested: cobweb data generator
function cw = generate_cobweb(hist, f_handle)
    n_pts = length(hist) - 1;
    % Each iteration produces 2 line segments: vertical then horizontal
    % Total: 2*n_pts segments → 4*n_pts + 1 points
    cw.x_line = zeros(4 * n_pts + 1, 1);
    cw.y_line = zeros(4 * n_pts + 1, 1);

    cw.x_line(1) = hist(1);
    cw.y_line(1) = 0;  % Start at (x0, 0)

    for i = 1:n_pts
        idx = 4 * (i - 1);
        % Vertical: (x_i, f(x_i)) → up to curve
        cw.x_line(idx + 1) = hist(i);
        cw.y_line(idx + 1) = f_handle(hist(i));
        % Vertical line up
        cw.x_line(idx + 2) = hist(i);
        cw.y_line(idx + 2) = f_handle(hist(i));
        % Horizontal to y=x
        cw.x_line(idx + 3) = f_handle(hist(i));
        cw.y_line(idx + 3) = f_handle(hist(i));
        % Horizontal then vertical to next
        cw.x_line(idx + 4) = f_handle(hist(i));
        cw.y_line(idx + 4) = f_handle(hist(i));
    end
    % Last point
    cw.x_line(end) = hist(end);
    cw.y_line(end) = f_handle(hist(end));
end

%% Self-test
function self_test()
    % Logistic map with r=2: known stable fixed point x* = 1 - 1/r = 0.5
    r_test = 2.0;
    x0_test = 0.1;
    [x_hist, flag_conv, final_v, ~] = difference_eq(x0_test, 500, ...
        map_type='logistic', r=r_test);

    expected_fixed = 1 - 1/r_test;  % 0.5
    err = abs(final_v - expected_fixed);

    assert(err < 1e-6, ...
        'Self-test failed: logistic r=2 should converge to %.6f, got %.6f (err=%.2e).', ...
        expected_fixed, final_v, err);
    assert(flag_conv, ...
        'Self-test failed: logistic r=2 should converge.');
    assert(final_v > 0.49 && final_v < 0.51, ...
        'Self-test failed: fixed point %.6f not near 0.5 for r=2.', final_v);

    % Linear DE: x_{n+1} = 0.5*x_n + 3 → fixed point x* = 3/(1-0.5) = 6
    [x_hist2, flag_conv2, final_v2, ~] = difference_eq(0, 200, ...
        map_type='linear_de', a=0.5, b=3);

    expected_linear = 3 / (1 - 0.5);  % 6
    err2 = abs(final_v2 - expected_linear);
    assert(err2 < 1e-6, ...
        'Self-test failed: linear a=0.5,b=3 should converge to 6, got %.6f.', final_v2);
    assert(flag_conv2, ...
        'Self-test failed: linear DE with |a|<1 should converge.');

    % Cobweb data should be non-empty when requested
    [~, ~, ~, cw] = difference_eq(0.2, 5, map_type='logistic', r=2.0, cobweb=true);
    assert(~isempty(cw.x_line), ...
        'Self-test failed: cobweb data not generated when requested.');

    disp('DIFFERENCEEQ self-test passed.');
end
end
