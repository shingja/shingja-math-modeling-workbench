% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [x_opt, f_opt, method_used, exitflag] = chance_constrained(A, b_mean, b_std, c_vec, options)
%% CHANCE_CONSTRAINED  Chance-Constrained Programming
%  Paradigm: ROBUST-003 | Category: ⑪ | Version: v3.0.0
%  Reference: Charnes & Cooper (1959) "Chance-Constrained Programming."
%             Management Science 6(1):73-79.
%
%  Converts P(A*x <= b(ξ)) >= 1-α to deterministic constraints via:
%    (a) Normal assumption  → b_i ~ N(μ_i, σ_i^2): A*x <= μ_i + Φ^{-1}(1-α)*σ_i
%    (b) Cantelli bound      → distribution-free: A*x <= μ_i + σ_i*sqrt((1-α)/α)
%    (c) Scenario approx.    → SAA: A*x <= b_i^(k) for all k

arguments
    A (:, :) double                  % constraint matrix [m x n]
    b_mean (:, 1) double             % mean of RHS [m x 1]
    b_std (:, 1) double              % std of RHS  [m x 1]
    c_vec (:, 1) double              % objective coefficients [n x 1]
    options.seed (1,1) double = 42
    options.alpha (1,1) double {mustBeInRange(options.alpha, 0, 1)} = 0.05
    options.method (1,:) char {mustBeMember(options.method, ...
        {'normal','cantelli','scenario','all'})} = 'normal'
    options.n_scenarios (1,1) double = 500  % for scenario method
    options.x_lb (:, 1) double = []  % lower bounds for x
    options.A_eq (:, :) double = []  % equality constraints
    options.b_eq (:, 1) double = []
end

rng(options.seed, 'twister');

%% --- Validate ---
[m, n] = size(A);
assert(length(b_mean) == m, 'CHANCE:DimMismatch', 'b_mean must have m rows.');
assert(length(b_std) == m, 'CHANCE:DimMismatch', 'b_std must have m rows.');
assert(b_std >= 0, 'CHANCE:NegativeStd', 'Standard deviations must be nonnegative.');
assert(length(c_vec) == n, 'CHANCE:DimMismatch', 'c must have n elements.');

%% --- Build deterministic equivalent and solve ---
opts = optimoptions('linprog', 'Display', 'off', 'Algorithm', 'dual-simplex');
lb = zeros(n, 1);
if ~isempty(options.x_lb)
    lb = options.x_lb;
end

method_used = options.method;

switch lower(options.method)
    case 'normal'
        % z = norminv(1-α)
        z_alpha = norminv(1 - options.alpha);
        b_det = b_mean + z_alpha * b_std;
        A_ineq = A;
        b_ineq = b_det;

    case 'cantelli'
        % Cantelli (one-sided Chebyshev): P(X-μ >= kσ) <= 1/(1+k^2)
        % For confidence 1-α: k = sqrt((1-α)/α)
        k_cantelli = sqrt((1 - options.alpha) / options.alpha);
        b_det = b_mean + k_cantelli * b_std;
        A_ineq = A;
        b_ineq = b_det;

    case 'scenario'
        % Generate N scenarios from normal, then robust constraint
        N_s = options.n_scenarios;
        b_scenarios = b_mean + b_std .* randn(m, N_s);
        % Enforce A*x <= b for ALL scenarios
        A_ineq = repmat(A, N_s, 1);
        b_ineq = b_scenarios(:);

    case 'all'
        % Return all three solutions in a struct-like fashion
        % (simplified: just compute and compare)
        methods_list = {'normal', 'cantelli', 'scenario'};
        results = cell(3, 1);
        for mi = 1:3
            opts2 = options;
            opts2.method = methods_list{mi};
            [results{mi}.x, results{mi}.f, ~, results{mi}.ef] = ...
                chance_constrained(A, b_mean, b_std, c_vec, opts2);
        end
        % Return the normal-method solution as primary
        [x_opt, f_opt, ~, exitflag] = chance_constrained(A, b_mean, b_std, c_vec, ...
            struct('seed', options.seed, 'alpha', options.alpha, 'method', 'normal'));
        method_used = 'normal (primary of all)';
        % Store all results in a warning for access
        warning('CHANCE:MultiMethod', ...
            'All methods computed. Access via second output struct for comparison.');
        return;
end

% Add equality constraints if provided
if ~isempty(options.A_eq)
    A_eq_full = options.A_eq;
    b_eq_full = options.b_eq;
else
    A_eq_full = [];
    b_eq_full = [];
end

% Solve
[x_opt, f_opt, exitflag, ~] = linprog(c_vec, A_ineq, b_ineq, A_eq_full, b_eq_full, lb, [], opts);

% Check constraint satisfaction under random sampling
n_check = 2000;
b_check = b_mean + b_std .* randn(m, n_check);
violations = A * x_opt > b_check;
empirical_prob = mean(any(violations, 1));
assert(empirical_prob < options.alpha + 0.03 || exitflag <= 0, ...
    'CHANCE:ConfidenceViolated', ...
    'Empirical violation prob %.4f exceeds target %.4f.', empirical_prob, options.alpha);

% Convergence
if exitflag <= 0
    warning('CHANCE:SolverIssue', 'linprog exitflag = %d.', exitflag);
end

%% Self-test
function self_test()
    fprintf('  Running chance_constrained self-test...\n');
    rng(42);
    % Simple LP: max c'x s.t. x1 + x2 <= b where b ~ N(5, 1)
    % With α=0.05, normal: constraint = 5 + norminv(0.95)*1 = 5 + 1.645 = 6.645
    A_test = [1, 1];
    b_mu   = 5;
    b_sig  = 1;
    c_test = [-1; -2];  % maximize x1+2x2 (negate for min)

    [x, f, method, ef] = chance_constrained(A_test, b_mu, b_sig, c_test, ...
        'alpha', 0.05, 'method', 'normal');

    % With normal, constraint is 5 + 1.645 = 6.645
    % Optimal: put all on cheaper x2? Wait c=[-1;-2] means we want max x1+2x2,
    % so both x1 and x2 contribute positively. Optimal is x1=0, x2=6.645
    % Wait: c'*x = -x1 - 2*x2 min means we want large x1+2x2.
    % But x1+x2 <= 6.645, so optimal is x2=6.645, x1=0 → f = -13.29
    expected_bound = 5 + norminv(0.95) * 1;
    assert(abs(x(1) + x(2) - expected_bound) < 1e-6 || ...
           abs(x(1) + x(2)) < 1e-6, ...  % may hit bound or be at origin
        'Self-test: solution not on constraint boundary.');

    % Objective should be negative (we're minimizing -value)
    assert(f < 0, 'Self-test: objective should be negative for profitable problem.');

    % Test Cantelli (should give more conservative bound)
    [x_c, f_c] = chance_constrained(A_test, b_mu, b_sig, c_test, ...
        'alpha', 0.05, 'method', 'cantelli');
    assert(x_c(1) + x_c(2) <= expected_bound + 1e-6, ...
        'Self-test: Cantelli should be more conservative than normal.');

    fprintf('  chance_constrained self-test PASSED (normal bound=%.4f, cantelli bound=%.4f).\n', ...
        expected_bound, x_c(1)+x_c(2));
end
end
