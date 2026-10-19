% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [valid, missing_fields, details] = handshake_validate(handshake_path)
%% HANDSHAKE_VALIDATE Check model handshake package completeness. v3.0.0.
arguments
    handshake_path (1,:) char
end
required_fields = {'model_id', 'math_formulation', 'variable_map', 'pseudo_code', ...
                   'parameter_bounds', 'validation_cases', 'invariants'};
% Load
if endsWith(handshake_path, '.json')
    hs = jsondecode(fileread(handshake_path));
elseif endsWith(handshake_path, '.mat')
    s = load(handshake_path, 'handshake'); hs = s.handshake; %#ok<NASGU>
    hs = s.handshake;
else
    valid = false; missing_fields = {'INVALID_FORMAT'}; details = struct(); return;
end

missing_fields = {};
for i = 1:numel(required_fields)
    if ~isfield(hs, required_fields{i})
        missing_fields{end+1} = required_fields{i}; %#ok<AGROW>
    end
end

% Extra checks
details.validation_cases_count = 0;
details.invariants_count = 0;
if isfield(hs, 'validation_cases') && ~isempty(hs.validation_cases)
    details.validation_cases_count = numel(hs.validation_cases);
end
if isfield(hs, 'invariants') && ~isempty(hs.invariants)
    details.invariants_count = numel(hs.invariants);
end
details.variable_map_rows = 0;
if isfield(hs, 'variable_map') && ~isempty(hs.variable_map)
    details.variable_map_rows = numel(hs.variable_map);
end

valid = isempty(missing_fields) && details.validation_cases_count >= 2 && ...
        details.invariants_count >= 1 && details.variable_map_rows >= 1;
end

%% Self-test
function self_test()
    % Test 1: complete package
    hs.model_id = 'Q1-TOPSIS';
    hs.math_formulation = 'min f(x)';
    hs.variable_map = struct('name',{'x1','x2'},'meaning',{'a','b'},'unit',{'m','s'});
    hs.pseudo_code = 'Step1: ...';
    hs.parameter_bounds = struct('alpha',[0.01,0.99]);
    hs.validation_cases = struct('name',{'v1','v2'},'expected',{0.5,0.8},'tol',{1e-3,1e-3});
    hs.invariants = {'sum(w)=1'};
    hs_path = fullfile(tempdir, 'hs_valid.json');
    fid = fopen(hs_path, 'w'); fprintf(fid, '%s', jsonencode(hs)); fclose(fid);
    [ok, miss] = handshake_validate(hs_path);
    assert(ok, 'Complete handshake should be valid');
    assert(isempty(miss), 'Should have no missing fields');
    % Test 2: incomplete
    hs2 = struct('model_id', 'test', 'math_formulation', 'f(x)');
    hs2_path = fullfile(tempdir, 'hs_invalid.json');
    fid = fopen(hs2_path, 'w'); fprintf(fid, '%s', jsonencode(hs2)); fclose(fid);
    [ok2, miss2] = handshake_validate(hs2_path);
    assert(~ok2, 'Incomplete handshake should be invalid');
    assert(numel(miss2) >= 5, 'Should list >=5 missing fields');
    disp('handshake_validate self-test passed.');
end
