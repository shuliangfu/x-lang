# Shux Language

VS Code / Cursor 中 `.sx`（Shux）语言的完整开发体验扩展。

## 功能一览

### 编辑器基础

- **语法高亮** — `function`/`struct`/`enum`/`trait`/`let`/`const`/`extern`/`import` 关键字分色；函数名/调用/结构体名/枚举变体/字段访问/标签/类型独立着色；注释/字符串/数字/运算符全覆盖
- **代码片段** — 25 个 Snippets：`func`/`extern`/`main`/`struct`/`structp`/`enum`/`trait`/`impl`/`let`/`const`/`if`/`ife`/`while`/`for`/`loop`/`match`/`defer`/`return`/`break`/`continue`/`goto`/`panic`/`import`/`as`/`/**`
- **实时缩进** — 打完 `{` 回车自动多缩进一级，输入 `}` 自动对齐匹配 `{`，`=>`/`->` 臂下一行额外缩进
- **智能选区扩展** — `Ctrl+Shift+→` 逐级扩大选区：单词 → 整行 → `{}` 块 → 整个文档
- **保存时格式化** — 默认开启，保存 `.sx` 文件即自动格式化
- **失去焦点格式化** — 切走编辑器时自动格式化上一个 `.sx` 文档

### 代码导航

- **大纲视图** — 函数、结构体（含字段展开）、枚举（含变体展开）、trait、import
- **面包屑导航** — 编辑器顶部显示当前所在函数 / 结构体层级
- **语义折叠** — 按函数体、结构体、枚举、注释块独立折叠
- **Import 可点击跳转** — `import lexer;` 中的模块路径 Ctrl+Click 直接打开对应 `.sx` 源文件

### 代码理解

- **悬停提示** — 鼠标悬停函数名 → 签名 + 文档注释，悬停结构体名 → 全部字段，悬停变量 → 声明类型
- **函数参数提示** — 输入 `func(` 自动弹出参数签名，`,` 切换高亮参数
- **智能补全** — 上下文感知：关键字、当前文件函数/结构体/字段、类型名补全、模块路径补全
- **CodeLens** — main 函数上方显示 `▶ Run`（点击运行），结构体显示字段数，枚举显示变体数
- **状态栏统计** — 右下角实时显示当前文件的 `fn N · st N · en N` 计数

### 构建与诊断

- **构建任务** — `Ctrl+Shift+B` 一键 `shux build`，另有 `shux build（当前文件）`、`shux run`、`shux check`
- **错误跳转** — 编译器输出 `parse error at 12:5: ...` / `typeck error: ... at 45:10` 自动解析到问题面板，点击跳转
- **LSP** — 诊断、定义跳转、查找引用、Hover、格式化

---

## 安装

1. `Ctrl+Shift+P`（Mac: `Cmd+Shift+P`），输入 **Extensions: Install from VSIX...**
2. 选择 `.vsix` 文件
3. 重载窗口

---

## 配置

`Ctrl+,` 打开设置，搜索 **Shux**，共 27 个配置项，分为 5 组：

### LSP 服务
| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.serverPath` | shux 可执行路径（默认 `compiler/shux`，相对工作区根目录） | `compiler/shux` |
| `shux.server.trace` | LSP 通信日志：`off` / `messages` / `verbose` | `off` |
| `shux.server.restartOnCrash` | 语言服务崩溃时自动重启 | `true` |

### 格式化
| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.format.enabled` | 启用格式化 | `true` |
| `shux.format.tabSize` | 缩进空格数（1–16） | `2` |
| `shux.format.insertSpaces` | 使用空格而非 Tab | `true` |
| `shux.format.maxLineLength` | 行宽上限（20–512） | `100` |
| `shux.format.insertFinalNewline` | 文件末尾加换行 | `true` |
| `shux.format.trimTrailingWhitespace` | 清除行尾空格 | `true` |
| `shux.format.trimFinalNewlines` | 压缩末尾空行 | `true` |

### 功能开关
| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.features.completion` | 智能补全（关键字/函数/结构体/字段/路径） | `true` |
| `shux.features.signatureHelp` | 函数参数签名提示 | `true` |
| `shux.features.hover` | 悬停提示 | `true` |
| `shux.features.codeLens` | CodeLens 行内提示 | `true` |
| `shux.features.symbols` | 大纲视图和面包屑导航 | `true` |
| `shux.features.folding` | 语义代码折叠 | `true` |
| `shux.features.documentLinks` | import 路径可点击跳转 | `true` |
| `shux.features.statusBar` | 状态栏符号统计 | `true` |
| `shux.features.formatOnType` | 实时缩进 | `true` |
| `shux.features.selectionRange` | 智能选区扩展 | `true` |
| `shux.features.formatOnBlur` | 失去焦点时自动格式化 | `true` |

### 编译器
| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.compiler.diagnosticLevel` | 诊断级别：`off` / `error` / `warning` / `info` | `warning` |
| `shux.compiler.extraArgs` | 额外命令行参数（数组） | `[]` |
| `shux.compiler.targetDir` | 编译器输出目录 | `""` |
| `shux.compiler.envJson` | 传递给 shux 的环境变量（JSON 字符串，如 `{"SHUX_PATH":"/path"}`） | `{}` |

---

## 命令

`Ctrl+Shift+P` 可执行：

| 命令 | 说明 |
|------|------|
| **Shux: 重启语言服务** | 强制重启 LSP |
| **Shux: 显示语言服务输出** | 打开 LSP 调试输出面板 |
| **Shux: 打开 Shux 设置** | 跳转到 Shux 设置页面 |
| **Shux: 运行当前 .sx 文件** | `shux run` 当前文件 |

---

## 格式化触发方式

| 触发方式 | 默认 | 配置 |
|----------|------|------|
| 手动格式化 | ✅ | `Shift+Option+F` 或右键 → 格式化文档 |
| 保存时格式化 | ✅ 默认开启 | 设置搜 `[sx]` → `Editor: Format On Save` |
| 粘贴时格式化 | ✅ 默认开启 | 设置搜 `[sx]` → `Editor: Format On Paste` |
| 失去焦点格式化 | ✅ 默认开启 | `shux.features.formatOnBlur` |

---

## 片段速查

| 前缀 | 展开 |
|------|------|
| `func` | `function name(params): i32 { ... }` |
| `extern` | `extern function name(params): i32;` |
| `main` | `function main(): i32 { ... return 0; }` |
| `struct` / `structp` | 结构体 / 带 `allow(padding)` 结构体 |
| `enum` | `enum Name { VARIANT, }` |
| `trait` / `impl` | trait 定义 / 实现 |
| `let` / `const` | 变量 / 常量声明 |
| `if` / `ife` | if / if-else |
| `while` / `for` / `loop` | 循环 |
| `match` | `match (expr) { Variant => ..., _ => ... }` |
| `defer` | defer 块 |
| `return` / `break` / `continue` | 控制流语句 |
| `goto` / `panic` | 跳转 / 异常 |
| `import` | `import module;` |
| `as` | `expr as Type` |
| `/**` | 文档注释 |

---

## 要求

- VS Code / Cursor `^1.75.0`
- 使用 LSP 时需本机可运行 `shux`（PATH 中或通过 `shux.serverPath` 指定路径）
