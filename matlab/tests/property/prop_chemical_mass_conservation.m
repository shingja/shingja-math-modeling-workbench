% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = prop_chemical_mass_conservation(n_trials)
%% PROP_CHEMICAL_MASS_CONSERVATION Property test: Chemical kinetics [A]+[B]+[C] = constant.
%  Invariant: For A -> B -> C reaction chain, total mass is conserved.
%  [A](t) + [B](t) + [C](t) = A0 + B0 + C0 for all t.

arguments
    n_trials (1,1) double {mustBePositive} = 100
end

rng(42, 'twister');
result.pass = true;
result.violations = [];
result.n_trials = n_trials;

for i = 1:n_trials
    % Generate random reaction parameters
    k1 = 0.05 + rand() * 1.5;
    k2 = 0.02 + rand() * 1.0;
    A0_val = 0.5 + rand() * 5;
    B0_val = rand() * 2;
    C0_val = rand() * 1;
    total_mass = A0_val + B0_val + C0_val;
    t_end = 10 + rand() * 40;
    tspan = [0, t_end];

    try
        res = chemical_kinetics(struct('k1', k1, 'k2', k2, ...
            'y0', [A0_val; B0_val; C0_val], 'tspan', tspan, 'seed', 42+i));
    catch ME
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', ['Chemical kinetics solve failed: ' ME.message]);
        continue;
    end

    % Invariant: [A]+[B]+[C] = total_mass
    mass_sum = sum(res.y, 2);  % sum across columns: A+B+C at each t
    violation_idx = find(abs(mass_sum - total_mass) > 1e-6 * max(total_mass, 1), 1);

    if ~isempty(violation_idx)
        result.pass = false;
        result.violations(end+1) = struct('trial', i, ...
            'violation', sprintf('Mass not conserved at t=%.2f: sum=%.6e, expected=%.6e', ...
            res.t(violation_idx), mass_sum(violation_idx), total_mass));
    end
end
end

%% Self-test
function self_test()
    result = prop_chemical_mass_conservation(5);
    assert(result.pass, 'Self-test failed: mass conservation violated.');
    fprintf('prop_chemical_mass_conservation self-test PASSED (%d trials).\n', result.n_trials);
end
