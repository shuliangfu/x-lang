# Shulang 性能军令状与路线图

> **铁律**：性能优化高于一切。功能与自举为性能服务，不为「语言完整性」牺牲 hot path 的一字节拷贝。  
> **北极星**：B-strict 自举 → 全知图 WPO → Std 零拷贝 + 无栈协程 → **在并发/吞吐/零拷贝三维量化超越 Clang -O3 与 Zig ReleaseFast**。  
> 背景：`compiler/docs/SELFHOST.md`、`compiler/src/asm/README.md`、`std/io/mod.su`（Z2）、`tests/baseline/*.tsv`。

---

## 0. 现状快照（2026-06-05）

| 维度 | 已达成 | 下一跳 |
|------|--------|--------|
| **自举** | …；**WPO 生产 main/driver/pipeline/typeck** ✅ | 全链 `shu_asm` __text **-3% stretch 实锤（proxy 5.67%）** |
| **计算** | asm microbench ≤ C -O2；compile dogfood 门禁 ✅；**WPO-S0** emit DCE + **WPO-S1** call graph | WPO v0 dogfood -3%；**SIMD-S1–S4** ✅；≤ C -O3 |
| **I/O/网络** | Linux io_uring + `IORING_REGISTER_BUFFERS`；macOS ≈ C；**IO-A3/A4/A5** ✅；**IO-A6** IOCP smoke（Windows CI）△ | ZC-1 `-10%` 实锤；≥ Zig |
| **零拷贝** | **ZC-2–5** Mac `shu-c` + **P5 OK**；Linux Docker `shu_asm` **zc gates OK**；**ZC-1** Mac/Mac-Docker **SKIP**（VM 无 io_uring） | ZC-1 △→✅（**GHA ubuntu 原生**跑 `-10%` perf） |
| **并发** | `std.async` A1/A2 POC + B-ASYNC bench ✅ | M:N + `async fn` 语法 |
| **内存安全** | typeck + 显式 unsafe 边界；Arena/heap 模块 | 线性类型 + 区域域静态证明（零 RT 开销） |

---

## 1. 核心愿景与性能军令状 (Vision & Benchmarks)

### 1.1 愿景

Shulang 不是「更安全的 C」或「更简单的 Zig」。我们要在**系统级 hot path**上证明：无 GC、无 LLVM、无 fat runtime，照样能在**高并发 I/O、批量零拷贝、数值内核**三类场景同时压制 Clang -O3 与 Zig ReleaseFast。

### 1.2 量化军令状（2026 Q4 – 2027 Q2）

所有指标须 **bench 脚本 + `tests/baseline/*.tsv` + CI 可选 fail**（与现有 P2/P3/I4/N3 同模式）。

| 代号 | 场景 | 对标 | 目标 | 验收 bench |
|------|------|------|------|------------|
| **B-CMP** | 算术/循环/struct/call 微基准 | Clang **-O3** | 中位数 **≤ 0.95×** C 用时 | `run-perf-baseline.sh` |
| **B-ZIG** | 同上 | Zig **ReleaseFast** | 中位数 **≤ 1.00×** Zig | `SHU_PERF_FAIL_ON_ZIG=1` |
| **B-IO** | 16MiB mmap 扫描 + batch readv + write | Zig std + io_uring | 吞吐 **≥ 1.05×** Zig | `run-perf-io.sh` |
| **B-NET** | 4096 conn accept + 4×4KiB echo + UDP recvmmsg | C + Zig libxev | **≥ 1.03×** C 中位数 | `run-perf-net.sh` |
| **B-ZC** | sendfile→socket 16MiB | C sendfile | **0 次 userspace copy**；用时 **≤ 1.00×** C | `zero_copy_sendfile` |
| **B-BOOT** | `hello` stripped exe 冷启动 | Zig 同规模 | **≤ 500µs**（stretch）；cap **8000µs**（含 std.io） | `run-perf-coldstart.sh` ✅ |
| **B-BOOT-FS** | freestanding return42 + hello（nostdlib static） | — | return42 **≤64KiB**；hello cap **2000µs** + **128KiB** | `run-perf-coldstart.sh` ✅（Linux shu_asm） |
| **B-SIZE** | `shu_asm` stripped | Zig 编译器同类工具 | **≤ 8MiB**（当前 ~12MiB 级） | `size(1)` 门禁 |
| **B-ASYNC** | 1M 协程 ping-pong（无 IO） | — | 切换 **≤ 15ns/op**（x86_64） | `run-perf-async.sh` ✅ ~1.5ns |
| **B-DOG** | 自编译 compiler 中位数 | 基线 tsv | **不回归** | `run-perf-compile-dogfood.sh` |

**分层门禁（L0–L4，只升不降）**：

```
┌──────────────────────────────────────────────────────────────┐
│ L4  生态默认：release = shu_asm -O2 + f32 xmm ABI；用户无感 B-strict        │
├──────────────────────────────────────────────────────────────┤
│ L3  编译器 dogfood 中位数不升（B-DOG ✅）                      │
├──────────────────────────────────────────────────────────────┤
│ L2  计算 microbench ≤ Zig / ≤ 0.95× C -O3（B-CMP/B-ZIG）     │
├──────────────────────────────────────────────────────────────┤
│ L1  I/O 吞吐 ≥ 1.05× Zig（B-IO）；fixed pool 全路径           │
├──────────────────────────────────────────────────────────────┤
│ L0  网络并发 ≥ 1.03× C（B-NET）；io_uring SQPOLL + fixed fd   │
└──────────────────────────────────────────────────────────────┘
```

**纪律**：自举阻塞项 > perf 微优化；宣称「超越」须对应 bench 绿；改默认 `-backend asm` 须附 bench。

---

## 2. 编译器内核与自举演进 (Core & Self-Hosting Roadmap)

### 2.1 C 阶段（当前）：最小可自举 Core

| 子系统 | 职责 | 状态 | 性能相关要点 |
|--------|------|------|--------------|
| **Lexer** | `.su` → token | ✅ seed + SU | 无堆热路径；后续 SU 直链 |
| **Parser** | token → AST pool | ✅ 288 funcs @ parser.su | `ast_pool` bump + 模块 sidecar |
| **Typeck** | 布局/符号/循环深度 | △ layout partial + C glue | field offset、enum tag 供 asm 零 indirection |
| **Codegen (asm)** | AST → ELF/Mach-O .o | ✅ x86_64/arm64/riscv64 | 无 LLVM；peephole + call 内联 |
| **Pipeline/Driver** | dep/import/link | ✅ B-strict | `build_asm/*.o` + C glue 编排 |
| **Runtime** | panic/ld/crt0 | △ Linux crt0 | 目标：syscall-only panic，无 DWARF unwind |

**asm 后端已落地的性能原语**（见 `compiler/src/asm/README.md`）：

- 线性 scan + Chaitin spill（x10–x15）；if/while/for **最小 φ**
- `backend_try_inline_*`：11 例 call-inline（含 vec div）
- 立即数二元运算、while 归纳、peephole 冗余 mov 消除
- 直接 ELF 编码（无 `-S` 文本往返）

### 2.2 自举阶段：`.su` 重写路径

| 里程碑 | 内容 | 验收 | WPO 关系 |
|--------|------|------|----------|
| **S1** ✅ | B-strict 链通；107 白名单；M11 macOS full_asm | `bootstrap-verify` | — |
| **S2** △ | typeck 整颗 SU emit（**thin delegate 空** ✅）；loop_depth/patch SU+glue | gate ✅ **68264B+/133**；emit-heavy ✅；parity CI ✅ | **S3** ✅ |
| **S3a** ✅ | pipeline.o EMIT_HEAVY + weak dispatch | **11588B / 38 func** gate ✅ | **S3b** driver |
| **S3b** ✅ | driver compile SU + bootstrap B-strict | **6008B / 18 func**；thin 空表；`bootstrap-driver-bstrict` ✅ | **Stage2** |
| **Stage2 B-strict** ✅ | shu_asm → shu_asm2 二遍自举 | `verify-selfhost-stage2-bstrict.sh`：42 + hello + **struct_mk gen2 内联** | — |
| **S3** △ | pipeline/driver/preprocess 全 SU，C glue 仅 syscall/ld | S3a/S3b ✅；typeck mega 仍 typeck.o | WPO 前置 |
| **S4** ✅ | **`-freestanding`** + 按需 io/panic + **--gc-sections** + B-BOOT-FS | `run-freestanding-hello.sh` ✅（glibc seed）；`run-perf-coldstart.sh` fs_* ✅（Linux shu_asm CI） | WPO vec fold/mono ✅ |
| **S5** ✅ | **WPO v0**：五模块 asm DCE ✅ + **binary proxy 5.92%** ✅ + **strict link 三模块** ✅ | dogfood **-3%** stretch 实锤；CI strict link gate | `run-perf-wpo-dce-shu-asm-text.sh` / `run-wpo-strict-link-gate.sh` |

**S3a pipeline.o 完成度（2026-06，`run-s3-pipeline-gate.sh`）**

| 类别 | 状态 | 说明 |
|------|------|------|
| resolve/read/load/sync | ✅ SU 真 emit | path helper、resolve 链、load_one/load_and_sync、sync_dep_slots |
| dep parse | ✅ SU 真 emit | `pipeline_parse_into_buf`、`parse_into_with_init_buf`、**`parse_into_with_init`（slice sidecar + `pipeline_parse_into_with_init_result_c`）** |
| 主流水线 | ✅ SU 编排 | `run_su_pipeline_impl`、typecheck_entry SU（skip+`pipeline_typeck_entry_module`）、codegen deps |
| slice/LSP/诊断 | ✅ SU emit + C glue | `lsp_diag_parse_*`/`typeck_after_parse_ok`/`parse_set_main` SU；`ParseIntoResult` 由 C 返回；`driver_diagnostic_*` 标量 glue |
| entry parse/typecheck | △ 部分 bl→C | `parse_entry_if_needed` SU 快路径；大路径经 pipeline SU |
| driver argv | ✅ SU 真 emit + C glue | EMIT_HEAVY；`parse_argv` init→**loop(step+glue)**→finalize；side-effect 走 `driver_compile_argv_apply_*_c` |
| driver 后端 | ✅ dispatch SU + link alias | `compile_dispatch_*` SU；`driver_compile_asm_link_alias.c`→`driver_compile_link.o`；**parity/gate ✅** |
| `k_asm_pipeline_thin_delegate` | ✅ 空表 | pipeline parse/typecheck 均 SU safe_helper 真 emit |
| `k_asm_driver_thin_delegate` | ✅ 空表 | `run_compiler_full_su*` 堆 `driver_compile_state_alloc_c` + post_parse/dispatch SU emit |
| strict `_c` 回退 | 保留 | weak dispatch→impl_c 仅 `SHU_PIPELINE_GLUE_STANDALONE_TU`；`pipeline_su.o` 可 FORCE 重编 |

**S4 前可选**：WPO-S2 smoke ✅ + perf gate ✅（compile/disasm/exit + ratio；`SHU_WPO_S2_COMPILE_ONLY=1` 可跳过计时；CI 用 `SHU_WPO_S2_LIMIT=1M`）。

**2026-06-02 S4 seed asm 修复（glibc / `build-seed-asm-host` + `relink-shu`）**

| 子系统 | 修复 | 文件 |
|--------|------|------|
| ELF 导出 | `Elf64_Sym` 字段偏移、`rela` r_info/addend、UND 外部符号 | `compiler/src/asm/platform/elf.su` |
| x86_64 编码 | `enc_epilogue` `mov %rbp,%rsp`；arg reg mov 避免 `[6][3]u8` 全零 | `compiler/src/asm/arch/x86_64_enc.su` |
| freestanding 入口 | Linux x86_64 用户 `main` 保持 ELF 裸名 `main`（与 `crt0_user_x86_64.s` `call main` 一致；去掉错误的 `_main` 重命名） | `backend_enc_dispatch.c`、`backend.su`、`run-freestanding-hello.sh` |
| 比较/分支 | `setcc` 前补 `backend_enc_cmp_rbx_rax` | `compiler/pipeline_glue.c` |
| 按需链接 | Linux `nm -u`；`SHU_USE_SU_*` guard；`relink-shu` 补 `PIPELINE_LIBS` | `runtime.c`、`Makefile` |
| WPO root 误杀 | EMIT_HEAVY 自举模块禁用 WPO reach；library 模块勿用 `main_func_index` 作 root | `compiler/ast_pool.c` |
| `0 - 1` let init | `parse_into_with_init` 的 `let fail_mi = 0 - 1` 导致块 let SUB emit 失败 → 改 `-1` 字面量 | `compiler/src/pipeline/pipeline.su` |
| 第二遍编排 | Linux crt0 失败后走 experimental bootstrap；pipeline 未达标仍跑 typeck 第二遍 | `compiler/scripts/build_shu_asm.sh` |

验收：`./tests/run-freestanding-hello.sh`（return42 exit=42；panic_div exit=134；hello stdout + exit=0；按需 trim io/panic）。Debian `docker-distro` 走完整 `shu -backend asm`；Alpine 仍 **musl crt0 烟测回退** △（待 musl CI 上 `build_seed_asm_host` 实锤）。

**2026-06-02 build_shu_asm Linux 修复**

| 项 | 说明 |
|----|------|
| `asm_o_text_bytes` | POSIX `sh` 不支持 `$((16#hex))` → 改用 `perl hex`（与 S2 gate 一致） |
| crt0 失败 | Linux 自动试 **experimental bootstrap**（`pipeline_su.o` + SU companions），不再直落残缺 gen_driver |
| gen_driver 回退 | 补链 `typeck_su.o` + `typeck_su_link_alias.o`（mega 调 `typeck_check_*`） |
| CI | S2 gate 后增 **`run-s2-typeck-o-parity.sh`**（`SHU_S2_FAIL_ON_PARITY=1`） |

**2026-06-02 LSP/entry C glue 统一**：`do_parse_c` / `lsp_diag_*_c` / glue `impl_c` 均走 `pipeline_parse_set_main_from_buf_c`；`lsp_diag_parse_typeck_buf_c` 复用 `pipeline_typeck_parsed_module`。

**2026-06-02 x86_64 codegen + shu_asm gate（B-strict strict 链）**

| 子系统 | 修复 | 文件 |
|--------|------|------|
| bool 条件分支 | `mov` 到 `eax` 后须 `test %eax,%eax` 再 `jz`（`while(false)` 等） | `compiler/pipeline_glue.c` |
| while `i < n` | 字面量 `enc_cmp_eax_imm32`；变量 `enc_cmp_rax_rbx` + load 顺序 `n`→`i` | `x86_64_enc.su`、`backend.su` |
| struct 字段偏移 | while 体内 `let` 作用域查类型 → 正确 `p.b` 偏移 | `pipeline_glue.c`（`g_pipeline_asm_emit_scope_block`） |
| 大栈实参 CALL | `enc_add_rsp_imm` 支持 imm32（65 实参 480B 回收） | `x86_64_enc.su` |
| SysV 奇数栈实参 | 8B 对齐垫 **先于** 栈实参 push（`many_call_args` exit=64） | `backend_call_dispatch.c` |
| ELF 识别 | 无 `file(1)` 时用魔数 `7f454c46` | `tests/run-return-value.sh` |

验收：`SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh` ✅（含 pool-limits / check / fmt / test）；`verify-selfhost-stage2-bstrict.sh` ✅；`many_call_args.su` exit=64。

**2026-06-02 rebuild_main_o_for_cli（strict 链 main.o 真 emit entry）**

| 项 | 说明 |
|----|------|
| 根因 | 原实现去掉 `ENTRY_MODULE_ONLY` → 全量 dep typeck 失败（codegen `type_to_c_repr`）或 shu_asm SIGSEGV |
| 修复 | `ENTRY_MODULE_ONLY` + `SHU_ASM_ENTRY_EMIT_HEAVY=1` + `SKIP_TYPECK`（与 typeck 第二遍同模式） |
| 验收 | `main.o` 导出 `entry`（~9–13KiB __text）；`rebuild_main_o_for_cli` 绿；gate check/fmt/test 仍 OK |

**2026-06-02 typeck 整颗 SU 直链（✅ strict 链）**

| 项 | 说明 |
|----|------|
| 方案 | `build_asm/typeck.o` 整链 + `typeck_asm_bare_link_alias.c`（52 个裸→`typeck_` 前缀）+ `typeck_c_module_stubs.c`（`typeck_module`/`typeck_one_function` weak 桩，替代 seed `typeck_c_orchestration_partial`） |
| 生成 | `compiler/scripts/gen_typeck_asm_bare_link_alias.py` 从 typeck.su 签名自动 diff 生成 alias |
| 兼容 | `typeck_su_link_alias.c` 中 `check_*_impl`/`find_or_alloc_ptr` 改 **weak**，整链时 build_asm 强符号覆盖 |
| 验收 | `make bootstrap-verify` ✅；`run-shu-asm-gate` ✅；`verify-selfhost-stage2-bstrict` ✅；不再链 `typeck_su_no_layout` |

**2026-06-03 去掉 `typeck_c_orchestration_partial`（✅）**

| 项 | 说明 |
|----|------|
| 动机 | strict 链已整链 `build_asm/typeck.o`，不再需要从 seed `typeck.o` ld -r 抽出 `typeck_module` |
| 方案 | 新增 `typeck_c_module_stubs.c`：weak `typeck_module` / `typeck_one_function` 返回 -1，满足 `lsp_diag.c` 链接 |
| 影响 | 编译/诊断热路径仍走 `typeck_su_ast`；strict shu_asm 上 LSP C-path definition/hover 不可用（完整 LSP 仍用 seed `shu`/`shu-su`） |
| 验收 | Linux：`build_shu_asm.sh` + `bootstrap-verify` + `run-shu-asm-gate` + `verify-selfhost-stage2-bstrict` |

**2026-06-03 Alpine/musl seed asm 前置（✅）**

| 项 | 说明 |
|----|------|
| 根因 | Alpine GCC 在 `pipeline_su.o` 编译时报 `pipeline_resolve_path_su`：`uint8_t*` vs `uint8_t[64]` 冲突 → `bootstrap-verify` 失败 → `shu_asm` 缺失 → freestanding 回退 musl 烟测 |
| 修复 | `ast_pool.c` 统一 `import_path[64]`；`fix_pipeline_extern_gen_c.pl` 去掉 `parser_copy` 指针声明；`pipeline_glue.c` 前置 `asm_ctx_set_scope_block`；musl 也用 `runtime_panic_x86_64.s`；freestanding 符号 `main` 与 crt0 对齐；**runtime 按需链**（`nm -u` 空 → 仅 `gcc user.o -lc`） |
| 验收 | Alpine docker：seed `./shu -backend asm return-value` ✅；`-freestanding return42` ✅；musl fallback 烟测 ✅；**shu_asm strict + hello gate + bootstrap-verify** ✅ |

**2026-06-03 shu_asm strict hello / Stage2（✅）**

| 项 | 说明 |
|----|------|
| 根因 | gen1 `shu_asm` 无 `-backend asm` 时 import 降级 C → ld undefined；Alpine silent fail / SIGSEGV |
| 修复 | `runtime.c` + `compile.su`：有 `-o` 时设 `backend_asm_explicit=1`；`print_str`→`std_io_print_str`；pipeline skip load/sync；`x86_64_enc` 1-byte store；CALL 实参 lea |
| 验收 | `SHU=./compiler/shu_asm ./tests/run-shu-asm-gate.sh` ✅；Alpine `make bootstrap-verify` ✅（Stage2 hello 42/42 + check-7.2-bstrict） |

**2026-06-03 gen2 用户 typecheck（✅ partial 预检）**

| 项 | 说明 |
|----|------|
| 根因 | strict 链 `typeck_c_module_stubs` weak 桩导致 impl_c 双 skip；SU typecheck 对 return-value SIGSEGV |
| 修复 | `ensure_typeck_c_user_precheck_obj`：优先 seed `typeck_c_orchestration_partial`；`runtime.c` 统一 C 预检 |
| 验收 | gen2 负例 C 预检 + `bootstrap-verify` + smoke return-value |

**2026-06-03 WPO main.su asm A/B（✅）**

| 项 | 说明 |
|----|------|
| 根因 | 脚本用 `-L compiler/src` 全量编 main.su → import/typeck 失败或 180s 超时 |
| 修复 | 与 `rebuild_main_o_for_cli` 同模式：`ENTRY_ONLY` + `SKIP_TYPECK` + `EMIT_HEAVY`；`ast_pool.c` WPO root 补 `entry` |
| 验收 | `run-perf-wpo-dce-compiler-self-text.sh` main.su A/B 数秒内完成（~9460B→~32B __text proxy，≥3% gate） |

**2026-06-03 struct_mk gen2 内联（✅）**

| 项 | 说明 |
|----|------|
| 现状 | gen2 `struct_mk_let_inline.su` exit=10；`_main` 无 `call mk`（与 gate `shu_asm` 一致） |
| 验收 | `verify-selfhost-stage2-bstrict.sh` Step 4b 升为硬门禁（非 warn） |

**2026-06-03 vec_div4 call-inline SIGFPE（✅）**

| 项 | 说明 |
|----|------|
| 根因 | i32x4 lane 用 `movq` 读栈槽 → 相邻 lane 污染 `rdx`；`idiv` 前缺 `cltd` → Alpine #DE SIGFPE（exit 136） |
| 修复 | `enc_load_rbp_to_eax32`/`ebx32` + `backend_enc_load_rbp_lane_to_*`；`backend_enc_idiv_rbx_arch` x86 前补 `cltd` |
| 验收 | `run-asm-call-inline.sh` 11 例全绿（含 vec div）；`bootstrap-verify` ✅ |

**2026-06-03 WPO 生产 main.o dogfood（✅）**

| 项 | 说明 |
|----|------|
| 根因 | Alpine 默认栈 8MB：`main.su` EMIT_HEAVY + WPO 易 SIGSEGV；`rebuild_main_o` 误 fallback 9460B |
| 修复 | `ulimit -s 65532` 于 smoke/rebuild/stage2；WPO on 校验 __text≤512B；post-strict **优先 `./shu_asm`**（2026-06-03：ast_pool+pipeline_su 重链后 main EH=0/1 均 ~656B，SIGSEGV 已消除） |
| 门禁 | `run-wpo-main-o-gate.sh` 硬门禁（≤512B + `entry`）；Stage2 Step 2b/2c |
| 度量 | `run-perf-wpo-dce-compiler-self-text.sh` §4：**wpo-eligible**（main.o + driver_compile.o + pipeline_wpo.o + typeck_wpo.o + backend_wpo.o）；≥50000B chain gate |

**2026-06-03 WPO 生产 driver_compile.o dogfood（✅）**

| 项 | 说明 |
|----|------|
| 方案 | 双产物：`driver_compile.o` WPO 压缩（~145B，`compile_dispatch_asm_backend`）；`driver_compile_emit_heavy.o` 全量 EMIT_HEAVY（strict link / S3 insn gate） |
| 修复 | `ast_pool.c` driver WPO should_emit；`build_shu_asm.sh` post-strict `rebuild_driver_compile_*`；`run-s3-driver-sync-build-o.sh` 拆分 |
| 门禁 | `run-wpo-driver-o-gate.sh`（≤768B + WPO export）；S3 gate insn 仍查 emit_heavy.o；CI bootstrap + stage2 Step 2d |

**2026-06-03 pipeline.su WPO + perf 快路径（✅）**

| 项 | 说明 |
|----|------|
| 方案 | `ast_pool.c`：pipeline 以 `run_su_pipeline_impl` 为 WPO root；产出 `pipeline_wpo.o`（strict 仍用全量 `pipeline.o`） |
| 实测 | A/B：11588B → **1745B**（~85%）；5 符号 export |
| 门禁 | `run-wpo-pipeline-o-gate.sh`（≤2048B + save≥8000B + `run_su_pipeline_impl`）；Stage2 Step 2e |
| 快路径 | `tests/lib/wpo-ab-proxy.sh`：build_asm 已有压缩 .o 时用 baseline proxy，CI 免 180s×N 重编 |

**2026-06-03 shu_asm 全二进制 WPO proxy（✅）**

| 项 | 说明 |
|----|------|
| 方案 | 五模块 eligible 代理反推 WPO-off |
| 实测 | **100687B / 5.92%** proxy（main+driver+pipeline+typeck+backend）；stretch **-3%** ✅ |
| 门禁 | `min_binary_proxy_save_pct=3.00`；eligible ≥50000B |

**2026-06-03 typeck.su WPO dogfood（✅）**

| 项 | 说明 |
|----|------|
| 方案 | `ast_pool.c`：`typeck_su_ast` WPO root + reach；产出 `typeck_wpo.o`（strict 仍用全量 `typeck.o`） |
| 实测 | A/B：**79397B → 1253B**（~98%）；6 符号 export |
| 门禁 | `run-wpo-typeck-o-gate.sh`（≤2048B + save≥70000B）；Stage2 Step 2f |
| 修复 | `relink_shu_asm_experimental_bootstrap.sh` Linux 补 `-luring`；ast_pool 变更后 `make pipeline_su.o` + relink |

**2026-06-03 backend.su WPO dogfood（✅）**

| 项 | 说明 |
|----|------|
| 方案 | `ast_pool.c`：`asm_codegen_ast` WPO root + reach；产出 `backend_wpo.o`（strict 仍用全量 `backend.o`） |
| 实测 | A/B：**4677B → 117B**（~97%）；5 符号 export |
| 门禁 | `run-wpo-backend-o-gate.sh`（≤512B + save≥4000B）；chain gate 五模块聚合 |
| 构建 | `build_shu_asm.sh` `rebuild_backend_wpo_o` / post-strict |
| CI | `ensure-wpo-build-asm-artifacts.sh` + chain gate + **`run-wpo-strict-link-gate.sh`**（缺 `*_wpo.o` 时 `SHU_WPO_REBUILD_ARTIFACTS_ONLY=1` 补编） |

**2026-06-03 WPO strict link 三模块（✅）**

| 项 | 说明 |
|----|------|
| 方案 | `pipeline_wpo.o` + `typeck_wpo.o` + `backend_wpo.o` 链入 `shu_asm.strict_glue`；seed partial 用 `comm -23` 剔除 WPO 已替代符号 |
| 组件 | `typeck_strict_link_partial.o` / `backend_asm_bare_link_alias.c` / `asm_backend_seed_helper_partial.o` |
| 门禁 | `run-wpo-strict-link-gate.sh`（reach + relink + 编排符号非 U）；CI WPO-S2 + `run-bootstrap-bstrict-ci.sh` + Stage2 Step 2h |
| 限制 | strict_glue 全路径 asm 编译仍不稳定（`ENTRY_MODULE_ONLY` SIGSEGV）；dogfood 走 `shu_asm.experimental` |

### 2.3 全知图优化（WPO）引入时机

**为何不等 LTO**：Clang/Zig LTO 在链接期做 IPA，编译/链接双份成本，且丢失前端语义（ownership、slice lifetime）。Shulang 在 **S3 完成后**于 pipeline 层构建：

```
Module AST ──► Per-func CFG + call edges ──► Whole-Program Graph (WPG)
                      │                              │
                      ▼                              ▼
              Intra-procedural opts          Inter-procedural:
              (现有 peephole/inline)         • Global DCE（dead export 剔除）
                                             • Context-Sensitive Inline
                                               （call site 常参 → 特化 asm）
                                             • Devirt（trait 单 impl 消解）
                                             • SOA layout rewrite hint（见 §4.3）
```

**WPO v0（S5）**：只读 call graph + 常量实参；在 `asm_codegen` 前插入 `wpo_specialize(module, callsite)`，生成单态副本（如 `vec_add4_i32_16`）。**零运行时开销**——多份 .o 由链接器 `--gc-sections` 剔除未引用。

**WPO v1（2027 H1）**：跨模块 escape analysis → stack allocate 小 struct；跨 await 点不变（协程帧布局见 §3.2）。

**验收**：`run-perf-compile-dogfood.sh` 中位数降 ≥3%；`size shu_asm` 降 ≥2%；`run-asm-73-gate.sh` 仍绿。

---

## 3. 标准库与硬核性能特性落地 (Std & Performance Implementation)

### 3.1 全面零拷贝（Total Zero-Copy）

#### 3.1.1 问题：C/Zig 的结构性拷贝

| 层 | C | Zig | Shulang 破局 |
|----|---|-----|--------------|
| 读 API | `fread` 经 `FILE` 内部 buffer | `Reader.read` 默认拷入用户 buf | **`read_ptr` / mmap / fixed read** |
| 写 API | `fwrite` 二次缓冲 | `Writer.write` 可控但仍常 alloc | **直传 ptr → `writev`/SQE** |
| 网卡→用户 | `recv` + 用户 buf | 同左 | **`IORING_OP_PROVIDE_BUFFERS`**（Linux 5.19+） |
| 磁盘→socket | `read`+`write` | `sendfile` 可选 | **`splice`/`sendfile` 一等公民** |
| 字符串切片 | pointer + length 手动 | `[]const u8` 仍可能 alloc | **编译期 lifetime 域 + 视图类型** |

#### 3.1.2 已落地（✅）

- **写零拷贝**：`std.io.write` → `io_uring_prep_write` / `write`，用户 ptr 直达内核（`std/io/mod.su`）。
- **读半零拷贝**：`read_ptr` 返回 TLS 单缓冲视图（Z2 生命周期文档）；大文件 `std.fs.fs_mmap_ro`。
- **内核 fixed buffer**：`io_register_buffers` → `io_uring_register_buffers`；批量读走 `read_fixed`（`std/io/io.c`）。
- **sendfile**：`tests/bench/zero_copy_sendfile`；cap 0.20s（`io-perf.tsv`）。

#### 3.1.3 路线图

| 代号 | 机制 | 底层实现 | 目标季度 | 验收 |
|------|------|----------|----------|------|
| **ZC-1** △ | **Provided Buffers** | API + smoke + echo bench + io 热路径；`-10%` 须 **GHA ubuntu 原生**（Mac Docker Desktop `queue_init=-38` 无 io_uring） |
| **ZC-2** ✅ | **macOS 绝对视图** | `ReadPtrView` + Linux mmap + **macOS dispatch_data** + `read_ptr_backend()`；`run-zc2-gate.sh` | 2026 Q3 | Darwin exit=22 / Linux exit=21 |
| **ZC-3** ✅ | **编译期 Slice 域** | M-3 region + M-5 read_ptr 域；`run-zc3-gate.sh` + **`run-zc-gates.sh` CI** | 2026 Q4 | region array smoke + typeck |
| **ZC-4** ✅ | **String 视图** | `StrView` + `stack_str_*`（SSO_STACK 32B）+ `string_view_concat_arena`；`run-zc4-gate.sh` + `run-perf-string-arena.sh`（Linux strace 零 malloc） | 2027 Q1 | gate + bench exit=128 |
| **ZC-5** ✅ | **splice 管道** | `fs_pipe_splice` + `run-zc5-gate.sh` + `zero_copy_splice` **io-perf.tsv**（cap 0.35s） | 2027 Q1 | Linux：16MiB + strace splice |

**String/Buffer 零拷贝语义（目标语法级）**：

```su
// 编译期证明：s 的生命周期 ⊂ buf 的 arena 域；无 RC，无 copy
let arena = Arena.open();
let buf = arena.alloc(4096);
let s: Slice<arena> = buf.subslice(0, n);   // ptr+len 视图
let t = s.subslice(2, 5);                   // 仍零拷贝
// escape arena → typeck error
```

### 3.2 高并发与高吞吐（Async & IO）

#### 3.2.1 架构：M:N 无栈协程

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ OS Threads  │────►│ Per-CPU Runqueue │────►│ Stackless Task  │
│ (pinned)    │     │ (MPMC ring,      │     │ (state machine  │
│             │     │  cache-line pad) │     │  in .text)      │
└─────────────┘     └──────────────────┘     └─────────────────┘
         │                    │                       │
         ▼                    ▼                       ▼
   io_uring/kqueue      work stealing            await → jmp table
   SQPOLL thread        bounded ring 64K         no malloc frame
```

**相对 Zig 的突破口**：Zig 移除 async；C 只有 pthread。我们用 **编译期 CPS 变换** 生成 state machine，**无 `malloc` 协程栈**，切换目标 **≤15ns**。

#### 3.2.2 无栈协程最优化（Stackless Async）

| 阶段 | 编译器行为 | 运行时 |
|------|------------|--------|
| **A0** ✅ | `std.async` sync 门面 | submit+wait（现有） |
| **A1** ✅ | 手工状态机 + `scheduler.c` switch | `async_switch.su` + `coop_pingpong` |
| **A2** ✅ | **computed-goto 跳转表** | `async_switch_sched.su` + `coop_pingpong_jmp`；runtime 按需链 scheduler.o ✅ |
| **A2b** ✅ | **`async function` 语法** | `async function` + `Func.is_async`；codegen 暂同普通 emit |
| **A2c** ✅ | **`await` 语法原型** | `await expr` + `AST_EXPR_AWAIT`；仅 async 内；sync stub（无 CPS） |
| **A3** ✅ | **CPS suspend/resume** | static 帧 + yield 烟测 ✅；return reset `__phase` ✅；`shu_async_sched_*` ✅；await IO CPS ✅；顶层 `const 0x…` ✅ |
| **A4** ✅ | **M:N 就绪队列** | per-worker 环 + **`run` v4** + **`spawn` v4**（并行 in-flight）✅；**v5 spawn + workers IO e2e** ✅ |

**Lock-Free 数据结构规范**：

- 所有热路径队列：**SPSC/MPSC ring buffer**，`head`/`tail` 各独占 **64B cache line**（`align(64)`）。
- 计数器：`atomic.u64` + `memory_order_relaxed`（仅统计）；同步点用 `acquire/release`。
- 伪共享防护：`struct TaskQueue { align(64) head; align(64) tail; align(64) slots[]; }`。
- **禁止** general `Mutex` 出现在 `run-perf-net.sh` hot path（仅 cold setup）。

#### 3.2.3 IO 模块时间表

| 代号 | 内容 | 平台 | 验收 |
|------|------|------|------|
| **IO-A1** ✅ | io_uring + register_buffers + read_fixed | Linux | I1–I6 bench 绿 |
| **IO-A2** ✅ | kqueue / readv 回退 | macOS/BSD | 与 C 同级 cap |
| **IO-A3** ✅ | **SQPOLL 默认开**（`SHU_IO_URING_SQPOLL=1`）+ `/proc` 禁用探测；fixed slot 失败仍走 uring 非 syscall 回退 | Linux | accept_many 门禁不回归 |
| **IO-A4** ✅ | **multishot accept**（`SHU_IO_URING_MULTISHOT_ACCEPT=1`；内核 6.0+ + liburing） | Linux 6.0+ | `run-io-multishot.sh` Linux CI ✅ |
| **IO-A5** ✅ | io_uring 与 **协程 scheduler 融合** | 双 pipe `.su` run ✅；v3 poll wake ✅；v4 spawn 并行 + drain ✅；**v5 C spawn + workers e2e** ✅ |
| **IO-A6** △ | Windows IOCP + registered buffer | `run-iocp-gate.sh` smoke ✅；`run-perf-iocp.sh` pipe batch + `iocp-perf.tsv`（Windows CI 待实锤） |

### 3.3 零成本内存安全（Zero-Cost Memory Safety）

**设计原则**：拒绝 GC；拒绝 Rust 级 borrow checker 运行时；拒绝 Zig 式全手动 `defer` 作为唯一手段。

#### 3.3.1 三层静态证明（运行时开销 = 0）

| 层 | 机制 | 编译期 | 运行时 |
|----|------|--------|--------|
| **L1 区域域** | `Arena` / `Region<'scope>` | 离开 scope 自动 `invalid` 域内所有 slice | bump free = 单指针 reset |
| **L2 线性类型** | `Linear(T)`：use-once move | 二次 use = error | 无 RC |
| **L3 所有权域** | `Own<T>` / `Slice<'owner>` | escape analysis on AST | 无 fat pointer |

**与 unsafe 边界**：`unsafe { ... }` 块内降级为 C 语义；块外恢复 L1–L3。FFI 出口自动 `Own→ptr` + 文档化 transfer。

#### 3.3.2 Memory 模块时间表

| 代号 | 内容 | 验收 |
|------|------|------|
| **M-1** ✅ | `std.mem` copy/set/compare + Buffer ABI | 现有 |
| **M-2** ✅ | `std.heap` Arena + 按需链接 | `run-heap.sh` |
| **M-3** ✅ | **`Region<'a>` typeck 原型** | C/shu-c ✅；SU glue ✅；`run-typeck-region.sh` + **`run-pre-push-p5.sh`**；Linux refresh gate ✅（`docker-ci-local.sh ubuntu-gates`） |
| **M-4** ✅ | **`Linear(T)` move 语义** | C/shu-c ✅；SU migrate ✅；refresh gate SU 负例 + shu-c 正例 emit ✅ |
| **M-5** ✅ | 与 **ZC-3 slice 域** 合并 | `read_ptr_slice` C+std.io + typeck 域 `io_read_ptr`；codegen 局部 slice 用 `.`；`run-io.sh` / `run-typeck-region.sh` |
| **M-6** ⬜ | `-fsanitize=address` 等价 **comptime 插桩模式**（仅 debug） | 零 release 开销 |

---

## 4. 优化专项攻坚 (Optimization Sprints)

### 4.1 编译期全知图优化器（WPO Optimizer）

| Sprint | 周期 | 交付 | 指标 |
|--------|------|------|------|
| **WPO-S1** ✅ | 2026 Q3 | call graph JSON + codegen WPO DCE | dead export 剔除（单文件+跨 import） |
| **WPO-S0** ✅ | 2026 Q3 | `codegen_wpo_reach` 接入 `-E`/`-o` emit + **asm `-backend asm -o` DCE** | `run-wpo-dce-emit.sh`（含 if-block→some_i32 可达）/ `run-wpo-dce-asm.sh` |
| **WPO-S5** ✅ | 2026 Q2 | asm dead export 剔除 + **五模块 build_asm dogfood** + binary proxy **5.92%** + **strict link 三模块** | `run-wpo-build-asm-chain-gate.sh` / `run-wpo-strict-link-gate.sh` / `run-perf-wpo-dce-shu-asm-text.sh` |
| **WPO-S2** ✅ | 2026 Q4 | call graph v2 + **asm 标量/vec const fold/mono** ✅ + **perf gate** ✅ | `run-wpo-s2.sh` + `run-perf-wpo-s2.sh --bench`（`ubuntu-wpo-s2` / CI）；修复：注释 `+=` 误降级、`i32x4_t` typedef、vec `return s`→exit128、NO_FOLD 关 WPO DCE |
| **WPO-S3** ✅ | 2027 Q1 | 跨模块 escape → stack promotion | smoke/cross/cross_ret/escape/escape_cross exit7 ✅；escape_global typeck 拒 ✅；**await asm CPS** exit10 + **SHU_ASYNC_YIELD** await_yield exit0 ✅（`parser.su` let=await 解析 + `glue_async_cps_emit_phase_reset` preserve rax）；**CI** WPO-S3 step + `ubuntu-wpo-s3-full` |
| **WPO-S4** ✅ | 2027 Q2 | Profile-guided layout（PGO-Lite）| **S0** ✅ binary __text 代理；**S1/S2** ✅ `SHU_WPO_PGO_HOT=1` 用户 `.text.hot`/`.text.unlikely` + call-depth emit 序；`ast_pool.c`：用户 PGO main 补边/修剪误边、`g_asm_wpo.valid` 先于 depth 标记；**CI** `ubuntu-wpo-s4-full` |

**Context-Specific Specialization 示例**：

```su
// 源码
function dot(a: *f32, b: *f32, n: i32): f32 { ... }

// WPO 见 call site: n=1024, align=64 → 生成 dot_1024_avx2 单态体
// 未引用版本由 --gc-sections 剔除
```

### 4.2 硬件-centric 优化（SIMD + DOD）

#### 4.2.1 自动 SIMD 矢量化

| Sprint | 内容 | 实现 |
|--------|------|------|
| **SIMD-S1** ✅ | 目标 CPU feature 探测 | `-target-cpu` + `/proc/cpuinfo` / sysctl；`--print-target-cpu`；`run-simd-s1-gate.sh` |
| **SIMD-S2** ✅ | **std.simd** 类型：`Vec4f`、`Vec8i` | f32x4/i32x8 映射；`run-simd-s2-gate.sh` |
| **SIMD-S3** ✅ | 硬件向量 add/sub/mul + loop peel/条带 | peel + 可变 n 条带；`run-simd-s3-gate.sh` |
| **SIMD-S4** ✅ | shuffle + select + `@shuffle`/`@select`；`run-simd-s4-gate.sh` + `run-perf-simd-dot.sh` | M8-tail：`simd_vector_inline.su` bl→C |

**2026-06-05 SIMD shu_asm parse/relink（✅ Linux Docker）**

| 项 | 说明 |
|----|------|
| parse | `parser.su` `parse_primary_into` 数组字面量改走 `parse_expr`（Vec4f `[t, t+1.0, …]`）；`parse_as_suffix_into` 补 `as f32/f64` |
| relink | `relink_shu_asm_experimental_bootstrap.sh` 补 `target_cpu.o`/`simd_enc.o`/`simd_loop.o` + `runtime_driver_asm_strict.o` |
| 烟测 | `tests/asm/simd_dot_as_f32_smoke.su`、`simd_vec4f_*.su`；`run-perf-simd-dot.sh` **1.47×** C（≥0.90） |

**2026-06-06 DOD-S1 正确性 + 大栈帧 INDEX（✅ SoA Docker）**

| 项 | 说明 |
|----|------|
| x86 load | `enc_load_rbp_to_rbx` 大 disp modrm **0x9d**（旧 0x95 误 load %rdx）；`backend_enc_dispatch.c` 内联兜底 |
| i32 load | `backend_enc_load_32_from_rax_arch` 后 **cdqe**（SoA/binop 勿把指针当数值） |
| INDEX esz | `[N]Struct` 用 layout 宽 + `imul` 非标量步长（12B struct） |
| bench | `dod_*_sum_x.su` 改 **i32** + `return sum/256`（4096→exit **16**，规避 shell 8-bit） |
| 门禁 | `run-perf-dod-soa.sh`：`shu_asm -o` 链可执行 + `WANT_RC=16`；SoA/AoS **exit=16 OK** |
| L1 | **GHA linux x64** 已启用 `SHU_DOD_SOA_REQUIRE_L1=1` + `perf_event_paranoid=1`；Docker 本地 perf 常为 nan（跳过 L1 硬门禁） |

**2026-06-06 DOD-S1 AoS 大数组栈帧（✅ Docker）**

| 项 | 说明 |
|----|------|
| 根因 | `[N]Struct` AoS 栈槽误算 `N×8`（struct 当指针宽），4096×12 数组溢出覆盖 `i`/`s` → sum=0 |
| 修复 | `ast_pool.c` `asm_fixed_array_total_bytes_mod`：SoA 列主序 / AoS `N×layout`；`glue_fixed_array_temp_bytes` 对齐 `glue_type_size_simple` |
| 验收 | `dod_aos_sum_x.su` **exit=16**（与 SoA 一致）；prologue `sub $0x18060` |

**2026-06-06 DOD-S2 vec3f_soa_push SIGSEGV（✅ Docker）**

| 项 | 说明 |
|----|------|
| 根因 | `backend_enc_load_rbp_to_rbx_arch` disp8 分支误用 modrm **0x9d**（disp32），应为 **0x5d**；`mov -8(%rbp),%rbx` 仅 4 字节却被 CPU 当 7 字节 disp32 解析，吞掉后续 `mov %rbx,%rax` 等 emit → `v.col_x[i]=x` 指令重叠 |
| 修复 | `backend_enc_dispatch.c` disp8 改 **0x5d**（与 `x86_64_enc.su` `enc_load_rbp_to_rbx` 一致） |
| 验收 | `run-dod-s2-gate.sh` **exit=3 OK**；`vec3f_soa_push` 反汇编 `48 8b 5d f8` + 三列 f32 store 无重叠 |

**2026-06-06 SoA y 列 field 写（✅）**

| 项 | 说明 |
|----|------|
| 根因 | `pipeline_fill_soa_field_access_for_asm_emit` 在 `typeck_field_soa_index` 写 col_base 后，又用 AoS `layout_off` 覆盖 `field_access_offset`（y 列 8→4） |
| 修复 | `soa_stride > 0` 时跳过 AoS layout 回落 |
| 验收 | `soa_smoke.su` 含 `arr[0].y=1` + x 列累加 **exit=8**；反汇编 `arr[0].y` → `add $0x8,%rax` |

**2026-06-06 f32 SoA 列扫描 addss（✅ Docker）**

| 项 | 说明 |
|----|------|
| codegen | `backend_enc_addss_rax_rbx_arch` + `glue_emit_binop_add_rax_rbx_elf_c`：双操作数 resolved f32 时走 **addss**（非整数 add） |
| 烟测 | `tests/dod/f32_soa_sum_smoke.su` 栈 SoA 列累加 **exit=10**；`run-dod-s1-gate.sh` 含 disasm **addss** 检查 |
| f32 lit | `let v: f32 = 1.0` / field assign 走 **32-bit 位型**（`glue_emit_float_lit` + `store_eax_to_rbp` + lane load） |
| f32 bench | `tests/bench/dod_f32_soa_sum_x.su` / `dod_f32_aos_sum_x.su`（4096×1.0 addss，exit=16）；`run-perf-dod-soa.sh` 含 disasm **addss** |
| AoS lit assign | `glue_emit_assign_rhs_elf_c`：f32 左值 + 浮点字面量发 **imm32**；`f32_aos_lit_assign_smoke.su` exit=10 ✅ |
| SIMD peel | f32 SoA 列 reduce **movups/addps** peel（`glue_try_simd_peel_f32_soa_sum_while_elf_c`）✅ |
| SIMD strip | f32 SoA **可变 n 条带** + 标量 epilogue（n%4≠0）；`f32_soa_sum_strip_smoke` exit=10、`strip_var_n` exit=12 ✅ |
| f32 xmm ABI | **默认 ON**（`-legacy-f32-abi` / `SHU_ABI_F32_XMM=0` legacy）；**release `-O2`+xmm**；弃用表 **`F32_XMM_ABI.md` §5**；CI **CLI legacy 烟测** ✅ |
| AoS f32 layout | `glue_type_align_simple`：**f32 align=4**（勿 8→0/8/16）；struct lit **4B store + imm32**；f32 **ADD 链 addss** ✅ |

**2026-06-06 Vec3f heap sum_x（✅ Docker）**

| 项 | 说明 |
|----|------|
| 烟测 | `tests/vec/vec3f_soa_sum_smoke.su`：push 1/2/3 → **`vec3f_soa_sum_x` exit=6**；`run-dod-s2-gate.sh` 含 disasm **addss** |
| 路径 | heap `*Vec3f_soa` 形参 field INDEX + f32 **addss** + **`as i32` cvttss2si** |

**2026-06-04 DOD-S2 sum_x exit=0 根因（✅ Docker）**

| 项 | 说明 |
|----|------|
| 根因 | `backend_enc_cvtsd2ss_eax_from_f64_bits_arch` 的 **movq xmm0,rax** 缺 **66** 前缀（`48 0F 6E` 落到 **mm0**），`cvtsd2ss` 读 xmm0 得 0 → heap 三列全 0 → sum=0 |
| 修复 | `backend_enc_dispatch.c`：`66 48 0F 6E C0`（5 字节）；形参 f32 **cvtsd2ss** 后 push 写入正确 |
| 附带 | `pipeline_glue.c` 形参 f32 类型优先 + INDEX assign push/pop + `*Vec3f_soa` 大 struct 形参 hidden ptr 判定 + **`as f32` cvtsi2ss** |
| 验收 | `run-dod-s2-gate.sh` **exit=3 + exit=6 OK**（Docker linux/amd64 `shu_asm`） |

**2026-06-04 DOD-S2 import CALL f32 实参（✅ Docker）**

| 项 | 说明 |
|----|------|
| 根因 | `import std.vec` 的 `vec3f_soa_push(…, 1.0, …)`：dep 形参 f32 type_ref 未映到 caller arena → CALL emit 误 f64 movabs 低 32 位=0 |
| 修复 | `glue_asm_resolve_call_target_module_c` + dep type 映射；CALL f32 字面量 **`call_abi_widen_f64`** 发正确 f64 位型（整型寄存器 8B 槽 + callee cvtsd2ss） |
| 验收 | push 反汇编 `movabs $0x3ff0000000000000`（1.0）；S1/S2/S3/CL 门禁全绿 |

**2026-06-04 DOD f32 bench + AoS addss（✅ Docker）**

| 项 | 说明 |
|----|------|
| bench | `tests/bench/dod_f32_soa_sum_x.su` / `dod_f32_aos_sum_x.su`（4096×1.0 f32 列扫描，exit=16） |
| codegen | `glue_binop_operand_is_scalar_f32_elf_c` 补 **FIELD_ACCESS** f32 回落（AoS `arr[i].x` addss） |
| 门禁 | `run-perf-dod-soa.sh` 含 f32 bench 正确性 + disasm **addss** |
| AoS lit assign | `glue_emit_assign_rhs_elf_c` + `f32_aos_lit_assign_smoke.su`（字面量 field assign + 累加 exit=10）✅ |
| SIMD peel | `glue_try_simd_peel_f32_soa_sum_while_elf_c`：SoA f32 列 **movups/addps** reduce；`f32_soa_sum_peel_smoke.su` ✅ |


| 项 | 说明 |
|----|------|
| CI | GHA linux x64：`run-dod-s2-gate.sh` + `run-dod-s3-gate.sh` + **`run-dod-cl-s1-gate.sh`** + **`run-dod-cl-s2-gate.sh`**；perf 加 **`SHU_DOD_SOA_REQUIRE_L1=1`** + `sysctl perf_event_paranoid=1` |
| 验收 | Docker：S3 **exit=10×2**；CL-S1 **exit=64 + tail@64 disasm**；CL-S2 **exit=0**；L1 硬门禁须 **GHA 原生 ubuntu** 实锤 |

| 项 | 说明 |
|----|------|
| CI | GHA `linux` x64：`SHU_DOD_SOA_FAIL=1` + `run-dod-s1-gate.sh`（`build_shu_asm` 后） |
| 脚本 | `tests/lib/dod-native-exe.sh` 统一 native 检测（无 file 时不 SKIP）；perf 回落 cache-misses |
| smoke | `soa_smoke.su` / `soa_attr_smoke.su` 改 **i32**；x/y 列读写 exit=8 |

**2026-06-05 DOD-S1 SoA 读路径（✅ Linux Docker）**

| 项 | 说明 |
|----|------|
| typeck | `typeck.su` FIELD_ACCESS 委托 `pipeline_typeck_check_expr_field_access_c`（含 SoA arr[i].field） |
| codegen | emit 前 `pipeline_fill_soa_field_access_for_asm_emit`；INDEX FA 读回落 lvalue 寻址 |
| parse | C `parser.c` 补 `#[soa]` 顶层属性；seed `parser.o` 须与 `parser.c` 同步 |
| 门禁 | `run-dod-s1-gate.sh` ✅（`soa_smoke.su` + `soa_attr_smoke.su`） |

**2026-06-06 DOD parser 根因修复 ✅**

| 项 | 说明 |
|----|------|
| parser.su | `struct_field_continues_tok_kind` 含 `TOKEN_ALIGN`；续字段 `align(64) tail:` 不再误 `return -1` |
| 效果 | `Ring64` parse 直出 **nf=2, tail@64, fa1=64**（无需 emit 侧 STRUCT_LIT merge 兜底） |
| 重建 | `make parser_gen.c parser_su.o` + `pipeline_su.o PIPELINE_SU_FORCE_COMPILE=1` + `relink_shu_asm_experimental_bootstrap.sh` |

**2026-06-06 DOD-S2/S3 + DOD-CL P5 续跑 ✅**

| 项 | 说明 |
|----|------|
| DOD-S2/S3 | FIELD_ACCESS layout 偏移 + CALL `*T` lea/load + 形参 fill 策略；`run-dod-s2-gate.sh` / `run-dod-s3-gate.sh` **exit=3 OK**（Docker linux/amd64 `shu_asm`） |
| DOD-CL-S1 | asm emit 前 STRUCT_LIT 合并 layout + `field_align` 动态 offset + 单 layout fallback；`run-dod-cl-s1-gate.sh` **exit=64 + disasm tail@64 OK** |
| DOD-CL-S2 | `arena64_*` / `ptr_mod` → `heap_*_c` 重定向；smoke 用 struct lit 代替 `arena64_empty()`（skip dep emit）；`run-dod-cl-s2-gate.sh` **exit=0 OK** |
| 重建 | `pipeline_glue.c` 变更后须 `make pipeline_su.o PIPELINE_SU_FORCE_COMPILE=1` + `relink_shu_asm_experimental_bootstrap.sh` |

**2026-06-04 P5 全绿（Docker linux/amd64 `shu_asm`）✅**

| 项 | 说明 |
|----|------|
| WPO-S3 cross | `asm_ctx_local_reset` 同步 `asm_ctx_block_slot_reset`；dep/entry 模块 **block_ref 碰撞** 不再误跳过 `fill_local_slots`（`stack_promote_cross` exit 0→7） |
| DOD-S2 compile | `std/vec/mod.su` 多函数 **`if (0==0){…;return}`** 规避 stmt_order 末条赋值隐式尾返回（`vec_i32_with_capacity` 等） |
| P5 | `./tests/run-pre-push-p5.sh` 全绿（WPO-S3/S4、SIMD、DOD、refresh shu_asm）；**ZC-1** Docker **SKIP**（无 io_uring，GHA ubuntu 补 perf） |

**2026-06-05 DOD-S2/S3 P5 续跑（已闭合，见上）**

| 项 | 说明 |
|----|------|
| DOD-S2 parse | `vec3f_soa_smoke.su` 变量 `soa` → `v_soa`（避免 `TOKEN_SOA` 关键字冲突） |
| DOD-S3 parse | `soa_cross_lib.su` `let s: f32 = 0.0 as f32` → `0.0`（`as f32` 在 let 初值导致 dep 模块 funcs=0） |
| glue | 形参 `[N]T` 回填 type + CALL lea 传址时 load 指针槽；`pipeline_backend_asm_codegen_ast_to_elf_c` 各 dep co-emit 前 fill SoA |

**约束**：仅对 **counted loop + proven stride** 自动矢量；否则要求显式 `simd` 块（opt-in 安全）。

**验收**：`tests/bench/simd_dot.su` ≥ **0.90×** hand-written intrinsics C。

#### 4.2.2 面向数据设计（DOD / SoA）

| Sprint | 内容 |
|--------|------|
| **DOD-S1** ✅ | `struct Name soa { }` + `#[soa]` + `[N]T` 列主序 + `arr[i].field`；`run-dod-s1-gate.sh` + `run-perf-dod-soa.sh` | L1 miss ≤1%：**GHA** `SHU_DOD_SOA_REQUIRE_L1=1` 已接 CI |
| **DOD-S2** ✅ | `std.vec` **Vec3f_soa** 默认三列 SoA；**Vec3f_aos** opt-in；`run-dod-s2-gate.sh` | Linux `shu_asm` exit=3 + **sum exit=6** OK |
| **DOD-S3** ✅ | WPO 跨函数 layout 统一（`typeck_wpo_unify_soa_layouts`）；`run-dod-s3-gate.sh` | Linux `shu_asm` exit=3 OK |

**Cache 指标**：SoA 遍历 microbench L1 miss **≤ 1%**（`perf stat -e L1-dcache-load-misses`）。

#### 4.2.3 Cache Line 专项

| Sprint | 内容 |
|--------|------|
| **DOD-CL-S1** ✅ | struct 字段 **`align(N)`** + **`SHU_PAD_FIELDS=1`** 伪共享 warning；`run-dod-cl-s1-gate.sh` | Linux disasm tail@64 + exit=64 OK |
| **DOD-CL-S2** ✅ | **`std.heap` Arena64** + **`SHU_HOT_REORDER=1`** 热字段 hint；`run-dod-cl-s2-gate.sh` | Linux `shu_asm` exit=0 OK |

- 热路径 struct：**64B 对齐**；字段重排（hot 在前）。
- 编译器 `-pad-fields` 警告（`SHU_PAD_FIELDS=1`）：相邻 atomic 与 data 同 line。
- **`align(64)` 全局分配**：Arena chunk、ring slot、协程 runqueue。

### 4.3 极致轻量二进制与冷启动

| 机制 | 做法 | 目标 |
|------|------|------|
| **错误码** | `!T` = `{tag, payload}` 寄存器返回；**无 DWARF unwind** | panic 仅 frame pointer 链（可选 strip） |
| **符号表** | release strip + `.gnu.hash`；compiler 自举 **`-Wl,--gc-sections`** | B-SIZE ≤ 8MiB |
| **runtime** | 无 init array；TLS lazy；**单页 Arena** 默认分配 | B-BOOT ≤ 500µs |
| **链接** | 按需 `std` 模块；未引用 `io.o`/`net.o` 不链 | hello **≤ 40KiB** stripped |

---

## 5. 季度执行序（2026 Q3 – 2027 Q2）

| 优先级 | 方向 | 关键交付 |
|--------|------|----------|
| **P0** | Linux CI 实锤 L1/L2 | GHA `SHU_PERF_FAIL_ON_*` + **ZC gates CI step**；`ubuntu-zc-gates` Docker；median 写入 baseline |
| **P1** | ZC-1 Provided Buffers △ | 本地完成；`run-zc1-gate.sh` smoke+perf；`-10%` 待 **GHA ubuntu** 实锤后 △→✅ |
| **P1b** | B-BOOT 冷启动门禁 | `run-perf-coldstart.sh` + cap 8000µs ✅ |
| **P2** | A1–A4 ✅；async/await/spawn/CPS ✅ | B-ASYNC + yield + IO await 烟测 |
| **P3** | WPO-S0–S4 ✅；S3 await asm/yield ✅ | assign/index SU ✅；SIMD call 内联 M8-tail（`simd_vector_inline.su`）；**SIMD-S1–S4** ✅ |
| **P4** | DOD-S1/S2/S3/CL-S1/CL-S2 ✅；SIMD ✅ | **P5** `run-pre-push-p5.sh` / **ZC-1** △→✅（GHA `-10%`） |
| **P5** | M-3/M-4/ZC-1–5 ✅；**`run-zc-gates.sh`** | ZC-1 `-10%` 实锤；L1/L2 perf 全绿 |
| **P6** | S4 freestanding + B-BOOT/B-BOOT-FS | `run-freestanding-hello.sh` ✅；`run-perf-coldstart.sh` fs_* ✅（Linux shu_asm CI） |

---

## 6. 固定验收命令

```bash
# ── asm 计算门禁 ──
SHU=./compiler/shu_asm ./tests/run-asm-73-gate.sh

# ── P0 push 前一键 ──
SHU=./compiler/shu_asm ./tests/run-pre-push-p0.sh

# ── P5 push 前一键（M-3/M-4/M-5/ZC-3/WPO；Mac 跳过 refresh，Linux 含 SU 路径）──
./tests/run-pre-push-p5.sh
./tests/run-push-ready.sh
# Mac 复现 Linux P5 + refresh：
./scripts/docker-ci-local.sh ubuntu-gates
# Mac 复现 ZC-1→5（须 make clean 避免 Mach-O .o 混链；Mac Docker 无 io_uring → ZC-1 SKIP）：
./scripts/docker-ci-local.sh ubuntu-zc-gates
# Mac 复现 WPO-S2 asm fold/mono + perf compile-only：
./scripts/docker-ci-local.sh ubuntu-wpo-s2
# 已有 Linux shu_asm 时快速 WPO-S3 disasm：
./scripts/docker-ci-local.sh ubuntu-wpo-s3
# 从零 bootstrap + await/yield asm 实锤（较慢）：
./scripts/docker-ci-local.sh ubuntu-wpo-s3-full
# WPO-S3 占位（struct 按值返回 smoke；有 shu_asm 时跑 exit 7）：
./tests/run-wpo-s3-gate.sh
SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh
# WPO-S4：S0 text 代理 + S1/S2 SHU_WPO_PGO_HOT=1 用户 .o .text.hot + .text.unlikely + call-depth emit 序：
SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh
SHU_WPO_PGO_HOT=1 SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh
# Mac 从零复现 WPO-S4（linux/amd64 Docker）：
./scripts/docker-ci-local.sh ubuntu-wpo-s4-full
# SIMD-S1：`-target-cpu` + 宿主机 feature 探测（--print-target-cpu）：
./tests/run-simd-s1-gate.sh
SHU=./compiler/shu_asm ./tests/run-simd-s1-gate.sh
# SIMD-S2：std.simd Vec4f/Vec8i 编译 smoke：
./tests/run-simd-s2-gate.sh
SHU=./compiler/shu_asm ./tests/run-simd-s2-gate.sh
# SIMD-S3：硬件向量 add（x86 vpaddd/paddd；objdump 可选严格）：
./tests/run-simd-s3-gate.sh
SHU_SIMD_HW_STRICT=1 SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh
# ABI f32 xmm（默认 ON + release -O2；legacy：-legacy-f32-abi；见 compiler/docs/F32_XMM_ABI.md）：
SHU=./compiler/shu_asm ./tests/run-f32-xmm-gates.sh
# legacy 仅 CLI 烟测（已含于 run-f32-xmm-gates.sh / run-abi-f32-xmm-gate.sh）
# CLI：shu_asm -backend asm -O2 -L . -legacy-f32-abi app.su -o app
# SIMD-S4：shuffle/select + @shuffle/@select smoke：
./tests/run-simd-s4-gate.sh
SHU=./compiler/shu_asm ./tests/run-simd-s4-gate.sh
# SIMD-S4 验收：simd_dot.su ≥ 0.90× intrinsics C（Linux shu_asm）：
./tests/run-perf-simd-dot.sh
SHU_SIMD_DOT_FAIL=1 SHU=./compiler/shu_asm ./tests/run-perf-simd-dot.sh
# DOD-S1：struct soa / #[soa] + arr[i].field smoke：
./tests/run-dod-s1-gate.sh
SHU=./compiler/shu_asm ./tests/run-dod-s1-gate.sh
# DOD-S1 L1 miss：SoA vs AoS 列扫描（Linux + perf；GHA 已门禁 correctness）：
./tests/run-perf-dod-soa.sh
SHU_DOD_SOA_FAIL=1 SHU=./compiler/shu_asm ./tests/run-perf-dod-soa.sh
# GHA ubuntu 原生 perf 可用后启用 L1 硬门禁：
SHU_DOD_SOA_REQUIRE_L1=1 SHU_DOD_SOA_FAIL=1 SHU=./compiler/shu_asm ./tests/run-perf-dod-soa.sh
# DOD-S2：std.vec Vec3f_soa / Vec3f_aos smoke：
./tests/run-dod-s2-gate.sh
SHU=./compiler/shu_asm ./tests/run-dod-s2-gate.sh
# （xmm ABI 已含于 run-f32-xmm-gates.sh，勿重复单独跑除非调试）
# DOD-S3：WPO 跨模块 SoA layout 统一 + 跨函数 arr[i].field：
./tests/run-dod-s3-gate.sh
SHU=./compiler/shu_asm ./tests/run-dod-s3-gate.sh
# DOD-CL-S1：struct align(64) + SHU_PAD_FIELDS=1 伪共享 warning：
./tests/run-dod-cl-s1-gate.sh
SHU_PAD_FIELDS=1 SHU=./compiler/shu_asm ./tests/run-dod-cl-s1-gate.sh
# DOD-CL-S2：std.heap Arena64 + SHU_HOT_REORDER=1 热字段 hint：
./tests/run-dod-cl-s2-gate.sh
SHU_HOT_REORDER=1 SHU=./compiler/shu_asm ./tests/run-dod-cl-s2-gate.sh
# Mac 复现 ZC-1（无 io_uring 时 SKIP；真 Linux 或 GHA 跑 -10% 门禁）：
./scripts/docker-ci-local.sh ubuntu-net-zc1
# 或本机 Linux：
./tests/run-zc1-gate.sh --perf
# shu_asm 已有时快速 WPO-S2 perf（跳过 median）：
SHU=./compiler/shu_asm SHU_WPO_S2_COMPILE_ONLY=1 SHU_WPO_S2_LIMIT=100000 ./tests/run-perf-wpo-s2.sh --bench

# ── 自举 ──
make -C compiler bootstrap-driver-bstrict
make -C compiler bootstrap-verify
./tests/run-all-bstrict.sh
./tests/run-bootstrap-bstrict-ci.sh

# ── 性能：计算 / dogfood ──
SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench
SHU_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh

# ── P1 perf 门禁（Linux CI 对齐；io_uring 可用时含 ZC-1）──
./tests/run-perf-p1-gate.sh

# ── 零拷贝统一门禁（ZC-1→5；Mac 无 shu_asm 时 typeck-only SKIP）──
./tests/run-zc-gates.sh
SHU=./compiler/shu_asm ./tests/run-zc-gates.sh
# ZC-1 -10% 全量 perf（Linux io_uring；与 ci.yml Net perf 对齐）：
SHU=./compiler/shu_asm ./tests/run-zc-gates.sh --perf
# ZC-4 String 视图 + arena concat bench：
./tests/run-zc4-gate.sh
./tests/run-perf-string-arena.sh
# ZC-5 splice 管道（Linux strace 实锤）：
./tests/run-zc5-gate.sh
# ZC-5 io perf（含于 run-perf-io --bench，Linux only）：
SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench

# ── 零拷贝：Provided Buffers（ZC-1，Linux）──
./tests/run-zc1-gate.sh
./tests/run-provided-buffers.sh
SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench
# 可选：provided echo 须比同次 batch 中位数快 ≥10%（Linux io_uring）
SHU_PERF_FAIL_ON_NET_REGRESSION=1 SHU_PERF_FAIL_ON_ZC1=1 ./tests/run-perf-net.sh --bench

# ── Windows IOCP（IO-A6，MSYS2）──
./tests/run-iocp-gate.sh
./tests/run-iocp-gate.sh --perf
./tests/run-perf-iocp.sh --bench

# ── parser/typeck/codegen .su → gen.c → .o（跨平台，M-3 前置）──
./tests/run-migrate-su-gen-gate.sh

# ── parser/lexer .su → shu_asm 对齐（Linux）──
./tests/run-refresh-shu-asm-gate.sh

# ── M-3 slice 域 typeck 原型 ──
./tests/run-typeck-region.sh

# ── M-4 Linear(T) move 原型 ──
./tests/run-typeck-linear.sh

# ── M-5 read_ptr_slice 运行时 + slice 字段 codegen ──
./tests/run-io-read-ptr-slice.sh

# ── ZC-2 read_ptr 绝对视图（gen + mmap + ReadPtrView）──
./tests/run-zc2-gate.sh
SHU=./compiler/shu_asm ./tests/run-zc2-gate.sh

# ── ZC-3 编译期 slice 域 + 数组→slice smoke ──
./tests/run-zc3-gate.sh
SHU=./compiler/shu_asm ./tests/run-zc3-gate.sh
# 分项（与 run-zc3-gate.sh 等价子集）：
./tests/run-typeck-region.sh
./tests/run-slice-field.sh
./tests/run-io-read-ptr-slice.sh
./tests/run-stdlib-import.sh

# ── S2 typeck.o 门禁（P3）──
./tests/run-s2-typeck-gate.sh
SHU_S2_REQUIRE_TYPECK_O=1 SHU_S2_FAIL_ON_REGRESSION=1 ./tests/run-s2-typeck-gate.sh
# EMIT_HEAVY 第二遍 + 同步 build_asm/typeck.o
./tests/run-s2-typeck-emit-heavy.sh
SHU_S2_FAIL_ON_EMIT_HEAVY=1 ./tests/run-s2-typeck-emit-heavy.sh
# strict_glue 重链后可用同一烟测（parser_su.o 链时跳过 parser_asm_link_alias）
SHU_S2_EMIT_HEAVY_COMPILER=./compiler/shu_asm.strict_glue ./tests/run-s2-typeck-emit-heavy.sh
./tests/run-s2-typeck-sync-build-o.sh
SHU_S2_FAIL_ON_PARITY=1 ./tests/run-s2-typeck-o-parity.sh

# ── S3 pipeline.o 门禁（P3）──
./tests/run-s3-pipeline-gate.sh
SHU_S3_FAIL_ON_EMIT_HEAVY=1 ./tests/run-s3-pipeline-emit-heavy.sh
./tests/run-s3-pipeline-sync-build-o.sh
SHU_S3_FAIL_ON_REGRESSION=1 ./tests/run-s3-pipeline-gate.sh

# ── S3 driver argv 门禁（P3）──
./tests/run-s3-driver-gate.sh
SHU_S3_DRIVER_REQUIRE_COMPILE_O=1 ./tests/run-s3-driver-gate.sh
SHU_S3_FAIL_ON_EMIT_HEAVY=1 ./tests/run-s3-driver-emit-heavy.sh
./tests/run-s3-driver-sync-build-o.sh
SHU_S3_FAIL_ON_REGRESSION=1 ./tests/run-s3-driver-gate.sh
SHU_S3_FAIL_ON_PARITY=1 ./tests/run-s3-driver-o-parity.sh
# strict 链 asm driver 替换：sync 后 STRICT_LINK_BUILD_ASM_DRIVER=1 relink
# 已修（2026-06-02）：parse_argv loop+glue；bootstrap-driver-bstrict ✅；verify-selfhost-stage2-bstrict ✅

# ── Stage2 B-strict（shu_asm → shu_asm2）──
# cd compiler && sh ./verify-selfhost-stage2-bstrict.sh
# 或：make -C compiler bootstrap-verify-stage2-bstrict

# ── S2/S3 里程碑：S2 **67880B/130**；S3a pipeline **11588B/38**；S3b driver **6008B/18** ──

# ── WPO-S1：call graph + dead export 分析（P3）──
./tests/run-wpo-s1.sh
./tests/run-wpo-compiler-self.sh
./tests/run-wpo-dce-emit.sh
./tests/run-wpo-dce-asm.sh
SHU=./compiler/shu_asm ./tests/run-perf-wpo-dce-text.sh
SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_DCE_TEXT=1 ./tests/run-perf-wpo-dce-text.sh
./tests/run-perf-wpo-dce-compiler-self-text.sh
SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_COMPILER_SELF_TEXT=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh
SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shu-asm-text.sh
./tests/run-wpo-build-asm-chain-gate.sh
SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh
./tests/ensure-wpo-build-asm-artifacts.sh
./tests/run-wpo-main-o-gate.sh compiler/build_asm/main.o
./tests/run-wpo-driver-o-gate.sh compiler/build_asm/driver_compile.o
./tests/run-wpo-pipeline-o-gate.sh compiler/build_asm/pipeline_wpo.o
./tests/run-wpo-typeck-o-gate.sh compiler/build_asm/typeck_wpo.o
./tests/run-wpo-backend-o-gate.sh compiler/build_asm/backend_wpo.o
./tests/run-wpo-s2.sh
SHU_WPO_DUMP_CALLGRAPH=/tmp/wpo.json ./compiler/shu-c check tests/wpo/dead_fn.su
perl compiler/scripts/wpo_dce.pl /tmp/wpo.json --expect-dead dead_helper

# ── WPO-S2（常量 call fold + bench）──
./tests/run-wpo-s2.sh
SHU=./compiler/shu_asm ./tests/run-perf-wpo-s2.sh --bench
SHU_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHU=./compiler/shu_asm ./tests/run-perf-wpo-s2.sh --bench

# ── 协作调度 / B-ASYNC（P2 A1/A2）──
./tests/run-async.sh
./tests/run-perf-async.sh --bench
SHU_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench

# ── S4 freestanding 烟测（return42 / panic_div / hello，按需 io/panic）──
./tests/run-freestanding-hello.sh
# docker-distro / CI：bootstrap-verify 后须 SHU=shu_asm（C-only seed shu 无 -backend asm）
SHU=./compiler/shu_asm ./tests/run-freestanding-hello.sh

# ── 性能：冷启动（B-BOOT / B-BOOT-FS）──
./tests/run-perf-coldstart.sh --bench
SHU_COLDSTART_STD_ONLY=1 SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=1 ./tests/run-perf-coldstart.sh --bench
SHU=./compiler/shu_asm SHU_COLDSTART_FREESTANDING_ONLY=1 SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=1 ./tests/run-perf-coldstart.sh --bench

# ── 性能：I/O / 网络 / 零拷贝 ──
SHU_PERF_FAIL_ON_IO_ZIG=1 SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench
SHU_PERF_FAIL_ON_NET_REGRESSION=1 ./tests/run-perf-net.sh --bench
./tests/run-perf-io-ring-ab.sh
```

---

## 7. 风险与纪律（须跟踪）

- `shu_asm -o` 偶发 SIGSEGV → `SHU_SKIP_PARSE_SMOKE=1`（见 SELFHOST.md §4.1）。
- 改 `parser.su` / `typeck.su` / `codegen.su` / `ast.su` 后须 `make relink-shu` + `refresh-shu-asm-gate`（Linux：`./tests/run-refresh-shu-asm-gate.sh` 含 SU region 烟测；CI 门禁）。
- **C glue 与 `AsmFuncCtx` 字段一一对应**；emit 薄包装禁止与 slow 路径互递归。
- WPO / async 变换 **不得**引入默认 runtime 分配；bench 回归即回滚。
- 宣称「超越 C/Zig」仅当 **§1.2 对应 bench + CI 门禁** 绿时标记 ✅。

---

## 8. 文档维护

- 新任务挂 **§2–§4** 对应代号；完成 ⬜ → ✅ 并附 bench 数字。
- 基线更新：`SHU_PERF_UPDATE_BASELINE=1` / `SHU_PERF_UPDATE_NET_BASELINE=1`。
- 自举细节：`compiler/docs/SELFHOST.md`；asm 能力：`compiler/src/asm/README.md`。
- 历史 M2–M11、P0–P4 勾选表见 git 历史（2026-05 归档）。
