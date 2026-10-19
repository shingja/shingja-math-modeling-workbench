% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pareto_front, pareto_set, metrics] = nsga2_optimize(funs, nvars, bounds, options)
%% NSGA2_OPTIMIZE  NSGA-II multi-objective optimizer
%  Paradigm: MCDM-001 | Category: ⑫ | Version: v3.0.0
%  Reference: Deb, Pratap, Agarwal & Meyarivan (2002) "A Fast and Elitist
%             Multiobjective Genetic Algorithm: NSGA-II." IEEE TEC 6(2):182-197.
%
%  Functions:
%    nsga2_optimize(funs, nvars, bounds, pop, n_gen) -> [pareto_front, pareto_set, metrics]

arguments
    funs (1,1) function_handle        % objective function f(x) -> [1 x n_obj] vector
    nvars (1,1) double {mustBeInteger, mustBePositive}
    bounds (:, 2) double              % [lb, ub] per variable
    options.seed (1,1) double = 42
    options.pop_size (1,1) double {mustBeInteger, mustBePositive} = 100
    options.n_gen (1,1) double {mustBeInteger, mustBePositive} = 100
    options.p_cross (1,1) double {mustBeInRange(options.p_cross, 0, 1)} = 0.9
    options.p_mut (1,1) double {mustBeInRange(options.p_mut, 0, 1)} = 0.1
    options.eta_c (1,1) double = 20    % SBX distribution index
    options.eta_m (1,1) double = 20    % polynomial mutation index
end

rng(options.seed, 'twister');

%% --- Initialize ---
pop_size = options.pop_size;
n_gen    = options.n_gen;
lb = bounds(:, 1)';
ub = bounds(:, 2)';

% Initialize population uniformly in bounds
pop = lb + (ub - lb) .* rand(pop_size, nvars);

% Evaluate initial population
n_obj = length(funs(pop(1, :)));
obj_vals = zeros(pop_size, n_obj);
for i = 1:pop_size
    obj_vals(i, :) = funs(pop(i, :));
end

% Metrics tracking
metrics = struct();
metrics.hypervolume_history = zeros(n_gen, 1);
metrics.n_pareto_front = zeros(n_gen, 1);
metrics.converged = false;
metrics.exitflag = 1;

%% --- NSGA-II Main Loop ---
for gen = 1:n_gen
    % Generate offspring via selection, crossover, mutation
    offspring = zeros(pop_size, nvars);
    for i = 1:2:pop_size
        % Binary tournament selection
        p1_idx = tournament_selection(obj_vals);
        p2_idx = tournament_selection(obj_vals);

        parent1 = pop(p1_idx, :);
        parent2 = pop(p2_idx, :);

        % SBX crossover
        if rand() < options.p_cross
            [child1, child2] = sbx_crossover(parent1, parent2, lb, ub, options.eta_c);
        else
            child1 = parent1;
            child2 = parent2;
        end

        % Polynomial mutation
        child1 = polynomial_mutation(child1, lb, ub, options.p_mut, options.eta_m);
        child2 = polynomial_mutation(child2, lb, ub, options.p_mut, options.eta_m);

        % Boundary repair
        child1 = min(max(child1, lb), ub);
        child2 = min(max(child2, lb), ub);

        offspring(i, :) = child1;
        if i + 1 <= pop_size
            offspring(i+1, :) = child2;
        end
    end

    % Evaluate offspring
    offspring_obj = zeros(pop_size, n_obj);
    for i = 1:pop_size
        offspring_obj(i, :) = funs(offspring(i, :));
    end

    % Combine parent and offspring
    combined_pop = [pop; offspring];
    combined_obj = [obj_vals; offspring_obj];  % 2*pop_size x n_obj

    % Non-dominated sorting
    [fronts, ~] = non_dominated_sort(combined_obj);

    % Select next generation
    new_pop = zeros(pop_size, nvars);
    new_obj = zeros(pop_size, n_obj);
    count = 0;
    front_idx = 1;

    while count + length(fronts{front_idx}) <= pop_size
        f = fronts{front_idx};
        n_in_front = length(f);
        new_pop(count+1 : count+n_in_front, :) = combined_pop(f, :);
        new_obj(count+1 : count+n_in_front, :) = combined_obj(f, :);
        count = count + n_in_front;
        front_idx = front_idx + 1;
        if front_idx > length(fronts), break; end
    end

    % Fill remaining slots with crowding-based selection from last front
    if count < pop_size && front_idx <= length(fronts)
        last_front = fronts{front_idx};
        crowd_dist = crowding_distance(combined_obj(last_front, :));
        [~, sort_idx] = sort(crowd_dist, 'descend');
        n_remaining = pop_size - count;
        selected = last_front(sort_idx(1:n_remaining));
        new_pop(count+1 : end, :) = combined_pop(selected, :);
        new_obj(count+1 : end, :) = combined_obj(selected, :);
    end

    pop = new_pop;
    obj_vals = new_obj;

    % Track Pareto front size
    front1 = fronts{1};
    metrics.n_pareto_front(gen) = length(front1);

    % Approximate hypervolume (using nadir point as reference)
    % Hypervolume = product of (ref_i - f_i) for each Pareto point
    if ~isempty(front1)
        pareto_obj = obj_vals(front1, :);
        ref_point = max(obj_vals(front1, :), [], 1) + 1.0;
        hv = 0;
        for i = 1:size(pareto_obj, 1)
            hv = hv + prod(ref_point - pareto_obj(i, :));
        end
        metrics.hypervolume_history(gen) = hv;
    end
end

% Final Pareto front (first front)
[fronts, ~] = non_dominated_sort(obj_vals);
pareto_set  = pop(fronts{1}, :);
pareto_front = obj_vals(fronts{1}, :);

% Convergence check
if gen >= n_gen
    metrics.converged = true;
end
if isempty(pareto_front)
    metrics.exitflag = -1;
    warning('NSGA2:NoPareto', 'No Pareto-optimal solutions found.');
end

%% --- Helper: Binary tournament selection ---
function idx = tournament_selection(obj_all)
    n_all = size(obj_all, 1);
    cand = randperm(n_all, min(2, n_all));
    fronts_t, ranks_t = non_dominated_sort(obj_all(cand, :));
    if length(fronts_t{1}) == 1
        idx = cand(fronts_t{1});
    else
        % Use crowding distance to break ties
        cd = crowding_distance(obj_all(cand, :));
        [~, best] = max(cd);
        idx = cand(best);
    end
end

%% --- Helper: Non-dominated sorting ---
function [fronts, rank] = non_dominated_sort(obj_mat)
    [N, ~] = size(obj_mat);
    rank = zeros(N, 1);
    dominated_by = cell(N, 1);
    dominates_count = zeros(N, 1);

    for i = 1:N
        for j = 1:N
            if i ~= j
                if all(obj_mat(i,:) <= obj_mat(j,:)) && any(obj_mat(i,:) < obj_mat(j,:))
                    dominates_count(i) = dominates_count(i) + 1;
                    dominated_by{j} = [dominated_by{j}, i];
                end
            end
        end
    end

    fronts = {};
    current_front = find(dominates_count == 0)';
    while ~isempty(current_front)
        fronts{end+1} = current_front;
        rank(current_front) = length(fronts);
        next_front = [];
        for p = current_front
            for q = dominated_by{p}
                dominates_count(q) = dominates_count(q) - 1;
                if dominates_count(q) == 0
                    next_front = [next_front, q];
                end
            end
        end
        current_front = next_front;
    end
end

%% --- Helper: Crowding distance ---
function cd = crowding_distance(obj_mat)
    [N, M] = size(obj_mat);
    cd = zeros(N, 1);
    for m = 1:M
        [~, idx] = sort(obj_mat(:, m));
        cd(idx(1)) = inf;
        cd(idx(end)) = inf;
        f_range = obj_mat(idx(end), m) - obj_mat(idx(1), m);
        if f_range > 0
            for i = 2:N-1
                cd(idx(i)) = cd(idx(i)) + ...
                    (obj_mat(idx(i+1), m) - obj_mat(idx(i-1), m)) / f_range;
            end
        end
    end
end

%% --- Helper: SBX Crossover ---
function [c1, c2] = sbx_crossover(p1, p2, lb, ub, eta)
    nv = length(p1);
    c1 = zeros(1, nv);
    c2 = zeros(1, nv);
    for j = 1:nv
        if rand() <= 0.5
            if abs(p2(j) - p1(j)) > 1e-14
                if p1(j) < p2(j)
                    y1 = p1(j); y2 = p2(j);
                else
                    y1 = p2(j); y2 = p1(j);
                end
                yl = lb(j); yu = ub(j);
                beta = 1 + (2 * (y1 - yl) / max(y2 - y1, 1e-14));
                alpha = 2 - beta^(-(eta+1));
                u = rand();
                if u <= 1/alpha
                    beta_q = (u * alpha)^(1/(eta+1));
                else
                    beta_q = (1/(2 - u*alpha))^(1/(eta+1));
                end
                c1(j) = 0.5 * ((y1+y2) - beta_q*(y2-y1));
                beta = 1 + (2 * (yu - y2) / max(y2 - y1, 1e-14));
                alpha = 2 - beta^(-(eta+1));
                u = rand();
                if u <= 1/alpha
                    beta_q = (u * alpha)^(1/(eta+1));
                else
                    beta_q = (1/(2 - u*alpha))^(1/(eta+1));
                end
                c2(j) = 0.5 * ((y1+y2) + beta_q*(y2-y1));
            else
                c1(j) = p1(j); c2(j) = p2(j);
            end
        else
            c1(j) = p1(j); c2(j) = p2(j);
        end
    end
end

%% --- Helper: Polynomial mutation ---
function c = polynomial_mutation(p, lb, ub, p_mut, eta)
    nv = length(p);
    c = p;
    for j = 1:nv
        if rand() < p_mut
            y = p(j); yl = lb(j); yu = ub(j);
            delta1 = (y - yl) / (yu - yl);
            delta2 = (yu - y) / (yu - yl);
            u = rand();
            if u <= 0.5
                delta_q = (2*u + (1-2*u)*(1-delta1)^(eta+1))^(1/(eta+1)) - 1;
            else
                delta_q = 1 - (2*(1-u) + 2*(u-0.5)*(1-delta2)^(eta+1))^(1/(eta+1));
            end
            c(j) = y + delta_q * (yu - yl);
        end
    end
end

%% Self-test
function self_test()
    fprintf('  Running nsga2 self-test (ZDT1)...\n');
    rng(42);
    % ZDT1: 30 vars, f1=x1, f2=g*(1-sqrt(x1/g)), g=1+9*sum(x_{2:30})/(n-1)
    zdt1 = @(x) zdt1_obj(x);
    nv = 8;  % reduced for quick test
    bnds = [zeros(nv,1), ones(nv,1)];

    [pf, ps, mets] = nsga2_optimize(@zdt1, nv, bnds, ...
        'pop_size', 60, 'n_gen', 40, 'seed', 42);

    % Pareto front should have multiple points
    assert(size(pf, 1) >= 5, 'Self-test: too few Pareto points (%d).', size(pf,1));

    % Hypervolume should be > 0.3 (for normalized [0,1]^2 space)
    hv_final = mets.hypervolume_history(end);
    assert(hv_final > 0.3, 'Self-test: hypervolume = %.4f too small.', hv_final);

    % Pareto front should span reasonable range
    assert(min(pf(:,1)) < 0.5, 'Self-test: f1 min should be near 0.');
    assert(max(pf(:,1)) > 0.5, 'Self-test: f1 max should be near 1.');

    fprintf('  nsga2 self-test PASSED (Pareto points=%d, HV=%.4f).\n', size(pf,1), hv_final);
end

function f = zdt1_obj(x)
    n = length(x);
    g = 1 + 9 * sum(x(2:end)) / (n - 1);
    f = [x(1); g * (1 - sqrt(x(1)/g))];
end
end
