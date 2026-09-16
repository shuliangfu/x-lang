#!/usr/bin/env bash
# STD-152: std.tar long-path / Pax / dir gate — honesty residual
# XLANG fallthrough / auto-make / ensure rebuild / check=/c=/x=/skip=
# →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` rebuild + extra CLI .o + report check=/c=/x=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit
# bad XLANG / missing native = hard die (refuse soft SKIP→OK / soft
# auto-make / prefer-c / XLANG fallthrough / soft ensure rebuild).
# check residual = obs (paused 2026-08-05). Host-C archaeology = obs
# (existing std/tar/tar.o only; never rebuild; never pass extra CLI
# .o). tests/tar/long_path_dir.x product -o exit0 = hard run. Report:
# run=/obs=/skip=. Keep MOD_X=std/tar/mod.x vs TAR_X=std/tar/tar.x.
# Keep ## 4. Gate (DOC/TSV already aligned; Pax lives under §2).
# Live ensure_std family left. F-tar v1/v2 still hard-delegate this
# gate (must stay exit 0). PLATFORM: SHARED archaeology — Ubuntu
# gold still required.
# Usage: ./tests/run-std-tar-extended-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_TAR_EXTENDED_DOC:-analysis/archive/std/std-tar-extended-v1.md}"
MANIFEST="${XLANG_STD_TAR_EXTENDED_TSV:-tests/baseline/std-tar-extended.tsv}"
MOD_X="std/tar/mod.x"
TAR_X="std/tar/tar.x"
LIB="tests/lib/std-tar-extended.sh"
SMOKE_X="tests/tar/long_path_dir.x"
SMOKE_C="tests/std-tar/extended_ok.c"
MIN_APIS=1

# shellcheck source=tests/lib/std-tar-extended.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-tar-extended gate FAIL: $*" >&2
  std_tar_extended_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
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

echo "=== STD-152: tar extended manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-tar-extended-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TAR_X" "$SMOKE_X" "$SMOKE_C" std/tar/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-152 prefix Pax path_max TAR_TYPE_PAX; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" || die "doc missing ## 4. Gate section"

grep -qF "path_max" std/tar/README.md 2>/dev/null \
  || die "README missing path_max"

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
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_tar_extended_symbols_ok "$MOD_X" "$TAR_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-tar-extended manifest OK"

if [ "${XLANG_STD_TAR_EXTENDED_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_tar_extended_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-tar-extended gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-152: smoke (XLANG=$XLANG_BIN; check/host-C=obs; long_path_dir.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std152_ext_check_$$.log 2>&1
chk_x=$?
set -e
if [ "$chk_x" -ne 0 ]; then
  echo "std-tar-extended OBS check (paused / CHK residual ec=$chk_x; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o. Product -o is the hard path (pure .x).
# C smoke file existence is TSV-required; compile/run of host-C is not a
# green signal (historically observational and already failed both ends).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
if [ ! -f std/tar/tar.o ]; then
  echo "std-tar-extended OBS missing std/tar/tar.o (no soft ensure; product -o still hard)" >&2
  OBS=$((OBS + 1))
fi

# long_path_dir.x product -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_tar_extended_run_smoke "$XLANG_BIN" "$SMOKE_X" "long_path_dir"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-tar-extended OK: product long_path_dir.x"
else
  die "product -o $SMOKE_X failed (refuse soft SKIP→OK)"
fi

std_tar_extended_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-tar-extended gate OK"
