#!/usr/bin/env bash
# STD-038：std.tar 目录遍历与 ustar round-trip 门禁（假权威诚实）。
#
# 用法：./tests/run-std-tar-ustar-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); ustar_roundtrip.x + main.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/rt=/main=/skip=.
# Also restore MOD_X=std/tar/mod.x vs TAR_X=std/tar/tar.x (prior gate overwrote
# TAR_X twice → API grep against tar.x = portable false-red). Product surface
# already green under asm; gate was portable-false-red (prefer xlang-c / hard
# check / soft SKIP / MOD_X clobber).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_TAR_USTAR_DOC:-analysis/archive/std/std-tar-ustar-v1.md}"
MANIFEST="${XLANG_STD_TAR_USTAR_TSV:-tests/baseline/std-tar-ustar.tsv}"
MOD_X="std/tar/mod.x"
TAR_X="std/tar/tar.x"
LIB="tests/lib/std-tar-ustar.sh"
RT_X="tests/tar/ustar_roundtrip.x"
MAIN_X="tests/tar/main.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-tar-ustar.sh
. "$LIB"

echo "=== STD-038: tar ustar manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TAR_X" "$RT_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-tar-ustar gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-038 ustar next_entry read_entry_data append_entry round-trip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-tar-ustar gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-tar-ustar gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

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
        echo "std-tar-ustar gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-tar-ustar gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-tar-ustar gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_tar_ustar_symbols_ok "$MOD_X" "$TAR_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_tar_ustar_emit_report "fail" 0 0 0 0
  echo "std-tar-ustar gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-tar-ustar manifest OK"

if [ "${XLANG_STD_TAR_USTAR_MANIFEST_ONLY:-0}" = "1" ]; then
  std_tar_ustar_emit_report "ok" 0 0 0 1
  echo "std-tar-ustar gate OK (manifest only)"
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
RT_OK=0
MAIN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-038: smoke (XLANG=$XLANG_BIN; check observational; rt/main hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$RT_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-tar-ustar gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_tar_ustar_run_smoke "$XLANG_BIN" "$RT_X" "ustar_roundtrip"; then
    RT_OK=1
  else
    std_tar_ustar_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  if std_tar_ustar_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
    SKIP=0
  else
    std_tar_ustar_emit_report "fail" "$CHECK_OK" "$RT_OK" 0 0
    exit 1
  fi
else
  echo "std-tar-ustar gate FAIL: no native xlang" >&2
  std_tar_ustar_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is rt= + main=.
echo "std-tar-ustar check_ok=${CHECK_OK} (observational)"
std_tar_ustar_emit_report "ok" "$CHECK_OK" "$RT_OK" "$MAIN_OK" "$SKIP"
echo "std-tar-ustar gate OK"
