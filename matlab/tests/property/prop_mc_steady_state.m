% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_mc_steady_state(n_trials)
%% PROP_MC_STEADY_STATE Property test: Steady state satisfies pi*P = pi.
%  Invariant: For any valid stochastic matrix P, the stationary distribution
%             pi computed by markov_chain('steady_state', P) must satisfy pi*P = pi.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_states = randi([2, 8]);

    % Generate random stochastic matrix (rows sum to 1)
    P = rand(n_states, n_states);
    P = P ./ sum(P, 2);  % normalize rows

    % Ensure irreducibility: add small uniform perturbation
    P = 0.95 * P + 0.05 * (ones(n_states) / n_states);
    P = P ./ sum(P, 2);

    try
        pi = markov_chain('steady_state', P);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Markov chain steady_state failed: ' ME.message]);
        continue;
    end

    % Invariant 1: pi*P should equal pi
    pi_P = pi * P;
    err = max(abs(pi_P - pi));
    if err > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('pi*P != pi: max|err|=%.2e', err));
    end

    % Invariant 2: pi should sum to 1
    if abs(sum(pi) - 1) > 1e-8
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('pi sum = %.10f != 1', sum(pi)));
    end

    % Invariant 3: all pi entries non-negative
    if any(pi < -1e-10)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', 'Steady state pi has negative entries.');
    end
end
end

%% Self-test
function self_test()
    result = prop_mc_steady_state(5);
    assert(result.pass, 'Self-test failed: Markov chain steady state violated.');
    fprintf('prop_mc_steady_state self-test PASSED (%d trials).\n', result.n_trials);
end
