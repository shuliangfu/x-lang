/* seeds/rt_emit_state_surface.from_x.c
 * G-02f rt_emit_state R2 full surface — isomorphic with src/runtime/rt_emit_state.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_emit_state.x) + rest seed BSS+marker under FROM_X
 * Cap-global-bss residual: path/lib slots + bind APIs in driver_abi; BSS in rest seed
 * Prove: full.x vs this seed → nm IDENTICAL (public surface)
 * Regen: ./shux -E ... src/runtime/rt_emit_state.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t rt_emit_max_lib_roots(void);
extern int32_t rt_emit_path_cap(void);
extern int32_t rt_emit_lib_cap(void);
extern int32_t rt_argv_is_minus_L(uint8_t * s);
extern int32_t rt_argv_is_minus_x(uint8_t * s);
extern int32_t rt_argv_is_minus_E_tok(uint8_t * s);
extern void rt_emit_copy_n(uint8_t * dst, uint8_t * src, int32_t n);
extern int32_t driver_run_x_emit_c_set_path(uint8_t * path, int32_t path_len);
extern int32_t driver_run_x_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t driver_run_x_emit_c_set_n_lib_roots(int32_t n);
extern int32_t driver_run_x_emit_c_set_emit_extern(int32_t v);
extern int32_t rt_scan_x_emit_argv(int32_t argc, uint8_t * * argv, int32_t i);
extern int32_t driver_argv_parse_x_emit_c(int32_t argc, uint8_t * * argv);
extern uint8_t * driver_x_emit_path_buf_slot(void);
extern uint8_t * driver_x_emit_lib_buf_slot(int32_t i);
extern uint8_t * driver_x_emit_scan_ab_slot(void);
extern uint8_t * driver_x_emit_scan_nx_slot(void);
extern void driver_x_emit_clear_c_path(void);
extern void driver_x_emit_bind_c_path_to_buf(void);
extern void driver_x_emit_bind_lib_root(int32_t i);
extern int32_t * driver_x_emit_n_lib_roots_slot(void);
extern int32_t * driver_x_emit_want_extern_slot(void);
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * * argv, int32_t i, uint8_t * buf, int32_t max);
int32_t rt_emit_max_lib_roots(void) {
  return 16;
}
int32_t rt_emit_path_cap(void) {
  return 512;
}
int32_t rt_emit_lib_cap(void) {
  return 256;
}
int32_t rt_argv_is_minus_L(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] !=45)) {
    return 0;
  }
  if (((s)[1] !=76)) {
    return 0;
  }
  if (((s)[2] !=0)) {
    return 0;
  }
  return 1;
}
int32_t rt_argv_is_minus_x(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] !=45)) {
    return 0;
  }
  if (((s)[1] !=120)) {
    return 0;
  }
  if (((s)[2] !=0)) {
    return 0;
  }
  return 1;
}
int32_t rt_argv_is_minus_E_tok(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] !=45)) {
    return 0;
  }
  if (((s)[1] !=69)) {
    return 0;
  }
  if (((s)[2] !=0)) {
    return 0;
  }
  return 1;
}
void rt_emit_copy_n(uint8_t * dst, uint8_t * src, int32_t n) {
  int32_t ci = 0;
  if ((dst ==((uint8_t *)(0)))) {
    return;
  }
  if ((src ==((uint8_t *)(0)))) {
    (void)(((dst)[0] = 0));
    return;
  }
  while ((ci < n)) {
    (void)(((dst)[((size_t)(ci))] = (src)[((size_t)(ci))]));
    (void)((ci = (ci + 1)));
  }
  (void)(((dst)[((size_t)(n))] = 0));
}
int32_t driver_run_x_emit_c_set_path(uint8_t * path, int32_t path_len) {
  uint8_t * set_pbuf = ((uint8_t *)(0));
  int32_t set_cap = 0;
  {
    (void)(driver_x_emit_clear_c_path());
  }
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((path_len <=0)) {
    return 0;
  }
  (void)((set_cap = rt_emit_path_cap()));
  if ((path_len >=set_cap)) {
    return 0;
  }
  {
    (void)((set_pbuf = driver_x_emit_path_buf_slot()));
  }
  if ((set_pbuf ==((uint8_t *)(0)))) {
    return 0;
  }
  (void)(rt_emit_copy_n(set_pbuf, path, path_len));
  {
    (void)(driver_x_emit_bind_c_path_to_buf());
  }
  return 0;
}
int32_t driver_run_x_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len) {
  uint8_t * set_lbuf = ((uint8_t *)(0));
  int32_t set_maxr = 0;
  int32_t set_lcap = 0;
  (void)((set_maxr = rt_emit_max_lib_roots()));
  (void)((set_lcap = rt_emit_lib_cap()));
  if ((i < 0)) {
    return 0;
  }
  if ((i >=set_maxr)) {
    return 0;
  }
  if ((buf ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((len < 0)) {
    return 0;
  }
  if ((len >=set_lcap)) {
    return 0;
  }
  {
    (void)((set_lbuf = driver_x_emit_lib_buf_slot(i)));
  }
  if ((set_lbuf ==((uint8_t *)(0)))) {
    return 0;
  }
  (void)(rt_emit_copy_n(set_lbuf, buf, len));
  {
    (void)(driver_x_emit_bind_lib_root(i));
  }
  return 0;
}
int32_t driver_run_x_emit_c_set_n_lib_roots(int32_t n) {
  int32_t * n_slot = ((int32_t *)(0));
  int32_t n_maxr = 0;
  int32_t n_v = 0;
  (void)((n_maxr = rt_emit_max_lib_roots()));
  if ((n >=0)) {
    if ((n <=n_maxr)) {
      (void)((n_v = n));
    }
  }
  {
    (void)((n_slot = driver_x_emit_n_lib_roots_slot()));
  }
  if ((n_slot !=((int32_t *)(0)))) {
    (void)(((n_slot)[0] = n_v));
  }
  return 0;
}
int32_t driver_run_x_emit_c_set_emit_extern(int32_t v) {
  int32_t * w_slot = ((int32_t *)(0));
  int32_t w_out = 0;
  if ((v !=0)) {
    (void)((w_out = 1));
  }
  {
    (void)((w_slot = driver_x_emit_want_extern_slot()));
  }
  if ((w_slot !=((int32_t *)(0)))) {
    (void)(((w_slot)[0] = w_out));
  }
  return 0;
}
int32_t rt_scan_x_emit_argv(int32_t argc, uint8_t * * argv, int32_t i) {
  uint8_t * sc_ab = ((uint8_t *)(0));
  uint8_t * sc_nx = ((uint8_t *)(0));
  int32_t sc_ln = 0;
  int32_t sc_k = 0;
  int32_t * sc_nslot = ((int32_t *)(0));
  uint8_t * sc_pbuf = ((uint8_t *)(0));
  uint8_t * sc_lbuf = ((uint8_t *)(0));
  int32_t sc_maxr = 0;
  if ((i >=argc)) {
    return 0;
  }
  {
    (void)((sc_ab = driver_x_emit_scan_ab_slot()));
  }
  if ((sc_ab ==((uint8_t *)(0)))) {
    return 0;
  }
  {
    (void)((sc_ln = driver_get_argv_i(argc, argv, i, sc_ab, 512)));
  }
  if ((sc_ln < 0)) {
    return rt_scan_x_emit_argv(argc, argv, (i + 1));
  }
  if ((rt_argv_is_minus_L(sc_ab) !=0)) {
    if (((i + 1) >=argc)) {
      return rt_scan_x_emit_argv(argc, argv, (i + 1));
    }
    {
      (void)((sc_nslot = driver_x_emit_n_lib_roots_slot()));
    }
    (void)((sc_k = 0));
    if ((sc_nslot !=((int32_t *)(0)))) {
      (void)((sc_k = (sc_nslot)[0]));
    }
    (void)((sc_maxr = rt_emit_max_lib_roots()));
    if ((sc_k < sc_maxr)) {
      {
        (void)((sc_lbuf = driver_x_emit_lib_buf_slot(sc_k)));
      }
      if ((sc_lbuf !=((uint8_t *)(0)))) {
        {
          (void)((sc_ln = driver_get_argv_i(argc, argv, (i + 1), sc_lbuf, 256)));
        }
        if ((sc_ln < 0)) {
          return 0;
        }
        {
          (void)(driver_x_emit_bind_lib_root(sc_k));
        }
        if ((sc_nslot !=((int32_t *)(0)))) {
          (void)(((sc_nslot)[0] = (sc_k + 1)));
        }
      }
    }
    return rt_scan_x_emit_argv(argc, argv, (i + 2));
  }
  if ((rt_argv_is_minus_x(sc_ab) !=0)) {
    if (((i + 2) >=argc)) {
      return rt_scan_x_emit_argv(argc, argv, (i + 1));
    }
    {
      (void)((sc_nx = driver_x_emit_scan_nx_slot()));
    }
    if ((sc_nx ==((uint8_t *)(0)))) {
      return 0;
    }
    {
      (void)((sc_ln = driver_get_argv_i(argc, argv, (i + 1), sc_nx, 512)));
    }
    if ((sc_ln < 0)) {
      return rt_scan_x_emit_argv(argc, argv, (i + 1));
    }
    if ((rt_argv_is_minus_E_tok(sc_nx) ==0)) {
      return rt_scan_x_emit_argv(argc, argv, (i + 1));
    }
    {
      (void)((sc_pbuf = driver_x_emit_path_buf_slot()));
    }
    if ((sc_pbuf ==((uint8_t *)(0)))) {
      return 0;
    }
    {
      (void)((sc_ln = driver_get_argv_i(argc, argv, (i + 2), sc_pbuf, 512)));
    }
    if ((sc_ln < 0)) {
      return 0;
    }
    {
      (void)(driver_x_emit_bind_c_path_to_buf());
    }
    return 1;
  }
  return rt_scan_x_emit_argv(argc, argv, (i + 1));
}
int32_t driver_argv_parse_x_emit_c(int32_t argc, uint8_t * * argv) {
  int32_t * pr_nslot = ((int32_t *)(0));
  {
    (void)(driver_x_emit_clear_c_path());
    (void)((pr_nslot = driver_x_emit_n_lib_roots_slot()));
  }
  if ((pr_nslot !=((int32_t *)(0)))) {
    (void)(((pr_nslot)[0] = 0));
  }
  if ((argc < 4)) {
    return 0;
  }
  return rt_scan_x_emit_argv(argc, argv, 1);
}
