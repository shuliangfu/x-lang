#!/usr/bin/env bash
# I/O perf baseline (mmap / read_batch_fd / write vs C -O2 / Zig -O2).
#
# Honesty: soft XLANG_PERF_FAIL_ON_IO_*: -0 previously left over-cap /
# Zig-loss unchecked (silent OK = portable false-green). Soft auto-make
# before resolve retired. Prefer product xlang_asm. Over-cap / Zig-loss =
# obs (FAIL_ON=1 still hard). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-io.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_IO_ZIG=1 — Xlang ≤ Zig -O2 hard
#   XLANG_PERF_FAIL_ON_IO_REGRESSION=1 — Xlang ≤ io-perf.tsv hard
#   XLANG_PERF_UPDATE_BASELINE=1 — refresh io-perf.tsv
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/zig-baseline.sh
. tests/lib/zig-baseline.sh
# Honesty: do NOT auto-make before resolve.

PREFIX="xlang: [XLANG_PERF_IO]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "io perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  # Explicit XLANG must be native — refuse soft fallthrough.
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

XLANG_RESOLVED="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_RESOLVED"
export XLANG_LINK_XLANG="$XLANG_RESOLVED"
# PLATFORM: DARWIN — hosted io benches need xlang-c (asm link __TEXT not r-x).
# PLATFORM: LINUX — product asm is the compile authority.
PERF_COMPILE_XLANG="$XLANG_RESOLVED"
case "$(uname -s 2>/dev/null)" in
  Darwin)
    if [ -x ./compiler/xlang-c ] && dod_native_exe "$(pwd)/compiler/xlang-c"; then
      PERF_COMPILE_XLANG="$(pwd)/compiler/xlang-c"
    fi
    ;;
esac
echo "io perf: resolve=$XLANG_RESOLVED compile=$PERF_COMPILE_XLANG"

BENCH_MMAP_FILE="bench/.io_mmap_bench_tmp"
BENCH_WRITE_FILE="bench/.io_write_bench_tmp"
BENCH_MB="${XLANG_IO_BENCH_MB:-16}"
SENDFILE_PORT_DEFAULT=38459
BENCH_BYTES=$((BENCH_MB * 1024 * 1024))
RUNS=3
DO_BENCH=0
PERF_IO_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${XLANG_PERF_FAIL_ON_IO_ZIG:-0}" = "1" ] && PERF_FAIL_IO=1 || PERF_FAIL_IO=0
[ "${XLANG_PERF_FAIL_ON_IO_REGRESSION:-0}" = "1" ] && PERF_FAIL_REGRESS=1 || PERF_FAIL_REGRESS=0
IO_CASE_MEDS=""

# 从 time 输出提取 real 秒数
extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

median_real() {
  local exe="$1"
  local i vals med
  vals=""
  for i in $(seq 1 "$RUNS"); do
    vals=$( ( time "$exe" >/dev/null ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

# 每轮 sendfile bench 使用新端口，避免 TIME_WAIT 干扰。
pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38000 + RANDOM % 2000))
  fi
}

SENDFILE_SINK_BIN="/tmp/bench_io_sendfile_sink"

# 预编译 sendfile sink（计时循环外一次，避免 cc 冷启动污染 median）。
ensure_sendfile_sink() {
  cc -O2 bench/i07_zero_copy_sendfile_sink.c -o "$SENDFILE_SINK_BIN" 2>/dev/null || return 1
  [ -x "$SENDFILE_SINK_BIN" ]
}

# 仅跑 client→sink 传输（sink 须已编好；计 sleep + client + wait sink）。
time_sendfile_client() {
  local client="$1"
  local port="$2"
  "$SENDFILE_SINK_BIN" "$port" &
  local spid=$!
  sleep 0.15
  if ! "$client" "$port"; then
    kill "$spid" 2>/dev/null || true
    wait "$spid" 2>/dev/null || true
    return 1
  fi
  wait "$spid"
}

time_sendfile_pair() {
  ensure_sendfile_sink || return 1
  time_sendfile_client "$1" "$2"
}

compile_shu_sendfile() {
  local bytes="$1"
  local out="$2"
  rm -f "$out"
  sed -e "s/16777216/${bytes}/" \
      bench/i07_zero_copy_sendfile.x >"/tmp/bench_io_sendfile.x"
  if ! $PERF_COMPILE_XLANG -L . "/tmp/bench_io_sendfile.x" -o "$out" >/tmp/bench_io_compile.log 2>&1; then
    cat /tmp/bench_io_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

median_shu_sendfile() {
  local i vals med port out="/tmp/bench_io_shu_sendfile"
  vals=""
  ensure_sendfile_sink || { echo "nan"; return 1; }
  if ! compile_shu_sendfile "$BENCH_BYTES" "$out"; then
    echo "nan"
    return 1
  fi
  # 预热 dyld/页缓存（同一路径二进制，避免每轮 recompile）。
  port=$(pick_free_port)
  time_sendfile_client "$out" "$port" >/dev/null 2>&1 || true
  time_sendfile_client "$out" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    port=$(pick_free_port)
    vals=$( ( time time_sendfile_client "$out" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

median_c_sendfile() {
  local i vals med port exe="/tmp/bench_io_c_sendfile"
  vals=""
  cc -O2 bench/i07_zero_copy_sendfile.c -o "$exe" 2>/dev/null || { echo "nan"; return 1; }
  ensure_sendfile_sink || { echo "nan"; return 1; }
  port=$(pick_free_port)
  time_sendfile_client "$exe" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    port=$(pick_free_port)
    vals=$( ( time time_sendfile_client "$exe" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

median_zig_sendfile() {
  local i vals med port exe="/tmp/bench_io_zig_sendfile"
  vals=""
  zig_build_exe_o2 bench/i07_zero_copy_sendfile.zig "$exe" || { echo "nan"; return 0; }
  ensure_sendfile_sink || { echo "nan"; return 0; }
  port=$(pick_free_port)
  time_sendfile_client "$exe" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    port=$(pick_free_port)
    vals=$( ( time time_sendfile_client "$exe" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

bench_io_sendfile_case() {
  local name="zero_copy_sendfile"
  local XLANG_ASM_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"

  if ! fs_sendfile_supported; then
    echo "=== bench/${name} — skip (sendfile unsupported on $(uname -s)) ==="
    printf '\n'
    return 0
  fi

  ensure_io_mmap_bench_file
  echo "=== bench/${name} (${BENCH_MB}MiB file→socket sendfile @ 127.0.0.1:<dynamic>) ==="

  XLANG_ASM_MED=$(median_shu_sendfile)
  echo "Xlang (default asm) ${name} median real: ${XLANG_ASM_MED}s"

  if command -v cc >/dev/null 2>&1; then
    C_MED=$(median_c_sendfile)
    echo "C -O2 ${name} median real: ${C_MED}s"
  fi

  if command -v zig >/dev/null 2>&1 && [ -f bench/i07_zero_copy_sendfile.zig ]; then
    ZIG_MED=$(median_zig_sendfile)
    echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (default asm) | %s |\n' "$XLANG_ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  check_io_zig_regress "$name" "$XLANG_ASM_MED" "$ZIG_MED"
  check_io_baseline_regress "$name" "$XLANG_ASM_MED" "nan"

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${XLANG_ASM_MED};"
}

compile_shu_splice() {
  local bytes="$1"
  local out="$2"
  rm -f "$out"
  sed -e "s/16777216/${bytes}/" \
      bench/i07_zero_copy_splice.x >"/tmp/bench_io_splice.x"
  if ! $PERF_COMPILE_XLANG -L . "/tmp/bench_io_splice.x" -o "$out" >/tmp/bench_io_splice_compile.log 2>&1; then
    cat /tmp/bench_io_splice_compile.log >&2
    return 1
  fi
  [ -x "$out" ]
}

median_shu_splice() {
  local i vals med port out="/tmp/bench_io_shu_splice"
  vals=""
  ensure_sendfile_sink || { echo "nan"; return 1; }
  if ! compile_shu_splice "$BENCH_BYTES" "$out"; then
    echo "nan"
    return 1
  fi
  port=$(pick_free_port)
  time_sendfile_client "$out" "$port" >/dev/null 2>&1 || true
  time_sendfile_client "$out" "$port" >/dev/null 2>&1 || true
  for i in $(seq 1 "$RUNS"); do
    port=$(pick_free_port)
    vals=$( ( time time_sendfile_client "$out" "$port" ) 2>&1 | extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

bench_io_splice_case() {
  local name="zero_copy_splice"
  local XLANG_ASM_MED="nan"

  if ! fs_splice_supported; then
    echo "=== bench/${name} — skip (pipe splice unsupported on $(uname -s)) ==="
    printf '\n'
    return 0
  fi

  ensure_io_mmap_bench_file
  echo "=== bench/${name} (${BENCH_MB}MiB file→socket fs_pipe_splice @ 127.0.0.1:<dynamic>) ==="

  XLANG_ASM_MED=$(median_shu_splice)
  echo "Xlang (default asm) ${name} median real: ${XLANG_ASM_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (default asm) | %s |\n' "$XLANG_ASM_MED"
  printf '\n'

  check_io_baseline_regress "$name" "$XLANG_ASM_MED" "nan"

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${XLANG_ASM_MED};"
}

fs_splice_supported() {
  [ "$(uname -s)" = "Linux" ]
}

fs_sendfile_supported() {
  case "$(uname -s)" in
    Linux|Darwin) return 0 ;;
    *) return 1 ;;
  esac
}

# 从 baseline 读取某 case 的上限秒数
io_baseline_cap() {
  local name="$1"
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' "${XLANG_PERF_IO_BASELINE:-tests/baseline/io-perf.tsv}"
}

# Zig check: always compare when both medians exist. Loss = obs when
# PERF_FAIL_IO=0; FAIL=1 still hard.
check_io_zig_regress() {
  local name="$1"
  local xlang_med="$2"
  local zig_med="$3"
  if [ "$xlang_med" = "nan" ] || [ "$zig_med" = "nan" ] || [ -z "$zig_med" ]; then
    return 0
  fi
  if awk -v xlang="$xlang_med" -v zig="$zig_med" 'BEGIN { exit (xlang <= zig + 0.000001) ? 0 : 1 }'; then
    echo "io perf zig OK: ${name} Xlang asm ${xlang_med}s <= Zig ${zig_med}s"
  else
    echo "io perf OBS: ${name} Xlang asm ${xlang_med}s > Zig ${zig_med}s" >&2
    OBS=$((OBS + 1))
    PERF_IO_FAILS=$((PERF_IO_FAILS + 1))
    if [ "$PERF_FAIL_IO" -eq 1 ]; then
      : # hard exit deferred to end summary
    fi
  fi
}

# Cap check: always compare when measured. Over-cap = obs when
# PERF_FAIL_REGRESS=0; FAIL=1 still hard. Refuse soft FAIL_ON:-0 silent OK.
check_io_baseline_regress() {
  local name="$1"
  local xlang_asm_med="$2"
  local xlang_c_med="$3"
  local med_gate cap
  med_gate="$xlang_asm_med"
  if [ "$med_gate" = "nan" ] && [ "$xlang_c_med" != "nan" ]; then
    med_gate="$xlang_c_med"
  fi
  if [ "$med_gate" = "nan" ]; then
    return 0
  fi
  cap=$(io_baseline_cap "$name")
  [ -z "$cap" ] && return 0
  # CI VM jitter: 40% slack (same as compile-dogfood).
  if [ "$(echo "${CI:-}" | tr '[:upper:]' '[:lower:]')" = "true" ] || [ "${CI:-}" = "1" ]; then
    cap=$(awk -v c="$cap" 'BEGIN { printf "%.6f", c * 1.4 }')
  fi
  # Docker bind-mount write amplification slack.
  if [ -f /.dockerenv ] || [ -n "${XLANG_CI_DOCKER:-}" ]; then
    cap=$(awk -v c="$cap" 'BEGIN { printf "%.6f", c * 3.5 }')
  fi
  if awk -v xlang="$med_gate" -v cap="$cap" 'BEGIN { exit (xlang <= cap + 0.000001) ? 0 : 1 }'; then
    echo "io perf baseline OK: ${name} ${med_gate}s <= cap ${cap}s"
  else
    echo "io perf OBS: ${name} ${med_gate}s > cap ${cap}s" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL_REGRESS" -eq 1 ]; then
      die "${name} ${med_gate}s > cap ${cap}s (XLANG_PERF_FAIL_ON_IO_REGRESSION=1)"
    fi
  fi
}

# 生成确定性 16MiB（字节 i%256），供 mmap 扫描；优先块写入（勿逐字节 16M 次 syscall）。
ensure_io_mmap_bench_file() {
  rm -f "$BENCH_MMAP_FILE"
  python3 -c "
import os
p='$BENCH_MMAP_FILE'
os.makedirs(os.path.dirname(p), exist_ok=True)
n=int(${BENCH_MB})*1024*1024
pat=bytes([i & 255 for i in range(256)])
with open(p,'wb') as f:
    f.write(pat * (n // 256))
    r=n % 256
    if r:
        f.write(pat[:r])
" 2>/dev/null || {
    dd if=/dev/zero of="$BENCH_MMAP_FILE" bs=1048576 count="$BENCH_MB" 2>/dev/null
  }
  [ -f "$BENCH_MMAP_FILE" ] || { echo "run-perf-io: failed to create $BENCH_MMAP_FILE" >&2; exit 1; }
}

bench_io_case() {
  local name="$1"
  local base="$2"
  local desc="$3"
  local x="${base}.x"
  local c="${base}.c"
  local zig="${base}.zig"
  local XLANG_ASM_MED="nan"
  local XLANG_C_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== bench/${name} (${desc}) ==="

  # write 用例：每次计时前清输出文件；readv 用例：确保输入文件存在
  if [ "$name" = "io_write_throughput" ]; then
    rm -f "$BENCH_WRITE_FILE"
  fi
  if [ "$name" = "io_batch_readv" ]; then
    ensure_io_mmap_bench_file
  fi
  if [ "$name" = "io_random_pread" ]; then
    ensure_io_mmap_bench_file
  fi

  $PERF_COMPILE_XLANG -L . "$x" -o "/tmp/bench_io_shu_${tag}" 2>&1
  if [ -x "/tmp/bench_io_shu_${tag}" ]; then
    [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
    XLANG_ASM_MED=$(median_real "/tmp/bench_io_shu_${tag}")
    echo "Xlang (default asm) ${name} median real: ${XLANG_ASM_MED}s"
  fi

  if [ "$PERF_COMPILE_XLANG" != "./compiler/xlang-c" ] \
    && $PERF_COMPILE_XLANG -L . "$x" -backend c -o "/tmp/bench_io_shu_c_${tag}" 2>&1 \
    && [ -x "/tmp/bench_io_shu_c_${tag}" ]; then
    [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
    XLANG_C_MED=$(median_real "/tmp/bench_io_shu_c_${tag}")
    echo "Xlang (-backend c) ${name} median real: ${XLANG_C_MED}s"
  elif [ "$PERF_COMPILE_XLANG" = "./compiler/xlang-c" ] && [ "$XLANG_ASM_MED" != "nan" ]; then
    XLANG_C_MED="$XLANG_ASM_MED"
  fi

  if [ -x compiler/xlang_asm ]; then
    if compiler/xlang_asm -L . "$x" -o "/tmp/bench_io_asm_${tag}" 2>&1 && [ -x "/tmp/bench_io_asm_${tag}" ]; then
      [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
      ASM_MED=$(median_real "/tmp/bench_io_asm_${tag}")
      echo "Xlang asm (xlang_asm) ${name} median real: ${ASM_MED}s"
    fi
  fi

  if command -v cc >/dev/null 2>&1 && [ -f "$c" ]; then
    if cc -O2 "$c" -o "/tmp/bench_io_c_${tag}" 2>/dev/null && [ -x "/tmp/bench_io_c_${tag}" ]; then
      [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
      C_MED=$(median_real "/tmp/bench_io_c_${tag}")
      echo "C -O2 ${name} median real: ${C_MED}s"
    fi
  fi

  if command -v zig >/dev/null 2>&1 && [ -f "$zig" ]; then
    if zig_build_exe_o2 "$zig" "/tmp/bench_io_zig_${tag}"; then
      [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
      ZIG_MED=$(median_real "/tmp/bench_io_zig_${tag}")
      echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
    fi
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Xlang (default asm) | %s |\n' "$XLANG_ASM_MED"
  printf '| Xlang (-backend c) | %s |\n' "$XLANGXX_C_MED"
  printf '| Xlang asm (xlang_asm) | %s |\n' "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  check_io_zig_regress "$name" "$XLANG_ASM_MED" "$ZIG_MED"
  check_io_baseline_regress "$name" "$XLANG_ASM_MED" "$XLANGXX_C_MED"

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${XLANG_ASM_MED};"
}

ensure_io_mmap_bench_file

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-io: use --bench to run io_mmap_throughput + io_batch_readv + io_random_pread + io_write_throughput + zero_copy_sendfile + zero_copy_splice"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

BASELINE="${XLANG_PERF_IO_BASELINE:-tests/baseline/io-perf.tsv}"
bench_io_case io_mmap_throughput bench/i01_io_mmap_throughput "${BENCH_MB}MiB mmap scan"
rm -f "$BENCH_MMAP_FILE"
ensure_io_mmap_bench_file
bench_io_case io_batch_readv bench/i05_io_batch_readv "${BENCH_MB}MiB read_batch_fd 4×4KiB×1024"
rm -f "$BENCH_MMAP_FILE"
ensure_io_mmap_bench_file
bench_io_case io_random_pread bench/i01_io_random_pread "${BENCH_MB}MiB fs_pread random 4KiB×1024"
rm -f "$BENCH_MMAP_FILE"
bench_io_case io_write_throughput bench/i01_io_write_throughput "${BENCH_MB}MiB write (4KiB×4096)"
rm -f "$BENCH_WRITE_FILE"
bench_io_sendfile_case
rm -f "$BENCH_MMAP_FILE"
bench_io_splice_case
rm -f "$BENCH_MMAP_FILE"

if [ "${XLANG_PERF_UPDATE_BASELINE:-0}" = "1" ]; then
  {
    if [ -f "$BASELINE" ]; then
      awk -F'\t' '$1 !~ /^#/ && NF>=2 { print $1 "\t" $2 }' "$BASELINE"
    fi
    for pair in $(echo "$IO_CASE_MEDS" | tr ';' ' '); do
      [ -z "$pair" ] && continue
      cname="${pair%%:*}"
      cmed="${pair#*:}"
      [ "$cmed" = "nan" ] && continue
      printf '%s\t%s\n' "$cname" "$cmed"
    done
  } | awk -F'\t' 'NF>=2 { cap[$1]=$2 } END { for (k in cap) print k "\t" cap[k] }' >"${BASELINE}.body"
  {
    echo "# xlang io bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：XLANG_PERF_UPDATE_BASELINE=1 ./tests/run-perf-io.sh --bench"
    for c in io_mmap_throughput io_batch_readv io_random_pread io_write_throughput zero_copy_sendfile zero_copy_splice; do
      if grep -q "^${c}	" "${BASELINE}.body" 2>/dev/null; then
        grep "^${c}	" "${BASELINE}.body"
      fi
    done
    awk -F'\t' 'NF>=2 { print }' "${BASELINE}.body" | grep -v -E '^(io_mmap_throughput|io_batch_readv|io_random_pread|io_write_throughput|zero_copy_sendfile|zero_copy_splice)	' || true
  } >"$BASELINE"
  rm -f "${BASELINE}.body"
  echo "run-perf-io: updated $BASELINE"
fi

if [ "$PERF_FAIL_IO" -eq 1 ] && [ "$PERF_IO_FAILS" -gt 0 ]; then
  die "${PERF_IO_FAILS} case(s) slower than Zig -O2 (XLANG_PERF_FAIL_ON_IO_ZIG=1)"
fi

RUN_OK=1
echo "=== io perf OK ==="
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
