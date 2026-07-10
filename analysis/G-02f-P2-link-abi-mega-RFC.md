# G-02f P2 — `runtime_link_abi` mega 拆分 RFC（f-266 / 原 f-303）

> **状态**：草案可执行（2026-07-11）  
> **对象**：`compiler/seeds/runtime_link_abi.from_x.c`（≈6.9k LOC）→ 产品 `src/runtime_link_abi.o`  
> **对标**：[`G-02f-P2-runtime-mega-RFC.md`](G-02f-P2-runtime-mega-RFC.md)（runtime 已切 R0–R3/R5-lite）  
> **约束**：不破坏 G05 51 objs；默认仍单 seed `cc`；切片 hybrid 仅 `SHUX_G05_PREFER_X_O` 或后续专用开关。

---

## 1. 目标与非目标

### 1.1 目标

1. 把 **link_abi mega** 切成可独立真迁/审计的子系统，每步只动一册。  
2. 明确 **🔒 永久 seed** 边界：`spawn` / `system` / `cc`/`ld` 拼装 / `stat` 探活 / freestanding 平台链。  
3. 给出 **首个可运行切片** 与门禁，对齐 runtime 的 hybrid 模式。  
4. 保持产品：`g05_ensure` 热路径 `seeds/runtime_link_abi.from_x.c` → `src/runtime_link_abi.o`。

### 1.2 非目标

- 本步不把 G05 的 `runtime_link_abi.o` 拆成多个正式 objs（仍单 `.o`；hybrid 用 `ld -r` 合成）。  
- 不默认打开 prefer（见 L2 pilot f-259）。  
- 不并行大改 `runtime_driver_no_c` 切片集。  
- 不啃 `parser_asm_thin_c`（另 RFC f-304）。

---

## 2. 现状（量化）

| 项 | 值 |
|----|-----|
| seed | `compiler/seeds/runtime_link_abi.from_x.c` |
| 逻辑源锚 | `src/runtime_link_abi.x`（多 gate；产品仍 seed C 主体） |
| 产物 | `compiler/src/runtime_link_abi.o` |
| ensure | `g05_ensure`：seed 新于 `.o` 则 `cc -c`（**G05 热路径**） |
| 约 LOC | **~6920** |
| 约导出 `T` | **~188** |
| 头文件 | `runtime_link_abi.h` + `runtime_proc_abi.h` / `runtime_io_abi.h` / `diag.h` |
| 关键词密度 | `link` ~1k、`path` ~600、`ensure_` ~100、`invoke_cc` ~120、`std/` ~125、`spawn` ~21 |

**角色**：用户程序 / 自举产物 **链接编排**——解析 `.o` 路径、按需 `cc -c` 标准库与 glue、`invoke_cc` / `invoke_ld` / platform 尾库、freestanding 特例、诊断。

---

## 3. 子系统边界（建议册）

按依赖方向（纯 → 诊断 → 探活 🔒 → 拼装 🔒 → 平台 🔒）：

| 册 | 代号 | 内容摘要 | 代表符号 | 难度 | 🔒 |
|----|------|----------|----------|------|-----|
| **L0** | `labi_path_pure` | 路径纯串：分隔符、后缀、`.o`/`.obj` 判定 | `shux_path_has_sep`、`shux_path_last_sep`、`link_abi_ld_argv_entry_is_obj`、`shux_output_is_elf_o` | 易 | 无 |
| **L1** | `labi_diag` | 诊断码/kind 映射与纯文案 | `link_diag_code_for_kind`、部分 `link_diag_*` 纯分支 | 易 | 少 |
| **L2** | `labi_host` | host 探测常量 | `shux_host_is_linux`、`shux_host_is_apple_aarch64` | 易 | `#if` 字面量 🔒 可留 |
| **L3** | `labi_path_io` | `stat` 探活、realpath、compiler dir | `shux_path_is_nonempty_regular_file*`、`shux_runtime_o_realpath*` | 中 | **stat/IO 🔒** |
| **L4** | `labi_ensure` | `shux_ensure_runtime_*` 族（缺 `.o` 则 `cc -c`） | ~30 `shux_ensure_runtime_*` | 高 | **spawn/cc 🔒** |
| **L5** | `labi_invoke_cc` | `shux_invoke_cc` / `append_linux_link_harden` / argv 拼装 | `shux_invoke_cc*`、`invoke_cc_*` | 高 | **spawn/cc 🔒** |
| **L6** | `labi_invoke_ld` | `shux_invoke_ld*` / `shux_asm_ld_*` 尾库与 platform | `shux_asm_ld_append_*`、`shux_invoke_ld_*` | 高 | **ld/OS 🔒** |
| **L7** | `labi_freestanding` | nostdlib / crt0 / freestanding 用户链 | `shux_freestanding_*`、`bootstrap_nostdlib_*` | 高 | **平台 🔒** |
| **L8** | `labi_std_objs` | 按需链入 std/user/on-demand `.o` 列表 | `shux_asm_ld_append_std_objs`、`append_on_demand_user_objs` | 中高 | 路径+探活 |
| **L9** | `labi_gates` | 历史 thin gate / `_impl` 转发层 | `link_abi_*_impl` 薄壳 | 中 | 视壳内是否 OS |

**禁止再塞回 mega 的兄弟**（已独立 G05 objs）：`runtime_driver_no_c`、`runtime_pipeline_abi`、`runtime_io_abi`、`runtime_driver_abi`、`diag`、`strict_glue` 等。

---

## 4. 拆分策略（不破坏 G05）

### 4.1 逻辑源 vs 链接单元

| 阶段 | 做法 |
|------|------|
| **A. 逻辑切片（默认）** | `src/runtime/labi_*.x` + `seeds/labi_*.from_x.c`；mega `#ifndef SHUX_LABI_*_FROM_X`；prefer 时 `ld -r` 合成 **单** `runtime_link_abi.o` |
| **B. 物理多 `.o`（后期）** | 仅当 A 稳定后修订 `g05_relink_env`；需 c08 / STRICT 同步 |

**首阶段只做 A**。

### 4.2 宏约定

```text
SHUX_LABI_PATH_PURE_FROM_X   // L0
SHUX_LABI_DIAG_FROM_X        // L1
SHUX_LABI_HOST_FROM_X        // L2
SHUX_LABI_PATH_IO_FROM_X     // L3 🔒
...
```

- 默认：宏未定义 → 全逻辑在 `runtime_link_abi.from_x.c`。  
- 试验：`SHUX_G05_PREFER_X_O=1` 或后续 `SHUX_LABI_HYBRID=1` 时切片 `cc` + rest `ld -r`。  
- 产品默认关闭 hybrid。

### 4.3 weak / 重复符号

- 与其它 seed 同名：保持既有 weak / 单强定义策略。  
- 新切片导出若撞车：`G05_X_O_WEAK=1` 模式（strict_glue f-258）。

### 4.4 与 runtime hybrid 的关系

| mega | ensure 入口 | hybrid 开关 |
|------|-------------|-------------|
| runtime | 已五切片 | `SHUX_G05_PREFER_X_O` + `SHUX_RT_*_FROM_X` |
| **link_abi** | 今日整文件 seed | 本文落地后同 prefer 或独立 `SHUX_LABI_HYBRID` |

建议：**首切片落地时复用 `SHUX_G05_PREFER_X_O`**，避免环境变量爆炸；若 ensure 过重再拆开关。

---

## 5. 建议真迁顺序

| 序 | 切片 | 理由 | 验收 |
|----|------|------|------|
| **1** | **L0 path pure** | 无 IO；符号少；与 R1 `drv_path_*` 风格一致 | unit：`.o`/`.obj` 判定；prefer hybrid 可选 |
| **2** | **L1 diag pure** | `link_diag_code_for_kind` 等 | 诊断码字符串不变 |
| **3** | **L2 host lit** | `#if` 字面量；可与 bootstrap cfg 对齐 | 双平台 host 探测 |
| **4** | **L3 path IO** | 薄封装 `stat` | 🔒 登记；行为不变 |
| **5** | **L8 std objs 列表纯部分** | 字符串表/顺序可迁；IO 仍 seed | 链 std 列表一致 |
| **6+** | L4 ensure / L5 cc / L6 ld / L7 freestanding | 必须单独 commit | 全门禁 + 用户 build |

**禁止**：一次 PR 同时改 invoke_cc 与 invoke_ld。

---

## 6. 首个可运行切片规格（L0 path pure）

### 6.1 范围（建议）

| 符号 | 说明 |
|------|------|
| `link_abi_ld_argv_entry_is_obj` | 串是否以 `.o` / `.obj` 结尾 |
| `shux_path_has_sep` | `/`（及 Windows `\\`） |
| `shux_path_last_sep` | 若已是纯逻辑则纳入 |
| 其它纯后缀判定 | 经 `nm` 复核后加入 |

**新路径建议**：

- 逻辑源：`compiler/src/runtime/labi_path_pure.x`  
- 产品切片：`compiler/seeds/labi_path_pure.from_x.c`  
- mega：`#ifndef SHUX_LABI_PATH_PURE_FROM_X`

### 6.2 非范围

- `shux_path_is_nonempty_regular_file*`（`stat` → L3）  
- 任何 `ensure_*` / `invoke_*`  
- freestanding 全链

### 6.3 门禁（L0 落地时）

```bash
cd compiler
# 默认
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# prefer hybrid（落地后）
SHUX_G05_PREFER_X_O=1 G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# unit（切片 .c 直编）
cc -o /tmp/labi0_ut tests_or_inline_ut.c seeds/labi_path_pure.from_x.c && /tmp/labi0_ut
# 用户
./shux -backend c build -o /tmp/rv42 /tmp/rv42.x && /tmp/rv42   # 42
# Linux 再加 asm build 最小 main
```

---

## 7. 门禁矩阵（任何 link_abi 切片）

| Gate | 必须 |
|------|------|
| G05 relink 51 objs | ✅ |
| 默认 seed 行为不变 | ✅ |
| prefer hybrid（若实现） | ✅ 可选路径绿 |
| 用户 `build` / rv42 | ✅ |
| Ubuntu + macOS | ✅ |
| STRICT / lang-unsafe | 🟡 动 ABI 时 |

---

## 8. 风险与 🔒 登记

| 风险 | 缓解 |
|------|------|
| `ensure_*` 与 `invoke_cc` 共享全局/静态路径缓冲 | 切片前列 static；禁止静默拆状态 |
| 双平台 ld 参数顺序 | L6 变更必须 Ubuntu+macOS 真链 |
| freestanding / nolibc | L7 单独轨；不挡 L0–L2 |
| seed 与 `.x` 双写 | 与 runtime 一致：大逻辑 seed 切片优先，`.x` 锚点；live `-E` 可选 |

---

## 9. 与 runtime / parser 的关系

| mega | 状态 | 下一步 |
|------|------|--------|
| **runtime** | 五切片 hybrid 已落地（f-261～265） | R6 compile 深切可选 |
| **link_abi** | 本文 RFC | **f-267 = L0 path pure 真迁** |
| **parser_asm_thin** | 未开 | f-304 God-View RFC |

---

## 10. 决议摘要

1. **link_abi 拆 10 册（L0–L9）**；首迁 **L0 path pure**。  
2. **默认单 seed → 单 `runtime_link_abi.o`**；hybrid 仅试验。  
3. **L3+ 含 stat/spawn/cc/ld → 🔒**，只做薄门闩或后移。  
4. **不把 R4 DCE 式「整块 #if 消失」当产品进度**——以 `nm` 产品 `.o` 为准。  
5. 下代码步：**f-267 L0**（`labi_path_pure` + mega 宏 + prefer hybrid + 双平台）。

---

## 11. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-11 | f-266 初版：link_abi mega 拆分 RFC |
| 2026-07-11 | **f-267 L0 落地**：`labi_path_pure.x` + `seeds/labi_path_pure.from_x.c`（`shux_path_last_sep` / `has_sep` / `link_abi_ld_argv_entry_is_obj` / `shux_output_is_elf_o`）；`SHUX_LABI_PATH_PURE_FROM_X`；prefer hybrid `L0+rest → runtime_link_abi.o`。 |
| 2026-07-11 | **f-268 L1 落地**：`labi_diag_pure.*`（`link_diag_code_for_kind` + resolve/missing/freestanding/ld_debug 薄 report；不含 wait/errno 系）；`SHUX_LABI_DIAG_PURE_FROM_X`；hybrid **L0+L1+rest**。 |
| 2026-07-11 | **f-269 L2 落地**：`labi_host_lit.*`（`shux_host_is_linux` / `shux_host_is_apple_aarch64`，C `#if` 字面量）；`SHUX_LABI_HOST_LIT_FROM_X`；hybrid **L0+L1+L2+rest**。 |
| 2026-07-11 | **f-270 L3 落地**：`labi_path_io.*`（`shux_path_is_nonempty_regular_file*` / `asm_link_obj_skip_missing` / `shux_runtime_o_realpath_if_exists`，stat/realpath 🔒）；`SHUX_LABI_PATH_IO_FROM_X`；hybrid **L0+L1+L2+L3+rest**。 |
| 2026-07-11 | **f-271 L8 列表纯落地**：`labi_std_list.*`（默认 ASM ld plan 表 + `labi_std_plan_count/step_at` / `labi_std_default_std_rel_*`）；`append_std_objs` 改为 plan 解释器（IO/ensure 仍 mega）；`SHUX_LABI_STD_LIST_FROM_X`；hybrid **L0～L3+L8+rest**。 |
| 2026-07-11 | **f-272 L8b on_demand 列表纯落地**：`labi_ondemand_list.*`（simple 6 组符号→rel + kv/arrow/time/queue 表 + `labi_od_rel_*`）；`append_on_demand_user_objs` 表驱动（nm/ensure 仍 mega）；`SHUX_LABI_ONDEMAND_LIST_FROM_X`；hybrid **L0～L3+L8+L8b+rest**。 |
| 2026-07-11 | **f-273 L4 ensure 列表纯落地**：`labi_ensure_list.*`（26 目标 catalog：stem/out/seed/flags）；`link_abi_ensure_from_catalog` + 26 薄 wrap；panic/wrap/mbedtls 仍特殊；`SHUX_LABI_ENSURE_LIST_FROM_X`；hybrid **L0～L4+L8+L8b+rest**。 |
| 2026-07-11 | **f-274 L5 invoke_cc 列表纯落地**：`labi_invoke_cc_list.*`（linux harden 5 flags / skip-native 3 envs / 12 needs rel + `invoke_cc_skip_native_tuning`）；harden_impl 表驱动；invoke_cc needs rel 走 `labi_icc_rel_*`；`SHUX_LABI_INVOKE_CC_LIST_FROM_X`；hybrid **L0～L5+L8+L8b+rest**。 |
| 2026-07-11 | **f-275 L6 invoke_ld 列表纯落地**：`labi_invoke_ld_list.*`（brew -L×2 / compress -l*×4 / tail flags / driver+entry 名）；mach/unix tail + compress + apple clang/ld 前缀表驱动；`SHUX_LABI_INVOKE_LD_LIST_FROM_X`；hybrid **L0～L6+L8+L8b+rest**。 |
| 2026-07-11 | **f-276 L7 freestanding 列表纯落地**：`labi_freestanding_list.*`（`SHUX_FREESTANDING` env / 13 io syscall syms / `shux_panic_` / crt0+io ensure src）；needs_io/panic + ensure 表驱动；`SHUX_LABI_FREESTANDING_LIST_FROM_X`；hybrid **L0～L8+L8b+rest**（link_abi 册 L0–L8 纯列表阶段齐）。 |
| 2026-07-11 | **f-277 L9 gates 落地**：`labi_gates.*`（6 薄门闩：`bank_push` / `invoke_cc` / mach·unix tail / `harden` / `invoke_ld_for_exe`）；`_impl` 仍 mega rest；`SHUX_LABI_GATES_FROM_X`；hybrid **L0～L9+L8b+rest** — **link_abi L0–L9 十册 hybrid 齐**。 |
