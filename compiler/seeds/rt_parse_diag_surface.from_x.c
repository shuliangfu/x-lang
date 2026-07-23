/* seeds/rt_parse_diag_surface.from_x.c
 * G-02f rt_parse_diag R2 full surface — isomorphic with src/runtime/rt_parse_diag.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_parse_diag.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (runtime_report_precise_parse_failure_if_known)
 * Regen: ./xlang -E ... src/runtime/rt_parse_diag.x | filter DBG + polish prologue
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
extern int32_t runtime_report_precise_parse_failure_if_known(uint8_t * input_path, uint8_t * src, size_t src_len);
static const int32_t RT_PARSE_TOKEN_STRING = 130;
extern int32_t parser_diag_fail_at_token_kind_buf(uint8_t * data, int32_t len);
extern void diag_report_with_code(uint8_t * file, int32_t line, int32_t col, uint8_t * kind, uint8_t * code, uint8_t * msg, uint8_t * detail);
int32_t runtime_report_precise_parse_failure_if_known(uint8_t * input_path, uint8_t * src, size_t src_len) {
  int32_t fail_tok = 0;
  int32_t n = 0;
  uint8_t kind[16] = {};
  uint8_t code[8] = {};
  uint8_t msg[140] = {};
  if ((src ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((src_len ==((size_t)(0)))) {
    return 0;
  }
  (void)((n = ((int32_t)(src_len))));
  if ((n <=0)) {
    return 0;
  }
  {
    (void)((fail_tok = parser_diag_fail_at_token_kind_buf(src, n)));
  }
  if ((fail_tok !=RT_PARSE_TOKEN_STRING)) {
    return 0;
  }
  (void)(((kind)[0] = 112));
  (void)(((kind)[1] = 97));
  (void)(((kind)[2] = 114));
  (void)(((kind)[3] = 115));
  (void)(((kind)[4] = 101));
  (void)(((kind)[5] = 32));
  (void)(((kind)[6] = 101));
  (void)(((kind)[7] = 114));
  (void)(((kind)[8] = 114));
  (void)(((kind)[9] = 111));
  (void)(((kind)[10] = 114));
  (void)(((kind)[11] = 0));
  (void)(((code)[0] = 80));
  (void)(((code)[1] = 48));
  (void)(((code)[2] = 48));
  (void)(((code)[3] = 49));
  (void)(((code)[4] = 0));
  (void)(((msg)[0] = 101));
  (void)(((msg)[1] = 120));
  (void)(((msg)[2] = 112));
  (void)(((msg)[3] = 101));
  (void)(((msg)[4] = 99));
  (void)(((msg)[5] = 116));
  (void)(((msg)[6] = 101));
  (void)(((msg)[7] = 100));
  (void)(((msg)[8] = 32));
  (void)(((msg)[9] = 105));
  (void)(((msg)[10] = 110));
  (void)(((msg)[11] = 116));
  (void)(((msg)[12] = 101));
  (void)(((msg)[13] = 103));
  (void)(((msg)[14] = 101));
  (void)(((msg)[15] = 114));
  (void)(((msg)[16] = 32));
  (void)(((msg)[17] = 108));
  (void)(((msg)[18] = 105));
  (void)(((msg)[19] = 116));
  (void)(((msg)[20] = 101));
  (void)(((msg)[21] = 114));
  (void)(((msg)[22] = 97));
  (void)(((msg)[23] = 108));
  (void)(((msg)[24] = 44));
  (void)(((msg)[25] = 32));
  (void)(((msg)[26] = 102));
  (void)(((msg)[27] = 108));
  (void)(((msg)[28] = 111));
  (void)(((msg)[29] = 97));
  (void)(((msg)[30] = 116));
  (void)(((msg)[31] = 32));
  (void)(((msg)[32] = 108));
  (void)(((msg)[33] = 105));
  (void)(((msg)[34] = 116));
  (void)(((msg)[35] = 101));
  (void)(((msg)[36] = 114));
  (void)(((msg)[37] = 97));
  (void)(((msg)[38] = 108));
  (void)(((msg)[39] = 44));
  (void)(((msg)[40] = 32));
  (void)(((msg)[41] = 105));
  (void)(((msg)[42] = 100));
  (void)(((msg)[43] = 101));
  (void)(((msg)[44] = 110));
  (void)(((msg)[45] = 116));
  (void)(((msg)[46] = 105));
  (void)(((msg)[47] = 102));
  (void)(((msg)[48] = 105));
  (void)(((msg)[49] = 101));
  (void)(((msg)[50] = 114));
  (void)(((msg)[51] = 44));
  (void)(((msg)[52] = 32));
  (void)(((msg)[53] = 39));
  (void)(((msg)[54] = 116));
  (void)(((msg)[55] = 114));
  (void)(((msg)[56] = 117));
  (void)(((msg)[57] = 101));
  (void)(((msg)[58] = 39));
  (void)(((msg)[59] = 44));
  (void)(((msg)[60] = 32));
  (void)(((msg)[61] = 39));
  (void)(((msg)[62] = 102));
  (void)(((msg)[63] = 97));
  (void)(((msg)[64] = 108));
  (void)(((msg)[65] = 115));
  (void)(((msg)[66] = 101));
  (void)(((msg)[67] = 39));
  (void)(((msg)[68] = 44));
  (void)(((msg)[69] = 32));
  (void)(((msg)[70] = 39));
  (void)(((msg)[71] = 105));
  (void)(((msg)[72] = 102));
  (void)(((msg)[73] = 39));
  (void)(((msg)[74] = 44));
  (void)(((msg)[75] = 32));
  (void)(((msg)[76] = 39));
  (void)(((msg)[77] = 98));
  (void)(((msg)[78] = 114));
  (void)(((msg)[79] = 101));
  (void)(((msg)[80] = 97));
  (void)(((msg)[81] = 107));
  (void)(((msg)[82] = 39));
  (void)(((msg)[83] = 44));
  (void)(((msg)[84] = 32));
  (void)(((msg)[85] = 39));
  (void)(((msg)[86] = 99));
  (void)(((msg)[87] = 111));
  (void)(((msg)[88] = 110));
  (void)(((msg)[89] = 116));
  (void)(((msg)[90] = 105));
  (void)(((msg)[91] = 110));
  (void)(((msg)[92] = 117));
  (void)(((msg)[93] = 101));
  (void)(((msg)[94] = 39));
  (void)(((msg)[95] = 44));
  (void)(((msg)[96] = 32));
  (void)(((msg)[97] = 39));
  (void)(((msg)[98] = 114));
  (void)(((msg)[99] = 101));
  (void)(((msg)[100] = 116));
  (void)(((msg)[101] = 117));
  (void)(((msg)[102] = 114));
  (void)(((msg)[103] = 110));
  (void)(((msg)[104] = 39));
  (void)(((msg)[105] = 44));
  (void)(((msg)[106] = 32));
  (void)(((msg)[107] = 39));
  (void)(((msg)[108] = 112));
  (void)(((msg)[109] = 97));
  (void)(((msg)[110] = 110));
  (void)(((msg)[111] = 105));
  (void)(((msg)[112] = 99));
  (void)(((msg)[113] = 39));
  (void)(((msg)[114] = 44));
  (void)(((msg)[115] = 32));
  (void)(((msg)[116] = 39));
  (void)(((msg)[117] = 109));
  (void)(((msg)[118] = 97));
  (void)(((msg)[119] = 116));
  (void)(((msg)[120] = 99));
  (void)(((msg)[121] = 104));
  (void)(((msg)[122] = 39));
  (void)(((msg)[123] = 44));
  (void)(((msg)[124] = 32));
  (void)(((msg)[125] = 111));
  (void)(((msg)[126] = 114));
  (void)(((msg)[127] = 32));
  (void)(((msg)[128] = 39));
  (void)(((msg)[129] = 40));
  (void)(((msg)[130] = 39));
  (void)(((msg)[131] = 0));
  {
    (void)(diag_report_with_code(input_path, 0, 0, &((kind)[0]), &((code)[0]), &((msg)[0]), ((uint8_t *)(0))));
  }
  return 1;
}
