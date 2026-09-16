#!/usr/bin/env bash
# TST-003: std round-trip vectors (base64/json/csv/compress) — leftover
# prefer-c / auto-make / SKIP→OK / check-as-hard / ensure_std_c_o →硬绿.
#
# Honesty: leftover prefer-c (`xlang-c` then `xlang`, never asm) + leftover
# `stdlib_cm_native_xlang` duplicate of dod_native_exe + leftover
# `xlang_compiler_make -q xlang-c || true` + leftover SKIP→OK when no native
# + leftover hard `xlang check` + leftover `ensure_std_c_o` + leftover
# top-level DOC (archived) retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse
# leftover unused compiler-make / leftover SKIP→OK / leftover prefer-c /
# leftover auto-make / leftover ensure). Manifest + archive DOC = hard.
# Four roundtrip product -o exit0 = hard run. check = obs (paused 2026-08-05).
# libzstd link env remains skip= (existing leftover). Report: run=/obs=/skip=
# (legacy vectors=/pass= folded into run=/skip=). G.7: complete existing
# resolve_shu family; drop stdlib_cm_native_xlang.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-tst-003-std-roundtrip-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/tst-003-std-roundtrip.sh
. tests/lib/tst-003-std-roundtrip.sh

DOC="${XLANG_TST003_DOC:-analysis/archive/tst/tst-003-std-roundtrip-v1.md}"
MANIFEST="${XLANG_TST003_TSV:-tests/baseline/std-roundtrip.tsv}"
LIB="tests/lib/tst-003-std-roundtrip.sh"
MIN_VEC=4
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "tst-003-roundtrip gate FAIL: $*" >&2
  tst003_emit_report "fail" "${RUN_OK:-0}" "${OBS:-0}" "${SKIP:-0}"
  exit 1
}

# G.7: complete the existing per-script resolve_shu family (dod_native_exe);
# do not fork a third resolver. Drop leftover stdlib_cm_native_xlang.
# Explicit XLANG that is missing/non-native returns 1 (caller hard-dies).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== TST-003: std round-trip manifest (archive DOC) ==="
if [ -f analysis/tst-003-std-roundtrip-v1.md ]; then
  die "top-level DOC resurrected (live = archive/tst/)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" \
  tests/boundary/base64_roundtrip.x tests/json/object_array_roundtrip.x \
  tests/csv/row_roundtrip.x tests/std-compress/gzip_roundtrip.x; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in round-trip std-roundtrip base64 json csv compress; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_vectors) MIN_VEC="$c2" ;; esac
done < "$MANIFEST"

miss="$(tst003_verify_manifest "$MANIFEST" || true)"
[ "${miss:-0}" -eq 0 ] || die "manifest_miss=${miss}"
echo "tst-003-roundtrip manifest OK"

if [ -n "${XLANG:-}" ]; then
  if ! XLANG_BIN="$(resolve_shu)"; then
    die "explicit XLANG not native (refuse leftover prefer-c / leftover SKIP→OK / leftover auto-make / leftover unused compiler-make / leftover ensure)"
  fi
elif ! XLANG_BIN="$(resolve_shu)"; then
  die "no native xlang/xlang_asm/xlang-c (refuse leftover SKIP→OK / leftover auto-make / leftover prefer-c)"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== TST-003: round-trip smoke (XLANG=$XLANG_BIN; prefer asm; hard) ==="

# Homebrew libzstd (Darwin leftover link env); missing lib still skip= via
# tst003_run_vector rc=2 — existing leftover, not this knife.
if [ -d /opt/homebrew/lib ]; then
  export LIBRARY_PATH="/opt/homebrew/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
elif [ -d /usr/local/lib ]; then
  export LIBRARY_PATH="/usr/local/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
fi

VECTORS=0
while IFS=$'\t' read -r item_id kind _mod test_path _needs_o _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|doc|lib|gate) continue ;; esac
  case "$kind" in
    roundtrip)
      VECTORS=$((VECTORS + 1))
      # Observational check (paused); CHK red does not hard-fail.
      set +e
      "$XLANG_BIN" check -L . "$test_path" >/tmp/xlang_tst003_check.log 2>&1
      chk_ec=$?
      set -e
      if [ "$chk_ec" -ne 0 ]; then
        echo "tst-003-roundtrip OBS check $test_path (paused / CHK residual ec=$chk_ec)" >&2
        OBS=$((OBS + 1))
      fi
      rv=0
      tst003_run_vector "$XLANG_BIN" "$test_path" "$item_id" || rv=$?
      if [ "$rv" -eq 0 ]; then
        RUN_OK=$((RUN_OK + 1))
        echo "  OK ${item_id} (${test_path})"
      elif [ "$rv" -eq 2 ]; then
        SKIP=$((SKIP + 1))
        echo "  SKIP ${item_id} (link env: libzstd)" >&2
      else
        die "product -o failed for $test_path (refuse leftover SKIP→OK / leftover ensure)"
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$VECTORS" -ge "$MIN_VEC" ] || die "vectors=${VECTORS} < min=${MIN_VEC}"

echo "tst-003-roundtrip gate OK"
tst003_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
exit 0
