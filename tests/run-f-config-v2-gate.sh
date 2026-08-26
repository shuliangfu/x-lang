#!/usr/bin/env bash
# F-config v2: TOML/YAML/ENV in config.x (F-ZC; io glue deleted).
#
# Usage: ./tests/run-f-config-v2-gate.sh
#        XLANG=./compiler/xlang_asm ./tests/run-f-config-v2-gate.sh
# 2026-08-27: Honesty — hard-fail static TSV + ## Gate + prefer-asm ensure +
# STD-086 config + STD-119 config-yaml hard delegate.
# Soft XLANG_F_CONFIG_V2_FAIL retired.
# Root: soft die→exit0 = portable false-green (static+STD already green).
# Report static=/ensure=/cfg=/yaml=/skip=. PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/dod-native-exe.sh
source "$(dirname "$0")/lib/dod-native-exe.sh"
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="analysis/archive/phase/phase-f-config-v2.md"
MANIFEST="tests/baseline/f-config-v2-closure.tsv"
PREFIX="xlang: [XLANG_F_CONFIG_V2]"

resolve_shu() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

die() {
  echo "f-config-v2 gate FAIL: $*" >&2
  echo "${PREFIX} status=fail static=${STATIC_OK:-0} ensure=${ENSURE_OK:-0} cfg=${CFG_OK:-0} yaml=${YAML_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

STATIC_OK=0
ENSURE_OK=0
CFG_OK=0
YAML_OK=0
SKIP=1

echo "=== F-config v2: config logic → config.x (honesty) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-config v2' "$DOC" || die "doc missing F-config v2 marker"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"
[ -f xbuild ] || die "missing xbuild"
if [ -f compiler/Makefile ]; then
  die "compiler/Makefile resurrected (use ./xbuild)"
fi
[ -f std/config/config.x ] || die "missing config.x"
[ ! -f std/config/config_io_glue.c ] || die "config_io_glue.c should be deleted (F-ZC)"
[ ! -f std/config/config_glue.c ] || die "config_glue.c should be deleted"

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile)
      [ -f "$anchor" ] || die "missing $anchor ($item_id)"
      ;;
    absent)
      [ ! -f "$anchor" ] || die "$anchor should be absent ($item_id)"
      ;;
    *)
      die "manifest unknown kind '$kind' for $item_id"
      ;;
  esac
done < "$MANIFEST"
grep -q 'config_load_toml_buf_c' std/config/config.x || die "config.x missing toml load"
grep -q 'config_load_yaml_buf_c' std/config/config.x || die "config.x missing yaml load"
grep -q 'config_smoke_c' std/config/config.x || die "config.x missing smoke"
grep -q 'config_f_config_v2_marker_c' std/config/config.x || die "config.x missing v2 marker"
grep -q 'config_f_zero_c_marker_c' std/config/config.x || die "config.x missing zero-c marker"
grep -q 'config_read_file_c' std/config/config.x || die "config.x missing read_file"
grep -q 'fs_open_read_c' std/config/config.x || die "config.x missing fs IO"
STATIC_OK=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  die "no native xlang"
fi
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
export XLANG_SKIP_SUBSCRIPT_MAKE=1
SKIP=0

xlang_compiler_make ../std/config/config.o >/dev/null 2>&1 \
  || die "ensure config.o failed (xlang_compiler_make; prefer asm)"
ENSURE_OK=1

# Hard-delegate already soft→硬绿 STD-086 / STD-119.
# Do NOT export retired XLANG_F_CONFIG_V2_FAIL.
# PLATFORM: SHARED archaeology.
if [ -f tests/run-std-config-gate.sh ]; then
  echo "=== F-config v2: delegate run-std-config-gate (hard) ==="
  chmod +x tests/run-std-config-gate.sh
  if ! tests/run-std-config-gate.sh; then
    die "std-config sub-gate failed"
  fi
  CFG_OK=1
else
  die "missing tests/run-std-config-gate.sh"
fi

if [ -f tests/run-std-config-yaml-gate.sh ]; then
  echo "=== F-config v2: delegate run-std-config-yaml-gate (hard) ==="
  chmod +x tests/run-std-config-yaml-gate.sh
  if ! tests/run-std-config-yaml-gate.sh; then
    die "std-config-yaml sub-gate failed"
  fi
  YAML_OK=1
else
  die "missing tests/run-std-config-yaml-gate.sh"
fi

echo "${PREFIX} status=ok static=${STATIC_OK} ensure=${ENSURE_OK} cfg=${CFG_OK} yaml=${YAML_OK} skip=${SKIP} host=$(ci_host_summary)"
echo "f-config-v2 gate OK (F-config v2; honesty)"
