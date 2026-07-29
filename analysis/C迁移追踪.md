# C → .X 迁移追踪（自举全程待办地图）

> **创建**：2026-07-29（wave710 tip L4 钉盘 `53fd80927` 双端 129 全绿后）
> **用途**：全面列出 C 逻辑迁移到 .X 的所有步骤，按自举顺序排列。每完成一步打勾。已完成的打 ✅，未完成的打 ⬜，永久边界（不可迁）打 🔒，部分完成打 🟡。
> **方法**：[自举方法.md](自举方法.md)（Cap / R / L / M 四轨）
> **进度数字**：[自举进度.md](自举进度.md) · [当前进度.md](当前进度.md)
> **维护约定**：每完成一波自举，更新本文对应待办项的勾选状态 + 日期/波次标注。

---

## 0. 总览仪表盘

| 维度 | 状态 | 数据 |
|------|------|------|
| **库层（std+core）.x 化** | ✅ 100% | 178 文件 / 75,007 行 .x · 0 行 .c |
| **Thin 退役（T）** | ✅ 18/18 | 18 号结案 |
| **Prove 注册（N）** | ✅ 111/111 IDENTICAL | MODULES 数组实际 128 条（17 条后期新增未计入 KPI） |
| **R2 真迁退役** | 🟡 ~85% | 128 prove 模块中 ~120 已 R2；Cap residual 永久边界 ~8 模块 |
| **Mega 拆分（M1-M3）** | ✅ 3/3 mega 拆分完成 | runtime 24/24 · parser 21/21 · link_abi 11/11 切片 |
| **Mega 去 pin（M4）** | ⬜ 0/3 | runtime / parser / link_abi 均 pinned |
| **Pinned gen.c 退役** | 🟡 8/19 | Track L 退役 8 个；仍 pinned 11 个（前端核心） |
| **Cap 能力解锁** | 🟡 持续 | 已闭多波；untyped self 待治；LANG-006 保留 |
| **产品 L4 放行** | ✅ 钉盘 `53fd80927` | 双端 L4 真冷 + 129 bstrict |
| **终局 v2==v3** | ⬜ 未达 | 需 mega 去 pin + pinned gen.c 退役后 |

---

## 阶段 0：基建与方法论（已完成）

- [x] **0.1 自举方法论确立**（Cap/R/L/M 四轨）✅ 2026-07-14
- [x] **0.2 工程轨 vs 产品轨分清**（禁止工程轨绿当自举完成）✅ 2026-07-15
- [x] **0.3 日常真测 vs 真冷全测节奏**（L2/L3 日常 · L4 整波收口）✅ 2026-07-16
- [x] **0.4 双端验证纪律**（macOS 开发 + Ubuntu 金标）✅
- [x] **0.5 git 锚点机制**（每波前建 tag，可秒级回退）✅
- [x] **0.6 产品闸门 skill**（`xlang-selfhost-product-gate`）✅

---

## 阶段 1：库层 .X 化（已完成 · 100%）

### 1.1 std/ 标准库

- [x] **1.1.1 std/ 全目录 .x 化** ✅ 166 文件 / 72,941 行 .x · 0 行 .c
- [x] **1.1.2 std/io/** ✅
- [x] **1.1.3 std/fmt/** ✅
- [x] **1.1.4 std/string/** ✅
- [x] **1.1.5 std/sync/** ✅
- [x] **1.1.6 std/result/** ✅
- [x] **1.1.7 std/option/** ✅
- [x] **1.1.8 std/crypto/** ✅
- [x] **1.1.9 std/net/** ✅
- [x] **1.1.10 std/其余子目录** ✅

### 1.2 core/ 核心库

- [x] **1.2.1 core/ 全目录 .x 化** ✅ 12 文件 / 2,066 行 .x · 0 行 .c
- [x] **1.2.2 core/fmt** ✅
- [x] **1.2.3 core/result** ✅
- [x] **1.2.4 core/其余** ✅

---

## 阶段 2：Thin 退役 Track T（已完成 · 18/18）

> **定义**：hybrid 模块 thin 切片 prove IDENTICAL，构建切换至 thin.x。
> **结案**：18/18 ✅

- [x] **2.1 T-001 ~ T-018 全部 thin 退役** ✅ 18 号结案
- [x] **2.2 T 降为维护指标**（不占前排）✅

---

## 阶段 3：Prove 注册 Track N（已完成 · 111/111）

> **定义**：prove_module_selfhost.sh nm IDENTICAL 验证。
> **KPI**：N=111/111 IDENTICAL ✅（28 日 wave539–575 扩至）
> **注意**：MODULES 数组实际 128 条；17 条后期新增未计入 KPI。

### 3.1 driver 组（11 条）

- [x] **3.1.1 fmt** ✅ Track L 退役
- [x] **3.1.2 check** ✅ Track L 退役（archaeology）
- [x] **3.1.3 test** ✅ Track L 退役（archaeology）
- [x] **3.1.4 build** ✅ Track L 退役（archaeology）
- [x] **3.1.5 run** ✅ Track L 退役（archaeology）
- [x] **3.1.6 compile** ✅ R2 真迁（Track L 退役）
- [x] **3.1.7 emit** ✅ R2 真迁（Track L 退役）
- [x] **3.1.8 lsp_io_std_heap** ✅ Track L 退役叶子
- [x] **3.1.9 target_cpu_flags** ✅ R2 DIRECT（wave559）
- [x] **3.1.10 fmt_check_cmd** ✅ R2 mixed（wave565）
- [x] **3.1.11 fmt_check** ✅ R2 thin + Cap residual pure 深迁

### 3.2 lexer 组（1 条）

- [x] **3.2.1 token** ✅ prove 锁 nm 面

### 3.3 lsp 组（4 条）

- [x] **3.3.1 lsp_diag_pipeline_sizes** ✅
- [x] **3.3.2 lsp_diag_stubs_no_c** ✅ R2 DIRECT（wave557）
- [x] **3.3.3 lsp_diag_pipeline_ctx** ✅ R2 thin+rest（wave561）
- [x] **3.3.4 lsp_io_std_heap** ✅（见 driver 组）

### 3.4 runtime 组 — labi_* 切片（12 条，link_abi mega）

- [x] **3.4.1 labi_path_pure** ✅ R2 full（L0）
- [x] **3.4.2 labi_diag_pure** ✅ R2 full（L1）
- [x] **3.4.3 labi_host_lit** ✅ R2 full（L2）
- [x] **3.4.4 labi_path_io** ✅ R2 full（L3 · Cap: stat/realpath 🔒）
- [x] **3.4.5 labi_ensure_list** ✅ R2 full（L4）
- [x] **3.4.6 labi_invoke_cc_list** ✅ R2 full（L5 · Cap: getenv 🔒）
- [x] **3.4.7 labi_invoke_ld_list** ✅ R2 full（L6 · Cap: spawn/ld 🔒）
- [x] **3.4.8 labi_freestanding_list** ✅ R2 full（L7）
- [x] **3.4.9 labi_std_list** ✅ R2 full（L8）
- [x] **3.4.10 labi_ondemand_list** ✅ R2 full（L8b）
- [x] **3.4.11 labi_ondemand_heavy** ✅ R2 full（L8b heavy）
- [x] **3.4.12 labi_gates** ✅ R2 full（L9）

### 3.5 runtime 组 — rt_* 切片（23 条，runtime mega）

- [x] **3.5.1 rt_dispatch_thin** ✅ R2 thin+rest（wave561）
- [x] **3.5.2 rt_dispatch_impl** ✅ R2 full
- [x] **3.5.3 rt_asm_stub** ✅ R2 full
- [x] **3.5.4 rt_fmt_one** ✅ R2 full
- [x] **3.5.5 rt_pipeline_elf_diag** ✅ R2 full
- [x] **3.5.6 rt_run_x_emit** ✅ R2 full
- [x] **3.5.7 rt_parse_diag** ✅ R2 full
- [x] **3.5.8 rt_diag_errno** ✅ R2 full
- [x] **3.5.9 rt_fs_open** ✅ R2 full
- [x] **3.5.10 rt_arena_buf** ✅ R2 full（Cap-global-bss 🔒）
- [x] **3.5.11 rt_preamble** ✅ R2 full（Cap-giant-string 🔒）
- [x] **3.5.12 rt_stack** ✅ R2 full（Cap-fn-ptr 🔒）
- [x] **3.5.13 rt_lib_root** ✅ R2 full
- [x] **3.5.14 rt_emit_flags** ✅ R2 full
- [x] **3.5.15 rt_emit_state** ✅ R2 full（Cap-global-bss 🔒）
- [x] **3.5.16 rt_content** ✅ R2 full
- [x] **3.5.17 rt_util** ✅ R2 full
- [x] **3.5.18 rt_argv** ✅ R2 full
- [x] **3.5.19 rt_entry** ✅ R2 full
- [x] **3.5.20 rt_compile** ✅ R2 full
- [x] **3.5.21 rt_run_exec** ✅ R2 full
- [x] **3.5.22 rt_run_asm_backend** ✅ R2 full
- [x] **3.5.23 rt_run_compiler_parsed** ✅ R2 full

### 3.6 asm 组 — runtime_* 切片（41 条，asm OS 桥）

- [x] **3.6.1 runtime_time_os** ✅ R2 thin+rest（Cap: clock_gettime 🔒）
- [x] **3.6.2 runtime_path_fast** ✅ R2 DIRECT
- [x] **3.6.3 runtime_dynlib_os** ✅ R2 thin+rest（Cap: dlopen 🔒）
- [x] **3.6.4 runtime_panic** ✅ R2 thin+rest
- [x] **3.6.5 runtime_panic_arm64** ✅ R2 thin+rest
- [x] **3.6.6 runtime_process_argv** ✅ R2 thin+rest
- [x] **3.6.7 runtime_test_fn_invoke** ✅ R2 thin+rest（Cap: fnptr 🔒）
- [x] **3.6.8 runtime_net_workers** ✅ R2 thin+rest（Cap: fnptr 🔒）
- [x] **3.6.9 runtime_compress_zlib_glue** ✅ R2 thin+rest（Cap: zlib.h 🔒）
- [x] **3.6.10 runtime_arrow_simd_glue** ✅ R2 thin+rest（Cap: SIMD 🔒）
- [x] **3.6.11 runtime_random_fill** ✅ R2 thin+rest wave544（Cap: getrandom 🔒）
- [x] **3.6.12 runtime_tls_mbedtls_bio** ✅ R2 thin+rest wave544（Cap: mbedtls 🔒）
- [x] **3.6.13 runtime_ed25519_ref10_glue** ✅ R2 thin+rest wave544（Cap: .inc 宏 🔒）
- [x] **3.6.14 runtime_net_udp_batch** ✅ R2 thin+rest wave545
- [x] **3.6.15 runtime_net_sock_fast** ✅ R2 thin+rest wave545
- [x] **3.6.16 runtime_net_dns_fast** ✅ R2 thin+rest wave545（Cap: getaddrinfo 🔒）
- [x] **3.6.17 runtime_net_ipv6_fast** ✅ R2 thin+rest wave545
- [x] **3.6.18 runtime_net_addr_fast** ✅ R2 thin+rest wave546
- [x] **3.6.19 runtime_slice_glue** ✅ R2 DIRECT wave546
- [x] **3.6.20 runtime_crypto_inc_glue** ✅ R2 thin+rest wave547
- [x] **3.6.21 runtime_sync_lock_diag_tls** ✅ R2 mixed wave547
- [x] **3.6.22 runtime_std_runtime_fast** ✅ R2 DIRECT wave548
- [x] **3.6.23 runtime_atomic_glue** ✅ R2 thin+rest wave548（Cap: stdatomic 🔒）
- [x] **3.6.24 runtime_asm_build** ✅ R2 thin wave549（Cap: char** argv 🔒）
- [x] **3.6.25 runtime_asm_io_stubs** ✅ R2 thin+rest wave549（Cap: syscall 🔒）
- [x] **3.6.26 runtime_string_fast** ✅ R2 DIRECT wave549
- [x] **3.6.27 runtime_net_io_batch_fast** ✅ R2 thin+rest wave550
- [x] **3.6.28 runtime_env_os** ✅ R2 thin+rest wave550（Cap: getenv 🔒）
- [x] **3.6.29 runtime_http_glue** ✅ R2 mixed wave551
- [x] **3.6.30 runtime_queue_contention** ✅ R2 mixed wave551（Cap: pthread 🔒）
- [x] **3.6.31 runtime_backtrace_platform** ✅ R2 thin+rest wave552（Cap: execinfo 🔒）
- [x] **3.6.32 runtime_sync_os** ✅ R2 thin+rest wave552（Cap: pthread 🔒）
- [x] **3.6.33 runtime_channel_glue** ✅ R2 thin+rest wave553（Cap: pthread 🔒）
- [x] **3.6.34 runtime_log_os** ✅ R2 mixed wave553（Cap: write 🔒）
- [x] **3.6.35 runtime_scheduler_glue** ✅ R2 mixed wave554
- [x] **3.6.36 runtime_process_os_glue** ✅ R2 thin+rest wave554（Cap: execve 🔒）
- [x] **3.6.37 runtime_thread_glue** ✅ R2 thin+rest wave555（Cap: pthread 🔒）
- [x] **3.6.38 runtime_math_libm** ✅ R2 mixed wave564（Cap: libm 🔒）
- [x] **3.6.39 runtime_lsp_glue** ✅ R2 mixed wave566
- [x] **3.6.40 runtime_kv_mmap_glue** ✅（未在 prove 注册）
- [x] **3.6.41 runtime_ast_glue / runtime_lexer_glue / runtime_sqlite_glue** ✅（未在 prove 注册）

### 3.7 asm 组 — backend/simd/parser 切片

- [x] **3.7.1 asm_backend_compat_stubs** ✅ R2 DIRECT wave555
- [x] **3.7.2 bootstrap_nostdlib_stubs** ✅ R2 mixed wave556
- [x] **3.7.3 backend_seed_mega_fallback** ✅ R2 DIRECT wave556
- [x] **3.7.4 parser_asm_parse_expr_link** ✅ R2 thin+rest wave557
- [x] **3.7.5 user_asm_seed_bridge** ✅ R2 mixed wave558
- [x] **3.7.6 parser_asm_thin_c** ✅ R2 mixed wave560
- [x] **3.7.7 simd_loop_thin** ✅ R2 mixed wave563
- [x] **3.7.8 simd_enc_thin** ✅ R2 mixed wave568
- [x] **3.7.9 simd_loop** ✅ R2 full
- [x] **3.7.10 simd_enc** ✅ R2 full
- [x] **3.7.11 backend_enc_dispatch_thin** ✅ R2 thin full wave574
- [x] **3.7.12 backend_enc_dispatch** ✅ R2 full
- [x] **3.7.13 backend_arch_emit_dispatch_thin** ✅ R2 mixed wave567
- [x] **3.7.14 backend_arch_emit_dispatch** ✅ R2 full
- [x] **3.7.15 backend_try_inline_dispatch_thin** ✅ R2 mixed wave566
- [x] **3.7.16 backend_try_inline_dispatch** ✅ R2 full
- [x] **3.7.17 backend_call_dispatch_thin** ✅ R2 mixed wave567
- [x] **3.7.18 backend_call_dispatch** ✅ R2 full
- [x] **3.7.19 backend_x86_64_enc_c** ✅ R2 mixed wave570
- [x] **3.7.20 async_asm_pool** ✅ R2 full

### 3.8 src 根组（15 条）

- [x] **3.8.1 runtime_io_abi** ✅ R2 full（Cap: mmap/fstat 🔒）
- [x] **3.8.2 runtime_driver_diagnostic_thin** ✅ R2 thin + Cap residual pure
- [x] **3.8.3 runtime_driver_abi_thin** ✅ R2 thin + pure 深迁
- [x] **3.8.4 runtime_driver_strict_glue_stubs** ✅ R2 mixed wave560
- [x] **3.8.5 runtime_driver_strict_glue_thin** ✅ R2 mixed wave568
- [x] **3.8.6 runtime_driver_abi** ✅ R2 mixed wave569
- [x] **3.8.7 diag_thin** ✅ R2 mixed wave569
- [x] **3.8.8 diag** ✅ R2 mixed wave571
- [x] **3.8.9 runtime** ✅ R2 mixed wave572（mega 主名）
- [x] **3.8.10 runtime_link_abi** ✅ R2 mixed wave573（mega 主名）
- [x] **3.8.11 runtime_pipeline_abi** ✅ R2 full wave575
- [x] **3.8.12 runtime_heap_user** ✅ R2 DIRECT wave559
- [x] **3.8.13 build_runtime** ✅ R2 thin+rest wave558
- [x] **3.8.14 x_seed_bridge** ✅ R2 mixed wave562
- [x] **3.8.15 seed_link_compat** ✅ R2 mixed wave562

### 3.9 async 组（2 条）

- [x] **3.9.1 async_liveness** ✅ R2 pure + Cap residual pure
- [x] **3.9.2 async_cps_codegen** ✅ R2 pure + Cap residual pure

---

## 阶段 4：Cap 能力解锁 Track Cap（进行中）

> **定义**：一类语言/编译器能力缺口，阻塞 ≥2 模块真迁。一次修，多 rest 可真迁。

### 4.1 已闭合的 Cap 波次

- [x] **4.1.1 Cap-empty-str**（空串字面量 typeck/codegen）✅
- [x] **4.1.2 Cap-string-pool**（串池 >64 封顶）✅
- [x] **4.1.3 Cap-global-bss**（u8[N] 全局/static BSS）✅
- [x] **4.1.4 Cap-va-reportf**（reportf / va_list 深路径）✅ wave6
- [x] **4.1.5 Cap-regen-sync**（.x 改了 pin/patch 未同源）✅
- [x] **4.1.6 Cap-fn-ptr**（函数指针类型表达）✅ 部分（driver_run_stack_esc_gate 仍 🔒）
- [x] **4.1.7 Cap-giant-string**（巨型字串数据）✅ rt_preamble
- [x] **4.1.8 wave668 fs lit-left ptr cmp**（freestanding null==p / 0==p 假绿）✅ wave669
- [x] **4.1.9 wave677 bool→i32 算术提升**（binop/unary 假绿）✅ wave677
- [x] **4.1.10 wave311 i32→u64 widen**（true widen hole）✅
- [x] **4.1.11 wave311 i32→u8 窄存储**（var init/assign/return）✅ wave712 验证已闭
- [x] **4.1.12 wave421 impl Trait for T 缺方法**（false-green）✅ wave421
- [x] **4.1.13 wave450 零值参泛型 mono**（phantom T）✅ wave450
- [x] **4.1.14 wave459 host-C aggregate as cast**（compound literal / GNU stmt-expr）✅ wave459-462
- [x] **4.1.15 wave406 dual same-call 形参别名**（callee 静态 __xlang_al）✅ wave406
- [x] **4.1.16 wave284 标识符 >63 字节 honest-fail**（sticky overflow）✅ wave284
- [x] **4.1.17 wave707-709 match struct 模式链**（field bind + lit guard + wildcard + 显式 guard）✅ wave710 tip L4
- [x] **4.1.18 wave711 freestanding match field bind**（fs asm backend 4-arm 全组合）✅ wave711 验证已闭
- [x] **4.1.19 wave698 host-C 八层 scalar / 七层 NAMED fat**（nested slice 布局）✅ wave698
- [x] **4.1.20 wave677 LANG-007 unsafe block 诊断**（*T 解引用 + extern 调用须 unsafe）✅

### 4.2 当前前排 Cap 待办

- [ ] **4.2.1 untyped `self` 形参 skip** ⬜ **下一硬叶候选**
  - 症状：无类型标注的 `self` 形参（`fn m(self) {...}`）被 typeck/parser skip，未硬失败
  - LANG-006 标量 bool→int 保留不动（不当糊绿目标）
  - 日常 L2 推进

- [ ] **4.2.2 trait bounds / dyn Trait soft** ⬜
  - 症状：wave421 闭 missing-method，但 trait bounds 与 dyn Trait 仍 soft
  - typeck 不硬失败，留作后续收口

- [ ] **4.2.3 八层+ nested slice fat 布局 / 深 lit typeck** ⬜ soft
  - wave698 闭 8 层 scalar / 7 层 NAMED；更深仍 soft

- [ ] **4.2.4 bare `unit_t()` 无 turbofish + 零参 T subst** ⬜ leave-off
  - typeck 仍要求类型参数；零参 body/return T 替换无存储 type-arg refs

- [ ] **4.2.5 多 T 组合共享 bare link name** ⬜ leave-off
  - 不同 T 组合（`unit_t<A>()` vs `unit_t<B>()`）共用一个 C 函数

- [ ] **4.2.6 泛型方法 let-binding 接收者推断** ⬜ deferred
  - `y.dup()` 而非 `x.clone()` 的类型推断需 let-scan fallback
  - deferred to wave446，但 wave446 闭的是 parser 角列表，此项未见关闭

- [ ] **4.2.7 TYPE_SLICE call-arg 真递归 / 无堆重入 last-wins** ⬜ soft
  - wave406 闭 dual same-call；超出范围仍 last-wins 于静态 temp

- [ ] **4.2.8 AST name 槽 128 字节 layout raise** ⬜ leave-off
  - wave284 honest-fail 已绿；布局升维（fixed name[128] → 可变长度）仍 leave-off

- [ ] **4.2.9 LANG-006 标量 bool→int 保留** ⬜ **有意保留 soft**
  - `let x: i32 = true` 仍合法；显式保留的语言契约，非 bug

---

## 阶段 5：R2 真迁退役 Track R（大部分完成）

> **定义**：产品构建路径上，该 TU 业务符号全部来自 .x→.o，不再依赖 hybrid rest 同名 C 体。
> **判据**：rest 中该业务符号不再 `#ifndef` 提供 C 体；rest seed 可空/可删宏。

### 5.1 已完成 R2 真迁的模块（~120/128）

> 详见阶段 3 的 128 prove 模块列表。其中 ~120 个已 R2 真迁（rest 业务 H=0），仅保留 Cap residual _impl 桥或 marker。

- [x] **5.1.1 全部 labi_* 切片（12 个）R2 full** ✅
- [x] **5.1.2 全部 rt_* 切片（23 个）R2 full** ✅
- [x] **5.1.3 全部 runtime_* asm 切片（41 个）R2 thin+rest / DIRECT** ✅
- [x] **5.1.4 全部 backend/simd 切片（20 个）R2 mixed/full** ✅
- [x] **5.1.5 src 根组（15 个）R2 mixed/full** ✅
- [x] **5.1.6 async 组（2 个）R2 pure** ✅
- [x] **5.1.7 driver 组（11 个）R2 / Track L 退役** ✅
- [x] **5.1.8 lsp 组（4 个）R2** ✅
- [x] **5.1.9 lexer 组（1 个）prove 锁** ✅

### 5.2 R2 待收口项

- [ ] **5.2.1 wave445 SHARED ABI mono 字段 tip L4 收口** ⬜
  - 日常 L2 已过，tip L4 升钉未含此
  - 下一阶段收口时跑 L4

- [ ] **5.2.2 Darwin stage2 rv / strict multi-def** ⬜ 平台债
  - macOS stage2 riscv 与 strict 多重定义路径

- [ ] **5.2.3 host `_impl` 后缀命名** ⬜ leave-off
  - host-C 路径的 `_impl` 后缀命名（与 R2 真迁相关）

---

## 阶段 6：Mega 拆分 Track M1-M3（已完成 · 3/3）

> **定义**：M1 该 mega 源能被当前编译器 typeck / -E 消费；M2 regen *_x.o 替换 pinned .o smoke 绿；M3 Stage2 / D-03。

### 6.1 runtime mega 拆分（RFC: G-02f-P2-runtime-mega）

- [x] **6.1.1 R0–R10 全部落地** ✅ 11 册
- [x] **6.1.2 13 个 rest sub-slice 落地** ✅（rt_dispatch_impl / rt_asm_stub / rt_fmt_one / rt_pipeline_elf_diag / rt_run_x_emit / rt_parse_diag / rt_diag_errno / rt_fs_open / rt_arena_buf / rt_preamble / rt_stack / rt_lib_root / rt_emit_flags / rt_emit_state / rt_content / rt_compile / rt_run_exec / rt_run_asm_backend / rt_run_compiler_parsed）
- [x] **6.1.3 f-317 里程碑** ✅ product rest 业务 T 符号 = 0
- [x] **6.1.4 切片完成度** ✅ 24/24
- [x] **6.1.5 rest 仅 marker + Cap residual** ✅（R7/R8 OS/pthread 🔒 永久 seed 边界）

### 6.2 parser thin mega 拆分（RFC: G-02f-P2-parser-thin-mega）

- [x] **6.2.1 P0–P9 原计划落地** ✅ 10 册
- [x] **6.2.2 P10–P20 扩展落地** ✅ 11 册（f-318–f-329）
- [x] **6.2.3 f-329 P20 foundation** ✅ rest T=0
- [x] **6.2.4 f-330 omit empty rest** ✅ 全产品切片齐时跳过 mega rest cc -c
- [x] **6.2.5 24 个 pthin_*.x 切片** ✅
- [x] **6.2.6 切片完成度** ✅ 21/21

### 6.3 link_abi mega 拆分（RFC: G-02f-P2-link-abi-mega）

- [x] **6.3.1 L0–L9 全部落地** ✅ 10 册
- [x] **6.3.2 L8b ondemand 拆分** ✅（f-272）
- [x] **6.3.3 f-277 里程碑** ✅ link_abi L0–L9 十册 hybrid 齐
- [x] **6.3.4 12 个 labi_*.x 切片** ✅
- [x] **6.3.5 切片完成度** ✅ 11/11
- [x] **6.3.6 L3+ 含 stat/spawn/cc/ld → 🔒** ✅ 只做薄门闩或后移

---

## 阶段 7：Mega 去 pin Track M4（未开始 · 0/3）

> **定义**：M4 关 pin / 空 patch；冷启动可从「上一代 xlang -E」重建。
> **当前**：三大 mega 拆分完成（M1-M3），但 pinned *_gen.c 仍是产品链权威，去 pin 未开始。

### 7.1 runtime mega 去 pin

- [ ] **7.1.1 关闭 runtime pinned seed** ⬜
  - 当前：seeds/runtime.from_x.c（~7,320 LOC）仍是冷启动 seed
  - 目标：冷启动可从 .x 重建，不再依赖 pinned seed
- [ ] **7.1.2 runtime_driver_no_c.o 产品链去 pin** ⬜
  - 当前：RUNTIME_DRIVER_NO_C_CFLAGS 编译 pinned seed
  - 目标：产品 .o 全部来自 .x→.o
- [ ] **7.1.3 M3 Stage2 / D-03 验证** ⬜

### 7.2 parser mega 去 pin

- [ ] **7.2.1 关闭 parser pinned seed** ⬜
  - 当前：seeds/parser_asm_thin_c.from_x.c（~21,935 LOC）仍是冷启动 seed
  - 目标：冷启动可从 pthin_*.x 重建
- [ ] **7.2.2 parser_gen.c 去 pin** ⬜
  - 当前：Makefile L1760 pinned
  - 目标：regen parser_x.o 替换 pinned
- [ ] **7.2.3 M3 Stage2 / D-03 验证** ⬜

### 7.3 link_abi mega 去 pin

- [ ] **7.3.1 关闭 link_abi pinned seed** ⬜
  - 当前：seeds/runtime_link_abi.from_x.c（~6,920 LOC）仍是冷启动 seed
  - 目标：冷启动可从 labi_*.x 重建
- [ ] **7.3.2 runtime_link_abi_gen.c 去 pin** ⬜（如存在独立 pin）
- [ ] **7.3.3 M3 Stage2 / D-03 验证** ⬜

---

## 阶段 8：Pinned gen.c 退役（部分完成 · 8/19）

> **定义**：compiler/ 顶层的 *_gen.c 是 pinned 生成器，产品链权威。Track L 退役 = 构建改用 *_x.o，pinned gen 仅考古。

### 8.1 已退役的 pinned gen.c（8 个）

- [x] **8.1.1 lsp_io_std_heap_gen.c** ✅ Track L 退役（构建用 lsp_io_std_heap_x.o）
- [x] **8.1.2 driver_fmt_gen.c** ✅ Track L 退役（构建用 driver_fmt_x.o）
- [x] **8.1.3 driver_check_gen.c** ✅ Track L 退役（archaeology）
- [x] **8.1.4 driver_test_gen.c** ✅ Track L 退役（archaeology）
- [x] **8.1.5 driver_build_gen.c** ✅ Track L 退役（archaeology）
- [x] **8.1.6 driver_run_gen.c** ✅ Track L 退役（archaeology）
- [x] **8.1.7 driver_emit_gen.c** ✅ Track L 退役（构建用 driver_emit_x.o）
- [x] **8.1.8 driver_compile_gen.c** ✅ R2 真迁（构建用 driver_compile_x.o，gen 仍 pinned 但产品不读）

### 8.2 仍需退役的 pinned gen.c（11 个 · 前端核心）

- [ ] **8.2.1 parser_gen.c** ⬜ pinned（Makefile L1760 · XLANG_FORCE_REGGEN=1 to regen）
  - 前端核心：src/parser/parser.x
  - 阻塞：parser mega 去 pin（阶段 7.2）
- [ ] **8.2.2 lexer_gen.c** ⬜ pinned（Makefile L1843）
  - 前端核心：src/lexer/lexer.x
- [ ] **8.2.3 ast_gen2.c** ⬜ pinned（Makefile L2155）
  - AST 池：src/ast/ast.x（typeck/codegen 单 TU 依赖）
- [ ] **8.2.4 typeck_gen.c** ⬜ pinned（Makefile L2172）
  - 前端核心：src/typeck/typeck.x
  - 阻塞：typeck mega 去 pin
- [ ] **8.2.5 codegen_gen.c** ⬜ pinned（Makefile L2199）
  - 前端核心：src/codegen/codegen.x
  - 阻塞：codegen mega 去 pin
- [ ] **8.2.6 lsp_diag_gen.c** ⬜ pinned（Makefile L2551）
- [ ] **8.2.7 lsp_io_gen.c** ⬜ pinned（Makefile L2574）
- [ ] **8.2.8 lsp_gen.c** ⬜ pinned（Makefile L2613）
- [ ] **8.2.9 driver_gen.c** ⬜ pinned（Makefile L2870 · up-to-date with MAIN_X_DEPS）
  - driver main：src/main.x
- [ ] **8.2.10 preprocess_gen.c** ⬜ pinned（Makefile L2918）
  - preprocess：src/preprocess/preprocess.x
- [ ] **8.2.11 pipeline_gen.c** ⬜ pinned（Makefile L3325 · bootstrap-pipeline · P0-4 i64 ABI guard）
  - pipeline：src/pipeline/pipeline.x

---

## 阶段 9：Cap residual 永久边界（不可迁 · 🔒）

> **定义**：OS 系统调用 / 第三方库头依赖 / 宏展开 / C ABI 限制，Xlang 无法表达，留作永久 seed 边界。
> **性质**：这些不是"欠债"，是语言边界。列出供参考，不打勾。

### 9.1 OS 系统调用类

- 🔒 **9.1.1 getenv / setenv / unsetenv / environ** — labi_invoke_cc/ld · labi_diag · rt_entry · runtime_env_os · runtime_scheduler_glue · parser_asm_parse_expr_link
- 🔒 **9.1.2 stat / access / realpath** — labi_path_io · labi_ensure_list · labi_freestanding_list · labi_invoke_ld_list · fmt_check
- 🔒 **9.1.3 getcwd / chdir / getpid / getppid** — runtime_process_os_glue · labi_invoke_ld_list
- 🔒 **9.1.4 execve / waitpid / pipe / spawn / system** — runtime_process_os_glue · labi_invoke_ld_list · labi_diag_pure · rt_entry
- 🔒 **9.1.5 clock_gettime / nanosleep / gmtime_r / QPC / Sleep** — runtime_time_os
- 🔒 **9.1.6 getrandom / getentropy / BCryptGenRandom** — runtime_random_fill
- 🔒 **9.1.7 getaddrinfo / WSAStartup / socket / connect / poll / recvmmsg / sendmmsg** — runtime_net_* · runtime_http_glue
- 🔒 **9.1.8 _write / write** — runtime_log_os
- 🔒 **9.1.9 inline asm syscall（Linux x86_64）** — runtime_asm_io_stubs
- 🔒 **9.1.10 opendir / readdir / closedir** — fmt_check
- 🔒 **9.1.11 execinfo / dladdr / DbgHelp / CaptureStackBackTrace** — runtime_backtrace_platform
- 🔒 **9.1.12 sysctl / proc/#if** — target_cpu_pure

### 9.2 第三方库依赖

- 🔒 **9.2.1 mbedtls BIO send/recv** — runtime_tls_mbedtls_bio（需 #include <mbedtls/ssl.h>）
- 🔒 **9.2.2 zlib deflateInit2_ / inflateInit2_** — runtime_compress_zlib_glue（需 #include <zlib.h> + #undef macros）
- 🔒 **9.2.3 ed25519 ref10 实现** — runtime_ed25519_ref10_glue（8 个 .inc 文件宏展开）
- 🔒 **9.2.4 libm math_*_impl** — runtime_math_libm（32 个 libm 函数桥）
- 🔒 **9.2.5 arrow SIMD kernels** — runtime_arrow_simd_glue（需 C target attributes）
- 🔒 **9.2.6 sqlite3** — runtime_sqlite_glue（sqlite3 C API）

### 9.3 宏展开类

- 🔒 **9.3.1 ed25519 ref10 宏重命名** — 8 个 .inc 经宏发射 _impl_c
- 🔒 **9.3.2 zlib macros #undef** — rest #include + #undef + call real
- 🔒 **9.3.3 #if host 字面量** — labi_host_lit · target_cpu_pure · runtime_panic_arm64
- 🔒 **9.3.4 C11 stdatomic / GCC __atomic intrinsics** — runtime_atomic_glue（30 个原子操作）
- 🔒 **9.3.5 SIMD intrinsics** — runtime_arrow_simd_glue（ARM SVE / x86 AVX）

### 9.4 C ABI / fnptr 表达限制

- 🔒 **9.4.1 uintptr_t → fnptr cast + indirect call** — runtime_test_fn_invoke
- 🔒 **9.4.2 void*(*)(void*) C ABI** — runtime_net_workers
- 🔒 **9.4.3 main() char** argv — runtime_asm_build
- 🔒 **9.4.4 pthread_mutex_t / pthread_cond_t / pthread_create** — runtime_sync_os · runtime_channel_glue · runtime_queue_contention · runtime_thread_glue · runtime_sync_lock_diag_tls
- 🔒 **9.4.5 CRITICAL_SECTION / SRWLOCK / CONDITION_VARIABLE / CreateThread / _beginthreadex** — 同上 Windows 侧
- 🔒 **9.4.6 SetThreadAffinityMask / qos_class** — runtime_thread_glue

### 9.5 FILE* / fprintf / fputs / va_list

- 🔒 **9.5.1 driver_preamble_fputs（G.7）** — async_liveness · async_cps_codegen
- 🔒 **9.5.2 xlang_target_cpu_print（FILE/fprintf）** — target_cpu_pure
- 🔒 **9.5.3 reportf / va_list** — diagnostic 深路径
- 🔒 **9.5.4 vsnprintf + write** — bootstrap_nostdlib_stubs

### 9.6 全局/static BSS / 巨型字串数据

- 🔒 **9.6.1 u8[N] 全局/static BSS** — rt_arena_buf · rt_emit_state（Cap-global-bss）
- 🔒 **9.6.2 巨型字串表数据** — rt_preamble（Cap-giant-string）
- 🔒 **9.6.3 static 共享状态** — 各 mega rest 切片

### 9.7 driver_abi 平台层集中点

- 🔒 **9.7.1 FILE/pctx/host/defines/work 槽** — rt_run_asm_backend · rt_run_compiler_parsed · rt_run_x_emit · rt_dispatch_impl · rt_asm_stub
- 🔒 **9.7.2 lib_roots 槽 + Parsed 填表** — rt_dispatch_impl
- 🔒 **9.7.3 GAS 行表 + OutBuf append** — rt_asm_stub
- 🔒 **9.7.4 driver_stdio_* + driver_entry_*_slot** — rt_entry
- 🔒 **9.7.5 usage_write + compiled_body** — rt_run_exec
- 🔒 **9.7.6 driver_run_stack_esc_gate** — rt_stack（pthread）
- 🔒 **9.7.7 driver_run_thread_on_large_stack_pthread** — rt_stack

---

## 阶段 10：终局 — 自举完成（未达）

> **定义**：`xlang_v2 == xlang_v3` / D-03 哈希；冷启动可从上一代 xlang -E 重建；无双权威 pin 糊弄。
> **前置**：bstrict 全绿 + mega 去 pin + pinned gen.c 退役。

- [ ] **10.1 三大 mega 去 pin 完成** ⬜（阶段 7）
- [ ] **10.2 11 个 pinned gen.c 退役完成** ⬜（阶段 8）
- [ ] **10.3 v2 == v3 语义自举验证** ⬜
  ```
  seed_xlang -E compiler/*.x   →  xlang_v1
  xlang_v1   -E compiler/*.x   →  xlang_v2
  xlang_v2   -E compiler/*.x   →  xlang_v3
  assert xlang_v2 == xlang_v3   →  语义自举成立
  ```
- [ ] **10.4 D-03 bit-identical 验证（可选更强）** ⬜
- [ ] **10.5 双端 L4 真冷 + 129 bstrict 全绿（终局）** ⬜
- [ ] **10.6 物理删 seed（冷启动考古归档）** ⬜
- [ ] **10.7 宣布自举完成** ⬜

---

## 附录 A：代码量分布

| 维度 | .x 行数 | .c 行数 | .x 占比 |
|------|---------|---------|---------|
| std/ + core/（库） | 75,007 | 0 | 100% ✅ |
| compiler/src/（产品源） | 176,729 | — | — |
| compiler/ 非 seed .c（pinned gen） | — | 372,826 | — |
| compiler/seeds/ .c（.x 衍生 seed） | — | 209,657 | — |
| **全项目 .x vs 全 .c** | **251,736** | **582,483** | **30.2%** |

## 附录 B：三大 mega rest 规模

| mega | rest LOC | 切片数 | 状态 |
|------|----------|--------|------|
| parser_asm_thin_c | ~21,935 | 21/21 ✅ | 拆分完成 · 去 pin ⬜ |
| runtime | ~7,320 | 24/24 ✅ | 拆分完成 · 去 pin ⬜ |
| runtime_link_abi | ~6,920 | 11/11 ✅ | 拆分完成 · 去 pin ⬜ |

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

## 附录 D：综合迁移进度

```
迁移进度 = (N 模块完成度 × 0.35)  111/111 = 100%  → 35%
        + (std/core 完成度 × 0.20)  100%            → 20%
        + (compiler/src .x 化 × 0.25)  32%          → 8%
        + (mega 拆分 × 0.15)  100% (M1-M3) / 0% (M4) = 50% → 7.5%
        + (Cap 治理 × 0.05)  ~80%                    → 4%
                                                    ≈ 74.5%
```

**综合迁移进度：约 74%**

剩余 26% 集中在：
1. 三大 mega 去 pin（M4）— 阶段 7
2. 11 个 pinned gen.c 退役 — 阶段 8
3. Cap 前排硬叶（untyped self 等）— 阶段 4.2
4. 终局 v2==v3 验证 — 阶段 10

---

## 变更记录

| 日期 | 波次 | 变更 |
|------|------|------|
| 2026-07-29 | wave712 | 创建文档；全面列出 C→.X 迁移全程待办；标记已完成项 |

---

> **使用方式**：每完成一波自举，找到对应待办项，将 `⬜` 改为 `✅` 并标注日期/波次。新增的待办项追加到对应阶段末尾。
