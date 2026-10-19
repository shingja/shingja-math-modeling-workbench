% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [bound, hash] = result_claim_bind(results_json_path, mode)
%% RESULT_CLAIM_BIND Bind results to paper claims via SHA-256 hash. v3.0.0.
%  mode='bind': compute hash, write .bind_hash
%  mode='verify': compare stored hash with current
arguments
    results_json_path (1,:) char
    mode (1,:) char {mustBeMember(mode, {'bind','verify'})} = 'bind'
end
[dir, ~] = fileparts(results_json_path);
hash_path = fullfile(dir, '.bind_hash');

% Read JSON
content = fileread(results_json_path);

% Compute SHA-256 (use Java MessageDigest)
md = java.security.MessageDigest.getInstance('SHA-256');
hash_bytes = md.digest(uint8(content));
hash = sprintf('%02x', hash_bytes);

if strcmp(mode, 'bind')
    fid = fopen(hash_path, 'w');
    fprintf(fid, '%s', hash);
    fclose(fid);
    bound = true;
else % verify
    if ~isfile(hash_path)
        warning('RESULT_CLAIM:NoBind', '.bind_hash not found. Run bind first.');
        bound = false;
        return;
    end
    stored_hash = strtrim(fileread(hash_path));
    bound = strcmp(hash, stored_hash);
    if ~bound
        warning('RESULT_CLAIM:Mismatch', ...
            'Results JSON has changed since last bind! Hash stored=%s, current=%s', ...
            stored_hash(1:16), hash(1:16));
    end
end
end

%% Self-test
function self_test()
    % Test bind→verify consistency
    tmp = fullfile(tempdir, 'test_claim.json');
    fid = fopen(tmp, 'w'); fprintf(fid, '{"score": 0.95, "method": "TOPSIS"}'); fclose(fid);
    [b1, h1] = result_claim_bind(tmp, 'bind');
    assert(b1, 'Bind should succeed');
    assert(~isempty(h1), 'Hash should not be empty');
    [b2, ~] = result_claim_bind(tmp, 'verify');
    assert(b2, 'Verify should pass immediately after bind');
    % Test tamper detection
    fid = fopen(tmp, 'w'); fprintf(fid, '{"score": 0.50, "method": "TOPSIS"}'); fclose(fid);
    [b3, ~] = result_claim_bind(tmp, 'verify');
    assert(~b3, 'Verify should FAIL after tampering');
    disp('result_claim_bind self-test passed.');
end
