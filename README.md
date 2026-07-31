# X language

> **Systems code that is simple, safe, and fast — finally in one language.**
>
> Familiar imperative style · memory safety without a type-theory tax · codegen that aims to **beat** careful C · a learning curve measured in **days**, not months.

| | |
|--|--|
| **Language** | **X language** |
| **Toolchain** | `xlang` — CLI name, package id, and repo short name |
| **Compiler binary** | `xlang` / `xlang_asm` (product binary after a proper build) |
| **Source extension** | `.x` |
| **Project build** | `build.x` — build strategy written in X (`xlang build` / `build_tool` / `xlang-build.sh`) |
| **Status (2026-07-31)** | **Product L4 pin `9bb7a757c`** (dual-host true cold + bstrict **129/129**). Tip dual L4 candidate **`eef4d7743`** (wave923 · **not** re-pinned yet). Residual tip on `self-hosting` (MG **11.3.1** · daily L2 · Makefile still present · **awaiting explicit auth** for physical delete). **Self-host not finished** — cold start still needs seed / host `cc`. |
| **Live dashboard** | [Progress](analysis/自举进度.md) · [Timeline](analysis/自举时序.md) · [C-migration debt](analysis/C迁移追踪.md) · [Makefile map](analysis/Makefile迁移表.md) · [Leaf residual](compiler/docs/LEAF_PATTERN_RESIDUAL.md) |
| **中文** | [README_zh-CN.md](README_zh-CN.md) |

---

## Contents

1. [Language sketch](#1-language-sketch)
2. [Quick start](#2-quick-start)
3. [Compiler CLI](#3-compiler-cli)
4. [Repository layout](#4-repository-layout)
5. [Standard library](#5-standard-library)
6. [Compiler architecture](#6-compiler-architecture)
7. [Self-host status](#7-self-host-status-snapshot--2026-07-31)
8. [Milestones](#8-milestones)
9. [Documentation map](#9-documentation-map)
10. [Testing and quality](#10-testing-and-quality)
11. [Tooling](#11-tooling)
12. [Why X language — Three Highs, One Low](#12-why-x-language--three-highs-one-low)
13. [Contributing](#13-contributing)
14. [License](#14-license)

---

## 1. Language sketch

### Types and semantics

- **Primitives** — `i8`/`i16`/`i32`/`i64`, `u8`/`u16`/`u32`/`u64`, `f32`/`f64`, `bool`, `usize`/`isize`
- **Structs & generics** — monomorphized generics; trait / impl
- **Nullability / errors** — `Option<T>`, `Result<T, E>` (prefer over raw nullable C pointers)
- **Slices** — `T[]` carries length; region forms `T[]<label>` with escape checks
- **Modules** — `import("std.io")` / `import("core.mem")`; **directory = module**, entry `mod.x`
- **Field access** — only `.` in source (no `->`; C `->` is codegen’s job when the base is a pointer)

### Memory and safety

- **No GC** — stack + heap + arena; compile-time region / linear / borrow checks
- **Compile-time help** — `defer`, `owned`, scoped allocators (`with_arena`), SROA, BCE
- **Graded safety** — safe by default; raw pointers and low-level syscalls only in `unsafe { ... }`
- **Alias analysis** — `noalias` and borrow gates for autovec / DCE

See [compile-time memory & autovec](analysis/编译时自动内存管理和自动向量化.md) · [safety & perf](analysis/安全与性能.md).

### Platforms

- Conditional compilation (`#if` / target branches)
- **One API, multi-OS** — Linux / macOS primary product paths; Windows hybrid / probes
- Freestanding: `-freestanding` (nostdlib static, Linux x86_64 path)
- Targets such as `x86_64-linux`, `arm64-macos` (`-target`)

Syntax index: [docs/README.md](docs/README.md).

#### Support tiers (policy)

We do **not** treat every OS point-release as a required test matrix. Clear tiers keep quality high without infinite VMs:

| Tier | Meaning | What we do |
|------|---------|------------|
| **Tier 1 — Official** | Documented, CI-backed, bugs fixed first | Representative hosts only (see tables below) |
| **Tier 2 — Best effort** | Often works; no guarantee | Fix when cheap / when users report |
| **Tier 3 — Unsupported** | No testing, no support commitment | Documented so expectations stay honest |

**Project truth (orthogonal to tiers):**

| Role | Host | Notes |
|------|------|--------|
| **Gold standard** | **Ubuntu x86_64** | Link completeness / product gates; do not treat macOS green alone as SHARED done |
| **Product dual host** | Ubuntu x86_64 + **macOS** | L4 true cold + full `run-all-bstrict` for release pins |
| **Windows** | MSYS2 / MinGW **hybrid** probes | Hybrid green ≠ product L4 / self-host complete |

Linux care is driven more by **libc family** (glibc vs musl), **glibc major line**, and **kernel era** than by every Ubuntu point release. On macOS, care is **Darwin major + arch** (arm64 first). On Windows, care is **Win10/11 + x64 toolchain**, not every build number.

**Alpine / musl is supported** (host + CI Docker smoke). It is **not** the product gold host: gold and release pins still mean **Ubuntu x86_64 (glibc)**. Full B-strict / L4 self-host parity on Alpine is on the post-bootstrap track (A-13), not “won’t fix.”

#### Official matrix — Linux (Ubuntu / glibc and Alpine)

| Platform | Arch | Tier | Notes |
|----------|------|------|--------|
| **Ubuntu 24.04 LTS** | x86_64 | **1** | Current mainstream LTS; CI (`ubuntu-latest` / 24.04 line) |
| **Ubuntu 22.04 LTS** | x86_64 | **1** | Gold-adjacent LTS; CI `ubuntu-22.04`; Docker gates often pin 22.04 |
| **Ubuntu 26.04 LTS** (when used as host) | x86_64 | **1** | Newer LTS line — same Tier 1 bar once adopted as a primary host |
| **Alpine Linux** (musl) | x86_64 | **2** | **Supported host**; CI `docker-distro` (`alpine:3.x`); local `scripts/docker-ci-local.sh alpine`; host facts via `XLANG_HOST_ALPINE` / platform linker docs. Musl quirks handled (stack, link, some std fallbacks). **Not gold**: product L4 / release pins still Ubuntu glibc; full B-strict self-host on Alpine is deferred (A-13), not unsupported |
| **Ubuntu 24.04 / current** | aarch64 | **2** | CI probe (`ubuntu-24.04-arm`); not the product gold host |
| **Ubuntu 20.04 LTS** | x86_64 | **2** | Late life; may work if toolchain is new enough |
| Other glibc distros (Debian stable, Fedora, …) | x86_64 | **2** | Untested officially; report bugs with distro + glibc version |
| Rolling / exotic (Arch, etc.) | * | **2** | Best effort only |
| **Ubuntu 18.04 and older** / pre-glibc-2.28 era | * | **3** | EOL; no official support |

#### Official matrix — macOS

| Platform | Arch | Tier | Notes |
|----------|------|------|--------|
| **macOS 14 Sonoma** | **arm64** (Apple Silicon) | **1** | CI `macos-14` |
| **macOS 15 Sequoia** and **macOS 26.x** (current Apple major line) | **arm64** | **1** | CI `macos-latest` tracks the current runner image; primary mac development host |
| macOS 14+ | **x86_64** (Intel) | **2** | May work; not CI-primary; Intel Macs are declining |
| **macOS 13 Ventura** | arm64 / x86_64 | **2** | Best effort; no dedicated CI pin |
| **macOS 12 Monterey and older** | * | **3** | No official support (Xcode / SDK / linker expectations drift) |
| iOS / iPadOS / tvOS as **host** build OS | * | **3** | Not host platforms (cross targets are a separate story) |

**macOS policy in one line:** official support = **Apple Silicon + last ~2–3 major macOS releases (14+)**. Older macOS and Intel are best-effort or unsupported—not a reason to keep old VMs forever.

#### Official matrix — Windows

| Platform | Arch | Tier | Notes |
|----------|------|------|--------|
| **Windows 11** | x64 | **1** | Preferred Windows host; CI `windows-latest`; MSYS2 / MinGW hybrid path |
| **Windows 10 22H2+** | x64 | **2** | Large install base; support when practical (local / cloud repro) |
| Windows 10 before 22H2 | x64 | **3** | Not targeted |
| **Windows 7 / 8 / 8.1** | * | **3** | **Explicitly unsupported** (EOL, security, modern toolchain) |
| Windows 11 / 10 | ARM64 | **2** | Experimental / best effort; not CI-primary |
| MSVC-only pure PE product path | * | **2** | Hybrid MinGW path is what gates exercise today |

Windows status today is **hybrid / min-gate green on the product path**, not “full self-host L4 gold.” See [self-host status](#7-self-host-status-snapshot--2026-07-31) and [Windows limits guide](analysis/Windows平台限制与测试指南.md) when present.

#### Explicitly unsupported (Tier 3 — do not expect fixes)

| Item | Why |
|------|-----|
| Windows 7 / 8 / 8.1 | Long EOL; no modern security / toolchain story |
| Windows 10 before 22H2 | Out of support window for this project |
| macOS 12 and older | SDK / ld64 / system expectations too old |
| Ubuntu 18.04 and older | EOL LTS; ancient glibc / packages |
| “Every Ubuntu / Windows / macOS point release needs its own VM” | **Out of policy** — use tiers + representative hosts |

**Not Tier 3:** Alpine / musl — **Tier 2 supported** (see Linux matrix). Gold remains Ubuntu glibc; that is a quality bar, not a “musl unsupported” policy.

#### How we test (cost-effective)

| Layer | Coverage |
|-------|----------|
| **CI** | Ubuntu 22.04 + current Ubuntu LTS line; **Alpine + Debian slim** (`docker-distro`); macOS 14 + `macos-latest`; Windows latest (hybrid gate) |
| **Local / lab (few VMs)** | 1× Ubuntu LTS (gold), 1× macOS arm64, optional 1× Win11 (+ Win10 only if Tier-2 pressure is real); Alpine via Docker is enough (no dedicated Alpine VM required) |
| **On-demand cloud** | Spin a machine only when a platform bug needs repro — better than hoarding EOL VMs |

**We will not** maintain official VMs for Win7/Win8 or every Ubuntu interim release. Users on Tier 2/3 should not assume release-pin quality.

---

## 2. Quick start

### Requirements

- A **Tier 1** host from the [support tiers & platform matrix](#support-tiers-policy) (or Tier 2 if you accept best-effort): **Ubuntu x86_64 (gold)** or **macOS arm64 (14+)**; Windows 11 x64 for hybrid probes
- Host C toolchain (`cc` / `clang`; on Windows, MSYS2 / MinGW for the hybrid path)
- Optional: Docker for Linux gates (`ubuntu:22.04` common; Alpine via `scripts/docker-ci-local.sh alpine` / CI `docker-distro`)

### First-time build

```bash
# Recommended: pinned seeds → build_tool → daily xlang
make -C compiler build-tool
./xlang-build.sh first-time          # build_tool + ./build_tool ./xlang
# Or: cd compiler && ./build_tool ./xlang

# Cold start with cc only:
#   cd compiler && sh bootstrap.sh

# Full seed driver (common product / LSP path):
make -C compiler bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### Daily build

```bash
# Daily: G-05 path → xlang_asm relink
./xlang-build.sh build
# Or: cd compiler && ./build_tool ./xlang

export XLANG=./compiler/xlang_asm   # this-wave product binary
./tests/run-hello.sh

# Heavier rebuild after backend / seed changes
./xlang-build.sh full              # or: make -C compiler bootstrap-driver-bstrict
```

| Entry | Use |
|-------|-----|
| `./xlang-build.sh build` / `./build_tool ./xlang` | **Daily incremental** (default) |
| `./xlang-build.sh full` | Full B-strict-style rebuild |
| `make -C compiler …` | Cold start, CI, low-level targets |

**Product binary** — after a proper build, use **`compiler/xlang_asm`** (often mirrored as `compiler/xlang`).  
`xlang-c` and seed helpers are for **cold start and transition**, not the daily release story.

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

More samples: [examples/](examples/) (io, net, async, json, compress, …).

### Acceptance tests

```bash
export XLANG=./compiler/xlang_asm
./tests/run-all.sh                 # full regression (when appropriate)
XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh   # product gate (~129 scripts)
./tests/run-linux-a09-a11-gate.sh  # Linux gold bootstrap subset (Docker OK)
./tests/run-freestanding-hello.sh  # Linux x86_64 freestanding S4 smoke
```

For **self-host / product release claims**, the project requires **L4 true cold** (wipe **all** `.o` under `compiler` / `std` / `core`, rebuild binaries) **plus** dual-platform `run-all-bstrict` green.

Details: [self-host method](analysis/自举方法.md) · [SELFHOST.md](compiler/docs/SELFHOST.md).

> **Daily L2 green on tip ≠ tip L4 pin.**  
> Release pin remains **`9bb7a757c`** (129/129 dual true cold) until an explicit re-pin.  
> Tip dual L4 candidate **`eef4d7743`** and safety net **`ec773fe95`** are **not** automatic pin bumps (see [§7](#7-self-host-status-snapshot--2026-07-31)).

---

## 3. Compiler CLI

Default backend: **ASM** (`-backend asm`).

```bash
xlang [COMMAND] [OPTIONS]
```

### Subcommands

| Command | Description | Usage |
|---------|-------------|-------|
| `build` | Compile `.x` to binary / object (default `a.out`) | `xlang build [options] file.x [-o exe]` |
| `run` | Compile and run `.x` | `xlang run [options] file.x` |
| `check` | Parse + typeck only (no codegen) | `xlang check [paths...]` |
| `fmt` | Format `.x` sources | `xlang fmt [--check] [paths...]` |
| `explain` | Explain a diagnostic code | `xlang explain <CODE>` |
| `test` | Run a test script | `xlang test [script.sh]` |

### Build options (`build` / `run`)

| Option | Description |
|--------|-------------|
| `-backend asm\|c` | Backend (default `asm`) |
| `-O <0\|1\|2\|3\|s>` | Optimization level (default `2`) |
| `-o <path>` | Output binary or `.o` |
| `-L <dir>` | Library search path |
| `-target <triple>` | Target triple (e.g. `aarch64-linux-gnu`) |
| `-target-cpu <cpu>` | `native` \| `generic` \| `avx2` \| … |
| `-freestanding` | Nostdlib static link (Linux x86_64 ELF) |
| `-legacy-f32-abi` | Legacy SysV f32 CALL (f64 widen; default xmm ABI) |
| `-E` | Emit C (debug) |
| `-flto` | Link-time optimization (C backend) |

### Global options

| Option | Description |
|--------|-------------|
| `--print-target-cpu` | Print host CPU features and exit |
| `--explain <CODE>` | Print diagnostic code explanation and exit |
| `--help`, `-h` | Show help |

### Environment variables

| Variable | Effect |
|----------|--------|
| `XLANG_ABI_F32_XMM=0` | Same as `-legacy-f32-abi` (x86_64 SysV) |
| `XLANG_OPT` | Default `-O` level if omitted |
| `NO_COLOR` | Disable color output |
| `CLICOLOR_FORCE=1` | Force color even when piped |
| `XLANG_FORCE_COLOR=1` | Same as `CLICOLOR_FORCE` |

### Examples

```bash
xlang run examples/hello.x
xlang build examples/hello.x -o hello && ./hello
xlang check examples/hello.x
xlang fmt src/
xlang explain XP003
xlang test tests/run-all-bstrict.sh
xlang --lsp                              # language server (stdio JSON-RPC)
xlang build -backend c file.x
xlang build -freestanding file.x         # Linux x86_64 nostdlib
```

Root [build.x](build.x) describes *what* to build. Daily entry: `./xlang-build.sh` / `build_tool`.

---

## 4. Repository layout

```
xlang/
├── README.md · README_zh-CN.md
├── LICENSE · LICENSE.AGPL-3.0 · LICENSE.Apache-2.0 · NOTICE · CONTRIBUTING.md
├── build.x · xlang-build.sh · xbuild/
├── analysis/                 # process docs, RFCs, self-host dashboard
├── docs/                     # language syntax (user-facing)
├── compiler/                 # compiler (.x + seed C / glue)
│   ├── src/                  # lexer · parser · typeck · codegen · asm · pipeline · driver · lsp
│   ├── seeds/                # cold-start pins
│   ├── mk/                   # driver-seed list authority (leaf residual path)
│   ├── docs/SELFHOST.md
│   └── scripts/              # build_xlang_asm, g05, relink, …
├── core/                     # OS-free core library
├── std/                      # OS-facing standard library (product .x; no handwritten std .c)
├── tests/                    # regressions and product gates
├── examples/
├── tools/ · scripts/
├── runtime/                  # freestanding / low-level runtime support
└── editors/                  # vscode · vim · tree-sitter
    └── vscode/               # VS Code / Cursor / Trae + LSP client
```

- **`core/`** does not depend on **`std/`**; **`std/`** may depend on **`core/`**
- Module rule: **directory = module**, entry `mod.x`

Architecture notes (historical narrative): [构架分析.md](analysis/archive/narrative/构架分析.md).

---

## 5. Standard library

### `core` (no OS)

| Module | Role |
|--------|------|
| `core.types` | `size_of` / `align_of`, layout |
| `core.mem` | memory ops |
| `core.option` / `core.result` | option / result |
| `core.slice` / `core.str` | slices and string views |
| `core.fmt` / `core.debug` | format / debug |
| `core.builtin` / `core.iterator` / `core.cmp` | builtins, iteration, compare |

Full list: [docs/07-内置与标准库.md](docs/07-内置与标准库.md).

### `std` (OS-facing)

Product sources under `std/` are **`.x`** (Phase F: no handwritten `.c` / `.h` in `std/`). Coverage includes:

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

Link is **on demand** — unused modules stay out of the final link when possible.

---

## 6. Compiler architecture

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
| **User / product path** | This-SHA `xlang_asm` compiles user `.x` → `-o` / run; product matrix + bstrict |
| **Bootstrap / engineering path** | Seed cold start → `build_xlang_asm` / g05 → optional Stage2 / WPO dogfood |

### Two tracks (do not mix when reading status)

| Track | What it measures | Alone enough to claim “self-host done”? |
|-------|------------------|----------------------------------------|
| **Product** | L4 true cold + product matrix + dual `run-all-bstrict` **129** | **Required**, not sufficient for “zero C forever” |
| **Engineering** | prove T/N, Cap residual pure, Stage2, WPO chain / link / text gates | **No** |

---

## 7. Self-host status (snapshot · 2026-07-31)

> **Authoritative live numbers:** [自举进度.md](analysis/自举进度.md) · [C迁移追踪.md](analysis/C迁移追踪.md) · [LEAF_PATTERN_RESIDUAL.md](compiler/docs/LEAF_PATTERN_RESIDUAL.md).  
> This README only summarizes. **Do not** treat Stage2 / prove / WPO / daily L2 green as a tip L4 re-pin or as “self-host done”.  
> **Bare “continue next step” ≠ physical delete of `compiler/Makefile`.** Endgame delete needs **explicit user authorization** (Windows re-proof and dual tip L4 are already green on the current path).

### Product track

| Item | Status |
|------|--------|
| **L4 release pin** | **`9bb7a757c`** (wave710, 2026-07-29) — dual-host **true cold** + `run-all-bstrict` **129/129** (Ubuntu + macOS) |
| Product bstrict suite | **129** scripts (`tests/run-all-bstrict.sh`; log must show `OK (129 scripts…)`) |
| Ubuntu L4 + full bstrict (pin) | ✅ **129/129** @ **`9bb7a757c`** |
| macOS L4 + full bstrict (pin) | ✅ **129/129** @ **`9bb7a757c`** |
| tip L4 safety net (not a pin bump) | ✅ **`ec773fe95`** (wave840) — mid-endgame tip proved dual L4; **pin stays `9bb7a757c`** until explicit re-pin |
| tip dual L4 candidate (not a pin bump) | ✅ **`eef4d7743`** (wave923) — dual true cold + 129 green; **re-pin only after endgame delete + explicit decision** |
| Windows hybrid / phys-del min-gate | ✅ re-proved green on current tip path (wave922 lineage); tip drift still requires re-proof |
| Gold host | **Ubuntu x86_64** |
| Product binary under test | This-wave `compiler/xlang_asm` (g05 / relink) — **never** leftover Stage2 `xlang_asm2` or old `stage1` |
| Branch residual tip (≠ release pin) | Daily MG work on `self-hosting` (11.3.1 leaf residual · L2). **Exact SHA → dashboard** |

### What “usable” means today

On the **user product path** (`xlang_asm` → `-o` / run / freestanding / gates), the release pin already covers a large closed surface — networking PRIMARY, bare struct lit, CTFE match fold, X ABI P0b waves, Windows hybrid gate, CLI help, `std.fmt` print ownership, freestanding S4 / NL-07, hosted asm matrix, and more.

**Green L2 on residual tip does not auto-raise the L4 pin.**

### Track MG · endgame (Makefile / zero host-cc cold start)

| Item | Status |
|------|--------|
| Goal | Physical delete of `compiler/Makefile` + cold start without host-cc compiling business C (C-migration stages 11–12) |
| Path | **11.3.1 leaf-pattern residual** — absorb host-cc / multi-token / list inventory into shell + `compiler/mk/*.mk` (**Makefile still present**) |
| Tree flags | `TREE_ARMED=1` · `BODY_SHIPPED=0` · `DELETE_ALLOWED=0` · `--delete` never-rm until auth |
| Progress (through 2026-07-31) | Hundreds of residual waves closed (list→mk, FORCE multi-target families, shell-primary phonies, build_xlang_asm make-call shrinkage through ~wave930, …) |
| Endgame preconditions | ✅ Windows re-proof · ✅ dual tip L4 (`eef4d7743`) · ⬜ **explicit user auth** for `phys-del-gate --delete-body` |

### Engineering track (subset)

| KPI / gate | Status |
|------------|--------|
| **T** typeck surface | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **111/111** |
| Cap residual pure | Major waves closed on product pin lineage; open only when product is red |
| **D Stage2** | ✅ freestanding / parity (**≠** full product g05 chain) |
| Stage2 **WPO** chain + strict-link + text-gate | ✅ engineering green (Ubuntu; some Darwin N/A) |

### What is *not* claimed

- **Not** “compiler is 100% `.x` with zero seed”
- **Not** “Stage2 `xlang_asm2` is the product compiler”
- **Not** “engineering WPO green = tip product L4”
- **Not** “dual L2 residual checks = tip L4” — release pin is **`9bb7a757c`** until the next dual **true cold** re-pin
- **Not** “Windows hybrid green = product L4 / self-host done”
- **Not** “11.3.1 residual closed = Makefile deleted” — physical delete is a later endgame wave with **explicit auth**
- Final physical zero-C / full seed elimination (**G**) remains roadmap, not the weekly claim surface

Methodology: [自举方法.md](analysis/自举方法.md) · timeline: [自举时序.md](analysis/自举时序.md) · ops: [SELFHOST.md](compiler/docs/SELFHOST.md) · discipline: [AGENTS.md](AGENTS.md) + skill `xlang-selfhost-product-gate`.

### Near-term front row

1. **Clear remaining preflight blockers / residual make edges** on the MG path (daily dual L2)  
2. **Explicit user auth** → physical Makefile delete (`phys-del-gate --delete-body`) → dual bstrict green  
3. **Re-pin** to tip dual L4 candidate (e.g. **`eef4d7743`** lineage) only after endgame delete is validated — **no soft-skip typeck, no dual authority, no unmapped tip L4 re-pin**

---

## 8. Milestones

| Milestone | Content | Status |
|-----------|---------|--------|
| M0 | Lexer, AST, Parser | ✅ |
| M1 | Typeck, Codegen, Driver | ✅ |
| M2 | import, core/std subset, multi-target | ✅ |
| M3 | Generics, trait, modules, std growth | ✅ |
| M4 | DCE, `-O2`/`-Os`, size / perf baseline | ✅ partial |
| M5 | Bootstrap (compiler rebuilds itself) | 🟡 **usable product path + advanced self-host**; **seed still required for cold start**; Makefile residual path open |
| **Now** | Product L4 dual pin @ **`9bb7a757c`** (129/129); tip dual L4 candidate **`eef4d7743`**; tip L4 safety net **`ec773fe95`**; residual MG **11.3.1** awaiting **explicit auth** for delete | See [dashboard](analysis/自举进度.md) |

---

## 9. Documentation map

| Document | Role |
|----------|------|
| [analysis/自举进度.md](analysis/自举进度.md) | **KPI dashboard** (must update each wave) |
| [analysis/自举时序.md](analysis/自举时序.md) | Self-host timeline (S0–S8) · switch-IDE protocol |
| [compiler/docs/LEAF_PATTERN_RESIDUAL.md](compiler/docs/LEAF_PATTERN_RESIDUAL.md) | 11.3.1 leaf residual human map |
| [analysis/C迁移追踪.md](analysis/C迁移追踪.md) | Endgame debt map (MG / delete-Makefile DAG) |
| [analysis/Makefile迁移表.md](analysis/Makefile迁移表.md) | Makefile → xbuild leaf map |
| [analysis/自举方法.md](analysis/自举方法.md) | Cap / R / L / M method |
| [analysis/自举步骤.md](analysis/自举步骤.md) | Executable gates |
| [docs/README.md](docs/README.md) | Language docs index |
| [analysis/需求分析.md](analysis/需求分析.md) | Goals, perf & safety strategy |
| [analysis/archive/narrative/构架分析.md](analysis/archive/narrative/构架分析.md) | Repo / compiler layout (narrative archive) |
| [analysis/性能压榨.md](analysis/性能压榨.md) | Perf layers / dogfood |
| [compiler/docs/SELFHOST.md](compiler/docs/SELFHOST.md) | Self-host ops |
| [editors/vscode/README.md](editors/vscode/README.md) | Editor plugin + LSP |
| [AGENTS.md](AGENTS.md) | Contributor / agent rules (root-cause, dual authority, platforms) |
| [HOW_TO_TEST.md](HOW_TO_TEST.md) | Testing entry points |

Many RFCs live under `analysis/` (http, async, WPO, …).

---

## 10. Testing and quality

| Suite | Command |
|-------|---------|
| Full regression | `./tests/run-all.sh` |
| Product bstrict | `XLANG=./compiler/xlang_asm XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| Pre-push P0 | `XLANG=./compiler/xlang_asm ./tests/run-pre-push-p0.sh` |
| Linux gold subset | `./tests/run-linux-a09-a11-gate.sh` |
| Topic gates | `tests/run-*-gate.sh` |
| Compile dogfood | `XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

Baselines: `tests/baseline/`. On **true cold full tests**, operators should print log paths (e.g. `/tmp/*true_cold*`, `/tmp/*true_bstrict*`).

### Perf snapshot (historical · 2026-07-09 · Linux x86_64)

Fair wall-time medians vs `clang -O2` (warmup 3 + 20 rounds). Refresh procedure: `analysis/perf-*`.

| Benchmark | ratio (XLANG / C) | Note |
|-----------|------------------|------|
| `loop_i32` | ~0.87 | ✅ |
| `mem_copy` | ~0.87 | ✅ |
| `struct_param` | ~0.08 | ✅ |
| `call_boundary` (fold) | ~0.00 | compile-time affine fold |
| `call_boundary` (real) | ~1.77 | ❌ — stack-heavy ASM; regalloc still weak |

Diff cases D1–D6: 5/6 pass; float D4 remains a known P2 placeholder.

---

## 11. Tooling

| Component | Path |
|-----------|------|
| VS Code / Cursor / Trae | [editors/vscode/](editors/vscode/) |
| Vim | [editors/vim/](editors/vim/) |
| Tree-sitter | [editors/tree-sitter-xlang/](editors/tree-sitter-xlang/) |
| LSP | `xlang --lsp` · `compiler/src/lsp/` |

Plugin install: [editors/vscode/README.md](editors/vscode/README.md).

---

## 12. Why X language — **Three Highs, One Low**

**X language** is a **systems language** for kernels, drivers, runtimes, embedded targets, and high-performance tools: no GC, zero-cost abstractions, an explicit memory model, and freestanding support.

Most languages force a trade-off. X refuses that trade-off:

| Pillar | Target | What it means |
|--------|--------|----------------|
| **High performance** | **Beat careful C by default** | No GC; default ASM backend (+ optional C backend); aggressive alias / `noalias`, BCE, monomorphized generics; arena / region paths with zero hot-path malloc. Speed comes from the **compiler**, not heroics at every call site. |
| **High safety** | **Near Rust in the safe subset** | Compile-time region / borrow / linear checks; `Option` / `Result` instead of silent null; length-carrying slices; graded `unsafe` only at hardware & syscall edges — **auditable**, never ambient UB. |
| **High readability** | **Simpler than C at scale** | `T[]` carries length; no header hell (directory = module); `defer` / `with_arena` / scoped allocators; field access is only `.`; diagnostics with real source locations. |
| **Low learning cost** | **Days, not months — if you already program** | No type-theory bootcamp: a solid imperative background (C / C++ / Java / Go / **JS / TS** / …) is enough. Familiar control flow; no lifetime-annotation maze; progressive path (start “almost C”, then adopt safety features); `xlang build` / `fmt` / LSP in one toolchain. |

**One-line design rule for every language feature:**

> *Would this make a C programmer’s life harder?*  
> If yes → cut it, hide it in the compiler, or quarantine it in `unsafe`.  
> **Simpler than C is the highest design priority.** Safety and speed are delivered by compiler intelligence, not by burdening the author.

### Honest positioning

| vs | X language choice |
|----|-------------------|
| **C** | Same “close to the metal” control — cleaner syntax, fewer footguns, one toolchain, and safety proofs where C has UB. |
| **Rust** | Same ambition on memory safety — **without** a heavy borrow-checker lifestyle; regions + inference + linear types carry the load. |
| **Zig** | Shared love of simplicity and explicitness — plus a first-class safe subset and a stronger static safety story by default. |

### Supporting goals

| Goal | Meaning |
|------|---------|
| **Lightweight** | Few deps; small binaries; freestanding / embedded; std linked on demand |
| **Standard library** | Full `core/` + `std/`; one API across platforms (platform details under `std.sys`) |
| **Self-hosting** | End state: compiler + std 100% `.x`; host C / seed only for cold start (**in progress — not claimed complete**) |

### Design stance

- **Aim** — extreme performance where it matters: **default codegen better than typical careful C**, not “as good if you are careful”.
- **Discipline** — maintainable code, simple development, **memory safety** (no silent UB in the safe subset).
- **Method** — region-based memory + borrow gates + linear types; alias analysis feeds autovec / DCE; `unsafe` stays thin and reviewable.

Longer design notes: [syntax & safety](analysis/语法与类型设计-高性能与内存安全.md) · [requirements](analysis/需求分析.md) · [safety & perf](analysis/安全与性能.md).

---

## 13. Contributing

1. Clone → `make -C compiler build-tool && ./xlang-build.sh first-time` (or full bootstrap-driver path).  
2. Daily edits → `./xlang-build.sh build`, set `XLANG=./compiler/xlang_asm`, run relevant tests / gates.  
3. Product / link / **SHARED** changes → **Ubuntu gold** (and mac when SHARED); release claims need **L4 true cold** + dual bstrict **129** (pin `9bb7a757c` until re-pin).  
4. Commits: Conventional Commits (`feat:` / `fix:` / `docs:` …). New `.x` comments in **English** (see `AGENTS.md` / G.9).  
5. **No dual authority** — seed and `.x` product surfaces move in the **same commit** when both exist.  
6. **No false green** — do not claim self-host complete from prove / Stage2 / WPO alone.

**Main-line resolution** — prioritize self-host / product gates over large new std features; IR v4 architecture is frozen for post-bootstrap work.

---

## 14. License

X language uses **layered licensing** (language libraries permissive; compiler copyleft). See [LICENSE](LICENSE) and [NOTICE](NOTICE).

| Layer | Paths | License |
|-------|--------|---------|
| A — Toolchain | `compiler/`, `tools/`, root `build*.x` | **AGPL-3.0-or-later** ([LICENSE.AGPL-3.0](LICENSE.AGPL-3.0)) |
| B — Language libs | `core/`, `std/` | **Apache-2.0** ([LICENSE.Apache-2.0](LICENSE.Apache-2.0)) |
| Samples | `examples/`, `tests/` | **Apache-2.0** |
| Editors | `editors/vscode`, `editors/tree-sitter-xlang`, `editors/vim` | **Apache-2.0** |
| Third-party | `compiler/seeds/crypto/ed25519/` (orlp) | **zlib** |

**Intent:** programs you write that use `core` / `std` are **not** forced under AGPL. Modifying or redistributing the **compiler / toolchain** is AGPL (or commercial terms).

Contributing terms: [CONTRIBUTING.md](CONTRIBUTING.md).

### Commercial licensing (Layer A only)

For an **AGPL exemption on the compiler / toolchain** (proprietary embedding, closed distribution of a modified toolchain, modified network services without offering corresponding source), contact:

- ShuLiangfu — [admin@shuliangfu.com](mailto:admin@shuliangfu.com)

---

*X language — Three Highs, One Low: faster than C · safer near Rust · simpler than C · learnable in days.*
