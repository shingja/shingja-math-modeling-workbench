% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [score, lower_score, upper_score, ranking] = interval_evaluation(data_matrix, varargin)
%INTERVAL_EVALUATION 区间数综合评价 (Interval Number Evaluation)
%   处理指标值为区间数 [下界, 上界] 的多方案评价问题。
%   支持: 区间AHP、区间TOPSIS、区间VIKOR 三种方法。
%
%   Source: 徐泽水 (2004). 不确定多属性决策方法及应用. 清华大学出版社.
%   Author: Adapted by MathModelingSkill
%   License: MIT
%   Verified: 2026-07-27
%
%   输入:
%       data_matrix - 区间数据 (n_objects × n_indicators × 2)
%                     (:,:,1) = 区间下界, (:,:,2) = 区间上界
%                     data_matrix(i,j,:) = [lower, upper]
%
%   可选参数:
%       'Method'    - 评价方法 (默认: 'TOPSIS')
%                     'TOPSIS' | 'VIKOR' | 'weighted_sum'
%       'Weights'   - 权重向量 (1×n_indicators, 默认: 等权)
%                     支持区间权重: (1×n_indicators×2) 或 点值 (1×n_indicators)
%       'Direction' - 指标方向 (1×n_indicators), +1高优/-1低优 (默认: +1)
%
%   输出:
%       score       - 综合得分 (n_objects×1, 点估计)
%       lower_score - 得分下界
%       upper_score - 得分上界
%       ranking     - 排序 (1=最优), 按可能度矩阵排序
%
%   示例:
%       % 3方案, 2指标, 区间数据
%       data(:,:,1) = [60 80; 70 75; 55 90];  % 下界
%       data(:,:,2) = [70 85; 80 82; 65 95];  % 上界
%       [score, lo, hi, rank] = interval_evaluation(data, 'Method', 'TOPSIS');

%% 依赖检查
% 仅使用 MATLAB 内置函数

[n_objects, n_indicators, ~] = size(data_matrix);

if size(data_matrix, 3) ~= 2
    error('data_matrix 必须是 n×m×2 数组: (:,:,1)=下界, (:,:,2)=上界');
end

L = data_matrix(:, :, 1);  % 下界矩阵
U = data_matrix(:, :, 2);  % 上界矩阵

% 验证: 下界 <= 上界
if any(L(:) > U(:))
    warning('存在下界 > 上界的数据点, 已自动交换。');
    for i = 1:n_objects
        for j = 1:n_indicators
            if L(i,j) > U(i,j)
                tmp = L(i,j); L(i,j) = U(i,j); U(i,j) = tmp;
            end
        end
    end
end

%% 参数解析
p = inputParser;
p.addParameter('Method', 'TOPSIS', @(v) any(strcmp(v, {'TOPSIS', 'VIKOR', 'weighted_sum'})));
p.addParameter('Weights', ones(1, n_indicators) / n_indicators);
p.addParameter('Direction', ones(1, n_indicators));
p.parse(varargin{:});
opts = p.Results;

% 权重处理
if ndims(opts.Weights) == 3 && size(opts.Weights, 3) == 2
    w_lower = opts.Weights(:, :, 1);
    w_upper = opts.Weights(:, :, 2);
else
    w_lower = opts.Weights(:)';
    w_upper = opts.Weights(:)';
end

direction = opts.Direction(:)';

%% Step 1: 区间正向化与归一化
% 确定每个指标的正理想点 (最大值上界) 和负理想点 (最小值下界)
best = zeros(1, n_indicators);
worst = zeros(1, n_indicators);

for j = 1:n_indicators
    if direction(j) == 1
        best(j) = max(U(:, j));
        worst(j) = min(L(:, j));
    else
        best(j) = min(L(:, j));
        worst(j) = max(U(:, j));
    end
end

% 区间归一化: 除以 (best - worst)
range = best - worst;
range(range < 1e-10) = 1;

L_norm = zeros(n_objects, n_indicators);
U_norm = zeros(n_objects, n_indicators);

for j = 1:n_indicators
    if direction(j) == 1
        L_norm(:, j) = (L(:, j) - worst(j)) ./ range(j);
        U_norm(:, j) = (U(:, j) - worst(j)) ./ range(j);
    else
        % 逆向指标: 反向归一化
        L_norm(:, j) = (best(j) - U(:, j)) ./ range(j);
        U_norm(:, j) = (best(j) - L(:, j)) ./ range(j);
    end
end

% 确保在 [0,1] 区间内
L_norm = max(0, min(1, L_norm));
U_norm = max(0, min(1, U_norm));

%% Step 2: 根据方法计算得分区间
lower_score = zeros(n_objects, 1);
upper_score = zeros(n_objects, 1);

switch opts.Method
    case 'weighted_sum'
        % 区间加权和
        for i = 1:n_objects
            lower_score(i) = sum(w_lower .* L_norm(i, :));
            upper_score(i) = sum(w_upper .* U_norm(i, :));
        end

    case 'TOPSIS'
        % 区间TOPSIS: 计算到正/负理想解的区间距离
        pos_ideal = ones(1, n_indicators);   % 归一化后正理想=[1,1,...,1]
        neg_ideal = zeros(1, n_indicators);  % 归一化后负理想=[0,0,...,0]

        d_pos_lower = zeros(n_objects, 1);
        d_pos_upper = zeros(n_objects, 1);
        d_neg_lower = zeros(n_objects, 1);
        d_neg_upper = zeros(n_objects, 1);

        for i = 1:n_objects
            % 到正理想的距离 (区间)
            d_pos_low = sqrt(sum(w_lower .* (max(0, pos_ideal - U_norm(i, :))).^2));
            d_pos_up  = sqrt(sum(w_upper .* (max(0, pos_ideal - L_norm(i, :))).^2));
            d_pos_lower(i) = min(d_pos_low, d_pos_up);
            d_pos_upper(i) = max(d_pos_low, d_pos_up);

            % 到负理想的距离 (区间)
            d_neg_low = sqrt(sum(w_lower .* (max(0, L_norm(i, :) - neg_ideal)).^2));
            d_neg_up  = sqrt(sum(w_upper .* (max(0, U_norm(i, :) - neg_ideal)).^2));
            d_neg_lower(i) = min(d_neg_low, d_neg_up);
            d_neg_upper(i) = max(d_neg_low, d_neg_up);
        end

        % 贴近度
        lower_score = d_neg_lower ./ (d_neg_upper + d_pos_upper + 1e-10);
        upper_score = d_neg_upper ./ (d_neg_lower + d_pos_lower + 1e-10);

    case 'VIKOR'
        % 区间VIKOR
        best_all = ones(1, n_indicators);
        worst_all = zeros(1, n_indicators);

        S_lower = zeros(n_objects, 1);
        S_upper = zeros(n_objects, 1);
        R_lower = zeros(n_objects, 1);
        R_upper = zeros(n_objects, 1);

        for i = 1:n_objects
            S_i_low = sum(w_lower .* (best_all - U_norm(i, :)) ./ (best_all - worst_all + 1e-10));
            S_i_up  = sum(w_upper .* (best_all - L_norm(i, :)) ./ (best_all - worst_all + 1e-10));
            S_lower(i) = min(S_i_low, S_i_up);
            S_upper(i) = max(S_i_low, S_i_up);

            R_i_low = max(w_lower .* (best_all - U_norm(i, :)) ./ (best_all - worst_all + 1e-10));
            R_i_up  = max(w_upper .* (best_all - L_norm(i, :)) ./ (best_all - worst_all + 1e-10));
            R_lower(i) = min(R_i_low, R_i_up);
            R_upper(i) = max(R_i_low, R_i_up);
        end

        % 计算 Q 值 (v=0.5 折中)
        v = 0.5;
        S_star = min(S_lower); S_minus = max(S_upper);
        R_star = min(R_lower); R_minus = max(R_upper);

        for i = 1:n_objects
            Q_low = v * (S_lower(i) - S_star) / (S_minus - S_star + 1e-10) + ...
                    (1-v) * (R_lower(i) - R_star) / (R_minus - R_star + 1e-10);
            Q_up  = v * (S_upper(i) - S_star) / (S_minus - S_star + 1e-10) + ...
                    (1-v) * (R_upper(i) - R_star) / (R_minus - R_star + 1e-10);
            lower_score(i) = min(Q_low, Q_up);
            upper_score(i) = max(Q_low, Q_up);
        end
end

%% Step 3: 可能度排序 (Possibility Degree Matrix)
% 基于区间数 [a_i, b_i] 与 [a_j, b_j] 的可能度
P = zeros(n_objects, n_objects);

for i = 1:n_objects
    for j = 1:n_objects
        if i == j
            P(i, j) = 0.5;
        else
            L_i = lower_score(i); U_i = upper_score(i);
            L_j = lower_score(j); U_j = upper_score(j);

            len_i = U_i - L_i;
            len_j = U_j - L_j;

            if U_i <= L_j
                P(i, j) = 0;
            elseif U_j <= L_i
                P(i, j) = 1;
            else
                % 区间重叠情况
                if len_i == 0 && len_j == 0
                    P(i, j) = double(L_i > L_j);
                else
                    overlap = min(U_i, U_j) - max(L_i, L_j);
                    P(i, j) = max(0, U_i - L_j) / (len_i + len_j + 1e-10);
                    P(i, j) = max(0, min(1, P(i, j)));
                end
            end
        end
    end
end

% 排序值 = 平均可能度
score = mean(P, 2);

% 按得分降序排名
[~, rank_idx] = sort(score, 'descend');
ranking = zeros(n_objects, 1);
for r = 1:n_objects
    ranking(rank_idx(r)) = r;
end

%% 输出摘要
fprintf('\n=== 区间数评价 (%s) ===\n', opts.Method);
fprintf('%-8s %-12s %-12s %-10s %-8s\n', '方案', '得分下界', '得分上界', '综合得分', '排名');
fprintf('%s\n', repmat('-', 1, 52));
for i = 1:n_objects
    fprintf('%-8d %-12.4f %-12.4f %-10.4f %-8d\n', ...
            i, lower_score(i), upper_score(i), score(i), ranking(i));
end
end

%% Exit status
exitflag = 1;  %% normal termination

%% Self-test
function self_test()
    % Test with 2-alternative interval data
    data = zeros(2, 2, 2);
    data(:,:,1) = [60 80; 70 75];  % lower bounds
    data(:,:,2) = [70 90; 80 85];  % upper bounds
    [score, lo, hi, ranking] = interval_evaluation(data, 'Method', 'weighted_sum');
    assert(length(score) == 2, 'Test failed: score should have 2 entries.');
    assert(all(lo <= hi), 'Test failed: lower scores should not exceed upper scores.');
    disp('interval_evaluation self-test passed.');
end
