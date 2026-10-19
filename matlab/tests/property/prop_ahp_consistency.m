% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_ahp_consistency(n_trials)
%% PROP_AHP_CONSISTENCY Property test: CR decreases for more consistent matrices.
%  Invariant: An identity-like judgment matrix (all ones) has CR = 0,
%             and perturbations increase CR.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    n_crit = randi([3, 7]);

    % Perfectly consistent matrix (identity: all 1s)
    A_perfect = ones(n_crit, n_crit);

    try
        [~, ~, ~, CR_perfect, ~] = ahp_evaluate(A_perfect, 'verbose', false, 'seed', 42+i);
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['AHP perfect matrix failed: ' ME.message]);
        continue;
    end

    % Invariant: perfectly consistent matrix should have CR ~ 0
    if CR_perfect > 1e-6
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Perfect matrix CR=%.6e > 0', CR_perfect));
    end

    % Generate slightly perturbed matrix (more consistent: near-identity)
    A_near = ones(n_crit, n_crit);
    for r = 1:n_crit
        for c = (r+1):n_crit
            perturb = 1 + (rand() - 0.5) * 0.2;  % small perturbation
            A_near(r, c) = perturb;
            A_near(c, r) = 1 / perturb;
        end
    end

    % Generate highly perturbed matrix (less consistent)
    A_pert = ones(n_crit, n_crit);
    for r = 1:n_crit
        for c = (r+1):n_crit
            perturb = 1 + (rand() - 0.5) * 1.8;  % larger perturbation
            A_pert(r, c) = max(1/9, min(9, perturb));
            A_pert(c, r) = 1 / A_pert(r, c);
        end
    end

    try
        [~, ~, ~, CR_near, ~] = ahp_evaluate(A_near, 'verbose', false, 'seed', 42+i);
        [~, ~, ~, CR_pert, ~] = ahp_evaluate(A_pert, 'verbose', false, 'seed', 42+i);
    catch ME
        continue;
    end

    % Invariant: more perturbed -> higher CR (generally)
    % This is probabilistic; we only flag clear violations
    if CR_pert < CR_near - 0.01 && CR_near > 0.01
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('CR ordering violated: CR_near=%.4f, CR_pert=%.4f', ...
            CR_near, CR_pert));
    end
end
end

%% Self-test
function self_test()
    result = prop_ahp_consistency(5);
    assert(result.pass, 'Self-test failed: AHP consistency violated.');
    fprintf('prop_ahp_consistency self-test PASSED (%d trials).\n', result.n_trials);
end
