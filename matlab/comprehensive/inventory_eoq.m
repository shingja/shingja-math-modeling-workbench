% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function result = inventory_eoq(varargin)
%% INVENTORYEOQ  Economic Order Quantity model and inventory management.
%  Multi-function inventory toolkit: EOQ basic, EOQ with backorders,
%  newsvendor model, and (s,S) policy simulation.
%  Paradigm: PARADIGM-0702
%  Category: Comprehensive
%  Version: v3.0.0
%  Reference: Silver, E.A., Pyke, D.F. & Thomas, D.J. (1998)
%             Inventory and Production Management in Supply Chains,
%             3rd ed. Wiley. ISBN: 978-0471196473.
%
%  Usage:
%      result = inventory_eoq('eoq_basic', D, K, h)
%      result = inventory_eoq('eoq_backorder', D, K, h, b)
%      result = inventory_eoq('newsvendor', cu, co, demand_mean, demand_std)
%      result = inventory_eoq('newsvendor_empirical', cu, co, demand_samples)
%      result = inventory_eoq('ss_simulate', demand_seq, s, S, init_stock)
%
%  Common options:
%      options.seed - RNG seed for simulation modes (default: 42)
%
%  See nested functions for detailed documentation of each mode.
%
%  Output (struct with fields depending on mode):
%      eoq_basic:       .Q_opt, .cycle_time, .total_cost, .order_freq
%      eoq_backorder:   .Q_opt, .S_opt, .max_backorder, .total_cost
%      newsvendor:      .Q_opt, .expected_cost, .critical_ratio
%      ss_simulate:     .stock_history, .order_history, .total_cost,
%                       .service_level, .avg_inventory

arguments (Repeating)
    varargin
end

%% Dispatch based on first argument (mode selector)
if isempty(varargin)
    error('INVENTORYEOQ requires a mode selector as the first argument.');
end

mode = varargin{1};
if ~ischar(mode) && ~isstring(mode)
    error('First argument must be a mode selector string.');
end
mode = char(mode);

% Parse common options from last arguments
opts.seed = 42;
opts.display = false;
% Extract trailing name-value pairs
args = varargin(2:end);
i = 1;
while i <= length(args)
    if ischar(args{i}) || isstring(args{i})
        key = char(args{i});
        if i + 1 <= length(args)
            val = args{i+1};
            switch lower(key)
                case 'seed'
                    opts.seed = val;
                case 'display'
                    opts.display = val;
            end
            i = i + 2;
        else
            i = i + 1;
        end
    else
        i = i + 1;
    end
end

% Path note: save results via save(fullfile(output_dir, 'eoq_results.mat'), '-struct', 'result');

%% Dispatch to appropriate function
switch lower(mode)
    case 'eoq_basic'
        if length(args) < 3
            error('eoq_basic requires: D, K, h');
        end
        result = eoq_basic(args{1}, args{2}, args{3}, opts);

    case 'eoq_backorder'
        if length(args) < 4
            error('eoq_backorder requires: D, K, h, b');
        end
        result = eoq_backorder(args{1}, args{2}, args{3}, args{4}, opts);

    case 'newsvendor'
        if length(args) < 4
            error('newsvendor requires: cu, co, demand_mean, demand_std');
        end
        result = newsvendor_normal(args{1}, args{2}, args{3}, args{4}, opts);

    case 'newsvendor_empirical'
        if length(args) < 3
            error('newsvendor_empirical requires: cu, co, demand_samples');
        end
        result = newsvendor_empirical(args{1}, args{2}, args{3}, opts);

    case 'ss_simulate'
        if length(args) < 4
            error('ss_simulate requires: demand_seq, s, S, init_stock');
        end
        result = ss_simulate(args{1}, args{2}, args{3}, args{4}, opts);

    otherwise
        error('Unknown mode: %s. Valid modes: eoq_basic, eoq_backorder, newsvendor, newsvendor_empirical, ss_simulate.', mode);
end
end

%% ==================== EOQ BASIC ====================
function res = eoq_basic(D, K, h, opts)
% EOQ_BASIC  Classic Economic Order Quantity.
%   D = annual demand rate, K = fixed ordering cost, h = holding cost/unit/year
%   Q* = sqrt(2*D*K/h)
    assert(D > 0 && K > 0 && h > 0, 'D, K, h must all be positive.');

    rng(opts.seed, 'twister');

    Q_opt = sqrt(2 * D * K / h);
    cycle_time = Q_opt / D;
    total_cost = sqrt(2 * D * K * h);
    order_freq = D / Q_opt;

    assert(Q_opt > 0, 'EOQ: Numerically invalid Q* = %.4f.', Q_opt);
    assert(isfinite(total_cost), 'EOQ: Total cost is not finite.');

    res.Q_opt = Q_opt;
    res.cycle_time = cycle_time;
    res.total_cost = total_cost;
    res.order_freq = order_freq;

    if opts.display
        fprintf('EOQ Basic: D=%.2f, K=%.2f, h=%.2f\n', D, K, h);
        fprintf('  Q* = %.4f, Cycle = %.4f yr, Cost = %.4f/yr\n', Q_opt, cycle_time, total_cost);
    end
end

%% ==================== EOQ WITH BACKORDERS ====================
function res = eoq_backorder(D, K, h, b, opts)
% EOQ_BACKORDER  EOQ with planned shortages.
%   b = backorder cost/unit/year
%   Q* = sqrt(2*D*K/h * (h+b)/b), S* = Q* * h/(h+b)
    assert(D > 0 && K > 0 && h > 0 && b > 0, 'D, K, h, b must all be positive.');

    rng(opts.seed, 'twister');

    factor = (h + b) / b;
    Q_opt = sqrt(2 * D * K / h * factor);
    S_opt = Q_opt * h / (h + b);
    max_backorder = Q_opt - S_opt;
    total_cost = sqrt(2 * D * K * h * b / (h + b));

    assert(Q_opt > 0 && S_opt > 0, ...
        'EOQ_BACKORDER: Invalid Q*=%.4f, S*=%.4f.', Q_opt, S_opt);
    assert(max_backorder >= 0, ...
        'EOQ_BACKORDER: Negative max backorder %.4f.', max_backorder);

    res.Q_opt = Q_opt;
    res.S_opt = S_opt;
    res.max_backorder = max_backorder;
    res.total_cost = total_cost;

    if opts.display
        fprintf('EOQ Backorder: D=%.2f, K=%.2f, h=%.2f, b=%.2f\n', D, K, h, b);
        fprintf('  Q* = %.4f, S* = %.4f, Max BO = %.4f, Cost = %.4f/yr\n', ...
            Q_opt, S_opt, max_backorder, total_cost);
    end
end

%% ==================== NEWSBOY (NORMAL DEMAND) ====================
function res = newsvendor_normal(cu, co, mu, sigma, opts)
% NEWSVENDOR_NORMAL  Newsvendor model with normal demand.
%   cu = underage cost (lost profit per unit short)
%   co = overage cost (salvage loss per unit leftover)
%   mu, sigma = demand distribution parameters (normal)
%   Q* = mu + sigma * norminv(cu/(cu+co))
    assert(cu > 0 && co > 0, 'cu and co must be positive.');
    assert(sigma > 0, 'sigma must be positive.');

    rng(opts.seed, 'twister');

    critical_ratio = cu / (cu + co);
    z = norminv(critical_ratio);
    Q_opt = mu + sigma * z;

    % Expected cost
    L_z = normpdf(z) - z * (1 - normcdf(z));  % standard loss function
    expected_cost = (cu + co) * sigma * L_z + co * (Q_opt - mu);

    assert(isfinite(Q_opt), 'NEWSVENDOR: Optimal Q is not finite.');
    assert(critical_ratio > 0 && critical_ratio < 1, ...
        'NEWSVENDOR: Critical ratio %.4f outside (0,1).', critical_ratio);

    res.Q_opt = Q_opt;
    res.expected_cost = expected_cost;
    res.critical_ratio = critical_ratio;
    res.safety_factor = z;

    if opts.display
        fprintf('Newsvendor (Normal): cu=%.2f, co=%.2f, mu=%.2f, sigma=%.2f\n', ...
            cu, co, mu, sigma);
        fprintf('  Critical ratio = %.4f, Q* = %.4f, E[cost] = %.4f\n', ...
            critical_ratio, Q_opt, expected_cost);
    end
end

%% ==================== NEWSBOY (EMPIRICAL) ====================
function res = newsvendor_empirical(cu, co, samples, opts)
% NEWSVENDOR_EMPIRICAL  Newsvendor with empirical demand distribution.
    assert(cu > 0 && co > 0, 'cu and co must be positive.');

    rng(opts.seed, 'twister');
    samples = samples(:);
    n_s = length(samples);
    assert(n_s >= 10, 'At least 10 demand samples required.');

    critical_ratio = cu / (cu + co);
    sorted_demand = sort(samples);
    idx = ceil(critical_ratio * n_s);
    idx = max(1, min(n_s, idx));
    Q_opt = sorted_demand(idx);

    % Expected cost via empirical CDF
    expected_cost = 0;
    for i = 1:n_s
        if samples(i) <= Q_opt
            expected_cost = expected_cost + co * (Q_opt - samples(i));
        else
            expected_cost = expected_cost + cu * (samples(i) - Q_opt);
        end
    end
    expected_cost = expected_cost / n_s;

    res.Q_opt = Q_opt;
    res.expected_cost = expected_cost;
    res.critical_ratio = critical_ratio;

    if opts.display
        fprintf('Newsvendor (Empirical): cu=%.2f, co=%.2f, n=%d\n', cu, co, n_s);
        fprintf('  Q* = %.4f, E[cost] = %.4f\n', Q_opt, expected_cost);
    end
end

%% ==================== (s,S) SIMULATION ====================
function res = ss_simulate(demand_seq, s, S, init_stock, opts)
% SS_SIMULATE  (s,S) inventory policy simulation.
%   When inventory <= s, order up to S.
    assert(s < S, 's must be less than S.');
    assert(init_stock >= 0, 'Initial stock must be non-negative.');

    rng(opts.seed, 'twister');

    n_periods = length(demand_seq);
    stock = init_stock;
    stock_history = zeros(n_periods + 1, 1);
    order_history = zeros(n_periods, 1);
    stock_history(1) = init_stock;

    total_holding = 0;
    total_shortage = 0;
    total_ordering = 0;
    n_orders = 0;

    for t = 1:n_periods
        % Check reorder point
        if stock <= s
            order_qty = S - stock;
            order_history(t) = order_qty;
            stock = stock + order_qty;
            total_ordering = total_ordering + 1;  % fixed order cost
            n_orders = n_orders + 1;
        end

        % Meet demand
        demand = demand_seq(t);
        if stock >= demand
            stock = stock - demand;
        else
            total_shortage = total_shortage + (demand - stock);
            stock = 0;
        end

        stock_history(t + 1) = stock;
        total_holding = total_holding + max(0, stock);
    end

    service_level = 1 - total_shortage / max(sum(demand_seq), 1e-10);
    avg_inventory = mean(stock_history);
    total_cost = total_holding + total_shortage * 5 + total_ordering * 10;  % approximate

    assert(service_level >= 0 && service_level <= 1, ...
        'SS_SIMULATE: Invalid service level %.4f.', service_level);

    res.stock_history = stock_history;
    res.order_history = order_history;
    res.total_cost = total_cost;
    res.service_level = service_level;
    res.avg_inventory = avg_inventory;
    res.n_orders = n_orders;

    if opts.display
        fprintf('(s,S) Simulation: s=%.2f, S=%.2f, T=%d\n', s, S, n_periods);
        fprintf('  Service level = %.4f, Avg inv = %.4f, Orders = %d\n', ...
            service_level, avg_inventory, n_orders);
    end
end

%% ==================== SELF-TEST ====================
function self_test()
    % Test 1: EOQ basic — known analytical result
    % D=1000, K=50, h=2 → Q* = sqrt(2*1000*50/2) = sqrt(50000) ≈ 223.6068
    res1 = inventory_eoq('eoq_basic', 1000, 50, 2);
    Q_expected = sqrt(2 * 1000 * 50 / 2);
    assert(abs(res1.Q_opt - Q_expected) < 1e-4, ...
        'Self-test failed: EOQ Q* = %.6f, expected %.6f.', res1.Q_opt, Q_expected);
    assert(abs(res1.Q_opt - 223.6068) < 0.01, ...
        'Self-test failed: EOQ Q* = %.6f, expected ~223.6.', res1.Q_opt);

    % Test 2: EOQ backorder
    % D=1000, K=50, h=2, b=8
    res2 = inventory_eoq('eoq_backorder', 1000, 50, 2, 8);
    factor = (2 + 8) / 8;
    Q_expected2 = sqrt(2 * 1000 * 50 / 2 * factor);
    assert(abs(res2.Q_opt - Q_expected2) < 1e-4, ...
        'Self-test failed: EOQ backorder Q* mismatch.');
    % S* should be less than Q*
    assert(res2.S_opt < res2.Q_opt, ...
        'Self-test failed: S* should be less than Q* with backorders.');

    % Test 3: Newsvendor normal
    % cu=10, co=5 → critical ratio = 10/15 = 0.6667
    res3 = inventory_eoq('newsvendor', 10, 5, 100, 20);
    assert(abs(res3.critical_ratio - 2/3) < 1e-4, ...
        'Self-test failed: critical ratio mismatch.');
    assert(res3.Q_opt > 100, ...
        'Self-test failed: Q* should exceed mean when cu > co.');

    % Test 4: Newsvendor empirical
    samples_test = (1:100)';
    res4 = inventory_eoq('newsvendor_empirical', 10, 5, samples_test);
    assert(res4.Q_opt > 0 && res4.Q_opt <= 100, ...
        'Self-test failed: empirical Q* out of range.');

    % Test 5: (s,S) simulation
    demand_test = [10; 15; 8; 20; 12; 18; 5; 14; 22; 9];
    res5 = inventory_eoq('ss_simulate', demand_test, 20, 50, 30);
    assert(res5.service_level >= 0, ...
        'Self-test failed: negative service level.');
    assert(length(res5.stock_history) == length(demand_test) + 1, ...
        'Self-test failed: stock_history length incorrect.');

    disp('INVENTORYEOQ self-test passed.');
end
