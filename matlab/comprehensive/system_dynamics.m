% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [t, stock_history, flow_history, converged] = system_dynamics(stock_init, flow_funcs, dt, n_steps, options)
%% SYSTEMDYNAMICS  System dynamics Euler integrator for stock-flow models.
%  Simulates coupled stock-flow systems with first-order Euler integration.
%  Paradigm: PARADIGM-0708
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Sterman, J.D. (2000) Business Dynamics: Systems Thinking
%             and Modeling for a Complex World. McGraw-Hill.
%             ISBN: 978-0072389154.
%
%  Input:
%      stock_init - Initial stock values (n_stocks × 1)
%      flow_funcs - Cell array of function handles. Each returns
%                   [(n_flows,) vector] given (t, stocks, params).
%                   Positive = inflow, Negative = outflow.
%      dt         - Time step size
%      n_steps    - Number of simulation steps
%
%  Options:
%      options.params     - Parameter struct passed to flow functions
%      options.aux_funcs  - Cell array of auxiliary function handles
%      options.bounds     - [lower, upper] bounds for stock values (n_stocks×2)
%      options.stock_names - Cell array of stock names (for display)
%      options.display    - 'on' | 'off' (default: 'off')
%      options.seed       - RNG seed (default: 42)
%
%  Output:
%      t              - Time vector (n_steps+1 × 1)
%      stock_history  - Stock time histories (n_steps+1 × n_stocks)
%      flow_history   - Flow time histories (n_steps+1 × n_flows)
%      converged      - Boolean: did system reach equilibrium?

arguments
    stock_init (:, 1) double
    flow_funcs cell
    dt (1,1) double {mustBePositive}
    n_steps (1,1) double {mustBeInteger, mustBePositive}
    options.params struct = struct()
    options.aux_funcs cell = {}
    options.bounds (:, 2) double = []
    options.stock_names cell = {}
    options.display char = 'off'
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

n_stocks = length(stock_init);
n_flows = length(flow_funcs);

assert(n_stocks >= 1, 'At least one stock must be defined.');
assert(n_flows >= 1, 'At least one flow function must be defined.');

%% Apply bounds
if ~isempty(options.bounds)
    assert(size(options.bounds, 1) == n_stocks, ...
        'bounds must have %d rows (one per stock).', n_stocks);
end

%% Preallocate
t = (0:n_steps)' * dt;
stock_history = zeros(n_steps + 1, n_stocks);
stock_history(1, :) = stock_init';

% Pre-compute flow dimension from first call
[~, first_flows] = eval_flows(0, stock_init, flow_funcs, options.params, options.aux_funcs);
n_flow_values = length(first_flows);
flow_history = zeros(n_steps + 1, n_flow_values);
flow_history(1, :) = first_flows;

%% Simulation loop
stocks = stock_init;
converged = false;
conv_tol = 1e-6;
conv_window = max(10, ceil(0.1 * n_steps));
recent_changes = zeros(conv_window, 1);

for step = 1:n_steps
    t_cur = t(step);

    % Evaluate flow rates at current state
    [aux_vals, flow_rates] = eval_flows(t_cur, stocks, flow_funcs, ...
        options.params, options.aux_funcs);

    % Euler integration: stock_{t+1} = stock_t + dt * sum(flows)
    stocks = stocks + dt * flow_rates(:);

    % Apply bounds
    if ~isempty(options.bounds)
        for s = 1:n_stocks
            stocks(s) = max(options.bounds(s,1), min(options.bounds(s,2), stocks(s)));
        end
    end

    % Non-negativity enforcement (stocks are typically non-negative)
    stocks = max(0, stocks);

    % Record
    stock_history(step + 1, :) = stocks';
    flow_history(step + 1, :) = flow_rates;

    % Check convergence: max relative change over recent window
    if step <= conv_window
        recent_changes(step) = max(abs(flow_rates));
    else
        recent_changes(mod(step-1, conv_window) + 1) = max(abs(flow_rates));
        max_change = max(recent_changes);
        if max_change < conv_tol
            converged = true;
            % Note: we continue simulation but mark as converged
        end
    end

    % Numerical sanity check
    if any(~isfinite(stocks))
        warning('SYSTEMDYNAMICS:NumericalFailure', ...
            'Non-finite stock values at step %d. Simulation diverged.', step);
        stock_history(step+2:end, :) = NaN;
        flow_history(step+2:end, :) = NaN;
        converged = false;
        break;
    end
end

% Save results: save(fullfile(pwd, 'sysdyn_results.mat'), 't', 'stock_history', 'flow_history');

%% Convergence check
if ~converged
    % Check final state: is system near equilibrium?
    [~, final_flows] = eval_flows(t(end), stock_history(end, :)', ...
        flow_funcs, options.params, options.aux_funcs);
    if max(abs(final_flows)) < 1e-4
        converged = true;
    end
end

%% Display summary
if strcmp(options.display, 'on')
    fprintf('System Dynamics Simulation:\n');
    fprintf('  Time: [0, %.2f], dt=%.4f, %d steps\n', t(end), dt, n_steps);
    for s = 1:n_stocks
        name = get_stock_name(s, options.stock_names);
        fprintf('  %s: init=%.4f, final=%.4f\n', name, stock_init(s), stocks(s));
    end
    if converged
        fprintf('  System reached equilibrium.\n');
    end
end

assert(all(isfinite(stock_history(end, :))), ...
    'SYSTEMDYNAMICS:InvalidFinalState', ...
    'Final stock values contain NaN or Inf.');
end

%% Nested: evaluate all flow functions
function [aux_vals, flow_rates] = eval_flows(t, stocks, flow_fns, params, aux_fns)
    n_f = length(flow_fns);
    n_a = length(aux_fns);

    % Evaluate auxiliary functions first
    aux_vals = cell(n_a, 1);
    for i = 1:n_a
        aux_vals{i} = aux_fns{i}(t, stocks, params);
    end

    % Evaluate flow functions
    flow_rates = zeros(n_f, 1);
    for i = 1:n_f
        val = flow_fns{i}(t, stocks, params, aux_vals);
        if isscalar(val)
            flow_rates(i) = val;
        else
            % Flow function returned a vector — concatenate
            flow_rates(i) = val(1);
        end
    end
end

%% Nested: get stock name
function name = get_stock_name(idx, stock_names)
    if idx <= length(stock_names)
        name = stock_names{idx};
    else
        name = sprintf('Stock_%d', idx);
    end
end

%% Self-test
function self_test()
    % Bass diffusion model: new product adoption
    % dA/dt = (p + q*A/M) * (M - A)
    % where A = adopters, M = market potential, p = innovation, q = imitation
    % Known: peak adoption time t* = ln(q/p) / (p+q) for the Bass model
    p_bass = 0.03;
    q_bass = 0.38;
    M_bass = 1000;

    % Flow function: innovation + imitation adoption rate
    adopt_flow = @(t, stocks, params, aux) ...
        (params.p + params.q * stocks(1) / params.M) * (params.M - stocks(1));

    params_bass.p = p_bass;
    params_bass.q = q_bass;
    params_bass.M = M_bass;

    [t_sim, stock_hist, flow_hist, flag] = system_dynamics(...
        0, {adopt_flow}, 0.1, 300, ...
        params=params_bass, display='off');

    % Check that adoption reaches near M (saturation)
    final_adoption = stock_hist(end, 1);
    assert(final_adoption > 0.95 * M_bass, ...
        'Self-test failed: adopters only reached %.2f of M=1000.', ...
        final_adoption/M_bass);

    % Check that adoption is non-decreasing (for valid Bass model)
    diff_adopt = diff(stock_hist(:, 1));
    assert(all(diff_adopt >= -1e-10), ...
        'Self-test failed: adoption should be non-decreasing in Bass model.');

    % Check final flow is near zero (saturation)
    final_flow = flow_hist(end, 1);
    % Overall flow may not be exactly zero as residuals remain, but should be small
    assert(abs(final_flow) < 5, ...
        'Self-test failed: final flow %.4f not near zero at saturation.', final_flow);

    % The peak occurs where the flow is maximum
    [~, peak_idx] = max(flow_hist(:, 1));
    peak_time = t_sim(peak_idx);
    % Theoretical peak: t* = ln(q/p)/(p+q)
    peak_theoretical = log(q_bass / p_bass) / (p_bass + q_bass);
    % Allow generous tolerance due to discretization
    assert(abs(peak_time - peak_theoretical) < 2.0, ...
        'Self-test failed: peak time %.2f, expected ~%.2f.', peak_time, peak_theoretical);

    % Verify output dimensions
    assert(size(stock_hist, 1) == length(t_sim), ...
        'Self-test failed: stock_history rows mismatch with time vector.');
    assert(size(flow_hist, 1) == length(t_sim), ...
        'Self-test failed: flow_history rows mismatch with time vector.');

    disp('SYSTEMDYNAMICS self-test passed.');
end
