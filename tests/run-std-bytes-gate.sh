#!/usr/bin/env bash
# STD-072：std.bytes 门禁（假权威诚实）。
#
# 用法：./tests/run-std-bytes-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); roundtrip.x exit 0 hard-fail (no soft SKIP
# when native xlang present). Fossil DOC `len` → product `length`; section
# `## 3. Gate` → `## 5. Gate`. Report check=/run=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_BYTES_DOC:-analysis/archive/std/std-bytes-v1.md}"
MANIFEST="${XLANG_STD_BYTES_MANIFEST:-tests/baseline/std-bytes-manifest.tsv}"
VECTORS="${XLANG_STD_BYTES_VECTORS:-tests/baseline/std-bytes-vectors.tsv}"
MOD_X="std/bytes/mod.x"
LIB="tests/lib/std-bytes.sh"
SMOKE_X="tests/std-bytes/roundtrip.x"
MIN_APIS=12
# Designed success score (roundtrip.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-bytes.sh
. "$LIB"

echo "=== STD-072: std.bytes manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SMOKE_X" std/bytes/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-bytes gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-072 extend as_view BytesReader reserve length; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-bytes gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-bytes gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-bytes gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_bytes_symbols_ok "$MOD_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_bytes_emit_report "fail" 0 0 0
  echo "std-bytes gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-bytes manifest OK"

if [ "${XLANG_STD_BYTES_MANIFEST_ONLY:-0}" = "1" ]; then
  std_bytes_emit_report "ok" 0 0 1
  echo "std-bytes gate OK (manifest only)"
  exit 0
fi

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
  echo "=== STD-072: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-bytes gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/bytes/mod.o 2>/dev/null || xlang_compiler_make ../std/bytes/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/heap/heap.o 2>/dev/null || xlang_compiler_make ../std/heap/heap.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_bytes_$$"
  LOG="/tmp/xlang_std_bytes_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-bytes gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_bytes_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-bytes gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_bytes_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-bytes gate FAIL: no native xlang" >&2
  std_bytes_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-bytes check_ok=${CHECK_OK} (observational)"
std_bytes_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-bytes gate OK"
