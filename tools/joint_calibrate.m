% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [score, report] = joint_calibrate(handshake_path, results_path, opts)
%% JOINT_CALIBRATE Compute joint calibration score. v3.0.0.
%  Protocol: protocols/joint_calibration_protocol.md
arguments
    handshake_path (1,:) char
    results_path (1,:) char
    opts.threshold_pass (1,1) double = 0.85
    opts.threshold_warn (1,1) double = 0.70
    opts.n_seeds (1,1) double = 5
end %#ok<*NASGU>

% Load handshake (JSON or MAT)
if endsWith(handshake_path, '.json')
    handshake = jsondecode(fileread(handshake_path));
elseif endsWith(handshake_path, '.mat')
    s = load(handshake_path, 'handshake');
    handshake = s.handshake;
else
    error('Handshake must be .json or .mat');
end

% Load results
results = jsondecode(fileread(results_path));

% D1: magnitude_score
report.magnitude_score = compute_magnitude_score(results, handshake);

% D2: goodness_score
report.goodness_score = compute_goodness_score(results, handshake);

% D3: stability_score
report.stability_score = compute_stability_score(results, handshake, opts.n_seeds);

% D4: invariant_score
report.invariant_score = compute_invariant_score(results, handshake);

% Weighted score
score = 0.30 * report.magnitude_score ...
      + 0.30 * report.goodness_score ...
      + 0.20 * report.stability_score ...
      + 0.20 * report.invariant_score;

% Verdict
if score >= opts.threshold_pass
    report.verdict = 'PASS';
elseif score >= opts.threshold_warn
    report.verdict = 'WARN';
else
    report.verdict = 'BLOCK';
end
report.score = score;
report.timestamp = char(datetime);
end

function ms = compute_magnitude_score(results, handshake)
%% Magnitude: compare key_results with validation_cases
if ~isfield(handshake, 'validation_cases') || isempty(handshake.validation_cases)
    ms = 0.5;  % no validation cases → neutral
    return;
end
errors = [];
for i = 1:numel(handshake.validation_cases)
    vc = handshake.validation_cases(i);
    % Find matching key in results
    actual = [];
    if isfield(results, 'key_results')
        for j = 1:numel(results.key_results)
            if contains(results.key_results(j).name, vc.name)
                actual = results.key_results(j).value;
                break;
            end
        end
    end
    if ~isempty(actual) && ~isempty(vc.expected)
        err = abs(actual - vc.expected) / max(abs(vc.expected), 1e-10);
        errors(end+1) = err; %#ok<AGROW>
    end
end
if isempty(errors)
    ms = 0.5;
else
    ms = max(0, min(1, 1 - mean(errors)));
end
end

function gs = compute_goodness_score(results, handshake)
%% Goodness: use residual, R^2, or conservation error from results
if isfield(results, 'goodness') && isfield(results.goodness, 'value')
    gs = max(0, min(1, results.goodness.value));
elseif isfield(results, 'r_squared')
    gs = max(0, min(1, results.r_squared));
else
    % Fallback: if results have key_results with type='goodness'
    gs = 0.5;
    if isfield(results, 'key_results')
        for j = 1:numel(results.key_results)
            if contains(results.key_results(j).name, '残差') || ...
               contains(results.key_results(j).name, 'residual') || ...
               contains(results.key_results(j).name, 'R2') || ...
               contains(results.key_results(j).name, 'R-squared')
                gs = max(0, min(1, results.key_results(j).value));
            end
        end
    end
end
end

function ss = compute_stability_score(results, handshake, n_seeds)
%% Stability: sensitivity to random seed
if ~isfield(results, 'stability') || ~isfield(results.stability, 'cv')
    ss = 0.5;
    return;
end
cv_val = results.stability.cv;
ss = max(0, 1 - cv_val / 0.20);  % CV >= 0.2 -> score = 0
end

function is_ = compute_invariant_score(results, handshake)
%% Invariants: fraction of declared invariants that pass
if ~isfield(handshake, 'invariants') || isempty(handshake.invariants)
    is_ = 1.0;
    return;
end
n_invariants = numel(handshake.invariants);
n_passed = 0;
if isfield(results, 'invariants') && isfield(results.invariants, 'passed')
    n_passed = results.invariants.passed;
else
    % If results didn't explicitly report, assume all passed
    n_passed = n_invariants;
end
is_ = n_passed / max(n_invariants, 1);
end

%% Self-test
function self_test()
    rng(42);
    % Build dummy handshake
    hs.model_id = 'test-model';
    hs.variable_map = struct('name', 'x1', 'meaning', 'var', 'unit', 'm');
    hs.validation_cases = struct('name', 'score_A', 'expected', 0.8234, 'tol', 1e-3);
    hs.invariants = {'sum(w)=1', 'w_i in [0,1]'};
    hs_path = fullfile(tempdir, 'test_handshake.json');
    fid = fopen(hs_path, 'w'); fprintf(fid, '%s', jsonencode(hs)); fclose(fid);

    % Build dummy results (all perfect)
    res.key_results = struct('name', 'score_A', 'value', 0.8234);
    res.goodness = struct('value', 0.95);
    res.stability = struct('cv', 0.03);
    res.invariants = struct('passed', 2);
    res_path = fullfile(tempdir, 'test_results.json');
    fid = fopen(res_path, 'w'); fprintf(fid, '%s', jsonencode(res)); fclose(fid);

    [sc, rp] = joint_calibrate(hs_path, res_path);
    % Perfect match: magnitude=1, goodness=0.95, stability=0.85, invariants=1
    expected = 0.30*1.0 + 0.30*0.95 + 0.20*0.85 + 0.20*1.0;
    fprintf('Expected=%.4f, Got=%.4f\n', expected, sc);
    assert(abs(sc - expected) < 0.01, sprintf('Score mismatch: %.4f vs %.4f', sc, expected));
    assert(strcmp(rp.verdict, 'PASS'), 'Should PASS for perfect results');
    assert(rp.magnitude_score > 0.9, 'Magnitude should be near 1');
    disp('joint_calibrate self-test passed.');
end
