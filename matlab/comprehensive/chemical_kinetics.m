% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = chemical_kinetics(options)
%% CHEMICAL_KINETICS Solve ODE for first-order reaction chain A -> B -> C. Paradigm: PARADIGM-0814-CHEMICAL-KINETICS. v3.0.0.
%   d[A]/dt = -k1*[A]
%   d[B]/dt =  k1*[A] - k2*[B]
%   d[C]/dt =  k2*[B]
%
%   Analytical solution:
%     [A](t) = A0 * exp(-k1*t)
%     [B](t) = A0 * k1/(k2-k1) * (exp(-k1*t) - exp(-k2*t))
%     [C](t) = A0 * (1 + (k1*exp(-k2*t) - k2*exp(-k1*t))/(k2-k1))
%   Peak B at t_peak = ln(k1/k2) / (k1 - k2)
%
%   Inputs:
%       options.k1         - rate constant A->B (default: 0.3)
%       options.k2         - rate constant B->C (default: 0.1)
%       options.y0         - initial [A; B; C] (default: [1; 0; 0])
%       options.tspan      - time span (default: [0, 50])
%       options.seed       - random seed (default: 42)
%
%   Outputs:
%       result.t           - time vector
%       result.y           - solution [A, B, C] (Nt x 3)
%       result.analytical  - analytical solution at same t points
%       result.t_peak_B    - time of peak [B]
%       result.B_peak      - maximum [B] concentration
%       result.exitflag    - 1 if integration completed

arguments
    options.k1 (1,1) double {mustBePositive} = 0.3
    options.k2 (1,1) double {mustBePositive} = 0.1
    options.y0 (3,1) double = [1; 0; 0]
    options.tspan (1,2) double = [0, 50]
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

k1_val = options.k1;
k2_val = options.k2;
A0 = options.y0(1);

% Verify masses sum to A0
if abs(sum(options.y0) - A0) > 1e-10 && A0 > 0
    warning('KINETICS:BadInit', 'Initial masses don''t sum to A0. Normalizing.');
    options.y0 = options.y0 / sum(options.y0) * A0;
end

% ODE system
    function dydt = kinetics_ode(~, y)
        A = y(1);
        B = y(2);
        % C = y(3);  % Not needed for RHS, but tracked implicitly

        dA = -k1_val * A;
        dB =  k1_val * A - k2_val * B;
        dC =  k2_val * B;

        dydt = [dA; dB; dC];
    end

% Solve ODE
ode_opts = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
[t_sol, y_sol] = ode45(@kinetics_ode, options.tspan, options.y0, ode_opts);

% Check integration success
if length(t_sol) < 2
    warning('KINETICS:IntegrationFailed', 'ODE integration failed.');
    exitflag = -1;
else
    exitflag = 1;
end

% Analytical solution at t_sol points
A_analytical = A0 * exp(-k1_val * t_sol);

if abs(k1_val - k2_val) < 1e-12
    % Special case k1 = k2
    B_analytical = A0 * k1_val * t_sol .* exp(-k1_val * t_sol);
    C_analytical = A0 * (1 - exp(-k1_val * t_sol) - k1_val * t_sol .* exp(-k1_val * t_sol));
else
    B_analytical = A0 * k1_val / (k2_val - k1_val) * ...
                   (exp(-k1_val * t_sol) - exp(-k2_val * t_sol));
    C_analytical = A0 * (1 + (k1_val * exp(-k2_val * t_sol) - ...
                              k2_val * exp(-k1_val * t_sol)) / (k2_val - k1_val));
end

% Find peak B numerically from ODE solution
[B_peak_num, peak_idx] = max(y_sol(:, 2));
t_peak_num = t_sol(peak_idx);

% Analytical peak time
if abs(k1_val - k2_val) < 1e-12
    t_peak_analytical = 1 / k1_val;
else
    t_peak_analytical = log(k1_val / k2_val) / (k1_val - k2_val);
end

% Analytical peak B value
B_peak_analytical = A0 * (k1_val / k2_val) ^ (k1_val / (k2_val - k1_val)) * ...
                    exp(-k1_val * t_peak_analytical);

% Mass conservation check
total_mass = y_sol(:, 1) + y_sol(:, 2) + y_sol(:, 3);
max_mass_error = max(abs(total_mass - A0));

% Exponential decay check: linear fit to log(A)
log_A = log(max(y_sol(:, 1), 1e-15));
idx_valid = y_sol(:, 1) > 1e-6;
if sum(idx_valid) > 5
    p = polyfit(t_sol(idx_valid), log_A(idx_valid), 1);
    fitted_k1 = -p(1);
    r_squared = 1 - sum((log_A(idx_valid) - polyval(p, t_sol(idx_valid))).^2) / ...
                sum((log_A(idx_valid) - mean(log_A(idx_valid))).^2);
else
    fitted_k1 = NaN;
    r_squared = NaN;
end

% Package results
result.t = t_sol;
result.y = y_sol;
result.A = y_sol(:, 1);
result.B = y_sol(:, 2);
result.C = y_sol(:, 3);
result.analytical.A = A_analytical;
result.analytical.B = B_analytical;
result.analytical.C = C_analytical;
result.t_peak_B = t_peak_num;
result.t_peak_B_analytical = t_peak_analytical;
result.B_peak = B_peak_num;
result.B_peak_analytical = B_peak_analytical;
result.max_mass_error = max_mass_error;
result.fitted_k1 = fitted_k1;
result.r_squared = r_squared;
result.exitflag = exitflag;

%% Self-test
    function self_test()
        fprintf('Running chemical_kinetics self-test...\n');

        opts.k1 = 0.3;
        opts.k2 = 0.1;
        opts.y0 = [1; 0; 0];
        opts.tspan = [0, 50];
        opts.seed = 42;

        r = chemical_kinetics(opts);

        % Assert 1: total mass conserved ([A]+[B]+[C]=1)
        assert(r.max_mass_error < 1e-8, ...
            'Chem-Kin self-test FAIL: mass not conserved (max error=%.2e)', ...
            r.max_mass_error);

        % Assert 2: peak B occurs at correct analytical time
        t_peak_expected = log(0.3/0.1) / (0.3 - 0.1);  % = ln(3)/0.2
        assert(abs(r.t_peak_B - t_peak_expected) / t_peak_expected < 0.02, ...
            'Chem-Kin self-test FAIL: B peak time %.4f not near expected %.4f', ...
            r.t_peak_B, t_peak_expected);

        % Assert 3: A decays exponentially (fitted k1 near true k1)
        assert(abs(r.fitted_k1 - 0.3) < 0.02, ...
            'Chem-Kin self-test FAIL: fitted k1=%.4f not near 0.3', r.fitted_k1);

        % Assert 4: r_squared of exponential fit > 0.99
        assert(r.r_squared > 0.99, ...
            'Chem-Kin self-test FAIL: exponential fit R^2=%.4f not > 0.99', r.r_squared);

        % Assert 5: B_peak > 0 (intermediate accumulates)
        assert(r.B_peak > 0, ...
            'Chem-Kin self-test FAIL: no B accumulation (B_peak=%.4f)', r.B_peak);

        % Assert 6: A monotonically decreases
        assert(all(diff(r.A) <= 1e-10), ...
            'Chem-Kin self-test FAIL: A not monotonic decreasing');

        % Assert 7: exitflag = 1
        assert(r.exitflag == 1, ...
            'Chem-Kin self-test FAIL: exitflag not 1');

        disp('chemical_kinetics self-test passed.');
    end

self_test();
end
