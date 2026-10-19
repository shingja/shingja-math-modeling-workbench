% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = sir_extended(options)
%% SIR_EXTENDED Extended SIR with vital dynamics, seasonal forcing, age structure. Paradigm: PARADIGM-0810-SIR-EXTENDED. v3.0.0.
%   (a) vital dynamics: birth=death=mu
%   (b) seasonal forcing: beta(t)=beta0*(1+A*cos(2*pi*t/365))
%   (c) age structure: 2-group (young, old)
%
%   Inputs:
%       options.N          - total population vector [young, old] (default: [700, 300])
%       options.beta0      - baseline transmission (default: 0.5)
%       options.gamma      - recovery rate (default: 0.1)
%       options.mu         - birth/death rate (default: 1/(70*365))
%       options.A_seasonal - seasonal forcing amplitude (default: 0.3)
%       options.contact_matrix - 2x2 contact matrix (default: [4,1; 1,2])
%       options.I0         - initial infected [young, old] (default: [1, 0])
%       options.tspan      - time span (default: [0, 3650])
%       options.seasonal   - enable seasonal forcing (default: true)
%       options.vital      - enable vital dynamics (default: true)
%       options.seed       - random seed (default: 42)
%
%   Outputs:
%       result.t              - time vector
%       result.S, .I, .R      - compartment matrices (time x groups)
%       result.R0             - basic reproduction number
%       result.exitflag       - 1 if integration completed

arguments
    options.N (1,2) double = [700, 300]
    options.beta0 (1,1) double {mustBePositive} = 0.5
    options.gamma (1,1) double {mustBePositive} = 0.1
    options.mu (1,1) double = 1/(70*365)
    options.A_seasonal (1,1) double = 0.3
    options.contact_matrix (2,2) double = [4, 1; 1, 2]
    options.I0 (1,2) double = [1, 0]
    options.tspan (1,2) double = [0, 3650]
    options.seasonal (1,1) logical = true
    options.vital (1,1) logical = true
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

% Extract parameters
N_y = options.N(1);  % young
N_o = options.N(2);  % old
N_total = N_y + N_o;

beta0 = options.beta0;
gamma = options.gamma;
mu = options.mu;
A = options.A_seasonal;
C = options.contact_matrix;  % contact matrix

% Normalize contact matrix for frequency-dependent transmission
% Force of infection on group i = sum_j beta * C_ij * I_j / N_j

% Initial conditions
I0_y = options.I0(1);
I0_o = options.I0(2);

S0_y = N_y - I0_y;
S0_o = N_o - I0_o;
R0_y = 0;
R0_o = 0;

% ODE system: [S_y, I_y, R_y, S_o, I_o, R_o]
    function dydt = sir_ode(t, y)
        S_y = y(1); I_y = y(2); R_y = y(3);
        S_o = y(4); I_o = y(5); R_o = y(6);

        % Seasonal beta
        if options.seasonal
            beta_t = beta0 * (1 + A * cos(2 * pi * t / 365));
        else
            beta_t = beta0;
        end

        % Force of infection: lambda_i = sum_j beta * C_ij * I_j / N_j
        lambda_y = beta_t * (C(1,1) * I_y / N_y + C(1,2) * I_o / N_o);
        lambda_o = beta_t * (C(2,1) * I_y / N_y + C(2,2) * I_o / N_o);

        % Birth rate: all newborns enter young susceptible group
        birth_total = mu * N_total;

        % Vital dynamics terms
        if options.vital
            dS_y = birth_total - lambda_y * S_y - mu * S_y;
            dI_y = lambda_y * S_y - gamma * I_y - mu * I_y;
            dR_y = gamma * I_y - mu * R_y;
        else
            dS_y = -lambda_y * S_y;
            dI_y = lambda_y * S_y - gamma * I_y;
            dR_y = gamma * I_y;
        end

        if options.vital
            dS_o = -lambda_o * S_o - mu * S_o;
            dI_o = lambda_o * S_o - gamma * I_o - mu * I_o;
            dR_o = gamma * I_o - mu * R_o;
        else
            dS_o = -lambda_o * S_o;
            dI_o = lambda_o * S_o - gamma * I_o;
            dR_o = gamma * I_o;
        end

        dydt = [dS_y; dI_y; dR_y; dS_o; dI_o; dR_o];
    end

% Solve ODE
y0 = [S0_y; I0_y; R0_y; S0_o; I0_o; R0_o];
ode_opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
[t_sol, y_sol] = ode45(@sir_ode, options.tspan, y0, ode_opts);

% Check integration success
if length(t_sol) < 2
    warning('SIREXT:IntegrationFailed', 'ODE integration produced too few points.');
    exitflag = -1;
else
    exitflag = 1;
end

% Extract compartments
S_y_sol = y_sol(:, 1); I_y_sol = y_sol(:, 2); R_y_sol = y_sol(:, 3);
S_o_sol = y_sol(:, 4); I_o_sol = y_sol(:, 5); R_o_sol = y_sol(:, 6);

% Total by age group
total_young = S_y_sol + I_y_sol + R_y_sol;
total_old = S_o_sol + I_o_sol + R_o_sol;

% Compute dominant eigenvalue of next-generation matrix for R0
% At disease-free equilibrium with vital dynamics:
% F = beta0 * diag(S_i/N_i) * C, V = (gamma + mu) * eye(2)
% R0 = rho(F * V^-1) = rho(beta0/(gamma+mu) * diag(S_i/N_i) * C)
% At DFE: S_i = N_i, so diag(S_i/N_i) = eye(2)

if options.vital
    R0 = beta0 / (gamma + mu) * max(abs(eig(C)));
else
    R0 = beta0 / gamma * max(abs(eig(C)));
end

% Detect oscillations via autocorrelation of I_total
I_total = I_y_sol + I_o_sol;
if length(I_total) > 100
    I_detrended = I_total - movmean(I_total, max(10, floor(length(I_total)/20)));
    [acf_vals, lags] = xcorr(I_detrended, min(500, floor(length(I_detrended)/2)), 'coeff');
    % Find second positive peak
    acf_pos = acf_vals(lags > 0);
    lags_pos = lags(lags > 0);
    if length(acf_pos) > 10
        [~, peak_locs] = findpeaks(acf_pos);
        oscillation_period = NaN;
        if length(peak_locs) >= 2
            oscillation_period = mean(diff(lags_pos(peak_locs))) * mean(diff(t_sol));
        end
    else
        oscillation_period = NaN;
    end
else
    oscillation_period = NaN;
end

% Package results
result.t = t_sol;
result.S = [S_y_sol, S_o_sol];
result.I = [I_y_sol, I_o_sol];
result.R = [R_y_sol, R_o_sol];
result.total_young = total_young;
result.total_old = total_old;
result.total_pop = total_young + total_old;
result.R0 = R0;
result.oscillation_period = oscillation_period;
result.exitflag = exitflag;
result.params = struct('beta0', beta0, 'gamma', gamma, 'mu', mu, ...
                       'A_seasonal', A, 'contact_matrix', C);

%% Self-test
    function self_test()
        fprintf('Running sir_extended self-test...\n');

        % Test 1: Seasonal vs constant beta
        opts_seasonal.N = [700, 300];
        opts_seasonal.beta0 = 0.5;
        opts_seasonal.gamma = 0.1;
        opts_seasonal.mu = 1/(70*365);
        opts_seasonal.A_seasonal = 0.3;
        opts_seasonal.contact_matrix = [4, 1; 1, 2];
        opts_seasonal.I0 = [5, 2];
        opts_seasonal.tspan = [0, 2000];
        opts_seasonal.seasonal = true;
        opts_seasonal.vital = true;
        opts_seasonal.seed = 42;

        r_seas = sir_extended(opts_seasonal);

        % Constant beta for comparison
        opts_const = opts_seasonal;
        opts_const.seasonal = false;
        r_const = sir_extended(opts_const);

        % Assert 1: seasonal forcing produces more variance in I
        I_total_seas = sum(r_seas.I, 2);
        I_total_const = sum(r_const.I, 2);

        var_seas = var(I_total_seas(floor(end/4):end));  % post-transient
        var_const = var(I_total_const(floor(end/4):end));

        assert(var_seas > var_const, ...
            'SIR-ext self-test FAIL: seasonal variance (%.4f) not > constant variance (%.4f)', ...
            var_seas, var_const);

        % Assert 2: R0 computed and positive
        assert(r_seas.R0 > 1.0, ...
            'SIR-ext self-test FAIL: R0 (%.3f) not > 1.0', r_seas.R0);

        % Assert 3: with vital dynamics, population should approach equilibrium
        if opts_seasonal.vital
            % Check that total population is bounded (not diverging)
            pop_range = max(r_seas.total_pop) - min(r_seas.total_pop);
            assert(pop_range < 0.1 * mean(r_seas.total_pop), ...
                'SIR-ext self-test FAIL: population too variable (range=%.2f)', pop_range);
        end

        % Assert 4: two age groups have different dynamics
        % Correlation between young and old I should be < 1
        I_y_seas = r_seas.I(:, 1);
        I_o_seas = r_seas.I(:, 2);
        [R_corr, ~] = corrcoef(I_y_seas, I_o_seas);
        assert(R_corr(1,2) < 0.999, ...
            'SIR-ext self-test FAIL: age groups too correlated (%.4f)', R_corr(1,2));

        % Assert 5: exitflag = 1
        assert(r_seas.exitflag == 1, ...
            'SIR-ext self-test FAIL: exitflag not 1');

        disp('sir_extended self-test passed.');
    end

self_test();
end
