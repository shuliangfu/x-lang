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
#     --src SRC.o --out OUT.o --stem NAME [--omit DEP.o]... [--omit-sym NAME]... [--require-keep]
#   # positional:
#   sh scripts/filter_o_export_against_deps.sh SRC OUT STEM [DEP...]
#   # optional env:
#   FILTER_REQUIRE_KEEP=1  — fail if keep list empty (pipeline)
#
# Exit: 0 success; 1 missing SRC / ld failure / empty keep when required
#
# PLATFORM: SHARED — Darwin product link is primary consumer of filtered.o;
# Linux may build for hygiene (product link often uses bare .o).
# --omit-sym: Stage2 X dogfood (verify-selfhost-stage2) named-symbol omit set;
# G.7 有则补全 on this filter (do not re-copy Darwin/Linux ld -r bodies).

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
OMIT_SYMS=()

usage() {
  echo "usage: filter_o_export_against_deps.sh --src SRC --out OUT --stem STEM [--omit DEP]... [--omit-sym NAME]... [--require-keep]" >&2
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
      --omit-sym)
        OMIT_SYMS+=("${2:-}")
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
# Named-symbol omit (Stage2 X dogfood): strip leading _ for nm parity.
for sym in "${OMIT_SYMS[@]+"${OMIT_SYMS[@]}"}"; do
  [ -n "$sym" ] || continue
  case "$sym" in
    _*) printf '%s\n' "${sym#_}" >>"$omit_syms" ;;
    *) printf '%s\n' "$sym" >>"$omit_syms" ;;
  esac
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
uname_m="$(uname -m 2>/dev/null || echo unknown)"
echo "filter_o_export_against_deps: $SRC_O → $OUT_O (stem=$STEM keep=$keep_n; host=$uname_s)"

# PLATFORM: MACOS|DARWIN — Xcode ld requires -arch on -r; F7 prefer hybrid may
# leave SRC as libtool -static **ar archive** (two LC_SEGMENT MH_OBJECT cannot
# ld -r). Filter MH_OBJECT with -arch; for ar, per-member filter (keep original
# member when that member rejects ld -r) then re-ar. Never exit 0 without OUT
# (Apple ld has returned 0 after "Missing -arch" with no file).
# PLATFORM: LINUX — GNU ld --version-script (keep names with leading _).
darwin_ld_arch_args() {
  case "$uname_m" in
    arm64|aarch64) printf '%s' "-arch arm64" ;;
    x86_64|amd64) printf '%s' "-arch x86_64" ;;
    *) printf '%s' "" ;;
  esac
}

# $1=src $2=out $3=exported_symbols_list (leading _).
darwin_filter_mh_object() {
  local src="$1" out="$2" exp_list="$3" arch_args
  arch_args="$(darwin_ld_arch_args)"
  # shellcheck disable=SC2086
  if ! ld -r $arch_args -exported_symbols_list "$exp_list" -o "$out" "$src" 2>/dev/null; then
    return 1
  fi
  [ -s "$out" ] || return 1
  return 0
}

darwin_filter_ar_archive() {
  local src="$1" out="$2"
  local work mem mem_exp mem_keep policy_keep bare ok any
  local -a members
  work="$(mktemp -d "${TMPDIR:-/tmp}/filter_ar_${STEM}.XXXXXX")" || return 1
  # Absolute paths: ar x + member ld run under $work.
  case "$src" in
    /*) ;;
    *) src="$(pwd)/$src" ;;
  esac
  case "$out" in
    /*) ;;
    *) out="$(pwd)/$out" ;;
  esac
  policy_keep="$keep_syms"
  case "$policy_keep" in
    /*) ;;
    *) policy_keep="$(pwd)/$policy_keep" ;;
  esac
  (
    cd "$work" || exit 1
    ar x "$src" || exit 1
    any=0
    members=()
    for mem in *; do
      [ -f "$mem" ] || continue
      case "$mem" in
        __.SYMDEF|__.SYMDEF\ SORTED|*.keep|*.exp) continue ;;
      esac
      # Per-member keep = intersection(policy keep, member TDS).
      mem_keep="${mem}.keep"
      : >"$mem_keep"
      while IFS= read -r sym; do
        [ -n "$sym" ] || continue
        bare="$sym"
        case "$sym" in
          _*) bare="${sym#_}" ;;
        esac
        if grep -qx "_${bare}" "$policy_keep" 2>/dev/null \
          || grep -qx "$sym" "$policy_keep" 2>/dev/null; then
          printf '%s\n' "_${bare}" >>"$mem_keep"
        fi
      done < <(nm "$mem" 2>/dev/null | awk '/ [TDS] / { print $3 }')
      mem_exp="${mem}.exp"
      if [ -s "$mem_keep" ] && darwin_filter_mh_object "$mem" "$mem_exp" "$mem_keep"; then
        mv "$mem_exp" "$mem"
      else
        # Multi LC_SEGMENT thin / empty keep: keep member as-is (final ld
        # accepts libtool ar; omit is best-effort on filterable members).
        rm -f "$mem_exp"
      fi
      rm -f "$mem_keep"
      members+=("$mem")
      any=1
    done
    [ "$any" = "1" ] || exit 1
    rm -f "$out"
    ar rc "$out" "${members[@]}" || exit 1
    if command -v ranlib >/dev/null 2>&1; then
      ranlib "$out" 2>/dev/null || true
    fi
    [ -s "$out" ] || exit 1
  )
  ok=$?
  rm -rf "$work"
  return "$ok"
}
rm -f "$OUT_O"
if [ "$uname_s" = "Darwin" ]; then
  if file "$SRC_O" 2>/dev/null | grep -q 'ar archive'; then
    if ! darwin_filter_ar_archive "$SRC_O" "$OUT_O"; then
      echo "filter_o_export_against_deps: Darwin ar filter failed for $SRC_O" >&2
      exit 1
    fi
  else
    if ! darwin_filter_mh_object "$SRC_O" "$OUT_O" "$keep_syms"; then
      echo "filter_o_export_against_deps: Darwin ld -r filter failed for $SRC_O" >&2
      exit 1
    fi
  fi
else
  {
    printf '{ global:\n'
    if [ -s "$keep_syms" ]; then
      sed 's/.*/  &;/' "$keep_syms"
    fi
    printf '  *;\n};\n'
  } >"$ver_file"
  if ! ld -r --version-script="$ver_file" -o "$OUT_O" "$SRC_O"; then
    echo "filter_o_export_against_deps: GNU ld -r filter failed for $SRC_O" >&2
    exit 1
  fi
  if [ ! -s "$OUT_O" ]; then
    echo "filter_o_export_against_deps: missing OUT after ld -r ($OUT_O)" >&2
    exit 1
  fi
fi

exit 0
