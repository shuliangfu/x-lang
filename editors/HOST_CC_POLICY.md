# editors/ host-cc／make policy（§6 10.6 · knife 11.21）

> **Authority** for classifying `editors/**` make and third-party `.c` under the product zero host-cc map.  
> **Status map**: `analysis/终局待办.md` §6 **10.6** · `analysis/自举续办.md`.  
> **Wave rows**: `analysis/自举进度.md` only.

## Non-negotiables (G.7)

| Rule | Meaning |
|------|---------|
| **Not product** | `editors/**` is **never** an input to g05, `./xbuild all`, product link of `xlang` / `xlang_asm` / `xlang-c`, `compiler/**` OBJ lists, or product CI cold/L2 matrices. |
| **Editor-only / 仓外** | tree-sitter grammar, bindings, and `Makefile` exist for **editor integrations** (Neovim／Helix／Emacs／Zed／VS Code). They are **out-of-tree relative to the compiler product chain**（标明仓外）. |
| **No silent product make** | Host `make`／`cc` under `editors/tree-sitter-xlang/` may run only when a human builds the editor package; never as a silent product step. |
| **Generated `src/`** | `editors/tree-sitter-xlang/src/`（含 `parser.c`）is **gitignored generated** output of `tree-sitter generate` — not a product residual. |

## 10.6.1 `editors/tree-sitter-xlang/` — 标明仓外（knife 11.21）

### LOCATE inventory (git-tracked, 2026-11-03)

| Kind | Paths | Product chain? |
|------|-------|----------------|
| Grammar JS | `grammar.js` | **No**（editor） |
| Make | `Makefile` | **No** — builds generated `src/parser.c` + bindings for editors only |
| Node binding | `bindings/node/binding.cc` | **No** |
| Python binding | `bindings/python/tree_sitter_xlang/binding.c` | **No** |
| C headers／pkgconfig | `bindings/c/*`、`bindings/swift/*` | **No** |
| Other bindings | go／rust／swift／package metadata | **No** |
| Generated parser | `src/parser.c`（gitignore） | **No** — local generate only |
| Product compiler | `compiler/**`、g05、`./xbuild` | **Yes — do not touch** |

### Product-path probes (knife 11.21)

- `compiler/scripts/g05_*.sh`、`build.x` PRODUCT_*／COLD_*／LINKER schedules：**0×** `tree-sitter`／`editors/tree-sitter` references as compile inputs.
- `xlang.toml`：`tree-sitter-xlang` dependency remains **commented optional**（未来包管理；非产品链）.
- CI product matrices：**0×** tree-sitter make／cc.

### Disposition

| Option | Ruling |
|--------|--------|
| **标明仓外（this plant）** | ✅ Document + gate：editor-only／not product；Makefile＋binding `.c`／`.cc` stay for editors. |
| **迁走 submodule／独立 release** | ⏸ residual follow-up（非本刀；勿假绿整表删除 bindings） |

**Plant this knife**: policy file + README banner + `build.x` strategy note + zero-make gate checks. **No** mass-delete of bindings；**no** product compiler edits.

## Gate contract (`tests/run-product-path-zero-make-gate.sh`)

Knife 11.21 hard-checks (static):

1. This file exists and states **not product** + **仓外**／editor-only for tree-sitter.
2. Product `g05_*.sh` do **not** reference `editors/tree-sitter` as compile／make inputs.
3. `build.x` strategy map mentions editors tree-sitter／HOST_CC_POLICY／10.6.
4. Tracked binding stubs exist（floor）：`bindings/python/.../binding.c`、`bindings/node/binding.cc`、`Makefile`.

## Out of scope

| Item | Track |
|------|--------|
| Move tree-sitter to submodule／separate release | post-10.6 residual／user-approved |
| Rewrite bindings to pure `.x` | N/A（third-party tree-sitter ABI） |
| Touch `compiler/**` product OBJ／g05 bodies | **Banned** |
