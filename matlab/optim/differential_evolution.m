% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [best_solution, best_fitness, history] = differential_evolution(fitness_func, lb, ub, varargin)
% DIFFERENTIAL_EVOLUTION  DE/rand/1/bin for global continuous optimization.
%
%   [BEST, FITNESS, HISTORY] = DIFFERENTIAL_EVOLUTION(FITFUN, LB, UB)
%   FITFUN: function handle f(x) → scalar. Minimized by DE.
%   LB:     1×d vector of lower bounds.
%   UB:     1×d vector of upper bounds.
%
%   Optional name-value pairs:
%   'PopSize',    NP:  population size (default 10*dim).
%   'MaxIter',    G:   maximum generations (default 200).
%   'F',          F:   mutation factor [0,2] (default 0.8).
%   'CR',         CR:  crossover probability [0,1] (default 0.9).
%   'TolFun',     tol: convergence tolerance (default 1e-6).
%   'Seed',       s:   random seed (default: none).
%
%   BEST:       1×d best solution vector.
%   FITNESS:    scalar, best objective value.
%   HISTORY:    struct with .bestfit (G×1), .meanfit (G×1).
%
%   Example:
%       fun = @(x) sum(x.^2);  % sphere function
%       [x, fval] = differential_evolution(fun, [-5 -5], [5 5]);
%
%   References:
%       Storn, R. & Price, K. (1997). J. Global Optimization 11:341-359.
%       《各类常用数学模型》第23章 现代优化算法

p = inputParser;
p.addRequired('fitness_func', @(x) isa(x, 'function_handle'));
p.addRequired('lb', @isnumeric);
p.addRequired('ub', @isnumeric);
p.addParameter('PopSize', [], @isnumeric);
p.addParameter('MaxIter', 200, @isnumeric);
p.addParameter('F', 0.8, @isnumeric);
p.addParameter('CR', 0.9, @isnumeric);
p.addParameter('TolFun', 1e-6, @isnumeric);
p.addParameter('Seed', [], @isnumeric);
p.parse(fitness_func, lb, ub, varargin{:});

opts = p.Results;
lb = lb(:)';
ub = ub(:)';
dim = length(lb);

if isempty(opts.PopSize)
    opts.PopSize = 10 * dim;
end
NP = opts.PopSize;
G  = opts.MaxIter;
F  = opts.F;
CR = opts.CR;

if ~isempty(opts.Seed)
    rng(opts.Seed);
end

% Initialize population uniformly in [lb, ub]
pop = lb + rand(NP, dim) .* (ub - lb);
fitness = zeros(NP, 1);
for i = 1:NP
    fitness(i) = fitness_func(pop(i, :));
end

[best_fitness, best_idx] = min(fitness);
best_solution = pop(best_idx, :);

history.bestfit = zeros(G, 1);
history.meanfit = zeros(G, 1);

for gen = 1:G
    for i = 1:NP
        % Select three distinct random vectors r1 ≠ r2 ≠ r3 ≠ i
        candidates = 1:NP;
        candidates(i) = [];
        r = candidates(randperm(NP - 1, 3));
        r1 = r(1); r2 = r(2); r3 = r(3);

        % Mutation: v = x_r1 + F * (x_r2 - x_r3)
        v = pop(r1, :) + F * (pop(r2, :) - pop(r3, :));

        % Boundary repair: bounce-back
        v = max(v, lb);
        v = min(v, ub);

        % Crossover: binomial
        jrand = randi(dim);
        u = pop(i, :);
        for j = 1:dim
            if rand() <= CR || j == jrand
                u(j) = v(j);
            end
        end

        % Selection: greedy
        f_u = fitness_func(u);
        if f_u < fitness(i)
            pop(i, :) = u;
            fitness(i) = f_u;
            if f_u < best_fitness
                best_fitness  = f_u;
                best_solution = u;
            end
        end
    end

    history.bestfit(gen) = best_fitness;
    history.meanfit(gen) = mean(fitness);

    % Convergence check
    if gen > 20 && abs(history.bestfit(gen) - history.bestfit(gen-20)) < opts.TolFun
        history.bestfit = history.bestfit(1:gen);
        history.meanfit = history.meanfit(1:gen);
        break;
    end
end
end

%% Self-test
function self_test()
    % Test minimize sphere function f(x) = sum(x.^2) in 2D
    rng(42, 'twister');
    fun = @(x) sum(x.^2);
    lb = [-5, -5]; ub = [5, 5];
    [best, fval] = differential_evolution(fun, lb, ub, 'Seed', 42, 'MaxIter', 50);
    assert(fval < 2.0, 'Test failed: sphere should find near-zero solution.');
    assert(all(size(best) == [1, 2]), 'Test failed: solution should be 1x2.');
    disp('differential_evolution self-test passed.');
end
