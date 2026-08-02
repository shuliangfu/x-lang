/**
 * pipeline_asm_label_format.c — asm label integer formatting domain (BC 8.3.1).
 *
 * Mechanically extracted from pipeline_glue.c (same translation unit via
 * #include). Authority for writing unsigned/signed decimal integers into a
 * raw uint8_t buffer for asm label suffix generation (".Lf<scope>_<id>").
 *
 * Members (wave1102 G.7 migration from pipeline_glue.c):
 * - glue_format_u32_to_buf (unsigned decimal → buf[off..])
 * - glue_format_i32_to_buf (signed decimal → buf[off..])
 *
 * Callers: pipeline_asm_emit_next_label_c and match label formatters in
 * pipeline_glue.c (all after #include).
 *
 * Not compiled as a separate .o — #included from pipeline_glue.c at the
 * original definition site. All members remain static (same-TU).
 *
 * PLATFORM: SHARED — pure integer formatting, no arch dependency.
 */

/**
 * Write an unsigned 32-bit decimal into buf[off..].
 *
 * Why: asm label suffixes (".Lf<scope>_<id>") need numeric IDs formatted as
 * ASCII decimal. snprintf to a temp then byte-copy avoids linking full
 * printf into the codegen path.
 *
 * Invariant: Returns number of bytes written (1..10); -1 on null buf,
 * non-positive max, negative off, or result exceeding max bytes.
 *
 * Asm/Perf: O(log10(val)) — snprintf + byte copy. Cold path (label emit).
 *
 * PLATFORM: SHARED.
 */
static int32_t glue_format_u32_to_buf(uint8_t *buf, int32_t off, int32_t max, uint32_t val) {
  char tmp[16];
  int n;
  int i;
  if (!buf || max <= 0 || off < 0)
    return -1;
  n = snprintf(tmp, sizeof(tmp), "%u", val);
  if (n <= 0 || n > max)
    return -1;
  for (i = 0; i < n; i++)
    buf[off + i] = (uint8_t)tmp[i];
  return n;
}

/**
 * Write a signed 32-bit decimal into buf[off..].
 *
 * Why: match label IDs and scope indices can be negative (error contexts);
 * signed formatting ensures the minus sign is emitted correctly.
 *
 * Invariant: Returns number of bytes written (1..11); -1 on null buf,
 * non-positive max, negative off, or result exceeding max bytes.
 *
 * Asm/Perf: O(log10(|val|)) — snprintf + byte copy. Cold path.
 *
 * PLATFORM: SHARED.
 */
static int32_t glue_format_i32_to_buf(uint8_t *buf, int32_t off, int32_t max, int32_t val) {
  char tmp[16];
  int n;
  int i;
  if (!buf || max <= 0 || off < 0)
    return -1;
  n = snprintf(tmp, sizeof(tmp), "%d", val);
  if (n <= 0 || n > max)
    return -1;
  for (i = 0; i < n; i++)
    buf[off + i] = (uint8_t)tmp[i];
  return n;
}

/* ========================================================================== *
 * wave1201 G.7: asm label format public wrappers (2 fns) migrated from
 * pipeline_glue.c (L2655-2702). Colocated with wave1102 integer format
 * primitives — these wrappers are the sole consumers of glue_format_u32_to_buf
 * / glue_format_i32_to_buf (static above, same file).
 *
 * Members:
 *  - pipeline_asm_emit_next_label_c: emit ".Lf<scope>_<n>" into buf; advances
 *    AsmFuncCtx.label_counter so each label is unique within a function.
 *  - pipeline_asm_format_label_id_c: format ".L_<id>" into buf; counterpart of
 *    backend.x format_label_id (does NOT advance label_counter).
 *
 * Same-TU #include at glue.c L2653 (before mega_body callsite at L3173).
 * Static deps visible at #include point:
 *  - pipeline_asm_ctx_layout (static at glue.c L86)
 *  - pipeline_glue_AsmFuncCtxLayout (struct decl at glue.c top, before L86)
 *  - pipeline_elf_label_mod_scope_active (extern at glue.c L836)
 * Extern fwd decl retained at glue.c L835 (pipeline_asm_emit_next_label_c —
 * called by glue.c L3173 mega_body, after this file's #include at L2653).
 * PLATFORM: SHARED — pure label formatting, no arch dependency.
 * ========================================================================== */

/**
 * Emit a unique local label ".Lf<scope>_<n>" into buf.
 *
 * Why: per-function label counter ensures uniqueness when multiple modules
 *      share an elf_ctx; scope (from pipeline_elf_label_mod_scope_active)
 *      disambiguates cross-module label collisions in the final link.
 * Contract: NULL ctx/buf or buf_size<8 → -1; otherwise returns total label
 *           length written (>=4). Advances AsmFuncCtx.label_counter by 1.
 * Invariant: label format is ".Lf<scope>_<id>" — 3 prefix bytes + scope
 *            decimal + 1 underscore + id decimal. Caller must size buf >= 16.
 * Asm/Perf: O(log10(scope)+log10(id)) — snprintf + byte copy. Cold path.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_emit_next_label_c(struct backend_AsmFuncCtx *ctx, uint8_t *buf, int32_t buf_size) {
  pipeline_glue_AsmFuncCtxLayout *ly;
  int32_t n;
  int32_t id;
  int32_t scope;
  int32_t off;
  if (!ctx || !buf || buf_size < 8)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  scope = pipeline_elf_label_mod_scope_active();
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'f';
  off = 3;
  n = glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)scope);
  if (n <= 0)
    n = 1;
  off = off + n;
  if (off + 2 >= buf_size)
    return -1;
  buf[off] = (uint8_t)'_';
  off = off + 1;
  id = ly->label_counter;
  ly->label_counter = id + 1;
  n = glue_format_u32_to_buf(buf, off, buf_size - off, (uint32_t)id);
  if (n <= 0)
    n = 1;
  return off + n;
}

/**
 * Format a label ID as ".L_<id>" into buf.
 *
 * Why: counterpart of backend.x format_label_id — emits a fixed-prefix label
 *      for match arms / fixed tags. Does NOT advance label_counter (caller
 *      supplies the id explicitly).
 * Contract: NULL buf or buf_size<4 → -1; otherwise returns total label
 *           length written (>=4). id may be negative (signed format).
 * Invariant: label format is ".L_<id>" — 3 prefix bytes + signed decimal.
 * Asm/Perf: O(log10(|id|)) — snprintf + byte copy. Cold path.
 * PLATFORM: SHARED.
 */
int32_t pipeline_asm_format_label_id_c(uint8_t *buf, int32_t buf_size, int32_t id) {
  int32_t n;
  if (!buf || buf_size < 4)
    return -1;
  buf[0] = (uint8_t)'.';
  buf[1] = (uint8_t)'L';
  buf[2] = (uint8_t)'_';
  n = glue_format_i32_to_buf(buf, 3, buf_size - 3, id);
  if (n <= 0)
    n = 1;
  return 3 + n;
}
