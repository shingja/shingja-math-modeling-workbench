% 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
function [pass, report] = W2_format_check(project_root, varargin)
%% W2_FORMAT_CHECK Gate W2: format compliance audit (10 dimensions). v3.0.0.
%  双模式 (2026 规范):
%   --mode electronic (默认, 电子版): 首页=摘要页, 无承诺书/编号页, 页码从摘要页起1
%   --mode paper     (纸质版): 承诺书 → 编号页 → 摘要页
%  调用方式:
%   W2_format_check(root)                       % electronic
%   W2_format_check(root, '--mode', 'paper')    % paper
%   W2_format_check(root, 'paper')              % paper (简写)
%   W2_format_check(root, mode='paper')         % paper (name-value)
%
%  electronic 模式:
%  D1 : Page 1 = 摘要页 (含摘要标记且无承诺书)
%  D2 : 全文无承诺书/编号专用页
%  D3 : Page 1 contains abstract environment
%  paper 模式:
%  D1 : Page 1 contains  承诺书  keyword
%  D2 : Page 2 contains  编号  keyword
%  D3 : Page 3 contains abstract environment
%  D4 : Page numbering starts=1 from abstract page (两模式一致)
%  D5 : NO page headers (no \pagestyle{fancy} / no running header)
%  D6 : Appendix contains .m source code listings
%  D7 : Three-line tables present (\toprule\midrule\bottomrule)
%  D8 : Body <= 30 pages (after abstract to before appendix)
%  D9 : No school/name/region identity on ANY page
%  D10: File size <= 20 MB (compiled PDF)
if nargin < 1 || isempty(project_root), project_root = pwd; end
mode = parse_mode(varargin{:});
report = struct();
report.mode = mode;

% Locate main tex + any PDF companion
main_tex = find_main_tex(project_root);
if isempty(main_tex)
    error('W2:NoTexFile', 'No .tex source file found in %s', project_root);
end
tex_content = fileread(main_tex);
% Also read companion tex files (appendix, etc.)
tex_files = collect_tex_files(project_root, main_tex);
all_tex = tex_content;
for i = 1:numel(tex_files)
    all_tex = [all_tex, newline, fileread(tex_files{i})]; %#ok<AGROW>
end

% Try to find compiled PDF
pdf_path = find_pdf(project_root);
pdf_size_mb = 0;
if ~isempty(pdf_path)
    d = dir(pdf_path);
    pdf_size_mb = d.bytes / (1024^2);
end

%% D1: Page 1 – 承诺书 (paper) / 首页=摘要页 (electronic)
report.D1 = d1_commitment_page(tex_content, mode);

%% D2: Page 2 – 编号 (paper) / 无承诺书编号页 (electronic)
report.D2 = d2_number_page(tex_content, mode);

%% D3: Abstract page (paper: page 3; electronic: page 1)
report.D3 = d3_abstract_page(tex_content, mode);

%% D4: Page numbering starts from abstract
report.D4 = d4_page_numbering(tex_content);

%% D5: No page headers
report.D5 = d5_no_page_headers(tex_content);

%% D6: Appendix with .m source code
report.D6 = d6_appendix_code(all_tex);

%% D7: Three-line tables
report.D7 = d7_three_line_tables(all_tex);

%% D8: Body <= 30 pages
report.D8 = d8_body_page_limit(all_tex, tex_content);

%% D9: No identity (all pages)
report.D9 = d9_no_identity_all(all_tex);

%% D10: File size <= 20 MB
report.D10 = d10_file_size(pdf_size_mb, pdf_path);

%% Aggregate
dims = {'D1','D2','D3','D4','D5','D6','D7','D8','D9','D10'};
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
fid = fopen(fullfile(results_dir, 'W2_gate_report.json'), 'w');
fprintf(fid, '%s', jsonencode(report)); fclose(fid);
end

% -------------------------------------------------------------------------
%  Helpers
% -------------------------------------------------------------------------

function mode = parse_mode(varargin)
%% Parse --mode electronic|paper (plus 'mode' name-value and bare shorthand).
mode = 'electronic';
i = 1;
while i <= numel(varargin)
    arg = varargin{i};
    if isstring(arg), arg = char(arg); end
    if ischar(arg)
        if strcmpi(arg, '--mode') || strcmpi(arg, 'mode')
            if i + 1 > numel(varargin)
                error('W2:ArgParse', '--mode requires a value: electronic | paper');
            end
            mode = char(varargin{i+1}); i = i + 1;
        elseif strcmpi(arg, 'electronic') || strcmpi(arg, 'paper')
            mode = lower(arg);
        else
            error('W2:ArgParse', 'Unknown option "%s" (expected --mode electronic|paper)', arg);
        end
    elseif isstruct(arg) && isfield(arg, 'mode')
        mode = char(arg.mode);
    end
    i = i + 1;
end
mode = lower(mode);
if ~ismember(mode, {'electronic', 'paper'})
    error('W2:ArgParse', 'mode must be "electronic" or "paper", got "%s"', mode);
end
end

function main_tex = find_main_tex(project_root)
tex_files = dir(fullfile(project_root, '**', '*.tex'));
candidates = {};
for i = 1:numel(tex_files)
    c = fileread(fullfile(tex_files(i).folder, tex_files(i).name));
    if contains(c, '\documentclass') || contains(c, '\begin{document}')
        candidates{end+1} = fullfile(tex_files(i).folder, tex_files(i).name); %#ok<AGROW>
    end
end
if isempty(candidates), main_tex = ''; return; end
canonical = {'main','paper','article','manuscript','modeling','model','body'};
for i = 1:numel(candidates)
    [~, fname] = fileparts(candidates{i});
    if any(strcmpi(fname, canonical)), main_tex = candidates{i}; return; end
end
main_tex = candidates{1};
end

function tex_files = collect_tex_files(project_root, main_tex)
%% Gather \input/\include -ed tex files.
tex_files = {};
% Extract \input{...} and \include{...} targets
[main_dir, ~] = fileparts(main_tex);
candidates = [regexp(fileread(main_tex), '\\input\{([^}]+)\}', 'tokens'), ...
              regexp(fileread(main_tex), '\\include\{([^}]+)\}', 'tokens')];
for i = 1:numel(candidates)
    fname = candidates{i}{1};
    if ~endsWith(fname, '.tex'), fname = [fname, '.tex']; end
    fpath = fullfile(main_dir, fname);
    % Also search project_root if not found
    if ~isfile(fpath)
        fpath = fullfile(project_root, fname);
    end
    if isfile(fpath)
        tex_files{end+1} = fpath; %#ok<AGROW>
    end
end
end

function pdf_path = find_pdf(project_root)
%% Locate compiled PDF in project tree.
pdfs = dir(fullfile(project_root, '**', '*.pdf'));
for i = 1:numel(pdfs)
    pdf_path = fullfile(pdfs(i).folder, pdfs(i).name);
    return;
end
pdf_path = '';
end

function pages = split_pages(tex_content)
%% Split tex content at explicit page-break commands.
% Returns cell array of page text blocks.
markers = regexp(tex_content, '(\\newpage|\\clearpage|\\cleardoublepage)', 'split');
pages = markers;
end

% -------------------------------------------------------------------------
%  D1 – Page 1: 承诺书 (paper) / 摘要页 (electronic)
% -------------------------------------------------------------------------
function res = d1_commitment_page(tex_content, mode)
pages = split_pages(tex_content);
if numel(pages) < 1
    res = struct('pass', false, 'detail', 'Cannot identify page breaks');
    return;
end
page1 = pages{1};
if strcmp(mode, 'paper')
    pass = contains(page1, '承诺书');
    if pass
        detail = '承诺书 found on page 1';
    else
        detail = '承诺书 NOT found on page 1';
    end
else % electronic: 首页=摘要页, 无承诺书
    has_abstract = contains(page1, '\begin{abstract}') || ...
                   contains(page1, '摘要') || contains(page1, 'Abstract');
    has_commitment = contains(page1, '承诺书');
    pass = has_abstract && ~has_commitment;
    if pass
        detail = 'Electronic: page 1 is abstract page (no 承诺书)';
    elseif has_commitment
        detail = 'Electronic: page 1 contains 承诺书 – must be abstract page';
    else
        detail = 'Electronic: page 1 has no abstract markers (摘要/Abstract/\begin{abstract})';
    end
end
res = struct('pass', pass, 'detail', detail);
end

% -------------------------------------------------------------------------
%  D2 – Page 2: 编号 (paper) / 无承诺书编号页 (electronic)
% -------------------------------------------------------------------------
function res = d2_number_page(tex_content, mode)
if strcmp(mode, 'paper')
    pages = split_pages(tex_content);
    if numel(pages) < 2
        res = struct('pass', false, 'detail', 'Less than 2 pages detected');
        return;
    end
    page2 = pages{2};
    pass = contains(page2, '编号');
    if pass
        detail = '编号 found on page 2';
    else
        detail = '编号 NOT found on page 2';
    end
else % electronic: 全文不得出现承诺书/编号专用页
    has_commitment = contains(tex_content, '承诺书');
    has_number = contains(tex_content, '编号');
    pass = ~has_commitment && ~has_number;
    if pass
        detail = 'Electronic: no 承诺书/编号 pages anywhere (OK)';
    else
        issues = {};
        if has_commitment, issues{end+1} = '承诺书'; end
        if has_number, issues{end+1} = '编号'; end
        detail = sprintf('Electronic: forbidden pages found: %s', strjoin(issues, ', '));
    end
end
res = struct('pass', pass, 'detail', detail);
end

% -------------------------------------------------------------------------
%  D3 – Abstract page (paper: page 3; electronic: page 1)
% -------------------------------------------------------------------------
function res = d3_abstract_page(tex_content, mode)
pages = split_pages(tex_content);
page_idx = 3;                                    % paper: 承诺书→编号页→摘要页
if strcmp(mode, 'electronic'), page_idx = 1; end % electronic: 首页=摘要页
if numel(pages) < page_idx
    res = struct('pass', false, 'detail', ...
        sprintf('Less than %d pages detected', page_idx));
    return;
end
page3 = pages{page_idx};
has_abstract_env = contains(page3, '\begin{abstract}');
has_abstract_cn  = contains(page3, '摘要');
has_abstract_en  = contains(page3, 'Abstract');
pass = has_abstract_env || has_abstract_cn || has_abstract_en;
if pass
    detail = sprintf('Abstract found on page %d', page_idx);
else
    detail = sprintf('Abstract NOT found on page %d', page_idx);
end
res = struct('pass', pass, 'detail', detail, ...
    'has_environment', has_abstract_env, ...
    'has_cn_marker', has_abstract_cn, ...
    'has_en_marker', has_abstract_en);
end

% -------------------------------------------------------------------------
%  D4 – Page numbering starts from abstract
% -------------------------------------------------------------------------
function res = d4_page_numbering(tex_content)
%% Check for \setcounter{page}{1} or \pagenumbering{arabic} near abstract.
pass = contains(tex_content, '\setcounter{page}{1}') || ...
       contains(tex_content, '\pagenumbering{arabic}');
if pass
    detail = 'Page numbering reset command found';
else
    detail = 'Missing \setcounter{page}{1} or \pagenumbering{arabic}';
end
res = struct('pass', pass, 'detail', detail);
end

% -------------------------------------------------------------------------
%  D5 – No page headers
% -------------------------------------------------------------------------
function res = d5_no_page_headers(tex_content)
%% Headers must be plain/empty, not fancy with running heads.
has_fancy  = contains(tex_content, '\pagestyle{fancy}');
has_myhead = contains(tex_content, '\pagestyle{myheadings}');
has_header  = contains(tex_content, '\fancyhead');
has_running = contains(tex_content, '\markboth') || contains(tex_content, '\markright');
has_plain   = contains(tex_content, '\pagestyle{plain}') || ...
              contains(tex_content, '\pagestyle{empty}');

pass = ~has_fancy && ~has_myhead && ~has_header && ~has_running;
if pass && has_plain
    detail = 'Page style is plain/empty – no running headers';
elseif pass && ~has_plain
    detail = 'No explicit header commands found (neutral pass)';
else
    issues = {};
    if has_fancy, issues{end+1} = '\pagestyle{fancy}'; end
    if has_myhead, issues{end+1} = '\pagestyle{myheadings}'; end
    if has_header, issues{end+1} = '\fancyhead'; end
    if has_running, issues{end+1} = '\markboth/\markright'; end
    detail = sprintf('Page header commands found: %s', strjoin(issues, ', '));
end
res = struct('pass', pass, 'detail', detail, ...
    'has_fancy', has_fancy, 'has_plain', has_plain);
end

% -------------------------------------------------------------------------
%  D6 – Appendix contains .m source code
% -------------------------------------------------------------------------
function res = d6_appendix_code(tex_content)
%% Check for code-listing commands referencing .m files.
has_lst = ~isempty(regexp(tex_content, '\\lstinputlisting\{[^}]*\.m\}', 'once'));
has_vrb = ~isempty(regexp(tex_content, '\\verbatiminput\{[^}]*\.m\}', 'once'));
has_mcode = ~isempty(regexp(tex_content, '\\begin\{minted\}\{matlab\}', 'once')) || ...
            ~isempty(regexp(tex_content, '\\begin\{lstlisting\}', 'once'));
has_mfile = ~isempty(regexpi(tex_content, '[^\{](\w+\.m)\s*[}\]]', 'once'));
pass = has_lst || has_vrb || has_mcode || has_mfile;
if pass
    detail = 'MATLAB .m source code listing found in appendix';
else
    detail = 'No MATLAB .m code listing found in appendix';
end
res = struct('pass', pass, 'detail', detail, ...
    'lstinputlisting', has_lst, 'verbatiminput', has_vrb, ...
    'minted_lstlisting', has_mcode);
end

% -------------------------------------------------------------------------
%  D7 – Three-line tables
% -------------------------------------------------------------------------
function res = d7_three_line_tables(tex_content)
%% Check for \toprule, \midrule, \bottomrule (booktabs package).
n_top = numel(regexp(tex_content, '\\toprule', 'match'));
n_mid = numel(regexp(tex_content, '\\midrule', 'match'));
n_bot = numel(regexp(tex_content, '\\bottomrule', 'match'));
% All three must appear
pass = n_top >= 1 && n_mid >= 1 && n_bot >= 1;
if pass
    detail = sprintf('Three-line table commands found (top=%d mid=%d bot=%d)', ...
        n_top, n_mid, n_bot);
else
    missing = {};
    if n_top == 0, missing{end+1} = '\toprule'; end
    if n_mid == 0, missing{end+1} = '\midrule'; end
    if n_bot == 0, missing{end+1} = '\bottomrule'; end
    detail = sprintf('Missing: %s', strjoin(missing, ', '));
end
res = struct('pass', pass, 'detail', detail, ...
    'toprule_count', n_top, 'midrule_count', n_mid, 'bottomrule_count', n_bot);
end

% -------------------------------------------------------------------------
%  D8 – Body <= 30 pages
% -------------------------------------------------------------------------
function res = d8_body_page_limit(all_tex, tex_content)
%% Estimate body page count (after abstract to before appendix / bibliography).
% Count explicit \newpage / \clearpage between abstract start and appendix.
abstract_start = regexp(all_tex, '\\begin\{abstract\}', 'once');
if isempty(abstract_start)
    abstract_start = regexp(all_tex, '摘\s*要', 'once');
end
appendix_start = regexp(all_tex, '\\begin\{appendices\}', 'once');
if isempty(appendix_start)
    appendix_start = regexp(all_tex, '\\appendix', 'once');
end
if isempty(appendix_start)
    appendix_start = regexp(all_tex, '\\section\{[^}]*[Aa]ppendix', 'once');
end
ref_start = regexp(all_tex, '\\begin\{thebibliography\}', 'once');
if isempty(ref_start)
    ref_start = regexp(all_tex, '\\section\{[^}]*[Rr]eference', 'once');
end

body_start = min_val(abstract_start, 999999);
body_end   = min_val(min_val(appendix_start, ref_start), numel(all_tex));

if body_start >= body_end
    res = struct('pass', true, 'detail', 'Cannot precisely delineate body – neutral pass', ...
        'estimated_pages', 0);
    return;
end
body_text = all_tex(body_start:body_end);
% Estimate pages: ~3000 chars per page for Chinese-major text
n_newpages = numel(regexp(body_text, '\\newpage|\\clearpage', 'match'));
page_est = max(n_newpages + 1, ceil(numel(body_text) / 3000));
pass = page_est <= 30;
if pass
    detail = sprintf('Body est. %d pages (<=30 limit)', page_est);
else
    detail = sprintf('Body est. %d pages (>30 limit!)', page_est);
end
res = struct('pass', pass, 'detail', detail, 'estimated_pages', page_est);
end

function v = min_val(a, b)
if isempty(a), v = b; elseif isempty(b), v = a; else, v = min(a, b); end
end

% -------------------------------------------------------------------------
%  D9 – No identity (all pages, stricter than W1)
% -------------------------------------------------------------------------
function res = d9_no_identity_all(tex_content)
%% Scan ALL text (including first 2 pages) for identity keywords.
%  2026-08 修复: 原单字模式 '省\s*[市区县]' / '[省市区县](?!...)' 会误报
%  "节省/该区域/市面/小区" 等普通词。现改为完整行政区地名组合模式
%  (直辖市 / XX省XX市区县 / XX自治区 / XX市XX区县), 牺牲单字召回率换取精度。
blacklist = {'大学','学院','学校','姓名','指导','教师'};
region_patterns = { ...
    '(?:北京|天津|上海|重庆)市', ...               % 直辖市: "北京市"
    '[一-龥]{2,6}省\s*[一-龥]{2,8}[市区县]', ...   % 省+市县组合: "山东省济南市"
    '[一-龥]{2,6}(?:自治区|特别行政区)', ...       % "内蒙古自治区" "香港特别行政区"
    '市[一-龥]{2,6}[区县](?=[，。；、：""）】\s]|$)'}; % 市辖区县: "武汉市洪山区"
blacklist = [blacklist, region_patterns];
findings = {};
for i = 1:numel(blacklist)
    m = regexp(tex_content, blacklist{i}, 'match');
    findings = [findings, m]; %#ok<AGROW>
end
pass = isempty(findings);
if pass
    detail = 'No identity-revealing keywords on any page';
else
    detail = sprintf('Identity keywords found: %s', strjoin(unique(findings), ', '));
end
res = struct('pass', pass, 'detail', detail, 'findings', {unique(findings)});
end

% -------------------------------------------------------------------------
%  D10 – File size <= 20 MB
% -------------------------------------------------------------------------
function res = d10_file_size(pdf_size_mb, pdf_path)
if isempty(pdf_path)
    res = struct('pass', true, ...
        'detail', 'No compiled PDF found – neutral pass', 'size_mb', 0);
    return;
end
pass = pdf_size_mb <= 20;
if pass
    detail = sprintf('PDF size %.2f MB (<=20 MB limit)', pdf_size_mb);
else
    detail = sprintf('PDF size %.2f MB (>20 MB limit!)', pdf_size_mb);
end
res = struct('pass', pass, 'detail', detail, 'size_mb', pdf_size_mb);
end

% =========================================================================
%% Self-test
function self_test()
%% Dual-mode: paper + electronic PASS/FAIL projects + D9 regex unit checks.
rng(42);

% -- PAPER mode: PASS project (承诺书 → 编号页 → 摘要页) -------------------
tmp_pass = fullfile(tempdir, 'w2_test_pass');
if isfolder(tmp_pass), rmdir(tmp_pass, 's'); end
mkdir(tmp_pass);

tex_pass = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{graphicx}\n' ...
    '\\usepackage{booktabs}\n' ...
    '\\usepackage{listings}\n' ...
    '\\pagestyle{plain}\n' ...
    '\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '% === PAGE 1: 承诺书 ===\n' ...
    '\\begin{center}\n{\\LARGE\\bfseries 承\ 诺\ 书}\n\\end{center}\n' ...
    '我们仔细阅读了竞赛规则，承诺严格遵守竞赛纪律。\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% === PAGE 2: 编号页 ===\n' ...
    '\\begin{center}\n{\\LARGE\\bfseries 赛区评阅编号}\n\\end{center}\n' ...
    '\\vspace{2cm}\n编号专用页\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% === PAGE 3: abstract (page number reset) ===\n' ...
    '\\pagenumbering{arabic}\n' ...
    '\\setcounter{page}{1}\n' ...
    '\\begin{abstract}\n' ...
    '本文建立了多目标优化模型，采用粒子群算法进行求解。\n' ...
    '\\end{abstract}\n' ...
    '\n' ...
    '\\section{模型建立与求解}\n' ...
    '\\subsection{问题分析}\n' ...
    '本文对问题进行了深入分析，建立了数学模型并进行求解。\n' ...
    '\n' ...
    '\\subsection{模型建立}\n' ...
    '基于上述分析，建立如下优化模型。\n' ...
    '\n' ...
    '\\subsection{模型求解}\n' ...
    '\\begin{table}[h]\n' ...
    '\\centering\n' ...
    '\\caption{参数灵敏度分析}\n' ...
    '\\begin{tabular}{ccc}\n' ...
    '\\toprule\n' ...
    '参数 & 取值 & 灵敏度 \\\\ \n' ...
    '\\midrule\n' ...
    '$\\alpha$ & 0.5 & 0.1234 \\\\ \n' ...
    '$\\beta$  & 0.3 & 0.0876 \\\\ \n' ...
    '\\bottomrule\n' ...
    '\\end{tabular}\n' ...
    '\\end{table}\n' ...
    '\n' ...
    '\\section{附录：程序代码}\n' ...
    '\\begin{lstlisting}[language=Matlab]\n' ...
    '%% main_optimize.m\n' ...
    'x = fmincon(@objective, x0, A, b);\n' ...
    'disp(x);\n' ...
    '\\end{lstlisting}\n' ...
    '\n' ...
    '\\end{document}\n'];

fid = fopen(fullfile(tmp_pass, 'main.tex'), 'w');
fprintf(fid, '%s', tex_pass); fclose(fid);

[p1, r1] = W2_format_check(tmp_pass, '--mode', 'paper');
assert(p1, 'Paper clean project should pass W2 entirely');
assert(strcmp(r1.mode, 'paper'), 'mode recorded as "paper"');
assert(r1.D1.pass, 'paper D1: 承诺书 on page 1');
assert(r1.D2.pass, 'paper D2: 编号 on page 2');
assert(r1.D3.pass, 'paper D3: abstract on page 3');
assert(r1.D4.pass, 'paper D4: page numbering reset');
assert(r1.D5.pass, 'paper D5: no fancy headers (\pagestyle{plain})');
assert(r1.D6.pass, 'paper D6: .m code listing found');
assert(r1.D7.pass, 'paper D7: three-line table \toprule\midrule\bottomrule');
assert(r1.D9.pass, 'paper D9: no identity keywords');

% -- PAPER mode: VIOLATION project -----------------------------------------
tmp_fail = fullfile(tempdir, 'w2_test_fail');
if isfolder(tmp_fail), rmdir(tmp_fail, 's'); end
mkdir(tmp_fail);

tex_fail = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{fancyhdr}\n' ...
    '\\pagestyle{fancy}\n' ...
    '\\fancyhead[L]{清华大学数学建模竞赛}\n' ...  % ← header + identity
    '\\fancyhead[R]{参赛队号: 12345}\n' ...
    '\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '% PAGE 1: NO commitment keyword\n' ...
    '\\section{摘要}\n' ...
    '本文来自清华大学数学科学系，由指导教师张教授带领。\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% PAGE 2: NO numbering keyword\n' ...
    '\\section{引言}\n' ...
    '这是第二页的内容。\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% PAGE 3: NO abstract environment\n' ...
    '\\section{模型}\n' ...
    '直接进入模型部分。\n' ...
    '\n' ...
    '% TABLE: NO three-line (uses \hline instead of \toprule)\n' ...
    '\\begin{table}[h]\n' ...
    '\\caption{普通表格}\n' ...
    '\\begin{tabular}{cc}\n' ...
    '\\hline\n' ...
    'A & B \\\\ \n' ...
    '\\hline\n' ...
    '1 & 2 \\\\ \n' ...
    '\\hline\n' ...
    '\\end{tabular}\n' ...
    '\\end{table}\n' ...
    '\n' ...
    '\\end{document}\n'];

fid = fopen(fullfile(tmp_fail, 'main.tex'), 'w');
fprintf(fid, '%s', tex_fail); fclose(fid);

[p2, r2] = W2_format_check(tmp_fail, '--mode', 'paper');
assert(~p2, 'Paper violation project should NOT pass W2');
assert(~r2.D1.pass, 'paper D1: should fail (no 承诺书)');
assert(~r2.D2.pass, 'paper D2: should fail (no 编号)');
assert(~r2.D3.pass, 'paper D3: should fail (no abstract environment)');
assert(~r2.D4.pass, 'paper D4: should fail (no \setcounter{page}{1})');
assert(~r2.D5.pass, 'paper D5: should fail (\pagestyle{fancy} + \fancyhead)');
assert(~r2.D7.pass, 'paper D7: should fail (no \toprule/\midrule/\bottomrule)');
assert(~r2.D9.pass, 'paper D9: should fail (清华大学 identity keyword)');

% -- ELECTRONIC mode: PASS project (首页=摘要页, 无承诺书/编号页) ------------
tmp_epass = fullfile(tempdir, 'w2_test_epass');
if isfolder(tmp_epass), rmdir(tmp_epass, 's'); end
mkdir(tmp_epass);

tex_epass = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{graphicx}\n' ...
    '\\usepackage{booktabs}\n' ...
    '\\usepackage{listings}\n' ...
    '\\pagestyle{plain}\n' ...
    '\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '% === PAGE 1: 摘要页 (electronic: 首页=摘要页, 页码起1) ===\n' ...
    '\\pagenumbering{arabic}\n' ...
    '\\setcounter{page}{1}\n' ...
    '\\begin{abstract}\n' ...
    '本文建立了多目标优化模型，采用粒子群算法进行求解。\n' ...
    '\\end{abstract}\n' ...
    '\n' ...
    '\\section{模型建立与求解}\n' ...
    '本文对问题进行了深入分析，建立了数学模型并进行求解。\n' ...
    '\n' ...
    '\\begin{table}[h]\n' ...
    '\\centering\n' ...
    '\\caption{参数灵敏度分析}\n' ...
    '\\begin{tabular}{ccc}\n' ...
    '\\toprule\n' ...
    '参数 & 取值 & 灵敏度 \\\\ \n' ...
    '\\midrule\n' ...
    '$\\alpha$ & 0.5 & 0.1234 \\\\ \n' ...
    '\\bottomrule\n' ...
    '\\end{tabular}\n' ...
    '\\end{table}\n' ...
    '\n' ...
    '\\newpage\n' ...
    '\n' ...
    '\\section{附录：程序代码}\n' ...
    '\\begin{lstlisting}[language=Matlab]\n' ...
    '%% main_optimize.m\n' ...
    'x = fmincon(@objective, x0, A, b);\n' ...
    '\\end{lstlisting}\n' ...
    '\n' ...
    '\\end{document}\n'];

fid = fopen(fullfile(tmp_epass, 'main.tex'), 'w');
fprintf(fid, '%s', tex_epass); fclose(fid);

[p3, r3] = W2_format_check(tmp_epass);   % default mode = electronic
assert(p3, 'Electronic clean project should pass W2 (default mode)');
assert(strcmp(r3.mode, 'electronic'), 'default mode recorded as "electronic"');
assert(r3.D1.pass, 'elec D1: page 1 = abstract page (no 承诺书)');
assert(r3.D2.pass, 'elec D2: no 承诺书/编号 pages anywhere');
assert(r3.D3.pass, 'elec D3: abstract on page 1');
assert(r3.D4.pass, 'elec D4: page numbering reset');
assert(r3.D5.pass, 'elec D5: no fancy headers (\pagestyle{plain})');
assert(r3.D6.pass, 'elec D6: .m code listing found');
assert(r3.D7.pass, 'elec D7: three-line table \toprule\midrule\bottomrule');
assert(r3.D9.pass, 'elec D9: no identity keywords');

% -- ELECTRONIC mode: VIOLATION project (paper-style front pages) -----------
tmp_efail = fullfile(tempdir, 'w2_test_efail');
if isfolder(tmp_efail), rmdir(tmp_efail, 's'); end
mkdir(tmp_efail);

tex_efail = [ ...
    '\documentclass[12pt]{ctexart}\n' ...
    '\\usepackage{fancyhdr}\n' ...
    '\\pagestyle{fancy}\n' ...
    '\\fancyhead[L]{清华大学数学建模竞赛}\n' ...  % ← header + identity
    '\n' ...
    '\\begin{document}\n' ...
    '\n' ...
    '% PAGE 1: 承诺书 (electronic 违禁: 首页不允许)\n' ...
    '\\begin{center}\n{\\LARGE\\bfseries 承\ 诺\ 书}\n\\end{center}\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% PAGE 2: 编号页 (electronic 违禁)\n' ...
    '\\begin{center}\n{\\LARGE\\bfseries 赛区评阅编号}\n\\end{center}\n' ...
    '\\newpage\n' ...
    '\n' ...
    '% PAGE 3: abstract (electronic 要求在第 1 页)\n' ...
    '\\begin{abstract}\n' ...
    '本文建立了多目标优化模型。\n' ...
    '\\end{abstract}\n' ...
    '\n' ...
    '% TABLE: NO three-line (uses \hline)\n' ...
    '\\begin{table}[h]\n' ...
    '\\caption{普通表格}\n' ...
    '\\begin{tabular}{cc}\n' ...
    '\\hline\n' ...
    'A & B \\\\ \n' ...
    '\\hline\n' ...
    '\\end{tabular}\n' ...
    '\\end{table}\n' ...
    '\n' ...
    '\\end{document}\n'];

fid = fopen(fullfile(tmp_efail, 'main.tex'), 'w');
fprintf(fid, '%s', tex_efail); fclose(fid);

[p4, r4] = W2_format_check(tmp_efail);
assert(~p4, 'Electronic violation project should NOT pass W2');
assert(~r4.D1.pass, 'elec D1: should fail (page 1 = 承诺书, not abstract page)');
assert(~r4.D2.pass, 'elec D2: should fail (承诺书/编号 present)');
assert(~r4.D3.pass, 'elec D3: should fail (no abstract on page 1)');
assert(~r4.D4.pass, 'elec D4: should fail (no \setcounter{page}{1})');
assert(~r4.D5.pass, 'elec D5: should fail (\pagestyle{fancy} + \fancyhead)');
assert(~r4.D7.pass, 'elec D7: should fail (no \toprule/\midrule/\bottomrule)');
assert(~r4.D9.pass, 'elec D9: should fail (清华大学 identity keyword)');

% -- D9 regex unit: 行政区单字模式误报修复 (2026-08) -------------------------
d9_clean = '该模型节省资源，适用于该区域与市面分析，覆盖小区与山区。';
r9c = d9_no_identity_all(d9_clean);
assert(r9c.pass, 'D9 regex: 节省/该区域/市面/小区/山区 must NOT be flagged');
d9_dirty = '本文数据来自北京市和山东省济南市，另有武汉市洪山区。';
r9d = d9_no_identity_all(d9_dirty);
assert(~r9d.pass, 'D9 regex: 北京市/山东省济南市/武汉市洪山区 must be flagged');

disp('W2_format_check self-test passed (paper + electronic + D9 regex).');
end
