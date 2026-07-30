# C → .X 迁移追踪（自举全程待办地图）

> **创建**：2026-07-29（wave710 tip L4 钉盘 `53fd80927` 双端 129 全绿后）  
> **审计补全**：2026-07-29（对照仓库实况：非 gen 产品 C / 零 cc 三义 / G-05·build.x 半路径 / Makefile 删除关键路径）  
> **终局目标**（wave713 升级 · **用户硬指标**）：**去掉 Makefile** 为主闸门，并收口 **零 cc/gcc/clang + v2==v3**。  
>   即：日常与冷启动编排 **不再依赖 `make` / `compiler/Makefile` / 顶层 `Makefile`**；编译器自举链与产品默认路径 **不再 exec 外部 C 编译器**。  
> **用途**：全面列出 C 逻辑迁移到 .X 的所有步骤，按自举顺序排列。每完成一步打勾。已完成的打 ✅，未完成的打 ⬜，部分完成打 🟡。  
> **路线**：路线 A（纯 .x + 内建能力重写）— 详见「路线选择」章节。  
> **方法**：[自举方法.md](自举方法.md)（Cap / R / L / M）+ Track L2（语言能力）+ Track X（xbuild）+ Track C0（冷启动零 cc）+ Track MG（Makefile 退役）  
> **进度数字**：[自举进度.md](自举进度.md) · skill `xlang-selfhost-product-gate` · Makefile 映射：[Makefile迁移表.md](Makefile迁移表.md)  
> **先→后时序（换 IDE）**：[自举时序.md](自举时序.md)（执行序 S0–S8；与本文阶段号对照见时序 §5）  
> **维护约定**：本文只维护 **待办勾选 / 状态表 / 债地图**；**波次变更记录只写 [自举进度.md](自举进度.md)**（禁止在本文追加 changelog 段）。  
> **权威钉盘**（与本文附录 C 同步）：**`53fd80927`**（wave710）。

---

## 0. 总览仪表盘

| 维度 | 状态 | 数据 |
|------|------|------|
| **库层（std+core）.x 化** | ✅ 100% | 178 文件 / 75,007 行 .x · 0 行 .c |
| **Thin 退役（T）** | ✅ 18/18 | 18 号结案 |
| **Prove 注册（N）** | ✅ 111/111 IDENTICAL | MODULES 数组实际 128 条（17 条后期新增未计入 KPI） |
| **R2 真迁退役** | 🟡 ~85% | 128 prove 模块中 ~120 已 R2；Cap residual 待消灭 ~8 模块 |
| **Mega 拆分（M1-M3）** | ✅ 3/3 mega 拆分完成 | runtime 24/24 · parser 21/21 · link_abi 11/11 切片 |
| **Mega 去 pin（M4）** | ⬜ 0/5 | runtime / parser / link_abi + **typeck / codegen** 前端 pin 均未关（见阶段 7.4） |
| **Pinned gen.c 退役** | 🟡 8/30 | Track L 退役 8 个；仍 pinned 22 个（前端核心 + 工具链 + 测试） |
| **非 gen 产品 C（glue/ast 池）** | ⬜ 0/~10 | **`pipeline_glue.c` ~40k + `ast_pool.c` ~18k** 等；阶段 8.3（**删 Makefile 前最大体积债**） |
| **Cap 能力解锁** | 🟡 持续 | 已闭多波；untyped self 待治；LANG-006 保留 |
| **产品 L4 放行** | ✅ 钉盘 `53fd80927` | 双端 L4 真冷 + 129 bstrict |
| **Cap residual 边界消灭** | ⬜ 0/~50 | 原「永久边界」降级为「必须消灭」；按路线 A 逐个消灭 |
| **语言能力补齐（L2）** | ⬜ 0/~20 | syscall/FFI/inline asm/fnptr/va_list/线程原语 全部待补 |
| **Makefile 退役 / xbuild** | 🟡 半路径 | **`./xbuild`→`xlang-build.sh`** 产品入口；根 Makefile **help-only**；叶/组合体→`compiler/mk/*.mk`；**`compiler/Makefile` 仍 ~3445 行权威图**（阶段 11） |
| **根脚本 / tools / docker / CI 去 make+cc** | 🟡 部分 | **11.2.5/11.4.3 ✅** · **11.2.3 ✅** tests/** hub · **11.1.6 🟡** g05+…+archaeology-gen → xbuild · **11.1.5 🟡** build.x · **11.1.1 🟡** BUILD_DAG 库存 · **11.1.2 🟡** schedule dry-run/run · **11.1.3/4 🟡** 平台+链接策略（wave745）· **11.3 🟡** prereq 边 shell（wave744）· **11.3.1 路径 🟡** 叶 pattern residual（wave746–868 · **非**物理删；**逐行清单见下 §11.3.1**） · **11.4.1 ✅** `build.sh`→xbuild · **11.4.6 ✅** delete-one→xbuild · **11.4.5 🟡** Docker 入口文档（包 residual 至 12）；零 cc 仍 ⬜ |
| **tests/ 对照 C 处理策略** | 🟡 4/4 策略 | 11.5.1–4 **策略已裁定**（wave734/741 · `tests/HOST_CC_POLICY.md`）；改写 .x / 卸 cc 属阶段 12 |
| **冷启动零 cc 链** | ⬜ 0/4 | 最小 seed + 零 cc 验证 + 双端冷启动 |
| **终局：无 Makefile + 零 cc + v2==v3** | ⬜ 未达 | 见 §0.1 三义；阶段 13 |

### 0.1 终局三义（禁止混谈「零 cc」）

去掉 Makefile 与「零 cc」常被混为一谈。**自举终局须同时满足下列三层**（缺一层仍不能宣称终局）：

| 层 | 含义 | 今日状态 | 失败时的假绿 |
|----|------|----------|--------------|
| **MG · 编排层** | 不依赖 `make` / `compiler/Makefile` / 顶层 `Makefile` 完成 build / L4 / bootstrap | 🟡 日常可走 `xlang-build.sh`→g05 shell；冷启动/依赖图/`*.o` 规则仍大量在 Makefile | 只删入口 Makefile、实现层仍 `make -C compiler` |
| **BC · 自举编译层** | 编译器自身 TU **不**再被 host `cc/gcc/clang` 编译（.x→纯 asm `.o` 或等价） | ⬜ 大量 pin `*_gen.c` / glue / seed 仍 `$(CC) -c` | seed 用 xlang `-E` 出 C 再交给 gcc |
| **PC · 产品默认后端** | 用户程序默认 **`-backend asm`**（或纯自研目标）；**不**默认 emit C 再 `exec` host-cc；`labi_invoke_cc*` 退役或仅 opt-in | ⬜ `-backend c` 与 labi invoke_cc 仍在产品面 | 自举绿但用户 `-o` 仍调 gcc |

> **用户主目标对齐**：以 **去掉 Makefile（MG）** 为终局叙事主闸门；MG 物理删除的**前置**是 BC 足够小（glue/gen 可被 xbuild 用 xlang 编）且编排逻辑迁到 xbuild / g05 已覆盖的 shell·.x。  
> **禁止**：只完成 MG 包装层、底层仍 `make`；或只宣称 v2==v3 而 Makefile 仍是冷启动权威。

### 0.2 删 Makefile 关键路径（依赖 DAG · 顺序不可跳）

```text
[阶段 10 语言能力 L2] ──► [阶段 9 residual 消灭] ──┐
                                                    ├─► [阶段 8.3 glue/ast 池 .x 化]
[阶段 7 M4 mega 去 pin] ──► [阶段 8 gen.c 退役] ───┤
                                                    ├─► [阶段 11.0–11.2 xbuild 吃掉 Makefile 规则]
[现有 G-05 / build.x / xlang-build.sh] ────────────┘
                                                    │
                                                    ▼
                              [11.3 物理删 Makefile] + [12 冷启动零 cc] + [13 v2==v3]
```

| 顺序陷阱 | 说明 |
|----------|------|
| 先删 Makefile、glue 仍 40k C | xbuild 只能 `cc -c pipeline_glue.c` → **BC 未满足** |
| 先写满 xbuild、仍 pin seed | 编排绿但双权威 / 冷启动仍读 `*_gen.c` |
| 只迁顶层 Makefile | 根 `Makefile` 已是薄包装；**真正权威在 `compiler/Makefile`** |
| 忽略 tests/CI `make` | 产品入口无 make，gate 脚本仍 make → 终局叙事假绿 |

---

## 阶段 0：基建与方法论（已完成）

✅ **0.1 自举方法论确立**（Cap/R/L/M 四轨）2026-07-14

✅ **0.2 工程轨 vs 产品轨分清**（禁止工程轨绿当自举完成）2026-07-15

✅ **0.3 日常真测 vs 真冷全测节奏**（L2/L3 日常 · L4 整波收口）2026-07-16

✅ **0.4 双端验证纪律**（macOS 开发 + Ubuntu 金标）

✅ **0.5 git 锚点机制**（每波前建 tag，可秒级回退）

✅ **0.6 产品闸门 skill**（`xlang-selfhost-product-gate`）


---

## 阶段 1：库层 .X 化（已完成 · 100%）

### 1.1 std/ 标准库

✅ **1.1.1 std/ 全目录 .x 化** 166 文件 / 72,941 行 .x · 0 行 .c

✅ **1.1.2 std/io/**

✅ **1.1.3 std/fmt/**

✅ **1.1.4 std/string/**

✅ **1.1.5 std/sync/**

✅ **1.1.6 std/result/**

✅ **1.1.7 std/option/**

✅ **1.1.8 std/crypto/**

✅ **1.1.9 std/net/**

✅ **1.1.10 std/其余子目录**


### 1.2 core/ 核心库

✅ **1.2.1 core/ 全目录 .x 化** 12 文件 / 2,066 行 .x · 0 行 .c

✅ **1.2.2 core/fmt**

✅ **1.2.3 core/result**

✅ **1.2.4 core/其余**


---

## 阶段 2：Thin 退役 Track T（已完成 · 18/18）

> **定义**：hybrid 模块 thin 切片 prove IDENTICAL，构建切换至 thin.x。
> **结案**：18/18 ✅

✅ **2.1 T-001 ~ T-018 全部 thin 退役** 18 号结案

✅ **2.2 T 降为维护指标**（不占前排）


---

## 阶段 3：Prove 注册 Track N（已完成 · 111/111）

> **定义**：prove_module_selfhost.sh nm IDENTICAL 验证。
> **KPI**：N=111/111 IDENTICAL ✅（28 日 wave539–575 扩至）
> **注意**：MODULES 数组实际 128 条；17 条后期新增未计入 KPI。

### 3.1 driver 组（11 条）

✅ **3.1.1 fmt** Track L 退役

✅ **3.1.2 check** Track L 退役（archaeology）

✅ **3.1.3 test** Track L 退役（archaeology）

✅ **3.1.4 build** Track L 退役（archaeology）

✅ **3.1.5 run** Track L 退役（archaeology）

✅ **3.1.6 compile** R2 真迁（Track L 退役）

✅ **3.1.7 emit** R2 真迁（Track L 退役）

✅ **3.1.8 lsp_io_std_heap** Track L 退役叶子

✅ **3.1.9 target_cpu_flags** R2 DIRECT（wave559）

✅ **3.1.10 fmt_check_cmd** R2 mixed（wave565）

✅ **3.1.11 fmt_check** R2 thin + Cap residual pure 深迁


### 3.2 lexer 组（1 条）

✅ **3.2.1 token** prove 锁 nm 面


### 3.3 lsp 组（4 条）

✅ **3.3.1 lsp_diag_pipeline_sizes**

✅ **3.3.2 lsp_diag_stubs_no_c** R2 DIRECT（wave557）

✅ **3.3.3 lsp_diag_pipeline_ctx** R2 thin+rest（wave561）

✅ **3.3.4 lsp_io_std_heap**（见 driver 组）


### 3.4 runtime 组 — labi_* 切片（12 条，link_abi mega）

✅ **3.4.1 labi_path_pure** R2 full（L0）

✅ **3.4.2 labi_diag_pure** R2 full（L1）

✅ **3.4.3 labi_host_lit** R2 full（L2）

✅ **3.4.4 labi_path_io** R2 full（L3 · Cap: stat/realpath 🔒）

✅ **3.4.5 labi_ensure_list** R2 full（L4）

✅ **3.4.6 labi_invoke_cc_list** R2 full（L5 · Cap: getenv 🔒）

✅ **3.4.7 labi_invoke_ld_list** R2 full（L6 · Cap: spawn/ld 🔒）

✅ **3.4.8 labi_freestanding_list** R2 full（L7）

✅ **3.4.9 labi_std_list** R2 full（L8）

✅ **3.4.10 labi_ondemand_list** R2 full（L8b）

✅ **3.4.11 labi_ondemand_heavy** R2 full（L8b heavy）

✅ **3.4.12 labi_gates** R2 full（L9）


### 3.5 runtime 组 — rt_* 切片（23 条，runtime mega）

✅ **3.5.1 rt_dispatch_thin** R2 thin+rest（wave561）

✅ **3.5.2 rt_dispatch_impl** R2 full

✅ **3.5.3 rt_asm_stub** R2 full

✅ **3.5.4 rt_fmt_one** R2 full

✅ **3.5.5 rt_pipeline_elf_diag** R2 full

✅ **3.5.6 rt_run_x_emit** R2 full

✅ **3.5.7 rt_parse_diag** R2 full

✅ **3.5.8 rt_diag_errno** R2 full

✅ **3.5.9 rt_fs_open** R2 full

✅ **3.5.10 rt_arena_buf** R2 full（Cap-global-bss 🔒）

✅ **3.5.11 rt_preamble** R2 full（Cap-giant-string 🔒）

✅ **3.5.12 rt_stack** R2 full（Cap-fn-ptr 🔒）

✅ **3.5.13 rt_lib_root** R2 full

✅ **3.5.14 rt_emit_flags** R2 full

✅ **3.5.15 rt_emit_state** R2 full（Cap-global-bss 🔒）

✅ **3.5.16 rt_content** R2 full

✅ **3.5.17 rt_util** R2 full

✅ **3.5.18 rt_argv** R2 full

✅ **3.5.19 rt_entry** R2 full

✅ **3.5.20 rt_compile** R2 full

✅ **3.5.21 rt_run_exec** R2 full

✅ **3.5.22 rt_run_asm_backend** R2 full

✅ **3.5.23 rt_run_compiler_parsed** R2 full


### 3.6 asm 组 — runtime_* 切片（41 条，asm OS 桥）

✅ **3.6.1 runtime_time_os** R2 thin+rest（Cap: clock_gettime 🔒）

✅ **3.6.2 runtime_path_fast** R2 DIRECT

✅ **3.6.3 runtime_dynlib_os** R2 thin+rest（Cap: dlopen 🔒）

✅ **3.6.4 runtime_panic** R2 thin+rest

✅ **3.6.5 runtime_panic_arm64** R2 thin+rest

✅ **3.6.6 runtime_process_argv** R2 thin+rest

✅ **3.6.7 runtime_test_fn_invoke** R2 thin+rest（Cap: fnptr 🔒）

✅ **3.6.8 runtime_net_workers** R2 thin+rest（Cap: fnptr 🔒）

✅ **3.6.9 runtime_compress_zlib_glue** R2 thin+rest（Cap: zlib.h 🔒）

✅ **3.6.10 runtime_arrow_simd_glue** R2 thin+rest（Cap: SIMD 🔒）

✅ **3.6.11 runtime_random_fill** R2 thin+rest wave544（Cap: getrandom 🔒）

✅ **3.6.12 runtime_tls_mbedtls_bio** R2 thin+rest wave544（Cap: mbedtls 🔒）

✅ **3.6.13 runtime_ed25519_ref10_glue** R2 thin+rest wave544（Cap: .inc 宏 🔒）

✅ **3.6.14 runtime_net_udp_batch** R2 thin+rest wave545

✅ **3.6.15 runtime_net_sock_fast** R2 thin+rest wave545

✅ **3.6.16 runtime_net_dns_fast** R2 thin+rest wave545（Cap: getaddrinfo 🔒）

✅ **3.6.17 runtime_net_ipv6_fast** R2 thin+rest wave545

✅ **3.6.18 runtime_net_addr_fast** R2 thin+rest wave546

✅ **3.6.19 runtime_slice_glue** R2 DIRECT wave546

✅ **3.6.20 runtime_crypto_inc_glue** R2 thin+rest wave547

✅ **3.6.21 runtime_sync_lock_diag_tls** R2 mixed wave547

✅ **3.6.22 runtime_std_runtime_fast** R2 DIRECT wave548

✅ **3.6.23 runtime_atomic_glue** R2 thin+rest wave548（Cap: stdatomic 🔒）

✅ **3.6.24 runtime_asm_build** R2 thin wave549（Cap: char** argv 🔒）

✅ **3.6.25 runtime_asm_io_stubs** R2 thin+rest wave549（Cap: syscall 🔒）

✅ **3.6.26 runtime_string_fast** R2 DIRECT wave549

✅ **3.6.27 runtime_net_io_batch_fast** R2 thin+rest wave550

✅ **3.6.28 runtime_env_os** R2 thin+rest wave550（Cap: getenv 🔒）

✅ **3.6.29 runtime_http_glue** R2 mixed wave551

✅ **3.6.30 runtime_queue_contention** R2 mixed wave551（Cap: pthread 🔒）

✅ **3.6.31 runtime_backtrace_platform** R2 thin+rest wave552（Cap: execinfo 🔒）

✅ **3.6.32 runtime_sync_os** R2 thin+rest wave552（Cap: pthread 🔒）

✅ **3.6.33 runtime_channel_glue** R2 thin+rest wave553（Cap: pthread 🔒）

✅ **3.6.34 runtime_log_os** R2 mixed wave553（Cap: write 🔒）

✅ **3.6.35 runtime_scheduler_glue** R2 mixed wave554

✅ **3.6.36 runtime_process_os_glue** R2 thin+rest wave554（Cap: execve 🔒）

✅ **3.6.37 runtime_thread_glue** R2 thin+rest wave555（Cap: pthread 🔒）

✅ **3.6.38 runtime_math_libm** R2 mixed wave564（Cap: libm 🔒）

✅ **3.6.39 runtime_lsp_glue** R2 mixed wave566

✅ **3.6.40 runtime_kv_mmap_glue**（未在 prove 注册）

✅ **3.6.41 runtime_ast_glue / runtime_lexer_glue / runtime_sqlite_glue**（未在 prove 注册）


### 3.7 asm 组 — backend/simd/parser 切片

✅ **3.7.1 asm_backend_compat_stubs** R2 DIRECT wave555

✅ **3.7.2 bootstrap_nostdlib_stubs** R2 mixed wave556

✅ **3.7.3 backend_seed_mega_fallback** R2 DIRECT wave556

✅ **3.7.4 parser_asm_parse_expr_link** R2 thin+rest wave557

✅ **3.7.5 user_asm_seed_bridge** R2 mixed wave558

✅ **3.7.6 parser_asm_thin_c** R2 mixed wave560

✅ **3.7.7 simd_loop_thin** R2 mixed wave563

✅ **3.7.8 simd_enc_thin** R2 mixed wave568

✅ **3.7.9 simd_loop** R2 full

✅ **3.7.10 simd_enc** R2 full

✅ **3.7.11 backend_enc_dispatch_thin** R2 thin full wave574

✅ **3.7.12 backend_enc_dispatch** R2 full

✅ **3.7.13 backend_arch_emit_dispatch_thin** R2 mixed wave567

✅ **3.7.14 backend_arch_emit_dispatch** R2 full

✅ **3.7.15 backend_try_inline_dispatch_thin** R2 mixed wave566

✅ **3.7.16 backend_try_inline_dispatch** R2 full

✅ **3.7.17 backend_call_dispatch_thin** R2 mixed wave567

✅ **3.7.18 backend_call_dispatch** R2 full

✅ **3.7.19 backend_x86_64_enc_c** R2 mixed wave570

✅ **3.7.20 async_asm_pool** R2 full


### 3.8 src 根组（15 条）

✅ **3.8.1 runtime_io_abi** R2 full（Cap: mmap/fstat 🔒）

✅ **3.8.2 runtime_driver_diagnostic_thin** R2 thin + Cap residual pure

✅ **3.8.3 runtime_driver_abi_thin** R2 thin + pure 深迁

✅ **3.8.4 runtime_driver_strict_glue_stubs** R2 mixed wave560

✅ **3.8.5 runtime_driver_strict_glue_thin** R2 mixed wave568

✅ **3.8.6 runtime_driver_abi** R2 mixed wave569

✅ **3.8.7 diag_thin** R2 mixed wave569

✅ **3.8.8 diag** R2 mixed wave571

✅ **3.8.9 runtime** R2 mixed wave572（mega 主名）

✅ **3.8.10 runtime_link_abi** R2 mixed wave573（mega 主名）

✅ **3.8.11 runtime_pipeline_abi** R2 full wave575

✅ **3.8.12 runtime_heap_user** R2 DIRECT wave559

✅ **3.8.13 build_runtime** R2 thin+rest wave558

✅ **3.8.14 x_seed_bridge** R2 mixed wave562

✅ **3.8.15 seed_link_compat** R2 mixed wave562


### 3.9 async 组（2 条）

✅ **3.9.1 async_liveness** R2 pure + Cap residual pure

✅ **3.9.2 async_cps_codegen** R2 pure + Cap residual pure


---

## 阶段 4：Cap 能力解锁 Track Cap（进行中）

> **定义**：一类语言/编译器能力缺口，阻塞 ≥2 模块真迁。一次修，多 rest 可真迁。

### 4.1 已闭合的 Cap 波次

✅ **4.1.1 Cap-empty-str**（空串字面量 typeck/codegen）

✅ **4.1.2 Cap-string-pool**（串池 >64 封顶）

✅ **4.1.3 Cap-global-bss**（u8[N] 全局/static BSS）

✅ **4.1.4 Cap-va-reportf**（reportf / va_list **深路径子集**已闭）wave6 — **注意**：完整 va_list 语言能力仍见阶段 **10.7**；libc `vsnprintf` 桥仍见 **9.5.3/9.5.4**

✅ **4.1.5 Cap-regen-sync**（.x 改了 pin/patch 未同源）

✅ **4.1.6 Cap-fn-ptr**（函数指针类型表达）部分（driver_run_stack_esc_gate 仍 🔒）

✅ **4.1.7 Cap-giant-string**（巨型字串数据）rt_preamble

✅ **4.1.8 wave668 fs lit-left ptr cmp**（freestanding null==p / 0==p 假绿）wave669

✅ **4.1.9 wave677 bool→i32 算术提升**（binop/unary 假绿）wave677

✅ **4.1.10 wave311 i32→u64 widen**（true widen hole）

✅ **4.1.11 wave311 i32→u8 窄存储**（var init/assign/return）wave712 验证已闭

✅ **4.1.12 wave421 impl Trait for T 缺方法**（false-green）wave421

✅ **4.1.13 wave450 零值参泛型 mono**（phantom T）wave450

✅ **4.1.14 wave459 host-C aggregate as cast**（compound literal / GNU stmt-expr）wave459-462

✅ **4.1.15 wave406 dual same-call 形参别名**（callee 静态 __xlang_al）wave406

✅ **4.1.16 wave284 标识符 >63 字节 honest-fail**（sticky overflow）wave284

✅ **4.1.17 wave707-709 match struct 模式链**（field bind + lit guard + wildcard + 显式 guard）wave710 tip L4

✅ **4.1.18 wave711 freestanding match field bind**（fs asm backend 4-arm 全组合）wave711 验证已闭

✅ **4.1.19 wave698 host-C 八层 scalar / 七层 NAMED fat**（nested slice 布局）wave698

✅ **4.1.20 wave677 LANG-007 unsafe block 诊断**（*T 解引用 + extern 调用须 unsafe）


### 4.2 当前前排 Cap 待办

⬜ **4.2.1 untyped `self` 形参 skip** **下一硬叶候选**

  - 症状：无类型标注的 `self` 形参（`fn m(self) {...}`）被 typeck/parser skip，未硬失败
  - LANG-006 标量 bool→int 保留不动（不当糊绿目标）
  - 日常 L2 推进

⬜ **4.2.2 trait bounds / dyn Trait soft**

  - 症状：wave421 闭 missing-method，但 trait bounds 与 dyn Trait 仍 soft
  - typeck 不硬失败，留作后续收口

⬜ **4.2.3 八层+ nested slice fat 布局 / 深 lit typeck** soft

  - wave698 闭 8 层 scalar / 7 层 NAMED；更深仍 soft

⬜ **4.2.4 bare `unit_t()` 无 turbofish + 零参 T subst** leave-off

  - typeck 仍要求类型参数；零参 body/return T 替换无存储 type-arg refs

⬜ **4.2.5 多 T 组合共享 bare link name** leave-off

  - 不同 T 组合（`unit_t<A>()` vs `unit_t<B>()`）共用一个 C 函数

⬜ **4.2.6 泛型方法 let-binding 接收者推断** deferred

  - `y.dup()` 而非 `x.clone()` 的类型推断需 let-scan fallback
  - deferred to wave446，但 wave446 闭的是 parser 角列表，此项未见关闭

⬜ **4.2.7 TYPE_SLICE call-arg 真递归 / 无堆重入 last-wins** soft

  - wave406 闭 dual same-call；超出范围仍 last-wins 于静态 temp

⬜ **4.2.8 AST name 槽 128 字节 layout raise** leave-off

  - wave284 honest-fail 已绿；布局升维（fixed name[128] → 可变长度）仍 leave-off

⬜ **4.2.9 LANG-006 标量 bool→int 保留** **有意保留 soft**

  - `let x: i32 = true` 仍合法；显式保留的语言契约，非 bug

⬜ **4.2.10 `take(W.xs)` f32[2]→[]f32 fs CG002** 疑似已闭待核查

  - 来源：wave648 soft · wave649 探针含「f32 host+fs=42」
  - 疑似已被 wave649 关闭，但文档未明确标记关闭

⬜ **4.2.11 `i64[]` call-arg fs** 疑似已闭待核查

  - 来源：wave619 soft · wave622 探针含「pure+fs i64 idx1=32·sum=42」
  - 疑似已被 wave622 关闭，但文档未明确标记关闭

⬜ **4.2.12 fs multi-method mangle** 疑似已闭待核查

  - 来源：wave681/682 soft · wave683 修了 freestanding multi-method bare `get` UNDEF
  - 其后 soft 不再列此项，疑似关闭

⬜ **4.2.13 dup_func first-wins** 疑似已闭待核查

  - 来源：wave679/680 soft · wave681 修了有参 redef
  - 其后 soft 不再列此项，疑似关闭

⬜ **4.2.14 bare type-param field** 疑似已闭待核查

  - 来源：wave683 soft · wave684 探针「t/s/w_nope T001」疑似关闭
  - field_unknown 硬失败，但未明确标记关闭

⬜ **4.2.15 impl method on INDEX** soft 未闭

  - 来源：wave635 soft 项
  - 症状：在 INDEX 表达式（如 `a[i]`）上调用 impl method 的能力缺口
  - wave636/637 修的是 PTR-to-fixed-array DEREF / array-of-ptr INDEX esz，未涉及 impl method on INDEX
  - 未在任何后续波次（wave636–712）中明确关闭

⬜ **4.2.16 `*T[N]` 解析序** **有意保留 soft**（设计决策）

  - 来源：wave635 soft + wave636 描述
  - 决策：`*T[N]` = array-of-pointers（C 式故意）；pointer-to-array 写 `*[N]T`
  - 类似 4.2.9 LANG-006，属显式保留的语言契约，非 bug

⬜ **4.2.17 `fixed return S24[2]` fx=11** 疑似已闭待核查

  - 来源：wave632 soft 项
  - 症状：fixed TYPE_ARRAY 的 return 路径（`return S24[2]`）仍 soft
  - wave633 修的是 let 路径（let from CALL/VAR bulk），探针含 "fx" 但未明确包含 return 路径
  - 疑似由 wave633 fx 探针间接覆盖，但文档未明确标记关闭

⬜ **4.2.18 未知 arg_ty soft-skip（param_raw≤0 路径）** 待确认

  - 来源：wave673 描述 + wave660–673 soft 项
  - 症状：wave673 修复了「形参已知时 sc<0 一律 T001」，但 `param_raw≤0`（形参类型未知）仍 soft-skip
  - wave676（定义侧 untyped formal）可能间接闭合此路径，但未明确登记
  - 待确认 wave676 是否覆盖此路径

---

## 阶段 5：R2 真迁退役 Track R（大部分完成）

> **定义**：产品构建路径上，该 TU 业务符号全部来自 .x→.o，不再依赖 hybrid rest 同名 C 体。
> **判据**：rest 中该业务符号不再 `#ifndef` 提供 C 体；rest seed 可空/可删宏。

### 5.1 已完成 R2 真迁的模块（~120/128）

> 详见阶段 3 的 128 prove 模块列表。其中 ~120 个已 R2 真迁（rest 业务 H=0），仅保留 Cap residual _impl 桥或 marker。

✅ **5.1.1 全部 labi_* 切片（12 个）R2 full**

✅ **5.1.2 全部 rt_* 切片（23 个）R2 full**

✅ **5.1.3 全部 runtime_* asm 切片（41 个）R2 thin+rest / DIRECT**

✅ **5.1.4 全部 backend/simd 切片（20 个）R2 mixed/full**

✅ **5.1.5 src 根组（15 个）R2 mixed/full**

✅ **5.1.6 async 组（2 个）R2 pure**

✅ **5.1.7 driver 组（11 个）R2 / Track L 退役**

✅ **5.1.8 lsp 组（4 个）R2**

✅ **5.1.9 lexer 组（1 个）prove 锁**


### 5.2 R2 待收口项

⬜ **5.2.1 wave445 SHARED ABI mono 字段 tip L4 收口**

  - 日常 L2 已过，tip L4 升钉未含此
  - 下一阶段收口时跑 L4

⬜ **5.2.2 Darwin stage2 rv / strict multi-def** 平台债

  - macOS stage2 riscv 与 strict 多重定义路径

⬜ **5.2.3 host `_impl` 后缀命名** leave-off

  - host-C 路径的 `_impl` 后缀命名（与 R2 真迁相关）

⬜ **5.2.4 Darwin `int64_t main` 硬要求 int** 平台债

  - 来源：wave623 soft 项
  - macOS 平台硬性要求 main 返回 int，与 int64_t 冲突
  - 未在任何后续 wave 中明确关闭

⬜ **5.2.5 Windows MSYS2 继承 hybrid 未重跑** 平台债

  - 来源：自举进度.md 双端/平台表
  - Windows MSYS2 仍继承 hybrid，本波未重跑
  - 需补做 Windows 双端 L4 验证

⬜ **5.2.6 mac CTFE 常 fold 假绿** 工程债

  - 来源：wave620/645/646/647/648 反复出现
  - mac 上 pure-asm 路径 CTFE 折叠常导致假绿，掩盖真问题
  - 需治本或列入长期约束

⬜ **5.2.7 mac `-dead_strip` 假绿当 Ubuntu 全链已过** 工程纪律债

  - 来源：自举进度.md §7 禁止清单
  - 禁止把 mac `-dead_strip` 假绿当 Ubuntu 全链已过
  - 需列入长期约束文档

---

## 阶段 6：Mega 拆分 Track M1-M3（已完成 · 3/3）

> **定义**：M1 该 mega 源能被当前编译器 typeck / -E 消费；M2 regen *_x.o 替换 pinned .o smoke 绿；M3 Stage2 / D-03。

### 6.1 runtime mega 拆分（RFC: G-02f-P2-runtime-mega）

✅ **6.1.1 R0–R10 全部落地** 11 册

✅ **6.1.2 19 个 rest sub-slice 落地**（详见 3.5 rt_* 切片）

✅ **6.1.3 f-317 里程碑** product rest 业务 T 符号 = 0

✅ **6.1.4 切片完成度** 24/24

✅ **6.1.5 rest 仅 marker + Cap residual**（R7/R8 OS/pthread 等 **原**标 🔒；wave713 起归阶段 9 **必须消灭**，非永久 seed 边界）


### 6.2 parser thin mega 拆分（RFC: G-02f-P2-parser-thin-mega）

✅ **6.2.1 P0–P9 原计划落地** 10 册

✅ **6.2.2 P10–P20 扩展落地** 11 册（f-318–f-329）

✅ **6.2.3 f-329 P20 foundation** rest T=0

✅ **6.2.4 f-330 omit empty rest** 全产品切片齐时跳过 mega rest cc -c

✅ **6.2.5 24 个 pthin_*.x 切片**

✅ **6.2.6 切片完成度** 21/21


### 6.3 link_abi mega 拆分（RFC: G-02f-P2-link-abi-mega）

✅ **6.3.1 L0–L9 全部落地** 10 册

✅ **6.3.2 L8b ondemand 拆分**（f-272）

✅ **6.3.3 f-277 里程碑** link_abi L0–L9 十册 hybrid 齐

✅ **6.3.4 12 个 labi_*.x 切片**

✅ **6.3.5 切片完成度** 11/11

✅ **6.3.6 L3+ 含 stat/spawn/cc/ld** 历史曾标 🔒 薄门闩；wave713 起 **invoke_cc/ld 本体归阶段 9/12–13 必须消灭或 opt-in 隔离**（删 Makefile 后产品默认不得再 `exec` host-cc）


---

## 阶段 7：Mega 去 pin Track M4（未开始 · 0/5）

> **定义**：M4 关 pin / 空 patch；冷启动可从「上一代 xlang -E」或 **纯 .x 产品路径**重建。  
> **当前**：三大 mega 拆分完成（M1-M3），但 pinned `*_gen.c` / mega seed 仍是产品链权威，去 pin 未开始。  
> **补遗**：前端 **typeck / codegen** 亦是 pin 权威（产品链 `typeck_x.o` / `codegen_x.o` 常来自 pin seed），原 0/3 仪表盘漏计，现计 **0/5**。

### 7.1 runtime mega 去 pin

⬜ **7.1.1 关闭 runtime pinned seed**

  - 当前：seeds/runtime.from_x.c（~7,320 LOC）仍是冷启动 seed
  - 目标：冷启动可从 .x 重建，不再依赖 pinned seed

⬜ **7.1.2 runtime_driver_no_c.o 产品链去 pin**

  - 当前：RUNTIME_DRIVER_NO_C_CFLAGS 编译 pinned seed
  - 目标：产品 .o 全部来自 .x→.o

⬜ **7.1.3 M3 Stage2 / D-03 验证**


### 7.2 parser mega 去 pin

⬜ **7.2.1 关闭 parser pinned seed**

  - 当前：seeds/parser_asm_thin_c.from_x.c（~21,935 LOC）仍是冷启动 seed
  - 目标：冷启动可从 pthin_*.x 重建

⬜ **7.2.2 parser_gen.c 去 pin**

  - 当前：Makefile 规则 pinned；`XLANG_FORCE_REGGEN=1` 才 regen
  - 目标：regen parser_x.o 替换 pinned；冷启动不读 pin 体

⬜ **7.2.3 M3 Stage2 / D-03 验证**


### 7.3 link_abi mega 去 pin

⬜ **7.3.1 关闭 link_abi pinned seed**

  - 当前：seeds/runtime_link_abi.from_x.c（~6,920 LOC）仍是冷启动 seed
  - 目标：冷启动可从 labi_*.x 重建

⬜ **7.3.2 runtime_link_abi_gen.c 去 pin**（如存在独立 pin）

⬜ **7.3.3 M3 Stage2 / D-03 验证**


### 7.4 前端 mega 去 pin（typeck / codegen · 原文档漏项）

> **为何独立成 7.4**：M1–M3 历史只拆 runtime/parser/link_abi 三 mega；但产品 L4 链上 **`typeck_gen.c` / `codegen_gen.c` pin** 与 `.x` 双权威问题同等严重（改 `.x` 不改 seed = 假绿）。删 Makefile 前必须可「上一代 xlang 直接编 typeck.x/codegen.x」而不读 pin。

⬜ **7.4.1 typeck 去 pin**

  - 当前：`compiler/typeck_gen.c` + `seeds/typeck_gen.linux.x86_64.c`（~490kB 级）为产品/冷启动权威孪生
  - 目标：`typeck_x.o` 仅由 `src/typeck/typeck.x`（+ empty_surface 策略若仍需） regen；pin 仅考古

⬜ **7.4.2 codegen 去 pin**

  - 当前：`compiler/codegen_gen.c` + `seeds/codegen_gen.linux.x86_64.c` 产品 pin
  - 目标：同 7.4.1；与 wave70x seed 同 commit 纪律收敛为「仅 .x 权威」

⬜ **7.4.3 lexer / preprocess / pipeline 去 pin 对齐**

  - 与阶段 8.2.2 / 8.2.10 / 8.2.11 联动；前端「能自 regen」再谈删 Makefile 冷启动规则

⬜ **7.4.4 双权威禁令验收**

  - 合入闸门：任意 touch `*.x` 产品面 → 同 commit 无「只改 seed」；CI 可 diff pin 与 `-E` 漂移（可选）


---

## 阶段 8：Pinned gen.c 退役（部分完成 · 8/30）

> **定义**：compiler/ 顶层的 *_gen.c 是 pinned 生成器，产品链权威。Track L 退役 = 构建改用 *_x.o，pinned gen 仅考古。

### 8.1 已退役的 pinned gen.c（8 个）

> 产品链 PREFER_X_O；工作区考古 gen 生产体 = `ensure_archaeology_gen.sh`（**wave740** · Makefile 薄叶）

✅ **8.1.1 lsp_io_std_heap_gen.c** Track L 退役（构建用 lsp_io_std_heap_x.o；考古 shell wave740）

✅ **8.1.2 driver_fmt_gen.c** Track L 退役（构建用 driver_fmt_x.o；考古 shell wave740）

✅ **8.1.3 driver_check_gen.c** Track L 退役（archaeology shell wave740）

✅ **8.1.4 driver_test_gen.c** Track L 退役（archaeology shell wave740）

✅ **8.1.5 driver_build_gen.c** Track L 退役（archaeology shell wave740）

✅ **8.1.6 driver_run_gen.c** Track L 退役（archaeology shell wave740）

✅ **8.1.7 driver_emit_gen.c** Track L 退役（构建用 driver_emit_x.o；考古 shell wave740）

✅ **8.1.8 driver_compile_gen.c** R2 真迁（构建用 driver_compile_x.o；考古 shell wave740）


### 8.2 仍需退役的 pinned gen.c（22 个 · 前端核心 + 工具链 + 测试）

⬜ **8.2.1 parser_gen.c** pinned（Makefile L1760 · XLANG_FORCE_REGGEN=1 to regen）

  - 前端核心：src/parser/parser.x
  - 阻塞：parser mega 去 pin（阶段 7.2）

⬜ **8.2.2 lexer_gen.c** pinned（生产体 shell ensure_migrate_gen · 去 pin 仍 ⬜）

  - 前端核心：src/lexer/lexer.x

⬜ **8.2.3 ast_gen2.c** pinned（Makefile L2155）

  - AST 池：src/ast/ast.x（typeck/codegen 单 TU 依赖）

⬜ **8.2.4 typeck_gen.c** pinned（Makefile L2172）

  - 前端核心：src/typeck/typeck.x
  - 阻塞：typeck mega 去 pin

⬜ **8.2.5 codegen_gen.c** pinned（Makefile L2199）

  - 前端核心：src/codegen/codegen.x
  - 阻塞：codegen mega 去 pin

🟡 **8.2.6 lsp_diag_gen.c** pin/seed/-E → `ensure_lsp_pipeline_gen.sh`（wave739 · Makefile 薄叶）

🟡 **8.2.7 lsp_io_gen.c** pin/seed/-E → `ensure_lsp_pipeline_gen.sh`（wave739 · Makefile 薄叶）

🟡 **8.2.8 lsp_gen.c** pin/seed/-E + g_lsp_state_buf post → `ensure_lsp_pipeline_gen.sh`（wave739）

🟡 **8.2.9 driver_gen.c** pin/seed/-E → `ensure_driver_gen.sh`（wave738 · Makefile 薄叶）

  - driver main：src/main.x
  - MAIN_X_DEPS freshness + `fix_driver_gen_duplicate_main` in shell

🟡 **8.2.10 preprocess_gen.c** pin/seed/-E → `ensure_driver_gen.sh`（wave738 · Makefile 薄叶）

  - preprocess：src/preprocess/preprocess.x

🟡 **8.2.11 pipeline_gen.c** pin/seed/-E + i64 ABI → `ensure_lsp_pipeline_gen.sh`（wave739 · Makefile 薄叶）

  - pipeline：src/pipeline/pipeline.x · post = `check_pipeline_gen_expr_i64_abi.sh`

⬜ **8.2.12 token_gen.c** pinned（19 行 · seeds/token_gen.linux.x86_64.c）

  - token：src/lexer/token.x（prove 锁 nm 面 · 见 3.2.1）

⬜ **8.2.13 ast_gen.c** pinned（808 行 · seeds/ast_gen.linux.x86_64.c）

  - AST 池 v1：src/ast/ast.x
  - 注意：与 ast_gen2.c 并存（双版本），需统一去 pin

⬜ **8.2.14 build_gen.c** pinned（40 行 · seeds/build_gen.c）

  - build 工具生成器

⬜ **8.2.15 build_runner_gen.c** pinned（93 行 · seeds/build_runner_gen.c）

  - build runner 生成器

⬜ **8.2.16 build_runtime_x_gen.c** pinned（245 行 · seeds/build_runtime_x_gen.c）

  - build runtime 生成器

⬜ **8.2.17 cfg_eval_gen.c** pinned（src/lexer/ · 973 行 · seeds/cfg_eval_gen.linux.x86_64.c）

  - cfg_eval：src/lexer/cfg_eval.x
  - src/ 下唯一未迁移的 .c 文件

⬜ **8.2.18 lsp_gen_full.c** pinned（1072 行 · 非 *_gen.c 命名但属 pinned 生成器）

  - lsp 完整版变体

⬜ **8.2.19 token_gen2.c** pinned（466 行 · gen2 变体）

  - token v2：与 token_gen.c 并存

⬜ **8.2.20 lexer_gen2.c** 空文件（0 行 · gen2 变体占位）

  - 待删除或填充

⬜ **8.2.21 parser_gen_test.c** pinned（5383 行 · 测试用 pinned）

  - parser 测试生成器

⬜ **8.2.22 typeck_gen_test.c** pinned（249 行 · 测试用 pinned）

  - typeck 测试生成器

### 8.3 非 gen 产品 C / 链接桩（原文档大漏 · **删 Makefile 体积主债**）

> **定义**：不叫 `*_gen.c`，但 **产品链 / bootstrap-driver-seed / g05** 仍 `$(CC) -c` 的 C 体与符号桩。  
> **规模（2026-07-29 仓库实测）**：仅 glue+ast_pool 系 **~60,574 LOC**，远大于多数 gen 单文件；不迁完则 xbuild **无法**在 BC 层摆脱 host-cc。  
> **G.7**：glue 与 typeck.x / codegen.x 禁止长期双权威；迁时同 commit 收敛。  
> **地图用途**：动 8.3 前先查消费方，禁止只改一端。

#### 8.3 体积地图（主债文件 · 实测 LOC）

| 文件（compiler/） | LOC | 角色 | 状态 |
|-------------------|-----|------|------|
| `pipeline_glue.c` | 40,096 | 产品 mega glue（typeck/codegen/asm/match…） | ⬜ |
| `ast_pool.c` | 18,109 | AST 池 / MatchArm / sidecar | ⬜ |
| `pipeline_typeck_field_access.c` | 1,477 | field_access 权威切片（常被 glue 拉入） | ⬜ |
| `pipeline_typeck_soa.c` | 255 | typeck SOA 辅助 | ⬜ |
| `ast_pool_bootstrap_glue.c` | 632 | 冷启动 ast 桥 | ⬜ |
| `pipeline_bootstrap_orchestration.c` | 5 | 编排占位 | ⬜ |
| `pipeline_glue_strict_minimal`（seed → `.o`） | — | 产品 weak 孪生 | ⬜ |
| bare link alias / stubs 族 | 小 | `*_bare_link_alias.c` · `_stubs.c` · `xlang_x_stubs.c` · `typeck_c_module_stubs.c` 等 | ⬜ |

#### 8.3 消费方地图（谁还拉 glue · 迁时必同改）

| 消费方 | 如何引用 | 风险 |
|--------|----------|------|
| `compiler/Makefile` `PIPELINE_X_DEPS` | `pipeline_glue.c` + `ast_pool.c` + bootstrap glue 进 deps | 改源必重编 pipeline_x |
| `compiler/Makefile` `ASM_GLUE_STANDALONE_O` | standalone seed + glue + types.inc | weak 孪生与主链分叉 |
| `g05_ensure_relink_prereqs.sh` | mtime vs `pipeline_x.o` / standalone；unbundle 卫生 | 产品热路径仍 host-cc 重编 |
| `pipeline_gen.c` / `-E` runtime 路径 | 入口 pipeline.x 时追加 glue 到 stdout | 与 gen 双权威风险 |
| `seeds/pipeline_glue_standalone.from_x.c` | 与 glue 并列产品链 | seed 与 .c 须同 commit |
| `build_asm/gen_driver/*.c`（10） | Makefile + g05 + partial 脚本 | 物理在 compiler/ 外，易漏计 |
| bare alias / stubs `.c` | 链接安静桩 | 终局由 .x `#[no_mangle]` 取代 |

⬜ **8.3.1 `pipeline_glue.c` → .x（或按域切 thin + 唯一权威）**

  - 爆炸半径：几乎所有 typeck/codegen/asm 产品路径
  - 验收：产品链不再 `cc -c pipeline_glue.c`；Ubuntu L4 + 129

⬜ **8.3.2 `ast_pool.c` → .x / 已有 ast.x 权威收敛**

  - MatchArm / GrowVec / module sidecar 与 parser pin 同生命周期

⬜ **8.3.3 `pipeline_typeck_field_access.c` / `pipeline_typeck_soa.c` 并入 typeck 权威**

  - 禁止 glue 旁路第二套 field resolve

⬜ **8.3.4 bootstrap glue / orchestration 折叠进 8.3.1–8.3.2 或删**

⬜ **8.3.5 链接桩 / bare alias 退役**

  - `ast_asm_bare_link_alias.c` · `backend_asm_*_alias.c` · `typeck_asm_bare_link_alias.c` · `x_frontend_link_alias.c` · `_stubs.c` · `_x_stubs2.c` · `xlang_x_stubs.c` · `typeck_c_module_stubs.c`
  - 目标：符号面由 .x `#[no_mangle]` / 单一 mangle 权威提供，无「为让 ld 安静」的永久 C 桩

⬜ **8.3.6 `seeds/*.from_x.c` 全表退役策略**

  - 今日 **~329** 个 seeds `.c`：分 **产品 pin** / **prove surface** / **EMPTY surface** / **strict_minimal**
  - 终局：冷启动不读 from_x 业务体；surface 仅考古或生成物不入库（策略二选一写清）

⬜ **8.3.7 scripts 下 asm stub C**

  - `compiler/scripts/asm_text_stub.c` · `asm_xlang_lsp_diag_stub.c` 等 — 随 xbuild/g05 迁走或删

⬜ **8.3.8 `build_asm/gen_driver/*.c`（10 个 · 物理在 compiler/ 外）**

  - `build_asm/gen_driver/pipeline_gen.c` · `lsp_io_gen.c` · `driver_check.c` · `preprocess_gen.c` · `driver_fmt.c` · `lsp_gen.c` · `lsp_io_std_heap_gen.c` · `driver_gen.c` · `driver_test.c`
  - 被 `compiler/Makefile` 行 2821-2839 + `g05_ensure_relink_prereqs.sh` 行 1956-1957 + `build_seed_user_asm_codegen_partial.sh` 引用
  - 属构建链产物，物理位置在 compiler/ 之外，原 8.3 漏计

⬜ **8.3.9 `analysis/_debug_io_ctx_gen.c` 孤儿 .c**

  - grep 全仓无任何引用，调试残留
  - 确认后删除

⬜ **8.3.10 `editors/tree-sitter-xlang/` 第三方 .c**

  - `editors/tree-sitter-xlang/src/parser.c` · `bindings/python/tree_sitter_xlang/binding.c` 等
  - 第三方 tree-sitter grammar，自带 Makefile + binding.gyp + Cargo.toml(cc crate)
  - 与 xlang 自举链无关，但物理存在于仓库；终局需决定：删除 / git submodule / 独立 release


---

## 阶段 9：Cap residual 边界消灭（路线 A · 必须消除）

> **定义**：OS 系统调用 / 第三方库头依赖 / 宏展开 / C ABI 限制，当前 Xlang 无法表达，以 .c 形式残留。
> **性质变更**（2026-07-29）：原标记为「永久边界 🔒 不可迁」，现**降级为必须消灭的边界 ⬜**。
> **原因**：自举终局目标升级为「零 Makefile + 零 cc/gcc」（见阶段 13），只要这些 residual 还以 .c 源文件形式存在，就必然需要 cc/gcc 来编译它们。因此必须通过路线 A（语言能力补齐 + 纯 .x 重写）逐个消灭。
> **消灭顺序**：syscall 层（9.1）→ 文件/网络/线程（9.4/9.5）→ 第三方库 glue（9.2）→ 宏展开（9.3）→ 数据布局（9.6）→ driver_abi 平台层（9.7）。
> **前置**：阶段 10 语言能力补齐（syscall / raw FFI / inline asm / fnptr / va_list / 线程原语）是消灭这些 residual 的前提。

### 9.1 OS 系统调用类（消灭优先级 P0 · 最底层）

> **消灭路径**：为 Xlang 增加 syscall 内建（Linux x86_64 / arm64 syscall 号 + Windows NT API），用 .x 直接发 syscall，不再经 libc 包装。
> **依赖**：阶段 10.1 syscall / raw FFI。

⬜ **9.1.1 getenv / setenv / unsetenv / environ**
  - labi_invoke_cc/ld
  - labi_diag
  - rt_entry
  - runtime_env_os
  - runtime_scheduler_glue
  - parser_asm_parse_expr_link

⬜ **9.1.2 stat / access / realpath**
  - labi_path_io
  - labi_ensure_list
  - labi_freestanding_list
  - labi_invoke_ld_list
  - fmt_check

⬜ **9.1.3 getcwd / chdir / getpid / getppid**
  - runtime_process_os_glue
  - labi_invoke_ld_list

⬜ **9.1.4 execve / waitpid / pipe / spawn / system**
  - runtime_process_os_glue
  - labi_invoke_ld_list
  - labi_diag_pure
  - rt_entry

⬜ **9.1.5 clock_gettime / nanosleep / gmtime_r / QPC / Sleep**
  - runtime_time_os

⬜ **9.1.6 getrandom / getentropy / BCryptGenRandom**
  - runtime_random_fill

⬜ **9.1.7 getaddrinfo / WSAStartup / socket / connect / poll / recvmmsg / sendmmsg**
  - runtime_net_*
  - runtime_http_glue

⬜ **9.1.8 _write / write**
  - runtime_log_os

⬜ **9.1.9 inline asm syscall（Linux x86_64）**
  - runtime_asm_io_stubs

⬜ **9.1.10 opendir / readdir / closedir**
  - fmt_check

⬜ **9.1.11 execinfo / dladdr / DbgHelp / CaptureStackBackTrace**
  - runtime_backtrace_platform

⬜ **9.1.12 sysctl / proc/#if**
  - target_cpu_pure

### 9.2 第三方库依赖（消灭优先级 P2 · 自实现子集或桥接）

> **消灭路径**：能纯 .x 重写的重写（如 ed25519 / 部分libm）；不能重写的放弃或自实现子集；TLS / zlib 等大库走 .x 绑定层 + 预置二进制 .a（但不再走 cc 编译源码）。
> **依赖**：阶段 10.1 syscall / raw FFI · 阶段 10.2 inline asm（SIMD）。

⬜ **9.2.1 mbedtls BIO send/recv**（需 #include <mbedtls/ssl.h>）
  - runtime_tls_mbedtls_bio

⬜ **9.2.2 zlib deflateInit2_ / inflateInit2_**（需 #include <zlib.h> + #undef macros）
  - runtime_compress_zlib_glue

⬜ **9.2.3 ed25519 ref10 实现**（8 个 .inc 文件宏展开）
  - runtime_ed25519_ref10_glue

⬜ **9.2.4 libm math_*_impl**（32 个 libm 函数桥）
  - runtime_math_libm

⬜ **9.2.5 arrow SIMD kernels**（需 C target attributes）
  - runtime_arrow_simd_glue

⬜ **9.2.6 sqlite3**（sqlite3 C API）
  - runtime_sqlite_glue

### 9.3 宏展开类（消灭优先级 P2 · .x 内建替代）

> **消灭路径**：stdatomic → .x 原子内建；SIMD intrinsics → .x SIMD 内建；ed25519/zlib 宏 → .x 模板/过程化展开。
> **依赖**：阶段 10.2 inline asm · 阶段 10.4 原子内建 · 阶段 10.5 SIMD 内建。

⬜ **9.3.1 ed25519 ref10 宏重命名**
  - 8 个 .inc 经宏发射 _impl_c

⬜ **9.3.2 zlib macros #undef**
  - rest #include + #undef + call real

⬜ **9.3.3 #if host 字面量**
  - labi_host_lit
  - target_cpu_pure
  - runtime_panic_arm64

⬜ **9.3.4 C11 stdatomic / GCC __atomic intrinsics**
  - runtime_atomic_glue（30 个原子操作）

⬜ **9.3.5 SIMD intrinsics**
  - runtime_arrow_simd_glue（ARM SVE / x86 AVX）

### 9.4 C ABI / fnptr 表达限制（消灭优先级 P1 · 平台线程原语）

> **消灭路径**：fnptr → 阶段 10.3 完整 fnptr 支持；pthread/Win32 → 阶段 10.6 平台线程原语内建（.x 直接调 syscall/NT API）。
> **依赖**：阶段 10.3 fnptr · 阶段 10.6 线程原语。

⬜ **9.4.1 uintptr_t → fnptr cast + indirect call**
  - runtime_test_fn_invoke

⬜ **9.4.2 void*(*)(void*) C ABI**
  - runtime_net_workers

⬜ **9.4.3 main() char** argv
  - runtime_asm_build

⬜ **9.4.4 pthread_mutex_t / pthread_cond_t / pthread_create**
  - runtime_sync_os
  - runtime_channel_glue
  - runtime_queue_contention
  - runtime_thread_glue
  - runtime_sync_lock_diag_tls

⬜ **9.4.5 CRITICAL_SECTION / SRWLOCK / CONDITION_VARIABLE / CreateThread / _beginthreadex**
  - 同 9.4.4 Windows 侧

⬜ **9.4.6 SetThreadAffinityMask / qos_class**
  - runtime_thread_glue

### 9.5 FILE* / fprintf / fputs / va_list（消灭优先级 P1 · va_list + 格式化）

> **消灭路径**：FILE* → .x 自己的 I/O 流（基于 syscall write）；va_list → 阶段 10.7 可变参数内建；vsnprintf → .x 自实现格式化器。
> **依赖**：阶段 10.1 syscall · 阶段 10.7 va_list。

⬜ **9.5.1 driver_preamble_fputs（G.7）**
  - async_liveness
  - async_cps_codegen

⬜ **9.5.2 xlang_target_cpu_print（FILE/fprintf）**
  - target_cpu_pure

⬜ **9.5.3 reportf / va_list**
  - diagnostic 深路径

⬜ **9.5.4 vsnprintf + write**
  - bootstrap_nostdlib_stubs

### 9.6 全局/static BSS / 巨型字串数据（消灭优先级 P1 · Cap 已部分闭）

> **消灭路径**：Cap-global-bss / Cap-giant-string 已部分闭合（见 4.1.3 / 4.1.7）；剩余用 .x 全局数据表达。
> **依赖**：Cap-global-bss / Cap-giant-string 完全闭合。

⬜ **9.6.1 u8[N] 全局/static BSS**（Cap-global-bss）
  - rt_arena_buf
  - rt_emit_state

⬜ **9.6.2 巨型字串表数据**（Cap-giant-string）
  - rt_preamble

⬜ **9.6.3 static 共享状态**
  - 各 mega rest 切片

### 9.7 driver_abi 平台层集中点（消灭优先级 P3 · 最上层）

> **消灭路径**：driver_abi 平台槽位全部用 .x 表达；FILE/pctx/host/defines/work 槽 → .x 结构体；GAS 行表 → .x OutBuf。
> **依赖**：阶段 9.1-9.6 全部消灭后，此层自然消失。

⬜ **9.7.1 FILE/pctx/host/defines/work 槽**
  - rt_run_asm_backend
  - rt_run_compiler_parsed
  - rt_run_x_emit
  - rt_dispatch_impl
  - rt_asm_stub

⬜ **9.7.2 lib_roots 槽 + Parsed 填表**
  - rt_dispatch_impl

⬜ **9.7.3 GAS 行表 + OutBuf append**
  - rt_asm_stub

⬜ **9.7.4 driver_stdio_* + driver_entry_*_slot**
  - rt_entry

⬜ **9.7.5 usage_write + compiled_body**
  - rt_run_exec

⬜ **9.7.6 driver_run_stack_esc_gate**（pthread）
  - rt_stack

⬜ **9.7.7 driver_run_thread_on_large_stack_pthread**
  - rt_stack

---

## 路线选择：零 Makefile + 零 cc/gcc 的实现路径

> **背景**（2026-07-29）：自举终局目标从「v2==v3 + 无 pin」升级为「零 Makefile + 零外部 C 编译器」。阶段 9 的 residual C 只要以 .c 源文件形式存在，就必然需要 cc/gcc 编译。因此必须选定一条路线彻底消灭 .c 源文件依赖。

### 路线对比

| 路线 | 做法 | 优点 | 缺点 | 是否采用 |
|------|------|------|------|----------|
| **A · 纯 .x + 内建能力重写** | 为 Xlang 增加 syscall / FFI / inline asm / fnptr / va_list / 线程原语内建；阶段 9 全部用 .x 重写或自实现子集；纯 .x 写 xbuild 替代 Makefile | 最干净；真正零 cc；终局最纯 | 工作量大；需补语言底层能力 | ✅ **采用** |
| B · 预置二进制 blob | residual C 提前编译成 .o/.a；运行时只链接；冷启动仍需一次 cc | 工作量小 | 严格说 cc 仍参与过；不够纯；跨平台二进制管理复杂 | ❌ 不采用 |
| C · Xlang 实现 C 编译器前端 | 在 Xlang 里写一个足够用的 C 编译器 | 可兼容遗留 C 代码 | 工作量巨大；几乎再做一个编译器 | ❌ 不采用 |

### 路线 A 落地顺序

```
1. 更新追踪文档（本文）— 删 Makefile + 零 cc 三义 + 8.3 glue 债入图 ✅（本审计）
2. 语言能力补齐（阶段 10）— syscall / raw FFI / inline asm / fnptr / va_list / 线程原语
3. 消灭阶段 9 residual + 阶段 8.3 glue/ast 池 — 从底向上
4. 阶段 7/8 去 pin + gen 退役 — 前端 typeck/codegen 与三 mega
5. xbuild 吃掉 Makefile（阶段 11.0 可与 2–4 并行：先搬编排、后断 cc）
6. 冷启动路径重设计（阶段 12）— 最小 seed → xlang → xbuild → 完整产品
7. 终局验证（阶段 13）— 物理删 Makefile + 零 cc 三义 + v2==v3
```

### 与「已有半路径」的关系（禁止从零幻想）

| 已有资产 | 路径 | 今日角色 | 终局角色 |
|----------|------|----------|----------|
| 顶层 `Makefile` | 仓库根 | **薄包装** → `./xlang-build.sh` | **删除** |
| `compiler/Makefile` | ~3445 行 | **实现层权威**：.o 规则 / bootstrap / CI 历史目标 | **删除**（规则迁 xbuild） |
| `xlang-build.sh` | 根 | G-05 用户入口 | 可保留为 xbuild 的 shell shim 或删 |
| `scripts/g05_*.sh` | compiler/scripts | **产品 relink 编排已在 shell**（注释写明 Makefile 不参与产品路径） | 由 xbuild 调用或 .x 重写 |
| `build.x` | 仓库根 | **策略稿**（what/order）；实现大量 “See implementation” | 填实为 xbuild 策略源 |
| `compiler/src/driver/build.x` | driver | build 子命令相关 | 与 xbuild 合并为单一权威 |
| `build_tool` / seeds/build_* | 历史 | 仍可能 `make xlang_asm` 兜底 | 断 make 依赖 |

---

## 阶段 10：语言能力补齐 Track L2（路线 A 前置 · 消灭 residual 的前提）

> **定义**：为 Xlang 增加底层能力，使其能表达 OS 系统调用 / inline asm / 函数指针 / 可变参数 / 平台线程原语。
> **性质**：这是消灭阶段 9 residual 的**前提**。没有这些能力，阶段 9 的 .c 无法用 .x 重写。
> **优先级**：P0（最高）— 阻塞所有阶段 9 消灭工作。

### 10.1 syscall / raw FFI 内建

⬜ **10.1.1 Linux x86_64 syscall 内建**

  - 支持 `syscall(nr, args...)` 直接发系统调用
  - 覆盖：read/write/open/close/stat/mmap/munmap/exit/getpid/...

⬜ **10.1.2 Linux arm64 syscall 内建**

  - 同上，arm64 syscall 号表

⬜ **10.1.3 Windows NT API 内建**

  - NtCreateFile / NtWriteFile / NtReadFile / NtClose / NtQuerySystemTime...
  - 或经 ntdll.dll 符号绑定

⬜ **10.1.4 raw FFI（ extern "C" 调用约定）**

  - 支持 .x 直接声明 extern 符号 + 调用（不需 .c 桥）
  - 覆盖：dlsym 加载 / 函数指针 cast / 平台 ABI

### 10.2 inline asm 内建

⬜ **10.2.1 x86_64 inline asm**

  - 支持 `asm!("syscall", in("rax") nr, in("rdi") a0, ...)` 语法
  - 覆盖：syscall 指令 / cpuid / rdtsc / mfence / barrier

⬜ **10.2.2 arm64 inline asm**

  - 同上，arm64 指令

⬜ **10.2.3 Windows inline asm（或等价 intrinsics）**

  - Windows 不支持 inline asm（MSVC），用 intrinsic 或纯 asm 文件替代

### 10.3 函数指针完整支持

⬜ **10.3.1 fnptr 类型表达**

  - `let f: fn(i32) -> i32` 类型完整支持
  - 与 Cap-fn-ptr（4.1.6）合并收口

⬜ **10.3.2 fnptr cast + indirect call**

  - `uintptr_t → fnptr` cast 合法化
  - 间接调用 `(*f)(args)`

⬜ **10.3.3 fnptr 作为参数 / 返回值 / 结构体字段**

  - 全场景支持（C ABI 兼容）

### 10.4 原子操作内建

⬜ **10.4.1 atomic_load / atomic_store / atomic_cas**

  - .x 原子内建，替代 C11 stdatomic / GCC __atomic

⬜ **10.4.2 内存屏障内建**

  - acquire / release / seq_cst 语义

### 10.5 SIMD 内建

⬜ **10.5.1 x86 AVX / SSE 内建**

  - .x SIMD 向量类型 + 内建操作

⬜ **10.5.2 ARM SVE / NEON 内建**

  - 同上，arm64

### 10.6 平台线程原语内建

⬜ **10.6.1 Linux futex / clone / mmap 栈**

  - .x 直接调 syscall 实现线程，不经 libpthread

⬜ **10.6.2 Windows CreateThread / WaitForSingleObject**

  - .x 直接调 NT API

⬜ **10.6.3 互斥锁 / 条件变量 / 信号量**

  - 基于 10.6.1/10.6.2 实现 .x 线程原语

### 10.7 可变参数 va_list 内建

⬜ **10.7.1 va_list 类型 + va_start / va_arg / va_end**

  - .x 可变参数支持
  - 用于 reportf / vsnprintf / 诊断深路径

⬜ **10.7.2 .x 自实现 vsnprintf**

  - 替代 libc vsnprintf

---

## 阶段 11：xbuild + Makefile 退役 Track MG（**用户终局主闸门**）

> **定义**：用 **xbuild（纯 .x + 必要极薄 shim）** 接管依赖分析、编译、链接、自举 stage、L4/bstrict 编排，**物理删除 Makefile**。  
> **前置（硬）**：阶段 8.3 glue/ast 与阶段 7/8 pin **不必 100% 完成才允许启动 11.0**；但 **11.3 物理删除** 前必须 BC 层不再强制 `$(CC) -c` 业务 C。  
> **目标入口**：`xbuild build` / `xbuild test` / `xbuild bootstrap` / `xbuild cold-test` 替代 `make` / `make -C compiler …`。  
> **既有半路径**：`./xbuild`→`xlang-build.sh` · `g05_*.sh` · `build.x`（策略）· 根 Makefile **help-only** — **禁止再开第三套编排**。

### 11.0 Makefile 瘦身（可与阶段 7–10 **并行** · 早启动）

> **目的**：在 residual C 仍存在时，先把「编排权威」从 Makefile 挪走，避免终局时一次性改 3445 行。

✅ **11.0.1 盘点 `compiler/Makefile` 规则 → 迁移表**（2026-07-29 · wave714）

  - 分类：冷启动 bootstrap / `*_x.o` / seed pin cp / g05 已覆盖 / 测试·prove / Windows / 死规则
  - 产出：**[`analysis/Makefile迁移表.md`](Makefile迁移表.md)**（288 唯一目标 · 类 A–O）+ 本文附录 E 摘要
  - xbuild 拟目标命名已挂表；迁移完成定义见迁移表 §0

✅ **11.0.2 产品路径 0-make 验收**（wave714 静态 ✅ · wave715/716 class-G filtered ✅ · **wave726 PATH 探针 ✅**）

  - 在 **不** `make -C compiler` 的前提下：仅 `xlang-build.sh` / g05 完成 `xlang`/`xlang_asm` 链 + 矩阵
  - **静态闸门**：`tests/run-product-path-zero-make-gate.sh`（allowlist 冻结 g05 日常 `make`；防回退）
  - **wave715**：pipeline filtered → shell；**wave716**：其余 3 partial-filter + 共用 `filter_o_export_against_deps.sh`；g05_ensure Darwin trio 纯 shell
  - **wave726 运行时 PATH 探针**：`tests/run-product-path-zero-make-path-probe.sh` — shadow make/gmake；help + g05_relink_env + ensure/prepare 须 **0-exec** make；闸门硬检并真跑
  - **仍非日常 0-make**：FULL=1→make bstrict（g05 白名单）；嵌套 `tests/run-all-*.sh` / ensure 内 make（11.2.3）

🟡 **11.0.3 冷启动路径减 make**（§5b 全 🟢；叶清单→mk）

  - ✅ 类 G 全 4 filtered.o = 纯 shell；冷启动 `$(MAKE)` **白名单**：[Makefile迁移表.md](Makefile迁移表.md) §5b
  - ✅ 编排 / 链接 / rebuild / host-stubs / check-abi / asm-host → shell 权威；Makefile 薄叶子 + export
  - ✅ 叶清单 / 组合体定义 → `compiler/mk/*.mk`（G.7 单权威；catalog 18 keys）
  - ⬜ FULL=1 冷路径仍经 make 白名单叶（编排已 shell）

🟡 **11.0.4 根 Makefile 只保留 help → xbuild**

  - ✅ OBJS 叶 + 组合体 → `compiler/mk/*.mk`；`export-obj-catalog` + `driver_seed_obj_catalog.sh`（禁 shell 双清单）
  - ✅ **`./xbuild`** 薄转调 **`xlang-build.sh`**（G.7 同体）；根 Makefile **help-only**（`.DEFAULT_GOAL=help`；`%` 仅兼容转发）
  - ⬜ 禁止再加厚根 Makefile；compiler/Makefile 本体仍待 xbuild 吞并（11.1/11.3）

### 11.1 核心功能

🟡 **11.1.1 依赖图分析**

  - 扫描 .x import / seed 输入 / 平台条件；增量重编
  - 对齐 code-review-graph 思路可选，但 **权威在 xbuild**
  - ✅ wave742：编排 DAG **库存** — `compiler/docs/BUILD_DAG.md` + `product_build_dag.sh` dump/`--check`；`./xbuild product-dag`；产品日路径 + 冷启动节点/owner；G.7 禁第二套 `.o`（列表仍 mk/catalog）
  - ✅ wave744：`DRIVER_SEED_PREREQS` **边满足** → `driver_seed_ensure_prereqs.sh`（catalog 列表 + glue companion）；Makefile 薄 phony 不再挂 make-graph prereq
  - ⬜ 终局：import 扫描 + 增量图执行（依赖 11.1.2）；叶 `.o` pattern residual → 11.3.1

🟡 **11.1.2 编译调度（.x → .o）**

  - 默认 **asm backend**（BC 终局）；过渡期允许显式 `host-cc` 仅编 **白名单 residual C**（清单来自 8.3/9，逐步清空）
  - 并行：线程原语（10.6）就绪前可用进程池 / 外部 ninja 过渡（**过渡须标 temporary**）
  - ✅ wave743：编排图 **schedule 执行** — `product` / `refresh` / `cold` 命名调度；`--dry-run` / `--run`；`run` 只转调既有 shell 体（G.7 禁双路径）；product 跳过 archaeology 与独立 g05_ensure/link_env；cold live = 外层 `bootstrap-driver-seed`
  - ✅ wave744：cold 调度首节点 `cold_ensure_prereqs`；live outer 内嵌 shell ensure
  - ⬜ 终局：.x import 增量图 + 并行；冷启动叶不经 make pattern（与 11.3 同闸）

🟡 **11.1.3 平台处理**

  - Linux / macOS / Windows 路径·ABI·seed 选择
  - 替代 Makefile `ifeq ($(UNAME)…)` / Alpine 等
  - ✅ wave745：权威 `compiler/docs/PLATFORM_LINKER.md` + `host_platform_linker.sh`（`XLANG_HOST_OS`/`ARCH`/`PLATFORM_TAG`/Alpine/seed pin）；`./xbuild host-platform`；产品 pin 仍 `*.linux.x86_64.c`（host-portable）
  - ✅ wave746 交叉：叶 UNAME residual 类 **R2** 已在 `LEAF_PATTERN_RESIDUAL.md` 命名（库存 only）
  - ⬜ 终局：Makefile `UNAME` 叶 pattern 全吞（与 11.3.1 同闸）；禁 shell 第二套 uname 矩阵

🟡 **11.1.4 链接器调用**

  - 直接调 `ld` / `lld` / `link.exe`（syscall 或 raw FFI / 过渡 `posix_spawn`）
  - **禁止**默认 `$(CC) -o` 当链接器（避免偷偷拉 cc）
  - ✅ wave745：策略库存 — prefer `xlang_asm_invoke_ld_platform` + direct ld；**命名 residual** `bootstrap_driver_seed_link.sh` `SEED_LINK_CC -o`（列表仍 Makefile export）；`./xbuild linker-policy`
  - ✅ wave772：cold phase1/final **pure-ld** — Makefile export `SEED_LINK_LD/MULTIDEF/ENTRY/LD_TAIL/PURE_OK`；`bootstrap_driver_seed_link.sh` pure ld（Darwin syslibroot）；`--self-test`
  - ✅ wave773：g05 product **pure-ld** — G.7 抽 `pure_ld_shared.sh`；cold 转调；`g05_relink_xlang` pure-ld（LINUX nostdlib static；else `-lSystem`/`-lc`）
  - ✅ wave774：**drop silent CC fallback** — pure-ld eligible → hard fail on pure miss；named CC residual only `FORCE_CC` / ineligible（`PURE_OK=0` / non-freestanding）
  - ⬜ 终局：Windows PE pure-ld · 无任何 residual `CC -o`（含 FORCE_CC 逃生口收敛）

🟡 **11.1.5 填实 `build.x` 策略源**

  - ✅ wave734：根 `build.x` 英文策略图（产品/冷启动/残余叶/xbuild 目标映射）；三函数 ABI 保持 pin-compatible
  - ✅ wave742：`build.x` §F 挂 11.1.1 BUILD_DAG / product-dag
  - ✅ wave743：`build.x` §F 挂 11.1.2 dry-run/run schedules
  - ✅ wave744：`build.x` §F 挂 shell ensure_prereqs / driver-seed-prereqs
  - ✅ wave745：`build.x` §F 挂 11.1.3 host-platform / 11.1.4 linker-policy
  - ⬜ 终局：DAG-as-data 替代 C build_runtime 步表（依赖 11.1.1–4 执行层）

🟡 **11.1.6 吞并 g05 脚本族**

  - `g05_ensure_relink_prereqs` / `g05_relink_env` / `g05_relink_xlang` / `g05_prepare_and_relink` / `build_xlang_asm.sh`
  - ✅ wave733：`./xbuild ensure|link-env|link-product|link-product-asm` 直调 g05 shell（**零 make**）；Makefile 薄兼容入口仍在
  - ✅ wave733：`run_compiler_make` 与 tests hub 合体 → `tests/lib/compiler-make.sh`（G.7 单 make -C 体）
  - ✅ wave734：`refresh_xlang_asm_gate.sh` 唯一体；`./xbuild refresh-gate`；bstrict/run-refresh 脱 make recipe
  - ✅ wave735：`migrate_x_objs.sh` 唯一体（parser/typeck/codegen `_x.o`）；`./xbuild migrate`；refresh 0× make migrate；Makefile 薄叶
  - ✅ wave736：`ensure_migrate_gen.sh` 唯一体（parser/typeck/codegen `_gen.c` pin/seed/-E）；`./xbuild migrate-gen`；migrate 0× make gen 体
  - ✅ wave737：`lexer_gen.c` → 同 script mode lexer；`./xbuild lexer-gen`；Makefile 薄叶
  - ✅ wave738：`ensure_driver_gen.sh` 唯一体（`driver_gen.c` + `preprocess_gen.c`）；`./xbuild driver-gen`；Makefile 薄叶
  - ✅ wave739：`ensure_lsp_pipeline_gen.sh` 唯一体（`lsp_diag`/`lsp_io`/`lsp_gen` + `pipeline_gen`）；`./xbuild lsp-gen` / `pipeline-gen`；Makefile 薄叶；考古 subcmd gen residual
  - ✅ wave740：`ensure_archaeology_gen.sh` 唯一体（7× `driver_*_gen` + `lsp_io_std_heap_gen`）；`./xbuild archaeology-gen`；产品链不消费（Track L PREFER_X_O）
  - ⬜ 终局：xbuild 内建或单一 `scripts/g05` 族；删 Makefile 间接调用 / seed prereq 图（与 11.3 同闸）

### 11.2 自举 stage + 测试/CI 编排

⬜ **11.2.1 stage1 → stage2 → stage3 编排**

  - seed_xlang → xlang_v1 → xlang_v2 → xlang_v3；自动 v2==v3

⬜ **11.2.2 L4 真冷全测集成**

  - `xbuild cold-test`：全擦 `compiler|std|core` 下 `.o` + 删产品二进制 → seed/g05 或纯 xbuild → 矩阵 → `run-all-bstrict`（`XLANG_BSTRICT_SKIP_BUILD=1`）

✅ **11.2.3 prove / bstrict / gate 脚本去 make**（wave727–733）

  - `tests/**/*.sh`（含 `tests/lib/*.sh` · `tests/bench/**/*.sh` · `tests/docker/*`）中 `make -C compiler` 清零或改为 `xbuild` / `xlang_compiler_make`
  - ✅ `tests/lib/compiler-make.sh` 单入口 `xlang_compiler_make`；tests/lib **0** raw `make -C`（hub 外）；`XLANG_COMPILER_DIR` 支持 nolibc（wave727/728）
  - ✅ `tests/run-*.sh` **0** raw `make -C`（~456 脚本 → hub；wave732）；图仍 Makefile 至 11.3
  - ✅ wave733：全仓 `tests/**/*.sh` 0 raw make -C（bench 本无 make -C，vacuous close）；CLI 模式供 xbuild 共用 hub
  - docker CI 外层 / 11.2.5 workflow ✅ wave730

⬜ **11.2.4 Windows 入口**

  - 非金标但终局须有 xbuild 路径（MSYS2）；禁止「只 Linux 删了 Makefile」
  - 🟡 CI Windows job 已 `./xbuild compiler-all`（wave730）；本地 MSYS2 入口仍待 11.2.4 专波

✅ **11.2.5 `.github/workflows/*.yml` CI 去 make/cc（wave730 · 外层）**

  - `ci.yml` / `ci-nightly.yml` / `selfhost-stage2.yml` / `release.yml`：构建入口 → `./xbuild compiler-all` / `bootstrap-driver-seed` / `compiler-make` / shell `clean`
  - `bootstrap-seeds-capture.yml`：无 `make -C`（仅装 gmake 包）
  - 实现层仍经 `xlang-build.sh`→`run_compiler_make` 触 Makefile 图（至 11.3）；guest 仍装 host-cc/make（零 cc 属 12）

### 11.3 Makefile 物理删除（**终局硬指标**）

🟡 **11.3 residual · prereq 边吞并（wave744 · 非物理删）**

  - ✅ `driver_seed_ensure_prereqs.sh`：catalog 展开 `DRIVER_SEED_PREREQS` + glue companion；`--dry-run` / `--check` / `--run`
  - ✅ `bootstrap_driver_seed.sh` step 0 调 ensure；Makefile `bootstrap-driver-seed` 薄 phony（无 `$(DRIVER_SEED_PREREQS)` make deps）
  - ✅ `./xbuild driver-seed-prereqs`；cold dry-run 印 `PREREQ=` 边
  - ⬜ 叶 `.o` pattern / host-cc residual 仍 Makefile 至 11.3.1 物理删
  - ✅ wave746：**11.3.1 路径库存** — `LEAF_PATTERN_RESIDUAL.md` + `leaf_pattern_residual.sh`
    （R1–R6 命名；`./xbuild leaf-patterns`；**非**物理删 / **非** pure-ld）
  - ✅ wave747：**R4 mode-policy 吞并** — `rebuild_leaves` 默认 catalog KEY + shell mode 表；
    pattern 体仍 make（R4 body residual）；export 叶 inventory/legacy
  - ✅ wave748–755：**R1 八族** — `ensure_host_cc_seed_o.sh` 单 body + catalog 八 KEY；
    Makefile 薄转调；`./xbuild host-cc-seed` umbrella
  - ✅ wave757：**R3 cold-else body** — `rebuild_leaves` residual → `ensure try-r3-cold`
    （catalog `R3_COLD_SEED_OBJS`）；PREFER thin 仍 make
  - ✅ wave756：**R4 pure-R1 body** — `rebuild_leaves` → `ensure try-r1`（catalog membership）；
    bridge 无 make；non-R1 residual 仍 make
  - ✅ wave758：**R4 residual thin_glue → R1 seed-map**（G.7 有则补全）—
    `parser_asm_thin_glue` pure host-cc；user-asm shell-only
  - ✅ wave759：**R4 residual glue-standalone → R1 seed-map**（G.7 有则补全）—
    `pipeline_glue_standalone` pure host-cc；glue shell-only
  - ✅ wave760：**R2 panic cold try-r2** — catalog `DRIVER_SEED_PANIC_OBJS`；
    stamp+UNAME 选源；panic shell-only；PREFER thin residual
  - ✅ wave762：**R2 typeck_f64/crt0 try-r2** — catalog `DRIVER_SEED_TYPECK_F64_OBJS` +
    `DRIVER_SEED_CRT0_OBJS`；host pick `.s` / mingw seed；Makefile+g05+build_xlang_asm 收敛
  - ✅ wave763：**R3 PREFER thin try-r3-prefer** — catalog `R3_COLD_SEED_OBJS` 九叶；
    thin+rest 单 body（prefer 失败 → cold ensure_one）；Makefile thin
  - ✅ wave764：**g05 R3_COLD r3-prefer-family** — 同 catalog 体；full→thin ladder；
    删 g05 双 hybrid
  - ✅ wave765–767：**g05 labi/rt/pipeline_abi/ldpc try-*-prefer** — 单 body；g05/Makefile thin-call
  - ✅ wave768：**g05 target_cpu try-target-cpu-prefer** — flags.x + rest FROM_X → `$CC -r`
  - ✅ wave769–771：**g05 L2-asm / async / other-L2 try-*-prefer** — 表驱动；g05/Makefile thin-call
  - ✅ wave772：**11.1.4 pure-ld** — cold phase1/final
  - ✅ wave773：**11.1.4 g05 pure-ld** — `pure_ld_shared` + g05_relink
  - ✅ wave774：**11.1.4 drop silent CC fallback** — cold+g05 pure-ld required；FORCE_CC/ineligible named residual only

🟡 **11.3.1 路径 · 叶 pattern residual**（**非**物理删）

路径波次（一行一项 · 库存 → 吞体；完整流水见 `LEAF_PATTERN_RESIDUAL.md` / `自举进度.md` §6）：

- **wave746** · 库存（命名 R1–R6）
- **wave747** · R4 mode
- **wave748–755** · R1 八族
- **wave756** · pure-R1 try-r1
- **wave757** · R3 cold-else try-r3-cold
- **wave758** · thin_glue seed-map
- **wave759** · glue-standalone seed-map
- **wave760** · R2 panic cold try-r2
- **wave761** · gen/pipeline try-gen-x
- **wave762–839** · R2/R3 prefer · phys-del prep · B7A–D · list→mk · FORCE dep-thin（见下 bullet）
- **wave841–845** · B7C shell-primary（typeck/codegen · x-compiler · self · parser smoke · xlang-x-pipeline）
- **wave846** · B7C xlang-x shell-primary（host-cc product link）
- **wave847** · B7C xlang-no-c-frontend shell-primary（host-cc product link）
- **wave848** · B7C bootstrap-driver-seed-x-frontend shell-primary（host-cc experiment link）
- **wave849** · B7C relink-xlang-lexer shell-primary（host-cc product link + XLANG_C sync）
- **wave850** · B7B RELINK_PRODUCT_LINK bag → composites.mk（BTC/RXL product link 单权威）
- **wave851** · B7B XXL/BS/XNC full link bags → composites + archaeology_experiment（3 bags）
- **wave852** · B7B BXF full link bag → archaeology_experiment（bootstrap-driver-seed-x-frontend）
- **wave853** · B7B seed phase1/final full link bags → composites（SEED_LINK_OBJS；2 bags）
- **wave854** · B7B seed-gate REQUIRED_OBJS bags → composites + archaeology（RXL/XXL/XNC；3 bags）
- **wave855** · B7B seed-gate REQUIRED shell-load from mk（RXL/XXL/XNC；Makefile 去 multi-token REQUIRED env）
- **wave858** · B7B LEGACY xlang-c link shell-primary（export-legacy-xlang-c-link-objs + CFLAGS reuse product）
- **wave860** · B7B driver_leaf BASE_CFLAGS multi-token shell-load（export-driver-leaf-base-cflags；8 leaves）
- **wave861** · B7B rt_* multi-token -I CFLAGS hygiene（5 RT_SEED_SLICE leaves；plain CFLAGS= try-heat）
- **wave862** · B7B try-heat CFLAGS/PIPELINE_GEN bulk shell-load（export-try-heat-cflags；114 recipes 去 multi-token CFLAGS inject）
- **wave863** · B7B class-G filter CFLAGS/PIPELINE_GEN shell-load hygiene（4 filter FORCE recipes 去 multi-token CFLAGS inject；try-heat CC-only）
- **wave864** · B7B leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene（3 leaves：pipeline_abi / runtime_driver_no_c / parser_asm_thin_glue；shell `_DEFAULT_*` 权威）
- **wave865** · B7B migrate/bootstrap multi-token CFLAGS shell-load（export-try-heat-cflags；8 recipes：migrate 4 + BTC 2 + XXP/BXC 2）
- **wave866** · B7B build-tool CFLAGS shell-load + WIN32_O_CFLAGS leaf drop（export-try-heat-cflags；2 recipes：build-tool + crt0_mingw）
- **wave867** · B7B archaeology host-pick LD_R_MULTIDEF_FLAGS leaf drop（4 recipes：net-o-stub/openssl/mbedtls + sqlite-o-stub；shell uname 默认）
- **wave868** · B7C bootstrap-driver-bstrict-relink shell-primary（1 phony → relink_xlang_asm_bstrict_runtime_objs.sh；G.7 有则补全 dual body）
- **wave869** · B7C bootstrap-driver-crt0 shell-primary（1 phony → bootstrap_driver_crt0.sh；G.7 有则补全 dual body · crt0 log gates）
- **wave870** · B7C check-7.2 shell-primary（1 phony → check_7_2.sh；seed stage1/stage2 smoke · ≠ bstrict path）
- **wave871** · B7C check-6.4 shell-primary（1 phony → check_6_4.sh；seed emit-C + host-cc + exit 42）
- **wave872** · B7C bootstrap-driver-hybrid shell-primary（1 phony → bootstrap_driver_hybrid.sh；B-hybrid build_xlang_asm + replace/soft-skip；alias -asm）
- **wave873** · B7C regen-lsp-gens-x shell-primary（1 phony → regen_lsp_gens_x.sh；XLANG_X gate + rm four gens + make file targets）
- **wave874** · B7C build-via-tool shell-primary（1 phony → build_via_tool.sh；run host build_tool → TARGET + OK；xbuild dual retired）
- **wave875** · B7C size/perf-baseline shell-primary（2 phonies → stage8_baseline.sh）
- **wave876** · B7C default xlang-c alias shell-primary（1 target → ensure_xlang_c.sh；LEGACY 仍 wave858）
- **wave877** · B7B gen ensure multi-token env inject hygiene（20 recipes → thin `@bash ensure_*_gen`；shell 默认权威）
- **wave878** · B7B migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene（4 recipes → thin `@sh migrate_x_objs`；shell 默认权威）
- **wave879** · B7B stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene（13 recipes → thin `@sh`/`@bash`；shell 默认权威）
- **wave880** · B7B ENSURE=0 / OUT=$@ / all OPT inject hygiene（7 recipes → thin `@bash`/`@sh`；MAKELEVEL shell 默认权威）
- **wave881** · B7B try-heat XLANG_G05_PREFER_X_O inject hygiene（31 recipes → CC-only thin-call；PREFER 经 make CLI/env + shell 默认；net XLANG= 同删）
- **wave882** · B7B residual single-token TARGET= inject hygiene（10 recipes → drop TARGET=；shell TARGET:-xlang + CLI auto-export）
- **wave884** · B7B residual single-token CC= inject hygiene（118 recipes → drop CC=；shell resolve_host_cc + CLI/env；keep LD/pipeline multi bags）
- **wave883** · B7B residual single-token MAKE= inject hygiene（24 recipes → drop MAKE=；shell MAKE:-make + GNU make auto-export；keep ENSURE_SEED/NO_REPLACE）
- **wave885** · B7B residual G05_SYNC inject hygiene（2 recipes → relink-xlang `--no-sync` + xlang_asm bare；drop G05_SYNC_ASM= recipe inject）
- **wave886** · B7B residual LD + pipeline bag inject hygiene（2 recipes → cfg_eval drop LD/LD_RELFLAGS；pipeline_x drop PIPELINE bags；shell LD defaults + mk DEPS load）
- **wave887** · B7B residual terminal env inject hygiene（6 recipes → XLANG_C ensure `$@`；cc_inc_tu PEERS seed-map；drop ENSURE_SEED/NO_REPLACE/XLANG=；shell 默认 + CLI/env）
- **wave888** · B7B residual recipe thin-call form hygiene（22 recipe sites → drop dual chmod +x；@./scripts/ 与 sh ./… → 纯 `@bash scripts/…`）
- **wave889** · B7B residual non-thin recipe body / form hygiene（10 sites → drop dual `@mkdir -p build_asm` + panic stamp body；bare `sh scripts/cc_inc_tu` → `@bash`；`legacy-xlang-c-ready` nested `$(MAKE)` → thin ensure）
- **wave890** · B7B residual bulk `@sh` → `@bash` thin-call form hygiene（77 sites → formal_mod 38 + std_x 22 + migrate/eoo/g05/clean/token/refresh；纯 `@bash scripts/…`）
- **wave891** · B7B residual non-thin HOST_CC + SKIP_SUBSCRIPT body hygiene（2 sites → host_cc_objs_core_link.sh + bootstrap_driver_seed soft-skip）
- **wave892** · B7B residual terminal `@echo` + last multi-token `-I` form hygiene（13 sites → dual echo drop 3 · pure echo→`@true` 9 · last `cc_inc_tu` `-I` drop 1）
- **wave893** · B7B residual verify-selfhost thin-call form hygiene（2 sites → body under `scripts/` · pure `@bash scripts/…` · root shim for CI/tests）
- **wave894** · B7B formal_mod product edges list→mk + multi-target FORCE thin（38 → `mk/formal_mod_product_objs.mk` · Makefile multi-target ensure）
- **wave895** · B7B std_x product edges list→mk + multi-target FORCE thin（22 → `mk/std_x_product_objs.mk` · Makefile multi-target ensure）
- **wave896** · B7B driver_leaf product edges list→mk + multi-target FORCE thin（8 → `mk/driver_leaf_product_objs.mk` · Makefile multi-target ensure）
- **wave897** · B7B B2 std_core hybrid product edges list→mk + multi-target FORCE thin（5 → `mk/std_core_hybrid_product_objs.mk` · Makefile multi-target try-heat）
- **wave898** · B7B RT_SEED_SLICE multi-target FORCE thin try-heat（5 → `$(RT_SEED_SLICE_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave899** · B7B R1_CORE_SEED multi-target FORCE thin try-heat（5 → `$(R1_CORE_SEED_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave900** · B7B R1_FRONTEND_GLUE multi-target FORCE thin try-heat（3 → `$(R1_FRONTEND_GLUE_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave901** · B7B R1_MAIN_RUNTIME multi-target FORCE thin try-heat（7 → `$(R1_MAIN_RUNTIME_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave902** · B7B R1_ALIAS_STUBS multi-target FORCE thin try-heat（8 → `$(R1_ALIAS_STUBS_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave903** · B7B R1_EXTRA_CFLAGS multi-target FORCE thin try-heat（5 → `$(R1_EXTRA_CFLAGS_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave904** · B7B R1_MISC_BASENAME multi-target FORCE thin try-heat（9 → `$(R1_MISC_BASENAME_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave905** · B7B R1_SEED_MAP multi-target FORCE thin try-heat（5 → `$(R1_SEED_MAP_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave906** · B7B R3_COLD multi-target FORCE thin try-heat（9 → `$(R3_COLD_SEED_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- **wave859** · B7B XXP/BXC multi-token bag shell-load（export-xxp-link-bags + export-bxc-link-objs；2 shells）
- **wave857** · B7B archaeology LINK_CFLAGS shell-load via make export leaves（4 bags / 6 shells；配方去 multi-token CFLAGS/FLAGS env）
- **wave856** · B7B archaeology LINK_OBJS shell-load via make export leaves（5 bags / 6 shells；nested expand；配方去 multi-token LINK_OBJS env；CFLAGS → wave857）
- **wave907** · B7B ASYNC_THREE multi-target FORCE thin try-heat（3 → `$(ASYNC_THREE_SEED_OBJS)` in `mk/driver_seed_r_lists.mk` · G.7 有则补全）
- ✅ **B1_RUNTIME_OS multi-target FORCE thin**（wave908 · 23 · `$(B1_RUNTIME_OS_SEED_OBJS)` 新 list in mk · G.7 有则补全 try-runtime-os-prefer · Makefile multi-target FORCE thin try-heat · **非**物理删）
- ✅ **GEN_X multi-target FORCE thin**（wave909 · 4 · `$(GEN_X_SEED_OBJS)` 新 list in mk · G.7 try-gen-x map · Makefile multi-target FORCE thin try-heat · **非**物理删）
- ✅ **GEN_C_TO_O (B4) multi-target FORCE thin**（wave910 · 5 · `$(GEN_C_TO_O_SEED_OBJS)` 新 list in mk · G.7 try-gen-c-to-o map · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **B3_LSP_SAT multi-target FORCE thin**（wave911 · 2 · `$(B3_LSP_SAT_SEED_OBJS)` 新 list in mk · G.7 try-lsp-sat-prefer map · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **FMT_CHECK multi-target FORCE thin**（wave912 · 2 · `$(FMT_CHECK_SEED_OBJS)` 新 list in mk · G.7 try-other-l2-prefer map · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **R2 CRT0 multi-target FORCE thin**（wave913 · 6 · `$(DRIVER_SEED_CRT0_OBJS)` 迁 r_lists · G.7 try-r2 · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **R2 TYPECK_F64 multi-target FORCE thin**（wave914 · 1 · `$(DRIVER_SEED_TYPECK_F64_OBJS)` 迁 r_lists · G.7 try-r2 host pick · UNAME ifeq hard-error 面收掉 · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **R2 PANIC multi-target FORCE thin**（wave915 · 1 · `$(DRIVER_SEED_PANIC_OBJS)` 迁 r_lists · G.7 try-heat→try-r2-prefer/try-r2 · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- ✅ **B5 CFG_EVAL multi-target FORCE thin**（wave916 · 1 · `$(DRIVER_SEED_CFG_EVAL_OBJS)` = `src/lexer/cfg_eval.o` 迁 r_lists · G.7 try-heat→try-cfg-eval-ladder · per-leaf recipe → multi-target FORCE thin try-heat · **非**物理删 · thin edges + mk lists hybrid 仍 residual）
- **open** · thin edges + mk lists hybrid（cc_inc_tu / net_merge …）· → tip Windows → 双端 L4 → explicit auth 真删  # post-wave916 B5 CFG_EVAL multi

**状态明细**（一行一项）：

- ✅ 权威图：`compiler/docs/LEAF_PATTERN_RESIDUAL.md`
- ✅ 机检：`leaf_pattern_residual.sh` dump/classes/`--check`；`./xbuild leaf-patterns`
- ✅ R1 host-cc seed · R2 UNAME stamp · R3 thin+rest · R4 rebuild pattern bodies · R5 CI all · R6→11.1.4
- ✅ R4 mode+list shell（wave747）
- ✅ R4 pure-R1 body shell（wave756 try-r1）
- ✅ R3 cold-else body shell（wave757 try-r3-cold）
- ✅ thin_glue seed-map（wave758）
- ✅ glue-standalone seed-map（wave759）
- ✅ R2 panic cold try-r2（wave760）
- ✅ gen/pipeline try-gen-x（wave761）
- ⬜ R4 remaining residual 离 make 图（gen/pipeline-x 等，后序 B 桶吞）
- ✅ R1 八族 body（wave748–755）+ thin_glue/glue-standalone 并入 seed-map
- ✅ R2 typeck_f64/crt0 try-r2（wave762）
- ✅ R3 PREFER thin R3_COLD nine try-r3-prefer（wave763）
- ✅ g05 R3_COLD r3-prefer-family（wave764）
- ✅ g05 labi/rt/pipeline_abi/ldpc/target_cpu/l2-asm/async/other-l2 try-*-prefer（wave765–771）
- ✅ R6 pure-ld（wave772）
- ✅ g05 pure-ld（wave773）
- ✅ drop silent CC fallback（wave774）
- ✅ fmt dual（wave775 try-other-l2-prefer fmt_core）
- ✅ panic PREFER try-r2-prefer（wave776）
- ✅ **phys-del prep inventory**（wave777：B1–B7 命名桶 · 非删 Makefile · 非吞体）
- ✅ **Windows gate + dual-end verify**（wave778：`PHYS_DEL_WINDOWS_GATE` · `MG_VERIFY_DUAL_END=mac_plus_ubuntu_required` · 金标 Ubuntu；**禁** mac 单端宣称波绿；**禁** Windows 未绿就物理删 Makefile）
- ✅ **B1** try-runtime-os-prefer（wave779 · 23 thin-call）
- ✅ **B2** try-std-core-prefer（wave780 · 5 thin-call）
- ✅ **B3** try-lsp-sat-prefer（wave781 · 2 thin-call）
- ✅ **B4** try-gen-c-to-o（wave782 · 5 thin-call；body=`ensure_gen_x_o.sh` 扩展；**非** try-gen-x catalog）
- ✅ **B5** try-cfg-eval-ladder（wave783 · 1 thin-call；cfg_eval multi-ladder）
- ✅ **B6** R5 CI `compiler_all_ci.sh`（wave784 · xbuild/Makefile thin-call；叶图仍 B7）
- ✅ **B7 DAG inventory**（wave785 · 子桶 B7A–D · 考古 `$(CC) -c` thin → migrate/ensure；**非**物理删 · `BODY_SWALLOWED=0`）
- ✅ **B7D host-cc product link**（wave786 · 默认 `make xlang` → g05_prepare_and_relink；禁 OBJS_CORE UNDEF；**非**物理删）
- ✅ **B7A cold residual_make=0 + B7B list honesty**（wave787 · 冷七模式 shell only；heat thin-edge residual；列表仍 mk+catalog；**非**物理删）
- ✅ **B7B shell-primary catalog**（wave788 · mk 解析 0-make；make export 逃生；R1/R3/RT → `mk/driver_seed_r_lists.mk`；**非**物理删）
- ✅ **B7A heat try-heat**（wave789 · shell auto-dispatch prefer→R1→R2→gen；`./xbuild heat-o`；Makefile thin-call 边仍 residual；**非**物理删）
- ✅ **B7A heat thin-unify**（wave790 · Makefile 115 ensure recipes → `try-heat` only；mode 名注释考古；dep 边 residual；**非**物理删）
- ✅ **B7A heat dep-edge thin**（wave791 · 28 pure `runtime_*` prereq → FORCE+ensure；shell mtime；**非**物理删）
- ✅ **B7A heat dep-edge thin pure seed+.x residual**（wave792 · +31 → **59 FORCE**；排除 hdr/twin/cfg_eval/asm/gen；**非**物理删）
- ✅ **B7A heat dep-edge thin pure seed+.x+.h residual**（wave793 · +19 → **78 FORCE**；`seed_project_hdrs_newer`；**非**物理删）
- ✅ **B7A heat dep-edge thin twin·mkflags·leftover**（wave794 · +8 → **86 FORCE**；twin hdr + `force_thin_makefile_flags_newer`；**非**物理删）
- ✅ **B7A heat dep-edge thin cfg_eval·asm·std**（wave795 · +15 → **101 FORCE**；cfg_eval multi · crt0/typeck_f64 · path/runtime/process；**非**物理删；residual net·stamp·gen_x）
- ✅ **B7A heat dep-edge thin net·panic·gen_x**（wave796 · +11 → **112 FORCE**；net multi-merge mtime · panic stamp · gen_x/B4 try-heat；**非**物理删；residual orch / 物理删）
- ✅ **B7A heat dep-edge thin orch**（wave797 · +1 → **113 FORCE**；orch seed/.x + `pipeline_gen.c` + types.inc mtime；**HEAT_RESIDUAL=0**；**非**物理删；residual 物理删 only）
- ✅ **phys-del preflight**（wave798 · readiness 机检 · blockers 命名 · Windows min-gate 命令权威；**非**物理删 · **非** Windows 绿 · `WINDOWS_GATE_STATUS=not_reproven_this_tip`）
- ✅ **phys-del execute-gate**（wave799 · `phys_del_makefile_gate.sh` / `./xbuild phys-del-gate` 硬拒删 · dry-run · MSYS runbook；**非**物理删 · **非** Windows 绿 · `DELETE_ALLOWED=0`）
- ✅ **Windows proof stamp harness**（wave800 · `--run-windows-gate` 写 stamp · `--verify-windows-proof` tip 校验；**非** STATUS 翻转 · **非**物理删 · `PROOF_STATUS_FLIP=0`）
- ✅ **STATUS flip prep / preview**（wave801 · `--status-flip-preview` 有 proof 后打印翻转计划；**非** STATUS 翻转 · **非**物理删 · `APPLIED=0` · TARGET=`reproven_green` · ENDGAME 保持 0）
- ✅ **STATUS flip apply harness**（wave802 · `--status-flip-apply` 需 proof + confirm env；`--check` 仅 temp leaf；ENDGAME 保持 0）
- ✅ **STATUS flip commit honesty**（wave803 · `--status-flip-commit-honesty` pre/post 契约 + co-change 清单；`DELETE_ALLOWED=0` · ENDGAME 保持 0）
- ✅ **Windows min-gate proof + STATUS apply**（wave804 · MSYS2 B-hybrid 绿 + proof tip `bb8f07263` + Mac verify · STATUS=`reproven_green` · `TREE_APPLIED=1` · **ENDGAME 仍 0** · **非**物理删）
- ✅ **ENDGAME arm prep/preview**（wave805 · `--endgame-preview` · TREE_ARMED=0 · ENDGAME 仍 0 · **非** arm · **非**物理删）
- ✅ **ENDGAME arm apply harness**（wave806 · `--endgame-arm-apply` · confirm 闸门 · TREE_ARMED=0 · 树 ENDGAME 仍 0 · **非**树 arm · **非**物理删）
- ✅ **ENDGAME arm commit honesty**（wave807 · `--endgame-arm-commit-honesty` · pre_arm/post_arm · TREE_ARMED=0 · 树 ENDGAME 仍 0 · **非**树 arm · **非**物理删）
- ✅ **TREE_ARMED arm**（wave808 · `ENDGAME=1` · `TREE_ARMED=1` · Makefile 仍在 · `--delete` 仍 never-rm · **非**物理删）
- ✅ **delete-body prep/preview**（wave809 · `--delete-body-preview` · BODY_SHIPPED=0 · Makefile 仍在 · **非**物理删）
- ✅ **delete-body commit honesty**（wave810 · `--delete-body-commit-honesty` · pre_ship 清单 · BODY_SHIPPED=0 · Makefile 仍在 · **非**物理删）
- ✅ **std_x product hybrid thin**（wave811 · 22 叶 → `xlang_compile_std_x` `auto|auto-soft|auto-soft-merge` · Makefile thin-call · **非**物理删 · formal_mod/B2 图仍 residual）
- ✅ **formal_mod shell-primary catalog**（wave812 · 38 叶 → `xlang_compile_std_module ensure` · 表驱动 bare/sources/fs_formal · Makefile thin-call · **非**物理删 · thin edges + B2 + B7B lists 仍 residual）
- ✅ **B7B STD_AND_PANIC_O list → mk**（wave813 · `mk/std_and_panic_objs.mk` · 65 base + Linux freestanding · Makefile include only · **非**物理删 · thin edges + B2 + 其它 mk lists 仍 residual）
- ✅ **driver_leaf shell-primary catalog**（wave814 · 8 leaves · `driver_leaf_x_to_o.sh ensure` · rename/dirs 进 catalog · **非**物理删 · thin edges + B7B lists 仍 residual）
- ✅ **archaeology host-pick phonies**（wave815 · 4 phonies · `archaeology_host_pick_phony.sh ensure` · net-o-stub/openssl/mbedtls + sqlite-o-stub · host via `xlang_compile_std_x` · **非**物理删 · thin edges + B7B lists 仍 residual）
- ✅ **DRIVER_SUBCMD list→mk**（wave816 · 7 · `mk/driver_subcmd_objs.mk` · Makefile include only · catalog parse mk · **非**物理删 · thin edges + 其它 B7B lists 仍 residual）
- ✅ **PIPELINE_X list→mk**（wave817 · satellite 9 · `mk/pipeline_x_objs.mk` · BASE/FRONTEND/SATELLITE/LINK/SUPPORT + PIPELINE_LIBS · Makefile include only · catalog parse mk · **非**物理删 · thin edges + 其它 B7B lists 仍 residual）
- ✅ **SEED_MODE list→mk**（wave818 · product SUPPORT_EXTRA 3 · `mk/driver_seed_mode_objs.mk` · RUNTIME_O/FRONTEND_EXTRA/SUPPORT_EXTRA/LINK_FLAGS/RUNTIME_REBUILD · Makefile include only · catalog parse mk · **非**物理删 · thin edges + 其它 B7B lists 仍 residual）
- ✅ **SEED_LINK_PICKS list→mk**（wave819 · product GLUE 2 · `mk/driver_seed_link_picks.mk` · MAIN_LINK/LEXER_AST/LSP_DIAG/PREPROCESS/GLUE · Makefile include only · catalog parse mk · **非**物理删 · thin edges + OBJS_CORE/其它 lists 仍 residual）
- ✅ **OBJS_CORE list→mk**（wave820 · product 16 · `mk/objs_core.mk` · archaeology incomplete + LEGACY layout · Makefile include only · catalog parse mk · **非**物理删 · thin edges + 其它 B7B lists 仍 residual）
- ✅ **ARCH_EXPERIMENT list→mk**（wave821 · EXPERIMENT 7 · `mk/archaeology_experiment_objs.mk` · X_FRONTEND_EXPERIMENT + NO_C_FRONTEND · Makefile include only · catalog parse mk · **非**物理删 · thin edges + 其它 B7B lists 仍 residual）
- ✅ **RELINK_LEGACY list→mk**（wave822 · RELINK fixed 14 · `mk/driver_seed_composites.mk` · RELINK_XLANG_PREREQS + LEGACY_XLANG_C_* · Makefile include only · catalog parse composites · **非**物理删 · thin edges + SOURCE_DEPS/std_core graph 仍 residual）
- ✅ **SOURCE_DEPS list→mk**（wave823 · fixed 19 · `mk/x_source_deps.mk` · SRCS/MAIN_X_DEPS/PREPROCESS_X_DEPS/PIPELINE_*_DEPS · Makefile include only · catalog parse mk · ensure_driver_gen 自 mk 加载 · **非**物理删 · thin edges + E_DIRS/std_core graph 仍 residual）
- ✅ **E_DIRS list→mk**（wave824 · dir-roots 26 · `mk/x_e_dirs.mk` · MAIN_X_E_DIRS/LSP_X_E_DIRS/PIPELINE_X_E_DIRS · Makefile include only · catalog parse mk · ensure_driver_gen/lsp_pipeline/archaeology + driver_leaf kind=lsp 自 mk 加载 · **非**物理删 · thin edges + std_core product make graph 仍 residual）
- ✅ **std_x shell-primary catalog**（wave825 · 22 叶 · `xlang_compile_std_x ensure` · mode|x_path 表进 shell · Makefile thin-call ensure only · **非**物理删 · formal_mod + B2 + thin edges + mk lists 仍 residual）
- ✅ **formal_mod FORCE dep-thin**（wave826 · 38 叶 · Makefile FORCE+ensure only · shell 拥 source mtime · **非**物理删 · B2 try-heat + thin edges + mk lists 仍 residual）
- ✅ **std_x FORCE dep-thin**（wave827 · 22 叶 · Makefile FORCE+ensure only · shell 拥 source mtime · **非**物理删 · formal_mod FORCE + B2 try-heat + thin edges + mk lists 仍 residual）
- ✅ **std_x product edges list→mk multi-target**（wave895 · 22 · `mk/std_x_product_objs.mk` · Makefile multi-target FORCE thin ensure · **非**物理删 · thin edges + B2 + 其它 mk lists 仍 residual）
- ✅ **formal_mod product edges list→mk multi-target**（wave894 · 38 叶 · `mk/formal_mod_product_objs.mk` + `$(FORMAL_MOD_PRODUCT_OBJS)` FORCE ensure · shell catalog 体权威 · **非**物理删 · thin edges + B2 + 其它 mk lists 仍 residual）
- ✅ **driver_leaf product edges list→mk multi-target**（wave896 · 8 · `mk/driver_leaf_product_objs.mk` · Makefile multi-target FORCE thin ensure · **非**物理删 · thin edges + 其它 mk lists 仍 residual）
- ✅ **B2 std_core hybrid product edges list→mk multi-target**（wave897 · 5 · `mk/std_core_hybrid_product_objs.mk` · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + 其它 mk lists 仍 residual）
- ✅ **RT_SEED_SLICE multi-target FORCE thin**（wave898 · 5 · `$(RT_SEED_SLICE_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · remaining R1 multi / thin edges 仍 residual）
- ✅ **R1_CORE_SEED multi-target FORCE thin**（wave899 · 5 · `$(R1_CORE_SEED_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · remaining R1 multi / thin edges 仍 residual）
- ✅ **R1_FRONTEND_GLUE multi-target FORCE thin**（wave900 · 3 · `$(R1_FRONTEND_GLUE_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · remaining R1 multi / thin edges 仍 residual）
- ✅ **R1_MAIN_RUNTIME multi-target FORCE thin**（wave901 · 7 · `$(R1_MAIN_RUNTIME_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · remaining R1 multi / thin edges 仍 residual）
- ✅ **R1_ALIAS_STUBS multi-target FORCE thin**（wave902 · 8 · `$(R1_ALIAS_STUBS_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · remaining R1 multi / thin edges 仍 residual）
- ✅ **R1_EXTRA_CFLAGS multi-target FORCE thin**（wave903 · 5 · `$(R1_EXTRA_CFLAGS_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删）
- ✅ **R1_MISC_BASENAME multi-target FORCE thin**（wave904 · 9 · `$(R1_MISC_BASENAME_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删）
- ✅ **R1_SEED_MAP multi-target FORCE thin**（wave905 · 5 · `$(R1_SEED_MAP_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删 · R1 multi-target family closed · thin edges + mk lists hybrid 仍 residual）
- ✅ **R3_COLD multi-target FORCE thin**（wave906 · 9 · `$(R3_COLD_SEED_OBJS)` 既有 mk · G.7 有则补全 · Makefile multi-target FORCE thin try-heat · **非**物理删）
- ✅ **ASYNC_THREE multi-target FORCE thin**（wave907 · 3 · `$(ASYNC_THREE_SEED_OBJS)` 新 list in mk · G.7 有则补全 try-async-prefer · Makefile multi-target FORCE thin try-heat · **非**物理删 · thin edges + B1/gen-x hybrid 仍 residual）
- ✅ **driver_leaf FORCE dep-thin**（wave828 · 8 叶 · Makefile FORCE+ensure only · shell 拥 source mtime · **非**物理删 · B2 try-heat + thin edges + mk lists 仍 residual）
- ✅ **gen.c FORCE dep-thin**（wave829 · 17 叶 · Makefile FORCE+ensure_*_gen only · bash recipe · shell 拥 pin/FORCE_REGEN · **非**物理删 · B2 + thin edges + mk lists 仍 residual）
- ✅ **ast_gen2 FORCE dep-thin**（wave830 · 1 叶 · Makefile FORCE+ensure_ast_gen2 only · bash recipe · shell 拥 pin/FORCE_REGEN/-E+fix_slim · **非**物理删 · B2 + thin edges + mk lists 仍 residual）
- ✅ **src-edge FORCE dep-thin**（wave831 · 7 叶 · parser_asm_thin_glue FORCE+try-heat + 6× cc_inc_tu FORCE · shell 拥 seed/slice mtime · **非**物理删 · migrate *_x.o gen.c 边 + thin edges + B2 + mk lists 仍 residual）
- ✅ **migrate *_x FORCE dep-thin**（wave832 · 3 叶 · parser_x/typeck_x/codegen_x FORCE+migrate_x_objs · shell 拥 gen.c mtime · **非**物理删 · ~~pipeline_glue_types.inc~~（wave833）+ thin edges + B2 + mk lists 仍 residual）
- ✅ **pipeline_glue_types FORCE dep-thin**（wave833 · 1 叶 · FORCE+ensure_pipeline_glue_types · shell 拥 gen/extract mtime + ABI guard · **非**物理删 · ~~bootstrap-pipeline~~（wave834）+ thin edges + B2 + mk lists 仍 residual）
- ✅ **bootstrap-pipeline FORCE shell-primary**（wave834 · 1 叶 · FORCE+ensure_lsp_pipeline_gen pipeline · G.7 有则补全 wave739 body · **非**物理删 · ~~filtered.o~~（wave835）+ thin edges + B2 + mk lists 仍 residual）
- ✅ **bootstrap_seed filtered.o FORCE dep-thin**（wave835 · 4 叶 · FORCE+filter_* ensure · shell mtime + try-heat SRC · g05 同 path · **非**物理删 · thin edges + B2 + mk lists 仍 residual）
- ✅ **product object-path cp-alias FORCE dep-thin**（wave836 · 3 叶 · FORCE+ensure_cp_alias_o · shell mtime + try-heat SRC · **非**物理删 · thin edges + B2 + mk lists 仍 residual）
- ✅ **pipeline_gen.c FORCE dep-thin**（wave837 · 1 叶 · FORCE+ensure_lsp_pipeline_gen pipeline · G.7 有则补全 wave739 body · 收 empty-prereq 残 · **非**物理删 · thin edges + B2 + mk lists 仍 residual）
- ✅ **bootstrap_xlangc FORCE dep-thin**（wave838 · 1 叶 · FORCE+select_bootstrap_xlangc · G.7 有则补全 · 收 create.sh make-graph 残 · **非**物理删 · thin edges + B2 + mk lists 仍 residual）
- ✅ **archaeology host-pick FORCE dep-thin**（wave839 · 4 叶 · FORCE+archaeology_host_pick_phony · G.7 有则补全 · 收 script-only prereq 残 · **非**物理删 · thin edges + B2 + mk lists 仍 residual）
- ✅ **bootstrap-typeck/codegen shell-primary**（wave841 · 2 叶 · bootstrap_typeck_codegen.sh · ensure_migrate_gen FORCE_REGEN + migrate_x_objs + BTC_* link · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **bootstrap-x-compiler shell-primary**（wave842 · 1 叶 · bootstrap_x_compiler.sh · TARGET_x -x -E + host-cc -c typeck_x_x + BXC_LINK_OBJS · **非** migrate · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **bootstrap-self shell-primary**（wave843 · 1 叶 · bootstrap_self.sh · stage1 snapshot + satellite ensure + stage2 host-cc link + out_self smoke · BS_LINK_OBJS from mk · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **bootstrap-parser/parse-file shell-primary**（wave844 · 2 叶 · bootstrap_parser_smoke.sh · parser.x -o smoke + dual-path parse fixtures · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **xlang-x-pipeline shell-primary**（wave845 · 1 叶 · xlang_x_pipeline.sh · force pipeline_x.o + migrate/satellites + host-cc link TARGET_x · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **xlang-x shell-primary**（wave846 · 1 叶 · xlang_x.sh · seed gate + host-cc link product xlang-x · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **xlang-no-c-frontend shell-primary**（wave847 · 1 叶 · xlang_no_c_frontend.sh · seed gate + host-cc link archaeology no-C-frontend · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **bootstrap-driver-seed-x-frontend shell-primary**（wave848 · 1 叶 · bootstrap_driver_seed_x_frontend.sh · host-cc link archaeology `$(TARGET)_x_frontend` · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **relink-xlang-lexer shell-primary**（wave849 · 1 叶 · relink_xlang_lexer.sh · seed gate + host-cc link product TARGET + XLANG_C/bootstrap_xlangc sync · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **RELINK_PRODUCT_LINK bag → mk**（wave850 · composites.mk · `RELINK_PRODUCT_LINK_BASE/OBJS` · BTC typeck/codegen + RXL relink-lexer 三处 dual bag 收单权威 · fixed BASE **8** · Makefile expand only · **非**物理删 · thin edges + B2 + 其它 mk lists）
- ✅ **XXL/BS/XNC full link bags → mk**（wave851 · composites + archaeology_experiment · `XLANG_X_LINK_*` + `BOOTSTRAP_SELF_LINK_OBJS` + `XLANG_NO_C_FRONTEND_LINK_OBJS` · COUNT=**3** bags · Makefile expand only · **非**物理删 · thin edges + B2 + 其它 mk lists）
- ✅ **BXF full link bag → mk**（wave852 · archaeology_experiment · `DRIVER_SEED_X_FRONTEND_LINK_OBJS` · fixed multi-token **2** · Makefile expand only · **非**物理删 · thin edges + B2 + 其它 mk lists）
- ✅ **seed phase1/final full link bags → mk**（wave853 · composites · `BOOTSTRAP_DRIVER_SEED_{PHASE1,FINAL}_LINK_OBJS` · bags **2** · SEED_LINK_OBJS expand only · **非**物理删 · thin edges + B2 + 其它 mk lists）
- ✅ **seed-gate REQUIRED_OBJS bags → mk**（wave854 · composites + archaeology · `RELINK_XLANG_REQUIRED_OBJS`/`XLANG_X_REQUIRED_OBJS`/`XLANG_NO_C_FRONTEND_REQUIRED_OBJS` · bags **3** · fixed multi-token 6+12+3 · Makefile expand only · **非**物理删 · thin edges + B2 + 其它 mk lists） · 双端 L2 tip **`44f161811`**
- ✅ **seed-gate REQUIRED shell-load from mk**（wave855 · RXL/XXL/XNC 3 shells · `_mk_assign_val` 自 mk 加载 · Makefile 去 multi-token REQUIRED env · **非**物理删 · LINK env + thin edges + B2 + mk lists）
- ✅ **try-heat CFLAGS bulk shell-load**（wave862 · export-try-heat-cflags · 114 recipes 去 CFLAGS/PIPELINE_GEN inject · shell 未设时 make 展开 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **filter CFLAGS shell-load hygiene**（wave863 · 4 class-G filter FORCE · 去 multi-token CFLAGS/PIPELINE inject · filter→try-heat CC-only · **非**物理删 · thin edges + B2 + leaf-extra + mk lists）
- ✅ **leaf-extra RUNTIME_*/PARSER_* CFLAGS hygiene**（wave864 · 3 leaves · 去 multi-token leaf-extra inject · ensure shell `_DEFAULT_*` · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **migrate/bootstrap CFLAGS shell-load**（wave865 · 8 recipes · export-try-heat-cflags · 去 multi-token CFLAGS inject · **非**物理删 · thin edges + B2 + build-tool/WIN32 residual）
- ✅ **build-tool/WIN32 CFLAGS hygiene**（wave866 · 2 recipes · build-tool shell-load export-try-heat-cflags · crt0_mingw 去 WIN32_O inject · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **archaeology host-pick LD_R_MULTIDEF hygiene**（wave867 · 4 recipes · net-o-stub/openssl/mbedtls + sqlite-o-stub 去 multi-token `LD_R_MULTIDEF_FLAGS=` · shell `arch_ld_r_multidef_flags` uname 默认 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **bstrict-relink shell-primary**（wave868 · bootstrap-driver-bstrict-relink → relink_xlang_asm_bstrict_runtime_objs.sh · G.7 有则补全 dual body · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`c14777d2b`**
- ✅ **bootstrap-driver-crt0 shell-primary**（wave869 · bootstrap-driver-crt0 → bootstrap_driver_crt0.sh · G.7 有则补全 dual body · shell 拥 build_xlang_asm + crt0 log gates · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`74ebab839`**
- ✅ **check-7.2 shell-primary**（wave870 · check-7.2 → check_7_2.sh · G.7 有则补全 dual body · seed stage1/stage2 smoke · **非** bstrict 路径 · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`0dc9ae7b3`**
- ✅ **check-6.4 shell-primary**（wave871 · check-6.4 → check_6_4.sh · G.7 有则补全 dual body · seed emit-C + host-cc + exit 42 · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`63ef5a3b5`**
- ✅ **bootstrap-driver-hybrid shell-primary**（wave872 · hybrid/-asm → bootstrap_driver_hybrid.sh · G.7 有则补全 dual body · B-hybrid no SKIP_GEN + replace/soft-skip · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`c784aa7d5`**
- ✅ **regen-lsp-gens-x shell-primary**（wave873 · regen-lsp-gens-x → regen_lsp_gens_x.sh · G.7 有则补全 dual body · XLANG_X gate + rm four gens + make · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`e210fa41b`**
- ✅ **build-via-tool shell-primary**（wave874 · build-via-tool → build_via_tool.sh · G.7 有则补全 dual body + xbuild run_build_tool · host build_tool → TARGET · **非**物理删 · thin edges + B2 + mk lists） · 双端 L2 tip **`42b11f0fc`**
- ✅ **size/perf-baseline shell-primary**（wave875 · size/perf-baseline → stage8_baseline.sh · G.7 有则补全 · **非**物理删） · 双端 L2 tip **`9df290572`**
- ✅ **default xlang-c alias shell-primary**（wave876 · `$(XLANG_C)` → ensure_xlang_c.sh · SKIP_SUBSCRIPT soft-skip + cp · **非**物理删） · 双端 L2 tip **`15418b3ea`**
- ✅ **gen ensure multi-token env inject hygiene**（wave877 · 20 recipes · ensure_*_gen/ast_gen2/bootstrap-pipeline 去 MAKE/XLANG_*/FORCE/TIMEOUT inject · shell 默认权威 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **migrate multi-token env inject hygiene**（wave878 · 4 recipes · parser/typeck/codegen_x.o + migrate-x-objs 去 CC/PYTHON/MAKE inject · shell 默认权威 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **stage/bootstrap multi-token env inject hygiene**（wave879 · 13 recipes · clean/typeck/codegen/seed/relink/… 去 multi-token TARGET/CC/MAKE inject · shell 默认权威 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **ENSURE/OUT/OPT inject hygiene**（wave880 · 7 recipes · all/test_c/test_x/… 去 ENSURE/OUT/OPT multi inject · MAKELEVEL shell 默认 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **try-heat PREFER_X_O inject hygiene**（wave881 · 31 recipes · try-heat 去 PREFER/XLANG inject · CC-only · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual single-token TARGET= inject hygiene**（wave882 · 10 recipes · smoke/hybrid/crt0/tool/check-7.2 + bstrict/refresh 去 TARGET= · shell TARGET 默认 · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual single-token CC= inject hygiene**（wave884 · 118 recipes · try-heat/filter pure + cfg_eval/pipeline_x multi 去 CC= · shell resolve_host_cc + CLI/env · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual single-token MAKE= inject hygiene**（wave883 · 24 recipes · archaeology/driver_leaf/rebuild_leaves/host_stubs/phase1 + bstrict/refresh 去 MAKE= · shell MAKE 默认 + GNU make auto-export · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual G05_SYNC inject hygiene**（wave885 · 2 recipes · relink-xlang/xlang_asm 去 G05_SYNC_ASM= inject · shell `--no-sync` + default sync · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual LD + pipeline bag inject hygiene**（wave886 · 2 recipes · cfg_eval 去 LD/LD_RELFLAGS · pipeline_x 去 PIPELINE bags · shell LD defaults + mk DEPS load · **非**物理删 · thin edges + B2 + mk lists）
- ✅ **residual terminal env inject hygiene**（wave887 · 6 recipes · XLANG_C ensure `$@` · PEERS seed-map · drop ENSURE_SEED/NO_REPLACE/XLANG= · shell 默认 + CLI/env · **非**物理删 · thin edges + B2 + mk lists）
- ⬜ **B7 residual endgame · physical delete / 删 Makefile**
  - **须** lists/thin 残项 + Windows tip 复证 + Mac/Ubuntu L4 + explicit auth → ship 物理删体
  - 已闭（一行一项，摘要）：
    - heat closed · STATUS 绿 · TREE_ARMED arm ✅
    - delete-body honesty ✅
    - std_x thin / catalog / FORCE thin ✅
    - formal_mod catalog / FORCE thin ✅
    - STD_AND_PANIC · DRIVER_SUBCMD · PIPELINE_X · SEED_MODE · SEED_LINK_PICKS · OBJS_CORE · ARCH_EXPERIMENT · RELINK_LEGACY · SOURCE_DEPS · E_DIRS list→mk ✅
    - driver_leaf catalog / FORCE thin ✅
    - gen.c / ast_gen2 / src-edge / migrate *_x / pipeline_glue_types FORCE thin ✅
    - bootstrap-pipeline / pipeline_gen / bootstrap_xlangc / archaeology FORCE thin ✅
    - bootstrap-typeck/codegen · x-compiler · self · parser smoke · xlang-x-pipeline · xlang-x · xlang-no-c-frontend · seed-x-frontend · relink-xlang-lexer shell ✅
    - RELINK_PRODUCT_LINK bag → mk · XXL/BS/XNC bags → mk · BXF bag → mk · seed phase1/final bags → mk ✅
- ⬜ 物理删 `compiler/Makefile` 仍 ⬜（下项）

⬜ **11.3.1 删除 `compiler/Makefile`**

  - 前置（一行一项；**仍**须 lists/thin + tip Windows + 双端 L4 + explicit auth 后才可 ship 真删）：
    - 11.0 迁移表 100% 有主
    - 8.3/7/8 白名单 residual 可被 xbuild 编完或已为 0
    - wave746 库存类 R1–R5 有主 shell
    - wave777 prep 桶 B1–B7 有主
    - wave797 heat source-prereq closed
    - wave798 preflight
    - wave799 execute-gate 硬拒删
    - wave800 proof stamp harness
    - wave801–804 STATUS flip + Windows min-gate 绿
    - wave805 endgame-preview
    - wave806 endgame-arm-apply harness
    - wave807 endgame-arm-commit-honesty
    - wave808 TREE_ARMED arm ENDGAME=1
    - wave809 delete-body-preview
    - wave810 delete-body-commit-honesty
    - wave811 std_x hybrid thin
    - wave812 formal_mod shell-primary
    - wave813 STD_AND_PANIC list→mk
    - wave814 driver_leaf catalog
    - wave815 archaeology host-pick
    - wave816 DRIVER_SUBCMD list→mk
    - wave817 PIPELINE_X list→mk
    - wave818 SEED_MODE list→mk
    - wave819 SEED_LINK_PICKS list→mk
    - wave820 OBJS_CORE list→mk
    - wave821 ARCH_EXPERIMENT list→mk
    - wave822 RELINK_LEGACY list→mk
    - wave823 SOURCE_DEPS list→mk
    - wave824 E_DIRS list→mk
    - wave825 std_x shell-primary catalog
    - wave826 formal_mod FORCE dep-thin
    - wave827 std_x FORCE dep-thin
    - wave828 driver_leaf FORCE dep-thin
    - wave829 gen.c FORCE dep-thin
    - wave830 ast_gen2 FORCE dep-thin
    - wave831 src-edge FORCE dep-thin
    - wave832 migrate *_x FORCE dep-thin
    - wave833 pipeline_glue_types FORCE dep-thin
    - wave834 bootstrap-pipeline FORCE shell-primary
    - wave835 filtered.o FORCE dep-thin
    - wave836 cp-alias FORCE dep-thin
    - wave837 pipeline_gen.c FORCE dep-thin
    - wave838 bootstrap_xlangc FORCE dep-thin
    - wave839 archaeology host-pick FORCE dep-thin
    - wave841 bootstrap-typeck/codegen shell-primary
    - wave842 bootstrap-x-compiler shell-primary
    - wave843 bootstrap-self shell-primary
    - wave844 bootstrap-parser/parse-file shell-primary
    - wave845 xlang-x-pipeline shell-primary
    - wave846 xlang-x shell-primary
    - wave847 xlang-no-c-frontend shell-primary
    - wave848 bootstrap-driver-seed-x-frontend shell-primary
    - wave849 relink-xlang-lexer shell-primary
    - wave850 RELINK_PRODUCT_LINK bag → composites.mk
    - wave851 XXL/BS/XNC full link bags → mk
    - wave852 BXF full link bag → mk
    - wave853 seed phase1/final full link bags → mk
    - wave854 seed-gate REQUIRED_OBJS bags → mk
    - wave855 seed-gate REQUIRED shell-load from mk
    - wave872 bootstrap-driver-hybrid shell-primary
    - wave873 regen-lsp-gens-x shell-primary
    - wave874 build-via-tool shell-primary
    - **open** · lists/thin 残项（hybrid）+ tip Windows 复证 + Mac/Ubuntu L4 + explicit auth → ship 物理删体（终局波）
  - 验收 grep（全仓 · 不止 tests/analysis/docs）：
    ```
    rg -n 'make -C compiler|compiler/Makefile|\bmake\s+-C|\$\(MAKE\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    ```
    仅考古引用

⬜ **11.3.2 删除仓库根 `Makefile`**

  - 入口改为 `./xbuild` 或 `./xlang-build.sh` → xbuild

⬜ **11.3.3 删除/归档其它 make 碎片**

  - 子目录 Makefile（`editors/tree-sitter-xlang/Makefile` 等）
  - 生成 compile_commands 对 make 的依赖等

⬜ **11.3.4 「无 make + 无 cc」CI 闸门**

  - `PATH` 无 make **且** cc/gcc/clang 被 stub 拒绝时，xbuild cold-test + 129 仍绿
  - 验收 grep（同时搜 make 和 cc）：
    ```
    rg -n 'make -C compiler|compiler/Makefile|\bmake\s+-C|\$\(MAKE\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    rg -n '\bcc\b|\bgcc\b|\bclang\b|\$\(CC\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    ```
    仅考古或第三方（tree-sitter）

### 11.4 根脚本 / tools / docker 去 make+cc（**原文档大漏**）

> **背景**：阶段 11.0–11.3 只点 Makefile 与 tests/，**漏了根脚本、tools/、scripts/、docker/ 中的 make/cc 调用**。这些是「零 cc 链」的硬障碍。

✅ **11.4.1 `build.sh`（根目录）薄转发 `./xbuild`（wave731）**

  - 旧体：直接 `cc` 链 `build_tool`（双权威 + 已坏变量 `$LINK_SHU`）
  - 现体：默认 `./xbuild build`；参数透传任意 xbuild 目标；**0× host-cc**
  - host-cc residual 仅 `compiler/scripts/build_tool.sh`（至阶段 12）

🟡 **11.4.2 `xlang-build.sh` 产品路径 0× make -C；CI hub 单点**

  - 产品目标（build/clean/test*/bootstrap-* 烟测）已 shell（wave718–720）
  - wave730：`run_compiler_make` 单 hub 供 `compiler-all` / `bootstrap-driver-seed` / `compiler-make`（CI/冷启动/叶 .o）
  - 终局 11.3 删 Makefile 后 hub 改 shell 体，外层目标名不变

✅ **11.4.3 `scripts/docker-ci-local.sh` 外层 0× `make -C`（wave730）**

  - 全矩阵段 → `./xbuild clean|compiler-all|test_*|bootstrap-*|compiler-make …`
  - 与 11.2.5 同入口；guest 仍需 build-essential（零 cc 属 12）

✅ **11.4.4 `tools/verify-xlang-migration.sh` 提示 → xbuild（wave730）**

🟡 **11.4.5 `tests/docker/linux-dev.Dockerfile`（wave731 入口文档）**

  - ✅ `XLANG_PREFERRED_ENTRY=./xbuild` + `org.xlang.entry` label
  - ⬜ 仍装 `gcc make`（build_tool / seed / bench 差分 residual；**卸包装 = 阶段 12**）

✅ **11.4.6 `tests/lib/delete-one-c-file.sh` → `./xbuild`（wave731）**

  - host + Docker 回归：`./xbuild bootstrap-driver-bstrict`（无 raw `make -C`）
  - bare ubuntu guest 仍可 apt residual gcc/make（至阶段 12）
### 11.5 tests/ 对照 C 文件处理策略（**零 cc 终局下的归属**）

> **背景**：`tests/` 下有 ~200 个 .c 文件（bench/、std-*/、abi/、leak/、safe/、kernel/），当前需 host cc 编译做对照/smoke。阶段 8.3 只管 compiler/ 内 residual C，**完全没覆盖 tests/ 下的对照 C**。零 cc 终局下必须决定它们的归属。

🟡 **11.5.1 `tests/bench/**/*.c`（~50 个）对照基准 C**

  - `loop_i32.c` · `mem_copy.c` · `simd_dot.c` · `struct_param.c` · `call_boundary.c` · `zero_copy_sendfile*.c` · `regex_match_*.c` · `http_bench_server.c` · `net_*.c` · `io_*.c` · `async_*.c` · `diff/d1_int_arith.c` ~ `d6_mem_ops.c`
  - **策略裁定（wave734）**：**永久 host-cc 白名单（仅差分/对照基准）** — 不进产品路径、不进 g05、不经 `./xbuild all`；与 `.x` 对照测时由 bench 脚本显式 `cc`（标 temporary residual 至阶段 12 零 cc 终局复审）。优先路径：有 `.x` 孪生则产品侧只编 `.x`；裸 `.c` 不强制本波改写
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.1

🟡 **11.5.2 `tests/std-*/*.c`（50 个）std 模块 smoke 测试 C**

  - `tests/std-sqlite/*_ok.c` · `tests/std-elf/*_ok.c` · `tests/std-crypto/*_smoke*.c` · `tests/std-math/*` · `tests/std-config/*` · `tests/std-uuid/*` · `tests/std-ffi/*` · `tests/std-trace/*` · `tests/std-context/*` · `tests/std-base64/*` · `tests/std-tar/*` · `tests/std-task/*` · `tests/std-log/*` · …
  - 被 `tests/lib/std-*.sh` 用 host cc 链接 **已编好的** `std/**/*.o`
  - **策略裁定（wave741）**：**永久 host-cc 白名单（C smoke harness only）** — 不进 g05 / `./xbuild all` / 产品编译器链接；产品绿以 bstrict / `.x` 闸门为准；改写为 `.x` 属阶段 12 复审，不挡 11.3
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.2（50 路径 + 闸门 floor ≥40）

🟡 **11.5.3 `tests/abi|leak|safe|kernel/*.c` 探针 C**

  - `tests/abi/layout_abi.c` · `tests/leak/leak_probe.c`（cc -fsanitize=address）· `tests/safe/race_probe.c` · `tests/kernel/freestanding_stubs.c`
  - **策略裁定（wave741）**：**永久 host-cc 白名单（ABI / sanitizer / freestanding 探针）** — 依赖 host 工具链能力；不进产品链；权威见 `tests/HOST_CC_POLICY.md` §11.5.3

🟡 **11.5.4 `tests/probes/**/*.c` prove/seed 工具产物**

  - `seed_optional/*/optional_gen.c` · `prove_x_o/*/{*.gen.c,*.raw.c,*.seed.probe.c,*.merged.probe.c,thin.c}` · `bootstrap-parser/{csv_core,json_core}_gen_probe*.c`
  - **策略裁定（wave741）**：**非产品 residual 类** — 工具/生成物；多数不入库；随 prove→xbuild 收缩；禁止扩成产品 host-cc 债。权威：`tests/HOST_CC_POLICY.md` §11.5.4

### 11.6 editors/ 与文档去 make（**用户指南同步**）

⬜ **11.6.1 `editors/tree-sitter-xlang/` 第三方 grammar**

  - 自带 Makefile + binding.gyp + Cargo.toml(cc crate) + bindings/rust/build.rs
  - 策略：git submodule / 独立 release / 删除（与 xlang 自举链解耦）

⬜ **11.6.2 `editors/vscode/` 用户提示语**

  - 15+ 语言文件（package.nls.{json,zh-cn,zh-tw,ja,ko,...}.json · l10n.bundle.*.json · src/lspClient.ts:40 · README.md · editors/LSP接入.md）
  - 全部提示用户运行 `make -C compiler bootstrap-driver-seed`
  - 改为 `xbuild bootstrap` 或删除提示

⬜ **11.6.3 `README.md` / `README_zh-CN.md` 用户指南**

  - 行 128/496 指导用户 `make -C compiler build-tool && ./xlang-build.sh first-time`
  - 改为 `xbuild build`


---

## 阶段 12：冷启动路径重设计（零 cc 链 · BC 层）

> **定义**：从最小 seed 到完整产品，**不出现 host cc/gcc/clang**（§0.1 BC + 编排 MG）。  
> **前置**：阶段 10 + 阶段 9 + 阶段 8.3 足够；阶段 11 xbuild 可驱动冷启动。  
> **目标**：`最小 seed → xlang → xbuild → 完整产品`。

### 12.1 最小 seed 设计

⬜ **12.1.1 手写 asm seed（或极简二进制）**

  - 不依赖 cc 编译的 seed
  - 选项 A：手写 x86_64/arm64 asm，经 **xlang 自带 assembler** 装配
  - 选项 B：预置极简二进制（版本钉死、可复现下载/校验）

⬜ **12.1.2 seed 能产出 xlang_v1（无需 -E→cc）**

  - 优先：seed **直接** asm-codegen 出 v1  
  - 若过渡仍 `-E`：生成物不得经 host-cc（与终局 BC 冲突 → 仅临时）

⬜ **12.1.3 与 pin 退役衔接**

  - 冷启动输入是 **`.x` + 最小 seed**，不是 `seeds/*_gen.linux*.c` 业务体

### 12.2 链路验证

⬜ **12.2.1 零 cc 验证（BC+PC）**

  - 构建与默认产品路径：`strace`/`dtruss` 无 `execve(cc|gcc|clang)`
  - 可选：`XLANG_FORBID_HOST_CC=1` 运行时硬失败

⬜ **12.2.2 双端冷启动验证**

  - macOS + Ubuntu；Windows 探针按 G.8

⬜ **12.2.3 产品默认后端**

  - 文档与 CLI 默认 `-backend asm`；host-C 标 **deprecated / opt-in only**


---

## 阶段 13：终局 — 自举完成（**无 Makefile** + 零 cc 三义 + v2==v3）

> **定义**：  
> 1. **MG**：仓库无 Makefile 权威，xbuild 为唯一编排入口；  
> 2. **BC/PC**：自举与默认产品路径零 host-cc；  
> 3. **语义**：`xlang_v2 == xlang_v3`（及可选 D-03）；  
> 4. **无 pin 糊弄**：阶段 7/8/8.3 完成。  
> **前置**：阶段 7–12。  
> **节奏**：整波 Cap/R/M 收口 → L4；日终兜底见 skill §3.3。

### 13.1 语义自举验证

⬜ **13.1.1 阶段 7 M4 完成**（含 7.4 typeck/codegen）

⬜ **13.1.2 阶段 8 gen + 8.3 glue/ast/桩 完成**

⬜ **13.1.3 阶段 9 residual 全部消灭**

⬜ **13.1.4 v2 == v3 语义自举验证**

  ```
  seed_xlang  …  →  xlang_v1   （无 host-cc）
  xlang_v1    …  →  xlang_v2
  xlang_v2    …  →  xlang_v3
  assert xlang_v2 == xlang_v3
  ```

⬜ **13.1.5 D-03 bit-identical 验证（可选更强）**

### 13.2 零 Makefile / 零 cc 验证（**主验收**）

⬜ **13.2.1 双端 L4 真冷 + 129 bstrict（xbuild 驱动 · 零 make · 零 host-cc）**

⬜ **13.2.2 Makefile 物理删除验收**

  - `test ! -e Makefile && test ! -e compiler/Makefile`
  - 文档/脚本无「请 make -C compiler」作为唯一路径

⬜ **13.2.3 零 cc 三义验收**（§0.1 MG+BC+PC）

  - strace 无 make/cc/gcc/clang（或 make 仅用户 PATH 偶然存在但从未被调用）

⬜ **13.2.4 labi_invoke_cc / `-backend c` 退役或隔离**

  - 产品默认不 exec host-cc；历史 C 后端进 experimental 或删除

### 13.3 收尾

⬜ **13.3.1 物理删 seed 业务体（考古归档）**

  - pin/from_x 业务 C 出主链；最小 seed 单独归档

⬜ **13.3.2 宣布自举完成**

  - 公告：**Xlang 自举完成 — 无 Makefile + 零 host-cc + v2==v3**
  - **完成后主线**见 [`自举完成后路线图.md`](自举完成后路线图.md)（P0 稳住基线 → P1 `xlang test` T1 → P2 语言/优化/std）


---

## 附录 A：代码量分布（快照 · wave713 文档创建时；审计后补 glue 列）

| 维度 | .x 行数 | .c 行数 | 备注 |
|------|---------|---------|------|
| std/ + core/（库） | 75,007 | 0 | 100% ✅ |
| compiler/src/（产品源） | 176,729 | — | — |
| compiler/ 非 seed .c（含 gen+glue） | — | 372,826* | *原统计；**含** glue 巨头 |
| 其中 glue/ast 池系（2026-07-29 实测） | — | **~60,574** | pipeline_glue+ast_pool+field_access+soa+bootstrap 等 |
| compiler/seeds/ .c | — | 209,657 | ~329 文件 |
| **全项目 .x vs 全 .c** | **251,736** | **582,483** | **~30.2% .x** |

> 终局看的不是 .x 占比，而是 **BC 层是否还有必须 host-cc 的 .c** 与 **是否还有 Makefile 权威**。

## 附录 B：三大 mega rest 规模

| mega | rest LOC | 切片数 | 状态 |
|------|----------|--------|------|
| parser_asm_thin_c | ~21,935 | 21/21 ✅ | 拆分完成 · 去 pin ⬜ |
| runtime | ~7,320 | 24/24 ✅ | 拆分完成 · 去 pin ⬜ |
| runtime_link_abi | ~6,920 | 11/11 ✅ | 拆分完成 · 去 pin ⬜ |

另：**typeck / codegen pin** 见阶段 7.4（非本表三 mega，但是删 Makefile 同级债）。

## 附录 C：当前 L4 钉盘状态

| 项 | 值 |
|---|---|
| 钉盘 SHA | `53fd80927` |
| 前钉 SHA | `4fa4f07e7` |
| 升钉波次 | wave710（match struct 模式链整波收口） |
| 上次 L4 日期 | 2026-07-29 |
| 双端 bstrict 数 | 129 |
| mac 产品链 | ✅ L4 真冷 OK (129) |
| Ubuntu L4（金标） | ✅ L4 真冷 OK (129) |
| 工程轨 KPI | T 18/18 · N 111/111 IDENTICAL |
| git 锚点 | `anchor-pre-wave710-l4` · `anchor-pre-wave712-cap` |

## 附录 D：综合迁移进度（终局 = **无 Makefile** + 零 cc 三义）

```
旧终局（v2==v3 + 无 pin）≈ 74.5%（历史权重，见变更记录）

新终局权重（2026-07-29 审计修订）：
  库+T+N+R2+M拆分+Cap≈         0.40 × ~85%  → ~34%
  阶段 7/8 gen 去 pin            0.10 × ~25%  → ~2.5%
  阶段 8.3 glue/ast（新）        0.12 × 0%    → 0%
  阶段 9 residual                0.12 × 0%    → 0%
  阶段 10 语言 L2                0.10 × 0%    → 0%
  阶段 11 Makefile 退役/xbuild   0.12 × ~15%  → ~2%   （G-05/shell/build.x 半路径）
  阶段 12–13 冷启动+终局验收     0.04 × 0%    → 0%
                                 合计 ≈ 38–45%
```

**综合迁移进度（修订）：约 40–45%**  
（原写 ~50% 略乐观：漏计 **8.3 glue ~60k** 与 **typeck/codegen pin**，且根 Makefile 薄包装 ≠ compiler/Makefile 已退役。）

剩余工作按 **删 Makefile** 优先级：

1. **阶段 11.0** Makefile 规则迁移表 + 产品路径 0-make 闸门（可立即开）  
2. **阶段 8.3** pipeline_glue / ast_pool 等非 gen 产品 C  
3. **阶段 7.4 + 8.2** typeck/codegen/parser… 去 pin  
4. **阶段 10 → 9** 语言能力 + residual 消灭  
5. **阶段 11.1–11.3** xbuild 填实 + **物理删 Makefile**  
6. **阶段 12–13** 冷启动零 cc 三义 + v2==v3 + 公告  

## 附录 E：compiler/Makefile 迁移表（摘要 · 全量见独立文档）

> **全量权威清单**（11.0.1 · wave714）：[`analysis/Makefile迁移表.md`](Makefile迁移表.md)  
> 每完成一行迁移到 xbuild，在迁移表「迁移状态」列改 🟢，并回写本摘要若影响仪表盘。

| 类 | 主题 | 条数（约） | 今日落点 | xbuild 拟目标 | 状态 |
|----|------|------------|----------|---------------|------|
| **I** | g05 / relink / build-tool 入口 | 9 | `./xbuild`→g05 shell | `xbuild link-product` | 🟢 产品入口 |
| **H** | bootstrap / 产品二进制 phony | 34 | 冷=Makefile 图；日常 g05 | `xbuild bootstrap` / `link-product` | 🟡 编排 shell + mk 清单 |
| **D** | 前端 `*_x.o` | 20 | g05 热路径 + Makefile pin | `xbuild frontend` | 🟡 |
| **E** | `compiler/src` 宿主 .o | 59 | g05 ensure cc | `xbuild runtime-src` | 🟡 |
| **F** | `runtime_*` residual .o | 31 | g05 ensure | `xbuild residual-c` | 🟡 → 阶段 9 |
| **C** | glue / pipeline_x / strict_minimal | 3 | Makefile + g05 cc | `xbuild glue` | ⬜ 体积主债 8.3（地图已落） |
| **B** | pinned `*_gen.c` | 18 | Makefile pin cp | `xbuild pin-gen` | ⬜ 7.4/8.2 |
| **A** | std/core 模块 .o | 65 | 部分 shell / g05 | `xbuild std` | 🟡 |
| **G** | `build_asm/*_filtered.o` | 4 | 全 4 🟢 shell | `xbuild build-asm-filter` | ✅ 产品+Makefile 同调 |
| **J** | test / check / verify | 12 | shell + tests hub | `xbuild test` / `cold-test` | 🟢 11.2.3 tests/** hub ✅（wave733） |
| **K** | seed 工具 | 4 | Makefile | `xbuild seed-tools` | ⬜ 11.0.3 |
| **L** | std 变体 stub | 10 | Makefile | `xbuild std-variant` | ⬜ |
| **M** | clean / compile_commands / legacy | 6 | make / 考古 | util 或 🗑 | 🟡 |
| **N/O** | link alias / 未分类 | ~14 | g05 / 待确认 | stubs 或 🗑 | ⬜ |
| **Σ** | | **~288** | | | 盘点 ✅ 迁移 ⬜ |


---

> **使用方式**：每完成一步，将本文对应待办 `⬜`→`✅`/`🟡` 并保持状态表准确。  
> **波次叙事 / 变更记录**：只写 [`自举进度.md`](自举进度.md)（本文不设 changelog）。  
> **删 Makefile 自检**：动构建系统前先更新附录 E；宣称「无 Makefile」前跑 13.2.2–13.2.4。
