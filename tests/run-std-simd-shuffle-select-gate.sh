#!/usr/bin/env bash
# STD-047：std.simd shuffle/select 矢量化实装门禁（假权威诚实）。
#
# 用法：./tests/run-std-simd-shuffle-select-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); shuffle_select_roundtrip.x exit 0 hard-fail
# (no soft SKIP when native xlang present; smoke helper no longer swallows
# run≠0). simd-s4: hard on x86_64, observational elsewhere. Report
# check=/shuffle=/select=/s4=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang / soft SKIP on smoke fail / DOC missing select_lane /
# ## 4. 门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/archive/std/std-simd-shuffle-select-v1.md}"
MANIFEST="${XLANG_STD_SIMD_SHUFFLE_SELECT_TSV:-tests/baseline/std-simd-shuffle-select.tsv}"
MOD_X="std/simd/mod.x"
LIB="tests/lib/std-simd-shuffle-select.sh"
SMOKE_X="tests/simd/shuffle_select_roundtrip.x"
MIN_APIS=7

# shellcheck source=tests/lib/std-simd-shuffle-select.sh
. "$LIB"

echo "=== STD-047: simd shuffle/select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-simd-shuffle-select gate FAIL: missing $f" >&2
    exit 1
  fi
done

# Product names are overload shuffle/select/select_lane.
# Historical vec4f_shuffle / vec8i_select are not a second export.
for kw in STD-047 shuffle select select_lane lane-scalar XLANG_SIMD_HW; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-shuffle-select gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-simd-shuffle-select gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

# mod.x 须含 lane-scalar 实装（非零桩）
if ! grep -qF 'v[mask[0]]' "$MOD_X" 2>/dev/null; then
  echo "std-simd-shuffle-select gate FAIL: missing lane-scalar shuffle in $MOD_X" >&2
  exit 1
fi
# Product API is select_lane (mod.x); legacy gate string vec8i_select_lane drifted.
if ! grep -qE 'function select_lane\(' "$MOD_X" 2>/dev/null; then
  echo "std-simd-shuffle-select gate FAIL: missing select_lane helper in $MOD_X" >&2
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
        echo "std-simd-shuffle-select gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-simd-shuffle-select gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-simd-shuffle-select gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_simd_ss_symbols_ok "$MOD_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_simd_ss_emit_report "fail" 0 0 0 0 0
  echo "std-simd-shuffle-select gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-simd-shuffle-select manifest OK"

if [ "${XLANG_STD_SIMD_SHUFFLE_SELECT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_simd_ss_emit_report "ok" 0 0 0 0 1
  echo "std-simd-shuffle-select gate OK (manifest only)"
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
  # SIMD shuffle/select needs asm backend; xlang-c cannot emit C for Vec bodies.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      case "$cand" in
        */xlang-c|*/xlang-x*) continue ;;
      esac
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
SHUFFLE_OK=0
SELECT_OK=0
S4_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-047: smoke (XLANG=$XLANG_BIN; check observational; roundtrip hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-simd-shuffle-select gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_simd_ss_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
    SHUFFLE_OK=1
    SELECT_OK=1
    SKIP=0
  else
    std_simd_ss_emit_report "fail" "$CHECK_OK" 0 0 0 0
    exit 1
  fi

  # simd-s4: hard on x86_64 (HW objdump); observational elsewhere (Darwin arm64
  # host-cc-requires-allow / BLD001 is not a soft-green SKIP for roundtrip).
  # PLATFORM: LINUX x86_64 hard; MACOS/ARM observational.
  if [ -x tests/run-simd-s4-gate.sh ]; then
    S4_STRICT=""
    case "$(uname -m 2>/dev/null)" in
      x86_64|amd64) S4_STRICT=1 ;;
    esac
    S4_LOG="/tmp/std_simd_s4_$$.log"
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      XLANG_SIMD_HW_STRICT="${S4_STRICT}" \
      ./tests/run-simd-s4-gate.sh >"$S4_LOG" 2>&1; then
      S4_OK=1
    elif [ -n "$S4_STRICT" ]; then
      echo "std-simd-shuffle-select gate FAIL: simd-s4 strict HW check" >&2
      tail -8 "$S4_LOG" >&2 || true
      std_simd_ss_emit_report "fail" "$CHECK_OK" "$SHUFFLE_OK" "$SELECT_OK" 0 "$SKIP"
      rm -f "$S4_LOG"
      exit 1
    else
      echo "std-simd-shuffle-select gate SKIP simd-s4 (observational; non-x86)" >&2
      tail -5 "$S4_LOG" >&2 || true
    fi
    rm -f "$S4_LOG"
  fi
else
  echo "std-simd-shuffle-select gate FAIL: no native asm xlang" >&2
  std_simd_ss_emit_report "fail" 0 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is shuffle=/select=.
echo "std-simd-shuffle-select check_ok=${CHECK_OK} (observational)"
std_simd_ss_emit_report "ok" "$CHECK_OK" "$SHUFFLE_OK" "$SELECT_OK" "$S4_OK" "$SKIP"
echo "std-simd-shuffle-select gate OK"
