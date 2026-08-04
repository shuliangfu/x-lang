# C → .X 迁移追踪（自举全程待办地图）

> **创建**：2026-07-29  
> **状态刷新**：2026-08-04（对照 tip residual：glue ~3.4k／ast_pool ~9.9k／ELF write + ELF ctx + type-to-c + skip/force 域抽出；**只改勾选与事实 LOC**，无波次流水）  
> **审计补全**：2026-07-29（对照仓库实况：非 gen 产品 C / 零 cc 三义 / G-05·build.x 半路径 / Makefile 删除关键路径）  
> **终局目标**（**用户硬指标**）：**去掉 Makefile** 为主闸门，并收口 **零 cc/gcc/clang + v2==v3**。  
>   即：日常与冷启动编排 **不再依赖 `make` / `compiler/Makefile` / 顶层 `Makefile`**；编译器自举链与产品默认路径 **不再 exec 外部 C 编译器**。  
> **用途**：全面列出 C 逻辑迁移到 .X 的所有步骤，按自举顺序排列。  
> **状态标记（唯一进度记法）**：  
> - ⬜ 未开始  
> - 🟡 **进行中**（做到哪一项就把哪一项标黄）  
> - ✅ **已完成**（该项做完直接打绿勾）  
> **路线**：路线 A（纯 .x + 内建能力重写）— 详见「路线选择」章节。  
> **方法**：[自举方法.md](自举方法.md)（Cap / R / L / M）+ Track L2（语言能力）+ Track X（xbuild）+ Track C0（冷启动零 cc）+ Track MG（Makefile 退役）  
> **进度数字 / 波次流水**：[自举进度.md](自举进度.md) · skill `xlang-selfhost-product-gate` · Makefile 映射：[Makefile迁移表.md](Makefile迁移表.md)  
> **先→后时序（换 IDE）**：[自举时序.md](自举时序.md)（执行序 S0–S8；与本文阶段号对照见时序 §5）  
> **维护约定（强制）**：  
> 1. 本文 **只** 维护 **待办勾选 / 状态表 / 债地图**（✅ / 🟡 / ⬜ + 必要事实：路径、LOC、验收条件）。  
> 2. **禁止** 在本文写波次号、波次 changelog、「waveN 做了 X」流水账。  
> 3. 波次叙事、tip SHA 演进、commit 序列 **只写 [自举进度.md](自举进度.md)**。  
> 4. 做到某一项 → 标 🟡；该项完成 → 改 ✅；不要追加「完成波次」段落。  
> **权威钉盘**（与本文附录 C 同步）：**`77b334842`**（Makefile 物理删除 + 双端 L4）。

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
| **Pinned gen.c 退役** | 🟡 13/30 | Track L 退役 **13** 个（含 lsp_io_gen + build_*_gen 三件套 + cfg_eval_gen）；仍 pin **前端核心** typeck／codegen／parser／pipeline 等 + 工具链／测试 pin |
| **非 gen 产品 C（glue/ast 池）** | 🟡 | 阶段 8.3 **进行中**（**2026-08-04 实测**）：`pipeline_glue.c` **~3.4k**（静态叶基本 fold 完，文件多为 domain `#include` + 薄 wrapper）；`ast_pool.c` **~9.9k**（域 thin 已切 + **ELF write → pipeline_elf_write_o.c ~1.6k** + **ELF ctx → pipeline_elf_ctx.c ~1k** + **type-to-c → pipeline_codegen_type_to_c.c ~350** + **skip/force → pipeline_codegen_skip_force.c ~393**；WPO 等仍 core）。**8.3.1 域 thin 子项大多 ✅**；**8.3.2 域 thin + write 域 ✅ 子项**；**8.3.3 field_access／soa 已抽出仍 host-cc 🟡**；**8.3.9 ✅**；**8.3.4–8.3.8／8.3.10 ⬜**。**BC 终局（离 host-cc）仍 ⬜** |
| **Cap 能力解锁** | 🟡 | untyped self 待治；LANG-006 保留 |
| **产品 L4 放行** | ✅ | 钉盘 `77b334842` · Makefile 物理删除 + 双端 L4 真冷 |
| **Cap residual 边界消灭** | ⬜ 0/~50 | 原「永久边界」降级为「必须消灭」；按路线 A 逐个消灭 |
| **语言能力补齐（L2）** | ⬜ 0/~20 | syscall/FFI/inline asm/fnptr/va_list/线程原语 全部待补 |
| **Makefile 退役 / xbuild** | ✅ **MG 已完成** | **Makefile 已物理删除**（根 + compiler/）· bootstrap 0 make · catalog 单权威（mk/*.mk）· 阶段 11.3.1 ✅ |
| **根脚本 / tools / docker / CI 去 make+cc** | 🟡 | 11.2.5/11.4.3/11.2.3/11.1.6/11.3/11.3.1/11.4.1/11.4.6 ✅ · 11.1.1–5/11.4.5 🟡 · 零 cc 仍 ⬜ |
| **tests/ 对照 C 处理策略** | 🟡 | 11.5.1–4 **策略已裁定**（`tests/HOST_CC_POLICY.md`）；改写 .x / 卸 cc 属阶段 12 |
| **冷启动零 cc 链** | ⬜ 0/4 | 最小 seed + 零 cc 验证 + 双端冷启动 |
| **终局：无 Makefile + 零 cc + v2==v3** | 🟡 | MG ✅ · BC 🟡 · PC ⬜；见 §0.1 三义；阶段 13 |

### 0.1 终局三义（禁止混谈「零 cc」）

去掉 Makefile 与「零 cc」常被混为一谈。**自举终局须同时满足下列三层**（缺一层仍不能宣称终局）：

| 层 | 含义 | 今日状态 | 失败时的假绿 |
|----|------|----------|--------------|
| **MG · 编排层** | 不依赖 `make` / `compiler/Makefile` / 顶层 `Makefile` 完成 build / L4 / bootstrap | ✅ Makefile 物理删除 · bootstrap 0 make · catalog 单权威（mk/*.mk）· 双端 L4 绿 | 只删入口 Makefile、实现层仍 `make -C compiler` |
| **BC · 自举编译层** | 编译器自身 TU **不**再被 host `cc/gcc/clang` 编译（.x→纯 asm `.o` 或等价） | 🟡 已开（inventory 冻结；**glue 叶已 fold、ast_pool 续迁**；`pipeline_x` 仍 host-cc mega-TU） | seed 用 xlang `-E` 出 C 再交给 gcc |
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

✅ **0.3b 每步自举先 `xlang check` 再 L2**（skill §3.3.0 · 自举验证 §4.0）2026-08-04

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

✅ **6.1.5 rest 仅 marker + Cap residual**（R7/R8 OS/pthread 等 **原**标 🔒；归阶段 9 **必须消灭**，非永久 seed 边界）


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

✅ **6.3.6 L3+ 含 stat/spawn/cc/ld** 历史曾标 🔒 薄门闩；**invoke_cc/ld 本体归阶段 9/12–13 必须消灭或 opt-in 隔离**（删 Makefile 后产品默认不得再 `exec` host-cc）


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
  - 目标：同 7.4.1；与 seed 同 commit 纪律收敛为「仅 .x 权威」

⬜ **7.4.3 lexer / preprocess / pipeline 去 pin 对齐**

  - 与阶段 8.2.2 / 8.2.10 / 8.2.11 联动；前端「能自 regen」再谈删 Makefile 冷启动规则

⬜ **7.4.4 双权威禁令验收**

  - 合入闸门：任意 touch `*.x` 产品面 → 同 commit 无「只改 seed」；CI 可 diff pin 与 `-E` 漂移（可选）


---

## 阶段 8：Pinned gen.c 退役（部分完成 · 13/30）

> **定义**：compiler/ 顶层的 *_gen.c 是 pinned 生成器，产品链权威。Track L 退役 = 构建改用 *_x.o，pinned gen 仅考古。

### 8.1 已退役的 pinned gen.c（13 个）

> 产品链 PREFER_X_O；工作区考古 gen 生产体 = `ensure_archaeology_gen.sh`

✅ **8.1.1 lsp_io_std_heap_gen.c** Track L 退役（构建用 lsp_io_std_heap_x.o；考古 shell）

✅ **8.1.2 driver_fmt_gen.c** Track L 退役（构建用 driver_fmt_x.o；考古 shell）

✅ **8.1.3 driver_check_gen.c** Track L 退役（archaeology shell）

✅ **8.1.4 driver_test_gen.c** Track L 退役（archaeology shell）

✅ **8.1.5 driver_build_gen.c** Track L 退役（archaeology shell）

✅ **8.1.6 driver_run_gen.c** Track L 退役（archaeology shell）

✅ **8.1.7 driver_emit_gen.c** Track L 退役（构建用 driver_emit_x.o；考古 shell）

✅ **8.1.8 driver_compile_gen.c** R2 真迁（构建用 driver_compile_x.o；考古 shell）

✅ **8.1.9 lsp_io_gen.c** Track L 退役 wave1036（构建用 lsp_io_x.o via `driver_leaf_x_to_o.sh` catalog；考古 `ensure_lsp_pipeline_gen.sh`；6 个级联符号重命名复刻 historic -D flags）

✅ **8.1.10 build_gen.c** Track L 退役 wave1038（构建用 `../build.x` via `./xlang -x -E` 生成；考古 `seeds/build_gen.c`；最小文件优先策略）

✅ **8.1.11 build_runner_gen.c** Track L 退役 wave1039（构建用 `../build_runner.x` via `./xlang -x -E` 生成；考古 `seeds/build_runner_gen.c`；根源修复：9 处 extern 调用包裹 `unsafe{}` + `entry` 加 `#[no_mangle] export`）

✅ **8.1.12 build_runtime_x_gen.c** Track L 退役 wave1040（构建用 `../build_runtime_x.x` via `./xlang -x -E` 生成；考古 `seeds/build_runtime_x_gen.c`；根源修复：15 处 `build_exec_system` extern 调用用 `unsafe{}` 表达式形式包裹 + `copy_path`/`append_lit` 加 `#[no_mangle]`；build_*_gen 三件套全退役）

✅ **8.1.13 cfg_eval_gen.c** Track L 退役 wave1041（bespoke ladder · `try-cfg-eval-ladder` in `ensure_host_cc_seed_o.sh`；`src/lexer/cfg_eval.x` via `-E-extern -L ..` → `cfg_eval_x.o` → `ld -r` with `cfg_eval_link_alias.from_x.c` → `cfg_eval.o`；考古 `seeds/cfg_eval_gen.linux.x86_64.c`；G.7 单权威：catalog 不支持 ld -r alias merge，保留 bespoke ladder；`audit_gen_retirement.sh` 添加 Bespoke ladder-retired 识别段）


### 8.2 仍需退役的 pinned gen.c（17 个 · 前端核心 + 工具链 + 测试）

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

🟡 **8.2.6 lsp_diag_gen.c** pin/seed/-E → `ensure_lsp_pipeline_gen.sh`

✅ **8.2.7 ~~lsp_io_gen.c~~** 已退役 → 见 8.1.9（wave1036）

🟡 **8.2.8 lsp_gen.c** pin/seed/-E + g_lsp_state_buf post → `ensure_lsp_pipeline_gen.sh`

🟡 **8.2.9 driver_gen.c** pin/seed/-E → `ensure_driver_gen.sh`

  - driver main：src/main.x
  - MAIN_X_DEPS freshness + `fix_driver_gen_duplicate_main` in shell

🟡 **8.2.10 preprocess_gen.c** pin/seed/-E → `ensure_driver_gen.sh`

  - preprocess：src/preprocess/preprocess.x

🟡 **8.2.11 pipeline_gen.c** pin/seed/-E + i64 ABI → `ensure_lsp_pipeline_gen.sh`

  - pipeline：src/pipeline/pipeline.x · post = `check_pipeline_gen_expr_i64_abi.sh`

⬜ **8.2.12 token_gen.c** pinned（19 行 · seeds/token_gen.linux.x86_64.c）

  - token：src/lexer/token.x（prove 锁 nm 面 · 见 3.2.1）

⬜ **8.2.13 ast_gen.c** pinned（808 行 · seeds/ast_gen.linux.x86_64.c）

  - AST 池 v1：src/ast/ast.x
  - 注意：与 ast_gen2.c 并存（双版本），需统一去 pin

✅ **8.2.14 ~~build_gen.c~~** 已退役 → 见 8.1.10（wave1038）

✅ **8.2.15 ~~build_runner_gen.c~~** 已退役 → 见 8.1.11（wave1039）

✅ **8.2.16 ~~build_runtime_x_gen.c~~** 已退役 → 见 8.1.12（wave1040）

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
> **规模（2026-07-29 初测）**：glue+ast_pool 系曾 **~60k LOC**。  
> **规模（2026-08-04 刷新）**：`pipeline_glue.c` **~3.4k** + `ast_pool.c` **~11.6k** + 已抽出 domain 叶合计仍大（同 TU `#include` 入 `pipeline_x`，**仍 host-cc**）；不离 host-cc 则 **BC 终局未达成**。  
> **G.7**：glue 与 typeck.x / codegen.x 禁止长期双权威；迁时同 commit 收敛。  
> **地图用途**：动 8.3 前先查消费方，禁止只改一端。  
> **勾选语义**：域 thin「已抽出」= ✅ 子项；**整项 8.3.x 离 host-cc** 才把父项改 ✅。

#### 8.3 体积地图（主债文件 · 2026-08-04 实测 LOC）

| 文件（compiler/） | LOC | 角色 | 状态 |
|-------------------|-----|------|------|
| `pipeline_glue.c` | **~3,408** | 产品 mega glue 壳（多为 `#include` + 薄 wrapper） | 🟡 **静态叶基本收口**；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_ctfe.c` | 1,177 | typeck CTFE 生产者切片（同 TU `#include`） | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_assign.c` | 348 | typeck assign 域切片（lit 收窄 + EXPR_ASSIGN） | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_coerce_init.c` | 460 | typeck coerce-init 域切片（lit/float/enum/call/array/struct…） | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_method_call.c` | 998 | typeck method_call + generic UFCS mono 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_check_block.c` | 312 | typeck check_block 编排切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_region_assign.c` | 450 | typeck region/escape assign-site 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_unary.c` | ~279 | asm ELF unary emit（NEG/LOGNOT/BITNOT + public faces）切片 | 🟡 已抽出；thin faces wave1014 有则补全；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_as.c` | ~422 | asm ELF as/await/try/float-lit emit（+ public as face）切片 | 🟡 已抽出；thin face wave1014 有则补全；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_return.c` | ~643 | asm ELF return emit（slice escape + impl + public face）切片 | 🟡 已抽出；thin face wave1014 有则补全；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_logand.c` | ~102 | asm ELF LOGAND/LOGOR short-circuit emit 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_block_body.c` | ~809 | asm ELF block body sync emit（defer + body_sync + accessors）切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_block_if_stmt.c` | ~106 | asm ELF block-level if-stmt emit（then-first jz）切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_block_inits.c` | ~171 | asm ELF block const/let init emit 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_assign.c` | ~678 | asm ELF EXPR_ASSIGN emit（lhs f32 + rhs + assign_rhs_to_rax + assign_elf）切片 | 🟡 已抽出（wave995）+ assign_rhs 有则补全（wave1016）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_array_lit.c` | ~335 | asm ELF EXPR_ARRAY_LIT emit（elem_sz + empty + force_esz）切片 | 🟡 已抽出（wave996）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_index.c` | ~434 | asm ELF INDEX／ADDR_OF／DEREF emit（esz + load + lea）切片 | 🟡 已抽出（wave997）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_match.c` | ~179 | asm ELF MATCH／EXPR_IF emit（arm cmp+jeq + if jz）切片 | 🟡 已抽出（wave998）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_panic.c` | ~121 | asm ELF PANIC／int div-zero face（xlang_panic_call + panic_elf + div0）切片 | 🟡 已抽出（wave999）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_field_access.c` | ~632 | asm ELF FIELD_ACCESS emit（layout_by_name + call_arg + call_base + var + fast）切片 | 🟡 已抽出（wave1000）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_binop.c` | ~1976 | asm ELF EXPR_BINOP emit（arith/bitwise/shift + residual scalar/ptr/add + try_binop load/placement）切片 | 🟡 已抽出 + residual 有则补全（wave1015/1018）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_cmp.c` | ~315 | asm ELF relational CMP emit（eq/ne/lt/le/gt/ge + enum RHS + f32/f64/int finish）切片 | 🟡 已抽出（wave1002）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_call_args.c` | ~1052 | asm ELF CALL-arg emit（named_struct + resolve + f32 slot + lea + dual-GP + named layout + for_call_args）切片 | 🟡 已抽出（wave1003）+ type_named_struct（wave1017）+ resolve／f32 slot（wave1019）有则补全；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_struct_lit.c` | ~484 | asm ELF STRUCT_LIT emit（field_store_sz + rehome + fields + struct_lit_elf）切片 | 🟡 已抽出（wave1004）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_vector_let.c` | ~686 | asm ELF vector_let／fixed-array field store（leaf + flat + vector_let + frame_mag + store_fixed）切片 | 🟡 已抽出（wave1005）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_vector_simd.c` | ~1436 | asm ELF SIMD vector lane／shuffle／select／fma emit domain 切片 | 🟡 已抽出（wave1006）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_struct_let.c` | ~215 | asm ELF struct let-init（struct_let_init + type_let_init + sret shift）切片 | 🟡 已抽出（wave1007）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_index_helpers.c` | ~3135 | asm ELF INDEX residual helpers（slot+esz+try_index forest+lvalue_eff_addr elf+text）切片 | 🟡 已抽出；lvalue_text wave1013 有则补全；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_emit_spill.c` | ~2549 | asm ELF 7.3 live／Chaitin spill／bulk_mem + break／continue faces 切片 | 🟡 已抽出；break／continue faces wave1014 有则补全；仍 host-cc 入 `pipeline_x` |
| `ast_pool.c` | **~9,926** | AST 池 / MatchArm / sidecar / WPO | 🟡 多域 thin 已切 + **ELF/Mach-O write 已切出** + **ELF ctx 已切出** + **type-to-c 已切出** + **skip/force 已切出**；WPO／struct tag 等仍 core |
| `ast_pool_module_import.c` | ~226 | module ImportEntry cold-twin accessors 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_struct_layout.c` | ~385 | module StructLayout cold accessors 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_top_level.c` | ~326 | module TopLevelLetEntry + name_is_const／hoist + hoist_target／sum residual 切片 | 🟡 已抽出（wave980+993–994 有则补全）；仍 host-cc 入 `pipeline_x` |
| `ast_pool_type_alias.c` | ~100 | module TypeAliasEntry cold accessors 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_expr_sidecar.c` | ~647 | expr (+ type-pos) var-len sidecar 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_module_enum.c` | ~359 | module ModuleEnumEntry + enum field-access mark 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_onefunc.c` | ~986 | OneFunc sidecar + fill_from_onefunc residual 切片 | 🟡 已抽出（wave984+991 有则补全）；仍 host-cc 入 `pipeline_x` |
| `ast_pool_dep_ctx.c` | ~514 | PipelineDepCtx cold accessors + lib_root + empty_param 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_module_func.c` | ~445 | module Func cold accessors + param sidecar 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_arena.c` | ~248 | ASTArena main-pool cold accessors 切片 | 🟡 已抽出；仍 host-cc 入 `pipeline_x` |
| `ast_pool_block.c` | ~1,439 | block append/region/defer + loop/labeled/getters + parent/resolve + stmt_order rebuild residual 切片 | 🟡 已抽出（wave988–990+992 有则补全）；仍 host-cc 入 `pipeline_x` |
| `pipeline_typeck_field_access.c` | **~1,619** | field_access 权威切片（同 TU 入 glue） | 🟡 **已抽出**；仍 host-cc；**.x 权威收敛 8.3.3 未完** |
| `pipeline_typeck_soa.c` | **~375** | typeck SOA 辅助 | 🟡 **已抽出**；部分 helper 已进 typeck.x；仍 host-cc |
| `pipeline_elf_write_o.c` | **~1,581** | ELF64 ET_REL + Mach-O MH_OBJECT `.o` writers | 🟡 **已抽出**（8.3.2）；仍 host-cc 入 `pipeline_x` |
| `pipeline_elf_ctx.c` | **~1,001** | ELF/Mach-O codegen ctx accessors + PGO-Lite + reloc/label/patch/shndx/common sidecar | 🟡 **已抽出**（8.3.2 wave1247）；仍 host-cc 入 `pipeline_x` |
| `pipeline_codegen_type_to_c.c` | **~349** | TypeKind/VECTOR → C type name repr（type_kind_cstr/copy + vector_type_cstr/copy + type_to_c_repr） | 🟡 **已抽出**（8.3.2 wave1248）；仍 host-cc 入 `pipeline_x` |
| `pipeline_codegen_skip_force.c` | **~393** | codegen skip/force/override/path 谓词（call_num_args_override + dep_skip_* + should_skip_emit_* + force_param_*） | 🟡 **已抽出**（8.3.2 wave1249）；仍 host-cc 入 `pipeline_x` |
| `pipeline_asm_codegen_mega_body.c` | ~223 | asm codegen mega_body 主循环 | 🟡 **已抽出**；仍 host-cc |
| `pipeline_parse_orch.c` | ~1,038 | parse/load/typeck 编排 | 🟡 **已抽出**；仍 host-cc |
| `pipeline_ast_forwarders.c` | ~667 | ast_pipeline_* forwarder 簇 | 🟡 **已抽出**；仍 host-cc |
| `pipeline_elf_codegen_forwarders.c` | ~223 | elf/codegen 前缀 forwarder | 🟡 **已抽出**；仍 host-cc |
| `pipeline_asm_emit_context.c` | ~743 | AsmFuncCtx setters/getters | 🟡 **已抽出**；仍 host-cc |
| `ast_pool_bootstrap_glue.c` | 632 | 冷启动 ast 桥 | 🟡 已在产品链；**折叠／删 8.3.4 ⬜** |
| `pipeline_bootstrap_orchestration.c` | 5 | 编排占位 | 🟡 占位存在；**折叠／删 8.3.4 ⬜** |
| `pipeline_glue_strict_minimal`（seed → 产品链） | — | 产品 weak 孪生 | 🟡 仍在链；**退役策略 8.3.6 ⬜** |
| bare link alias / stubs 族 | 小 | `*_bare_link_alias.c` · `_stubs.c` · `xlang_x_stubs.c` · `typeck_c_module_stubs.c` 等 | 🟡 仍在链；**8.3.5 退役 ⬜** |

#### 8.3 消费方地图（谁还拉 glue · 迁时必同改）

| 消费方 | 如何引用 | 风险 |
|--------|----------|------|
| `compiler/mk/x_source_deps.mk` `PIPELINE_X_DEPS` | glue + 8.3.1 切片（含 …／spill／index_eff_addr／expr_rec）+ `ast_pool` + 11× ast_pool domain slices + bootstrap glue | 改源必重编 pipeline_x |
| g05 / standalone seed 链 | standalone seed + glue + types.inc | weak 孪生与主链分叉 |
| `g05_ensure_relink_prereqs.sh` | mtime vs pipeline_x / standalone；切片 STALE | 产品热路径仍 host-cc 重编 |
| `pipeline_gen.c` / `-E` runtime 路径 | 入口 pipeline.x 时追加 glue 到 stdout | 与 gen 双权威风险 |
| `seeds/pipeline_glue_standalone.from_x.c` | 与 glue 并列产品链 | seed 与 .c 须同 commit |
| `build_asm/gen_driver/*.c`（10） | g05 + partial 脚本 | 物理在 compiler/ 外，易漏计 |
| bare alias / stubs `.c` | 链接安静桩 | 终局由 .x `#[no_mangle]` 取代 |

🟡 **8.3.1 `pipeline_glue.c` → .x（或按域切 thin + 唯一权威）**

  - 爆炸半径：几乎所有 typeck/codegen/asm 产品路径
  - 验收（父项 ✅ 条件）：产品链不再 host-cc 编 glue mega-TU；Ubuntu L4 + 129
  - **进度（2026-08-04）**：glue 文件 **~3.4k**；**业务 static 叶基本 fold 完**（残留 mainly `#include` + 极薄 wrapper）；**父项仍 🟡**（未离 host-cc）
  - ✅ CTFE 域 thin：`pipeline_typeck_ctfe.c`（const whitelist + fold 生产者）自 glue 同 TU `#include` 抽出
  - ✅ assign 域 thin：`pipeline_typeck_assign.c`（lit i16/u16 收窄 + `check_expr_assign` 生产者）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` / g05 STALE / inventory 已收
  - ✅ coerce_init 域 thin：`pipeline_typeck_coerce_init.c`（lit/float/enum/call/array｜vector/int binop/struct/slice + `coerce_init_expr_to_decl` 分发）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 23→24 / g05 STALE / inventory 已收
  - ✅ method_call 域 thin：`pipeline_typeck_method_call.c`（weak method_call + pattern-unify/mono-map/subst + generic UFCS）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 24→25 / g05 STALE / inventory 已收
  - ✅ check_block 域 thin：`pipeline_typeck_check_block.c`（block_impl ctx + loop/unsafe depth + check_block_impl_c + weak fallback + check_block_c + as_loop_body）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 25→26 / g05 STALE / inventory 已收
  - ✅ region-assign 域 thin：`pipeline_typeck_region_assign.c`（M-3 slice region + return slice + WPO-S3 stack-escape assign + MEM-A3 scope-borrow + MEM-C1 with_arena/allocator region）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 26→27 / g05 STALE / inventory 已收
  - ✅ asm unary emit 域 thin：`pipeline_asm_emit_unary.c`（NEG/LOGNOT/BITNOT + sxt/jz）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 27→28 / g05 STALE / inventory 已收
  - ✅ asm as/await/try/float-lit emit 域 thin：`pipeline_asm_emit_as.c` 自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 28→29 / g05 STALE / inventory 已收
  - ✅ asm return emit 域 thin：`pipeline_asm_emit_return.c`（slice escape finder + return_impl ~633 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 29→30 / g05 STALE / inventory 已收
  - ✅ asm logand·logor emit 域 thin：`pipeline_asm_emit_logand.c`（LOGAND/LOGOR short-circuit ~102 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 30→31 / g05 STALE / inventory 已收
  - ✅ asm block body sync emit 域 thin：`pipeline_asm_emit_block_body.c`（defer mask + body_sync + backend accessors ~809 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 31→32 / g05 STALE / inventory 已收
  - ✅ asm block-level if-stmt emit 域 thin：`pipeline_asm_emit_block_if_stmt.c`（then-first + jz / else / done + live merge ~106 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 32→33 / g05 STALE / inventory 已收
  - ✅ asm block const/let init emit 域 thin：`pipeline_asm_emit_block_inits.c`（const+let · VECTOR/SLICE/fixed-array/struct · empty dual-GP ~171 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 33→34 / g05 STALE / inventory 已收
  - ✅ asm EXPR_ASSIGN emit 域 thin：`pipeline_asm_emit_assign.c`（lhs f32 + rhs + assign_elf · FIELD/INDEX/VAR/DEREF · slice dual-GP / fixed-array / STRUCT_LIT index / esz>8 bulk · ~556 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 45→46 / g05 STALE / inventory 已收（wave995）
  - ✅ asm EXPR_ARRAY_LIT emit 域 thin：`pipeline_asm_emit_array_lit.c`（elem_byte_sz + empty + emit/force_esz · nested flat / SLICE dual-GP / >8B STRUCT / may_clobber re-lea · ~335 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 46→47 / g05 STALE / inventory 已收（wave996）
  - ✅ asm INDEX／ADDR_OF／DEREF emit 域 thin：`pipeline_asm_emit_index.c`（index_elem_byte_sz + emit_index + addr_of + deref · multi-dim／SLICE dual-GP／lea-slot／TYPE_ARRAY leave · ~434 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 47→48 / g05 STALE / inventory 已收（wave997）
  - ✅ asm MATCH／EXPR_IF emit 域 thin：`pipeline_asm_emit_match.c`（match_elf + expr_if_elf · arm cmp+jeq／wildcard join／RETURN skip · cond jz then／else · ~179 LOC）自 glue 同 TU `#include` 抽出；CALL／METHOD_CALL 仍 seed；`PIPELINE_X_DEPS` COUNT 48→49 / g05 STALE / inventory 已收（wave998）
  - ✅ asm PANIC／div-zero face thin：`pipeline_asm_emit_panic.c`（xlang_panic_call + panic_elf + panic_int_div_zero + divisor_zero_check_rbx · ~121 LOC）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 49→50 / g05 STALE / inventory 已收（wave999）
  - ✅ asm FIELD_ACCESS emit domain thin：`pipeline_asm_emit_field_access.c`（layout_by_name + call_arg struct／agg + call_base rvalue + var_field_access + field_access_elf_fast · ~583 LOC body）自 glue 同 TU `#include` 抽出；`PIPELINE_X_DEPS` COUNT 50→51 / g05 STALE / inventory 已收（wave1000）
  - ✅ asm BINOP emit domain thin：`pipeline_asm_emit_binop.c`（add／sub／mul／div／mod／and／bitwise／shift + unsigned／64bit + nested rax／rbx helpers · ~857 LOC body）自 glue 同 TU `#include` 抽出；panic include 前置；`PIPELINE_X_DEPS` COUNT 51→52 / g05 STALE / inventory 已收（wave1001）
  - ✅ asm relational CMP emit domain thin：`pipeline_asm_emit_cmp.c`（emit_cmp_elf + enum RHS tag + 64bit/rex + f32/f64/int finish · ~278 LOC body）自 glue 同 TU `#include` 抽出；typekind_variant_tag 仍 glue（field_access 共享）；`PIPELINE_X_DEPS` COUNT 52→53 / g05 STALE / inventory 已收（wave1002）
  - ✅ asm CALL-arg emit domain thin：`pipeline_asm_emit_call_args.c`（lea_not_load + dual-GP load_var + named layout size + pass_addr + for_call_args · ~792 LOC body／~831 file）自 glue 同 TU `#include` 抽出；resolve_* 仍 glue（leaf VAR 共享）；CALL／METHOD_CALL 仍 seed；`PIPELINE_X_DEPS` COUNT 53→54 / g05 STALE / inventory 已收（wave1003）
  - ✅ asm STRUCT_LIT emit domain thin：`pipeline_asm_emit_struct_lit.c`（field_store_sz + public wrapper + DEST_IN_RBX/rehome + fields + struct_lit_elf · ~444 LOC body／~484 file）自 glue 同 TU `#include` 抽出；store_fixed_array_field／vector_let 本波后进 vector_let 叶；`PIPELINE_X_DEPS` COUNT 54→55 / g05 STALE / inventory 已收（wave1004）
  - ✅ asm vector_let／fixed-array field store domain thin：`pipeline_asm_emit_vector_let.c`（leaf_elem_byte_sz + array_lit_flat + vector_let_init + field_frame_mag + store_fixed_array_field · ~645 LOC body／~686 file）自 glue 同 TU `#include` 抽出；glue_emit_fixed_array_type_let_init 仍 glue 薄包装；SIMD lane 仍 glue；`PIPELINE_X_DEPS` COUNT 55→56 / g05 STALE / inventory 已收（wave1005）
  - ✅ glue 静态叶迁移基本收口：剩余 static 为跨域基础设施（ctx_layout／arena accessor／var stack off／type kind 映射等），不宜再硬拆；业务 leaf 已 fold；文件 ~3.4k 多为 `#include`
  - ✅ asm mega_body 主循环域 thin：`pipeline_asm_codegen_mega_body.c`
  - ✅ asm loop_labels／slice_init／float_lit／region／call_slice_region／fill_soa／fill_array_lit 等续 fold（同 TU 入既有域文件）
  - ✅ dead fn + 冗余 fwd decl 清理（glue／ast_pool 零 caller 符号）
  - ✅ `#if 0` 死代码块物理删除（glue）
  - 🟡 仍 host-cc 编入 `pipeline_x`（未 .x 化 / 未离 host-cc）— **域 thin 子项 ✅ ≠ 父项 BC 完成**

🟡 **8.3.2 `ast_pool.c` → .x / 已有 ast.x 权威收敛**

  - MatchArm / GrowVec / module sidecar 与 parser pin 同生命周期
  - 验收（父项 ✅ 条件）：ast_pool 业务体不再 host-cc；与 ast.x 单权威
  - **进度（2026-08-04）**：core **~9.9k**；多域 thin 已切 + **ELF/Mach-O write 已切出** + **ELF ctx 已切出** + **type-to-c 已切出** + **skip/force 已切出**；WPO／struct tag 仍 core
  - ✅ module_import 域 thin：`ast_pool_module_import.c`（XLANG_WEAK ImportEntry cold twins ~208 LOC）自 `ast_pool.c` 同 TU `#include` 抽出；COUNT 34→35
  - ✅ struct_layout 域 thin：`ast_pool_struct_layout.c`（`pipeline_module_struct_layout_*` + num + type_param meta ~365 LOC）同 TU 抽出；COUNT 35→36 / g05 STALE / inventory 已收
  - ✅ top_level 域 thin：`ast_pool_top_level.c`（`pipeline_module_top_level_let_*` ~113 LOC）同 TU 抽出；COUNT 36→37 / g05 STALE / inventory 已收
  - ✅ type_alias 域 thin：`ast_pool_type_alias.c`（`pipeline_module_type_alias_*` + `num_type_aliases_at` ~80 LOC body）同 TU 抽出；COUNT 37→38 / g05 STALE / inventory 已收
  - ✅ expr_sidecar 域 thin：`ast_pool_expr_sidecar.c`（call/method/match/struct_lit/array_lit + type_type_arg ~620 LOC body）同 TU 抽出；COUNT 38→39 / g05 STALE / inventory 已收
  - ✅ module_enum 域 thin：`ast_pool_module_enum.c`（`pipeline_module_enum_*` + expr/codegen enum field-access mark ~336 LOC body）同 TU 抽出；COUNT 39→40 / g05 STALE / inventory 已收
  - ✅ onefunc 域 thin：`ast_pool_onefunc.c`（const/let/param/call/while/for + copy_sidecar ~522 LOC body；`grow_vec_copy_append` 上提 core）同 TU 抽出；COUNT 40→41 / g05 STALE / inventory 已收
  - ✅ dep_ctx 域 thin：`ast_pool_dep_ctx.c`（PipelineDepCtx cold accessors + lib_root + empty_param ~480 LOC body；path_append/resolve/load 仍 core）同 TU 抽出；COUNT 41→42 / g05 STALE / inventory 已收
  - ✅ module_func 域 thin：`ast_pool_module_func.c`（module Func alloc/flags/params/name_equal/byte + arena_func param_write/copy_slot · ~409 LOC body；static helpers + visibility/L7 + glue name/body 仍 core）同 TU 抽出；COUNT 42→43 / g05 STALE / inventory 已收
  - ✅ arena 域 thin：`ast_pool_arena.c`（type/expr/block/func ptr/alloc/get/set + write_var/binop + num_types + caps · ~220 LOC body；block_at/sidecar helpers 仍 core）同 TU 抽出；COUNT 43→44 / g05 STALE / inventory 已收
  - ✅ block 域 thin：`ast_pool_block.c`（block_pool_append_pos + append const/let/if/region/with_arena/unsafe/defer + region/defer accessors · ~297 LOC body）同 TU 抽出；COUNT 44→45 / g05 STALE / inventory 已收
  - ✅ block residual 有则补全：同文件迁入 append expr_stmt/stmt_order/while/for/labeled + static block_*_at + while/for/labeled/const/let/if/expr/stmt_order getters（~438 LOC；file ~763）；COUNT 仍 45；onefunc fill/resolve residual 仍 core
  - ✅ block parent／resolve residual 有则补全：同文件迁入 parent patch + resolve_var_type_ref／name_binding／local_redecl／find_var（~359 LOC；file ~1140）；COUNT 仍 45；`pipeline_arena_expr_ptr`；fill_* residual 仍 core
  - ✅ onefunc fill residual 有则补全：`ast_pool_onefunc.c` 迁入 defer/labeled/if/region/stmt_order + fill_*（defers/labeled/regions/ifs/stmt_order/expr_stmts/whiles/fors）（~438 LOC；file ~986）；COUNT 仍 45；module_top_level_name_is_const + stmt_order rebuild 仍 core（wave991）
  - ✅ stmt_order rebuild residual 有则补全：`ast_pool_block.c` insert/fixup/sparse_ifs/module_fixup（~299 LOC；file ~1439）；COUNT 仍 45；name_is_const + hoist 仍 core（wave992）
  - ✅ top_level name_is_const／hoist residual 有则补全：`ast_pool_top_level.c` 迁入 name_is_const + hoist_top_level_lets_into_main（~115 LOC；file ~249）；COUNT 仍 45；block 后 include 可见 static prepend_lets（wave993）
  - ✅ top_level hoist_target／sum residual 有则补全：`ast_pool_top_level.c` 迁入 `pipeline_asm_hoist_target_func_index` + `pipeline_asm_sum_module_top_level_lets_stack`（~77 LOC；file ~326）；COUNT 仍 45；modlet／slot helpers 仍 glue extern（wave994）
  - ✅ ELF/Mach-O `.o` writers 域 thin：`pipeline_elf_write_o.c`（standard + PGO ELF + macho + `platform_macho_write_macho_o_to_buf` · ~1.6k）；g05 STALE／inventory／`PIPELINE_X_DEPS` 已收
  - ✅ ELF ctx 域 thin：`pipeline_elf_ctx.c`（PipelineElfCtxAccess layout + PGO-Lite + reloc/label/patch/shndx/common sidecar + ctx accessors + label/sym/patch ops · ~986 LOC body；含 mid-file #include write_o）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1247）
  - ✅ codegen type-to-c 域 thin：`pipeline_codegen_type_to_c.c`（type_kind_cstr/copy + vector_type_cstr/copy + type_kind_append + type_to_c_repr_inner + type_to_c_repr · ~336 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1248）
  - ✅ codegen skip/force 域 thin：`pipeline_codegen_skip_force.c`（call_num_args_override + is_std_io_driver_bridge + path_is_std_io_* + dep_skip_* + should_skip_emit_* + entry_is_lsp_* + force_param_* · ~379 LOC body）；g05 STALE／`PIPELINE_X_DEPS` 已收（wave1249）
  - 🟡 仍 host-cc 编入 `pipeline_x`（未 .x 化 / 未离 host-cc）— **域 thin 子项 ✅ ≠ 父项 BC 完成**
  - ✅ asm struct let-init domain thin：`pipeline_asm_emit_struct_let.c`（struct_let_init + glue_emit_struct_type_let_init + sret reg shift · ~176 LOC body／~215 file）自 glue 同 TU `#include` 抽出；store_retval／type_size 仍 glue；`PIPELINE_X_DEPS` COUNT 57→58 / g05 STALE / inventory 已收（wave1007）
  - ✅ asm INDEX residual helpers domain thin：`pipeline_asm_emit_index_helpers.c`（module_from_ctx + param/local slot + field_type_ref + fixed_array_total_bytes + index_elem_byte_sz_from_type_ref + try_index forest + soa_index_field_addr + lvalue_eff_addr · ~2988 LOC body／~3038 file）自 glue 同 TU `#include` 抽出；eff_addr_scaled／assign finish_store／bulk_mem_copy／Chaitin spill 仍 glue；`PIPELINE_X_DEPS` COUNT 58→59 / g05 STALE / inventory 已收（wave1008）
  - ✅ asm 7.3 live／Chaitin spill／bulk_mem／index-assign residual thin：`pipeline_asm_emit_spill.c`（live_fwd + CFG phi + color + bulk_mem_copy_spills + index_assign_finish_store + index scratch／binop_stack_spill methods · ~2487 LOC body／~2532 file）自 glue 同 TU `#include` 抽出；CAP statics 仍 index_helpers；eff_addr_scaled 仍 glue；`PIPELINE_X_DEPS` COUNT 59→60 / g05 STALE / inventory 已收（wave1009）
  - ✅ asm INDEX effective-address scaled domain thin：`pipeline_asm_emit_index_eff_addr.c`（rax_plus_rbx_scaled + bounds_guard + rvalue_slice_once + eff_addr_scaled · ~653 LOC body／~697 file）自 glue 同 TU `#include` 抽出；try_index 仍 index_helpers；face 仍 index／assign；`PIPELINE_X_DEPS` COUNT 60→61 / g05 STALE / inventory 已收（wave1010）
  - ✅ asm expr recursion dispatcher domain thin：`pipeline_asm_emit_expr_rec.c`（lit_i32 + emit_expr_elf_rec · ~139 LOC body／~179 file）自 glue 同 TU `#include` 抽出；face 仍各域叶；slow 仍 backend residual；`PIPELINE_X_DEPS` COUNT 61→62 / g05 STALE / inventory 已收（wave1011）
  - ✅ asm INDEX eff-addr base twins + public faces 有则补全：`pipeline_asm_emit_index_eff_addr.c` 迁入 local_slot_text + base_{elf,text} + public index_eff_addr_{elf,text}（~198 LOC；file ~697→~895）；COUNT 仍 62；lvalue_eff_addr_text 仍 glue residual；ELF lvalue 仍 index_helpers（wave1012）
  - ✅ asm lvalue_eff_addr_text 有则补全：`pipeline_asm_emit_index_helpers.c` 迁入 `pipeline_asm_emit_lvalue_eff_addr_text_c`（~77 LOC；file ~3039→~3135）；与 ELF twin 同叶；local_slot_text 仍 index_eff_addr（同 TU static 前向）；COUNT 仍 62；glue ~20.7k→~21.1k（wave1013）
  - ✅ asm thin ELF public faces 有则补全：return／unary／as／spill 叶迁入 `pipeline_asm_emit_{return,neg,lognot,bitnot,as,break,continue}_elf_c`（~40 LOC 自 glue；COUNT 仍 62；glue ~21.1k）（wave1014）
  - ✅ asm binop residual 有则补全：`pipeline_asm_emit_binop.c` 迁入 scalar f32／f64／ptr arith／add_rax_rbx（~306 LOC 自 glue；file ~1221；COUNT 仍 62；glue ~20.8k）（wave1015）
  - ✅ asm assign_rhs_to_rax 有则补全：`pipeline_asm_emit_assign.c` 迁入 `glue_emit_assign_rhs_to_rax_elf_c`（~89 LOC；file ~678；COUNT 仍 62；glue ~20.7k）（wave1016）
  - ✅ asm type_named_struct 有则补全：`pipeline_asm_emit_call_args.c` 迁入 `glue_type_ref_is_named_struct_layout_elf_c`（~30 LOC；file ~876；COUNT 仍 62；glue ~20.7k）（wave1017）
  - ✅ asm try_binop residual 有则补全：`pipeline_asm_emit_binop.c` 迁入 as_needs + load_operand／clobber／preserve／commutative／left_rax／cmp（~740 LOC；file ~1976；COUNT 仍 62；glue ~19.9k）（wave1018）
  - ✅ asm emit_expr_elf_fast + emit_expr_elf_c 有则补全：`pipeline_asm_emit_expr_rec.c` 迁入 fast／c（~212 LOC；file ~404；COUNT 仍 62；glue ~19.6k；include 迁 field_access 后）（wave1020）
  - ✅ asm array_lit durable + force_esz 有则补全：`pipeline_asm_emit_array_lit.c` 迁入 durable_ptr／force_esz_from_elem（~390 LOC；file ~779；COUNT 仍 62；glue ~19.2k）（wave1021）
  - ✅ asm call_arg resolve + f32 VAR slot 有则补全：`pipeline_asm_emit_call_args.c` 迁入 resolve_anon／resolve_var_stack_off + load_f32_var_slot_{rax,rbx} + unusable／append_at_offset／var_is_param（~160 LOC；file ~1052；COUNT 仍 62；glue ~19.8k；var_decl + lazy_append wave1023 已迁出共享叶）（wave1019）
  - ✅ asm slice reent deep-copy 有则补全：`pipeline_asm_emit_call_args.c` 迁入 `glue_slice_let_reent_deep_copy_after_dual_gp_elf_c`（~400 LOC；file ~1458；COUNT 仍 62；glue ~18.8k）（wave1022）
  - ✅ asm var_decl + lazy_append G.7 共享叶 fold：新建 `pipeline_asm_emit_var_decl.c`（~125 LOC；`glue_var_decl_type_ref_elf_c` ~30 + `glue_lazy_append_block_let_local` ~25 自 glue residual）；glue 66 行定义体 → 9 行 #include；COUNT 仍 62（同 TU #include 不增 .o）；glue ~18.8k→~18.7k；被 7 切片共享（call_args/binop/assign/unary/expr_rec/block_inits/block_body）（wave1023）
  - ✅ asm slice dual-GP helpers + slice_from_array G.7 同叶 fold：`pipeline_asm_emit_block_inits.c` 迁入 `glue_slice_dual_gp_length_off_c`（~5 LOC）+ `glue_slice_dual_gp_bump_past_home_c`（~14 LOC）+ `glue_emit_slice_from_array_let_init_elf_c`（~150 LOC 自 glue residual；file ~171→~402）；COUNT 仍 62；glue ~18.7k→~18.5k；被 block_inits + call_args（slice_let_reent_deep_copy）共享（length_off 早期 fwd 保留供 call_args）（wave1024）
  - ✅ asm sret return path helpers G.7 同叶 fold：`pipeline_asm_emit_return.c` 迁入 `glue_emit_sret_memcpy_rbx_to_home_elf_c` + `glue_emit_sret_return_from_var_elf_c` + `glue_copy_large_struct_from_rax_ptr_elf_c`（~103 LOC body 自 glue residual；file ~643→~772）；COUNT 仍 62；glue ~18.5k→~18.4k；被 return + struct_lit（sret_memcpy）+ struct_let（copy_large_struct via store_retval_pair）共享（glue 1989-1993 fwd 保留；新增 glue_enc_local_slot_ptr_or_addr_rbx_elf_c fwd——index_helpers 在 return 之后 #include）（wave1025）
  - ✅ asm field_access layout/offset helpers G.7 同叶 fold：`pipeline_asm_emit_field_access.c` 迁入 `glue_dep_layout_field_offset_by_name_c` + `glue_field_layout_offset_for_{var_base,base}_field` + `glue_field_access_effective_offset_c` + `pipeline_expr_field_access_layout_offset` + `glue_field_access_load_bytes_for_type_ref` + `pipeline_expr_field_access_load_byte_sz`（~395 LOC body 自 glue residual；file ~632→~1025）；COUNT 仍 62；glue ~18.4k→~18.0k；被 field_access + index_helpers／assign／index_eff_addr／vector_let 共享（glue 1726-1727 public fwd 保留；2500 static fwd 保留；新增 typeck_get_field_offset_from_layout_deps／pipeline_dep_ctx_ndep／pipeline_dep_ctx_module_at extern）（wave1026）
  - 🟡 下一域候选（父项仍 🟡）：ast_pool struct tag+outbuf 域／WPO；或 8.3.3 field_access 权威收敛

🟡 **8.3.3 `pipeline_typeck_field_access.c` / `pipeline_typeck_soa.c` 并入 typeck 权威**

  - 验收（父项 ✅）：field resolve 唯一权威在 typeck.x；C 叶仅 thin 或删
  - ✅ 文件已抽出同 TU：`pipeline_typeck_field_access.c` ~1.6k · `pipeline_typeck_soa.c` ~375（仍 host-cc）
  - ✅ `typeck_soa_array_storage_size_glue` 已从 C bypass 迁到 typeck.x 权威；2 static helpers 改为 non-static extern（供 field_soa_index）；.x 用 typeck_x_type_align（G.7 twin）
  - ⬜ `pipeline_typeck_field_access.c` field resolve **仍 C 权威** — 禁止 glue 旁路第二套；**整项未 ✅**

⬜ **8.3.4 bootstrap glue / orchestration 折叠进 8.3.1–8.3.2 或删**

  - 🟡 `ast_pool_bootstrap_glue.c`／`pipeline_bootstrap_orchestration.c` **仍在链**（未折叠／未删）

⬜ **8.3.5 链接桩 / bare alias 退役**

  - `ast_asm_bare_link_alias.c` · `backend_asm_*_alias.c` · `typeck_asm_bare_link_alias.c` · `x_frontend_link_alias.c` · `_stubs.c` · `_x_stubs2.c` · `xlang_x_stubs.c` · `typeck_c_module_stubs.c`
  - 目标：符号面由 .x `#[no_mangle]` / 单一 mangle 权威提供，无「为让 ld 安静」的永久 C 桩
  - 🟡 **桩文件仍在链** — 未退役

⬜ **8.3.6 `seeds/*.from_x.c` 全表退役策略**

  - 今日 **~329** 个 seeds `.c`：分 **产品 pin** / **prove surface** / **EMPTY surface** / **strict_minimal**
  - 终局：冷启动不读 from_x 业务体；surface 仅考古或生成物不入库（策略二选一写清）
  - ⬜ 策略未定稿／未执行

⬜ **8.3.7 scripts 下 asm stub C**

  - `compiler/scripts/asm_text_stub.c` · `asm_xlang_lsp_diag_stub.c` 等 — 随 xbuild/g05 迁走或删
  - 🟡 文件仍存在

⬜ **8.3.8 `build_asm/gen_driver/*.c`（10 个 · 物理在 compiler/ 外）**

  - `build_asm/gen_driver/pipeline_gen.c` · `lsp_io_gen.c` · `driver_check.c` · `preprocess_gen.c` · `driver_fmt.c` · `lsp_gen.c` · `lsp_io_std_heap_gen.c` · `driver_gen.c` · `driver_test.c`
  - 🟡 仍被 g05／partial 引用
  - 被 g05 / partial 脚本引用；属构建链产物，物理位置在 compiler/ 之外

✅ **8.3.9 `analysis/_debug_io_ctx_gen.c` 孤儿 .c**

  - 本就在 `analysis/*` gitignore 下（仅 `*.md` 入库）；本地调试残留已 rm
  - 机检：`bc_host_cc_product_inventory.sh --check` 断言 **absent** + 禁 `_debug_*_gen.c` 再出现

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

✅ **11.0.1 盘点 `compiler/Makefile` 规则 → 迁移表**（2026-07-29）

  - 分类：冷启动 bootstrap / `*_x.o` / seed pin cp / g05 已覆盖 / 测试·prove / Windows / 死规则
  - 产出：**[`analysis/Makefile迁移表.md`](Makefile迁移表.md)**（288 唯一目标 · 类 A–O）+ 本文附录 E 摘要
  - xbuild 拟目标命名已挂表；迁移完成定义见迁移表 §0

✅ **11.0.2 产品路径 0-make 验收**（静态 ✅ · class-G filtered ✅ · PATH 探针 ✅）

  - 在 **不** `make -C compiler` 的前提下：仅 `xlang-build.sh` / g05 完成 `xlang`/`xlang_asm` 链 + 矩阵
  - **静态闸门**：`tests/run-product-path-zero-make-gate.sh`（allowlist 冻结 g05 日常 `make`；防回退）
  - pipeline filtered → shell；其余 partial-filter + 共用 `filter_o_export_against_deps.sh`；g05_ensure Darwin trio 纯 shell
  - 运行时 PATH 探针：`tests/run-product-path-zero-make-path-probe.sh` — shadow make/gmake；help + g05_relink_env + ensure/prepare 须 **0-exec** make
  - **仍非日常 0-make**：FULL=1→make bstrict（g05 白名单）；嵌套 `tests/run-all-*.sh` / ensure 内 make（11.2.3）

🟡 **11.0.3 冷启动路径减 make**（§5b 全 🟢；叶清单→mk）

  - ✅ 类 G 全 4 filtered.o = 纯 shell；冷启动 `$(MAKE)` **白名单**：[Makefile迁移表.md](Makefile迁移表.md) §5b
  - ✅ 编排 / 链接 / rebuild / host-stubs / check-abi / asm-host → shell 权威；Makefile 薄叶子 + export
  - ✅ 叶清单 / 组合体定义 → `compiler/mk/*.mk`（G.7 单权威；catalog 18 keys）
  - ✅ FULL=1 / 冷路径编排已 shell；**Makefile 已物理删除** — 不再经 make 白名单叶
  - ✅ `tests/lib/compiler-make.sh` **0-make** 分发（formal_mod / std_x / try-heat / bootstrap / g05）；formal_std + net-tls ensure 命令串 → bash hub（.x + seed）

✅ **11.0.4 根 Makefile 只保留 help → xbuild → 已物理删除**

  - ✅ OBJS 叶 + 组合体 → `compiler/mk/*.mk`；`export-obj-catalog` + `driver_seed_obj_catalog.sh`（禁 shell 双清单）
  - ✅ **`./xbuild`** 薄转调 **`xlang-build.sh`**（G.7 同体）；根 Makefile 已物理删除
  - ✅ compiler/Makefile 编排权威 → catalog/shell/g05；**文件已 git rm**

### 11.1 核心功能

🟡 **11.1.1 依赖图分析**

  - 扫描 .x import / seed 输入 / 平台条件；增量重编
  - 对齐 code-review-graph 思路可选，但 **权威在 xbuild**
  - ✅ 编排 DAG **库存** — `compiler/docs/BUILD_DAG.md` + `product_build_dag.sh` dump/`--check`；`./xbuild product-dag`；产品日路径 + 冷启动节点/owner；G.7 禁第二套列表（仍 mk/catalog）
  - ✅ `DRIVER_SEED_PREREQS` **边满足** → `driver_seed_ensure_prereqs.sh`（catalog 列表 + glue companion）
  - ⬜ 终局：import 扫描 + 增量图执行（依赖 11.1.2）；叶 pattern residual → 11.3.1

🟡 **11.1.2 编译调度（.x → .o）**

  - 默认 **asm backend**（BC 终局）；过渡期允许显式 `host-cc` 仅编 **白名单 residual C**（清单来自 8.3/9，逐步清空）
  - 并行：线程原语（10.6）就绪前可用进程池 / 外部 ninja 过渡（**过渡须标 temporary**）
  - ✅ 编排图 **schedule 执行** — `product` / `refresh` / `cold` 命名调度；`--dry-run` / `--run`；`run` 只转调既有 shell 体（G.7 禁双路径）
  - ✅ cold 调度首节点 `cold_ensure_prereqs`；live outer 内嵌 shell ensure
  - ⬜ 终局：.x import 增量图 + 并行；冷启动叶不经 make pattern（与 11.3 同闸）

🟡 **11.1.3 平台处理**

  - Linux / macOS / Windows 路径·ABI·seed 选择
  - 替代历史 Makefile `UNAME` / Alpine 等
  - ✅ 权威 `compiler/docs/PLATFORM_LINKER.md` + `host_platform_linker.sh`；`./xbuild host-platform`
  - ✅ 叶 UNAME residual 类 **R2** 已在 `LEAF_PATTERN_RESIDUAL.md` 命名
  - ⬜ 终局：UNAME 叶 pattern 全吞（与 11.3.1 同闸）；禁 shell 第二套 uname 矩阵

🟡 **11.1.4 链接器调用**

  - 直接调 `ld` / `lld` / `link.exe`（syscall 或 raw FFI / 过渡 `posix_spawn`）
  - **禁止**默认 `$(CC) -o` 当链接器（避免偷偷拉 cc）
  - ✅ 策略库存 — prefer `xlang_asm_invoke_ld_platform` + direct ld；命名 residual `SEED_LINK_CC -o`；`./xbuild linker-policy`
  - ✅ cold / g05 product **pure-ld**（`pure_ld_shared.sh`）；eligible 路径 hard fail on pure miss；named CC residual only `FORCE_CC` / ineligible
  - ⬜ 终局：Windows PE pure-ld · 无任何 residual `CC -o`（含 FORCE_CC 逃生口收敛）

🟡 **11.1.5 填实 `build.x` 策略源**

  - ✅ 根 `build.x` 英文策略图（产品/冷启动/残余叶/xbuild 目标映射）；三函数 ABI 保持 pin-compatible
  - ✅ `build.x` §F 挂 BUILD_DAG / product-dag / schedule / ensure_prereqs / host-platform / linker-policy
  - ⬜ 终局：DAG-as-data 替代 C build_runtime 步表（依赖 11.1.1–4 执行层）

🟡 **11.1.6 吞并 g05 脚本族**

  - `g05_ensure_relink_prereqs` / `g05_relink_env` / `g05_relink_xlang` / `g05_prepare_and_relink` / `build_xlang_asm.sh`
  - ✅ `./xbuild ensure|link-env|link-product|link-product-asm` 直调 g05 shell（**零 make**）
  - ✅ `run_compiler_make` 与 tests hub 合体 → `tests/lib/compiler-make.sh`（G.7 单体）
  - ✅ `refresh_xlang_asm_gate.sh` / `migrate_x_objs.sh` / `ensure_migrate_gen.sh` / `lexer-gen` / `driver-gen` / `lsp-gen` / `pipeline-gen` / `archaeology-gen` 唯一体 + `./xbuild` 入口
  - ⬜ 终局：xbuild 内建或单一 `scripts/g05` 族；无 make 间接调用 / seed prereq 图（与 11.3 同闸）

### 11.2 自举 stage + 测试/CI 编排

⬜ **11.2.1 stage1 → stage2 → stage3 编排**

  - seed_xlang → xlang_v1 → xlang_v2 → xlang_v3；自动 v2==v3

⬜ **11.2.2 L4 真冷全测集成**

  - `xbuild cold-test`：全擦 `compiler|std|core` 下 `.o` + 删产品二进制 → seed/g05 或纯 xbuild → 矩阵 → `run-all-bstrict`（`XLANG_BSTRICT_SKIP_BUILD=1`）

✅ **11.2.3 prove / bstrict / gate 脚本去 make**

  - `tests/**/*.sh`（含 `tests/lib/*.sh` · `bench/**/*.sh` · `tests/docker/*`）中 `make -C compiler` 清零或改为 `xbuild` / `xlang_compiler_make`
  - ✅ `tests/lib/compiler-make.sh` 单入口 `xlang_compiler_make`；tests/lib **0** raw `make -C`（hub 外）；`XLANG_COMPILER_DIR` 支持 nolibc
  - ✅ `tests/run-*.sh` **0** raw `make -C`（~456 脚本 → hub）；图仍 Makefile 至 11.3
  - ✅ 全仓 `tests/**/*.sh` 0 raw make -C（bench 本无 make -C，vacuous close）；CLI 模式供 xbuild 共用 hub
  - docker CI 外层 / 11.2.5 workflow ✅

⬜ **11.2.4 Windows 入口**

  - 非金标但终局须有 xbuild 路径（MSYS2）；禁止「只 Linux 删了 Makefile」
  - 🟡 CI Windows job 已 `./xbuild compiler-all`；本地 MSYS2 入口仍待 11.2.4

✅ **11.2.5 `.github/workflows/*.yml` CI 去 make/cc（外层）**

  - `ci.yml` / `ci-nightly.yml` / `selfhost-stage2.yml` / `release.yml`：构建入口 → `./xbuild compiler-all` / `bootstrap-driver-seed` / `compiler-make` / shell `clean`
  - `bootstrap-seeds-capture.yml`：无 `make -C`（仅装 gmake 包）
  - 实现层仍经 `xlang-build.sh`→`run_compiler_make` 触 Makefile 图（至 11.3）；guest 仍装 host-cc/make（零 cc 属 12）

### 11.3 Makefile 物理删除（**终局硬指标** · ✅ 已完成）

✅ **11.3 residual · prereq 边吞并 → 物理删 Makefile**

  - ✅ `driver_seed_ensure_prereqs.sh`：catalog 展开 `DRIVER_SEED_PREREQS` + glue companion；`--dry-run` / `--check` / `--run`
  - ✅ `bootstrap_driver_seed.sh` step 0 调 ensure；历史 Makefile 薄 phony 已删除
  - ✅ `./xbuild driver-seed-prereqs`；cold dry-run 印 `PREREQ=` 边
  - ✅ 叶 pattern / host-cc residual → shell ensure + **Makefile 物理删除**
  - ✅ R1–R6 叶路径（host-cc seed / UNAME stamp / thin+rest / rebuild / CI / pure-ld）→ catalog + shell
  - ✅ g05 prefer 族 / pure-ld 与 cold 同体（无 silent CC fallback）

✅ **11.3.1 路径 · 叶 pattern residual + 物理删除**

**状态**（波次流水只写 `自举进度.md` · 本文件只保留 ✅/🟡/⬜）：

- ✅ 权威图：`compiler/docs/LEAF_PATTERN_RESIDUAL.md`
- ✅ 机检：`leaf_pattern_residual.sh` / `phys_del_makefile_gate.sh` **post_ship**（MF 缺席绿、无 stderr 噪声、无「unexpected early delete」假文案）
- ✅ R1 host-cc seed · R2 UNAME stamp · R3 thin+rest · R4 rebuild pattern bodies · R5 CI all · R6→11.1.4
- ✅ B1–B7 命名桶 + phys-del prep + Windows gate + dual-end verify
- ✅ R4 / B 桶列表 → `mk/*.mk` + catalog/shell ensure（bootstrap 默认冷路径 0 make）
- ✅ **B7 residual endgame · physical delete / 删 Makefile**
  - ✅ lists/thin 收口 · Windows tip 复证 · Mac/Ubuntu L4 · 用户授权 → **已 ship 物理删体**
  - ✅ heat / STATUS / TREE_ARMED / delete-body honesty / std_x·formal_mod·bags→mk / FORCE thin / 全 phony shell-primary
- ✅ **物理删 `compiler/Makefile`**

✅ **11.3.1 删除 `compiler/Makefile`**

  - ✅ 迁移表有主 shell/catalog；R1–R5 / B1–B7 / heat / preflight / gates / dual L4
  - ✅ `xlang-build.sh` bootstrap → 直调 `bootstrap_driver_seed.sh`；host_stubs catalog
  - ✅ **物理删除** 根 + `compiler/Makefile`；ensure CFLAGS → catalog；钉盘 `77b334842`
  - ✅ post-delete residual（0-make hub · gate/leaf post_ship · catalog bags · ensure_* `--check`）
  - ✅ BC 库存机检：`bc_host_cc_product_inventory.sh` / `./xbuild bc-inventory --check` · 8.3.1 ctfe+assign+coerce_init+method_call+check_block · 8.3.9 孤儿 absent
  - 🟡 8.3/7/8 residual C **仍在**（host-cc 编；MG 编排层已独立完成，BC 层另计）
  - 验收 grep：
    ```
    rg -n 'make -C compiler|compiler/Makefile|\bmake\s+-C|\$\(MAKE\)' \
       tests scripts tools editors .github analysis build.sh xlang-build.sh
    ```

✅ **11.3.2 删除仓库根 `Makefile`**

  - 入口：`./xbuild` 或 `./xlang-build.sh` → xbuild（根 Makefile 已不存在）

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

✅ **11.4.1 `build.sh`（根目录）薄转发 `./xbuild`**

  - 旧体：直接 `cc` 链 `build_tool`（双权威 + 已坏变量 `$LINK_SHU`）
  - 现体：默认 `./xbuild build`；参数透传任意 xbuild 目标；**0× host-cc**
  - host-cc residual 仅 `compiler/scripts/build_tool.sh`（至阶段 12）

✅ **11.4.2 `xlang-build.sh` 产品路径 0× make -C；CI hub 单点**

  - 产品目标（build/clean/test*/bootstrap-* 烟测）已 shell
  - ✅ `bootstrap-driver-seed` **不再**经 `run_compiler_make` → 直调 `bootstrap_driver_seed.sh`
  - ✅ `run_compiler_make` / `tests/lib/compiler-make.sh` **0-make** 分发（无 make -C）；`compiler_all_ci` 直 g05 + ensure_xlang_c
  - 外层 `./xbuild compiler-make <args…>` 目标名不变

✅ **11.4.3 `scripts/docker-ci-local.sh` 外层 0× `make -C`**

  - 全矩阵段 → `./xbuild clean|compiler-all|test_*|bootstrap-*|compiler-make …`
  - 与 11.2.5 同入口；guest 仍需 build-essential（零 cc 属 12）

✅ **11.4.4 `tools/verify-xlang-migration.sh` 提示 → xbuild**

🟡 **11.4.5 `tests/docker/linux-dev.Dockerfile`（入口文档）**

  - ✅ `XLANG_PREFERRED_ENTRY=./xbuild` + `org.xlang.entry` label
  - ⬜ 仍装 `gcc make`（build_tool / seed / bench 差分 residual；**卸包装 = 阶段 12**）

✅ **11.4.6 `tests/lib/delete-one-c-file.sh` → `./xbuild`**

  - host + Docker 回归：`./xbuild bootstrap-driver-bstrict`（无 raw `make -C`）
  - bare ubuntu guest 仍可 apt residual gcc/make（至阶段 12）
### 11.5 tests/ 对照 C 文件处理策略（**零 cc 终局下的归属**）

> **背景**：`tests/` 下有 ~200 个 .c 文件（bench/、std-*/、abi/、leak/、safe/、kernel/），当前需 host cc 编译做对照/smoke。阶段 8.3 只管 compiler/ 内 residual C，**完全没覆盖 tests/ 下的对照 C**。零 cc 终局下必须决定它们的归属。

🟡 **11.5.1 `bench/**/*.c`（~50 个）对照基准 C**

  - `loop_i32.c` · `mem_copy.c` · `simd_dot.c` · `struct_param.c` · `call_boundary.c` · `zero_copy_sendfile*.c` · `regex_match_*.c` · `http_bench_server.c` · `net_*.c` · `io_*.c` · `async_*.c` · `diff/d1_int_arith.c` ~ `d6_mem_ops.c`
  - **策略裁定**：**永久 host-cc 白名单（仅差分/对照基准）** — 不进产品路径、不进 g05、不经 `./xbuild all`；与 `.x` 对照测时由 bench 脚本显式 `cc`（标 temporary residual 至阶段 12 零 cc 终局复审）。优先路径：有 `.x` 孪生则产品侧只编 `.x`；裸 `.c` 不强制本波改写
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.1

🟡 **11.5.2 `tests/std-*/*.c`（50 个）std 模块 smoke 测试 C**

  - `tests/std-sqlite/*_ok.c` · `tests/std-elf/*_ok.c` · `tests/std-crypto/*_smoke*.c` · `tests/std-math/*` · `tests/std-config/*` · `tests/std-uuid/*` · `tests/std-ffi/*` · `tests/std-trace/*` · `tests/std-context/*` · `tests/std-base64/*` · `tests/std-tar/*` · `tests/std-task/*` · `tests/std-log/*` · …
  - 被 `tests/lib/std-*.sh` 用 host cc 链接 **已编好的** `std/**/*.o`
  - **策略裁定**：**永久 host-cc 白名单（C smoke harness only）** — 不进 g05 / `./xbuild all` / 产品编译器链接；产品绿以 bstrict / `.x` 闸门为准；改写为 `.x` 属阶段 12 复审，不挡 11.3
  - 权威清单：`tests/HOST_CC_POLICY.md` §11.5.2（50 路径 + 闸门 floor ≥40）

🟡 **11.5.3 `tests/abi|leak|safe|kernel/*.c` 探针 C**

  - `tests/abi/layout_abi.c` · `tests/leak/leak_probe.c`（cc -fsanitize=address）· `tests/safe/race_probe.c` · `tests/kernel/freestanding_stubs.c`
  - **策略裁定**：**永久 host-cc 白名单（ABI / sanitizer / freestanding 探针）** — 依赖 host 工具链能力；不进产品链；权威见 `tests/HOST_CC_POLICY.md` §11.5.3

🟡 **11.5.4 `tests/probes/**/*.c` prove/seed 工具产物**

  - `seed_optional/*/optional_gen.c` · `prove_x_o/*/{*.gen.c,*.raw.c,*.seed.probe.c,*.merged.probe.c,thin.c}` · `bootstrap-parser/{csv_core,json_core}_gen_probe*.c`
  - **策略裁定**：**非产品 residual 类** — 工具/生成物；多数不入库；随 prove→xbuild 收缩；禁止扩成产品 host-cc 债。权威：`tests/HOST_CC_POLICY.md` §11.5.4

### 11.6 editors/ 与文档去 make（**用户指南同步**）

⬜ **11.6.1 `editors/tree-sitter-xlang/` 第三方 grammar**

  - 自带 Makefile + binding.gyp + Cargo.toml(cc crate) + bindings/rust/build.rs
  - 策略：git submodule / 独立 release / 删除（与 xlang 自举链解耦）

✅ **11.6.2 `editors/vscode/` 用户提示语**

  - package.nls.* · l10n.bundle.* · src/lspClient.ts · README · editors/LSP接入.md
  - 全部改为 `./xbuild bootstrap-driver-seed`（Makefile 已删）

✅ **11.6.3 `README.md` / `README_zh-CN.md` 用户指南**

  - 首次/日常/贡献入口 → `./xbuild build-tool|first-time|build|full|bootstrap-driver-seed|compiler-make`
  - MG 状态改为 Makefile **已删**；钉盘摘要对齐 `77b334842`


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

🟡 **13.2.2 Makefile 物理删除验收**（文件层 ✅ · 零 make 调用面 🟡）

  - ✅ `test ! -e Makefile && test ! -e compiler/Makefile`
  - ✅ 产品入口 / 文档 / labi hint → `./xbuild`（无 make -C）
  - ✅ ensure 阶梯 / gen / tests / link bags shell-primary + catalog bag（MF 缺席绿）
  - ✅ `bc_host_cc_product_inventory.sh` / `./xbuild bc-inventory --check` · 8.3.9 孤儿 absent
  - 🟡 仍有 host-cc residual C（BC/PC 未闭）；逃生口 env 仍可能调 make

⬜ **13.2.3 零 cc 三义验收**（§0.1 MG+BC+PC）

  - strace 无 make/cc/gcc/clang（或 make 仅用户 PATH 偶然存在但从未被调用）

⬜ **13.2.4 labi_invoke_cc / `-backend c` 退役或隔离**

  - 产品默认不 exec host-cc；历史 C 后端进 experimental 或删除

### 13.3 收尾

⬜ **13.3.1 物理删 seed 业务体（考古归档）**

  - pin/from_x 业务 C 出主链；最小 seed 单独归档

⬜ **13.3.2 宣布自举完成**

  - 公告：**Xlang 自举完成 — 无 Makefile + 零 host-cc + v2==v3**
  - **完成后主线**见 [`自举完成后功能完善及优化时序表.md`](自举完成后功能完善及优化时序表.md)（P0 基线 → P1 CLI/`xlang test` T1 → P2 语言/优化/std/**toml Core**/**IR 旁路** → P3 DX → P4 生态）


---

## 附录 A：代码量分布（快照 · 文档创建时；审计后补 glue 列）

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
| 钉盘 SHA | **`77b334842`**（Makefile 物理删除 + 双端 L4） |
| 前钉 SHA | `9bb7a757c` · `4fa4f07e7` |
| 上次 L4 日期 | 2026-07-31 |
| 双端 bstrict 数 | 129（历史钉盘）；tip 产品矩阵/bootstrap 绿 |
| mac 产品链 | ✅ build/g05 OK |
| Ubuntu L4（金标） | ✅ wipe+bootstrap+build+smoke OK |
| 工程轨 KPI | T 18/18 · N 111/111 IDENTICAL |
| MG | ✅ 根 + `compiler/Makefile` 已物理删除 |
| git 锚点 / 波次流水 | 见 `自举进度.md` |

## 附录 D：综合迁移进度（终局 = **无 Makefile** + 零 cc 三义）

```
旧终局（v2==v3 + 无 pin）≈ 74.5%（历史权重）

新终局权重（MG 物理删后）：
  库+T+N+R2+M拆分+Cap≈         0.40 × ~85%  → ~34%
  阶段 7/8 gen 去 pin            0.10 × ~25%  → ~2.5%
  阶段 8.3 glue/ast（新）        0.12 × ~5%   → ~0.6%  （CTFE 域已切；整体仍 🟡）
  阶段 9 residual                0.12 × 0%    → 0%
  阶段 10 语言 L2                0.10 × 0%    → 0%
  阶段 11 Makefile 退役/xbuild   0.12 × ~95%  → ~11%  （**MG 文件删除 ✅**；0-make hub ✅）
  阶段 12–13 冷启动+终局验收     0.04 × ~10%  → ~0.4% （13.2.2 文件层 ✅；零 cc / v2==v3 ⬜）
                                 合计 ≈ 48–50%
```

**综合迁移进度（修订）：约 48–50%**  
MG **编排层** ✅。BC 🟡（库存机检 + CTFE/assign 域已切）。PC ⬜。剩余主债：**8.3 glue 续切** · **PC 零 cc** · **去 pin** · 阶段 12 冷启动。

剩余工作优先级（MG 已闭后）：

1. ✅ **post-delete residual** — 0-make hub · gate post_ship · catalog bags · ensure_host_cc --check  
2. 🟡 **BC + 阶段 8.3**（库存 ✅ · 8.3.1 四十九刀（+array_lit durable／slice reent／**var_decl+lazy_append 共享叶**／**slice dual-GP+slice_from_array 同叶**／**sret return path 同叶**／**field_access layout/offset 同叶**／**lea/arm64 sret helpers 同叶**／**async CPS emit domain 同叶**／**x86 micro-encoders 同叶**／**with_arena scope domain 同叶**／**cmp cc helpers 同叶**／**empty struct check 同叶**／**TokenKind variant tag 同叶**／**float bits lo/hi 同叶**／**struct_lit field offset/type_ref 同叶**／**block_final_expr 同叶**／**array_let_empty_init 同叶**／**struct_layout_compute_field_offset 同叶**／**func_param_agg_byte_size 同叶**／**func_return_byte_size 同叶**／**func_param_home_width 同叶**／**call_return_byte_size 同叶**）+ index_eff／emit_expr fast／call_arg／try_binop 有则补全 ✅ · **8.3.2 …+top_level residual ✅** · 8.3.9 ✅ · **当前：8.3.1 其它 leaf residual 或 8.3.3 field_access／soa**）
3. ⬜ **阶段 7.4 + 8.2** typeck/codegen/parser… 去 pin  
4. ⬜ **阶段 10 → 9** 语言能力 + residual 消灭  
5. ⬜ **阶段 12–13** 冷启动零 cc 三义 + v2==v3 + 公告  

## 附录 E：compiler/Makefile 迁移表（摘要 · 全量见独立文档）

> **全量权威清单**（11.0.1）：[`analysis/Makefile迁移表.md`](Makefile迁移表.md)  
> 每完成一行迁移到 xbuild，在迁移表「迁移状态」列改 ✅，并回写本摘要若影响仪表盘。

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
| **J** | test / check / verify | 12 | shell + tests hub | `xbuild test` / `cold-test` | ✅ 11.2.3 tests/** hub |
| **K** | seed 工具 | 4 | Makefile | `xbuild seed-tools` | ⬜ 11.0.3 |
| **L** | std 变体 stub | 10 | Makefile | `xbuild std-variant` | ⬜ |
| **M** | clean / compile_commands / legacy | 6 | make / 考古 | util 或 🗑 | 🟡 |
| **N/O** | link alias / 未分类 | ~14 | g05 / 待确认 | stubs 或 🗑 | ⬜ |
| **Σ** | | **~288** | | | 盘点 ✅ 迁移 ⬜ |


---

> **使用方式**：每完成一步，将本文对应待办 `⬜`→`✅`/`🟡` 并保持状态表准确。  
> **波次叙事 / 变更记录**：只写 [`自举进度.md`](自举进度.md)（本文不设 changelog）。  
> **删 Makefile 自检**：动构建系统前先更新附录 E；宣称「无 Makefile」前跑 13.2.2–13.2.4。
