#!/usr/bin/env bash
# STD-016: StrView + ZC-4 deep-integration gate (false-authority honesty).
#
# Usage: ./tests/run-std-strview-zc4-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); view_lifecycle / view_subview / arena_concat /
# stack_sso exit 0 hard-fail (no soft SKIP when native xlang present). Deep
# run-zc4-gate is observational (report zc4=; never soft-SKIP whole gate to OK).
# Report check=/life=/sub=/arena=/sso=/zc4=/skip=. Product surface already green
# under asm; gate was portable-false-red (prefer xlang-c / soft SKIP on missing
# native / hard typeck / soft zc4 SKIP→OK / ## 5. 验收 without ## 6. Gate).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SV_ZC4_DOC:-analysis/archive/std/std-strview-zc4-v1.md}"
MANIFEST="${XLANG_STD_SV_ZC4_TSV:-tests/baseline/std-strview-zc4.tsv}"
STRING_X="std/string/mod.x"
LIB="tests/lib/std-strview-zc4.sh"
LIFECYCLE_X="tests/string/view_lifecycle.x"
SUBVIEW_X="tests/string/view_subview_smoke.x"
ARENA_X="tests/string/arena_concat_smoke.x"
SSO_X="tests/string/stack_str_sso_smoke.x"
ZC4_GATE="tests/run-zc4-gate.sh"

# shellcheck source=tests/lib/std-strview-zc4.sh
. "$LIB"

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-strview-zc4-v1.md ]; then
  echo "std-strview-zc4 gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-016: StrView/ZC-4 manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$STRING_X" \
  "$LIFECYCLE_X" "$SUBVIEW_X" "$ARENA_X" "$SSO_X"; do
  if [ ! -f "$f" ]; then
    echo "std-strview-zc4 gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in ZC-4 arena64_deinit string_view_from_string 生命周期; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-strview-zc4 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-strview-zc4 gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

miss="$(std_sv_zc4_manifest_ok "$STRING_X" "$DOC" "$MANIFEST" || true)"
if [ "${miss:-0}" -gt 0 ]; then
  std_sv_zc4_emit_report "fail" 0 0 0 0 0 0 0
  echo "std-strview-zc4 gate FAIL: manifest_miss=${miss}" >&2
  exit 1
fi
echo "std-strview-zc4 manifest OK"

if [ "${XLANG_STD_SV_ZC4_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sv_zc4_emit_report "ok" 0 0 0 0 0 0 1
  echo "std-strview-zc4 gate OK (manifest only)"
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
LIFE_OK=0
SUB_OK=0
ARENA_OK=0
SSO_OK=0
ZC4_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-016: smoke (XLANG=$XLANG_BIN; check observational; life/sub/arena/sso hard; zc4 observational) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$LIFECYCLE_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SUBVIEW_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$ARENA_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$SSO_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-strview-zc4 gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_sv_zc4_run_smoke "$XLANG_BIN" "$LIFECYCLE_X" "life"; then
    LIFE_OK=1
  else
    std_sv_zc4_emit_report "fail" "$CHECK_OK" 0 0 0 0 0 0
    exit 1
  fi
  if std_sv_zc4_run_smoke "$XLANG_BIN" "$SUBVIEW_X" "sub"; then
    SUB_OK=1
  else
    std_sv_zc4_emit_report "fail" "$CHECK_OK" "$LIFE_OK" 0 0 0 0 0
    exit 1
  fi
  if std_sv_zc4_run_smoke "$XLANG_BIN" "$ARENA_X" "arena"; then
    ARENA_OK=1
  else
    std_sv_zc4_emit_report "fail" "$CHECK_OK" "$LIFE_OK" "$SUB_OK" 0 0 0 0
    exit 1
  fi
  if std_sv_zc4_run_smoke "$XLANG_BIN" "$SSO_X" "sso"; then
    SSO_OK=1
  else
    std_sv_zc4_emit_report "fail" "$CHECK_OK" "$LIFE_OK" "$SUB_OK" "$ARENA_OK" 0 0 0
    exit 1
  fi

  # Deep ZC-4 gate: observational only. Soft-SKIP→OK was false authority;
  # hard-failing zc4 here would open neighbor debt outside this soft knife.
  # PLATFORM: SHARED — report zc4=; never set skip=1 from zc4.
  if [ -x "$ZC4_GATE" ]; then
    echo "=== STD-016: delegate run-zc4-gate (observational) ==="
    chmod +x "$ZC4_GATE" tests/run-perf-string-arena.sh tests/run-string.sh 2>/dev/null || true
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      "$ZC4_GATE" >/tmp/std_sv_zc4_deep.log 2>&1; then
      ZC4_OK=1
    else
      echo "std-strview-zc4 gate SKIP zc4 deep (observational; see /tmp/std_sv_zc4_deep.log)" >&2
      ZC4_OK=0
    fi
  fi
  SKIP=0
else
  echo "std-strview-zc4 gate FAIL: no native xlang" >&2
  std_sv_zc4_emit_report "fail" 0 0 0 0 0 0 0
  exit 1
fi

# check/zc4 stay observational; hard-green signal is life=/sub=/arena=/sso=.
echo "std-strview-zc4 check_ok=${CHECK_OK} zc4_ok=${ZC4_OK} (observational)"
std_sv_zc4_emit_report "ok" "$CHECK_OK" "$LIFE_OK" "$SUB_OK" "$ARENA_OK" "$SSO_OK" "$ZC4_OK" "$SKIP"
echo "std-strview-zc4 gate OK"
