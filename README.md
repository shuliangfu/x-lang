# Shux

> **Write high-performance, memory-safe code in a modern language** — C-like type and execution model; simple, readable syntax; safety and speed via *explicit contracts + fewer undefined behaviors + safe by default*, not heavy type theory.

| Item | Description |
|------|-------------|
| **Language** | Shux |
| **Compiler** | `shux` / `shux_asm` (product binary after bootstrap) |
| **Source extension** | `.x` |
| **Build config** | `build.x` — project build strategy in Shux (steps, targets, products); entry via `shux build` / `build_tool` / `shux-build.sh` |
| **Status (2026-07-18)** | **Product L4 pin** dual green @ **`c51759eb`** (true cold + bstrict **123/123** macOS+Ubuntu). Daily tip **`48ef9833`** + product-path fixes: dual L2 bstrict **123/123** again (logs `/tmp/{mac,ubuntu}_bstrict_v4.log`). Recent L2 closes: i64 CTFE fold gate, `/* */` recovery, borrow/lifetime baselines, g05 hybrid-slice poison. **Self-host not finished** (seed / hybrid C still required for cold start; tip L4 not re-pinned) |
| **Live dashboard** | [`analysis/自举进度.md`](analysis/自举进度.md) · daily snapshot [`analysis/当前进度.md`](analysis/当前进度.md) |
| **中文** | [README_zh-CN.md](README_zh-CN.md) |

---

## 1. Positioning

Shux is a **systems language**: no GC, zero-cost abstractions, explicit memory model. Generated code aims to match or beat careful C. Versus C: cleaner syntax, diagnostics with locations, integrated toolchain. Versus Rust: a deliberately smaller type system that stays **explicit enough** at the hard edges (nullability, bounds, ownership/borrow, aliasing) so the compiler can prove safety and optimize.

### Goals

| Goal | Meaning |
|------|---------|
| **Performance** | No GC; ASM backend (default) + optional C backend; alias / `noalias` feed autovec and DCE |
| **Memory safety** | Safe subset: no leaks, dangling refs, OOB, or data races by default; auditable `unsafe` |
| **Lightweight** | Few deps; small binaries; freestanding/embedded; std linked on demand |
| **Standard library** | Full `core/` + `std/`; one API surface across platforms (impl details under `std.sys`) |
| **Learnability** | Much simpler than C-at-scale; gentle curve, integrated tools |
| **Self-hosting** | End state: compiler + std 100% `.x`; host C / seed only for cold start (in progress, not claimed complete) |

### Design stance

- **Aim**: extreme performance where it matters.
- **Discipline**: maintainable code, simple development, **memory safety** (no silent UB in the safe subset).

Design notes: [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md), [`analysis/需求分析.md`](analysis/需求分析.md).

---

## 2. Language sketch

### Types and semantics

- **Primitives**: `i8`/`i16`/`i32`/`i64`, `u8`/`u16`/`u32`/`u64`, `f32`/`f64`, `bool`, `usize`/`isize`
- **Structs and generics**: monomorphized generics; trait / impl
- **Nullability / errors**: `Option<T>`, `Result<T, E>` (prefer over raw nullable C pointers)
- **Slices**: `T[]` carries length; region forms `T[]<label>` with escape checks
- **Modules**: `import("std.io")` / `import("core.mem")`; directory = module, entry `mod.x`
- **Field access**: only `.` in Shux source (not `->`; C `->` is codegen’s job when the base is a pointer)

### Memory and safety

- **No GC**: stack + heap + arena; compile-time region / linear / borrow checks
- **Compile-time help**: `defer`, `owned`, scoped allocators (`with_arena`), SROA, BCE
- **Graded safety**: safe by default; raw pointers and low-level syscalls only in `unsafe { ... }`
- **Alias analysis**: `noalias` and borrow gates for autovec / DCE

See [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md), [`analysis/安全与性能.md`](analysis/安全与性能.md).

### Platforms

- Conditional compilation (`#if` / target branches)
- **One API, multi-OS** (Linux / macOS primary; Windows probes / B-hybrid)
- Freestanding: `-freestanding` (nostdlib static, Linux x86_64 path)
- Targets such as `x86_64-linux`, `arm64-macos` (`-target`)

Syntax index: [`docs/README.md`](docs/README.md).

---

## 3. Quick start

### Requirements

- **Linux** (x86_64 gold standard) or **macOS**
- Host C toolchain (`cc` / `clang`) for link and cold-start seed
- Optional: Docker for Linux gates

### First-time build

```bash
# Recommended: pinned seeds → build_tool → daily shux
make -C compiler build-tool
./shux-build.sh first-time          # build_tool + ./build_tool ./shux
# Or: cd compiler && ./build_tool ./shux

# Cold start with cc only: cd compiler && sh bootstrap.sh

# Full seed driver (LSP / product chain common path):
make -C compiler bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### Daily build

```bash
# Daily: G-05 path → shux_asm relink gold
./shux-build.sh build
# Or: cd compiler && ./build_tool ./shux

export SHUX=./compiler/shux_asm   # prefer this-wave product binary
./tests/run-hello.sh

# Heavier rebuild after backend/seed changes
./shux-build.sh full              # or make -C compiler bootstrap-driver-bstrict
```

| Entry | Use |
|-------|-----|
| `./shux-build.sh build` / `./build_tool ./shux` | **Daily incremental** (default) |
| `./shux-build.sh full` | Full B-strict-style rebuild |
| `make -C compiler …` | Cold start, CI, low-level targets |

**Product binary**: after a proper build, use **`compiler/shux_asm`** (often mirrored as `compiler/shux`).  
`shux-c` / seed helpers are for **cold start and transition**, not the daily release story.

### Hello World

```x
// Hello World — void main implies process exit 0 (Zig-like).
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

```bash
export SHUX=./compiler/shux_asm
$SHUX examples/hello.x
$SHUX build examples/hello.x -o hello && ./hello
$SHUX check examples/hello.x
```

More samples: [`examples/`](examples/) (io, net, async, json, compress, …).

### Acceptance tests

```bash
export SHUX=./compiler/shux_asm
./tests/run-all.sh                 # full regression (when appropriate)
SHUX_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # product gate suite (~125 scripts)
./tests/run-linux-a09-a11-gate.sh  # Linux gold bootstrap subset (Docker OK)
# Linux x86_64 freestanding S4 smoke (return42 / panic / hello):
./tests/run-freestanding-hello.sh
```

For **self-host / product release claims**, the project requires **L4 true cold** (wipe all `.o` under `compiler`/`std`/`core`, rebuild binaries) **plus** dual-platform `run-all-bstrict` green. Details: skill / [`analysis/自举方法.md`](analysis/自举方法.md) · [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md).  
**Note:** daily L2 green on tip ≠ tip L4 pin. **Release pin stays `c51759eb`** until the next dual true cold re-pin. Tip may already show dual L2 bstrict green after product-path fixes (see §8).

---

## 4. Compiler CLI

Default backend: **ASM** (`-backend asm`).

| Command | Description |
|---------|-------------|
| `shux file.x` | Compile and run (`shux run`) |
| `shux build` | Read `build.x`, run build runner |
| `shux build file.x -o exe` | Compile to executable |
| `shux check file.x` | Parse + typeck only |
| `shux fmt file.x` | Format |
| `shux test [script]` | Run tests (default `tests/run-all.sh`) |
| `shux --lsp` | Language server (stdio JSON-RPC) |
| `shux -E file.x` | Emit C (debug) |
| `shux -backend c file.x` | Force C backend |
| `shux -O2 file.x -o app` | Optimize (default **-O2**) |
| `shux -freestanding …` | Linux x86_64 nostdlib static |
| `shux -h` | Help |

Root [`build.x`](build.x) describes what to build. Daily entry: `./shux-build.sh` / `build_tool`.

---

## 5. Repository layout

```
shux/
├── README.md / README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x / shux-build.sh
├── analysis/                 # process docs + RFCs (当前进度 / 自举方法 / 自举步骤 / 问题分析 / 自举进度 …)
├── docs/                     # language syntax (user-facing)
├── compiler/                 # compiler (.x + seed C / glue)
│   ├── src/                  # lexer, parser, typeck, codegen, asm, pipeline, driver, lsp
│   ├── seeds/                # cold-start pins
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_shux_asm, g05, relink, …
├── core/                     # OS-free core library
├── std/                      # OS-facing standard library (product .x; no handwritten std .c)
├── tests/                    # regressions and gates
├── examples/
├── tools/
├── editors/vscode/           # VS Code / Cursor / Trae + LSP client
└── mcp/
```

- **core/** does not depend on **std/**; **std/** may depend on **core/**
- Module rule: **directory = module**, entry `mod.x`

Architecture: [`analysis/构架分析.md`](analysis/构架分析.md).

---

## 6. Standard library

### core (no OS)

| Module | Role |
|--------|------|
| `core.types` | `size_of` / `align_of`, layout |
| `core.mem` | memory ops |
| `core.option` / `core.result` | option / result |
| `core.slice` / `core.str` | slices and string views |
| `core.fmt` / `core.debug` | format / debug |
| `core.builtin` / `core.iterator` / `core.cmp` | builtins, iteration, compare |

Full list: [`docs/07-内置与标准库.md`](docs/07-内置与标准库.md).

### std (OS-facing)

Product sources under `std/` are **`.x`** (Phase F: no handwritten `.c`/`.h` in `std/`). Categories include:

| Category | Examples |
|----------|----------|
| Basics | `std.io`, `std.fs`, `std.path`, `std.process`, `std.env` |
| Containers | `std.vec`, `std.map`, `std.set`, `std.queue` |
| Memory | `std.heap`, `std.mem` |
| Concurrency | `std.thread`, `std.sync`, `std.channel`, `std.async` |
| Networking | `std.net`, `std.http`, `std.websocket` |
| Data | `std.json`, `std.csv`, `std.compress`, `std.db` |
| System | `std.sys` (Linux / macOS; Windows WIP) |
| Utilities | `std.test`, `std.fmt`, `std.log`, `std.cli`, `std.crypto`, … |

Link is **on demand** (unused modules stay out of the final link when possible).

---

## 7. Compiler architecture

```
.x source
  → preprocess (#if / import)
  → lexer → parser → AST
  → typeck (generics, borrow, region, …)
  → codegen (ASM default, or C via -E / -backend c)
  → host link → executable / .o
```

| Path | Meaning |
|------|---------|
| **User / product path** | This-SHA `shux_asm` compiles user `.x` → `-o` / run; matrix + bstrict |
| **Bootstrap / engineering path** | Seed cold start → `build_shux_asm` / g05 → optional Stage2 / WPO dogfood |

**Two tracks (do not mix when reading status):**

| Track | What it measures | Alone enough to claim “self-host done”? |
|-------|------------------|----------------------------------------|
| **Product** | L4 true cold + product matrix (rv / option / hello / …) + dual `run-all-bstrict` 123 | **Required**, not sufficient alone for “zero C forever” |
| **Engineering** | prove T/N, Cap residual pure, Stage2, WPO chain/link/text gates | **No** |

---

## 8. Self-host status (snapshot · 2026-07-18 · evening)

> **Authoritative live numbers**: [`analysis/自举进度.md`](analysis/自举进度.md) · daily [`analysis/当前进度.md`](analysis/当前进度.md).  
> README only summarizes; **do not** treat Stage2 / prove / WPO / daily L2 green as a tip L4 re-pin or as “self-host done”.

### Product track

| Item | Status |
|------|--------|
| **L4 release pin** | **`c51759eb`** — dual-host **true cold** + `run-all-bstrict` **123/123** (Ubuntu + macOS). Previous pin lineage includes `f16f7d48` / older `5c8204ae`-era waves — **do not** re-cite those as the live pin |
| Ubuntu L4 + full bstrict | ✅ **123/123** @ pin (`/tmp/ubuntu_true_cold_c51759eb.log`, `/tmp/ubuntu_true_bstrict_c51759eb.log`) |
| macOS L4 + full bstrict | ✅ **123/123** @ pin (`/tmp/mac_true_cold_c51759eb.log`, `/tmp/mac_true_bstrict_c51759eb.log`) |
| Gold host | **Ubuntu x86_64** |
| Product binary under test | This-wave `compiler/shux_asm` (g05 / relink) — **never** leftover Stage2 `shux_asm2` or old `stage1` |
| Branch tip (not tip L4) | **`48ef9833`** on `self-hosting` (+ local product-path worktree when present). **Tip L4 is re-pinned only after dual true cold + bstrict**, not after every L2 green |
| Latest dual L2 bstrict (tip wave) | ✅ **123/123** macOS + Ubuntu after product relink (`SHUX_BSTRICT_SKIP_BUILD=1`; `/tmp/mac_bstrict_v4.log`, `/tmp/ubuntu_bstrict_v4.log`, `EXIT:0`). **≠** tip L4 re-pin |

### Product surface recently closed (daily L2 · pin still `c51759eb`)

On the **user product path** (`shux_asm` / freestanding / gates). Green L2 **does not** auto-raise the L4 pin:

| Area | Status |
|------|--------|
| **i64 CTFE** (`run-i64-ctfe-gate`) | ✅ fold only when value fits `i32` (`glue_ctfe_fits_i32`); `INT64_MIN` no longer truncates to 0 → wrong exit |
| **Block comments / docblocks** | ✅ `/* … */` recovery in parse seed; keep docblocks — do not “fix” by stripping comments |
| **Borrow / lifetime baselines** | ✅ `type-borrow-conflict` + `lang-lifetime-diag` gates green with updated baselines |
| **g05 link discipline** | ✅ do not merge hybrid RT slices over permanent cold slices (avoids CG002 / wrong-binary after relink) |
| **Gate docs restored** | ✅ e.g. `analysis/安全与性能.md` required by product gates (not archive-only) |
| Freestanding S4 / `std.vec` / soft XT001 | ✅ earlier L2 closes still hold (`run-freestanding-hello`, SysV MEMORY param home, …) |
| NL-07 no-libc | ✅ L1–L10 + v5 on product pin (crt0 / soft libm / pure static matrix) |
| Hosted asm matrix | ✅ return-value / hello / option / stdlib-import (+ related L2 probes) on Ubuntu gold |

### Engineering track (subset)

| KPI / gate | Status |
|------------|--------|
| **T** typeck surface | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **54/54** |
| Cap residual pure | major waves closed on product pin lineage |
| **D Stage2** | ✅ freestanding / parity (**≠** full product g05 chain) |
| Stage2 **WPO** chain + strict-link + text-gate | ✅ engineering green (Ubuntu; some Darwin N/A) |

### What is *not* claimed

- **Not** “compiler is 100% `.x` with zero seed”
- **Not** “Stage2 `shux_asm2` is the product compiler”
- **Not** “engineering WPO green = tip product L4”
- **Not** “dual L2 bstrict on tip = tip L4” — pin stays **`c51759eb`** until dual **true cold** re-pin
- Final physical zero-C / full seed elimination (**G**) remains roadmap, not the weekly claim surface

Methodology: Cap / R / L / M → [`analysis/自举方法.md`](analysis/自举方法.md). Ops: [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md). Discipline: [`AGENTS.md`](AGENTS.md) + skill `shux-selfhost-product-gate`.

### Near-term front row (high level)

1. Land tip product-path work (i64 CTFE / block-comment / g05 ensure / baselines) in reviewable commits  
2. Optional next product map only after green dual L2; **re-pin tip L4** only with dual true cold + bstrict  
3. Side residuals when they block a product surface: ABI polish, cfg-extern / labi edges — **no** soft-skip typeck, **no** dual authority

---

## 9. Milestones

| Milestone | Content | Status |
|-----------|---------|--------|
| M0 | Lexer, AST, Parser | ✅ |
| M1 | Typeck, Codegen, Driver | ✅ |
| M2 | import, core/std subset, multi-target | ✅ |
| M3 | Generics, trait, modules, std growth | ✅ |
| M4 | DCE, -O2/-Os, size/perf baseline | ✅ partial |
| M5 | Bootstrap (compiler can rebuild itself) | 🟡 **usable product path + advanced self-host**; **seed still required for cold start** |
| **Now** | Product L4 dual pin @ **`c51759eb`**; tip dual L2 bstrict **123/123** @ **`48ef9833`** wave; product residuals (CTFE / comments / g05) closed on L2 | See dashboard |

---

## 10. Documentation map

| Document | Role |
|----------|------|
| [`analysis/自举进度.md`](analysis/自举进度.md) | **KPI dashboard** (must update each wave) |
| [`analysis/当前进度.md`](analysis/当前进度.md) | Daily snapshot / front row |
| [`analysis/自举方法.md`](analysis/自举方法.md) | Cap / R / L / M method |
| [`analysis/自举步骤.md`](analysis/自举步骤.md) | Executable gates |
| [`docs/README.md`](docs/README.md) | Language docs index |
| [`analysis/需求分析.md`](analysis/需求分析.md) | Goals, perf & safety strategy |
| [`analysis/构架分析.md`](analysis/构架分析.md) | Repo / compiler layout |
| [`analysis/性能压榨.md`](analysis/性能压榨.md) | Perf layers / dogfood |
| [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md) | Self-host ops |
| [`editors/vscode/README.md`](editors/vscode/README.md) | Editor plugin + LSP |
| [`AGENTS.md`](AGENTS.md) | Contributor / agent rules (root-cause, dual authority, platforms) |

Many RFCs live under `analysis/` (http, async, WPO, …).

---

## 11. Testing and quality

| Suite | Command |
|-------|---------|
| Full regression | `./tests/run-all.sh` |
| Product bstrict | `SHUX=./compiler/shux_asm SHUX_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| Pre-push P0 | `SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh` |
| Linux gold subset | `./tests/run-linux-a09-a11-gate.sh` |
| Topic gates | `tests/run-*-gate.sh` |
| Compile dogfood | `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

Baselines: `tests/baseline/`. When running **true cold full tests**, log paths should be printed for operators (e.g. `/tmp/*true_cold*`, `/tmp/*true_bstrict*`).

### Perf snapshot (historical · 2026-07-09 · Linux x86_64)

Fair wall-time medians vs `clang -O2` (warmup 3 + 20 rounds). See suite docs under `analysis/perf-*` for refresh procedure.

| Benchmark | ratio (SHUX / C) | Note |
|-----------|------------------|------|
| `loop_i32` | ~0.87 | ✅ |
| `mem_copy` | ~0.87 | ✅ |
| `struct_param` | ~0.08 | ✅ |
| `call_boundary` (fold) | ~0.00 | compile-time affine fold |
| `call_boundary` (real) | ~1.77 | ❌ — stack-heavy ASM; regalloc still weak |

Diff cases D1–D6: 5/6 pass; float D4 still a known P2 placeholder.

---

## 12. Tooling

| Component | Path |
|-----------|------|
| VS Code / Cursor / Trae | [`editors/vscode/`](editors/vscode/) |
| LSP | `shux --lsp` · `compiler/src/lsp/` |
| MCP | [`mcp/`](mcp/) |

Plugin install: [`editors/vscode/README.md`](editors/vscode/README.md).

---

## 13. Contributing

1. Clone → `make -C compiler build-tool && ./shux-build.sh first-time` (or full bootstrap-driver path).  
2. Daily edits → `./shux-build.sh build`, set `SHUX=./compiler/shux_asm`, run relevant tests/gates.  
3. Product / link / SHARED changes → **Ubuntu gold** (and mac when SHARED); for release claims use **L4 true cold** + dual bstrict.  
4. Commits: Conventional Commits (`feat:` / `fix:` / `docs:` …), English preferred for code comments in `.x` (see `AGENTS.md` / G.9).  
5. **No dual authority**: seed and `.x` product surfaces move **same commit** when both exist.  
6. **No false green**: do not claim self-host complete from prove/Stage2/WPO alone.

**Main line resolution**: prioritize self-host / product gates over large new std features; IR v4 architecture is frozen for post-bootstrap work.

---

## 14. License

Shux uses **layered licensing** (language libraries permissive; compiler copyleft). See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).

| Layer | Paths | License |
|-------|--------|---------|
| A — Toolchain | `compiler/`, `tools/`, root `build*.x` | **AGPL-3.0-or-later** ([`LICENSE.AGPL-3.0`](LICENSE.AGPL-3.0)) |
| B — Language libs | `core/`, `std/` | **Apache-2.0** ([`LICENSE.Apache-2.0`](LICENSE.Apache-2.0)) |
| Samples | `examples/`, `tests/` | **Apache-2.0** |
| Editors | `editors/vscode` | **MIT** |
| Editors | `editors/tree-sitter-shux`, `editors/vim` | **Apache-2.0** |
| Third-party | `compiler/seeds/crypto/ed25519/` (orlp) | **zlib** |

**Intent:** programs you write that use `core`/`std` are not forced under AGPL. Modifying or redistributing the **compiler/toolchain** is AGPL (or commercial terms).

Contributing terms: [`CONTRIBUTING.md`](CONTRIBUTING.md).

### Commercial licensing (Layer A only)

For **AGPL exemption on the compiler/toolchain** (proprietary embedding, closed distribution of modified toolchain, modified network services without offering corresponding source), contact:

- ShuLiangfu — [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*Shux — performance-oriented, simple, readable, maintainable, memory-safe.*
