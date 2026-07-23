#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
extern int32_t driver_run_eq_word(uint8_t * buf, int32_t len, uint8_t * word_ptr, int32_t word_len);
extern int32_t driver_cmd_run(int32_t argc, uint8_t * argv);
extern int32_t driver_exec_compiled(int32_t argc, uint8_t * argv);
extern int32_t main_run_compiler_x_path_impl(int32_t argc, uint8_t * argv);
int32_t driver_run_eq_word(uint8_t * buf, int32_t len, uint8_t * word_ptr, int32_t word_len) {
  if ((len !=word_len)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < len)) {
    if (((buf)[i] !=(word_ptr)[i])) {
      return 0;
    }
    (void)((i = (i + 1)));
  }
  return 1;
}
int32_t driver_cmd_run(int32_t argc, uint8_t * argv) {
  {
    int32_t rc = main_run_compiler_x_path_impl(argc, argv);
    if ((argc < 2)) {
      return 1;
    }
    if ((rc ==0)) {
      return driver_exec_compiled(argc, argv);
    }
    return rc;
  }
  return 0;
}
