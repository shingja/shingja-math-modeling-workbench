% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [phi_plus, phi_minus, phi_net, ranking_I, ranking_II] = promethee(DM, weights, criteria_types, options)
%% PROMETHEE  PROMETHEE I / II outranking method
%  Paradigm: MCDM-005 | Category: ⑫ | Version: v3.0.0
%  Reference: Brans & Vincke (1985) "A preference ranking organisation method:
%             The PROMETHEE method for MCDM." Management Science 31(6):647-656.
%
%  Functions:
%    promethee_preference(diff, type, params) -> preference degree P(d)
%    promethee_flows(DM, weights, pref_funcs) -> [phi+, phi-, phi]
%
%  Preference functions: 'usual','u-shape','v-shape','level','linear','gaussian'

arguments
    DM (:, :) double                      % decision matrix [n_alt x n_crit]
    weights (:, 1) double                 % criterion weights
    criteria_types (:, 1) double          % 1=benefit (max), -1=cost (min)
    options.seed (1,1) double = 42
    options.pref_funcs cell = {}          % cell array of {type, params} per criterion
    options.default_q (1,1) double = 0.0  % default indifference threshold
    options.default_p (1,1) double = 1.0  % default preference threshold
    options.default_s (1,1) double = 0.5  % default Gaussian sigma
end

rng(options.seed, 'twister');

%% --- Validate ---
[n_alt, n_crit] = size(DM);
assert(n_alt >= 2, 'PROMETHEE:TooFewAlts', 'Need at least 2 alternatives.');
assert(length(weights) == n_crit, 'PROMETHEE:DimMismatch', ...
    'Weights length must equal number of criteria.');
assert(length(criteria_types) == n_crit, 'PROMETHEE:DimMismatch', ...
    'criteria_types length must equal number of criteria.');
weights = weights(:) / sum(weights);
assert(all(weights >= 0), 'PROMETHEE:BadWeights', 'Weights must be nonnegative.');

%% --- Setup preference functions ---
if isempty(options.pref_funcs)
    % Default: 'usual' for all criteria
    pref_funcs = cell(n_crit, 1);
    for j = 1:n_crit
        pref_funcs{j} = struct('type', 'usual', 'q', 0, 'p', 0, 's', 0);
    end
else
    pref_funcs = options.pref_funcs;
    assert(length(pref_funcs) == n_crit, 'PROMETHEE:PrefFuncMismatch', ...
        'pref_funcs must have n_crit entries.');
end

%% --- Compute preference degrees for all pairs ---
% Preference matrix P(i,j): how much i is preferred over j
P_mat = zeros(n_alt, n_alt);

for i = 1:n_alt
    for j = 1:n_alt
        if i == j, continue; end
        pref_sum = 0;
        for k = 1:n_crit
            diff_ij = DM(i, k) - DM(j, k);
            % Adjust direction for cost criteria
            if criteria_types(k) == -1
                diff_ij = -diff_ij;  % reverse: lower cost = better
            end
            % Apply preference function
            pf = pref_funcs{k};
            if ~isstruct(pf)
                pf = struct('type', 'usual', 'q', options.default_q, ...
                           'p', options.default_p, 's', options.default_s);
            end
            P_ijk = preference_degree(diff_ij, pf);
            pref_sum = pref_sum + weights(k) * P_ijk;
        end
        P_mat(i, j) = pref_sum;
    end
end

% Numerical sanity: preference degrees in [0, 1]
assert(all(P_mat(:) >= -1e-10 & P_mat(:) <= 1 + 1e-10), ...
    'PROMETHEE:BoundsViolation', 'Preference degrees must be in [0,1].');

%% --- Compute flows ---
% Positive outranking flow (how much i outranks others)
phi_plus  = sum(P_mat, 2) / (n_alt - 1);

% Negative outranking flow (how much others outrank i)
phi_minus = sum(P_mat, 1)' / (n_alt - 1);

% Net flow
phi_net = phi_plus - phi_minus;

% Numerical sanity
assert(all(phi_plus >= -1e-10 & phi_plus <= 1 + 1e-10), ...
    'PROMETHEE:PhiPlusRange', 'phi+ outside [0,1].');
assert(all(phi_minus >= -1e-10 & phi_minus <= 1 + 1e-10), ...
    'PROMETHEE:PhiMinusRange', 'phi- outside [0,1].');

%% --- PROMETHEE I: Partial ranking ---
% a P_I b if (phi+(a)>=phi+(b) AND phi-(a)<=phi-(b)) with at least one strict
% a I_I b if phi+(a)==phi+(b) AND phi-(a)==phi-(b)
% Use phi_plus descending, phi_minus ascending for ranking
[~, idx_p] = sort(phi_plus, 'descend');
[~, idx_m] = sort(phi_minus, 'ascend');
ranking_I = struct();
ranking_I.phi_plus_rank = idx_p;
ranking_I.phi_minus_rank = idx_m;

%% --- PROMETHEE II: Complete ranking ---
% Rank by net flow phi
[~, idx_net] = sort(phi_net, 'descend');
ranking_II = zeros(n_alt, 1);
for r = 1:n_alt
    ranking_II(idx_net(r)) = r;
end

% At least one alternative should have distinct phi_net
assert(length(unique(phi_net)) > 1 || n_alt <= 2, ...
    'PROMETHEE:AllTied', 'All alternatives have identical net flow.');

%% --- Nested: preference degree ---
function P = preference_degree(d, pf)
    % Compute P(d) based on preference function type
    q = pf.q; p_val = pf.p; s = pf.s;
    switch lower(pf.type)
        case 'usual'
            P = double(d > 0);
        case 'u-shape'
            P = double(d > q);
        case 'v-shape'
            if d <= 0
                P = 0;
            elseif d <= p_val
                P = d / p_val;
            else
                P = 1;
            end
        case 'level'
            if d <= q
                P = 0;
            elseif d <= p_val
                P = 0.5;
            else
                P = 1;
            end
        case 'linear'
            if d <= q
                P = 0;
            elseif d <= p_val
                P = (d - q) / (p_val - q);
            else
                P = 1;
            end
        case 'gaussian'
            if d <= 0
                P = 0;
            else
                P = 1 - exp(-d^2 / (2 * s^2));
            end
        otherwise
            P = double(d > 0);  % default: usual
    end
end

%% Self-test
function self_test()
    fprintf('  Running promethee self-test...\n');
    rng(42);
    % 4 alternatives, 2 criteria (both benefit/maximize)
    DM_test = [80, 90;    % A1
               65, 60;    % A2
               90, 50;    % A3
               70, 75];   % A4
    w_test = [0.6; 0.4];
    ctype  = [1; 1];

    [phi_p, phi_m, phi_n, rI, rII] = promethee(DM_test, w_test, ctype);

    % phi_plus and phi_minus should be in [0,1]
    assert(all(phi_p >= 0 & phi_p <= 1), 'Self-test: phi+ out of range.');
    assert(all(phi_m >= 0 & phi_m <= 1), 'Self-test: phi- out of range.');

    % Net flow phi = phi+ - phi- should be in [-1, 1]
    assert(all(abs(phi_n) <= 1 + 1e-10), 'Self-test: phi_net out of range.');

    % Ranking should differentiate alternatives
    assert(max(rII) == 4, 'Self-test: PROMETHEE II ranking incomplete.');

    % Most preferred alternative should have highest net flow
    assert(phi_n(rII == 1) == max(phi_n), 'Self-test: best rank != max phi_net.');

    fprintf('  promethee self-test PASSED (phi_net=[%.4f, %.4f, %.4f, %.4f]).\n', phi_n);
end
end
