% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pass, report] = W1_writing_check(project_root)
%% W1_WRITING_CHECK Gate W1: writing quality audit (8 dimensions). v3.0.0.
%  D1: Abstract <= 1 page (~3000 chars mixed CN/EN)
%  D2: Abstract has NO standalone English paragraphs (>50 char runs)
%  D3: Each sub-problem section has method->solve->numerical result
%  D4: Numerical format: 4 sig-digits / % 2 decimals / p 3 decimals
%  D5: NO school/name/region keywords in body (blacklist, excl. references)
%  D6: >= 8 figures (count \includegraphics + subfigure environments)
%  D7: >= 1 reference entry with DOI
%  D8: No placeholder text ([待补充], TODO, TBD, XXX, 占位)
arguments
    project_root (1,:) char = pwd
end

% Locate the main .tex source file
main_tex = find_main_tex(project_root);
if isempty(main_tex)
    error('W1:NoTexFile', 'No .tex source file found in %s', project_root);
end
tex_content = fileread(main_tex);
report = struct();

%% D1: Abstract page budget
report.D1 = d1_abstract_length(tex_content);

%% D2: Abstract English-purity
report.D2 = d2_abstract_english(tex_content);

%% D3: Method-solve-result per section
report.D3 = d3_method_solve_result(tex_content);

%% D4: Numerical format compliance
report.D4 = d4_numerical_format(tex_content);

%% D5: Identity keyword blacklist (body only)
report.D5 = d5_identity_blacklist(tex_content);

%% D6: Figure count >= 8
report.D6 = d6_figure_count(tex_content);

%% D7: At least one DOI
report.D7 = d7_doi_presence(tex_content);

%% D8: No placeholder text
report.D8 = d8_no_placeholders(tex_content);

%% Aggregate
dims = {'D1','D2','D3','D4','D5','D6','D7','D8'};
all_pass = true;
for k = 1:numel(dims)
    all_pass = all_pass && report.(dims{k}).pass;
end
pass = all_pass;
report.overall_pass = pass;
report.timestamp = char(datetime);

% Persist report
results_dir = fullfile(project_root, 'results');
if ~isfolder(results_dir), mkdir(results_dir); end
fid = fopen(fullfile(results_dir, 'W1_gate_report.json'), 'w');
fprintf(fid, '%s', jsonencode(report)); fclose(fid);
end

% -------------------------------------------------------------------------
%  Helpers
% -------------------------------------------------------------------------

function main_tex = find_main_tex(project_root)
%% Scan directory tree for candidate main .tex file.
tex_files = dir(fullfile(project_root, '**', '*.tex'));
candidates = {};
for i = 1:numel(tex_files)
    fpath = fullfile(tex_files(i).folder, tex_files(i).name);
    content = fileread(fpath);
    if contains(content, '\documentclass') || contains(content, '\begin{document}')
        candidates{end+1} = fpath; %#ok<AGROW>
    end
end
if isempty(candidates)
    main_tex = '';
    return;
end
% Prefer canonical names
canonical = {'main','paper','article','manuscript','modeling','model','body'};
for i = 1:numel(candidates)
    [~, fname] = fileparts(candidates{i});
    if any(strcmpi(fname, canonical))
        main_tex = candidates{i};
        return;
    end
end
main_tex = candidates{1};
end

function [txt, found] = extract_abstract(tex_content)
%% Pull abstract body from LaTeX source.
found = false;  txt = '';
% Standard environment
m = regexp(tex_content, '\\begin\{abstract\}(.*?)\\end\{abstract\}', 'tokens', 'dotexceptnewline');
if ~isempty(m), txt = strtrim(m{1}{1}); found = true; return; end
% \abstract{...}  macro
m = regexp(tex_content, '\\abstract\{(.*?)\}', 'tokens', 'dotexceptnewline');
if ~isempty(m), txt = strtrim(m{1}{1}); found = true; return; end
% Chinese  摘要  section
m = regexp(tex_content, '摘\s*要\s*([\s\S]*?)(?=\\section|\\subsection|$)', 'tokens', 'once');
if ~isempty(m), txt = strtrim(m{1}); found = true; return; end
end

% -------------------------------------------------------------------------
%  D1 – abstract page budget
% -------------------------------------------------------------------------
function res = d1_abstract_length(tex_content)
%% Abstract should fit one page (~3000 mixed-script chars).
[abstract_text, found] = extract_abstract(tex_content);
if ~found
    res = struct('pass', true, ...
        'detail', 'No abstract found – neutral pass', 'page_est', 0);
    return;
end
page_est = numel(abstract_text) / 3000;
res = struct('pass', page_est <= 1.05, ...
    'detail', sprintf('Abstract est. %.2f pages (%d chars)', page_est, numel(abstract_text)), ...
    'page_est', page_est);
end

% -------------------------------------------------------------------------
%  D2 – abstract English-purity
% -------------------------------------------------------------------------
function res = d2_abstract_english(tex_content)
%% Abstract must NOT contain standalone English runs > 50 chars.
[abstract_text, found] = extract_abstract(tex_content);
if ~found
    res = struct('pass', true, ...
        'detail', 'No abstract found – neutral pass', ...
        'english_segments', {{}});
    return;
end
% Strip LaTeX commands and math
cleaned = regexprep(abstract_text, '\\([a-zA-Z@]+)(\{[^}]*\})*', ' ');
cleaned = regexprep(cleaned, '\$[^$]*\$', ' ');
cleaned = regexprep(cleaned, '\\[a-zA-Z@]+\{[^}]*\}', ' ');
% Find runs of pure English (letters + spaces + punctuation) > 50 chars
eng_runs = regexp(cleaned, '[A-Za-z][A-Za-z\s,.;:!?\-''"]{50,}', 'match');
pass = isempty(eng_runs);
if pass
    detail = 'No long English paragraphs in abstract';
else
    detail = sprintf('Found %d English segment(s) > 50 chars', numel(eng_runs));
end
res = struct('pass', pass, 'detail', detail, ...
    'english_segments', {eng_runs});
end

% -------------------------------------------------------------------------
%  D3 – method->solve->numerical result per sub-problem
% -------------------------------------------------------------------------
function res = d3_method_solve_result(tex_content)
%% Each sub-problem section must have method keywords AND numeric results.
method_kw = {'方法','模型','算法','模型建立','模型求解', ...
             'method','model','algorithm','approach','framework'};
number_re = '\d+\.?\d*([eE][+-]?\d+)?';

% Split by problem markers (common in CUMCM papers)
splits = regexp(tex_content, '(问题\s*[一二三四五六七八九十\d]+)', 'split');
if numel(splits) < 2
    % Fall back to section splits
    splits = regexp(tex_content, '\\section\{[^}]*\}', 'split');
end
if numel(splits) < 2
    splits = {tex_content};  % single block
end

n_checked = 0;
n_passed  = 0;
for i = 1:numel(splits)
    sec = splits{i};
    if numel(sec) < 80, continue; end
    has_method = false;
    for k = 1:numel(method_kw)
        if contains(sec, method_kw{k})
            has_method = true;
            break;
        end
    end
    if ~has_method, continue; end
    n_checked = n_checked + 1;
    has_number = ~isempty(regexp(sec, number_re, 'once'));
    if has_number, n_passed = n_passed + 1; end
end

if n_checked == 0
    res = struct('pass', false, ...
        'detail', 'No sections found with method keywords', ...
        'sections_checked', 0, 'sections_passed', 0);
    return;
end
pass = n_passed >= n_checked;
res = struct('pass', pass, ...
    'detail', sprintf('%d/%d method-sections have numeric results', n_passed, n_checked), ...
    'sections_checked', n_checked, 'sections_passed', n_passed);
end

% -------------------------------------------------------------------------
%  D4 – numerical format
% -------------------------------------------------------------------------
function res = d4_numerical_format(tex_content)
%% Flag p-values with <3 decimals, excessive precision >4 decimals.
issues = {};

% p-value check: p = 0.05 or p < 0.05  (1-2 decimals → bad)
% (don't flag p = 0.050 or inside math mode)
p_raw = regexp(tex_content, '(?i)p\s*[<>≤≥=]\s*0\.\d+', 'match');
p_bad = {};
for i = 1:numel(p_raw)
    pv = p_raw{i};
    dec = regexp(pv, '\.(\d+)', 'tokens', 'once');
    if ~isempty(dec) && numel(dec{1}) < 3
        % Exclude if followed by another digit (e.g. 0.050 has 2 before 0)
        if numel(dec{1}) == 1 || numel(dec{1}) == 2
            p_bad{end+1} = pv; %#ok<AGROW>
        end
    end
end
if ~isempty(p_bad)
    issues{end+1} = sprintf('%d p-value(s) with <3 decimal places', numel(p_bad));
end

% Excessive precision: numbers with >=5 decimal places
excess = regexp(tex_content, '(?<!\d)\d+\.\d{5,}(?!\d)', 'match');
if ~isempty(excess)
    issues{end+1} = sprintf('%d number(s) with >=5 decimal places', numel(excess));
end

% Percentages: look for 1-decimal percentages (e.g. 12.3% → should be 12.30%)
pct_raw = regexp(tex_content, '\d+\.\d{1}%', 'match');
if ~isempty(pct_raw)
    issues{end+1} = sprintf('%d percentage(s) with only 1 decimal (want 2)', numel(pct_raw));
end

pass = isempty(issues);
if pass
    detail = 'Numerical format appears compliant';
else
    detail = strjoin(issues, '; ');
end
res = struct('pass', pass, 'detail', detail, ...
    'issues', {issues}, 'pval_issues', {p_bad}, ...
    'excessive_precision', {excess});
end

% -------------------------------------------------------------------------
%  D5 – identity keyword blacklist
% -------------------------------------------------------------------------
function res = d5_identity_blacklist(tex_content)
%% Scan body text (excl. references) for school/name/region keywords.
blacklist = {'大学','学院','学校','姓名','指导','教师', ...
             '省\s*[市区县]','[省市区县](?!\s*[\w]*\s*[=:：]\s*\d)'};

% Strip everything after 参考文献 / References / \begin{thebibliography}
ref_marker = regexpi(tex_content, ...
    ['(\\section\*?\{[^}]*参[^}]*\}|' ...
     '\\section\*?\{[^}]*[Rr]eference[^}]*\}|' ...
     '\\begin\{thebibliography\})'], 'once');
if ~isempty(ref_marker)
    body_text = extractBefore(tex_content, ref_marker);
else
    body_text = tex_content;
end

findings = {};
for i = 1:numel(blacklist)
    m = regexp(body_text, blacklist{i}, 'match');
    findings = [findings, m]; %#ok<AGROW>
end

pass = isempty(findings);
if pass
    detail = 'No identity-revealing keywords in body text';
else
    detail = sprintf('Identity keywords found: %s', strjoin(unique(findings), ', '));
end
res = struct('pass', pass, 'detail', detail, 'findings', {unique(findings)});
end

% -------------------------------------------------------------------------
%  D6 – figure count >= 8
% -------------------------------------------------------------------------
function res = d6_figure_count(tex_content)
%% Count includegraphics + figure environments.
n_include = numel(regexp(tex_content, '\\includegraphics', 'match'));
n_fig_env = numel(regexp(tex_content, '\\begin\{figure\}', 'match'));
n_fig_star = numel(regexp(tex_content, '\\begin\{figure\*\}', 'match'));
n_subfig  = numel(regexp(tex_content, '\\begin\{subfigure\}', 'match'));
n_total = max(n_include, n_fig_env + n_fig_star) + n_subfig;
pass = n_total >= 8;
if pass
    detail = sprintf('Found %d figures (>=8 required)', n_total);
else
    detail = sprintf('Only %d figures found (need >=8)', n_total);
end
res = struct('pass', pass, 'detail', detail, 'figure_count', n_total);
end

% -------------------------------------------------------------------------
%  D7 – DOI presence
% -------------------------------------------------------------------------
function res = d7_doi_presence(tex_content)
%% Count DOI entries in references.
n_doi_cmd  = numel(regexpi(tex_content, '\\doi\{[^}]+\}', 'match'));
n_doi_text = numel(regexpi(tex_content, 'DOI[:\s]*10\.\d{4,}/[^\s,;}]+', 'match'));
n_doi      = n_doi_cmd + n_doi_text;
pass = n_doi >= 1;
if pass
    detail = sprintf('Found %d DOI reference(s)', n_doi);
else
    detail = 'No DOI found in references';
end
res = struct('pass', pass, 'detail', detail, 'doi_count', n_doi);
end

% -------------------------------------------------------------------------
%  D8 – placeholder text
% -------------------------------------------------------------------------
function res = d8_no_placeholders(tex_content)
%% Flag placeholder tokens.
tokens = {'[待补充]','TODO','TBD','XXX','待填','占位','PLACEHOLDER'};
findings = {};
for i = 1:numel(tokens)
    if contains(tex_content, tokens{i}, 'IgnoreCase', true)
        findings{end+1} = tokens{i}; %#ok<AGROW>
    end
end
pass = isempty(findings);
if pass
    detail = 'No placeholder text found';
else
    detail = sprintf('Placeholder text found: %s', strjoin(findings, ', '));
end
res = struct('pass', pass, 'detail', detail, 'findings', {findings});
end

% =========================================================================
%% Self-test
function self_test()
%% Build a pass-clean project and a violation project; verify dimensions.
rng(42);

% -- PASS project ---------------------------------------------------------
tmp_pass = fullfile(tempdir, 'w1_test_pass');
if isfolder(tmp_pass), rmdir(tmp_pass, 's'); end
mkdir(tmp_pass);

tex_pass = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{graphicx}\n' ...
    '\\usepackage{hyperref}\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '\\begin{abstract}\n' ...
    '本文针对复杂系统的多目标优化问题，建立了基于改进粒子群算法的数学规划模型。\n' ...
    '通过对约束条件的松弛处理，将原问题转化为可求解的凸优化形式。\n' ...
    '数值实验表明，所提方法在收敛速度和解的质量上均有显著提升。\n' ...
    '\\end{abstract}\n' ...
    '\n' ...
    '\\section{问题一：资源分配模型}\n' ...
    '本文采用线性规划方法建立资源分配模型。通过引入松弛变量，\n' ...
    '将约束条件转化为等式约束，利用单纯形法求解得到最优分配方案。\n' ...
    '数值结果显示，最优总成本为 1234.6 万元，资源利用率为 87.34\\%。\n' ...
    '\n' ...
    '\\section{问题二：调度优化模型}\n' ...
    '针对多阶段调度问题，建立了混合整数规划模型。采用分支定界算法\n' ...
    '进行求解，结合启发式规则加速收敛。计算结果表明，\n' ...
    '总完工时间从 45.7 h 缩短至 32.15 h，效率提升 29.8\\%。\n' ...
    '\n' ...
    '\\section{问题三：鲁棒优化模型}\n' ...
    '考虑参数不确定性，构建了基于场景的鲁棒优化模型。\n' ...
    '利用对偶理论将鲁棒对应式转化为可求解的线性规划问题。\n' ...
    '蒙特卡洛模拟验证了模型的鲁棒性，期望成本为 876.54 万元。\n' ...
    '\n' ...
    '\\section{问题四：综合评价模型}\n' ...
    '构建了基于熵权-TOPSIS的综合评价模型。通过信息熵确定指标权重，\n' ...
    '结合逼近理想解排序法进行方案优选。最终评价得分为 0.8234，\n' ...
    '验证了模型的有效性和合理性。\n' ...
    '\n'];
% Add 8 figures (D6)
for j = 1:8
    tex_pass = [tex_pass, ...
        sprintf('\\begin{figure}\n\\centering\n\\includegraphics[width=0.8\\textwidth]{fig%d.png}\n', j), ...
        sprintf('\\caption{图 %d}\n\\end{figure}\n', j)]; %#ok<AGROW>
end

% References with DOI (D7)
tex_pass = [tex_pass, ...
    '\n\\begin{thebibliography}{99}\n' ...
    '\\bibitem{ref1} Author A. Title. \\textit{Journal}, 2020. DOI:10.1234/abcde.2020.001\n' ...
    '\\bibitem{ref2} 张三, 李四. 优化方法研究. \\textit{运筹学学报}, 2019.\n' ...
    '\\end{thebibliography}\n' ...
    '\n\\end{document}\n'];

fid = fopen(fullfile(tmp_pass, 'main.tex'), 'w');
fprintf(fid, '%s', tex_pass); fclose(fid);

[p1, r1] = W1_writing_check(tmp_pass);
assert(p1, 'Clean project should pass W1 entirely');
assert(r1.D1.pass, 'D1 (abstract page): should pass');
assert(r1.D6.pass, 'D6 (figure count >=8): should pass');
assert(r1.D7.pass, 'D7 (DOI): should pass');
assert(r1.D8.pass, 'D8 (no placeholders): should pass');
assert(r1.D5.pass, 'D5 (no identity): should pass');

% -- VIOLATION project ----------------------------------------------------
tmp_fail = fullfile(tempdir, 'w1_test_fail');
if isfolder(tmp_fail), rmdir(tmp_fail, 's'); end
mkdir(tmp_fail);

tex_fail = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{graphicx}\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '\\begin{abstract}\n' ...
    'This paper presents a comprehensive framework for multi-objective optimization. ' ...
    'We propose a novel hybrid algorithm that combines particle swarm optimization ' ...
    'with genetic algorithms to achieve superior convergence properties. ' ...
    'The experimental results demonstrate the effectiveness of our approach. [待补充]\n' ...
    '\\end{abstract}\n' ...
    '\n' ...
    '\\section{问题一}\n' ...
    '本文采用线性规划方法建立资源分配模型，由北京大学数学科学学院提供支持。\n' ...
    '指导教师：王教授。求解结果为 123.45678 万元。\n' ...
    '\\begin{figure}\n\\includegraphics{fig.png}\n\\end{figure}\n' ...
    '\n' ...
    '\\begin{thebibliography}{99}\n' ...
    '\\bibitem{ref1} Author. Title. Journal, 2020.\n' ...
    '\\end{thebibliography}\n' ...
    '\n\\end{document}\n'];

fid = fopen(fullfile(tmp_fail, 'main.tex'), 'w');
fprintf(fid, '%s', tex_fail); fclose(fid);

[p2, r2] = W1_writing_check(tmp_fail);
assert(~p2, 'Violation project should NOT pass W1');
assert(~r2.D5.pass, 'D5: should detect 北京大学 on body');
assert(~r2.D6.pass, 'D6: only 1 figure, should fail (<8)');
assert(~r2.D8.pass, 'D8: should detect [待补充] placeholder');

% D2: the English abstract paragraph should be detected
assert(~r2.D2.pass, 'D2: should detect English paragraph in abstract');

disp('W1_writing_check self-test passed.');
end
