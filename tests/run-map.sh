#!/usr/bin/env bash
# 测试 std.map（empty_size）：typeck + map.o 符号烟测
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || SHUX_LEGACY_C_FRONTEND=1 make -C compiler shux-c 2>/dev/null || make -C compiler -q 2>/dev/null || make -C compiler
SHUX="${SHUX:-}"
if [ -z "$SHUX" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if [ -x "$cand" ]; then SHUX="$cand"; break; fi
  done
fi
if [ -z "$SHUX" ] || [ ! -x "$SHUX" ]; then
  echo "map test SKIP (no shux/shux-c)"
  exit 0
fi
# shellcheck source=tests/lib/build-std-c-o.sh
. "$(dirname "$0")/lib/build-std-c-o.sh"
make -C compiler -q ../std/map/map.o 2>/dev/null || make -C compiler ../std/map/map.o
if ! "$SHUX" check -L . tests/map/main.x 2>&1; then
  echo "map test: typeck failed"
  exit 1
fi
if ! nm std/map/map.o 2>/dev/null | grep -q 'std_map_empty_size'; then
  echo "map test: missing std_map_empty_size in map.o"
  exit 1
fi
# 链入 map_import_alias 烟测：empty_size() 恒 0（mod.x 全量 emit 暂走 alias 回退）
exe="/tmp/shux_map_$$"
smoke_c="/tmp/shux_map_smoke_$$.c"
cat > "$smoke_c" <<'EOF'
#include <stdint.h>
extern int32_t std_map_empty_size(void);
int main(void) {
  return (int)std_map_empty_size();
}
EOF
if ! gcc -fPIE -o "$exe" "$smoke_c" std/map/map.o 2>&1; then
  echo "map test: link failed"
  rm -f "$exe" "$smoke_c"
  exit 1
fi
rm -f "$smoke_c"
exitcode=0
"$exe" 2>/dev/null || exitcode=$?
rm -f "$exe"
if [ "$exitcode" -ne 0 ]; then
  echo "map test: expected exit 0 (empty_size), got $exitcode"
  exit 1
fi
echo "map test OK"
