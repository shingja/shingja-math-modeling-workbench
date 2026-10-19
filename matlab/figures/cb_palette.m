% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
%% cb_palette — Colorblind-safe publication color palette
% MATH-MODELING v3.0.0 S6 Phase 3
% Paradigm: visualization/infrastructure — accessible color schemes
%
% Returns a struct of colorblind-friendly hex colors suitable for
% publication figures. Palette inspired by Wong (2011) Nature Methods.
%
% Usage:
%   p = cb_palette();
%
% Output fields:
%   p.blue, p.red, p.green, p.orange, p.purple, p.gray  — individual colors
%   p.categorical — (1x8) cell of hex strings for categorical data
%   p.sequential  — (1x5) cell for sequential color scale
%   p.diverging   — (1x6) cell for diverging (bipolar) color scale

function p = cb_palette()
% Individual colors
p.blue   = '#0F4D92';
p.red    = '#B64342';
p.green  = '#3B7A57';
p.orange = '#D9782D';
p.purple = '#9A4D8E';
p.gray   = '#767676';

% Categorical palette: up to 8 distinct colors
p.categorical = {p.blue, p.red, p.green, p.orange, p.purple, p.gray, ...
                 '#42949E', '#FFD700'};

% Sequential palette: light to dark green (for intensity/quantity)
p.sequential = {'#DDF3DE', '#AADCA9', '#8BCF8B', '#5CB85C', '#3D8B3D'};

% Diverging palette: red to green, neutral center (for bipolar data)
p.diverging = {'#B64342', '#E9A6A1', '#F6CFCB', '#DDF3DE', '#AADCA9', '#3B7A57'};
end

%% Self-test
function self_test()
    p = cb_palette();
    assert(~isempty(p), 'cb_palette: output is empty');
    assert(isstruct(p), 'cb_palette: output is not a struct');
    assert(isfield(p, 'blue'), 'cb_palette: missing blue field');
    assert(isfield(p, 'categorical'), 'cb_palette: missing categorical');
    assert(numel(p.categorical) == 8, 'cb_palette: categorical wrong size');
    assert(numel(p.sequential) == 5, 'cb_palette: sequential wrong size');
    assert(numel(p.diverging) == 6, 'cb_palette: diverging wrong size');
    % Quick color display figure
    f = figure('Visible', 'off', 'Position', [100 100 600 200]);
    for i = 1:8
        patch([i-1 i i i-1], [0 0 1 1], p.categorical{i}, 'EdgeColor', 'none'); hold on;
    end
    hold off; xlim([0 8]); ylim([0 1]);
    title('cb\_palette categorical');
    apply_publication_style(gca);
    assert(~isempty(f), 'cb_palette: figure creation failed');
    close(f);
    disp('cb_palette: self-test PASSED');
end
