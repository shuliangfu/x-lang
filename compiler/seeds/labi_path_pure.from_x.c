/* seeds/labi_path_pure.from_x.c — G-02f-267/429/L P2 link_abi L0 path pure
 * Logic source: src/runtime/labi_path_pure.x
 * Regen: ./shux -E -L .. -L src/runtime src/runtime/labi_path_pure.x
 * Hybrid: SHUX_LABI_PATH_PURE_FROM_X + ld -r into runtime_link_abi.o
 * G-02f-L：i32 长度 + suffix helpers + want_exe；与 .x -E nm IDENTICAL。
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1);
extern int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
extern int32_t shux_output_is_elf_o(uint8_t * path);
extern int32_t shux_output_want_exe(uint8_t * path);
extern int32_t shux_path_has_sep(uint8_t * s);
extern uint8_t * shux_path_last_sep(uint8_t * s);
int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1) {
  if ((n < 2)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a1)) {
    return 0;
  }
  return 1;
}
int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3) {
  if ((n < 4)) {
    return 0;
  }
  if (((s)[(n - 4)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 3)] !=a1)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a2)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a3)) {
    return 0;
  }
  return 1;
}
int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s) {
  int32_t n = 0;
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] ==0)) {
    return 0;
  }
  while (((s)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(s, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(s, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t shux_output_is_elf_o(uint8_t * path) {
  int32_t n = 0;
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t shux_output_want_exe(uint8_t * path) {
  int32_t n = 0;
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 115) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 0;
  }
  return 1;
}
int32_t shux_path_has_sep(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * shux_path_last_sep(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  int32_t last = 0;
  int32_t found = 0;
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      (void)((last = i));
      (void)((found = 1));
    }
    (void)((i = (i + 1)));
  }
  if ((found ==0)) {
    return ((uint8_t *)(0));
  }
  size_t base = ((size_t)(s));
  return ((uint8_t *)((base + ((size_t)(last)))));
}
