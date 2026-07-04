# Shux Language

VS Code / Cursor 中 `.x`（Shux）语言的完整开发体验扩展。

**当前版本**：`0.2.0` · **引擎要求**：VS Code / Cursor `^1.75.0`

---

## 快速开始

1. **安装扩展** — 从 `.vsix` 安装，或在本目录开发调试（见 [开发与打包](#开发与打包)）。
2. **打开项目根目录** — `File → Open Folder`，选中 shux 仓库根（含 `compiler/`、`core/`、`std/`）。  
   LSP 需要工作区文件夹；仅打开单个文件时语法高亮/片段仍可用，但诊断、跳转、补全不会启动。
3. **准备 `shux` 编译器** — 在仓库根执行：
   ```bash
   make -C compiler bootstrap-driver-seed
   ```
   确认 `compiler/shux` 存在且支持 `--lsp`（`shux-c` 种子编译器**不支持** LSP）。
4. **打开任意 `.x` 文件** — 扩展自动启动 `shux --lsp`；右下角问题面板显示 parse/typeck 诊断。
5. **构建** — `Ctrl+Shift+B`（Mac: `Cmd+Shift+B`）运行 `shux build`。

### 推荐工作区设置

在 `.vscode/settings.json` 中可覆盖默认路径（多仓库或非标准布局时）：

```json
{
  "shux.serverPath": "compiler/shux",
  "shux.compiler.libRoots": [".", "compiler/src", "core", "std"]
}
```

---

## 功能一览

能力分为两类：**扩展内置**（不依赖 LSP）与 **语言服务 LSP**（`shux --lsp`，需工作区 + 可执行 `shux`）。

### 扩展内置

| 类别 | 能力 |
|------|------|
| **编辑器基础** | 语法高亮；25 个代码片段；括号/引号自动闭合；`//` / `/* */` 注释；基于 `language-configuration.json` 的缩进规则 |
| **实时缩进** | 输入 `{` / `}` / 回车 / `:` 时轻量对齐（`shux.features.formatOnType`，可与 LSP 格式化并存） |
| **智能选区扩展** | `Ctrl+Shift+→`（Mac 同）逐级扩大：单词 → 整行 → `{}` 块 → 整个文档 |
| **语义折叠** | 函数体、结构体、枚举、注释块独立折叠 |
| **大纲 / 面包屑** | 函数、结构体（含字段）、枚举（含变体）、trait、import |
| **Import 跳转** | `import lexer;` 等模块路径 Ctrl+Click 打开对应 `.x`（依赖 `shux.compiler.libRoots`） |
| **CodeLens** | `main` 上方 `▶ Run`；结构体/枚举显示字段/变体数；可选 `fn` / `extern fn` 标签 |
| **状态栏** | 右下角 `fn N · st N · en N` 符号计数 |
| **构建任务** | `shux build` / `build (当前文件)` / `run` / `check`，输出自动解析到问题面板 |
| **格式化触发** | 保存 / 粘贴时格式化（`[x]` 语言默认开启）；失去焦点格式化（`shux.features.formatOnBlur`，**默认关闭**） |

### 语言服务（LSP）

由 `shux --lsp` 提供，扩展通过 Pull 诊断在编辑/切换标签页时拉取 `textDocument/diagnostic`：

| 能力 | 说明 |
|------|------|
| **诊断** | parse / typeck 错误与警告，显示在问题面板与编辑器波浪线 |
| **跳转定义** | 符号、import 跨文件定义 |
| **查找引用** | 符号引用列表 |
| **悬停** | 函数签名、结构体字段、类型信息 |
| **补全** | 关键字、当前文件与跨模块符号、类型、路径 |
| **签名帮助** | `func(` 后参数列表，`,` 切换当前参数 |
| **格式化** | `Shift+Option+F` / 保存时 / 粘贴时（`shux.format.*` 控制风格） |

> **说明**：悬停、补全、签名帮助、跳转、引用、LSP 格式化均**仅走语言服务**，扩展不注册本地回退 Provider。LSP 未启动时这些能力不可用，但高亮、片段、任务、折叠等仍正常。

### 语法高亮覆盖

`function` / `struct` / `enum` / `trait` / `let` / `const` / `extern` / `import` 等关键字分色；函数名、调用、结构体名、枚举变体、字段访问、标签、类型、注释、字符串、数字、运算符独立着色。

---

## 安装

### 从 VSIX 安装（用户）

1. `Ctrl+Shift+P`（Mac: `Cmd+Shift+P`）→ **Extensions: Install from VSIX...**
2. 选择 `vscode-shux-<version>.vsix`
3. **Developer: Reload Window** 重载窗口

### 从源码调试（开发者）

1. `cd editors/vscode && npm install && npm run compile`
2. VS Code 打开 `editors/vscode` 目录 → **Run and Debug** → **Launch Extension**
3. 在新窗口中打开 shux 仓库根目录进行测试

打包发布流程见同目录 [打包与安装说明.md](./打包与安装说明.md)。

---

## 配置

`Ctrl+,` 打开设置，搜索 **Shux**。共 **27** 项，分 4 组（LSP / 格式化 / 功能开关 / 编译器）。

### LSP 服务

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.serverPath` | `shux` 可执行路径。支持绝对路径、相对工作区路径（如 `compiler/shux`）、或 `shux`（PATH；若工作区存在 `compiler/shux` 则自动使用） | `compiler/shux` |
| `shux.server.trace` | LSP 通信日志：`off` / `messages` / `verbose`，输出到 **Shux** 通道 | `off` |
| `shux.server.restartOnCrash` | 语言服务进程意外退出时自动重启 | `true` |

### 格式化

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.format.enabled` | 启用 LSP 格式化（关闭后「格式化文档」对 `.x` 无效） | `true` |
| `shux.format.tabSize` | 缩进空格数（1–16） | `2` |
| `shux.format.insertSpaces` | 使用空格而非 Tab | `true` |
| `shux.format.maxLineLength` | 行宽上限，超出时折行（20–512） | `100` |
| `shux.format.insertFinalNewline` | 文件末尾插入换行 | `true` |
| `shux.format.trimTrailingWhitespace` | 清除行尾空格 | `true` |
| `shux.format.trimFinalNewlines` | 压缩末尾多余空行 | `true` |

`[x]` 语言默认：`editor.defaultFormatter` = 本扩展，`editor.formatOnSave` / `editor.formatOnPaste` = `true`。

### 功能开关

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.features.completion` | LSP 智能补全 | `true` |
| `shux.features.signatureHelp` | LSP 函数参数签名提示 | `true` |
| `shux.features.hover` | LSP 悬停提示 | `true` |
| `shux.features.codeLens` | CodeLens（▶ Run、struct/enum 计数） | `true` |
| `shux.features.codeLensFunctionLabels` | 在 `function` / `extern function` 行上方显示 `fn` / `extern fn` 标签 | `false` |
| `shux.features.symbols` | 大纲视图与面包屑 | `true` |
| `shux.features.folding` | 语义代码折叠 | `true` |
| `shux.features.documentLinks` | import 路径可点击跳转 | `true` |
| `shux.features.statusBar` | 状态栏符号统计 | `true` |
| `shux.features.formatOnType` | 输入时实时缩进（OnTypeFormatting） | `true` |
| `shux.features.selectionRange` | 智能选区扩展 | `true` |
| `shux.features.formatOnBlur` | 编辑器失去焦点时格式化上一个 `.x` 文档 | `false` |

### 编译器

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.compiler.diagnosticLevel` | LSP 诊断最低级别：`off` / `error` / `warning` / `info` | `warning` |
| `shux.compiler.extraArgs` | 传给 `shux --lsp` 的额外参数（字符串数组），如 `["--verbose"]` | `[]` |
| `shux.compiler.targetDir` | 编译输出目录（相对工作区根），传给 `--target-dir` | `""` |
| `shux.compiler.libRoots` | import 解析库根目录列表，与 `shux -L` 布局一致；用于 import 跳转与 LSP 跨模块索引 | `[".", "compiler/src", "core", "std"]` |
| `shux.compiler.envJson` | 传给 `shux` 进程的环境变量（**对象**），如 `{ "SHUX_PATH": "/opt/shux" }` | `{}` |

修改 `serverPath`、`libRoots`、`diagnosticLevel`、`targetDir`、`envJson`、`extraArgs` 等后，扩展会提示**重启语言服务**；`server.trace` 可热更新。

---

## 命令

`Ctrl+Shift+P`（Mac: `Cmd+Shift+P`）搜索 **Shux**：

| 命令 | 说明 |
|------|------|
| **Shux: 重启语言服务** | 停止并重新启动 `shux --lsp` |
| **Shux: 显示语言服务输出** | 打开 **Shux** 输出通道（启动日志、LSP trace） |
| **Shux: 打开设置（工作区 settings.json）** | 打开工作区 `.vscode/settings.json`；无工作区时跳转设置 UI |
| **Shux: 运行当前 .x 文件** | 对当前文件执行 `shux run`（与 CodeLens ▶ Run 相同） |
| **Shux: 刷新 CodeLens** | 强制刷新当前 `.x` 的 CodeLens |

---

## 构建任务与错误跳转

`Ctrl+Shift+B` 默认运行 **shux build**。任务面板（`Tasks: Run Task`）还提供：

| 任务 | 说明 |
|------|------|
| **shux build** | 项目级构建 |
| **shux build (当前文件)** | `shux build <当前文件>` |
| **shux run (当前文件)** | 运行当前文件 |
| **shux check (当前文件)** | 类型/语法检查当前文件 |

编译器输出通过 Problem Matcher 解析，支持例如：

- `parse error at 12:5: ...`
- `typeck error: ... at 45:10`
- 通用 `... at file.x:12:5` 格式

点击问题面板条目可跳转到对应行列。

---

## 格式化触发方式

下表「默认状态」仅表示开箱默认开/关；**均可通过设置自行切换**（✅ = 默认开启，⭕ = 默认关闭但支持开启）。

| 触发方式 | 默认状态 | 如何开启 / 配置 |
|----------|----------|-----------------|
| 手动格式化 | ✅ | `Shift+Option+F`（Mac）/ `Shift+Alt+F`（Win/Linux）或右键 → 格式化文档 |
| 保存时格式化 | ✅ | 设置搜 `[x]` → `Editor: Format On Save` |
| 粘贴时格式化 | ✅ | 设置搜 `[x]` → `Editor: Format On Paste` |
| 失去焦点格式化 | ⭕ | 设置搜 `shux.features.formatOnBlur` → 勾选启用；切换标签页或文件时自动格式化刚离开的 `.x` |
| 输入时缩进 | ✅ | `shux.features.formatOnType`（非完整格式化，仅 `{`/`}`/回车时的缩进对齐；可关） |

需要失去焦点也自动排版时，在工作区 `.vscode/settings.json` 中加入：

```json
{
  "shux.features.formatOnBlur": true
}
```

---

## 片段速查

共 **25** 个 Snippets（输入前缀后 Tab 展开）：

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
| `goto` / `panic` | 跳转 / panic |
| `import` | `import module;` |
| `as` | `expr as Type` |
| `/**` | 文档注释块 |

---

## 故障排除

| 现象 | 处理 |
|------|------|
| 无诊断 / 无补全 / 无跳转 | 确认已 **Open Folder** 打开项目根；查看 **Shux** 输出通道是否有启动错误 |
| `当前 shux 不支持 --lsp` | `shux.serverPath` 指向了 `shux-c`；改为 bootstrap 后的 `compiler/shux` |
| `未找到 compiler/shux` | 在仓库根执行 `make -C compiler bootstrap-driver-seed` |
| import Ctrl+Click 失败 | 检查 `shux.compiler.libRoots` 是否包含模块所在目录；修改后重启语言服务 |
| LSP 频繁崩溃 | 设置 `shux.server.trace` 为 `verbose`，复现后查看输出；可暂时关闭 `shux.server.restartOnCrash` 便于定位 |
| 配置改了不生效 | 服务端相关项需执行 **Shux: 重启语言服务**；扩展会弹窗提示 |

---

## 开发与打包

```bash
cd editors/vscode
npm install
npm run compile          # 产出 out/extension.js
npx vsce package         # 生成 vscode-shux-<version>.vsix
```

详细说明（含 node 不在 PATH 时的处理）见 [打包与安装说明.md](./打包与安装说明.md)。

---

## 要求

- VS Code / Cursor `^1.75.0`
- 使用 LSP 与构建任务时，本机可运行 `shux`（PATH 中或通过 `shux.serverPath` 指定；须支持 `--lsp`）
- 建议以**文件夹**方式打开 shux  monorepo 或你的 Shux 项目根目录

## 链接

- 仓库：<https://github.com/shuxliangfu/shux>
- 许可证：MIT
