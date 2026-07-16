#!/usr/bin/env bash
# prove_module_selfhost.sh — 单模块自举验证（.o 符号差分）
#
# 自举方法 P0 工具：验证某模块的 .x → .o 与 seed gen.c → .o 符号一致
# 这是比 C 源码 diff 更准确的差分验证（符号层面 = 功能层面等价）
#
# 用法：bash tests/prove_module_selfhost.sh [模块名...]
#   不传参数 = 验证所有已配置模块
#   传模块名 = 只验证指定模块（如：fmt check test build run diagnostic）
#
# 输出：每个模块的 shux-E / cc-c / nm-diff 状态
#
# 模式（第 5 字段，可选）：
#   （空）  IDENTICAL — 已定义符号完全一致 → 可退役 seed（计入 N）
#   core:a,b,c  CORE — x 定义符号 ⊆ seed，允许 x 独有辅助符号 a,b,c
#               （hybrid thin/C-tail seed 的中间门禁；不计 N 退役）

set -u
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/compiler" || exit 1

# 模块配置（模块名|.x路径|seed路径|符号重命名|模式）
# 符号重命名映射格式：old1:new1,old2:new2,...
# 模式：空 | core:x_only_sym1,x_only_sym2
MODULES=(
  "fmt|src/driver/fmt.x|driver_fmt_gen.c|cmd_fmt:driver_cmd_fmt|"
  "check|src/driver/check.x|driver_check_gen.c|cmd_check:driver_cmd_check|"
  "test|src/driver/test.x|driver_test_gen.c|cmd_test:driver_cmd_test|"
  "build|src/driver/build.x|driver_build_gen.c|cmd_build:build_cmd_build|"
  "run|src/driver/run.x|driver_run_gen.c|cmd_run:driver_cmd_run,run_eq_word:driver_run_eq_word|"
  "compile|src/driver/compile.x|driver_compile_gen.c|compile_dispatch_asm_backend:driver_compile_dispatch_asm_backend,compile_dispatch_emit_c_path:driver_compile_dispatch_emit_c_path,eq_minus_o:driver_eq_minus_o,eq_minus_L:driver_eq_minus_L,eq_minus_backend:driver_eq_minus_backend,eq_minus_target:driver_eq_minus_target,eq_minus_target_cpu:driver_eq_minus_target_cpu,eq_print_target_cpu:driver_eq_print_target_cpu,eq_minus_O:driver_eq_minus_O,eq_flto:driver_eq_flto,eq_minus_freestanding:driver_eq_minus_freestanding,eq_legacy_f32_abi:driver_eq_legacy_f32_abi,eq_fsanitize_address:driver_eq_fsanitize_address,eq_asm_word:driver_eq_asm_word,eq_c_word:driver_eq_c_word,path_ends_x:driver_path_ends_x,target_has_arm:driver_target_has_arm,run_compiler_full_x_post_parse:driver_run_compiler_full_x_post_parse,run_compiler_full_x:driver_run_compiler_full_x|"
  "emit|src/driver/emit.x|driver_emit_gen.c|emit_copy_lib_roots_to_ctx:driver_emit_copy_lib_roots_to_ctx,run_x_emit_x:driver_run_x_emit_x,dispatch_x_emit_to_c:driver_dispatch_x_emit_to_c,emit_state_key:driver_emit_state_key,pipeline_dep_ctx_fill_for_emit:driver_pipeline_dep_ctx_fill_for_emit|"
  "lsp_io_std_heap|src/lsp/lsp_io_std_heap.x|lsp_io_std_heap_gen.c|std_heap_alloc:lsp_io_std_heap_std_heap_alloc,std_heap_alloc_zeroed:lsp_io_std_heap_std_heap_alloc_zeroed,std_heap_free:lsp_io_std_heap_std_heap_free|"
  # token：enum+Token+token_is_eof；产品链仍用 include/token.h（C 头），本条锁 nm 面 / 扩 N
  "token|src/lexer/token.x|token_gen.c||"
  # lsp_diag_pipeline_sizes：三枚 sizeof 门闩；产品 sizes_nostub PREFER_X_O；本条锁 nm / 扩 N
  "lsp_diag_pipeline_sizes|src/lsp/lsp_diag_pipeline_sizes.x|seeds/lsp_diag_pipeline_sizes.from_x.c||"
  # labi_path_pure R2 full：.x 吃满 7 公共门闩 + count；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：Windows #if sep 在 mega 冷路径
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_path_pure.from_x.c 全 C 体
  "labi_path_pure|src/runtime/labi_path_pure.x|seeds/labi_path_pure_surface.from_x.c||"
  # labi_gates R2 full：.x 吃满 6 thin gates + count（*u8 透传 _impl）；
  # mega rest 在 FROM_X 下业务 H=0；Cap residual：*_impl 主体在 mega rest
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_gates.from_x.c 全 C 体
  "labi_gates|src/runtime/labi_gates.x|seeds/labi_gates_surface.from_x.c||"
  # labi_invoke_cc_list R2 full：.x 吃满 harden/skip-native/icc rel 纯表；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：getenv 🔒 + mega invoke_cc_impl
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_invoke_cc_list.from_x.c 全 C 体
  "labi_invoke_cc_list|src/runtime/labi_invoke_cc_list.x|seeds/labi_invoke_cc_list_surface.from_x.c||"
  # labi_invoke_ld_list R2 full：.x 吃满 brew/compress/tail/driver/entry 纯表；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：spawn/ld/cc IO 在 mega invoke_ld
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_invoke_ld_list.from_x.c 全 C 体
  "labi_invoke_ld_list|src/runtime/labi_invoke_ld_list.x|seeds/labi_invoke_ld_list_surface.from_x.c||"
  # labi_freestanding_list R2 full：.x 吃满 env/io_sym/panic/ensure catalog 纯表；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：ensure/cc/spawn IO 在 mega freestanding
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_freestanding_list.from_x.c 全 C 体
  "labi_freestanding_list|src/runtime/labi_freestanding_list.x|seeds/labi_freestanding_list_surface.from_x.c||"
  # labi_std_list R2 full：.x 吃满 58 步 plan + default_std_rel 纯表；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：IO/ensure/push 在 mega append_std_objs
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_std_list.from_x.c 全 C 体
  "labi_std_list|src/runtime/labi_std_list.x|seeds/labi_std_list_surface.from_x.c||"
  # labi_ondemand_list R2 full：.x 吃满 simple/kv/arrow/time/queue + rel_* 纯表；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：nm/push/ensure 在 mega append_on_demand
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_ondemand_list.from_x.c 全 C 体
  "labi_ondemand_list|src/runtime/labi_ondemand_list.x|seeds/labi_ondemand_list_surface.from_x.c||"
  # labi_ensure_list R2 full：.x 吃满 ensure catalog 纯表（26 条目 stem/out/seed/flags/step_at）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：spawn/cc IO 在 mega ensure_from_catalog
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_ensure_list.from_x.c 全 C 体
  "labi_ensure_list|src/runtime/labi_ensure_list.x|seeds/labi_ensure_list_surface.from_x.c||"
  # labi_path_io R2 full：.x 吃满 3 公共门闩 + count；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：stat/realpath _impl 在 mega rest
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_path_io.from_x.c 全 C 体
  "labi_path_io|src/runtime/labi_path_io.x|seeds/labi_path_io_surface.from_x.c||"
  # labi_host_lit R2 full：.x 吃满 2 公共门闩 + count；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：#if host _impl 在 mega rest
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_host_lit.from_x.c 全 C 体
  "labi_host_lit|src/runtime/labi_host_lit.x|seeds/labi_host_lit_surface.from_x.c||"
  # labi_diag_pure R2 full：.x 吃满 code_for_kind + 7 report 消息体 + count；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：ld_debug_argv char** 在 mega rest
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/labi_diag_pure.from_x.c 全 C 体
  "labi_diag_pure|src/runtime/labi_diag_pure.x|seeds/labi_diag_pure_surface.from_x.c||"
  # diagnostic R2 thin + Cap residual pure 深迁：thin.x 公共门闩 + 固定措辞/pipe orch + 拼装 pure + getenv
  # + report_prefixed/pipe_note + debug_log/parser_diag_* + typeck_block/fn/var debug + scratch BSS
  # （return/assign/call/struct/asm note + fill/build/note）；rest FROM_X 无 pure-dup _impl；
  # Cap residual snprintf/va_list 在 full seed rest
  # prove 锁 thin surface IDENTICAL；冷/无 PREFER 仍可走 seeds/runtime_driver_diagnostic.from_x.c 全 C 体
  "diagnostic|src/runtime_driver_diagnostic_thin.x|seeds/runtime_driver_diagnostic_thin_surface.from_x.c||"
  # driver_abi R2 thin + pure 深迁：thin.x 门闩 + pure 真体（scan/has/argv/target_os/fail/smoke/peek/
  # entry_i32/large_stack orch + getenv 门闩 + 数值 env stack_limit_want/parse_u32/phase_timing_enabled）；
  # rest FROM_X 无 pure-dup _impl；Cap residual：uname/setrlimit/pthread/path-read/BSS/format/debug_pipe
  # prove 锁 thin surface IDENTICAL；冷/无 PREFER 仍可走 seeds/runtime_driver_abi.from_x.c 全 C 体
  "driver_abi|src/runtime_driver_abi_thin.x|seeds/runtime_driver_abi_thin_surface.from_x.c||"
  # runtime_io_abi R2 full：.x 吃满 19 公共门闩 + 5 _impl 真迁（read/malloc/memcpy）；
  # rest 在 SHUX_L2_RIO_THIN_FROM_X+FROM_X 下无 thin/impl 公共体；Cap residual：4 平台 _impl（mmap/fstat/O_*）
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/runtime_io_abi.from_x.c 全 C 体
  "runtime_io_abi|src/runtime_io_abi.x|seeds/runtime_io_abi_surface.from_x.c||"
  # fmt_check R2 thin + Cap residual pure 深迁（含 append_repo + missing_diag pure）：thin.x 吃满 lit/entry + pure 真体
  # （path_should_ignore / .x 后缀 / lint / file_list_push / process_child /
  #  collect_paths / default_dirs / check_one_file 门闩 / try_append 早退 / parse_ignore 前缀 /
  #  invoke_compile·dep_clear / set_current_file / print_collected / cwd_fallback / try_walk /
  #  path_resolve_abs / append_repo_lib_roots / missing_diag）；
  # rest FROM_X 无 pure-dup _impl；Cap residual：walk/stat/argv/大 BSS/one_file_body
  # prove 锁 thin surface IDENTICAL；冷/无 PREFER 仍可走 seeds/fmt_check_cmd.from_x.c 全 C 体
  "fmt_check|src/driver/fmt_check_cmd_thin.x|seeds/fmt_check_cmd_thin_surface.from_x.c||"
  # simd_loop R2 full：.x 吃满 peel/parse/emit 公共业务；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/simd_loop.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "simd_loop|src/asm/simd_loop.x|seeds/simd_loop_surface.from_x.c||"
  # simd_enc R2 full：.x 吃满 pure/insn/try_hw 公共业务（74 公共面 + anchor）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/simd_enc.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "simd_enc|src/asm/simd_enc.x|seeds/simd_enc_surface.from_x.c||"
  # backend_enc_dispatch R2 full：.x 吃满 enc/ta 公共业务；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/backend_enc_dispatch.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "backend_enc_dispatch|src/asm/backend_enc_dispatch.x|seeds/backend_enc_dispatch_surface.from_x.c||"
  # backend_arch_emit_dispatch R2 full：.x 吃满 47 ta 分派壳公共业务；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/backend_arch_emit_dispatch.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "backend_arch_emit_dispatch|src/asm/backend_arch_emit_dispatch.x|seeds/backend_arch_emit_dispatch_surface.from_x.c||"
  # backend_try_inline_dispatch R2 full：.x 吃满 try_inline/glue 公共业务；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/backend_try_inline_dispatch.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "backend_try_inline_dispatch|src/asm/backend_try_inline_dispatch.x|seeds/backend_try_inline_dispatch_surface.from_x.c||"
  # backend_call_dispatch R2 full：.x 吃满 CALL/emit/import 公共业务；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 slice_marker）；冷/无 PREFER 仍可走 seeds/backend_call_dispatch.from_x.c 全 C 体
  # prove 锁 full surface IDENTICAL；L2 thin seed 仅作 g05 full.x 失败回退
  "backend_call_dispatch|src/asm/backend_call_dispatch.x|seeds/backend_call_dispatch_surface.from_x.c||"
  # rt_dispatch R2 full：.x 吃满 asm/emit 薄门闩 + run_compiler_full + sibling；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：sibling spawn 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_dispatch_thin.from_x.c 全 C 体
  "rt_dispatch|src/runtime/rt_dispatch_thin.x|seeds/rt_dispatch_thin_surface.from_x.c||"
  # rt_dispatch_impl R2 full：.x 吃满 asm/emit/post_parse/full_x/x_emit_from_state 5 公共；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：lib_roots 槽 + Parsed 填表在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_dispatch_impl.from_x.c 全 C 体
  "rt_dispatch_impl|src/runtime/rt_dispatch_impl.x|seeds/rt_dispatch_impl_surface.from_x.c||"
  # rt_asm_stub R2 full：.x 吃满 want_exe + asm_codegen_ast（GAS main→42 循环）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：GAS 行表 + OutBuf append 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_asm_stub.from_x.c 全 C 体
  "rt_asm_stub|src/runtime/rt_asm_stub.x|seeds/rt_asm_stub_surface.from_x.c||"
  # rt_fmt_one L2 thin 公共面：与产品 PREFER_X_O 同源（thin.x + hybrid rest seed）；prove 锁 thin 面 IDENTICAL
  # 产品 hybrid rest 仍见 seeds/rt_fmt_one.from_x.c（read/format/write body）；入 runtime_driver_no_c.o
  # rt_fmt_one R2 full：.x 吃满 driver_fmt_one_file；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL（driver_fmt_one_file + path helpers）；冷/无 PREFER 仍可走 seeds/rt_fmt_one.from_x.c 全 C 体
  "rt_fmt_one|src/runtime/rt_fmt_one.x|seeds/rt_fmt_one_surface.from_x.c||"
  # rt_pipeline_elf_diag R2 full：.x 吃满 runtime_pipeline_elf_ctx_diag_note（字节偏移读表 + diag_report_with_code）；
  # 产品 rest 在 FROM_X 下业务符号 H=0（仅 marker）；prove 锁 full surface IDENTICAL
  # 冷/无 PREFER 仍可走 seeds/rt_pipeline_elf_diag.from_x.c 全 C 体
  "rt_pipeline_elf_diag|src/runtime/rt_pipeline_elf_diag.x|seeds/rt_pipeline_elf_diag_surface.from_x.c||"
  # rt_run_x_emit R2 full：.x 吃满 driver_run_x_emit_c（step 拆分 + work 槽）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual 在 driver_abi（OutBuf/stdout/work 槽）
  # 冷/无 PREFER 仍可走 seeds/rt_run_x_emit.from_x.c 全 C 体
  "rt_run_x_emit|src/runtime/rt_run_x_emit.x|seeds/rt_run_x_emit_surface.from_x.c||"
  # rt_parse_diag R2 full：.x 吃满 precise parse failure P001；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL（1 公共符号）；冷/无 PREFER 仍可走 seeds/rt_parse_diag.from_x.c 全 C 体
  "rt_parse_diag|src/runtime/rt_parse_diag.x|seeds/rt_parse_diag_surface.from_x.c||"
  # rt_diag_errno R2 full：.x 吃满 code_for_kind + errno{,_path,_path_pair} + cli_usage_note；产品 rest 在 FROM_X 下业务 H=0
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_diag_errno.from_x.c 全 C 体
  "rt_diag_errno|src/runtime/rt_diag_errno.x|seeds/rt_diag_errno_surface.from_x.c||"
  # rt_fs_open R2 full：.x 吃满 path_copy + open_read + open_write；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL（3 公共符号）；冷/无 PREFER 仍可走 seeds/rt_fs_open.from_x.c 全 C 体
  "rt_fs_open|src/runtime/rt_fs_open.x|seeds/rt_fs_open_surface.from_x.c||"
  # rt_arena_buf R2 full：.x 吃满 arena_buf + module_buf；产品 rest 在 FROM_X 下业务 H=0（marker+BSS）
  # Cap-global-bss residual：槽 API 在 driver_abi；prove 锁 full surface IDENTICAL
  # 冷/无 PREFER 仍可走 seeds/rt_arena_buf.from_x.c 全 C 体
  "rt_arena_buf|src/runtime/rt_arena_buf.x|seeds/rt_arena_buf_surface.from_x.c||"
  # rt_preamble R2 full：.x 吃满 write_io_net + write_fs_path_map_error（skip+fputs）；
  # 产品 rest 在 FROM_X 下业务 H=0（marker+巨型字串表数据）；Cap-giant-string residual 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_preamble.from_x.c 全 C 体
  "rt_preamble|src/runtime/rt_preamble.x|seeds/rt_preamble_surface.from_x.c||"
  # rt_stack R2 full：.x 吃满 thread_fn + large_stack；产品 rest 在 FROM_X 下业务符号 H=0（仅 marker）
  # Cap-fn-ptr residual：driver_run_stack_esc_gate_on_large_stack 在 driver_abi（平台层）
  # prove 锁 full surface IDENTICAL（2 公共符号）；冷/无 PREFER 仍可走 seeds/rt_stack.from_x.c 全 C 体
  "rt_stack|src/runtime/rt_stack.x|seeds/rt_stack_surface.from_x.c||"
  # rt_lib_root R2 full：.x 吃满 ptr_usable + default + roots_from_key；产品 rest 在 FROM_X 下业务符号 H=0（仅 marker）
  # prove 锁 full surface IDENTICAL（3 公共符号）；冷/无 PREFER 仍可走 seeds/rt_lib_root.from_x.c 全 C 体
  "rt_lib_root|src/runtime/rt_lib_root.x|seeds/rt_lib_root_surface.from_x.c||"
  # rt_emit_flags R2 full：.x 吃满 has_emit + set_use_lto + set_print_target_cpu；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL（3 公共符号）；冷/无 PREFER 仍可走 seeds/rt_emit_flags.from_x.c 全 C 体
  "rt_emit_flags|src/runtime/rt_emit_flags.x|seeds/rt_emit_flags_surface.from_x.c||"
  # rt_emit_state R2 full：.x 吃满 set_path/set_lib/set_n/set_extern + argv_parse；产品 rest FROM_X 业务 T=0（仅 marker+BSS）
  # Cap-global-bss residual：槽/绑定 API 在 driver_abi；共享 path_buf/lib_roots 数据在 rest seed
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_emit_state.from_x.c 全 C 体
  "rt_emit_state|src/runtime/rt_emit_state.x|seeds/rt_emit_state_surface.from_x.c||"
  # rt_content R2 full：.x 吃满 content_has_* + driver_source_has_* path wrappers；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_content.from_x.c 全 C 体
  "rt_content|src/runtime/rt_content.x|seeds/rt_content_surface.from_x.c||"
  # rt_util R2 full：.x 吃满 unlink + argv0_basename；产品 rest 在 FROM_X 下业务符号 H=0
  # prove 锁 full surface IDENTICAL（2 公共符号）；冷/无 PREFER 仍可走 seeds/rt_util.from_x.c 全 C 体
  "rt_util|src/runtime/rt_util.x|seeds/rt_util_surface.from_x.c||"
  # rt_argv R2 full：.x 吃满 15 公共 drv_eq_* / path_ends_x / target_has_arm；产品 rest 在 FROM_X 下业务 H=0
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_argv.from_x.c 全 C 体
  "rt_argv|src/runtime/rt_argv.x|seeds/rt_argv_surface.from_x.c||"
  # rt_entry R2 full：.x 吃满 explain_cli / smoke_diag / smoke_summary /
  #   fmt_report_no_files / run_compiler_c / build_build_x；产品 rest 在 FROM_X 下业务 H=0
  # Cap residual：driver_stdio_* + driver_entry_*_slot 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_entry.from_x.c 全 C 体
  "rt_entry|src/runtime/rt_entry.x|seeds/rt_entry_surface.from_x.c||"
  # rt_compile R2 full：.x 吃满 deps/asm_dep/apply/init/scan/impl/alloc 等 25 公共；产品 rest 在 FROM_X 下业务 H=0
  # （禁 let **u8 / 局部 u8[N]；malloc 扫描缓冲；strstr/strncmp；diag_report_with_code）
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_compile.from_x.c 全 C 体
  "rt_compile|src/runtime/rt_compile.x|seeds/rt_compile_surface.from_x.c||"
  # rt_run_exec R2 full：.x 吃满 want_asm/print_usage/test_status/print_cpu/scan/path/exec/run_test 8 公共；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：usage_write + compiled_body 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_run_exec.from_x.c 全 C 体
  "rt_run_exec|src/runtime/rt_run_exec.x|seeds/rt_run_exec_surface.from_x.c||"
  # rt_run_asm_backend R2 full：.x 吃满 driver_run_asm_backend（step 拆分 + work 槽）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual 在 driver_abi（FILE/pctx/host/defines/work）
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_run_asm_backend.from_x.c 全 C 体
  "rt_run_asm_backend|src/runtime/rt_run_asm_backend.x|seeds/rt_run_asm_backend_surface.from_x.c||"
  # rt_run_compiler_parsed R2 full：.x 吃满 driver_run_compiler_parsed（step 拆分 + work 槽）；
  # 产品 rest 在 FROM_X 下业务 H=0（仅 marker）；Cap residual：Parsed/FILE/invoke_cc/work 在 driver_abi
  # prove 锁 full surface IDENTICAL；冷/无 PREFER 仍可走 seeds/rt_run_compiler_parsed.from_x.c 全 C 体
  "rt_run_compiler_parsed|src/runtime/rt_run_compiler_parsed.x|seeds/rt_run_compiler_parsed_surface.from_x.c||"
)

# 找 shux 二进制：优先 $SHUX（文档/进度验收），再 shux_asm / shux / shux-c
# 注意：本脚本已 cd 到 compiler/，故 $SHUX=./compiler/shux_asm 需映射到 $REPO_ROOT
SHUX_BIN=""
if [ -n "${SHUX:-}" ]; then
  _shux_cand="$SHUX"
  case "$_shux_cand" in
    /*) ;;
    ./*|../*) _shux_cand="$REPO_ROOT/${_shux_cand#./}" ;;
    *)
      if [ -x "$_shux_cand" ]; then
        :
      elif [ -x "$REPO_ROOT/$_shux_cand" ]; then
        _shux_cand="$REPO_ROOT/$_shux_cand"
      elif [ -x "./$_shux_cand" ]; then
        _shux_cand="./$_shux_cand"
      fi
      ;;
  esac
  if [ -x "$_shux_cand" ]; then
    SHUX_BIN="$_shux_cand"
  fi
  unset _shux_cand
fi
if [ -z "$SHUX_BIN" ]; then
  for bin in ./shux_asm ./shux ./shux-c ./bootstrap_shuxc; do
    if [ -x "$bin" ]; then
      SHUX_BIN="$bin"
      break
    fi
  done
fi
if [ -z "$SHUX_BIN" ]; then
  echo "prove: no shux_asm/shux/shux-c found in compiler/ (set SHUX=...)" >&2
  exit 127
fi
echo "prove: SHUX_BIN=$SHUX_BIN" >&2

CC="${CC:-cc}"
BASE_CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc"
TMP_DIR="${TMPDIR:-/tmp}/shux_prove_$$"
mkdir -p "$TMP_DIR"

SHUX_LIB_PATHS="-L .. -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/lsp -L src/driver -L src/preprocess"

# 最近一次 gen_x_o 失败原因（供主循环打印；勿 2>/dev/null 吞掉）
GEN_X_O_LAST_ERR=""

# 生成 .x 版 .o（模拟 g05_try_x_to_o 逻辑；prologue 须与 g05 同源）
gen_x_o() {
  local xsrc="$1"
  local xout="$2"
  local sym_rename="$3"

  local tmp="$TMP_DIR/$(basename "$xsrc" .x)_x.c"
  local e_err="$TMP_DIR/$(basename "$xsrc" .x)_E.err"
  GEN_X_O_LAST_ERR=""

  # shux -E（超时 30s 防死循环）；stderr 落盘
  # shellcheck disable=SC2086
  if ! perl -e 'alarm 30; exec @ARGV' "$SHUX_BIN" -E $SHUX_LIB_PATHS "$xsrc" >"$tmp" 2>"$e_err" || [ ! -s "$tmp" ]; then
    GEN_X_O_LAST_ERR="shux -E fail: $(tr '\n' ' ' <"$e_err" | head -c 160)"
    return 1
  fi

  # 过滤 DBG- 调试行
  grep -v '^DBG-' "$tmp" >"${tmp}.clean" && mv "${tmp}.clean" "$tmp"

  # 符号重命名（与 g05 G05_X_O_SYM_RENAME 一致）
  if [ -n "$sym_rename" ]; then
    local old_ifs="$IFS"
    IFS=','
    for pair in $sym_rename; do
      old_name="${pair%%:*}"
      new_name="${pair#*:}"
      if [ -n "$old_name" ] && [ -n "$new_name" ] && [ "$old_name" != "$new_name" ]; then
        perl -i -pe "s/\\b${old_name}\\b/${new_name}/g" "$tmp" || true
      fi
    done
    IFS="$old_ifs"
  fi

  # POSIX prologue + 删 -E 自带 #include 和 libc extern（与 g05_try_x_to_o 一致）
  {
    echo '/* prove prologue (g05_try_x_to_o aligned + uio/poll) */'
    echo '#include <stddef.h>'
    echo '#include <stdint.h>'
    echo '#include <sys/types.h>'
    echo '#include <stdlib.h>'
    echo '#include <string.h>'
    echo '#include <stdio.h>'
    echo '#ifndef _WIN32'
    echo '#include <unistd.h>'
    echo '#include <fcntl.h>'
    echo '#include <errno.h>'
    # PLATFORM: POSIX — -E preamble 内联 shux_sys_readv/writev/poll；
    # sed 会删 -E 自带 #include，故在此补齐（权威：g05_try_x_to_o）。
    echo '#include <sys/uio.h>'
    echo '#include <poll.h>'
    echo '#endif'
    sed -e '/^#include /d' \
        -e '/^extern ssize_t read(/d' \
        -e '/^extern ssize_t write(/d' \
        -e '/^extern int32_t open(/d' \
        -e '/^extern int open(/d' \
        -e '/^extern int32_t close(/d' \
        -e '/^extern int close(/d' \
        -e '/^extern uint8_t \* calloc(/d' \
        -e '/^extern uint8_t \* malloc(/d' \
        -e '/^extern void free(/d' \
        -e '/^extern uint8_t \* memcpy(/d' \
        -e '/^extern void \* memcpy(/d' \
        -e '/^extern int32_t memcmp(/d' \
        -e '/^extern int memcmp(/d' \
        -e '/^extern char \* getenv(/d' \
        -e '/^extern uint8_t \* getenv(/d' \
        -e '/^extern char \* getcwd(/d' \
        -e '/^extern uint8_t \* getcwd(/d' \
        -e '/^extern int32_t unlink(/d' \
        -e '/^extern int unlink(/d' \
        -e '/^extern size_t strlen(/d' \
        -e '/^extern int32_t strcmp(/d' \
        -e '/^extern int strcmp(/d' \
        -e '/^extern int32_t strncmp(/d' \
        -e '/^extern int strncmp(/d' \
        -e '/^extern uint8_t \* strstr(/d' \
        -e '/^extern char \* strstr(/d' \
        -e '/^extern uint8_t \* memset(/d' \
        -e '/^extern void \* memset(/d' \
        -e '/^extern int32_t setenv(/d' \
        -e '/^extern int setenv(/d' \
        -e '/^extern uint8_t \* strerror(/d' \
        -e '/^extern char \* strerror(/d' \
        -e '/^extern int32_t system(/d' \
        -e '/^extern int system(/d' \
        -e '/^extern int32_t fputs(/d' \
        -e '/^extern int fputs(/d' \
        "$tmp"
  } >"${tmp}.full" && mv "${tmp}.full" "$tmp"

  # cc -c
  if ! $CC $BASE_CFLAGS -x c -c -o "$xout" "$tmp" 2>"${TMP_DIR}/cc_err.txt"; then
    GEN_X_O_LAST_ERR="cc -c fail: $(tr '\n' ' ' <"${TMP_DIR}/cc_err.txt" | head -c 160)"
    return 1
  fi
  return 0
}

# 生成 seed 版 .o
gen_seed_o() {
  local seed="$1"
  local out="$2"
  $CC $BASE_CFLAGS -I. -c -o "$out" "$seed" 2>"${TMP_DIR}/cc_err.txt"
}

# 已定义**强全局**业务符号裸名（去 Mach-O 前导 _），一行一个
#
# PLATFORM: SHARED — IDENTICAL 只比「强定义」API 面：
#   · Linux ELF：nm 类型 T/D/B/R/S/C（排除 U / W weak / V）
#   · macOS Mach-O：nm -m「external」且非 weak（Darwin 上 weak 常显示为 T，
#     若用 plain nm 会把 -E preamble 的 weak 桩算进 x 面 → N 全红假象）
# 忽略：局部 t/d/s、ltmp、l_ 字符串池。preamble 弱桩（args_iter_*/ctx_*/io_*…）
# 不参与退役判据——与 g05 PREFER 入链语义一致（weak 可重叠）。
defined_sym_names() {
  local obj="$1"
  # LC_ALL=C：comm 要求字节序排序；locale sort 在 Ubuntu 会触发 “not in sorted order”
  if nm -m "$obj" >/dev/null 2>&1; then
    # PLATFORM: MACOS — nm -m 可区分 weak external vs external
    nm -m "$obj" 2>/dev/null | awk '
      /undefined/ { next }
      / non-external / { next }
      / weak / { next }
      / external / {
        s = $NF
        if (s ~ /^_/) s = substr(s, 2)
        if (s ~ /^l_/) next
        if (s ~ /^\./) next
        if (s ~ /^L\./) next
        if (s ~ /^ltmp/) next
        print s
      }' | LC_ALL=C sort -u
  else
    # PLATFORM: LINUX — 强定义字母类；W/V = weak，不计入 N
    nm "$obj" 2>/dev/null | awk '
      $2 ~ /^[TDBRSC]$/ {
        s = $3
        if (s ~ /^_/) s = substr(s, 2)
        if (s ~ /^l_/) next
        if (s ~ /^\./) next
        if (s ~ /^L\./) next
        if (s ~ /^ltmp/) next
        print s
      }' | LC_ALL=C sort -u
  fi
}

# nm 比较符号 — IDENTICAL 模式：全局业务符号集合相等（可退役 seed）
compare_symbols() {
  local o1="$1"
  local o2="$2"
  local sym1="$TMP_DIR/sym1.txt"
  local sym2="$TMP_DIR/sym2.txt"
  defined_sym_names "$o1" >"$sym1"
  defined_sym_names "$o2" >"$sym2"
  diff "$sym1" "$sym2"
}

# CORE 模式：x 定义符号（除 allowlist）必须 ⊆ seed；seed 可多 thin/impl/C-tail
# 输出：空=通过；否则列出缺失符号
compare_core_surface() {
  local x_o="$1"
  local seed_o="$2"
  local allow_csv="$3"
  local x_syms="$TMP_DIR/core_x.txt"
  local seed_syms="$TMP_DIR/core_seed.txt"
  local allow_file="$TMP_DIR/core_allow.txt"
  local missing="$TMP_DIR/core_missing.txt"

  defined_sym_names "$x_o" >"$x_syms"
  defined_sym_names "$seed_o" >"$seed_syms"
  : >"$allow_file"
  if [ -n "$allow_csv" ]; then
    local old_ifs="$IFS"
    IFS=','
    for a in $allow_csv; do
      a="${a#_}"
      [ -n "$a" ] && echo "$a" >>"$allow_file"
    done
    IFS="$old_ifs"
    LC_ALL=C sort -u "$allow_file" -o "$allow_file"
  fi

  # x \ seed \ allow
  comm -23 "$x_syms" "$seed_syms" >"${missing}.raw"
  if [ -s "$allow_file" ]; then
    comm -23 "${missing}.raw" "$allow_file" >"$missing"
  else
    mv "${missing}.raw" "$missing"
  fi

  if [ -s "$missing" ]; then
    echo "CORE missing from seed:"
    cat "$missing"
    return 1
  fi
  # 备注：seed 多 / x 仅 allowlist 不 fail
  local seed_only x_only
  seed_only=$(comm -13 "$x_syms" "$seed_syms" | wc -l | tr -d ' ')
  x_only=$(comm -23 "$x_syms" "$seed_syms" | wc -l | tr -d ' ')
  echo "seed+${seed_only} x_allow+${x_only}"
  return 0
}

# 主逻辑
printf "%-18s | %-8s | %-8s | %-10s | %s\n" "模块" "shux-E" "cc-c" "nm-diff" "备注"
printf "%-18s-+-%-8s-+-%-8s-+-%-10s-+-%s\n" "$(printf '%0.s-' {1..18})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..8})" "$(printf '%0.s-' {1..10})" "$(printf '%0.s-' {1..30})"

PASS=0
CORE_PASS=0
FAIL=0
SKIP=0

# 过滤模块（如果传了参数）
SELECTED="${*:-}"
for entry in "${MODULES[@]}"; do
  IFS='|' read -r name xsrc seed sym_rename mode <<< "$entry"

  # 如果传了参数，只验证指定的模块
  if [ -n "$SELECTED" ]; then
    found=0
    for sel in $SELECTED; do
      [ "$sel" = "$name" ] && found=1 && break
    done
    [ "$found" = "0" ] && continue
  fi

  # 检查 .x 和 seed 是否存在
  if [ ! -f "$xsrc" ]; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "NOSRC" "-" "-" ".x 不存在"
    SKIP=$((SKIP + 1))
    continue
  fi
  seed_path=""
  # Track L：工作区 *_gen.c 已非构建硬依赖；冷启动对照用 seeds/*_gen.linux.x86_64.c
  _seed_base="${seed%.c}"
  for s in "$seed" "seeds/$seed" "seeds/${_seed_base}.linux.x86_64.c" "seeds/${seed}"; do
    if [ -f "$s" ]; then
      seed_path="$s"
      break
    fi
  done
  if [ -z "$seed_path" ]; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "NOSEED" "-" "-" "seed=$seed 不存在"
    SKIP=$((SKIP + 1))
    continue
  fi

  x_o="$TMP_DIR/${name}_x.o"
  seed_o="$TMP_DIR/${name}_seed.o"

  # 生成 .x 版 .o
  if ! gen_x_o "$xsrc" "$x_o" "$sym_rename"; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "FAIL" "-" "-" "${GEN_X_O_LAST_ERR:-shux -E 或 cc -c 失败}"
    FAIL=$((FAIL + 1))
    continue
  fi

  # 生成 seed 版 .o
  if ! gen_seed_o "$seed_path" "$seed_o"; then
    printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "FAIL" "-" "seed cc -c 失败"
    FAIL=$((FAIL + 1))
    continue
  fi

  # nm 比较
  if [[ "$mode" == core:* ]]; then
    allow_csv="${mode#core:}"
    core_out=$(compare_core_surface "$x_o" "$seed_o" "$allow_csv")
    core_rc=$?
    if [ "$core_rc" -eq 0 ]; then
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "CORE_OK" "$core_out; hybrid 非退役"
      CORE_PASS=$((CORE_PASS + 1))
    else
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "CORE_FAIL" "x 公共面缺失于 seed"
      echo "$core_out" | head -8 | sed 's/^/    /'
      FAIL=$((FAIL + 1))
    fi
  else
    diff_out=$(compare_symbols "$x_o" "$seed_o")
    if [ -z "$diff_out" ]; then
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "IDENTICAL" "可退役 seed"
      PASS=$((PASS + 1))
    else
      diff_lines=$(echo "$diff_out" | wc -l | tr -d ' ')
      printf "%-18s | %-8s | %-8s | %-10s | %s\n" "$name" "OK" "OK" "${diff_lines}行" "符号差异"
      # 显示前 5 行差异
      echo "$diff_out" | head -5 | sed 's/^/    /'
      FAIL=$((FAIL + 1))
    fi
  fi
done

echo ""
echo "=== 自举验证结果 ==="
echo "总计：$((PASS + CORE_PASS + FAIL + SKIP))"
echo "  符号一致（可退役 seed / KPI N）：$PASS"
echo "  核心面 OK（hybrid CORE，不计 N）：$CORE_PASS"
echo "  符号差异 / CORE 失败：$FAIL"
echo "  跳过：$SKIP"
echo ""
echo "IDENTICAL = .x→.o 与 seed→.o 已定义符号完全相同（可退役）"
echo "CORE_OK   = x 公共符号 ⊆ seed（允许 seed 多 thin/C-tail；x 独有列于 core: allowlist）"

# 清理
rm -rf "$TMP_DIR"

# 有 FAIL 则非零退出（CI / 门禁）
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
