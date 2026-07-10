# G-02f P2 — `runtime` mega 拆分 RFC（f-260 / 原 f-302）

> **状态**：草案可执行（2026-07-11）  
> **对象**：`compiler/seeds/runtime.from_x.c`（≈7.3k LOC）→ 产品 `src/runtime_driver_no_c.o`  
> **约束**：不破坏 G05 51 objs 链接面；默认仍可整 seed `cc`；切片可并行真迁但不改 G05 最终 `.o` 个数（除非显式 RFC 修订）。

---

## 1. 目标与非目标

### 1.1 目标

1. 把 **runtime mega** 切成可独立真迁/审计的**子系统**，每步只动一个切片。  
2. 明确 **🔒 永久 seed** 边界（OS / spawn / pthread / stdio 巨石）。  
3. 给出 **首个可运行切片** 与验收门禁，使 f-305+ 有序推进。  
4. 保持产品路径：`seeds/runtime.from_x.c` + `RUNTIME_DRIVER_NO_C_CFLAGS` → `runtime_driver_no_c.o`。

### 1.2 非目标（本 RFC 与首切片）

- 不在本步把 G05 的 `runtime_driver_no_c.o` 拆成多个 link 单元（避免 51→N 连锁）。  
- 不默认 `SHUX_G05_PREFER_X_O`（见 L2 pilot f-259）。  
- 不啃 `parser_asm_thin_c`（22k，另 RFC）。  
- 不在本步追求 gen1==gen2 黄金哈希变化。

---

## 2. 现状（量化）

| 项 | 值 |
|----|-----|
| seed | `compiler/seeds/runtime.from_x.c` |
| 产品产物 | `compiler/src/runtime_driver_no_c.o` |
| 编译 flags | `RUNTIME_DRIVER_NO_C_CFLAGS`（`SHUX_USE_X_*` + `SHUX_NO_C_FRONTEND` + …） |
| ensure | `g05_ensure`：seed 新于 `.o` 则 `cc -c` |
| 约 LOC | **~7320** |
| 约导出 `T` | **~98**（`nm runtime_driver_no_c.o`） |
| thin wrap 历史 | f-165 批折叠后本 mega 仍巨；真逻辑多仍在 C |
| 已拆出兄弟 TU | `runtime_pipeline_abi` / `runtime_driver_abi` / `runtime_driver_diagnostic` / `runtime_link_abi` / `runtime_io_abi` / `strict_glue_stubs` |

**关键现实**：业务入口大量在 `main.x` / `driver_*.x`，本 mega 是 **C 侧驱动原语 + 编排胶层 + ABI 内联写入 + DCE/asm 桩**，不是完整「编译器前端」。

---

## 3. 子系统边界（建议册）

按**依赖方向**（底层 → 上层）与**语言限制**：

| 册 | 代号 | 内容摘要 | 约符号簇 | 真迁难度 | 🔒 |
|----|------|----------|----------|----------|-----|
| **R0** | `rt_util` | path basename、unlink out、TEMP vs `/tmp`、字符串 eq helper | `driver_unlink_*`、`shux_get_*`、path helpers | 易 | 少 |
| **R1** | `rt_argv` | argv 扫描、`-o`/`-L`/`-O`/`-backend`/`-target`/`-E` 标志 | `driver_compile_argv_*`、`driver_argv_*` | 中 | 无 OS |
| **R2** | `rt_content` | 源码内容嗅探（generic / compound-assign 语法） | `content_has_*` | 易 | 无 |
| **R3** | `rt_preamble` | 向生成 C 写 std.io/net/fs 内联 ABI 块 | `write_io_*`、`write_fs_*`、`codegen_emit_*` | 中 | 大字符串数据可留 seed |
| **R4** | `rt_dce` | DCE 上下文填充与 used 查询回调 | `dce_is_*`、`driver_smoke` 周边 | 中 | 无 |
| **R5** | `rt_emit_x` | `-x -E` / emit 路径状态、`driver_run_x_emit_*` 灌参 | `driver_run_x_*`、`driver_want_*` | 中高 | 与 pipeline 紧耦 |
| **R6** | `rt_compile` | `driver_compile_*` 主编排（库根、deps、阶段） | `driver_compile_*`、`driver_deps_*` | 高 | 部分 IO |
| **R7** | `rt_run_exec` | 编译后 exec / run / fmt 子命令胶 | `driver_run_*`、`driver_exec_*`、`driver_fmt_*` | 高 | **exec/spawn 🔒** |
| **R8** | `rt_stack` | large_stack / pthread token dump | `driver_stack_*`、smoke pthread | 高 | **pthread 🔒** |
| **R9** | `rt_asm_stub` | asm 最小 GAS 桩、codegen AST 桥 | `asm_codegen_*` | 中 | 平台敏感 |
| **R10** | `rt_entry` | `main_entry` / 全局入口残留 | `runtime_run_*`、`run_compiler_*` | 高 | 与 crt0 边界 |

已外置、**禁止再塞回 mega** 的兄弟：

- `runtime_pipeline_abi`（import/path/typeck 编排）  
- `runtime_driver_abi`（phase/stack want/argv_collect）  
- `runtime_driver_diagnostic`（文案）  
- `runtime_link_abi`（cc/spawn/链 std `.o`）  
- `runtime_io_abi`（读文件 view）  
- `runtime_driver_strict_glue_stubs`（metrics/weak 桩；L2 thin 已 opt-in）

---

## 4. 拆分策略（不破坏 G05）

### 4.1 逻辑源 vs 链接单元

| 阶段 | 做法 |
|------|------|
| **A. 逻辑切片（默认）** | 在 `src/runtime/` 下新增 `rt_*.x`；seed 内对应函数改 thin 或 `#ifndef SHUX_RT_*_FROM_X` + ld -r **仅在 PREFER 试验**；**默认仍单文件 seed → 单 `.o`** |
| **B. 物理多 `.o`（可选后期）** | 仅当 A 稳定后，RFC 修订 G05 清单，把 R0–R2 等纯册拆成独立 objs；需 c08 / STRICT 同步 |

**首阶段只做 A**，避免 G05 51 抖动。

### 4.2 Seed 宏约定

```text
SHUX_RT_UTIL_FROM_X      // R0
SHUX_RT_ARGV_FROM_X      // R1
SHUX_RT_CONTENT_FROM_X   // R2
...
```

- 默认：宏未定义 → 全逻辑在 `runtime.from_x.c`。  
- 试验：`PREFER` 或专用 env 编 `.x` → 临时 `.o`，与「rest seed」`cc -r` 成 `runtime_driver_no_c.o`（对齐 target_cpu / strict_glue hybrid）。  
- **产品默认关闭 hybrid**（与 f-259 prefer 结论一致）。

### 4.3 weak / 重复符号

- 与 `pipeline_filtered` / 其它 seed 同名符号：seed 侧继续 **weak** 或保证单一强定义。  
- 新 `.x` 导出若可能撞车：ensure 路径 `G05_X_O_WEAK=1`（f-258 模式）。

---

## 5. 建议真迁顺序（f-305+ 可直接领任务）

| 序 | 切片 | 理由 | 验收 |
|----|------|------|------|
| **1** | **R2 content_has_*** | 纯串扫描；无 IO；符号面小 | `nm` 有符号；hello check；prefer 可选 hybrid |
| **2** | **R0 util**（unlink / basename） | 冷路径；易测 | 失败产物删除行为不变 |
| **3** | **R1 argv parse helpers** | 已有 driver_abi 部分 pure；补 compile 侧 | 全 flags 烟测 |
| **4** | **R4 DCE** | 纯表查询 | WPO/DCE 相关 gate 不回退 |
| **5** | **R3 preamble 字符串** | 数据表可仍 seed；编排 pure | `-E` 生成 C 含 ABI 块 |
| **6** | **R5 emit_x 状态** | 修 Linux `-backend c -E` SIGSEGV 的候选根因区 | Ubuntu `shux -E sizes` 绿 |
| **7+** | R6–R10 | 含 🔒；每步单独 commit | 见 §7 |

**禁止**：一次 PR 跨 R6+R7+R8。

---

## 6. 首个可运行切片规格（R2）

### 6.1 范围

- 符号：`content_has_generic_syntax`、`content_has_compound_assign_syntax`（以 seed 实际导出名为准；`nm` 核对）。  
- 新逻辑源建议路径：`compiler/src/runtime/rt_content.x`（或并入既有 `src/runtime*.x` 若已有锚点）。  
- seed：对应函数体用 `#ifndef SHUX_RT_CONTENT_FROM_X` 包住；hybrid 时 rest 提供其余 ~7k。

### 6.2 非范围

- 不改 argv 主循环。  
- 不改 link_abi / pipeline_abi。

### 6.3 门禁（首切片落地时）

```bash
# macOS + Ubuntu
cd compiler
G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# 可选 hybrid 试验（落地 R2 后）：
# SHUX_G05_PREFER_X_O=1 或专用 SHUX_RT_CONTENT_FROM_X 路径
./shux check /path/to/tiny.x
./shux -backend c build -o /tmp/rv42 /tmp/rv42.x && /tmp/rv42   # 42
# Linux 再加：用户 asm build 最小 main（f-259 udp_batch 已修）
```

---

## 7. 门禁矩阵（任何 runtime 切片）

| Gate | 命令级 | 必须 |
|------|--------|------|
| G05 relink | `g05_prepare_and_relink` 51 objs | ✅ |
| rv42 | C 后端或 Linux asm 最小 main | ✅ |
| 默认 seed | 未设 prefer 时与切片前行为一致 | ✅ |
| STRICT / noinc / lang-unsafe | 按仓库日常卡 | 🟡 动 ABI 时 |
| 回滚 | 删 hybrid `.o` + 重 ensure seed | ✅ |

---

## 8. 风险与 🔒 登记

| 风险 | 缓解 |
|------|------|
| mega 内隐式 `static` 共享状态 | 切片时先列全局/static；禁止静默拆状态 |
| `NO_C` flags 下条件编译 | 切片 `.x`/rest 必须同 flags 编 rest |
| Linux emit SIGSEGV（`main_driver_run_x_emit_x`） | 优先 R5 诊断；L2 已用 plain `-E` 绕过 |
| exec/pthread | R7/R8 **🔒 seed**，只做薄门闩 |
| 大 preamble 字符串 | R3 数据可永留 seed |

---

## 9. 与 link_abi / parser_thin 的关系

| mega | 下一步 |
|------|--------|
| **runtime**（本文） | f-260 RFC ✅ → 下步可落地 **R2** |
| **link_abi**（~6.9k） | 另文 f-303：cc/spawn/std `.o` ensure 🔒 边界 |
| **parser_asm_thin**（~22k） | **f-278/f-304 RFC 已写** → [`G-02f-P2-parser-thin-mega-RFC.md`](G-02f-P2-parser-thin-mega-RFC.md)；禁止无计划硬啃 |

---

## 10. 决议摘要

1. **runtime 拆 11 册（R0–R10）**；首迁 **R2 content**。  
2. **默认单 seed → 单 `runtime_driver_no_c.o`**；hybrid 仅试验。  
3. **G05 物理多 obj 延后**。  
4. **R7/R8 OS/pthread 🔒**。  
5. 下代码步建议：**f-261 = R2 content 真迁 + seed 宏 + 双平台门禁**（非本 RFC 文档步）。

---

## 11. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-07-11 | f-260 初版：runtime mega 拆分 RFC |
| 2026-07-11 | **f-261 R2 落地**：`src/runtime/rt_content.x` + `seeds/rt_content.from_x.c`；mega `SHUX_RT_CONTENT_FROM_X`；`PREFER_X_O` hybrid `content.o+rest → runtime_driver_no_c.o`。live `-E` 全量 `.x` 仍可能挂/截断，默认 hybrid 用 seed slice；`SHUX_RT_CONTENT_TRY_X_E=1` 可选试 -E。 |
| 2026-07-11 | **f-291 R6-lite**：`rt_compile.*`（deps_std_core + emit_asm path pure）；`SHUX_RT_COMPILE_FROM_X`；hybrid 六切片+rest；主编排/IO 仍 mega |
| 2026-07-11 | **f-292 R6 扩**：`rt_compile` 增 copy_path / freestanding / legacy_f32 / sanitize / is_help；仍 `SHUX_RT_COMPILE_FROM_X` |
| 2026-07-11 | **f-293 R6 apply_***：`rt_compile` 增 apply_minus_o/L/O + backend/target/target_cpu next；仍 `SHUX_RT_COMPILE_FROM_X` |
| 2026-07-11 | **f-262 R0 落地**：`rt_util.x` + `seeds/rt_util.from_x.c`（`driver_unlink_failed_output` / `driver_argv0_basename_is`）；`SHUX_RT_UTIL_FROM_X`；hybrid **R2+R0+rest**。 |
| 2026-07-11 | **f-263 R1 落地**：`rt_argv.x` + `seeds/rt_argv.from_x.c`（全部 `drv_eq_*`、`drv_path_ends_x`、`drv_target_has_arm`）；`SHUX_RT_ARGV_FROM_X`；hybrid **R2+R0+R1+rest**。 |
| 2026-07-11 | **f-264**：RFC **R4 DCE 产品路径跳过**（整块 `#if !SHUX_USE_X_DRIVER`，不进 `runtime_driver_no_c.o`）。改落地 **R5-lite emit_flags**：`driver_argv_has_emit_c_flag`、`set_use_lto_c`、`set_print_target_cpu_c` → `rt_emit_flags.*`；`SHUX_RT_EMIT_FLAGS_FROM_X`；hybrid 四切片+rest。 |
| 2026-07-11 | **f-265 R3 preamble**：`write_io_net_abi_inline` + `write_fs_path_map_error_abi_inline` → `seeds/rt_preamble.from_x.c` + `rt_preamble.x` 锚点；`SHUX_RT_PREAMBLE_FROM_X`；hybrid **五切片+rest**。 |
