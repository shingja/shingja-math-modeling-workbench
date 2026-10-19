% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [model, y_pred, anova_tbl] = rsm_poly(X, y, Xnew, options)
%% RSM_POLY  Polynomial Response Surface Methodology
%  Paradigm: SURROGATE-003 | Category: ⑩ | Version: v3.0.0
%  Reference: Myers, Montgomery & Anderson-Cook (2016) Response Surface
%             Methodology, 4th ed. Wiley.
%
%  Functions:
%    rsm_fit(X,y,degree)        -> model (fitlm object + metadata)
%    rsm_predict(model,Xnew)    -> y_pred
%    rsm_anova(model)           -> ANOVA table

arguments
    X (:, :) double                  % design matrix [n x d]
    y (:, 1) double                  % response vector [n x 1]
    Xnew (:, :) double = []          % prediction points
    options.seed (1,1) double = 42
    options.degree (1,1) double {mustBeInteger, mustBeInRange(options.degree, 1, 5)} = 2
    options.interactions (1,1) logical = true
    options.standardize (1,1) logical = false
end

rng(options.seed, 'twister');

%% --- rsm_fit: build polynomial response surface ---
[N, D] = size(X);
assert(N >= 3, 'RSM:TooFewPoints', 'Need at least 3 data points.');
assert(size(y,1) == N, 'RSM:DimMismatch', 'X and y must have same number of rows.');

% Generate polynomial feature matrix
X_poly = build_poly_features(X, options.degree, options.interactions);

% Standardize if requested
if options.standardize
    X_poly_mean = mean(X_poly, 1);
    X_poly_std  = std(X_poly, 0, 1);
    X_poly_std(X_poly_std == 0) = 1;
    X_poly = (X_poly - X_poly_mean) ./ X_poly_std;
end

% Fit linear model
mdl = fitlm(X_poly, y, 'Intercept', true);

% Build model struct
model = struct();
model.lm           = mdl;
model.degree       = options.degree;
model.interactions = options.interactions;
model.n_features   = size(X_poly, 2);
model.r_squared    = mdl.Rsquared.Ordinary;
model.r_squared_adj = mdl.Rsquared.Adjusted;
model.rmse         = mdl.RMSE;
model.converged    = true;
model.exitflag     = 1;

% Convergence / quality checks
if model.r_squared_adj < 0
    warning('RSM:PoorFit', 'Adjusted R-squared = %.4f is negative. Model may overfit or be misspecified.', ...
        model.r_squared_adj);
    model.exitflag = 0;
end
assert(model.rmse >= 0, 'RSM:NegativeRMSE', 'RMSE must be nonnegative.');

% Numerical sanity: residuals should be finite
resid = mdl.Residuals.Raw;
assert(all(isfinite(resid)), 'RSM:BadResiduals', 'Residuals contain non-finite values.');

%% --- rsm_predict ---
if ~isempty(Xnew)
    Xnew_poly = build_poly_features(Xnew, options.degree, options.interactions);
    if options.standardize
        Xnew_poly = (Xnew_poly - X_poly_mean) ./ X_poly_std;
    end
    y_pred = predict(mdl, Xnew_poly);
    assert(all(isfinite(y_pred)), 'RSM:NonFinitePred', ...
        'Predictions contain non-finite values.');
else
    y_pred = [];
end

%% --- rsm_anova ---
if nargout >= 3
    anova_tbl = anova(mdl, 'summary');
end

%% --- Nested: build_poly_features ---
function XP = build_poly_features(Xdata, deg, interactions_flag)
    [Npts, Dpts] = size(Xdata);
    XP = Xdata;  % linear terms always included (if deg >= 1)
    if deg >= 2
        % Pure quadratic terms
        XP = [XP, Xdata.^2];
        % Interactions
        if interactions_flag
            for i = 1:Dpts
                for j = i+1:Dpts
                    XP = [XP, Xdata(:,i) .* Xdata(:,j)];
                end
            end
        end
    end
    if deg >= 3
        % Cubic terms
        XP = [XP, Xdata.^3];
        if interactions_flag
            for i = 1:Dpts
                for j = i+1:Dpts
                    XP = [XP, Xdata(:,i).^2 .* Xdata(:,j), ...
                               Xdata(:,i) .* Xdata(:,j).^2];
                end
            end
            if Dpts >= 3
                for i = 1:Dpts
                    for j = i+1:Dpts
                        for k = j+1:Dpts
                            XP = [XP, Xdata(:,i) .* Xdata(:,j) .* Xdata(:,k)];
                        end
                    end
                end
            end
        end
    end
    if deg >= 4
        XP = [XP, Xdata.^4];
    end
    if deg >= 5
        XP = [XP, Xdata.^5];
    end
end

%% Self-test
function self_test()
    fprintf('  Running rsm_poly self-test...\n');
    rng(42);
    % Generate data from z = 2*x^2 + 3*y^2 + x*y + noise
    n = 50;
    X_pts = randn(n, 2);
    y_true = 2*X_pts(:,1).^2 + 3*X_pts(:,2).^2 + X_pts(:,1).*X_pts(:,2);
    y_obs = y_true + 0.1 * randn(n, 1);

    [model, y_pred, anova_tbl] = rsm_poly(X_pts, y_obs, X_pts, 'degree', 2);

    % R-squared should be high
    assert(model.r_squared > 0.9, 'Self-test: R^2 = %.4f too low.', model.r_squared);

    % Predictions should be close to true values
    pred_rmse = sqrt(mean((y_pred - y_true).^2));
    assert(pred_rmse < 1.0, 'Self-test: prediction RMSE = %.4f too large.', pred_rmse);

    % ANOVA table should exist
    assert(~isempty(anova_tbl), 'Self-test: ANOVA table is empty.');

    % Model converged
    assert(model.converged, 'Self-test: model did not converge.');
    assert(model.exitflag == 1, 'Self-test: exitflag != 1.');

    fprintf('  rsm_poly self-test PASSED.\n');
end
end
