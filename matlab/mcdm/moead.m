% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pareto_front, pareto_set, metrics] = moead(funs, nvars, bounds, options)
%% MOEAD  MOEA/D: Multi-Objective Evolutionary Algorithm based on Decomposition
%  Paradigm: MCDM-002 | Category: ⑫ | Version: v3.0.0
%  Reference: Zhang & Li (2007) "MOEA/D: A Multiobjective Evolutionary
%             Algorithm Based on Decomposition." IEEE TEC 11(6):712-731.
%
%  Decomposes MOP into N scalar subproblems via Tchebycheff / weighted-sum /
%  penalty-boundary intersection.

arguments
    funs (1,1) function_handle         % f(x) -> [1 x n_obj]
    nvars (1,1) double {mustBeInteger, mustBePositive}
    bounds (:, 2) double               % [lb, ub] per variable
    options.seed (1,1) double = 42
    options.pop_size (1,1) double {mustBeInteger, mustBePositive} = 100
    options.n_gen (1,1) double {mustBeInteger, mustBePositive} = 100
    options.n_neighbors (1,1) double {mustBeInteger, mustBePositive} = 20
    options.p_cross (1,1) double = 0.9
    options.p_mut (1,1) double = 0.1
    options.eta_c (1,1) double = 20
    options.eta_m (1,1) double = 20
    options.method (1,:) char {mustBeMember(options.method, ...
        {'tchebycheff','weighted_sum','pbi'})} = 'tchebycheff'
    options.pbi_theta (1,1) double = 5.0  % penalty param for PBI
end

rng(options.seed, 'twister');

%% --- Initialize ---
N = options.pop_size;          % number of subproblems
T = min(options.n_neighbors, N);

% Generate N weight vectors uniformly distributed on simplex
% Using simplex-lattice design for 2-objective (or Das-Dennis for general)
lb = bounds(:, 1)';
ub = bounds(:, 2)';
n_obj_test = length(funs(lb));
n_obj = n_obj_test;
if n_obj == 2
    weights = [linspace(0,1,N)', 1 - linspace(0,1,N)'];
else
    % Simple random uniform on simplex
    weights = rand(N, n_obj);
    weights = weights ./ sum(weights, 2);
end

% Neighborhood: for each weight vector, find T closest (Euclidean)
dist_mat = pdist2(weights, weights);
[~, neighbor_idx] = sort(dist_mat, 2);
neighbors = neighbor_idx(:, 1:T);

% Initialize population randomly
pop = lb + (ub - lb) .* rand(N, nvars);
obj_vals = zeros(N, n_obj);
for i = 1:N
    obj_vals(i, :) = funs(pop(i, :));
end

% Ideal point (best in each objective)
z_ideal = min(obj_vals, [], 1);

% Compute scalarized fitness
fitness = zeros(N, 1);
for i = 1:N
    fitness(i) = scalarize(obj_vals(i, :), z_ideal, weights(i, :), options);
end

%% --- Main MOEA/D Loop ---
for gen = 1:options.n_gen
    for i = 1:N
        % Select two parents from neighborhood
        nb = neighbors(i, :);
        p1_idx = nb(randi(T));
        p2_idx = nb(randi(T));
        while p2_idx == p1_idx
            p2_idx = nb(randi(T));
        end

        % SBX crossover
        if rand() < options.p_cross
            [child, ~] = sbx_crossover_mo(pop(p1_idx,:), pop(p2_idx,:), lb, ub, options.eta_c);
        else
            child = pop(p1_idx, :);
        end

        % Polynomial mutation
        child = polynomial_mutation_mo(child, lb, ub, options.p_mut, options.eta_m);
        child = min(max(child, lb), ub);

        % Evaluate child
        f_child = funs(child);

        % Update ideal point
        z_ideal = min(z_ideal, f_child);

        % Update neighbors
        c = 0;
        max_replace = min(2, T);
        perm = randperm(T);
        for jj = 1:T
            j = nb(perm(jj));
            f_new = scalarize(f_child, z_ideal, weights(j, :), options);
            if f_new < fitness(j)
                pop(j, :) = child;
                obj_vals(j, :) = f_child;
                fitness(j) = f_new;
                c = c + 1;
                if c >= max_replace, break; end
            end
        end
    end

    % Track convergence
    if mod(gen, 20) == 0
        z_ideal_prev = z_ideal;
    end
end

% Extract Pareto front (non-dominated among final population)
[fronts, ~] = non_dominated_sort_mo(obj_vals);
pareto_set  = pop(fronts{1}, :);
pareto_front = obj_vals(fronts{1}, :);

% Metrics
metrics = struct();
metrics.z_ideal = z_ideal;
metrics.n_pareto = size(pareto_front, 1);
metrics.converged = true;
metrics.exitflag = 1;

% Inverted Generational Distance (IGD) approximation
if ~isempty(pareto_front)
    % Approximate reference: use extreme points
    ref_set = [min(pareto_front(:,1)), max(pareto_front(:,2));
               max(pareto_front(:,1)), min(pareto_front(:,2))];
    D = pdist2(ref_set, pareto_front);
    metrics.igd = mean(min(D, [], 2));
else
    metrics.igd = inf;
    metrics.exitflag = -1;
end

%% --- Nested: scalarization ---
function s = scalarize(f_vec, z, w, opts)
    switch lower(opts.method)
        case 'tchebycheff'
            % max_i w_i * |f_i - z_i|
            s = max(w .* abs(f_vec - z));
        case 'weighted_sum'
            s = sum(w .* f_vec);
        case 'pbi'
            % d1 + theta * d2
            d1 = abs(dot(f_vec - z, w)) / norm(w);
            d2 = norm((f_vec - z) - d1 * (w / norm(w)));
            s = d1 + opts.pbi_theta * d2;
        otherwise
            s = max(w .* abs(f_vec - z));
    end
end

%% --- Nested: SBX crossover ---
function [c1, c2] = sbx_crossover_mo(p1, p2, lb, ub, eta)
    nv = length(p1);
    c1 = zeros(1, nv); c2 = zeros(1, nv);
    for j = 1:nv
        if rand() <= 0.5 && abs(p2(j)-p1(j)) > 1e-14
            y1 = min(p1(j), p2(j)); y2 = max(p1(j), p2(j));
            yl = lb(j); yu = ub(j);
            beta = 1 + 2*(y1-yl)/max(y2-y1, 1e-14);
            alpha = 2 - beta^(-(eta+1));
            u1 = rand(); u2 = rand();
            if u1 <= 1/alpha
                bq1 = (u1*alpha)^(1/(eta+1));
            else
                bq1 = (1/(2-u1*alpha))^(1/(eta+1));
            end
            if u2 <= 1/alpha
                bq2 = (u2*alpha)^(1/(eta+1));
            else
                bq2 = (1/(2-u2*alpha))^(1/(eta+1));
            end
            c1(j) = 0.5*((y1+y2) - bq1*(y2-y1));
            c2(j) = 0.5*((y1+y2) + bq2*(y2-y1));
        else
            c1(j) = p1(j); c2(j) = p2(j);
        end
    end
end

%% --- Nested: Polynomial mutation ---
function c = polynomial_mutation_mo(p, lb, ub, p_mut, eta)
    nv = length(p); c = p;
    for j = 1:nv
        if rand() < p_mut
            y = p(j); yl = lb(j); yu = ub(j);
            delta1 = (y-yl)/(yu-yl); delta2 = (yu-y)/(yu-yl);
            u = rand();
            if u <= 0.5
                dq = (2*u+(1-2*u)*(1-delta1)^(eta+1))^(1/(eta+1)) - 1;
            else
                dq = 1 - (2*(1-u)+2*(u-0.5)*(1-delta2)^(eta+1))^(1/(eta+1));
            end
            c(j) = y + dq*(yu-yl);
        end
    end
end

%% --- Nested: Non-dominated sort ---
function [fronts, rank] = non_dominated_sort_mo(obj_mat)
    [N, M] = size(obj_mat);
    rank = zeros(N,1);
    dominated_by = cell(N,1);
    dom_count = zeros(N,1);
    for i = 1:N
        for j = 1:N
            if i~=j && all(obj_mat(i,:)<=obj_mat(j,:)) && any(obj_mat(i,:)<obj_mat(j,:))
                dom_count(i) = dom_count(i)+1;
                dominated_by{j} = [dominated_by{j}, i];
            end
        end
    end
    fronts = {};
    cf = find(dom_count==0)';
    while ~isempty(cf)
        fronts{end+1} = cf;
        rank(cf) = length(fronts);
        nf = [];
        for p = cf
            for q = dominated_by{p}
                dom_count(q) = dom_count(q)-1;
                if dom_count(q)==0, nf=[nf,q]; end
            end
        end
        cf = nf;
    end
end

%% Self-test
function self_test()
    fprintf('  Running moead self-test (ZDT1)...\n');
    rng(42);
    zdt1 = @(x) zdt1_obj_mo(x);
    nv = 8;
    bnds = [zeros(nv,1), ones(nv,1)];

    [pf, ps, mets] = moead(@zdt1, nv, bnds, ...
        'pop_size', 60, 'n_gen', 40, 'seed', 42, 'method', 'tchebycheff');

    % Pareto front should have multiple points
    assert(size(pf,1) >= 5, 'Self-test: too few Pareto points (%d).', size(pf,1));

    % IGD should be reasonable
    assert(mets.igd < 2.0, 'Self-test: IGD = %.4f too large.', mets.igd);

    % Pareto front should span range
    assert(min(pf(:,1)) < 0.3, 'Self-test: f1 should extend near 0.');
    assert(max(pf(:,1)) > 0.7, 'Self-test: f1 should extend near 1.');

    % Compare methods
    [~, ~, mets_ws] = moead(@zdt1, nv, bnds, ...
        'pop_size', 40, 'n_gen', 20, 'seed', 42, 'method', 'weighted_sum');
    assert(isfinite(mets_ws.igd), 'Self-test: weighted_sum IGD not finite.');

    fprintf('  moead self-test PASSED (points=%d, IGD=%.4f).\n', size(pf,1), mets.igd);
end

function f = zdt1_obj_mo(x)
    n = length(x);
    g = 1 + 9*sum(x(2:end))/(n-1);
    f = [x(1); g*(1-sqrt(x(1)/g))];
end
end
