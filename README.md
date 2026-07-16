# Shux

> **Write high-performance, memory-safe code in a modern language** — Based on C's type and execution model, with syntax and semantics kept simple, readable, and maintainable; achieves performance and memory safety through "explicit + fewer undefined behaviors + safe by default" rather than complex type theory.

| Item | Description |
|------|-------------|
| **Language Name** | Shux |
| **Compiler** | `shux` |
| **Source File Extension** | `.x` |
| **Build Configuration** | `build.x` (equivalent to Zig's `build.zig`) |
| **Current Main Track** | **Phase B + C in parallel** (Cap capability unlocking → R2 real migration → M mega depinning; D+E-soft+F v1 closed) |
| **Progress View** | [`analysis/自举进度.md`](analysis/自举进度.md) (single source of truth) |

---

## 1. Project Positioning

Shux is a **systems programming language**: no GC, zero-cost abstractions, explicit memory model, targeting code quality **comparable to or exceeding C**. Compared to C, it offers a simpler development experience—clean syntax, errors with locations and suggestions, integrated toolchain; compared to Rust, the type system is deliberately restrained, being **sufficiently explicit** at key points (nullable, bounds, ownership/borrowing, aliasing), allowing the compiler to statically prove safety and optimize with confidence.

### Core Objectives

| Objective | Meaning |
|-----------|---------|
| **Extreme Performance** | No GC, zero-cost abstractions, direct ASM output + optional C backend; aliasing and noalias drive auto-vectorization |
| **Memory Safety** | No leaks, no dangling pointers, no out-of-bounds, no data races in the safe subset; clear auditable `unsafe` boundaries |
| **Lightweight** | Few dependencies, small executables, supports freestanding and embedded; standard library linked on-demand |
| **Rich Standard Library** | Full `core/` + `std/` modules, one API across all platforms |
| **Easy to Learn** | Much simpler than C; gentle learning curve, smooth toolchain |
| **Self-Hosting** | Compiler and standard library eventually 100% `.x`; host C / seed only for cold start and cleanup transition |

### Design Philosophy

- **Purpose**: Extreme performance optimization.
- **Principle**: Highly maintainable code, simple development; **memory safety** (no leaks, no crashes, absolute safety).

Detailed design: [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md), [`analysis/需求分析.md`](analysis/需求分析.md).

---

## 2. Language Feature Overview

### Types and Semantics

- **Primitive Types**: `i8`/`i16`/`i32`/`i64`, `u8`/`u16`/`u32`/`u64`, `f32`/`f64`, `bool`, `usize`/`isize`
- **Structs and Generics**: Generic functions/structs + monomorphization; trait / impl interfaces
- **Nullable and Error Handling**: `Option<T>`, `Result<T, E>`; explicit handling, avoiding C-style nullable raw pointers
- **Slices**: `T[]` carries length; region annotation `T[]<label>` with **region** borrowing domains (typeck rejects escapes)
- **Modules**: `import("std.io")` / `import("core.mem")`; directories are modules, entry is `mod.x`

### Memory and Safety

- **No GC**: Stack + Heap + Arena; compile-time region / linear / borrow rejects errors
- **Compile-Time Automatic Memory Management**: `defer`, `owned`, scoped `Allocator` (`with_arena`), SROA, BCE
- **Gradated Safety**: Safe by default; only `unsafe { ... }` allows raw pointers and low-level syscalls
- **Alias Analysis**: `noalias`, scope borrow gate, providing basis for autovec and DCE

See also [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md), [`analysis/安全与性能.md`](analysis/安全与性能.md).

### Conditional Compilation and Platforms

- Conditional compilation (`#if` / target branches) supports multiple targets
- **One API across all platforms**: Platform differences encapsulated inside `std/sys`
- Supports **freestanding** (`-freestanding`, nostdlib static linking)
- Multi-target: `x86_64-linux`, `arm64-macos`, etc. (`-target`)

Language syntax quick reference: [`docs/README.md`](docs/README.md) (keywords, types, control flow, modules, etc.).

---

## 3. Quick Start

### Requirements

- Linux or macOS (Windows bootstrap chain in progress, B-hybrid)
- System C compiler and linker (`cc` / `clang`), used for linking phase and cold-start seed
- Optional: Docker (Linux x86_64 gold standard gate, e.g., `run-linux-a09-a11-gate.sh`)

### First-Time Build

```bash
# Recommended: pinned seeds produce build_tool, then daily relink to shux
make -C compiler build-tool
./shux-build.sh first-time          # = build_tool + ./build_tool ./shux
# Or: cd compiler && ./build_tool ./shux

# Cold start (cc only, no Makefile): cd compiler && sh bootstrap.sh

# For LSP (--lsp):
make -C compiler bootstrap-driver-seed
```

### Daily Build and Bootstrap

```bash
# [Recommended daily] G-05: build_tool → g05_build_shux_asm.sh → make shux_asm (relink gold standard)
./shux-build.sh build                 # at repo root (root make also delegates to this script)
# Or: cd compiler && ./build_tool ./shux

SHUX=./compiler/shux ./tests/run-hello.sh

# Full B-strict (after changing backend/seed; slower)
./shux-build.sh full                  # or make -C compiler bootstrap-driver-bstrict

# Semantic bootstrap smoke test
make -C compiler bootstrap-verify     # Makefile fallback / CI
```

| Entry Point | Purpose |
|-------------|---------|
| `./shux-build.sh build` / `./build_tool ./shux` | **Daily incremental** (default) |
| `./shux-build.sh full` | Full B-strict |
| `make -C compiler …` | Cold start details, legacy CI, test targets (**fallback**) |

`shux-c` is only used for **first cold start** or MSYS2 / non-x86_64 linking fallback; **not** the daily release binary. Daily work uses `compiler/shux` (relink / B-strict finalized).

### Hello World

```x
// examples/hello.x
const fmt = import("std.fmt");

function main(): i32 {
  let n: i32 = fmt.println("Hello World");
  return if (n >= 0) { 0 } else { 1 };
}
```

```bash
./compiler/shux examples/hello.x          # compile and run (requires shux already built)
./compiler/shux build examples/hello.x -o hello && ./hello
./compiler/shux check examples/hello.x      # parse + typeck only
```

More examples: [`examples/`](examples/) (includes cookbook: io, net, async, json, compress, etc.).

### Acceptance Tests

```bash
./tests/run-all.sh              # full regression (repo root)
./tests/run-all-bstrict.sh      # B-strict chain equivalent CI
./tests/run-linux-a09-a11-gate.sh   # Linux gold standard bootstrap gate (Docker recommended)
```

---

## 4. Compiler Usage (`shux`)

Default uses **ASM backend** to emit machine code directly (`-backend asm`). Common commands:

| Command | Description |
|---------|-------------|
| `shux file.x` | Compile and run (same as `shux run file.x`) |
| `shux build` | Read current directory `build.x`, compile and run `build_runner` |
| `shux build file.x` | Compile only, default output `a.out` |
| `shux build file.x -o exe` | Compile to specified executable |
| `shux run file.x` | Compile and run |
| `shux check file.x` | Parse + typeck only (including imports), no linking |
| `shux fmt file.x` | Format `.x` source file |
| `shux test [script.sh]` | Run test script (default `tests/run-all.sh`) |
| `shux --lsp` | Language server (stdio JSON-RPC; called by IDE plugins) |
| `shux -E file.x` | Output C source (for debugging) |
| `shux -backend c file.x` | Force C backend |
| `shux -O2 file.x -o app` | Optimization level (**default -O2**) |
| `shux -freestanding … -o app` | Linux x86_64 nostdlib static linking |
| `shux -h` / `shux --help` | Print usage summary |

Build configuration entry: root [`build.x`](build.x): equivalent to Zig's `build.zig`, describing "how to compile, what to compile". Daily entry: `./shux-build.sh` / `build_tool` (G-05 ~95%); `compiler/Makefile` only for relink dependency graph and cold-start implementation layer.

---

## 5. Repository Structure

```
shux/
├── README.md                 # This file
├── LICENSE                   # Full AGPL-3.0-or-later license text
├── NOTICE                    # Copyright, SPDX identifiers, and third-party notices
├── build.x                  # Build configuration (equivalent to build.zig)
├── NEXT.md                   # Complete bootstrap roadmap and gate commands
├── analysis/                 # Requirements, architecture, RFCs, performance and security analysis
├── docs/                     # Language syntax documentation (user-facing)
├── compiler/                 # Compiler (.x main chain + C seed / glue, moving toward physical zero C)
│   ├── src/
│   │   ├── lexer/ parser/ ast/ typeck/ codegen/
│   │   ├── asm/              # In-house ASM backend
│   │   ├── pipeline/ driver/ lsp/
│   │   └── …
│   ├── seeds/                # bootstrap_shuxc, *_gen cold-start seeds
│   ├── docs/SELFHOST.md      # Bootstrap acceptance commands
│   └── scripts/              # build_shux_asm.sh etc.
├── core/                     # Standard library core (no OS dependency)
├── std/                      # Standard library std (F-ZC: 0 handwritten .c/.h)
├── runtime/                  # Minimal runtime (optional)
├── tests/                    # Regression tests and gate scripts
├── examples/                 # Examples and cookbook
├── tools/                    # Formatting, test runners, etc.
├── editors/vscode/           # VS Code / Cursor / Trae plugins (LSP client)
└── mcp/                      # MCP services (development assistance)
```

- **core/** does not depend on **std/**; **std/** depends on **core/**
- Module layout: **directory is module**, entry is `mod.x` (e.g., `std/io/mod.x`)
- User references: `import("core.mem")`, `import("std.io")`

Architecture details: [`analysis/构架分析.md`](analysis/构架分析.md).

---

## 6. Standard Library

### core (No OS)

| Module | Responsibility |
|--------|----------------|
| `core.types` | `size_of` / `align_of`, layout queries |
| `core.mem` | Memory operations, alignment, copying |
| `core.option` / `core.result` | Nullable and error types |
| `core.slice` / `core.str` | Slices and string views |
| `core.fmt` / `core.debug` | Formatting and debugging |
| `core.builtin` / `core.iterator` / `core.cmp` | Builtins, iteration, comparison |

(Full list: [`docs/07-内置与标准库.md`](docs/07-内置与标准库.md).)

### std (OS-Dependent, F-ZC ✅)

Handwritten **`.c`/`.h` under `std/` is now 0** (Phase F closed). Covers I/O, filesystem, networking, concurrency, compression, encoding, database, HTTP, async, crypto, regex, configuration, etc. Representative modules:

| Category | Modules |
|----------|---------|
| Basics | `std.io`, `std.fs`, `std.path`, `std.process`, `std.env` |
| Containers | `std.vec`, `std.map`, `std.set`, `std.queue` |
| Memory | `std.heap` (Allocator, Arena), `std.mem` |
| Concurrency | `std.thread`, `std.sync`, `std.channel`, `std.async` |
| Networking | `std.net`, `std.http`, `std.websocket` |
| Data | `std.json`, `std.csv`, `std.compress`, `std.db` |
| System | `std.sys` (Linux syscall / macOS libSystem / Win32 planned) |
| Utilities | `std.test`, `std.fmt`, `std.log`, `std.cli` |

Standard library is linked on-demand, no unused modules included, fulfilling "lightweight, everything small".

---

## 7. Compiler Architecture

### Pipeline

```
.x source
  → [Preprocess] → #if / import expansion
  → [Lexer] → Token stream
  → [Parser] → AST
  → [Type Checker] → Generic monomorphization, borrow, region
  → [Code Generator] → ASM or C
  → [Linker] → Executable / .o
```

### Two Build Paths

| Path | Description |
|------|-------------|
| **User Compilation** | `.x` → driver → asm/c backend → ld → executable |
| **Bootstrap Build** | Seed (`shux-c` / `bootstrap_shuxc` + `*_gen`) → `build_shux_asm.sh` → `shux_asm` → Stage2 verification |

### Bootstrap Status (2026-07-14)

> Detailed numbers and TODOs: [`analysis/自举进度.md`](analysis/自举进度.md); table below is README summary.

#### Progress Over the Past Month (2026-06-14 → 2026-07-14)

One month ago, this repository had no bootstrap progress tracking system (no `analysis/自举进度.md`, no Cap/R/L/M methodology, README was "development timeline"). Within one month (4163 commits), key changes:

| Dimension | One Month Ago | Now | Change |
|-----------|--------------|-----|--------|
| **Methodology** | Stage G cleanup ~20% | Cap/R/L/M four tracks + four KPIs (T/N/R2/H/S/G) | Established [`自举方法.md`](自举方法.md), [`自举步骤.md`](自举步骤.md), [`自举进度.md`](analysis/自举进度.md), [`当前进度.md`](当前进度.md) |
| **T** (typeck) | Some modules failing | **18/18 full** | 12 root cause waves including W-lsp-diag-expr / W-lexer-timeout / W-tail / W-isize all cleared |
| **N** (prove IDENTICAL) | 0 (system not built) | **49** | 9 labi_* + 12 rt_* + 7 backend/diagnostic thin proves all green |
| **R2** (real migration H=0) | 0 | **15** full | `rt_util` / `rt_lib_root` / `rt_emit_flags` / `rt_emit_state` / `rt_content` / `rt_fs_open` / `rt_parse_diag` / `rt_fmt_one` / `rt_diag_errno` / `rt_stack` / `rt_argv` / `rt_entry` / `rt_pipeline_elf_diag` / `rt_compile` / `rt_run_exec` |
| **W Waves** | 0 | **12 ✅** | W-string / W-keyword-param / W-unsafe-expr / W-extern-unsafe / W-tail / W-isize / W-heap-overload / W-escape / W-lexer-timeout / W-lsp-diag-expr / W-string-let / W-string-nul |
| **Cap** | 0 unlocked | **1** ✅ | Cap-empty-str; ⬜ Cap-string-pool / Cap-global-bss / Cap-va-reportf / Cap-regen-sync |
| **Gate G** | — | ✅ mac + Ubuntu all green | Seed cold start / G-FFI-5 |

> **Core Conclusion**: Within one month, completed "from no progress tracking → established four-track methodology + four KPIs + 12 root cause waves all cleared + 15 slices R2 full real migration". Remaining bottlenecks converged to **4 Cap items + 3 mega pins**, no longer unorganized cleanup.

#### Stage Overview

| Stage | Meaning | Status |
|-------|---------|--------|
| **D** | Gold bootstrap Stage2 | ✅ v1 |
| **E** | Compiler de-C (soft) | 🟡 Default no_c; pinned seed + patch still present ← **current main track** |
| **F** | std no C (F-ZC) | ✅ `std/` 0 `.c` + 0 `.h` |
| **G** | Final physical zero C / nostdlib hard green | 🟡 Not this week's main track (E three tracks first) |

#### Four KPIs (Ubuntu x86_64, 2026-07-14)

| KPI | Meaning | Current | Healthy Direction |
|-----|---------|---------|-------------------|
| **T** | typeck OK / 18 | **18/18** ✅ | Full |
| **N** | prove IDENTICAL module count | **49** (annotated) | No longer sprinting |
| **R2** | Production rest business symbols migrated (H=0) | **15** full | ↑ Primary metric |
| **H** | Hybrid rest slices still containing business C bodies | 15 slices above H=0; remaining runtime multi-slices still rest C | ↓ Primary metric |
| **S** | Pinned seed surface hard-depended by build chain | R2×15 production PREFER full .x; others hybrid multi thin+rest; mega still pinned | ↓ |
| **G** | Gates: seed cold start / G-FFI-5 | ✅ mac + Ubuntu | All green |

#### Current Main Track (Phase B + C in Parallel)

```
Current ──► Phase B Exit ──► Phase C Exit ──► v2==v3 ──► Bootstrap Semantics Complete
  │           │                │
  │           │                └─ All mega pins removed (typeck M4 + codegen + parser)
  │           └─ 4 Cap items + batch R2 (H→0, except syscall/crt shells)
  └─ T=18/18 ✅ / N=49 annotated / R2=15
```

| Track | Current Status | Next Step |
|-------|---------------|-----------|
| **Cap** (Capability Unlocking) | ✅ Cap-empty-str; ⬜ Cap-string-pool / Cap-global-bss / Cap-va-reportf / Cap-regen-sync | Cap-global-bss → rt_arena_buf |
| **R** (Real Migration Retirement) | R2=15 full (H=0); remaining hybrid multi-slices still rest C | Batch R2: other runtime rest |
| **M** (Mega Depinning) | 3 still pinned (typeck / codegen / parser) | typeck M2 trial replacement smoke |
| **L** (Leaf Prove) | N=49 IDENTICAL (secondary track, no longer sprinting) | Regression lock only |

#### Current Blockers

1. **Phase B Exit Not Reached**: Production `runtime_driver_no_c` / labi still has business rest C (H not reduced) — Root cause: 4 Cap items not unlocked
2. **Phase C Exit Not Reached**: 3 mega still pinned — Root cause: typeck M2 trial replacement not smoke-verified
3. **typeck standalone variable resolution**: `shux-c -E src/runtime_driver_diagnostic.x` still reports `expected *u8, found ?`

Full picture and acceptance: [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md), [`NEXT.md`](NEXT.md) §10 Stage G, [`analysis/doc-selfhost-architecture-v1.md`](analysis/doc-selfhost-architecture-v1.md).

---

## 8. Milestones

| Milestone | Content | Status |
|-----------|---------|--------|
| M0 | Lexer, AST, Parser | ✅ |
| M1 | Typeck, Codegen, Driver, first working version | ✅ |
| M2 | import, core/std minimal subset, multi-target | ✅ |
| M3 | Generics, trait, module system, standard library expansion | ✅ |
| M4 | DCE, -O2/-Os, size and performance baseline | ✅ (partial) |
| M5 | Bootstrap (`.x` compiler can compile itself) | ✅ D+E+F v1; 🟡 Phase B+C parallel (Cap→R2→M depinning) |
| **Current Main Track** | **Phase B + C in Parallel** (bootstrap semantics complete) | See [`自举进度.md`](自举进度.md) |

---

## 9. Documentation Index

| Document | Content |
|----------|---------|
| [`自举进度.md`](自举进度.md) | **Bootstrap / Final G progress (prioritized maintenance)** |
| [`当前进度.md`](当前进度.md) | Daily engineering blockers and reproduction commands |
| [`自举方法.md`](自举方法.md) | Cap/R/L/M methodology |
| [`NEXT.md`](NEXT.md) | Roadmap, Stage G tasks, gate commands |
| [`docs/README.md`](docs/README.md) | Language syntax documentation index |
| [`analysis/自举进度.md`](analysis/自举进度.md) | Bootstrap progress dashboard (KPI / front-row / three tracks) |
| [`analysis/需求分析.md`](analysis/需求分析.md) | Overall goals, performance and security strategy |
| [`analysis/构架分析.md`](analysis/构架分析.md) | Repository structure, compiler module division |
| [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md) | Type and semantic design principles |
| [`analysis/编译时自动内存管理和自动向量化.md`](analysis/编译时自动内存管理和自动向量化.md) | Arena, SROA, autovec roadmap |
| [`analysis/安全与性能.md`](analysis/安全与性能.md) | Compiler and language security defenses |
| [`analysis/性能压榨.md`](analysis/性能压榨.md) | Performance layering and pre-bootstrap perf baseline |
| [`analysis/IR核心设计.md`](analysis/IR核心设计.md) | Five-layer IR architecture (Architecture Freeze v4.0, post-bootstrap) |
| [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md) | Bootstrap operations and acceptance commands |
| [`editors/vscode/README.md`](editors/vscode/README.md) | VS Code / Cursor / Trae plugin and LSP configuration |

There are also numerous RFCs and module-level designs (std-http, std-async, perf, etc.) under `analysis/`, search by module name.

---

## 10. Testing and Quality

- **Full Regression**: `./tests/run-all.sh`
- **B-strict CI**: `SHUX=./compiler/shux ./tests/run-bootstrap-bstrict-ci.sh` (or `shux_asm`)
- **Pre-Push P0**: `SHUX=./compiler/shux ./tests/run-pre-push-p0.sh`
- **Linux Gold Standard**: `./tests/run-linux-a09-a11-gate.sh`
- **Gate Scripts**: `tests/run-*-gate.sh` (borrow, arena, region, linear, autovec, etc.)
- **No Compile Regression**: `SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh`
- **Performance Baseline**: `tests/baseline/`, `analysis/perf-*.md`

### Performance Benchmark Results (2026-07-09, Linux x86_64, fair data after anti-cheat fix)

> Test machine: Ubuntu x86_64; reference compiler `clang -O2 -std=c11`; SHUX compiler `./compiler/shux` (seed, ASM backend, default `-O2`).
> Gate standard (Dev Spec v1 §4): SHUX in-house backend wall time median ≤ C `-O2` median. Sampling: warmup 3 + rounds 20, take median.
> Anti-cheat: All C sources contain `__asm__ volatile` to prevent constant folding (`call_boundary.c` / `struct_param.c` fixed, see commit 567bea0a).

#### Differential Tests D1–D6 (Behavior correctness: exit code + stdout match C source)

| Test Case | Verification Content | Result |
|-----------|---------------------|--------|
| D1 `int_arith` | u32 overflow wrap / signed division truncation toward zero / modulo sign / shift / bit ops | ✅ PASS (rc=242) |
| D2 `struct_layout` | repr(C) layout / packed no padding / nested struct / field read/write | ✅ PASS (rc=50) |
| D3 `call_conv` | Multi-parameter passing (>6 register spill to stack) / struct return / recursive call | ✅ PASS (rc=178) |
| D4 `float` | IEEE 754 float operations / float comparison | ❌ FAIL (P2 placeholder, ASM backend float codegen pending) |
| D5 `bit_ops` | Negative arithmetic right shift / unsigned logical right shift / bitfield extract / bit set/clear | ✅ PASS (rc=130) |
| D6 `mem_ops` | Handwritten memset/memcpy / array index access / loop fill copy | ✅ PASS (rc=8) |

**D1–D6 Summary: 5/6 PASS**. D4 float is P2 placeholder (explicitly commented in `tests/bench/diff/d4_float.x`), to be activated after ASM backend float support is complete.

#### PERF-001 Performance Gate (wall time median comparison, fair comparison)

| Benchmark | Loop Scale | C median | SHUX median | ratio | Gate |
|-----------|------------|----------|-------------|-------|------|
| `loop_i32` | 100M LCG accumulation loops | 45.7 ms | 39.9 ms | 0.87 | ✅ PASS |
| `mem_copy` | 8192 rounds × 4096 bytes fill+sum | 7.5 ms | 6.5 ms | 0.87 | ✅ PASS |
| `struct_param` | 100M Pair(2×i32) pass-by-value | 67.6 ms | 5.7 ms | 0.08 | ✅ PASS |
| `call_boundary` (fold) | 200M 5-layer deep call chain | 81.1 ms | 0.3 ms | 0.00 | ✅ PASS |
| `call_boundary` (real) | 200M 5-layer deep call chain | 81.2 ms | 143.4 ms | 1.77 | ❌ FAIL |

> ratio = SHUX median / C median; < 1.0 means SHUX is faster. Sampling: warmup 3 + rounds 20, take median (Python `perf_counter` precise timing).
> `call_boundary` provides two datasets: **fold** = compile-time affine loop elimination (recognizes `while(i<n){s=s+f(i);i++}` pattern, f0–f4 are `x+K` chains K=5, closed-form evaluation `n(n-1)/2 + K·n`, 200M loops folded into 2 instructions `mov $total,%eax; store`); **real** = disabled fold for fair runtime comparison, gap from ASM backend lacking register allocation (loop variables s/i all stored on stack, load/store per iteration, clang `-O2` keeps in registers). Post-bootstrap register allocation will make real ratio approach 1.0.

> macOS arm64 cannot run ASM backend benchmarks due to CG002 (ASM backend `code_len=0` limitation), please execute on Linux x86_64 (use `ssh ubuntu-server`).

---

## 11. Toolchain Ecosystem

| Component | Path | Description |
|-----------|------|-------------|
| VS Code / Cursor / Trae Plugin | [`editors/vscode/`](editors/vscode/) | Syntax highlighting, LSP (`shux --lsp`), formatting, tasks, diagnostics; 32 config items, 14 UI languages, 36 snippets |
| Language Server | `compiler/src/lsp/` | `lsp.x`, `lsp_diag.x`, etc.; requires `compiler/shux` with `--lsp` support |
| MCP Server | [`mcp/`](mcp/) | IDE/AI calls parsing and diagnostics via MCP |

Install plugin: see [`editors/vscode/README.md`](editors/vscode/README.md) (VSIX or development mode); workspace requires Open Folder to start LSP.

---

## 12. Contributing

1. After cloning: `make -C compiler build-tool && ./shux-build.sh first-time` (or `make -C compiler bootstrap-driver-bstrict`).
2. After modifying `.x` daily: `./shux-build.sh build` (or `cd compiler && ./build_tool ./shux`), then run `./tests/run-all.sh` / relevant gate.
3. Bootstrap-related changes: `make -C compiler bootstrap-verify`; final items cross-reference [`analysis/自举进度.md`](analysis/自举进度.md).
4. Commit conventions: Conventional Commits (`feat:` / `fix:` / `perf:` etc.), English description.

**Current Resolution**: Standard library **new features** are paused; **only main track = bootstrap semantics completion** (Phase B + C parallel: Cap capability unlocking → R2 real migration retirement → M mega depinning). Post-bootstrap, IR Phase 0 will start (architecture already frozen v4.0).

---

## 13. License

This project is licensed under **GNU Affero General Public License v3.0 or later** (AGPL-3.0-or-later).

- Full license text: [`LICENSE`](LICENSE)
- Copyright and third-party notices: [`NOTICE`](NOTICE)

### Commercial License

If your use case requires **exemption from AGPL-3.0 copyleft** (e.g., embedding the Shux compiler, toolchain, or derivative works in proprietary products, or running modified versions as network services without providing corresponding source to remote users), please contact the author for **commercial licensing**:

- Shuliang Fu — [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*Shux — Extreme performance optimization, simple, readable, maintainable, memory safe.*
