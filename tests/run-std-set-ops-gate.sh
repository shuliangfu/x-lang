#!/usr/bin/env bash
# STD-129：std.set Set_i32 union/intersect/difference 门禁（假权威诚实）。
#
# 用法：./tests/run-std-set-ops-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: TSV anchors aligned to product (union_into / intersect_into /
# difference_into); Prefer xlang_asm; ops.x exit 0 hard-fail (no soft SKIP /
# no hard check). check smoke observational SKIP (check gate paused 2026-08-05).
# cookbook set_u64_insert hard-fail neighborhood (same std.set module).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD129_DOC:-analysis/archive/std/std-set-ops-v1.md}"
MANIFEST="${XLANG_STD129_TSV:-tests/baseline/std-set-ops-manifest.tsv}"
MOD_X="std/set/mod.x"
LIB="tests/lib/std-set-ops.sh"
SMOKE="tests/set/ops.x"
COOKBOOK="examples/cookbook/set_u64_insert.x"
# Designed success score (tests/set/ops.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-set-ops.sh
. "$LIB"

echo "=== STD-129: set ops manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE" "$COOKBOOK"; do
  if [ ! -f "$f" ]; then
    echo "std-set-ops gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-129 union_into intersect_into difference_into; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-set-ops gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_set_ops_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_set_ops_emit_report "fail" 0 0 0
  echo "std-set-ops gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-set-ops manifest OK"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}
resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-129: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-set-ops gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/set/mod.o 2>/dev/null || xlang_compiler_make ../std/set/mod.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_set_ops_$$"
  LOG="/tmp/xlang_std_set_ops_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-set-ops gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_set_ops_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-set-ops gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_set_ops_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi

  # Neighborhood cookbook (Set_u64 insert/contains_key/remove) — same std.set module; hard-fail.
  if [ -f "$COOKBOOK" ]; then
    CB_OUT="/tmp/xlang_std_set_ops_cb_$$"
    CB_LOG="/tmp/xlang_std_set_ops_cb_$$.log"
    if $RUN_XLANG build -L . "$COOKBOOK" -o "$CB_OUT" 2>"$CB_LOG"; then
      cb_ec=0
      "$CB_OUT" >/dev/null 2>&1 || cb_ec=$?
      rm -f "$CB_OUT"
      if [ "$cb_ec" -ne 0 ]; then
        echo "std-set-ops gate FAIL cookbook set_u64_insert exit=$cb_ec" >&2
        std_set_ops_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
      echo "std-set-ops cookbook set_u64_insert OK"
    else
      echo "std-set-ops gate FAIL cookbook set_u64_insert link" >&2
      tail -20 "$CB_LOG" 2>/dev/null >&2 || true
      std_set_ops_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  fi
else
  echo "std-set-ops gate FAIL: no native xlang" >&2
  std_set_ops_emit_report "fail" 0 0 0
  exit 1
fi

std_set_ops_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-set-ops gate OK"
