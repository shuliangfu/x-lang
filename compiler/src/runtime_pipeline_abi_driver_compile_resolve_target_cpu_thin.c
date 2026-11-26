/* Host-gcc twin of driver_compile_resolve_target_cpu_c (rt_compile.x).
 *
 * DIG s238: tipU first-wins T reads/writes target_cpu_len@0x6b0 /
 * target_cpu_buf@0x630 / target_cpu_features@0x6b4 as shallow lea through
 * &state (local at [rbp-0x10]). Those stores smash the host-cc
 * parse_argv → full_x -0x28 state ptr → SEGV at state+0x6b8 after
 * alloc/init/cfg_sync Soft Caps. Host-gcc twin indexes through the heap
 * pointer. docs-only .x, do not idx8. PLATFORM: SHARED host-cc.
 */
#include <stdint.h>

extern int32_t xlang_target_cpu_resolve(uint8_t *spec, uint64_t spec_len,
                                        uint32_t *out_feats);
extern uint32_t xlang_target_cpu_generic_for_host(void);
extern void diag_report_with_code(void *ctx, int32_t a, int32_t b, uint8_t *kind,
                                  uint8_t *code, uint8_t *msg, uint8_t *path);

enum { OFF_TARGET_CPU_BUF = 0x630 };
enum { OFF_TARGET_CPU_LEN = 0x6b0 };
enum { OFF_TARGET_CPU_FEATURES = 0x6b4 };

void driver_compile_resolve_target_cpu_c(void *state) {
  uint8_t *p;
  uint8_t *spec;
  uint64_t spec_len;
  uint32_t feats;
  int32_t rc;
  int32_t cpu_len;
  static uint8_t native[] = "native";
  static uint8_t kind_note[] = "note";
  static uint8_t msg_unk[] =
      "unknown -target-cpu; using generic baseline";

  if (state == 0)
    return;
  p = (uint8_t *)state;
  spec = native;
  spec_len = 6;
  cpu_len = *(int32_t *)(p + OFF_TARGET_CPU_LEN);
  if (cpu_len > 0) {
    spec = p + OFF_TARGET_CPU_BUF;
    spec_len = (uint64_t)(uint32_t)cpu_len;
  }
  feats = 0;
  rc = xlang_target_cpu_resolve(spec, spec_len, &feats);
  if (rc != 0) {
    diag_report_with_code(0, 0, 0, kind_note, 0, msg_unk, 0);
    feats = xlang_target_cpu_generic_for_host();
  }
  *(int32_t *)(p + OFF_TARGET_CPU_FEATURES) = (int32_t)feats;
}
