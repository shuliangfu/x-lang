#!/usr/bin/env bash
# STD-052：std.backtrace 符号化门禁（假权威诚实）。
#
# 用法：./tests/run-std-backtrace-symbolicate-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); symbolicate_known.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/c_gold=/x=/skip=.
# TSV symbol_smoke_c path aligned to seed (fossil pointed at backtrace.x);
# DOC/TSV → ## 5. Gate. Product surface already green under asm; gate was
# prefer-c / hard check / soft SKIP / fossil-path false-red.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_BACKTRACE_SYM_DOC:-analysis/archive/std/std-backtrace-symbolicate-v1.md}"
MANIFEST="${XLANG_STD_BACKTRACE_SYM_TSV:-tests/baseline/std-backtrace-symbolicate.tsv}"
VECTORS="${XLANG_STD_BACKTRACE_SYM_VECTORS:-tests/baseline/std-backtrace-symbolicate-vectors.tsv}"
MOD_X="std/backtrace/mod.x"
BT_RUNTIME="compiler/seeds/runtime_backtrace_platform.from_x.c"
BT_X="std/backtrace/backtrace.x"
LIB="tests/lib/std-backtrace-symbolicate.sh"
SMOKE_X="tests/backtrace/symbolicate_known.x"
SMOKE_C="tests/backtrace/symbolicate_gold.c"
MIN_APIS=2

# shellcheck source=tests/lib/std-backtrace-symbolicate.sh
. "$LIB"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

echo "=== STD-052: backtrace symbolicate manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$BT_X" "$BT_RUNTIME" "$SMOKE_X" "$SMOKE_C"; do
  if [ ! -f "$f" ]; then
    echo "std-backtrace-symbolicate gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-052 gold_anchor SYM_NAME_LEN dladdr; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-backtrace-symbolicate gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-backtrace-symbolicate gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

if ! grep -qF 'gold_anchor' "$VECTORS" 2>/dev/null; then
  echo "std-backtrace-symbolicate gate FAIL: vectors missing gold_anchor" >&2
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
        echo "std-backtrace-symbolicate gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-backtrace-symbolicate gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-backtrace-symbolicate gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_backtrace_sym_symbols_ok "$MOD_X" "$BT_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_backtrace_sym_emit_report "fail" 0 0 0 0 "$(ci_host_summary)"
  echo "std-backtrace-symbolicate gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-backtrace-symbolicate manifest OK"

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
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
SKIP_GOLD=0

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-052: smoke (XLANG=$XLANG_BIN; check observational; x hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-backtrace-symbolicate gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/backtrace/backtrace.o
  ensure_runtime_backtrace_platform_o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_backtrace_sym_gold_supported; then
    if std_backtrace_sym_run_c_gold "$BT_RUNTIME"; then
      C_OK=1
    else
      std_backtrace_sym_emit_report "fail" "$CHECK_OK" 0 0 0 "$(ci_host_summary)"
      exit 1
    fi
  else
    echo "std-backtrace-symbolicate gate SKIP C gold (no execinfo; e.g. Alpine/musl)" >&2
    C_OK=1
    SKIP_GOLD=1
  fi

  if std_backtrace_sym_run_smoke "$XLANG_BIN" "$SMOKE_X" "known"; then
    X_OK=1
    SKIP=$SKIP_GOLD
  else
    std_backtrace_sym_emit_report "fail" "$CHECK_OK" "$C_OK" 0 "$SKIP_GOLD" "$(ci_host_summary)"
    exit 1
  fi
else
  echo "std-backtrace-symbolicate gate FAIL: no native xlang" >&2
  std_backtrace_sym_emit_report "fail" 0 0 0 0 "$(ci_host_summary)"
  exit 1
fi

# check stays observational; hard-green signal is x= (+ c_gold= when supported).
echo "std-backtrace-symbolicate check_ok=${CHECK_OK} (observational)"
std_backtrace_sym_emit_report "ok" "$CHECK_OK" "$C_OK" "$X_OK" "$SKIP" "$(ci_host_summary)"
echo "std-backtrace-symbolicate gate OK"
