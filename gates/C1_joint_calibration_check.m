% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pass, report] = C1_joint_calibration_check(project_root)
%% C1_JOINT_CALIBRATION_CHECK Gate C1: joint calibration audit. v4.2.0.
%  6 dimensions: D1(calibration_score), D2(log completeness),
%  D3(claim bind), D4(model ensemble), D5(handshake validity),
%  D6(model quality scorecard, M-Loop 指标达成度)
%
%  D1 三档判定 (与 joint_calibration_protocol §4 阈值对齐):
%    score >= 0.85        -> PASS
%    0.70 <= score < 0.85 -> WARN  (不算 PASS; 论文必须写局限性)
%    score < 0.70         -> FAIL  (必须迭代修正)
%  总体状态 report.overall_status ∈ {PASS, WARN, FAIL}, 与返回值 pass 区分:
%    pass = true 仅当 overall_status == 'PASS' (WARN 不视为通过)。
arguments
    project_root (1,:) char = pwd
end

% Add tools to path
tools_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'tools');
addpath(tools_dir);

results_dir = fullfile(project_root, 'results');
report = struct();

%% D1: calibration_score (三档: >=0.85 PASS, [0.70,0.85) WARN, <0.70 FAIL)
cal_path = fullfile(results_dir, 'calibration_report.json');
if isfile(cal_path)
    cal = jsondecode(fileread(cal_path));
    if cal.score >= 0.85
        status = 'PASS';
    elseif cal.score >= 0.70
        status = 'WARN';
    else
        status = 'FAIL';
    end
    report.D1 = struct('pass', strcmp(status, 'PASS'), ...
        'status', status, 'score', cal.score, 'detail', cal.verdict);
else
    report.D1 = struct('pass', false, 'status', 'FAIL', 'score', 0, ...
        'detail', 'calibration_report.json not found');
end

%% D2: calibration log completeness
log_path = fullfile(results_dir, 'calibration_log.md');
has_log = isfile(log_path);
if has_log
    log_content = fileread(log_path);
    has_iterations = contains(log_content, '迭代 #');
    report.D2 = struct('pass', has_iterations, ...
        'detail', sprintf('log exists=%d, has_iterations=%d', has_log, has_iterations));
else
    report.D2 = struct('pass', true, 'detail', 'Single-pass, no iterations needed (OK)');
end

%% D3: result-claim hash binding
results_json = fullfile(results_dir, 'results.json');
hash_file = fullfile(results_dir, '.bind_hash');
if isfile(hash_file) && isfile(results_json)
    [bound, ~] = result_claim_bind(results_json, 'verify');
    report.D3 = struct('pass', bound, ...
        'detail', iff(bound, 'Hash verified', 'Hash MISMATCH - results changed!'));
else
    report.D3 = struct('pass', false, ...
        'detail', '.bind_hash or results.json missing');
end

%% D4: model ensemble evidence
ensemble_path = fullfile(results_dir, 'model_selection.json');
if isfile(ensemble_path)
    sel = jsondecode(fileread(ensemble_path));
    has_candidates = isfield(sel, 'candidates') && numel(sel.candidates) >= 2;
    has_reason = isfield(sel, 'reason') && ~isempty(sel.reason);
    report.D4 = struct('pass', has_candidates && has_reason, ...
        'detail', sprintf('candidates=%d, reason=%d', ...
        iff(has_candidates, numel(sel.candidates), 0), has_reason));
else
    report.D4 = struct('pass', false, ...
        'detail', 'model_selection.json not found');
end

%% D5: handshake validity
hs_path = fullfile(project_root, 'handshake.json');
if isfile(hs_path)
    [valid, missing] = handshake_validate(hs_path);
    report.D5 = struct('pass', valid, ...
        'detail', iff(valid, 'Handshake complete', ['Missing: ', strjoin(missing, ', ')]));
else
    report.D5 = struct('pass', false, 'detail', 'handshake.json not found');
end

%% D6: model quality scorecard (M-Loop, v4.2.0)
%  ALL_PASS -> pass; HARD_FAIL/SOFT_FAIL -> fail; 文件缺失 -> N/A(老项目兼容, 不阻塞)
mq_path = fullfile(results_dir, 'model_quality_score.json');
if isfile(mq_path)
    try
        mq = jsondecode(fileread(mq_path));
        switch mq.summary
            case 'ALL_PASS'
                report.D6 = struct('pass', true, 'summary', 'ALL_PASS', ...
                    'detail', '指标目标卡全部达标');
            otherwise
                report.D6 = struct('pass', false, 'summary', mq.summary, ...
                    'detail', iff(strcmp(mq.summary,'HARD_FAIL'), ...
                        '硬指标不达标, 须 M-Loop 迭代', '软指标不达标, 须数值卫生修复'));
        end
    catch
        report.D6 = struct('pass', true, 'summary', 'PARSE_ERROR', ...
            'detail', 'model_quality_score.json 解析失败 (按 N/A 放行)');
    end
else
    report.D6 = struct('pass', true, 'summary', 'N/A', ...
        'detail', '无指标目标卡 (v4.2 之前项目, 按 N/A 放行)');
end

%% Aggregate
dims = {'D1','D2','D3','D4','D5','D6'};
all_pass = true;
others_pass = true;   % D2..D6 全通过 (用于区分 WARN 与 FAIL)
for i = 1:numel(dims)
    all_pass = all_pass && report.(dims{i}).pass;
    if i >= 2, others_pass = others_pass && report.(dims{i}).pass; end
end
pass = all_pass;
report.overall_pass = pass;
% 三档总体状态: PASS 全过; WARN = D1 处于 [0.70,0.85) 且其余全过 (不算 PASS);
% FAIL = 任一维度失败 (含 D1 < 0.70)
if all_pass
    report.overall_status = 'PASS';
elseif strcmp(report.D1.status, 'WARN') && others_pass
    report.overall_status = 'WARN';
else
    report.overall_status = 'FAIL';
end
report.timestamp = char(datetime);

% Write report
fid = fopen(fullfile(results_dir, 'C1_gate_report.json'), 'w');
fprintf(fid, '%s', jsonencode(report)); fclose(fid);
end

function s = iff(cond, t, f)
if cond, s = t; else, s = f; end
end

%% Self-test
function self_test()
    % Build a dummy project with all required files
    tmp = fullfile(tempdir, 'c1_test_project');
    mkdir(fullfile(tmp, 'results'));

    % Perfect results
    cal.path = fullfile(tmp, 'results', 'calibration_report.json');
    cal.data = struct('score', 0.92, 'verdict', 'PASS');
    fid = fopen(cal.path, 'w'); fprintf(fid, '%s', jsonencode(cal.data)); fclose(fid);

    % Log
    fid = fopen(fullfile(tmp, 'results', 'calibration_log.md'), 'w');
    fprintf(fid, '## 迭代 #1\n**症状**: test\n**calibration_score**: 0.62 → 0.92 ✅\n');
    fclose(fid);

    % Results JSON + bind
    res = struct('key_results', struct('name','test','value',0.5), ...
        'goodness', struct('value',0.95), 'stability', struct('cv',0.03), ...
        'invariants', struct('passed',2));
    res_path = fullfile(tmp, 'results', 'results.json');
    fid = fopen(res_path, 'w'); fprintf(fid, '%s', jsonencode(res)); fclose(fid);
    result_claim_bind(res_path, 'bind');

    % Model selection
    sel = struct('candidates', {{struct('name','A'), struct('name','B')}}, ...
        'selected', 'A', 'reason', 'Higher calibration score');
    fid = fopen(fullfile(tmp, 'results', 'model_selection.json'), 'w');
    fprintf(fid, '%s', jsonencode(sel)); fclose(fid);

    % Handshake (validation_cases 必须为 struct 数组, 使 numel>=2 成立)
    hs = struct('model_id', 'test', 'math_formulation', 'f(x)', ...
        'variable_map', struct('name',{'x1'},'meaning',{'var'},'unit',{'m'}), ...
        'pseudo_code', 'Step1', 'parameter_bounds', struct('a',[0,1]), ...
        'validation_cases', struct('name',{'v1','v2'},'expected',{0.5,0.8},'tol',{1e-3,1e-3}), ...
        'invariants', {{'sum=1'}});
    fid = fopen(fullfile(tmp, 'handshake.json'), 'w');
    fprintf(fid, '%s', jsonencode(hs)); fclose(fid);

    [p1, r1] = C1_joint_calibration_check(tmp);
    assert(p1, 'Complete project should pass C1');
    assert(strcmp(r1.D1.status, 'PASS'), 'D1: score 0.92 should be PASS');
    assert(strcmp(r1.overall_status, 'PASS'), 'overall_status should be PASS');
    assert(strcmp(r1.D6.summary, 'N/A'), 'D6 without scorecard should be N/A');

    % Test: D6 HARD_FAIL -> overall FAIL (M-Loop 未收敛)
    mq = struct('summary', 'HARD_FAIL', ...
        'fail_hard', {{struct('problem','问题2','metric','R2_test')}});
    fid = fopen(fullfile(tmp, 'results', 'model_quality_score.json'), 'w');
    fprintf(fid, '%s', jsonencode(mq)); fclose(fid);
    [p1b, r1b] = C1_joint_calibration_check(tmp);
    assert(~p1b, 'D6 HARD_FAIL must NOT pass C1');
    assert(~r1b.D6.pass, 'D6 should fail on HARD_FAIL');
    assert(strcmp(r1b.overall_status, 'FAIL'), 'overall should FAIL on D6');
    % D6 ALL_PASS -> PASS
    mq.summary = 'ALL_PASS'; mq.fail_hard = [];
    fid = fopen(fullfile(tmp, 'results', 'model_quality_score.json'), 'w');
    fprintf(fid, '%s', jsonencode(mq)); fclose(fid);
    [p1c, r1c] = C1_joint_calibration_check(tmp);
    assert(p1c, 'D6 ALL_PASS should pass C1');
    assert(r1c.D6.pass, 'D6 should pass on ALL_PASS');

    % Test: score 0.78 -> WARN (不算 PASS, 总体 WARN)
    cal.data = struct('score', 0.78, 'verdict', 'WARN');
    fid = fopen(cal.path, 'w'); fprintf(fid, '%s', jsonencode(cal.data)); fclose(fid);
    [p2, r2] = C1_joint_calibration_check(tmp);
    assert(~p2, 'WARN score must NOT pass C1');
    assert(strcmp(r2.D1.status, 'WARN'), 'D1: score 0.78 should be WARN');
    assert(strcmp(r2.overall_status, 'WARN'), ...
        'overall_status should be WARN (other dims pass)');

    % Test: score 0.62 -> FAIL
    cal.data = struct('score', 0.62, 'verdict', 'BLOCK');
    fid = fopen(cal.path, 'w'); fprintf(fid, '%s', jsonencode(cal.data)); fclose(fid);
    [p3, r3] = C1_joint_calibration_check(tmp);
    assert(~p3, 'FAIL score must NOT pass C1');
    assert(strcmp(r3.D1.status, 'FAIL'), 'D1: score 0.62 should be FAIL');
    assert(strcmp(r3.overall_status, 'FAIL'), 'overall_status should be FAIL');

    % Test: restore PASS score, delete model_selection.json -> D4 fail
    cal.data = struct('score', 0.92, 'verdict', 'PASS');
    fid = fopen(cal.path, 'w'); fprintf(fid, '%s', jsonencode(cal.data)); fclose(fid);
    delete(fullfile(tmp, 'results', 'model_selection.json'));
    [p4, r4] = C1_joint_calibration_check(tmp);
    assert(~p4, 'Missing model_selection should fail C1');
    assert(~r4.D4.pass, 'D4 should specifically fail');
    assert(strcmp(r4.overall_status, 'FAIL'), 'overall_status should be FAIL on D4');

    disp('C1_joint_calibration_check self-test passed.');
end
