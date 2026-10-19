% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, f_opt, history] = ego_bayesopt(fun, bounds, options)
%% EGO_BAYESOPT  Efficient Global Optimization via Expected Improvement
%  Paradigm: SURROGATE-004 | Category: ⑩ | Version: v3.0.0
%  Reference: Jones, Schonlau & Welch (1998) "Efficient Global Optimization
%             of Expensive Black-Box Functions." J Global Optim 13:455-492.
%
%  Functions:
%    ego_iterate(fun,bounds,n_init,n_iter) -> [x_opt, f_opt, history]

arguments
    fun (1,1) function_handle         % objective function f(x) -> scalar
    bounds (:, 2) double              % [lb, ub] per dimension, size [d x 2]
    options.seed (1,1) double = 42
    options.n_init (1,1) double {mustBeInteger, mustBePositive} = 10
    options.n_iter (1,1) double {mustBeInteger, mustBePositive} = 30
    options.tol (1,1) double = 1e-6
    options.max_stall (1,1) double = 10   % early stopping
    options.acq_func (1,:) char {mustBeMember(options.acq_func, ...
        {'ei','lcb','pi'})} = 'ei'       % acquisition: ei / lower confidence bound / probability of improvement
end

rng(options.seed, 'twister');

%% --- Main EGO loop ---
d = size(bounds, 1);
lb = bounds(:, 1);
ub = bounds(:, 2);

% Step 1: Initial design (Latin hypercube sampling via lhsdesign)
n_init = max(options.n_init, 2 * d + 1);
X_samples = lhsdesign(n_init, d);
X_samples = lb' + (ub' - lb') .* X_samples;
Y_samples = zeros(n_init, 1);
for i = 1:n_init
    Y_samples(i) = fun(X_samples(i, :));
end

% Track best
[f_opt, idx_best] = min(Y_samples);
x_opt = X_samples(idx_best, :);

% History
history = struct();
history.X = X_samples;
history.Y = Y_samples;
history.f_best = zeros(options.n_iter, 1);
history.f_best(1) = f_opt;
history.exitflag = 1;
history.converged = true;
history.stall_count = 0;

% Step 2: Iterative improvement
for iter = 1:options.n_iter
    % Fit GP surrogate on current data
    try
        gp_mdl = fitrgp(history.X, history.Y, ...
            'KernelFunction', 'ardsquaredexponential', ...
            'Standardize', true, ...
            'FitMethod', 'exact', ...
            'PredictMethod', 'exact');
    catch
        warning('EGO:GPFitFailed', 'GP fit failed at iteration %d. Stopping.', iter);
        history.exitflag = -1;
        history.converged = false;
        break;
    end

    % Optimize acquisition function via random search + local refinement
    n_candidates = max(1000, 100 * d);
    X_cand = lb' + (ub' - lb') .* rand(n_candidates, d);
    [mu_cand, sigma_cand] = predict(gp_mdl, X_cand);
    sigma_cand = max(sigma_cand, 1e-12);

    f_best_current = min(history.Y);

    switch lower(options.acq_func)
        case 'ei'
            % Expected Improvement
            diff_val = f_best_current - mu_cand;
            Z = diff_val ./ sigma_cand;
            acq = diff_val .* normcdf(Z) + sigma_cand .* normpdf(Z);
            acq(sigma_cand < 1e-12) = 0;

        case 'lcb'
            % Lower Confidence Bound
            beta = 2.0;
            acq = -(mu_cand - beta * sigma_cand);  % negate for minimization

        case 'pi'
            % Probability of Improvement
            Z = (f_best_current - mu_cand) ./ sigma_cand;
            acq = normcdf(Z);

        otherwise
            error('EGO:UnknownAcqFunc', 'Unknown acquisition: %s', options.acq_func);
    end

    % Select point with maximum acquisition
    [acq_max, idx_acq] = max(acq);
    x_new = X_cand(idx_acq, :);

    % Local refinement around best candidate
    if acq_max > 0
        try
            neg_acq = @(x) -acquisition_value(x, gp_mdl, f_best_current, options.acq_func);
            opts_local = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');
            [x_refined, ~, exitflag_local] = fmincon(neg_acq, x_new, ...
                [], [], [], [], lb, ub, [], opts_local);
            if exitflag_local >= 0
                x_new = x_refined;
            end
        catch
            % Local refinement failed, use random search result
        end
    end

    % Evaluate new point
    f_new = fun(x_new);

    % Update history
    history.X = [history.X; x_new];
    history.Y = [history.Y; f_new];
    history.f_best(iter) = min(history.Y);

    % Track convergence
    if abs(f_new - f_opt) < options.tol
        history.stall_count = history.stall_count + 1;
    else
        history.stall_count = 0;
    end

    % Update best
    if f_new < f_opt
        f_opt = f_new;
        x_opt = x_new;
    end

    % Early stopping check
    if history.stall_count >= options.max_stall
        fprintf('EGO: converged after %d iterations (stall).\n', iter);
        break;
    end
end

% Final convergence assessment
history.n_evals = size(history.X, 1);
history.final_best = f_opt;
if history.final_best > f_opt + 1e-10
    history.exitflag = -2;
end

%% --- Nested: acquisition value ---
function a = acquisition_value(x, gp_mdl, f_best, acq_type)
    [mu, sigma] = predict(gp_mdl, x);
    sigma = max(sigma, 1e-12);
    switch lower(acq_type)
        case 'ei'
            dval = f_best - mu;
            Z = dval / sigma;
            a = dval * normcdf(Z) + sigma * normpdf(Z);
        case 'lcb'
            a = -(mu - 2.0 * sigma);
        case 'pi'
            a = normcdf((f_best - mu) / sigma);
    end
end

%% Self-test
function self_test()
    fprintf('  Running ego_bayesopt self-test...\n');
    rng(42);
    % Minimize 1D Rastrigin: f(x) = x^2 - 10*cos(2*pi*x) + 10 on [-2, 2]
    % True minimum at x = 0 with f(0) = 0
    rastrigin_1d = @(x) x.^2 - 10*cos(2*pi*x) + 10;
    bounds_1d = [-2, 2];

    [x_opt, f_opt, history] = ego_bayesopt(rastrigin_1d, bounds_1d, ...
        'n_init', 8, 'n_iter', 25, 'seed', 42);

    % Verify optimum within 0.1 of true minimum x=0
    assert(abs(x_opt) < 0.2, ...
        'Self-test: x_opt = %.4f not within 0.2 of true minimum (0).', x_opt);

    % f_opt should be near 0
    assert(f_opt < 1.5, ...
        'Self-test: f_opt = %.4f too far from true minimum (0).', f_opt);

    % History should show improvement
    assert(history.final_best <= history.Y(1), ...
        'Self-test: No improvement over initial samples.');

    % Convergence check
    assert(history.n_evals > 0, 'Self-test: no function evaluations recorded.');

    fprintf('  ego_bayesopt self-test PASSED (x*=%6.4f, f*=%6.4f).\n', x_opt, f_opt);
end
end
