% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = reliability_fta(varargin)
%% RELIABILITYFTA  Fault Tree Analysis with MOCUS and importance measures.
%  Computes top event probability, minimal cut sets, and component
%  importance measures for coherent fault trees.
%  Paradigm: PARADIGM-0707
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Vesely, W.E., Goldberg, F.F., Roberts, N.H., Haasl, D.F. (1981)
%             Fault Tree Handbook. NUREG-0492. U.S. Nuclear Regulatory
%             Commission. Washington, DC.
%
%  Usage:
%      result = reliability_fta('analyze', tree_struct)
%      result = reliability_fta('top_prob', tree_struct, probs)
%      result = reliability_fta('min_cut_sets', tree_struct)
%      result = reliability_fta('importance', tree_struct, probs)
%      result = reliability_fta('build_tree', gate_list)
%
%  Tree structure:
%      Each node is a struct with fields:
%          .type     - 'AND' | 'OR' | 'BASIC' | 'VOTING' | 'NOT'
%          .name     - Node name (string)
%          .prob     - Failure probability (for BASIC events)
%          .children - Cell array of child nodes (for gates)
%          .k        - Required votes for VOTING gate (k-out-of-n)
%
%  Output struct fields (depending on mode):
%      .top_prob      - Top event probability
%      .cut_sets      - Minimal cut sets (cell array of name vectors)
%      .mcs_order     - Order of each minimal cut set
%      .birnbaum      - Birnbaum importance for each basic event
%      .fussell_vesely - Fussell-Vesely importance for each basic event
%      .risk_achievement_worth - RAW importance
%      .basic_events  - List of basic event names
%      .basic_probs   - Corresponding probabilities

arguments (Repeating)
    varargin
end

if isempty(varargin)
    error('RELIABILITYFTA requires a mode selector.');
end
mode = char(varargin{1});
args = varargin(2:end);

opts.display = false;
opts.seed = 42;  %#ok<NASGU>
new_args = {};
i = 1;
while i <= length(args)
    if (ischar(args{i}) || isstring(args{i})) && i + 1 <= length(args)
        key = char(args{i});
        switch lower(key)
            case 'display'; opts.display = args{i+1}; i = i + 2;
            otherwise; new_args{end+1} = args{i}; i = i + 1;
        end
    else
        new_args{end+1} = args{i}; i = i + 1;
    end
end
args = new_args;

rng(opts.seed, 'twister');

% Path note: save results via save(fullfile(output_dir, 'fta_results.mat'), '-struct', 'result');

switch lower(mode)
    case 'analyze'
        result = fta_analyze(args{:}, opts);
    case 'top_prob'
        result = fta_top_prob(args{:}, opts);
    case 'min_cut_sets'
        result = fta_min_cut_sets(args{:}, opts);
    case 'importance'
        result = fta_importance(args{:}, opts);
    case 'build_tree'
        result = fta_build_tree(args{:}, opts);
    otherwise
        error('Unknown mode: %s.', mode);
end
end

%% ==================== BUILD TREE ====================
function tree = fta_build_tree(gate_list, opts)
% Build a fault tree from a nested cell structure.
% gate_list = {type, name, children...} or 'BASIC'
    tree = build_recursive(gate_list);
end

function node = build_recursive(item)
    if ischar(item) || isstring(item)
        node = struct('type', 'BASIC', 'name', char(item), 'prob', NaN, 'children', {{}});
    elseif iscell(item)
        node.type = upper(item{1});
        node.name = item{2};
        node.prob = NaN;
        node.children = {};
        if strcmp(node.type, 'VOTING')
            node.k = item{3};
            node.children = item(4:end);
        else
            node.children = item(3:end);
        end
        for c = 1:length(node.children)
            node.children{c} = build_recursive(node.children{c});
        end
    elseif isstruct(item)
        node = item;
    end
end

%% ==================== TOP EVENT PROBABILITY ====================
function res = fta_top_prob(tree, probs, opts)
% Compute top event probability given basic event probabilities.
% probs can be a struct (name→prob) or cell arrays {names, values}.
    probs_map = parse_probs(probs);
    P_top = eval_node_prob(tree, probs_map);

    assert(P_top >= 0 && P_top <= 1, ...
        'FTA: Top event probability %.6f outside [0,1].', P_top);

    res.top_prob = P_top;

    if opts.display
        fprintf('FTA Top Event Probability: %.6e\n', P_top);
    end
end

function P = eval_node_prob(node, probs_map)
    switch node.type
        case 'BASIC'
            p = get_prob(node.name, probs_map);
            P = p;
        case 'AND'
            P = 1;
            for c = 1:length(node.children)
                P = P * eval_node_prob(node.children{c}, probs_map);
            end
        case 'OR'
            % P(OR) = 1 - prod(1 - P_i)
            P = 1;
            for c = 1:length(node.children)
                P = P * (1 - eval_node_prob(node.children{c}, probs_map));
            end
            P = 1 - P;
        case 'VOTING'
            k = node.k;
            n = length(node.children);
            child_probs = zeros(n, 1);
            for c = 1:n
                child_probs(c) = eval_node_prob(node.children{c}, probs_map);
            end
            % Sum over combinations: probability of at least k successes
            P = 0;
            for r = k:n
                combos = nchoosek(1:n, r);
                for row = 1:size(combos, 1)
                    term = 1;
                    for j = 1:n
                        if ismember(j, combos(row, :))
                            term = term * child_probs(j);
                        else
                            term = term * (1 - child_probs(j));
                        end
                    end
                    P = P + term;
                end
            end
        case 'NOT'
            P = 1 - eval_node_prob(node.children{1}, probs_map);
        otherwise
            error('Unknown gate type: %s', node.type);
    end
end

%% ==================== MINIMAL CUT SETS ====================
function res = fta_min_cut_sets(tree, opts)
% MOCUS algorithm: Method for Obtaining Cut Sets.
    raw_cut_sets = mocus(tree);
    % Remove supersets to get minimal cut sets
    mcs = minimize_cut_sets(raw_cut_sets);
    % Compute order of each MCS
    mcs_order = cellfun(@length, mcs);

    res.cut_sets = mcs;
    res.mcs_order = mcs_order;
    res.n_mcs = length(mcs);
    res.raw_cut_sets = raw_cut_sets;

    if opts.display
        fprintf('FTA Minimal Cut Sets: %d found\n', res.n_mcs);
        for j = 1:min(5, res.n_mcs)
            fprintf('  MCS %d (order %d): %s\n', j, mcs_order(j), ...
                strjoin(mcs{j}, ', '));
        end
    end
end

function cs = mocus(node)
% MOCUS algorithm: recursively generate cut sets
    switch node.type
        case 'BASIC'
            cs = {{node.name}};
        case 'OR'
            cs = {};
            for c = 1:length(node.children)
                child_cs = mocus(node.children{c});
                cs = [cs, child_cs];  %#ok<AGROW>
            end
        case 'AND'
            % Cartesian product: every combination of one CS from each child
            child_css = cell(length(node.children), 1);
            for c = 1:length(node.children)
                child_css{c} = mocus(node.children{c});
            end
            cs = cartesian_union(child_css);
        case 'VOTING'
            % k-out-of-n: union of all (n choose k) combinations of child CS
            k = node.k;
            n = length(node.children);
            child_css = cell(n, 1);
            for c = 1:n
                child_css{c} = mocus(node.children{c});
            end
            cs = {};
            combos = nchoosek(1:n, k);
            for row = 1:size(combos, 1)
                sub_css = child_css(combos(row, :));
                and_cs = cartesian_union(sub_css);
                cs = [cs, and_cs];  %#ok<AGROW>
            end
        case 'NOT'
            % NOT gates are expanded as complementary events during MOCUS
            child_cs = mocus(node.children{1});
            cs = cellfun(@(x) [x, {['NOT_', node.children{1}.name]}], child_cs, ...
                'UniformOutput', false);
        otherwise
            cs = {};
    end
end

function result = cartesian_union(all_sets)
% Cartesian product of multiple cell arrays of sets
    n_groups = length(all_sets);
    if n_groups == 1
        result = all_sets{1};
        return;
    end

    % Recursive Cartesian product
    indices = ones(n_groups, 1);
    sizes = cellfun(@length, all_sets);
    total = prod(sizes);
    result = cell(total, 1);

    for idx = 1:total
        combined = {};
        for g = 1:n_groups
            combined = [combined, all_sets{g}{indices(g)}];  %#ok<AGROW>
        end
        result{idx} = unique(combined);  % remove duplicates within a cut set

        % Increment indices
        for g = n_groups:-1:1
            if indices(g) < sizes(g)
                indices(g) = indices(g) + 1;
                break;
            else
                indices(g) = 1;
            end
        end
    end
end

function mcs = minimize_cut_sets(raw_cs)
% Remove supersets: keep only minimal cut sets
    n = length(raw_cs);
    is_minimal = true(n, 1);
    for i = 1:n
        if ~is_minimal(i), continue; end
        for j = 1:n
            if i == j || ~is_minimal(j), continue; end
            % Check if raw_cs{j} is a superset of raw_cs{i}
            if all(ismember(raw_cs{i}, raw_cs{j}))
                is_minimal(j) = false;
            end
        end
    end
    mcs = raw_cs(is_minimal);
end

%% ==================== IMPORTANCE MEASURES ====================
function res = fta_importance(tree, probs, opts)
% Compute Birnbaum, Fussell-Vesely, and Risk Achievement Worth measures.
    probs_map = parse_probs(probs);
    basic_names = collect_basic_names(tree);
    n_basic = length(basic_names);
    basic_probs = zeros(n_basic, 1);
    for j = 1:n_basic
        basic_probs(j) = get_prob(basic_names{j}, probs_map);
    end

    % Base top event probability
    P_top_base = eval_node_prob(tree, probs_map);
    assert(P_top_base >= 0 && P_top_base <= 1, ...
        'FTA: Base top probability outside [0,1].');

    birnbaum = zeros(n_basic, 1);
    fussell_vesely = zeros(n_basic, 1);
    raw_importance = zeros(n_basic, 1);

    % Probability of union of minimal cut sets containing basic i
    res_mcs = fta_min_cut_sets(tree, opts);
    mcs = res_mcs.cut_sets;

    for i = 1:n_basic
        bname = basic_names{i};

        % Birnbaum: dP_top / dp_i = P(top | i failed) - P(top | i working)
        probs_fail = probs_map;
        probs_fail(bname) = 1.0;
        P_fail = eval_node_prob(tree, probs_fail);

        probs_work = probs_map;
        probs_work(bname) = 0.0;
        P_work = eval_node_prob(tree, probs_work);

        birnbaum(i) = P_fail - P_work;

        % Fussell-Vesely: P(at least one MCS containing i) / P_top
        mcs_with_i = 0;
        for m = 1:length(mcs)
            if ismember(bname, mcs{m})
                mcs_with_i = mcs_with_i + 1;
            end
        end
        % Approximate: sum of MCS probabilities containing i / P_top
        % More accurate: union of MCS containing i
        P_mcs_i = 0;
        for m = 1:length(mcs)
            if ismember(bname, mcs{m})
                P_mcs = 1;
                for member = 1:length(mcs{m})
                    P_mcs = P_mcs * get_prob(mcs{m}{member}, probs_map);
                end
                P_mcs_i = P_mcs_i + P_mcs;
            end
        end
        fussell_vesely(i) = min(1, P_mcs_i / max(P_top_base, 1e-12));

        % Risk Achievement Worth: P_top(i=1) / P_top_base
        raw_importance(i) = P_fail / max(P_top_base, 1e-12);
    end

    res.birnbaum = birnbaum;
    res.fussell_vesely = fussell_vesely;
    res.risk_achievement_worth = raw_importance;
    res.basic_events = basic_names;
    res.basic_probs = basic_probs;
    res.top_prob = P_top_base;

    if opts.display
        fprintf('FTA Importance Measures:\n');
        for i = 1:n_basic
            fprintf('  %s: Birnbaum=%.4e, FV=%.4e, RAW=%.4e\n', ...
                basic_names{i}, birnbaum(i), fussell_vesely(i), raw_importance(i));
        end
    end
end

function res = fta_analyze(tree, probs, opts)
% Combined analysis: top_prob + min_cut_sets + importance
    res_top = fta_top_prob(tree, probs, opts);
    res_mcs = fta_min_cut_sets(tree, opts);
    res_imp = fta_importance(tree, probs, opts);
    res = res_imp;
    res.cut_sets = res_mcs.cut_sets;
    res.mcs_order = res_mcs.mcs_order;
    res.n_mcs = res_mcs.n_mcs;
    res.top_prob = res_top.top_prob;
end

%% Helper functions
function pmap = parse_probs(probs)
% Convert various probability specs to a containers.Map
    if isstruct(probs)
        fields = fieldnames(probs);
        pmap = containers.Map();
        for f = 1:length(fields)
            pmap(fields{f}) = probs.(fields{f});
        end
    elseif iscell(probs) && length(probs) == 2
        names = probs{1};
        vals = probs{2};
        pmap = containers.Map();
        for j = 1:length(names)
            pmap(names{j}) = vals(j);
        end
    else
        error('probs must be a struct or {names, values} cell array.');
    end
end

function p = get_prob(name, pmap)
    if isKey(pmap, name)
        p = pmap(name);
    else
        p = NaN;
    end
end

function names = collect_basic_names(node)
    names = {};
    if strcmp(node.type, 'BASIC')
        names = {node.name};
    elseif isfield(node, 'children')
        for c = 1:length(node.children)
            child_names = collect_basic_names(node.children{c});
            names = [names, child_names];  %#ok<AGROW>
        end
    end
    names = unique(names);
end

%% ==================== SELF-TEST ====================
function self_test()
    % Test 1: 2-component OR gate with p1=0.01, p2=0.02
    % P(top) = 1 - (1-0.01)*(1-0.02) = 1 - 0.99*0.98 = 1 - 0.9702 = 0.0298
    tree_or = struct('type', 'OR', 'name', 'TOP', 'prob', NaN, 'children', {{...
        struct('type', 'BASIC', 'name', 'C1', 'prob', 0.01, 'children', {{}}), ...
        struct('type', 'BASIC', 'name', 'C2', 'prob', 0.02, 'children', {{}})}});
    probs_or = struct('C1', 0.01, 'C2', 0.02);

    res_or = reliability_fta('top_prob', tree_or, probs_or);
    P_expected_or = 1 - (1-0.01)*(1-0.02);  % = 0.0298
    assert(abs(res_or.top_prob - P_expected_or) < 1e-6, ...
        'Self-test failed: OR gate P(top) = %.6f, expected %.6f.', ...
        res_or.top_prob, P_expected_or);
    assert(abs(P_expected_or - 0.0298) < 1e-6, ...
        'Self-test failed: expected exactly 0.0298.');

    % Test 2: AND gate with p1=0.1, p2=0.2 → P = 0.1*0.2 = 0.02
    tree_and = struct('type', 'AND', 'name', 'TOP', 'prob', NaN, 'children', {{...
        struct('type', 'BASIC', 'name', 'A1', 'prob', 0.1, 'children', {{}}), ...
        struct('type', 'BASIC', 'name', 'A2', 'prob', 0.2, 'children', {{}})}});
    probs_and = struct('A1', 0.1, 'A2', 0.2);

    res_and = reliability_fta('top_prob', tree_and, probs_and);
    P_expected_and = 0.1 * 0.2;
    assert(abs(res_and.top_prob - P_expected_and) < 1e-8, ...
        'Self-test failed: AND gate P(top) = %.6f, expected %.6f.', ...
        res_and.top_prob, P_expected_and);

    % Test 3: Minimal cut sets for OR gate
    res_mcs = reliability_fta('min_cut_sets', tree_or);
    assert(res_mcs.n_mcs == 2, ...
        'Self-test failed: OR gate should have 2 MCS, got %d.', res_mcs.n_mcs);

    % Test 4: Complex tree: TOP = OR(AND(C1,C2), C3)
    tree_comp = struct('type', 'OR', 'name', 'TOP', 'prob', NaN, 'children', {{...
        struct('type', 'AND', 'name', 'G1', 'prob', NaN, 'children', {{...
            struct('type', 'BASIC', 'name', 'C1', 'prob', 0.01, 'children', {{}}), ...
            struct('type', 'BASIC', 'name', 'C2', 'prob', 0.02, 'children', {{}})}}), ...
        struct('type', 'BASIC', 'name', 'C3', 'prob', 0.03, 'children', {{}})}});
    probs_comp = struct('C1', 0.01, 'C2', 0.02, 'C3', 0.03);

    res_comp = reliability_fta('top_prob', tree_comp, probs_comp);
    % P = 1 - (1 - 0.01*0.02) * (1 - 0.03) = 1 - 0.9998*0.97 = 1 - 0.969806 = 0.030194
    P_expected_comp = 1 - (1 - 0.01*0.02) * (1 - 0.03);
    assert(abs(res_comp.top_prob - P_expected_comp) < 1e-6, ...
        'Self-test failed: complex tree P(top) = %.6f, expected %.6f.', ...
        res_comp.top_prob, P_expected_comp);

    % Test 5: Importance measures
    res_imp = reliability_fta('importance', tree_or, probs_or, 'display', false);
    % Birnbaum for C1: P(top|C1=1) - P(top|C1=0) = (1-0.98) - (1-1*0.98) = 0.02 - 0.02?
    % Actually: P(top|C1=1) = 1 - (1-1)*(1-0.02) = 1 - 0 = 1? No: 1 - 0*0.98 = 1
    % P(top|C1=0) = 1 - (1-0)*(1-0.02) = 1 - 1*0.98 = 0.02
    % Birnbaum_C1 = 1 - 0.02 = 0.98
    assert(abs(res_imp.birnbaum(1) - 0.98) < 1e-5, ...
        'Self-test failed: Birnbaum for C1 = %.6f, expected 0.98.', res_imp.birnbaum(1));

    disp('RELIABILITYFTA self-test passed.');
end
