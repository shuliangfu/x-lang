/* seeds/labi_od_needle_tables.c — Class BE
 * Always-linked needle tables for labi_od_simple_group_sym_at /
 * labi_fk0_sym_at / labi_std_fk_gate_sym_at. Prefer L8b/L8c .x omit these
 * bodies so this host-cc table wins (M2 labi .o true shrink). PLATFORM: SHARED.
 */
#include <stddef.h>

/* Class BE: table form of labi_od_simple_group_sym_at (od simple-group needles). PLATFORM: SHARED. */
static const char *const labi_od_simple_group_sym_at_g0[13] = {
  "xlang_string_copy_c",
  "xlang_string_memcmp_c",
  "xlang_string_memchr_c",
  "xlang_string_memmem_c",
  "xlang_string_memrchr_c",
  "std_string_string_new",
  "std_string_string_from_slice",
  "std_string_string_view",
  "std_string_string_len",
  "std_string_string_view_case_fold",
  "std_string_string_view_concat_arena",
  "std_string_string_view_get",
  "std_string_length_StrView"
};
static const char *const labi_od_simple_group_sym_at_g1[27] = {
  "core_types_size_of_i16",
  "core_types_size_of_u16",
  "core_types_align_of_i16",
  "core_types_align_of_u16",
  "core_types_size_of_i32",
  "core_types_size_of_bool",
  "core_types_size_of_u8",
  "core_types_size_of_u32",
  "core_types_size_of_u64",
  "core_types_size_of_i64",
  "core_types_size_of_usize",
  "core_types_size_of_isize",
  "core_types_size_of_f32",
  "core_types_size_of_f64",
  "core_types_size_of_pointer",
  "core_types_align_of_i32",
  "core_types_align_of_bool",
  "core_types_align_of_u8",
  "core_types_align_of_u32",
  "core_types_align_of_u64",
  "core_types_align_of_i64",
  "core_types_align_of_usize",
  "core_types_align_of_isize",
  "core_types_align_of_f32",
  "core_types_align_of_f64",
  "core_types_align_of_pointer",
  "core_types_placeholder"
};
static const char *const labi_od_simple_group_sym_at_g2[6] = {
  "encoding_utf8_valid_c",
  "encoding_hex_encode_c",
  "encoding_ascii_is_alpha_c",
  "std_encoding_utf8_valid",
  "std_encoding_utf8_decode_rune",
  "std_encoding_ascii_is_alpha"
};
static const char *const labi_od_simple_group_sym_at_g3[4] = {
  "base64_encode_standard_c",
  "std_base64_encode_standard",
  "std_base64_decode_standard",
  "std_base64_encode_url"
};
static const char *const labi_od_simple_group_sym_at_g4[5] = {
  "std_csv_next_field",
  "std_csv_escape",
  "std_csv_csv_test_quoted_first",
  "std_csv_parse_row",
  "std_csv_write_row"
};
static const char *const labi_od_simple_group_sym_at_g5[3] = {
  "schema_create_c",
  "schema_decode_json_c",
  "schema_smoke_c"
};
static const char *const labi_od_simple_group_sym_at_g6[4] = {
  "core_option_some_i32",
  "core_option_unwrap_or_i32",
  "core_option_none_i32",
  "core_option_is_some_i32"
};
static const char *const labi_od_simple_group_sym_at_g7[10] = {
  "core_result_ok_i32",
  "core_result_is_ok_i32",
  "core_result_err_i32",
  "core_result_ok",
  "core_result_err",
  "core_result_is_ok",
  "core_result_is_err",
  "core_result_unwrap_or",
  "core_result_unwrap_or_i32",
  "core_result_is_err_i32"
};
static const char *const labi_od_simple_group_sym_at_g8[6] = {
  "core_debug_assert_eq_i32",
  "core_debug_assert_eq_u32",
  "core_debug_assert_eq_u64",
  "core_debug_assert_ne_i32",
  "core_debug_assert",
  "core_debug_debug_assert"
};
static const char *const labi_od_simple_group_sym_at_g9[28] = {
  "core_slice_len_i32",
  "core_slice_get_i32",
  "core_slice_get_i32_unchecked",
  "core_slice_is_empty_i32",
  "core_slice_first_i32",
  "core_slice_last_i32",
  "core_slice_subslice_i32",
  "core_slice_split_at_i32",
  "core_slice_chunks_len_i32",
  "core_slice_chunk_i32",
  "core_slice_len_u8",
  "core_slice_get_u8",
  "core_slice_get_u8_unchecked",
  "core_slice_is_empty_u8",
  "core_slice_first_u8",
  "core_slice_subslice_u8",
  "core_slice_split_at_u8",
  "core_slice_chunks_len_u8",
  "core_slice_chunk_u8",
  "core_slice_len_u64",
  "core_slice_get_u64",
  "core_slice_is_empty_u64",
  "core_slice_first_u64",
  "core_slice_last_u64",
  "core_slice_subslice_u64",
  "core_slice_split_at_u64",
  "core_slice_chunks_len_u64",
  "core_slice_chunk_u64"
};
static const char *const labi_od_simple_group_sym_at_g10[14] = {
  "core_builtin_placeholder",
  "core_builtin_copy",
  "core_builtin_min_i32",
  "core_builtin_max_i32",
  "core_builtin_min_u32",
  "core_builtin_max_u32",
  "core_builtin_clz_u32",
  "core_builtin_ctz_u32",
  "core_builtin_popcount_u32",
  "core_builtin_bswap_u32",
  "core_builtin_rotl_u32",
  "core_builtin_rotr_u32",
  "core_builtin_unreachable",
  "core_builtin_abort"
};
static const char *const labi_od_simple_group_sym_at_g11[8] = {
  "std_ffi_cstr_len",
  "std_ffi_cstring_new",
  "std_ffi_cstring_free",
  "std_ffi_cstring_try_new",
  "std_ffi_cstring_destroy",
  "ffi_cstr_len_c",
  "ffi_cstring_new_c",
  "ffi_cstring_free_c"
};
static const char *const labi_od_simple_group_sym_at_g12[5] = {
  "std_test_expect",
  "std_test_expect_eq_i32",
  "std_test_expect_ne_i32",
  "std_test_assert",
  "std_test_runner_case"
};
static const char *const labi_od_simple_group_sym_at_g13[6] = {
  "core_assert_assert",
  "core_assert_assert_eq_i32",
  "core_assert_assert_ne_i32",
  "core_assert_debug_assert",
  "core_assert_assert_eq_u32",
  "core_assert_assert_eq_bool"
};
static const char *const labi_od_simple_group_sym_at_g14[9] = {
  "std_fmt_format_i32",
  "std_fmt_to_buf_u8_ptr_i32_i32",
  "std_fmt_to_buf_u8_ptr_i32_u32",
  "std_fmt_to_buf_u8_ptr_i32_i64",
  "std_fmt_to_buf_u8_ptr_i32_u64",
  "std_fmt_hex_to_buf_u8_ptr_i32_u32",
  "std_fmt_append_to_buf_u8_ptr_i32_i32_i32",
  "std_fmt_format_u8_ptr_i32_i32_i32",
  "std_fmt_format_template"
};
static const char *const labi_od_simple_group_sym_at_g15[28] = {
  "std_compress_gzip_compress",
  "std_compress_gzip_decompress",
  "std_compress_brotli_compress",
  "std_compress_brotli_decompress",
  "std_compress_zstd_compress",
  "std_compress_zstd_decompress",
  "std_compress_compress_state_bytes_for",
  "std_compress_compress_init",
  "std_compress_compress_process",
  "std_compress_compress_end",
  "std_compress_format_brotli",
  "std_compress_format_zstd",
  "std_compress_mode_compress",
  "std_compress_mode_decompress",
  "std_compress_zlib_deflate",
  "std_compress_zlib_inflate",
  "std_compress_gzip_gzip_compress",
  "std_compress_gzip_gzip_decompress",
  "std_compress_deflate",
  "std_compress_inflate",
  "compress_deflate_c",
  "compress_inflate_c",
  "compress_gzip_compress_c",
  "compress_gzip_decompress_c",
  "std_compress_gzip_stream_state_bytes",
  "std_compress_brotli_stream_state_bytes",
  "std_compress_zstd_stream_state_bytes",
  "std_compress_brotli_lib_compress_brotli_stream_init_decompress_"
};
static const char *const labi_od_simple_group_sym_at_g16[4] = {
  "std_io_driver_register",
  "std_io_driver_submit_read",
  "std_io_driver_submit_write",
  "std_io_driver_submit_register_fixed_buffers_buf"
};
static const char *const labi_od_simple_group_sym_at_g17[3] = {
  "std_debug_assert",
  "std_debug_println_u8_ptr_i32",
  "std_debug_print_u8_ptr_i32"
};
static const char *const labi_od_simple_group_sym_at_g18[23] = {
  "std_simd_shuffle_f32x4_i32_a4",
  "std_simd_shuffle_i32x8_i32_a8",
  "std_simd_select_f32x4_f32x4_f32x4",
  "std_simd_select_i32x8_i32x8_i32x8",
  "std_simd_splat_i32",
  "std_simd_splat_f32",
  "std_simd_mul_f32x4_f32x4",
  "std_simd_mul_i32x8_i32x8",
  "std_simd_sub_i32x8_i32x8",
  "std_simd_sub_f32x4_f32x4",
  "std_simd_add_f32x4_f32x4",
  "std_simd_add_i32x8_i32x8",
  "std_simd_dot",
  "std_simd_madd",
  "std_simd_fma",
  "std_simd_hsum",
  "std_simd_placeholder",
  "std_simd_hw_available",
  "std_simd_recommend_path",
  "std_simd_SIMD_PATH_SCALAR",
  "std_simd_SIMD_PATH_HW",
  "std_simd_select_lane_i32_i32_i32",
  "std_simd_select_lane_f32_f32_f32"
};
static const char *const labi_od_simple_group_sym_at_g19[3] = {
  "std_io_timeout_from_ctx",
  "std_io_read_ctx",
  "std_io_write_ctx"
};
static const char *const labi_od_simple_group_sym_at_g20[8] = {
  "std_unicode_category",
  "std_unicode_to_lower",
  "std_unicode_to_upper",
  "std_unicode_is_whitespace",
  "std_unicode_is_ascii",
  "std_unicode_case_fold_rune",
  "std_unicode_is_supplementary",
  "std_unicode_rune_utf8_len"
};
static const char *const labi_od_simple_group_sym_at_g21[12] = {
  "core_str_bytes_view",
  "core_str_bytes_view_from_slice",
  "core_str_bytes_view_len",
  "core_str_bytes_view_is_empty",
  "core_str_bytes_view_get",
  "core_str_bytes_view_subview",
  "core_str_bytes_view_eq",
  "core_str_bytes_view_eq_bytes",
  "core_str_bytes_view_index_of_byte",
  "core_str_bytes_view_index_of",
  "core_str_bytes_view_contains_byte",
  "core_str_bytes_view_starts_with"
};
static const char *const labi_od_simple_group_sym_at_g22[10] = {
  "core_iterator_iter_i32",
  "core_iterator_iter_u8",
  "core_iterator_next_i32",
  "core_iterator_next_u8",
  "core_iterator_iter_remaining_i32",
  "core_iterator_iter_remaining_u8",
  "core_iterator_iterator_protocol_version",
  "core_iterator_iter_u64_from_buf",
  "core_iterator_next_u64",
  "core_iterator_iter_remaining_u64"
};
static const char *const labi_od_simple_group_sym_at_g23[29] = {
  "std_bytes_from_external",
  "std_bytes_is_owned",
  "std_bytes_recommend_bytes_alloc_arena",
  "std_bytes_extend",
  "std_bytes_length",
  "std_bytes_deinit",
  "std_bytes_default_capacity",
  "std_bytes_new",
  "std_bytes_recommend_bytes_alloc",
  "std_bytes_with_capacity",
  "std_bytes_reserve_one",
  "std_bytes_reserve",
  "std_bytes_grow",
  "std_bytes_append_byte",
  "std_bytes_from_slice",
  "std_bytes_capacity",
  "std_bytes_clear",
  "std_bytes_as_view",
  "std_bytes_from_view",
  "std_bytes_as_buffer",
  "std_bytes_reader",
  "std_bytes_read",
  "std_bytes_remaining",
  "std_bytes_seek",
  "std_bytes_writer",
  "std_bytes_write",
  "std_bytes_remaining_cap",
  "std_bytes_eq",
  "std_bytes_bytes_module_anchor"
};
static const char *const labi_od_simple_group_sym_at_g24[12] = {
  "core_fmt_fmt_usize_to_buf",
  "core_fmt_fmt_isize_to_buf",
  "core_fmt_fmt_ptr_to_buf",
  "core_fmt_fmt_f64_to_buf",
  "core_fmt_fmt_f64_to_buf_prec",
  "core_fmt_fmt_i32_to_buf",
  "core_fmt_fmt_u32_to_buf",
  "core_fmt_fmt_u64_to_buf",
  "core_fmt_fmt_i64_to_buf",
  "core_fmt_fmt_bool_to_buf",
  "core_fmt_fmt_u64_hex_to_buf",
  "core_fmt_fmt_i32"
};
static const char *const labi_od_simple_group_sym_at_g25[12] = {
  "core_cmp_cmp_i32",
  "core_cmp_cmp_u8",
  "core_cmp_cmp_ptr",
  "core_cmp_is_lt",
  "core_cmp_is_eq",
  "core_cmp_is_gt",
  "core_cmp_then",
  "core_cmp_reverse",
  "core_cmp_ordering_less",
  "core_cmp_ordering_equal",
  "core_cmp_ordering_greater",
  "core_cmp_ordering_from_i32"
};
struct labi_od_simple_group_sym_at_row { const char *const *syms; int n; };
static const struct labi_od_simple_group_sym_at_row labi_od_simple_group_sym_at_rows[] = {
  { labi_od_simple_group_sym_at_g0, 13 },
  { labi_od_simple_group_sym_at_g1, 27 },
  { labi_od_simple_group_sym_at_g2, 6 },
  { labi_od_simple_group_sym_at_g3, 4 },
  { labi_od_simple_group_sym_at_g4, 5 },
  { labi_od_simple_group_sym_at_g5, 3 },
  { labi_od_simple_group_sym_at_g6, 4 },
  { labi_od_simple_group_sym_at_g7, 10 },
  { labi_od_simple_group_sym_at_g8, 6 },
  { labi_od_simple_group_sym_at_g9, 28 },
  { labi_od_simple_group_sym_at_g10, 14 },
  { labi_od_simple_group_sym_at_g11, 8 },
  { labi_od_simple_group_sym_at_g12, 5 },
  { labi_od_simple_group_sym_at_g13, 6 },
  { labi_od_simple_group_sym_at_g14, 9 },
  { labi_od_simple_group_sym_at_g15, 28 },
  { labi_od_simple_group_sym_at_g16, 4 },
  { labi_od_simple_group_sym_at_g17, 3 },
  { labi_od_simple_group_sym_at_g18, 23 },
  { labi_od_simple_group_sym_at_g19, 3 },
  { labi_od_simple_group_sym_at_g20, 8 },
  { labi_od_simple_group_sym_at_g21, 12 },
  { labi_od_simple_group_sym_at_g22, 10 },
  { labi_od_simple_group_sym_at_g23, 29 },
  { labi_od_simple_group_sym_at_g24, 12 },
  { labi_od_simple_group_sym_at_g25, 12 }
};
const char *labi_od_simple_group_sym_at(int g, int i) {
  const struct labi_od_simple_group_sym_at_row *row;
  if (g < 0 || i < 0)
    return NULL;
  if ((unsigned)g >= (unsigned)(sizeof(labi_od_simple_group_sym_at_rows) / sizeof(labi_od_simple_group_sym_at_rows[0])))
    return NULL;
  row = &labi_od_simple_group_sym_at_rows[g];
  if (!row->syms || i >= row->n)
    return NULL;
  return row->syms[i];
}

/* Class BE: table form of labi_fk0_sym_at (fk0 needles). PLATFORM: SHARED. */
static const char *const labi_fk0_sym_at_g0[11] = {
  "std_string_string_empty",
  "std_string_new",
  "std_string_length_String",
  "std_string_length_StrView",
  "std_string_is_empty_String",
  "std_string_is_empty_StrView",
  "std_string_view",
  "std_string_string_from_slice",
  "std_string_string_eq",
  "xlang_string_memcmp_c",
  "xlang_string_memmem_c"
};
static const char *const labi_fk0_sym_at_g1[2] = {
  "std_encoding_utf8_valid",
  "std_encoding_ascii_is_alpha"
};
static const char *const labi_fk0_sym_at_g2[2] = {
  "std_base64_encode_standard",
  "std_base64_decode_standard"
};
static const char *const labi_fk0_sym_at_g3[4] = {
  "std_http_get",
  "std_http_request",
  "std_http_client_new",
  "http_get_c"
};
static const char *const labi_fk0_sym_at_g4[12] = {
  "std_json_parse",
  "std_json_parse_null",
  "std_json_parse_number",
  "std_json_parse_string",
  "std_json_parse_string_view",
  "std_json_skip_value",
  "json_parse_null_c",
  "json_parse_number_c",
  "json_parse_bool_c",
  "json_parse_string_c",
  "json_parse_string_view_c",
  "json_skip_value_c"
};
static const char *const labi_fk0_sym_at_g5[4] = {
  "std_csv_next_field",
  "std_csv_parse_line",
  "std_csv_parse_row",
  "std_csv_write_row"
};
static const char *const labi_fk0_sym_at_g6[12] = {
  "std_path_join",
  "std_path_dirname",
  "std_path_empty_len",
  "std_path_basename",
  "std_path_sep",
  "std_path_is_absolute",
  "std_path_is_sep",
  "std_path_extension",
  "std_path_stem",
  "std_path_extension_and_stem",
  "std_path_clean",
  "std_path_resolve"
};
static const char *const labi_fk0_sym_at_g7[11] = {
  "std_hash_sip_hash",
  "std_hash_fnv1a",
  "std_hash_start",
  "std_hash_bytes",
  "std_hash_finish",
  "std_hash_free",
  "std_hash_write_u8_ptr_u32",
  "hash_sip_bytes_c",
  "hash_sip_free_c",
  "hash_xxhash64_bytes_c",
  "hash_xxhash64_seed_bytes_c"
};
static const char *const labi_fk0_sym_at_g8[57] = {
  "std_error_ok",
  "std_error_code_alloc_fail",
  "std_error_code_invalid",
  "std_error_code_not_found",
  "std_error_ok_value",
  "std_error_from_code",
  "std_error_code",
  "std_error_is_ok",
  "std_error_is_err",
  "std_error_base_io",
  "std_error_io_err_timeout",
  "std_error_io_err_cancelled",
  "std_error_io_err_generic",
  "std_error_base_net",
  "std_error_net_err_timeout",
  "std_error_net_err_cancelled",
  "std_error_net_err_generic",
  "std_error_base_async",
  "std_error_async_err_generic",
  "std_error_base_coll",
  "std_error_coll_err_generic",
  "std_error_base_fs",
  "std_error_fs_err_not_found",
  "std_error_mod_tag_io",
  "std_error_mod_tag_fs",
  "std_error_mod_tag_db",
  "std_error_sidecar_none",
  "std_error_sidecar_errno",
  "std_error_sidecar_db_struct",
  "std_error_code_to_module_base",
  "std_error_code_in_global_range",
  "std_error_code_in_module_span",
  "std_error_code_is_platform_errno",
  "std_error_mod_tag_from_base",
  "std_error_mod_base_from_tag",
  "std_error_module_sidecar_kind",
  "std_error_sem_none",
  "std_error_sem_timeout",
  "std_error_sem_cancelled",
  "std_error_sem_not_found",
  "std_error_http_err_timeout",
  "std_error_http_err_cancelled",
  "std_error_semantic_class",
  "std_error_is_timeout",
  "std_error_is_cancelled",
  "std_error_is_not_found",
  "std_error_recommend_retry",
  "std_error_chain_max_depth",
  "std_error_chain_empty",
  "std_error_chain_from_code",
  "std_error_chain_from_result",
  "std_error_chain_depth",
  "std_error_chain_root",
  "std_error_chain_code_at",
  "std_error_chain_leaf",
  "std_error_chain_wrap",
  "std_error_error_module_anchor"
};
static const char *const labi_fk0_sym_at_g9[4] = {
  "std_context_background",
  "std_context_deadline_ns",
  "std_context_is_cancelled",
  "std_context_remaining_ns"
};
static const char *const labi_fk0_sym_at_g10[42] = {
  "std_vec_new_retVec_u8",
  "std_vec_new_retVec_i32",
  "std_vec_push_Vec_u8_ptr_u8",
  "std_vec_push_Vec_i32_ptr_i32",
  "std_vec_length_Vec_u8",
  "std_vec_length_Vec_i32",
  "std_vec_len_empty",
  "std_vec_vec_len_empty",
  "std_vec_new",
  "std_vec_push",
  "std_vec_pop_Vec_i32_ptr",
  "std_vec_pop_Vec_u8_ptr",
  "std_vec_extend_Vec_i32_ptr_i32_ptr_i32",
  "std_vec_extend_Vec_u8_ptr_u8_ptr_i32",
  "std_vec_extend_Vec_u64_ptr_u64_ptr_i32",
  "std_vec_extend_Vec_f64_ptr_f64_ptr_i32",
  "std_vec_from_slice_u64_ptr_i32",
  "std_vec_from_slice_f64_ptr_i32",
  "std_vec_push_Vec_u64_ptr_u64",
  "std_vec_push_Vec_f64_ptr_f64",
  "std_vec_length_Vec_u64",
  "std_vec_deinit_Vec_u64_ptr",
  "std_vec_length_Vec_f64",
  "std_vec_deinit_Vec_f64_ptr",
  "std_vec_get_Vec_u64_i32",
  "std_vec_get_Vec_f64_i32",
  "std_vec_vec3f_soa_push",
  "std_vec_vec3f_soa_deinit",
  "std_vec_vec3f_aos_push",
  "std_vec_vec3f_aos_deinit",
  "std_vec_vec3f_soa_sum_x",
  "std_vec_vec3f_soa_reserve_one",
  "std_vec_vec3f_soa_len",
  "std_vec_vec3f_soa_get_x",
  "std_vec_vec3f_soa_get_y",
  "std_vec_vec3f_soa_get_z",
  "std_vec_vec3f_soa_set",
  "std_vec_vec3f_soa_with_capacity",
  "std_vec_vec3f_aos_reserve_one",
  "std_vec_vec3f_aos_get_x",
  "std_vec_vec3f_aos_sum_x",
  "std_vec_vec3f_aos_with_capacity"
};
static const char *const labi_fk0_sym_at_g11[9] = {
  "std_sort_sort_i32_ptr_i32",
  "std_sort_sort_u8_ptr_i32",
  "std_sort_stable_i32_ptr_i32",
  "std_sort_stable_u8_ptr_i32",
  "std_sort_stable_by_key",
  "std_sort_cmp",
  "std_sort_cmp_asc_fn",
  "std_sort_cmp_desc_fn",
  "std_sort_cmp_key_fn"
};
static const char *const labi_fk0_sym_at_g12[13] = {
  "std_env_getenv",
  "std_env_getenv_exists",
  "std_env_getenv_z",
  "std_env_getenv_ptr",
  "std_env_setenv",
  "std_env_unsetenv",
  "std_env_temp_dir",
  "std_env_iter",
  "std_env_iter_count",
  "std_env_args_iter",
  "std_env_args_iter_count",
  "args_iter_count_c",
  "args_iter_at_c"
};
static const char *const labi_fk0_sym_at_g13[12] = {
  "std_random_next",
  "std_random_fill_bytes",
  "std_random_fill",
  "std_random_range_u32_u32",
  "std_random_flip",
  "std_random_gen",
  "std_random_rng_smoke",
  "std_random_seed",
  "random_u32_c",
  "random_u64_c",
  "random_rng_smoke_c",
  "random_fill_bytes_c"
};
static const char *const labi_fk0_sym_at_g14[15] = {
  "std_time_now_monotonic_ns",
  "std_time_now_monotonic_ms",
  "std_time_now_wall_ns",
  "std_time_sleep_ms",
  "std_time_sleep_ns",
  "std_time_duration_ns",
  "std_time_timer_start",
  "std_time_start",
  "std_time_elapsed_ns",
  "std_time_format_wall_rfc3339",
  "std_time_wall_local_offset_min",
  "std_time_format_timezone_smoke",
  "time_now_monotonic_ns_c",
  "time_sleep_ns_c",
  "time_now_wall_ns_c"
};
static const char *const labi_fk0_sym_at_g15[15] = {
  "std_fs_invalid",
  "std_fs_open",
  "std_fs_create",
  "std_fs_close",
  "std_fs_read",
  "std_fs_write",
  "std_fs_chunk_size",
  "std_fs_mmap_ro",
  "std_fs_last_error",
  "std_fs_readv_buf",
  "std_fs_writev_buf",
  "std_fs_stat",
  "std_fs_dir_open",
  "std_fs_dir_read",
  "std_fs_dir_close"
};
static const char *const labi_fk0_sym_at_g16[7] = {
  "std_tar_read_header",
  "std_tar_write_header",
  "std_tar_append_entry",
  "std_tar_next_entry",
  "std_tar_read_entry_data",
  "std_tar_path_max",
  "tar_read_header_c"
};
static const char *const labi_fk0_sym_at_g17[8] = {
  "std_unicode_category",
  "std_unicode_to_lower",
  "std_unicode_to_upper",
  "std_unicode_is_whitespace",
  "std_unicode_is_ascii",
  "std_unicode_case_fold_rune",
  "std_unicode_is_supplementary",
  "std_unicode_rune_utf8_len"
};
static const char *const labi_fk0_sym_at_g18[5] = {
  "std_runtime_ready",
  "std_runtime_panic",
  "std_runtime_abort",
  "std_runtime_diag_enabled",
  "std_runtime_crash_evidence_collect"
};
static const char *const labi_fk0_sym_at_g19[10] = {
  "std_cli_err_ok",
  "std_cli_err_help",
  "std_cli_err_unknown",
  "std_cli_parse_from_iter",
  "std_cli_arg_len",
  "std_cli_is_help",
  "std_cli_is_version",
  "std_cli_match_long",
  "std_cli_match_short",
  "std_cli_write_usage"
};
static const char *const labi_fk0_sym_at_g20[27] = {
  "std_datetime_timezone_iana",
  "std_datetime_now_utc",
  "std_datetime_from_unix",
  "std_datetime_from_utc_fields",
  "std_datetime_to_utc_fields",
  "std_datetime_compare",
  "std_datetime_parse_rfc3339",
  "std_datetime_format_rfc3339",
  "std_datetime_format_rfc3339_nano",
  "std_datetime_local_offset_min",
  "std_datetime_to_local_fields",
  "std_datetime_duration_from_ns",
  "std_datetime_duration_from_sec",
  "std_datetime_duration_between",
  "std_datetime_add_duration",
  "std_datetime_duration_sleep",
  "std_datetime_duration_from_monotonic",
  "std_datetime_timezone_utc",
  "std_datetime_timezone_local",
  "std_datetime_timezone_fixed",
  "std_datetime_timezone_from_name",
  "std_datetime_timezone_offset_at",
  "std_datetime_parse_offset_min",
  "std_datetime_to_zoned_fields",
  "std_datetime_from_zoned_fields",
  "std_datetime_iana_dst_smoke",
  "std_datetime_timezone_smoke"
};
static const char *const labi_fk0_sym_at_g21[31] = {
  "std_config_err_ok",
  "std_config_err_null",
  "std_config_err_not_found",
  "std_config_err_invalid",
  "std_config_err_io",
  "std_config_err_full",
  "std_config_source_unknown",
  "std_config_source_toml",
  "std_config_source_yaml",
  "std_config_source_env",
  "std_config_source_set",
  "std_config_new",
  "std_config_free",
  "std_config_clear",
  "std_config_load_toml_buf",
  "std_config_load_toml_file",
  "std_config_load_env_prefix",
  "std_config_merge",
  "std_config_set_string",
  "std_config_get_string",
  "std_config_get_i32",
  "std_config_get_bool",
  "std_config_get_source",
  "std_config_get_i32_meta",
  "std_config_get_bool_meta",
  "std_config_get_string_meta",
  "std_config_backend_toml",
  "std_config_backend_yaml",
  "std_config_load_yaml_buf",
  "std_config_load_yaml_file",
  "std_config_yaml_smoke"
};
static const char *const labi_fk0_sym_at_g22[20] = {
  "std_cache_err_ok",
  "std_cache_err_null",
  "std_cache_err_not_found",
  "std_cache_err_full",
  "std_cache_err_invalid",
  "std_cache_new_lru",
  "std_cache_free_LruCache_ptr",
  "std_cache_get",
  "std_cache_put",
  "std_cache_remove",
  "std_cache_purge",
  "std_cache_stats_LruCache_ptr_CacheStats_ptr",
  "std_cache_new",
  "std_cache_free_ObjPool_ptr",
  "std_cache_add",
  "std_cache_acquire",
  "std_cache_release",
  "std_cache_mark_unhealthy",
  "std_cache_idle",
  "std_cache_stats_ObjPool_ptr_PoolStats_ptr"
};
static const char *const labi_fk0_sym_at_g23[10] = {
  "std_url_parse",
  "std_url_build",
  "std_url_stringify",
  "std_url_query_encode",
  "std_url_query_decode",
  "std_url_resolve",
  "std_url_host_to_ipv6",
  "std_url_format_ipv6_host",
  "std_url_host_is_ipv6",
  "std_url_ipv6_host_smoke"
};
static const char *const labi_fk0_sym_at_g24[16] = {
  "std_security_key_len",
  "std_security_salt_len_default",
  "std_security_min_secret_len",
  "std_security_err_ok",
  "std_security_err_invalid",
  "std_security_err_random",
  "std_security_err_buffer",
  "std_security_ct_compare",
  "std_security_random_key",
  "std_security_random_salt",
  "std_security_hkdf",
  "std_security_secure_zero",
  "std_security_sensitive_lock",
  "std_security_sensitive_unlock",
  "std_security_sensitive_buf_init",
  "std_security_sensitive_buf_wipe"
};
static const char *const labi_fk0_sym_at_g25[11] = {
  "std_option_none",
  "std_option_some",
  "std_option_unwrap_or",
  "std_option_is_some",
  "std_option_is_none",
  "std_option_map",
  "std_option_and_then",
  "std_option_or",
  "std_option_from_result_Result_i32",
  "std_option_from_result_Result_u8",
  "std_option_to_result"
};
static const char *const labi_fk0_sym_at_g26[11] = {
  "std_result_ok",
  "std_result_err",
  "std_result_is_ok",
  "std_result_is_err",
  "std_result_unwrap_or",
  "std_result_map",
  "std_result_and_then",
  "std_result_or_else",
  "std_result_from_error_code",
  "std_result_from_value",
  "std_result_err_code"
};
struct labi_fk0_sym_at_row { const char *const *syms; int n; };
static const struct labi_fk0_sym_at_row labi_fk0_sym_at_rows[] = {
  { labi_fk0_sym_at_g0, 11 },
  { labi_fk0_sym_at_g1, 2 },
  { labi_fk0_sym_at_g2, 2 },
  { labi_fk0_sym_at_g3, 4 },
  { labi_fk0_sym_at_g4, 12 },
  { labi_fk0_sym_at_g5, 4 },
  { labi_fk0_sym_at_g6, 12 },
  { labi_fk0_sym_at_g7, 11 },
  { labi_fk0_sym_at_g8, 57 },
  { labi_fk0_sym_at_g9, 4 },
  { labi_fk0_sym_at_g10, 42 },
  { labi_fk0_sym_at_g11, 9 },
  { labi_fk0_sym_at_g12, 13 },
  { labi_fk0_sym_at_g13, 12 },
  { labi_fk0_sym_at_g14, 15 },
  { labi_fk0_sym_at_g15, 15 },
  { labi_fk0_sym_at_g16, 7 },
  { labi_fk0_sym_at_g17, 8 },
  { labi_fk0_sym_at_g18, 5 },
  { labi_fk0_sym_at_g19, 10 },
  { labi_fk0_sym_at_g20, 27 },
  { labi_fk0_sym_at_g21, 31 },
  { labi_fk0_sym_at_g22, 20 },
  { labi_fk0_sym_at_g23, 10 },
  { labi_fk0_sym_at_g24, 16 },
  { labi_fk0_sym_at_g25, 11 },
  { labi_fk0_sym_at_g26, 11 }
};
const char *labi_fk0_sym_at(int k, int i) {
  const struct labi_fk0_sym_at_row *row;
  if (k < 0 || i < 0)
    return NULL;
  if ((unsigned)k >= (unsigned)(sizeof(labi_fk0_sym_at_rows) / sizeof(labi_fk0_sym_at_rows[0])))
    return NULL;
  row = &labi_fk0_sym_at_rows[k];
  if (!row->syms || i >= row->n)
    return NULL;
  return row->syms[i];
}

/* Class BE: table form of labi_std_fk_gate_sym_at (std fk gate needles). PLATFORM: SHARED. */
static const char *const labi_std_fk_gate_sym_at_g1[28] = {
  "process_xlang_argv_get",
  "process_arg_c",
  "process_args_count_c",
  "std_process_exit",
  "std_process_args_count",
  "std_process_arg",
  "std_process_getenv",
  "std_process_setenv",
  "std_process_unsetenv",
  "std_process_getpid",
  "std_process_getppid",
  "std_process_getcwd",
  "std_process_getcwd_ptr",
  "std_process_getcwd_cached_len",
  "std_process_chdir",
  "std_process_self_exe_path",
  "std_process_self_exe_path_ptr",
  "std_process_self_exe_path_cached_len",
  "std_process_spawn",
  "std_process_spawn_io",
  "std_process_spawn_simple",
  "std_process_exec",
  "std_process_exec_simple",
  "std_process_waitpid",
  "std_process_pipe",
  "process_getenv_c",
  "process_spawn_c",
  "process_waitpid_c"
};
static const char *const labi_std_fk_gate_sym_at_g2[16] = {
  "std_thread_spawn",
  "std_thread_join",
  "thread_create_c",
  "thread_join_c",
  "thread_pool_start_c",
  "thread_pool_submit_c",
  "thread_pool_drain_c",
  "thread_pool_stop_c",
  "thread_pool_pending_c",
  "thread_set_name_self_c",
  "thread_dummy_entry_ptr_c",
  "thread_create_with_stack_c",
  "thread_self_c",
  "thread_set_affinity_c",
  "thread_set_affinity_self_c",
  "thread_set_qos_class_self_c"
};
static const char *const labi_std_fk_gate_sym_at_g3[5] = {
  "std_sync_lock",
  "std_sync_new_mutex",
  "std_sync_try_lock",
  "std_sync_wait",
  "sync_mutex_lock_c"
};
static const char *const labi_std_fk_gate_sym_at_g4[3] = {
  "std_crypto_mem_eq",
  "crypto_mem_eq_c",
  "std_crypto_sha256"
};
static const char *const labi_std_fk_gate_sym_at_g5[5] = {
  "std_log_log",
  "std_log_level_info",
  "std_log_set_min_level",
  "log_write_c",
  "std_log_structured_kv"
};
static const char *const labi_std_fk_gate_sym_at_g6[32] = {
  "std_atomic_store_i32_ptr_i32",
  "std_atomic_load_i32_ptr",
  "std_atomic_fetch_add_i32_ptr_i32",
  "std_atomic_store_i64_ptr_i64",
  "atomic_store_i32_c",
  "std_atomic_store_i16_ptr_i16",
  "std_atomic_store_u16_ptr_u16",
  "std_atomic_store_u32_ptr_u32",
  "std_atomic_store_u64_ptr_u64",
  "std_atomic_load_i16_ptr",
  "std_atomic_load_u16_ptr",
  "std_atomic_load_u32_ptr",
  "std_atomic_load_i64_ptr",
  "std_atomic_load_u64_ptr",
  "std_atomic_fetch_add_i16_ptr_i16",
  "std_atomic_fetch_add_u16_ptr_u16",
  "std_atomic_fetch_add_u32_ptr_u32",
  "std_atomic_fetch_add_i64_ptr_i64",
  "std_atomic_fetch_add_u64_ptr_u64",
  "std_atomic_fetch_sub_i32_ptr_i32",
  "std_atomic_fetch_sub_i64_ptr_i64",
  "std_atomic_fetch_sub_u64_ptr_u64",
  "std_atomic_compare_exchange_i16_ptr_i16_ptr_i16",
  "std_atomic_compare_exchange_i32_ptr_i32_ptr_i32",
  "std_atomic_compare_exchange_i64_ptr_i64_ptr_i64",
  "std_atomic_compare_exchange_u16_ptr_u16_ptr_u16",
  "std_atomic_compare_exchange_u32_ptr_u32_ptr_u32",
  "std_atomic_compare_exchange_u64_ptr_u64_ptr_u64",
  "std_atomic_fence_acquire",
  "std_atomic_fence_release",
  "std_atomic_fence_seq_cst",
  "atomic_load_i32_c"
};
static const char *const labi_std_fk_gate_sym_at_g7[19] = {
  "std_channel_send",
  "std_channel_recv",
  "std_channel_bounded",
  "std_channel_close",
  "std_channel_free",
  "std_channel_try_send",
  "std_channel_try_recv",
  "std_channel_unbounded",
  "channel_send",
  "channel_recv",
  "channel_i32_send_c",
  "channel_i32_bounded_c",
  "channel_i32_unbounded_c",
  "channel_i32_recv_c",
  "channel_i32_try_send_c",
  "channel_i32_try_recv_c",
  "channel_i32_close_c",
  "channel_i32_free_c",
  "channel_i32_is_closed_c"
};
static const char *const labi_std_fk_gate_sym_at_g8[2] = {
  "std_backtrace_capture",
  "backtrace_capture"
};
static const char *const labi_std_fk_gate_sym_at_g9[60] = {
  "std_math_sin",
  "std_math_cos",
  "std_math_tan",
  "std_math_pi",
  "std_math_e",
  "std_math_tau",
  "std_math_floor",
  "std_math_ceil",
  "std_math_trunc",
  "std_math_round",
  "std_math_sqrt",
  "std_math_cbrt",
  "std_math_pow",
  "std_math_exp",
  "std_math_log",
  "std_math_abs",
  "std_math_signum",
  "std_math_min",
  "std_math_max",
  "std_math_asin",
  "std_math_acos",
  "std_math_atan",
  "std_math_atan2",
  "math_sin",
  "math_cos",
  "math_sin_c",
  "math_cos_c",
  "math_floor_c",
  "math_pi_c",
  "math_acos_c",
  "math_asin_c",
  "math_atan_c",
  "math_atan2_c",
  "math_cbrt_c",
  "math_ceil_c",
  "math_erf_c",
  "math_erfc_c",
  "math_exp_c",
  "math_expm1_c",
  "math_fabs_c",
  "math_fmax_c",
  "math_fmin_c",
  "math_log_c",
  "math_log1p_c",
  "math_pow_c",
  "math_round_c",
  "math_signum_c",
  "math_sqrt_c",
  "math_tan_c",
  "math_trunc_c",
  "math_fenv_available_c",
  "math_fenv_capability_smoke_c",
  "math_fenv_clear_c",
  "math_fenv_emit_cap_report",
  "math_fenv_fe_to_mask",
  "math_fenv_mask_to_fe",
  "math_fenv_raise_c",
  "math_fenv_smoke_c",
  "math_fenv_test_c",
  "math_special_near"
};
static const char *const labi_std_fk_gate_sym_at_g10[33] = {
  "std_db_sqlite_is_available",
  "std_db_sqlite_open",
  "std_db_sqlite_close",
  "std_db_sqlite_exec",
  "std_db_sqlite_rows",
  "std_db_sqlite_begin",
  "std_db_sqlite_next_row",
  "std_db_sqlite_col",
  "std_db_sqlite_col_text",
  "std_db_sqlite_col_blob",
  "std_db_sqlite_col_blob_len",
  "std_db_sqlite_col_blob_read",
  "std_db_sqlite_end",
  "std_db_sqlite_begin_tx",
  "std_db_sqlite_commit",
  "std_db_sqlite_rollback",
  "std_db_sqlite_last_error",
  "std_db_sqlite_backend_name",
  "std_db_sqlite_changes",
  "std_db_sqlite_prepare",
  "std_db_sqlite_prepare_cached",
  "std_db_sqlite_bind",
  "std_db_sqlite_step",
  "std_db_sqlite_reset",
  "std_db_sqlite_finalize",
  "std_db_sqlite_cache_clear",
  "std_db_sqlite_acquire",
  "std_db_sqlite_release",
  "std_db_sqlite_idle",
  "std_db_sqlite",
  "sqlite3_open",
  "db_sqlite_open",
  "db_open_c"
};
static const char *const labi_std_fk_gate_sym_at_g11[2] = {
  "std_elf_parse",
  "elf_parse"
};
static const char *const labi_std_fk_gate_sym_at_g12[4] = {
  "std_dynlib_open",
  "std_dynlib_sym",
  "dynlib_open_c",
  "dynlib_open"
};
static const char *const labi_std_fk_gate_sym_at_g13[5] = {
  "std_http_get",
  "std_http_request",
  "std_http_client_new",
  "std_http_request_timeout_ms_for_ctx",
  "http_get_c"
};
struct labi_std_fk_gate_sym_at_row { const char *const *syms; int n; };
static const struct labi_std_fk_gate_sym_at_row labi_std_fk_gate_sym_at_rows[] = {
  { NULL, 0 },
  { labi_std_fk_gate_sym_at_g1, 28 },
  { labi_std_fk_gate_sym_at_g2, 16 },
  { labi_std_fk_gate_sym_at_g3, 5 },
  { labi_std_fk_gate_sym_at_g4, 3 },
  { labi_std_fk_gate_sym_at_g5, 5 },
  { labi_std_fk_gate_sym_at_g6, 32 },
  { labi_std_fk_gate_sym_at_g7, 19 },
  { labi_std_fk_gate_sym_at_g8, 2 },
  { labi_std_fk_gate_sym_at_g9, 60 },
  { labi_std_fk_gate_sym_at_g10, 33 },
  { labi_std_fk_gate_sym_at_g11, 2 },
  { labi_std_fk_gate_sym_at_g12, 4 },
  { labi_std_fk_gate_sym_at_g13, 5 }
};
const char *labi_std_fk_gate_sym_at(int fk, int i) {
  const struct labi_std_fk_gate_sym_at_row *row;
  if (fk < 0 || i < 0)
    return NULL;
  if ((unsigned)fk >= (unsigned)(sizeof(labi_std_fk_gate_sym_at_rows) / sizeof(labi_std_fk_gate_sym_at_rows[0])))
    return NULL;
  row = &labi_std_fk_gate_sym_at_rows[fk];
  if (!row->syms || i >= row->n)
    return NULL;
  return row->syms[i];
}

/* Class BF: table form of labi_od_kv_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_kv_sym_at_tab[14] = {
  "std_db_kv_mmap_available",
  "std_db_kv_open",
  "std_db_kv_close",
  "std_db_kv_append_ts",
  "std_db_kv_get",
  "std_db_kv_wal_flush",
  "std_db_kv_compact",
  "std_db_kv_sst_level_count",
  "std_db_kv_sync",
  "std_db_kv_put",
  "std_db_kv_compact_generation",
  "std_db_kv_wal_bytes",
  "db_kv_open_c",
  "db_kv_get_c"
};
const char *labi_od_kv_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_kv_sym_at_tab) / sizeof(labi_od_kv_sym_at_tab[0])))
    return NULL;
  return labi_od_kv_sym_at_tab[i];
}

/* Class BF: table form of labi_od_arrow_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_arrow_sym_at_tab[29] = {
  "std_db_arrow_adopt_f32_ptr_i32_i32",
  "std_db_arrow_sum",
  "std_db_arrow_dot",
  "std_db_arrow_free_ArrowColumn",
  "std_db_arrow_new_i32",
  "std_db_arrow_new_f32",
  "std_db_arrow_new_f64",
  "std_db_arrow_adopt_i32_ptr_i32_i32",
  "std_db_arrow_length_ArrowColumn",
  "std_db_arrow_length_ArrowBatch",
  "std_db_arrow_owned",
  "std_db_arrow_null_bitmap",
  "std_db_arrow_valid",
  "std_db_arrow_data_i32",
  "std_db_arrow_data_f32",
  "std_db_arrow_data_f64",
  "std_db_arrow_append_ArrowColumn_i32",
  "std_db_arrow_append_ArrowColumn_f32",
  "std_db_arrow_append_ArrowColumn_f64",
  "std_db_arrow_append_null",
  "std_db_arrow_batch",
  "std_db_arrow_add",
  "std_db_arrow_get",
  "std_db_arrow_free_ArrowBatch",
  "std_db_arrow_sum_valid_i32",
  "std_db_arrow_sum_valid_f32",
  "std_db_arrow_simd_hw_available",
  "arrow_column_i32_create_c",
  "arrow_column_adopt_f32_c"
};
const char *labi_od_arrow_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_arrow_sym_at_tab) / sizeof(labi_od_arrow_sym_at_tab[0])))
    return NULL;
  return labi_od_arrow_sym_at_tab[i];
}

/* Class BF: table form of labi_od_net_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_net_sym_at_tab[34] = {
  "std_net_listen",
  "std_net_connect",
  "std_net_udp_bind",
  "std_net_udp_recv_many_buf",
  "std_net_udp_send_many_buf",
  "std_net_addr_to_u32",
  "std_net_close_udp",
  "net_stream_write_batch_c",
  "net_tcp_connect_c",
  "net_tcp_listen_c",
  "net_udp_bind_c",
  "net_udp_recv_many_buf_c",
  "net_udp_send_many_buf_c",
  "net_close_socket_c",
  "net_udp_send_c",
  "net_dns_resolve_c",
  "net_sock_create_c",
  "std_net_resolve_ex",
  "std_net_resolve_err_host_not_found",
  "std_net_resolve_err_no_data",
  "std_net_close_stream",
  "std_net_connect_blocking",
  "std_net_write_batch",
  "std_net_tcp_pool_connect_count",
  "std_net_tcp_pool_destroy",
  "std_net_tcp_pool_drain",
  "std_net_tcp_pool_idle_count",
  "std_net_close_listener",
  "std_net_tcp_pool_new",
  "std_net_tcp_pool_smoke",
  "std_net_tcp_pool_acquire",
  "std_net_tcp_pool_release",
  "net_resolve_ipv4_ex_c",
  "net_resolve_ipv6_ex_c"
};
const char *labi_od_net_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_net_sym_at_tab) / sizeof(labi_od_net_sym_at_tab[0])))
    return NULL;
  return labi_od_net_sym_at_tab[i];
}

/* Class BF: table form of labi_od_vec_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_vec_sym_at_tab[44] = {
  "std_vec_push_Vec_u16_ptr_u16",
  "std_vec_push_Vec_i32_ptr_i32",
  "std_vec_push_Vec_u8_ptr_u8",
  "std_vec_get_Vec_u16_i32",
  "std_vec_length_Vec_u16",
  "std_vec_deinit_Vec_u16_ptr",
  "std_vec_get_Vec_i32_i32",
  "std_vec_length_Vec_i32",
  "std_vec_deinit_Vec_i32_ptr",
  "std_vec_from_slice_u8_ptr_i32",
  "std_vec_capacity_Vec_u8",
  "std_vec_clear_Vec_u8_ptr",
  "std_vec_pop_Vec_i32_ptr",
  "std_vec_pop_Vec_u8_ptr",
  "std_vec_extend_Vec_i32_ptr_i32_ptr_i32",
  "std_vec_extend_Vec_u8_ptr_u8_ptr_i32",
  "std_vec_extend_Vec_u64_ptr_u64_ptr_i32",
  "std_vec_extend_Vec_f64_ptr_f64_ptr_i32",
  "std_vec_from_slice_u64_ptr_i32",
  "std_vec_from_slice_f64_ptr_i32",
  "std_vec_push_Vec_u64_ptr_u64",
  "std_vec_push_Vec_f64_ptr_f64",
  "std_vec_length_Vec_u64",
  "std_vec_deinit_Vec_u64_ptr",
  "std_vec_length_Vec_f64",
  "std_vec_deinit_Vec_f64_ptr",
  "std_vec_get_Vec_u64_i32",
  "std_vec_get_Vec_f64_i32",
  "std_vec_vec3f_soa_push",
  "std_vec_vec3f_soa_deinit",
  "std_vec_vec3f_aos_push",
  "std_vec_vec3f_aos_deinit",
  "std_vec_vec3f_soa_sum_x",
  "std_vec_vec3f_soa_reserve_one",
  "std_vec_vec3f_soa_len",
  "std_vec_vec3f_soa_get_x",
  "std_vec_vec3f_soa_get_y",
  "std_vec_vec3f_soa_get_z",
  "std_vec_vec3f_soa_set",
  "std_vec_vec3f_soa_with_capacity",
  "std_vec_vec3f_aos_reserve_one",
  "std_vec_vec3f_aos_get_x",
  "std_vec_vec3f_aos_sum_x",
  "std_vec_vec3f_aos_with_capacity"
};
const char *labi_od_vec_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_vec_sym_at_tab) / sizeof(labi_od_vec_sym_at_tab[0])))
    return NULL;
  return labi_od_vec_sym_at_tab[i];
}

/* Class BF: table form of labi_od_set_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_set_sym_at_tab[20] = {
  "std_set_new_i32_retSet_i32",
  "std_set_new_i32_retSet_u64",
  "std_set_with_capacity_Set_i32_ptr_i32",
  "std_set_insert_Set_i32_ptr_i32",
  "std_set_insert_Set_u64_ptr_u64",
  "std_set_contains_key_Set_i32_i32",
  "std_set_contains_key_Set_u64_u64",
  "std_set_remove_Set_i32_ptr_i32",
  "std_set_remove_Set_u64_ptr_u64",
  "std_set_length_Set_i32",
  "std_set_length_Set_u64",
  "std_set_deinit_Set_i32_ptr",
  "std_set_deinit_Set_u64_ptr",
  "std_set_str_new",
  "std_set_str_insert",
  "std_set_set_i32_insert",
  "std_set_set_i32_contains",
  "std_set_set_i32_remove",
  "std_set_set_i32_len",
  "std_set_set_i32_deinit"
};
const char *labi_od_set_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_set_sym_at_tab) / sizeof(labi_od_set_sym_at_tab[0])))
    return NULL;
  return labi_od_set_sym_at_tab[i];
}

/* Class BF: table form of labi_od_map_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_map_sym_at_tab[15] = {
  "std_map_empty_size",
  "std_map_new_Map_i32_i32",
  "std_map_with_capacity_Map_i32_i32_ptr_i32",
  "std_map_insert_Map_i32_i32_ptr_i32_i32",
  "std_map_get_Map_i32_i32_i32",
  "std_map_find_Map_i32_i32_i32",
  "std_map_deinit_Map_i32_i32_ptr",
  "std_map_str_new",
  "std_map_str_insert",
  "std_map_new_u64",
  "std_map_with_capacity_Map_u64_i32_ptr_i32",
  "std_map_insert_Map_u64_i32_ptr_u64_i32",
  "std_map_get_Map_u64_i32_u64_i32",
  "std_map_remove_Map_u64_i32_ptr_u64",
  "std_map_deinit_Map_u64_i32_ptr"
};
const char *labi_od_map_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_map_sym_at_tab) / sizeof(labi_od_map_sym_at_tab[0])))
    return NULL;
  return labi_od_map_sym_at_tab[i];
}

/* Class BF: table form of labi_od_queue_api_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_queue_api_sym_at_tab[12] = {
  "std_queue_new_retQueue_i32",
  "std_queue_new_retQueue_u8",
  "std_queue_push_back_Queue_i32_ptr_i32",
  "std_queue_push_back_Queue_u8_ptr_u8",
  "std_queue_push_front",
  "std_queue_pop_front_Queue_i32_ptr",
  "std_queue_pop_back",
  "std_queue_get",
  "std_queue_length_Queue_i32",
  "std_queue_is_empty_Queue_i32",
  "std_queue_deinit_Queue_i32_ptr",
  "std_queue_with_capacity"
};
const char *labi_od_queue_api_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_queue_api_sym_at_tab) / sizeof(labi_od_queue_api_sym_at_tab[0])))
    return NULL;
  return labi_od_queue_api_sym_at_tab[i];
}

/* Class BF: table form of labi_od_test_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_test_sym_at_tab[28] = {
  "test_call_i32_void_c",
  "test_runner_",
  "test_expect_",
  "test_bench_",
  "test_f_test_",
  "test_io_",
  "test_fuzz_",
  "std_test_expect",
  "std_test_expect_eq_i32",
  "std_test_expect_ne_i32",
  "std_test_assert",
  "std_test_runner_case",
  "test_expect_c",
  "test_expect_eq_i32_c",
  "test_expect_eq_u32_c",
  "test_expect_ne_i32_c",
  "test_run_c",
  "test_bench_run_c",
  "test_bench_report_c",
  "test_fuzz_seed_c",
  "test_fuzz_next_c",
  "test_fuzz_run_c",
  "test_bench_run_noop_c",
  "test_fuzz_run_noop_c",
  "test_runner_reset_c",
  "test_runner_report_case_c",
  "test_runner_report_skip_c",
  "test_runner_finish_c"
};
const char *labi_od_test_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_test_sym_at_tab) / sizeof(labi_od_test_sym_at_tab[0])))
    return NULL;
  return labi_od_test_sym_at_tab[i];
}

/* Class BF: table form of labi_od_core_mem_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_core_mem_sym_at_tab[31] = {
  "core_mem_align_up",
  "core_mem_align_down",
  "core_mem_mem_copy",
  "core_mem_mem_set",
  "core_mem_mem_zero",
  "core_mem_mem_move",
  "core_mem_mem_compare",
  "core_mem_mem_swap",
  "core_mem_is_alignment_power_of_two",
  "core_mem_placeholder",
  "core_mem_align_of_i32",
  "core_mem_align_of_bool",
  "core_mem_align_of_u8",
  "core_mem_align_of_u32",
  "core_mem_align_of_u64",
  "core_mem_align_of_i64",
  "core_mem_align_of_usize",
  "core_mem_align_of_isize",
  "core_mem_align_of_f32",
  "core_mem_align_of_f64",
  "core_mem_align_of_pointer",
  "core_mem_volatile_load_u8",
  "core_mem_volatile_store_u8",
  "core_mem_volatile_load_u16",
  "core_mem_volatile_store_u16",
  "core_mem_volatile_load_u32",
  "core_mem_volatile_store_u32",
  "core_mem_compiler_fence",
  "core_mem_fence_acquire",
  "core_mem_fence_release",
  "core_mem_fence_seq_cst"
};
const char *labi_od_core_mem_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_core_mem_sym_at_tab) / sizeof(labi_od_core_mem_sym_at_tab[0])))
    return NULL;
  return labi_od_core_mem_sym_at_tab[i];
}

/* Class BF: table form of labi_od_sys_linux_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_sys_linux_sym_at_tab[38] = {
  "std_sys_linux_linux_syscall_nr_read_amd64",
  "std_sys_linux_linux_syscall_nr_write_amd64",
  "std_sys_linux_linux_syscall_nr_open_amd64",
  "std_sys_linux_linux_syscall_nr_close_amd64",
  "std_sys_linux_linux_syscall_nr_exit_amd64",
  "std_sys_linux_linux_syscall_nr_mmap_amd64",
  "std_sys_linux_linux_syscall_nr_read_arm64",
  "std_sys_linux_linux_syscall_nr_write_arm64",
  "std_sys_linux_linux_syscall_nr_openat_arm64",
  "std_sys_linux_linux_syscall_nr_close_arm64",
  "std_sys_linux_linux_syscall_nr_exit_arm64",
  "std_sys_linux_linux_syscall_nr_mmap_arm64",
  "std_sys_linux_linux_syscall_table_available",
  "std_sys_linux_linux_syscall_invoke_available",
  "std_sys_linux_linux_syscall_read",
  "std_sys_linux_linux_syscall_close",
  "std_sys_linux_linux_syscall_write",
  "std_sys_linux_linux_syscall_exit",
  "std_sys_linux_linux_syscall_openat",
  "std_sys_linux_linux_anonymous_mmap",
  "std_sys_linux_linux_syscall_munmap",
  "std_sys_linux_linux_read_file_openat",
  "std_sys_linux_linux_syscall_open",
  "std_sys_linux_linux_read_file_into",
  "std_sys_linux_linux_syscall_socket",
  "std_sys_linux_linux_syscall_connect",
  "std_sys_linux_linux_syscall_bind",
  "std_sys_linux_linux_syscall_listen",
  "std_sys_linux_linux_syscall_accept",
  "std_sys_linux_linux_mmap_rw",
  "std_sys_linux_linux_munmap",
  "std_sys_linux_linux_msync_sync",
  "std_sys_linux_linux_mmap_file_available",
  "std_sys_linux_linux_sys_module_anchor",
  "xlang_sys_close",
  "xlang_sys_openat",
  "xlang_sys_exit",
  "xlang_sys_connect"
};
const char *labi_od_sys_linux_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_sys_linux_sym_at_tab) / sizeof(labi_od_sys_linux_sym_at_tab[0])))
    return NULL;
  return labi_od_sys_linux_sym_at_tab[i];
}

/* Class BF: table form of labi_od_sys_macos_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_sys_macos_sym_at_tab[13] = {
  "std_sys_macos_macos_exit",
  "std_sys_macos_macos_write_available",
  "std_sys_macos_macos_write",
  "std_sys_macos_macos_write_stdout",
  "std_sys_macos_macos_write_stderr",
  "std_sys_macos_macos_read",
  "std_sys_macos_macos_close",
  "std_sys_macos_macos_read_file_into",
  "std_sys_macos_macos_anonymous_mmap",
  "std_sys_macos_macos_munmap",
  "std_sys_macos_macos_mmap_available",
  "std_sys_macos_macos_mmap_rw",
  "std_sys_macos_macos_msync_sync"
};
const char *labi_od_sys_macos_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_sys_macos_sym_at_tab) / sizeof(labi_od_sys_macos_sym_at_tab[0])))
    return NULL;
  return labi_od_sys_macos_sym_at_tab[i];
}

/* Class BF: table form of labi_od_heap_api_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_heap_api_sym_at_tab[32] = {
  "std_heap_alloc_i32",
  "std_heap_alloc_u8",
  "std_heap_free_i32",
  "std_heap_free_u8",
  "std_heap_alloc_size_zero",
  "std_heap_alloc_usize",
  "std_heap_free_u8_ptr",
  "std_heap_default_alloc",
  "std_heap_kind_arena",
  "std_heap_alloc_Allocator_usize",
  "std_heap_realloc_Allocator_u8_ptr_usize",
  "std_heap_free_Allocator_u8_ptr",
  "std_heap_arena64_alloc",
  "std_heap_libc_heap_arena64_alloc_c",
  "std_heap_libc_heap_alloc_c",
  "std_heap_libc_heap_free_c",
  "std_heap_libc_heap_alloc_aligned_c",
  "std_heap_libc_heap_alloc_i32_c",
  "std_heap_libc_heap_alloc_u8_c",
  "std_heap_libc_heap_alloc_u64_c",
  "std_heap_libc_heap_free_i32_c",
  "std_heap_libc_heap_free_u8_c",
  "std_heap_libc_heap_free_u64_c",
  "std_heap_map_find",
  "std_heap_libc_heap_copy_u8_at_c",
  "std_heap_trace_on",
  "std_heap_trace_reset",
  "std_heap_arena64_empty",
  "std_heap_arena64_init",
  "std_heap_arena64_deinit",
  "std_heap_mem_set",
  "std_heap_mem_compare"
};
const char *labi_od_heap_api_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_heap_api_sym_at_tab) / sizeof(labi_od_heap_api_sym_at_tab[0])))
    return NULL;
  return labi_od_heap_api_sym_at_tab[i];
}

/* Class BF: table form of labi_od_async_scheduler_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_async_scheduler_sym_at_tab[35] = {
  "xlang_async_coop_pingpong",
  "xlang_async_coop_pingpong_jmp",
  "xlang_async_cps_suspend",
  "xlang_async_asm_frame_phase_by_id",
  "xlang_async_asm_frame_store_from_ptr",
  "xlang_async_asm_frame_load_to_ptr",
  "xlang_async_asm_frame_reset_by_id",
  "xlang_async_cps_suspend_io",
  "xlang_async_run_i32",
  "xlang_async_task_submit",
  "xlang_async_task_submit_to",
  "xlang_async_scheduler_drain",
  "xlang_async_worker_drain",
  "xlang_async_worker_count",
  "xlang_async_worker_pending",
  "xlang_async_queue_reset",
  "xlang_async_scheduler_pending",
  "xlang_async_io_wake_all",
  "xlang_async_io_waiters_pending",
  "xlang_async_io_completions_ready",
  "xlang_async_run_seed_set_i32",
  "xlang_async_run_seed_reset",
  "xlang_async_run_seed_push_i32",
  "xlang_async_run_seed_push_u32",
  "xlang_async_run_seed_push_i64",
  "xlang_async_run_seed_valid",
  "xlang_async_run_seed_take_i32",
  "xlang_async_run_seed_take_u32",
  "xlang_async_run_seed_take_i64",
  "xlang_io_submit_read_async",
  "xlang_io_complete_read_async",
  "xlang_io_complete_read_async_slot",
  "xlang_io_submit_write_async",
  "xlang_io_complete_write_async",
  "xlang_io_complete_write_async_slot"
};
const char *labi_od_async_scheduler_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_async_scheduler_sym_at_tab) / sizeof(labi_od_async_scheduler_sym_at_tab[0])))
    return NULL;
  return labi_od_async_scheduler_sym_at_tab[i];
}

/* Class BF: table form of labi_od_zlib_undef_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_zlib_undef_sym_at_tab[22] = {
  "_compress2",
  "_deflate",
  "_inflate",
  "_uncompress",
  "compress2",
  "deflate",
  "inflate",
  "uncompress",
  "_deflateInit2",
  "_inflateInit2",
  "_std_compress_gzip_gzip_compress",
  "_std_compress_gzip_gzip_decompress",
  "deflateInit2",
  "inflateInit2",
  "std_compress_gzip_gzip_compress",
  "std_compress_gzip_gzip_decompress",
  "_std_compress_gzip_compress",
  "_std_compress_gzip_decompress",
  "std_compress_gzip_compress",
  "std_compress_gzip_decompress",
  "_std_compress_compress_init",
  "std_compress_compress_init"
};
const char *labi_od_zlib_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_zlib_undef_sym_at_tab) / sizeof(labi_od_zlib_undef_sym_at_tab[0])))
    return NULL;
  return labi_od_zlib_undef_sym_at_tab[i];
}

/* Class BF: table form of labi_od_zstd_undef_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_zstd_undef_sym_at_tab[12] = {
  "ZSTD_",
  "_ZSTD",
  "_std_compress_zstd_compress",
  "_std_compress_zstd_decompress",
  "std_compress_zstd_compress",
  "std_compress_zstd_decompress",
  "_std_compress_zstd_zstd_compress",
  "_std_compress_zstd_zstd_decompress",
  "std_compress_zstd_zstd_compress",
  "std_compress_zstd_zstd_decompress",
  "_std_compress_compress_init",
  "std_compress_compress_init"
};
const char *labi_od_zstd_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_zstd_undef_sym_at_tab) / sizeof(labi_od_zstd_undef_sym_at_tab[0])))
    return NULL;
  return labi_od_zstd_undef_sym_at_tab[i];
}

/* Class BF: table form of labi_od_brotli_undef_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_brotli_undef_sym_at_tab[12] = {
  "BrotliEncoderCompress",
  "BrotliDecoderDecompress",
  "_std_compress_brotli_compress",
  "_std_compress_brotli_decompress",
  "std_compress_brotli_compress",
  "std_compress_brotli_decompress",
  "_std_compress_brotli_brotli_compress",
  "_std_compress_brotli_brotli_decompress",
  "std_compress_brotli_brotli_compress",
  "std_compress_brotli_brotli_decompress",
  "_std_compress_compress_init",
  "std_compress_compress_init"
};
const char *labi_od_brotli_undef_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_brotli_undef_sym_at_tab) / sizeof(labi_od_brotli_undef_sym_at_tab[0])))
    return NULL;
  return labi_od_brotli_undef_sym_at_tab[i];
}

/* Class BF: table form of labi_od_runtime_time_os_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_runtime_time_os_sym_at_tab[10] = {
  "time_now_monotonic_ns_c",
  "time_now_wall_ns_c",
  "time_sleep_ns_c",
  "time_format_wall_rfc3339_c",
  "time_wall_local_offset_min_c",
  "std_time_now_monotonic_ns",
  "std_time_now_wall_ns",
  "std_time_sleep_ms",
  "std_time_timer_start",
  "std_time_duration_ns"
};
const char *labi_od_runtime_time_os_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_runtime_time_os_sym_at_tab) / sizeof(labi_od_runtime_time_os_sym_at_tab[0])))
    return NULL;
  return labi_od_runtime_time_os_sym_at_tab[i];
}

/* Class BF: table form of labi_od_runtime_random_fill_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_runtime_random_fill_sym_at_tab[12] = {
  "random_fill_bytes_c",
  "std_random_fill_bytes",
  "std_random_fill",
  "std_random_next",
  "std_random_range_u32_u32",
  "std_random_gen",
  "std_random_flip",
  "std_random_rng_smoke",
  "std_random_seed",
  "random_u32_c",
  "random_u64_c",
  "random_rng_smoke_c"
};
const char *labi_od_runtime_random_fill_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_runtime_random_fill_sym_at_tab) / sizeof(labi_od_runtime_random_fill_sym_at_tab[0])))
    return NULL;
  return labi_od_runtime_random_fill_sym_at_tab[i];
}

/* Class BF: table form of labi_od_runtime_env_os_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_runtime_env_os_sym_at_tab[19] = {
  "env_getenv_c",
  "env_getenv_exists_c",
  "env_getenv_z_c",
  "env_getenv_ptr_c",
  "env_setenv_c",
  "env_unsetenv_c",
  "env_temp_dir_c",
  "env_iter_count_c",
  "env_iter_at_c",
  "std_env_getenv",
  "std_env_getenv_exists",
  "std_env_getenv_z",
  "std_env_getenv_ptr",
  "std_env_setenv",
  "std_env_unsetenv",
  "std_env_temp_dir",
  "std_env_iter",
  "std_env_iter_count",
  "std_env_args_iter"
};
const char *labi_od_runtime_env_os_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_runtime_env_os_sym_at_tab) / sizeof(labi_od_runtime_env_os_sym_at_tab[0])))
    return NULL;
  return labi_od_runtime_env_os_sym_at_tab[i];
}

/* Class BF: table form of labi_od_std_task_sym_at. PLATFORM: SHARED. */
static const char *const labi_od_std_task_sym_at_tab[29] = {
  "std_task_new",
  "std_task_free",
  "std_task_bind",
  "std_task_spawn",
  "std_task_join",
  "std_task_pending",
  "std_task_check_leak",
  "std_task_cancel",
  "std_task_total",
  "std_task_set_new",
  "std_task_set_free",
  "std_task_set_spawn",
  "std_task_set_join",
  "std_task_set_check_leak",
  "std_task_echo",
  "std_task_echo_ptr",
  "std_task_retry",
  "std_task_err_ok",
  "task_group_create_c",
  "task_group_spawn_c",
  "task_group_join_c",
  "task_group_free_c",
  "join_set_create_c",
  "join_set_spawn_c",
  "join_set_join_c",
  "task_smoke_c",
  "task_supervise_retry_c",
  "task_echo_fn_c",
  "task_echo_fn_ptr_c"
};
const char *labi_od_std_task_sym_at(int i) {
  if (i < 0)
    return NULL;
  if ((unsigned)i >= (unsigned)(sizeof(labi_od_std_task_sym_at_tab) / sizeof(labi_od_std_task_sym_at_tab[0])))
    return NULL;
  return labi_od_std_task_sym_at_tab[i];
}
