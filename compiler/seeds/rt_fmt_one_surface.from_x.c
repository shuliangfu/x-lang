/* seeds/rt_fmt_one_surface.from_x.c
 * G-02f rt_fmt_one R2 full surface — isomorphic with src/runtime/rt_fmt_one.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_fmt_one.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (driver_fmt_one_file + path helpers)
 * Regen: ./shux -E ... src/runtime/rt_fmt_one.x | filter DBG + polish prologue
 * Track-L (2026-07-16): path helpers keep short names; .x has #[no_mangle] (was module mangle)
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
extern int32_t rt_fmt_path_copy_nul(uint8_t * path, int32_t path_len, uint8_t * path_buf);
extern int32_t rt_fmt_path_ends_x(uint8_t * path_buf, int32_t path_len);
extern int32_t driver_fmt_one_file(uint8_t * path, int32_t path_len);
extern uint8_t * runtime_read_file_malloc(uint8_t * path, size_t * out_len);
extern int32_t shu_format_x_document(uint8_t * doc, int32_t doc_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t driver_fmt_check_only_get(void);
extern int32_t shux_write_path_bytes(uint8_t * path, uint8_t * data, size_t len);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
int32_t rt_fmt_path_copy_nul(uint8_t * path, int32_t path_len, uint8_t * path_buf) {
  int32_t i = 0;
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((path_len <=0)) {
    return 0;
  }
  if ((path_len >=512)) {
    return 0;
  }
  while ((i < path_len)) {
    (void)(((path_buf)[((size_t)(i))] = (path)[((size_t)(i))]));
    (void)((i = (i + 1)));
  }
  (void)(((path_buf)[((size_t)(path_len))] = 0));
  return 1;
}
int32_t rt_fmt_path_ends_x(uint8_t * path_buf, int32_t path_len) {
  if ((path_len < 2)) {
    return 0;
  }
  if (((path_buf)[((size_t)((path_len - 2)))] !=46)) {
    return 0;
  }
  if (((path_buf)[((size_t)((path_len - 1)))] !=120)) {
    return 0;
  }
  return 1;
}
int32_t driver_fmt_one_file(uint8_t * path, int32_t path_len) {
  uint8_t path_buf[512] = {};
  uint8_t * raw = ((uint8_t *)(0));
  size_t raw_len = 0;
  size_t cap = 0;
  uint8_t * out = ((uint8_t *)(0));
  int32_t fmt_len = 0;
  int32_t changed = 0;
  uint8_t kind[16] = {};
  uint8_t code[8] = {};
  uint8_t msg[48] = {};
  uint8_t info_kind[8] = {};
  uint8_t ok_msg[16] = {};
  if ((rt_fmt_path_copy_nul(path, path_len, &((path_buf)[0])) ==0)) {
    return 1;
  }
  if ((rt_fmt_path_ends_x(&((path_buf)[0]), path_len) ==0)) {
    return 1;
  }
  (void)(((kind)[0] = 102));
  (void)(((kind)[1] = 109));
  (void)(((kind)[2] = 116));
  (void)(((kind)[3] = 32));
  (void)(((kind)[4] = 101));
  (void)(((kind)[5] = 114));
  (void)(((kind)[6] = 114));
  (void)(((kind)[7] = 111));
  (void)(((kind)[8] = 114));
  (void)(((kind)[9] = 0));
  (void)(((code)[0] = 70));
  (void)(((code)[1] = 77));
  (void)(((code)[2] = 84));
  (void)(((code)[3] = 48));
  (void)(((code)[4] = 48));
  (void)(((code)[5] = 49));
  (void)(((code)[6] = 0));
  {
    (void)((raw = runtime_read_file_malloc(&((path_buf)[0]), &(raw_len))));
  }
  if ((raw ==((uint8_t *)(0)))) {
    (void)(((msg)[0] = 99));
    (void)(((msg)[1] = 97));
    (void)(((msg)[2] = 110));
    (void)(((msg)[3] = 110));
    (void)(((msg)[4] = 111));
    (void)(((msg)[5] = 116));
    (void)(((msg)[6] = 32));
    (void)(((msg)[7] = 114));
    (void)(((msg)[8] = 101));
    (void)(((msg)[9] = 97));
    (void)(((msg)[10] = 100));
    (void)(((msg)[11] = 32));
    (void)(((msg)[12] = 102));
    (void)(((msg)[13] = 105));
    (void)(((msg)[14] = 108));
    (void)(((msg)[15] = 101));
    (void)(((msg)[16] = 0));
    {
      (void)(diag_report_with_code(&((path_buf)[0]), 0, 0, &((kind)[0]), &((code)[0]), &((msg)[0]), ((uint8_t *)(0))));
    }
    return 1;
  }
  (void)((cap = ((raw_len * ((size_t)(2))) + ((size_t)(4096)))));
  if ((cap < ((size_t)(65536)))) {
    (void)((cap = ((size_t)(65536))));
  }
  {
    (void)((out = malloc(cap)));
  }
  if ((out ==((uint8_t *)(0)))) {
    {
      (void)(free(raw));
    }
    (void)(((msg)[0] = 111));
    (void)(((msg)[1] = 117));
    (void)(((msg)[2] = 116));
    (void)(((msg)[3] = 32));
    (void)(((msg)[4] = 111));
    (void)(((msg)[5] = 102));
    (void)(((msg)[6] = 32));
    (void)(((msg)[7] = 109));
    (void)(((msg)[8] = 101));
    (void)(((msg)[9] = 109));
    (void)(((msg)[10] = 111));
    (void)(((msg)[11] = 114));
    (void)(((msg)[12] = 121));
    (void)(((msg)[13] = 32));
    (void)(((msg)[14] = 119));
    (void)(((msg)[15] = 104));
    (void)(((msg)[16] = 105));
    (void)(((msg)[17] = 108));
    (void)(((msg)[18] = 101));
    (void)(((msg)[19] = 32));
    (void)(((msg)[20] = 102));
    (void)(((msg)[21] = 111));
    (void)(((msg)[22] = 114));
    (void)(((msg)[23] = 109));
    (void)(((msg)[24] = 97));
    (void)(((msg)[25] = 116));
    (void)(((msg)[26] = 116));
    (void)(((msg)[27] = 105));
    (void)(((msg)[28] = 110));
    (void)(((msg)[29] = 103));
    (void)(((msg)[30] = 0));
    {
      (void)(diag_report_with_code(&((path_buf)[0]), 0, 0, &((kind)[0]), &((code)[0]), &((msg)[0]), ((uint8_t *)(0))));
    }
    return 1;
  }
  {
    (void)((fmt_len = shu_format_x_document(raw, ((int32_t)(raw_len)), out, ((int32_t)(cap)))));
  }
  if ((fmt_len < 0)) {
    {
      (void)(free(out));
      (void)(free(raw));
    }
    (void)(((msg)[0] = 102));
    (void)(((msg)[1] = 111));
    (void)(((msg)[2] = 114));
    (void)(((msg)[3] = 109));
    (void)(((msg)[4] = 97));
    (void)(((msg)[5] = 116));
    (void)(((msg)[6] = 32));
    (void)(((msg)[7] = 102));
    (void)(((msg)[8] = 97));
    (void)(((msg)[9] = 105));
    (void)(((msg)[10] = 108));
    (void)(((msg)[11] = 101));
    (void)(((msg)[12] = 100));
    (void)(((msg)[13] = 0));
    {
      (void)(diag_report_with_code(&((path_buf)[0]), 0, 0, &((kind)[0]), &((code)[0]), &((msg)[0]), ((uint8_t *)(0))));
    }
    return 1;
  }
  (void)((changed = 0));
  if ((((size_t)(fmt_len)) !=raw_len)) {
    (void)((changed = 1));
  } else {
    int32_t cmp = 0;
    {
      (void)((cmp = memcmp(raw, out, raw_len)));
    }
    if ((cmp !=0)) {
      (void)((changed = 1));
    }
  }
  if ((driver_fmt_check_only_get() !=0)) {
    {
      (void)(free(out));
      (void)(free(raw));
    }
    if ((changed !=0)) {
      return 1;
    }
    return 0;
  }
  if ((changed !=0)) {
    int32_t wr = 0;
    {
      (void)((wr = shux_write_path_bytes(&((path_buf)[0]), out, ((size_t)(fmt_len)))));
    }
    if ((wr !=0)) {
      {
        (void)(free(out));
        (void)(free(raw));
      }
      (void)(((msg)[0] = 119));
      (void)(((msg)[1] = 114));
      (void)(((msg)[2] = 105));
      (void)(((msg)[3] = 116));
      (void)(((msg)[4] = 101));
      (void)(((msg)[5] = 32));
      (void)(((msg)[6] = 102));
      (void)(((msg)[7] = 97));
      (void)(((msg)[8] = 105));
      (void)(((msg)[9] = 108));
      (void)(((msg)[10] = 101));
      (void)(((msg)[11] = 100));
      (void)(((msg)[12] = 0));
      {
        (void)(diag_report_with_code(&((path_buf)[0]), 0, 0, &((kind)[0]), &((code)[0]), &((msg)[0]), ((uint8_t *)(0))));
      }
      return 1;
    }
    (void)(((info_kind)[0] = 105));
    (void)(((info_kind)[1] = 110));
    (void)(((info_kind)[2] = 102));
    (void)(((info_kind)[3] = 111));
    (void)(((info_kind)[4] = 0));
    (void)(((ok_msg)[0] = 102));
    (void)(((ok_msg)[1] = 109));
    (void)(((ok_msg)[2] = 116));
    (void)(((ok_msg)[3] = 32));
    (void)(((ok_msg)[4] = 79));
    (void)(((ok_msg)[5] = 75));
    (void)(((ok_msg)[6] = 0));
    {
      (void)(diag_report_with_code(((uint8_t *)(0)), 0, 0, &((info_kind)[0]), ((uint8_t *)(0)), &((ok_msg)[0]), &((path_buf)[0])));
    }
  }
  {
    (void)(free(out));
    (void)(free(raw));
  }
  return 0;
}
