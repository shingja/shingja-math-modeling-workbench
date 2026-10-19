% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [weights, centers, y_pred, r2] = rbf_surrogate(X, y, Xnew, options)
%% RBF_SURROGATE  Radial Basis Function surrogate model
%  Paradigm: SURROGATE-002 | Category: ⑩ | Version: v3.0.0
%  Reference: Buhmann (2003) Radial Basis Functions. Cambridge University Press.
%
%  Functions:
%    rbf_fit(X,y,kernel)        -> [weights, centers]
%    rbf_predict(w,centers,Xnew) -> y_pred
%
%  Kernels: 'gaussian', 'multiquadric', 'inverse-multiquadric', 'thinplate'

arguments
    X (:, :) double                  % training inputs  [n x d]
    y (:, 1) double                  % training outputs [n x 1]
    Xnew (:, :) double               % test inputs
    options.seed (1,1) double = 42
    options.kernel (1,:) char {mustBeMember(options.kernel, ...
        {'gaussian','multiquadric','inverse-multiquadric','thinplate'})} = 'gaussian'
    options.epsilon (1,1) double = -1  % shape param, -1 => auto
    options.regularize (1,1) double = 1e-8
end

rng(options.seed, 'twister');

%% --- rbf_fit: compute weights and centers ---
[N, D] = size(X);
assert(N >= 2, 'RBF:TooFewPoints', 'Need at least 2 training points.');
assert(size(y,1) == N, 'RBF:DimMismatch', 'X and y must have same number of rows.');

% Use training points as centers
centers = X;

% Auto-select shape parameter if not provided
if options.epsilon <= 0
    % Median pairwise distance heuristic
    if N <= 200
        Dmat = pdist2(X, X);
        Dvec = Dmat(Dmat > 0);
        options.epsilon = median(Dvec);
    else
        % Sample to avoid O(N^2)
        idx = randperm(N, min(N, 200));
        Dmat = pdist2(X(idx,:), X(idx,:));
        Dvec = Dmat(Dmat > 0);
        options.epsilon = median(Dvec);
    end
    if options.epsilon < 1e-10
        options.epsilon = 1.0;
    end
end

% Build interpolation matrix Phi
Phi = rbf_kernel(X, centers, options.kernel, options.epsilon);

% Add regularization for numerical stability
Phi_reg = Phi + options.regularize * eye(N);

% Solve linear system: Phi * w = y
weights = Phi_reg \ y;

% Check conditioning and convergence
cond_num = cond(Phi_reg);
converged = cond_num < 1e12;
if ~converged
    warning('RBF:PoorConditioning', ...
        'RBF matrix condition number %.2e > 1e12, results may be unreliable.', cond_num);
end

% R-squared at training points (for diagnostics)
y_train_pred = Phi * weights;
SS_res = sum((y - y_train_pred).^2);
SS_tot = sum((y - mean(y)).^2);
if SS_tot > 0
    r2 = 1 - SS_res / SS_tot;
else
    r2 = NaN;
end

% Numerical sanity: residuals should be small for well-conditioned system
assert(~converged || max(abs(y - y_train_pred)) < 1e3 * std(y) + 1e-6, ...
    'RBF:LargeResiduals', 'Training residuals too large.');

%% --- rbf_predict ---
if nargin >= 3 && ~isempty(Xnew)
    Phi_new = rbf_kernel(Xnew, centers, options.kernel, options.epsilon);
    y_pred = Phi_new * weights;
    assert(all(isfinite(y_pred)), 'RBF:NonFinitePred', ...
        'Predictions contain non-finite values.');
else
    y_pred = [];
end

%% --- Nested: rbf_kernel ---
function K = rbf_kernel(A, B, kernel_type, eps_val)
    % Compute RBF kernel matrix between A (m x d) and B (n x d)
    D2 = pdist2(A, B).^2;
    switch lower(kernel_type)
        case 'gaussian'
            K = exp(-D2 / (2 * eps_val^2));
        case 'multiquadric'
            K = sqrt(D2 + eps_val^2);
        case 'inverse-multiquadric'
            K = 1 ./ sqrt(D2 + eps_val^2);
        case 'thinplate'
            K = D2 .* log(sqrt(D2) + 1e-12);
            K(isnan(K)) = 0;
        otherwise
            error('RBF:UnknownKernel', 'Unknown kernel: %s', kernel_type);
    end
end

%% Self-test
function self_test()
    fprintf('  Running rbf_surrogate self-test...\n');
    rng(42);
    % Fit 1D parabola y = x^2 with 4 points
    X_train = [-2; 0; 1; 3];
    y_train = X_train.^2;
    [weights, centers, y_pred, r2] = rbf_surrogate(X_train, y_train, X_train, ...
        'kernel', 'gaussian');

    % R^2 should be > 0.99 at training points
    assert(r2 > 0.99, 'Self-test: R^2 = %.4f at training points, expected > 0.99.', r2);

    % Test prediction at new points
    X_test = [-1.5; 0.5; 2.0; 2.5];
    y_true = X_test.^2;
    [~, ~, y_pred_test] = rbf_surrogate(X_train, y_train, X_test, ...
        'kernel', 'gaussian');
    pred_mae = mean(abs(y_pred_test - y_true));
    assert(pred_mae < 2.0, 'Self-test: prediction MAE = %.4f too large.', pred_mae);

    % Test multiquadric kernel
    [~, ~, y_pred_mq] = rbf_surrogate(X_train, y_train, X_test, ...
        'kernel', 'multiquadric');
    assert(all(isfinite(y_pred_mq)), 'Self-test: multiquadric kernel failed.');

    fprintf('  rbf_surrogate self-test PASSED.\n');
end
end
