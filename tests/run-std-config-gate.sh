#!/usr/bin/env bash
# STD-086：std.config 门禁（含来源 meta）
#
# 用法：./tests/run-std-config-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_CONFIG_DOC:-analysis/std-config-v1.md}"
MANIFEST="${SHUX_STD_CONFIG_MANIFEST:-tests/baseline/std-config-manifest.tsv}"
MOD_X="std/config/mod.x"
CFG_X="std/config/config.x"
LIB="tests/lib/std-config.sh"
SMOKE_X="tests/std-config/layer_smoke.x"
SMOKE_C="tests/std-config/config_smoke_ok.c"
MIN_APIS=15

# shellcheck source=tests/lib/std-config.sh
. "$LIB"

echo "=== STD-086: std.config manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CFG_X" "$SMOKE_X" "$SMOKE_C" std/config/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-config gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-086 load_toml_file load_env_prefix merge get_i32 get_bool get_source source_toml; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-config gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

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
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-config gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-config gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_config_symbols_ok "$MOD_X" "$CFG_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_config_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-config manifest OK"

C_OK=0
X_OK=0
SKIP=0

echo "=== STD-086: config c smoke ==="
if [ -x ./compiler/shux-c ] || [ -x ./compiler/shux ]; then
  make -C compiler ../std/config/config.o ../std/env/env.o ../std/process/process.o runtime_process_argv.o runtime_process_os_glue.o runtime_env_os.o >/dev/null 2>&1
  if cc -std=c11 -O1 -o /tmp/shux_config_smoke \
    "$SMOKE_C" std/config/config.o std/env/env.o std/process/process.o compiler/runtime_process_argv.o compiler/runtime_process_os_glue.o compiler/runtime_env_os.o 2>/dev/null; then
    if /tmp/shux_config_smoke >/dev/null 2>&1; then C_OK=1; fi
    rm -f /tmp/shux_config_smoke
  fi
else
  echo "std-config gate SKIP c smoke (need shux-c for config.x merge)" >&2
  SKIP=1
fi
if [ "$C_OK" -eq 0 ] && [ "$SKIP" -eq 0 ]; then
  std_config_emit_report "fail" 0 0 0
  echo "std-config gate FAIL: c smoke" >&2
  exit 1
fi

SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-086: .x smoke (SHUX=$SHUX_BIN) ==="
  if ! "$SHUX_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    echo "std-config gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE_X" 2>&1 | tail -10 >&2 || true
    std_config_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_config_run_smoke "$SHUX_BIN" "$SMOKE_X" "layer"; then X_OK=1; else
    std_config_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  echo "std-config gate SKIP .x smoke (no shux)" >&2
  SKIP=1
fi

std_config_emit_report "ok" "$C_OK" "$X_OK" "$SKIP"
echo "std-config gate OK"
