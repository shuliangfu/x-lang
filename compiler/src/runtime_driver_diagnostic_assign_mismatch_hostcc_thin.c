/* Source-faithful driver_diagnostic_typeck_assign_mismatch twin
 * (runtime_driver_diagnostic_thin.x).
 *
 * s216 DIG: tipU first-wins places epart/fpart/msg at lea -0x50/-0x58/-0x60
 * while fill/build pass cap 112/112/240 → write upward through saved rbp/ret
 * (same undersized-local class as s187/s214 uasb note). Manifests as
 * `let s: string = "hi"` typeck path AV at ret of assign_mismatch; stderr
 * shows smashed "assignment" → overlapping "signment…" repeats.
 *
 * Host-cc allocates real epart[112]/fpart[112]/msg[240] and forwards to
 * existing fill/build/report. Tip-land via g05 LINK_WINNERS.
 * docs-only .x overlays must not first-wins; do not idx8.
 * PLATFORM: SHARED host-cc first-wins.
 */
#include <stdint.h>

extern void driver_diag_fill_expr_part(uint8_t *part, int32_t part_cap,
                                      const uint8_t *buf, int32_t len);
extern void driver_diag_build_expected_found(uint8_t *msg, int32_t msg_cap,
                                            const uint8_t *pref,
                                            const uint8_t *epart,
                                            const uint8_t *fpart);
extern void driver_diag_report_prefixed(int32_t line, int32_t col,
                                       const uint8_t *msg);

/**
 * Report assign / compound-assign type mismatch without smashing the frame.
 * @param is_compound non-zero → compound wording
 * @param line source line
 * @param col source column
 * @param expect_buf expected type bytes
 * @param expect_len expected length
 * @param found_buf found type bytes
 * @param found_len found length
 */
void driver_diagnostic_typeck_assign_mismatch(int32_t is_compound, int32_t line,
                                              int32_t col,
                                              const uint8_t *expect_buf,
                                              int32_t expect_len,
                                              const uint8_t *found_buf,
                                              int32_t found_len) {
  uint8_t epart[112];
  uint8_t fpart[112];
  uint8_t msg[240];
  const uint8_t *pref;

  driver_diag_fill_expr_part(&epart[0], 112, expect_buf, expect_len);
  driver_diag_fill_expr_part(&fpart[0], 112, found_buf, found_len);
  pref = (const uint8_t *)"typeck error: assignment type mismatch: expected ";
  if (is_compound != 0) {
    pref = (const uint8_t *)"typeck error: compound assignment type mismatch: expected ";
  }
  driver_diag_build_expected_found(&msg[0], 240, pref, &epart[0], &fpart[0]);
  driver_diag_report_prefixed(line, col, &msg[0]);
}
