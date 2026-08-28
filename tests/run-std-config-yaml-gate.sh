#!/usr/bin/env bash
# STD-119: std.config YAML optional backend gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make (`xlang_compiler_make … || true`) + check=/run=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / soft
# ensure rebuild). Product yaml_smoke.x -o exit0 = hard run (run=1). check /
# host-C archaeology = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-config-yaml-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD119_CONFIG_YAML_DOC:-analysis/archive/std/std-config-yaml-v1.md}"
MANIFEST="${XLANG_STD119_CONFIG_YAML_MANIFEST:-tests/baseline/std-config-yaml-manifest.tsv}"
VECTORS="tests/baseline/std-config-yaml-vectors.tsv"
MOD_X="std/config/mod.x"
CFG_X="std/config/config.x"
LIB="tests/lib/std-config-yaml.sh"
SMOKE_X="tests/std-config/yaml_smoke.x"
SMOKE_C="tests/std-config/yaml_smoke_ok.c"
MIN_APIS=4
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-config-yaml.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-config-yaml gate FAIL: $*" >&2
  std_config_yaml_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-119: std.config YAML manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$CFG_X" "$SMOKE_X" "$SMOKE_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-119 load_yaml_buf load_yaml_file backend_yaml yaml_smoke db.url; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null && ! grep -qF -- "$kw" "$VECTORS" 2>/dev/null; then
    die "doc/vectors missing '$kw'"
  fi
done

grep -qF load_yaml_buf "$DOC" || die "doc missing load_yaml_buf"
grep -qF db.url "$VECTORS" || die "vectors missing db.url"
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

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
  grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_config_yaml_symbols_ok "$MOD_X" "$CFG_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-config-yaml manifest OK"

if [ "${XLANG_STD119_CONFIG_YAML_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_config_yaml_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-config-yaml gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-119: smoke (XLANG=$XLANG_BIN; check/host-C obs; product -o hard) ==="

# Host-C archaeology = obs only; refuse soft ensure/auto-make rebuild.
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if std_config_yaml_run_c_smoke; then
  echo "std-config-yaml c smoke OK (observational)"
else
  echo "std-config-yaml OBS c smoke (host-C archaeology; refuse soft ensure/auto-make)" >&2
  OBS=$((OBS + 1))
fi

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std119_yaml_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-config-yaml OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std119_config_yaml_$$"
LOG="/tmp/xlang_std119_config_yaml_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-config-yaml OK: product -o"

std_config_yaml_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-config-yaml gate OK"
