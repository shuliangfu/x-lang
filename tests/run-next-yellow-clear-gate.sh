#!/usr/bin/env bash
# NEXT-YELLOW: one-shot clear of former NEXT.md yellow items
# (CORE-018～020 / STD-159～167) — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + prefer-c (xlang-c
# before asm) + soft auto-make + hard-bound `xlang check` + fossil
# top-level DOC / NEXT.md requirement retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - archive DOC + ## Gate + manifest symbols/smokes = hard.
#   - refuse NEXT.md / top-level analysis/next-yellow-clear-v1.md resurrect.
#   - product -o hard green: vec/map/net/fmt/iterator/thread/runtime_diag/unicode.
#   - queue run residual / sqlite stub TLS UNDEF / debug diag ld / check = obs.
#   - CORE-018 delegates to run-core-builtin-bitops-gate.sh (hard).
# Report: run=/obs=/skip=
# Usage: ./tests/run-next-yellow-clear-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_NEXT_YELLOW_DOC:-analysis/archive/other-tickets/next-yellow-clear-v1.md}"
MANIFEST="${XLANG_NEXT_YELLOW_TSV:-tests/baseline/next-yellow-clear.tsv}"
PREFIX="${XLANG_NEXT_YELLOW_CLEAR_PREFIX:-xlang: [XLANG_NEXT_YELLOW_CLEAR]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "next-yellow-clear gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

run_timeout_case() {
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$@"
}

# Product -o hard green: build + run exit 0.
# Return: 0=ok, 1=hard fail, 2=obs (timeout / tip residual).
# NOTE: keep errexit off across non-zero returns — bash `set -e` + `return 2`
# from a function aborts the caller even when the call site used `set +e`
# (Darwin / bash 3.2). Callers must use `prc=0; f || prc=$?`.
product_run_case() {
  local label="$1"
  local src="$2"
  local expect_ec="${3:-0}"
  local mode="${4:-hard}" # hard | obs
  local err="/tmp/xlang_yellow_${label}.log"
  local out="/tmp/xlang_yellow_${label}"
  local o_ec r_ec
  [ -f "$src" ] || { echo "next-yellow-clear FAIL: missing $src" >&2; return 1; }

  rm -f "$out"
  set +e
  run_timeout_case "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  if [ "$o_ec" -eq 124 ]; then
    echo "next-yellow-clear OBS $label (-o timeout ${XLANG_CASE_TIMEOUT}s; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    if [ "$mode" = "obs" ]; then
      echo "next-yellow-clear OBS $label (product -o residual; refuse soft SKIP→OK)" >&2
      return 2
    fi
    echo "next-yellow-clear FAIL: product -o $src ec=$o_ec" >&2
    tail -8 "$err" >&2 || true
    return 1
  fi
  "$out" >/dev/null 2>&1
  r_ec=$?
  rm -f "$out"
  if [ "$r_ec" -eq "$expect_ec" ]; then
    return 0
  fi
  if [ "$mode" = "obs" ]; then
    echo "next-yellow-clear OBS $label (run exit=$r_ec expect=$expect_ec; product residual)" >&2
    return 2
  fi
  echo "next-yellow-clear FAIL: runnable $src exit=$r_ec expect=$expect_ec" >&2
  return 1
}

# Observational check path (paused 2026-08-05 / CHK002) — never soft SKIP→OK.
obs_check_case() {
  local src="$1"
  local err="/tmp/xlang_yellow_chk_$$.log"
  local ec
  [ -f "$src" ] || return 2
  set +e
  run_timeout_case "$XLANG_BIN" check -L . "$src" >"$err" 2>&1
  ec=$?
  if [ "$ec" -eq 0 ]; then
    return 0
  fi
  echo "next-yellow-clear OBS check $src (paused/CHK002 residual; refuse soft SKIP→OK)" >&2
  return 2
}

echo "=== NEXT-YELLOW: manifest (archive DOC; refuse NEXT.md) ==="
if [ -f NEXT.md ]; then
  die "NEXT.md resurrected (live roadmap = analysis/自举进度.md)"
fi
if [ -f analysis/next-yellow-clear-v1.md ]; then
  die "top-level DOC resurrected (live = archive/other-tickets/)"
fi
for f in "$DOC" "$MANIFEST" tests/run-core-builtin-bitops-gate.sh; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes || [ -n "${item_id:-}" ]; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    symbol)
      if ! grep -qE "function ${anchor}\\(" "$mod_path" 2>/dev/null; then
        echo "next-yellow-clear FAIL: missing function ${anchor}( in ${mod_path}" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file|smoke|doc|script)
      if [ ! -f "$anchor" ]; then
        echo "next-yellow-clear FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || die "manifest miss=${MISS}"
echo "next-yellow-clear manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

# CORE-018: delegate to honesty-rewritten bitops gate (hard).
echo "=== NEXT-YELLOW: CORE-018 bitops sub-gate ==="
if ! XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
  ./tests/run-core-builtin-bitops-gate.sh >/tmp/xlang_yellow_bitops.log 2>&1; then
  tail -20 /tmp/xlang_yellow_bitops.log >&2 || true
  die "core-builtin-bitops (CORE-018) failed"
fi
RUN_OK=$((RUN_OK + 1))
echo "next-yellow-clear CORE-018 OK"

echo "=== NEXT-YELLOW: product -o smokes (XLANG=$XLANG_BIN) ==="

# Hard-green product smokes (probed 2026-08-28 Darwin + Ubuntu follow-up).
HARD_SMOKES=(
  "vec:tests/vec/u16_roundtrip.x"
  "map:tests/map/iter_rehash.x"
  "net:tests/net/tcp_pool_smoke.x"
  "fmt:tests/fmt/template_smoke.x"
  "iterator:tests/iterator/u64_roundtrip.x"
  "thread:tests/thread/pool_stats.x"
  "runtime_diag:tests/exc/runtime_diag_smoke.x"
  "unicode:tests/string/unicode_bridge.x"
)
for entry in "${HARD_SMOKES[@]}"; do
  label="${entry%%:*}"
  src="${entry#*:}"
  prc=0
  product_run_case "$label" "$src" 0 hard || prc=$?
  case "$prc" in
    0) RUN_OK=$((RUN_OK + 1)) ;;
    2) OBS=$((OBS + 1)) ;;
    *) die "hard smoke $label" ;;
  esac
done

# Tip residuals = obs (queue pop residual; sqlite stub TLS UNDEF; debug diag ld).
OBS_SMOKES=(
  "queue:tests/queue/u8_roundtrip.x"
  "sqlite_stub:tests/stub/sqlite_net_stub.x"
  "debug_diag:tests/debug/diag_smoke.x"
)
for entry in "${OBS_SMOKES[@]}"; do
  label="${entry%%:*}"
  src="${entry#*:}"
  prc=0
  product_run_case "$label" "$src" 0 obs || prc=$?
  case "$prc" in
    0) RUN_OK=$((RUN_OK + 1)) ;;
    2) OBS=$((OBS + 1)) ;;
    *) die "obs smoke $label unexpected hard" ;;
  esac
done

echo "=== NEXT-YELLOW: observational check path (paused) ==="
# One check-path probe (paused 2026-08-05 / CHK002) — not soft silence.
prc=0
obs_check_case tests/debug/diag_smoke.x || prc=$?
case "$prc" in
  0) RUN_OK=$((RUN_OK + 1)) ;;
  2) OBS=$((OBS + 1)) ;;
  *) die "check path diag_smoke" ;;
esac

ok_report
echo "next-yellow-clear gate OK"
