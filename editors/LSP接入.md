# XLANG LSP 接入指南

XLANG 语言服务（LSP）内置于 `xlang` 编译器进程，通过 `--lsp` 子命令进入 stdio JSON-RPC 模式。本文档面向所有编辑器客户端（VSCode / Neovim / Vim），统一描述服务端能力、启动协议、配置项与故障排查。

> 权威来源：[compiler/src/lsp/lsp.x](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp.x)、[lsp_io.x](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp_io.x)、[lsp_diag.x](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp_diag.x)、[editors/vscode/src/lspClient.ts](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/lspClient.ts)。如本文与代码冲突，以代码为准。

## 1. 架构与传输

- **进程模型**：客户端以子进程方式启动 `xlang --lsp`，子进程 stdin/stdout 即 LSP 通道；stderr 由客户端自行捕获到 Output 通道。
- **传输协议**：标准 LSP base protocol——每条消息带 `Content-Length: <n>\r\n\r\n` 头，正文为 UTF-8 JSON-RPC 2.0。
- **单条 body 上限**：1 MiB（[lsp.x](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp.x) 中 `LSP_BODY_CAP = 1048576`）。超长消息会被丢弃，循环读下一条。
- **诊断模式**：仅 **Pull**（`textDocument/diagnostic`），未实现 Push（`textDocument/publishDiagnostics`）。客户端必须支持 3.17 Pull 模式，否则 Problems 面板不会更新。
- **生命周期**：客户端发 `initialize` → `initialized` → 业务请求 → `shutdown`（服务端回 `null`）→ `exit`（服务端退出，退出码 0）。`exit` 在未收到 `shutdown` 时不会触发退出，避免误关。

## 2. 服务端能力清单

下表是 [lsp.x#lsp_main_impl](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp.x) 实际 dispatch 的全部 method。未列出者（如 `codeAction`、`signatureHelp`、`inlayHint`）**未实现**，客户端不要声明依赖。

| Method | 类型 | 说明 |
| --- | --- | --- |
| `initialize` | request | 返回 capabilities + serverInfo，由 C 侧 `lsp_build_initialize_result` 构造 |
| `initialized` | notification | 握手完成，无响应 |
| `shutdown` | request | 回 `null`，置 `shutdown_requested` 标志 |
| `exit` | notification | 仅当已 `shutdown` 时退出主循环 |
| `textDocument/didOpen` | notification | 从 body 提取 `"text"` 并存为当前文档（[lsp_io.x#extract_document_text](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp_io.x)） |
| `textDocument/didChange` | notification | 同上，整体替换文档（不支持增量 range patch） |
| `textDocument/didSave` | notification | 仅消费，不触发重算 |
| `textDocument/didClose` | notification | 释放文档缓冲，使诊断缓存失效 |
| `textDocument/diagnostic` | request | 对文档跑 `.x` 前端（parse + typeck），收集 `driver_diagnostic_*` 转写为 `Diagnostic[]` |
| `textDocument/definition` | request | 光标在函数名/调用处 → 跳到 `function <name>` 定义；不支持跨文件 |
| `textDocument/references` | request | 全量扫描 arena 找 `EXPR_CALL` 同 `func_index` 调用点；上限 512 条 |
| `textDocument/hover` | request | 返回 (line,col) 处表达式的 `resolved_type_ref` 文本；不支持 doc 注释 |
| `textDocument/completion` | request | 基于当前文档符号 + 关键字补全（粗粒度） |
| `textDocument/documentSymbol` | request | 文档大纲（function/struct/enum/trait/let/const） |
| `textDocument/semanticTokens/full` | request | delta 五元组，覆盖 var/call/struct_lit/enum_variant/lit/field/as |
| `textDocument/rename` | request | 基于 `WorkspaceEdit` 重命名（同文件内） |
| `textDocument/formatting` | request | 走 `lsp_fmt_pure_thin.x`，`maxLineLength` 从 `FormattingOptions` body 读取 |
| `$/cancelRequest` | notification | 静默消费，无实际取消语义（请求仍在跑完） |
| `workspace/didChangeConfiguration` | notification | 使诊断缓存失效 |

**未实现** 的常见 method（避免误用）：`textDocument/rangeFormatting`、`textDocument/onTypeFormatting`（VSCode 扩展侧自己实现）、`textDocument/codeAction`、`textDocument/signatureHelp`、`textDocument/inlayHint`、`textDocument/semanticTokens/range`、`textDocument/prepareRename`、`workspace/symbol`。

## 3. 启动参数与环境变量

### 命令行参数

```
xlang --lsp [--diagnostic-level=<level>] [--target-dir=<path>] [<extra-args>...]
```

- `--lsp`（必需）：进入 LSP 主循环。`xlang-c` 不识别此 flag，[lspClient.ts#validateXlangLanguageServer](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/lspClient.ts) 在启动前用 2 秒探针检测，发现 `unknown option --lsp` 即拒绝启动。
- `--diagnostic-level=<off|error|warning|info>`：诊断过滤阈值，默认 `warning`。
- `--target-dir=<path>`：编译产物目录（影响 import 解析的相对路径）。
- 额外参数：透传给前端，例如 `--lib-name` 等（老 seed 可能不支持，扩展侧用 `xlang.compiler.extraArgs` 传入，遇到不支持的 flag 须自行探针）。

### 环境变量

| 变量 | 用途 |
| --- | --- |
| `XLANG_LSP_LIB_ROOTS` | 库根目录，**冒号分隔**（Unix）/ 分号分隔（Windows）。由客户端从 `xlang.compiler.libRoots` 数组 join 后注入。默认 `[".", "compiler/src", "core", "std"]` |
| `XLANG_COMPILE_STD_USE_C=1` | 强制使用 xlang-c 编译 `std/*.o`，确保与测试程序同源（见 project memory） |
| `XLANG_LEGACY_C_FRONTEND=1` | C 前端构建；**注意：此构建产物 xlang-c 不支持 `--lsp`**，必须用 X pipeline 构建的 `compiler/xlang` |
| `CC=gcc` | Windows/MinGW 必需（系统无 `cc`） |
| `TEMP=C:/xlang_tmp` | Windows 短路径，避免 gcc 内部子进程 TEMP 被截断 |

## 4. 构建

在 macOS / Ubuntu 上，从仓库根目录执行：

```
make -C compiler bootstrap-driver-seed
```

产物为 [compiler/xlang](file:///home/shuliangfu/worker/shu/shux/compiler/xlang)。该产物内置 LSP 服务（[lsp.x](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp.x) 等 `.x` 源被 bootstrap 编译进二进制），可直接用 `--lsp` 启动。

Windows 必须使用 `XLANG_LEGACY_C_FRONTEND=1` 构建的 `xlang-c.exe` 作为编译器（`xlang.exe` 是 stub），但 **作为 LSP server 的最终产物必须是支持 `--lsp` 的 X pipeline 构建**。具体构建链见 `compiler/` 下的构建脚本。

验证启动是否正常：

```
echo -e 'Content-Length: 0\r\n\r\n' | timeout 2 ./compiler/xlang --lsp
# 正常：进程阻塞等待 stdin（被 timeout 杀掉，退出码 124）
# 异常：打印 "unknown option --lsp" → 你用的是 xlang-c，换 compiler/xlang
```

## 5. VSCode 接入（内置）

VSCode 扩展 [editors/vscode](file:///home/shuliangfu/worker/shu/shux/editors/vscode) 已内置 LSP 客户端，无需额外配置即可使用。

### 最小配置

在 `.vscode/settings.json` 中：

```json
{
  "xlang.serverPath": "compiler/xlang",
  "xlang.server.restartOnCrash": true,
  "xlang.server.trace": "off",
  "xlang.compiler.libRoots": [".", "compiler/src", "core", "std"],
  "xlang.compiler.diagnosticLevel": "warning",
  "xlang.format.enabled": true,
  "xlang.format.tabSize": 2,
  "xlang.format.maxLineLength": 100
}
```

### serverPath 解析规则

[xlangPath.ts#resolveServerCommand](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/xlangPath.ts) 的优先级：

1. 绝对路径：原样使用；
2. 含路径分隔符的相对路径：相对工作区根目录解析；
3. 配置为 `"xlang"` 且工作区存在 `compiler/xlang`：自动改用本仓库产物（monorepo 开发体验）；
4. 其他：原样返回，交给 `PATH` 查找。

### 特性开关

[extension.ts#loadHeavyFeatures](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/extension.ts) 按 `xlang.features.*` 注册 Provider。LSP 自身的能力（诊断/定义/引用/悬停/补全/大纲/语义高亮/重命名/格式化）直接走 `LanguageClient`，无需扩展侧 Provider；以下为 **扩展侧本地实现** 的轻量增强，与 LSP 并行：

- `features.folding` / `formatOnType` / `documentLinks` / `selectionRange` / `documentHighlight` / `codeAction` / `codeLens` / `statusBar` / `workspaceSymbol`

`workspaceSymbol`（Ctrl+T）是扩展本地扫文件实现，不依赖 LSP；保存 `.x` 时失效缓存。

### 命令

| 命令 | 说明 |
| --- | --- |
| `xlang.restartServer` | 停止并重新启动 LSP 子进程（改完 `serverPath` / `libRoots` 后用） |
| `xlang.showServerOutput` | 打开 Xlang Output 通道 |
| `xlang.runFile` / `xlang.buildFile` / `xlang.checkFile` / `xlang.buildProject` | 走 `vscode.Task` + problem matcher `$xlang-parse` / `$xlang-typeck` |
| `xlang.formatDocument` | 显式调用 LSP formatting provider |

### 崩溃自动重启

[lspClient.ts#startXlangLanguageClient](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/lspClient.ts) 监听 `onDidChangeState`：`Running → Stopped` 且非用户主动 stop 时，自动 `client.start()`。`xlang.server.restartOnCrash: false` 关闭。

### 配置热更新

修改 `xlang.serverPath` / `libRoots` / `extraArgs` / `diagnosticLevel` / `targetDir` / `envJson` / `restartOnCrash` 会触发弹窗 `Restart Now / Later`；只改 `trace` 会即时 `setTrace`，不重启。

## 6. Neovim 接入（builtin LSP）

Neovim 0.8+ 自带 `vim.lsp`，无需插件。

```lua
-- ~/.config/nvim/lua/lsp/xlang.lua
local lsp = vim.lsp
local util = lsp.handlers.util or vim.lsp.util

lsp.config('xlang', {
  cmd = function()
    -- 优先用工作区内的 compiler/xlang，否则 PATH 中的 xlang
    local ws = vim.fn.getcwd()
    local local_xlang = ws .. '/compiler/xlang'
    if vim.fn.executable(local_xlang) == 1 then
      return { local_xlang, '--lsp' }
    end
    return { 'xlang', '--lsp' }
  end,
  filetypes = { 'x' },
  root_dir = function(bufnr, on_dir)
    -- 以 .git 或 compiler/xlang 作为工作区根
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(util.root_pattern('.git', 'compiler/xlang')(fname) or vim.fs.dirname(fname))
  end,
  -- Pull 诊断（Neovim 0.10+ 支持）
  -- 老版本 Neovim 不发 textDocument/diagnostic，Problems 不会更新；请升级到 0.10+
  settings = {},
  init_options = {},
  -- 库根通过环境变量注入
  before_init = function(_, config)
    config.cmd_env = config.cmd_env or {}
    config.cmd_env.XLANG_LSP_LIB_ROOTS = table.concat({
      '.', 'compiler/src', 'core', 'std',
    }, ':')
  end,
})

-- 启用
vim.cmd('LspEnable xlang')
```

关键点：

- `filetypes = { 'x' }`：需先在 `runtimepath` 中加载 XLANG 的 `ftdetect/xlang.vim`（[editors/vim/ftdetect/xlang.vim](file:///home/shuliangfu/worker/shu/shux/editors/vim/ftdetect/xlang.vim)），否则 Neovim 不识别 `.x`。
- Pull 诊断要求 Neovim ≥ 0.10；旧版本只能依赖 `vim.diagnostic` 的 Push，而服务端不发 Push，所以无诊断显示。
- `key=K` 悬停、`gd` 跳转、`gr` 引用、`<C-x><C-o>` 补全都走标准 LSP keymap，按 Neovim 文档配置即可。

## 7. Vim 接入（coc.nvim）

[coc.nvim](https://github.com/neoclide/coc.nvim) 通过 `coc-settings.json` 配置自定义 server：

```json
{
  "languageserver": {
    "xlang": {
      "command": "xlang",
      "args": ["--lsp"],
      "filetypes": ["x"],
      "rootPatterns": [".git", "compiler/xlang"],
      "InitializationOptions": {},
      "settings": {},
      "env": {
        "XLANG_LSP_LIB_ROOTS": ".:compiler/src:core:std"
      }
    }
  }
}
```

如果工作区里有 `compiler/xlang`，可把 `command` 改为绝对路径避免 PATH 问题：

```json
"command": "${workspaceFolder}/compiler/xlang"
```

coc.nvim 默认走 Push 诊断（`textDocument/publishDiagnostics`），但 XLANG LSP 只支持 Pull，所以 **诊断不会自动显示**。需要：

- 升级 coc.nvim 到支持 Pull diagnostic 的版本；或
- 在 coc 中通过 `diagnostic.pull` 相关配置显式启用 Pull；或
- 改用 Neovim builtin LSP（见 §6）。

## 8. Vim 接入（vim-lsp）

[prabirshrestha/vim-lsp](https://github.com/prabirshrestha/vim-lsp)：

```vim
if executable('xlang')
  augroup xlang_lsp
    autocmd!
    autocmd User lsp_setup call lsp#register_server('xlang', {
      \ 'cmd': {server -> ['xlang', '--lsp']},
      \ 'allowlist': ['x'],
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), '.git'))},
      \ 'initialization_options': {},
      \ 'workspace_config': {},
      \ 'env': {'XLANG_LSP_LIB_ROOTS': '.:compiler/src:core:std'},
      \ })
  augroup END
endif
```

注意：vim-lsp 同样以 Push 诊断为主，Pull 支持请查阅其最新文档。本仓库的 [vim/autoload/xlang.vim](file:///home/shuliangfu/worker/shu/shux/editors/vim/autoload/xlang.vim) 已在 `omnifunc` 中预留 "LSP 接管后自动降级" 的注释，但实际并未集成任何 LSP 客户端——Vim 用户需自行选用上述之一。

## 9. 故障排查

### 9.1 启动失败：`unknown option --lsp`

```
[Xlang] xlang.serverPath is empty / Current xlang does not support --lsp (commonly xlang-c).
```

**根因**：`xlang.serverPath` 指向了 `xlang-c`（C 前端 legacy 构建），它不识别 `--lsp`。

**修复**：改用 X pipeline 构建的 `compiler/xlang`：

```json
{ "xlang.serverPath": "compiler/xlang" }
```

或绝对路径 `/abs/path/to/xlang`。验证：`/abs/path/to/xlang --lsp`（应阻塞，2 秒后被超时杀掉）。

### 9.2 诊断不显示 / Problems 面板空

**根因**：客户端不支持 Pull 诊断（`textDocument/diagnostic`），而服务端不发 Push。

**修复**：

- VSCode：`vscode-languageclient` ≥ 8.1，已在 [package.json#dependencies](file:///home/shuliangfu/worker/shu/shux/editors/vscode/package.json) 中固定。
- Neovim：≥ 0.10。
- coc.nvim / vim-lsp：检查版本是否支持 Pull。

### 9.3 跳转/引用找不到

**根因**：

- `definition` / `references` 仅在 **当前文档** 内扫描（[lsp_diag.x#lsp_diag_definition_at](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp_diag.x)），不支持跨文件索引。
- 光标必须在 `function <name>` 标识符上、或某个 `EXPR_CALL` 调用点上；落在空白/字面量上不会命中。

### 9.4 文档过大导致消息丢失

单条 body 上限 1 MiB。超过的请求会被静默丢弃（`content_len > LSP_BODY_CAP` 时 `continue`）。表现：保存大文件后诊断不更新、formatting 不生效。

**临时缓解**：拆分文件。根因修复需调整 `LSP_BODY_CAP` 并重新 bootstrap。

### 9.5 `XLANG_LSP_LIB_ROOTS` 不生效

- 必须作为 **环境变量** 注入子进程，不是 `initializationOptions` 或 `workspace` 配置。
- 分隔符：Unix 用 `:`，Windows 用 `;`。
- VSCode 扩展在 [extension.ts#buildServerEnv](file:///home/shuliangfu/worker/shu/shux/editors/vscode/src/extension.ts) 自动从 `xlang.compiler.libRoots` 拼接注入；其他客户端需手动 join。

### 9.6 Windows 路径被截断

Windows 上 gcc 内部子进程的 `TEMP` 被截断会导致 LSP 启动子编译失败。必须设 `TEMP=C:/xlang_tmp`（短路径）。

### 9.7 ARM64 / macOS 大响应损坏

历史 bug：栈上缓冲 + 大 JSON 输出在 ARM64 上溢出。已在 [lsp.x#lsp_main_impl](file:///home/shuliangfu/worker/shu/shux/compiler/src/lsp/lsp.x) 中将 `initialize` 响应改用堆 `diag_ptr`，`formatting` / `completion` / `documentSymbol` / `semanticTokens` / `rename` 共用 `format_ptr`（堆 256 KiB）。若再次出现响应截断，检查这两个缓冲是否仍为堆分配。

### 9.8 查看 LSP 日志

- VSCode：`Xlang: Show Server Output` 命令，或设 `"xlang.server.trace": "verbose"` 后看 Output 面板 `Xlang` 通道。
- Neovim：`vim.lsp.set_log_level('debug')`，日志在 `:lua print(vim.lsp.get_log_path())`。
- coc.nvim：`:CocOpenLog`。

## 10. 约束与注意事项

- **诊断缓存**：服务端对文档做哈希缓存（`lsp_diag_invalidate_cache`），`didChange` / `didSave` / `didClose` / `workspace/didChangeConfiguration` 都会失效缓存。客户端不要省略这些通知。
- **增量同步**：`didChange` 只支持 **整体替换**（`contentChanges` 取第一个的 `text`），不支持 range patch。客户端必须发完整文档。
- **跨文件能力**：当前所有请求都在单文档内完成，无 workspace 索引。`workspace/symbol` 未实现，VSCode 的 Ctrl+T 是扩展侧本地扫文件。
- **取消请求**：`$/cancelRequest` 被静默消费，服务端不会真的中断正在跑的解析；客户端不要依赖取消语义做超时控制。
- **bootstrap 一致性**：服务端用 `.x` pipeline 处理文档，与编译命令行 `xlang build` 同源；若用户混用 `xlang-c` 编译，类型检查结果可能与服务端诊断不一致。统一用 `compiler/xlang` 即可。
