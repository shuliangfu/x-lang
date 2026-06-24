#!/usr/bin/env bash
# STD-052：std.backtrace 符号化门禁
#
# 用法：./tests/run-std-backtrace-symbolicate-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${SHUX_STD_BACKTRACE_SYM_DOC:-analysis/std-backtrace-symbolicate-v1.md}"
MANIFEST="${SHUX_STD_BACKTRACE_SYM_TSV:-tests/baseline/std-backtrace-symbolicate.tsv}"
VECTORS="${SHUX_STD_BACKTRACE_SYM_VECTORS:-tests/baseline/std-backtrace-symbolicate-vectors.tsv}"
MOD_SX="std/backtrace/mod.sx"
BT_RUNTIME="compiler/src/asm/runtime_backtrace_platform.c"
BT_SX="std/backtrace/backtrace.sx"
LIB="tests/lib/std-backtrace-symbolicate.sh"
SMOKE_SX="tests/backtrace/symbolicate_known.sx"
SMOKE_C="tests/backtrace/symbolicate_gold.c"
MIN_APIS=2

# shellcheck source=tests/lib/std-backtrace-symbolicate.sh
. "$LIB"

echo "=== STD-052: backtrace symbolicate manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$BT_SX" "$BT_RUNTIME" "$SMOKE_SX" "$SMOKE_C"; do
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
      if ! grep -qE "function ${anchor}\\(" "$MOD_SX" 2>/dev/null; then
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

sym_miss="$(std_backtrace_sym_symbols_ok "$MOD_SX" "$BT_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_backtrace_sym_emit_report "fail" 0 0 0 "$(ci_host_summary)"
  echo "std-backtrace-symbolicate gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-backtrace-symbolicate manifest OK"

C_OK=0
SX_OK=0
SKIP=0
SKIP_GOLD=0
SHUX_BIN=""
stdlib_cm_native_shu() {
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
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
fi

if [ -n "$SHUX_BIN" ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/backtrace/backtrace.o
  ensure_runtime_backtrace_platform_o

  if std_backtrace_sym_gold_supported; then
    if std_backtrace_sym_run_c_gold "$BT_RUNTIME"; then
      C_OK=1
    else
      std_backtrace_sym_emit_report "fail" 0 0 0 "$(ci_host_summary)"
      exit 1
    fi
  else
    echo "std-backtrace-symbolicate gate SKIP C gold (no execinfo; e.g. Alpine/musl)" >&2
    C_OK=1
    SKIP_GOLD=1
  fi

  echo "=== STD-052: .sx smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_SX" >/dev/null 2>&1; then
    echo "std-backtrace-symbolicate gate FAIL: typeck $SMOKE_SX" >&2
    "$SHUX_BIN" check -L . "$SMOKE_SX" 2>&1 | tail -10 >&2 || true
    std_backtrace_sym_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
  if std_backtrace_sym_run_smoke "$SHUX_BIN" "$SMOKE_SX" "known"; then
    SX_OK=1
  else
    std_backtrace_sym_emit_report "fail" "$C_OK" 0 0 "$(ci_host_summary)"
    exit 1
  fi
else
  echo "std-backtrace-symbolicate gate SKIP C/.sx smoke (no native shux-c)" >&2
  SKIP=1
fi

std_backtrace_sym_emit_report "ok" "$C_OK" "$SX_OK" "$((SKIP + SKIP_GOLD))" "$(ci_host_summary)"
echo "std-backtrace-symbolicate gate OK"
