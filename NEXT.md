# Shux 完全自举路线图（NEXT）

> **更新时间**：2026-06-19  
> **决议**：标准库**新功能**暂停；**下一阶段唯一主线 = 完全自举**（含 **必达** 阶段 F：全仓库 std 无 C）。  
> **依据**：`[自举分析.md](自举分析.md)`（战略与四关卡）、`[compiler/docs/SELFHOST.md](compiler/docs/SELFHOST.md)`（验收命令）、`[analysis/doc-selfhost-architecture-v1.md](analysis/doc-selfhost-architecture-v1.md)`（1 小时全景）  
> **旧版 std 缺口总表**：已归档至 git 历史（2026-06-18 版）；std 维护暂停，不再在本文件逐模块展开。

---

## 0. 使用说明


| 标记  | 含义                           |
| --- | ---------------------------- |
| ✅   | **已完成**（有 gate / 脚本 / 文档可复验） |
| 🟡  | **进行中**（部分平台或子路径已通，未达金标准）    |
| ⬜   | **未开始**（依赖前置项）               |


**阅读顺序**：§1 定义 → §2 当前站位 → §3 总时序 → §4～§9 按开发顺序执行 → §10 下一步 → §11 验收命令。

**「完全自举」金标准**（与 `自举分析.md` 一致）：

```text
Stage 0（寄生）  C/shux-c 编译全 .sx 编译器  →  Stage 1 二进制
Stage 1（破茧）  Stage 1 再编同一套 .sx 源码  →  Stage 2 二进制
Stage 2（黄金）  SHA256(Stage 1) == SHA256(Stage 2) 且全链无 cc -c 编译器主体
终局（必达）    删除仓库内手写 .c/.h —— 含编译器、LSP、core、std（全仓库无 C）
```

> **决议**：「全仓库 std 无 C」**不是可选项**，而是完全自举定义的组成部分（见 `自举分析.md` 终局 / `完全去掉C与H-前置清单.md` 程度 5）。

---

## 1. 五关卡 × 三平台（自举分析摘要 + 终局 std 无 C）


| 关卡    | 内容                                            | Linux        | macOS        | Windows |
| ----- | --------------------------------------------- | ------------ | ------------ | ------- |
| **一** | 编译器前端全 `.sx`（lexer/parser/ast/typeck/codegen） | ⬜ 像素级替换 C    | ⬜            | ⬜       |
| **二** | 后端 Codegen 自举 MVP（指针/struct/控制流/栈帧/条件编译）      | 🟡 asm 主链    | 🟡 asm 主链    | ⬜       |
| **三** | `_stubs.c` 退役 → `std/sys/*.sx` 独立调 OS         | 🟡 v0～v3     | 🟡 v0～v2     | ⬜ win32 |
| **四** | 三阶段自举闭环 + 二进制哈希一致                             | 🟡 行为 parity | 🟡 行为 parity | ⬜       |
| **五** | **全仓库 std/core 无 C**（`.sx` + FFI/asm，按需链入）    | ⬜            | ⬜            | ⬜       |


**平台策略**（`自举分析.md`）：

- **Linux**：`std/sys/linux.sx` — 内联汇编 `svc/syscall`，可 freestanding，拒绝 libc 脐带。  
- **macOS**：`std/sys/macos.sx` — `extern "C"` 绑 `libSystem.dylib`（稳定，规避 syscall 号漂移）。  
- **Windows**：`std/sys/win32.sx` — `extern "stdcall"` 绑 `kernel32.dll` / `ws2_32.dll` + **IOCP**（禁止硬编码 Nt* syscall 号）。

---

## 2. 当前站位（2026-06-19）


| 维度                        | 状态                    | 说明                                                                                            |
| ------------------------- | --------------------- | --------------------------------------------------------------------------------------------- |
| **标准库**                   | 🟡 功能收口 / C 未清        | mod ✅ 约 39/73；**新功能暂停**，但 **std/*.c 必须清零**（阶段 F）                                              |
| **全仓库 std 无 C**           | ⬜                     | 当前大量 `std/**/*.c`、`runtime.c` 按需链 `.o`；终局必无手写 C                                               |
| **std/core C 存量基线**       | 🟡                    | `**run-std-c-inventory-gate.sh`**：`std/**/*.c = 104`、`core/**/*.c = 4`（total 108）             |
| **语义自举烟测**                | ✅                     | `make -C compiler bootstrap-verify`                                                           |
| **B-strict 构建**           | ✅ macOS arm64 / Linux | `full_asm` + `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1`；24/24 `__text` 非空（macOS 实测）                   |
| **B-partial（Linux crt0）** | ✅                     | 无 `pipeline_gen.c` 的 crt0 链                                                                   |
| **Stage2 行为一致**           | ✅                     | `verify-selfhost-stage2-bstrict.sh`（42 + hello + struct mk）                                   |
| **Stage2 哈希金标准**          | 🟡                    | `run-stage2-hash-gate.sh` 已接入；当前 **track-only**（不等仍 WARN 通过）                                  |
| **std.sys 底座**            | 🟡                    | v0 write + v1 Linux 号表 + v2 macOS write + v3 mmap；**缺** Linux 全 syscall/.sx asm、Windows       |
| **去 C/H（编译器本体）**          | 🟡                    | 仍有 `runtime.c`、`parser.c`、`lsp_diag.c` 等；见 `[完全去掉C与H-前置清单.md](compiler/docs/完全去掉C与H-前置清单.md)` |
| **语言：条件编译 / repr(C)**     | 🟡                    | B-01/B-03 lexer v0 已落地；语义剪枝与 layout codegen 待做 |
| **术语口径统一（NEXT/SELFHOST）** | 🟡                    | `SELFHOST.md` 现偏“编译器本体”；阶段 D 完成后需同步为 **D+E+F 才叫完全自举**                                         |


---

## 3. 总时序（从现在 → 完全自举）

```mermaid
flowchart LR
  subgraph done["已完成底座"]
    A1["B-strict shux_asm"]
    A2["Stage2 行为 parity"]
    A3["std.sys v0～v3"]
    A4["DOC-002 自举文档"]
  end

  subgraph p1["阶段 A：构建链硬化"]
    B1["全平台 B-strict"]
    B2["Stage2 SHA256 门禁"]
    B3["L5 run-all parity"]
  end

  subgraph p2["阶段 B：语言 + std/sys"]
    C1["cfg / repr(C)"]
    C2["linux.sx syscall asm"]
    C3["win32.sx + IOCP"]
    C4["编译器读源不 fopen"]
  end

  subgraph p3["阶段 C：前端 .sx 化"]
    D1["去 pipeline_gen.c"]
    D2["lsp_diag.sx"]
    D3["默认只链 *_sx.o"]
  end

  subgraph p4["阶段 D：黄金自举"]
    E1["Stage1 纯 shux 二进制"]
    E2["Stage2 哈希一致"]
    E3["文档：Stage2 达成"]
  end

  subgraph p5["阶段 E：编译器去 C"]
    F1["lsp / parser / runtime"]
    F2["删除 compiler C/H"]
  end

  subgraph p6["阶段 F：全仓库 std 无 C"]
    G1["std/*.c → .sx / FFI"]
    G2["构建链无 cc 编 std"]
    G3["vX.Y.Z-selfhost 发布"]
  end

  done --> p1 --> p2 --> p3 --> p4 --> p5 --> p6
```



---

## 4. 阶段 A — 构建链与门禁硬化（优先，约 2～4 周）

> **目标**：在不动大架构的前提下，把「能自举」变成「可 CI 证明、可重复、可跨平台」。

### 4.1 变绿判定（避免 🟡 长期不更新）

| 状态 | 含义 |
| --- | --- |
| ✅ | **该条验收标准已全部满足**（gate 硬失败模式亦通过，或平台 scope 内 CI 绿） |
| 🟡 | gate/脚本**已落地**，但金标准/平台/指标**尚未闭合** |
| ⬜ | 未开始或缺 gate |

**按 A 序号推进**：A-07 已绿 → 依次 A-08 → A-09 → …；**不要跳去 B/C** 直到当前条变绿或 documented skip（如 A-13）。

**本机 Darwin 限制**：A-11 / A-12 的 parse count 与 `nm arch_*` **只能在 Linux x86_64 CI 变绿**；本地 gate 会 `N/A` 跳过。


| #    | 任务                                                    | 状态  | 验收                                                                                                 | 变绿条件 |
| ---- | ----------------------------------------------------- | --- | -------------------------------------------------------------------------------------------------- | --- |
| A-01 | 语义自举烟测                                                | ✅   | `make -C compiler bootstrap-verify`                                                                | — |
| A-02 | macOS `bootstrap-driver-bstrict` → `asm_only_strict`  | ✅   | `SELFHOST.md` §4.1；`check_asm_o_quality.sh` → 24/24                                                | — |
| A-03 | Linux crt0 **B-partial**（无 `pipeline_gen.c`）          | ✅   | `make -C compiler bootstrap-driver-crt0`                                                           | — |
| A-04 | B-strict Stage2 **行为** parity                         | ✅   | `verify-selfhost-stage2-bstrict.sh`                                                                | — |
| A-05 | BOOT 门禁族（repro / stage-diag / bstrict-ci）             | ✅   | `run-bootstrap-bstrict-ci.sh`                                                                      | — |
| A-06 | DOC-002 自举架构全景                                        | ✅   | `run-doc-selfhost-architecture-gate.sh`                                                            | — |
| A-07 | push 前 P0 包（bstrict + asm-73 + perf）                  | ✅   | `run-pre-push-p0.sh`                                                                               | — |
| A-08 | **Windows** B-hybrid 可构建 `shux_asm`                   | 🟡  | `run-bootstrap-bstrict-windows-gate.sh` + CI windows job；MSYS experimental 链                       | CI windows job 绿；**非** B-strict |
| A-09 | **Stage2 SHA256 金标准**门禁                               | 🟡  | `run-stage2-hash-gate.sh` + `SHUX_STAGE2_HASH_STRICT=1` 硬失败通过                                  | stage1/stage2 **SHA256 一致** |
| A-10 | **L5 run-all**：bootstrap `shux` 真 parity（缩小 seed 白名单） | 🟡  | `run-l5-run-all-parity-gate.sh`；bstrict **110** 项 ⊆ whitelist                                      | 白名单 sync + **110 项全绿** |
| A-11 | parser/typeck **第二遍 EMIT_HEAVY** 稳定（大 module 不截断）     | 🟡  | `run-typeck-parse-count-gate.sh`（**num_defined** target 146）+ bisect                               | **Linux**：num_defined≥146 且 FAIL=1 |
| A-12 | 跨模块符号统一（`arch_arm64_*` 等）                             | 🟡  | `run-a12-cross-module-symbols-gate.sh` + baseline TSV                                                | **Linux**：`SHUX_A12_CROSS_MODULE_FAIL=1` 无新 U |
| A-13 | Alpine / 其他 Linux 变体 B-strict 或 documented skip       | ⬜   | `run-bootstrap-crossplatform-gate.sh`                                                              | gate 绿或 documented skip |
| A-14 | Stage2 哈希门禁**脚本化**                                     | ✅   | `run-stage2-hash-gate.sh` 已落地并挂 `verify-selfhost-stage2-bstrict`                                     | 脚本 + 接入（**与 A-09 正交**） |


---

## 5. 阶段 B — 语言特性 + std/sys 斩断 C 脐带（约 3～5 周）

> **目标**：新编译器读 `.sx` 源码、写文件、调 OS，**不经过** C 的 `fopen` / `_stubs.c`。对应自举分析 **关卡三 + 缺失拼图 1/2/4**。

### 5.1 语言 / 编译器前端特性（自举必需）


| #    | 任务                                           | 状态  | 说明 / 验收                                                                 |
| ---- | -------------------------------------------- | --- | ----------------------------------------------------------------------- |
| B-01 | `**#[cfg(target_os = "linux")]`** 模块/函数级条件编译 | 🟡  | v1：lexer + parser/asm import 区 cfg 剪枝 + gate |
| B-02 | `**#[cfg(target_arch = "aarch64")]**` 等      | 🟡  | `-target` triple 联动 #[cfg] + gate；host 默认仍可用 |
| B-03 | `**#[repr(C)]` / 显式 struct 对齐**              | 🟡  | v1：`TOKEN_ATTR_REPR_C` + typeck 允许 C padding + layout gate |
| B-04 | **内联汇编 `asm { }` 块**（或等价 intrinsic）          | 🟡  | Linux freestanding 已有 `.s` 桩；需在 **.sx 语法层** 可写                          |
| B-05 | Codegen 自举 MVP 稳定性清单                         | 🟡  | 指针 &/*、struct 字段、if/while/switch、函数调用 ABI — `run-asm-73-gate.sh` 覆盖子集   |
| B-06 | **显式 AST Arena / 对象池**（.sx 写编译器时用）           | 🟡  | `ast_pool` 已有 C+glue；需在 .sx 编译器中可依赖                                     |


### 5.2 std/sys 分平台实现


| #    | 任务                                                                  | 状态  | 说明 / 验收                                         |
| ---- | ------------------------------------------------------------------- | --- | ----------------------------------------------- |
| B-10 | **std.sys v0** — freestanding `os_write`                            | ✅   | BOOT-029；`tests/sys/sys_write_freestanding.sx`  |
| B-11 | **std.sys v1** — Linux syscall 号表                                   | ✅   | `std/sys/linux.sx`；`linux_syscall_nr_smoke.sx`  |
| B-12 | **std.sys v2** — macOS POSIX write                                  | ✅   | `std/sys/macos.sx`；`macos_posix_write_smoke.sx` |
| B-13 | **std.sys v3** — mmap（kv 等用）                                        | ✅   | `std/sys/mmap.sx` + `mmap.inc.c`；按需链入           |
| B-14 | **Linux .sx 真实 syscall**：`read/write/openat/close/mmap` 内联 asm      | 🟡  | v3：openat/mmap/munmap + gate；v2 open+read；v1 read/write/close/exit |
| B-15 | **Linux io_uring** 最小子集（setup/enter/register）                       | ⬜   | 结构体 `#[repr(C)]` + smoke                        |
| B-16 | **macOS** 扩展：`open/read/mmap` 经 libSystem FFI                       | 🟡  | v1：macos_mmap_rw MAP_SHARED + `run-macos-mmap-file-gate.sh`；v0 匿名 mmap |
| B-17 | **std/sys/win32.sx** — `ReadFile/WriteFile/CreateFileW/ExitProcess` | 🟡  | v2：CreateFileA+ReadFile + gate；v1 WriteFile；ExitProcess 待 v3 |
| B-18 | **std/sys/win32 网络** — `WSA*` + **IOCP** 最小 async                   | ⬜   | 为后续 std.net Windows 高性能路径                       |
| B-19 | **std/sys/mod.sx** 统一门面 + `#[cfg]` 分流                               | 🟡  | os_write + cfg import 剪枝（C/asm collect_imports）；`run-sys-mod-cfg-import-gate.sh` |
| B-20 | 编译器自身 **读源文件** 改调 `std.sys`（非 C `fopen`）                            | 🟡  | v1：generated_c_needs_* 改 read_file；读/fmt 已 POSIX；asm -o 仍 FILE* |


### 5.3 去 stubs / runtime C 依赖


| #    | 任务                                             | 状态  | 说明                                   |
| ---- | ---------------------------------------------- | --- | ------------------------------------ |
| B-30 | 盘点 `_stubs.c` / `runtime.c` 中 OS 调用            | 🟡  | 见 `完全去掉C与H-前置清单.md`                  |
| B-31 | freestanding_io 保留为 **极薄 .s** 或迁入 linux.sx asm | 🟡  | x86_64 已有 `freestanding_io_x86_64.s` |
| B-32 | **按需链 std.o** 与自举 **不依赖 cc 编译 std**            | ⬜   | 与 B-14/B-17 同步                       |


---

## 6. 阶段 C — 编译器前端 .sx 化（约 4～6 周）

> **目标**：构建编译器时 **默认只链 `.sx` 产出的 .o`**，对应自举分析 **关卡一** 与` 完全去掉C与H` 条目 2、3。


| #    | 任务                                                                       | 状态  | 说明 / 验收                      |
| ---- | ------------------------------------------------------------------------ | --- | ---------------------------- |
| C-01 | 前端模块 **.sx 源码齐全**（lexer/parser/ast/typeck/codegen/pipeline/driver）       | ✅   | `compiler/src/**/*.sx`       |
| C-02 | `build_asm/*.o` 全量 `-backend asm` 构建                                     | ✅   | `asm_build_list.sx`          |
| C-03 | **去掉 `cc -c pipeline_gen.c`**（全平台 B-strict）                              | 🟡  | macOS/Linux ✅ B-strict；Windows B-hybrid **track-only** 审计（`SHUX_WIN_C03_PIPELINE_GEN_FAIL=1`） |
| C-04 | `**-E-extern` 生成 C 自带 extern**（去 `lsp_io_extern.h`）                      | 🟡  | shux-c：parser 零 fix_parser_pool；shux-sx 仍条件 perl 回退 |
| C-05 | **LSP**：`lsp_diag.sx` 或 C 兼容 parse API                                   | ⬜   | 方案 A/B 见前置清单 §2              |
| C-06 | Makefile **默认** `parser_sx.o` / `typeck_su.o` / `ast_su.o`，不链 `parser.o` | ⬜   | bootstrap + CI 同步改           |
| C-07 | **像素级**验证：`.sx` 编译器 ≡ C 编译器（同一输入 AST/产物）                                 | ⬜   | 差分测试 harness                 |
| C-08 | `main.c` 收成一行入口；`runtime.c` 业务迁 `driver.sx` / `build.sx`                 | ⬜   | 前置清单 §4                      |
| C-09 | mega7 / force_stub 清理（parser 无 C 回退）                                     | 🟡  | `analysis/boot-mega7-gap.md` |


---

## 7. 阶段 D — 三阶段自举闭环（约 2～3 周）

> **目标**：达成 `自举分析.md` **Stage 0→1→2** 与 **SHA256 一致**。


| #    | 任务                                                      | 状态  | 说明 / 验收                                      |
| ---- | ------------------------------------------------------- | --- | -------------------------------------------- |
| D-01 | **Stage 0**：C/seed 编译出 **Stage 1** 纯 shux 编译器           | 🟡  | 当前 `shux_asm`；仍含少量 C seed/ panic             |
| D-02 | **Stage 1** 编译同一 tree → **Stage 2**                     | 🟡  | `verify-selfhost-stage2-bstrict.sh`          |
| D-03 | **Stage 1 与 Stage 2 二进制哈希一致**                           | ⬜   | **完全自举金标准**                                  |
| D-04 | Stage2 扩展：`make test_sx` / `run-portable-suite` 两代 diff | ⬜   | 同一 SHUX=stage1 vs stage2                     |
| D-05 | 发布 `**shux` 单二进制** 不依赖 `shux-c` 冷启动                     | ⬜   | 仅保留 bootstrap 脚本用于考古                         |
| D-06 | 文档：README 声明 **Stage2 黄金自举** + 复现命令                     | ⬜   | 更新 `SELFHOST.md` §1（**不含**最终「完全自举」——须等 F 完成） |


---

## 8. 阶段 E — 删除 C/H（编译器 + LSP，约 2～4 周）

> **依据**：`[compiler/docs/完全去掉C与H-前置清单.md](compiler/docs/完全去掉C与H-前置清单.md)` 程度 1～4。**不含 std** — std 在 §9 阶段 F 单独清场。


| #    | 任务                                                                              | 状态  | 目标文件     |
| ---- | ------------------------------------------------------------------------------- | --- | -------- |
| E-01 | 删除 `lsp_io_extern.h` / `lsp_gen_extern.h`                                       | ⬜   | 程度 1     |
| E-02 | 删除 `lsp_diag.c`                                                                 | ⬜   | 程度 2     |
| E-03 | 删除 `parser.c` / `typeck.c` / `ast.c` / `codegen.c` / `lexer.c` / `preprocess.c` | ⬜   | 程度 3     |
| E-04 | `runtime.c` 仅保留 ABI 边界或全删                                                       | ⬜   | 程度 4     |
| E-05 | `include/*.h` 仅保留 FFI/ABI 必需                                                    | ⬜   | 程度 4     |
| E-06 | CI：**构建链不出现 `cc -c`** 编译器 `.c`（链接器 `ld`/`clang` 除外）                             | ⬜   | 目标 B 完整版 |


---

## 9. 阶段 F — 全仓库 std 无 C（必达终局，约 8～16 周）

> **目标**：`core/` + `std/` 下**零手写 `.c/.h` 业务实现**；OS 边界仅允许 `.sx` 内 `asm { }` 或 `extern` FFI（+ 极薄 `.s` 入口如 crt0，若仍需要）。  
> **与阶段 E 关系**：编译器本体先去 C（E），再系统性清 std（F）；**未完成 F 不得宣称「完全自举」**。  
> **依据**：`完全去掉C与H-前置清单.md` **程度 5**；`自举分析.md` Stage 3「彻底消灭 C」。

### 9.1 清场原则


| 原则           | 说明                                                                |
| ------------ | ----------------------------------------------------------------- |
| **mod 面不变**  | 用户仍 `import("std.*")`；实现从 `.c` 迁 `.sx` 或 `extern` 系统 DLL/dylib    |
| **按需链接保留**   | 无 C 不等于全量静态链入；runtime 扫描符号 → 链对应 `.o`（由 `.sx` 编译产出）               |
| **分模块推进**    | 先 **std.sys / std.io / std.fs / std.mem**，再 net/crypto/compress 等 |
| **每模块 gate** | 删除某 `.c` 前：对应 smoke/gate 绿 + 文档同步                                 |


### 9.2 任务清单


| #    | 任务                                                                       | 状态  | 说明 / 验收                                                                          |
| ---- | ------------------------------------------------------------------------ | --- | -------------------------------------------------------------------------------- |
| F-01 | **inventory**：列出全仓库 `std/**/*.c`、`core/**/*.c` 及链入点                      | 🟡  | `**run-std-c-inventory-gate.sh`** + `tests/baseline/std-c-inventory.tsv`（108 文件） |
| F-02 | **std.sys** 去 C：`mmap.inc.c` 等 → `.sx` asm/FFI                           | 🟡  | v3 仍含 `mmap.inc.c`                                                               |
| F-03 | **std.io / std.fs / std.mem / std.heap** 核心路径 .sx 化                      | ⬜   | 编译器 bootstrap 可读源、写产物                                                            |
| F-04 | **std.net / std.compress / std.crypto** 等 `.inc.c` → `.sx` 或分平台 FFI      | ⬜   | 按模块 gate 逐个替换                                                                    |
| F-05 | **std.db**（sqlite/kv/arrow）`.c` → `.sx` 或 OS 纯 FFI                       | ⬜   | 当前 kv/arrow/sqlite 均为 `.c`                                                       |
| F-06 | **runtime.c** 中 std 按需链路径改为链 `**.sx` 产物 .o**                             | ⬜   | 无 `cc -c std/*.c`                                                                |
| F-07 | **Makefile / build.sx**：构建 std 仅 `-backend asm` 或自举 shux，**禁止 cc 编 std** | ⬜   | CI 审计无 std 的 `cc -c`                                                             |
| F-08 | **core/** 确认无 `.c`（或仅保留 0 文件）                                            | 🟡  | 以 mod.sx + 编译器内建为准                                                               |
| F-09 | 全仓库 `**grep -r '\.c$'` 门禁**（compiler + std 白名单为空）                        | ⬜   | 新增 `run-no-handwritten-c-gate.sh`                                                |
| F-10 | `**make test_sx` + portable suite** 在「无 std C」构建下全绿                      | ⬜   | 与阶段 D Stage2 联动                                                                  |
| F-11 | Tag `**vX.Y.Z-selfhost`**：发布物 = 单二进制 + 全 `.sx` 源码树                       | ⬜   | README / SELFHOST 声明完全自举                                                         |
| F-12 | 文档口径统一：`README.md` + `SELFHOST.md` 将「完全自举」改为 **D+E+F**                   | ⬜   | 不再把仅 Stage2/B-strict 写成完全自举                                                      |


### 9.3 推荐模块顺序（阶段 F 内部）

1. `std/sys`（含 mmap）→ 2. `std/io` + `std/fs` → 3. `std/mem` + `std/heap` → 4. `std/process` + `std/path` → 5. `std/net` 族 → 6. 其余 std → 7. `std/db` → 8. runtime 链入表收尾。

---

## 10. 建议执行顺序（下一步动作）

> **严格按 A 序号**：A-07 已绿 → **A-08 → A-09 → A-10 → A-11 → A-12 → A-13**；每项变绿后再进 B/C。  
> **完全自举 = D（哈希）+ E（编译器无 C）+ F（全仓库 std 无 C）**，缺一不可。

| 序 | 条 | 动作 | 变绿命令 / 备注 |
| --- | --- | --- | --- |
| 1 | **A-08** | Windows B-hybrid CI 绿 | `./tests/run-bootstrap-bstrict-windows-gate.sh`（MSYS2）；CI `windows` job |
| 2 | **A-09** | Stage2 SHA256 一致 | `verify-selfhost-stage2-bstrict` → `SHUX_STAGE2_HASH_STRICT=1 ./tests/run-stage2-hash-gate.sh` |
| 3 | **A-10** | L5 110 项 shux_asm 全绿 | `make -C compiler bootstrap-driver-bstrict` 后 `./tests/run-l5-run-all-parity-gate.sh` |
| 4 | **A-11** | typeck num_defined→146 | **Linux**：`SHUX_TYPECK_PARSE_COUNT_FAIL=1 ./tests/run-typeck-parse-count-gate.sh` |
| 5 | **A-12** | 消除 arch_* U | **Linux**：`SHUX_A12_CROSS_MODULE_FAIL=1 ./tests/run-a12-cross-module-symbols-gate.sh` |
| 6 | **A-13** | Alpine/cross 或 skip 文档 | `./tests/run-bootstrap-crossplatform-gate.sh` |
| 7 | **B-01…** | 语言/std.sys | 见 §5；**须 A 阶段闭合后再默认推进** |
| 8 | **C-04→C-06** | -E-extern / 只链 `*_sx.o` | 见 §6 |
| 9 | **D/E/F** | 完全自举终局 | 见 §7–§9 |

**当前阻塞（2026-06）**：

- **Darwin 本地**：A-11 / A-12 gate 直接 `N/A`，**无法在本机变绿**，只能 Linux CI 或远程 runner。
- **A-09**：行为 parity（A-04）已绿，**二进制 SHA256 仍不一致** → 故意 track-only，不能标绿。
- **A-10**：白名单 sync 已 OK；缺 `shux_asm` 跑完 110 项（需 `bootstrap-driver-bstrict`）。
- **A-14**：脚本化已完成 → **已标 ✅**（与 A-09 分开）。

---

## 11. 验收命令速查

```bash
# 语义自举
make -C compiler bootstrap-verify

# 生产 shux_asm（B-strict）
make -C compiler bootstrap-driver-bstrict

# CI 等价全链
SHUX=./compiler/shux_asm ./tests/run-bootstrap-bstrict-ci.sh

# Stage2 行为 parity
make -C compiler bootstrap-verify-stage2-bstrict

# Stage2 SHA256（A-09；默认 track-only，严格：SHUX_STAGE2_HASH_STRICT=1）
./tests/run-stage2-hash-gate.sh compiler/shux_asm_stage1 compiler/shux_asm2

# Windows B-hybrid（A-08；仅 MSYS2）
./tests/run-bootstrap-bstrict-windows-gate.sh
# C-03 Windows track-only（B-hybrid 日志 cc -c pipeline_gen.c 计数；严格：SHUX_WIN_C03_PIPELINE_GEN_FAIL=1）
SHUX_WIN32_WRITE_FAIL=1 ./tests/run-win32-write-gate.sh
SHUX_WIN32_READ_FILE_FAIL=1 ./tests/run-win32-read-file-gate.sh

# L5 bstrict 白名单（A-10）
./tests/run-l5-run-all-parity-gate.sh

# typeck 模块 parse 函数数（A-11；Linux；指标 num_defined）
SHUX_TYPECK_PARSE_COUNT_FAIL=1 ./tests/run-typeck-parse-count-gate.sh
./tests/run-typeck-parse-bisect-gate.sh

# std/core .c 存量盘点（F-01）
./tests/run-std-c-inventory-gate.sh

# B-01：#[cfg(...)] 词法跳过（shux-c / 任意平台）
SHUX_CFG_ATTR_SKIP_FAIL=1 ./tests/run-cfg-attribute-skip-gate.sh

# B-02：#[cfg] 与 -target triple 联动（cross OS/arch 剪枝）
SHUX_CFG_TARGET_TRIPLE_FAIL=1 ./tests/run-cfg-target-triple-gate.sh

# B-14：Linux freestanding syscall invoke（Linux x86_64）
SHUX_LINUX_SYSCALL_INVOKE_FAIL=1 ./tests/run-linux-syscall-invoke-gate.sh
SHUX_LINUX_OPEN_READ_FAIL=1 ./tests/run-linux-open-read-gate.sh
SHUX_LINUX_MMAP_INVOKE_FAIL=1 ./tests/run-linux-mmap-invoke-gate.sh
SHUX_LINUX_OPENAT_READ_FAIL=1 ./tests/run-linux-openat-read-gate.sh

# B-20：std.sys os_read_file_into（任意平台 shux-c）
SHUX_SYS_READ_FILE_FAIL=1 ./tests/run-sys-read-file-gate.sh
SHUX_B20_GENERATED_C_SCAN_FAIL=1 ./tests/run-b20-generated-c-scan-gate.sh

# C-04：-E-extern 自动生成 import extern（shux-c）
SHUX_E_EXTERN_IMPORT_FAIL=1 ./tests/run-e-extern-import-gate.sh
SHUX_LEXER_E_EXTERN_FAIL=1 ./tests/run-lexer-e-extern-gate.sh
SHUX_PIPELINE_E_EXTERN_FAIL=1 ./tests/run-pipeline-e-extern-gate.sh
SHUX_PARSER_E_EXTERN_FAIL=1 ./tests/run-parser-e-extern-gate.sh

# B-16：macOS libSystem mmap（Darwin）
SHUX_MACOS_MMAP_FAIL=1 ./tests/run-macos-mmap-gate.sh
SHUX_MACOS_MMAP_FILE_FAIL=1 ./tests/run-macos-mmap-file-gate.sh

# B-03：#[repr(C)] 词法跳过 + C ABI layout 烟测（shux-c / 任意平台）
SHUX_REPR_C_ATTR_SKIP_FAIL=1 ./tests/run-repr-c-attribute-skip-gate.sh
SHUX_REPR_C_LAYOUT_FAIL=1 ./tests/run-repr-c-layout-gate.sh

# B-19：std.sys 统一 os_write（任意平台 shux-c）
SHUX_SYS_PLATFORM_WRITE_FAIL=1 ./tests/run-sys-platform-write-gate.sh
SHUX_SYS_MOD_CFG_IMPORT_FAIL=1 ./tests/run-sys-mod-cfg-import-gate.sh

# 跨模块 arch/backend 符号（A-12；Linux）
SHUX_A12_CROSS_MODULE_FAIL=1 ./tests/run-a12-cross-module-symbols-gate.sh

# push 前
SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh

# 自举文档门禁
./tests/run-doc-selfhost-architecture-gate.sh

# 失败诊断
./tests/run-bootstrap-bstrict-ci.sh 2>&1 | tee /tmp/boot.log
./tests/run-bootstrap-stage-diag.sh /tmp/boot.log
```

> F 阶段仍缺一条**必须新增**门禁脚本：  
> `tests/run-no-handwritten-c-gate.sh`（F-09，手写 C 清零审计）  
> Stage2 哈希：`tests/run-stage2-hash-gate.sh`（A-09/A-14，已接入 verify-stage2-bstrict）

---

## 附录 A — 标准库状态说明

> **功能扩展**暂停（HTTP/3、kv 多级 SST 深化等不再排期）。  
> **实现去 C**（阶段 F）**不暂停** — 完全自举必达项。


| 里程碑                                           | 状态  | 摘要                        |
| --------------------------------------------- | --- | ------------------------- |
| std.http HTTP/1.1 + HTTP/2 v1                 | ✅   | 远期 HTTP/3 非目标             |
| std.websocket / std.net TLS / TcpConnPool     | ✅   |                           |
| std.async net/fs + datetime IANA + compress 流 | ✅   | #78～#81                   |
| std.sqlite / std.db blob + kv/arrow + docs/07 | ✅   | #82～#93；**功能**收口          |
| mod ✅ 计数（2026-06-18 审计）                       | ✅   | core 11/11；std 约 28 mod ✅ |
| **std/*.c 清零（阶段 F）**                          | ⬜   | **完全自举必达**                |


---

## 附录 B — 文档索引


| 文档                                                                                     | 用途                      |
| -------------------------------------------------------------------------------------- | ----------------------- |
| `[自举分析.md](自举分析.md)`                                                                   | 战略、syscall 平台策略、四关卡、三阶段 |
| `[compiler/docs/SELFHOST.md](compiler/docs/SELFHOST.md)`                               | 目标 A/B/C、拓扑、CI job      |
| `[analysis/doc-selfhost-architecture-v1.md](analysis/doc-selfhost-architecture-v1.md)` | 新人 1 小时全景               |
| `[compiler/docs/完全去掉C与H-前置清单.md](compiler/docs/完全去掉C与H-前置清单.md)`                       | 去 C/H 分程度清单             |
| `[compiler/src/asm/README.md](compiler/src/asm/README.md)`                             | asm 后端能力表               |
| `[docs/07-内置与标准库.md](docs/07-内置与标准库.md)`                                               | 用户-facing std API       |


---

*本文档随自举推进更新；**下一编辑**请同步 §2 当前站位与 §10 第一条未完成任务。*