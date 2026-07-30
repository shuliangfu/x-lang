# X language

> **Systems code that is simple, safe, and fast — finally in one language.**  
> C-like model you already know · Rust-grade memory safety without the type-theory tax · codegen that aims to **beat** careful C · learning curve measured in **days**, not months.

| Item | Description |
|------|-------------|
| **Language** | **X language** |
| **Short / toolchain** | `xlang` — compiler CLI, package id, and repo short name |
| **Compiler** | `xlang` / `xlang_asm` (product binary after bootstrap) |
| **Source extension** | `.x` |
| **Build config** | `build.x` — project build strategy in X language (steps, targets, products); entry via `xlang build` / `build_tool` / `xlang-build.sh` |
| **Status (2026-07-31)** | **Product L4 pin `53fd80927`** (dual-host true cold + bstrict **129/129**, wave710). Tip L4 safety net **`f8be401e9`** (wave840 · **not** a pin bump). Residual tip on `self-hosting` (MG **11.3.1** leaf-pattern residual · daily L2 · **≠** tip L4 re-pin). **Self-host not finished** (seed / host-cc still required for cold start; `compiler/Makefile` still present — physical delete needs Windows re-proof + dual L4 + **explicit auth**) |
| **Live dashboard** | [`analysis/自举进度.md`](analysis/自举进度.md) · timeline [`analysis/自举时序.md`](analysis/自举时序.md) · debt [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) · Makefile map [`analysis/Makefile迁移表.md`](analysis/Makefile迁移表.md) · leaf residual [`compiler/docs/LEAF_PATTERN_RESIDUAL.md`](compiler/docs/LEAF_PATTERN_RESIDUAL.md) |
| **中文** | [README_zh-CN.md](README_zh-CN.md) |

---

## 1. Why X language — **Three Highs, One Low**

**X language** is a **systems language** for kernels, drivers, runtimes, and high-performance tools: no GC, zero-cost abstractions, explicit memory model, freestanding-ready.

Most languages force a trade-off. X language refuses that trade-off:

| Pillar | Target | What it means in practice |
|--------|--------|---------------------------|
| **High performance** | **Beat careful C by default** | No GC; default ASM backend + optional C backend; aggressive alias / `noalias`, BCE, monomorphized generics, arena/region paths with zero hot-path malloc. Performance comes from the **compiler**, not from heroics in every call site |
| **High safety** | **Near Rust in the safe subset** | Compile-time region / borrow / linear checks; `Option` / `Result` over silent null; bounds-aware slices; graded `unsafe` only for hardware & syscall edges — **auditable**, not ambient |
| **High readability** | **Simpler than C at scale** | `T[]` carries length; no header hell (directory = module); `defer` / `with_arena` / scoped allocators; field access is only `.`; diagnostics with real locations |
| **Low learning cost** | **C programmers productive in days** | C-like control flow and mental model; no lifetime annotation maze; progressive features (write “almost C” first, then adopt modern safety); integrated `xlang build` / fmt / LSP |

**One-line review rule for every language feature:**

> *Would this make a C programmer’s life harder?*  
> If yes → cut it, hide it in the compiler, or quarantine it in `unsafe`. **Simpler than C is the highest design priority**; safety and speed are delivered by compiler intelligence, not by burdening the author.

### How we differ (honest positioning)

| vs | X language choice |
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
- **Field access**: only `.` in X language source (not `->`; C `->` is codegen’s job when the base is a pointer)

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
# Recommended: pinned seeds → build_tool → daily xlang
make -C compiler build-tool
./xlang-build.sh first-time          # build_tool + ./build_tool ./xlang
# Or: cd compiler && ./build_tool ./xlang

# Cold start with cc only: cd compiler && sh bootstrap.sh

# Full seed driver (LSP / product chain common path):
make -C compiler bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### Daily build

```bash
# Daily: G-05 path → xlang_asm relink gold
./xlang-build.sh build
# Or: cd compiler && ./build_tool ./xlang

export XLANG=./compiler/xlang_asm   # prefer this-wave product binary
./tests/run-hello.sh

# Heavier rebuild after backend/seed changes
./xlang-build.sh full              # or make -C compiler bootstrap-driver-bstrict
```

| Entry | Use |
|-------|-----|
| `./xlang-build.sh build` / `./build_tool ./xlang` | **Daily incremental** (default) |
| `./xlang-build.sh full` | Full B-strict-style rebuild |
| `make -C compiler …` | Cold start, CI, low-level targets |

**Product binary**: after a proper build, use **`compiler/xlang_asm`** (often mirrored as `compiler/xlang`).  
`xlang-c` / seed helpers are for **cold start and transition**, not the daily release story.

### Hello World

```x
// Hello World — void main implies process exit 0 (Zig-like).
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
```

```bash
export XLANG=./compiler/xlang_asm
$XLANG run examples/hello.x
$XLANG build examples/hello.x -o hello && ./hello
$XLANG check examples/hello.x
```

More samples: [`examples/`](examples/) (io, net, async, json, compress, …).

### Acceptance tests

```bash
export XLANG=./compiler/xlang_asm
./tests/run-all.sh                 # full regression (when appropriate)
XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # product gate suite (~129 scripts)
./tests/run-linux-a09-a11-gate.sh  # Linux gold bootstrap subset (Docker OK)
# Linux x86_64 freestanding S4 smoke (return42 / panic / hello):
./tests/run-freestanding-hello.sh
```

For **self-host / product release claims**, the project requires **L4 true cold** (wipe all `.o` under `compiler`/`std`/`core`, rebuild binaries) **plus** dual-platform `run-all-bstrict` green. Details: skill / [`analysis/自举方法.md`](analysis/自举方法.md) · [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md).  
**Note:** daily L2 green on tip ≠ tip L4 pin. **Release pin is `53fd80927`** (129/129 dual true cold). Tip L4 safety net `f8be401e9` is **not** a pin bump (see §8).

---

## 4. Compiler CLI

Default backend: **ASM** (`-backend asm`).

```bash
xlang [COMMAND] [OPTIONS]
```

### Subcommands

| Command | Description | Usage |
|---------|-------------|-------|
| `build` | Compile .x to binary/object (default a.out) | `xlang build [options] file.x [-o exe]` |
| `run` | Compile and run .x | `xlang run [options] file.x` |
| `check` | Parse + typeck only (no codegen) | `xlang check [paths...]` |
| `fmt` | Format .x sources | `xlang fmt [--check] [paths...]` |
| `explain` | Explain a diagnostic code | `xlang explain <CODE>` |
| `test` | Run test script | `xlang test [script.sh]` |

### Build options (build / run)

| Option | Description |
|--------|-------------|
| `-backend asm\|c` | Backend (default asm) |
| `-O <0\|1\|2\|3\|s>` | Optimization level (default 2) |
| `-o <path>` | Output binary or .o |
| `-L <dir>` | Library search path |
| `-target <triple>` | Target triple (e.g. `aarch64-linux-gnu`) |
| `-target-cpu <cpu>` | `native\|generic\|avx2\|...` |
| `-freestanding` | Nostdlib static link (Linux x86_64 ELF) |
| `-legacy-f32-abi` | Legacy SysV f32 CALL (f64 widen; default xmm ABI) |
| `-E` | Emit C (debug) |
| `-flto` | Link-time optimization (C backend) |

### Global options

| Option | Description |
|--------|-------------|
| `--print-target-cpu` | Print host CPU features and exit |
| `--explain <CODE>` | Print diagnostic code explanation and exit |
| `--help, -h` | Show this help |

### Environment variables

| Variable | Effect |
|----------|--------|
| `XLANG_ABI_F32_XMM=0` | Same as `-legacy-f32-abi` (x86_64 SysV) |
| `XLANG_OPT` | Default -O level if omitted |
| `NO_COLOR` | Disable color output |
| `CLICOLOR_FORCE=1` | Force color output even when piped |
| `XLANG_FORCE_COLOR=1` | Same as CLICOLOR_FORCE |

### Examples

```bash
# Compile and run
xlang run examples/hello.x

# Compile to executable
xlang build examples/hello.x -o hello && ./hello

# Parse + typeck only
xlang check examples/hello.x

# Format sources
xlang fmt src/

# Explain diagnostic code
xlang explain XP003

# Run test script
xlang test tests/run-all-bstrict.sh

# Language server (stdio JSON-RPC)
xlang --lsp

# Force C backend
xlang build -backend c file.x

# Freestanding (Linux x86_64 nostdlib)
xlang build -freestanding file.x
```

Root [`build.x`](build.x) describes what to build. Daily entry: `./xlang-build.sh` / `build_tool`.

---

## 5. Repository layout

```
xlang/
├── README.md / README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x / xlang-build.sh
├── analysis/                 # process docs + RFCs (自举进度 / C迁移追踪 / Makefile迁移表 / 自举方法 / 自举步骤 …)
├── docs/                     # language syntax (user-facing)
├── compiler/                 # compiler (.x + seed C / glue)
│   ├── src/                  # lexer, parser, typeck, codegen, asm, pipeline, driver, lsp
│   ├── seeds/                # cold-start pins
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_xlang_asm, g05, relink, …
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
| **User / product path** | This-SHA `xlang_asm` compiles user `.x` → `-o` / run; matrix + bstrict |
| **Bootstrap / engineering path** | Seed cold start → `build_xlang_asm` / g05 → optional Stage2 / WPO dogfood |

**Two tracks (do not mix when reading status):**

| Track | What it measures | Alone enough to claim “self-host done”? |
|-------|------------------|----------------------------------------|
| **Product** | L4 true cold + product matrix (rv / option / hello / …) + dual `run-all-bstrict` **129** | **Required**, not sufficient alone for “zero C forever” |
| **Engineering** | prove T/N, Cap residual pure, Stage2, WPO chain/link/text gates | **No** |

---

## 8. Self-host status (snapshot · 2026-07-31)

> **Authoritative live numbers**: [`analysis/自举进度.md`](analysis/自举进度.md) · debt [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) · leaf residual map [`compiler/docs/LEAF_PATTERN_RESIDUAL.md`](compiler/docs/LEAF_PATTERN_RESIDUAL.md).  
> README only summarizes; **do not** treat Stage2 / prove / WPO / daily L2 green as a tip L4 re-pin or as “self-host done”.  
> **Bare “continue next step” ≠ physical delete of `compiler/Makefile`** — endgame needs Windows re-proof + dual L4 + **explicit user auth**.

### Product track

| Item | Status |
|------|--------|
| **L4 release pin** | **`53fd80927`** (wave710, 2026-07-29) — dual-host **true cold** + `run-all-bstrict` **129/129** (Ubuntu + macOS). Prior pins in lineage (e.g. `4fa4f07e7`, `deaf773b`, …) are **not** the live pin |
| Product bstrict suite size | **129** scripts (`tests/run-all-bstrict.sh`; must log `OK (129 scripts…)`) |
| Ubuntu L4 + full bstrict (pin) | ✅ **129/129** @ **`53fd80927`** |
| macOS L4 + full bstrict (pin) | ✅ **129/129** @ **`53fd80927`** |
| tip L4 safety net (not a pin bump) | ✅ **`f8be401e9`** (wave840) — mid-endgame tip proved dual L4; **pin stays `53fd80927`** until explicit re-pin |
| Windows hybrid / phys-del min-gate | ✅ STATUS=`reproven_green` on proof tip; **tip drift requires re-proof** before any physical Makefile delete |
| Gold host | **Ubuntu x86_64** |
| Product binary under test | This-wave `compiler/xlang_asm` (g05 / relink) — **never** leftover Stage2 `xlang_asm2` or old `stage1` |
| Branch residual tip (≠ tip L4) | Daily MG work on `self-hosting` (11.3.1 leaf residual · L2 dual residual/ensure checks). **See dashboard for exact SHA**; do not treat residual tip as the release pin |
| Latest tip daily L2 | ✅ mac + Ubuntu residual / ensure / catalog checks on residual tip (**≠** tip L4 re-pin) |

### Product path (what “usable” means today)

On the **user product path** (`xlang_asm` → `-o` / run / freestanding / gates), the pin already includes a large closed surface (net PRIMARY, bare struct lit, CTFE match fold, X ABI P0b waves, Windows hybrid gate, CLI help, `std.fmt` print ownership, freestanding S4 / NL-07, hosted asm matrix, …).  
**Green L2 on residual tip does not auto-raise the L4 pin.**

### Track MG · endgame (Makefile / zero host-cc cold start)

| Item | Status |
|------|--------|
| Goal | Physical delete of `compiler/Makefile` + cold start without host-cc compiling business C (C migration stages 11–12) |
| Path | **11.3.1 leaf-pattern residual** — swallow host-cc / multi-token / list inventory into shell + `compiler/mk/*.mk` (**not** physical delete yet) |
| Tree flags | `TREE_ARMED=1` · `BODY_SHIPPED=0` · `DELETE_ALLOWED=0` · `--delete` never-rm until auth |
| Preflight blockers (honest) | thin-call edges · B7B lists-in-mk · std/core product make graph (names evolve; see residual dump) |
| Progress through 2026-07-31 | Hundreds of residual waves (list→mk, FORCE thin try-heat, shell-primary phonies, env inject hygiene, multi-target families R1/R2/R3/B1–B5/…) — **Makefile still present** |
| Front residual examples | bootstrap_nostdlib_stubs (Linux guard) · net_merge · remaining thin edges — see open row in C迁移 / LEAF |

### Engineering track (subset)

| KPI / gate | Status |
|------------|--------|
| **T** typeck surface | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **111/111** |
| Cap residual pure | major waves closed on product pin lineage; open only when product red |
| **D Stage2** | ✅ freestanding / parity (**≠** full product g05 chain) |
| Stage2 **WPO** chain + strict-link + text-gate | ✅ engineering green (Ubuntu; some Darwin N/A) |

### What is *not* claimed

- **Not** “compiler is 100% `.x` with zero seed”
- **Not** “Stage2 `xlang_asm2` is the product compiler”
- **Not** “engineering WPO green = tip product L4”
- **Not** “dual L2 residual checks on tip = tip L4” — release pin is **`53fd80927`** until the next dual **true cold** re-pin
- **Not** “Windows hybrid green = product L4 / self-host done” — Windows is probe / min-gate only
- **Not** “11.3.1 residual closed = Makefile deleted” — physical delete is a later endgame wave with **explicit auth**
- Final physical zero-C / full seed elimination (**G**) remains roadmap, not the weekly claim surface

Methodology: Cap / R / L / M → [`analysis/自举方法.md`](analysis/自举方法.md). Timeline: [`analysis/自举时序.md`](analysis/自举时序.md). Ops: [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md). Discipline: [`AGENTS.md`](AGENTS.md) + skill `xlang-selfhost-product-gate`.

### Near-term front row (high level)

1. **11.3.1 residual (non-delete)** — finish remaining thin edges / mk-list hybrid; dual L2 on residual tip  
2. **tip Windows re-proof** → **Mac/Ubuntu L4** on tip (when claiming endgame) → **explicit user auth** for true Makefile delete  
3. Cap hard leaves only when product matrix is red — **no** soft-skip typeck, **no** dual authority, **no** unmapped tip L4 re-pin  

## 9. Milestones

| Milestone | Content | Status |
|-----------|---------|--------|
| M0 | Lexer, AST, Parser | ✅ |
| M1 | Typeck, Codegen, Driver | ✅ |
| M2 | import, core/std subset, multi-target | ✅ |
| M3 | Generics, trait, modules, std growth | ✅ |
| M4 | DCE, -O2/-Os, size/perf baseline | ✅ partial |
| M5 | Bootstrap (compiler can rebuild itself) | 🟡 **usable product path + advanced self-host**; **seed still required for cold start**; Makefile residual path open |
| **Now** | Product L4 dual pin @ **`53fd80927`** (129/129); tip L4 safety net **`f8be401e9`**; residual MG **11.3.1** (daily L2 · **not** tip L4 re-pin) | See dashboard |

---

## 10. Documentation map

| Document | Role |
|----------|------|
| [`analysis/自举进度.md`](analysis/自举进度.md) | **KPI dashboard** (must update each wave) |
| [`analysis/C迁移追踪.md`](analysis/C迁移追踪.md) | Endgame debt map (MG / delete Makefile DAG) |
| [`analysis/Makefile迁移表.md`](analysis/Makefile迁移表.md) | Makefile → xbuild leaf map |
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
| Product bstrict | `XLANG=./compiler/xlang_asm XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| Pre-push P0 | `XLANG=./compiler/xlang_asm ./tests/run-pre-push-p0.sh` |
| Linux gold subset | `./tests/run-linux-a09-a11-gate.sh` |
| Topic gates | `tests/run-*-gate.sh` |
| Compile dogfood | `XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

Baselines: `tests/baseline/`. When running **true cold full tests**, log paths should be printed for operators (e.g. `/tmp/*true_cold*`, `/tmp/*true_bstrict*`).

### Perf snapshot (historical · 2026-07-09 · Linux x86_64)

Fair wall-time medians vs `clang -O2` (warmup 3 + 20 rounds). See suite docs under `analysis/perf-*` for refresh procedure.

| Benchmark | ratio (XLANG / C) | Note |
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
| LSP | `xlang --lsp` · `compiler/src/lsp/` |
| MCP | [`mcp/`](mcp/) |

Plugin install: [`editors/vscode/README.md`](editors/vscode/README.md).

---

## 13. Contributing

1. Clone → `make -C compiler build-tool && ./xlang-build.sh first-time` (or full bootstrap-driver path).  
2. Daily edits → `./xlang-build.sh build`, set `XLANG=./compiler/xlang_asm`, run relevant tests/gates.  
3. Product / link / SHARED changes → **Ubuntu gold** (and mac when SHARED); for release claims use **L4 true cold** + dual bstrict **129** (pin `53fd80927` until re-pin).  
4. Commits: Conventional Commits (`feat:` / `fix:` / `docs:` …), English preferred for code comments in `.x` (see `AGENTS.md` / G.9).  
5. **No dual authority**: seed and `.x` product surfaces move **same commit** when both exist.  
6. **No false green**: do not claim self-host complete from prove/Stage2/WPO alone.

**Main line resolution**: prioritize self-host / product gates over large new std features; IR v4 architecture is frozen for post-bootstrap work.

---

## 14. License

X language uses **layered licensing** (language libraries permissive; compiler copyleft). See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).

| Layer | Paths | License |
|-------|--------|---------|
| A — Toolchain | `compiler/`, `tools/`, root `build*.x` | **AGPL-3.0-or-later** ([`LICENSE.AGPL-3.0`](LICENSE.AGPL-3.0)) |
| B — Language libs | `core/`, `std/` | **Apache-2.0** ([`LICENSE.Apache-2.0`](LICENSE.Apache-2.0)) |
| Samples | `examples/`, `tests/` | **Apache-2.0** |
| Editors | `editors/vscode` | **Apache-2.0** |
| Editors | `editors/tree-sitter-xlang`, `editors/vim` | **Apache-2.0** |
| Third-party | `compiler/seeds/crypto/ed25519/` (orlp) | **zlib** |

**Intent:** programs you write that use `core`/`std` are not forced under AGPL. Modifying or redistributing the **compiler/toolchain** is AGPL (or commercial terms).

Contributing terms: [`CONTRIBUTING.md`](CONTRIBUTING.md).

### Commercial licensing (Layer A only)

For **AGPL exemption on the compiler/toolchain** (proprietary embedding, closed distribution of modified toolchain, modified network services without offering corresponding source), contact:

- ShuLiangfu — [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*X language — Three Highs, One Low: faster than C · safer near Rust · simpler than C · learnable in days.*
