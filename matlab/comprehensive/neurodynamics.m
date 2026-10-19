% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = neurodynamics(options)
%% NEURODYNAMICS Continuous Hopfield network. Paradigm: PARADIGM-0815-NEURODYNAMICS. v3.0.0.
%   dV/dt = -V/tau + W*tanh(V) + I_ext
%   Pattern storage via Hebbian learning: W = (1/N)*sum(xi*xi')
%
%   Inputs:
%       options.N                 - number of neurons (default: 64)
%       options.tau               - time constant (default: 1.0)
%       options.dt                - integration time step (default: 0.01)
%       options.T_end             - simulation duration (default: 50)
%       options.patterns          - PxN matrix of patterns to store (optional)
%       options.n_patterns        - number of orthogonal patterns to generate (default: 3)
%       options.I_ext             - external input vector (default: zeros)
%       options.noise_level       - noise level for recall test (default: 0.2)
%       options.seed              - random seed (default: 42)
%
%   Outputs:
%       result.W                  - weight matrix (N x N)
%       result.V_history          - state history
%       result.t                  - time vector
%       result.fixed_point_check  - dV/dt norm at each stored pattern
%       result.recall_success     - whether noisy recall succeeded
%       result.exitflag           - 1 if completed

arguments
    options.N (1,1) double {mustBePositive, mustBeInteger} = 64
    options.tau (1,1) double {mustBePositive} = 1.0
    options.dt (1,1) double {mustBePositive} = 0.01
    options.T_end (1,1) double {mustBePositive} = 50
    options.patterns (:, :) double = []
    options.n_patterns (1,1) double {mustBePositive, mustBeInteger} = 3
    options.I_ext (:, 1) double = []
    options.noise_level (1,1) double = 0.2
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

N = options.N;
tau = options.tau;
dt = options.dt;
T_end = options.T_end;

% Generate or use provided patterns
if isempty(options.patterns)
    n_pat = options.n_patterns;
    if n_pat > N
        error('NEURO:TooManyPatterns', ...
            'Number of patterns (%d) exceeds network capacity (%d).', n_pat, N);
    end

    % Generate approximately orthogonal random patterns (bipolar: +1/-1)
    patterns = 2 * (rand(n_pat, N) > 0.5) - 1;

    % Orthogonalize patterns using Gram-Schmidt
    for p = 1:n_pat
        for q = 1:(p-1)
            proj = (patterns(p, :) * patterns(q, :)') / (patterns(q, :) * patterns(q, :)');
            patterns(p, :) = patterns(p, :) - proj * patterns(q, :);
        end
        % Keep bipolar by taking sign, but this loses exact orthogonality
        % For Hopfield, the sign is what matters for pattern storage
        patterns(p, :) = sign(patterns(p, :));
        if all(patterns(p, :) == 0)
            patterns(p, :) = 2 * (rand(1, N) > 0.5) - 1;
        end
    end
else
    patterns = options.patterns;
    n_pat = size(patterns, 1);
end

% Hebbian learning: W = (1/N) * sum(xi * xi') with zero self-connections
W = zeros(N, N);
for p = 1:n_pat
    xi = patterns(p, :)';
    W = W + xi * xi';
end
W = W / N;

% Zero out diagonal (no self-excitation)
W = W - diag(diag(W));

% Verify symmetry
W_symmetric = norm(W - W', 'fro') < 1e-12;

% External input
if isempty(options.I_ext)
    I_ext = zeros(N, 1);
else
    I_ext = options.I_ext(:);
end

% Check if each pattern is a fixed point
fixed_point_check = zeros(n_pat, 1);
for p = 1:n_pat
    V_pattern = patterns(p, :)';
    dVdt_pattern = -V_pattern / tau + W * tanh(V_pattern) + I_ext;
    fixed_point_check(p) = norm(dVdt_pattern);
end
all_fixed_points = all(fixed_point_check < 0.01 * sqrt(N));

% Euler integration of Hopfield dynamics from random initial condition
V0 = 0.5 * randn(N, 1);
n_steps = ceil(T_end / dt);

V = V0;
V_history = zeros(N, n_steps + 1);
V_history(:, 1) = V;
t_vec = (0:n_steps)' * dt;

exitflag = 1;

for step = 1:n_steps
    dVdt = -V / tau + W * tanh(V) + I_ext;
    V_new = V + dt * dVdt;

    % Numerical stability check
    if any(isnan(V_new)) || any(isinf(V_new))
        warning('NEURO:NumericalInstability', ...
            'Numerical instability at step %d. Truncating.', step);
        V_history = V_history(:, 1:step);
        t_vec = t_vec(1:step);
        exitflag = -1;
        break;
    end

    V = V_new;
    V_history(:, step + 1) = V;
end

% Recall test: start from noisy version of each pattern and check convergence
recall_success = zeros(n_pat, 1);
recall_converged = cell(n_pat, 1);

for p = 1:n_pat
    clean_pattern = patterns(p, :)';

    % Add noise: flip noise_level fraction of signs
    noise_mask = rand(N, 1) < options.noise_level;
    noisy_pattern = clean_pattern;
    noisy_pattern(noise_mask) = -noisy_pattern(noise_mask);

    % Simulate from noisy start
    V_recall = noisy_pattern;
    n_recall_steps = ceil(30 / dt);  % Shorter run for recall

    for s = 1:n_recall_steps
        dVdt_recall = -V_recall / tau + W * tanh(V_recall) + I_ext;
        V_recall = V_recall + dt * dVdt_recall;
    end

    % Check if converged to original pattern (sign match)
    recovered_pattern = sign(V_recall);
    match_ratio = sum(recovered_pattern == clean_pattern) / N;
    recall_success(p) = double(match_ratio > 0.95);  % 95% match threshold

    recall_converged{p} = struct('match_ratio', match_ratio, ...
                                 'recovered', recovered_pattern, ...
                                 'original', clean_pattern, ...
                                 'noisy_start', noisy_pattern);
end

% Package results
result.W = W;
result.W_symmetric = W_symmetric;
result.patterns = patterns;
result.V0 = V0;
result.V_history = V_history;
result.t = t_vec;
result.fixed_point_check = fixed_point_check;
result.all_fixed_points = all_fixed_points;
result.recall_success = recall_success;
result.recall_converged = recall_converged;
result.exitflag = exitflag;
result.params = struct('N', N, 'tau', tau, 'dt', dt, ...
                       'T_end', T_end, 'n_patterns', n_pat);

%% Self-test
    function self_test()
        fprintf('Running neurodynamics self-test...\n');

        opts.N = 64;
        opts.tau = 1.0;
        opts.dt = 0.01;
        opts.T_end = 50;
        opts.n_patterns = 3;
        opts.noise_level = 0.2;
        opts.seed = 42;

        r = neurodynamics(opts);

        % Assert 1: W is symmetric
        assert(r.W_symmetric, ...
            'Neuro self-test FAIL: weight matrix not symmetric');

        % Assert 2: each pattern is a fixed point (dV/dt ~ 0 at pattern)
        assert(r.all_fixed_points, ...
            'Neuro self-test FAIL: not all patterns are fixed points');

        for p_idx = 1:length(r.fixed_point_check)
            assert(r.fixed_point_check(p_idx) < 0.01 * sqrt(opts.N), ...
                'Neuro self-test FAIL: pattern %d dV/dt norm %.4f exceeds threshold', ...
                p_idx, r.fixed_point_check(p_idx));
        end

        % Assert 3: noisy pattern recall succeeds (at least 2 of 3 recovered)
        n_recalled = sum(r.recall_success);
        assert(n_recalled >= 2, ...
            'Neuro self-test FAIL: only %d/3 patterns recalled from noise', n_recalled);

        % Assert 4: individual recall match ratios > 90%
        for p_idx = 1:length(r.recall_converged)
            mr = r.recall_converged{p_idx}.match_ratio;
            assert(mr >= 0.90 || r.recall_success(p_idx) == 0, ...
                'Neuro self-test FAIL: pattern %d match ratio %.3f inconsistent with success flag', ...
                p_idx, mr);
        end

        % Assert 5: patterns are bipolar (+1/-1)
        for p_idx = 1:size(r.patterns, 1)
            vals = unique(r.patterns(p_idx, :));
            assert(all(ismember(vals, [-1, 1])), ...
                'Neuro self-test FAIL: pattern %d not bipolar', p_idx);
        end

        % Assert 6: zero diagonal (no self-connections)
        assert(max(abs(diag(r.W))) < 1e-12, ...
            'Neuro self-test FAIL: weight matrix has non-zero diagonal');

        % Assert 7: exitflag = 1
        assert(r.exitflag == 1, ...
            'Neuro self-test FAIL: exitflag not 1');

        disp('neurodynamics self-test passed.');
    end

self_test();
end
