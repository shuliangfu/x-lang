#!/usr/bin/env bash
# PERF-001：Zig 对标基线门禁（版本/参数/机器可追溯 + 可选录制/校验）
#
# 用法：
#   ./tests/run-zig-baseline-gate.sh              # manifest + 版本检查（默认）
#   ./tests/run-zig-baseline-gate.sh --record     # 录制 median 写入 zig-perf.tsv（须 pin 版 zig）
#   SHUX_ZIG_BASELINE_STRICT=1 ...                 # zig 版本须匹配 0.13.x
#   SHUX_ZIG_BASELINE_VERIFY=1 ...                 # 实测须在 recorded×(1+tolerance%) 内
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"

DO_RECORD=0
for arg in "$@"; do
  case "$arg" in
    --record) DO_RECORD=1 ;;
    -h|--help)
      echo "Usage: $0 [--record]"
      exit 0
      ;;
    *)
      echo "run-zig-baseline-gate: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

echo "=== PERF-001: Zig baseline manifest ==="
zig_baseline_validate_tsv "$ZIG_BASELINE_TSV"
echo "zig-perf.tsv OK"

echo "=== PERF-001: host trace ==="
zig_baseline_host_summary

echo "=== PERF-001: zig version pin ==="
zig_baseline_check_version

if [ "$DO_RECORD" -eq 0 ] && [ "${SHUX_ZIG_BASELINE_VERIFY:-0}" != "1" ]; then
  echo "zig baseline gate OK (manifest)"
  exit 0
fi

if ! command -v zig >/dev/null 2>&1; then
  echo "zig baseline gate SKIP bench (no zig)" >&2
  exit 0
fi

RUNS="$(zig_baseline_meta_get runs)"
[ -n "$RUNS" ] || RUNS=3
BENCH_ROOT="tests/bench"
VERIFY_FAILS=0
RECORD_TMP="$(mktemp)"

# 遍历 case 行：type case_id category src median tolerance notes
while IFS=$'\t' read -r typ case_id category src recorded tol notes; do
  [ "$typ" = "case" ] || continue
  [ -n "$src" ] || continue
  local_src="${BENCH_ROOT}/${src}"
  [ -f "$local_src" ] || continue

  tag="${case_id}"
  out="/tmp/zig_baseline_${tag}"
  rm -f "$out"

  if ! zig_build_exe_o2 "$local_src" "$out"; then
    echo "zig baseline WARN: compile fail $src (zig API may need pin 0.13)" >&2
    continue
  fi

  med="$(zig_baseline_median_real "$out" "$RUNS")"
  echo "Zig ${case_id} median real: ${med}s (recorded=${recorded:-—} tol=${tol:-10}%)"

  if [ "$DO_RECORD" -eq 1 ]; then
    printf 'case\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$case_id" "$category" "$src" "$med" "${tol:-15}" "${notes:-}" >> "$RECORD_TMP"
    continue
  fi

  if [ "${SHUX_ZIG_BASELINE_VERIFY:-0}" = "1" ] && [ -n "$recorded" ] && [ "$recorded" != "nan" ]; then
    pct="${tol:-15}"
    if awk -v m="$med" -v r="$recorded" -v p="$pct" 'BEGIN {
      hi = r * (1.0 + p / 100.0) + 0.000001
      exit (m <= hi) ? 0 : 1
    }'; then
      echo "zig verify OK: $case_id $med <= $recorded (+${pct}%)"
    else
      echo "zig verify FAIL: $case_id $med > $recorded (+${pct}%)" >&2
      VERIFY_FAILS=$((VERIFY_FAILS + 1))
    fi
  fi
done < "$ZIG_BASELINE_TSV"

if [ "$DO_RECORD" -eq 1 ]; then
  if [ ! -s "$RECORD_TMP" ]; then
    echo "zig baseline RECORD: no cases compiled (check zig ${pin:-0.13.0})" >&2
    rm -f "$RECORD_TMP"
    exit 1
  fi
  # 合并：保留 meta + 更新 case median 列
  awk -F'\t' -v rec="$RECORD_TMP" '
    BEGIN {
      while ((getline line < rec) > 0) {
        split(line, a, "\t")
        if (a[1] == "case") med[a[2]] = a[5]
      }
      close(rec)
    }
    $1 == "meta" { print; next }
    $1 == "case" {
      if ($2 in med) $5 = med[$2]
      print
      next
    }
    { print }
  ' OFS='\t' "$ZIG_BASELINE_TSV" > "${ZIG_BASELINE_TSV}.new"
  mv "${ZIG_BASELINE_TSV}.new" "$ZIG_BASELINE_TSV"
  rm -f "$RECORD_TMP"
  echo "zig baseline RECORD OK → $ZIG_BASELINE_TSV"
  exit 0
fi

if [ "$VERIFY_FAILS" -gt 0 ]; then
  echo "zig baseline gate FAIL: ${VERIFY_FAILS} case(s) over tolerance" >&2
  exit 1
fi

echo "zig baseline gate OK"
