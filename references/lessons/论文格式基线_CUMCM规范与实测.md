# 论文格式基线（样例实测 + CUMCM 官方规范）⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠

<!-- 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 保留版权标识 -->

> 来源: ① 某机理优化类赛题的通过版论文（docx/pdf，已匿名化）的 zipfile+python-docx 逐项反解(styles.xml/numbering.xml/sectPr/页眉页脚 XML)与 pdfplumber 渲染交叉验证; ② CUMCM 官方三件套: 《全国大学生数学建模竞赛论文格式规范(2026年修订稿)》《全国大学生数学建模竞赛参赛规则(2026年修订稿)》《全国大学生数学建模竞赛人工智能工具使用规定(2025年试行)》——官方原件本地留存, 逐条核对。
> 提取于 2026 年夏。所有"实测值"均附 XML 依据; 第三节为官方规范与样例实测的逐条对照, 结论: **样例提交版在全部可验证维度上与 CUMCM 2026 官方规范一致, 可直接作为国赛格式基线**。

## 一、样例实测格式规格(逐项)

### 1. 页面设置

| 项目 | 实测值 | XML 依据 |
|------|--------|----------|
| 纸张 | A4 (11906×16838 twips = 21.0×29.7cm) | sectPr `<w:pgSz w:w="11906" w:h="16838"/>` |
| 页边距 | 四边 1418 twips = **2.5cm** | sectPr `<w:pgMar w:top/right/bottom/left="1418"` |
| 装订线 | 0 | `w:gutter="0"` |
| 页眉距 | 851 twips = 1.5cm | `w:header="851"` |
| 页脚距 | 1020 twips = 1.8cm | `w:footer="1020"` |
| 文档网格 | lines 网格, linePitch=312 twips = **15.6pt/行**(正文行贴此网格) | sectPr `<w:docGrid w:type="lines" w:linePitch="312"/>` |
| 页码起始 | 从摘要页(第1页)起, 全文连续(后续节不重启) | 节0 `<w:pgNumType w:start="1"/>`, 节1/2 无 pgNumType |

### 2. 节结构(3 节)

| 节 | 内容 | 页眉 | 页脚 |
|----|------|------|------|
| 节0 | 标题+摘要页 | header1.xml(空, 两空段落) | 首页 footer2.xml(PAGE 域居中), 其他页 footer1.xml(装饰线图片) |
| 节1 | 正文(问题重述→参考文献) | 继承(空) | default footer3.xml(PAGE 域居中), 首页 footer4.xml |
| 节2 | 附录(支撑材料目录+代码) | 继承(空) | 继承节1 |

- 节0/节1 均设 `<w:titlePg/>`(首页不同页脚)。
- **页眉实际为空** → 论文无可见页眉(官方规范未要求页眉); **页码 = 页脚居中 PAGE 域**, footer 样式字号 9pt(`footer` 样式 rPr sz=18)。
- 页码域 XML 形态: `<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText>PAGE \* MERGEFORMAT</w:instrText></w:r>…`, 段落 `jc=center`。

### 3. 字体基准(docDefaults)

```xml
<w:docDefaults><w:rPrDefault><w:rPr>
  <w:rFonts w:ascii="Times New Roman" w:eastAsia="宋体" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
  <w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/>
</w:rPr></w:rPrDefault><w:pPrDefault/></w:docDefaults>
```

- 中文=宋体, 西文=Times New Roman; **docDefaults 与 Normal 样式均未声明字号 → Word 默认 10pt**。PDF 实测正文 10pt。官方规范对字号不做统一要求(第八条), 10pt 合规; 新论文建议小四 12pt 提升可读性。

### 4. 标题体系

| 层级 | 样式(id) | 字体(实测渲染) | 字号 | 加粗 | 对齐 | 段前/段后 | 编号 |
|------|----------|----------------|------|------|------|-----------|------|
| 主标题 | Title (af0) | CJK=宋体, 西文=等线 Light | 16pt(三号, sz=32) | 是 | 居中 | 240/60 twips | 无 |
| "摘 要" | Subtitle (af2) | 同主标题 | 16pt | 是 | 居中 | 240/60, line=312 auto | 无 |
| 一级标题 | heading 1 (1) | **黑体**(eastAsia=黑体) | 14pt(四号, sz=28) | 是 | **居中** | 340/330(≈17/16.5pt), line=578 auto | **"一、"**(chineseCountingThousand `%1、`) |
| 二级标题 | heading 2 (2) | **缺陷**: 只设 ascii/hAnsi=黑体, CJK 实渲染宋体加粗; 数字(如 1.1)为黑体 | 10pt(未声明 sz) | 是 | 左 | 50/50 + beforeLines/afterLines 50 | "1.1"(decimal `%1.%2` isLgl) |
| 三级标题 | heading 3 (3) | 同二级(同缺陷) | 10pt | 是 | 左 | 50/50 | "1.1.1" |

XML 依据:
- styles.xml 样式 `1`: `<w:rPr><w:rFonts w:eastAsia="黑体"/><w:b/><w:bCs/><w:kern w:val="44"/><w:sz w:val="28"/><w:szCs w:val="44"/></w:rPr>`, pPr `keepNext/keepLines, spacing before=340 after=330 line=578 auto, jc=center`。
- styles.xml 样式 `2`/`3`: `<w:rFonts w:ascii="黑体" w:hAnsi="黑体"/><w:b/><w:bCs/><w:szCs w:val="32"/>` — **无 w:eastAsia、无 w:sz**。
- 标题编号: numbering.xml numId=11→abstractNum 8, ilvl0 `numFmt=chineseCountingThousand lvlText="%1、"`, ilvl1/2 `numFmt=decimal isLgl lvlText="%1.%2"/"%1.%2.%3"`, `ind left=0 firstLine=0`; H1/H2/H3 样式 pPr 中 `numPr` 引用该 numId。
- PDF 实测: H1 "一、 问题重述"= SimHei 14pt; H2 "1.1 问题背景" 数字=SimHei、汉字=SimSun(宋体) 10pt。

> **教训**: 生成新论文时 H2/H3 必须同时设 `w:eastAsia="黑体"` 和 `w:sz`(推荐小四 12pt), 否则中文部分会回落 docDefaults 宋体。

### 5. 正文

| 项目 | 实测值 | 依据 |
|------|--------|------|
| 字体 | 宋体/Times New Roman | docDefaults |
| 字号 | 10pt(该论文实测; 官方未规定, 建议 12pt) | PDF 字符 size=10.0 |
| 对齐 | 两端对齐 | Normal 样式 `<w:jc w:val="both"/>` |
| 行距 | 贴网格 15.6pt/行(≈10pt 的 1.56 倍) | docGrid linePitch=312; PDF 行 top 差实测 15.6pt |
| 段前/段后 | 0 | Normal 无 spacing 声明 |
| 首行缩进 | **2 字符** `<w:ind w:firstLineChars="200" w:firstLine="400"/>`(225 处) | 各正文段落 pPr 直接声明(非样式) |
| 段落间 | 无空行, 靠首行缩进区分 | 实测 |

### 6. 摘要页

- 结构: 主标题(Title 样式) → "摘 要"(Subtitle 样式, 字间一空格) → 摘要正文(Normal, 首行缩进 2 字符) → 关键词段。
- 关键词段: 标签 run "关键词：" = **黑体 12pt(小四, sz=24) 加粗**; 内容 run = 默认 10pt 宋体; 分隔符"；"。
- 摘要页单独成页(节0, titlePg), 为电子版论文第一页(官方第十条要求, 样例符合)。
- PDF 实测: 标题 16pt 宋体加粗, "摘 要" 16pt, 正文 10pt, "关键词：" SimHei 12pt。

### 7. 图注 / 表注

| 项目 | 样式(id) | 格式 | 位置 | 编号 |
|------|----------|------|------|------|
| 图注 | **图名** (a0) | 居中, 加粗, 字号继承正文(实测 10pt 宋体), 段后 156 twips | **图下方**(drawing 后约 1 段) | **"图N" 全文连续**(自动编号) |
| 表注 | **表注** (a) | based on 表格文字 → 居中, **9pt**, 加粗, 段前 50 twips | **表上方**(tbl 前) | **"表N" 全文连续**(自动编号) |

- 样式 XML: 图名 `<w:style w:type="paragraph" w:customStyle="1" w:styleId="a0"><w:name w:val="图名"/><w:basedOn w:val="a2"/>…<w:pPr><w:numPr><w:ilvl w:val="6"/><w:numId w:val="13"/></w:numPr><w:spacing w:afterLines="50" w:after="156"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:szCs w:val="21"/></w:rPr></w:style>`; 表注 同理 `basedOn=表格文字(af4)` + `<w:b/>` + `spacing beforeLines=50 before=50`。
- 编号定义(numbering.xml):
  - 表注 numId=14→abstractNum 7, ilvl 6: `<w:lvlText w:val="表%7"/>` + `lvlRestart=0` + `pStyle=表注` → 渲染"表1 符号说明"。
  - 图注 numId=13→abstractNum 8, ilvl 6: `<w:lvlText w:val="%7图%1"/>` → 渲染"图1 研究整体架构与流程"(PDF 实测)。
  - 该"多级列表第 7 级计数器"技巧能产出全文连续图/表号; 更稳妥的替代: 生成时手工写"图1"文本或 SEQ 域。
- 数量实测: 15 表 / 24 图(23 PNG + 1 JPEG, 均 inline) / 图名段 23 / 表注段 15。

### 8. 三线表

- 表格样式 **"三线表1"**(styleId=13, customStyle): 15/15 个表格全部使用(`<w:tblStyle w:val="13"/>`), 基于 Normal Table。
- 边框: 顶/底单线 **sz=12 = 1.5pt**; 表头行(firstRow)下边 **sz=4 = 0.5pt**; 无左右竖线、无内部横线(样式 XML 见第二节, 可直接复制)。
- 单元格段落样式 **"表格文字"**(af4): 居中, **9pt**(sz=18), 470 处使用。
- 表格属性: `<w:tblW w:w="0" w:type="auto"/>`, 列宽固定 dxa, `<w:tblLook w:val="04A0" w:firstRow="1" … w:noVBand="1"/>`。
- 续页表: 表注写"续表11 …"(实测)。

### 9. 公式

- 全部为 Word 原生 OMML: **486 个 `<m:oMath>`**, 80 个 `<m:oMathPara>`(含 71 个独立段落, 其余在表格单元格内)。
- 公式字体: Cambria Math(m:r 内 rPr 显式声明)。
- 编号: **显示公式不挂编号**(PDF 无行尾编号); 正文引用用按章编号 **"式(6-1)"**,"6"=一级标题序号。
- 变量上下标、分式、求和等均为 OMML 结构, 非图片。

### 10. 参考文献

- 标题"参考文献"使用 **Subtitle 样式**(16pt 加粗居中), 非 H1。
- 条目 13 条, 样式 **"参考文献"**(a1, 基于 Normal), 自动编号 **"[n]"**: numbering.xml numId=15→abstractNum 8 ilvl 8 `<w:lvlText w:val="[%9]"/>`, `ind left=0 firstLine=0`(无悬挂缩进)。
- 格式 = GB/T 7714 顺序编码制, 实测条目(3 条样例):
  1. `Cang D, Dong Z, Lv S, et al. Design and intelligent optimization of TSV-based embedded microchannel heatsinks in 2.5D Packaging[J]. International Journal of Heat and Mass Transfer, 2026, 255: 127908.`
  2. `Shah R K, London A L. Laminar Flow Forced Convection in Ducts[M]. New York: Academic Press, 1978.`
  3. `Storn R, Price K. Differential evolution — a simple and efficient heuristic for global optimization[J]. J. Global Optimization, 1997, 11(4): 341-359.`
- 正文引用: 方括号数字如 `[1-3]`、`[2]`、`[10]`。
- **AI 工具列为最后一条**(符合官方 AI 规定第 4(1) 条): `工具名, 版本/型号, 开发机构, 使用日期。`

### 11. 代码附录

- 附录标题"H1 附录"+"A 支撑材料目录"(加粗, 首行缩进 420 twips, 后附目录截图)+"B 代码（python）"。
- 代码段格式(实测 XML): 每行一段, 字体 **Courier New 9pt**(sz=18), 行距 **固定 12pt**(`w:spacing w:line="240" w:lineRule="exact"`), 段落左右边框单线 sz=6(0.75pt)形成代码框, 行号文本+右对齐 tab(pos=624 twips≈1.1cm)。
- 附录为独立节(节2), 页码继续。

### 12. 目录

- **无目录**: 0 个 TOC 域(实测), 有 16 个 `_Toc` 书签残留(删除目录后遗留)。符合官方第四条"不要目录"。

### 13. PDF 渲染实测(交叉验证)

- 总页数 **70 页**(pdfplumber 实测): 摘要页 1 页 + 正文至第 30 页 + 附录第 31 页起 → **正文约 29 页, 符合官方 ≤30 页硬约束**。
- 字体子集: 宋体(SimSun)、黑体(SimHei)、Times New Roman; 正文/图注 10pt, H1 14pt 黑体, 主标题 16pt, 表注 9pt, 页脚 9pt。

## 二、三线表样式 XML 定义(可复制的样式规格)

### 1. "三线表1"表格样式(styles.xml, styleId=13)

```xml
<w:style w:type="table" w:customStyle="1" w:styleId="13">
  <w:name w:val="三线表1"/>
  <w:basedOn w:val="a4"/>
  <w:rPr><w:sz w:val="21"/></w:rPr>
  <w:tblPr>
    <w:tblBorders>
      <w:top w:val="single" w:sz="12" w:space="0" w:color="auto"/>
      <w:bottom w:val="single" w:sz="12" w:space="0" w:color="auto"/>
    </w:tblBorders>
  </w:tblPr>
  <w:tblStylePr w:type="firstRow">
    <w:tblPr/>
    <w:tcPr>
      <w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/></w:tcBorders>
    </w:tcPr>
  </w:tblStylePr>
</w:style>
```

线宽换算: `w:sz` 单位 = 1/8 pt → sz=12 即 **1.5pt**(顶/底线), sz=4 即 **0.5pt**(表头下线)。无左右/内部竖线 = 三线表。

### 2. 配套段落样式

- 表格文字(af4): 基于 Normal, `jc=center`, rPr `sz=18`(9pt) — 用于所有单元格段落。
- 表注(a): 基于表格文字, `numPr ilvl=6 numId=14`, `spacing before=50`, rPr `b` — 表上方题注。
- 图名(a0): 基于 Normal, `numPr ilvl=6 numId=13`, `spacing after=156`, `jc=center`, rPr `b` — 图下方题注。
- 参考文献(a1): 基于 Normal, `numPr ilvl=8 numId=15` — 自动"[n]"编号条目。

### 3. python-docx 快速等效构建(不依赖 numbering.xml 技巧时)

```python
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.shared import Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH

def three_line_table(doc, rows_data, header=True):
    t = doc.add_table(rows=len(rows_data), cols=len(rows_data[0]))
    tblPr = t._tbl.tblPr
    borders = OxmlElement('w:tblBorders')
    for tag, sz in (('w:top', 12), ('w:bottom', 12)):
        el = OxmlElement(tag)
        el.set(qn('w:val'), 'single'); el.set(qn('w:sz'), str(sz))
        el.set(qn('w:space'), '0'); el.set(qn('w:color'), 'auto')
        borders.append(el)
    tblPr.append(borders)
    if header:
        for tc in t.rows[0].cells:
            tcB = OxmlElement('w:tcBorders')
            b = OxmlElement('w:bottom')
            b.set(qn('w:val'), 'single'); b.set(qn('w:sz'), '4')
            b.set(qn('w:space'), '0'); b.set(qn('w:color'), 'auto')
            tcB.append(b)
            tc._tc.get_or_add_tcPr().append(tcB)
    for row in t.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                for r in p.runs:
                    r.font.size = Pt(9)
    return t
```

> 更简单可靠: 直接把上方"三线表1"样式 XML 写入 styles.xml 并引用 `w:tblStyle w:val="13"`, 与样例行为完全一致。

## 三、CUMCM 2026 官方规范要点(与样例实测对照)

> 来源: 官方三件套原件（本地留存, 完整提取无限制）。样例实测在全部可验证维度上与官方规范一致, 对照结论如下。

### 1. 论文格式规范(2026年修订稿)13 条要点

| 条 | 官方要求 | 样例实测对照 |
|----|----------|----------------|
| 第1条 | 白色 A4 纸(单/双面均可), 四边 ≥2.5cm 页边距, 左侧装订 | ✓ 四边 2.5cm, A4 |
| 第2条 | 纸质版第1页承诺书、第2页编号专用页 | 纸质版要素(电子版不含, 见第10条) |
| 第3条 | **第3页摘要专用页**(含标题+关键词, 无需英文), 原则上 ≤1 页; **从此页起编页码, 页脚中部, 阿拉伯数字从"1"连续编号** | ✓ 摘要单独成页, pgNumType start=1, 页脚居中 PAGE 域 |
| 第4条 | 第4页起正文(**不要目录, ≤30 页**); 之后附录(页数不限), 打印装订 | ✓ 无目录; 正文至第 30 页(≈29 页); 附录第 31 页起 |
| 第5条 | 附录含支撑材料文件列表 + 全部完整可运行源程序(含 EXCEL/SPSS 交互命令); 缺程序/不能运行/与论文不符 → 可能取消评奖资格; 没用到程序 → 声明"本论文没有用到程序" | ⚠️ 样例代码 ✓ 全量贴入, 但"支撑材料文件列表"标题下内容曾为空(已列硬门控) |
| 第6条 | 摘要页/正文/附录**任何地方不得出现身份、学校、赛区信息** | ✓ |
| 第7条 | 引用他人/公开资料必须列参考文献+正文标注 | ✓ GB/T 7714 [n] 制 |
| 第8条 | **字号、字体、行距、颜色不做统一要求**(赛区可自行要求) | 样例的 10pt 方案合规; 12pt 更佳 |
| 第9条 | 按《报名和参赛须知》提交论文+支撑材料两个电子文件 | — |
| 第10条 | 电子版与纸质版完全一致(含附录); **单独文件 PDF 或 Word(建议 PDF), ≤20MB, 不压缩**; **承诺书和编号专用页不放入电子版, 电子版第一页必须为摘要专用页** | ✓ 电子版第一页即标题+摘要 |
| 第11条 | 支撑材料 = 全部可运行源程序 + 自主查阅数据 + 较大中间结果图表; **压缩 RAR/ZIP ≤20MB**; 文件列表放论文附录; 无支撑材料 → 注明"本论文没有支撑材料"; 与论文不符 → 可能取消评奖; 不含承诺书/编号页/身份信息 | ✓ 有支撑材料目录+结果数据 |
| 第12-13条 | 不符规范 = 违反竞赛规则, 可能取消评奖资格; 解释权归全国组委会 | — |

### 2. 参赛规则(2026年修订稿)要点

- 违反承诺/章程/规范 → **无条件取消评奖资格**。
- 指导教师竞赛期间不得以任何方式指导(解释赛题/建议/改论文), 违者两年内不受理其报名。
- **抄袭/大篇幅照抄 → 无条件取消评奖资格**。
- 竞赛期间严禁与队外任何人交流赛题; **不得在贴吧/QQ群/微信群/直播间/知乎/小红书/CSDN/GitHub 等平台浏览、发布、讨论赛题相关内容** → 严重违纪取消评奖资格。→ 工具链全程本地, 团队协作时注意。
- 可用 AI 工具辅助, 但参赛队对作品原创性/真实性/准确性负全部责任, 须遵守 AI 使用规定。
- 规则自 2026-03-01 试行。（注: 本规则未含赛后公开发布参赛内容之限制条款。）

### 3. AI 工具使用规定(2025年试行)要点 — "四件套"

1. **未使用 AI** → 在参考文献之后明确声明: "**本参赛队未使用任何AI工具**"。
2. 可使用但必须公开透明; **核心建模与分析必须由参赛队独立完成**。
3. **使用 AI 时四件套**:
   - ① 正文相应位置**标注 AI 生成内容**;
   - ② 参考文献列出所用 AI 工具: `[编号] 工具名称，版本/型号，开发机构/公司，使用日期。`(官方示例: `[1] DeepSeek, DeepSeek-R1-0528, 深度求索（DeepSeek）, 2025-09-05`)— 样例同格式 ✓;
   - ③ 支撑材料包含 **AI 工具使用详情说明(PDF, 以"AI工具使用详情"为文件名)**, 内容四项: 所用 AI 工具名称和版本 / 具体使用目的和环节 / 关键交互记录(重要提示词与回复) / 采纳和人工修改情况 — 样例提交材料含 AI工具使用详情.pdf ✓;
   - ④ 未使用声明(同 1)。
4. **不符合上述要求 → 视为违反竞赛规则, 取消评奖资格**。
5. 自 2025-09-01 试行。

### 4. 对照结论

样例提交版 = 官方规范 2026 版的合规范例(摘要第一页/页码/无目录/电子版不含承诺书/AI 文献条目/详情说明 全部符合), **唯一未闭合风险: 附录"支撑材料文件列表"内容为空(第5/11条要求, 已列入Gloom硬性门控)**。国赛可直接沿用该基线, 三处升级: ①正文字号 10pt→12pt(官方未规定, 可读性更佳); ②修复 H2/H3 eastAsia=黑体缺陷; ③附录文件列表必须非空且与实际支撑材料一致。

## 四·五、样例二次解析增量

> 二次解析结论: 样例提交版在全部可验证维度上仍是合规范例, 但存在 **2 个样例自身瑕疵** + 若干基线未覆盖的机制细节。新论文照抄时要修掉瑕疵。

### 样例自身瑕疵(必须修, 不能学)

1. **附录首页页码 bug**: 节2 首页页脚(footer4.xml)是**硬编码文字"2"+装饰图形**, 节3 未显式定义页脚 → 继承节2 → 附录首页(页31)页脚显示"2"而非"31"。教训: titlePg 的 first 页脚一律用 PAGE 域, 禁用硬编码页码; 每节显式定义 footerReference。
2. **元数据未清理**: core.xml creator 与 lastModifiedBy 残留人名、title 残留占位词; PDF 元数据同源泄露; app.xml Pages 陈旧缓存(实际 70)。教训: 样例自己也漏了身份清理——新论文 docProps 三重清理(creator/lastModifiedBy/title) + PDF 元数据 + 重存刷新 app.xml。

### 基线未覆盖的机制细节(可学的精华)

3. **编号全挂样式级 numPr**: 章(ilvl0 `%1、`)/节(ilvl1-5 `%1.%2`)/图名(ilvl6 `%7图%1` numId13)/表注(ilvl6 `表%7` numId14)/参考文献(ilvl8 `[%9]` numId11)共挂 abstractNum 九级列表, **段落级 numPr 全文档 0 处**——改样式即整体重排; 取消编号=段落级 `numId=0`(附录标题/节断行)。跨页表以"续表"表注重发共用同一编号源。
4. **分节不用手动分页符**: 3 节间隔全部用"空段落携带 sectPr"实现, 全文 0 个 `w:br type=page`——手动分页符在改稿时会乱页。
5. **关键词段精确格式**: "关键词："黑体粗体 12pt(sz24) + 内容宋体; 摘要正文首行缩进 firstLineChars=200(2 字符), 不用固定磅值。
6. **代码附录精确格式**(基线§11 已述, 补细节): 行号=字面文本+右对齐 tab(pos=624) **禁用 Word 行号功能**(防重排); 代码文件标题=Heading3+numId=0+`b=0` 去粗+黑体 11pt(sz22) 保大纲导航。
7. **正文引用非上标**: 行内 [n]/[1-3], vertAlign superscript 全部留给 R²/m² 等真实上标, 引用不用上标。

### AI 工具使用详情六章结构实测(样例模板)

标题(16pt 粗体居中) → 引言(引规定第4条第(2)款) → 一、所用AI工具基本信息(表1 9行2列: 队名/选题/工具名/版本型号含模型ID/机构/时间段/使用方式/标注情况) → 二、具体使用目的和环节(表2 5行4列: 环节|目的|AI贡献占比估计|采纳修改说明) → 三、关键交互记录(按环节, 每条四要素: 提示词/回复要点/采纳情况, 约占全文38%) → 四、采纳和人工修改情况总结((1)采纳(2)人工修改(3)核心工作独立性) → 五、AI使用基本原则(4条) → 六、责任声明(3条确认+队名+日期)。官方四要素=一~四章, 五/六是加分项。生成用 python-docx(docProps creator=python-docx 可接受, 但姓名必须清)。

## 四、国赛直接适用的 Word 构建清单(生成 docx 时逐项执行)

官方硬约束项(违反可能取消评奖资格)在前, 排版基线项(官方不规定, 按样例实测保证美观)在后:

**官方硬约束**
- [ ] 页面: 白色 A4; 四边页边距 ≥2.5cm(按样例用 2.5cm); 左侧装订。
- [ ] 电子版第一页 = **摘要专用页**(主标题+摘 要+摘要正文+关键词, 无需英文, ≤1 页)。
- [ ] **无目录**; 正文从摘要页后开始, **≤30 页**; 附录页数不限。
- [ ] 页码: **从摘要页起**页脚中部阿拉伯数字从"1"连续编号(PAGE 域居中 9pt)。
- [ ] 全文(摘要页/正文/附录)**不含身份、学校、赛区信息**。
- [ ] 附录: 支撑材料文件列表(**非空且与实际文件一致**) + 全部可运行源程序(含 EXCEL/SPSS 命令); 确实没用程序 → 声明"本论文没有用到程序"。
- [ ] 参考文献: 引用他人/公开资料必须正文标注+列表; 不照抄。
- [ ] **AI 四件套**: ①正文标注 AI 生成内容 ②参考文献列 AI 工具 `[编号] 工具名称，版本/型号，开发机构/公司，使用日期。` ③支撑材料含"AI工具使用详情".pdf(4 项内容) ④(未用 AI 时)参考文献后声明"本参赛队未使用任何AI工具"。
- [ ] 电子版: 单独文件 **PDF(建议)或 Word, ≤20MB, 不压缩**; 承诺书/编号页不放入电子版。
- [ ] 支撑材料: 压缩 **RAR/ZIP ≤20MB**, 含全部源程序+自查数据+中间结果图表; 文件列表放论文附录。

**排版基线(样例实测, 官方未规定的美观标准)**
- [ ] 主标题: 16pt 加粗居中(宋体 CJK + Times New Roman 西文)。
- [ ] H1: 黑体(eastAsia+ascii 都设) 14pt 加粗居中, 自动编号"一、"; H2/H3: 黑体加粗左对齐 12pt, 自动编号"1.1"/"1.1.1"; **必须设 w:eastAsia="黑体"**(样例缺陷教训)。
- [ ] 正文: 宋体/Times New Roman, 两端对齐, 首行缩进 2 字符(`firstLineChars=200`), 行距 1.5 倍或 15.6pt 网格; 字号 12pt(样例为 10pt, 两者合规)。
- [ ] 图注: 样式"图名", **图下方**, 居中加粗, "图N"全文连续; 表注: 样式"表注", **表上方**, 9pt 加粗, "表N"。
- [ ] 表格: 全部"三线表1"(顶/底 1.5pt, 表头下 0.5pt, 无竖线 — 复用第二节样式 XML); 单元格 9pt 居中。
- [ ] 公式: OMML 原生 Cambria Math 可编辑; 正文引用按章"式(n-m)"。
- [ ] 参考文献: GB/T 7714 顺序编码制, 自动编号"[n]", 标题用 Subtitle 样式(16pt 加粗居中)。
- [ ] 附录代码: Courier New 9pt, 行距固定 12pt, 0.75pt 左右边框代码框+行号。
- [ ] 页眉: 无(官方未要求, 样例实测为空); 页脚: 居中页码 9pt。

**导出后核对**
- [ ] Word→PDF 渲染后: 摘要确为第一页且 ≤1 页; 正文 ≤30 页(附录不计); 页码从 1 起页脚中部; PDF ≤20MB; 全文搜索无学校/姓名/队号。
- [ ] 支撑材料打包 RAR/ZIP ≤20MB; 论文附录文件列表与实际打包一致; 源程序可运行、结果与论文一致。
