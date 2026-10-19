% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [xbest, fbest, exitflag, output] = particleswarm_pso(objfun, lb, ub, options)
%% PARTICLESWARM_PSO Particle Swarm Optimization wrapper. Paradigm: PARADIGM-0106-PSO. v3.0.0.
%  Reference: Kennedy & Eberhart (1995) IEEE ICNN. DOI:10.1109/ICNN.1995.488968
%  Requirement 5 (fullfile): not_applicable -- no file IO.
arguments
    objfun (1,1) function_handle
    lb (:,1) double
    ub (:,1) double
    options.SwarmSize (1,1) double {mustBePositive} = 50
    options.MaxIterations (1,1) double {mustBePositive} = 200
    options.Display (1,1) string = "off"
    options.seed (1,1) double = 42
    options.MaxStallIterations (1,1) double {mustBePositive} = 20
    options.FunctionTolerance (1,1) double {mustBePositive} = 1e-6
    options.UseParallel (1,1) logical = false
end
rng(options.seed, 'twister');
% Validate input dimensions
nvars = numel(lb);
assert(numel(ub) == nvars, ...
    'particleswarm_pso: lb and ub must have the same number of elements.');
assert(all(ub > lb), ...
    'particleswarm_pso: ub must be strictly greater than lb element-wise.');
% Verify the objective function returns a scalar for a test point
test_point = (lb + ub) / 2;
test_val = objfun(test_point);
assert(isscalar(test_val) && isfinite(test_val), ...
    'particleswarm_pso: objfun must return a finite scalar.');
% Build optimoptions structure for particleswarm
opts = optimoptions('particleswarm', ...
    'SwarmSize', options.SwarmSize, ...
    'MaxIterations', options.MaxIterations, ...
    'Display', char(options.Display), ...
    'MaxStallIterations', options.MaxStallIterations, ...
    'FunctionTolerance', options.FunctionTolerance, ...
    'UseParallel', options.UseParallel);
% Execute particle swarm optimization
[xbest, fbest, exitflag, output] = particleswarm(objfun, nvars, lb, ub, opts);
% Convergence assessment
if exitflag <= 0
    warning('particleswarm_pso: did not converge satisfactorily. Exitflag = %d.', exitflag);
elseif exitflag == 1
    fprintf('particleswarm_pso: converged successfully (exitflag=1).\n');
end
% Numerical sanity checks on the solution
assert(isfinite(fbest), ...
    'particleswarm_pso: PSO returned non-finite objective value.');
assert(all(isfinite(xbest)), ...
    'particleswarm_pso: PSO returned non-finite solution vector.');
% Verify solution satisfies bound constraints (within tolerance)
tol_bnd = 1e-6;
in_bounds = all(xbest >= lb - tol_bnd) && all(xbest <= ub + tol_bnd);
assert(in_bounds, ...
    'particleswarm_pso: solution violates bound constraints.');
% Verify fbest is not worse than the test point
assert(fbest <= test_val + 1e-6, ...
    'particleswarm_pso: optimized fbest is worse than midpoint test value.');
fprintf('particleswarm_pso: fbest=%.6e, funcCount=%d, iterations=%d.\n', ...
    fbest, output.funccount, output.iterations);
end

%% Self-test
function self_test()
    % Test 1: Rosenbrock 2D -- known global min at [1,1], f=0
    rosenbrock = @(x) (1 - x(1))^2 + 100 * (x(2) - x(1)^2)^2;
    [xb1, fb1, ef1] = particleswarm_pso(rosenbrock, [-5; -5], [5; 5], ...
        SwarmSize=30, MaxIterations=80, seed=42);
    assert(ef1 >= 0, 'PSO exitflag should be nonnegative.');
    dist1 = norm(xb1 - [1; 1]);
    assert(dist1 < 0.5, ...
        sprintf('Rosenbrock: xbest=[%.4f,%.4f] too far from [1,1], dist=%.4f', ...
        xb1(1), xb1(2), dist1));
    assert(fb1 < 1.0, ...
        sprintf('Rosenbrock: fbest=%.6f should be near 0', fb1));

    % Test 2: Sphere 3D -- known global min at [0,0,0], f=0
    sphere3 = @(x) sum(x.^2);
    [xb2, fb2, ef2] = particleswarm_pso(sphere3, [-10; -10; -10], [10; 10; 10], ...
        SwarmSize=40, MaxIterations=100, seed=123);
    assert(ef2 >= 0, 'Sphere PSO exitflag should be nonnegative.');
    assert(norm(xb2) < 1.0, ...
        sprintf('Sphere: norm(xbest)=%.4f should be near 0', norm(xb2)));
    assert(fb2 < 1.0, ...
        sprintf('Sphere: fbest=%.6f should be near 0', fb2));

    fprintf('particleswarm_pso self-test passed (2 test cases, 6 asserts).\n');
end
