% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, entropy, utility] = ewm_weight(data, options)
%% EWM_WEIGHT Entropy Weight Method for objective indicator weighting. Paradigm: PARADIGM-0303-EWM. v3.0.0.
%  Reference: Shannon, C.E. (1948) Bell System Tech. J. 27:379-423. DOI:10.1002/j.1538-7305.1948.tb01338.x
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    data (:, :) double
    options.directions (:, 1) double = []  % +1=benefit, -1=cost; defaults to all +1
    options.verbose (1,1) logical = true
    options.epsilon (1,1) double {mustBePositive} = 1e-12
end
% Validate input dimensions
[n_samples, n_indicators] = size(data);
assert(n_samples >= 2, 'ewm_weight: at least 2 samples required.');
assert(n_indicators >= 2, 'ewm_weight: at least 2 indicators required.');
% Default directions: all benefit (+1)
if isempty(options.directions)
    directions = ones(n_indicators, 1);
else
    assert(numel(options.directions) == n_indicators, ...
        'ewm_weight: directions must have one entry per indicator.');
    directions = options.directions(:);
    assert(all(abs(directions) == 1), ...
        'ewm_weight: directions must be +1 (benefit) or -1 (cost).');
end
% Step 1: Min-Max normalization
data_norm = zeros(n_samples, n_indicators);
for j = 1:n_indicators
    col = data(:, j);
    col_min = min(col);
    col_max = max(col);
    denom = col_max - col_min;
    if denom < options.epsilon
        % Constant indicator: all values equal
        data_norm(:, j) = 0.5;
    else
        if directions(j) == 1
            % Benefit: larger is better
            data_norm(:, j) = (col - col_min) / denom;
        else
            % Cost: smaller is better
            data_norm(:, j) = (col_max - col) / denom;
        end
    end
end
% Shift away from zero to avoid log(0)
data_norm = data_norm + options.epsilon;
% Step 2: Compute proportion matrix P (each column sums to 1)
col_sums = sum(data_norm, 1);
P = data_norm ./ col_sums;
% Step 3: Compute entropy for each indicator
k = 1 / log(n_samples);  % normalization constant
entropy = zeros(n_indicators, 1);
for j = 1:n_indicators
    pj = P(:, j);
    entropy(j) = -k * sum(pj .* log(pj));
end
% Step 4: Compute utility (degree of diversification)
utility = 1 - entropy;
% Step 5: Compute weights (normalized utility)
utility_sum = sum(utility);
if utility_sum < options.epsilon
    weights = ones(n_indicators, 1) / n_indicators;
else
    weights = utility / utility_sum;
end
% Sanity checks
assert(abs(sum(weights) - 1) < 1e-10, ...
    'ewm_weight: weights must sum to 1.');
assert(all(weights >= -1e-12), ...
    'ewm_weight: weights must be non-negative.');
assert(all(entropy >= 0 - 1e-12 & entropy <= 1 + 1e-12), ...
    'ewm_weight: entropy must be in [0, 1].');
if options.verbose
    fprintf('EWM: %d samples x %d indicators.\n', n_samples, n_indicators);
    fprintf('Weights: %s\n', sprintf('%.4f ', weights));
    fprintf('Entropy: %s\n', sprintf('%.4f ', entropy));
    fprintf('Utility: %s\n', sprintf('%.4f ', utility));
end
end

%% Self-test
function self_test()
    rng(42, 'twister');
    % Generate synthetic data: 10 samples x 5 indicators
    n_samples = 10;
    n_ind = 5;
    data = randn(n_samples, n_ind) * 2 + 5;  % N(5,4) per indicator
    % Indicator 3 is cost-type (smaller better), rest are benefit
    dirs = [1; 1; -1; 1; 1];

    [w, e, u] = ewm_weight(data, directions=dirs, verbose=false);

    % Assert 1: weights sum to 1
    assert(abs(sum(w) - 1) < 1e-10, ...
        sprintf('Weights sum=%.10f, expected 1.0', sum(w)));

    % Assert 2: all weights in (0, 1)
    assert(all(w > 0) && all(w < 1), ...
        'All weights must be strictly between 0 and 1.');

    % Assert 3: all entropy values in [0, 1]
    assert(all(e >= 0 - 1e-12 & e <= 1 + 1e-12), ...
        'All entropy values must be in [0, 1].');

    % Assert 4: utility + entropy = 1 for each indicator
    assert(max(abs(u + e - 1)) < 1e-10, ...
        'Utility + Entropy must equal 1 for each indicator.');

    % Assert 5: higher entropy -> lower weight (spearman rank correlation <= 0)
    rho = corr(e, w, 'Type', 'Spearman');
    assert(rho <= 0.1, ...
        sprintf('Entropy-weight Spearman rho=%.4f, expected <= 0', rho));

    % Assert 6: weights are proportional to utility
    assert(max(abs(w / sum(w) - u / sum(u))) < 1e-10, ...
        'Weights must be proportional to utility values.');

    fprintf('ewm_weight self-test passed (6 asserts, %d x %d data).\n', n_samples, n_ind);
end
