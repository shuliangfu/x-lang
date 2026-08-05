# VSCode 插件语法高亮完善分析

> **文档目的**：分析 `allow(padding)` 白色等语法高亮问题的根因，全面盘点 TextMate 语法文件、language-configuration、semanticTokens 的现状与缺口，给出分优先级的完善方案。
> **交办**：grok
> **建立日期**：2026-08-05
> **状态**：待决策 / 待实施
> **配套**：[语言语义诊断与LSP跟踪能力分析.md](./语言语义诊断与LSP跟踪能力分析.md) · [自举完成后功能完善及优化时序表.md](./自举完成后功能完善及优化时序表.md)

---

## 0. 摘要

### 0.1 `allow(padding)` 白色的直接根因

`allow(padding)` 在语法文件里**写了两处规则，其中一处是「坏规则」，另一处用了无颜色的 scope**：

1. **struct-body begin 捕获（真正匹配到的地方）** [x.tmLanguage.json:L94](../editors/vscode/grammars/x.tmLanguage.json#L94)
   - regex：`(\b(?:allow\(padding\)\s+)?)(struct)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{`
   - capture 1 含整个 `allow(padding) ` 整块，scope 写的是 **`meta.attribute.xlang`**
   - 主流主题（包括用户使用的主题）里 **`meta.` 前缀 scope 没有独立颜色**——它是纯容器 scope，用作语法捕获分组而非着色。结果：整段 `allow(padding)` 直接继承默认文本色，看起来就是白色。

2. **attributes 块 allow 规则（命中顺序被抢）** [L40-47](../editors/vscode/grammars/x.tmLanguage.json#L40)
   - regex：`\ballow\((padding)\)`
   - capture 1 标 `constant.other.attribute`，**`allow` 本身没独立标 scope**，跟着整体（隐式 `meta.attribute.xlang`）也是无色。
   - 即使 attributes 规则先跑（patterns 里 attributes 在 declarations 之前），因为 attributes 的 allow 只匹配到 `allow(padding)` 这个 token 串，而 `allow(padding) struct Foo {` 后续整段仍会被 struct-body 的 begin 再次匹配——这里的 beginCaptures L96 又把 capture 1 盖成了 `meta.attribute.xlang`。

**一句话修复**：struct-body begin 的 capture 1（整个 allow 块）与 attributes allow 块的 `allow` 关键字 + `padding` 参数 + `( )` 括号，都标成**真正有颜色的 TextMate scope**（不是 `meta.`）。主流主题里通常有颜色的是：
- `entity.other.attribute-name`（和 `#[cfg(...)]` 的 `cfg` 同色）——建议用于 `allow` + `padding`
- `keyword.other.attribute` / `storage.modifier.attribute`——建议用于 `allow` 关键字
- `punctuation.section.attribute`——建议用于 `( )`

### 0.2 全景缺口

| 问题 | 根因层 | 影响面 | 修复复杂度 |
|------|--------|--------|-----------|
| A. `allow(padding)` 白色 | struct-body begin 用 `meta.` scope + allow 关键字无独立 scope | 20+ 处 `allow(padding)` | 低（纯 JSON regex 改） |
| B. `#[...]` 属性 `#[cfg(target_os = "linux")]` 嵌套括号内内容着色不全 | attributes regex 是 `\([^)]*\)` ——不支持 `cfg( xxx(yyy) )` 嵌套，也没给 `=` / `"linux"` 分别着色 | 50+ 处 `#[cfg(...)]` 含嵌套 | 中 |
| C. `export struct` / `export enum` 的 `export` 在 struct/enum 声明前标错 scope | struct-body begin regex 里 capture 组没包含 `export` 前缀，export 靠 #keywords 兜底为 `storage.modifier`（尚可），但 `export allow(padding) struct Foo` 这三连组合结构整体没被 struct-body begin 捕获（regex 只有 `allow` 没 `export`）| `export allow(padding) struct` 写法 | 低 |
| D. SIMD comptime builtin `@shuffle(x, y, mask)` 内 `@` 不标色 | 规则要求 `@xxx` 后面必须跟 `(` 才标 `support.function.builtin`——`@shuffle` 有括号 OK，但其 `@` 符号本身是 capture 的一部分（整个 `@name` 同色），若用户期望 `@` 独立颜色则需拆 | `@shuffle/@select/@broadcast` | 低 |
| E. function 参数名（函数签名圆括号内）无独立 scope 颜色 | 函数签名 regex 只匹配到 `function name`，括号内 `a: i32, b: i32` 全留给后续规则，`a:` 和 `b:` 靠 #declarations L236 `entity.name.label`（label scope 颜色对参数语义不够贴切） | 所有函数签名参数 | 中 |
| F. `unsafe extern "C" function` 的 `unsafe` 前缀在函数签名里未标 | declarations 149/160 行 regex 顺序是 `export extern "C" function`——缺 `unsafe` 前缀；unsafe 只能靠 #keywords 兜底（`keyword.control`），颜色对但组合不统一 | `unsafe extern "C" function` 写法 | 低 |
| G. `wordPattern` 不含 `@`/`*` | `@shuffle` 的 Go-to-definition / hover 会把 `@` 剔除成 `shuffle`（因为 word 选择不含 `@`），影响 IntelliSense 边界识别 | IntelliSense 定位 SIMD builtin | 低 |
| H. `#[]` 属性无自动闭合 | language-configuration.json 没把 `["#[", "]"]` 作为 bracket 对 + autoClosingPair——用户打 `#[` 不会自动补 `]` | 所有 `#[...]` 属性编辑体验 | 低 |
| I. semanticTokens 有完整 legend 但 server handler 产数据的覆盖度未确认 | LSP advertise 了 semanticTokensProvider（21 types + 10 modifiers，full 模式），但 `lsp_build_semantic_tokens_response` 的实现覆盖度未深挖（struct 字段、函数参数、属性名等是否真产生 semantic token）。TextMate 漏色的地方，如果 semanticTokens 产 token，客户端会以 semantic 颜色优先覆盖 TextMate | 字段名颜色 / 参数名颜色 / 属性名颜色等 | 高（深度） |
| J. `attribute` 规则 `comments` 中 `#(?!\[).*$` 把 `#` 开头但不是 `#[` 的都标成 comment | 如果将来有其他 `#xxx` 语言特性会被标成注释；目前 X 语言确实没有其他 `#` 语法，但不如保守点好 | 兼容性 | 低 |

### 0.3 修复优先级建议（考虑自举）

| 批次 | 项目 | 风险 | 改动量 | 推荐时机 |
|------|------|------|--------|---------|
| **P0（立即，0 自举风险）** | A + G + H + allow 关键字独立色 | 🟢 低 | 纯 JSON 改 20 行内 | 现在即可做 |
| P1（低风险） | C + F + B 嵌套括号内容着色 + D `@` 独立色 | 🟢 低 | 纯 JSON 改 50 行内 | 自举冲刺期可穿插 |
| P2（中风险） | E 参数名 scope 颜色 + J comment # 保守化 | 🟡 中 | JSON + 可能需改函数签名 begin/end 模式，50~100 行 | 自举后或独立窗口 |
| P3（深度，依赖 LSP） | I semanticTokens handler 覆盖度补齐：struct 字段 → property、参数 → parameter、属性 → modifier/attribute | 🟢 低~🟡 中 | LSP glue C 实现（`lsp_build_semantic_tokens_response`），不改 parser/typeck 主路径 | 自举后或与 P0 并行 |

> **注意**：本任务全部改动在 `editors/vscode/`（纯插件）+ `compiler/seeds/lsp_diag*.from_x.c`（semanticTokens LSP glue），**不碰 parser/typeck/IR/codegen 主路径**，自举风险整体远低于 parser 分号收紧那波。P0 + P1 完全可以立即做；P3（semanticTokens）也是 glue 层，不影响自举编译正确性。

---

## 1. TextMate 语法文件逐段审查

[x.tmLanguage.json](../editors/vscode/grammars/x.tmLanguage.json)

### 1.1 Top-level patterns 顺序

```
comments → attributes → strings → lifetimes → imports → declarations → keywords → types → literals → builtins → operators
```

顺序正确（先 comment/string/attr 吞掉非关键字、再关键字）。注意 declarations 内含 include attributes/struct-body/enum-body，和顶层 attributes 可能存在"先匹配"的重叠（见下文）。

### 1.2 comments 块 [L19-24](../editors/vscode/grammars/x.tmLanguage.json#L19)

```json
//       //.*$           → comment.line.double-slash
//       #(?!\[).*$      → comment.line.number-sign  【# 开头但不是 #[ 的按注释】
//       /* ... */       → comment.block
```

**问题 J**：`#(?!\[).*$` 过于激进——如果将来有 `#define`/`#line`/`#pragma` 等新语法会被错标成注释。但当前 X 语言确实无此语法。低风险，P2 再改（改成仅 `# ` 含空格后才算注释或直接去掉）。

### 1.3 attributes 块 [L27-49](../editors/vscode/grammars/x.tmLanguage.json#L27)

#### 1.3.1 `#[...]` 形式规则 [L29-39](../editors/vscode/grammars/x.tmLanguage.json#L29)

```
match: (#)(\[)([a-zA-Z_][a-zA-Z0-9_]*(?:\([^)]*\))?)(\])
```

**问题 B**：`(?:\([^)]*\))?` 用 `[^)]*`（任意非右括号）——遇到嵌套 `cfg(target_os = "linux")` 实际是单层括号，OK；但将来如果有 `cfg(all(target_os="linux", target_arch="x86_64"))` 这种嵌套（外层 `cfg(...)` 内层 `all(...)`），`[^)]*` 会在第一个 `)` 就停——**匹配不完整**，剩下的内容会丢失属性 scope。

**次要**：`=` / `"linux"` / 嵌套内关键字 `target_os`、`target_arch`、`all`、`any`、`not` 都没有独立 scope，直接跟随整体 `meta.attribute.xlang` 无色——这是它们看起来"半有色半没色"的原因。

建议改为 **begin/end 模式**（见 §3.1 B 方案），支持括号嵌套并为内部元素分别标色。

#### 1.3.2 `allow(padding)` 前缀规则 [L40-47](../editors/vscode/grammars/x.tmLanguage.json#L40)

```
match: \ballow\((padding)\)
captures:
  0: meta.attribute.xlang
  1: constant.other.attribute
```

**问题 A.2**：
- `allow` 关键字没有单独 capture——只 capture 了 `padding` 标 `constant.other.attribute`，`allow` 跟整个捕获 0 一起是 `meta.attribute.xlang`（无颜色）
- `padding` 标 `constant.other.attribute`：某些主题里 `constant.other.attribute` 颜色很浅甚至与前景一致（**为什么看起来 `padding` 也是白的**——尽管它有 scope，但主题对这个 scope 无着色规则）
- 最致命的：**此规则先匹配了 `allow(padding)`，但紧接着 `struct-body` begin 又把整段重新捕获，其 capture 1 标 `meta.attribute.xlang` 覆盖了前面 allow 的着色**（TextMate 允许后匹配的长范围覆盖短范围）

### 1.4 struct-body begin 规则 [L90-117](../editors/vscode/grammars/x.tmLanguage.json#L90)

```
begin: (\b(?:allow\(padding\)\s+)?)(struct)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{
beginCaptures:
  1: meta.attribute.xlang   ← 整个 allow(padding) 块！
  2: storage.type            ← struct
  3: entity.name.type        ← Foo
```

**问题 A.1（根因）**：begin capture 1 把整个 `allow(padding)` 块（含空格）塞给 `meta.attribute.xlang`——`meta.` scope 在几乎所有主题里**没有颜色**，导致用户视觉上白色。

**问题 C.1**：regex 不包含 `export` 前缀。对于 `export allow(padding) struct Foo`，`export` 靠 keywords 兜底 `storage.modifier`（颜色还行但语义不精准）。

**建议改法**：
```
begin: ((?:(export)\s+)?(allow)\((padding)\)\s+)?(struct)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{
beginCaptures:
  2: storage.modifier                    ← export
  3: keyword.other.attribute             ← allow
  4: variable.parameter.attribute        ← padding（或 entity.other.attribute-name）
  5: storage.type                        ← struct
  6: entity.name.type                    ← Foo
```

同时 **`(` 和 `)` 括号** 应在 attributes allow 规则里单独 capture 成 `punctuation.section.attribute`（和 `#[...]` 的 `[` `]` 一致）。

### 1.5 enum-body [L120-141](../editors/vscode/grammars/x.tmLanguage.json#L120)

正确。注意也可以加 `export` 前缀与 `allow(padding)` 前缀的支持（若未来 enum 也支持 allow）。当前 enum 本身写法一般是 `export enum Foo`——`export` 靠 keywords 兜底。

### 1.6 declarations 块 [L143-242](../editors/vscode/grammars/x.tmLanguage.json#L143)

顺序：attributes → struct-body → enum-body → export extern → extern → export function → function → extern function → struct/enum/trait/impl/type → let/const → 函数调用 → 点方法调用 → 点成员 → match 臂/goto 标签。

**问题 F**：export extern / extern function 规则没包含 `unsafe` 前缀。`unsafe extern "C" function xyz` 的 `unsafe` 靠 #keywords L262 兜底（`keyword.control`）。颜色凑合——但如果想把 unsafe 精确定为 `storage.modifier`，需要 regex 加 `(?:unsafe\s+)?`。

**问题 E.1**：函数参数。`function foo(a: i32, b: i32)` 中 `a:` 被 #declarations L236 `entity.name.label`（因为 `\bname\s*:` 匹配）。label 颜色在某些主题是"跳转目的地"风格（红色/棕色），用于参数语义不贴切。更合适的是 `variable.parameter`（参数色，通常在主题里是浅蓝或独立色）。

**解决路径**（P2）：函数声明改为 **begin/end 模式**——begin 匹配 `(?:export\s+)?(?:extern\s+"[CX]"\s+)?function\s+NAME\s*\(`，end 匹配 `\)`，整个括号内 `variable.parameter` 标参数名，`:` 标 punctuation，类型包含 #types。工作量：50~100 行 JSON，需要处理 export/extern/unsafe 多种前缀组合。

### 1.7 keywords 块 [L244-275](../editors/vscode/grammars/x.tmLanguage.json#L244)

正确，关键字较全：`struct/enum/trait/impl/type/function/let/const/extern/export/packed/soa/align/region/with_arena/async/await/unsafe/if/else/match/while/for/loop/break/continue/return/defer/goto/panic/try/catch/run/spawn/import/self/as/allow/_`。

注意 L272 `allow` 被归为 `keyword.other`——这和 attributes 规则/struct-body 规则里 allow 不冲突（如果前面规则给了更高优先级的 capture，优先用那些；否则这里兜底为 keyword.other，也 OK）。

### 1.8 types 块 [L277-320](../editors/vscode/grammars/x.tmLanguage.json#L277)

正确，SIMD types `i32x4/i32x8/i32x16/u32x4/u32x8/u32x16/f32x4` 已包含 L292。

**观察**：泛型 begin/end L297-309 只处理 `Name<...>` 模式，正确。L311 `[A-Z][A-Za-z0-9_]*` 作为 `support.type` 这是"大驼峰默认为类型"启发式，OK。

### 1.9 literals 块 [L322-334](../editors/vscode/grammars/x.tmLanguage.json#L322)

正确：`true/false/null`（L324）、整数（含 0x/0o/0b + 8/16/32/64/size 后缀）、浮点（含科学计数 + f 后缀）。

### 1.10 builtins 块 [L336-346](../editors/vscode/grammars/x.tmLanguage.json#L336)

```
match: (@[a-zA-Z_][a-zA-Z0-9_]*)\s*\(
capture 1: support.function.builtin
```

**问题 D**：`@` 与 `name` 同色（都在 capture 1）。如果期望 `@` 是运算符/标点独立色，应拆：
```
match: (@)([a-zA-Z_][a-zA-Z0-9_]*)\s*\(
captures:
  1: keyword.operator.builtin   (或 punctuation.accessor)
  2: support.function.builtin
```
工作量一行，低风险（P1）。

### 1.11 operators 块 [L348-361](../editors/vscode/grammars/x.tmLanguage.json#L348)

正确。范围 `..`/`...`（L351-352）、复合赋值 `<<= / >>= / += / -= / *= / /= / %= / &= / |= / ^=`（L353）、其他比较/逻辑/位运算/算术。注意复合赋值 L353 列表里还缺 `<>`（如果 X 支持），不过当前语言看起来不使用。

---

## 2. language-configuration.json 审查

[language-configuration.json](../editors/vscode/language-configuration.json)

### 2.1 comments ✅
```json
"lineComment": "//",
"blockComment": ["/*", "*/"]
```
正确。注意 X 语言用 `//` 和 `/* */`，配置一致。

### 2.2 brackets
```
["{", "}"], ["[", "]"], ["(", ")"]
```

**问题 H.1**：缺 `["#[", "]"]`。建议加——属性括号对可帮助用户"选中括起来的属性"等。

### 2.3 autoClosingPairs
```json
{ "{", "}" }, { "[", "]" }, { "(", ")" },
{ "\"", "\"", notIn: [string, comment] },
{ "/**", " */", notIn: [string, comment] }
```

**问题 H.2**：缺 `{ "open": "#[", "close": "]", "notIn": ["string", "comment"] }`——用户打 `#[` 自动补 `]`。（P0）

### 2.4 surroundingPairs ✅

OK，当前够用。也可以加 `["#[", "]"]`（可选）。

### 2.5 folding 折叠标记
```
start: ^\s*\{        | ^\s*/\*\*   | ^\s*(region|with_arena|unsafe)\b
end:   ^\s*\}|^\s*\*/
```

正确。`region`/`with_arena`/`unsafe` 关键字折叠入口已加。

### 2.6 indentationRules
- increaseIndentPattern：`{` 无 `}` 到行尾 / `[` 空行 / if with { / while/for/loop/match/defer / else if {
- decreaseIndentPattern：`}` / `]` / `)`
- indentNextLinePattern：`=>` 行尾 / `->` 行尾（lambda / fat-arrow 换行缩进）
- unIndentedLinePattern：`//` 开头 / `*` 开头（doc block）/ `#(?!\[)` 开头

**问题 H.3**：`#(?!\[)` 行不缩进，OK 但和 comments 里 `#...` 注释约定一致。

### 2.7 onEnterRules ✅

doc comment enter 续 ` * `；`{` enter 缩进；`}` enter 取消缩进。正确。

### 2.8 wordPattern

```
[a-zA-Z_][a-zA-Z0-9_]*
```

**问题 G**：缺 `@` 和 `*`。对 IntelliSense 的"光标选中 word"边界有影响：
- `@shuffle` 被分成 `@` + `shuffle`——hover/Go-to-definition 的 word 是 `shuffle`，不带 `@`，定位 SIMD builtin 时可能找不到（要看 server 端是否 strip `@` 后再查）。
- `*u8` 这种指针类型，光标在 `*` 上不会被包含进 word——但一般类型 word 只取 `u8`，OK。

**建议**：改为 `[a-zA-Z_@*][a-zA-Z0-9_@]*` 或拆规则（如果 VSCode 支持多个或允许 lookbehind）。注意 wordPattern 正则在 VSCode 实现里通常是"完整 word 的字符集合"——加 `@` 至少让 `@shuffle` 作为一个整体被选中。

---

## 3. SemanticTokens 能力审查

### 3.1 Server advertise

[runtime_lsp_glue.from_x.c:L2271](../compiler/seeds/runtime_lsp_glue.from_x.c#L2271)：

```
"semanticTokensProvider": {
  "legend": {
    "tokenTypes": [
      "namespace","type","class","enum","interface","struct","typeParameter",
      "parameter","variable","property","enumMember","event",
      "function","method","macro","keyword","modifier","comment",
      "string","number","regexp","operator"
    ],
    "tokenModifiers": [
      "declaration","definition","readonly","static","deprecated","abstract",
      "async","modification","documentation","defaultLibrary"
    ]
  },
  "full": true,
  "range": false
}
```

完整 legend：21 tokenTypes + 10 modifiers。LSP client 在 [lspClient.ts:L110](../editors/vscode/src/lspClient.ts#L110) 配 `semanticTokensProvider: { legend }` 匹配 Server legend。

### 3.2 Handler 现状（待 grok 深挖）

[x.tmLanguage.json builtins 仅覆盖 SIMD @shuffle 等](#110-builtins-块)——如果 semanticTokens 能产：

| 构造 | 期望 semantic token | LSP handler 是否产（grok 需确认） |
|------|--------------------|--------------------------------|
| struct 字段 `ctx_handle: i64` | property (optional + definition) | ? 当前 TextMate 给了 variable.other.readwrite 颜色 OK，但 hover/F12 不定位字段如果 semantic 不产 property |
| 函数参数 `a: i32`（签名内） | parameter | ? 当前靠 match arm label scope 着色，语义不准 |
| `allow(...)` 关键字 | modifier | ? 如果 semanticTokens 产 modifier，客户端会用 semantic 颜色覆盖 TextMate 白色 |
| `#[cfg(...)]` 整体 | modifier | ? 同上 |
| `export` 前缀 | modifier (declaration) | ? |
| SIMD builtin 函数调用 `@shuffle(...)` | function (macro 或 defaultLibrary modifier) | ? 支持精确的 @name 语义 |
| let/const 绑定 | variable (with readonly for const) | ? 当前 TextMate 已有颜色，但 semantic 可附加 declaration/definition 做文档高亮同步 |
| 枚举 variant | enumMember | ? 当前 TextMate 已有 constant.other.enum，OK |

**关键作用**：semanticTokens 颜色**优先于** TextMate。如果 P3 补齐 handler，§0.2 里 A/B/E 这些"颜色缺口"可以通过 semanticTokens 统一填上，**同时**给编辑器提供"语义级的符号身份"（hover 在 property 上 F12 跳字段定义、Find References 只找 property）。

### 3.3 客户端 documentHighlight

[documentHighlight.ts:L1-L10](../editors/vscode/src/documentHighlight.ts#L1) 是客户端本地正则实现，**不依赖 server semanticTokensProvider**。它的弱点是"同名不同作用域"变量会全高亮——如果 server 端实现 `textDocument/documentHighlight`（基于 AST 语义），效果会大幅优于本地正则版。但这属于 P3+ 深度体验，不紧急。

---

## 4. 具体修复方案（分批次）

### 4.1 批次 P0（立即）

目标：解决用户立即感知的 `allow(padding)` 白色 + `#[` 不自动补 + wordPattern SIMD 定位。

**改动清单**：

1. **`x.tmLanguage.json` struct-body 正则改 + allow 独立色**
   - `struct-body` begin：拆分 capture，`allow` 标 `keyword.other.attribute`，`padding` 标 `entity.other.attribute-name`，`export` 加前缀支持标 `storage.modifier`。
   - `attributes` 块 allow 正则：拆分 `allow` / `(...)` / `padding` 分别标色，与 struct-body 保持一致。
   - #keywords 里 `allow` L272 可以保留（兜底位置）也可以移除（前面 attribute 规则优先级更高）。

2. **`language-configuration.json` 补 `#[` bracket/auto-close**
   - `brackets` 加 `["#[", "]"]`。
   - `autoClosingPairs` 加 `{ "open": "#[", "close": "]", "notIn": ["string", "comment"] }`。

3. **`language-configuration.json` wordPattern 扩 `@`**
   - 改成 `[a-zA-Z_@][a-zA-Z0-9_]*`（可选加 `*`，如果指针类型 word 边界选择需要包含的话，但通常不需要 `*`）。

总改动：~40 行 JSON。纯插件，零自举风险。

**验证**：
- `allow(padding) struct Foo {`：`allow` 有明确色（attribute-name / keyword.other.attribute 同 `#[cfg]` 里的 `cfg` 色），`padding` 有颜色，`( )` 为标点色。
- 打 `#[` 自动补 `]`，选中括号内属性能匹配 bracket。
- `@shuffle` 双击选中时整体选中（包含 `@`）。

### 4.2 批次 P1（低风险）

1. **B：`#[...]` 改为 begin/end 模式**（支持嵌套括号 + 内部元素着色）
   - begin：`#\s*\[\s*([a-zA-Z_][a-zA-Z0-9_]*)`——`#` 标属性名、`[` 标标点、`cfg`/`repr_c` 标 `entity.other.attribute-name`
   - patterns 内：
     - `target_os`/`target_arch`/`all`/`any`/`not`/`unix`/`windows` 等 config key 标 `variable.parameter.attribute`
     - `=` 标 `keyword.operator.assignment`
     - `"..."` 包含 `#strings`
     - `( )` 嵌套：`punctuation.section.attribute`
     - `,`：`punctuation.separator`
   - end：`\]`

2. **C + F**：`export` / `unsafe extern` / `unsafe` 前缀在 struct/enum/function 声明里精确 capture。

3. **D**：`@shuffle(...)` 的 `@` 与 `name` 拆 capture。

### 4.3 批次 P2（中风险）

1. **E**：函数签名改 begin/end 模式，`parameter` 标参数名。
   - begin/end 处理 `( ... )` 内的参数列表
   - 需要兼容多种前缀组合：`export? (unsafe\s+)? extern? "[CX]"? function NAME` 共 2×2×3=12 种组合或用嵌套 optional 处理

2. **J**：`#(?!\[).*$` comment 标记保守化处理或移除（如果确实不需要的话）。

### 4.4 批次 P3（深度体验，LSP glue）

1. **I**：`lsp_build_semantic_tokens_response` 覆盖度补齐——struct 字段产 property、参数产 parameter、属性产 modifier。
   - 定位 `compiler/seeds/lsp_diag_empty_surface.from_x.c` 里 `lsp_build_semantic_tokens_response` 实现（如果是 stub，则从 AST arena / module func 表遍历产生 token）。
   - Semantic token 编码：每个 token = (deltaLine, deltaStart, length, typeIndex, modifierBits)，按 LSP spec。
   - 产生 token 后客户端自动优先用 semantic 颜色覆盖 TextMate，allow 白色的问题也能被 semantic modifier 颜色覆盖兜底。

2. 可选：`textDocument/documentHighlight` server 端实现（基于 AST 作用域语义）替代客户端正则版。

---

## 5. 代码位置清单

| 位置 | 作用 | 改哪批 |
|------|------|--------|
| [x.tmLanguage.json:L27-49](../editors/vscode/grammars/x.tmLanguage.json#L27) | attributes 块（`#[...]` + allow） | P0/P1 |
| [x.tmLanguage.json:L90-117](../editors/vscode/grammars/x.tmLanguage.json#L90) | struct-body begin（allow 白色根因） | **P0** |
| [x.tmLanguage.json:L120-141](../editors/vscode/grammars/x.tmLanguage.json#L120) | enum-body | P1 (可选) |
| [x.tmLanguage.json:L143-242](../editors/vscode/grammars/x.tmLanguage.json#L143) | declarations 函数签名/参数/unsafe extern/export | P1/P2 |
| [x.tmLanguage.json:L336-346](../editors/vscode/grammars/x.tmLanguage.json#L336) | builtins @shuffle @拆独立色 | P1 |
| [language-configuration.json:L6-17](../editors/vscode/language-configuration.json#L6) | brackets + autoClosingPairs，补 #[] | **P0** |
| [language-configuration.json:L57](../editors/vscode/language-configuration.json#L57) | wordPattern，扩 @ | **P0** |
| [runtime_lsp_glue.from_x.c:L2271](../compiler/seeds/runtime_lsp_glue.from_x.c#L2271) | semanticTokensProvider legend（已 advertise） | P3 (不改) |
| `compiler/seeds/lsp_diag_empty_surface.from_x.c` `lsp_build_semantic_tokens_response` | semanticTokens 产数据的 handler（grok 深挖覆盖度） | P3 |

---

## 6. 验证清单

### P0 验证
- [ ] `allow(padding) struct Foo`：`allow` 有明确颜色（keyword/attribute 色，和 `#[cfg]` 的 `cfg` 类似）
- [ ] `allow(padding)` 里 `padding` 有颜色（attribute-name 或 parameter 色）
- [ ] `allow(padding)` 里 `(` 和 `)` 是标点色
- [ ] `export allow(padding) struct Foo`：`export` 是 modifier 色 / `struct` 是 storage.type / `Foo` 是 entity.name.type
- [ ] 光标打 `#[` → 自动补 `]`
- [ ] `@shuffle` 双击整体被选中（含 `@`）

### P1 验证
- [ ] `#[cfg(all(target_os = "linux", target_arch = "x86_64"))]`：嵌套括号内内容完整着色（`cfg`/`all`/`target_os`/`=`/`"linux"`/`,` 分别有颜色）
- [ ] `unsafe extern "C" function foo`：`unsafe` 颜色一致
- [ ] `@shuffle(x, y, mask)`：`@` 独立色，`shuffle` builtin 色

### P2 验证
- [ ] `function foo(a: i32, b: Bar)`：`a`/`b` 参数名颜色与 match 臂 label 色有区分

### P3 验证
- [ ] struct 字段名在 Problems 外的语义颜色与 TextMate 不同但更准
- [ ] 光标在字段上：documentHighlight 只高亮同字段（非所有同名字段）

---

## 附录 A：scope 颜色对照表（主流主题）

给 grok 选择 scope 时的参考（某 scope 在用户主题里是否"真有颜色"）：

| scope | Dark+/Dark Modern 颜色 | 稳妥性 |
|-------|------------------------|--------|
| `entity.other.attribute-name` | 青色/青绿（`#[cfg]` 的 `cfg` 就是这个） | ⭐⭐⭐⭐⭐ |
| `keyword.other` | 品红/紫（allow 在 #keywords 里已用这个兜底） | ⭐⭐⭐⭐⭐ |
| `storage.modifier` | 蓝/品红（export/extern 用这个，颜色稳定） | ⭐⭐⭐⭐⭐ |
| `variable.parameter` | 浅蓝/橙（用于参数名，比 entity.name.label 贴切） | ⭐⭐⭐⭐ |
| `punctuation.section.attribute` | 与其他标点相同（灰色或淡色） | ⭐⭐⭐⭐⭐ |
| `support.function.builtin` | 蓝/青色（@shuffle 就是这个） | ⭐⭐⭐⭐⭐ |
| `constant.other.attribute` | 🌶 某些主题无颜色（当前 allow 里 padding 用的就是这个，可能是白的根因之一） | ⭐⭐ 不稳妥 |
| `meta.*` | ❌ 所有主题基本无颜色（纯容器 scope） | ⭐ 禁止用于着色目标 capture |

**规则**：选 scope 时，避免用 `meta.` 前缀作为着色目标（只当容器时 OK）；避免用 `constant.other.attribute` 这种不常用的（主题未定义时回退默认前景=白）。优先用 `entity.other.attribute-name` / `keyword.other` / `storage.modifier` / `variable.parameter` 这些主流语言（Rust/TS/C++）插件共同使用的 scope——主题作者基本都会给颜色。
