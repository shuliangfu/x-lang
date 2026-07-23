/* seeds/rt_pipeline_elf_diag_surface.from_x.c
 * G-02f rt_pipeline_elf_diag R2 full surface — isomorphic with src/runtime/rt_pipeline_elf_diag.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_pipeline_elf_diag.x) + hybrid rest seed
 *   seeds/rt_pipeline_elf_diag.from_x.c (-DXLANG_RT_PIPELINE_ELF_DIAG_FROM_X) ld -r into runtime_driver_no_c
 * Hybrid rest seed: FROM_X 仅 marker（业务 H=0）；冷启动全 C 体
 * Prove: full.x vs this seed → nm IDENTICAL (public surface)
 * Regen: ./xlang -E ... src/runtime/rt_pipeline_elf_diag.x | filter DBG + polish
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t rt_elf_load_i32_le(uint8_t * base, int32_t off);
extern uint8_t * rt_elf_name_at(uint8_t * base, int32_t entry_off, int32_t name_rel);
extern int32_t rt_elf_names_eq(uint8_t * a, uint8_t * b, int32_t n);
extern int32_t rt_elf_strlen(uint8_t * s);
extern void rt_elf_append(uint8_t * dst, int32_t cap, uint8_t * src);
extern void rt_elf_append_i32(uint8_t * dst, int32_t cap, int32_t v);
extern void rt_elf_note_kind(uint8_t * kind);
extern void rt_elf_report_note(uint8_t * msg);
extern void runtime_pipeline_elf_ctx_diag_note(uint8_t * ctx_bytes);
static const int32_t RT_ELF_CTX_TABLE_CAP = 16384;
static const int32_t RT_ELF_LABEL_ENTRY_SIZE = 72;
static const int32_t RT_ELF_PATCH_ENTRY_SIZE = 76;
static const int32_t RT_ELF_LABELS_OFF = 4;
static const int32_t RT_ELF_NUM_LABELS_OFF = 1179652;
static const int32_t RT_ELF_PATCHES_OFF = 1179656;
static const int32_t RT_ELF_NUM_PATCHES_OFF = 2424840;
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
int32_t rt_elf_load_i32_le(uint8_t * base, int32_t off) {
  if ((base ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((off < 0)) {
    return 0;
  }
  {
    uint8_t * q = (base + off);
    int32_t m = 256;
    int32_t a0 = ((int32_t)((q)[0]));
    int32_t a1 = (a0 + (((int32_t)((q)[1])) * m));
    int32_t a2 = (a1 + ((((int32_t)((q)[2])) * m) * m));
    int32_t a3 = (a2 + (((((int32_t)((q)[3])) * m) * m) * m));
    return a3;
  }
  return 0;
}
uint8_t * rt_elf_name_at(uint8_t * base, int32_t entry_off, int32_t name_rel) {
  if ((base ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if ((entry_off < 0)) {
    return ((uint8_t *)(0));
  }
  if ((name_rel < 0)) {
    return ((uint8_t *)(0));
  }
  {
    return (base + (entry_off + name_rel));
  }
  return ((uint8_t *)(0));
}
int32_t rt_elf_names_eq(uint8_t * a, uint8_t * b, int32_t n) {
  int32_t i = 0;
  if ((n <=0)) {
    return 1;
  }
  if ((a ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((b ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((i < n)) {
    if (((a)[((size_t)(i))] !=(b)[((size_t)(i))])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t rt_elf_strlen(uint8_t * s) {
  int32_t i = 0;
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((i < 512)) {
    if (((s)[((size_t)(i))] ==0)) {
      return i;
    }
    (void)((i = (i + 1)));
  }
  return i;
}
void rt_elf_append(uint8_t * dst, int32_t cap, uint8_t * src) {
  int32_t dlen = 0;
  int32_t slen = 0;
  int32_t i = 0;
  if ((dst ==((uint8_t *)(0)))) {
    return;
  }
  if ((src ==((uint8_t *)(0)))) {
    return;
  }
  if ((cap <=1)) {
    return;
  }
  (void)((dlen = rt_elf_strlen(dst)));
  (void)((slen = rt_elf_strlen(src)));
  while ((i < slen)) {
    if (((dlen + 1) >=cap)) {
      break;
    }
    (void)(((dst)[((size_t)(dlen))] = (src)[((size_t)(i))]));
    (void)((dlen = (dlen + 1)));
    (void)((i = (i + 1)));
  }
  (void)(((dst)[((size_t)(dlen))] = 0));
}
void rt_elf_append_i32(uint8_t * dst, int32_t cap, int32_t v) {
  uint8_t dig[16] = {};
  int32_t n = v;
  int32_t i = 0;
  int32_t j = 0;
  int32_t neg = 0;
  uint8_t a = 0;
  (void)(((dig)[0] = 0));
  if ((n ==0)) {
    (void)(((dig)[0] = 48));
    (void)(((dig)[1] = 0));
    (void)(rt_elf_append(dst, cap, &((dig)[0])));
    return;
  }
  if ((n < 0)) {
    (void)((neg = 1));
    (void)((n = (0 - n)));
  }
  while ((n > 0)) {
    if ((i >=15)) {
      break;
    }
    (void)(((dig)[i] = ((uint8_t)((48 + (n - ((n / 10) * 10)))))));
    (void)((n = (n / 10)));
    (void)((i = (i + 1)));
  }
  if ((neg !=0)) {
    if ((i < 15)) {
      (void)(((dig)[i] = 45));
      (void)((i = (i + 1)));
    }
  }
  (void)((j = 0));
  while ((j < (i / 2))) {
    (void)((a = (dig)[j]));
    (void)(((dig)[j] = (dig)[((i - 1) - j)]));
    (void)(((dig)[((i - 1) - j)] = a));
    (void)((j = (j + 1)));
  }
  (void)(((dig)[i] = 0));
  (void)(rt_elf_append(dst, cap, &((dig)[0])));
}
void rt_elf_note_kind(uint8_t * kind) {
  (void)(((kind)[0] = 110));
  (void)(((kind)[1] = 111));
  (void)(((kind)[2] = 116));
  (void)(((kind)[3] = 101));
  (void)(((kind)[4] = 0));
}
void rt_elf_report_note(uint8_t * msg) {
  uint8_t kind[8] = {};
  (void)(rt_elf_note_kind(&((kind)[0])));
  {
    (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, &((kind)[0]), ((uint8_t *)(0)), msg, ((uint8_t *)(0))));
  }
}
void runtime_pipeline_elf_ctx_diag_note(uint8_t * ctx_bytes) {
  int32_t code_len = 0;
  int32_t num_labels = 0;
  int32_t num_patches = 0;
  uint8_t msg[192] = {};
  int32_t name_len = 0;
  int32_t l = 0;
  int32_t p_base = 0;
  uint8_t * p_name = ((uint8_t *)(0));
  int32_t lbl_base = 0;
  uint8_t * lbl_name = ((uint8_t *)(0));
  int32_t lbl_nl = 0;
  int32_t lbl_off = 0;
  int32_t same = 0;
  int32_t i = 0;
  uint8_t namebuf[65] = {};
  if ((ctx_bytes ==((uint8_t *)(0)))) {
    return;
  }
  (void)((code_len = rt_elf_load_i32_le(ctx_bytes, 0)));
  (void)((num_labels = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_LABELS_OFF)));
  (void)((num_patches = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_PATCHES_OFF)));
  (void)(((msg)[0] = 0));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){101, 108, 102, 32, 99, 116, 120, 32, 99, 111, 100, 101, 95, 108, 101, 110, 61, 0 }))));
  (void)(rt_elf_append_i32(&((msg)[0]), 192, code_len));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){32, 110, 117, 109, 95, 108, 97, 98, 101, 108, 115, 61, 0 }))));
  (void)(rt_elf_append_i32(&((msg)[0]), 192, num_labels));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){32, 110, 117, 109, 95, 112, 97, 116, 99, 104, 101, 115, 61, 0 }))));
  (void)(rt_elf_append_i32(&((msg)[0]), 192, num_patches));
  (void)(rt_elf_report_note(&((msg)[0])));
  if ((num_patches <=0)) {
    return;
  }
  (void)((p_base = RT_ELF_PATCHES_OFF));
  (void)((name_len = rt_elf_load_i32_le(ctx_bytes, (p_base + 68))));
  if ((name_len > 64)) {
    (void)((name_len = 64));
  }
  if ((name_len < 0)) {
    (void)((name_len = 0));
  }
  (void)((p_name = rt_elf_name_at(ctx_bytes, p_base, 4)));
  (void)((i = 0));
  while ((i < name_len)) {
    if ((p_name !=((uint8_t *)(0)))) {
      (void)(((namebuf)[i] = (p_name)[((size_t)(i))]));
    } else {
      (void)(((namebuf)[i] = 0));
    }
    (void)((i = (i + 1)));
  }
  (void)(((namebuf)[name_len] = 0));
  (void)(((msg)[0] = 0));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){101, 108, 102, 32, 102, 105, 114, 115, 116, 32, 112, 97, 116, 99, 104, 32, 110, 97, 109, 101, 95, 108, 101, 110, 61, 0 }))));
  (void)(rt_elf_append_i32(&((msg)[0]), 192, name_len));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){32, 110, 97, 109, 101, 61, 39, 0 }))));
  (void)(rt_elf_append(&((msg)[0]), 192, &((namebuf)[0])));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){39, 0 }))));
  (void)(rt_elf_report_note(&((msg)[0])));
  (void)((l = 0));
  while ((l < num_labels)) {
    if ((l >=RT_ELF_CTX_TABLE_CAP)) {
      break;
    }
    (void)((lbl_base = (RT_ELF_LABELS_OFF + (l * RT_ELF_LABEL_ENTRY_SIZE))));
    (void)((lbl_nl = rt_elf_load_i32_le(ctx_bytes, (lbl_base + 64))));
    (void)((same = 0));
    if ((lbl_nl ==name_len)) {
      (void)((same = 1));
    }
    if ((same !=0)) {
      if ((name_len > 0)) {
        (void)((lbl_name = rt_elf_name_at(ctx_bytes, lbl_base, 0)));
        (void)((same = rt_elf_names_eq(lbl_name, p_name, name_len)));
      }
    }
    if ((same !=0)) {
      (void)((lbl_off = rt_elf_load_i32_le(ctx_bytes, (lbl_base + 68))));
      (void)(((msg)[0] = 0));
      (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){101, 108, 102, 32, 108, 97, 98, 101, 108, 32, 109, 97, 116, 99, 104, 32, 97, 116, 32, 105, 100, 120, 61, 0 }))));
      (void)(rt_elf_append_i32(&((msg)[0]), 192, l));
      (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){32, 111, 102, 102, 115, 101, 116, 61, 0 }))));
      (void)(rt_elf_append_i32(&((msg)[0]), 192, lbl_off));
      (void)(rt_elf_report_note(&((msg)[0])));
      return;
    }
    (void)((l = (l + 1)));
  }
  (void)(((msg)[0] = 0));
  (void)(rt_elf_append(&((msg)[0]), 192, ((uint8_t *)((uint8_t[]){101, 108, 102, 32, 110, 111, 32, 108, 97, 98, 101, 108, 32, 109, 97, 116, 99, 104, 32, 102, 111, 114, 32, 102, 105, 114, 115, 116, 32, 112, 97, 116, 99, 104, 0 }))));
  (void)(rt_elf_report_note(&((msg)[0])));
}
