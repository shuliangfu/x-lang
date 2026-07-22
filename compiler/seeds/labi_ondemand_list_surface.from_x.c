/* seeds/labi_ondemand_list_surface.from_x.c
 * G-02f labi_ondemand_list R2 full surface — isomorphic with src/runtime/labi_ondemand_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_ondemand_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (on_demand tables + wave118–134 needs_std_net/set/map/queue/test + needs_core_mem/slice + needs_std_heap_page_mmap + needs_std_sys_linux + needs_std_sys + needs_std_heap_api + needs_heap_user_syms + needs_async_scheduler + compress family + labi_user_needs_runtime time_os/random_fill/env_os/process_argv + labi_user_needs_std_task + labi_std_fk0_user_needs_rel + wave140 user_o_provides_core_mem/std_heap pure + wave145 link_needs_heap_user_c/std_heap_import aggregate pure)
 * Cap residual: nm/push/ensure + undef_sym / exports_marker / has_undef_sym / has_defined_sym probes in mega
 * Regen: ./shux_asm -E ... src/runtime/labi_ondemand_list.x | filter DBG + polish prologue
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
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
extern uint8_t * strstr(uint8_t * hay, uint8_t * needle);
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
extern int32_t shux_link_obj_has_defined_sym(uint8_t * o_path, uint8_t * sym);
extern int32_t link_abi_obj_exports_marker(uint8_t * obj_o, uint8_t * marker);
extern int32_t link_abi_obj_has_undef_sym(uint8_t * obj_o, uint8_t * sym);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
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
    uint8_t * p = ((uint8_t *)"_compress2");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"_deflate");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"_inflate");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"_uncompress");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_zlib_marker(void) {
  uint8_t * p = ((uint8_t *)"shu_compress_zlib_marker");
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
    uint8_t * p = ((uint8_t *)"ZSTD_");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"_ZSTD");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_zstd_marker(void) {
  uint8_t * p = ((uint8_t *)"shu_compress_zstd_marker");
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
    uint8_t * p = ((uint8_t *)"BrotliEncoderCompress");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"BrotliDecoderDecompress");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_od_compress_brotli_marker(void) {
  uint8_t * p = ((uint8_t *)"shu_compress_brotli_marker");
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
    uint8_t * p = ((uint8_t *)"time_now_monotonic_ns_c");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"time_now_wall_ns_c");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"time_sleep_ns_c");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"time_format_wall_rfc3339_c");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"time_wall_local_offset_min_c");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"std_time_now_monotonic_ns");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"std_time_now_wall_ns");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"std_time_sleep_ms");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"std_time_timer_start");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"std_time_duration_ns");
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
    uint8_t * p = ((uint8_t *)"random_fill_bytes_c");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"std_random_fill_bytes");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"std_random_fill");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"std_random_next");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"std_random_range_u32_u32");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"std_random_gen");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"std_random_flip");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"std_random_rng_smoke");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"std_random_seed");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"random_u32_c");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"random_u64_c");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"random_rng_smoke_c");
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
    uint8_t * p = ((uint8_t *)"env_getenv_c");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"env_getenv_exists_c");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"env_getenv_z_c");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"env_getenv_ptr_c");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"env_setenv_c");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"env_unsetenv_c");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"env_temp_dir_c");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"env_iter_count_c");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"env_iter_at_c");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"std_env_getenv");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"std_env_getenv_exists");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"std_env_getenv_z");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"std_env_getenv_ptr");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"std_env_setenv");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"std_env_unsetenv");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"std_env_temp_dir");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"std_env_iter");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"std_env_iter_count");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"std_env_args_iter");
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
    uint8_t * p = ((uint8_t *)"process_shux_argc_get");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"process_shux_argv_get");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"process_arg_c");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"process_args_count_c");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"std_process_args");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"std_process_arg");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"std_process_argc");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"std_process_argv");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"std_env_args_iter");
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
    uint8_t * p = ((uint8_t *)"std_task_new");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"std_task_free");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"std_task_bind");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"std_task_spawn");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"std_task_join");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"std_task_pending");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"std_task_check_leak");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"std_task_cancel");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"std_task_total");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"std_task_set_new");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"std_task_set_free");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"std_task_set_spawn");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"std_task_set_join");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"std_task_set_check_leak");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"std_task_echo");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"std_task_echo_ptr");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"std_task_retry");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"std_task_err_ok");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"task_group_create_c");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"task_group_spawn_c");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"task_group_join_c");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"task_group_free_c");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"join_set_create_c");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"join_set_spawn_c");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"join_set_join_c");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"task_smoke_c");
    return p;
  }
  if ((i ==26)) {
    uint8_t * p = ((uint8_t *)"task_supervise_retry_c");
    return p;
  }
  if ((i ==27)) {
    uint8_t * p = ((uint8_t *)"task_echo_fn_c");
    return p;
  }
  if ((i ==28)) {
    uint8_t * p = ((uint8_t *)"task_echo_fn_ptr_c");
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
    uint8_t * p = ((uint8_t *)"std/string/string.o");
    return p;
  }
  if ((k ==1)) {
    uint8_t * p = ((uint8_t *)"std/encoding/encoding.o");
    return p;
  }
  if ((k ==2)) {
    uint8_t * p = ((uint8_t *)"std/base64/base64.o");
    return p;
  }
  if ((k ==3)) {
    uint8_t * p = ((uint8_t *)"std/http/http.o");
    return p;
  }
  if ((k ==4)) {
    uint8_t * p = ((uint8_t *)"std/json/json.o");
    return p;
  }
  if ((k ==5)) {
    uint8_t * p = ((uint8_t *)"std/csv/csv.o");
    return p;
  }
  if ((k ==6)) {
    uint8_t * p = ((uint8_t *)"std/path/path.o");
    return p;
  }
  if ((k ==7)) {
    uint8_t * p = ((uint8_t *)"std/hash/hash.o");
    return p;
  }
  if ((k ==8)) {
    uint8_t * p = ((uint8_t *)"std/error/error.o");
    return p;
  }
  if ((k ==9)) {
    uint8_t * p = ((uint8_t *)"std/context/context.o");
    return p;
  }
  if ((k ==10)) {
    uint8_t * p = ((uint8_t *)"std/vec/vec.o");
    return p;
  }
  if ((k ==11)) {
    uint8_t * p = ((uint8_t *)"std/sort/sort.o");
    return p;
  }
  if ((k ==12)) {
    uint8_t * p = ((uint8_t *)"std/env/env.o");
    return p;
  }
  if ((k ==13)) {
    uint8_t * p = ((uint8_t *)"std/random/random.o");
    return p;
  }
  if ((k ==14)) {
    uint8_t * p = ((uint8_t *)"std/time/time.o");
    return p;
  }
  if ((k ==15)) {
    uint8_t * p = ((uint8_t *)"std/fs/fs.o");
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
  if ((i <0)) {
    return ((uint8_t *)(0));
  }
  if ((k ==0)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_string_string_empty");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_string_new");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_string_len_String");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_string_len_StrView");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_string_is_empty_String");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_string_is_empty_StrView");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_string_view");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_string_string_from_slice");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_string_string_eq");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"shux_string_memcmp_c");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"shux_string_memmem_c");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==1)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_encoding_utf8_valid");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_encoding_ascii_is_alpha");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==2)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_base64_encode_standard");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_base64_decode_standard");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==3)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_http_get");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_http_request");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_http_client_new");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==4)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_json_parse");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_json_stringify");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==5)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_csv_next_field");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_csv_parse_line");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==6)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_path_join");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_path_dirname");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_path_empty_len");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_path_basename");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==7)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_hash_sip_hash");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_hash_fnv1a");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_hash_start");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_hash_bytes");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_hash_finish");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_hash_free");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_hash_write_u8_ptr_u32");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==8)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_error_http_err_timeout");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_error_ok");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_error_io_err_timeout");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_error_io_err_cancelled");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==9)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_context_background");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_context_deadline_ns");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_context_is_cancelled");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_context_remaining_ns");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==10)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_vec_new_retVec_u8");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_vec_new_retVec_i32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_vec_push_Vec_u8_ptr_u8");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_vec_push_Vec_i32_ptr_i32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_vec_len_Vec_u8");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_vec_len_Vec_i32");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_vec_len_empty");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_vec_vec_len_empty");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_vec_new");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"std_vec_push");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==11)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_sort_sort_i32_ptr_i32");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_sort_sort_u8_ptr_i32");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_sort_stable_i32_ptr_i32");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_sort_stable_u8_ptr_i32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_sort_stable_by_key");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_sort_cmp");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_sort_cmp_asc_fn");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_sort_cmp_desc_fn");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_sort_cmp_key_fn");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==12)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_env_getenv");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_env_getenv_exists");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_env_getenv_z");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_env_getenv_ptr");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_env_setenv");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_env_unsetenv");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_env_temp_dir");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_env_iter");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_env_iter_count");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"std_env_args_iter");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==13)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_random_next");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_random_fill_bytes");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_random_fill");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_random_range_u32_u32");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_random_flip");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_random_gen");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_random_rng_smoke");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_random_seed");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"random_u32_c");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"random_u64_c");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"random_rng_smoke_c");
      return p;
    }
    if ((i ==11)) {
      uint8_t * p = ((uint8_t *)"random_fill_bytes_c");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==14)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_time_now_monotonic_ns");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_time_now_monotonic_ms");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_time_now_wall_ns");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_time_sleep_ms");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_time_sleep_ns");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_time_duration_ns");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_time_timer_start");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_time_start");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_time_elapsed_ns");
      return p;
    }
    if ((i ==9)) {
      uint8_t * p = ((uint8_t *)"std_time_format_wall_rfc3339");
      return p;
    }
    if ((i ==10)) {
      uint8_t * p = ((uint8_t *)"std_time_wall_local_offset_min");
      return p;
    }
    if ((i ==11)) {
      uint8_t * p = ((uint8_t *)"std_time_format_timezone_smoke");
      return p;
    }
    if ((i ==12)) {
      uint8_t * p = ((uint8_t *)"time_now_monotonic_ns_c");
      return p;
    }
    if ((i ==13)) {
      uint8_t * p = ((uint8_t *)"time_sleep_ns_c");
      return p;
    }
    if ((i ==14)) {
      uint8_t * p = ((uint8_t *)"time_now_wall_ns_c");
      return p;
    }
    return ((uint8_t *)(0));
  }
  if ((k ==15)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"std_fs_invalid");
      return p;
    }
    if ((i ==1)) {
      uint8_t * p = ((uint8_t *)"std_fs_open");
      return p;
    }
    if ((i ==2)) {
      uint8_t * p = ((uint8_t *)"std_fs_create");
      return p;
    }
    if ((i ==3)) {
      uint8_t * p = ((uint8_t *)"std_fs_close");
      return p;
    }
    if ((i ==4)) {
      uint8_t * p = ((uint8_t *)"std_fs_read");
      return p;
    }
    if ((i ==5)) {
      uint8_t * p = ((uint8_t *)"std_fs_write");
      return p;
    }
    if ((i ==6)) {
      uint8_t * p = ((uint8_t *)"std_fs_chunk_size");
      return p;
    }
    if ((i ==7)) {
      uint8_t * p = ((uint8_t *)"std_fs_mmap_ro");
      return p;
    }
    if ((i ==8)) {
      uint8_t * p = ((uint8_t *)"std_fs_last_error");
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
        uint8_t * hitp = ((uint8_t *)(0));
        (void)((hitp = strstr(rel, needle)));
        if ((hitp !=0)) {
          (void)((kind = k));
          (void)((k = nk));
        }
      }
    }
    (void)((k = (k + 1)));
  }
  if ((kind <0)) {
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
