# G-02f L2 试点：产品链 `.x` 编出的 `.o`（G-02f-256 → f-258）

## 1. 目标

今日 G05 热路径几乎全部是：

```text
seeds/*.from_x.c  →  cc -c  →  *.o  →  link shux
```

即便 `.x` 已是 L1 逻辑源，**运行时仍是手写/生成的 seed C**。L2 终局要把至少部分 G05 objs 改成：

```text
src/**/*.x  →  工具链  →  *.o  →  link shux
```

**f-256**：最窄 1:1 路径（sizes）。  
**f-257**：表驱动 + target_cpu pure flags 混合。  
**f-258**：第 3 TU strict_glue thin 混合（weak 对齐 seed）。

## 2. 当前 L2 TUs

| # | 源 | 产物 | 路径 | 步 |
|---|----|------|------|----|
| 1 | `src/lsp/lsp_diag_pipeline_sizes.x` | `sizes_nostub.o` | 1:1 `.x→-E→cc` | f-256 |
| 2 | `src/driver/target_cpu_flags.x` | 并入 `target_cpu.o` | hybrid：flags.o + seed-rest（`-DSHUX_L2_TARGET_CPU_FLAGS_FROM_X`）`cc -r` | f-257 |
| 3 | `src/runtime_driver_strict_glue_thin.x` | 并入 `strict_glue_stubs.o` | hybrid：thin.o（**weak**）+ seed-rest（`-DSHUX_L2_STRICT_GLUE_THIN_FROM_X`）`cc -r` | f-258 |
| 4 | `src/lsp/lsp_diag_pipeline_ctx.x` | 并入 `lsp_diag_pipeline_ctx.o` | hybrid：thin.o（**weak**）+ seed-rest（`-DSHUX_L2_LSP_CTX_THIN_FROM_X`，C 尾 `_impl`）`cc -r` | f-331 |
| 5 | `src/x_seed_bridge.x` | 并入 `x_seed_bridge.o` | hybrid：thin.o（**weak** heap/io 桩）+ seed-rest（`-DSHUX_L2_X_SEED_BRIDGE_THIN_FROM_X`，C 尾）`cc -r` | f-332 |
| 6 | `src/asm/parser_asm_parse_expr_link.x` | 并入 `parser_asm_parse_expr_link.o` | hybrid：thin.o（**weak** `debug_enabled`）+ seed-rest（`-DSHUX_L2_PEL_THIN_FROM_X` + SKIP_X）`cc -r` | f-333 |
| 7 | `src/runtime_io_abi.x` | 并入 `runtime_io_abi.o` | hybrid：thin.o（**weak** fs/path/file_view 门闩）+ seed-rest（`-DSHUX_L2_RIO_THIN_FROM_X`，C 尾 `_impl` / `flags_impl`）`cc -r` | f-334 |
| 8 | `src/diag_thin.x` | 并入 `diag.o` | hybrid：thin.o（**weak** **41** 门闩：…+ snap pure + push/restore snap orch）+ seed-rest（`-DSHUX_L2_DIAG_THIN_FROM_X`，`apply_impl`）`cc -r` | f-335～347 |
| 9 | `src/runtime_driver_diagnostic_thin.x` | 并入 `runtime_driver_diagnostic.o` | hybrid：thin.o（**weak** **~71** 门闩：覆盖几乎全部 rdd.x 导出）+ seed-rest（`-DSHUX_L2_RDD_THIN_FROM_X`）`cc -r` | f-339～341 |
| 10 | `src/runtime_driver_abi_thin.x` | 并入 `runtime_driver_abi.o` | hybrid：thin.o（**weak** **31** flag pure + timing + ascii/typeck_skip/sanitize_get）+ seed-rest（`-DSHUX_L2_RDABI_THIN_FROM_X`）`cc -r` | f-343～345 |
| 11 | `src/asm/simd_enc_thin.x` | 并入 `simd_enc.o` | hybrid：thin.o（**weak** **3** pure：`arm64_ins_v1` / `rbp_lea_off_128half` / `rbp_disp32`）+ seed-rest（`-DSHUX_L2_SIMD_ENC_THIN_FROM_X`）`cc -r` | f-348 |
| 12 | `src/asm/simd_loop_thin.x` | 并入 `simd_loop.o` | hybrid：thin.o（**weak** **5** pure：disp / pick_lanes / array_i32 size）+ seed-rest（`-DSHUX_L2_SIMD_LOOP_THIN_FROM_X`）`cc -r` | f-349 |
| 13 | `src/driver/fmt_check_cmd_thin.x` | 并入 `fmt_check_cmd_driver.o` | hybrid：thin.o（**weak** **7** pure：quiet/skip/fallback + path_abs/finalize/lit 门闩）+ seed-rest（`-DSHUX_L2_FMT_CHECK_THIN_FROM_X` + `SHUX_USE_X_PIPELINE`）`cc -r` | f-350～351 |
| 14 | `src/asm/backend_enc_dispatch_thin.x` | 并入 `backend_enc_dispatch.o` | hybrid：thin.o（**weak** **109**：arm64 encode 5 + ta 壳 104）+ seed-rest（`-DSHUX_L2_ENC_DISPATCH_THIN_FROM_X`）`cc -r` | f-352～361 |
| 15 | `src/asm/backend_arch_emit_dispatch_thin.x` | 并入 `backend_arch_emit_dispatch.o` | hybrid：thin.o（**weak** **47** ta 壳）+ seed-rest（`-DSHUX_L2_ARCH_EMIT_THIN_FROM_X`）`cc -r` | f-362 |
| 16 | `src/asm/backend_try_inline_dispatch_thin.x` | 并入 `backend_try_inline_dispatch.o` | hybrid：thin.o（**weak** **14**：+ `try_expr_const`→seed `_impl`）+ seed-rest（`-DSHUX_L2_TRY_INLINE_THIN_FROM_X`）`cc -r` | f-363～369 |
| 17 | `src/asm/backend_call_dispatch_thin.x` | 并入 `backend_call_dispatch.o` | hybrid：thin.o（**weak** **11**：+ path/binding equal + f32 get→impl）+ seed-rest（`-DSHUX_L2_CALL_DISPATCH_THIN_FROM_X`）`cc -r` | f-364～369 |

- **默认路径**：仍整 seed `cc`（冷启动/回滚安全）
- **优先路径**：`SHUX_G05_PREFER_X_O=1`（显式 opt-in）

### 2.1 target_cpu hybrid 细节

| 层 | 内容 |
|----|------|
| **flags.x** | `driver_set/get_pending_target_cpu_features`、`tcp_tolower`、`tcp_eq5`、`tcp_eq6` |
| **seed-rest** | resolve / simd / print / detect_* / `tcp_eq_at` / parse_named / flags_has_token… |
| **seed 宏** | `SHUX_L2_TARGET_CPU_FLAGS_FROM_X` 省略 flags 符号，改为 `extern` |
| **失败** | 回退整文件 `seeds/target_cpu_pure.from_x.c` |

> 全量 `target_cpu_pure.x` 的 `-E` 仍会挂起/超时，故 **禁止** 整 TU 优先；仅切 pure flags 子集。

## 3. 实现路径（当前机可绿）

asm 后端对纯常量 TU 仍可能 `asm_codegen_elf_o` 失败。**过渡路径**（仍算 L2 语义主权）：

```text
shux -backend c -E foo.x  →  tmp.c  →  cc -c  →  foo.o
```

- **输入**：仓库内 `.x`（非 committed seed 作为逻辑源）
- **中间**：临时 C（不入库）
- **失败**：回退 seed `cc`（默认与今日相同）

## 4. 开关与脚本

| 环境变量 | 默认 | 行为 |
|----------|------|------|
| `SHUX_G05_PREFER_X_O` | 未设/0 | 仅 seed（与 f-255 前一致） |
| `SHUX_G05_PREFER_X_O=1` | — | 表内 TU 优先 `.x`；hybrid 失败则整 seed |

入口：`compiler/scripts/g05_ensure_relink_prereqs.sh`  
助手：`g05_try_x_to_o` · `g05_ensure_l2_or_seed`（1:1 表项）

## 5. 验收

### 5.1 默认（必须双绿）

```bash
cd compiler && G05_SYNC_ASM=1 sh scripts/g05_prepare_and_relink.sh
# + STRICT + noinc + rv42 + lang-unsafe（macOS + Ubuntu）
```

### 5.2 优先路径（本机 smoke）

```bash
cd compiler
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o src/driver/target_cpu.o \
      src/runtime_driver_strict_glue_stubs.o src/lsp/lsp_diag_pipeline_ctx.o \
      src/x_seed_bridge.o src/asm/parser_asm_parse_expr_link.o \
      src/runtime_io_abi.o src/diag.o src/runtime_driver_diagnostic.o \
      src/runtime_driver_abi.o
SHUX_G05_PREFER_X_O=1 sh scripts/g05_ensure_relink_prereqs.sh
# 日志应含：
#   sizes_nostub.o ← ...sizes.x (... L2 prefer .x: sizes_nostub)
#   target_cpu.o ← ...target_cpu_flags.x + seed-rest (... hybrid flags)
#   strict_glue_stubs.o ← ...strict_glue_thin.x + seed-rest (... hybrid thin weak)
#   lsp_diag_pipeline_ctx.o ← ...ctx.x + seed-rest (... L2 hybrid ctx thin)
#   x_seed_bridge.o ← ...x_seed_bridge.x + seed-rest (... L2 hybrid x_seed_bridge thin)
#   parser_asm_parse_expr_link.o ← ...parse_expr_link.x + seed-rest (... L2 hybrid parse_expr_link thin)
#   runtime_io_abi.o ← ...runtime_io_abi.x + seed-rest (... L2 hybrid runtime_io_abi thin)
#   diag.o ← ...diag_thin.x + seed-rest (... L2 hybrid diag thin)
#   runtime_driver_diagnostic.o ← ...diagnostic_thin.x + seed-rest (... L2 hybrid diagnostic thin)
#   runtime_driver_abi.o ← ...abi_thin.x + seed-rest (... L2 hybrid driver_abi thin)
nm src/lsp/lsp_diag_pipeline_sizes_nostub.o | grep sizeof
nm src/driver/target_cpu.o | grep 'T _tcp_tolower\|T _shu_target_cpu_detect'
nm -m src/runtime_driver_strict_glue_stubs.o | grep 'typeck_i32_ptr_store'   # weak external
G05_SYNC_ASM=1 SHUX_G05_PREFER_X_O=1 sh scripts/g05_prepare_and_relink.sh
./shux -backend c build -o /tmp/rv42 /tmp/rv42.x && /tmp/rv42  # exit 42
```

macOS arm64 默认 asm 可能 `code_len=0`（已知限制）；C 后端 smoke 即可。

### 2.2 strict_glue thin 注意

| 项 | 说明 |
|----|------|
| **weak** | `G05_X_O_WEAK=1` 注入 `__attribute__((weak))`；否则与 `bootstrap_seed_pipeline_filtered.o` 强符号 duplicate |
| **不含 append** | `append_text_to_codegen_buf` 仍 seed（`.x` 原版依赖不存在的 `_impl`） |
| **槽指针 🔒** | `typeck_*_slot*` 仍 seed C |

## 6. 扩展顺序（后续 f-步）

1. ~~**L2-2 扩表**~~ ✅ f-257  
2. ~~**L2-4 第 3 TU**~~ ✅ f-258 strict_glue_thin  
3. ~~**默认 prefer 评估**~~ ✅ f-259：**保持 opt-in**（见 §6.1）  
4. ~~**L2 第 4 TU**~~ ✅ f-331 `lsp_diag_pipeline_ctx` hybrid thin  
5. ~~**L2 第 5 TU**~~ ✅ f-332 `x_seed_bridge` hybrid thin（`-E` 前置 `sys/types.h`）  
6. ~~**L2 第 6 TU**~~ ✅ f-333 `parse_expr_link` hybrid thin（debug_enabled 去字符串字面量）  
7. ~~**L2 第 7 TU**~~ ✅ f-334 `runtime_io_abi` hybrid thin（POSIX 头 + strip libc redecls；flags→flags_impl）  
8. ~~**L2 第 8 TU**~~ ✅ f-335～342 `diag_thin` hybrid（**32** 门闩）  
9. ~~**L2 第 9 TU**~~ ✅ f-339～341 `rdd_thin` hybrid（**~71** 门闩，近满覆盖）  
10. ~~**L2 第 10 TU**~~ ✅ f-343 `runtime_driver_abi_thin` hybrid（**23** 门闩）  
11. ~~**rdabi timing 全套**~~ ✅ f-344（**28** 门闩：+ index_ok / timing_enabled/begin/end/flush）  
12. ~~**rdabi pure 扩**~~ ✅ f-345（**31**：+ ascii_toupper / typeck_skip_large_entry / sanitize_address_get）  
13. ~~**diag snap pure**~~ ✅ f-346（**40**：store/load ptr/usize/i32 + le）  
14. ~~**diag push/restore snap orch**~~ ✅ f-347（**41**：`push_snap_save` + `apply_impl`；restore 全 thin）  
15. ~~**L2 第 11 TU**~~ ✅ f-348 `simd_enc_thin` hybrid（**3** pure 编码）  
16. ~~**L2 第 12 TU**~~ ✅ f-349 `simd_loop_thin` hybrid（**5** pure glue）  
17. ~~**L2 第 13 TU**~~ ✅ f-350 `fmt_check_cmd_thin` hybrid（**3** pure）  
18. ~~**fmt thin 扩**~~ ✅ f-351（**7**：+ path_is_absolute / finalize→lint_impl / collect lit 门闩）  
19. ~~**L2 第 14 TU**~~ ✅ f-352 `backend_enc_dispatch_thin` hybrid（**3** arm64 SP encode）  
20. ~~**enc_dispatch +load/store**~~ ✅ f-353（**5**：+ LDUR/STUR w0@x29）  
21. ~~**enc_dispatch +ta shells**~~ ✅ f-354（**13**：+ push/pop/epilogue/add/sub/imul）  
22. ~~**enc_dispatch +logic/test ta**~~ ✅ f-355（**23**：+ mov/not/and/or/xor/cltd/neg/test）  
23. ~~**enc_dispatch +shift/cmp/idiv**~~ ✅ f-356（**36**：+ shl/shr/sar / cmp / idiv|div）  
24. ~~**enc_dispatch +imm/lea/label**~~ ✅ f-357（**52**：+ prologue/ret_imm/mov_imm/cmp_setcc/store|load_rbp/lea/scale/load_zext/add_imm/label）  
25. ~~**enc_dispatch +rem/jcc/load64**~~ ✅ f-358（**75**：+ rem_mod|u / load32|i32 / load64 / store ind|offset / mov_rbx / jcc* / jmp / mov_arg / call_stack* / store_x0|x_reg / load_qword* / store_rdx）  
26. ~~**enc_dispatch +index/call/jle**~~ ✅ f-359（**92**：+ index secondary×8 / call / x86 rdx·arg / scale / lane_rax / jle|jl）  
27. ~~**enc_dispatch +index imm/x29/rbx**~~ ✅ f-360（**102**：+ x29 pos / index imm×6 / load_rbp_to_rbx / lane_rbx）  
28. ~~**enc_dispatch +f32/xmm/store_eax**~~ ✅ f-361（**109**：+ addss/cvt*/mov xmm / store_eax；`*_arch` seed 体全 omit）  
29. ~~**L2 第 15 TU**~~ ✅ f-362 `backend_arch_emit_dispatch_thin` hybrid（**47** ta 壳全量）  
30. ~~**L2 第 16 TU**~~ ✅ f-363 `backend_try_inline_dispatch_thin` hybrid（**6** pure）  
31. ~~**L2 第 17 TU**~~ ✅ f-364 `backend_call_dispatch_thin` hybrid（**3** pure）  
32. ~~**try_inline/call 扩 pure**~~ ✅ f-365（try **10** / call **4**）  
33. ~~**try_inline/call 再扩**~~ ✅ f-366（try **12** / call **5**）  
34. ~~**call pure +f32/prefix**~~ ✅ f-367（call **7**：+`is_f32` / `c_prefix_redundant`；单 unsafe 扁平 early-exit）  
35. ~~**try/call 再扩**~~ ✅ f-368（try **13** +`local_var_indirect`；call **8** +path 段数 thin→impl）  
36. ~~**impl+forward 扩**~~ ✅ f-369（try **14** +`try_expr_const`；call **11** +import equal×2 / f32 get；6 参 local_slot 仍 seed）  
37. ~~**impl+forward 再扩**~~ ✅ f-370（try **17** +func_index/named_layout/type_ref；call **15** +overload/std_c_wrapper/fill_c_prefix/prefix_is_fmt；嵌套 pure 改 `_impl`）  
38. ~~**impl+forward 再扩**~~ ✅ f-371（try **20** +expr_is_func_param/struct_lit field_index/array_lit lane；call **18** +import_segment/binding_call_sym/std_string_shux redirect）  
39. ~~**impl+forward 再扩**~~ ✅ f-372（try **23** +param0_index/const_struct_can_inline/scalar_binop；call **21** +encoding_redirect/type_kind_suffix/string_lit_ptr_rax；module fold 仍 seed-only 防 -E mangle）  
40. ~~**impl+forward 再扩**~~ ✅ f-373（try **26** +param_struct_lit/vector_binop/default_alloc；call **24** +sysv_n_stack/dep_export/enc_call_redirected）  
41. ~~**impl+forward 再扩**~~ ✅ f-374（try **29** +dep_field_offset/const_struct_lit/default_alloc_emit；call **27** +heap_redirect/f32_xmm_env/build_func_export）  
42. ~~**impl+forward 再扩**~~ ✅ f-375（try **32** +inner_call_arg/wpo_scalar_binop/x_plus_k；call **30** +jmp_skip_string_lea/spill_struct16/resolve_whole_import）  
43. ~~**impl+forward 再扩**~~ ✅ f-376（try **35** +param0_single_field/wpo_vector_lane/mono_symbol；call **33** +emit_call_elf/method_call/call_args_text）  
44. ~~**impl+forward 再扩**~~ ✅ f-377（try **38** +var_field_offset/param0_field_sum/mono_vector_lane；call **36** +call_args_elf/sysv_f32_args/call_with_cleanup）  
45. ~~**impl+forward 再扩**~~ ✅ f-378（try **41** +field_init_param/struct_lit_to_slot×2；call **39** +one_call_arg/build_call_export/fmt_string_import；9 参 pure forward OK）  
46. ~~**try int32 thin 收口**~~ ✅ f-379（try **43**：+`lookup_callee`/`var_field_sum`；call 仍 **39**，void 路径 `-E` 丢体故 seed-only）  
47. ~~**call void 路径 hybrid**~~ ✅ f-380（call **43**：void 公开符号 thin **i32 壳** + seed **int32 `_impl`**；`set_f32`/`import_prefix`/`string_lit_into`/`sysv_arg_slot`；try/call 均 **43**）  
48. ~~**seed callee 上提**~~ ✅ f-381（try **47**：+`fold_module`/`array_lit_elem|reserve`/`local_var_slot` 改 call `_impl` 消同名 extern clash；call **44** +`f32_get_body`；6 参 local_slot 仍 seed callee）  
49. **L2**：再扩 mega / 默认 PREFER 评估  
50. **asm 直出 .o**：修 CG002 后去掉 `-E` 中间步  
51. 冷启动可稳定 `-E` 后再议默认 `PREFER_X_O`

### 6.1 f-259 默认 `SHUX_G05_PREFER_X_O` 评估（结论：否）

| 问题 | 现状 | 结论 |
|------|------|------|
| 冷启动鸡生蛋 | ensure 用 `./shux` 做 `-E`；冷机可能仅有 seed `bootstrap_shuxc`，`-E` 能力/稳定性因平台而异 | **不能默认开** |
| Linux `-backend c -E` | 对 sizes 等会 SIGSEGV；f-258b 已改 prefer plain `-E` | 已缓解但未证明全 TU 稳 |
| ensure 耗时 | 每热路径多一次 shux 进程 + cc | 日常默认应保持 seed 快路径 |
| 回滚 | 未设 env = 全 seed | 保持 |

**何时可再评估默认开**：冷启动文档写明「先 seed 链出 shux → 再 PREFER」两阶段；且 Ubuntu/macOS 全量 L2 TU 连续绿 ≥1 周。

### 6.2 f-259 附带：`runtime_net_udp_batch` include 债

`seeds/runtime_asm_io_stubs.from_x.c` 在 Linux 下 `#include "runtime_net_udp_batch.c"` → 源已迁 `runtime_net_udp_batch.from_x.c`，导致用户 `build` BLD001。已改为同目录 `.from_x.c`。

## 7. 非目标（本步不做）

- 不默认打开 `PREFER_X_O`（避免冷启动鸡生蛋）
- 不删 seed 文件
- 不一次改多个 mega
- 不要求 gen1/gen2 黄金哈希本步变化
- 不整文件 `-E` `target_cpu_pure.x`（仍 hang）

## 8. 回滚

```bash
unset SHUX_G05_PREFER_X_O
rm -f src/lsp/lsp_diag_pipeline_sizes_nostub.o src/driver/target_cpu.o \
      src/runtime_driver_strict_glue_stubs.o
sh scripts/g05_ensure_relink_prereqs.sh   # 仅 seed
```
