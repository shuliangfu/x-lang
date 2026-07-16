#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
void shux_panic_(int has_msg, int msg_val);
extern int32_t driver_cmd_fmt(int32_t argc, uint8_t * argv);
extern int32_t driver_run_fmt(int32_t argc, uint8_t * argv);
int32_t driver_cmd_fmt(int32_t argc, uint8_t * argv) {
  return driver_run_fmt(argc, argv);
  return 0;
}
