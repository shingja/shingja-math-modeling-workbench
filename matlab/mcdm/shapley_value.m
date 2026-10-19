% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [phi, marginal_contributions, shapley_std] = shapley_value(v_function, n_players, options)
%% SHAPLEY_VALUE  Shapley value for cooperative game theory
%  Paradigm: MCDM-003 | Category: ⑫ | Version: v3.0.0
%  Reference: Shapley (1953) "A Value for n-Person Games." In: Kuhn & Tucker
%             (eds) Contributions to the Theory of Games II, pp.307-317.
%
%  Computes marginal contributions for all permutations → fair allocation.

arguments
    v_function (1,1) function_handle  % v(coalition_mask) -> scalar value
    n_players (1,1) double {mustBeInteger, mustBePositive}
    options.seed (1,1) double = 42
    options.exact (1,1) logical = true    % true->exact, false->Monte Carlo approx
    options.n_samples (1,1) double {mustBeInteger, mustBePositive} = 10000
    options.coalition_values (:, 1) double = []  % precomputed 2^n vector
end

rng(options.seed, 'twister');

%% --- Validate ---
assert(n_players <= 15 || ~options.exact, ...
    'SHAPLEY:TooManyPlayers', ...
    'Exact Shapley requires 2^n evaluations. Use exact=false for n>15.');

%% --- Compute Shapley values ---
n = n_players;

if options.exact
    %% Exact computation: enumerate all 2^n coalitions
    n_coalitions = 2^n;
    % Precompute all coalition values
    v_vals = zeros(n_coalitions, 1);
    for mask = 0:(n_coalitions - 1)
        coalition = bitget(uint32(mask), 1:n);
        if isempty(options.coalition_values)
            v_vals(mask + 1) = v_function(coalition);
        else
            v_vals(mask + 1) = options.coalition_values(mask + 1);
        end
    end

    % Shapley: φ_i = (1/n!) * Σ_{S⊆N\{i}} |S|!(n-|S|-1)! [v(S∪{i}) - v(S)]
    phi = zeros(n, 1);
    marginal_contributions = zeros(n, n_coalitions / 2);  % not stored fully

    % Precompute factorials
    fact = factorial(0:n);

    for i = 1:n
        total = 0;
        for mask = 0:(n_coalitions - 1)
            coalition = bitget(uint32(mask), 1:n);
            if coalition(i) == 1
                continue;  % skip coalitions already containing i
            end
            s = sum(coalition);
            v_without = v_vals(mask + 1);
            v_with    = v_vals(mask + 2^(i-1) + 1);
            marginal = v_with - v_without;
            weight = fact(s) * fact(n - s - 1) / fact(n);
            total = total + weight * marginal;
        end
        phi(i) = total;
    end
    shapley_std = zeros(n, 1);

else
    %% Monte Carlo approximation
    N = options.n_samples;
    phi = zeros(n, 1);
    phi_sq = zeros(n, 1);

    for s = 1:N
        perm = randperm(n);
        current_coalition = false(1, n);
        current_value = 0;  % v(∅) assumed 0
        for pos = 1:n
            player = perm(pos);
            current_coalition(player) = true;
            if isempty(options.coalition_values)
                new_value = v_function(current_coalition);
            else
                idx = bin_mask_to_index(current_coalition);
                new_value = options.coalition_values(idx);
            end
            marginal = new_value - current_value;
            phi(player) = phi(player) + marginal;
            phi_sq(player) = phi_sq(player) + marginal^2;
            current_value = new_value;
        end
    end
    phi = phi / N;
    phi_sq = phi_sq / N;
    shapley_std = sqrt((phi_sq - phi.^2) / N);
    marginal_contributions = [];

    % Convergence check
    rel_err = shapley_std ./ (abs(phi) + 1e-10);
    if any(rel_err > 0.1)
        warning('SHAPLEY:HighMCError', ...
            'Monte Carlo relative error > 10%% for some players. Increase n_samples.');
    end
end

% Numerical sanity: sum of Shapley values = v(N) - v(∅)
full_grand = false(1, n);
if isempty(options.coalition_values)
    v_grand = v_function(true(1, n));
    v_empty = v_function(false(1, n));
else
    v_grand = options.coalition_values(end);   % last = all players
    v_empty = options.coalition_values(1);     % first = empty
end
assert(abs(sum(phi) - (v_grand - v_empty)) < max(1e-8, 1e-3 * abs(v_grand)), ...
    'SHAPLEY:EfficiencyCheck', ...
    'Sum of Shapley values (%.6f) != v(N)-v(∅) (%.6f).', sum(phi), v_grand - v_empty);

%% --- Helper: binary mask to index ---
function idx = bin_mask_to_index(mask)
    idx = 1 + sum(2.^(find(mask)-1));
end

%% Self-test
function self_test()
    fprintf('  Running shapley_value self-test...\n');
    rng(42);
    % Known 3-player game:
    % v({1})=0, v({2})=0, v({3})=0
    % v({1,2})=100, v({1,3})=100, v({2,3})=100
    % v({1,2,3})=300
    % Shapley values should be [100, 100, 100]
    v_coal = [0; 0; 0; 100; 0; 100; 100; 300];  % sorted by binary index
    % ordering: ∅, {1}, {2}, {1,2}, {3}, {1,3}, {2,3}, {1,2,3}
    % But: bitget orders as [1,2,3], so binary mask=0..7:
    % 0=000=∅, 1=001={1}, 2=010={2}, 3=011={1,2}, 4=100={3}, 5=101={1,3}, 6=110={2,3}, 7=111={1,2,3}
    % v values: [0, 0, 0, 100, 0, 100, 100, 300]

    v_fun = @(coal) v_coal(bin_mask_to_index(coal));

    [phi, ~, ~] = shapley_value(v_fun, 3, 'exact', true);

    % Expected: [100, 100, 100]
    expected = [100; 100; 100];
    assert(max(abs(phi - expected)) < 1e-6, ...
        'Self-test: Shapley values mismatch. Got [%.2f, %.2f, %.2f].', phi);

    % Efficiency
    assert(abs(sum(phi) - 300) < 1e-6, 'Self-test: efficiency check failed.');

    % Monte Carlo test
    [phi_mc, ~, ~] = shapley_value(v_fun, 3, 'exact', false, 'n_samples', 5000);
    assert(max(abs(phi_mc - expected)) < 10, ...
        'Self-test: MC Shapley too far from exact.');

    fprintf('  shapley_value self-test PASSED (φ=[%.2f, %.2f, %.2f]).\n', phi);
end
end
