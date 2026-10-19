% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [export_paths, exitflag] = export_results(results, cfg)
% EXPORT_RESULTS Export results struct to CSV/MAT/JSON/TXT summary. v3.0.0.
%   JSON schema matches paper-handoff contract with 4 significant digits.
%   Output: export_paths(struct with paths), exitflag(0=OK).
arguments
    results struct
    cfg.output_path (1,:) char = fullfile(pwd, 'results')
    cfg.base_name (1,:) char = 'model_results'
    cfg.formats (1,:) cell = {'csv', 'mat', 'json', 'txt'}
    cfg.significant_digits (1,1) double = 4
    cfg.verbose (1,1) logical = true
end

rng(42, 'twister');
t0 = tic;
exitflag = 0;
export_paths = struct();

if ~isfolder(cfg.output_path)
    [ok, msg] = mkdir(cfg.output_path);
    if ~ok
        exitflag = -1;
        export_paths.error = sprintf('Cannot create output dir: %s', msg);
        return;
    end
end

try
    fmt_list = cfg.formats;
    if ischar(fmt_list), fmt_list = {fmt_list}; end

    %% 1. Prepare export-safe copy (round to significant digits)
    export_data = round_struct(results, cfg.significant_digits);

    %% 2. CSV export
    if any(strcmpi(fmt_list, 'csv'))
        if cfg.verbose
            fprintf('[%s] Exporting CSV...\n', datestr(now, 'HH:MM:SS'));
        end
        csv_path = fullfile(cfg.output_path, [cfg.base_name, '.csv']);
        try
            % Flatten struct fields into a table
            tbl = struct_to_table(export_data);
            writetable(tbl, csv_path);
            export_paths.csv = csv_path;
            if cfg.verbose
                fprintf('  -> %s (%d rows)\n', csv_path, height(tbl));
            end
        catch ME_csv
            export_paths.csv = '';
            if cfg.verbose
                fprintf('  CSV export failed: %s\n', ME_csv.message);
            end
        end
    end

    %% 3. MAT export
    if any(strcmpi(fmt_list, 'mat'))
        if cfg.verbose
            fprintf('[%s] Exporting MAT...\n', datestr(now, 'HH:MM:SS'));
        end
        mat_path = fullfile(cfg.output_path, [cfg.base_name, '.mat']);
        save(mat_path, 'results', '-v7');
        export_paths.mat = mat_path;
        if cfg.verbose
            fprintf('  -> %s\n', mat_path);
        end
    end

    %% 4. JSON export (paper-handoff contract)
    if any(strcmpi(fmt_list, 'json'))
        if cfg.verbose
            fprintf('[%s] Exporting JSON...\n', datestr(now, 'HH:MM:SS'));
        end
        json_path = fullfile(cfg.output_path, [cfg.base_name, '.json']);
        % Build handoff struct
        handoff = struct();
        handoff.schema_version = '3.0.0';
        handoff.export_time = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        handoff.significant_digits = cfg.significant_digits;
        handoff.data = export_data;
        json_str = jsonencode(handoff);
        fid = fopen(json_path, 'w');
        if fid > 0
            fprintf(fid, '%s', json_str);
            fclose(fid);
        end
        export_paths.json = json_path;
        % Validate JSON is parseable by re-reading
        fid2 = fopen(json_path, 'r');
        if fid2 > 0
            raw_json = fread(fid2, '*char')';
            fclose(fid2);
            try
                decoded = jsondecode(raw_json);
                assert(isstruct(decoded), 'JSON must decode to struct');
            catch ME_json
                exitflag = -3;
                if cfg.verbose
                    fprintf('  JSON validation failed: %s\n', ME_json.message);
                end
            end
        end
        if cfg.verbose
            fprintf('  -> %s\n', json_path);
        end
    end

    %% 5. TXT summary (4 significant digits)
    if any(strcmpi(fmt_list, 'txt'))
        if cfg.verbose
            fprintf('[%s] Exporting TXT summary...\n', ...
                datestr(now, 'HH:MM:SS'));
        end
        txt_path = fullfile(cfg.output_path, [cfg.base_name, '.txt']);
        fid = fopen(txt_path, 'w');
        if fid > 0
            fprintf(fid, '=== Model Results Summary ===\n');
            fprintf(fid, 'Export time: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
            fprintf(fid, 'Significant digits: %d\n\n', cfg.significant_digits);
            write_struct_fields(fid, results, '', cfg.significant_digits);
            fclose(fid);
        end
        export_paths.txt = txt_path;
        if cfg.verbose
            fprintf('  -> %s\n', txt_path);
        end
    end

    %% 6. Cross-validate: verify at least one format succeeded
    exported_formats = fieldnames(export_paths);
    valid_count = 0;
    for i = 1:length(exported_formats)
        if ~isempty(export_paths.(exported_formats{i}))
            valid_count = valid_count + 1;
        end
    end
    if valid_count == 0
        exitflag = -2;
        export_paths.error = 'No format exported successfully';
    end
    export_paths.valid_count = valid_count;

catch ME
    exitflag = -1;
    export_paths.error = ME.message;
end

export_paths.elapsed_sec = toc(t0);

if cfg.verbose && exitflag == 0
    fprintf('[export_results] Done. %d format(s) exported.\n', valid_count);
end

%% Self-test
function self_test()
    fprintf('=== export_results self-test ===\n');
    tmp_dir = fullfile(tempdir, 'export_test');
    if ~isfolder(tmp_dir), mkdir(tmp_dir); end
    r = struct('x_opt', [1.0001; 0.9999], 'fval', 3.2157e-08, ...
        'method', 'fmincon', 'iterations', 42, ...
        'ranking', [1; 2; 3], 'converged', true);
    cfg_st = struct('output_path', tmp_dir, 'base_name', 'test_export', ...
        'verbose', false);
    [paths, ef] = export_results(r, cfg_st);
    assert(ef == 0, 'Should succeed, got exitflag=%d', ef);
    % Verify CSV exists
    assert(isfile(paths.csv), 'CSV file should exist: %s', paths.csv);
    % Verify MAT exists
    assert(isfile(paths.mat), 'MAT file should exist: %s', paths.mat);
    % Verify JSON exists and is parseable
    assert(isfile(paths.json), 'JSON file should exist: %s', paths.json);
    fid_j = fopen(paths.json, 'r');
    decoded_j = jsondecode(fread(fid_j, '*char')');
    fclose(fid_j);
    assert(isstruct(decoded_j), 'JSON should decode to struct');
    assert(strcmp(decoded_j.schema_version, '3.0.0'), ...
        'JSON schema version should be 3.0.0');
    % Verify TXT exists
    assert(isfile(paths.txt), 'TXT file should exist: %s', paths.txt);
    assert(paths.valid_count >= 4, 'All 4 formats should export, got %d', ...
        paths.valid_count);
    % Cleanup
    if isfolder(tmp_dir), rmdir(tmp_dir, 's'); end
    disp('export_results self-test passed.');
end
end

function data = round_struct(s, digits)
    % Recursively round numeric fields to significant digits
    data = s;
    fns = fieldnames(data);
    for i = 1:length(fns)
        val = data.(fns{i});
        if isstruct(val)
            data.(fns{i}) = round_struct(val, digits);
        elseif isnumeric(val) && ~isempty(val)
            if isscalar(val)
                if abs(val) > 0
                    data.(fns{i}) = round(val, digits - ...
                        floor(log10(abs(val))) - 1, 'significant');
                else
                    data.(fns{i}) = 0;
                end
            end
        end
    end
end

function tbl = struct_to_table(s)
    % Flatten a scalar struct to a one-row table
    fns = fieldnames(s);
    vals = cell(1, length(fns));
    for i = 1:length(fns)
        v = s.(fns{i});
        if isstruct(v)
            vals{i} = '<struct>';
        elseif ischar(v) || isstring(v)
            vals{i} = char(v);
        elseif isnumeric(v) && isscalar(v)
            vals{i} = v;
        else
            vals{i} = '<complex>';
        end
    end
    tbl = cell2table(vals, 'VariableNames', fns);
end

function write_struct_fields(fid, s, prefix, digits)
    % Recursively write struct fields to TXT with 4 significant digits
    fns = fieldnames(s);
    for i = 1:length(fns)
        val = s.(fns{i});
        if isstruct(val)
            fprintf(fid, '%s%s:\n', prefix, fns{i});
            write_struct_fields(fid, val, [prefix, '  '], digits);
        elseif isnumeric(val) && isscalar(val) && ~isempty(val)
            fmt = sprintf('%%s%%s = %%.%dg\n', digits);
            fprintf(fid, fmt, prefix, fns{i}, val);
        elseif isnumeric(val) && isvector(val) && length(val) <= 10
            fmt = sprintf('%%s%%s = [%%.%dg', digits);
            for k = 1:length(val)
                fprintf(fid, fmt, prefix, fns{i}, val(k));
                fmt = sprintf(', %%.%dg', digits);
            end
            fprintf(fid, ']\n');
        elseif ischar(val) || isstring(val)
            fprintf(fid, '%s%s = %s\n', prefix, fns{i}, char(val));
        elseif islogical(val)
            if val, fprintf(fid, '%s%s = true\n', prefix, fns{i});
            else, fprintf(fid, '%s%s = false\n', prefix, fns{i}); end
        end
    end
end
