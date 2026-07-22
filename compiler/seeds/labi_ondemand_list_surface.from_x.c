/* seeds/labi_ondemand_list_surface.from_x.c
 * G-02f labi_ondemand_list R2 full surface — isomorphic with src/runtime/labi_ondemand_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_ondemand_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (on_demand tables + wave118–129 needs_std_net/set/map/queue/test + needs_core_mem/slice + needs_std_heap_page_mmap + needs_std_sys_linux + needs_std_sys + needs_std_heap_api + needs_heap_user_syms pure)
 * Cap residual: nm/push/ensure + undef_sym probes in mega
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
extern int32_t shux_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
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
