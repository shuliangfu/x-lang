#!/usr/bin/env bash
# placeholder-inventory.sh — placeholder() inventory helper.
#
# Honesty: leftover catalog no Honesty report completed here (G.7).
# Extra fields count=/max= remain. run=/obs=/skip= required.
# Usage (after source):
#   placeholder_count_repo
#   placeholder_emit_report status count max [run obs skip]
# PLATFORM: SHARED archaeology.

PH_INV_PREFIX="${XLANG_PLACEHOLDER_INV_PREFIX:-xlang: [XLANG_PLACEHOLDER_INV]}"

# Count `function placeholder()` definitions under core/ + std/
# (exclude names like bad_path_placeholder).
placeholder_count_repo() {
  local n
  n="$(grep -rE '^function placeholder\(\)' core std 2>/dev/null \
    | grep -v compiler/asm_libroot \
    | wc -l \
    | tr -d ' ')"
  echo "${n:-0}"
}

# Structured report. Completes existing helper with run=/obs=/skip=
# (G.7: do not fork a second reporter). Optional host= when ci_host_summary
# is already sourced by the gate.
placeholder_emit_report() {
  local status="$1"
  local count="$2"
  local max="$3"
  local run="${4:-0}"
  local obs="${5:-0}"
  local skip="${6:-0}"
  local host=""
  if type ci_host_summary >/dev/null 2>&1; then
    host=" host=$(ci_host_summary)"
  fi
  echo "${PH_INV_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip} count=${count} max=${max}${host}"
}
