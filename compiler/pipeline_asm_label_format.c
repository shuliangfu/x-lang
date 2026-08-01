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
