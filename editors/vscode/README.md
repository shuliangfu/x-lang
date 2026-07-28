# Xlang Language

A complete development experience extension for `.x` (Xlang) language in VS Code, Cursor, and Trae IDE.

**Version**: `0.1.0` · **Engine**: VS Code / Cursor / Trae `^1.75.0` · **License**: Apache-2.0

> The extension UI itself supports 14 languages via `xlang.locale` (auto / en / zh-cn / zh-tw / ja / ko / de / fr / es / ru / pt-br / it / tr / pl). This README is provided in English only to avoid dual-authority drift.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Features](#features)
- [Configuration](#configuration) (32 settings)
- [Commands](#commands)
- [Build Tasks & Error Navigation](#build-tasks--error-navigation)
- [Formatting](#formatting)
- [Internationalization (i18n)](#internationalization-i18n)
- [File Icon Theme](#file-icon-theme)
- [Snippets](#snippets)
- [Troubleshooting](#troubleshooting)
- [Development & Packaging](#development--packaging)
- [Requirements](#requirements)

---

## Quick Start

1. **Install the extension** — from `.vsix`, or run in debug mode (see [Development & Packaging](#development--packaging)).
2. **Open the project root** — `File → Open Folder`, select the xlang repository root (containing `compiler/`, `core/`, `std/`).
   LSP requires a workspace folder; opening a single file still enables syntax highlighting and snippets, but diagnostics, navigation, and completion won't start.
3. **Prepare the `xlang` compiler** — if `compiler/xlang` already exists and supports `--lsp`, skip this step; otherwise run in the repo root:
   ```bash
   make -C compiler bootstrap-driver-seed
   ```
   Verify `compiler/xlang` exists and supports `--lsp` (the `xlang-c` seed compiler does **not** support LSP).
4. **Open any `.x` file** — the extension auto-starts `xlang --lsp`; parse/typeck diagnostics appear in the Problems panel.
5. **Build** — `Ctrl+Shift+B` (Mac: `Cmd+Shift+B`) runs `xlang build`.

### Recommended Workspace Settings

Override defaults in `.vscode/settings.json` (for multi-repo or non-standard layouts):

```json
{
  "xlang.serverPath": "compiler/xlang",
  "xlang.compiler.libRoots": [".", "compiler/src", "core", "std"]
}
```

See [Configuration](#configuration) for all 32 settings.

---

## Features

Capabilities fall into two categories: **Extension Built-in** (no LSP required) and **Language Server (LSP)** (`xlang --lsp`, requires workspace + executable `xlang`).

### Extension Built-in

| Category | Capability |
|----------|-----------|
| **Editor Basics** | Syntax highlighting (including `region`/`with_arena`/`export`/`packed`/`soa`/`align`/`type`/`run`/`spawn`/`unsafe` keywords, `#[no_mangle]`/`#[cfg(...)]`/`#[repr(C)]`/`#[soa]`/`#[alloc]` attributes, `extern "C"`/`extern "X"` ABI annotations, `T[]<label>` lifetime tags, `i8`/`i16`/`u16` narrow ints); 36 snippets; auto-closing brackets/quotes; `//` / `#` / `/* */` comments; indentation rules via `language-configuration.json` |
| **Real-time Indent** | Lightweight alignment on typing `{` / `}` / Enter / `:` (`xlang.features.formatOnType`, coexists with LSP formatting) |
| **Smart Selection** | `Ctrl+Shift+→` (Mac same) progressive expansion: word → line → `{}` block → entire document |
| **Semantic Folding** | Function bodies, structs, enums, traits, impls, comment blocks fold independently; `region`/`with_arena`/`unsafe` blocks tagged as Region kind |
| **Import Navigation** | `import lexer;` and other module paths are Ctrl+Click navigable to corresponding `.x` files (depends on `xlang.compiler.libRoots`) |
| **CodeLens** | `▶ Run` above `main`; struct/enum field/variant counts; trait method counts; optional `fn` / `extern fn` labels; recognizes `export`/`packed`/`soa`/`align(N)`/`extern "C"` prefixes |
| **Status Bar** | Bottom-right `Xlang · fn N · st N · en N · tr N · im N · ty N` symbol counts; `○` indicator when LSP disconnected; `· ✗ N · ⚠ N` diagnostics appended when errors/warnings exist |
| **Global Symbol Search** | `Ctrl+T` searches all `.x` files in workspace for top-level function/struct/enum/trait/impl/type declarations (extension-side local implementation, no LSP dependency) |
| **Document Highlight** | Same-identifier highlighting (Read/Write semantic distinction, highlights all references when cursor is on a variable) |
| **Code Action** | Lightbulb: missing semicolon/bracket QuickFix, comment selection Refactor |
| **Build Tasks** | `xlang build` / `build (current file)` / `run` / `check`, output auto-parsed into Problems panel |
| **Format Triggers** | Format on save / paste (`[x]` language defaults enabled); `maxLineLength` passed to LSP formatter |
| **i18n** | 14 UI languages: auto/en/zh-cn/zh-tw/ja/ko/de/fr/es/ru/pt-br/it/tr/pl, `xlang.locale` overrides VS Code `--locale` |
| **File Icons** | `.x` files, `main.x`, `mod.x`, `compiler/`/`src/` folders have dedicated icons (Xlang Icons theme) |
| **Walkthrough** | 4-step first-run guide: open project → build compiler → open .x file → run file |

### Language Server (LSP)

Provided by `xlang --lsp`; the extension pulls `textDocument/diagnostic` on edit/tab-switch via Pull diagnostics:

| Capability | Description |
|-----------|-------------|
| **Diagnostics** | parse / typeck errors and warnings, shown in Problems panel and editor squiggles |
| **Go to Definition** | Symbol and import cross-file definitions |
| **Find References** | Symbol reference list |
| **Hover** | Function signatures, struct fields, type information |
| **Completion** | Keywords, current-file and cross-module symbols, types, paths |
| **Signature Help** | Parameter list after `func(`, `,` switches active parameter |
| **Formatting** | `Shift+Option+F` / on save / on paste (`xlang.format.*` controls style, including `maxLineLength`) |
| **Rename** | `F2` or right-click Rename Symbol, cross-file rename |
| **Semantic Highlighting** | Semantic-level highlighting (variables/calls/structs overlaid on syntax highlighting, `[x]` default on) |
| **Document Symbol** | Top-level functions, structs, enums (outline; jump targets are placeholders pending LSP enhancement) |

> **Note**: Hover, completion, signature help, go-to-definition, references, LSP formatting, rename, and semantic highlighting are **LSP-only** — the extension registers no local fallback providers. When LSP is not running, these capabilities are unavailable, but highlighting, snippets, tasks, and folding still work normally.

### Syntax Highlighting Coverage

- **Keywords**: `function` / `struct` / `enum` / `trait` / `impl` / `type` / `let` / `const` / `extern` / `export` / `packed` / `soa` / `align` / `region` / `with_arena` / `unsafe` / `if` / `else` / `match` / `while` / `for` / `loop` / `break` / `continue` / `return` / `defer` / `goto` / `panic` / `async` / `await` / `run` / `spawn` / `import` / `self` / `as` / `allow` / `_`
- **Types**: `i8` / `i16` / `i32` / `i64` / `u8` / `u16` / `u32` / `u64` / `usize` / `isize` / `f32` / `f64` / `bool` / `void` / `i32x4` / `i32x8` / `i32x16` / `u32x4` / `u32x8` / `u32x16`
- **Attributes**: `#[no_mangle]` / `#[cfg(...)]` / `#[repr(C)]` / `#[repr(compatible)]` / `#[soa]` / `#[alloc]` / `allow(padding)`
- **ABI Annotations**: `"C"` / `"X"` in `extern "C"` / `extern "X"` colored independently
- **Lifetime Tags**: `<label>` in `T[]<label>` tagged as `storage.modifier.lifetime`
- **Declarations**: Function names, calls, struct names, enum variants, field access, labels colored independently

---

## Configuration

Open settings with `Ctrl+,` (Mac: `Cmd+,`) and search **Xlang**. There are **32** settings across 7 groups: Language / LSP Server / Formatting / Feature Toggles / Compiler / Build / Workspace Symbol.

### Language

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.locale` | UI language: `auto` (follow VS Code `--locale`) / `en` / `zh-cn` / `zh-tw` / `ja` / `ko` / `de` / `fr` / `es` / `ru` / `pt-br` / `it` / `tr` / `pl` | `auto` |

### LSP Server

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.serverPath` | `xlang` executable path. Supports absolute path, relative workspace path (e.g. `compiler/xlang`), or `xlang` (PATH lookup; auto-uses `compiler/xlang` if present in workspace) | `compiler/xlang` |
| `xlang.server.trace` | LSP communication log: `off` / `messages` / `verbose`, output to **Xlang** channel | `off` |
| `xlang.server.restartOnCrash` | Auto-restart language server process on crash | `true` |

### Formatting

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.format.enabled` | Enable LSP formatting (when disabled, Format Document is inactive for `.x`) | `true` |
| `xlang.format.tabSize` | Indent spaces (1–16) | `2` |
| `xlang.format.insertSpaces` | Use spaces instead of tabs | `true` |
| `xlang.format.maxLineLength` | Line width limit, passed to LSP formatter (20–512) | `100` |

`[x]` language defaults: `editor.defaultFormatter` = this extension, `editor.formatOnSave` / `editor.formatOnPaste` = `true`.

### Feature Toggles

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.features.folding` | Semantic code folding | `true` |
| `xlang.features.codeLens` | CodeLens (▶ Run, struct/enum/trait counts) | `true` |
| `xlang.features.codeLensFunctionLabels` | Show `fn` / `extern fn` labels above `function` / `extern function` lines | `false` |
| `xlang.features.codeLensRunButton` | `▶ Run` button above `function main` (constrained by `codeLens` master switch) | `true` |
| `xlang.features.codeLensStructInfo` | struct/enum/trait/impl/type field/variant/method counts (constrained by `codeLens` master switch) | `true` |
| `xlang.features.formatOnType` | Real-time indent on typing (OnTypeFormatting, not full formatting) | `true` |
| `xlang.features.documentLinks` | Clickable import path navigation | `true` |
| `xlang.features.statusBar` | Status bar symbol statistics | `true` |
| `xlang.features.statusBarDiagnostics` | Status bar error/warning counts for current file (constrained by `statusBar` master switch) | `true` |
| `xlang.features.statusBarLspStatus` | Status bar LSP connection indicator (constrained by `statusBar` master switch) | `true` |
| `xlang.features.selectionRange` | Smart selection expansion | `true` |
| `xlang.features.documentHighlight` | Same-identifier highlighting (Read/Write semantic distinction) | `true` |
| `xlang.features.codeAction` | Lightbulb suggestions (QuickFix + Refactor) | `true` |
| `xlang.features.workspaceSymbol` | Global symbol search (Ctrl+T/Cmd+T), scans workspace `.x` top-level declarations | `true` |

### Compiler

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.compiler.diagnosticLevel` | LSP minimum diagnostic level: `off` / `error` / `warning` / `info` | `warning` |
| `xlang.compiler.extraArgs` | Extra args passed to `xlang --lsp` (string array), e.g. `["--verbose"]` | `[]` |
| `xlang.compiler.targetDir` | Compiler output directory (relative to workspace root), passed as `--target-dir` | `""` |
| `xlang.compiler.libRoots` | Import resolution library root directories, aligned with `xlang -L` layout; used for import navigation and cross-module symbol indexing | `[".", "compiler/src", "core", "std"]` |
| `xlang.compiler.envJson` | Environment variables passed to `xlang` process (**object**), e.g. `{ "XLANG_PATH": "/opt/xlang" }` | `{}` |

### Build

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.build.optimizationLevel` | `xlang build` optimization level (via `-O<level>`): `0` / `1` / `2` / `3` | `"0"` |
| `xlang.build.debugInfo` | Generate debug info (`-g`), for debuggers and crash stack traces | `false` |
| `xlang.build.outputName` | Override output binary name (`-o <name>`). Empty uses compiler default | `""` |

Only applies to **Xlang: Build Current .x File** and **Xlang: Build Project** tasks; `run` tasks don't pass `-o` (to avoid overwriting temporary output).

### Workspace Symbol

| Setting | Description | Default |
|---------|-------------|---------|
| `xlang.workspaceSymbol.maxFiles` | Max `.x` files to scan for global symbol search (100–50000) | `2000` |
| `xlang.workspaceSymbol.excludePatterns` | Extra exclude glob patterns (merged with defaults: `node_modules`/`.git`/`out`/`dist`/`target`/`build`) | `[]` |

After changing `serverPath`, `libRoots`, `diagnosticLevel`, `targetDir`, `envJson`, or `extraArgs`, the extension prompts to **restart the language server**; `server.trace` updates live without restart.

---

## Commands

Search **Xlang** in Command Palette (`Ctrl+Shift+P` / Mac: `Cmd+Shift+P`):

| Command | Description |
|---------|-------------|
| **Xlang: Restart Language Server** | Stop and restart `xlang --lsp` |
| **Xlang: Show Language Server Output** | Open the **Xlang** output channel (startup logs, LSP trace) |
| **Xlang: Open Settings (Workspace settings.json)** | Open workspace `.vscode/settings.json`; falls back to Settings UI if no workspace |
| **Xlang: Run Current .x File** | Execute `xlang run` on current file (same as CodeLens ▶ Run) |
| **Xlang: Build Current .x File** | Execute `xlang build` on current file (Build task group) |
| **Xlang: Check Current .x File** | Execute `xlang check` on current file (Test task group) |
| **Xlang: Build Project** | Execute `xlang build` (project-level build) |
| **Xlang: Format Document** | Trigger LSP formatting on current `.x` file |
| **Xlang: Refresh CodeLens** | Force-refresh CodeLens for current `.x` |

---

## Build Tasks & Error Navigation

`Ctrl+Shift+B` runs **xlang build** by default. The task panel (`Tasks: Run Task`) also provides:

| Task | Description |
|------|-------------|
| **xlang build** | Project-level build |
| **xlang build (current file)** | `xlang build <current file>` |
| **xlang run (current file)** | Run current file |
| **xlang check (current file)** | Type/syntax check current file |

Compiler output is parsed via Problem Matcher, supporting formats like:

- `parse error at 12:5: ...`
- `typeck error: ... at 45:10`
- Generic `... at file.x:12:5` format

Click Problems panel entries to jump to the corresponding line/column.

---

## Formatting

| Trigger | Default | How to Configure |
|---------|---------|------------------|
| Manual format | ✅ On | `Shift+Option+F` (Mac) / `Shift+Alt+F` (Win/Linux) or right-click → Format Document |
| Format on save | ✅ On | Search `[x]` in settings → `Editor: Format On Save` |
| Format on paste | ✅ On | Search `[x]` in settings → `Editor: Format On Paste` |
| Indent on type | ✅ On | `xlang.features.formatOnType` (not full formatting; only indent alignment on `{`/`}`/Enter; can be disabled) |

Line width limit is controlled by `xlang.format.maxLineLength` (default 100); the extension passes it to the LSP formatter automatically.

---

## Internationalization (i18n)

The extension UI supports 14 languages via `xlang.locale`:

| Value | Language |
|-------|----------|
| `auto` | Follow VS Code `--locale` (default) |
| `en` | English |
| `zh-cn` | Simplified Chinese |
| `zh-tw` | Traditional Chinese |
| `ja` | Japanese |
| `ko` | Korean |
| `de` | German |
| `fr` | French |
| `es` | Spanish |
| `ru` | Russian |
| `pt-br` | Portuguese (Brazil) |
| `it` | Italian |
| `tr` | Turkish |
| `pl` | Polish |

When `xlang.locale` is set to a non-`auto` value, the extension manually loads the corresponding language bundle, which takes precedence over VS Code `--locale`. No window reload required — the extension auto-reloads language bundles on change.

---

## File Icon Theme

The extension provides the **Xlang Icons** icon theme, with dedicated icons for `.x` files, `main.x`, `mod.x`, and `compiler/`/`src/` folders.

Enable: `Ctrl+Shift+P` → **Preferences: File Icon Theme** → select **Xlang Icons**.

---

## Snippets

36 snippets total (type prefix then Tab to expand):

| Prefix | Expands To |
|--------|------------|
| `func` | `function name(params): i32 { ... }` |
| `extern` | `extern function name(params): i32;` |
| `externc` | `extern "C" function name(params): i32;` |
| `export` | `export function name(params): i32 { ... }` |
| `exportc` | `export extern "C" function name(params): i32;` |
| `nomangle` | `#[no_mangle]\nexport function ...` |
| `cfg` | `#[cfg(target_os = "linux")]\n...` |
| `main` | `function main(): i32 { ... return 0; }` |
| `struct` / `structp` | Struct / struct with `allow(padding)` (fields separated by `,`) |
| `packed` / `soa` | packed / soa struct |
| `type` | `type Name = ...;` |
| `enum` | `enum Name { VARIANT, }` |
| `trait` / `impl` | trait definition / implementation |
| `let` / `const` | Variable / constant declaration |
| `if` / `ife` | if / if-else |
| `while` / `for` / `loop` | Loops |
| `match` | `match (expr) { Variant => ..., _ => ... }` |
| `defer` / `unsafe` / `region` / `with_arena` | Block statements |
| `return` / `break` / `continue` | Control flow statements |
| `goto` / `panic` | Jump / panic |
| `import` | `import module;` |
| `as` | `expr as Type` |
| `/**` | Doc comment block |

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| No diagnostics / completion / navigation | Confirm **Open Folder** was used to open project root; check **Xlang** output channel for startup errors |
| `Current xlang does not support --lsp` | `xlang.serverPath` points to `xlang-c`; change to bootstrap-built `compiler/xlang` |
| `compiler/xlang not found` | Run `make -C compiler bootstrap-driver-seed` in repo root |
| Import Ctrl+Click fails | Check `xlang.compiler.libRoots` includes the module's directory; restart language server after changes |
| LSP crashes frequently | Set `xlang.server.trace` to `verbose`, reproduce, then check output; temporarily disable `xlang.server.restartOnCrash` for debugging |
| Config changes not taking effect | Server-related settings require **Xlang: Restart Language Server**; the extension prompts when needed |
| UI language doesn't switch | Set `xlang.locale` to target language (not `auto`); extension auto-reloads language bundle |
| Icons not showing | `Ctrl+Shift+P` → **Preferences: File Icon Theme** → select **Xlang Icons** |

---

## Development & Packaging

### Prerequisites

- Node.js 16+ and npm
- VS Code `^1.75.0` (or compatible: Cursor, Trae IDE)

### Build from Source

```bash
cd editors/vscode
npm install
npm run compile          # outputs out/extension.js
```

### Debug Launch

1. Open `editors/vscode` folder in VS Code
2. Go to **Run and Debug** (`Ctrl+Shift+D`)
3. Select **Launch Extension** and press `F5`
4. A new Extension Development Host window opens
5. Open the xlang repository root in the new window to test

### Package VSIX

```bash
cd editors/vscode
npm run compile
npx vsce package          # generates vscode-xlang-<version>.vsix
```

If `node` is not in PATH, use the full path: `/usr/local/bin/node npm run compile`.

### Install VSIX

1. `Ctrl+Shift+P` (Mac: `Cmd+Shift+P`) → **Extensions: Install from VSIX...**
2. Select `vscode-xlang-<version>.vsix`
3. **Developer: Reload Window** to reload

### Project Structure

```
editors/vscode/
├── src/                      # TypeScript sources
│   ├── extension.ts          # Entry point: LSP client + feature registration
│   ├── lspClient.ts          # LSP client lifecycle (start/stop/crash-restart)
│   ├── i18n.ts               # Internationalization module (t() function)
│   ├── workspaceSymbol.ts    # Global symbol search (Ctrl+T) provider
│   ├── codelens.ts           # CodeLens provider (Run/struct/enum counts)
│   ├── statusbar.ts          # Status bar (symbol counts + LSP status + diagnostics)
│   ├── tasks.ts              # Build/run/check task provider
│   ├── folding.ts            # Semantic folding range provider
│   ├── formatting.ts         # On-type formatting provider
│   ├── links.ts              # Import path document link provider
│   ├── selection.ts          # Smart selection range provider
│   ├── documentHighlight.ts  # Same-identifier highlight provider
│   ├── codeAction.ts         # CodeAction (QuickFix + Refactor) provider
│   ├── xlangPath.ts           # xlang executable path resolution
│   ├── configSettings.ts     # Config readers (envJson/extraArgs/libRoots)
│   └── importResolve.ts      # Import path resolution
├── syntaxes/
│   └── x.tmLanguage.json     # TextMate grammar (region/lifetime/attribute/ABI)
├── l10n/                     # Language bundles (14 languages)
├── snippets/
│   └── x.json                # 36 code snippets
├── fileicons/
│   └── xlang-icon-theme.json  # Xlang Icons theme
├── package.json              # Extension manifest (32 configurations)
├── package.nls.json          # English config descriptions
├── package.nls.zh-cn.json    # Chinese config descriptions
├── language-configuration.json
└── tsconfig.json
```

### Contributing

1. Fork the repository and create a feature branch
2. Make changes following the existing code style
3. Run `npm run compile` to verify no TypeScript errors
4. Test with `F5` (Launch Extension) in a real xlang workspace
5. Submit a pull request with a clear description of changes

---

## Requirements

- VS Code / Cursor / Trae IDE `^1.75.0`
- A runnable `xlang` binary (in PATH or via `xlang.serverPath`; must support `--lsp`) for LSP and build tasks
- Recommended: open the xlang monorepo or your Xlang project root as a **folder** (not individual files)

---

## Links

- **Repository**: <https://github.com/shuliangfu/x-lang>
- **License**: Apache-2.0
- **Roadmap**: See [完善功能.md](./完善功能.md) for feature completion status and LSP enhancement plans (post-bootstrap)
