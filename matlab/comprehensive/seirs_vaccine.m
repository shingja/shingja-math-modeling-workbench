% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = seirs_vaccine(options)
%% SEIRS_VACCINE SEIRS + vaccination compartment model. Paradigm: PARADIGM-0805-SEIRS-VACCINE. v3.0.0.
%   dS/dt = -beta*S*I/N - v*S + omega*R
%   dE/dt =  beta*S*I/N - sigma*E
%   dI/dt =  sigma*E - gamma*I
%   dR/dt =  gamma*I + v*S - omega*R
%
%   Inputs:
%       options.N         - total population (default: 1000)
%       options.beta      - transmission rate (default: 0.3)
%       options.sigma     - incubation rate 1/incubation_period (default: 0.2)
%       options.gamma     - recovery rate (default: 0.1)
%       options.omega     - immunity waning rate (default: 0.01)
%       options.v         - vaccination rate (default: 0.0)
%       options.I0        - initial infected (default: 1)
%       options.E0        - initial exposed (default: 0)
%       options.R0        - initial recovered (default: 0)
%       options.tspan     - time span [t0, tf] (default: [0, 365])
%       options.seed      - random seed (default: 42)
%
%   Outputs:
%       result.t          - time vector
%       result.S, .E, .I, .R - compartment time series
%       result.R0_eff     - effective reproduction number
%       result.R0_baseline- basic reproduction number without vaccine
%       result.exitflag   - 1 if integration completed

arguments
    options.N (1,1) double {mustBePositive} = 1000
    options.beta (1,1) double {mustBePositive} = 0.3
    options.sigma (1,1) double {mustBePositive} = 0.2
    options.gamma (1,1) double {mustBePositive} = 0.1
    options.omega (1,1) double = 0.01
    options.v (1,1) double = 0.0
    options.I0 (1,1) double {mustBePositive} = 1
    options.E0 (1,1) double = 0
    options.R0_init (1,1) double = 0
    options.tspan (1,2) double = [0, 365]
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

% Extract parameters
N = options.N;
beta = options.beta;
sigma = options.sigma;
gamma = options.gamma;
omega = options.omega;
v = options.v;

% Initial conditions
S0 = N - options.I0 - options.E0 - options.R0_init;
E0 = options.E0;
I0 = options.I0;
R0 = options.R0_init;

% Verify initial conditions
if S0 < 0
    error('SEIRS:InvalidInit', 'Initial conditions sum to more than N.');
end

% ODE system
    function dydt = seirs_ode(~, y)
        S = y(1);
        E = y(2);
        I = y(3);
        R = y(4);

        dS = -beta * S * I / N - v * S + omega * R;
        dE =  beta * S * I / N - sigma * E;
        dI =  sigma * E - gamma * I;
        dR =  gamma * I + v * S - omega * R;

        dydt = [dS; dE; dI; dR];
    end

% Solve ODE
y0 = [S0; E0; I0; R0];
ode_opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

[t_sol, y_sol] = ode45(@seirs_ode, options.tspan, y0, ode_opts);

% Check integration success
if length(t_sol) < 2
    warning('SEIRS:IntegrationFailed', 'ODE integration produced too few points.');
    exitflag = -1;
else
    exitflag = 1;
end

% Extract compartments
S_sol = y_sol(:, 1);
E_sol = y_sol(:, 2);
I_sol = y_sol(:, 3);
R_sol = y_sol(:, 4);

% Verify population conservation
total_pop = S_sol + E_sol + I_sol + R_sol;
max_deviation = max(abs(total_pop - N));

% Compute reproduction numbers
% R0_baseline = beta / gamma (without vaccine, without waning)
R0_baseline = beta / gamma;

% R0_eff with vaccination: R0 * (1 - v/beta) in simplified form
% More precisely: at disease-free equilibrium with vaccination,
% susceptible fraction = 1/(1 + v/omega) when omega > 0
if omega > 0
    s_star = omega / (omega + v);
else
    s_star = 1;
end
R0_eff = R0_baseline * s_star;

% Final epidemic size metrics
R_final = R_sol(end);
I_max = max(I_sol);
t_peak = t_sol(find(I_sol == I_max, 1));

% Package results
result.t = t_sol;
result.S = S_sol;
result.E = E_sol;
result.I = I_sol;
result.R = R_sol;
result.total_pop = total_pop;
result.max_pop_deviation = max_deviation;
result.R0_baseline = R0_baseline;
result.R0_eff = R0_eff;
result.final_epidemic_size = R_final;
result.I_max = I_max;
result.t_peak = t_peak;
result.exitflag = exitflag;
result.params = struct('N', N, 'beta', beta, 'sigma', sigma, ...
                       'gamma', gamma, 'omega', omega, 'v', v);

%% Self-test
    function self_test()
        fprintf('Running seirs_vaccine self-test...\n');

        % Test 1: SEIRS without vaccine (baseline)
        opts1.N = 1000;
        opts1.beta = 0.3;
        opts1.sigma = 0.2;
        opts1.gamma = 0.1;
        opts1.omega = 0.01;
        opts1.v = 0.0;
        opts1.I0 = 1;
        opts1.tspan = [0, 200];
        opts1.seed = 42;

        r1 = seirs_vaccine(opts1);

        % Assert 1: total population conserved (within tolerance)
        assert(r1.max_pop_deviation < 1e-6, ...
            'SEIRS self-test FAIL: population not conserved (deviation=%.2e)', ...
            r1.max_pop_deviation);

        % Assert 2: R0_baseline = beta/gamma
        assert(abs(r1.R0_baseline - 0.3/0.1) < 1e-10, ...
            'SEIRS self-test FAIL: R0_baseline incorrect');

        % Test 2: SEIRS with vaccination (v=0.05, 5% vaccination rate)
        opts2 = opts1;
        opts2.v = 0.05;

        r2 = seirs_vaccine(opts2);

        % Assert 3: total population conserved
        assert(r2.max_pop_deviation < 1e-6, ...
            'SEIRS self-test FAIL: population not conserved with vaccine');

        % Assert 4: R0_eff < R0_baseline when vaccination is active
        assert(r2.R0_eff < r2.R0_baseline, ...
            'SEIRS self-test FAIL: R0_eff (%.3f) not less than R0_baseline (%.3f)', ...
            r2.R0_eff, r2.R0_baseline);

        % Assert 5: vaccination reduces final epidemic size
        assert(r2.final_epidemic_size < r1.final_epidemic_size, ...
            'SEIRS self-test FAIL: vaccination did not reduce epidemic size');

        % Assert 6: I_max > 0 (epidemic occurred)
        assert(r1.I_max > 0, ...
            'SEIRS self-test FAIL: no epidemic (I_max=0)');

        % Assert 7: exitflag = 1
        assert(r1.exitflag == 1 && r2.exitflag == 1, ...
            'SEIRS self-test FAIL: exitflag not 1');

        disp('seirs_vaccine self-test passed.');
    end

self_test();
end
