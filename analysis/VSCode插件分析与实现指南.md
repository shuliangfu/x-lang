# VSCode 插件分析与实现指南（.x / Shux）

> 本文档分析如何为 Shux（.x）编写 VSCode 扩展，实现代码高亮、语言配置，以及可选的语法/类型检测与代码导航。与项目宗旨「开发简单易上手」一致，优先提升编辑体验。

---

## 一、目标与范围

### 1.1 当前缺口

- **无代码高亮**：.x 文件在 VSCode 中无语法着色，可读性差。
- **无语言识别**：编辑器不把 .x 当作独立语言（注释、括号配对、折叠等均无）。
- **无语检测**：编辑时无法实时看到 shux 的语法/类型错误。
- **无代码跟踪**：无「转到定义」「查找引用」等 LSP 能力。

### 1.2 分阶段目标

| 阶段 | 内容 | 优先级 | 依赖 |
|------|------|--------|------|
| **P0** | 语法高亮 + 语言配置 | 高 | 无，仅需 TextMate 语法与 language-configuration |
| **P1** | 语检测（问题面板显示 shux 报错） | 中 | 可调用 shux 或通过 LSP 对接编译器 |
| **P2** | 代码跟踪（跳转定义、引用） | 低 | LSP + 编译器或独立解析器提供符号信息 |

建议先做 **P0**，再视需要做 P1/P2。

---

## 二、VSCode 扩展结构概览

### 2.1 最小扩展目录

本仓库扩展位于 **`editors/vscode/`**：

```
editors/vscode/
├── package.json                 # 扩展清单：id、名称、语言贡献
├── README.md
├── language-configuration.json # 注释、括号、折叠、wordPattern
├── .vscodeignore               # 打包时排除文件（可选）
└── grammars/
    └── sx.tmLanguage.json      # TextMate 语法（高亮规则）
```

无需 TypeScript/JavaScript 入口即可实现 P0；P1/P2 需 `extension.js` 或 Language Server。

### 2.2 package.json 要点

- **publisher / name / displayName**：扩展标识与展示名。
- **contributes.languages**：注册语言 id（如 `su`）、扩展名 `.x`、别名 `shux`。
- **contributes.grammars**：关联 `scopeName`、语言 id、语法文件路径。
- **contributes.languages[].configuration**：指向 `language-configuration.json`。
- **activationEvents**：可设为 `onLanguage:su`，打开 .x 时再激活（若仅有静态贡献可省略 `main`）。

示例片段：

```json
{
  "name": "vscode-shux",
  "displayName": "Shux Language",
  "contributes": {
    "languages": [{
      "id": "su",
      "extensions": [".x"],
      "aliases": ["Shux", "su"]
    }],
    "grammars": [{
      "language": "su",
      "scopeName": "source.x",
      "path": "./grammars/sx.tmLanguage.json"
    }]
  }
}
```

---

## 三、语法高亮（TextMate Grammar）

### 3.1 原理

TextMate 语法用正则与作用域名（scope names）标记区间，VSCode 再根据主题把作用域映射为颜色。只需定义「哪些区间是关键字、类型、字面量、注释」等，无需写解析器。

### 3.2 .x 需要覆盖的类别

参考 `docs/01-关键字.md`、`compiler/include/token.h`，至少包括：

| 类别 | scope 建议 | 示例 |
|------|------------|------|
| 关键字（声明/控制流） | `keyword.control.x`, `keyword.other.x` | function, let, const, if, else, while, for, return, import, struct, enum, trait, impl, match, defer, goto, panic, break, continue, loop, extern, self, _ |
| 类型名（内建） | `support.type.x` | i32, i64, u8, u32, u64, usize, isize, bool, f32, f64, void |
| 布尔字面量 | `constant.language.x` | true, false |
| 整数字面量 | `constant.numeric.x` | 0, 42 |
| 浮点字面量 | `constant.numeric.x` | 0.0, 1.5 |
| 行注释 | `comment.line.x` | // ... |
| 块注释（若有） | `comment.block.x` | /* ... */ |
| 字符串字面量 | `string.quoted.x` | "..." |
| 标识符/函数名 | 默认即可，或 `variable.other.x`, `entity.name.function.x` |
| 运算符/符号 | `keyword.operator.x` 或留默认 | +, -, ->, =>, :, ;, [, ], {, }, (, ) |

### 3.3 语法文件结构（sx.tmLanguage.json）

- **scopeName**：`source.x`（根）。
- **patterns**：按顺序匹配；常用：
  - **include**：引用内建 `#comments`、`#strings` 等，或自定义 repository。
  - **repository**：命名子规则（如 `keywords`、`types`、`numbers`），用 `match` 配正则、`captures` 赋 scope。
- 关键字用一条正则或多项 `match`，注意**先匹配长符号**（如 `=>`、`->`、`==`、`!=`）再匹配单字符，避免把 `=` 吃进 `==`。

示例（片段）：

```json
{
  "$schema": "https://raw.githubusercontent.com/martinring/tmlanguage/master/tmlanguage.json",
  "name": "Shux",
  "scopeName": "source.x",
  "patterns": [
    { "include": "#comments" },
    { "include": "#keywords" },
    { "include": "#types" },
    { "include": "#literals" },
    { "include": "#strings" }
  ],
  "repository": {
    "comments": {
      "patterns": [{
        "name": "comment.line.x",
        "match": "//.*$"
      }]
    },
    "keywords": {
      "patterns": [{
        "name": "keyword.control.x",
        "match": "\\b(function|let|const|if|else|while|for|return|break|continue|loop|match|defer|goto|panic|import|struct|enum|trait|impl|extern|self)\\b"
      }]
    },
    "types": {
      "patterns": [{
        "name": "support.type.x",
        "match": "\\b(i32|i64|u8|u32|u64|usize|isize|bool|f32|f64|void)\\b"
      }]
    }
  }
}
```

完整关键字/类型列表以 `token.h`、`docs/01-关键字.md` 为准，可再补向量类型（i32x4 等）、运算符（`as` 等）。

---

## 四、语言配置（language-configuration.json）

用于括号配对、注释切换、折叠、行选等，不涉及高亮。

| 配置项 | 说明 | .x 建议 |
|--------|------|----------|
| **comments.lineComment** | 行注释 | `//` |
| **comments.blockComment** | 块注释 | `["/*", "*/"]`（若 lexer 支持） |
| **brackets** | 括号配对 | `["{", "}", "[", "]", "(", ")"]` |
| **autoClosingPairs** | 输入左括号自动补右括号 | 同上，可选 |
| **surroundingPairs** | 选中后包一层 | 同上 |
| **folding** | 折叠区域 | `markers.start` / `end` 可用 `{` / `}` |
| **wordPattern** | 标识符/单词边界 | 如 `[a-zA-Z_][a-zA-Z0-9_]*`，便于双击选词 |

---

## 五、语检测与代码跟踪（P1/P2，可选）

### 5.1 语检测（P1）

- **方式 A**：**任务**（Task）— 用户手动运行「用 shux 检查当前文件」，输出解析到「问题」面板（需解析 shux 的 stderr）。
- **方式 B**：**Language Server（LSP）** — 后台跑 shux（或封装为 LSP），对保存/打开的文件发 `textDocument/didOpen` 等，返回 `Diagnostic[]`；VSCode 通过 `vscode-languageclient` 连接。
- **方式 C**：**Code Action / 命令** — 提供「检查当前 .x 文件」命令，调用 shux 并把错误以 `vscode.Diagnostic` 写入 `vscode.diagnostics`。

推荐先做 **方式 A 或 C**（不引入 LSP 也能看到错误）；需要更好体验再上 LSP。

### 5.2 代码跟踪（P2）

需要**符号与位置信息**：函数/变量定义、引用。可选实现：

- **方案 1**：**LSP** — 自写或复用 LSP 实现，内部调用 shux 的 parser（或 C 库）得到 AST，实现 `textDocument/definition`、`textDocument/references`。
- **方案 2**：**shux 提供 LSP 模式** — 在 compiler 中增加「LSP 前端」：读 LSP 请求、调现有 parse/typeck、返回符号与位置；VSCode 扩展只起客户端作用。

两者都依赖编译器或独立解析器，工作量较大，建议在 P0（高亮+语言配置）稳定后再做。

---

## 六、实现步骤建议

1. **扩展目录**：本仓库已使用 `editors/vscode/` 作为扩展根目录。
2. **编写 package.json**：注册语言 `su`、扩展名 `.x`、grammar、language-configuration。
3. **编写 grammars/sx.tmLanguage.json**：按第三节与 token.h/01-关键字 补全关键字、类型、字面量、注释、字符串、运算符。
4. **编写 language-configuration.json**：注释、括号、wordPattern、折叠。
5. **本地安装**：`vsce package` 打 vsix 后在 VSCode 中「从 VSIX 安装」，或 F5 从扩展开发主机调试。
6. **（可选）P1**：增加命令或任务，调用 shux 并展示诊断；或接入 LSP。

---

## 七、与项目其它部分的关系

- **不依赖自举**：P0 仅依赖现有 .x 语法与关键字文档，与「三、自举与 .x 迁移」无先后关系。
- **文档一致**：关键字、类型、注释形式以 `docs/01-关键字.md`、`compiler/include/token.h`、`docs/08-语法规范.md` 为准，语法文件与之一致即可。
- **本仓库位置**：扩展位于 `editors/vscode/`，与编译器同仓，便于同步发布与文档一致。

---

## 八、参考

- [VSCode 扩展 API：语言扩展](https://code.visualstudio.com/api/language-extensions/overview)
- [TextMate 语法规范](https://macromates.com/manual/en/language_grammars)（VSCode 使用兼容的 JSON 格式）
- [language-configuration 官方说明](https://code.visualstudio.com/api/language-extensions/language-configuration-guide)
- 本项目：`docs/01-关键字.md`、`docs/08-语法规范.md`、`compiler/include/token.h`、`compiler/src/lexer/lexer.c`（关键字与注释识别）
