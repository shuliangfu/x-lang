#!/bin/bash
# abi_snapshot_diff.sh — G-02f / Phase 0：对 prove_x_o 工件做 canonical public snapshot 比对
#
# 目标：
#   - 不比原始内存
#   - 不比平台相关地址
#   - 只比稳定、可解释的 public symbol snapshot
#
# 用法：
#   sh scripts/abi_snapshot_diff.sh <x-file> [seed-c-or-o]

set -eu

cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
usage:
  sh scripts/abi_snapshot_diff.sh <x-file> [seed-c-or-o]

examples:
  sh scripts/abi_snapshot_diff.sh src/asm/simd_loop_thin.x seeds/simd_loop.from_x.c
  sh scripts/abi_snapshot_diff.sh src/asm/simd_enc_thin.x seeds/simd_enc.from_x.c
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage >&2
  exit 2
fi

X_SRC="$1"
SEED_SRC="${2:-}"
TIMEOUT="${SHUX_ABI_SNAPSHOT_TIMEOUT:-8}"

if [ ! -f "$X_SRC" ]; then
  echo "abi_snapshot_diff: missing x source: $X_SRC" >&2
  exit 1
fi

run_timeout() {
  _timeout="$1"
  shift
  perl -e 'alarm shift; exec @ARGV' "$_timeout" "$@"
}

resolve_seed_src() {
  _x_src="$1"
  _stem="$(basename "$_x_src" .x)"
  _seed_dir="seeds"
  _macro=""
  _macro_hits=""
  _hit_count=0

  if [ -f "${_seed_dir}/${_stem}.from_x.c" ]; then
    printf '%s\n' "${_seed_dir}/${_stem}.from_x.c"
    return 0
  fi

  case "$_stem" in
    *_thin)
      _base="${_stem%_thin}"
      if [ -f "${_seed_dir}/${_base}.from_x.c" ]; then
        printf '%s\n' "${_seed_dir}/${_base}.from_x.c"
        return 0
      fi
      ;;
  esac

  _macro="$(rg -o 'SHUX_[A-Z0-9_]+_FROM_X' "$_x_src" | sort -u | head -n 1 || true)"
  if [ -n "$_macro" ]; then
    _macro_hits="$(rg -l "$_macro" "$_seed_dir" -g '*.from_x.c' | sort -u || true)"
    _hit_count="$(printf '%s\n' "$_macro_hits" | awk 'NF { n++ } END { print n + 0 }')"
    if [ "$_hit_count" = "1" ]; then
      printf '%s\n' "$_macro_hits"
      return 0
    fi
  fi

  return 1
}

seed_is_direct_pair() {
  _x_src="$1"
  _seed_src="$2"
  _stem="$(basename "$_x_src" .x)"
  _seed_stem="$(basename "$_seed_src" .from_x.c)"
  if [ "$_seed_stem" = "$_stem" ]; then
    return 0
  fi
  case "$_stem" in
    *_thin)
      if [ "${_stem%_thin}" = "$_seed_stem" ]; then
        return 0
      fi
      ;;
  esac
  return 1
}

if [ -z "$SEED_SRC" ]; then
  SEED_SRC="$(resolve_seed_src "$X_SRC" || true)"
fi

acquire_probe_lock() {
  _stem="$1"
  _lock_root="../tests/probes/prove_x_o"
  _lock_dir="${_lock_root}/${_stem}.lock"
  _lock_timeout="${SHUX_PROVE_LOCK_TIMEOUT:-15}"
  _start_ts="${SECONDS:-0}"

  mkdir -p "$_lock_root"
  while ! mkdir "$_lock_dir" 2>/dev/null; do
    if [ $(( ${SECONDS:-0} - _start_ts )) -ge "$_lock_timeout" ]; then
      echo "abi_snapshot_diff: timed out waiting for probe lock: $_lock_dir" >&2
      exit 1
    fi
    sleep 1
  done
  printf '%s\n' "$$" >"${_lock_dir}/pid"
  trap 'rm -rf "$_lock_dir"' EXIT INT TERM HUP
}

line_count() {
  _file="$1"
  if [ -f "$_file" ]; then
    wc -l <"$_file" | tr -d ' '
  else
    echo 0
  fi
}

json_escape() {
  printf '%s' "$1" | perl -0pe 's/\\/\\\\/g; s/"/\\"/g; s/\n/\\n/g'
}

json_array_from_file() {
  _file="$1"
  if [ ! -f "$_file" ]; then
    printf '[]'
    return 0
  fi
  awk '
    BEGIN { printf "["; first = 1 }
    NF {
      gsub(/\\/,"\\\\",$0)
      gsub(/"/,"\\\"",$0)
      if (!first) printf ", "
      printf "\"%s\"", $0
      first = 0
    }
    END { printf "]" }
  ' "$_file"
}

collect_external_x_authorities() {
  _syms_file="$1"
  _out_file="$2"
  : >"$_out_file"
  if [ ! -f "$_syms_file" ]; then
    return 0
  fi
  while IFS= read -r _sym; do
    [ -n "$_sym" ] || continue
    _cname="${_sym#_}"
    if rg -l -U -P "#\\[no_mangle\\]\\s*\\n[[:space:]]*function[[:space:]]+${_cname}[[:space:]]*\\(" src -g '*.x' >/dev/null 2>&1; then
      printf '%s\n' "$_sym" >>"$_out_file"
    fi
  done <"$_syms_file"
  sort -u -o "$_out_file" "$_out_file"
}

collect_language_limit_residuals() {
  _x_src="$1"
  _syms_file="$2"
  _out_file="$3"
  : >"$_out_file"
  if [ ! -f "$_syms_file" ]; then
    return 0
  fi
  case "$(basename "$_x_src" .x)" in
    diag_thin)
      awk '/^_diag_(v)?reportf(_with_code)?$/' "$_syms_file" >"$_out_file"
      ;;
    runtime_driver_diagnostic_thin)
      awk '/^_driver_diag_report_x_pipeline_code$/' "$_syms_file" >"$_out_file"
      ;;
  esac
  sort -u -o "$_out_file" "$_out_file"
}

STEM="$(basename "$X_SRC" .x)"
acquire_probe_lock "$STEM"
PROBE_DIR="../tests/probes/prove_x_o/${STEM}"
RAW_JSON="${PROBE_DIR}/${STEM}.snapshot_compare.json"
SEED_PUBLIC_TXT="${PROBE_DIR}/${STEM}.seed_public.txt"
MERGED_PUBLIC_TXT="${PROBE_DIR}/${STEM}.merged_public.txt"
MISSING_IN_SEED_TXT="${PROBE_DIR}/${STEM}.missing_in_seed.txt"
MISSING_IN_MERGED_TXT="${PROBE_DIR}/${STEM}.missing_in_merged.txt"
NON_IMPL_RESIDUAL_TXT="${PROBE_DIR}/${STEM}.non_impl_residual.txt"
SEED_SYMS_TXT="${PROBE_DIR}/${STEM}.seed.syms.txt"
MERGED_SYMS_TXT="${PROBE_DIR}/${STEM}.merged.syms.txt"
X_SYMS_TXT="${PROBE_DIR}/${STEM}.syms.txt"
ONLY_SEED_TXT="${PROBE_DIR}/${STEM}.only_seed.txt"
SLICE_MARKER_TXT="${PROBE_DIR}/${STEM}.slice_marker_residual.txt"
EXTERNAL_X_AUTHORITY_TXT="${PROBE_DIR}/${STEM}.external_x_authority.txt"
RAW_NON_IMPL_RESIDUAL_TXT="${PROBE_DIR}/${STEM}.raw_non_impl_residual.txt"
ALLOWED_RESIDUAL_TXT="${PROBE_DIR}/${STEM}.allowed_residual.txt"
LANGUAGE_LIMIT_RESIDUAL_TXT="${PROBE_DIR}/${STEM}.language_limit_residual.txt"
FOREIGN_SEED_PUBLIC_TXT="${PROBE_DIR}/${STEM}.foreign_seed_public.txt"

if [ ! -f "$X_SYMS_TXT" ] || { [ -n "$SEED_SRC" ] && [ ! -f "$SEED_SYMS_TXT" ]; }; then
  if [ -n "$SEED_SRC" ]; then
    run_timeout "$TIMEOUT" sh scripts/prove_x_o.sh "$X_SRC" "$SEED_SRC"
  else
    run_timeout "$TIMEOUT" sh scripts/prove_x_o.sh "$X_SRC"
  fi
fi

if [ ! -f "$X_SYMS_TXT" ]; then
  echo "abi_snapshot_diff: missing prove artifacts: $X_SYMS_TXT" >&2
  exit 1
fi

rm -f "$SEED_PUBLIC_TXT" "$MERGED_PUBLIC_TXT" "$MISSING_IN_SEED_TXT" "$MISSING_IN_MERGED_TXT" "$NON_IMPL_RESIDUAL_TXT" "$RAW_JSON" "$SLICE_MARKER_TXT" "$EXTERNAL_X_AUTHORITY_TXT" "$RAW_NON_IMPL_RESIDUAL_TXT" "$ALLOWED_RESIDUAL_TXT" "$LANGUAGE_LIMIT_RESIDUAL_TXT" "$FOREIGN_SEED_PUBLIC_TXT"

if [ -f "$SEED_SYMS_TXT" ]; then
  comm -12 "$X_SYMS_TXT" "$SEED_SYMS_TXT" >"$SEED_PUBLIC_TXT" || true
  comm -23 "$X_SYMS_TXT" "$SEED_PUBLIC_TXT" >"$MISSING_IN_SEED_TXT" || true
else
  : >"$SEED_PUBLIC_TXT"
  cp "$X_SYMS_TXT" "$MISSING_IN_SEED_TXT"
fi

if [ -f "$MERGED_SYMS_TXT" ]; then
  comm -12 "$X_SYMS_TXT" "$MERGED_SYMS_TXT" >"$MERGED_PUBLIC_TXT" || true
  comm -23 "$X_SYMS_TXT" "$MERGED_PUBLIC_TXT" >"$MISSING_IN_MERGED_TXT" || true
else
  : >"$MERGED_PUBLIC_TXT"
  cp "$X_SYMS_TXT" "$MISSING_IN_MERGED_TXT"
fi

if [ -f "$ONLY_SEED_TXT" ]; then
  if [ -n "$SEED_SRC" ] && ! seed_is_direct_pair "$X_SRC" "$SEED_SRC"; then
    sort -u "$ONLY_SEED_TXT" >"$FOREIGN_SEED_PUBLIC_TXT"
    : >"$RAW_NON_IMPL_RESIDUAL_TXT"
    : >"$SLICE_MARKER_TXT"
    : >"$EXTERNAL_X_AUTHORITY_TXT"
    : >"$LANGUAGE_LIMIT_RESIDUAL_TXT"
    : >"$ALLOWED_RESIDUAL_TXT"
    : >"$NON_IMPL_RESIDUAL_TXT"
  else
    : >"$FOREIGN_SEED_PUBLIC_TXT"
    awk '!/_impl$/ { print }' "$ONLY_SEED_TXT" >"$RAW_NON_IMPL_RESIDUAL_TXT"
    awk '/^_labi_.*_slice_marker$/ { print }' "$RAW_NON_IMPL_RESIDUAL_TXT" >"$SLICE_MARKER_TXT"
    collect_external_x_authorities "$RAW_NON_IMPL_RESIDUAL_TXT" "$EXTERNAL_X_AUTHORITY_TXT"
    collect_language_limit_residuals "$X_SRC" "$RAW_NON_IMPL_RESIDUAL_TXT" "$LANGUAGE_LIMIT_RESIDUAL_TXT"
    cat "$SLICE_MARKER_TXT" "$EXTERNAL_X_AUTHORITY_TXT" "$LANGUAGE_LIMIT_RESIDUAL_TXT" | awk 'NF { print }' | sort -u >"$ALLOWED_RESIDUAL_TXT"
    if [ -s "$ALLOWED_RESIDUAL_TXT" ]; then
      awk '
        FNR == NR {
          ignored[$0] = 1
          next
        }
        !ignored[$0] {
          print
        }
      ' "$ALLOWED_RESIDUAL_TXT" "$RAW_NON_IMPL_RESIDUAL_TXT" | sort -u >"$NON_IMPL_RESIDUAL_TXT"
    else
      sort -u "$RAW_NON_IMPL_RESIDUAL_TXT" >"$NON_IMPL_RESIDUAL_TXT"
    fi
  fi
else
  : >"$RAW_NON_IMPL_RESIDUAL_TXT"
  : >"$SLICE_MARKER_TXT"
  : >"$EXTERNAL_X_AUTHORITY_TXT"
  : >"$LANGUAGE_LIMIT_RESIDUAL_TXT"
  : >"$FOREIGN_SEED_PUBLIC_TXT"
  : >"$ALLOWED_RESIDUAL_TXT"
  : >"$NON_IMPL_RESIDUAL_TXT"
fi

STATUS="ok"
if [ "$(line_count "$MISSING_IN_MERGED_TXT")" != "0" ] || [ "$(line_count "$NON_IMPL_RESIDUAL_TXT")" != "0" ]; then
  STATUS="mismatch"
fi

cat >"$RAW_JSON" <<EOF
{
  "schema_version": 1,
  "tu": "$(json_escape "$STEM")",
  "status": "$(json_escape "$STATUS")",
  "counts": {
    "x_public": $(line_count "$X_SYMS_TXT"),
    "seed_public": $(line_count "$SEED_PUBLIC_TXT"),
    "merged_public": $(line_count "$MERGED_PUBLIC_TXT"),
    "missing_in_seed": $(line_count "$MISSING_IN_SEED_TXT"),
    "missing_in_merged": $(line_count "$MISSING_IN_MERGED_TXT"),
    "non_impl_residual": $(line_count "$NON_IMPL_RESIDUAL_TXT")
  },
  "files": {
    "x_public": "$(json_escape "$X_SYMS_TXT")",
    "seed_public": "$(json_escape "$SEED_PUBLIC_TXT")",
    "merged_public": "$(json_escape "$MERGED_PUBLIC_TXT")",
    "missing_in_seed": "$(json_escape "$MISSING_IN_SEED_TXT")",
    "missing_in_merged": "$(json_escape "$MISSING_IN_MERGED_TXT")",
    "non_impl_residual": "$(json_escape "$NON_IMPL_RESIDUAL_TXT")",
    "slice_marker_residual": "$(json_escape "$SLICE_MARKER_TXT")",
    "external_x_authority": "$(json_escape "$EXTERNAL_X_AUTHORITY_TXT")",
    "language_limit_residual": "$(json_escape "$LANGUAGE_LIMIT_RESIDUAL_TXT")",
    "foreign_seed_public": "$(json_escape "$FOREIGN_SEED_PUBLIC_TXT")"
  },
  "snapshot": {
    "x_public": $(json_array_from_file "$X_SYMS_TXT"),
    "seed_public": $(json_array_from_file "$SEED_PUBLIC_TXT"),
    "merged_public": $(json_array_from_file "$MERGED_PUBLIC_TXT"),
    "missing_in_seed": $(json_array_from_file "$MISSING_IN_SEED_TXT"),
    "missing_in_merged": $(json_array_from_file "$MISSING_IN_MERGED_TXT"),
    "non_impl_residual": $(json_array_from_file "$NON_IMPL_RESIDUAL_TXT"),
    "slice_marker_residual": $(json_array_from_file "$SLICE_MARKER_TXT"),
    "external_x_authority": $(json_array_from_file "$EXTERNAL_X_AUTHORITY_TXT"),
    "language_limit_residual": $(json_array_from_file "$LANGUAGE_LIMIT_RESIDUAL_TXT"),
    "foreign_seed_public": $(json_array_from_file "$FOREIGN_SEED_PUBLIC_TXT")
  }
}
EOF

echo "abi_snapshot_diff: ${STATUS}"
echo "  json:              $RAW_JSON"
echo "  seed_public:       $SEED_PUBLIC_TXT"
echo "  merged_public:     $MERGED_PUBLIC_TXT"
echo "  missing_in_seed:   $MISSING_IN_SEED_TXT"
echo "  missing_in_merged: $MISSING_IN_MERGED_TXT"
echo "  non_impl_residual: $NON_IMPL_RESIDUAL_TXT"
echo "  slice_marker:      $SLICE_MARKER_TXT"
echo "  external_x_auth:   $EXTERNAL_X_AUTHORITY_TXT"

if [ "$STATUS" != "ok" ]; then
  exit 1
fi

exit 0
