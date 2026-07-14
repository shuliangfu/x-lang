# Shux Language

VS Code / Cursor 中 `.x`（Shux）语言的完整开发体验扩展。

**当前版本**：`0.3.0` · **引擎要求**：VS Code / Cursor `^1.75.0`

---

## 快速开始

1. **安装扩展** — 从 `.vsix` 安装，或在本目录开发调试（见 [开发与打包](#开发与打包)）。
2. **打开项目根目录** — `File → Open Folder`，选中 shux 仓库根（含 `compiler/`、`core/`、`std/`）。
   LSP 需要工作区文件夹；仅打开单个文件时语法高亮/片段仍可用，但诊断、跳转、补全不会启动。
3. **准备 `shux` 编译器** — 若已有 `compiler/shux` 且支持 `--lsp` 则跳过本步；否则在仓库根执行：
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
| **编辑器基础** | 语法高亮（含 `region`/`with_arena`/`export`/`packed`/`soa`/`align`/`type`/`run`/`spawn`/`unsafe` 关键字、`#[no_mangle]`/`#[cfg(...)]`/`#[repr(C)]`/`#[soa]`/`#[alloc]` 属性、`extern "C"`/`extern "X"` ABI 标注、`T[]<label>` lifetime 标签、`i8`/`i16`/`u16` 窄整型）；36 个代码片段；括号/引号自动闭合；`//` / `#` / `/* */` 注释；基于 `language-configuration.json` 的缩进规则 |
| **实时缩进** | 输入 `{` / `}` / 回车 / `:` 时轻量对齐（`shux.features.formatOnType`，可与 LSP 格式化并存） |
| **智能选区扩展** | `Ctrl+Shift+→`（Mac 同）逐级扩大：单词 → 整行 → `{}` 块 → 整个文档 |
| **语义折叠** | 函数体、结构体、枚举、trait、impl、注释块独立折叠；`region`/`with_arena`/`unsafe` 块标为 Region kind |
| **Import 跳转** | `import lexer;` 等模块路径 Ctrl+Click 打开对应 `.x`（依赖 `shux.compiler.libRoots`） |
| **CodeLens** | `main` 上方 `▶ Run`；结构体/枚举显示字段/变体数；trait 显示方法数；可选 `fn` / `extern fn` 标签；识别 `export`/`packed`/`soa`/`align(N)`/`extern "C"` 前缀 |
| **状态栏** | 右下角 `Shux · fn N · st N · en N · tr N · im N · ty N` 符号计数；LSP 未连接时显示 `○` 指示；有诊断时追加 `· ✗ N · ⚠ N`（错误/警告计数） |
| **全局符号搜索** | `Ctrl+T` 搜索工作区所有 `.x` 文件的顶层 function/struct/enum/trait/impl/type 声明（扩展侧本地实现，不依赖 LSP） |
| **DocumentHighlight** | 同符号高亮（Read/Write 语义区分，光标置于变量上时高亮所有引用） |
| **CodeAction** | 灯泡提示：缺分号/缺括号 QuickFix、注释选区 Refactor |
| **构建任务** | `shux build` / `build (当前文件)` / `run` / `check`，输出自动解析到问题面板 |
| **格式化触发** | 保存 / 粘贴时格式化（`[x]` 语言默认开启）；`maxLineLength` 传递给 LSP formatter |
| **多语言 i18n** | 14 种语言：auto/en/zh-cn/zh-tw/ja/ko/de/fr/es/ru/pt-br/it/tr/pl，`shux.locale` 可覆盖 VS Code `--locale` |
| **文件图标** | `.x` 文件、`main.x`、`mod.x`、`compiler/`/`src/` 文件夹有专属图标（Shux Icons 主题） |
| **Walkthrough** | 首次安装时 4 步引导：打开项目 → 构建编译器 → 打开 .x 文件 → 运行文件 |

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
| **格式化** | `Shift+Option+F` / 保存时 / 粘贴时（`shux.format.*` 控制风格，含 `maxLineLength`） |
| **重命名** | `F2` 或右键 Rename Symbol，跨文件重命名 |
| **Semantic Highlighting** | 语义级高亮（变量/调用/结构体等与语法高亮叠加，`[x]` 默认开启） |
| **大纲** | 顶层函数、结构体、枚举（`documentSymbol`，跳转目标暂为占位） |

> **说明**：悬停、补全、签名帮助、跳转、引用、LSP 格式化、重命名、Semantic Highlighting 均**仅走语言服务**，扩展不注册本地回退 Provider。LSP 未启动时这些能力不可用，但高亮、片段、任务、折叠等仍正常。

### 语法高亮覆盖

- **关键字**：`function` / `struct` / `enum` / `trait` / `impl` / `type` / `let` / `const` / `extern` / `export` / `packed` / `soa` / `align` / `region` / `with_arena` / `unsafe` / `if` / `else` / `match` / `while` / `for` / `loop` / `break` / `continue` / `return` / `defer` / `goto` / `panic` / `async` / `await` / `run` / `spawn` / `import` / `self` / `as` / `allow` / `_`
- **类型**：`i8` / `i16` / `i32` / `i64` / `u8` / `u16` / `u32` / `u64` / `usize` / `isize` / `f32` / `f64` / `bool` / `void` / `i32x4` / `i32x8` / `i32x16` / `u32x4` / `u32x8` / `u32x16`
- **属性**：`#[no_mangle]` / `#[cfg(...)]` / `#[repr(C)]` / `#[repr(compatible)]` / `#[soa]` / `#[alloc]` / `allow(padding)`
- **ABI 标注**：`extern "C"` / `extern "X"` 中的 `"C"` / `"X"` 独立着色
- **Lifetime 标签**：`T[]<label>` 中的 `<label>` 标为 `storage.modifier.lifetime`
- **声明**：函数名、调用、结构体名、枚举变体、字段访问、标签独立着色

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

`Ctrl+,` 打开设置，搜索 **Shux**。共 **32** 项，分 7 组（语言 / LSP 服务 / 格式化 / 功能开关 / 编译器 / 构建 / 全局符号搜索）。

### 语言

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.locale` | 界面语言：`auto`（跟随 VS Code `--locale`）/ `en` / `zh-cn` / `zh-tw` / `ja` / `ko` / `de` / `fr` / `es` / `ru` / `pt-br` / `it` / `tr` / `pl` | `auto` |

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
| `shux.format.maxLineLength` | 行宽上限，传递给 LSP formatter（20–512） | `100` |

`[x]` 语言默认：`editor.defaultFormatter` = 本扩展，`editor.formatOnSave` / `editor.formatOnPaste` = `true`。

### 功能开关

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.features.folding` | 语义代码折叠 | `true` |
| `shux.features.codeLens` | CodeLens（▶ Run、struct/enum/trait 计数） | `true` |
| `shux.features.codeLensFunctionLabels` | 在 `function` / `extern function` 行上方显示 `fn` / `extern fn` 标签 | `false` |
| `shux.features.codeLensRunButton` | `function main` 上方 `▶ Run` 按钮（受 `codeLens` 总开关约束） | `true` |
| `shux.features.codeLensStructInfo` | struct/enum/trait/impl/type 字段/变体/方法计数（受 `codeLens` 总开关约束） | `true` |
| `shux.features.formatOnType` | 输入时实时缩进（OnTypeFormatting，非完整格式化） | `true` |
| `shux.features.documentLinks` | import 路径可点击跳转 | `true` |
| `shux.features.statusBar` | 状态栏符号统计 | `true` |
| `shux.features.statusBarDiagnostics` | 状态栏显示当前文件错误/警告计数（受 `statusBar` 总开关约束） | `true` |
| `shux.features.statusBarLspStatus` | 状态栏显示 LSP 连接指示器（受 `statusBar` 总开关约束） | `true` |
| `shux.features.selectionRange` | 智能选区扩展 | `true` |
| `shux.features.documentHighlight` | 同符号高亮（Read/Write 语义区分） | `true` |
| `shux.features.codeAction` | 灯泡提示（QuickFix + Refactor） | `true` |
| `shux.features.workspaceSymbol` | 全局符号搜索（Ctrl+T/Cmd+T），扫描工作区 `.x` 顶层声明 | `true` |

### 编译器

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.compiler.diagnosticLevel` | LSP 诊断最低级别：`off` / `error` / `warning` / `info` | `warning` |
| `shux.compiler.extraArgs` | 传给 `shux --lsp` 的额外参数（字符串数组），如 `["--verbose"]` | `[]` |
| `shux.compiler.targetDir` | 编译输出目录（相对工作区根），传给 `--target-dir` | `""` |
| `shux.compiler.libRoots` | import 解析库根目录列表，与 `shux -L` 布局一致；用于 import 跳转与 LSP 跨模块索引 | `[".", "compiler/src", "core", "std"]` |
| `shux.compiler.envJson` | 传给 `shux` 进程的环境变量（**对象**），如 `{ "SHUX_PATH": "/opt/shux" }` | `{}` |

### 构建

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.build.optimizationLevel` | `shux build` 优化级别（通过 `-O<level>`）：`0` / `1` / `2` / `3` | `"0"` |
| `shux.build.debugInfo` | 生成调试信息（`-g`），便于调试器与崩溃栈追溯 | `false` |
| `shux.build.outputName` | 覆盖输出二进制名（`-o <name>`）。留空使用编译器默认 | `""` |

仅作用于 **Shux: 构建当前 .x 文件** 与 **Shux: 构建项目** 任务；`run` 任务不传 `-o`（避免覆盖临时输出）。

### 全局符号搜索

| 设置 | 说明 | 默认 |
|------|------|------|
| `shux.workspaceSymbol.maxFiles` | 全局符号搜索扫描 `.x` 文件上限（100–50000） | `2000` |
| `shux.workspaceSymbol.excludePatterns` | 额外排除 glob 模式（与默认 `node_modules`/`.git`/`out`/`dist`/`target`/`build` 合并） | `[]` |

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
| **Shux: 构建当前 .x 文件** | 对当前文件执行 `shux build`（Build 任务组） |
| **Shux: 检查当前 .x 文件** | 对当前文件执行 `shux check`（Test 任务组） |
| **Shux: 构建项目** | 执行 `shux build`（项目级构建） |
| **Shux: 格式化文档** | 对当前 `.x` 文件触发 LSP 格式化 |
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

| 触发方式 | 默认状态 | 如何开启 / 配置 |
|----------|----------|-----------------|
| 手动格式化 | ✅ | `Shift+Option+F`（Mac）/ `Shift+Alt+F`（Win/Linux）或右键 → 格式化文档 |
| 保存时格式化 | ✅ | 设置搜 `[x]` → `Editor: Format On Save` |
| 粘贴时格式化 | ✅ | 设置搜 `[x]` → `Editor: Format On Paste` |
| 输入时缩进 | ✅ | `shux.features.formatOnType`（非完整格式化，仅 `{`/`}`/回车时的缩进对齐；可关） |

行宽上限通过 `shux.format.maxLineLength`（默认 100）控制，扩展会自动传递给 LSP formatter。

---

## 多语言（i18n）

扩展支持 14 种界面语言，通过 `shux.locale` 配置：

| 值 | 语言 |
|----|------|
| `auto` | 跟随 VS Code `--locale`（默认） |
| `en` | English |
| `zh-cn` | 简体中文 |
| `zh-tw` | 繁體中文 |
| `ja` | 日本語 |
| `ko` | 한국어 |
| `de` | Deutsch |
| `fr` | Français |
| `es` | Español |
| `ru` | Русский |
| `pt-br` | Português (Brasil) |
| `it` | Italiano |
| `tr` | Türkçe |
| `pl` | Polski |

设置 `shux.locale` 为非 `auto` 时，扩展会手动加载对应的语言包，优先级高于 VS Code `--locale`。修改后无需重启窗口，扩展会自动重载语言包。

---

## 文件图标主题

扩展提供 **Shux Icons** 图标主题，为 `.x` 文件、`main.x`、`mod.x`、`compiler/`/`src/` 文件夹提供专属图标。

启用方式：`Ctrl+Shift+P` → **Preferences: File Icon Theme** → 选择 **Shux Icons**。

---

## 片段速查

共 **36** 个 Snippets（输入前缀后 Tab 展开）：

| 前缀 | 展开 |
|------|------|
| `func` | `function name(params): i32 { ... }` |
| `extern` | `extern function name(params): i32;` |
| `externc` | `extern "C" function name(params): i32;` |
| `export` | `export function name(params): i32 { ... }` |
| `exportc` | `export extern "C" function name(params): i32;` |
| `nomangle` | `#[no_mangle]\nexport function ...` |
| `cfg` | `#[cfg(target_os = "linux")]\n...` |
| `main` | `function main(): i32 { ... return 0; }` |
| `struct` / `structp` | 结构体 / 带 `allow(padding)` 结构体（字段用 `,` 分隔） |
| `packed` / `soa` | packed / soa 结构体 |
| `type` | `type Name = ...;` |
| `enum` | `enum Name { VARIANT, }` |
| `trait` / `impl` | trait 定义 / 实现 |
| `let` / `const` | 变量 / 常量声明 |
| `if` / `ife` | if / if-else |
| `while` / `for` / `loop` | 循环 |
| `match` | `match (expr) { Variant => ..., _ => ... }` |
| `defer` / `unsafe` / `region` / `with_arena` | 块语句 |
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
| 界面语言不切换 | 设置 `shux.locale` 为目标语言（非 `auto`），扩展自动重载语言包 |
| 图标不显示 | `Ctrl+Shift+P` → **Preferences: File Icon Theme** → 选择 **Shux Icons** |

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
- 建议以**文件夹**方式打开 shux monorepo 或你的 Shux 项目根目录

## 链接

- 仓库：<https://github.com/shuxliangfu/shux>
- 许可证：MIT
