// Thin pure: wave313/339/380 M2 — typeck_active Cap residual (was wave224 C thin).
// Process-local active-module cell + get/set; 2 exports.
// G.7: bodies match runtime_pipeline_abi.x wave224 leave.
// PRODUCT inject (pipeline_abi_inject_typeck_active_thin, stamp w380):
//   Prior: LINUX PREFER / DARWIN -E overlays kept.
//   HARD BAN reinject both ends (Darwin BRANCH26; Ubuntu tip SEGV).
// PLATFORM: SHARED · BAN reinject both ends (keep prior overlays).

let g_typeck_active_module: *u8 = 0 as *u8;

/**
 * Get the module currently under typeck (active typeck phase).
 * Contract: null outside typeck; non-null throughout typeck_parsed_module /
 * parse-coupled entry. Callers must null-check before use (CTFE enum mark).
 * @return *u8 — ast_Module* as *u8, or null
 * wave224 pure: G.7 authority (was Cap residual glue_statics + check_block getter).
 * PLATFORM: SHARED freestanding typeck.
 */
#[no_mangle]
export function pipeline_typeck_active_module_c(): *u8 {
  return g_typeck_active_module;
}

/**
 * Set the module currently under typeck (process-local cell only).
 * Contract: pipeline_typeck_set_active_ctx_c residual also updates
 * g_typeck_active_ctx (check_block-local); assign path may set module alone.
 * @param m *u8 — ast_Module* as *u8; may be null (clears active)
 * @return void
 * wave224 pure: G.7 authority (was Cap residual direct static write).
 * PLATFORM: SHARED freestanding typeck.
 */
#[no_mangle]
export function pipeline_typeck_active_module_set_c(m: *u8): void {
  g_typeck_active_module = m;
}

