#!/usr/bin/env bash
# STD-138：Windows/macOS 深度边界向量门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-xplat-deep-boundary-v1.md"
MANIFEST="tests/baseline/std-xplat-deep-boundary.tsv"
LIB="tests/lib/std-xplat-deep-boundary.sh"
SMOKE="tests/xplat/deep_boundary.sx"
MIN_ROWS=8
MIN_SMOKE_CASES=6
. "$LIB"
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
for f in "$DOC" "$MANIFEST" "$LIB" "$SMOKE"; do
  [ -f "$f" ] || { echo "xplat-deep-boundary gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-138 "$DOC" || { echo "xplat-deep-boundary gate FAIL: doc" >&2; exit 1; }
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_rows) MIN_ROWS="$c2" ;; min_smoke_cases) MIN_SMOKE_CASES="$c2" ;; esac
done < "$MANIFEST"
path_miss="$(xplat_deep_verify_paths "$MANIFEST" "$MIN_ROWS" || true)"
[ "${path_miss:-0}" -eq 0 ] || exit 1
echo "xplat-deep-boundary registry OK"
n_cases="$(grep -cE '// case [0-9]+' "$SMOKE" 2>/dev/null || echo 0)"
if [ "$n_cases" -lt "$MIN_SMOKE_CASES" ]; then
  echo "xplat-deep-boundary gate FAIL: deep_boundary cases=${n_cases} < ${MIN_SMOKE_CASES}" >&2
  exit 1
fi
SMOKE_OK=0
SKIP=0
SHUX_BIN=""
for cand in ./compiler/shux-c ./compiler/shux; do
  [ -x "$cand" ] && SHUX_BIN="$cand" && break
done
if [ -n "$SHUX_BIN" ]; then
  FAIL=0
  while IFS=$'\t' read -r case_id kind path linux pol_mac pol_win _notes; do
    [ -z "${case_id:-}" ] && continue
    case "$case_id" in \#*|min_*) continue ;; esac
    [ "$kind" = "smoke" ] || continue
    pol="$(xplat_deep_platform_policy "$linux" "$pol_mac" "$pol_win")"
    case "$pol" in
      skip) echo "xplat-deep SKIP $case_id"; continue ;;
    esac
    if ! "$SHUX_BIN" check -L . "$path" >/dev/null 2>&1; then
      echo "xplat-deep-boundary gate FAIL: typeck $path" >&2
      FAIL=1
      break
    fi
    if ! xplat_deep_run_smoke "$SHUX_BIN" "$path"; then
      if [ "$pol" = "optional" ]; then
        echo "xplat-deep WARN $case_id (optional)" >&2
      else
        echo "xplat-deep-boundary gate FAIL: run $path" >&2
        FAIL=1
        break
      fi
    else
      echo "xplat-deep OK $case_id"
    fi
  done < "$MANIFEST"
  [ "$FAIL" -eq 0 ] || exit 1
  SMOKE_OK=1
else
  SKIP=1
fi
xplat_deep_emit_report ok "$SMOKE_OK" "$SKIP" "$(ci_host_summary)"
echo "xplat-deep-boundary gate OK"
