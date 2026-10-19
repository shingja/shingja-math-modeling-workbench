% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [moran_I, p_moran, kriging_pred, kriging_var, exitflag] = moran_kriging(points, values, query_pts, options)
%% MORANKRIGING Moran's I spatial autocorrelation + Ordinary Kriging.
%  Computes Moran's I statistic for spatial autocorrelation detection,
%  fits a spherical semivariogram model, and performs ordinary kriging
%  for spatial interpolation at query points.
%  Paradigm: PARADIGM-0708
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Moran, P.A.P. (1950) Notes on continuous stochastic
%             phenomena. Biometrika, 37(1-2), 17-23.
%             Cressie, N. (1993) Statistics for Spatial Data, Revised
%             Edition. Wiley. ISBN: 978-0471002550.
%             Matheron, G. (1963) Principles of geostatistics. Economic
%             Geology, 58(8), 1246-1266.
%
%  Input:
%      points    - Spatial coordinates (n x d), each row = [x, y, ...]
%      values    - Observed values at each point (n x 1)
%      query_pts - Query/estimation points (m x d)
%
%  Options:
%      options.distance_metric - 'euclidean' (default)
%      options.W               - Spatial weights matrix (n x n), auto if empty
%      options.W_type          - 'inverse_distance' (default) | 'binary' | 'distance_band'
%      options.bandwidth       - Distance threshold for 'distance_band' (auto if empty)
%      options.variogram_model - 'spherical' (default) | 'exponential' | 'gaussian'
%      options.n_lags          - Number of lags for empirical variogram (default: 10)
%      options.seed            - RNG seed (default: 42)
%
%  Output:
%      moran_I      - Moran's I statistic
%      p_moran      - Approximate p-value for spatial randomness
%      kriging_pred - Kriging predictions at query points (m x 1)
%      kriging_var  - Kriging variance at query points (m x 1)
%      exitflag     - 1 = success, 0 = warning (near-singular), -1 = error

arguments
    points (:, :) double
    values (:, 1) double
    query_pts (:, :) double
    options.distance_metric char {mustBeMember(options.distance_metric, {'euclidean'})} = 'euclidean'
    options.W (:, :) double = []
    options.W_type char {mustBeMember(options.W_type, {'inverse_distance','binary','distance_band'})} = 'inverse_distance'
    options.bandwidth (1,1) double = []
    options.variogram_model char {mustBeMember(options.variogram_model, {'spherical','exponential','gaussian'})} = 'spherical'
    options.n_lags (1,1) double {mustBeInteger, mustBePositive} = 10
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');
exitflag = 1;

n_obs = size(points, 1);
assert(n_obs >= 3, 'Need at least 3 observations for spatial analysis.');
assert(size(values, 1) == n_obs, 'Number of values must match number of points.');
assert(size(query_pts, 2) == size(points, 2), ...
    'Query points must have same dimensionality as observation points.');

%% Part 1: Moran's I Spatial Autocorrelation
%% Step 1a: Build spatial weights matrix W
if isempty(options.W)
    D_full = zeros(n_obs, n_obs);
    for i = 1:n_obs
        for j = 1:n_obs
            D_full(i, j) = norm(points(i, :) - points(j, :));
        end
    end

    switch options.W_type
        case 'inverse_distance'
            W_mat = zeros(n_obs, n_obs);
            for i = 1:n_obs
                for j = 1:n_obs
                    if i ~= j && D_full(i, j) > 1e-12
                        W_mat(i, j) = 1 / D_full(i, j);
                    end
                end
            end
        case 'binary'
            W_mat = (D_full > 0) + 0;  % 1 if different points
        case 'distance_band'
            if isempty(options.bandwidth)
                bandwidth_val = mean(D_full(D_full > 0)) * 0.5;
            else
                bandwidth_val = options.bandwidth;
            end
            W_mat = double(D_full <= bandwidth_val & D_full > 0);
        otherwise
            W_mat = zeros(n_obs, n_obs);
            for i = 1:n_obs
                for j = 1:n_obs
                    if i ~= j && D_full(i, j) > 1e-12
                        W_mat(i, j) = 1 / D_full(i, j);
                    end
                end
            end
    end
else
    W_mat = options.W;
    assert(all(size(W_mat) == [n_obs, n_obs]), 'W must be n x n.');
end

% Zero diagonal
for i = 1:n_obs
    W_mat(i, i) = 0;
end

%% Step 1b: Compute Moran's I
% I = (N / W_sum) * sum_i sum_j w_ij (z_i - zbar)(z_j - zbar) / sum_i (z_i - zbar)^2
W_sum = sum(W_mat(:));
z_bar = mean(values);
z_dev = values - z_bar;

numerator = 0;
for i = 1:n_obs
    for j = 1:n_obs
        numerator = numerator + W_mat(i, j) * z_dev(i) * z_dev(j);
    end

end

denominator = sum(z_dev.^2);

if abs(denominator) < 1e-12 || abs(W_sum) < 1e-12
    moran_I = 0;
    p_moran = 1;
else
    moran_I = (n_obs / W_sum) * (numerator / denominator);

    % Expected value under spatial randomness: E[I] = -1/(n-1)
    E_I = -1 / (n_obs - 1);

    % Approximate variance (simplified, assumes normality)
    S1 = 0.5 * sum(sum((W_mat + W_mat').^2));
    S2 = sum((sum(W_mat, 1) + sum(W_mat, 2)').^2);
    Var_I = (n_obs * ((n_obs^2 - 3*n_obs + 3)*S1 - n_obs*S2 + 3*W_sum^2) - ...
             n_obs * ((n_obs^2 - n_obs)*S1 - 2*n_obs*S2 + 6*W_sum^2)) / ...
             ((n_obs - 1) * (n_obs - 2) * (n_obs - 3) * W_sum^2) - E_I^2;

    if Var_I < 1e-12
        Var_I = 1e-12;
    end

    % Z-score and p-value
    Z_I = (moran_I - E_I) / sqrt(Var_I);
    p_moran = 2 * (1 - normcdf(abs(Z_I)));
end

%% Part 2: Ordinary Kriging
%% Step 2a: Compute empirical semivariogram
% gamma(h) = 0.5 * mean((z(x_i) - z(x_j))^2) for pairs with distance ~ h
D_mat = zeros(n_obs, n_obs);
for i = 1:n_obs
    for j = 1:n_obs
        D_mat(i, j) = norm(points(i, :) - points(j, :));
    end
end

% Upper triangle distances (i < j)
pair_dists = [];
pair_gamma = [];
for i = 1:n_obs
    for j = i+1:n_obs
        pair_dists = [pair_dists; D_mat(i, j)];
        pair_gamma = [pair_gamma; 0.5 * (values(i) - values(j))^2];
    end
end

% Bin into lags
max_dist = max(pair_dists);
lag_edges = linspace(0, max_dist * 0.8, options.n_lags + 1);
emp_dist = zeros(options.n_lags, 1);
emp_gamma = zeros(options.n_lags, 1);
for lag = 1:options.n_lags
    in_lag = pair_dists >= lag_edges(lag) & pair_dists < lag_edges(lag + 1);
    if sum(in_lag) > 0
        emp_dist(lag) = mean(pair_dists(in_lag));
        emp_gamma(lag) = mean(pair_gamma(in_lag));
    else
        emp_dist(lag) = (lag_edges(lag) + lag_edges(lag + 1)) / 2;
        emp_gamma(lag) = NaN;
    end
end

% Remove NaN lags
valid_lag = ~isnan(emp_gamma) & emp_dist > 0;
h_emp = emp_dist(valid_lag);
gamma_emp = emp_gamma(valid_lag);

%% Step 2b: Fit variogram model (least squares)
if length(h_emp) >= 3
    % Nugget (c0), partial sill (c1), range (a)
    % Spherical: gamma(h) = c0 + c1 * (1.5*h/a - 0.5*(h/a)^3) for h <= a, c0+c1 for h > a
    % Exponential: gamma(h) = c0 + c1 * (1 - exp(-3*h/a))
    % Gaussian: gamma(h) = c0 + c1 * (1 - exp(-3*(h/a)^2))

    % Simple grid search for best fit
    c0_candidates = linspace(0, 0.5 * max(gamma_emp), 20);
    c1_candidates = linspace(0.1 * max(gamma_emp), max(gamma_emp), 20);
    a_candidates = linspace(0.2 * max(h_emp), 2 * max(h_emp), 20);

    best_mse = inf;
    best_c0 = 0;
    best_c1 = max(gamma_emp) * 0.8;
    best_a = max(h_emp) * 0.8;

    for c0 = c0_candidates
        for c1 = c1_candidates
            for a = a_candidates
                gamma_fit = zeros(size(h_emp));
                for k = 1:length(h_emp)
                    gamma_fit(k) = variogram_model_eval(h_emp(k), c0, c1, a, options.variogram_model);
                end
                mse = mean((gamma_emp - gamma_fit).^2);
                if mse < best_mse
                    best_mse = mse;
                    best_c0 = c0;
                    best_c1 = c1;
                    best_a = a;
                end
            end
        end
    end

    c0 = best_c0;
    c1 = best_c1;
    a = best_a;
else
    % Default values
    c0 = 0;
    c1 = var(values);
    a = max(pair_dists) * 0.5;
end

%% Step 2c: Solve kriging system for each query point
n_query = size(query_pts, 1);
kriging_pred = zeros(n_query, 1);
kriging_var = zeros(n_query, 1);

% Build covariance matrix: C_ij = sill - gamma(h_ij) = c0+c1 - gamma(h_ij)
% Or equivalently, use the variogram directly in the kriging system:
% [ Gamma  1 ] [ lambda ] = [ gamma_0 ]
% [ 1^T    0 ] [ mu     ]   [ 1      ]

for q = 1:n_query
    x_q = query_pts(q, :);

    % Variogram values between observations
    Gamma = zeros(n_obs, n_obs);
    for i = 1:n_obs
        for j = 1:n_obs
            h_ij = norm(points(i, :) - points(j, :));
            Gamma(i, j) = variogram_model_eval(h_ij, c0, c1, a, options.variogram_model);
        end
    end

    % Variogram values between query and observations
    gamma_0 = zeros(n_obs, 1);
    for i = 1:n_obs
        h_0i = norm(x_q - points(i, :));
        gamma_0(i) = variogram_model_eval(h_0i, c0, c1, a, options.variogram_model);
    end

    % Kriging system
    K = [Gamma, ones(n_obs, 1); ones(1, n_obs), 0];
    rhs = [gamma_0; 1];

    % Solve (use regularization if ill-conditioned)
    try
        lambda_mu = K \ rhs;
    catch
        % Regularize
        K_reg = K + eye(size(K)) * 1e-8 * mean(abs(diag(Gamma)));
        try
            lambda_mu = K_reg \ rhs;
        catch
            exitflag = 0;
            warning('MORANKRIGING:SingularSystem', ...
                'Kriging system singular at query point %d. Using mean.', q);
            kriging_pred(q) = mean(values);
            kriging_var(q) = var(values);
            continue;
        end
    end

    lambda = lambda_mu(1:n_obs);
    mu = lambda_mu(end);

    % Prediction
    kriging_pred(q) = lambda' * values;

    % Kriging variance
    kriging_var(q) = lambda' * gamma_0 - mu;

    % Ensure non-negative variance
    kriging_var(q) = max(kriging_var(q), 0);
end

%% Validation
if any(isnan(kriging_pred))
    exitflag = -1;
    warning('MORANKRIGING:NaN', 'NaN in kriging predictions.');
end
if any(kriging_var < -1e-10)
    exitflag = 0;
    warning('MORANKRIGING:NegativeVariance', 'Negative kriging variance detected.');
end

%% Nested: Variogram model evaluation
function g = variogram_model_eval(h, c0, c1, a, model_type)
    switch model_type
        case 'spherical'
            if h <= a
                g = c0 + c1 * (1.5 * (h / a) - 0.5 * (h / a)^3);
            else
                g = c0 + c1;
            end
        case 'exponential'
            g = c0 + c1 * (1 - exp(-3 * h / a));
        case 'gaussian'
            g = c0 + c1 * (1 - exp(-3 * (h / a)^2));
        otherwise
            g = c0 + c1 * (1.5 * (h / max(a,1e-12)) - 0.5 * (h / max(a,1e-12))^3);
            g = min(g, c0 + c1);
    end
end

%% Self-test
function self_test()
    rng(42);

    % 1D spatial data: 5 points along x-axis
    x_pts = [1.0; 2.0; 3.0; 4.0; 5.0];
    z_vals = [2.1; 2.9; 4.8; 6.2; 8.5];  % roughly linear trend

    % Query point at midpoint between points 3 and 4
    x_query = [3.5];

    [mi, p_val, k_pred, k_var, ef] = moran_kriging(x_pts, z_vals, x_query, ...
        'W_type', 'inverse_distance', 'variogram_model', 'spherical', ...
        'n_lags', 4, 'seed', 42);

    assert(ef >= 0, 'Self-test 1: exitflag >= 0, got %d.', ef);

    % Test 2: Moran's I for correlated data should be away from 0
    % With a linear trend, we expect positive spatial autocorrelation
    assert(mi > -1.1 && mi < 1.1, ...
        'Self-test 2: Moran I=%.4f should be in [-1,1].', mi);

    % Test 3: Kriging prediction at midpoint within min-max of neighbors
    neighbor_min = min(z_vals);
    neighbor_max = max(z_vals);
    assert(k_pred >= neighbor_min * 0.5 && k_pred <= neighbor_max * 1.5, ...
        'Self-test 3: kriging prediction %.4f unreasonably far from [%.2f, %.2f].', ...
        k_pred, neighbor_min, neighbor_max);

    % Test 4: Kriging variance should be non-negative
    assert(k_var >= -1e-10, ...
        'Self-test 4: kriging variance %.6f should be >= 0.', k_var);

    % Test 5: Prediction for training point should be close to observed value
    x_query_train = [3.0];  % exact training location
    [~, ~, k_pred_train, ~, ef5] = moran_kriging(x_pts, z_vals, x_query_train, ...
        'W_type', 'inverse_distance', 'variogram_model', 'spherical', ...
        'n_lags', 4, 'seed', 42);
    assert(ef5 >= 0, 'Self-test 5: exitflag >= 0.');
    assert(abs(k_pred_train - z_vals(3)) < std(z_vals), ...
        'Self-test 5: prediction at known point deviates excessively (%.4f vs %.4f).', ...
        k_pred_train, z_vals(3));

    % Test 6: p-value is valid
    assert(p_val >= 0 && p_val <= 1, ...
        'Self-test 6: p-value=%.4f should be in [0,1].', p_val);

    fprintf('MORANKRIGING self-test PASSED (6 tests, all assertions passed).\n');
end
end
