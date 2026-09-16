/*
 * Thin pure: wave224 typeck_active module BSS + get/set.
 * G.7: bodies match mega runtime_pipeline_abi.x wave224 leave.
 *
 * Independent C thin (same Darwin rule as wave222/223): do not grow prior
 * emit_ctx named-BSS leaves — Apple ld -r rejects data dups on re-merge.
 *
 * Why C (not .x pure-asm): file-level pointer lets become Lxml COMMON under
 * pure-asm vs mega named cells (dual-home). This thin owns the canonical
 * named cell g_typeck_active_module.
 *
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED freestanding typeck.
 */

#include <stdint.h>

/* wave224: canonical name (match mega leave). */
void *g_typeck_active_module = 0;

/** wave224: get module currently under typeck. PLATFORM: SHARED. */
void *pipeline_typeck_active_module_c(void) {
  return g_typeck_active_module;
}

/** wave224: set module currently under typeck. PLATFORM: SHARED. */
void pipeline_typeck_active_module_set_c(void *m) {
  g_typeck_active_module = m;
}
