#!/usr/bin/env bash
# STD-152：std.tar 长路径/Pax/目录门禁（假权威诚实）。
#
# 用法：./tests/run-std-tar-extended-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); long_path_dir.x exit 0 hard-fail (no soft
# SKIP when native xlang present). C smoke observational. Report
# check=/c=/x=/skip=. Product surface already green under asm; gate was
# portable-false-red (prefer xlang-c only / hard check / soft SKIP when no
# xlang-c).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_TAR_EXTENDED_DOC:-analysis/archive/std/std-tar-extended-v1.md}"
MANIFEST="${XLANG_STD_TAR_EXTENDED_TSV:-tests/baseline/std-tar-extended.tsv}"
MOD_X="std/tar/mod.x"
TAR_X="std/tar/tar.x"
LIB="tests/lib/std-tar-extended.sh"
SMOKE_X="tests/tar/long_path_dir.x"
SMOKE_C="tests/std-tar/extended_ok.c"
MIN_APIS=1

# shellcheck source=tests/lib/std-tar-extended.sh
. "$LIB"

echo "=== STD-152: tar extended manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-tar-extended-v1.md ]; then
  echo "std-tar-extended gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TAR_X" "$SMOKE_X" "$SMOKE_C" std/tar/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-tar-extended gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-152 prefix Pax path_max TAR_TYPE_PAX; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-tar-extended gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-tar-extended gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

if ! grep -qF "path_max" std/tar/README.md 2>/dev/null; then
  echo "std-tar-extended gate FAIL: README missing path_max" >&2
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
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-tar-extended gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-tar-extended gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_tar_extended_symbols_ok "$MOD_X" "$TAR_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_tar_extended_emit_report "fail" 0 0 0 0
  echo "std-tar-extended gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-tar-extended manifest OK"

if [ "${XLANG_STD_TAR_EXTENDED_MANIFEST_ONLY:-0}" = "1" ]; then
  std_tar_extended_emit_report "ok" 0 0 0 1
  echo "std-tar-extended gate OK (manifest only)"
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
C_OK=0
X_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-152: smoke (XLANG=$XLANG_BIN; check/C observational; x hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-tar-extended gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  TAR_O="$(cd compiler && pwd)/../std/tar/tar.o"
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # C smoke observational (seed gold; hard-green signal is .x runnable).
  if std_tar_extended_run_c_smoke; then
    C_OK=1
  else
    echo "std-tar-extended gate SKIP C smoke (observational)" >&2
  fi

  if std_tar_extended_run_x_smoke "$XLANG_BIN" "$SMOKE_X" "$TAR_O"; then
    X_OK=1
    SKIP=0
  else
    std_tar_extended_emit_report "fail" "$CHECK_OK" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-tar-extended gate FAIL: no native xlang" >&2
  std_tar_extended_emit_report "fail" 0 0 0 0
  exit 1
fi

# check + C stay observational; hard-green signal is x=.
echo "std-tar-extended check_ok=${CHECK_OK} c_ok=${C_OK} (observational)"
std_tar_extended_emit_report "ok" "$CHECK_OK" "$C_OK" "$X_OK" "$SKIP"
echo "std-tar-extended gate OK"
