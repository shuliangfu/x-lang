#!/usr/bin/env bash
# PERF-009：网络零拷贝 CPU/byte bench — perf cycles/MiB 与 baseline / ref 比较
#
# 用法：
#   ./tests/run-perf-net-zc.sh
#   SHU=./compiler/shu-c ./tests/run-perf-net-zc.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/perf-net-zc.sh
. tests/lib/perf-net-zc.sh
# shellcheck source=tests/lib/io-uring-probe.sh
source tests/lib/io-uring-probe.sh

BASELINE="${SHU_NET_ZC_BASELINE:-tests/baseline/net-zc-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${SHU_NET_ZC_FAIL:-0}"
REQUIRE_PERF="${SHU_NET_ZC_REQUIRE_PERF:-0}"

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38500 + RANDOM % 2000))
  fi
}

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
  SHU_BIN="${SHU_BIN:-./compiler/shu-c}"
else
  case "$SHU_BIN" in /*) ;; *) SHU_BIN="$(pwd)/$SHU_BIN" ;; esac
fi

echo "=== PERF-009: net zero-copy cycles/byte bench (baseline=${BASELINE}) ==="

if ! native_shu "$SHU_BIN"; then
  echo "net-zc perf SKIP: ${SHU_BIN} not native"
  exit 0
fi

if ! perf_nz_probe_ok; then
  if [ "$REQUIRE_PERF" = "1" ]; then
    echo "net-zc perf FAIL: perf unavailable (SHU_NET_ZC_REQUIRE_PERF=1)" >&2
    exit 1
  fi
  echo "net-zc perf SKIP: need Linux + perf stat cycles"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/net/net.o ../std/io/io.o ../std/thread/thread.o -q 2>/dev/null \
  || make -C compiler ../std/net/net.o ../std/io/io.o ../std/thread/thread.o

declare -A NZ_CYCLES NZ_CPM
HARD_FAIL=0
CASE_OK=0
CASE_TOTAL=0

# 第一遍：编译 + perf stat 收集 cycles/MiB。
while IFS=$'\t' read -r case_id bench_src server_c bytes_xfer _cap_mib _ref_case needs_uring _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))

  if [ "$needs_uring" = "1" ] && ! io_uring_available; then
    echo "net-zc SKIP case ${case_id} (io_uring N/A)"
    continue
  fi

  exe="${OUT_DIR}/shu_net_zc_${case_id}"
  rm -f "$exe"
  echo "── measure ${case_id} ──"
  if ! "$SHU_BIN" -L . "$bench_src" -o "$exe"; then
    echo "net-zc FAIL: compile $bench_src" >&2
    HARD_FAIL=1
    continue
  fi

  port=$(pick_free_port)
  if ! perf_nz_run_echo_cycles "$exe" "$server_c" "$port"; then
    echo "net-zc FAIL: perf stat $case_id" >&2
    HARD_FAIL=1
    continue
  fi

  cpm=$(perf_nz_cycles_per_mib "$perf_nz_cycles" "$bytes_xfer")
  NZ_CYCLES[$case_id]="$perf_nz_cycles"
  NZ_CPM[$case_id]="$cpm"
  echo "net-zc measure: $case_id cycles=${perf_nz_cycles} cycles_per_mib=${cpm}"
done < "$BASELINE"

# 第二遍：cap + zc_lt_ref 校验并 emit。
while IFS=$'\t' read -r case_id _su _srv bytes_xfer cap_mib ref_case needs_uring _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  [ -n "${NZ_CPM[$case_id]:-}" ] || continue

  cpm="${NZ_CPM[$case_id]}"
  ok=$(perf_nz_within_cap "$case_id" "$cpm" "$BASELINE")

  ref_cpm="-"
  if [ -n "$ref_case" ] && [ "$ref_case" != "-" ] && [ -n "${NZ_CPM[$ref_case]:-}" ]; then
    ref_cpm="${NZ_CPM[$ref_case]}"
    if awk -v z="$cpm" -v r="$ref_cpm" 'BEGIN { exit (z + 0 < r + 0) ? 0 : 1 }'; then
      :
    else
      ok=0
      echo "net-zc FAIL: $case_id cycles_per_mib=${cpm} >= ref ${ref_case}=${ref_cpm}" >&2
    fi
  fi

  perf_nz_report_emit "$case_id" "${NZ_CYCLES[$case_id]}" "$bytes_xfer" "$cpm" \
    "$cap_mib" "${ref_case:--}" "$ref_cpm" "$ok"

  if [ "$ok" = "1" ]; then
    echo "net-zc OK: $case_id cycles_per_mib=${cpm} ref=${ref_cpm}"
    CASE_OK=$((CASE_OK + 1))
  elif [ "$FAIL_FLAG" = "1" ]; then
    HARD_FAIL=1
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  echo "net-zc FAIL: no cases in $BASELINE" >&2
  exit 1
fi

if [ "$CASE_OK" -eq 0 ] && [ "$FAIL_FLAG" = "1" ]; then
  echo "net-zc perf FAIL (no case passed)" >&2
  exit 1
fi

if [ "$HARD_FAIL" -ne 0 ]; then
  echo "net-zc perf FAIL" >&2
  exit 1
fi

echo "net-zc perf OK (cases=${CASE_OK}/${CASE_TOTAL})"
