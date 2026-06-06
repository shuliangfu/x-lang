/**
 * pipeline_abi_f32_xmm.c — SysV f32 xmm 实/形参 ABI 开关（SHU_ABI_F32_XMM=1）。
 *
 * 独立 TU，供 backend_call_dispatch.o 链接；形参 homing 仍须在 pipeline_glue.c 重编后生效。
 */
#include <stdint.h>
#include <stdlib.h>

/** CALL emit 期间为 1：f32 实参走 xmm，勿 f64 widen。 */
static int32_t g_pipeline_asm_emit_call_f32_xmm;

/**
 * 是否启用 SysV f32 xmm 实/形参 ABI。
 * 默认开启（unset 或非 "0"）；显式 SHU_ABI_F32_XMM=0 回落 legacy f64 widen + cvtsd2ss。
 */
int32_t pipeline_asm_abi_f32_xmm_enabled_c(void) {
  const char *env;
  env = getenv("SHU_ABI_F32_XMM");
  if (env && env[0] == '0' && env[1] == '\0')
    return 0;
  return 1;
}

/** CALL emit 期间打开/关闭 f32 xmm 实参路径。 */
void pipeline_asm_emit_set_call_f32_xmm(int32_t on) {
  g_pipeline_asm_emit_call_f32_xmm = on != 0 ? 1 : 0;
}

/** CALL 路径查询：是否对 f32 实参禁用 f64 widen。 */
int32_t pipeline_asm_emit_get_call_f32_xmm_c(void) {
  return g_pipeline_asm_emit_call_f32_xmm;
}
