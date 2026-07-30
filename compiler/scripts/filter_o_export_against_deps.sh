#!/usr/bin/env bash
# filter_o_export_against_deps.sh — pure-shell authority for ld -r partial export
# of one object, omitting symbols also defined in dependency objects.
#
# Purpose:
#   Class-G bootstrap_seed_*_filtered.o recipes (pipeline / user_asm bridge /
#   compat stubs / backend_x86_64_enc) and any future omit-set filter share one
#   nm + ld -r implementation (G.7). Makefile and g05 must call this script
#   (or a thin named wrapper); do not re-copy the filter body.
#
# Semantics (historical Makefile class G):
#   nm SRC [TDS] minus union(nm DEP [TDS] for each present DEP) → keep with
#   leading '_' → Darwin ld -r -exported_symbols_list / Linux --version-script.
#
# Usage (cwd = compiler/):
#   sh scripts/filter_o_export_against_deps.sh \
#     --src SRC.o --out OUT.o --stem NAME [--omit DEP.o]... [--require-keep]
#   # positional:
#   sh scripts/filter_o_export_against_deps.sh SRC OUT STEM [DEP...]
#   # optional env:
#   FILTER_REQUIRE_KEEP=1  — fail if keep list empty (pipeline)
#
# Exit: 0 success; 1 missing SRC / ld failure / empty keep when required
#
# PLATFORM: SHARED — Darwin product link is primary consumer of filtered.o;
# Linux may build for hygiene (product link often uses bare .o).

set -euo pipefail
# PLATFORM: SHARED — GNU comm rejects non-C locale order (Ubuntu L2 hang/fail);
# force C collate for sort -u / comm -23 of nm symbol lists.
export LC_ALL=C

_script_dir="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
_compiler_dir="$(CDPATH= cd -- "$_script_dir/.." && pwd)"
cd "$_compiler_dir"

SRC_O=""
OUT_O=""
STEM=""
REQUIRE_KEEP="${FILTER_REQUIRE_KEEP:-0}"
OMITS=()

usage() {
  echo "usage: filter_o_export_against_deps.sh --src SRC --out OUT --stem STEM [--omit DEP]... [--require-keep]" >&2
  echo "   or: filter_o_export_against_deps.sh SRC OUT STEM [DEP...]" >&2
  exit 2
}

if [ "$#" -ge 1 ] && [ "${1#-}" = "$1" ]; then
  # positional mode
  [ "$#" -ge 3 ] || usage
  SRC_O="$1"
  OUT_O="$2"
  STEM="$3"
  shift 3
  while [ "$#" -gt 0 ]; do
    OMITS+=("$1")
    shift
  done
else
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --src)
        SRC_O="${2:-}"
        shift 2
        ;;
      --out)
        OUT_O="${2:-}"
        shift 2
        ;;
      --stem)
        STEM="${2:-}"
        shift 2
        ;;
      --omit)
        OMITS+=("${2:-}")
        shift 2
        ;;
      --require-keep)
        REQUIRE_KEEP=1
        shift
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "filter_o_export_against_deps: unknown arg: $1" >&2
        usage
        ;;
    esac
  done
fi

if [ -z "$SRC_O" ] || [ -z "$OUT_O" ] || [ -z "$STEM" ]; then
  usage
fi

if [ ! -f "$SRC_O" ]; then
  echo "filter_o_export_against_deps: missing $SRC_O" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_O")"
mkdir -p build_asm

all_syms="build_asm/.filter_${STEM}.all"
omit_syms="build_asm/.filter_${STEM}.omit"
keep_syms="build_asm/.filter_${STEM}.keep"
ver_file="${OUT_O}.ver"

: >"$omit_syms"
# PLATFORM: SHARED — missing deps skipped (cold partial trees); present deps always contribute.
for dep_o in "${OMITS[@]+"${OMITS[@]}"}"; do
  if [ -n "$dep_o" ] && [ -f "$dep_o" ]; then
    nm "$dep_o" 2>/dev/null | awk '/ [TDS] / { s=$3; sub(/^_/, "", s); print s }' >>"$omit_syms" || true
  fi
done
sort -u "$omit_syms" -o "$omit_syms"

nm "$SRC_O" 2>/dev/null | awk '/ [TDS] / { s=$3; sub(/^_/, "", s); print s }' | sort -u >"$all_syms"
# keep list always with leading _ for Darwin -exported_symbols_list (Makefile parity)
comm -23 "$all_syms" "$omit_syms" | sed 's/^/_/' >"$keep_syms"

keep_n=$(wc -l <"$keep_syms" | tr -d ' ')
if [ ! -s "$keep_syms" ]; then
  if [ "$REQUIRE_KEEP" = "1" ]; then
    echo "filter_o_export_against_deps: empty keep list for $SRC_O (stem=$STEM)" >&2
    exit 1
  fi
  echo "filter_o_export_against_deps: WARN empty keep for $SRC_O → $OUT_O (all TDS in omit set)" >&2
fi

uname_s="$(uname -s 2>/dev/null || echo unknown)"
echo "filter_o_export_against_deps: $SRC_O → $OUT_O (stem=$STEM keep=$keep_n; host=$uname_s)"

# PLATFORM: MACOS|DARWIN — ld64/lld -exported_symbols_list
# PLATFORM: LINUX — GNU ld --version-script (keep names with leading _)
if [ "$uname_s" = "Darwin" ]; then
  ld -r -exported_symbols_list "$keep_syms" -o "$OUT_O" "$SRC_O"
else
  {
    printf '{ global:\n'
    if [ -s "$keep_syms" ]; then
      sed 's/.*/  &;/' "$keep_syms"
    fi
    printf '  *;\n};\n'
  } >"$ver_file"
  ld -r --version-script="$ver_file" -o "$OUT_O" "$SRC_O"
fi

exit 0
