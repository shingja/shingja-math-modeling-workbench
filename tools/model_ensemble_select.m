% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_model, report] = model_ensemble_select(model_results, criterion)
%% MODEL_ENSEMBLE_SELECT Multi-model selection via AIC/BIC/CV/calibration. v3.0.0.
arguments
    model_results (1,:) struct
    criterion (1,:) char {mustBeMember(criterion, ...
        {'aic','bic','cv_rmse','calibration','weighted'})} = 'weighted'
end
n = numel(model_results);
assert(n >= 2, 'Need at least 2 candidate models');

% Extract metrics
names = {model_results.name};
scores = zeros(n, 1);
switch criterion
    case 'aic'
        metrics = [model_results.aic];
        [~, idx] = min(metrics);
        scores = -metrics; scores = scores - min(scores); scores = scores / max(max(scores),1);
    case 'bic'
        metrics = [model_results.bic];
        [~, idx] = min(metrics);
        scores = -metrics; scores = scores - min(scores); scores = scores / max(max(scores),1);
    case 'cv_rmse'
        metrics = [model_results.cv_rmse];
        [~, idx] = min(metrics);
        scores = 1 - (metrics - min(metrics)) / max(range(metrics), 1e-10);
    case 'calibration'
        metrics = [model_results.calibration_score];
        [~, idx] = max(metrics);
        scores = metrics;
    case 'weighted'
        % Weighted composite: 0.4*cal + 0.3*(1-cv_norm) + 0.3*(1-aic_norm)
        cal = [model_results.calibration_score];
        cal(isnan(cal)) = 0.5;
        rmses = [model_results.cv_rmse];
        if all(isnan(rmses)), cv_norm = zeros(1,n); else
            cv_norm = (rmses - min(rmses)) / max(range(rmses), 1e-10); end
        aics = [model_results.aic];
        if all(isnan(aics)), aic_norm = zeros(1,n); else
            aic_norm = (aics - min(aics)) / max(range(aics), 1e-10); end
        scores = 0.4*cal + 0.3*(1-cv_norm) + 0.3*(1-aic_norm);
        [~, idx] = max(scores);
end

best_model = names{idx};
report.names = names;
report.scores = num2cell(scores);
report.selected = best_model;
report.criterion = criterion;
report.ranking = names; % sorted by score descending
[~, sort_idx] = sort(scores, 'descend');
report.ranking = names(sort_idx);
end

%% Self-test
function self_test()
    mr(1) = struct('name', 'Model-A', 'aic', 120, 'bic', 135, 'cv_rmse', 0.05, 'calibration_score', 0.91);
    mr(2) = struct('name', 'Model-B', 'aic', 95, 'bic', 110, 'cv_rmse', 0.08, 'calibration_score', 0.78);
    mr(3) = struct('name', 'Model-C', 'aic', 150, 'bic', 165, 'cv_rmse', 0.12, 'calibration_score', 0.65);
    [best_aic, ~] = model_ensemble_select(mr, 'aic');
    assert(strcmp(best_aic, 'Model-B'), 'AIC should select Model-B (lowest)');
    [best_cal, ~] = model_ensemble_select(mr, 'calibration');
    assert(strcmp(best_cal, 'Model-A'), 'Calibration should select Model-A (highest)');
    [best_w, rep] = model_ensemble_select(mr, 'weighted');
    assert(numel(rep.ranking) == 3, 'Should have 3 candidates ranked');
    disp('model_ensemble_select self-test passed.');
end
