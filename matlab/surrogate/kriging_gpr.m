% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [model, mu_pred, sigma_pred, ei] = kriging_gpr(X, y, Xnew, options)
%% KRIGING_GPR  Kriging / Gaussian Process Regression surrogate model
%  Paradigm: SURROGATE-001 | Category: ⑩ | Version: v3.0.0
%  Reference: Rasmussen & Williams (2006) Gaussian Processes for Machine Learning. MIT Press.
%
%  Functions:
%    gpr_fit(X,y)        -> model (returns struct with GP model + params)
%    gpr_predict(model,X) -> [mu, sigma]
%    gpr_ei(model,X,ybest) -> expected improvement vector
%
%  Usage:
%    [model, mu, sigma, ei] = kriging_gpr(Xtrain, ytrain, Xtest)
%    model = kriging_gpr(Xtrain, ytrain)    % fit only

arguments
    X (:, :) double                 % training inputs  [n x d]
    y (:, 1) double                 % training outputs [n x 1]
    Xnew (:, :) double = []         % test inputs (empty => fit only)
    options.seed (1,1) double = 42
    options.kernel (1,:) char {mustBeMember(options.kernel, ...
        {'squaredexponential','matern32','matern52','ardexponential',...
         'ardmatern32','ardmatern52','ardrationalquadratic'})} = 'ardsquaredexponential'
    options.standardize (1,1) logical = true
    options.optimize_hyperparams (1,1) logical = true
end

rng(options.seed, 'twister');

%% --- gpr_fit: build GP model ---
[N, D] = size(X);
assert(N >= 2, 'KRIGING:TooFewPoints', 'Need at least 2 training points.');
assert(size(y,1) == N, 'KRIGING:DimMismatch', 'X and y must have same number of rows.');

if options.standardize
    X_mean = mean(X, 1);
    X_std  = std(X, 0, 1);
    X_std(X_std == 0) = 1;
    X_scaled = (X - X_mean) ./ X_std;
    y_mean = mean(y);
    y_std  = std(y);
    if y_std == 0, y_std = 1; end
    y_scaled = (y - y_mean) ./ y_std;
else
    X_scaled = X;
    X_mean = zeros(1, D); X_std = ones(1, D);
    y_scaled = y;
    y_mean = 0; y_std = 1;
end

% Fit GP model using fitrgp
if options.optimize_hyperparams
    gp_model = fitrgp(X_scaled, y_scaled, ...
        'KernelFunction', options.kernel, ...
        'Standardize', false, ...
        'FitMethod', 'exact', ...
        'PredictMethod', 'exact');
else
    gp_model = fitrgp(X_scaled, y_scaled, ...
        'KernelFunction', options.kernel, ...
        'Standardize', false, ...
        'FitMethod', 'exact', ...
        'PredictMethod', 'exact', ...
        'OptimizeHyperparameters', 'none');
end

% Store everything in model struct
model = struct();
model.gp         = gp_model;
model.X_mean     = X_mean;
model.X_std      = X_std;
model.y_mean     = y_mean;
model.y_std      = y_std;
model.standardize = options.standardize;
model.converged  = true;   % fitrgp reports convergence internally
model.exitflag   = 1;
model.N_train    = N;
model.kernel     = options.kernel;

% Check GP convergence via log-likelihood finiteness
ll = gp_model.LogLikelihood;
if ~isfinite(ll)
    model.converged = false;
    model.exitflag = -1;
    warning('KRIGING:ConvergenceIssue', ...
        'GP log-likelihood is not finite. Model may be unreliable.');
end

%% --- Common arrays for output ---
mu_pred    = [];
sigma_pred = [];
ei         = [];

%% --- gpr_predict ---
if ~isempty(Xnew)
    if options.standardize
        Xnew_scaled = (Xnew - X_mean) ./ X_std;
    else
        Xnew_scaled = Xnew;
    end
    [mu_scaled, sigma_scaled] = predict(gp_model, Xnew_scaled);
    mu_pred    = mu_scaled * y_std + y_mean;
    sigma_pred = sigma_scaled * y_std;

    % Numerical sanity: sigma must be nonnegative
    assert(all(sigma_pred >= -1e-10), 'KRIGING:NegativeSigma', ...
        'Prediction variance must be nonnegative.');
    sigma_pred = max(sigma_pred, 0);

    %% --- gpr_ei: Expected Improvement ---
    % EI(x) = (ybest - mu) * Phi(Z) + sigma * phi(Z),  Z = (ybest - mu)/sigma
    if nargout >= 4
        ybest = min(y);  % for minimization (default)
        sigma_pos = sigma_pred;
        sigma_pos(sigma_pos < 1e-12) = 1e-12;
        Z = (ybest - mu_pred) ./ sigma_pos;
        ei = (ybest - mu_pred) .* normcdf(Z) + sigma_pos .* normpdf(Z);
        ei(ei < 0) = 0;
        assert(all(isfinite(ei)), 'KRIGING:BadEI', 'EI values must be finite.');
    end
end

%% Self-test
function self_test()
    fprintf('  Running kriging_gpr self-test...\n');
    rng(42);
    % Fit sin(x) on [-pi, pi] with 5 points, predict at 20
    X_train = linspace(-pi, pi, 5)';
    y_train = sin(X_train);
    X_test  = linspace(-pi, pi, 20)';

    [model, mu, sigma] = kriging_gpr(X_train, y_train, X_test, 'seed', 42);
    y_true = sin(X_test);

    % Predictions should be within 3*sigma of true values
    within_3sigma = all(abs(mu - y_true) <= 3 * sigma + 1e-6);
    assert(within_3sigma, 'Self-test: predictions not within 3-sigma bound.');

    % At training points, error should be very small
    [~, mu_train, ~] = kriging_gpr(X_train, y_train, X_train, 'seed', 42);
    train_mae = mean(abs(mu_train - y_train));
    assert(train_mae < 0.5, 'Self-test: training MAE too large (%.4f).', train_mae);

    % EI at test points should be nonnegative
    [~, ~, ~, ei_test] = kriging_gpr(X_train, y_train, X_test, 'seed', 42);
    assert(all(ei_test >= -1e-12), 'Self-test: EI must be nonnegative.');

    % Convergence check
    assert(model.converged, 'Self-test: GP model did not converge.');
    assert(model.exitflag == 1, 'Self-test: exitflag != 1.');

    fprintf('  kriging_gpr self-test PASSED.\n');
end
end
