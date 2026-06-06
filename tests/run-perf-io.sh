#!/usr/bin/env bash
# I/O 性能基线（NEXT I1/I2/I3/I4）：mmap / read_batch_fd(4段) / write，对比 Shu / C -O2 / Zig -O2
# 用法：./tests/run-perf-io.sh [--bench]
# 门禁（可选）：
#   SHU_PERF_FAIL_ON_IO_ZIG=1 — Shu default asm ≤ Zig -O2
#   SHU_PERF_FAIL_ON_IO_REGRESSION=1 — Shu default asm ≤ tests/baseline/io-perf.tsv
#   SHU_PERF_UPDATE_BASELINE=1 — 用本次 median 刷新 io-perf.tsv
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/fs/fs.o ../std/net/net.o -q 2>/dev/null || make -C compiler ../std/fs/fs.o ../std/net/net.o

BENCH_MMAP_FILE="tests/bench/.io_mmap_bench_tmp"
BENCH_WRITE_FILE="tests/bench/.io_write_bench_tmp"
BENCH_MB="${SHU_IO_BENCH_MB:-16}"
SENDFILE_PORT_DEFAULT=38459
BENCH_BYTES=$((BENCH_MB * 1024 * 1024))
RUNS=3
DO_BENCH=0
PERF_IO_FAILS=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_IO_ZIG:-0}" = "1" ] && PERF_FAIL_IO=1 || PERF_FAIL_IO=0
[ "${SHU_PERF_FAIL_ON_IO_REGRESSION:-0}" = "1" ] && PERF_FAIL_REGRESS=1 || PERF_FAIL_REGRESS=0
IO_CASE_MEDS=""

# 从 time 输出提取 real 秒数
extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

# 编译 Zig 对照二进制：apt 旧版用 -O2，0.13+ 用 -O ReleaseFast
zig_build_exe_o2() {
  local zig_src="$1"
  local out="$2"
  if zig build-exe -O2 "$zig_src" -femit-bin="$out" 2>/dev/null && [ -x "$out" ]; then
    return 0
  fi
  if zig build-exe -O ReleaseFast "$zig_src" -femit-bin="$out" 2>/dev/null && [ -x "$out" ]; then
    return 0
  fi
  return 1
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
  cc -O2 tests/bench/zero_copy_sendfile_sink.c -o "$SENDFILE_SINK_BIN" 2>/dev/null || return 1
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
      tests/bench/zero_copy_sendfile.su >"/tmp/bench_io_sendfile.su"
  if ! ./compiler/shu -L . "/tmp/bench_io_sendfile.su" -o "$out" >/tmp/bench_io_compile.log 2>&1; then
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
  cc -O2 tests/bench/zero_copy_sendfile.c -o "$exe" 2>/dev/null || { echo "nan"; return 1; }
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
  zig_build_exe_o2 tests/bench/zero_copy_sendfile.zig "$exe" || { echo "nan"; return 0; }
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
  local SHU_ASM_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"

  if ! fs_sendfile_supported; then
    echo "=== tests/bench/${name} — skip (sendfile unsupported on $(uname -s)) ==="
    printf '\n'
    return 0
  fi

  ensure_io_mmap_bench_file
  echo "=== tests/bench/${name} (${BENCH_MB}MiB file→socket sendfile @ 127.0.0.1:<dynamic>) ==="

  SHU_ASM_MED=$(median_shu_sendfile)
  echo "Shu (default asm) ${name} median real: ${SHU_ASM_MED}s"

  if command -v cc >/dev/null 2>&1; then
    C_MED=$(median_c_sendfile)
    echo "C -O2 ${name} median real: ${C_MED}s"
  fi

  if command -v zig >/dev/null 2>&1 && [ -f tests/bench/zero_copy_sendfile.zig ]; then
    ZIG_MED=$(median_zig_sendfile)
    echo "Zig -O2 ${name} median real: ${ZIG_MED}s"
  fi

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (default asm) | %s |\n' "$SHU_ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  if [ "$PERF_FAIL_IO" -eq 1 ] && [ "$ZIG_MED" != "nan" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    if awk -v shu="$SHU_ASM_MED" -v zig="$ZIG_MED" 'BEGIN { exit (shu <= zig + 0.000001) ? 0 : 1 }'; then
      echo "io perf gate OK: ${name} Shu asm ${SHU_ASM_MED}s <= Zig ${ZIG_MED}s"
    else
      echo "io perf gate FAIL: ${name} Shu asm ${SHU_ASM_MED}s > Zig ${ZIG_MED}s" >&2
      PERF_IO_FAILS=$((PERF_IO_FAILS + 1))
    fi
  fi

  if [ "$PERF_FAIL_REGRESS" -eq 1 ] && [ "$SHU_ASM_MED" != "nan" ]; then
    cap=$(io_baseline_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v shu="$SHU_ASM_MED" -v cap="$cap" 'BEGIN { exit (shu <= cap + 0.000001) ? 0 : 1 }'; then
        echo "io perf baseline OK: ${name} ${SHU_ASM_MED}s <= cap ${cap}s"
      else
        echo "io perf baseline FAIL: ${name} ${SHU_ASM_MED}s > cap ${cap}s" >&2
        exit 1
      fi
    fi
  fi

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${SHU_ASM_MED};"
}

compile_shu_splice() {
  local bytes="$1"
  local out="$2"
  rm -f "$out"
  sed -e "s/16777216/${bytes}/" \
      tests/bench/zero_copy_splice.su >"/tmp/bench_io_splice.su"
  if ! ./compiler/shu -L . "/tmp/bench_io_splice.su" -o "$out" >/tmp/bench_io_splice_compile.log 2>&1; then
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
  local SHU_ASM_MED="nan"

  if ! fs_splice_supported; then
    echo "=== tests/bench/${name} — skip (pipe splice unsupported on $(uname -s)) ==="
    printf '\n'
    return 0
  fi

  ensure_io_mmap_bench_file
  echo "=== tests/bench/${name} (${BENCH_MB}MiB file→socket fs_pipe_splice @ 127.0.0.1:<dynamic>) ==="

  SHU_ASM_MED=$(median_shu_splice)
  echo "Shu (default asm) ${name} median real: ${SHU_ASM_MED}s"

  printf '\n'
  printf '| %s | real (s) 中位数 |\n' "$name"
  printf '|---|----------------|\n'
  printf '| Shu (default asm) | %s |\n' "$SHU_ASM_MED"
  printf '\n'

  if [ "$PERF_FAIL_REGRESS" -eq 1 ] && [ "$SHU_ASM_MED" != "nan" ]; then
    cap=$(io_baseline_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v shu="$SHU_ASM_MED" -v cap="$cap" 'BEGIN { exit (shu <= cap + 0.000001) ? 0 : 1 }'; then
        echo "io perf baseline OK: ${name} ${SHU_ASM_MED}s <= cap ${cap}s"
      else
        echo "io perf baseline FAIL: ${name} ${SHU_ASM_MED}s > cap ${cap}s" >&2
        exit 1
      fi
    fi
  fi

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${SHU_ASM_MED};"
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
  awk -F'\t' -v n="$name" '$1==n && $1 !~ /^#/ { print $2; exit }' "${SHU_PERF_IO_BASELINE:-tests/baseline/io-perf.tsv}"
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
  local su="${base}.su"
  local c="${base}.c"
  local zig="${base}.zig"
  local SHU_ASM_MED="nan"
  local SHU_C_MED="nan"
  local C_MED="nan"
  local ZIG_MED="nan"
  local ASM_MED="nan"
  local tag="${name}_"

  echo "=== tests/bench/${name} (${desc}) ==="

  # write 用例：每次计时前清输出文件；readv 用例：确保输入文件存在
  if [ "$name" = "io_write_throughput" ]; then
    rm -f "$BENCH_WRITE_FILE"
  fi
  if [ "$name" = "io_batch_readv" ]; then
    ensure_io_mmap_bench_file
  fi

  ./compiler/shu -L . "$su" -o "/tmp/bench_io_shu_${tag}" 2>&1
  if [ -x "/tmp/bench_io_shu_${tag}" ]; then
    [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
    SHU_ASM_MED=$(median_real "/tmp/bench_io_shu_${tag}")
    echo "Shu (default asm) ${name} median real: ${SHU_ASM_MED}s"
  fi

  if ./compiler/shu -L . "$su" -backend c -o "/tmp/bench_io_shu_c_${tag}" 2>&1 && [ -x "/tmp/bench_io_shu_c_${tag}" ]; then
    [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
    SHU_C_MED=$(median_real "/tmp/bench_io_shu_c_${tag}")
    echo "Shu (-backend c) ${name} median real: ${SHU_C_MED}s"
  fi

  if [ -x compiler/shu_asm ]; then
    if compiler/shu_asm -L . "$su" -o "/tmp/bench_io_asm_${tag}" 2>&1 && [ -x "/tmp/bench_io_asm_${tag}" ]; then
      [ "$name" = "io_write_throughput" ] && rm -f "$BENCH_WRITE_FILE"
      ASM_MED=$(median_real "/tmp/bench_io_asm_${tag}")
      echo "Shu asm (shu_asm) ${name} median real: ${ASM_MED}s"
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
  printf '| Shu (default asm) | %s |\n' "$SHU_ASM_MED"
  printf '| Shu (-backend c) | %s |\n' "$SHU_C_MED"
  printf '| Shu asm (shu_asm) | %s |\n' "$ASM_MED"
  printf '| C -O2 | %s |\n' "$C_MED"
  printf '| Zig -O2 | %s |\n' "$ZIG_MED"
  printf '\n'

  if [ "$PERF_FAIL_IO" -eq 1 ] && [ "$ZIG_MED" != "nan" ] && [ "$SHU_ASM_MED" != "nan" ]; then
    if awk -v shu="$SHU_ASM_MED" -v zig="$ZIG_MED" 'BEGIN { exit (shu <= zig + 0.000001) ? 0 : 1 }'; then
      echo "io perf gate OK: ${name} Shu asm ${SHU_ASM_MED}s <= Zig ${ZIG_MED}s"
    else
      echo "io perf gate FAIL: ${name} Shu asm ${SHU_ASM_MED}s > Zig ${ZIG_MED}s" >&2
      PERF_IO_FAILS=$((PERF_IO_FAILS + 1))
    fi
  fi

  if [ "$PERF_FAIL_REGRESS" -eq 1 ] && [ "$SHU_ASM_MED" != "nan" ]; then
    cap=$(io_baseline_cap "$name")
    if [ -n "$cap" ]; then
      if awk -v shu="$SHU_ASM_MED" -v cap="$cap" 'BEGIN { exit (shu <= cap + 0.000001) ? 0 : 1 }'; then
        echo "io perf baseline OK: ${name} ${SHU_ASM_MED}s <= cap ${cap}s"
      else
        echo "io perf baseline FAIL: ${name} ${SHU_ASM_MED}s > cap ${cap}s" >&2
        exit 1
      fi
    fi
  fi

  IO_CASE_MEDS="${IO_CASE_MEDS}${name}:${SHU_ASM_MED};"
}

ensure_io_mmap_bench_file

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-io: use --bench to run io_mmap_throughput + io_batch_readv + io_write_throughput + zero_copy_sendfile + zero_copy_splice"
  exit 0
fi

BASELINE="${SHU_PERF_IO_BASELINE:-tests/baseline/io-perf.tsv}"
bench_io_case io_mmap_throughput tests/bench/io_mmap_throughput "${BENCH_MB}MiB mmap scan"
rm -f "$BENCH_MMAP_FILE"
ensure_io_mmap_bench_file
bench_io_case io_batch_readv tests/bench/io_batch_readv "${BENCH_MB}MiB read_batch_fd 4×4KiB×1024"
rm -f "$BENCH_MMAP_FILE"
bench_io_case io_write_throughput tests/bench/io_write_throughput "${BENCH_MB}MiB write (4KiB×4096)"
rm -f "$BENCH_WRITE_FILE"
bench_io_sendfile_case
rm -f "$BENCH_MMAP_FILE"
bench_io_splice_case
rm -f "$BENCH_MMAP_FILE"

if [ "${SHU_PERF_UPDATE_BASELINE:-0}" = "1" ]; then
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
    echo "# shu io bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：SHU_PERF_UPDATE_BASELINE=1 ./tests/run-perf-io.sh --bench"
    for c in io_mmap_throughput io_batch_readv io_write_throughput zero_copy_sendfile zero_copy_splice; do
      if grep -q "^${c}	" "${BASELINE}.body" 2>/dev/null; then
        grep "^${c}	" "${BASELINE}.body"
      fi
    done
    awk -F'\t' 'NF>=2 { print }' "${BASELINE}.body" | grep -v -E '^(io_mmap_throughput|io_batch_readv|io_write_throughput|zero_copy_sendfile|zero_copy_splice)	' || true
  } >"$BASELINE"
  rm -f "${BASELINE}.body"
  echo "run-perf-io: updated $BASELINE"
fi

if [ "$PERF_FAIL_IO" -eq 1 ] && [ "$PERF_IO_FAILS" -gt 0 ]; then
  echo "io perf FAIL: ${PERF_IO_FAILS} case(s) slower than Zig -O2" >&2
  exit 1
fi

echo "=== io perf OK ==="
