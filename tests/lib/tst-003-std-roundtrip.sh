#!/usr/bin/env bash
# tst-003-std-roundtrip.sh — TST-003: round-trip vector helpers.
#
# Honesty: leftover `ensure_std_c_o` (`tst003_ensure_o`) + leftover hard
# `xlang check` inside `tst003_run_vector` retired. Product `-o` is the hard
# signal; check is observational in the gate (paused 2026-08-05).
# Usage (after source):
#   tst003_verify_manifest TSV
#   tst003_run_vector XLANG_BIN TEST_PATH TAG
#   tst003_emit_report status run obs skip
# PLATFORM: SHARED archaeology.

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

TST003_PREFIX="${XLANG_TST003_ROUNDTRIP_PREFIX:-xlang: [XLANG_TST003_ROUNDTRIP]}"

# Verify manifest roundtrip/file rows exist; echo missing count.
# @param tsv path — TSV path relative to repo root
# @return 0 if miss=0, else 1 (echoes miss either way)
tst003_verify_manifest() {
  local tsv="$1"
  local miss=0
  local item_id kind _mod test_path _needs_o
  while IFS=$'\t' read -r item_id kind _mod test_path _needs_o _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|doc|lib|gate) continue ;; esac
    case "$kind" in
      roundtrip)
        if [ ! -f "$test_path" ]; then
          echo "tst-003-roundtrip FAIL: missing test '$test_path' ($item_id)" >&2
          miss=$((miss + 1))
        fi
        ;;
      file)
        if [ ! -f "$test_path" ]; then
          echo "tst-003-roundtrip FAIL: missing file '$test_path'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile+run one roundtrip smoke. 0=ok, 2=link-env SKIP (libzstd), 1=hard fail.
# Refuse leftover hard check / leftover ensure_std_c_o.
# @param xlang native compiler
# @param test_path .x smoke
# @param tag vector id
tst003_run_vector() {
  local xlang="$1"
  local test_path="$2"
  local tag="$3"
  local exe="/tmp/xlang_tst003_rt_${tag}_$$"
  local log="/tmp/xlang_tst003_build_${tag}_$$.log"
  if [ ! -f "$test_path" ]; then
    echo "tst-003-roundtrip FAIL: missing $test_path" >&2
    return 1
  fi
  # Product `-o` is the hard signal. Check is observational in the gate.
  if ! "$xlang" -L . "$test_path" -o "$exe" >"$log" 2>&1; then
    if grep -qE "library 'zstd' not found|cannot find -lzstd" "$log" 2>/dev/null; then
      rm -f "$exe" "$log"
      return 2
    fi
    echo "tst-003-roundtrip FAIL: compile $test_path" >&2
    tail -8 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  rm -f "$log"
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "tst-003-roundtrip FAIL: run $test_path exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: run=/obs=/skip= (legacy vectors=/pass= folded into run=/skip=).
# Extra fields OK. PLATFORM: SHARED archaeology.
tst003_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${TST003_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip} host=$(ci_host_summary)"
}
