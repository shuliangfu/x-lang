#!/usr/bin/env bash
# STD-136：std.datetime IANA 时区 + DST 门禁
set -e
cd "$(dirname "$0")/.."
MANIFEST="tests/baseline/std-datetime-iana-manifest.tsv"
MOD_X="std/datetime/mod.x"
DT_X="std/datetime/datetime.x"
SMOKE_X="tests/std-datetime/iana_dst_smoke.x"

echo "=== STD-136: std.datetime IANA manifest ==="
for f in "$MANIFEST" "$MOD_X" "$DT_X" "$SMOKE_X"; do
  [ -f "$f" ] || { echo "std-datetime-iana gate FAIL: missing $f" >&2; exit 1; }
done

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      grep -qE "function ${anchor}" "$MOD_X" || { echo "std-datetime-iana FAIL: missing $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
    symbol)
      grep -qF "$anchor" "$mod_path" || { echo "std-datetime-iana FAIL: missing $anchor in $mod_path" >&2; MISS=$((MISS + 1)); }
      ;;
    smoke)
      [ -f "$anchor" ] || { echo "std-datetime-iana FAIL: missing $anchor" >&2; MISS=$((MISS + 1)); }
      ;;
  esac
done < "$MANIFEST"
[ "$MISS" -eq 0 ] || exit 1
echo "std-datetime-iana manifest OK"

. tests/lib/build-std-c-o.sh
ensure_std_c_o ../std/datetime/datetime.o
ensure_std_c_o ../std/time/time.o
DT_O="$(cd compiler && pwd)/../std/datetime/datetime.o"
TIME_O="$(cd compiler && pwd)/../std/time/time.o"
OUT="/tmp/shux_std_dt_iana_c_$$"
if nm std/time/time.o 2>/dev/null | grep -qF 'time_now_wall_sec_c'; then
  cat > /tmp/shux_std_dt_iana_c_main.c <<'EOF'
#include <stdint.h>
extern int32_t datetime_iana_dst_smoke_c(void);
int main(void) { return datetime_iana_dst_smoke_c() != 0; }
EOF
  make -C compiler runtime_time_os.o >/dev/null 2>&1 || true
  cc -std=c11 -O1 -o "$OUT" /tmp/shux_std_dt_iana_c_main.c "$DT_O" "$TIME_O" compiler/runtime_time_os.o
  "$OUT" || { echo "std-datetime-iana FAIL: C smoke" >&2; rm -f "$OUT"; exit 1; }
  rm -f "$OUT" /tmp/shux_std_dt_iana_c_main.c
else
  echo "std-datetime-iana gate SKIP c smoke (time.o missing time_now_wall_sec_c; need shux-c)" >&2
fi

if [ -x ./compiler/shux-c ]; then
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . tests/lib/bootstrap-link-shux.sh
  EXE="/tmp/shux_std_dt_iana_x_$$"
  $RUN_SHUX -L . "$SMOKE_X" -o "$EXE" >/dev/null
  "$EXE" || { echo "std-datetime-iana FAIL: x smoke" >&2; rm -f "$EXE"; exit 1; }
  rm -f "$EXE"
fi

echo "std-datetime-iana gate OK"
