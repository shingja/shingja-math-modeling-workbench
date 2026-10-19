% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [model] = adaboost_train(X, y, options)
%% ADABOOST_TRAIN AdaBoost with decision stumps (depth=1). Paradigm: PARADIGM-0602-ADABOOST. v3.0.0.
%   Sequential weight update: w_i *= exp(-alpha * y_i * h(x_i)) / Z
%   Alpha = 0.5 * log((1 - err) / err)
%
%   Inputs:
%       X           - NxD feature matrix
%       y           - Nx1 labels (+1 or -1)
%       options.n_estimators - number of weak learners (default: 50)
%       options.seed          - random seed (default: 42)
%
%   Outputs:
%       model.alphas      - 1xT vector of classifier weights
%       model.stumps      - struct array of decision stumps
%       model.n_estimators- number of trained estimators
%       model.exitflag    - convergence flag (1=completed, -1=early termination)

arguments
    X (:, :) double
    y (:, 1) double
    options.n_estimators (1,1) double {mustBePositive, mustBeInteger} = 50
    options.seed (1,1) double = 42
end

rng(options.seed, 'twister');

[N, D] = size(X);

% Ensure labels are +1/-1
y_unique = unique(y);
if length(y_unique) ~= 2
    error('ADABOOST:InvalidLabels', 'y must contain exactly two classes.');
end
if ~all(ismember(y_unique, [-1, 1]))
    % Convert to +1/-1
    y = 2 * (y == y_unique(2)) - 1;
end

% Initialize weights uniformly
w = ones(N, 1) / N;

% Storage for weak learners
alphas = zeros(1, options.n_estimators);
stumps = struct('feature', cell(1, options.n_estimators), ...
                'threshold', cell(1, options.n_estimators), ...
                'polarity', cell(1, options.n_estimators));

exitflag = 1;
used_estimators = options.n_estimators;

for t = 1:options.n_estimators
    % Train a decision stump: find best feature, threshold, and polarity
    best_err = inf;
    best_feature = 1;
    best_threshold = 0;
    best_polarity = 1;

    % Randomly sample candidate features and thresholds
    n_candidates = min(D, max(5, floor(sqrt(D))));
    candidate_features = randperm(D, n_candidates);

    for feat_idx = candidate_features
        x_col = X(:, feat_idx);
        x_sorted = sort(unique(x_col));

        % Candidate thresholds: midpoints between unique values
        if length(x_sorted) > 1
            thresholds = (x_sorted(1:end-1) + x_sorted(2:end)) / 2;
        else
            thresholds = x_sorted;
        end

        % Try a subset of thresholds for efficiency
        n_thresh = min(length(thresholds), 20);
        thresh_indices = round(linspace(1, length(thresholds), n_thresh));

        for thr_idx = thresh_indices
            thr = thresholds(thr_idx);

            for pol = [-1, 1]
                % Prediction: pol * sign(x - thr)  => +1 if pol*(x > thr), -1 otherwise
                pred = pol * (2 * (x_col > thr) - 1);  % This gives pol*sign, but sign is (2*(x>thr)-1)

                % Weighted error
                err = sum(w(pred ~= y));

                if err < best_err
                    best_err = err;
                    best_feature = feat_idx;
                    best_threshold = thr;
                    best_polarity = pol;
                end

                % Early exit if perfect
                if best_err < 1e-12
                    break;
                end
            end
            if best_err < 1e-12
                break;
            end
        end
        if best_err < 1e-12
            break;
        end
    end

    % Handle edge case: err = 0 or err >= 0.5
    if best_err >= 0.5
        % If error >= 0.5, we cannot improve; truncate
        used_estimators = t - 1;
        exitflag = -1;
        warning('ADABOOST:HighError', ...
            'Weak learner error %.4f >= 0.5 at iteration %d. Truncating.', best_err, t);
        break;
    end

    if best_err < 1e-12
        best_err = 1e-12;  % Avoid log(0)
    end

    % Compute alpha
    alpha_t = 0.5 * log((1 - best_err) / best_err);
    alphas(t) = alpha_t;

    % Store stump
    stumps(t).feature = best_feature;
    stumps(t).threshold = best_threshold;
    stumps(t).polarity = best_polarity;

    % Predict using current stump
    x_col = X(:, best_feature);
    h_t = best_polarity * (2 * (x_col > best_threshold) - 1);

    % Update weights: w_i *= exp(-alpha * y_i * h(x_i)) / Z
    w = w .* exp(-alpha_t * y .* h_t);
    Z = sum(w);
    w = w / Z;  % Normalize

    % Check for numerical issues
    if any(isnan(w)) || any(isinf(w))
        used_estimators = t;
        exitflag = -1;
        warning('ADABOOST:NumericalIssue', ...
            'Numerical instability at iteration %d. Truncating.', t);
        break;
    end
end

% Package model
model.alphas = alphas(1:used_estimators);
model.stumps = stumps(1:used_estimators);
model.n_estimators = used_estimators;
model.exitflag = exitflag;

%% Self-test
    function self_test()
        fprintf('Running adaboost_train self-test...\n');

        % Simple 2D 4-point linearly separable data
        rng(42, 'twister');
        X_test = [1, 1; 1, -1; -1, 1; -1, -1];
        y_test = [1; 1; -1; -1];

        opts_test.n_estimators = 10;
        opts_test.seed = 42;

        m = adaboost_train(X_test, y_test, opts_test);

        % Predict on training data
        y_pred = adaboost_predict_inner(m, X_test);

        % Assert 1: 100% training accuracy
        accuracy = mean(y_pred == y_test);
        assert(abs(accuracy - 1.0) < 1e-10, ...
            'AdaBoost self-test FAIL: accuracy %.3f not 100%%', accuracy);

        % Assert 2: all alphas positive
        assert(all(m.alphas > 0), ...
            'AdaBoost self-test FAIL: not all alphas positive');

        % Assert 3: at least one estimator trained
        assert(m.n_estimators >= 1, ...
            'AdaBoost self-test FAIL: no estimators trained');

        % Assert 4: exitflag indicates completion or acceptable truncation
        assert(ismember(m.exitflag, [1, -1]), ...
            'AdaBoost self-test FAIL: invalid exitflag');

        disp('adaboost_train self-test passed.');
    end

    function y_pred = adaboost_predict_inner(model, X_pred)
        N_pred = size(X_pred, 1);
        y_pred = zeros(N_pred, 1);
        for t_idx = 1:model.n_estimators
            feat = model.stumps(t_idx).feature;
            thr = model.stumps(t_idx).threshold;
            pol = model.stumps(t_idx).polarity;
            h_t = pol * (2 * (X_pred(:, feat) > thr) - 1);
            y_pred = y_pred + model.alphas(t_idx) * h_t;
        end
        y_pred = sign(y_pred);
    end

self_test();
end
