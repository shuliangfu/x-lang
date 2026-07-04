# Shux 完全自举路线图（NEXT）

> **更新时间**：2026-06-28（**G-FFI-3/4 gate ✅** #88；同步 [`analysis/FFI隔离.md`](analysis/FFI隔离.md) §7.5）  
> **决议**：标准库**新功能**暂停；**唯一主线 = 完全自举终局**（D+E+F ✅ v1 已闭合 → **阶段 G 清场** + **F-no-libc 硬绿**）。**FFI 隔离（LANG-007 v2）** 与 G **并行**，**不阻塞** bootstrap-min / bootstrap-gold。  
> **依据**：[`自举分析.md`](自举分析.md)（战略与五关卡）、[`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)（验收命令）、[`analysis/doc-selfhost-architecture-v1.md`](analysis/doc-selfhost-architecture-v1.md)（1 小时全景）  
> **旧版 std 缺口总表**：已归档至 git 历史；std 功能扩展暂停，**实现去 C（F-ZC）已闭合**。

---

## 0. 使用说明


| 标记  | 含义                           |
| --- | ---------------------------- |
| ✅   | **已完成**（有 gate / 脚本 / 文档可复验） |
| 🟡  | **进行中**（部分平台或子路径已通，未达金标准）    |
| ⬜   | **未开始**（依赖前置项）               |
| ⏭   | **延后**（documented defer；自举闭环后再做，**不阻塞** A→B→C） |


**阅读顺序**：§1 定义 → §2 进度仪表盘 → §3 总时序 → §4～§9 阶段 A～F（已完成项作基线）→ §10 **阶段 G（当前主线）** → §11 下一步 → §12 验收命令。

### 0.1 完全自举进度仪表盘（2026-06-24）

| 阶段 | 名称 | 状态 | 一句话 |
|------|------|------|--------|
| A | 构建链硬化 | 🟡 | Docker W3：**A-09/A-11/A-12 ✅**；**al06 ✅**；**i64-ctfe `-o` ✅**；**ub bounds ✅**；**A-10**（std path/net hang）仍待 |
| B | 语言 + std/sys | ✅ | cfg/repr(C)/linux.x/win32.x v1 |
| C | 前端 .x 化 | ✅ | 默认 `*_x.o`，无 C 前端回退 |
| D | 黄金自举 | ✅ | Stage2 SHA256 一致 |
| E | 编译器去 C | ✅ E-soft v2 | 默认 no_c；**~208 `.c` 仍保留** |
| F | std 无 C | ✅ F-ZC | `std/` **0 `.c` + 0 `.h`** |
| F-no-libc | Linux 零 libc | 🟡 | NL-07 v4 track；用户路径 NL-05 ✅ |
| **G** | **终局清场** | 🟡 **当前主线** | G-06 ~92%；W2 ✅；W3 全链 🟡 |

**完全自举（D+E+F）v1**：✅ 已在 Linux x86_64 验收口径下闭合。  
**终局（G + F-no-libc 硬绿）**：🟡 进行中 — G-06 冷启动 + W2 已绿；W3 **A-09 hash + al06 + i64-ctfe `-o` + ub ✅**；**A-10**（std path/net timeout）仍待；详见 [`自举进度.md`](analysis/自举进度.md)。  
**FFI 隔离（G-FFI）**：🟡 **并行轨** — L1/L3 v1 ✅；LANG-007 v2 gate ✅（G-FFI-3/4）；**std 层 unsafe 包裹 ✅**（#89）；G-FFI-5 尾声 ⬜；见 §10.5。

**「完全自举」金标准**（与 `自举分析.md` 一致）：

```text
Stage 0（寄生）  C/shux-c 编译全 .x 编译器  →  Stage 1 二进制
Stage 1（破茧）  Stage 1 再编同一套 .x 源码  →  Stage 2 二进制
Stage 2（黄金）  SHA256(Stage 1) == SHA256(Stage 2) 且全链无 cc -c 编译器主体
终局（阶段 G）  物理删除仓库内手写 .c/.h + Linux bootstrap -nostdlib + build.x 替代 Makefile
```

> **决议**：「全仓库 std 无 C」**不是可选项**（F-ZC ✅ 已达成）。**物理零 C** 与 **零 libc bootstrap** 见 **§10 阶段 G**。

---

## 1. 五关卡 × 三平台（自举分析摘要 + 终局 std 无 C）


| 关卡    | 内容                                            | Linux        | macOS        | Windows |
| ----- | --------------------------------------------- | ------------ | ------------ | ------- |
| **一** | 编译器前端全 `.x`（lexer/parser/ast/typeck/codegen） | ✅ 默认 `*_x.o` | ✅ B-strict | 🟡 B-hybrid |
| **二** | 后端 Codegen 自举 MVP（指针/struct/控制流/栈帧/条件编译）      | ✅ asm 主链    | ✅ asm 主链    | ⬜       |
| **三** | `_stubs.c` 退役 → `std/sys/*.x` 独立调 OS         | ✅ v1 gate | ✅ v1 gate | 🟡 v1 门面 |
| **四** | 三阶段自举闭环 + 二进制哈希一致                             | ✅ D v1 | ✅ 行为 parity | ⬜       |
| **五** | **全仓库 std 无 C**（`.x` + FFI/asm，按需链入）    | ✅ F-ZC | ✅ F-ZC | ✅ F-ZC |
| **六** | **终局清场**（物理删 C/H、`-nostdlib` bootstrap、无 Makefile） | ⬜ 阶段 G | ⬜ | ⬜ |


**平台策略**（`自举分析.md`）：

- **Linux**：`std/sys/linux.x` — 内联汇编 `svc/syscall`，可 freestanding，拒绝 libc 脐带。  
- **macOS**：`std/sys/macos.x` — `extern "C"` 绑 `libSystem.dylib`（稳定，规避 syscall 号漂移）。  
- **Windows**：`std/sys/win32.x` — `extern "stdcall"` 绑 `kernel32.dll` / `ws2_32.dll` + **IOCP**（禁止硬编码 Nt* syscall 号）。

---

## 2. 当前站位（2026-06-21）


| 维度                        | 状态                    | 说明                                                                                            |
| ------------------------- | --------------------- | --------------------------------------------------------------------------------------------- |
| **完全自举 D+E+F**            | ✅ v1                  | Stage2 SHA256 + E-soft + F-ZC；见 §0.1 仪表盘                                                      |
| **标准库 std 无 C**           | ✅ F-ZC                | `find std -name '*.c' -o -name '*.h'` → **0/0**；功能扩展暂停                                      |
| **core 无 C**               | 🟡                    | **5** 个 `.c`（builtin/mem/slice/debug/assert）；终局见 **G-01**                                      |
| **compiler 无 C（运行时）**     | ✅ E-soft v2           | 默认 bootstrap 不链 C 前端；**~208 `.c` 文件仍保留**（考古用 `SHUX_LEGACY_C_FRONTEND=1`）                  |
| **全仓库零 C（F-09 STRICT）**  | ⬜                     | 跟踪模式：**std 0 + core 5 + compiler ~208**；`SHUX_NO_HANDWRITTEN_C_STRICT=1` 当前必红 → **阶段 G**   |
| **语义自举烟测**                | ✅                     | `make -C compiler bootstrap-verify`                                                           |
| **B-strict 构建**           | ✅ macOS arm64 / Linux | `full_asm` + `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1`；24/24 `__text` 非空                              |
| **Stage2 哈希金标准**          | ✅                     | Docker Linux x86_64 SHA256 一致（2026-06-20）                                                    |
| **std.sys 底座**            | ✅ v1                  | B-01～B-32 v1；见 `analysis/phase-b-completion-v1.md`                                            |
| **F-no-libc bootstrap**     | 🟡 NL-07 v4 track    | 用户 `-freestanding` NL-05 ✅；编译器链仍 `-lc` → G-03                                           |
| **术语口径（NEXT/SELFHOST）**   | ✅ F-12 v1             | 「完全自举 = D+E+F」已统一；终局 G 见 §10                                                          |


### 2.12 Phase 3 首批（PLAN-001；§2.12）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| LANG-009 | 语言 | `Option<T>` 泛型 struct 完整形态 | P0 | ✅ | `run-lang-option-gate.sh` |
| LANG-010 | 语言 | `Result<T,E>` 泛型 struct 完整形态 | P0 | ✅ | `run-lang-result-gate.sh` |
| CORE-016 | core | 泛型 Option/Result 与 core 模块统一 | P0 | ✅ | `run-core-types-generic-gate.sh` |
| BOOT-019 | 自举 | Stage2 扩面 dogfood smoke | P0 | ✅ | `run-boot-019-stage2-dogfood-gate.sh` |
| BOOT-020 | 自举 | mega7 parser 替换里程碑验收 | P0 | ✅ | `run-boot-020-mega7-milestone-gate.sh` |
| COMP-013 | 编译器 | regalloc 质量波次 gate 扩展 | P1 | ✅ | `run-comp-regalloc-quality-gate.sh` |
| COMP-014 | 编译器 | isel 回归矩阵扩展 | P1 | ✅ | `run-comp-isel-p0-gate.sh` |
| STD-061 | 标准库 | simd shuffle/select 生产级深化 | P2 | ✅ | `run-std-simd-prod-gate.sh` |
| STD-062 | 标准库 | regex 纯引擎性能优化 | P2 | ✅ | `run-std-regex-prod-gate.sh` |
| TOOL-009 | 工具 | VS Code 扩展 0.2 稳定发布 | P1 | ✅ | `run-tool-vscode-gate.sh` |
| PLAN-001 | 治理 | Phase 3 路线图定版 | P0 | ✅ | `run-phase3-roadmap-gate.sh` |

### 2.13 Phase 3 第二批（PLAN-002；§2.13）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-021 | 自举 | mega7 parser 实替换（非 stub） | P0 | ✅ | `run-boot-021-mega7-promote-gate.sh` |
| COMP-015 | 编译器 | WPO 小规模持续启用 | P1 | ✅ | `run-comp-wpo-prod-gate.sh` |
| STD-063 | 标准库 | `std.elf` 只读解析深化 | P2 | ✅ | `run-std-elf-deep-gate.sh` |
| PLAN-002 | 治理 | Phase 3 第二批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave2-gate.sh` |

### 2.14 Phase 3 第三批（PLAN-003；§2.14）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-022 | 自举 | mega7 B1–B7 emit 晋升 | P0 | ✅ | `run-boot-022-mega7-emit-gate.sh` |
| COMP-016 | 编译器 | riscv64 后端矩阵扩展 | P1 | ✅ | `run-comp-riscv64-wave-gate.sh` |
| STD-064 | 标准库 | `std.elf` program header 只读 | P2 | ✅ | `run-std-elf-phdr-gate.sh` |
| PLAN-003 | 治理 | Phase 3 第三批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave3-gate.sh` |

### 2.15 Phase 3 第四批（PLAN-004；§2.15）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-023 | 自举 | mega7 7/7 全量 emit | P0 | ✅ | `run-boot-023-mega7-full-emit-gate.sh` |
| COMP-017 | 编译器 | WPO default tier 烟测 | P1 | ✅ | `run-comp-wpo-default-gate.sh` |
| STD-065 | 标准库 | `std.db` SQLite exec 深化 | P2 | ✅ | `run-std-sqlite-exec-deep-gate.sh` |
| PLAN-004 | 治理 | Phase 3 第四批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave4-gate.sh` |

### 2.16 Phase 3 第五批（PLAN-005；§2.16）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-024 | 自举 | parser C2 139 函数全量 emit | P0 | ✅ | `run-boot-024-parser-bootstrap-emit-gate.sh` |
| COMP-018 | 编译器 | riscv64 QEMU 用户态烟测 | P1 | ✅ | `run-comp-riscv64-qemu-gate.sh` |
| STD-066 | 标准库 | `std.db` query_rows 原型 | P2 | ✅ | `run-std-db-query-rows-gate.sh` |
| PLAN-005 | 治理 | Phase 3 第五批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave5-gate.sh` |

### 2.17 Phase 3 第六批（PLAN-006；§2.17）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-025 | 自举 | parser C3 gen1/gen2 三代一致性 | P0 | ✅ | `run-boot-025-parser-gen12-consistency-gate.sh` |
| COMP-019 | 编译器 | WPO 默认全局开启烟测 | P1 | ✅ | `run-comp-wpo-global-gate.sh` |
| STD-067 | 标准库 | `std.db` next_row 列值迭代 | P2 | ✅ | `run-std-db-next-row-gate.sh` |
| PLAN-006 | 治理 | Phase 3 第六批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave6-gate.sh` |

### 2.18 Phase 3 第七批（PLAN-007；§2.18）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-026 | 自举 | parser C4 全量 X bootstrap | P0 | ✅ | `run-boot-026-parser-c4-bootstrap-gate.sh` |
| COMP-020 | 编译器 | incr-compile 二次编译烟测扩面 | P1 | ✅ | `run-comp-incr-compile-wave-gate.sh` |
| STD-068 | 标准库 | `std.db` row_col_text 文本列 | P2 | ✅ | `run-std-db-row-col-text-gate.sh` |
| PLAN-007 | 治理 | Phase 3 第七批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave7-gate.sh` |

### 2.19 Phase 3 第八批（PLAN-008；§2.19）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-027 | 自举 | parser C5 shux_asm2 跨平台发布 | P0 | ✅ | `run-boot-027-shux-asm2-cross-gate.sh` |
| COMP-021 | 编译器 | incr-compile 生产 tier 烟测 | P1 | ✅ | `run-comp-incr-compile-prod-gate.sh` |
| STD-069 | 标准库 | `std.db` row_col_blob BLOB 列 | P2 | ✅ | `run-std-db-row-col-blob-gate.sh` |
| PLAN-008 | 治理 | Phase 3 第八批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave8-gate.sh` |

### 2.20 Phase 3 第九批（PLAN-009；§2.20）

| ID | 领域 | 待办 | 优先级 | 状态 | Gate |
| --- | --- | --- | --- | --- | --- |
| BOOT-028 | 自举 | parser C6 shux_asm2 CI 矩阵 | P0 | ✅ | `run-boot-028-shux-asm2-ci-matrix-gate.sh` |
| COMP-022 | 编译器 | incr-compile bench tier 扩面 | P1 | ✅ | `run-comp-incr-compile-bench-gate.sh` |
| STD-070 | 标准库 | `std.db` 预编译语句缓存 | P2 | ✅ | `run-std-db-stmt-cache-gate.sh` |
| PLAN-009 | 治理 | Phase 3 第九批路线图定版 | P2 | ✅ | `run-phase3-roadmap-wave9-gate.sh` |

### 2.21 对外路线图季度预览（§2.20+ gate 锚点）

| 季度 | 说明 |
| --- | --- |
| 2028-Q1 | parser C3 / WPO 全局 / std.db next_row（见 `analysis/doc-public-roadmap-v1.md` §5） |
| 2028-Q2 | incr-compile 生产 tier 扩面 |
| 2028-Q3 | shux_asm2 跨平台发布深化 |
| 2028-Q4 | shux_asm2 CI 矩阵与 bench tier 收官 |

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
    C2["linux.x syscall asm"]
    C3["win32.x + IOCP"]
    C4["编译器读源不 fopen"]
  end

  subgraph p3["阶段 C：前端 .x 化"]
    D1["去 pipeline_gen.c"]
    D2["lsp_diag.x"]
    D3["默认只链 *_x.o"]
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

  subgraph p6["阶段 F：全仓库 std 无 C ✅"]
    G1["std/*.c → .x / FFI"]
    G2["构建链无 cc 编 std"]
    G3["F-ZC 0/0"]
  end

  subgraph p7["阶段 G：终局清场 ⬜ 当前主线"]
    H1["core + compiler 物理删 C/H"]
    H2["F-no-libc bootstrap 硬绿"]
    H3["Makefile → build.x"]
    H4["vX.Y.Z-selfhost 发布"]
  end

  done --> p1 --> p2 --> p3 --> p4 --> p5 --> p6 --> p7
```



---

## 4. 阶段 A — 构建链与门禁硬化（优先，约 2～4 周）

> **目标**：在不动大架构的前提下，把「能自举」变成「可 CI 证明、可重复、可跨平台」。

### 4.1 变绿判定（避免 🟡 长期不更新）

| 状态 | 含义 |
| --- | --- |
| ✅ | **该条验收标准已全部满足**（gate 硬失败模式亦通过，或平台 scope 内验收通过） |
| 🟡 | gate/脚本**已落地**，但金标准/平台/指标**尚未闭合** |
| ⬜ | 未开始或缺 gate |
| ⏭ | **documented defer** — 明确延后至自举闭环后；**不阻塞**后续 A/B/C 推进 |

**自举冲刺期：本地金标准（2026-06 决议）**

- **不等 GitHub 全平台 CI 绿**再推进；开发分支 push 不必阻塞在 Windows / Alpine / ARM CI。
- **本机验收 = macOS 宿主** + **Docker Linux x86_64**（`./tests/run-local-linux-docker.sh`），与 CI Linux job 等价。
- **macOS 本地**：`run-portable-suite.sh`、`make bootstrap-verify`、`run-pre-push-p0.sh`。
- **Docker Linux 本地**：`run-local-linux-docker.sh portable|ci-full`；A-09～A-12 硬门禁在容器内跑（见 §11）。
- **延后平台**（⏭，自举后再补）：Windows（A-08）、Alpine/其他 Linux 变体（A-13）。

**按 A 序号推进**：A-07 已绿 → **A-09～A-12 已闭合**（Docker Linux 2026-06-20）→ 默认进 **B/C**（A-08/A-13 仍 ⏭ 不阻塞）。

**本机 Darwin 限制**：A-11 / A-12 的 parse count 与 `nm arch_*` **在 macOS 宿主 gate 会 N/A**；须在 **Docker Linux x86_64** 变绿（不必等 GitHub）。


| #    | 任务                                                    | 状态  | 验收                                                                                                 | 变绿条件 |
| ---- | ----------------------------------------------------- | --- | -------------------------------------------------------------------------------------------------- | --- |
| A-01 | 语义自举烟测                                                | ✅   | `make -C compiler bootstrap-verify`                                                                | — |
| A-02 | macOS `bootstrap-driver-bstrict` → `asm_only_strict`  | ✅   | `SELFHOST.md` §4.1；`check_asm_o_quality.sh` → 24/24                                                | — |
| A-03 | Linux crt0 **B-partial**（无 `pipeline_gen.c`）          | ✅   | `make -C compiler bootstrap-driver-crt0`                                                           | — |
| A-04 | B-strict Stage2 **行为** parity                         | ✅   | `verify-selfhost-stage2-bstrict.sh`                                                                | — |
| A-05 | BOOT 门禁族（repro / stage-diag / bstrict-ci）             | ✅   | `run-bootstrap-bstrict-ci.sh`                                                                      | — |
| A-06 | DOC-002 自举架构全景                                        | ✅   | `run-doc-selfhost-architecture-gate.sh`                                                            | — |
| A-07 | push 前 P0 包（bstrict + asm-73 + perf）                  | ✅   | `run-pre-push-p0.sh`                                                                               | — |
| A-08 | **Windows** B-hybrid 可构建 `shux_asm`                   | ⏭  | `run-bootstrap-bstrict-windows-gate.sh`；MSYS experimental 链                                          | **自举闭环后**再补；本地 macOS+Docker 不阻塞 |
| A-09 | **Stage2 SHA256 金标准**门禁                               | ✅  | `run-stage2-hash-gate.sh` + `SHUX_STAGE2_HASH_STRICT=1` 硬失败通过                                  | stage1/stage2 **SHA256 一致**（Docker Linux 2026-06-20） |
| A-10 | **L5 run-all**：bootstrap `shux` 真 parity（缩小 seed 白名单） | ✅  | `run-l5-run-all-parity-gate.sh`；bstrict **123** 项 ⊆ whitelist                                      | **Docker Linux x86_64**：123 项全绿 |
| A-11 | parser/typeck **第二遍 EMIT_HEAVY** 稳定（大 module 不截断）     | ✅  | `run-typeck-parse-count-gate.sh`（**num_defined** target 146）+ bisect                               | **Docker Linux x86_64**：num_defined=336 ≥146 |
| A-12 | 跨模块符号统一（`arch_arm64_*` 等）                             | ✅  | `run-a12-cross-module-symbols-gate.sh` + baseline TSV                                                | **Docker Linux x86_64**：`SHUX_A12_CROSS_MODULE_FAIL=1` 无新 U |
| A-13 | Alpine / 其他 Linux 变体 B-strict 或 documented skip       | ⏭  | `run-bootstrap-crossplatform-gate.sh`                                                              | **自举闭环后**再补 Alpine/cross |
| A-14 | Stage2 哈希门禁**脚本化**                                     | ✅   | `run-stage2-hash-gate.sh` 已落地并挂 `verify-selfhost-stage2-bstrict`                                     | 脚本 + 接入（**与 A-09 正交**） |


---

## 5. 阶段 B — 语言特性 + std/sys 斩断 C 脐带（约 3～5 周）

> **目标**：新编译器读 `.x` 源码、写文件、调 OS，**不经过** C 的 `fopen` / `_stubs.c`。对应自举分析 **关卡三 + 缺失拼图 1/2/4**。

### 5.1 语言 / 编译器前端特性（自举必需）

> **v1 完成标准**：见 [`analysis/phase-b-completion-v1.md`](analysis/phase-b-completion-v1.md)。`asm { }` 语法与 B-32 硬禁 cc 编 std **延后**至 C/F，不阻塞 B v1 ✅。


| #    | 任务                                           | 状态  | 说明 / 验收                                                                 |
| ---- | -------------------------------------------- | --- | ----------------------------------------------------------------------- |
| B-01 | `**#[cfg(target_os = "linux")]`** 模块/函数级条件编译 | ✅  | `run-cfg-attribute-skip-gate.sh` |
| B-02 | `**#[cfg(target_arch = "aarch64")]**` 等      | ✅  | `run-cfg-target-triple-gate.sh` |
| B-03 | `**#[repr(C)]` / 显式 struct 对齐**              | ✅  | `run-repr-c-*-gate.sh` |
| B-04 | **内联汇编 `asm { }` 块**（或等价 intrinsic）          | ✅  | **v1**：extern→`freestanding_io_x86_64.s`；`run-b04-freestanding-syscall-gate.sh`；语法层 ⏭ C/E |
| B-05 | Codegen 自举 MVP 稳定性清单                         | ✅  | `run-b05-codegen-mvp-gate.sh` → asm-73 |
| B-06 | **显式 AST Arena / 对象池**（.x 写编译器时用）           | ✅  | `run-b06-ast-pool-gate.sh`；parser.x 依赖 ast_pool glue |


### 5.2 std/sys 分平台实现


| #    | 任务                                                                  | 状态  | 说明 / 验收                                         |
| ---- | ------------------------------------------------------------------- | --- | ----------------------------------------------- |
| B-10 | **std.sys v0** — freestanding `os_write`                            | ✅   | BOOT-029；`tests/sys/sys_write_freestanding.x`  |
| B-11 | **std.sys v1** — Linux syscall 号表                                   | ✅   | `std/sys/linux.x`；`linux_syscall_nr_smoke.x`  |
| B-12 | **std.sys v2** — macOS POSIX write                                  | ✅   | `std/sys/macos.x`；`macos_posix_write_smoke.x` |
| B-13 | **std.sys v3** — mmap（kv 等用）                                        | ✅   | `std/sys/mmap.x` 纯 `.x`（F-02 v1 已删 `mmap.inc.c`） |
| B-14 | **Linux .x 真实 syscall**：`read/write/openat/close/mmap` 内联 asm      | ✅  | `run-linux-*-gate.sh`（x86_64 freestanding）；aarch64 桩表在 linux.x |
| B-15 | **Linux io_uring** 最小子集（setup/enter/register）                       | ✅  | **v1 门面**：`std/sys/linux_io_uring.x` + `run-b15-io-uring-sys-gate.sh`；完整 ring 在 std/io |
| B-16 | **macOS** 扩展：`open/read/mmap` 经 libSystem FFI                       | ✅  | `run-macos-mmap-*` + `run-macos-read-file-gate.sh` |
| B-17 | **std/sys/win32.x** — `ReadFile/WriteFile/CreateFileW/ExitProcess` | ✅  | v1～v3 Write/Read/ExitProcess + `run-b17-exit-process-gate.sh` |
| B-18 | **std/sys/win32 网络** — `WSA*` + **IOCP** 最小 async                   | ✅  | **v1 门面**：`std/sys/win32_net.x` + `run-b18-win32-net-gate.sh`；IOCP 在 std.io |
| B-19 | **std/sys/mod.x** 统一门面 + `#[cfg]` 分流                               | ✅  | os_write/read/close/exit/mmap + `run-b19-sys-mod-facade-gate.sh` |
| B-20 | 编译器自身 **读源文件** 改调 `std.sys`（非 C `fopen`）                            | ✅  | v1 generated_c scan；asm `-o` fopen **track**（阶段 C-08） |


### 5.3 去 stubs / runtime C 依赖


| #    | 任务                                             | 状态  | 说明                                   |
| ---- | ---------------------------------------------- | --- | ------------------------------------ |
| B-30 | 盘点 `_stubs.c` / `runtime.c` 中 OS 调用            | ✅  | `run-b30-stubs-runtime-os-inventory-gate.sh` + manifest |
| B-31 | freestanding_io 保留为 **极薄 .s** 或迁入 linux.x asm | ✅  | `run-b31-freestanding-io-gate.sh` |
| B-32 | **按需链 std.o** 与自举 **不依赖 cc 编译 std**            | ✅  | **v1 track-only**：`run-b32-no-cc-std-gate.sh`；硬禁 ⏭ F-06 |


---

## 6. 阶段 C — 编译器前端 .x 化（约 4～6 周）

> **目标**：构建编译器时 **默认只链 `.x` 产出的 .o`**，对应自举分析 **关卡一** 与` 完全去掉C与H` 条目 2、3。  
> **整体状态（2026-06）**：**C-03～C-09 v1 已闭合**（Windows C-03 / C-04 perl 全模块 / lsp_diag.c 删尽有 v2 延后项）。


| #    | 任务                                                                       | 状态  | 说明 / 验收                      |
| ---- | ------------------------------------------------------------------------ | --- | ---------------------------- |
| C-01 | 前端模块 **.x 源码齐全**（lexer/parser/ast/typeck/codegen/pipeline/driver）       | ✅   | `compiler/src/**/*.x`       |
| C-02 | `build_asm/*.o` 全量 `-backend asm` 构建                                     | ✅   | `asm_build_list.x`          |
| C-03 | **去掉 `cc -c pipeline_gen.c`**（全平台 B-strict）                              | ✅  | **v1 Linux/macOS B-strict**；`run-c03-no-pipeline-gen-gate.sh`；Windows B-hybrid **track** ⏭ A-08 |
| C-04 | `**-E-extern` 生成 C 自带 extern**（去 `lsp_io_extern.h`）                      | ✅  | **v1**：parser/lsp_diag 零 perl + lsp/pipeline `-E-extern`；`run-c04-e-extern-gate.sh`；lexer/typeck/codegen perl **track** v2 |
| C-05 | **LSP**：`lsp_diag.x` 或 C 兼容 parse API                                   | ✅  | **v1 方案 B 子集**：`lsp_diag.x` + `run-c05-lsp-x-gate.sh`；`lsp_diag.c` glue ⏭ E-02 |
| C-06 | Makefile **默认** `parser_x.o` / `typeck_x.o` / `ast_x.o`，不链 `parser.o` | ✅  | `DRIVER_SEED_X_FRONTEND_OBJS` + `run-c06-x-frontend-default-gate.sh`；`SHUX_LEGACY_C_FRONTEND=1` 回退 |
| C-07 | **像素级**验证：`.x` 编译器 ≡ C 编译器（同一输入 AST/产物）                                 | ✅  | **v1 行为 parity**：`run-c07-frontend-parity-gate.sh` + matrix；AST/-E 字节 diff ⏭ v2 |
| C-08 | `main.c` 收成一行入口；`runtime.c` 业务迁 `driver.x` / `build.x`                 | ✅  | **v1**：薄 main.c + driver 七模块 + build.x；`run-c08-runtime-driver-gate.sh`；runtime 大块仍 C ⏭ E |
| C-09 | mega7 / force_stub 清理（parser 无 C 回退）                                     | ✅  | **v1**：默认 `parser_x.o` + strict 覆盖 + force_stub/mega7 manifest；`run-c09-parser-no-c-fallback-gate.sh`；mega7 真 emit ⏭ v2 |


---

## 7. 阶段 D — 三阶段自举闭环（约 2～3 周）✅ v1

> **目标**：达成 `自举分析.md` **Stage 0→1→2** 与 **SHA256 一致**（D-01～D-06 v1 已闭合；v2：零 C seed、全量 portable diff）。


| #    | 任务                                                      | 状态  | 说明 / 验收                                      |
| ---- | ------------------------------------------------------- | --- | -------------------------------------------- |
| D-01 | **Stage 0**：C/seed 编译出 **Stage 1** 纯 shux 编译器           | ✅  | **v1**：`bootstrap-driver-bstrict` → `shux_asm`；`run-d01-stage0-to-stage1-gate.sh`；仍含少量 C seed ⏭ v2 |
| D-02 | **Stage 1** 编译同一 tree → **Stage 2**                     | ✅  | **v1**：`verify-selfhost-stage2-bstrict.sh`；`run-d02-stage1-to-stage2-gate.sh`（委托 stage2-bstrict） |
| D-03 | **Stage 1 与 Stage 2 二进制哈希一致**                           | ✅  | **v1 金标准**：`run-d03-stage2-hash-gate.sh` 委托 A-09；verify Step 4c 默认 `SHUX_STAGE2_HASH_STRICT=1` |
| D-04 | Stage2 扩展：`make test_x` / `run-portable-suite` 两代 diff | ✅  | **v1 子集**：10 用例 stage1/stage2 outcome 一致；`run-d04-stage2-portable-diff-gate.sh`；全量 portable ⏭ v2 |
| D-05 | 发布 `**shux` 单二进制** 不依赖 `shux-c` 冷启动                     | ✅  | **v1**：`bootstrap-driver-bstrict` → `shux=shux_asm`；`run-d05-single-shux-release-gate.sh`；冷启动仍须 seed |
| D-06 | 文档：README 声明 **Stage2 黄金自举** + 复现命令                     | ✅  | **v1**：`SELFHOST.md` §1.1 + §2；`run-d06-selfhost-doc-gate.sh`；**不含**完全自举（D+E+F） |


---

## 8. 阶段 E — 软删除 C/H（编译器 + LSP）✅ **E-soft v2 闭合**

> **依据**：`[compiler/docs/完全去掉C与H-前置清单.md](compiler/docs/完全去掉C与H-前置清单.md)` 程度 1～4。**不含 std** — std 在 §9 阶段 F 单独清场。  
> **策略（E-soft）**：C/H **文件保留**；默认 B-strict / bootstrap **不链、不调用**已登记模块；考古用 `SHUX_LEGACY_C_FRONTEND=1` / `shux-c`。  
> **闭合文档**：`analysis/phase-e-soft-v2-closure.md`（2026-06-20 gate 全绿）。


| #    | 任务                                                                              | 状态  | 说明 / 验收     |
| ---- | ------------------------------------------------------------------------------- | --- | ----------- |
| E-soft | manifest + 聚合 gate + 软退役闭合                                              | ✅ v2 | `phase-e-soft-v2-closure.md` + `run-e-soft-retire-gate.sh` |
| E-01 | 软退役 `lsp_io_extern.h` / `lsp_gen_extern.h`（已内嵌 `lsp_codegen_extern.c`）       | ✅  | `run-e01-extern-h-soft-gate.sh` |
| E-02 | 软退役 `lsp_diag.c`（保留文件；默认 stubs）                                                         | ✅ v1 | `run-e02-lsp-diag-soft-gate.sh` |
| E-03 | 软退役 `parser.c` / `typeck.c` / `codegen.c` / `preprocess.c` / `lexer.c` / `ast.c`（保留文件） | ✅ v3 | C-06/C-09 + E-03 v2/v3 gates；OBJS_CORE track 非阻塞 |
| E-04 | `runtime.c` / `main.c` 收到 ABI 薄壳（保留文件；默认 no_c） | ✅ v35 | `run-e04-runtime-soft-gate.sh`；v36+ 拆分为可选维护 |
| E-05 | `include/*.h` 仅保留 FFI/ABI 必需（保留文件） | ✅ v2 | `run-e05-include-soft-gate.sh` |
| E-06 | CI：bootstrap **不出现 `cc -c` 编译器前端 `.c`**（链接 ld 除外） | ✅ v5 | `run-e06-no-compiler-frontend-cc-gate.sh` |


---

## 9. 阶段 F — 全仓库 std 无 C（必达终局）✅ v1 已闭合

> **目标**：`core/` + `std/` 下**零手写 `.c/.h` 业务实现**；OS 边界仅允许 `.x` 内 `asm { }` 或 `extern` FFI（+ 极薄 `.s` 入口如 crt0，若仍需要）。  
> **与阶段 E 关系**：编译器本体先去 C（E），再系统性清 std（F）；**未完成 F 不得宣称「完全自举」**。  
> **依据**：`完全去掉C与H-前置清单.md` **程度 5**；`自举分析.md` Stage 3「彻底消灭 C」。

### 9.1 清场原则


| 原则           | 说明                                                                |
| ------------ | ----------------------------------------------------------------- |
| **mod 面不变**  | 用户仍 `import("std.*")`；实现从 `.c` 迁 `.x` 或 `extern` 系统 DLL/dylib    |
| **按需链接保留**   | 无 C 不等于全量静态链入；runtime 扫描符号 → 链对应 `.o`（由 `.x` 编译产出）               |
| **分模块推进**    | 先 **std.sys / std.io / std.fs / std.mem**，再 net/crypto/compress 等 |
| **每模块 gate** | 删除某 `.c` 前：对应 smoke/gate 绿 + 文档同步                                 |


### 9.2 任务清单


| #    | 任务                                                                       | 状态  | 说明 / 验收                                                                          |
| ---- | ------------------------------------------------------------------------ | --- | -------------------------------------------------------------------------------- |
| F-01 | **inventory**：列出全仓库 `std/**/*.c`、`core/**/*.c` 及链入点                      | ✅  | baseline **4**（std **0** + core 4；F-ZC ✅） |
| F-02 | **std.sys** 去 C：`mmap.inc.c` 等 → `.x` asm/FFI                           | ✅ | std/sys 零 `.c` |
| F-03 | **std.io / std.fs / std.mem / std.heap** 核心路径 .x 化                      | ✅ | **v1+v2+v3 ✅** 删 `heap.c`/`fs.c`/`io.c`；见 `phase-f-f03-closure.md` |
| F-04 | **std.net / std.compress / std.crypto** 等 `.inc.c` → `.x` 或分平台 FFI      | ✅   | **std.net v15 ✅**；**std.crypto v21 ✅** 闭合；**F-05 v4 ✅**；见 `phase-f-f04-v21-closure.md` |
| F-05 | **std.db**（sqlite/kv/arrow）`.c` → `.x` 或 OS 纯 FFI                       | ✅ v4 | **v1～v3 ✅** + **v4 ✅ 闭合**（3 胶层 C）；见 `phase-f-f05-v4-closure.md` |
| F-06 | **runtime.c** 中 std 按需链路径改为链 **`.x` 产物 .o**                             | ✅ v2 | v1+v2：`run-f06-runtime-std-o-cleanup-gate.sh`；stage2 无 legacy fs/io/heap `.o` |
| F-07 | **Makefile / build.x**：构建 std 仅 `-backend asm` 或自举 shux，**禁止 cc 编 std** | ✅ v2 | v1+v2：`run-f07-no-cc-std-migrated-gate.sh`；migrated 硬禁 |
| F-08 | **core/** 确认无 `.c`（或仅保留 0 文件）                                            | ✅ v1 | 存量 **4** 文件 manifest + 专 gate；`run-f08-core-inventory-gate.sh` |
| F-09 | 全仓库 `**grep -r '\.c$'` 门禁**（compiler + std 白名单为空）                        | ✅ v1 | `run-no-handwritten-c-gate.sh`；**193** 存量跟踪；见 `phase-f-f09-v1.md` |
| F-10 | `**make test_x` + portable suite** 在「无 std C」构建下全绿                      | ✅ v1 | v1：`run-f10-test-x-portable-gate.sh`（test_x + D-04 子集；无 shux SKIP） |
| F-11 | Tag `**vX.Y.Z-selfhost`**：发布物 = 单二进制 + 全 `.x` 源码树                       | ✅ v1 | v1 checklist：`run-f11-selfhost-release-prep-gate.sh`（tag 发布时人工打） |
| F-12 | 文档口径统一：`README.md` + `SELFHOST.md` 将「完全自举」改为 **D+E+F**                   | ✅ v1 | `run-f12-selfhost-doc-unified-gate.sh` |
| **F-ZC** | **std 零 C/H 终局**（`std/` 下 0 个 `.c`/`.h`）                              | ✅ v1 | **`.c` 0 + `.h` 0**；ABI 头 → `compiler/include/shux_std_abi/` + runtime 内联；[`phase-f-std-zero-c-v1.md`](analysis/phase-f-std-zero-c-v1.md) |


### 9.3 推荐模块顺序（阶段 F 内部）

1. `std/sys`（含 mmap）→ 2. `std/io` + `std/fs` → 3. `std/mem` + `std/heap` → 4. `std/process` + `std/path` → 5. `std/net` 族 → 6. 其余 std → 7. `std/db` → 8. runtime 链入表收尾。

### 9.4 阶段 F-std-zero-c（std 标准库零 C/H — 下一主线）

> **终局**：`find std -name '*.c' -o -name '*.h'` → **0**。当前 **`.c` 0 + `.h` 0**（Z9 已完成）。  
> **文档**：[`analysis/phase-f-std-zero-c-v1.md`](analysis/phase-f-std-zero-c-v1.md)  
> **批次**：Z8 ✅ → Z2 ✅ → Z3 ✅ → Z1 http ✅ → Z6 db ✅ → Z7 crypto ✅ → **Z9 abi.h ✅**

```bash
SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh
SHUX_F_STD_ZERO_C_STRICT=1 ./tests/run-f-std-zero-c-track-gate.sh   # 终局硬绿（F-ZC ✅ 已 0/0）
SHUX_F_STD_ZERO_C_UPDATE=1 ./tests/run-f-std-zero-c-track-gate.sh   # 迁移后刷新 manifest
```

### 9.5 阶段 F-no-libc（像 Zig freestanding，零 libc）🟡 准备中

> **目标**：Linux x86_64 金标准 **`ld -nostdlib -static`、无 `libc.so`、链接无 `-lc`**；OS 仅经 `std.sys` syscall + 极薄 `.s`。  
> **文档**：[`analysis/phase-f-no-libc-v1.md`](analysis/phase-f-no-libc-v1.md)  
> **与 F 关系**：F 清 C 源码；F-no-libc 清 **libc 运行时依赖**——二者叠加才是 Linux 上的「真 no-lib」。

| # | 任务 | 状态 | 说明 |
|---|------|------|------|
| NL-01 | manifest + 聚合 gate | ✅  | `phase-f-n01-v1.md` + `run-nolibc-n01-preparation-gate.sh` + `run-no-libc-gate.sh` |
| NL-02 | 扩展 syscall 桩（socket v1） | ✅  | `freestanding_io_x86_64.s` socket/connect/bind/listen/accept + `run-no-libc-socket-gate.sh` |
| NL-03 | **堆**：mmap page 分配器（替代 `heap.c`/malloc） | ✅  | `std/heap/page_mmap.x` + `run-no-libc-heap-gate.sh` |
| NL-04 | **fs/io** 改调 `std.sys` only | ✅  | `std/fs/freestanding_linux.x` + `run-no-libc-fs-gate.sh` |
| NL-05 | 链接审计：用户 `-freestanding` 无 `-lc` | ✅  | `run-no-libc-link-gate.sh` + runtime NL-05 标记块；编译器 bootstrap `-lc` track → F-07 |
| NL-06 | freestanding std 首批发 + F-01 track | 🟡 v1 | `phase-f-n06-v1.md` + `run-nolibc-n06-std-track-gate.sh`；97 `.c` 全量迁移 v2+ |
| NL-07 | 编译器 bootstrap 去 `-lc` 准备 | 🟡 v4 | v3 ✅ 烟测；**v4 track** 全链试跑 + POSIX 桩 |

**验收**：

```bash
SHUX_NOLIBC_N01_FAIL=1 ./tests/run-nolibc-n01-preparation-gate.sh   # NL-01 专 gate
SHUX_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh     # NL-06 freestanding std track
SHUX_NOLIBC_N07_FAIL=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh # NL-07 bootstrap prep
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh                      # 全链聚合
```

Linux x86_64 硬绿；其它宿主 NL-01 + NL-06 + NL-07 manifest OK。

---

## 10. 阶段 G — 终局清场（当前主线，约 4～8 周）

> **前提**：阶段 **D + E + F v1 已闭合**（§0.1）。G 不是重复 D/E/F，而是把「软退役 + std 零 C」推进到**仓库内零手写 C/H、Linux bootstrap 零 libc、构建仅 build.x**。  
> **依据**：[`自举分析.md`](自举分析.md) §终局、[`analysis/完全自举-无C无Makefile.md`](analysis/完全自举-无C无Makefile.md)。

### 10.1 清场原则

| 原则 | 说明 |
|------|------|
| **先硬绿再删文件** | 每批物理删除 `.c/.h` 前：对应 gate 绿 + Stage2 哈希仍一致 |
| **E-soft → E-hard** | 默认路径已 no_c；删文件后移除 `SHUX_LEGACY_C_FRONTEND` 考古链 |
| **F-09 STRICT 为终局哨兵** | `SHUX_NO_HANDWRITTEN_C_STRICT=1` 硬绿 = G 完成 |
| **F-no-libc 与 G 并行** | NL-07 bootstrap `-nostdlib` 硬绿是 G-03 阻塞项 |
| **并行轨不阻塞 bootstrap-min** | G-FFI（LANG-007 v2）与 G-02/G-03 同排期，**不进** bootstrap-min / bootstrap-gold 阻塞项 |
| **平台补全不阻塞 G** | A-08 Windows / A-13 Alpine ⏭ 自 G 主链闭合后再补 |

### 10.2 任务清单

| # | 任务 | 状态 | 说明 / 验收 |
|---|------|------|-------------|
| G-01 | **core/** 5→0 `.c` | ⬜ | builtin/mem/slice/debug/assert → 编译器内建或 `.x`；`run-std-c-inventory-gate.sh` total→0 |
| G-02 | **compiler/** 物理删 C/H（E-hard） | ⬜ | parser/typeck/codegen/runtime 等 ~208 文件；删前 `run-e-soft-retire-gate.sh` + Stage2 仍绿 |
| G-03 | **F-no-libc bootstrap 硬绿** | 🟡 | NL-07 v4 track → v5：`SHUX_BOOTSTRAP_NOSTDLIB=1` 全链 + `ldd` 无 libc |
| G-04 | **F-09 STRICT 白名单为空** | ⬜ | `SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh` |
| G-05 | **Makefile 退役** | ⬜ | 根目录 + `compiler/Makefile` → 仅 `build.x` / `build_tool`；见完全自举-无C无Makefile |
| G-06 | **D/E/F v2 零 seed** | 🟡 | W1/W2 绿；真 partial ~175KB；LSP seed 仍缺；W3 bootstrap→gen2 ~3min |
| G-07 | **正式发布** | ⬜ | `git tag -a vX.Y.Z-selfhost`；`run-f11-selfhost-release-prep-gate.sh` 全绿 |
| G-08 | **跨平台 B-strict** | ⏭ | A-08 Windows + A-13 Alpine；G 主链闭合后 |

### 10.3 推荐推进顺序（G 内部）

```text
G-03（NL-07 硬绿）∥ G-01（core 5→0）
    → G-02 分批删 compiler C（按 module：lexer→ast→parser→typeck→codegen→runtime→lsp）
    → G-04 F-09 STRICT
    → G-05 Makefile 退役
    → G-06 零 seed + G-07 发布

并行轨（∥ 上述主线，不阻塞 bootstrap-min）：
    G-FFI-2 L3 维护（持续）
    G-FFI-3 unsafe { } 语法 ✅
    G-FFI-4 typeck 隔离规则 ✅
    → G-FFI-5 G-07 前硬拒 + release CI
    G-FFI-6 v3 / 插件 IPC ⏭ post-release
```

### 10.5 并行轨 — FFI 隔离（G-FFI）

> **要不要等完全自举后再做？** **不要等。** D+E+F v1 已闭合；v1 底座已在 CI；v2 与阶段 G **并行**。  
> **定稿分析**：[`analysis/FFI隔离.md`](analysis/FFI隔离.md) §7；进度勾选见 [`自举进度.md`](analysis/自举进度.md) §10.10。

| # | 任务 | 状态 | 说明 / 验收 |
|---|------|------|-------------|
| G-FFI-1 | **L1/L3 v1**（TYPE-004、SAFE-004、U1–U3、`std/ffi` F-ZC） | ✅ | `run-safe-ffi-contract-gate.sh`、`run-type-ffi-bridge-gate.sh` |
| G-FFI-2 | **L3 维护** | 🟡 | 新 `extern` → 审计 TSV；`std/sys`/`dynlib` 不暴露裸 `*T` |
| G-FFI-3 | **LANG-007 v2 语法** | ✅ | `unsafe { }`；Docker **`run-lang-unsafe-gate.sh` 全绿**（#88） |
| G-FFI-4 | **typeck 隔离** | ✅ | S0 内 `extern`/`*T` 解引用 → error；gate 已验（#88） |
| G-FFI-5 | **G 尾声闭合** | 🟡 | **std/ffi + std/sys unsafe 包裹 ✅**（#89）；bstrict 业务零裸 `extern` + release CI 仍 ⬜ |
| G-FFI-6 | **v3 / 生态** | ⏭ | `ForeignBuf`、provenance、类型化 `dynlib.sym`、插件 IPC、Wasm/Capability — **v1.0.0 后** |

```bash
# v1（现阶段 ✅）
./tests/run-safe-ffi-contract-gate.sh
./tests/run-type-ffi-bridge-gate.sh
./tests/run-safe-unsafe-audit-gate.sh

# v2（阶段 G 并行 — gate ✅ #88）
./tests/run-lang-unsafe-gate.sh   # relink 后；run 路径 -backend c -o

# G-FFI-5 std 层 unsafe 包裹（#89）
./tests/run-g-ffi-5-std-wrap-gate.sh
```

### 10.4 验收命令（阶段 G）

```bash
# G 进度哨兵
./tests/run-std-c-inventory-gate.sh                    # core 5→0
SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh   # 终局（当前必红）

# F-no-libc bootstrap（G-03）
SHUX_NOLIBC_N07_V4_FAIL=1 ./tests/run-nolibc-n07-v4-build-gate.sh
SHUX_NOLIBC_N07_V3_FAIL=1 ./tests/run-nolibc-n07-v3-link-gate.sh
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh

# 删 C 前回归（每批必跑）
make -C compiler bootstrap-verify-stage2-bstrict
SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh

# 发布清单（G-07）
SHUX_F11_SELFHOST_RELEASE_PREP_FAIL=1 ./tests/run-f11-selfhost-release-prep-gate.sh
```

---

## 11. 建议执行顺序（下一步动作）

> **2026-06-21 主线**：D+E+F v1 ✅ 已闭合 → **阶段 G 终局清场** + **F-no-libc NL-07 硬绿**。  
> **本地金标准**：macOS 宿主 + Docker Linux x86_64；不等 GitHub 全平台 CI。

| 序 | 条 | 动作 | 变绿命令 / 备注 |
| --- | --- | --- | --- |
| **0** | **G-03** | NL-07 bootstrap `-nostdlib` 全链试跑 | `SHUX_NOLIBC_N07_V4_TRY_BUILD=1 SHUX_NOLIBC_N07_V4_FAIL=1 ./tests/run-nolibc-n07-v4-build-gate.sh` |
| **1** | **G-01** | core 5→0 `.c` | 迁移 assert/builtin/mem/slice/debug → `run-std-c-inventory-gate.sh` total=0 |
| **2** | **G-02** | compiler C 分批物理删除 | 每批：E-soft gate + Stage2 哈希；从 lexer/ast 小模块起 |
| **3** | **G-04** | F-09 STRICT 硬绿 | `SHUX_NO_HANDWRITTEN_C_STRICT=1 ./tests/run-no-handwritten-c-gate.sh` |
| **4** | **G-05** | Makefile → build.x 唯一入口 | 见 `analysis/完全自举-无C无Makefile.md` |
| **5** | **G-07** | `vX.Y.Z-selfhost` 发布 | `run-f11-selfhost-release-prep-gate.sh` |
| **∥** | **G-FFI-5** | std 层 `unsafe` 包裹 + release CI + 业务零裸 `extern`（**并行，非阻塞**） | §10.5；[`FFI隔离.md`](analysis/FFI隔离.md) |
| — | **G-08** | ⏭ Windows / Alpine | `run-bootstrap-bstrict-windows-gate.sh`；自 G 主链后 |
| — | **本地** | 日常回归 | `./tests/run-portable-suite.sh`；`./tests/run-local-linux-docker.sh portable` |

**已完成基线（勿回退）**：

| 阶段 | 状态 | 一键复验 |
|------|------|----------|
| A-09～A-12 | 🟡 | `./tests/run-linux-a09-a11-gate.sh`（2026-06-24：A-09/A-11/A-12 ✅；**al06 ✅**；**i64-ctfe `-o` ✅**；**ub ✅**；**A-10** 仍待） |
| W2 d01/e03/d03 | ✅ | `./tests/run-g-fast-track.sh --w2` 或 `--w2-d03-only` |
| B-01～B-32 | ✅ | `run-bootstrap-bstrict-ci.sh` 含 phase-B |
| C-03～C-09 | ✅ | `run-c06/c09-*-gate.sh` |
| D-01～D-06 | ✅ | `run-d03-stage2-hash-gate.sh` |
| E-soft v2 | ✅ | `SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh` |
| F-01～F-12 + F-ZC | ✅ | `SHUX_F_PHASE_F_92_FAIL=1 ./tests/run-f-phase-f-92-batch-gate.sh` |

**当前阻塞（2026-06-24）**：

- **W3 al06**：✅ `run-al06-gate.sh` 绿；`import("std.vec")` + `with_arena` 逃逸；**import 返回类型前缀**已在 `pipeline_typeck_get_dep_return_type_in_caller_arena_c` 落地。
- **W3 A-09 hash**：✅ 同次 bootstrap gen1→gen2 后 `sha256=7547d08232200bbb6412a00771f4fabd85f0c9ad095942ae8db5c007bf1237e8`（2816304 B）；`SHUX_W3_RESUME_FROM=ensure` 仅当 stage1/2 与当前 shux 同次构建时可用。
- **W3 A-10 path/net**：✅ `std/path/path.o`（6598 B）、`std/net/net.o`（29320 B）；struct 指针 compat（`la==lb`）+ `asm_experimental_symbol_bridge` 符号冲突已修。
- **G-06**：LSP `*_gen.c` seed 未入库；`asm_backend_partial` 未 pin 入 `seeds/`。
- **G-03**：NL-07 v5 bootstrap `-nostdlib` 全链仍待硬绿。
- **G-01**：core 工作区 0 `.c`，**git 单文件 commit** 未完成。
- **G-02**：compiler ~226 `.c` 仅软退役；物理删除须分批 + Stage2 回归。
- **G-04**：F-09 STRICT 当前必红（预期）；G-01/G-02 完成后转绿。

---

## 12. 验收命令速查

```bash
# 语义自举
make -C compiler bootstrap-verify

# 生产 shux_asm（B-strict）
make -C compiler bootstrap-driver-bstrict

# CI 等价全链
SHUX=./compiler/shux_asm ./tests/run-bootstrap-bstrict-ci.sh

# Stage2 行为 parity
make -C compiler bootstrap-verify-stage2-bstrict

# Stage 0→1 / 1→2 门禁（D-01 / D-02）
SHUX_D01_FAIL=1 ./tests/run-d01-stage0-to-stage1-gate.sh
SHUX_D02_FAIL=1 ./tests/run-d02-stage1-to-stage2-gate.sh

# Stage2 SHA256 金标准（D-03；verify Step 4c 默认 STRICT）
SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh

# Stage2 portable 两代 diff（D-04）
SHUX_D04_FAIL=1 ./tests/run-d04-stage2-portable-diff-gate.sh

# Docker Linux 黄金自举一键（A-09～A-12）
./tests/run-linux-a09-a11-gate.sh

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

# NL-01 F-no-libc 准备（manifest + 基础设施）
SHUX_NOLIBC_N01_FAIL=1 ./tests/run-nolibc-n01-preparation-gate.sh

# 全链聚合（NL-01～NL-06）
SHUX_NOLIBC_FAIL=1 ./tests/run-no-libc-gate.sh

# NL-06 freestanding std 首批发 track（任意平台 manifest）
SHUX_NOLIBC_N06_FAIL=1 ./tests/run-nolibc-n06-std-track-gate.sh

# NL-07 编译器 bootstrap 去 libc 准备（任意平台 manifest）
SHUX_NOLIBC_N07_FAIL=1 ./tests/run-nolibc-n07-bootstrap-prep-gate.sh

# NL-07 v2 bootstrap nostdlib 首试（桩编译；Linux 全链：SHUX_BOOTSTRAP_NOSTDLIB=1 build_shux_asm）
SHUX_NOLIBC_N07_V2_FAIL=1 ./tests/run-nolibc-n07-v2-prep-gate.sh
# NL-07 v3 bootstrap nostdlib 链入烟测（Linux x86_64 硬绿）
SHUX_NOLIBC_N07_V3_FAIL=1 ./tests/run-nolibc-n07-v3-link-gate.sh
# NL-07 v4 bootstrap nostdlib 全链试跑（track；Linux+shux_asm：SHUX_NOLIBC_N07_V4_TRY_BUILD=1）
SHUX_NOLIBC_N07_V4_FAIL=1 ./tests/run-nolibc-n07-v4-build-gate.sh
SHUX_NOLIBC_N07_V2_FAIL=1 ./tests/run-nolibc-n07-v2-prep-gate.sh

# 阶段 E-soft：编译器 C/H 软退役（任意平台 manifest）
SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh
SHUX_E01_FAIL=1 ./tests/run-e01-extern-h-soft-gate.sh

# E-02 lsp_diag.c 软退役（默认 stubs）
SHUX_E02_FAIL=1 ./tests/run-e02-lsp-diag-soft-gate.sh

# NL-03 mmap bump 堆（Linux x86_64）
SHUX_NOLIBC_HEAP_FAIL=1 ./tests/run-no-libc-heap-gate.sh

# NL-04 freestanding 读文件（Linux x86_64）
SHUX_NOLIBC_FS_FAIL=1 ./tests/run-no-libc-fs-gate.sh

# NL-05 freestanding 链接策略（runtime 无 -lc + smoke）
SHUX_NOLIBC_LINK_FAIL=1 ./tests/run-no-libc-link-gate.sh

# NL-02 freestanding socket syscall（Linux x86_64）
SHUX_NOLIBC_SOCKET_FAIL=1 ./tests/run-no-libc-socket-gate.sh

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
SHUX_C04_NO_PERL_FAIL=1 ./tests/run-c04-no-perl-fallback-gate.sh
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

# push 前（macOS 本地）
SHUX=./compiler/shux_asm ./tests/run-pre-push-p0.sh

# Docker Linux 本地金标准（替代等 GitHub CI）
./tests/run-local-linux-docker.sh portable    # 快
./tests/run-local-linux-docker.sh ci-full     # 全量

# 自举文档门禁
./tests/run-doc-selfhost-architecture-gate.sh

# 失败诊断
./tests/run-bootstrap-bstrict-ci.sh 2>&1 | tee /tmp/boot.log
./tests/run-bootstrap-stage-diag.sh /tmp/boot.log
```

> F-09 门禁：`tests/run-no-handwritten-c-gate.sh`（手写 C 清零审计；**G-04 终局：`SHUX_NO_HANDWRITTEN_C_STRICT=1`**）  
> **F §9.2 聚合**：`SHUX_F_PHASE_F_92_FAIL=1 ./tests/run-f-phase-f-92-batch-gate.sh`（F-06～F-12 + F-01 + F-ZC）  
> **F-ZC 零 C/H 跟踪**：`SHUX_F_STD_ZERO_C_FAIL=1 ./tests/run-f-std-zero-c-track-gate.sh`  
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
| std.db.sqlite / std.db blob + kv/arrow + docs/07 | ✅   | #82～#93；**功能**收口          |
| mod ✅ 计数（2026-06-18 审计）                       | ✅   | core 11/11；std 约 28 mod ✅ |
| **std/*.c 清零（阶段 F）**                          | ✅   | **0** std `.c`；F-ZC 闭合；见 §9.4 |


---

## 附录 B — 文档索引


| 文档                                                                                     | 用途                      |
| -------------------------------------------------------------------------------------- | ----------------------- |
| [`自举分析.md`](自举分析.md)                                                                   | 战略、五关卡、三阶段、进度摘要 |
| [`compiler/docs/SELFHOST.md`](compiler/docs/SELFHOST.md)                               | 目标 A/B/C、拓扑、CI job      |
| [`analysis/doc-selfhost-architecture-v1.md`](analysis/doc-selfhost-architecture-v1.md) | 新人 1 小时全景               |
| [`analysis/完全自举-无C无Makefile.md`](analysis/完全自举-无C无Makefile.md)                       | 阶段 G：无 Makefile 终局       |
| [`compiler/docs/完全去掉C与H-前置清单.md`](compiler/docs/完全去掉C与H-前置清单.md)                       | 去 C/H 分程度清单             |
| [`analysis/phase-e-soft-v2-closure.md`](analysis/phase-e-soft-v2-closure.md)           | E-soft 闭合记录             |
| [`analysis/phase-f-std-zero-c-v1.md`](analysis/phase-f-std-zero-c-v1.md)               | F-ZC std 零 C/H           |
| [`analysis/phase-f-no-libc-v1.md`](analysis/phase-f-no-libc-v1.md)                     | F-no-libc / G-03          |
| [`analysis/FFI隔离.md`](analysis/FFI隔离.md)                                           | G-FFI 并行轨；LANG-007 v2 排期 |
| [`analysis/lang-unsafe-v1-rfc.md`](analysis/lang-unsafe-v1-rfc.md)                   | LANG-007 S0/U1–U4         |
| [`compiler/src/asm/README.md`](compiler/src/asm/README.md)                             | asm 后端能力表               |
| [`docs/07-内置与标准库.md`](docs/07-内置与标准库.md)                                               | 用户-facing std API       |


---

*本文档随自举推进更新；**下一编辑**请同步 §0.1 仪表盘、§2 当前站位、§10.5 G-FFI 与 §11 第一条未完成任务。*