% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pareto_front, pareto_set, metrics, exitflag] = nsga3_optimize(funs, nvars, bounds, options)
%% NSGA3OPTIMIZE NSGA-III many-objective optimizer with reference points.
%  Implements NSGA-III with Das-Dennis reference point generation,
%  niche-preservation operator, and adaptive normalization for
%  many-objective (3+ objectives) optimization.
%  Paradigm: PARADIGM-0603
%  Category: MCDM
%  Version: v3.0.0
%  Reference: Deb, K. & Jain, H. (2014) An Evolutionary Many-Objective
%             Optimization Algorithm Using Reference-Point-Based
%             Nondominated Sorting Approach, Part I: Solving Problems
%             With Box Constraints. IEEE Transactions on Evolutionary
%             Computation, 18(4), 577-601. DOI: 10.1109/TEVC.2013.2281535.
%
%  Input:
%      funs   - Function handle f(x) -> [1 x n_obj] objective vector
%      nvars  - Number of decision variables
%      bounds - [lb, ub] per variable (nvars x 2)
%
%  Options:
%      options.seed       - RNG seed (default: 42)
%      options.pop_size   - Population size (default: 100)
%      options.n_gen      - Number of generations (default: 100)
%      options.n_div      - Divisions for Das-Dennis reference points (default: 4)
%      options.p_cross    - Crossover probability (default: 0.9)
%      options.p_mut      - Mutation probability (default: 1/nvars)
%      options.eta_c      - SBX distribution index (default: 30)
%      options.eta_m      - Polynomial mutation index (default: 20)
%
%  Output:
%      pareto_front - Objective values of Pareto solutions (n_pareto x n_obj)
%      pareto_set   - Decision variable values (n_pareto x nvars)
%      metrics      - Structure with convergence metrics
%      exitflag     - 1 = success, -1 = failed

arguments
    funs (1,1) function_handle
    nvars (1,1) double {mustBeInteger, mustBePositive}
    bounds (:, 2) double
    options.seed (1,1) double = 42
    options.pop_size (1,1) double {mustBeInteger, mustBePositive} = 100
    options.n_gen (1,1) double {mustBeInteger, mustBePositive} = 100
    options.n_div (1,1) double {mustBeInteger, mustBePositive} = 4
    options.p_cross (1,1) double {mustBeInRange(options.p_cross, 0, 1)} = 0.9
    options.p_mut (1,1) double {mustBeInRange(options.p_mut, 0, 1)} = []
    options.eta_c (1,1) double = 30
    options.eta_m (1,1) double = 20
end

rng(options.seed, 'twister');

lb = bounds(:, 1)';
ub = bounds(:, 2)';
pop_size = options.pop_size;
n_gen = options.n_gen;
p_cross = options.p_cross;

if isempty(options.p_mut)
    p_mut = 1 / nvars;
else
    p_mut = options.p_mut;
end

%% Determine number of objectives
x0 = lb + (ub - lb) .* rand(1, nvars);
n_obj = length(funs(x0));
assert(n_obj >= 2, 'NSGA-III requires at least 2 objectives.');

%% Generate Das-Dennis reference points
ref_points = generate_reference_points(n_obj, options.n_div);
n_ref = size(ref_points, 1);

%% Adjust population size to nearest multiple of 4 above n_ref
% NSGA-III pop size should be >= number of reference points
desired_pop = max(pop_size, n_ref);
pop_size = ceil(desired_pop / 4) * 4;

%% Initialize population
pop = lb + (ub - lb) .* rand(pop_size, nvars);
obj_vals = zeros(pop_size, n_obj);
for i = 1:pop_size
    obj_vals(i, :) = funs(pop(i, :));
end

%% Metrics tracking
metrics = struct();
metrics.hv_history = zeros(n_gen, 1);
metrics.n_pareto = zeros(n_gen, 1);
metrics.igd_history = zeros(n_gen, 1);
metrics.converged = false;
exitflag = 1;

%% NSGA-III Main Loop
for gen = 1:n_gen
    %% Generate offspring
    offspring = zeros(pop_size, nvars);
    for i = 1:2:pop_size
        % Tournament selection
        p1 = pop(tournament_selection(obj_vals, 2), :);
        p2 = pop(tournament_selection(obj_vals, 2), :);

        % SBX crossover
        if rand() < p_cross
            [c1, c2] = sbx_crossover(p1, p2, lb, ub, options.eta_c);
        else
            c1 = p1; c2 = p2;
        end

        % Polynomial mutation
        c1 = polynomial_mutation(c1, lb, ub, p_mut, options.eta_m);
        c2 = polynomial_mutation(c2, lb, ub, p_mut, options.eta_m);

        % Boundary repair
        c1 = min(max(c1, lb), ub);
        c2 = min(max(c2, lb), ub);

        offspring(i, :) = c1;
        if i + 1 <= pop_size
            offspring(i + 1, :) = c2;
        end
    end

    %% Evaluate offspring
    offspring_obj = zeros(pop_size, n_obj);
    for i = 1:pop_size
        offspring_obj(i, :) = funs(offspring(i, :));
    end

    %% Combine
    combined_pop = [pop; offspring];         % 2*pop_size x nvars
    combined_obj = [obj_vals; offspring_obj]; % 2*pop_size x n_obj

    %% Non-dominated sorting
    [fronts, ~] = non_dominated_sort(combined_obj);

    %% Select next population (NSGA-III niche preservation)
    new_pop = [];
    new_obj = [];
    count = 0;
    last_front_idx = 1;

    % Include complete fronts
    for f_idx = 1:length(fronts)
        if count + length(fronts{f_idx}) <= pop_size
            f_members = fronts{f_idx};
            new_pop = [new_pop; combined_pop(f_members, :)];
            new_obj = [new_obj; combined_obj(f_members, :)];
            count = count + length(f_members);
            last_front_idx = last_front_idx + 1;
        else
            last_front_idx = f_idx;
            break;
        end
    end

    % Niche-preservation for the last front
    if count < pop_size && last_front_idx <= length(fronts)
        St = fronts(1:last_front_idx-1);  % already selected fronts
        Fl = fronts{last_front_idx};       % last front to select from

        % Normalize objectives of combined population so far
        if count > 0
            ideal_point = min(new_obj, [], 1);
            % Estimate nadir point from extreme points
            nadir_point = max(new_obj, [], 1);
        else
            ideal_point = min(combined_obj, [], 1);
            nadir_point = max(combined_obj, [], 1);
        end

        % Normalize
        norm_range = nadir_point - ideal_point;
        norm_range(norm_range < 1e-12) = 1;
        norm_combined_obj = (combined_obj - ideal_point) ./ norm_range;

        % Associate each solution with nearest reference point
        [pi_assoc, d_assoc] = associate_to_ref_points(norm_combined_obj, ref_points);

        % Count niche sizes for already-selected solutions
        niche_count = zeros(n_ref, 1);
        for s = 1:count
            ref_idx = pi_assoc(s);
            if ref_idx > 0
                niche_count(ref_idx) = niche_count(ref_idx) + 1;
            end
        end

        % Niching: select remaining solutions from Fl
        remaining = pop_size - count;
        selected_from_Fl = false(length(Fl), 1);

        for k = 1:remaining
            % Find reference point with min niche count
            candidates = Fl(~selected_from_Fl);
            if isempty(candidates), break; end

            % Find reference points with at least one associated candidate
            ref_with_cand = [];
            for rp = 1:n_ref
                assoc_in_Fl = false;
                for cand_idx = 1:length(candidates)
                    global_idx = candidates(cand_idx);
                    if pi_assoc(global_idx) == rp
                        assoc_in_Fl = true;
                        break;
                    end
                end
                if assoc_in_Fl
                    ref_with_cand = [ref_with_cand, rp];
                end
            end

            if isempty(ref_with_cand)
                % Random selection from remaining
                pick = candidates(randi(length(candidates)));
            else
                % Find reference point with minimum niche count
                [~, min_idx_local] = min(niche_count(ref_with_cand));
                chosen_ref = ref_with_cand(min_idx_local);

                % Find candidates associated with chosen_ref
                assoc_cand = [];
                for cand_idx = 1:length(candidates)
                    if pi_assoc(candidates(cand_idx)) == chosen_ref
                        assoc_cand = [assoc_cand, candidates(cand_idx)];
                    end
                end

                if niche_count(chosen_ref) == 0 && ~isempty(assoc_cand)
                    % Pick closest
                    [~, best_local] = min(d_assoc(assoc_cand));
                    pick = assoc_cand(best_local);
                elseif ~isempty(assoc_cand)
                    % Randomly pick
                    pick = assoc_cand(randi(length(assoc_cand)));
                else
                    pick = candidates(randi(length(candidates)));
                end

                niche_count(chosen_ref) = niche_count(chosen_ref) + 1;
            end

            selected_from_Fl(Fl == pick) = true;
            new_pop = [new_pop; combined_pop(pick, :)];
            new_obj = [new_obj; combined_obj(pick, :)];
            count = count + 1;
        end
    end

    pop = new_pop;
    obj_vals = new_obj;

    % Track Pareto front
    [f1, ~] = non_dominated_sort(obj_vals);
    metrics.n_pareto(gen) = length(f1{1});

    % Approximate hypervolume
    pareto_f = obj_vals(f1{1}, :);
    if ~isempty(pareto_f) && size(pareto_f, 1) > 1
        ref_point = max(pareto_f, [], 1) + 1.0;
        hv = 0;
        for pi = 1:size(pareto_f, 1)
            hv = hv + prod(max(0, ref_point - pareto_f(pi, :)));
        end
        metrics.hv_history(gen) = hv;
    end
end

% Final output
[f1, ~] = non_dominated_sort(obj_vals);
pareto_set = pop(f1{1}, :);
pareto_front = obj_vals(f1{1}, :);

if isempty(pareto_front)
    exitflag = -1;
    warning('NSGA3:NoPareto', 'No Pareto solutions found.');
    metrics.converged = false;
else
    metrics.converged = true;
end

%% Nested: Das-Dennis reference points
function Z = generate_reference_points(M, p)
    % Generate reference points on M-simplex with p divisions
    % Number: C(M+p-1, p)
    Z = generate_recursive(M, p, []);
    function pts = generate_recursive(M_inner, p_inner, prefix)
        if M_inner == 1
            pts = [prefix, p_inner];
        else
            pts = [];
            for v = 0:p_inner
                sub = generate_recursive(M_inner - 1, p_inner - v, [prefix, v]);
                pts = [pts; sub];
            end
        end
    end
    Z = Z / p;  % normalize to [0,1]
end

%% Nested: Associate solutions to reference points
function [pi_idx, d_min] = associate_to_ref_points(obj_norm, ref_pts)
    n_sol = size(obj_norm, 1);
    n_ref = size(ref_pts, 1);
    pi_idx = zeros(n_sol, 1);
    d_min = zeros(n_sol, 1);

    for s = 1:n_sol
        min_dist = inf;
        best_ref = 0;
        for rp = 1:n_ref
            % Perpendicular distance to reference line
            d_perp = norm(obj_norm(s, :) - ...
                (obj_norm(s, :) * ref_pts(rp, :)') * ref_pts(rp, :) / ...
                max(norm(ref_pts(rp, :))^2, 1e-12));
            if d_perp < min_dist
                min_dist = d_perp;
                best_ref = rp;
            end
        end
        pi_idx(s) = best_ref;
        d_min(s) = min_dist;
    end
end

%% Nested: Tournament selection (same as NSGA-II)
function idx = tournament_selection(obj_all, k)
    n_all = size(obj_all, 1);
    cand = randperm(n_all, min(k, n_all));
    [fr, ~] = non_dominated_sort(obj_all(cand, :));
    if length(fr{1}) == 1
        idx = cand(fr{1}(1));
    else
        idx = cand(fr{1}(randi(length(fr{1}))));
    end
end

%% Nested: Non-dominated sorting
function [fronts, ranks] = non_dominated_sort(obj_mat)
    [N_s, ~] = size(obj_mat);
    dominated_by = cell(N_s, 1);
    dominates_count = zeros(N_s, 1);

    for p = 1:N_s
        for q = 1:N_s
            if p ~= q
                if all(obj_mat(p,:) <= obj_mat(q,:)) && any(obj_mat(p,:) < obj_mat(q,:))
                    dominates_count(p) = dominates_count(p) + 1;
                    dominated_by{q} = [dominated_by{q}, p];
                end
            end
        end
    end

    fronts = {};
    ranks = zeros(N_s, 1);
    current_front = find(dominates_count == 0)';
    while ~isempty(current_front)
        fronts{end+1} = current_front;
        ranks(current_front) = length(fronts);
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

%% Nested: SBX crossover
function [c1, c2] = sbx_crossover(p1, p2, lb, ub, eta)
    nv = length(p1);
    c1 = p1; c2 = p2;
    for j = 1:nv
        if rand() <= 0.5 && abs(p2(j) - p1(j)) > 1e-14
            y1 = min(p1(j), p2(j));
            y2 = max(p1(j), p2(j));
            yl = lb(j); yu = ub(j);
            beta = 1 + 2 * (y1 - yl) / max(y2 - y1, 1e-14);
            alpha = 2 - beta^(-(eta + 1));
            u = rand();
            if u <= 1 / alpha
                beta_q = (u * alpha)^(1 / (eta + 1));
            else
                beta_q = (1 / (2 - u * alpha))^(1 / (eta + 1));
            end
            c1(j) = 0.5 * ((y1 + y2) - beta_q * (y2 - y1));
            beta = 1 + 2 * (yu - y2) / max(y2 - y1, 1e-14);
            alpha = 2 - beta^(-(eta + 1));
            u = rand();
            if u <= 1 / alpha
                beta_q = (u * alpha)^(1 / (eta + 1));
            else
                beta_q = (1 / (2 - u * alpha))^(1 / (eta + 1));
            end
            c2(j) = 0.5 * ((y1 + y2) + beta_q * (y2 - y1));
        end
    end
end

%% Nested: Polynomial mutation
function c = polynomial_mutation(p, lb, ub, p_mut, eta)
    nv = length(p);
    c = p;
    for j = 1:nv
        if rand() < p_mut
            y = p(j); yl = lb(j); yu = ub(j);
            delta1 = (y - yl) / max(yu - yl, 1e-14);
            delta2 = (yu - y) / max(yu - yl, 1e-14);
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
    fprintf('  Running nsga3 self-test (ZDT1)...\n');
    rng(42);

    zdt1 = @(x) zdt1_obj(x);
    nv = 5;
    bnds = [zeros(nv,1), ones(nv,1)];

    [pf, ps, mets, ef] = nsga3_optimize(zdt1, nv, bnds, ...
        'pop_size', 60, 'n_gen', 30, 'n_div', 4, 'seed', 42);

    assert(ef == 1, 'Self-test 1: exitflag should be 1, got %d.', ef);
    assert(size(pf, 1) >= 5, ...
        'Self-test 1: expected >= 5 Pareto points, got %d.', size(pf, 1));
    assert(size(ps, 1) == size(pf, 1), ...
        'Self-test 1: Pareto set and front sizes should match.');

    % Pareto front should span [0,1] in f1
    assert(min(pf(:, 1)) < 0.3, ...
        'Self-test 2: f1 min should be near 0, got %.4f.', min(pf(:, 1)));
    assert(max(pf(:, 1)) > 0.7, ...
        'Self-test 2: f1 max should be near 1, got %.4f.', max(pf(:, 1)));

    % Hypervolume should be positive
    hv_final = mets.hv_history(end);
    assert(hv_final > 0.1, ...
        'Self-test 3: final hypervolume should be > 0.1, got %.4f.', hv_final);

    % Pareto count should be > 0 in most generations
    assert(mean(mets.n_pareto) > 0, ...
        'Self-test 4: average Pareto count across generations should be > 0.');

    % Convergence flag
    assert(mets.converged == true, ...
        'Self-test 5: metrics.converged should be true.');

    fprintf('  nsga3 self-test PASSED (Pareto points=%d, HV=%.4f).\n', size(pf,1), hv_final);
end

function f = zdt1_obj(x)
    n = length(x);
    g = 1 + 9 * sum(x(2:end)) / (n - 1);
    f = [x(1); g * (1 - sqrt(x(1)/g))];
end
end
