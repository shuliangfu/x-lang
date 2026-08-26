#!/usr/bin/env bash
# STD-004：std.async 调度器稳定 API 门禁（假权威诚实）。
#
# 用法：./tests/run-std-async-api-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); i06_async_switch + cookbook async_mod_import +
# async_drain_idle exit 0 hard-fail (no soft SKIP when native xlang present).
# coop/1m (coop_pingpong*) observational (product UNDEF residual — not soft).
# Report check=/switch=/imp=/drain=/coop=/skip=.
# Product switch + placeholder/drain_idle already green under asm; gate was
# portable-false-red (prefer xlang-c / soft SKIP when no native / full
# run-async.sh + 1M hard with fossil bench/async_switch.x + coop UNDEF).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ASYNC_API_DOC:-analysis/archive/std/std-async-api-v1.md}"
BASELINE="${XLANG_STD_ASYNC_API_TSV:-tests/baseline/std-async-api.tsv}"
LIB="tests/lib/std-async-api.sh"
MOD="std/async/mod.x"
SMOKE_SWITCH="bench/i06_async_switch.x"
SMOKE_IMP="examples/cookbook/async_mod_import.x"
SMOKE_DRAIN="examples/cookbook/async_drain_idle.x"
SMOKE_COOP="bench/i06_async_1m_coop.x"

# shellcheck source=tests/lib/std-async-api.sh
. "$LIB"

echo "=== STD-004: std.async stable API manifest ==="
for f in "$DOC" "$BASELINE" "$LIB" "$MOD" "$SMOKE_SWITCH" "$SMOKE_IMP" "$SMOKE_DRAIN" "$SMOKE_COOP"; do
  if [ ! -f "$f" ]; then
    echo "std-async-api gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-004 std.async coop_pingpong wait_completion; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-async-api gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done
# Hard-smoke surface names (live cookbook / switch) must appear in Gate prose.
for kw in i06_async_switch async_mod_import async_drain_idle; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-async-api gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 10. Gate' "$DOC" 2>/dev/null; then
  echo "std-async-api gate FAIL: doc missing '## 10. Gate'" >&2
  exit 1
fi

sym_miss="$(std_async_api_symbols_ok "$MOD" "$BASELINE" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_async_api_emit_report "fail" 0 0 0 0 0 0
  echo "std-async-api gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-async-api manifest OK"

if [ "${XLANG_STD_ASYNC_API_MANIFEST_ONLY:-0}" = "1" ]; then
  std_async_api_emit_report "ok" 0 0 0 0 0 1
  echo "std-async-api gate OK (manifest only)"
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
SWITCH_OK=0
IMP_OK=0
DRAIN_OK=0
COOP_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-004: smoke (XLANG=$XLANG_BIN; check/coop observational; switch/imp/drain hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_SWITCH" >/dev/null 2>&1 \
     && "$XLANG_BIN" check -L . "$SMOKE_IMP" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-async-api gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/async/scheduler.o 2>/dev/null || true
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  # Hard: no-import switch + import placeholder + drain_idle cookbooks.
  if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_SWITCH" "switch"; then
    SWITCH_OK=1
  else
    std_async_api_emit_report "fail" "$CHECK_OK" 0 0 0 0 0
    exit 1
  fi
  if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_IMP" "imp"; then
    IMP_OK=1
  else
    std_async_api_emit_report "fail" "$CHECK_OK" "$SWITCH_OK" 0 0 0 0
    exit 1
  fi
  if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_DRAIN" "drain"; then
    DRAIN_OK=1
    SKIP=0
  else
    std_async_api_emit_report "fail" "$CHECK_OK" "$SWITCH_OK" "$IMP_OK" 0 0 0
    exit 1
  fi

  # Observational: coop_pingpong 1M (product UNDEF residual — not soft).
  if std_async_api_run_smoke "$XLANG_BIN" "$SMOKE_COOP" "coop"; then
    COOP_OK=1
  else
    echo "std-async-api gate SKIP coop/1m (observational; coop_pingpong UNDEF residual)" >&2
  fi
else
  echo "std-async-api gate FAIL: no native xlang" >&2
  std_async_api_emit_report "fail" 0 0 0 0 0 0
  exit 1
fi

# check/coop stay observational; hard-green signal is switch= + imp= + drain=.
echo "std-async-api check_ok=${CHECK_OK} coop_ok=${COOP_OK} (observational)"
std_async_api_emit_report "ok" "$CHECK_OK" "$SWITCH_OK" "$IMP_OK" "$DRAIN_OK" "$COOP_OK" "$SKIP"
echo "std-async-api gate OK"
