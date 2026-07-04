#!/usr/bin/env bash
# STD-119：std.config YAML 可选后端门禁
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-config-yaml-v1.md"
MANIFEST="tests/baseline/std-config-yaml-manifest.tsv"
VECTORS="tests/baseline/std-config-yaml-vectors.tsv"
MOD_X="std/config/mod.x"
CFG_X="std/config/config.x"
LIB="tests/lib/std-config-yaml.sh"
SMOKE_X="tests/std-config/yaml_smoke.x"
SMOKE_C="tests/std-config/yaml_smoke_ok.c"
MIN_APIS=4

# shellcheck source=tests/lib/std-config-yaml.sh
. "$LIB"

for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$CFG_X" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || { echo "std-config-yaml gate FAIL: missing $f" >&2; exit 1; }
done

grep -qF load_yaml_buf "$DOC" || exit 1
grep -qF db.url "$VECTORS" || exit 1

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
  grep -qE "function ${anchor}\\(" "$MOD_X" || exit 1
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || exit 1

sym_miss="$(std_config_yaml_symbols_ok "$MOD_X" "$CFG_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || exit 1

C_OK=0
X_OK=0
SKIP=0

if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/config/config.o
  ensure_std_c_o ../std/env/env.o
  ensure_std_c_o ../std/process/process.o
  CFG_O="$(cd compiler && pwd)/../std/config/config.o"
  ENV_O="$(cd compiler && pwd)/../std/env/env.o"
  PROC_O="$(cd compiler && pwd)/../std/process/process.o"
  std_config_yaml_run_c_smoke "$CFG_O" "$ENV_O" "$PROC_O" && C_OK=1 || exit 1
else
  echo "std-config-yaml gate SKIP c smoke (need shux-c for config.x merge)" >&2
  SKIP=1
fi

if [ -x ./compiler/shux-c ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  ./compiler/shux-c check -L . "$SMOKE_X" >/dev/null
  std_config_yaml_run_x_smoke ./compiler/shux-c "$SMOKE_X" && X_OK=1 || exit 1
else
  echo "std-config-yaml gate SKIP .x smoke (no shux)" >&2
  SKIP=1
fi

std_config_yaml_emit_report ok "$C_OK" "$X_OK" "$SKIP"
echo "std-config-yaml gate OK"
