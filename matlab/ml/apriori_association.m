% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [freq_itemsets, supp, rules] = apriori_association(transactions, varargin)
%APRIORI_ASSOCIATION Apriori 关联规则挖掘 (Association Rule Mining)
%   [FREQ_ITEMSETS, SUPP, RULES] = APRIORI_ASSOCIATION(TRANSACTIONS)
%   从事务数据库中分层挖掘频繁项集, 并生成满足支持度/置信度/提升度
%   阈值的关联规则。核心为 Apriori 反单调性质: 若项集频繁则其所有
%   子集频繁, 据此在候选生成时剪枝, 避免指数级扫描。
%
%   Source: Agrawal, R., Imielinski, T., Swami, A. (1993).
%          Mining association rules between sets of items in large
%          databases. Proc. ACM SIGMOD, 207-216.
%          DOI: 10.1145/170035.170072
%          教材: 通用算法模块/modeling/apriori.py (AprioriMiner, 数模加油站)
%   Author: Adapted by MathModelingSkill (S6, 2026-08)
%   License: MIT
%   Verified: 2026-08-16, self-test 10 事务集频繁项集/规则逐条核对
%
%   输入:
%       transactions - 事务数据库, 两种形式之一:
%                      (a) cell 数组: 每个 cell 为项编号行向量, 如 {[1 2], [2 3 4]}
%                      (b) n×d logical 矩阵: 行=事务, 列=项 (one-hot)
%
%   可选参数 (名值对):
%       'MinSupport'    - 最小支持度 (默认: 0.1, 取值 (0, 1])
%       'MinConfidence' - 最小置信度 (默认: 0.5, 取值 (0, 1])
%       'MinLift'       - 最小提升度 (默认: 1.0, lift>1 为正相关)
%       'MaxLength'     - 频繁项集最大长度 (默认: Inf 不限制)
%
%   输出:
%       freq_itemsets - 1×L cell, 第 k 个 cell 为 k-项集元胞数组 (每项为 1×k 行向量)
%       supp          - 1×L cell, 与 freq_itemsets 同结构的支持度数值
%       rules         - struct 数组, 字段: antecedent, consequent,
%                       support, confidence, lift (按提升度降序)
%
%   示例:
%       T = {[1 2 3], [1 2 3 5], [1 2], [2 3 4], [2 3], [3 4], ...
%            [1 3], [2 4], [1 2 3 4], [1 3 4]};
%       [FI, SUPP, R] = apriori_association(T, 'MinSupport', 0.3, ...
%           'MinConfidence', 0.7, 'MinLift', 0.9);
%
%   注意:
%       - MATLAB 无原生关联规则工具箱, 本实现为自写 (见范式卡 PARADIGM-0622)。
%       - 项编号需全局一致 (同一商品/事件始终同一编号), 否则规则被割裂。
%       - 大数据量 (d>500 且支持度阈值很低) 请改用 FP-Growth (PARADIGM-0617)
%         或 Python mlxtend。

%% 无参调用入口 (matlab -batch 自测用)
if nargin == 0
    self_test();
    return;
end

%% 参数解析
p = inputParser;
p.addRequired('transactions', @(x) iscell(x) || islogical(x));
p.addParameter('MinSupport', 0.1, @(x) isscalar(x) && x > 0 && x <= 1);
p.addParameter('MinConfidence', 0.5, @(x) isscalar(x) && x > 0 && x <= 1);
p.addParameter('MinLift', 1.0, @(x) isscalar(x) && x >= 0);
p.addParameter('MaxLength', Inf, @(x) isscalar(x) && x >= 1);
p.parse(transactions, varargin{:});
opts = p.Results;

%% 规范化事务数据 -> logical 矩阵 B (n×d)
if islogical(transactions)
    B = transactions;
else
    all_items = cell2mat(transactions(:)');
    if isempty(all_items)
        error('apriori_association:EmptyData', '事务数据为空。');
    end
    n_tx = numel(transactions);
    d_tx = max(all_items);
    B = false(n_tx, d_tx);
    for i = 1:n_tx
        items = transactions{i};
        if ~isempty(items)
            B(i, items) = true;
        end
    end
end
[n, d] = size(B);
if n < 2
    error('apriori_association:TooFewTx', '事务数少于 2, 无法挖掘。');
end
min_count = opts.MinSupport * n;    % 支持度阈值换算为最小计数

%% 频繁 1-项集 (第一次全库扫描)
counts = sum(B, 1);
L1 = find(counts >= min_count);
if isempty(L1)
    freq_itemsets = {}; supp = {}; rules = struct([]);
    warning('apriori_association:NoFreqItems', ...
        '无任何频繁 1-项集, 请降低 MinSupport (当前 %.3f)。', opts.MinSupport);
    return;
end

FI = cell(1, 1);
FI{1} = num2cell(L1(:)');                      % 1×m cell, 每项为 1×1 行向量
SUPP = cell(1, 1);
SUPP{1} = counts(L1) / n;

%% 逐层挖掘: 候选生成 -> 剪枝 -> 计数
Lk = FI{1};
k = 2;
while ~isempty(Lk) && k <= opts.MaxLength
    % ---- 候选 (k)-项集生成: 前 k-2 项相同的频繁 (k-1)-项集两两拼接 ----
    Ck = {};
    m = numel(Lk);
    for i = 1:m-1
        for j = i+1:m
            a = Lk{i}; b = Lk{j};
            if isequal(a(1:end-1), b(1:end-1)) && a(end) < b(end)
                cand = [a, b(end)];
                % ---- Apriori 剪枝: 所有 (k-1)-子集必须频繁 ----
                subs = nchoosek(cand, k - 1);
                ok = true;
                for s = 1:size(subs, 1)
                    if ~any(cellfun(@(x) isequal(x, subs(s, :)), FI{k-1}))
                        ok = false;
                        break;
                    end
                end
                if ok
                    Ck{end+1} = cand; %#ok<AGROW>
                end
            end
        end
    end

    % ---- 计数: 仅扫描候选 (利用 logical 矩阵按列取交集) ----
    Lnext = {};
    Snext = [];
    for c = 1:numel(Ck)
        cnt = sum(all(B(:, Ck{c}), 2));
        if cnt >= min_count
            Lnext{end+1} = Ck{c}; %#ok<AGROW>
            Snext(end+1) = cnt / n; %#ok<AGROW>
        end
    end

    if isempty(Lnext)
        break;
    end
    FI{k} = Lnext;
    SUPP{k} = Snext;
    Lk = Lnext;
    k = k + 1;
end

freq_itemsets = FI;
supp = SUPP;

%% 关联规则生成 (长度 >= 2 的频繁项集 -> 前件/后件划分)
rules = struct('antecedent', {}, 'consequent', {}, ...
    'support', {}, 'confidence', {}, 'lift', {});
for kk = 2:numel(FI)
    for idx = 1:numel(FI{kk})
        itemset = FI{kk}{idx};
        sup_union = SUPP{kk}(idx);
        for len = 1:kk-1
            ants = nchoosek(itemset, len);
            for a = 1:size(ants, 1)
                ant = ants(a, :);
                cons = setdiff(itemset, ant);
                sup_ant = lookup_support(ant, FI, SUPP);
                sup_cons = lookup_support(cons, FI, SUPP);
                if sup_ant <= 0
                    continue;
                end
                conf = sup_union / sup_ant;
                if conf < opts.MinConfidence
                    continue;
                end
                lift = conf / sup_cons;   % = supp(X∪Y) / (supp(X)·supp(Y))
                if lift < opts.MinLift
                    continue;
                end
                rules(end+1) = struct('antecedent', ant, 'consequent', cons, ...
                    'support', sup_union, 'confidence', conf, 'lift', lift); %#ok<AGROW>
            end
        end
    end
end

% 按提升度降序排列 (最相关规则在前)
if ~isempty(rules)
    [~, ord] = sort([rules.lift], 'descend');
    rules = rules(ord);
end
end

%% 支持度查询 (由 Apriori 性质保证频繁项集的子集必频繁, 必能查到)
function s = lookup_support(itemset, FI, SUPP)
    kk = numel(itemset);
    if kk > numel(FI)
        s = 0;
        return;
    end
    L = FI{kk};
    for i = 1:numel(L)
        if isequal(L{i}, itemset)
            s = SUPP{kk}(i);
            return;
        end
    end
    s = 0;
end

%% Self-test
function self_test()
    % 经典 10 事务购物篮 (项 1..5), 人工核算:
    %   freq-1: {1},{2},{3},{4} (共 4 个, 项5 支持度 0.1 < 0.3 被剪)
    %   freq-2: {1,2},{1,3},{2,3},{2,4},{3,4} (共 5 个)
    %   freq-3: {1,2,3} (支持度 0.3; {2,3,4} 计数 2 被剪)
    T = {[1 2 3], [1 2 3 5], [1 2], [2 3 4], [2 3], [3 4], ...
         [1 3], [2 4], [1 2 3 4], [1 3 4]};
    [FI, SUPP, R] = apriori_association(T, 'MinSupport', 0.3, ...
        'MinConfidence', 0.7, 'MinLift', 0.9);

    assert(numel(FI) == 3, 'Test failed: expected 3 levels of frequent itemsets.');
    assert(numel(FI{1}) == 4, 'Test failed: expected 4 frequent 1-itemsets.');
    assert(numel(FI{2}) == 5, 'Test failed: expected 5 frequent 2-itemsets.');
    assert(numel(FI{3}) == 1, 'Test failed: expected 1 frequent 3-itemset.');
    assert(isequal(FI{3}{1}, [1 2 3]), 'Test failed: {1,2,3} should be frequent.');
    assert(abs(SUPP{3}(1) - 0.3) < 1e-12, 'Test failed: support of {1,2,3} = 0.3.');

    % 期望规则 (MinConfidence=0.7, MinLift=0.9): 共 3 条
    assert(numel(R) == 3, sprintf('Test failed: expected 3 rules, got %d.', numel(R)));
    found13 = false; found43 = false;
    for i = 1:numel(R)
        if isequal(R(i).antecedent, 1) && isequal(R(i).consequent, 3)
            found13 = true;
            assert(abs(R(i).confidence - 5/6) < 1e-12, ...
                'Test failed: conf({1}->{3}) should be 5/6.');
            assert(abs(R(i).lift - 25/24) < 1e-12, ...
                'Test failed: lift({1}->{3}) should be 25/24.');
        end
        if isequal(R(i).antecedent, 4) && isequal(R(i).consequent, 3)
            found43 = true;
            assert(abs(R(i).confidence - 0.8) < 1e-12, ...
                'Test failed: conf({4}->{3}) should be 0.8.');
            assert(abs(R(i).lift - 1.0) < 1e-12, ...
                'Test failed: lift({4}->{3}) should be 1.0.');
        end
    end
    assert(found13, 'Test failed: rule {1}->{3} missing.');
    assert(found43, 'Test failed: rule {4}->{3} missing.');

    % 等价的 logical 矩阵输入应得到相同的频繁 1-项集数
    B = false(10, 5);
    for i = 1:10
        B(i, T{i}) = true;
    end
    FI2 = apriori_association(B, 'MinSupport', 0.3);
    assert(numel(FI2{1}) == 4, 'Test failed: logical-matrix input mismatch.');
    disp('apriori_association self-test passed.');
end
