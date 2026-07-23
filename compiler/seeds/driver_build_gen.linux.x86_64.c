#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
extern int32_t build_cmd_build(int32_t argc, uint8_t * argv);
extern int32_t main_run_compiler_x_path_impl(int32_t argc, uint8_t * argv);
extern int32_t driver_build_build_x(void);
int32_t build_cmd_build(int32_t argc, uint8_t * argv) {
  if ((argc < 2)) {
    return driver_build_build_x();
  }
  return main_run_compiler_x_path_impl(argc, argv);
  return 0;
}
