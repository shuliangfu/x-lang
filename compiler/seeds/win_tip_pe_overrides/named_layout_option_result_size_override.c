/* PLATFORM: WINDOWS tip PE — Option_i32/Result_* named layout size floor.
 *
 * Win tip lays value@+8 (align) but glue_type_named_layout_size soft-floors to 8.
 * That skips w1545 mid-named byref (needs 9..16): caller packs lo8 into rcx,
 * callee homes 8B then reads value@+8 → wrong/SEGV. Mac packs value@+4 size 8
 * (one GP) so L2 stays green. Soft Cap Prefer body copy banned.
 *
 * Fix: after original size, if TYPE_NAMED soft ≤8 and bare name is Option_* or
 * Result_*, return 16 so w1545 mid→24 byref + param home width fire.
 */
#include <stdint.h>

extern int32_t glue_type_named_layout_size_any_module_elf_c__orig(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ty_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ty_ref, uint8_t *buf);

static int32_t bare_is_option_or_result(const uint8_t *name, int32_t nlen) {
  int32_t base = 0;
  int32_t i;
  int32_t len;
  const uint8_t *s;
  for (i = 0; i < nlen; i++) {
    if (name[i] == (uint8_t)'.')
      base = i + 1;
  }
  len = nlen - base;
  s = name + base;
  if (len >= 7 && s[0] == 'O' && s[1] == 'p' && s[2] == 't' && s[3] == 'i' &&
      s[4] == 'o' && s[5] == 'n' && s[6] == '_')
    return 1;
  if (len >= 7 && s[0] == 'R' && s[1] == 'e' && s[2] == 's' && s[3] == 'u' &&
      s[4] == 'l' && s[5] == 't' && s[6] == '_')
    return 1;
  return 0;
}

int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref) {
  int32_t sz;
  int32_t tk;
  int32_t nlen;
  uint8_t name[256];
  sz = glue_type_named_layout_size_any_module_elf_c__orig(arena, ty_ref);
  if (sz > 8)
    return sz;
  if (arena == 0 || ty_ref <= 0)
    return sz;
  tk = pipeline_type_kind_ord_at(arena, ty_ref);
  if (tk != 8)
    return sz;
  nlen = pipeline_type_named_name_into(arena, ty_ref, &name[0]);
  if (nlen <= 0 || nlen > 255)
    return sz;
  if (bare_is_option_or_result(&name[0], nlen) != 0)
    return 16;
  return sz;
}
