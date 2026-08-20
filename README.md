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
| **Status (2026-08-20)** | **Product L4 pin `f7424ae47`** (2026-08-15 dual-host true cold + bstrict **129/129**; previous `e364f4a37` 2026-08-11 → `d79a368b2` 2026-08-10 → `36363b90f` …). Tip on **`self-hosting`**: TYPE_DYN / vtable **F1–F7 dual-end L2 green** · write `let x: Trait = a` (do **not** write `dyn Trait` — **P013**) · dest extras nested ARRAY/SLICE/PTR dest-stamp family closed through `[][2][]*T` · **no pin raise** (daily L2 only). MG Makefile **deleted** (0-make hub). **Self-host not finished** — cold start still needs seed / host `cc`; `pipeline_abi` mega **hard-banned** from pure-asm product (host-cc residual remains). |
| **Live dashboard** | [Progress](analysis/自举进度.md) · [Timeline](analysis/自举时序.md) · [C-migration debt](analysis/C迁移追踪.md) · [Makefile map](analysis/Makefile迁移表.md) · [Leaf residual](compiler/docs/LEAF_PATTERN_RESIDUAL.md) · [Archive 2026-08-19](analysis/自举进度-归档-2026-08-19.md) · [Archive 2026-08-18](analysis/自举进度-归档-2026-08-18.md) |
| **Chinese** | [README_zh-CN.md](README_zh-CN.md) |

---

## Contents

1. [Language sketch](#1-language-sketch)
2. [Quick start](#2-quick-start)
3. [Compiler CLI](#3-compiler-cli)
4. [Repository layout](#4-repository-layout)
5. [Standard library](#5-standard-library)
6. [Compiler architecture](#6-compiler-architecture)
7. [Self-host status](#7-self-host-status-snapshot--2026-08-20)
8. [Milestones](#8-milestones)
9. [Testing and quality](#9-testing-and-quality)
10. [Performance benchmarks](#10-performance-benchmarks)
11. [Tooling](#11-tooling)
12. [Why X language — Three Highs, One Low](#12-why-x-language--three-highs-one-low)
13. [Contributing](#13-contributing)
14. [License](#14-license)

### How to read this README (audiences)

| You are… | Start here | Then |
|----------|------------|------|
| **App / library author** | [§2 Quick start](#2-quick-start) · Hello World | [§3 CLI](#3-compiler-cli) · [§5 std](#5-standard-library) · [docs/](docs/README.md) |
| **Toolchain / compiler contributor** | [§2](#2-quick-start) · [§4 layout](#4-repository-layout) · [§13](#13-contributing) | [§7 self-host](#7-self-host-status-snapshot--2026-08-20) · live [Progress](analysis/自举进度.md) · [AGENTS.md](AGENTS.md) |
| **Release / pin reviewer** | Status table (top) · [§7](#7-self-host-status-snapshot--2026-08-20) | L4 true cold + dual bstrict **129** only; L2 green ≠ re-pin |
| **Need live residual numbers** | **Not this file** — open [Progress](analysis/自举进度.md) or `./xbuild bc-inventory` | This README is a snapshot; dashboards win on conflict |

**Doc roles (do not mix authorities):** root README = product + onboarding landing; `analysis/自举进度.md` = live self-host KPI; `compiler/docs/SELFHOST.md` = operator runbook; `docs/` = language syntax for users; `AGENTS.md` + skill `xlang-selfhost-product-gate` = engineering discipline.

---

## 1. Language sketch

### Types and semantics

- **Primitives** — `i8`/`i16`/`i32`/`i64`, `u8`/`u16`/`u32`/`u64`, `f32`/`f64`, `bool`, `usize`/`isize`
- **Structs & generics** — monomorphized generics; trait / impl; a type-position trait name is a dyn object (`let x: Clone = a`; do **not** write `dyn Trait`)
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
| **Gold lab host** | **Ubuntu x86_64** | Reproducible L4 / product gates; do not treat macOS green alone as SHARED done |
| **Product dual host** | Ubuntu x86_64 + **macOS** | L4 true cold + full `run-all-bstrict` for release pins |
| **Windows** | MSYS2 / MinGW **hybrid** probes | Hybrid green ≠ product L4 / self-host complete |

**Product vs host (do not confuse):**

| Layer | Policy |
|-------|--------|
| **User product binaries** | Goal is **libc-free / freestanding** where the path says so (`-freestanding`, crt0, syscall / `std.sys`, nostdlib static on Linux x86_64, etc.). **X is not “a glibc language.”** Gold on Ubuntu does **not** mean “shipped programs depend on glibc.” |
| **Host OS lab** | We still need **representative machines** to build the toolchain, run CI, and pin L4. That lab is **Ubuntu x86_64 first** — chosen for reproducibility, not as a permanent product libc ABI. |
| **Bootstrap residual** | Some **compiler build / hybrid / seed** steps may still touch host `cc`/`ld` or a system C library while self-hosting is incomplete. That is **engineering residue**, not the end-state product contract. Prefer freestanding gates when reporting “does my program need libc?” |

Linux host care is **kernel era + arch + object/link format (ELF)** and **which host tools built the compiler**, not “every glibc point release.” Distro libc (glibc vs musl) still matters for **host bootstrap quirks** and residual hosted links — it is **not** the product ABI we advertise. On macOS, care is **Darwin major + arch** (arm64 first). On Windows, care is **Win10/11 + x64 toolchain**, not every build number.

**Alpine is supported** as a **host** (CI Docker smoke, musl host facts). It is **not** the gold **lab** host: release pins / L4 truth still mean **Ubuntu x86_64**. Full B-strict / L4 self-host parity on Alpine is on the post-bootstrap track (A-13), not “won’t fix.” Product freestanding on Alpine is the same **no-product-libc** goal as on Ubuntu once the host toolchain path is green.

#### Official matrix — Linux (lab hosts: Ubuntu + Alpine, …)

| Platform | Arch | Tier | Notes |
|----------|------|------|--------|
| **Ubuntu 24.04 LTS** | x86_64 | **1** | Current mainstream LTS lab; CI (`ubuntu-latest` / 24.04 line) |
| **Ubuntu 22.04 LTS** | x86_64 | **1** | Gold-adjacent LTS lab; CI `ubuntu-22.04`; Docker gates often pin 22.04 |
| **Ubuntu 26.04 LTS** (when used as host) | x86_64 | **1** | Newer LTS line — same Tier 1 lab bar once adopted as a primary host |
| **Alpine Linux** | x86_64 | **2** | **Supported host**; CI `docker-distro` (`alpine:3.x`); local `scripts/docker-ci-local.sh alpine`; host facts via `XLANG_HOST_ALPINE` / platform linker docs. Host bootstrap may differ (musl-era tools, stack defaults); product freestanding still targets **no libc**. **Not gold lab**: L4 / release pins still Ubuntu x86_64; full B-strict self-host on Alpine deferred (A-13), not unsupported |
| **Ubuntu 24.04 / current** | aarch64 | **2** | CI probe (`ubuntu-24.04-arm`); not the product gold lab host |
| **Ubuntu 20.04 LTS** | x86_64 | **2** | Late life; may work if host toolchain is new enough |
| Other Linux distros (Debian, Fedora, Arch, …) | x86_64 | **2** | Best effort lab hosts. When filing bugs: **distro + arch + kernel**, build mode (**freestanding vs hosted**), and **host toolchain** (`cc`/`ld` versions) if the failure is in **building** the compiler — **not** “glibc version as product ABI” |
| **Ubuntu 18.04 and older** / ancient host userspace | * | **3** | EOL; host packages / toolchains too old for the lab |

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

Windows status today is **hybrid / min-gate green on the product path**, not “full self-host L4 gold.” See [self-host status](#7-self-host-status-snapshot--2026-08-20) and [Windows limits guide](analysis/Windows平台限制与测试指南.md) when present.

#### Explicitly unsupported (Tier 3 — do not expect fixes)

| Item | Why |
|------|-----|
| Windows 7 / 8 / 8.1 | Long EOL; no modern security / toolchain story |
| Windows 10 before 22H2 | Out of support window for this project |
| macOS 12 and older | SDK / ld64 / system expectations too old |
| Ubuntu 18.04 and older | EOL LTS; ancient host userspace / packages |
| “Every Ubuntu / Windows / macOS point release needs its own VM” | **Out of policy** — use tiers + representative **lab** hosts |

**Not Tier 3:** Alpine — **Tier 2 supported host** (see Linux matrix). Gold is **Ubuntu x86_64 as the L4 lab**, not “product requires glibc / musl unsupported.”

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
# Recommended product entry (Makefile deleted — wave942; 0-make hub wave944)
./xbuild build-tool                  # pinned seeds → build_tool
./xbuild first-time                  # build_tool + daily g05 path
# Or: ./xlang-build.sh first-time

# Cold start with cc only (minimal):
#   cd compiler && sh bootstrap.sh

# Full seed driver (common product / LSP path):
./xbuild bootstrap-driver-seed
FULL=0 bash compiler/scripts/g05_prepare_and_relink.sh
```

### Daily build

```bash
# Daily: G-05 path → xlang_asm relink
./xbuild build
# Or: ./xlang-build.sh build

export XLANG=./compiler/xlang_asm   # this-wave product binary
./tests/run-hello.sh

# Heavier rebuild after backend / seed changes
./xbuild full                        # bootstrap-driver-bstrict path
```

| Entry | Use |
|-------|-----|
| `./xbuild build` / `./xlang-build.sh build` | **Daily incremental** (default) |
| `./xbuild full` | Full B-strict-style rebuild |
| `./xbuild bootstrap-driver-seed` | Cold start seed driver / LSP binary |
| `./xbuild compiler-make <target>` | Residual leaf `.o` / CI hub (0-make) |

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

> **Daily L2 green on tip ≠ L4 pin raise.**  
> **Current product L4 pin = `f7424ae47`** (dual true cold + **129/129**, 2026-08-15). Residual tip may advance with **L2 only** and **does not** re-pin.  
> **`xlang check` syntax gates are paused** on the default L2/L4 product rhythm until self-host close-out; run check only when explicitly dogfooding that surface (see [§7](#7-self-host-status-snapshot--2026-08-20)).

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

## 7. Self-host status (snapshot · 2026-08-20)

> **Authoritative live numbers:** [Progress](analysis/自举进度.md) · [C-migration](analysis/C迁移追踪.md) · [LEAF residual](compiler/docs/LEAF_PATTERN_RESIDUAL.md) · inventory `./xbuild bc-inventory`.  
> This README only summarizes. **Do not** treat Stage2 / prove / WPO / daily L2 green as an L4 re-pin or as “self-host done”.  
> **Makefile physical delete is done** (wave941/942). Product entry is **`./xbuild` only** — do not reintroduce `make -C` orchestration.

### Product track

| Item | Status |
|------|--------|
| **L4 release pin (current)** | **`f7424ae47`** (2026-08-15) — dual-host **true cold** + product matrix + bstrict **129/129**; pin eggs refreshed from this-wave `xlang_asm`; includes Stage12.0.5 pure-asm residual close-out |
| Pin lineage (older → newer) | `9bb7a757c` → `77b334842` → `db809e00f` → `36363b90f` → `d79a368b2` → `e364f4a37` → **`f7424ae47`** |
| Product bstrict suite | **129** scripts (`tests/run-all-bstrict.sh`; log must show `OK (129 scripts…)`) |
| Ubuntu L4 + full bstrict (pin) | ✅ **129/129** @ **`f7424ae47`** (gold lab · wall ~24m45s) |
| macOS L4 + full bstrict (pin) | ✅ **129/129** @ **`f7424ae47`** (wall ~63m38s) |
| Residual tip (≠ pin) | inventory **present 0** · **prefer pure-asm product default** · TYPE_DYN/vtable **F1–F7** dual-end L2 green on `self-hosting` · dest extras nested dest-stamp closed through `[][2][]*T` · **no pin raise** on daily L2 leaves |
| Windows hybrid / phys-del min-gate | ✅ re-proved green (wave922 lineage); tip drift still requires re-proof |
| Gold host | **Ubuntu x86_64** (SSH lab often `ubuntu-remote-server`; LAN `ubuntu-server` may be off-site unreachable) |
| Product binary under test | This-wave `compiler/xlang_asm` (g05 / pure-ld relink) — **never** leftover Stage2 `xlang_asm2` or old `stage1` |
| `xlang check` gates | **Paused** on default L2/L4 product rhythm during self-host close-out; not a default green/red for residual leaves |

### What “usable” means today

On the **user product path** (`xlang_asm` → `-o` / run / freestanding / gates), the release pin already covers a large closed surface — networking PRIMARY, bare struct lit, CTFE match fold, X ABI P0b waves, Windows hybrid gate, CLI help, freestanding S4 / NL-07, hosted asm matrix, **prefer-family pure-asm product default**, Stage12.0.5 pure-asm residual (compile residual 13/13 at pin), and more.

**Green L2 on residual tip does not auto-raise the L4 pin.** Soft pure-asm std residual work (link ondemand / formal_mod companions) advances tip only.

### Tracks (MG / BC / Stage 8 / endgame)

| Track | Status |
|-------|--------|
| **MG** (Makefile orchestration) | ✅ **done** — `compiler/Makefile` deleted; 0-make hub `tests/lib/compiler-make.sh`; product entry `./xbuild` / `./xlang-build.sh` |
| **BC** (product residual host-cc catalog) | 🟢 **30/30 FULLY CLOSED** (wave332) — PRODUCT RETIRED **23/23 = 100%**; HALF=0; product PINNED=0; NON-PRODUCT 7 correctly never-product-chain |
| **M4 five domains** | ✅ **5/5** — runtime / typeck / codegen / parser / link_abi cold-chain closed (prefer FROM_X product default where applicable) |
| **Stage 8 Track L** | ✅ **30/30 FULLY CLOSED** (Batch 3 · wave332) |
| **Stage12 / PC prefer** | ✅ prefer pure-asm product default · FORBID／ALLOW_HOST_CC · **`pipeline_abi` mega pure-asm hard ban** (host-cc residual remains) |
| **PC / G** (seed-free cold / full zero-C) | ⬜ open — seed + host `cc` still required for cold start; mega `pipeline_abi` not pure-asm product |

### Residual inventory (order of magnitude)

| Signal | Value (2026-08-20) |
|--------|---------------------|
| `./xbuild bc-inventory` present rows | **0** (catalog closed; mega / seed cold residual is **not** counted as present leaves) |
| Soft pure-asm std residual ladder (mac L2) | **Green through** string／builtin／encoding／ffi／safe-ffi／io／net／heap／fs／path／env／process／**queue** |
| Soft next reds (examples) | fmt／unicode／compress／debug／… (class-batch via labi fk0／simple-group／companions preferred over one monofile per wave) |
| Efficiency rule | **domain / whole class / whole leaf**, not one BSS micro-cell per wave |

### Engineering track (subset)

| KPI / gate | Status |
|------------|--------|
| **T** typeck surface | **18/18** |
| **EMPTY** | **18/18** |
| **N** prove IDENTICAL | **111/111** |
| Cap residual pure | On-demand L2; dual-export ban where product prefers pure-asm |
| **D Stage2** | ✅ freestanding / parity (**≠** full product g05 chain); dual-end SHA256 match on known Stage2 SHAs |
| Stage2 **WPO** chain + strict-link + text-gate | ✅ engineering green (Ubuntu; some Darwin N/A) |

### What is *not* claimed

- **Not** “compiler is 100% `.x` with zero seed”
- **Not** “Stage2 `xlang_asm2` is the product compiler”
- **Not** “engineering WPO green = tip product L4”
- **Not** “dual L2 residual checks = L4 re-pin” — pin stays **`f7424ae47`** until the next explicit dual **true cold** re-pin
- **Not** “Windows hybrid green = product L4 / self-host done”
- **Not** “Makefile deleted = self-host / zero host-cc done” — seed + `pipeline_abi` mega residual remain
- **Not** “soft pure-asm std residual ladder complete” — queue closed; fmt／unicode／compress／debug… still open on tip
- Final physical zero-C / full seed elimination (**G**) remains roadmap, not the weekly claim surface

Methodology: [自举方法.md](analysis/自举方法.md) · timeline: [自举时序.md](analysis/自举时序.md) · ops: [SELFHOST.md](compiler/docs/SELFHOST.md) · discipline: [AGENTS.md](AGENTS.md) + skill `xlang-selfhost-product-gate`.

### Near-term front row

1. **Daily L2 on `self-hosting`** — F7 dest extras nested dest-stamp closed through `[][2][]*T`; next leftover PTR-outer `*[N][]T` (and host-C suffix / INDEX completeness). **No pin raise** by default  
2. **Keep 0-make honest** — product path stays `./xbuild`; no reintroduce `make -C`; prefer pure-asm default; never pure-asm `pipeline_abi` mega; wrapper first arg stays `rdi`/`x0` = data  
3. **Re-pin** only after explicit decision + dual true cold — **no soft-skip typeck, no dual authority**; nest cap stays **64**

---

## 8. Milestones

| Milestone | Content | Status |
|-----------|---------|--------|
| M0 | Lexer, AST, Parser | ✅ |
| M1 | Typeck, Codegen, Driver | ✅ |
| M2 | import, core/std subset, multi-target | ✅ |
| M3 | Generics, trait, modules, std growth | ✅ |
| M4 | DCE, `-O2`/`-Os`, size / perf baseline | ✅ partial |
| M5 | Bootstrap (compiler rebuilds itself) | 🟡 **usable product path + advanced self-host**; **seed still required for cold start**; MG **deleted** (0-make); BC catalog **present 0** / Track **30/30 CLOSED**; soft pure-asm std residual **in progress** |
| **Now** | L4 pin **`f7424ae47`** (dual 129 · 2026-08-15); tip `self-hosting` F7 TYPE_DYN/vtable + dest extras dest-stamp through `[][2][]*T`; write `let x: Trait = a`; BC／Stage8 **CLOSED** · MG ✅ · prefer pure-asm default | See [dashboard](analysis/自举进度.md) |

---

## 9. Testing and quality

| Suite | Command |
|-------|---------|
| Full regression | `./tests/run-all.sh` |
| Product bstrict | `XLANG=./compiler/xlang_asm XLANG_BSTRICT_SKIP_BUILD=1 ./tests/run-all-bstrict.sh` |
| Pre-push P0 | `XLANG=./compiler/xlang_asm ./tests/run-pre-push-p0.sh` |
| Linux gold subset | `./tests/run-linux-a09-a11-gate.sh` |
| Topic gates | `tests/run-*-gate.sh` |
| Compile dogfood | `XLANG_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh` |

Baselines: `tests/baseline/`. On **true cold full tests**, operators should print log paths (e.g. `/tmp/*true_cold*`, `/tmp/*true_bstrict*`).

Correctness gates above are **pass/fail**. Competitive wall-time / size / compile-time numbers vs C and Zig live in **[§10 Performance benchmarks](#10-performance-benchmarks)** (`bench/` + `./bench.sh`); they are intentionally **not** part of `run-all`.

---

## 10. Performance benchmarks

Fair, reproducible comparison of **xlang vs C vs Zig** on the same algorithms. This section is the README landing page; the operational rulebook and live numbers live under `bench/`.

| Doc | Role |
|-----|------|
| [bench/v1-methodology.md](bench/v1-methodology.md) | **Authority** — fairness rules, toolchain pins, dimension map, v1.0 snapshot |
| [bench/v1-methodology-zh-CN.md](bench/v1-methodology-zh-CN.md) | Same, Chinese |

### What v1.0 is

- **Version**: **v1.0 selfhost-period baseline** (2026-08-02). Compiler still seed/bootstrap; some cases may `COMPILE FAIL` (expected). **v2.0** re-runs the full matrix after selfhost; **v3.0** adds Evented async paths.
- **Fairness hard rules**: same algorithm / data structure / input size; same machine and run; fixed compile options; multi-run stats (median / mean / p95 — **never** “fastest only”); sources public under `bench/`; no cross-opt-level cheating; C uses asm barriers against constant-fold (xlang still lacks an equivalent — suspiciously fast X numbers are flagged).
- **Anchors**: C `cc -std=gnu11 -O2` · Zig `zig build-exe -OReleaseFast` · xlang `xlang-c -O 2`. Gold host for claims: **Ubuntu x86_64**; macOS arm64 is trend-watching.
- **Corpus**: ~155 sources under `bench/`, named `bench/<dim>_<name>.{c,x,zig}`.

### Dimension map (prefix → domain)

| Prefix | Domain | Priority |
|--------|--------|----------|
| `r01_`–`r10_` | Runtime compute | P0 |
| `m01_`–`m05_` | Memory & alloc | P0 |
| `b01_`–`b05_` | Binary size & link | P0 |
| `bt01_`–`bt05_` | Build time | P0 |
| `s01_`–`s05_` | Safety overhead | P1 |
| `a01_`–`a05_` | ABI & call | P1 |
| `cc01_`–`cc05_` | Concurrency | P1 |
| `i01_`–`i08_` | I/O & async | P1 |
| `e01_`–`e04_` / `l01_`–`l03_` | Embedded / language-self | P2 |

### How to run

```bash
./bench.sh                 # default P0+P1 + toolchain matrix (~2 min quick view)
./bench.sh --quick         # fewer samples
./bench.sh --dimension r   # one dimension family
# also: tests/run-perf-baseline.sh --bench
#       tests/run-perf-p0-matrix.sh
#       tests/run-perf-toolchain-matrix.sh
```

Raw logs typically land in `/tmp/xlang_perf_run.log` and `/tmp/xlang_net_perf_run.log`. Environment helpers: `tests/lib/perf-env.sh`.

### v1.0 snapshot (summary only)

Last full documented run in methodology: **2026-08-02 · macOS arm64** (trend). Color legend: ✅ X ≤ C and X ≤ Zig · 🟡 beats exactly one · ❌ slower than both · ⚪ X compile-fail / no data.

| Slice | Tally (from methodology §6) |
|-------|-----------------------------|
| Headline micro/io/net table (§6.0, 13 cases with data) | ✅ 9 · 🟡 2 · ❌ 1 · ⚪ 1 |
| Global color rollup (§6.0–§6.3b) | ✅ 26 · 🟡 6 · ❌ 5 · ⚪ 4 |

Where X is red today: mostly **compile time** (bootstrap expected) and some **concurrency fallbacks**. I/O / several micro cases already show X on par with or ahead of C/Zig on that host — always re-check Ubuntu before product claims. Full tables, `vs_c` / `vs_zig` ratios, and notes (including “likely folded”) are **only** in the methodology docs.

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

1. Clone → `./xbuild build-tool && ./xbuild first-time` (or `./xbuild bootstrap-driver-seed`).  
2. Daily edits → `./xbuild build`, set `XLANG=./compiler/xlang_asm`, run relevant tests / gates.  
3. Product / link / **SHARED** changes → **Ubuntu gold** (and mac when SHARED); release claims need **L4 true cold** + dual bstrict **129** (current pin **`f7424ae47`** until an explicit re-pin).  
4. Daily residual leaves → **L2** (pure-ld + product matrix probes); **do not** default-run `xlang check` gates while they are paused for self-host close-out.  
5. Commits: Conventional Commits (`feat:` / `fix:` / `docs:` …). New `.x` comments in **English** (see `AGENTS.md` / G.9).  
6. **No dual authority** — seed and `.x` product surfaces move in the **same commit** when both exist.  
7. **No false green** — do not claim self-host complete from prove / Stage2 / WPO / daily L2 alone.

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
