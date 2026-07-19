# Shux

> **Systems code that is simple, safe, and fast — finally in one language.**  
> C-like model you already know · Rust-grade memory safety without the type-theory tax · codegen that aims to **beat** careful C · learning curve measured in **days**, not months.

| Item | Description |
|------|-------------|
| **Language** | Shux（舒克斯） |
| **Compiler** | `shux` / `shux_asm` (product binary after bootstrap) |
| **Source extension** | `.x` |
| **Build config** | `build.x` — project build strategy in Shux (steps, targets, products); entry via `shux build` / `build_tool` / `shux-build.sh` |
| **Status (2026-07-19)** | **Product L4 pin `5cc73d54`** (dual-host true cold + bstrict **125/125**). Tip **`229708f1`**: C5 `EXPR_MATCH` CTFE, dual L2 green (**≠** tip L4 re-pin). **Self-host not finished** (seed / hybrid C still required for cold start) |
| **Live dashboard** | [`analysis/自举进度.md`](analysis/自举进度.md) · daily snapshot [`analysis/当前进度.md`](analysis/当前进度.md) |
| **中文** | [README_zh-CN.md](README_zh-CN.md) |

---

## 1. Why Shux — **Three Highs, One Low**

Shux is a **systems language** for kernels, drivers, runtimes, and high-performance tools: no GC, zero-cost abstractions, explicit memory model, freestanding-ready.

Most languages force a trade-off. Shux refuses that trade-off:

| Pillar | Target | What it means in practice |
|--------|--------|---------------------------|
| **High performance** | **Beat careful C by default** | No GC; default ASM backend + optional C backend; aggressive alias / `noalias`, BCE, monomorphized generics, arena/region paths with zero hot-path malloc. Performance comes from the **compiler**, not from heroics in every call site |
| **High safety** | **Near Rust in the safe subset** | Compile-time region / borrow / linear checks; `Option` / `Result` over silent null; bounds-aware slices; graded `unsafe` only for hardware & syscall edges — **auditable**, not ambient |
| **High readability** | **Simpler than C at scale** | `T[]` carries length; no header hell (directory = module); `defer` / `with_arena` / scoped allocators; field access is only `.`; diagnostics with real locations |
| **Low learning cost** | **C programmers productive in days** | C-like control flow and mental model; no lifetime annotation maze; progressive features (write “almost C” first, then adopt modern safety); integrated `shux build` / fmt / LSP |

**One-line review rule for every language feature:**

> *Would this make a C programmer’s life harder?*  
> If yes → cut it, hide it in the compiler, or quarantine it in `unsafe`. **Simpler than C is the highest design priority**; safety and speed are delivered by compiler intelligence, not by burdening the author.

### How we differ (honest positioning)

| vs | Shux choice |
|----|-------------|
| **C** | Same “close to the metal” control — cleaner syntax, fewer footguns, one toolchain, safety proofs where C has UB |
| **Rust** | Same ambition on memory safety — **without** a heavy borrow-checker lifestyle; regions + inference + linear types do the heavy lifting |
| **Zig** | Shared love of simplicity and explicitness — plus a first-class safe subset and stronger static safety story as default |

### Supporting goals

| Goal | Meaning |
|------|---------|
| **Lightweight** | Few deps; small binaries; freestanding / embedded; std linked on demand |
| **Standard library** | Full `core/` + `std/`; one API across platforms (details under `std.sys`) |
| **Self-hosting** | End state: compiler + std 100% `.x`; host C / seed only for cold start (**in progress — not claimed complete**) |

### Design stance

- **Aim**: extreme performance where it matters — **default codegen better than typical C**, not “as good if you are careful”.
- **Discipline**: maintainable code, simple development, **memory safety** (no silent UB in the safe subset).
- **Method**: region-based memory + borrow gates + linear types; alias analysis feeds autovec / DCE; unsafe stays thin and reviewable.

Design notes: [`analysis/语法与类型设计-高性能与内存安全.md`](analysis/语法与类型设计-高性能与内存安全.md), [`analysis/需求分析.md`](analysis/需求分析.md), [`analysis/安全与性能.md`](analysis/安全与性能.md).

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
**Note:** daily L2 green on tip ≠ tip L4 pin. **Release pin is `5cc73d54`** (125/125 dual true cold). Tip daily work (e.g. CTFE folds) may be dual-L2 green without re-pinning L4 (see §8).

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
| **Product** | L4 true cold + product matrix (rv / option / hello / …) + dual `run-all-bstrict` **125** | **Required**, not sufficient alone for “zero C forever” |
| **Engineering** | prove T/N, Cap residual pure, Stage2, WPO chain/link/text gates | **No** |

---

## 8. Self-host status (snapshot · 2026-07-19)

> **Authoritative live numbers**: [`analysis/自举进度.md`](analysis/自举进度.md) · daily [`analysis/当前进度.md`](analysis/当前进度.md).  
> README only summarizes; **do not** treat Stage2 / prove / WPO / daily L2 green as a tip L4 re-pin or as “self-host done”.

### Product track

| Item | Status |
|------|--------|
| **L4 release pin** | **`5cc73d54`** — dual-host **true cold** + `run-all-bstrict` **125/125** (Ubuntu + macOS). Prior pins today: `ea1f6827` → `5cc73d54`; earlier lineage includes `a74e25a1` / `c51759eb` — **do not** re-cite those as the live pin |
| Product bstrict suite size | **125** scripts (`tests/run-all-bstrict.sh`; must log `OK (125 scripts…)`) |
| Ubuntu L4 + full bstrict (pin) | ✅ **125/125** @ **`5cc73d54`** |
| macOS L4 + full bstrict (pin) | ✅ **125/125** @ **`5cc73d54`** |
| Gold host | **Ubuntu x86_64** |
| Product binary under test | This-wave `compiler/shux_asm` (g05 / relink) — **never** leftover Stage2 `shux_asm2` or old `stage1` |
| Branch tip (not tip L4) | **`229708f1`** on `self-hosting` — C5 `EXPR_MATCH` CTFE, dual L2 green. **Tip L4 re-pin only after dual true cold + bstrict 125**, not after every L2 green |
| Latest tip daily L2 | ✅ mac + Ubuntu L2 matrices + bstrict **125/125** @ `229708f1` (**≠** tip L4 re-pin; CTFE fold is not ABI/link) |

### Product surface closed on 2026-07-19

On the **user product path** (`shux_asm` / freestanding / gates). Green L2 **does not** auto-raise the L4 pin:

| Area | Status |
|------|--------|
| **C2 · `std.net` PRIMARY UNDEF** | ✅ `net.o` includes `mod.x`; `use_line` real-call detection; cookbook `net_listen_bind.x -o` green — in pin lineage |
| **C3=C4 · bare `{…}` struct lit** | ✅ parser `LBRACE` let-init handler; bare struct-lit + `unsafe`/`while` no longer drops lets → P001 |
| **C8 · vec/set/map/queue duplicate** | ✅ guard `mem.o`+`heap.o` push with `c_provides` (fk0 GAP) — **raised L4 pin to `5cc73d54`** |
| **Backtrace C-backend heap chain** | ✅ push `page_mmap.o` + asm IO stubs — pin `ea1f6827` |
| **C5 · `EXPR_MATCH` CTFE** | ✅ const subject + const arms fold to imm32 (`lang-const` 13/13); tip `229708f1`, dual L2, **not** L4 re-pin |
| **Driver · `shux run` / bare `shux file.x`** | ✅ in-memory compile-and-run (from 18→19 wave) |
| Freestanding S4 / NL-07 no-libc / hosted asm matrix | ✅ still hold on product pin |

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
- **Not** “dual L2 bstrict on tip = tip L4” — pin is **`5cc73d54`** until the next dual **true cold** re-pin
- Final physical zero-C / full seed elimination (**G**) remains roadmap, not the weekly claim surface

Methodology: Cap / R / L / M → [`analysis/自举方法.md`](analysis/自举方法.md). Ops: [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md). Discipline: [`AGENTS.md`](AGENTS.md) + skill `shux-selfhost-product-gate`.

### Near-term front row (high level)

1. Next product Cap map only with explicit candidates (C5 guard / struct-lit / enum-variant fold; C6 X ABI P0b; C7 plan thin) — **no** unmapped tip L4  
2. **Re-pin tip L4** only with dual true cold + bstrict 125 when ABI/link/seed surfaces move  
3. Residuals that block a product surface only: **no** soft-skip typeck, **no** dual authority

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
| **Now** | Product L4 dual pin @ **`5cc73d54`** (125/125); tip **`229708f1`** (C5 CTFE dual L2) — **not** tip L4 re-pin | See dashboard |

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

*Shux — Three Highs, One Low: faster than C · safer near Rust · simpler than C · learnable in days.*
