% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [earliest, latest, slack, critical_path, makespan] = critical_path(activities, durations, dependencies)
% Input validation
arguments
    data (:,:) double
end
%CRITICAL_PATH 关键路径法 (Critical Path Method, CPM)
%   [EARLIEST, LATEST, SLACK, CRITICAL_PATH, MAKESPAN] = ...
%       CRITICAL_PATH(ACTIVITIES, DURATIONS, DEPENDENCIES)
%
%   Source: Kelley, J.E., Walker, M.R. (1959).
%          Critical-Path Planning and Scheduling.
%          Proceedings of the Eastern Joint Computer Conference.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       activities   - 活动名称 cell 数组 (n_activities × 1) 或数量
%       durations    - 活动持续时间 (n_activities × 1)
%       dependencies - 依赖关系矩阵 (n_activities × n_activities)
%                      dependencies(i,j)=1 表示 j 依赖 i (i 完成才能开始 j)
%                      或 (m × 2) 边列表 [from, to]
%
%   输出:
%       earliest      - 最早开始时间 (n × 1)
%       latest        - 最晚开始时间 (n × 1)
%       slack         - 总时差 (n × 1), 0=关键活动
%       critical_path - 关键路径上的活动索引
%       makespan      - 项目总工期
%
%   示例:
%       dur = [3; 2; 4; 1; 2];
%       dep = [1 3; 2 3; 3 4; 3 5];  % 边列表格式
%       [e,l,s,cp,m] = critical_path([], dur, dep);

%% 依赖检查
% 仅使用 MATLAB 内置函数

%% 参数处理
if isempty(activities)
    n = length(durations);
elseif isscalar(activities)
    n = activities;
else
    n = length(activities);
end

durations = durations(:);

% 统一依赖关系为邻接矩阵格式
if size(dependencies, 2) == 2
    % 边列表 → 邻接矩阵
    dep_matrix = zeros(n, n);
    for k = 1:size(dependencies, 1)
        from = dependencies(k, 1);
        to = dependencies(k, 2);
        if from >= 1 && from <= n && to >= 1 && to <= n
            dep_matrix(from, to) = 1;
        end
    end
else
    dep_matrix = dependencies;
end

%% Step 1: 拓扑排序 (Kahn 算法)
in_degree = sum(dep_matrix > 0, 1);  % 入度
queue = find(in_degree == 0);
topo_order = zeros(n, 1);
idx = 0;

while ~isempty(queue)
    u = queue(1);
    queue(1) = [];
    idx = idx + 1;
    topo_order(idx) = u;

    for v = 1:n
        if dep_matrix(u, v) > 0
            in_degree(v) = in_degree(v) - 1;
            if in_degree(v) == 0
                queue = [queue, v]; %#ok<AGROW>
            end
        end
    end
end

if idx < n
    error('依赖关系包含环! 无法进行关键路径分析。请检查活动依赖。');
end

%% Step 2: 正向传播 (Forward Pass) → 最早时间
earliest = zeros(n, 1);

for k = 1:n
    u = topo_order(k);
    % 找所有前驱活动
    predecessors = find(dep_matrix(:, u) > 0);
    max_pred_finish = 0;
    for p = 1:length(predecessors)
        pred = predecessors(p);
        finish_pred = earliest(pred) + durations(pred);
        if finish_pred > max_pred_finish
            max_pred_finish = finish_pred;
        end
    end
    earliest(u) = max_pred_finish;
end

% 总工期
makespan = max(earliest + durations);

%% Step 3: 反向传播 (Backward Pass) → 最晚时间
latest = inf(n, 1);

% 终端活动 (出度为0)
terminals = find(sum(dep_matrix, 2) == 0);
for t = 1:length(terminals)
    latest(terminals(t)) = makespan - durations(terminals(t));
end

% 逆拓扑序遍历
for k = n:-1:1
    u = topo_order(k);
    % 找所有后继活动
    successors = find(dep_matrix(u, :) > 0);
    min_succ_start = makespan;
    for s = 1:length(successors)
        succ = successors(s);
        if latest(succ) < min_succ_start
            min_succ_start = latest(succ);
        end
    end
    if ~isempty(successors)
        latest(u) = min_succ_start - durations(u);
    end
    % 若无后继 (终端), latest 已在上一步设置
end

% 修正可能的负值
latest = max(0, latest);

%% Step 4: 计算时差 (Slack)
slack = latest - earliest;

% 关键路径: 时差为零的活动
critical_path = find(abs(slack) < 1e-10);

%% 输出摘要
fprintf('\n=== 关键路径法 (CPM) ===\n');
fprintf('项目总工期: %.2f\n', makespan);
fprintf('关键路径活动 (%d 个): ', length(critical_path));
fprintf('%d ', critical_path);
fprintf('\n\n活动明细:\n');
fprintf('%-6s %-8s %-10s %-10s %-10s %-6s\n', '活动', '工期', '最早开始', '最晚开始', '时差', '关键?');
fprintf('%s\n', repmat('-', 1, 58));
for i = 1:n
    is_cp = abs(slack(i)) < 1e-10;
    flag = '';
    if is_cp, flag = '★'; end
    fprintf('%-6d %-8.2f %-10.2f %-10.2f %-10.2f %-6s\n', ...
            i, durations(i), earliest(i), latest(i), slack(i), flag);
end
end

%% Self-test
function self_test()
% Input validation
arguments
    data (:,:) double
end
    % Test with 3-activity project: 1→2, 1→3
    dur = [3; 2; 4];
    dep = [1 2; 1 3];  % edge list
    [e, l, s, cp, m] = critical_path([], dur, dep);
    assert(abs(m - 7) < 1e-6, 'Test failed: makespan should be 7 (1→3=3+4).');
    assert(length(cp) >= 2, 'Test failed: should have at least 2 critical activities.');
    disp('critical_path self-test passed.');
end
