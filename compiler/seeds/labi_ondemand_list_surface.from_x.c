/* seeds/labi_ondemand_list_surface.from_x.c
 * G-02f labi_ondemand_list R2 full surface — isomorphic with src/runtime/labi_ondemand_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_ondemand_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (on_demand tables + wave118–134 needs + wave135 fk0 + wave140 provides + wave145 link_needs + wave190 labi_std_fk_gate_sym_* + labi_std_fk_user_needs fk1–13 plan gates + wave197 append_on_demand_user_objs shell + helpers)
 * Cap residual: ensure/skip/path + freestanding_get + undef_sym / exports_marker / has_undef_sym / has_defined_sym probes in mega
 * Regen: ./shux_asm -E ... src/runtime/labi_ondemand_list.x | filter DBG + polish prologue
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
/* Cap residual: strstr used by fk0 pure orch (uint8_t* surface; no string.h conflict). */
extern uint8_t * strstr(uint8_t * hay, uint8_t * needle);
extern int32_t labi_od_simple_group_count(void);
extern int32_t labi_od_simple_group_sym_count(int32_t g);
extern uint8_t * labi_od_simple_group_sym_at(int32_t g, int32_t i);
extern uint8_t * labi_od_simple_group_rel(int32_t g);
extern int32_t labi_od_kv_sym_count(void);
extern uint8_t * labi_od_kv_sym_at(int32_t i);
extern uint8_t * labi_od_kv_rel(void);
extern uint8_t * labi_od_kv_glue_rel(void);
extern int32_t labi_od_arrow_sym_count(void);
extern uint8_t * labi_od_arrow_sym_at(int32_t i);
extern uint8_t * labi_od_arrow_rel(void);
extern uint8_t * labi_od_arrow_glue_rel(void);
extern int32_t labi_od_time_sym_count(void);
extern uint8_t * labi_od_time_sym_at(int32_t i);
extern uint8_t * labi_od_time_rel(void);
extern uint8_t * labi_od_time_os_rel(void);
extern int32_t labi_od_queue_sym_count(void);
extern uint8_t * labi_od_queue_sym_at(int32_t i);
extern uint8_t * labi_od_queue_rel(void);
extern uint8_t * labi_od_queue_contention_rel(void);
extern int32_t labi_od_net_sym_count(void);
extern uint8_t * labi_od_net_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_net(uint8_t * user_o);
extern int32_t labi_od_set_sym_count(void);
extern uint8_t * labi_od_set_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_set(uint8_t * user_o);
extern int32_t labi_od_map_sym_count(void);
extern uint8_t * labi_od_map_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_map(uint8_t * user_o);
extern int32_t labi_od_queue_api_sym_count(void);
extern uint8_t * labi_od_queue_api_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_queue(uint8_t * user_o);
extern int32_t labi_od_test_sym_count(void);
extern uint8_t * labi_od_test_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_test(uint8_t * user_o);
extern int32_t labi_od_core_mem_sym_count(void);
extern uint8_t * labi_od_core_mem_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_core_mem(uint8_t * user_o);
extern int32_t labi_od_core_slice_sym_count(void);
extern uint8_t * labi_od_core_slice_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_core_slice(uint8_t * user_o);
extern int32_t labi_od_page_mmap_sym_count(void);
extern uint8_t * labi_od_page_mmap_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_heap_page_mmap(uint8_t * user_o);
extern int32_t labi_od_sys_linux_sym_count(void);
extern uint8_t * labi_od_sys_linux_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_sys_linux(uint8_t * user_o);
extern int32_t labi_od_sys_sym_count(void);
extern uint8_t * labi_od_sys_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_sys(uint8_t * user_o);
extern int32_t labi_od_heap_api_sym_count(void);
extern uint8_t * labi_od_heap_api_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_std_heap_api(uint8_t * user_o);
extern int32_t labi_od_heap_user_sym_count(void);
extern uint8_t * labi_od_heap_user_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_heap_user_syms(uint8_t * user_o);
extern int32_t labi_od_async_scheduler_sym_count(void);
extern uint8_t * labi_od_async_scheduler_sym_at(int32_t i);
extern int32_t link_abi_user_o_needs_async_scheduler(uint8_t * user_o);
extern int32_t labi_od_zlib_undef_sym_count(void);
extern uint8_t * labi_od_zlib_undef_sym_at(int32_t i);
extern uint8_t * labi_od_compress_zlib_marker(void);
extern int32_t labi_od_zstd_undef_sym_count(void);
extern uint8_t * labi_od_zstd_undef_sym_at(int32_t i);
extern uint8_t * labi_od_compress_zstd_marker(void);
extern int32_t labi_od_brotli_undef_sym_count(void);
extern uint8_t * labi_od_brotli_undef_sym_at(int32_t i);
extern uint8_t * labi_od_compress_brotli_marker(void);
extern int32_t link_abi_obj_needs_zlib(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_zstd(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_brotli(uint8_t * obj_o);
extern int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o);
extern int32_t labi_od_runtime_time_os_sym_count(void);
extern uint8_t * labi_od_runtime_time_os_sym_at(int32_t i);
extern int32_t labi_user_needs_runtime_time_os(uint8_t * user_o);
extern int32_t labi_od_runtime_random_fill_sym_count(void);
extern uint8_t * labi_od_runtime_random_fill_sym_at(int32_t i);
extern int32_t labi_user_needs_runtime_random_fill(uint8_t * user_o);
extern int32_t labi_od_runtime_env_os_sym_count(void);
extern uint8_t * labi_od_runtime_env_os_sym_at(int32_t i);
extern int32_t labi_user_needs_runtime_env_os(uint8_t * user_o);
extern int32_t labi_od_runtime_process_argv_sym_count(void);
extern uint8_t * labi_od_runtime_process_argv_sym_at(int32_t i);
extern int32_t labi_user_needs_runtime_process_argv(uint8_t * user_o);
extern int32_t labi_od_std_task_sym_count(void);
extern uint8_t * labi_od_std_task_sym_at(int32_t i);
extern int32_t labi_user_needs_std_task(uint8_t * user_o);
extern int32_t labi_fk0_rel_count(void);
extern uint8_t * labi_fk0_rel_at(int32_t k);
extern int32_t labi_fk0_sym_count(int32_t k);
extern uint8_t * labi_fk0_sym_at(int32_t k, int32_t i);
extern int32_t labi_std_fk0_user_needs_rel(uint8_t * user_o, uint8_t * rel);
extern int32_t labi_std_fk_gate_sym_count(int32_t fk);
extern uint8_t * labi_std_fk_gate_sym_at(int32_t fk, int32_t i);
extern int32_t labi_std_fk_user_needs(uint8_t * user_o, int32_t fk);
extern uint8_t * labi_od_rel_net(void);
extern uint8_t * labi_od_rel_thread(void);
extern uint8_t * labi_od_rel_heap(void);
extern uint8_t * labi_od_rel_set(void);
extern uint8_t * labi_od_rel_map(void);
extern uint8_t * labi_od_rel_async_scheduler(void);
extern uint8_t * labi_od_rel_core_mem(void);
extern uint8_t * labi_od_rel_sys_linux(void);
extern uint8_t * labi_od_rel_page_mmap(void);
extern uint8_t * labi_od_rel_sys(void);
extern uint8_t * labi_od_rel_core_slice(void);
extern uint8_t * labi_od_rel_test(void);
extern uint8_t * labi_od_rel_heap_user(void);
extern uint8_t * labi_od_rel_scheduler_glue(void);
extern uint8_t * labi_od_rel_thread_glue(void);
extern uint8_t * labi_od_rel_net_udp_batch(void);
extern uint8_t * labi_od_rel_net_workers(void);
extern uint8_t * labi_od_rel_test_fn_invoke(void);
extern int32_t labi_od_provides_core_mem_sym_count(void);
extern uint8_t * labi_od_provides_core_mem_sym_at(int32_t i);
extern int32_t link_abi_user_o_provides_core_mem(uint8_t * user_o);
extern int32_t labi_od_provides_std_heap_sym_count(void);
extern uint8_t * labi_od_provides_std_heap_sym_at(int32_t i);
extern int32_t link_abi_user_o_provides_std_heap(uint8_t * user_o);
extern int32_t link_abi_link_needs_heap_user_c(uint8_t * user_o, uint8_t * * argv, int32_t la);
extern int32_t link_abi_link_needs_std_heap_import(uint8_t * user_o, uint8_t * * argv, int32_t la);
extern int32_t shux_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
extern int32_t shux_link_obj_has_defined_sym(uint8_t * o_path, uint8_t * sym);
extern int32_t link_abi_obj_exports_marker(uint8_t * obj_o, uint8_t * marker);
extern int32_t link_abi_obj_has_undef_sym(uint8_t * obj_o, uint8_t * sym);

/* wave197 Cap residual / peer pure externs for on_demand shell surface */
extern int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t * flag_out);
extern void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * p);
extern uint8_t * shux_asm_ld_try_under_lib_roots(uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * shux_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
extern uint8_t * shux_repo_root_from_argv0(uint8_t * argv0);
extern int32_t shux_ensure_formal_std_make_o(uint8_t * repo_root, uint8_t * rel_from_repo, uint8_t * make_target);
extern int32_t driver_freestanding_get(void);
extern int32_t shux_ensure_runtime_thread_glue_o(uint8_t * argv0);
extern uint8_t * shux_runtime_thread_glue_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_net_udp_batch_o(uint8_t * argv0);
extern uint8_t * shux_runtime_net_udp_batch_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_net_workers_o(uint8_t * argv0);
extern uint8_t * shux_runtime_net_workers_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_test_fn_invoke_o(uint8_t * argv0);
extern uint8_t * shux_runtime_test_fn_invoke_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_heap_user_o(uint8_t * argv0);
extern uint8_t * shux_runtime_heap_user_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_process_argv_o(uint8_t * argv0);
extern uint8_t * shux_runtime_process_argv_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_time_os_o(uint8_t * argv0);
extern uint8_t * shux_runtime_time_os_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_queue_contention_o(uint8_t * argv0);
extern uint8_t * shux_runtime_queue_contention_o_path(uint8_t * argv0);
extern uint8_t * shux_std_async_scheduler_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_scheduler_glue_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_kv_mmap_glue_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_arrow_simd_glue_o_path(uint8_t * argv0);
int32_t labi_od_simple_group_count(void) {
  return 10;
}
int32_t labi_od_simple_group_sym_count(int32_t g) {
  if ((g < 0)) {
    return 0;
  }
  if ((g ==0)) {
    return 9;
  }
  if ((g ==1)) {
    return 2;
  }
  if ((g ==2)) {
    return 6;
  }
  if ((g ==3)) {
    return 4;
  }
  if ((g ==4)) {
    return 3;
  }
  if ((g ==5)) {
    return 3;
  }
  if ((g ==6)) {
    return 4;
  }
  if ((g ==7)) {
    return 4;
  }
  if ((g ==8)) {
    return 6;
  }
  if ((g ==9)) {
    return 10;
  }
  return 0;
}
uint8_t * labi_od_simple_group_sym_at(int32_t g, int32_t i) {
  if ((g < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((g ==0)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x63\x6f\x70\x79\x5f\x63");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x63\x6d\x70\x5f\x63");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x63\x68\x72\x5f\x63");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x6d\x65\x6d\x5f\x63");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x72\x63\x68\x72\x5f\x63");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6e\x65\x77");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x66\x72\x6f\x6d\x5f\x73\x6c\x69\x63\x65");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x76\x69\x65\x77");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6c\x65\x6e");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==1)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x74\x79\x70\x65\x73\x5f\x73\x69\x7a\x65\x5f\x6f\x66\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x74\x79\x70\x65\x73\x5f\x70\x6c\x61\x63\x65\x68\x6f\x6c\x64\x65\x72");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==2)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x75\x74\x66\x38\x5f\x76\x61\x6c\x69\x64\x5f\x63");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x68\x65\x78\x5f\x65\x6e\x63\x6f\x64\x65\x5f\x63");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x61\x73\x63\x69\x69\x5f\x69\x73\x5f\x61\x6c\x70\x68\x61\x5f\x63");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x75\x74\x66\x38\x5f\x76\x61\x6c\x69\x64");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x75\x74\x66\x38\x5f\x64\x65\x63\x6f\x64\x65\x5f\x72\x75\x6e\x65");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x61\x73\x63\x69\x69\x5f\x69\x73\x5f\x61\x6c\x70\x68\x61");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==3)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x62\x61\x73\x65\x36\x34\x5f\x65\x6e\x63\x6f\x64\x65\x5f\x73\x74\x61\x6e\x64\x61\x72\x64\x5f\x63");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x73\x65\x36\x34\x5f\x65\x6e\x63\x6f\x64\x65\x5f\x73\x74\x61\x6e\x64\x61\x72\x64");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x73\x65\x36\x34\x5f\x64\x65\x63\x6f\x64\x65\x5f\x73\x74\x61\x6e\x64\x61\x72\x64");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x73\x65\x36\x34\x5f\x65\x6e\x63\x6f\x64\x65\x5f\x75\x72\x6c");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==4)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x73\x76\x5f\x6e\x65\x78\x74\x5f\x66\x69\x65\x6c\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x73\x76\x5f\x65\x73\x63\x61\x70\x65");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x73\x76\x5f\x63\x73\x76\x5f\x74\x65\x73\x74\x5f\x71\x75\x6f\x74\x65\x64\x5f\x66\x69\x72\x73\x74");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==5)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x63\x68\x65\x6d\x61\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x63\x68\x65\x6d\x61\x5f\x64\x65\x63\x6f\x64\x65\x5f\x6a\x73\x6f\x6e\x5f\x63");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x63\x68\x65\x6d\x61\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==6)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6f\x70\x74\x69\x6f\x6e\x5f\x73\x6f\x6d\x65\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6f\x70\x74\x69\x6f\x6e\x5f\x75\x6e\x77\x72\x61\x70\x5f\x6f\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6f\x70\x74\x69\x6f\x6e\x5f\x6e\x6f\x6e\x65\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6f\x70\x74\x69\x6f\x6e\x5f\x69\x73\x5f\x73\x6f\x6d\x65\x5f\x69\x33\x32");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==7)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x72\x65\x73\x75\x6c\x74\x5f\x6f\x6b\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x72\x65\x73\x75\x6c\x74\x5f\x69\x73\x5f\x6f\x6b\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x72\x65\x73\x75\x6c\x74\x5f\x65\x72\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x72\x65\x73\x75\x6c\x74\x5f\x6f\x6b");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==8)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74\x5f\x65\x71\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74\x5f\x65\x71\x5f\x75\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74\x5f\x65\x71\x5f\x75\x36\x34");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74\x5f\x6e\x65\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x64\x65\x62\x75\x67\x5f\x64\x65\x62\x75\x67\x5f\x61\x73\x73\x65\x72\x74");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((g ==9)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x6c\x65\x6e\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x67\x65\x74\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x67\x65\x74\x5f\x69\x33\x32\x5f\x75\x6e\x63\x68\x65\x63\x6b\x65\x64");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x6c\x65\x6e\x5f\x75\x38");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x67\x65\x74\x5f\x75\x38");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x67\x65\x74\x5f\x75\x38\x5f\x75\x6e\x63\x68\x65\x63\x6b\x65\x64");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x38");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x6c\x65\x6e\x5f\x75\x36\x34");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x67\x65\x74\x5f\x75\x36\x34");
      return p;
    }
    return ((uint8_t *)(0));
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_simple_group_rel(int32_t g) {
  if ((g < 0)) {
    return ((uint8_t *)(0));
  }
  if ((g ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x74\x72\x69\x6e\x67\x2f\x73\x74\x72\x69\x6e\x67\x2e\x6f");
    return p;
  }
  if ((g ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x74\x79\x70\x65\x73\x2f\x74\x79\x70\x65\x73\x2e\x6f");
    return p;
  }
  if ((g ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x2f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x2e\x6f");
    return p;
  }
  if ((g ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x62\x61\x73\x65\x36\x34\x2f\x62\x61\x73\x65\x36\x34\x2e\x6f");
    return p;
  }
  if ((g ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x63\x73\x76\x2f\x63\x73\x76\x2e\x6f");
    return p;
  }
  if ((g ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x63\x68\x65\x6d\x61\x2f\x73\x63\x68\x65\x6d\x61\x2e\x6f");
    return p;
  }
  if ((g ==6)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6f\x70\x74\x69\x6f\x6e\x2f\x6f\x70\x74\x69\x6f\x6e\x2e\x6f");
    return p;
  }
  if ((g ==7)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x72\x65\x73\x75\x6c\x74\x2f\x72\x65\x73\x75\x6c\x74\x2e\x6f");
    return p;
  }
  if ((g ==8)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x64\x65\x62\x75\x67\x2f\x64\x65\x62\x75\x67\x2e\x6f");
    return p;
  }
  if ((g ==9)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x6d\x6f\x64\x2e\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_od_kv_sym_count(void) {
  return 2;
}
uint8_t * labi_od_kv_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x6f\x70\x65\x6e\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x67\x65\x74\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_kv_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x64\x62\x2f\x6b\x76\x2f\x6b\x76\x2e\x6f");
  return p;
}
uint8_t * labi_od_kv_glue_rel(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6b\x76\x5f\x6d\x6d\x61\x70\x5f\x67\x6c\x75\x65\x2e\x6f");
  return p;
}
int32_t labi_od_arrow_sym_count(void) {
  return 2;
}
uint8_t * labi_od_arrow_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x63\x6f\x6c\x75\x6d\x6e\x5f\x69\x33\x32\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x63\x6f\x6c\x75\x6d\x6e\x5f\x61\x64\x6f\x70\x74\x5f\x66\x33\x32\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_arrow_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x64\x62\x2f\x61\x72\x72\x6f\x77\x2f\x61\x72\x72\x6f\x77\x2e\x6f");
  return p;
}
uint8_t * labi_od_arrow_glue_rel(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x72\x72\x6f\x77\x5f\x73\x69\x6d\x64\x5f\x67\x6c\x75\x65\x2e\x6f");
  return p;
}
int32_t labi_od_time_sym_count(void) {
  return 4;
}
uint8_t * labi_od_time_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x72\x5f\x73\x74\x61\x72\x74");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_time_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x74\x69\x6d\x65\x2f\x74\x69\x6d\x65\x2e\x6f");
  return p;
}
uint8_t * labi_od_time_os_rel(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x5f\x6f\x73\x2e\x6f");
  return p;
}
int32_t labi_od_queue_sym_count(void) {
  return 3;
}
uint8_t * labi_od_queue_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x79\x6e\x63\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x71\x75\x65\x75\x65\x5f\x6f\x73\x5f\x72\x75\x6e\x5f\x74\x77\x6f\x5f\x77\x6f\x72\x6b\x65\x72\x73\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x70\x75\x73\x68\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_queue_rel(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x71\x75\x65\x75\x65\x2f\x71\x75\x65\x75\x65\x2e\x6f");
  return p;
}
uint8_t * labi_od_queue_contention_rel(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x2e\x6f");
  return p;
}
int32_t labi_od_net_sym_count(void) {
  return 17;
}
uint8_t * labi_od_net_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x6c\x69\x73\x74\x65\x6e");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x63\x6f\x6e\x6e\x65\x63\x74");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x69\x6e\x64");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x72\x65\x63\x76\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x61\x64\x64\x72\x5f\x74\x6f\x5f\x75\x33\x32");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x63\x6c\x6f\x73\x65\x5f\x75\x64\x70");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x73\x74\x72\x65\x61\x6d\x5f\x77\x72\x69\x74\x65\x5f\x62\x61\x74\x63\x68\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x74\x63\x70\x5f\x63\x6f\x6e\x6e\x65\x63\x74\x5f\x63");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x74\x63\x70\x5f\x6c\x69\x73\x74\x65\x6e\x5f\x63");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x69\x6e\x64\x5f\x63");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x72\x65\x63\x76\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66\x5f\x63");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66\x5f\x63");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x63\x6c\x6f\x73\x65\x5f\x73\x6f\x63\x6b\x65\x74\x5f\x63");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x63");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x64\x6e\x73\x5f\x72\x65\x73\x6f\x6c\x76\x65\x5f\x63");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x6e\x65\x74\x5f\x73\x6f\x63\x6b\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_net(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_net_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_net_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_set_sym_count(void) {
  return 20;
}
uint8_t * labi_od_set_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6e\x65\x77\x5f\x69\x33\x32\x5f\x72\x65\x74\x53\x65\x74\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6e\x65\x77\x5f\x69\x33\x32\x5f\x72\x65\x74\x53\x65\x74\x5f\x75\x36\x34");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x69\x6e\x73\x65\x72\x74\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x69\x6e\x73\x65\x72\x74\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72\x5f\x75\x36\x34");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73\x5f\x6b\x65\x79\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73\x5f\x6b\x65\x79\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x75\x36\x34");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x72\x65\x6d\x6f\x76\x65\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x72\x65\x6d\x6f\x76\x65\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72\x5f\x75\x36\x34");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6c\x65\x6e\x5f\x53\x65\x74\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6c\x65\x6e\x5f\x53\x65\x74\x5f\x75\x36\x34");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x64\x65\x69\x6e\x69\x74\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x64\x65\x69\x6e\x69\x74\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x74\x72\x5f\x6e\x65\x77");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x74\x72\x5f\x69\x6e\x73\x65\x72\x74");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x69\x6e\x73\x65\x72\x74");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x72\x65\x6d\x6f\x76\x65");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x6c\x65\x6e");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x64\x65\x69\x6e\x69\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_set(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_set_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_set_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_map_sym_count(void) {
  return 9;
}
uint8_t * labi_od_map_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x65\x6d\x70\x74\x79\x5f\x73\x69\x7a\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x6e\x65\x77\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x69\x6e\x73\x65\x72\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x67\x65\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x66\x69\x6e\x64\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x64\x65\x69\x6e\x69\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x73\x74\x72\x5f\x6e\x65\x77");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x73\x74\x72\x5f\x69\x6e\x73\x65\x72\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_map(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_map_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_map_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_queue_api_sym_count(void) {
  return 12;
}
uint8_t * labi_od_queue_api_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6e\x65\x77\x5f\x72\x65\x74\x51\x75\x65\x75\x65\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6e\x65\x77\x5f\x72\x65\x74\x51\x75\x65\x75\x65\x5f\x75\x38");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x62\x61\x63\x6b\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x62\x61\x63\x6b\x5f\x51\x75\x65\x75\x65\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x38");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x66\x72\x6f\x6e\x74");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x6f\x70\x5f\x66\x72\x6f\x6e\x74\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x6f\x70\x5f\x62\x61\x63\x6b");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x67\x65\x74");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6c\x65\x6e\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x69\x73\x5f\x65\x6d\x70\x74\x79\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x64\x65\x69\x6e\x69\x74\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_queue(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_queue_api_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_queue_api_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_test_sym_count(void) {
  return 7;
}
uint8_t * labi_od_test_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x63\x61\x6c\x6c\x5f\x69\x33\x32\x5f\x76\x6f\x69\x64\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x72\x75\x6e\x6e\x65\x72\x5f");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x65\x78\x70\x65\x63\x74\x5f");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x62\x65\x6e\x63\x68\x5f");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x66\x5f\x74\x65\x73\x74\x5f");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x69\x6f\x5f");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x74\x65\x73\x74\x5f\x66\x75\x7a\x7a\x5f");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_test(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_test_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_test_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_core_mem_sym_count(void) {
  return 7;
}
uint8_t * labi_od_core_mem_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x61\x6c\x69\x67\x6e\x5f\x75\x70");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x61\x6c\x69\x67\x6e\x5f\x64\x6f\x77\x6e");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x70\x79");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x73\x65\x74");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x7a\x65\x72\x6f");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x6d\x6f\x76\x65");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x6d\x70\x61\x72\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_core_mem(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_core_mem_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_core_mem_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_core_slice_sym_count(void) {
  return 6;
}
uint8_t * labi_od_core_slice_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_core_slice(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_core_slice_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_core_slice_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_page_mmap_sym_count(void) {
  return 5;
}
uint8_t * labi_od_page_mmap_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x69\x6e\x69\x74");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x64\x65\x69\x6e\x69\x74");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_heap_page_mmap(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_page_mmap_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_page_mmap_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_sys_linux_sym_count(void) {
  return 7;
}
uint8_t * labi_od_sys_linux_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x69\x6e\x76\x6f\x6b\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x61\x6e\x6f\x6e\x79\x6d\x6f\x75\x73\x5f\x6d\x6d\x61\x70");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x6d\x75\x6e\x6d\x61\x70");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x72\x65\x61\x64");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x77\x72\x69\x74\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x63\x6c\x6f\x73\x65");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x65\x78\x69\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_sys_linux(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_sys_linux_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_sys_linux_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_sys_sym_count(void) {
  return 8;
}
uint8_t * labi_od_sys_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65\x5f\x73\x74\x64\x6f\x75\x74");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65\x5f\x73\x74\x64\x65\x72\x72");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x72\x65\x61\x64");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x63\x6c\x6f\x73\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x65\x78\x69\x74");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x77\x72\x69\x74\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x74\x61\x62\x6c\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_sys(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_sys_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_sys_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_heap_api_sym_count(void) {
  return 25;
}
uint8_t * labi_od_heap_api_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x38");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x73\x69\x7a\x65\x5f\x7a\x65\x72\x6f");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x73\x69\x7a\x65");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x64\x65\x66\x61\x75\x6c\x74\x5f\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6b\x69\x6e\x64\x5f\x61\x72\x65\x6e\x61");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x73\x69\x7a\x65");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x73\x69\x7a\x65");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x38\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x61\x6c\x69\x67\x6e\x65\x64\x5f\x63");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x69\x33\x32\x5f\x63");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x38\x5f\x63");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x69\x33\x32\x5f\x63");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38\x5f\x63");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6d\x61\x70\x5f\x66\x69\x6e\x64");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x63\x6f\x70\x79\x5f\x75\x38\x5f\x61\x74\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_std_heap_api(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_heap_api_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_heap_api_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_heap_user_sym_count(void) {
  return 7;
}
uint8_t * labi_od_heap_user_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x5f\x69\x6e\x69\x74\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x64\x65\x69\x6e\x69\x74\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x69\x6e\x69\x74\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_heap_user_syms(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_heap_user_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_heap_user_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_async_scheduler_sym_count(void) {
  return 35;
}
uint8_t * labi_od_async_scheduler_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67\x5f\x6a\x6d\x70");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x70\x68\x61\x73\x65\x5f\x62\x79\x5f\x69\x64");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x73\x74\x6f\x72\x65\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x6c\x6f\x61\x64\x5f\x74\x6f\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x72\x65\x73\x65\x74\x5f\x62\x79\x5f\x69\x64");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64\x5f\x69\x6f");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74\x5f\x74\x6f");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x64\x72\x61\x69\x6e");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x64\x72\x61\x69\x6e");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x63\x6f\x75\x6e\x74");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x70\x65\x6e\x64\x69\x6e\x67");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x71\x75\x65\x75\x65\x5f\x72\x65\x73\x65\x74");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x70\x65\x6e\x64\x69\x6e\x67");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x77\x61\x6b\x65\x5f\x61\x6c\x6c");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x77\x61\x69\x74\x65\x72\x73\x5f\x70\x65\x6e\x64\x69\x6e\x67");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x69\x6f\x6e\x73\x5f\x72\x65\x61\x64\x79");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x73\x65\x74\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x72\x65\x73\x65\x74");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x75\x33\x32");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x69\x36\x34");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x76\x61\x6c\x69\x64");
    return p;
  }
  if ((i ==26)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x33\x32");
    return p;
  }
  if ((i ==27)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x75\x33\x32");
    return p;
  }
  if ((i ==28)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x36\x34");
    return p;
  }
  if ((i ==29)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x73\x75\x62\x6d\x69\x74\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63");
    return p;
  }
  if ((i ==30)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63");
    return p;
  }
  if ((i ==31)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63\x5f\x73\x6c\x6f\x74");
    return p;
  }
  if ((i ==32)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x73\x75\x62\x6d\x69\x74\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63");
    return p;
  }
  if ((i ==33)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63");
    return p;
  }
  if ((i ==34)) {
    uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63\x5f\x73\x6c\x6f\x74");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_needs_async_scheduler(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_async_scheduler_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_async_scheduler_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_zlib_undef_sym_count(void) {
  return 4;
}
uint8_t * labi_od_zlib_undef_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x32");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5f\x64\x65\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x5f\x69\x6e\x66\x6c\x61\x74\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x5f\x75\x6e\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_zlib_marker(void) {
  uint8_t * p = ((uint8_t *)"\x73\x68\x75\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x6d\x61\x72\x6b\x65\x72");
  return p;
}
int32_t labi_od_zstd_undef_sym_count(void) {
  return 2;
}
uint8_t * labi_od_zstd_undef_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x5a\x53\x54\x44\x5f");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x5f\x5a\x53\x54\x44");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_zstd_marker(void) {
  uint8_t * p = ((uint8_t *)"\x73\x68\x75\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x73\x74\x64\x5f\x6d\x61\x72\x6b\x65\x72");
  return p;
}
int32_t labi_od_brotli_undef_sym_count(void) {
  return 2;
}
uint8_t * labi_od_brotli_undef_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x45\x6e\x63\x6f\x64\x65\x72\x43\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x44\x65\x63\x6f\x64\x65\x72\x44\x65\x63\x6f\x6d\x70\x72\x65\x73\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_brotli_marker(void) {
  uint8_t * p = ((uint8_t *)"\x73\x68\x75\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x62\x72\x6f\x74\x6c\x69\x5f\x6d\x61\x72\x6b\x65\x72");
  return p;
}
int32_t link_abi_obj_needs_zlib(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  uint8_t * marker = labi_od_compress_zlib_marker();
  if ((marker !=0)) {
    if (((marker)[0] !=0)) {
      int32_t mhit = 0;
      (void)((mhit = link_abi_obj_exports_marker(obj_o, marker)));
      if ((mhit !=0)) {
        return 1;
      }
    }
  }
  int32_t n = labi_od_zlib_undef_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_zlib_undef_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_obj_has_undef_sym(obj_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_obj_needs_zstd(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  uint8_t * marker = labi_od_compress_zstd_marker();
  if ((marker !=0)) {
    if (((marker)[0] !=0)) {
      int32_t mhit = 0;
      (void)((mhit = link_abi_obj_exports_marker(obj_o, marker)));
      if ((mhit !=0)) {
        return 1;
      }
    }
  }
  int32_t n = labi_od_zstd_undef_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_zstd_undef_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_obj_has_undef_sym(obj_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_obj_needs_brotli(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  uint8_t * marker = labi_od_compress_brotli_marker();
  if ((marker !=0)) {
    if (((marker)[0] !=0)) {
      int32_t mhit = 0;
      (void)((mhit = link_abi_obj_exports_marker(obj_o, marker)));
      if ((mhit !=0)) {
        return 1;
      }
    }
  }
  int32_t n = labi_od_brotli_undef_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_brotli_undef_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = link_abi_obj_has_undef_sym(obj_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o) {
  if ((link_abi_obj_needs_zlib(user_o) !=0)) {
    return 1;
  }
  if ((link_abi_obj_needs_zstd(user_o) !=0)) {
    return 1;
  }
  if ((link_abi_obj_needs_brotli(user_o) !=0)) {
    return 1;
  }
  return 0;
}
int32_t labi_od_runtime_time_os_sym_count(void) {
  return 10;
}
uint8_t * labi_od_runtime_time_os_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6e\x73\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x77\x61\x6c\x6c\x5f\x72\x66\x63\x33\x33\x33\x39\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x77\x61\x6c\x6c\x5f\x6c\x6f\x63\x61\x6c\x5f\x6f\x66\x66\x73\x65\x74\x5f\x6d\x69\x6e\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x72\x5f\x73\x74\x61\x72\x74");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_user_needs_runtime_time_os(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_od_runtime_time_os_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_runtime_time_os_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_runtime_random_fill_sym_count(void) {
  return 12;
}
uint8_t * labi_od_runtime_random_fill_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x6e\x65\x78\x74");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x61\x6e\x67\x65\x5f\x75\x33\x32\x5f\x75\x33\x32");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x67\x65\x6e");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x6c\x69\x70");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x73\x65\x65\x64");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x33\x32\x5f\x63");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x36\x34\x5f\x63");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_user_needs_runtime_random_fill(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_od_runtime_random_fill_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_runtime_random_fill_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_runtime_env_os_sym_count(void) {
  return 19;
}
uint8_t * labi_od_runtime_env_os_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x65\x78\x69\x73\x74\x73\x5f\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x7a\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x73\x65\x74\x65\x6e\x76\x5f\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x75\x6e\x73\x65\x74\x65\x6e\x76\x5f\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x74\x65\x6d\x70\x5f\x64\x69\x72\x5f\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x69\x74\x65\x72\x5f\x63\x6f\x75\x6e\x74\x5f\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x65\x6e\x76\x5f\x69\x74\x65\x72\x5f\x61\x74\x5f\x63");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x65\x78\x69\x73\x74\x73");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x7a");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x73\x65\x74\x65\x6e\x76");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x75\x6e\x73\x65\x74\x65\x6e\x76");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x74\x65\x6d\x70\x5f\x64\x69\x72");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x69\x74\x65\x72");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x69\x74\x65\x72\x5f\x63\x6f\x75\x6e\x74");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x61\x72\x67\x73\x5f\x69\x74\x65\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_user_needs_runtime_env_os(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_od_runtime_env_os_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_runtime_env_os_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_runtime_process_argv_sym_count(void) {
  return 9;
}
uint8_t * labi_od_runtime_process_argv_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x73\x68\x75\x78\x5f\x61\x72\x67\x63\x5f\x67\x65\x74");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x73\x68\x75\x78\x5f\x61\x72\x67\x76\x5f\x67\x65\x74");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x5f\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x73\x5f\x63\x6f\x75\x6e\x74\x5f\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x73");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x61\x72\x67\x73\x5f\x69\x74\x65\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_user_needs_runtime_process_argv(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_od_runtime_process_argv_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_runtime_process_argv_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_std_task_sym_count(void) {
  return 29;
}
uint8_t * labi_od_std_task_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x6e\x65\x77");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x66\x72\x65\x65");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x62\x69\x6e\x64");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x70\x61\x77\x6e");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x6a\x6f\x69\x6e");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x70\x65\x6e\x64\x69\x6e\x67");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x63\x68\x65\x63\x6b\x5f\x6c\x65\x61\x6b");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x63\x61\x6e\x63\x65\x6c");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x74\x6f\x74\x61\x6c");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x65\x74\x5f\x6e\x65\x77");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x65\x74\x5f\x66\x72\x65\x65");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x65\x74\x5f\x73\x70\x61\x77\x6e");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x65\x74\x5f\x6a\x6f\x69\x6e");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x73\x65\x74\x5f\x63\x68\x65\x63\x6b\x5f\x6c\x65\x61\x6b");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x65\x63\x68\x6f");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x65\x63\x68\x6f\x5f\x70\x74\x72");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x72\x65\x74\x72\x79");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x61\x73\x6b\x5f\x65\x72\x72\x5f\x6f\x6b");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x67\x72\x6f\x75\x70\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x67\x72\x6f\x75\x70\x5f\x73\x70\x61\x77\x6e\x5f\x63");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x67\x72\x6f\x75\x70\x5f\x6a\x6f\x69\x6e\x5f\x63");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x67\x72\x6f\x75\x70\x5f\x66\x72\x65\x65\x5f\x63");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x6a\x6f\x69\x6e\x5f\x73\x65\x74\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x6a\x6f\x69\x6e\x5f\x73\x65\x74\x5f\x73\x70\x61\x77\x6e\x5f\x63");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x6a\x6f\x69\x6e\x5f\x73\x65\x74\x5f\x6a\x6f\x69\x6e\x5f\x63");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
    return p;
  }
  if ((i ==26)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x73\x75\x70\x65\x72\x76\x69\x73\x65\x5f\x72\x65\x74\x72\x79\x5f\x63");
    return p;
  }
  if ((i ==27)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x65\x63\x68\x6f\x5f\x66\x6e\x5f\x63");
    return p;
  }
  if ((i ==28)) {
    uint8_t * p = ((uint8_t *)"\x74\x61\x73\x6b\x5f\x65\x63\x68\x6f\x5f\x66\x6e\x5f\x70\x74\x72\x5f\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_user_needs_std_task(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_od_std_task_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_std_task_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_fk0_rel_count(void) {
  return 16;
}
uint8_t * labi_fk0_rel_at(int32_t k) {
  if ((k ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x74\x72\x69\x6e\x67\x2f\x73\x74\x72\x69\x6e\x67\x2e\x6f");
    return p;
  }
  if ((k ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x2f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x2e\x6f");
    return p;
  }
  if ((k ==2)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x62\x61\x73\x65\x36\x34\x2f\x62\x61\x73\x65\x36\x34\x2e\x6f");
    return p;
  }
  if ((k ==3)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x68\x74\x74\x70\x2f\x68\x74\x74\x70\x2e\x6f");
    return p;
  }
  if ((k ==4)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x6a\x73\x6f\x6e\x2f\x6a\x73\x6f\x6e\x2e\x6f");
    return p;
  }
  if ((k ==5)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x63\x73\x76\x2f\x63\x73\x76\x2e\x6f");
    return p;
  }
  if ((k ==6)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x70\x61\x74\x68\x2f\x70\x61\x74\x68\x2e\x6f");
    return p;
  }
  if ((k ==7)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x68\x61\x73\x68\x2f\x68\x61\x73\x68\x2e\x6f");
    return p;
  }
  if ((k ==8)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x65\x72\x72\x6f\x72\x2f\x65\x72\x72\x6f\x72\x2e\x6f");
    return p;
  }
  if ((k ==9)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x63\x6f\x6e\x74\x65\x78\x74\x2f\x63\x6f\x6e\x74\x65\x78\x74\x2e\x6f");
    return p;
  }
  if ((k ==10)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x76\x65\x63\x2f\x76\x65\x63\x2e\x6f");
    return p;
  }
  if ((k ==11)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x6f\x72\x74\x2f\x73\x6f\x72\x74\x2e\x6f");
    return p;
  }
  if ((k ==12)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x65\x6e\x76\x2f\x65\x6e\x76\x2e\x6f");
    return p;
  }
  if ((k ==13)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x72\x61\x6e\x64\x6f\x6d\x2f\x72\x61\x6e\x64\x6f\x6d\x2e\x6f");
    return p;
  }
  if ((k ==14)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x74\x69\x6d\x65\x2f\x74\x69\x6d\x65\x2e\x6f");
    return p;
  }
  if ((k ==15)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x66\x73\x2f\x66\x73\x2e\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_fk0_sym_count(int32_t k) {
  if ((k ==0)) {
    return 11;
  }
  if ((k ==1)) {
    return 2;
  }
  if ((k ==2)) {
    return 2;
  }
  if ((k ==3)) {
    return 3;
  }
  if ((k ==4)) {
    return 2;
  }
  if ((k ==5)) {
    return 2;
  }
  if ((k ==6)) {
    return 4;
  }
  if ((k ==7)) {
    return 7;
  }
  if ((k ==8)) {
    return 4;
  }
  if ((k ==9)) {
    return 4;
  }
  if ((k ==10)) {
    return 10;
  }
  if ((k ==11)) {
    return 9;
  }
  if ((k ==12)) {
    return 10;
  }
  if ((k ==13)) {
    return 12;
  }
  if ((k ==14)) {
    return 15;
  }
  if ((k ==15)) {
    return 9;
  }
  return 0;
}
uint8_t * labi_fk0_sym_at(int32_t k, int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((k ==0)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x65\x6d\x70\x74\x79");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6e\x65\x77");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6c\x65\x6e\x5f\x53\x74\x72\x69\x6e\x67");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6c\x65\x6e\x5f\x53\x74\x72\x56\x69\x65\x77");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x69\x73\x5f\x65\x6d\x70\x74\x79\x5f\x53\x74\x72\x69\x6e\x67");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x69\x73\x5f\x65\x6d\x70\x74\x79\x5f\x53\x74\x72\x56\x69\x65\x77");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x76\x69\x65\x77");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x66\x72\x6f\x6d\x5f\x73\x6c\x69\x63\x65");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x74\x72\x69\x6e\x67\x5f\x73\x74\x72\x69\x6e\x67\x5f\x65\x71");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x63\x6d\x70\x5f\x63");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"\x73\x68\x75\x78\x5f\x73\x74\x72\x69\x6e\x67\x5f\x6d\x65\x6d\x6d\x65\x6d\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==1)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x75\x74\x66\x38\x5f\x76\x61\x6c\x69\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x63\x6f\x64\x69\x6e\x67\x5f\x61\x73\x63\x69\x69\x5f\x69\x73\x5f\x61\x6c\x70\x68\x61");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==2)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x73\x65\x36\x34\x5f\x65\x6e\x63\x6f\x64\x65\x5f\x73\x74\x61\x6e\x64\x61\x72\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x73\x65\x36\x34\x5f\x64\x65\x63\x6f\x64\x65\x5f\x73\x74\x61\x6e\x64\x61\x72\x64");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==3)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x67\x65\x74");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x72\x65\x71\x75\x65\x73\x74");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x63\x6c\x69\x65\x6e\x74\x5f\x6e\x65\x77");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==4)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6a\x73\x6f\x6e\x5f\x70\x61\x72\x73\x65");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6a\x73\x6f\x6e\x5f\x73\x74\x72\x69\x6e\x67\x69\x66\x79");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==5)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x73\x76\x5f\x6e\x65\x78\x74\x5f\x66\x69\x65\x6c\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x73\x76\x5f\x70\x61\x72\x73\x65\x5f\x6c\x69\x6e\x65");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==6)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x61\x74\x68\x5f\x6a\x6f\x69\x6e");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x61\x74\x68\x5f\x64\x69\x72\x6e\x61\x6d\x65");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x61\x74\x68\x5f\x65\x6d\x70\x74\x79\x5f\x6c\x65\x6e");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x61\x74\x68\x5f\x62\x61\x73\x65\x6e\x61\x6d\x65");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==7)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x73\x69\x70\x5f\x68\x61\x73\x68");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x66\x6e\x76\x31\x61");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x73\x74\x61\x72\x74");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x62\x79\x74\x65\x73");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x66\x69\x6e\x69\x73\x68");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x66\x72\x65\x65");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x61\x73\x68\x5f\x77\x72\x69\x74\x65\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x33\x32");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==8)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x72\x72\x6f\x72\x5f\x68\x74\x74\x70\x5f\x65\x72\x72\x5f\x74\x69\x6d\x65\x6f\x75\x74");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x72\x72\x6f\x72\x5f\x6f\x6b");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x72\x72\x6f\x72\x5f\x69\x6f\x5f\x65\x72\x72\x5f\x74\x69\x6d\x65\x6f\x75\x74");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x72\x72\x6f\x72\x5f\x69\x6f\x5f\x65\x72\x72\x5f\x63\x61\x6e\x63\x65\x6c\x6c\x65\x64");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==9)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x62\x61\x63\x6b\x67\x72\x6f\x75\x6e\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x64\x65\x61\x64\x6c\x69\x6e\x65\x5f\x6e\x73");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x69\x73\x5f\x63\x61\x6e\x63\x65\x6c\x6c\x65\x64");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x72\x65\x6d\x61\x69\x6e\x69\x6e\x67\x5f\x6e\x73");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==10)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6e\x65\x77\x5f\x72\x65\x74\x56\x65\x63\x5f\x75\x38");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6e\x65\x77\x5f\x72\x65\x74\x56\x65\x63\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x70\x75\x73\x68\x5f\x56\x65\x63\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x38");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x70\x75\x73\x68\x5f\x56\x65\x63\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6c\x65\x6e\x5f\x56\x65\x63\x5f\x75\x38");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6c\x65\x6e\x5f\x56\x65\x63\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6c\x65\x6e\x5f\x65\x6d\x70\x74\x79");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x76\x65\x63\x5f\x6c\x65\x6e\x5f\x65\x6d\x70\x74\x79");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x6e\x65\x77");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x76\x65\x63\x5f\x70\x75\x73\x68");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==11)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x73\x6f\x72\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x73\x6f\x72\x74\x5f\x75\x38\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x73\x74\x61\x62\x6c\x65\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x73\x74\x61\x62\x6c\x65\x5f\x75\x38\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x73\x74\x61\x62\x6c\x65\x5f\x62\x79\x5f\x6b\x65\x79");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x63\x6d\x70");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x63\x6d\x70\x5f\x61\x73\x63\x5f\x66\x6e");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x63\x6d\x70\x5f\x64\x65\x73\x63\x5f\x66\x6e");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x6f\x72\x74\x5f\x63\x6d\x70\x5f\x6b\x65\x79\x5f\x66\x6e");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==12)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x65\x78\x69\x73\x74\x73");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x7a");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x67\x65\x74\x65\x6e\x76\x5f\x70\x74\x72");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x73\x65\x74\x65\x6e\x76");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x75\x6e\x73\x65\x74\x65\x6e\x76");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x74\x65\x6d\x70\x5f\x64\x69\x72");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x69\x74\x65\x72");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x69\x74\x65\x72\x5f\x63\x6f\x75\x6e\x74");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6e\x76\x5f\x61\x72\x67\x73\x5f\x69\x74\x65\x72");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==13)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x6e\x65\x78\x74");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x61\x6e\x67\x65\x5f\x75\x33\x32\x5f\x75\x33\x32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x6c\x69\x70");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x67\x65\x6e");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x73\x65\x65\x64");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x33\x32\x5f\x63");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x36\x34\x5f\x63");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65\x5f\x63");
      return p;
    }
    if ((i ==11)) {
      uint8_t * p = ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==14)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6d\x73");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6e\x73");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x72\x5f\x73\x74\x61\x72\x74");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x74\x61\x72\x74");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x65\x6c\x61\x70\x73\x65\x64\x5f\x6e\x73");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x77\x61\x6c\x6c\x5f\x72\x66\x63\x33\x33\x33\x39");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x77\x61\x6c\x6c\x5f\x6c\x6f\x63\x61\x6c\x5f\x6f\x66\x66\x73\x65\x74\x5f\x6d\x69\x6e");
      return p;
    }
    if ((i ==11)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65");
      return p;
    }
    if ((i ==12)) {
      uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63");
      return p;
    }
    if ((i ==13)) {
      uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6e\x73\x5f\x63");
      return p;
    }
    if ((i ==14)) {
      uint8_t * p = ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==15)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x69\x6e\x76\x61\x6c\x69\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x6f\x70\x65\x6e");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x63\x72\x65\x61\x74\x65");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x63\x6c\x6f\x73\x65");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x72\x65\x61\x64");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x77\x72\x69\x74\x65");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x63\x68\x75\x6e\x6b\x5f\x73\x69\x7a\x65");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x6d\x6d\x61\x70\x5f\x72\x6f");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x66\x73\x5f\x6c\x61\x73\x74\x5f\x65\x72\x72\x6f\x72");
      return p;
    }
    return ((uint8_t *)(0));
  }
  return ((uint8_t *)(0));
}
int32_t labi_std_fk0_user_needs_rel(uint8_t * user_o, uint8_t * rel) {
  if ((rel ==0)) {
    return 0;
  }
  if (((rel)[0] ==0)) {
    return 0;
  }
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t nk = labi_fk0_rel_count();
  int32_t k = 0;
  int32_t kind = -1;
  while ((k < nk)) {
    uint8_t * needle = labi_fk0_rel_at(k);
    if ((needle !=0)) {
      if (((needle)[0] !=0)) {
        uint8_t * hitp = 0;
        (void)((hitp = strstr(rel, needle)));
        if ((hitp !=0)) {
          (void)((kind = k));
          (void)((k = nk));
        }
      }
    }
    (void)((k = (k + 1)));
  }
  if ((kind < 0)) {
    return 0;
  }
  int32_t n = labi_fk0_sym_count(kind);
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_fk0_sym_at(kind, i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_std_fk_gate_sym_count(int32_t fk) {
  if ((fk ==1)) {
    return 4;
  }
  if ((fk ==2)) {
    return 4;
  }
  if ((fk ==3)) {
    return 5;
  }
  if ((fk ==4)) {
    return 3;
  }
  if ((fk ==5)) {
    return 5;
  }
  if ((fk ==6)) {
    return 5;
  }
  if ((fk ==7)) {
    return 4;
  }
  if ((fk ==8)) {
    return 2;
  }
  if ((fk ==9)) {
    return 29;
  }
  if ((fk ==10)) {
    return 3;
  }
  if ((fk ==11)) {
    return 2;
  }
  if ((fk ==12)) {
    return 4;
  }
  if ((fk ==13)) {
    return 4;
  }
  return 0;
}
uint8_t * labi_std_fk_gate_sym_at(int32_t fk, int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((fk ==1)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x73\x68\x75\x78\x5f\x61\x72\x67\x76\x5f\x67\x65\x74");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x5f\x63");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x65\x78\x69\x74");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x73");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==2)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x68\x72\x65\x61\x64\x5f\x73\x70\x61\x77\x6e");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x74\x68\x72\x65\x61\x64\x5f\x6a\x6f\x69\x6e");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x74\x68\x72\x65\x61\x64\x5f\x63\x72\x65\x61\x74\x65\x5f\x63");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x74\x68\x72\x65\x61\x64\x5f\x6a\x6f\x69\x6e\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==3)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x6e\x63\x5f\x6c\x6f\x63\x6b");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x6e\x63\x5f\x6e\x65\x77\x5f\x6d\x75\x74\x65\x78");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x6e\x63\x5f\x74\x72\x79\x5f\x6c\x6f\x63\x6b");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x6e\x63\x5f\x77\x61\x69\x74");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x79\x6e\x63\x5f\x6d\x75\x74\x65\x78\x5f\x6c\x6f\x63\x6b\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==4)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x72\x79\x70\x74\x6f\x5f\x6d\x65\x6d\x5f\x65\x71");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x63\x72\x79\x70\x74\x6f\x5f\x6d\x65\x6d\x5f\x65\x71\x5f\x63");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x72\x79\x70\x74\x6f\x5f\x73\x68\x61\x32\x35\x36");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==5)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6c\x6f\x67\x5f\x6c\x6f\x67");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6c\x6f\x67\x5f\x6c\x65\x76\x65\x6c\x5f\x69\x6e\x66\x6f");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6c\x6f\x67\x5f\x73\x65\x74\x5f\x6d\x69\x6e\x5f\x6c\x65\x76\x65\x6c");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x6c\x6f\x67\x5f\x77\x72\x69\x74\x65\x5f\x63");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6c\x6f\x67\x5f\x73\x74\x72\x75\x63\x74\x75\x72\x65\x64\x5f\x6b\x76");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==6)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x73\x74\x6f\x72\x65\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x6c\x6f\x61\x64\x5f\x69\x33\x32\x5f\x70\x74\x72");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x66\x65\x74\x63\x68\x5f\x61\x64\x64\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x73\x74\x6f\x72\x65\x5f\x69\x36\x34\x5f\x70\x74\x72\x5f\x69\x36\x34");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x61\x74\x6f\x6d\x69\x63\x5f\x73\x74\x6f\x72\x65\x5f\x69\x33\x32\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==7)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x73\x65\x6e\x64");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x72\x65\x63\x76");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x73\x65\x6e\x64");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x72\x65\x63\x76");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==8)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x63\x61\x70\x74\x75\x72\x65");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x63\x61\x70\x74\x75\x72\x65");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==9)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x73\x69\x6e");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x63\x6f\x73");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x74\x61\x6e");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x70\x69");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x65");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x74\x61\x75");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x66\x6c\x6f\x6f\x72");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x63\x65\x69\x6c");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x74\x72\x75\x6e\x63");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x72\x6f\x75\x6e\x64");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x73\x71\x72\x74");
      return p;
    }
    if ((i ==11)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x63\x62\x72\x74");
      return p;
    }
    if ((i ==12)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x70\x6f\x77");
      return p;
    }
    if ((i ==13)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x65\x78\x70");
      return p;
    }
    if ((i ==14)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x6c\x6f\x67");
      return p;
    }
    if ((i ==15)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x61\x62\x73");
      return p;
    }
    if ((i ==16)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x73\x69\x67\x6e\x75\x6d");
      return p;
    }
    if ((i ==17)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x6d\x69\x6e");
      return p;
    }
    if ((i ==18)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x6d\x61\x78");
      return p;
    }
    if ((i ==19)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x61\x73\x69\x6e");
      return p;
    }
    if ((i ==20)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x61\x63\x6f\x73");
      return p;
    }
    if ((i ==21)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x61\x74\x61\x6e");
      return p;
    }
    if ((i ==22)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x74\x68\x5f\x61\x74\x61\x6e\x32");
      return p;
    }
    if ((i ==23)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x73\x69\x6e");
      return p;
    }
    if ((i ==24)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x63\x6f\x73");
      return p;
    }
    if ((i ==25)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x73\x69\x6e\x5f\x63");
      return p;
    }
    if ((i ==26)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x63\x6f\x73\x5f\x63");
      return p;
    }
    if ((i ==27)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x66\x6c\x6f\x6f\x72\x5f\x63");
      return p;
    }
    if ((i ==28)) {
      uint8_t * p = ((uint8_t *)"\x6d\x61\x74\x68\x5f\x70\x69\x5f\x63");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==10)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x64\x62\x5f\x73\x71\x6c\x69\x74\x65");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x71\x6c\x69\x74\x65\x33\x5f\x6f\x70\x65\x6e");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x64\x62\x5f\x73\x71\x6c\x69\x74\x65\x5f\x6f\x70\x65\x6e");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==11)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x65\x6c\x66\x5f\x70\x61\x72\x73\x65");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x65\x6c\x66\x5f\x70\x61\x72\x73\x65");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==12)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x70\x65\x6e");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x73\x79\x6d");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x70\x65\x6e\x5f\x63");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x70\x65\x6e");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((fk ==13)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x67\x65\x74");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x72\x65\x71\x75\x65\x73\x74");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x63\x6c\x69\x65\x6e\x74\x5f\x6e\x65\x77");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x74\x74\x70\x5f\x72\x65\x71\x75\x65\x73\x74\x5f\x74\x69\x6d\x65\x6f\x75\x74\x5f\x6d\x73\x5f\x66\x6f\x72\x5f\x63\x74\x78");
      return p;
    }
    return ((uint8_t *)(0));
  }
  return ((uint8_t *)(0));
}
int32_t labi_std_fk_user_needs(uint8_t * user_o, int32_t fk) {
  if ((user_o ==0)) {
    return 1;
  }
  if (((user_o)[0] ==0)) {
    return 1;
  }
  int32_t n = labi_std_fk_gate_sym_count(fk);
  if ((n <=0)) {
    return 1;
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_std_fk_gate_sym_at(fk, i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_needs_undef_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * labi_od_rel_net(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x6e\x65\x74\x2f\x6e\x65\x74\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_thread(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x74\x68\x72\x65\x61\x64\x2f\x74\x68\x72\x65\x61\x64\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_heap(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_set(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x65\x74\x2f\x73\x65\x74\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_map(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x6d\x61\x70\x2f\x6d\x61\x70\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_async_scheduler(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_core_mem(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_sys_linux(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x79\x73\x2f\x6c\x69\x6e\x75\x78\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_page_mmap(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_sys(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x73\x79\x73\x2f\x73\x79\x73\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_core_slice(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x73\x6c\x69\x63\x65\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_test(void) {
  uint8_t * p = ((uint8_t *)"\x73\x74\x64\x2f\x74\x65\x73\x74\x2f\x74\x65\x73\x74\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_heap_user(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_scheduler_glue(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x67\x6c\x75\x65\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_thread_glue(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x68\x72\x65\x61\x64\x5f\x67\x6c\x75\x65\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_net_udp_batch(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x61\x74\x63\x68\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_net_workers(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x77\x6f\x72\x6b\x65\x72\x73\x2e\x6f");
  return p;
}
uint8_t * labi_od_rel_test_fn_invoke(void) {
  uint8_t * p = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f");
  return p;
}
int32_t labi_od_provides_core_mem_sym_count(void) {
  return 2;
}
uint8_t * labi_od_provides_core_mem_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x70\x79");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x70\x6c\x61\x63\x65\x68\x6f\x6c\x64\x65\x72");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_provides_core_mem(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_provides_core_mem_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_provides_core_mem_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_has_defined_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_od_provides_std_heap_sym_count(void) {
  return 2;
}
uint8_t * labi_od_provides_std_heap_sym_at(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x73\x69\x7a\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_user_o_provides_std_heap(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_provides_std_heap_sym_count();
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * sym = labi_od_provides_std_heap_sym_at(i);
    if ((sym !=0)) {
      if (((sym)[0] !=0)) {
        int32_t hit = 0;
        (void)((hit = shux_link_obj_has_defined_sym(user_o, sym)));
        if ((hit !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_link_needs_heap_user_c(uint8_t * user_o, uint8_t * * argv, int32_t la) {
  if ((user_o !=0)) {
    if (((user_o)[0] !=0)) {
      int32_t uh = link_abi_user_o_needs_heap_user_syms(user_o);
      if ((uh !=0)) {
        return 1;
      }
    }
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return 0;
  }
  if ((la <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < la)) {
    uint8_t * e = (argv)[i];
    if ((e ==0)) {
      return 0;
    }
    int32_t is_obj = 0;
    (void)((is_obj = link_abi_ld_argv_entry_is_obj(e)));
    if ((is_obj !=0)) {
      int32_t need = link_abi_user_o_needs_heap_user_syms(e);
      if ((need !=0)) {
        return 1;
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t link_abi_link_needs_std_heap_import(uint8_t * user_o, uint8_t * * argv, int32_t la) {
  if ((user_o !=0)) {
    if (((user_o)[0] !=0)) {
      int32_t uh = link_abi_user_o_needs_std_heap_api(user_o);
      if ((uh !=0)) {
        return 1;
      }
    }
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return 0;
  }
  if ((la <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < la)) {
    uint8_t * e = (argv)[i];
    if ((e ==0)) {
      return 0;
    }
    int32_t is_obj = 0;
    (void)((is_obj = link_abi_ld_argv_entry_is_obj(e)));
    if ((is_obj !=0)) {
      int32_t need = link_abi_user_o_needs_std_heap_api(e);
      if ((need !=0)) {
        return 1;
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}

/* wave197: on_demand shell pure orch + helpers (≡ labi_ondemand_list.x -E) */
int32_t labi_ondemand_list_labi_od_cstr_contains(uint8_t * hay, uint8_t * needle) {
  if ((hay ==0)) {
    return 0;
  }
  if ((needle ==0)) {
    return 0;
  }
  if (((hay)[0] ==0)) {
    return 0;
  }
  if (((needle)[0] ==0)) {
    return 0;
  }
  int32_t nlen = 0;
  while (((needle)[nlen] !=0)) {
    (void)((nlen = (nlen + 1)));
  }
  int32_t hlen = 0;
  while (((hay)[hlen] !=0)) {
    (void)((hlen = (hlen + 1)));
  }
  if ((nlen > hlen)) {
    return 0;
  }
  int32_t i = 0;
  while (((i + nlen) <=hlen)) {
    int32_t j = 0;
    int32_t ok = 1;
    while ((j < nlen)) {
      if ((ok !=0)) {
        if (((hay)[(i + j)] !=(needle)[j])) {
          (void)((ok = 0));
        }
      }
      (void)((j = (j + 1)));
    }
    if ((ok !=0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_ondemand_list_labi_od_user_needs_simple_group(uint8_t * user_o, int32_t g) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  int32_t n = labi_od_simple_group_sym_count(g);
  if ((n <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * s = labi_od_simple_group_sym_at(g, i);
    if ((s !=0)) {
      if (((s)[0] !=0)) {
        int32_t u = 0;
        (void)((u = shux_link_obj_needs_undef_sym(user_o, s)));
        if ((u !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_ondemand_list_labi_od_user_needs_table_which(uint8_t * user_o, int32_t n, int32_t which) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((n <=0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < n)) {
    uint8_t * s = 0;
    if ((which ==0)) {
      (void)((s = labi_od_kv_sym_at(i)));
    }
    if ((which ==1)) {
      (void)((s = labi_od_arrow_sym_at(i)));
    }
    if ((which ==2)) {
      (void)((s = labi_od_time_sym_at(i)));
    }
    if ((which ==3)) {
      (void)((s = labi_od_queue_sym_at(i)));
    }
    if ((s !=0)) {
      if (((s)[0] !=0)) {
        int32_t u = 0;
        (void)((u = shux_link_obj_needs_undef_sym(user_o, s)));
        if ((u !=0)) {
          return 1;
        }
      }
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
void labi_ondemand_list_labi_od_glue_push_if(int32_t er, uint8_t * primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la) {
  if ((er !=0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t _p = 0;
  (void)((_p = link_abi_asm_ld_push_obj(primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0)));
  if ((_p ==0)) {
    return;
  }
}
uint8_t * labi_ondemand_list_labi_od_resolve_or_try(uint8_t * primary, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank) {
  uint8_t * p = 0;
  if ((primary !=0)) {
    (void)((p = asm_link_obj_skip_missing(primary)));
  }
  if ((p ==0)) {
    if ((bank !=0)) {
      if ((rel !=0)) {
        (void)((p = shux_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank)));
      }
    }
  }
  return p;
}
void shux_asm_ld_append_on_demand_user_objs(uint8_t * link_argv0, uint8_t * user_o, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * flags) {
  if ((user_o ==0)) {
    return;
  }
  if (((user_o)[0] ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  if (((la)[0] >=(max_la - 1))) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  int32_t need_net = link_abi_user_o_needs_std_net(user_o);
  if ((need_net !=0)) {
    int32_t have_net = 0;
    uint8_t * rel_net = labi_od_rel_net();
    {
      int32_t _n = link_abi_asm_ld_push_obj(0, link_argv0, rel_net, lib_roots, n_lib_roots, bank, argv, la, max_la, &(have_net));
    }
    if ((have_net !=0)) {
      if ((flags !=0)) {
        int32_t * f = ((int32_t *)(flags));
        (void)(((f)[1] = 1));
      }
      uint8_t * rel_th = labi_od_rel_thread();
      int32_t have_th = 0;
      {
        int32_t _t = link_abi_asm_ld_push_obj(0, link_argv0, rel_th, lib_roots, n_lib_roots, bank, argv, la, max_la, &(have_th));
      }
      if ((have_th !=0)) {
        if ((flags !=0)) {
          int32_t * f2 = ((int32_t *)(flags));
          (void)(((f2)[2] = 1));
        }
        int32_t er = 0;
        uint8_t * tp = 0;
        uint8_t * trel = labi_od_rel_thread_glue();
        (void)((er = shux_ensure_runtime_thread_glue_o(link_argv0)));
        (void)((tp = shux_runtime_thread_glue_o_path(link_argv0)));
        (void)(labi_ondemand_list_labi_od_glue_push_if(er, tp, link_argv0, trel, lib_roots, n_lib_roots, bank, argv, la, max_la));
      }
      int32_t er_u = 0;
      uint8_t * up = 0;
      uint8_t * urel = labi_od_rel_net_udp_batch();
      (void)((er_u = shux_ensure_runtime_net_udp_batch_o(link_argv0)));
      (void)((up = shux_runtime_net_udp_batch_o_path(link_argv0)));
      (void)(labi_ondemand_list_labi_od_glue_push_if(er_u, up, link_argv0, urel, lib_roots, n_lib_roots, bank, argv, la, max_la));
      int32_t er_w = 0;
      uint8_t * wp = 0;
      uint8_t * wrel = labi_od_rel_net_workers();
      (void)((er_w = shux_ensure_runtime_net_workers_o(link_argv0)));
      (void)((wp = shux_runtime_net_workers_o_path(link_argv0)));
      (void)(labi_ondemand_list_labi_od_glue_push_if(er_w, wp, link_argv0, wrel, lib_roots, n_lib_roots, bank, argv, la, max_la));
    }
  }
  int32_t la_n = (la)[0];
  int32_t need_hi = link_abi_link_needs_std_heap_import(user_o, argv, la_n);
  if ((need_hi !=0)) {
    int32_t prov_m = link_abi_user_o_provides_core_mem(user_o);
    if ((prov_m ==0)) {
      uint8_t * rm = labi_od_rel_core_mem();
      {
        int32_t _m = link_abi_asm_ld_push_obj(0, link_argv0, rm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    int32_t prov_h = link_abi_user_o_provides_std_heap(user_o);
    if ((prov_h ==0)) {
      uint8_t * rh = labi_od_rel_heap();
      {
        int32_t _h = link_abi_asm_ld_push_obj(0, link_argv0, rh, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
  }
  int32_t need_set = link_abi_user_o_needs_std_set(user_o);
  if ((need_set !=0)) {
    uint8_t * root = 0;
    (void)((root = shux_repo_root_from_argv0(link_argv0)));
    if ((root !=0)) {
      if (((root)[0] !=0)) {
        {
          int32_t _e1 = shux_ensure_formal_std_make_o(root, ((uint8_t *)"\x73\x74\x64\x2f\x73\x65\x74\x2f\x73\x65\x74\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x73\x65\x74\x2f\x73\x65\x74\x2e\x6f"));
          int32_t _e2 = shux_ensure_formal_std_make_o(root, ((uint8_t *)"\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"));
          int32_t _e3 = shux_ensure_formal_std_make_o(root, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"));
          int32_t _e4 = shux_ensure_formal_std_make_o(root, ((uint8_t *)"\x73\x74\x64\x2f\x68\x61\x73\x68\x2f\x68\x61\x73\x68\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x68\x61\x73\x68\x2f\x68\x61\x73\x68\x2e\x6f"));
        }
      }
    }
    uint8_t * rs = labi_od_rel_set();
    uint8_t * rh2 = labi_od_rel_heap();
    uint8_t * rm2 = labi_od_rel_core_mem();
    {
      int32_t _s = link_abi_asm_ld_push_obj(0, link_argv0, rs, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _sh = link_abi_asm_ld_push_obj(0, link_argv0, rh2, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _sm = link_abi_asm_ld_push_obj(0, link_argv0, rm2, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _hh = link_abi_asm_ld_push_obj(0, link_argv0, ((uint8_t *)"\x73\x74\x64\x2f\x68\x61\x73\x68\x2f\x68\x61\x73\x68\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    }
  }
  int32_t need_map = link_abi_user_o_needs_std_map(user_o);
  if ((need_map !=0)) {
    uint8_t * rootm = 0;
    (void)((rootm = shux_repo_root_from_argv0(link_argv0)));
    if ((rootm !=0)) {
      if (((rootm)[0] !=0)) {
        {
          int32_t _m1 = shux_ensure_formal_std_make_o(rootm, ((uint8_t *)"\x73\x74\x64\x2f\x6d\x61\x70\x2f\x6d\x61\x70\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x6d\x61\x70\x2f\x6d\x61\x70\x2e\x6f"));
          int32_t _m2 = shux_ensure_formal_std_make_o(rootm, ((uint8_t *)"\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"));
          int32_t _m3 = shux_ensure_formal_std_make_o(rootm, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"));
        }
      }
    }
    uint8_t * rmap = labi_od_rel_map();
    uint8_t * rhm = labi_od_rel_heap();
    uint8_t * rmm = labi_od_rel_core_mem();
    {
      int32_t _mp = link_abi_asm_ld_push_obj(0, link_argv0, rmap, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _mph = link_abi_asm_ld_push_obj(0, link_argv0, rhm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _mpm = link_abi_asm_ld_push_obj(0, link_argv0, rmm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    }
  }
  int32_t need_as = link_abi_user_o_needs_async_scheduler(user_o);
  if ((need_as !=0)) {
    uint8_t * spath = 0;
    (void)((spath = shux_std_async_scheduler_o_path(link_argv0)));
    uint8_t * p_as = labi_ondemand_list_labi_od_resolve_or_try(spath, labi_od_rel_async_scheduler(), lib_roots, n_lib_roots, bank);
    if ((p_as !=0)) {
      if (((la)[0] < (max_la - 1))) {
        (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_as));
      }
      if (((la)[0] < (max_la - 1))) {
        uint8_t * gpath = 0;
        (void)((gpath = shux_runtime_scheduler_glue_o_path(link_argv0)));
        uint8_t * p_sg = labi_ondemand_list_labi_od_resolve_or_try(gpath, labi_od_rel_scheduler_glue(), lib_roots, n_lib_roots, bank);
        if ((p_sg !=0)) {
          (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_sg));
        }
      }
    }
  }
  int32_t need_cm = link_abi_user_o_needs_core_mem(user_o);
  if ((need_cm !=0)) {
    uint8_t * crel = labi_od_rel_core_mem();
    uint8_t * cprim = 0;
    (void)((cprim = shux_rel_o_path_from_argv0(link_argv0, crel)));
    uint8_t * p_cm = labi_ondemand_list_labi_od_resolve_or_try(cprim, crel, lib_roots, n_lib_roots, bank);
    if ((p_cm !=0)) {
      (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_cm));
    }
  }
  int32_t fs = 0;
  (void)((fs = driver_freestanding_get()));
  if ((fs ==0)) {
    int32_t need_pm = link_abi_user_o_needs_std_heap_page_mmap(user_o);
    int32_t need_sl = link_abi_user_o_needs_std_sys_linux(user_o);
    int32_t need_sy = link_abi_user_o_needs_std_sys(user_o);
    int32_t ai = 0;
    int32_t la_now = (la)[0];
    while ((ai < la_now)) {
      uint8_t * e = (argv)[ai];
      if ((e ==0)) {
        (void)((ai = la_now));
      }
      if ((e !=0)) {
        int32_t is_obj = 0;
        (void)((is_obj = link_abi_ld_argv_entry_is_obj(e)));
        if ((is_obj !=0)) {
          if ((link_abi_user_o_needs_std_heap_page_mmap(e) !=0)) {
            (void)((need_pm = 1));
          }
          if ((link_abi_user_o_needs_std_sys_linux(e) !=0)) {
            (void)((need_sl = 1));
          }
          if ((link_abi_user_o_needs_std_sys(e) !=0)) {
            (void)((need_sy = 1));
          }
        }
      }
      (void)((ai = (ai + 1)));
    }
    int32_t need_any_sys = 0;
    if ((need_sl !=0)) {
      (void)((need_any_sys = 1));
    }
    if ((need_pm !=0)) {
      (void)((need_any_sys = 1));
    }
    if ((need_sy !=0)) {
      (void)((need_any_sys = 1));
    }
    if ((need_any_sys !=0)) {
      uint8_t * rsl = labi_od_rel_sys_linux();
      {
        int32_t _sl = link_abi_asm_ld_push_obj(0, link_argv0, rsl, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    int32_t need_cm_sys = 0;
    if ((need_pm !=0)) {
      (void)((need_cm_sys = 1));
    }
    if ((need_sy !=0)) {
      (void)((need_cm_sys = 1));
    }
    if ((need_cm_sys !=0)) {
      uint8_t * rcm = labi_od_rel_core_mem();
      {
        int32_t _cm = link_abi_asm_ld_push_obj(0, link_argv0, rcm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    if ((need_pm !=0)) {
      uint8_t * rpm = labi_od_rel_page_mmap();
      {
        int32_t _pm = link_abi_asm_ld_push_obj(0, link_argv0, rpm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    if ((need_sy !=0)) {
      uint8_t * rsy = labi_od_rel_sys();
      {
        int32_t _sy = link_abi_asm_ld_push_obj(0, link_argv0, rsy, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
  }
  int32_t need_cs = link_abi_user_o_needs_core_slice(user_o);
  if ((need_cs !=0)) {
    uint8_t * csrel = labi_od_rel_core_slice();
    uint8_t * csprim = 0;
    (void)((csprim = shux_rel_o_path_from_argv0(link_argv0, csrel)));
    uint8_t * p_cs = labi_ondemand_list_labi_od_resolve_or_try(csprim, csrel, lib_roots, n_lib_roots, bank);
    if ((p_cs !=0)) {
      (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_cs));
    }
  }
  int32_t n_kv = labi_od_kv_sym_count();
  if ((labi_ondemand_list_labi_od_user_needs_table_which(user_o, n_kv, 0) !=0)) {
    uint8_t * kvrel = labi_od_kv_rel();
    uint8_t * kvprim = 0;
    (void)((kvprim = shux_rel_o_path_from_argv0(link_argv0, kvrel)));
    uint8_t * p_kv = labi_ondemand_list_labi_od_resolve_or_try(kvprim, kvrel, lib_roots, n_lib_roots, bank);
    if ((p_kv !=0)) {
      (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_kv));
      if (((la)[0] < (max_la - 1))) {
        uint8_t * kvp = 0;
        (void)((kvp = shux_runtime_kv_mmap_glue_o_path(link_argv0)));
        uint8_t * p_kg = labi_ondemand_list_labi_od_resolve_or_try(kvp, labi_od_kv_glue_rel(), lib_roots, n_lib_roots, bank);
        if ((p_kg !=0)) {
          (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_kg));
        }
      }
    }
  }
  int32_t n_ar = labi_od_arrow_sym_count();
  if ((labi_ondemand_list_labi_od_user_needs_table_which(user_o, n_ar, 1) !=0)) {
    uint8_t * arrel = labi_od_arrow_rel();
    uint8_t * arprim = 0;
    (void)((arprim = shux_rel_o_path_from_argv0(link_argv0, arrel)));
    uint8_t * p_ar = labi_ondemand_list_labi_od_resolve_or_try(arprim, arrel, lib_roots, n_lib_roots, bank);
    if ((p_ar !=0)) {
      (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_ar));
      if (((la)[0] < (max_la - 1))) {
        uint8_t * arp = 0;
        (void)((arp = shux_runtime_arrow_simd_glue_o_path(link_argv0)));
        uint8_t * p_ag = labi_ondemand_list_labi_od_resolve_or_try(arp, labi_od_arrow_glue_rel(), lib_roots, n_lib_roots, bank);
        if ((p_ag !=0)) {
          (void)(link_abi_asm_ld_argv_push_stable(bank, argv, la, max_la, p_ag));
        }
      }
    }
  }
  int32_t need_test = link_abi_user_o_needs_std_test(user_o);
  if ((need_test !=0)) {
    int32_t have_test = 0;
    uint8_t * trel = labi_od_rel_test();
    {
      int32_t _tt = link_abi_asm_ld_push_obj(0, link_argv0, trel, lib_roots, n_lib_roots, bank, argv, la, max_la, &(have_test));
    }
    if ((have_test !=0)) {
      int32_t er_t = 0;
      uint8_t * tp = 0;
      uint8_t * tfrel = labi_od_rel_test_fn_invoke();
      (void)((er_t = shux_ensure_runtime_test_fn_invoke_o(link_argv0)));
      (void)((tp = shux_runtime_test_fn_invoke_o_path(link_argv0)));
      (void)(labi_ondemand_list_labi_od_glue_push_if(er_t, tp, link_argv0, tfrel, lib_roots, n_lib_roots, bank, argv, la, max_la));
    }
  }
  if ((fs ==0)) {
    int32_t la_hu = (la)[0];
    int32_t need_hu = link_abi_link_needs_heap_user_c(user_o, argv, la_hu);
    if ((need_hu !=0)) {
      int32_t er_hu = 0;
      (void)((er_hu = shux_ensure_runtime_heap_user_o(link_argv0)));
      if ((er_hu !=0)) {
        return;
      }
      uint8_t * hup = 0;
      uint8_t * hurel = labi_od_rel_heap_user();
      {
        (void)((hup = shux_runtime_heap_user_o_path(link_argv0)));
        int32_t _hu = link_abi_asm_ld_push_obj(hup, link_argv0, hurel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
      if ((flags !=0)) {
        int32_t * fh = ((int32_t *)(flags));
        (void)(((fh)[10] = 1));
      }
    }
  }
  int32_t pushed_core_formal = 0;
  int32_t gcount = labi_od_simple_group_count();
  int32_t sg = 0;
  while ((sg < gcount)) {
    uint8_t * rel = labi_od_simple_group_rel(sg);
    if ((rel !=0)) {
      if (((rel)[0] !=0)) {
        if ((labi_ondemand_list_labi_od_user_needs_simple_group(user_o, sg) !=0)) {
          if ((sg ==1)) {
            uint8_t * rt = 0;
            (void)((rt = shux_repo_root_from_argv0(link_argv0)));
            if ((rt !=0)) {
              if (((rt)[0] !=0)) {
                {
                  int32_t _fe = shux_ensure_formal_std_make_o(rt, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x74\x79\x70\x65\x73\x2f\x74\x79\x70\x65\x73\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x74\x79\x70\x65\x73\x2f\x74\x79\x70\x65\x73\x2e\x6f"));
                }
                (void)((pushed_core_formal = 1));
              }
            }
          }
          if ((sg ==6)) {
            uint8_t * rt6 = 0;
            (void)((rt6 = shux_repo_root_from_argv0(link_argv0)));
            if ((rt6 !=0)) {
              if (((rt6)[0] !=0)) {
                {
                  int32_t _fe6 = shux_ensure_formal_std_make_o(rt6, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6f\x70\x74\x69\x6f\x6e\x2f\x6f\x70\x74\x69\x6f\x6e\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x6f\x70\x74\x69\x6f\x6e\x2f\x6f\x70\x74\x69\x6f\x6e\x2e\x6f"));
                }
                (void)((pushed_core_formal = 1));
              }
            }
          }
          if ((sg ==7)) {
            uint8_t * rt7 = 0;
            (void)((rt7 = shux_repo_root_from_argv0(link_argv0)));
            if ((rt7 !=0)) {
              if (((rt7)[0] !=0)) {
                {
                  int32_t _fe7 = shux_ensure_formal_std_make_o(rt7, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x72\x65\x73\x75\x6c\x74\x2f\x72\x65\x73\x75\x6c\x74\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x72\x65\x73\x75\x6c\x74\x2f\x72\x65\x73\x75\x6c\x74\x2e\x6f"));
                }
                (void)((pushed_core_formal = 1));
              }
            }
          }
          if ((sg ==8)) {
            uint8_t * rt8 = 0;
            (void)((rt8 = shux_repo_root_from_argv0(link_argv0)));
            if ((rt8 !=0)) {
              if (((rt8)[0] !=0)) {
                {
                  int32_t _fe8 = shux_ensure_formal_std_make_o(rt8, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x64\x65\x62\x75\x67\x2f\x64\x65\x62\x75\x67\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x64\x65\x62\x75\x67\x2f\x64\x65\x62\x75\x67\x2e\x6f"));
                }
                (void)((pushed_core_formal = 1));
              }
            }
          }
          if ((sg ==9)) {
            uint8_t * rt9 = 0;
            (void)((rt9 = shux_repo_root_from_argv0(link_argv0)));
            if ((rt9 !=0)) {
              if (((rt9)[0] !=0)) {
                {
                  int32_t _fe9 = shux_ensure_formal_std_make_o(rt9, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x6d\x6f\x64\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x6d\x6f\x64\x2e\x6f"));
                }
                (void)((pushed_core_formal = 1));
              }
            }
          }
          {
            int32_t _sg = link_abi_asm_ld_push_obj(0, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
          }
          if ((sg ==9)) {
            uint8_t * rtg = 0;
            (void)((rtg = shux_repo_root_from_argv0(link_argv0)));
            if ((rtg !=0)) {
              if (((rtg)[0] !=0)) {
                {
                  int32_t _feg = shux_ensure_formal_std_make_o(rtg, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x73\x6c\x69\x63\x65\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x73\x6c\x69\x63\x65\x2f\x73\x6c\x69\x63\x65\x2e\x6f"));
                }
              }
            }
            uint8_t * csgl = labi_od_rel_core_slice();
            {
              int32_t _csg = link_abi_asm_ld_push_obj(0, link_argv0, csgl, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
            }
          }
        }
      }
    }
    (void)((sg = (sg + 1)));
  }
  if ((pushed_core_formal !=0)) {
    uint8_t * pav = 0;
    {
      int32_t _ep = shux_ensure_runtime_process_argv_o(link_argv0);
      (void)((pav = shux_runtime_process_argv_o_path(link_argv0)));
      int32_t _pp = link_abi_asm_ld_push_obj(pav, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    }
  }
  int32_t need_pav = 0;
  int32_t have_process_o = 0;
  int32_t bi = 0;
  int32_t la_b = (la)[0];
  while ((bi < la_b)) {
    uint8_t * e2 = (argv)[bi];
    if ((e2 ==0)) {
      (void)((bi = la_b));
    }
    if ((e2 !=0)) {
      int32_t is_o = 0;
      (void)((is_o = link_abi_ld_argv_entry_is_obj(e2)));
      if ((is_o !=0)) {
        int32_t has_po = labi_ondemand_list_labi_od_cstr_contains(e2, ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x2e\x6f"));
        int32_t has_pa = labi_ondemand_list_labi_od_cstr_contains(e2, ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76"));
        if ((has_po !=0)) {
          if ((has_pa ==0)) {
            (void)((have_process_o = 1));
          }
        }
        int32_t u1 = 0;
        int32_t u2 = 0;
        (void)((u1 = shux_link_obj_needs_undef_sym(e2, ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x73\x68\x75\x78\x5f\x61\x72\x67\x63\x5f\x67\x65\x74"))));
        (void)((u2 = shux_link_obj_needs_undef_sym(e2, ((uint8_t *)"\x70\x72\x6f\x63\x65\x73\x73\x5f\x73\x68\x75\x78\x5f\x61\x72\x67\x76\x5f\x67\x65\x74"))));
        if ((u1 !=0)) {
          (void)((need_pav = 1));
        }
        if ((u2 !=0)) {
          (void)((need_pav = 1));
        }
      }
    }
    (void)((bi = (bi + 1)));
  }
  if ((need_pav !=0)) {
    if ((have_process_o ==0)) {
      uint8_t * pav2 = 0;
      {
        int32_t _ep2 = shux_ensure_runtime_process_argv_o(link_argv0);
        (void)((pav2 = shux_runtime_process_argv_o_path(link_argv0)));
        int32_t _pp2 = link_abi_asm_ld_push_obj(pav2, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
  }
  int32_t n_tm = labi_od_time_sym_count();
  if ((labi_ondemand_list_labi_od_user_needs_table_which(user_o, n_tm, 2) !=0)) {
    uint8_t * rtt = 0;
    (void)((rtt = shux_repo_root_from_argv0(link_argv0)));
    if ((rtt !=0)) {
      if (((rtt)[0] !=0)) {
        {
          int32_t _te = shux_ensure_formal_std_make_o(rtt, ((uint8_t *)"\x73\x74\x64\x2f\x74\x69\x6d\x65\x2f\x74\x69\x6d\x65\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x74\x69\x6d\x65\x2f\x74\x69\x6d\x65\x2e\x6f"));
        }
      }
    }
    int32_t er_to = 0;
    uint8_t * top = 0;
    uint8_t * torel = labi_od_time_os_rel();
    (void)((er_to = shux_ensure_runtime_time_os_o(link_argv0)));
    (void)((top = shux_runtime_time_os_o_path(link_argv0)));
    if ((er_to ==0)) {
      {
        int32_t _to = link_abi_asm_ld_push_obj(top, link_argv0, torel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    uint8_t * trel = labi_od_time_rel();
    {
      int32_t _tm = link_abi_asm_ld_push_obj(0, link_argv0, trel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    }
  }
  int32_t need_qp = link_abi_user_o_needs_std_queue(user_o);
  int32_t n_qc = labi_od_queue_sym_count();
  int32_t need_qc = labi_ondemand_list_labi_od_user_needs_table_which(user_o, n_qc, 3);
  if (((need_qp !=0) || (need_qc !=0))) {
    uint8_t * rq = 0;
    (void)((rq = shux_repo_root_from_argv0(link_argv0)));
    if ((rq !=0)) {
      if (((rq)[0] !=0)) {
        {
          int32_t _q1 = shux_ensure_formal_std_make_o(rq, ((uint8_t *)"\x73\x74\x64\x2f\x71\x75\x65\x75\x65\x2f\x71\x75\x65\x75\x65\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x71\x75\x65\x75\x65\x2f\x71\x75\x65\x75\x65\x2e\x6f"));
          int32_t _q2 = shux_ensure_formal_std_make_o(rq, ((uint8_t *)"\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x73\x74\x64\x2f\x68\x65\x61\x70\x2f\x68\x65\x61\x70\x2e\x6f"));
          int32_t _q3 = shux_ensure_formal_std_make_o(rq, ((uint8_t *)"\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"), ((uint8_t *)"\x2e\x2e\x2f\x63\x6f\x72\x65\x2f\x6d\x65\x6d\x2f\x6d\x65\x6d\x2e\x6f"));
        }
      }
    }
    if ((need_qc !=0)) {
      uint8_t * qcp = 0;
      uint8_t * qcrel = labi_od_queue_contention_rel();
      {
        int32_t _eq = shux_ensure_runtime_queue_contention_o(link_argv0);
        (void)((qcp = shux_runtime_queue_contention_o_path(link_argv0)));
        int32_t _qc = link_abi_asm_ld_push_obj(qcp, link_argv0, qcrel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      }
    }
    uint8_t * qrel = labi_od_queue_rel();
    uint8_t * qh = labi_od_rel_heap();
    uint8_t * qm = labi_od_rel_core_mem();
    {
      int32_t _qq = link_abi_asm_ld_push_obj(0, link_argv0, qrel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _qh = link_abi_asm_ld_push_obj(0, link_argv0, qh, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
      int32_t _qm = link_abi_asm_ld_push_obj(0, link_argv0, qm, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    }
  }
}
