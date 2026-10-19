% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function varargout = decision_tree(mode, varargin)
%% DECISION_TREE  Binary decision tree for classification (CART-like).
%  Paradigm: PARADIGM-0604-DT. Category: Comprehensive. v3.0.0.
%  Reference: Breiman, L., Friedman, J., Olshen, R. & Stone, C. (1984)
%             Classification and Regression Trees. Wadsworth. ISBN: 978-0412048418.
%
%  Usage:
%    tree   = decision_tree('fit', X, y, 'max_depth', 10, 'min_samples', 2)
%    labels = decision_tree('predict', tree, Xnew)
%    imp    = decision_tree('importance', tree)
%
%  Algorithm: Binary recursive partitioning with Gini impurity.
%    Gini = 1 - sum(p_k^2). Best split maximizes Gini gain.
%    Stopping: max_depth, min_samples per leaf, pure node.
%
%  Options (for 'fit' mode, name-value pairs after y):
%    'max_depth'   - Maximum tree depth (default: 10)
%    'min_samples' - Minimum samples per leaf (default: 2)
%    'seed'        - RNG seed for tie-breaking (default: 42)
%    'verbose'     - Display progress (default: false)

arguments
    mode (1,1) string
end
arguments (Repeating)
    varargin
end

% ---- Parse common options from trailing name-value pairs ----
opts.max_depth   = 10;
opts.min_samples = 2;
opts.seed        = 42;
opts.verbose     = false;

if strcmp(mode, 'fit') && length(varargin) >= 2
    remain = varargin(3:end);
    i = 1;
    while i <= length(remain)
        if ischar(remain{i}) || isstring(remain{i})
            key = char(remain{i});
            if i + 1 <= length(remain)
                val = remain{i+1};
                switch lower(key)
                    case 'max_depth',   opts.max_depth   = val;
                    case 'min_samples', opts.min_samples = val;
                    case 'seed',        opts.seed        = val;
                    case 'verbose',     opts.verbose     = val;
                end
                i = i + 2;
            else
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end
end

rng(opts.seed, 'twister');
exitflag = 1;

% IO note: save(fullfile(output_dir, 'decision_tree_model.mat'), 'tree');

%% ---- Dispatch ----
switch lower(mode)
    case 'fit'
        assert(length(varargin) >= 2, ...
            'DECISION_TREE:fit requires X and y as first two arguments.');
        X = varargin{1};
        y = varargin{2};
        tree = dt_fit_impl(X, y, opts);
        varargout{1} = tree;
        if opts.verbose
            n_nodes = count_nodes(tree);
            fprintf('Decision tree trained: %d nodes, max_depth=%d\n', n_nodes, tree.depth);
        end

    case 'predict'
        assert(length(varargin) >= 2, ...
            'DECISION_TREE:predict requires tree and Xnew.');
        tree = varargin{1};
        Xnew = varargin{2};
        labels = dt_predict_impl(tree, Xnew);
        varargout{1} = labels;

    case 'importance'
        assert(length(varargin) >= 1, ...
            'DECISION_TREE:importance requires tree.');
        tree = varargin{1};
        imp = dt_gini_importance_impl(tree);
        varargout{1} = imp;

    otherwise
        error('DECISION_TREE: unknown mode ''%s''. Valid: fit, predict, importance.', mode);
end

%% ==================== Nested: fit implementation ====================
    function tree = dt_fit_impl(X, y, opt)
        [n_samples, n_features] = size(X);
        y = y(:);
        assert(length(y) == n_samples, ...
            'X (%d rows) and y (%d rows) must match.', n_samples, length(y));
        assert(n_samples >= opt.min_samples, ...
            'Need at least %d samples, got %d.', opt.min_samples, n_samples);

        classes = unique(y);
        n_classes = length(classes);
        assert(n_classes >= 2, ...
            'Classification requires at least 2 distinct classes, got %d.', n_classes);

        feat_indices = 1:n_features;

        root = build_node(X, y, feat_indices, classes, 0, opt);
        tree = struct();
        tree.root       = root;
        tree.n_classes  = n_classes;
        tree.classes    = classes;
        tree.n_features = n_features;
        tree.depth      = root.depth;
        % Propagate max depth
        tree.depth      = node_depth(root);
    end

%% ==================== Nested: recursive node builder ====================
    function node = build_node(X, y, feat_idx, classes, depth, opt)
        n_samples = size(X, 1);
        node = struct();
        node.is_leaf     = false;
        node.depth       = depth;
        node.n_samples   = n_samples;

        % Class distribution and Gini impurity
        counts = zeros(length(classes), 1);
        for c = 1:length(classes)
            counts(c) = sum(y == classes(c));
        end
        node.probs = counts / n_samples;
        [max_count, max_idx] = max(counts);
        node.pred_class = classes(max_idx);
        node.gini = 1 - sum(node.probs.^2);

        % Stopping criteria
        if depth >= opt.max_depth || n_samples < 2 * opt.min_samples || node.gini < 1e-10
            node.is_leaf      = true;
            node.left         = [];
            node.right        = [];
            node.split_feat   = 0;
            node.split_thresh = 0;
            node.gini_gain    = 0;
            return;
        end

        % Exhaustive search for best split
        [best_feat, best_thresh, best_gain, best_left, best_right] = ...
            find_best_split(X, y, feat_idx, node.gini, opt);

        % Validate split quality
        if best_gain < 1e-10 || length(best_left) < opt.min_samples ...
                             || length(best_right) < opt.min_samples
            node.is_leaf      = true;
            node.left         = [];
            node.right        = [];
            node.split_feat   = 0;
            node.split_thresh = 0;
            node.gini_gain    = 0;
            return;
        end

        % Build children recursively
        node.split_feat   = best_feat;
        node.split_thresh = best_thresh;
        node.gini_gain    = best_gain;
        node.left  = build_node(X(best_left, :), y(best_left),  ...
                                feat_idx, classes, depth + 1, opt);
        node.right = build_node(X(best_right, :), y(best_right), ...
                                feat_idx, classes, depth + 1, opt);
    end

%% ==================== Nested: best-split search ====================
    function [best_feat, best_thresh, best_gain, best_left, best_right] = ...
            find_best_split(X, y, feat_idx, parent_gini, opt)
        n_samples  = size(X, 1);
        best_gain  = 0;
        best_feat  = 0;
        best_thresh = 0;
        best_left  = [];
        best_right = [];
        n_feats = length(feat_idx);

        for fi = 1:n_feats
            f = feat_idx(fi);
            col_vals   = X(:, f);
            uniq_vals  = unique(col_vals);
            if length(uniq_vals) <= 1
                continue;
            end
            sorted_vals = sort(uniq_vals);

            for ti = 1:(length(sorted_vals) - 1)
                thresh   = (sorted_vals(ti) + sorted_vals(ti + 1)) / 2;
                left_idx = col_vals <= thresh;
                right_idx = ~left_idx;

                n_left  = sum(left_idx);
                n_right = n_samples - n_left;
                if n_left < opt.min_samples || n_right < opt.min_samples
                    continue;
                end

                % Gini for children
                [~, ~, gL] = compute_gini_counts(y(left_idx),  []);
                [~, ~, gR] = compute_gini_counts(y(right_idx), []);
                w_gini = (n_left / n_samples) * gL + (n_right / n_samples) * gR;
                gain   = parent_gini - w_gini;

                if gain > best_gain
                    best_gain   = gain;
                    best_feat   = f;
                    best_thresh = thresh;
                    best_left   = find(left_idx);
                    best_right  = find(right_idx);
                end
            end
        end
    end

%% ==================== Nested: Gini from labels ====================
    function [counts, probs, gini] = compute_gini_counts(y_sub, classes_in)
        if isempty(classes_in)
            classes_in = unique(y_sub);
        end
        n_c  = length(classes_in);
        counts = zeros(n_c, 1);
        for c = 1:n_c
            counts(c) = sum(y_sub == classes_in(c));
        end
        total = sum(counts);
        if total == 0
            probs = zeros(size(counts));
            gini  = 0;
        else
            probs = counts / total;
            gini  = 1 - sum(probs.^2);
        end
    end

%% ==================== Nested: predict ====================
    function labels = dt_predict_impl(tree, Xnew)
        n_samples = size(Xnew, 1);
        labels = zeros(n_samples, 1);
        for i = 1:n_samples
            labels(i) = predict_one(tree.root, Xnew(i, :));
        end
    end

    function pred = predict_one(node, x)
        if node.is_leaf
            pred = node.pred_class;
        else
            if x(node.split_feat) <= node.split_thresh
                pred = predict_one(node.left, x);
            else
                pred = predict_one(node.right, x);
            end
        end
    end

%% ==================== Nested: Gini importance ====================
    function imp = dt_gini_importance_impl(tree)
        n_features = tree.n_features;
        imp = zeros(n_features, 1);
        imp = accumulate_importance(tree.root, imp);
        total_imp = sum(imp);
        if total_imp > 0
            imp = imp / total_imp;  % normalize
        end
    end

    function imp = accumulate_importance(node, imp)
        if ~node.is_leaf && ~isempty(node.left)
            weighted_gain = node.n_samples * node.gini_gain;
            imp(node.split_feat) = imp(node.split_feat) + weighted_gain;
            imp = accumulate_importance(node.left,  imp);
            imp = accumulate_importance(node.right, imp);
        end
    end

%% ==================== Nested: utility ====================
    function n = count_nodes(node)
        if isempty(node)
            n = 0;
        elseif node.is_leaf
            n = 1;
        else
            n = 1 + count_nodes(node.left) + count_nodes(node.right);
        end
    end

    function d = node_depth(node)
        if isempty(node)
            d = 0;
        elseif node.is_leaf
            d = node.depth;
        else
            d = max(node_depth(node.left), node_depth(node.right));
        end
    end

%% Self-test
function self_test()
    rng(42);
    % XOR-like 4-point data (not linearly separable)
    % Class 1: (0,0), (1,1);  Class 2: (0,1), (1,0)
    X_test = [0, 0; 1, 1; 0, 1; 1, 0];
    y_test = [1; 1; 2; 2];

    tree = decision_tree('fit', X_test, y_test, ...
        'max_depth', 3, 'min_samples', 1, 'verbose', false);

    % Predict on training data
    preds = decision_tree('predict', tree, X_test);

    % Assert 1: 100% training accuracy on XOR-like data with max_depth=3
    acc = mean(preds == y_test);
    assert(acc == 1.0, ...
        'Self-test FAILED: training accuracy = %.2f, expected 1.0.', acc);

    % Assert 2: Feature importances are non-negative and normalized
    imp = decision_tree('importance', tree);
    assert(all(imp >= 0), ...
        'Self-test FAILED: negative feature importance detected.');
    if sum(imp) > 0
        assert(abs(sum(imp) - 1.0) < 1e-10, ...
            'Self-test FAILED: importance sum = %.6f, expected 1.0.', sum(imp));
    end

    % Assert 3: Tree depth >= 1 (must have at least one split for XOR data)
    assert(tree.depth >= 1, ...
        'Self-test FAILED: tree depth = %d, expected >= 1.', tree.depth);

    % Assert 4: Root node Gini > 0 (impure)
    assert(tree.root.gini > 0, ...
        'Self-test FAILED: root Gini = %.6f, should be > 0 for mixed data.', tree.root.gini);

    disp('DECISION_TREE self-test passed.');
end
end
