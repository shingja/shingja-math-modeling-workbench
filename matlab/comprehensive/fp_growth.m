% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [result] = fp_growth(transactions, options)
%% FP_GROWTH FP-Growth frequent pattern mining. Paradigm: PARADIGM-0617-FP-GROWTH. v3.0.0.
%   Build FP-tree from transactions, mine frequent itemsets via conditional pattern bases.
%
%   Inputs:
%       transactions - cell array where each cell contains a numeric vector of items
%       options.min_support - minimum support count (default: 2)
%       options.max_itemset_size - max itemset size (default: Inf)
%
%   Outputs:
%       result.frequent_itemsets - cell array of [itemset, support] pairs
%       result.fp_tree           - struct representing the FP-tree
%       result.exitflag          - 1 if completed successfully

arguments
    transactions (:, 1) cell
    options.min_support (1,1) double {mustBePositive, mustBeInteger} = 2
    options.max_itemset_size (1,1) double = Inf
end

% Flatten all items and compute support counts
all_items = [];
for i = 1:length(transactions)
    all_items = [all_items, transactions{i}(:)'];  %#ok<AGROW>
end
unique_items = unique(all_items);
item_counts = zeros(size(unique_items));

for i = 1:length(unique_items)
    item = unique_items(i);
    for j = 1:length(transactions)
        if ismember(item, transactions{j})
            item_counts(i) = item_counts(i) + 1;
        end
    end
end

% Filter frequent items (1-itemsets)
freq_mask = item_counts >= options.min_support;
freq_items = unique_items(freq_mask);
freq_counts = item_counts(freq_mask);

if isempty(freq_items)
    warning('FPGROWTH:NoFrequent', 'No frequent items found with min_support=%d.', ...
        options.min_support);
    result.frequent_itemsets = {};
    result.fp_tree = struct();
    result.exitflag = -1;
    return;
end

% Sort frequent items by descending support
[freq_counts, sort_idx] = sort(freq_counts, 'descend');
freq_items = freq_items(sort_idx);

% Build header table
header_table = struct('item', num2cell(freq_items), ...
                     'count', num2cell(freq_counts), ...
                     'node_links', cell(size(freq_items)));

% Build FP-tree
fp_root = struct('item', 0, 'count', 0, 'parent', [], 'children', [], 'node_link', []);

for t_idx = 1:length(transactions)
    trans = transactions{t_idx};

    % Filter and sort items in this transaction by frequency
    trans_freq = [];
    for i_item = 1:length(trans)
        item = trans(i_item);
        freq_idx = find(freq_items == item, 1);
        if ~isempty(freq_idx)
            trans_freq = [trans_freq; item, freq_counts(freq_idx)];  %#ok<AGROW>
        end
    end

    if isempty(trans_freq)
        continue;
    end

    % Sort by descending frequency
    [~, sort_order] = sort(trans_freq(:, 2), 'descend');
    trans_freq = trans_freq(sort_order, 1);

    % Insert into FP-tree
    current_node = fp_root;
    for i_item = 1:length(trans_freq)
        item = trans_freq(i_item);

        % Check if child exists
        child_found = false;
        if ~isempty(current_node.children)
            for c = 1:length(current_node.children)
                if current_node.children(c).item == item
                    current_node.children(c).count = current_node.children(c).count + 1;
                    current_node = current_node.children(c);
                    child_found = true;
                    break;
                end
            end
        end

        if ~child_found
            % Create new node
            new_node = struct('item', item, 'count', 1, ...
                             'parent', current_node, 'children', [], 'node_link', []);

            if isempty(current_node.children)
                current_node.children = new_node;
            else
                current_node.children(end + 1) = new_node;
            end

            % Update header table node links
            for h = 1:length(header_table)
                if header_table(h).item == item
                    if isempty(header_table(h).node_links)
                        header_table(h).node_links = new_node;
                    else
                        % Append to linked list
                        last_link = header_table(h).node_links;
                        while ~isempty(last_link.node_link)
                            last_link = last_link.node_link;
                        end
                        last_link.node_link = new_node;
                    end
                    break;
                end
            end

            current_node = new_node;
        end
    end
end

% Mine frequent itemsets via FP-Growth recursion
frequent_itemsets = {};

    function mine_tree(tree_root, prefix, header_tbl)
        % Process items from bottom (least frequent) to top
        for h_idx = length(header_tbl):-1:1
            item_h = header_tbl(h_idx).item;
            count_h = header_tbl(h_idx).count;

            % Generate new frequent itemset: prefix + item
            new_itemset = [prefix, item_h];
            new_itemset = sort(new_itemset);

            % Check max_itemset_size
            if length(new_itemset) > options.max_itemset_size
                continue;
            end

            % Add to result
            frequent_itemsets{end + 1, 1} = new_itemset;  %#ok<AGROW>
            frequent_itemsets{end, 2} = count_h;

            % Build conditional pattern base
            cond_transactions = {};
            node_ptr = header_tbl(h_idx).node_links;
            while ~isempty(node_ptr)
                % Trace path to root to get conditional pattern
                cond_pattern = [];
                parent_ptr = node_ptr.parent;
                while ~isempty(parent_ptr) && parent_ptr.item ~= 0
                    cond_pattern = [cond_pattern, parent_ptr.item];  %#ok<AGROW>
                    parent_ptr = parent_ptr.parent;
                end
                if ~isempty(cond_pattern)
                    % Add pattern (count_h times for each occurrence in node_ptr)
                    for rep = 1:node_ptr.count
                        cond_transactions{end + 1, 1} = cond_pattern;  %#ok<AGROW>
                    end
                end
                node_ptr = node_ptr.node_link;
            end

            % Build conditional FP-tree if we have transactions
            if ~isempty(cond_transactions)
                [cond_freq_itemsets] = fp_growth(cond_transactions, ...
                    struct('min_support', options.min_support, ...
                           'max_itemset_size', options.max_itemset_size));
                if isfield(cond_freq_itemsets, 'frequent_itemsets')
                    cond_result = cond_freq_itemsets.frequent_itemsets;
                    for ci = 1:size(cond_result, 1)
                        combined_itemset = sort([prefix, item_h, cond_result{ci, 1}]);
                        if length(combined_itemset) <= options.max_itemset_size
                            frequent_itemsets{end + 1, 1} = combined_itemset;  %#ok<AGROW>
                            frequent_itemsets{end, 2} = cond_result{ci, 2};
                        end
                    end
                end
            end
        end
    end

% Also add 1-itemsets
for i = 1:length(freq_items)
    frequent_itemsets{end + 1, 1} = freq_items(i);  %#ok<AGROW>
    frequent_itemsets{end, 2} = freq_counts(i);
end

% Run FP-Growth mining
mine_tree(fp_root, [], header_table);

% Remove duplicate itemsets (keep highest support)
[unique_itemsets, ~, ic] = unique(cellfun(@(x) num2str(x), frequent_itemsets(:, 1), ...
    'UniformOutput', false));
final_itemsets = cell(length(unique_itemsets), 2);
for ui = 1:length(unique_itemsets)
    mask_ui = (ic == ui);
    supports = cell2mat(frequent_itemsets(mask_ui, 2));
    [max_sup, max_idx] = max(supports);
    idx_in_group = find(mask_ui);
    final_itemsets{ui, 1} = frequent_itemsets{idx_in_group(max_idx), 1};
    final_itemsets{ui, 2} = max_sup;
end

% Package result
result.frequent_itemsets = final_itemsets;
result.fp_tree = fp_root;
result.header_table = header_table;
result.exitflag = 1;

%% Self-test
    function self_test()
        fprintf('Running fp_growth self-test...\n');

        % Market basket dataset: 5 transactions
        transactions_test = {
            [1, 2, 5];     % milk, bread, eggs
            [2, 4];         % bread, butter
            [2, 3];         % bread, cheese
            [1, 2, 4];     % milk, bread, butter
            [1, 3];         % milk, cheese
        };

        opts_test.min_support = 2;

        r = fp_growth(transactions_test, opts_test);

        % Extract itemsets as strings for checking
        itemset_strings = cell(size(r.frequent_itemsets, 1), 1);
        for is_idx = 1:size(r.frequent_itemsets, 1)
            its = r.frequent_itemsets{is_idx, 1};
            if length(its) > 1
                itemset_strings{is_idx} = num2str(sort(its(:)'));
            else
                itemset_strings{is_idx} = num2str(its);
            end
        end

        % Assert 1: {1, 2} (milk, bread) is frequent (appears in transactions 1 and 4, support=2)
        assert(ismember(num2str([1, 2]), itemset_strings), ...
            'FP-Growth self-test FAIL: {milk, bread} not found as frequent itemset');

        % Assert 2: {2} (bread) is frequent (appears in all 4 transactions: 1,2,3,4)
        assert(ismember('2', itemset_strings), ...
            'FP-Growth self-test FAIL: {bread} not found as frequent itemset');

        % Assert 3: {2, 4} (bread, butter) is frequent (support=2)
        assert(ismember(num2str([2, 4]), itemset_strings), ...
            'FP-Growth self-test FAIL: {bread, butter} not found as frequent itemset');

        % Assert 4: exitflag is 1
        assert(r.exitflag == 1, ...
            'FP-Growth self-test FAIL: exitflag ~= 1');

        % Assert 5: at least 5 frequent itemsets found
        assert(size(r.frequent_itemsets, 1) >= 5, ...
            'FP-Growth self-test FAIL: fewer than 5 frequent itemsets found (got %d)', ...
            size(r.frequent_itemsets, 1));

        disp('fp_growth self-test passed.');
    end

self_test();
end
