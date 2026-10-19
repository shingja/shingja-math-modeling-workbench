% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_heat_monotonic(n_trials)
%% PROP_HEAT_MONOTONIC Property test: Heat equation max temperature decreases monotonically.
%  Invariant: For 1D diffusion with Dirichlet zero boundaries,
%             maximum temperature should not increase over time.
%             max(u(:, t2)) <= max(u(:, t1)) for t2 > t1.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random initial condition (positive values, smooth)
    nx = 20 + randi([10, 80]);
    % Create a smooth "bump" initial condition
    x_vals = linspace(0, 1, nx)';
    center = 0.3 + rand() * 0.4;
    width = 0.02 + rand() * 0.15;
    amplitude = 1 + rand() * 10;
    u0 = amplitude * exp(-((x_vals - center).^2) / (2 * width^2));
    u0(1) = 0; u0(end) = 0;  % Dirichlet BC

    D = 0.1 + rand() * 2;       % diffusion coefficient
    dx = 1 / (nx - 1);
    dt = 0.4 * dx^2 / D;        % ensure CFL safety
    n_steps = 10 + randi([5, 50]);

    try
        [u_hist, ~, ~, cfl] = pde_ftcs(u0, D, dx, dt, n_steps, ...
            'bc_left', 'dirichlet', 'bc_right', 'dirichlet', ...
            'bc_val_L', 0, 'bc_val_R', 0, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Heat PDE solve failed: ' ME.message]);
        continue;
    end

    % Invariant: max temperature should be monotonically non-increasing
    max_vals = max(u_hist, [], 1);  % max per time step
    for step = 2:length(max_vals)
        if max_vals(step) > max_vals(step-1) * 1.001 && max_vals(step-1) > 1e-10
            result.pass = false;
            result.violations(end+1) = struct('trial', i, ...
                'violation', sprintf('Max temp increased: step %d: %.6e > step %d: %.6e', ...
                step, max_vals(step), step-1, max_vals(step-1)));
            break;
        end
    end
end
end

%% Self-test
function self_test()
    result = prop_heat_monotonic(5);
    assert(result.pass, 'Self-test failed: heat monotonicity violated.');
    fprintf('prop_heat_monotonic self-test PASSED (%d trials).\n', result.n_trials);
end
