% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function cfg = default_cfg()
% DEFAULT_CFG Default configuration for math-modeling templates. v3.0.0.
%   Returns a struct with standard paths, figure settings, and flags.
cfg = struct();
cfg.seed = 42;
cfg.data_path = fullfile(pwd, 'data');
cfg.output_path = fullfile(pwd, 'results');
cfg.figure_path = fullfile(pwd, 'figures');
cfg.verbose = true;
cfg.figure_format = {'svg', 'png'};
cfg.figure_dpi = 300;
cfg.colorblind_safe = true;
cfg.font_name = 'Times New Roman';
cfg.font_size = 10;
cfg.line_width = 1.5;

%% Self-test
function self_test()
    fprintf('=== default_cfg self-test ===\n');
    c = default_cfg();
    assert(isstruct(c), 'Output should be a struct');
    expected_fields = {'seed', 'data_path', 'output_path', 'figure_path', ...
        'verbose', 'figure_format', 'figure_dpi', 'colorblind_safe', ...
        'font_name', 'font_size', 'line_width'};
    for i = 1:length(expected_fields)
        assert(isfield(c, expected_fields{i}), ...
            'Missing field: %s', expected_fields{i});
    end
    assert(c.seed == 42, 'Default seed should be 42');
    assert(c.verbose == true, 'Default verbose should be true');
    assert(c.figure_dpi == 300, 'Default DPI should be 300');
    assert(c.figure_dpi >= 150, 'DPI should be at least 150 for publication');
    assert(c.colorblind_safe == true, 'Colorblind-safe should be on by default');
    disp('default_cfg self-test passed.');
end
end
