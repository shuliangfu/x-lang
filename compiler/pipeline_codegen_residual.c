/* ============================================================================
 * pipeline_codegen_residual.c — codegen residual name/predicate helpers
 *
 * wave1251 BC 8.3.2 G.7 same-TU domain fold from ast_pool.c:
 *   use_buf_wrapper + skip_emit_extern_io_batch_buf + should_skip_emit_func_by_name
 *   emit_seed_mega_enabled + is_submit_batch_buf_call
 *   should_skip_emit_func_core_read_ptr + asm_io_core_extern_callee_sym
 *   io_driver_buf_call_sym + std_io_fixed_fd_emit_impl
 *
 * C predicate/symbol-rewrite helpers for codegen.x + asm backend io.core bridge.
 * Included from ast_pool.c (replaces former inline body). Not a separate .o.
 * Depends on codegen_name_prefix_eq (static, defined in pipeline_codegen_skip_force.c);
 * this file MUST be #included after pipeline_codegen_skip_force.c in the host TU.
 *
 * PLATFORM: SHARED.
 * ============================================================================ */
/** codegen.x：std.io.core xlang_io_* 调用名追加 _buf。 */
int32_t pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  if (!name || name_len <= 0)
    return 0;
  if (num_args == 1 && name_len == 15 && codegen_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (num_args == 2 && name_len == 18 && codegen_name_prefix_eq(name, name_len, "xlang_io_submit_read", 18))
    return 1;
  if (num_args == 2 && name_len == 19 && codegen_name_prefix_eq(name, name_len, "xlang_io_submit_write", 19))
    return 1;
  return 0;
}

/** codegen.x：driver extern io_* batch 由 preamble/io.o 提供，跳过 std_io_driver_io_* extern 声明。 */
int32_t pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 17 && memcmp(name, "io_read_batch_buf", 17) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, "io_write_batch_buf", 18) == 0)
    return 1;
  if (name_len == 23 && memcmp(name, "io_register_buffers_buf", 23) == 0)
    return 1;
  return 0;
}

/** codegen.x：占位/string 桩函数名跳过 emit（placeholder、string_new 等）。 */
int32_t pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "placeholder", 11))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "std_string_placeholder", 22))
    return 1;
  if (name_len == 10 && codegen_name_prefix_eq(name, name_len, "string_new", 10))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "std_string_string_new", 22))
    return 1;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "std_string_string_new", 21))
    return 1;
  /** bootstrap -E：seed_mega 体过大；XLANG_EMIT_SEED_MEGA=1 时仍尝试 X emit（build_seed_asm_host）。 */
  if (!link_abi_getenv("XLANG_EMIT_SEED_MEGA")) {
    if (name_len == 25 && memcmp(name, "asm_codegen_ast_seed_mega", 25) == 0)
      return 1;
    if (name_len == 32 && memcmp(name, "asm_codegen_ast_to_elf_seed_mega", 32) == 0)
      return 1;
  }
  return 0;
}

/** codegen.x：XLANG_EMIT_SEED_MEGA=1 时 bootstrap -E 仍 emit seed_mega。 */
int32_t pipeline_codegen_emit_seed_mega_enabled(void) {
  const char *e = link_abi_getenv("XLANG_EMIT_SEED_MEGA");
  return (e && e[0] && e[0] != '0') ? 1 : 0;
}

/** codegen.x：submit_*_batch_buf 调用需补第 4 参 timeout_ms。 */
int32_t pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.x：std.io.core 中 preamble/io.o 已提供的 xlang_io_* 桥接名，跳过函数体 emit。 */
int32_t pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len >= 19 && codegen_name_prefix_eq(name, name_len, "xlang_io_read_ptr_len", 19))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "xlang_io_read_ptr", 15))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (name_len == 23 && codegen_name_prefix_eq(name, name_len, "xlang_io_register_buffers", 23))
    return 1;
  if (name_len == 25 && codegen_name_prefix_eq(name, name_len, "xlang_io_unregister_buffers", 25))
    return 1;
  if (name_len == 20 && codegen_name_prefix_eq(name, name_len, "xlang_io_wait_readable", 20))
    return 1;
  return 0;
}

/**
 * asm 路径：std.io.core 薄包装未编入 .o（由 io.o 提供）时，将 call 重定向到 extern io_* 符号。
 * name 可为裸 xlang_io_* 或 std_io_core_xlang_io_*；命中写 sym_out，返回长度；无匹配 0；缓冲不足 -1。
 */
int32_t pipeline_asm_io_core_extern_callee_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t sym_cap) {
  uint8_t *bare;
  int32_t blen;
  const char *sym;
  int32_t slen;
  if (!name || name_len <= 0 || !sym_out || sym_cap <= 0)
    return 0;
  bare = name;
  blen = name_len;
  if (name_len > 12 && memcmp(name, "std_io_core_", 12) == 0) {
    bare = name + 12;
    blen = name_len - 12;
  }
  sym = NULL;
  slen = 0;
  if (blen == 23 && codegen_name_prefix_eq(bare, blen, "xlang_io_register_buffers", 23)) {
    sym = "io_register_buffers_4";
    slen = 23;
  } else if (blen == 25 && codegen_name_prefix_eq(bare, blen, "xlang_io_unregister_buffers", 25)) {
    sym = "io_unregister_buffers";
    slen = 21;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "xlang_io_register", 15)) {
    sym = "io_register_buffer";
    slen = 19;
  } else if (blen == 19 && codegen_name_prefix_eq(bare, blen, "xlang_io_read_ptr_len", 19)) {
    sym = "io_read_ptr_len";
    slen = 15;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "xlang_io_read_ptr", 15)) {
    sym = "io_read_ptr";
    slen = 11;
  } else if (blen == 20 && codegen_name_prefix_eq(bare, blen, "xlang_io_wait_readable", 20)) {
    sym = "io_wait_readable";
    slen = 17;
  }
  if (!sym)
    return 0;
  if (sym_cap < slen)
    return -1;
  memcpy(sym_out, sym, (size_t)slen);
  return slen;
}

/** codegen.x：std.io driver 短名 register/submit_* 映射到 xlang_io_*_buf；命中写 sym_out，返回符号长度；无匹配 0；缓冲不足 -1。 */
int32_t pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args, uint8_t *sym_out,
                                                int32_t sym_cap) {
  const char *sym;
  int32_t sym_len;
  if (!name || name_len <= 0)
    return 0;
  sym = NULL;
  sym_len = 0;
  if (num_args == 1 && name_len == 8 && codegen_name_prefix_eq(name, name_len, "register", 8)) {
    sym = "xlang_io_register_buf";
    sym_len = 20;
  } else if (num_args == 2 && name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11)) {
    sym = "xlang_io_submit_read_buf";
    sym_len = 23;
  } else if (num_args == 2 && name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12)) {
    sym = "xlang_io_submit_write_buf";
    sym_len = 24;
  }
  if (!sym)
    return 0;
  if (!sym_out || sym_cap < sym_len)
    return -1;
  memcpy(sym_out, sym, (size_t)sym_len);
  return sym_len;
}

/** codegen.x：std_io read_fixed_fd/write_fixed_fd 须追加 _impl 后缀。 */
int32_t pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                   int32_t name_len) {
  if (!prefix || !name || prefix_len < 7 || name_len <= 0)
    return 0;
  if (!codegen_name_prefix_eq(prefix, prefix_len, "std_io_", 7))
    return 0;
  if (name_len >= 13 && codegen_name_prefix_eq(name, name_len, "read_fixed_fd", 13))
    return 1;
  if (name_len >= 14 && codegen_name_prefix_eq(name, name_len, "write_fixed_fd", 14))
    return 1;
  return 0;
}
