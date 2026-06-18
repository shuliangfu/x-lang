#!/usr/bin/env bash
# STD-077：std.cli 门禁
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_STD_CLI_DOC:-analysis/std-cli-v1.md}"
MANIFEST="${SHU_STD_CLI_MANIFEST:-tests/baseline/std-cli-manifest.tsv}"
MOD_SU="std/cli/mod.su"
CLI_C="std/cli/cli.c"
LIB="tests/lib/std-cli.sh"
SMOKE_SU="tests/std-cli/roundtrip.su"
SMOKE_C="tests/std-cli/cli_smoke_ok.c"
COOKBOOK="examples/cookbook/cli_subcommand.su"
MIN_APIS=6

# shellcheck source=tests/lib/std-cli.sh
. "$LIB"

echo "=== STD-077: std.cli manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_SU" "$CLI_C" "$SMOKE_SU" "$SMOKE_C" "$COOKBOOK" std/cli/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-cli gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-077 parse_from_iter subcommand write_usage args_iter; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-cli gate FAIL: doc missing '$kw'" >&2
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
  if ! grep -qE "function ${anchor}\\(" "$MOD_SU" 2>/dev/null; then
    echo "std-cli gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-cli gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_cli_symbols_ok "$MOD_SU" "$CLI_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_cli_emit_report "fail" 0 0 0
  exit 1
fi
echo "std-cli manifest OK"

C_OK=0
SU_OK=0
SKIP=0

echo "=== STD-077: cli c smoke ==="
make -C compiler ../std/cli/cli.o >/dev/null 2>&1
if cc -std=c11 -O1 -o /tmp/shu_cli_smoke "$SMOKE_C" std/cli/cli.o 2>/dev/null; then
  if /tmp/shu_cli_smoke >/dev/null 2>&1; then C_OK=1; fi
  rm -f /tmp/shu_cli_smoke
fi
if [ "$C_OK" -eq 0 ]; then
  std_cli_emit_report "fail" 0 0 0
  echo "std-cli gate FAIL: c smoke" >&2
  exit 1
fi

SHU_BIN=""
if [ -x ./compiler/shu-c ]; then SHU_BIN=./compiler/shu-c; fi

if [ -n "$SHU_BIN" ]; then
  echo "=== STD-077: .su smoke (SHU=$SHU_BIN) ==="
  if ! "$SHU_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-cli gate FAIL: typeck" >&2
    "$SHU_BIN" check -L . "$SMOKE_SU" 2>&1 | tail -10 >&2 || true
    std_cli_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
  if std_cli_run_smoke "$SHU_BIN" "$SMOKE_SU" "roundtrip"; then SU_OK=1; else
    std_cli_emit_report "fail" "$C_OK" 0 0
    exit 1
  fi
else
  SKIP=1
fi

std_cli_emit_report "ok" "$C_OK" "$SU_OK" "$SKIP"
echo "std-cli gate OK"
