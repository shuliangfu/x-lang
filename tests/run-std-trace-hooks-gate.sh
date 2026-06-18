#!/usr/bin/env bash
# STD-118：std.trace 关键路径挂钩门禁
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-trace-hooks-v1.md"
MANIFEST="tests/baseline/std-trace-hooks-manifest.tsv"
VECTORS="tests/baseline/std-trace-hooks-vectors.tsv"
MOD_SU="std/trace/mod.su"
TRACE_C="std/trace/trace.c"
LIB="tests/lib/std-trace-hooks.sh"
SMOKE_SU="tests/std-trace/hooks_smoke.su"
SMOKE_C="tests/std-trace/hooks_smoke_ok.c"
MIN_APIS=6

# shellcheck source=tests/lib/std-trace-hooks.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$TRACE_C" "$SMOKE_SU" "$SMOKE_C"; do
  [ -f "$f" ] || { echo "std-trace-hooks gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF hook_io_read_ctx "$DOC" || exit 1
grep -qF io.read "$VECTORS" || exit 1

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  grep -qE "function ${anchor}\\(" "$MOD_SU" || exit 1
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || exit 1

sym_miss="$(std_trace_hooks_symbols_ok "$MOD_SU" "$TRACE_C" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/trace/trace.o
ensure_std_c_o ../std/time/time.o
ensure_std_c_o ../std/random/random.o
TRACE_O="$(cd compiler && pwd)/../std/trace/trace.o"
TIME_O="$(cd compiler && pwd)/../std/time/time.o"
RANDOM_O="$(cd compiler && pwd)/../std/random/random.o"

C_OK=0
std_trace_hooks_run_c_smoke "$TRACE_O" "$TIME_O" "$RANDOM_O" && C_OK=1 || exit 1

SU_OK=0
SKIP=0
if [ -x ./compiler/shu-c ]; then
  make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || true
  ./compiler/shu-c check -L . "$SMOKE_SU" >/dev/null
  std_trace_hooks_run_su_smoke ./compiler/shu-c "$SMOKE_SU" && SU_OK=1 || exit 1
else
  SKIP=1
fi

std_trace_hooks_emit_report ok "$C_OK" "$SU_OK" "$SKIP"
echo "std-trace-hooks gate OK"
