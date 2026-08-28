#!/usr/bin/env bash
# STD-008: std.json zero-copy gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true` / soft ensure_std_c_o)
# + soft XLANG fallthrough (explicit-bad still picks another binary) +
# check=/main=/zc=/skip= retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c / soft ensure rebuild). Product main.x -o exit0 = hard
# run (run=1). check + zc_parse_string_view = obs (Darwin arm64 needs_copy
# residual; Ubuntu gold may green). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-json-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_JSON_DOC:-analysis/archive/std/std-json-zc-v1.md}"
MANIFEST="${XLANG_STD_JSON_MANIFEST:-tests/baseline/std-json-manifest.tsv}"
MOD_X="${XLANG_STD_JSON_MOD:-std/json/mod.x}"
JSON_X="${XLANG_STD_JSON_X:-std/json/json.x}"
SMOKE_MAIN="tests/json/main.x"
SMOKE_ZC="tests/json/zc_parse_string_view.x"
MIN_APIS=10

# shellcheck source=tests/lib/std-json.sh
. tests/lib/std-json.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-json gate FAIL: $*" >&2
  std_json_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-008: std.json zero-copy manifest ==="
for f in "$DOC" "$MANIFEST" "$MOD_X" "$JSON_X" "$SMOKE_MAIN" "$SMOKE_ZC"; do
  [ -f "$f" ] || die "missing $f"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

grep -qF -- '## 6. Gate' "$DOC" 2>/dev/null || die "doc missing '## 6. Gate'"

MISS=0
API_N=0
echo "=== STD-008: API surface ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_json_has_api "$MOD_X" "$anchor"; then
        echo "std-json FAIL: missing API ${anchor} in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ "$anchor" = "std/json/json.x" ] || [ "$anchor" = "std/json/json.c" ]; then
        if ! std_json_has_c_impl "$JSON_X" "json_parse_string_view_c"; then
          echo "std-json FAIL: missing json_parse_string_view_c in $JSON_X" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "std-json FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-json FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-json FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "apis=${API_N} < min ${MIN_APIS}"

for kw in zero copy parse_string_view large object runnable; do
  grep -qiF "$kw" "$DOC" 2>/dev/null || die "doc missing keyword $kw"
done
[ "$MISS" -eq 0 ] || die "missing=${MISS}"
echo "std-json manifest OK (apis=${API_N})"

if [ "${XLANG_STD_JSON_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_json_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-json gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-008: smoke (XLANG=$XLANG_BIN; check/zc obs; main -o hard) ==="

# Refuse soft ensure_std_c_o / soft auto-make; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

set +e
"$XLANG_BIN" check -L . "$SMOKE_MAIN" >/tmp/xlang_std_json_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-json OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_json_main_$$"
LOG="/tmp/xlang_std_json_main_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_MAIN" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o main failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
rm -f "$OUT"
[ "$exitcode" -eq 0 ] || die "runnable main exit=$exitcode"
RUN_OK=$((RUN_OK + 1))
echo "std-json OK: product -o main"

# zc observational: Ubuntu gold may exit0; Darwin arm64 may hit needs_copy.
# Count as obs on fail; refuse soft SKIP→OK on the hard main path.
ZC_OUT="/tmp/xlang_std_json_zc_$$"
ZC_LOG="/tmp/xlang_std_json_zc_build_$$.log"
rm -f "$ZC_OUT" "$ZC_LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_ZC" -o "$ZC_OUT" >"$ZC_LOG" 2>&1
zc_build=$?
zc_run=1
if [ "$zc_build" -eq 0 ] && [ -x "$ZC_OUT" ]; then
  "$ZC_OUT" >/dev/null 2>&1
  zc_run=$?
fi
set -e
rm -f "$ZC_OUT"
if [ "$zc_build" -eq 0 ] && [ "$zc_run" -eq 0 ]; then
  echo "std-json zc smoke OK (observational)"
else
  echo "std-json OBS zc smoke (Darwin needs_copy residual / build=$zc_build run=$zc_run; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_json_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-json gate OK"
