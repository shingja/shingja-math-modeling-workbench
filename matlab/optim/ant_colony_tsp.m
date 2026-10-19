% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_solution, best_fitness, history] = ant_colony_tsp(dist_matrix, varargin)
% ANT_COLONY_TSP  Ant Colony Optimization for TSP / combinatorial optimization.
%
%   [BEST, FITNESS, HISTORY] = ANT_COLONY_TSP(DIST)
%   DIST:     n×n distance matrix (symmetric or asymmetric). DIST(i,j) ≥ 0.
%
%   Optional name-value pairs:
%   'NumAnts',       m:  number of ants (default: n).
%   'NumIter',       T:  maximum iterations (default 100).
%   'Alpha',         α:  pheromone weight (default 1).
%   'Beta',          β:  heuristic (visibility) weight (default 2).
%   'Evaporation',   ρ:  pheromone evaporation rate [0,1] (default 0.1).
%   'Q',             Q:  pheromone deposit constant (default 1).
%   'Seed',          s:  random seed (default: none).
%
%   BEST:       best tour found (1×n permutation).
%   FITNESS:    total tour length of BEST.
%   HISTORY:    T×1 vector of best fitness per iteration.
%
%   Example:
%       cities = rand(20, 2);
%       dist   = squareform(pdist(cities));
%       [tour, len] = ant_colony_tsp(dist);
%
%   References:
%       Dorigo, M. & Stützle, T. (2004). Ant Colony Optimization. MIT Press.
%       《各类常用数学模型》第23章 现代优化算法

p = inputParser;
p.addRequired('dist_matrix', @isnumeric);
p.addParameter('NumAnts', [], @isnumeric);
p.addParameter('NumIter', 100, @isnumeric);
p.addParameter('Alpha', 1, @isnumeric);
p.addParameter('Beta', 2, @isnumeric);
p.addParameter('Evaporation', 0.1, @isnumeric);
p.addParameter('Q', 1, @isnumeric);
p.addParameter('Seed', [], @isnumeric);
p.parse(dist_matrix, varargin{:});

opts = p.Results;
n = size(dist_matrix, 1);

if isempty(opts.NumAnts)
    opts.NumAnts = n;
end
m = opts.NumAnts;
T = opts.NumIter;

if ~isempty(opts.Seed)
    rng(opts.Seed);
end

% Initialization
tau = ones(n) * 0.1;          % pheromone matrix
% Heuristic: visibility = 1/distance
eta = 1 ./ (dist_matrix + eps);
eta(1:n+1:end) = 0;          % no self-loops

best_solution = [];
best_fitness  = inf;
history = zeros(T, 1);

for iter = 1:T
    tours  = zeros(m, n);
    lengths = zeros(m, 1);

    for ant = 1:m
        % Start at random city
        current = randi(n);
        visited = false(1, n);
        visited(current) = true;
        tour = zeros(1, n);
        tour(1) = current;

        for step = 2:n
            % Probability from current city to unvisited
            unvisited = find(~visited);
            probs = (tau(current, unvisited).^opts.Alpha) ...
                  .* (eta(current, unvisited).^opts.Beta);
            probs = probs / sum(probs);

            % Roulette wheel selection
            cumprob = cumsum(probs);
            r = rand();
            next_idx = find(cumprob >= r, 1);

            next_city = unvisited(next_idx);
            tour(step) = next_city;
            visited(next_city) = true;
            current = next_city;
        end

        % Compute tour length
        for i = 1:n
            from = tour(i);
            to   = tour(mod(i, n) + 1);
            lengths(ant) = lengths(ant) + dist_matrix(from, to);
        end

        tours(ant, :) = tour;

        % Update best
        if lengths(ant) < best_fitness
            best_fitness  = lengths(ant);
            best_solution = tour;
        end
    end

    % Pheromone update
    tau = (1 - opts.Evaporation) * tau;  % evaporation

    for ant = 1:m
        deposit = opts.Q / lengths(ant);
        tour = tours(ant, :);
        for i = 1:n
            from = tour(i);
            to   = tour(mod(i, n) + 1);
            tau(from, to) = tau(from, to) + deposit;
            tau(to, from) = tau(to, from) + deposit;  % symmetric
        end
    end

    history(iter) = best_fitness;
end
end


%% Convergence check
if ~exist('exitflag', 'var'), exitflag = 1; end
if exitflag < 0, warning('FUNC:DidNotConverge', 'Algorithm may not have converged.'); end

%% Self-test
function self_test()
    % Test with 4-city TSP (known optimal tour)
    rng(42, 'twister');
    % 4 cities in a square: optimal tour = 4
    dist = [0 1 1.414 1; 1 0 1 1.414; 1.414 1 0 1; 1 1.414 1 0];
    [tour, len] = ant_colony_tsp(dist, 'NumIter', 30, 'Seed', 42);
    assert(length(tour) == 4, 'Test failed: tour should visit 4 cities.');
    assert(len > 0, 'Test failed: tour length should be positive.');
    assert(len < 10, 'Test failed: tour length should be reasonable for 4-city TSP.');
    disp('ant_colony_tsp self-test passed.');
end
