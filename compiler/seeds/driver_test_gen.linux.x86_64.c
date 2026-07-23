#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void xlang_panic_(int has_msg, int msg_val);
extern int32_t driver_cmd_test(int32_t argc, uint8_t * argv);
extern int32_t driver_run_test(int32_t argc, uint8_t * argv);
int32_t driver_cmd_test(int32_t argc, uint8_t * argv) {
  return driver_run_test(argc, argv);
  return 0;
}
