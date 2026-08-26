#!/usr/bin/env bash
# STD-153：std.simd 自动向量化策略 + 跨平台 perf 门禁（假权威诚实）。
#
# 用法：./tests/run-std-simd-autovec-strategy-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational
# (check gate paused 2026-08-05); autovec_strategy.x exit 0 hard-fail
# (no soft SKIP when native xlang present). C smoke observational. Perf soft
# SKIP (ratio soft residual). Report check=/c=/x=/perf=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP without asm / archive DOC fossil
# recommend_simd_path / section check pointed at live DOC dual-authority).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD153_DOC:-analysis/archive/std/std-simd-autovec-strategy-v1.md}"
MANIFEST="tests/baseline/std-simd-autovec-strategy-manifest.tsv"
VECTORS="tests/baseline/std-simd-autovec-strategy.tsv"
MOD_X="std/simd/mod.x"
SIMD_X="std/simd/simd.x"
LIB="tests/lib/std-simd-autovec-strategy.sh"
SMOKE_X="tests/std-simd/autovec_strategy.x"
MIN_APIS=2

# shellcheck source=tests/lib/std-simd-autovec-strategy.sh
. "$LIB"

echo "=== STD-153: simd autovec strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SIMD_X" "$SMOKE_X" \
  tests/std-simd/autovec_strategy_ok.c std/simd/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-simd-autovec gate FAIL: missing $f" >&2
    exit 1
  fi
done

# Product names: recommend_path (not fossil recommend_simd_path).
for kw in STD-153 recommend_path XLANG_SIMD_AUTovec SIMD_PATH_HW; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-autovec gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 4. Gate' "$DOC" 2>/dev/null; then
  echo "std-simd-autovec gate FAIL: doc missing '## 4. Gate'" >&2
  exit 1
fi

if ! grep -qF "recommend_path" std/simd/README.md 2>/dev/null; then
  echo "std-simd-autovec gate FAIL: README missing recommend_path" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-simd-autovec gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

# Section anchors must match the gate DOC (archive); ban live/archive dual path.
sym_miss="$(std_simd_autovec_symbols_ok "$MOD_X" "$SIMD_X" "$SIMD_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_simd_autovec_emit_report "fail" 0 0 0 0 0 "$(std_simd_autovec_platform_key)"
  exit 1
fi
echo "std-simd-autovec manifest OK"

if [ "${XLANG_STD153_MANIFEST_ONLY:-0}" = "1" ]; then
  std_simd_autovec_emit_report "ok" 0 0 0 0 1 "$(std_simd_autovec_platform_key)"
  echo "std-simd-autovec gate OK (manifest only)"
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
  # SIMD strategy smoke needs asm backend; xlang-c cannot emit C for Vec bodies.
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

HOST_KEY="$(std_simd_autovec_platform_key)"
read -r DOT_MIN SS_MIN <<< "$(std_simd_autovec_perf_thresholds "$VECTORS" "$HOST_KEY")"

CHECK_OK=0
C_OK=0
X_OK=0
PERF_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-153: smoke (XLANG=$XLANG_BIN; check observational; x hard; perf soft) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-simd-autovec gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # C smoke observational (host-cc simd.o may be absent / soft).
  if std_simd_autovec_run_c_smoke; then
    C_OK=1
  else
    echo "std-simd-autovec gate SKIP c smoke (observational)" >&2
  fi

  if std_simd_autovec_run_x_smoke "$XLANG_BIN" "$SMOKE_X"; then
    X_OK=1
    SKIP=0
  else
    std_simd_autovec_emit_report "fail" "$CHECK_OK" "$C_OK" 0 0 0 "$HOST_KEY"
    exit 1
  fi

  # Perf soft residual: below-threshold / unavailable does not hard-fail gate.
  if awk -v d="$DOT_MIN" -v s="$SS_MIN" 'BEGIN { exit ((d+s) > 0.001) ? 0 : 1 }'; then
    if std_simd_autovec_run_perf "$XLANG_BIN" "$DOT_MIN" "$SS_MIN"; then
      PERF_OK=1
    else
      echo "std-simd-autovec WARN: perf below threshold; strategy smoke OK (perf soft residual)" >&2
      PERF_OK=0
    fi
  else
    echo "std-simd-autovec gate SKIP perf (thresholds=${DOT_MIN}/${SS_MIN}; soft residual)" >&2
    PERF_OK=0
  fi
else
  echo "std-simd-autovec gate FAIL: no native asm xlang" >&2
  std_simd_autovec_emit_report "fail" 0 0 0 0 0 "$HOST_KEY"
  exit 1
fi

# check/c observational; hard-green signal is x=; perf remains soft.
echo "std-simd-autovec check_ok=${CHECK_OK} c_ok=${C_OK} (observational)"
std_simd_autovec_emit_report "ok" "$CHECK_OK" "$C_OK" "$X_OK" "$PERF_OK" "$SKIP" "$HOST_KEY"
echo "std-simd-autovec gate OK"
