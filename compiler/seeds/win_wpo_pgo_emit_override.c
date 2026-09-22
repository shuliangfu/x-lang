/* wave778 Class AC: Win PE first-wins — pgo_emit_order_prepare empty→real.
 * Identity non-extern fill (FROM_X twin pattern; no PGO sort). PLATFORM: WINDOWS. */
#include <stdint.h>
#ifndef ASM_WPO_MAX_FUNCS
#define ASM_WPO_MAX_FUNCS 4096
#endif
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
static int32_t g_win_pgo_emit_order[ASM_WPO_MAX_FUNCS];
static int32_t g_win_pgo_emit_n;
static void *g_win_pgo_emit_mod;
void pipeline_asm_wpo_pgo_emit_order_prepare(void *m) {
  int32_t nf, fi, n = 0;
  g_win_pgo_emit_mod = m;
  g_win_pgo_emit_n = 0;
  if (!m) return;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0) continue;
    if (n < ASM_WPO_MAX_FUNCS) {
      g_win_pgo_emit_order[n] = fi;
      n++;
    }
  }
  g_win_pgo_emit_n = n;
}
int32_t pipeline_asm_wpo_pgo_emit_order_count(void *m) {
  if (!m) return 0;
  if (m != g_win_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  return g_win_pgo_emit_n;
}
int32_t pipeline_asm_wpo_pgo_emit_order_at(void *m, int32_t order_index) {
  if (!m || order_index < 0) return -1;
  if (m != g_win_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  if (order_index >= g_win_pgo_emit_n || order_index >= ASM_WPO_MAX_FUNCS)
    return -1;
  return g_win_pgo_emit_order[order_index];
}
