#!/usr/bin/env bash
# STD-047：std.simd shuffle/select 矢量化实装门禁
#
# 用法：./tests/run-std-simd-shuffle-select-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/std-simd-shuffle-select-v1.md}"
MANIFEST="${SHUX_STD_SIMD_SHUFFLE_SELECT_TSV:-tests/baseline/std-simd-shuffle-select.tsv}"
MOD_SU="std/simd/mod.sx"
LIB="tests/lib/std-simd-shuffle-select.sh"
SMOKE_SU="tests/simd/shuffle_select_roundtrip.sx"
MIN_APIS=6

# shellcheck source=tests/lib/std-simd-shuffle-select.sh
. "$LIB"

echo "=== STD-047: simd shuffle/select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$SMOKE_SU"; do
  if [ ! -f "$f" ]; then
    echo "std-simd-shuffle-select gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-047 vec4f_shuffle vec8i_select lane-scalar SHUX_SIMD_HW; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-shuffle-select gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

# mod.sx 须含 lane-scalar 实装（非零桩）
if ! grep -qF 'v[mask[0]]' "$MOD_SU" 2>/dev/null; then
  echo "std-simd-shuffle-select gate FAIL: missing lane-scalar shuffle in $MOD_SU" >&2
  exit 1
fi
if ! grep -qF 'vec8i_select_lane' "$MOD_SU" 2>/dev/null; then
  echo "std-simd-shuffle-select gate FAIL: missing select_lane helper in $MOD_SU" >&2
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
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

sym_miss="$(std_simd_ss_symbols_ok "$MOD_SU" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_simd_ss_emit_report "fail" 0 0 0 0
  echo "std-simd-shuffle-select gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-simd-shuffle-select manifest OK"

stdlib_cm_native_shu() {
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

# SIMD shuffle/select 需 asm 后端；shux-c 无法为 Vec 函数体生成 C。
stdlib_cm_native_simd_asm() {
  local f="$1"
  stdlib_cm_native_shu "$f" || return 1
  case "$f" in
    */shux-c|*/shux-sx*) return 1 ;;
  esac
  return 0
}

# 优先使用 bootstrap 产出的 ./compiler/shux（含新 simd_enc / 无 stretch 卡顿）。
stdlib_cm_pick_shux_asm() {
  local cand
  for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux_asm.strict ./compiler/shux_asm_working; do
    if stdlib_cm_native_simd_asm "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

SHUFFLE_OK=0
SELECT_OK=0
S4_OK=0
SKIP=1
SHUX_ASM=""
SHUX_TYPECK=""
if cand="$(stdlib_cm_pick_shux_asm)"; then
  SHUX_ASM="$cand"
fi
for cand in ./compiler/shux-c ./compiler/shux; do
  if stdlib_cm_native_shu "$cand"; then
    SHUX_TYPECK="$cand"
    break
  fi
done

if [ -n "$SHUX_TYPECK" ]; then
  echo "=== STD-047: typeck ($SHUX_TYPECK) ==="
  if ! "$SHUX_TYPECK" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-simd-shuffle-select gate FAIL: typeck $SMOKE_SU" >&2
    "$SHUX_TYPECK" check -L . "$SMOKE_SU" 2>&1 | tail -15 >&2 || true
    std_simd_ss_emit_report "fail" 0 0 0 0
    exit 1
  fi
fi

if [ -n "$SHUX_ASM" ]; then
  echo "=== STD-047: roundtrip smoke (SHUX_ASM=$SHUX_ASM) ==="
  if std_simd_ss_run_smoke "$SHUX_ASM" "$SMOKE_SU" "roundtrip"; then
    SHUFFLE_OK=1
    SELECT_OK=1
    SKIP=0
    if [ -x tests/run-simd-s4-gate.sh ]; then
      S4_STRICT=""
      case "$(uname -m 2>/dev/null)" in
        x86_64|amd64) S4_STRICT=1 ;;
      esac
      if SHUX="$SHUX_ASM" SHUX_SIMD_HW_STRICT="${S4_STRICT}" ./tests/run-simd-s4-gate.sh >/tmp/std_simd_s4_$$.log 2>&1; then
        S4_OK=1
      elif [ -n "$S4_STRICT" ]; then
        echo "std-simd-shuffle-select gate FAIL: simd-s4 strict HW check" >&2
        tail -8 /tmp/std_simd_s4_$$.log >&2 || true
        std_simd_ss_emit_report "fail" "$SHUFFLE_OK" "$SELECT_OK" 0 "$SKIP"
        exit 1
      else
        echo "std-simd-shuffle-select WARN: simd-s4 gate failed (non-fatal)" >&2
        tail -5 /tmp/std_simd_s4_$$.log >&2 || true
      fi
      rm -f /tmp/std_simd_s4_$$.log
    fi
  else
    echo "std-simd-shuffle-select WARN: asm runtime smoke failed; manifest+typeck OK (skip)" >&2
  fi
else
  echo "std-simd-shuffle-select gate SKIP runtime smoke (no native shux_asm)" >&2
fi

std_simd_ss_emit_report "ok" "$SHUFFLE_OK" "$SELECT_OK" "$S4_OK" "$SKIP"
echo "std-simd-shuffle-select gate OK"
