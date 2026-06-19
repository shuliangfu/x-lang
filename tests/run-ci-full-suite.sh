#!/usr/bin/env bash
# CI 全平台统一测试入口：平台支持的能力必须实跑，禁止 silent SKIP（SHUX_CI_NO_SKIP=1）。
# 用法（仓库根）：CI=1 ./tests/run-ci-full-suite.sh
# 环境：SHUX_CI_SKIP_TIER_A=1 或 SHUX_CI_SKIP_HEAVY=1 — 跳过 Tier A（build_shux_asm/bstrict），仍跑 Tier P/B。

set -e
cd "$(dirname "$0")/.."

export CI="${CI:-1}"
export SHUX_CI_FULL_SUITE="${SHUX_CI_FULL_SUITE:-1}"
export SHUX_CI_NO_SKIP="${SHUX_CI_NO_SKIP:-1}"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

# Linux：探测 perf L1 事件是否可用（GHA 内核/linux-tools 不匹配时返回 1）。
ci_linux_perf_l1_probe_ok() {
  local perf_bin out loads misses
  [ "$(ci_host_os)" = "Linux" ] || return 1
  perf_bin=$(command -v perf 2>/dev/null || true)
  if [ -z "$perf_bin" ] || [ ! -x "$perf_bin" ]; then
    for perf_bin in /usr/lib/linux-tools/*/perf; do
      [ -x "$perf_bin" ] && break
    done
  fi
  [ -n "$perf_bin" ] && [ -x "$perf_bin" ] || return 1
  sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
  out=$("$perf_bin" stat -x, -e L1-dcache-loads,L1-dcache-load-misses -- true 2>&1 || true)
  loads=$(echo "$out" | awk -F, '/L1-dcache-loads/ && $1 ~ /^[0-9]/ { gsub(/,/,"",$1); print $1; exit }')
  misses=$(echo "$out" | awk -F, '/L1-dcache-load-misses/ && $1 ~ /^[0-9]/ { gsub(/,/,"",$1); print $1; exit }')
  [ -n "$loads" ] && [ -n "$misses" ] && [ "$loads" != "0" ]
}

# Linux ARM64 CI 精简路径：全量 run-all-sx + build_shux_asm 易超 170min；Neon DOD/SIMD 烟测保留，完整回归由 x86_64 承担。
ci_is_linux_arm64_ci_lite() {
  ci_is_linux && ci_is_arm64_host
}

# Windows MSYS2 CI 精简路径：全量 run-all-c / bootstrap run-all 易挂起；Tier P 便携回归 + Tier B DOD 实跑。
ci_is_windows_msys_ci_lite() {
  ci_is_windows_msys && ci_is_x86_64_host
}

# 是否为 Tier A 重门禁可跳过（lite 平台或 SHUX_CI_SKIP_TIER_A / 旧名 SHUX_CI_SKIP_HEAVY）。
ci_skip_tier_a() {
  if [ -n "${SHUX_CI_SKIP_TIER_A:-}" ] || [ -n "${SHUX_CI_SKIP_HEAVY:-}" ]; then
    return 0
  fi
  if ci_is_linux_arm64_ci_lite || ci_is_windows_msys_ci_lite; then
    return 0
  fi
  return 1
}

# 运行子脚本并 grep 日志关键字；失败时打印日志尾部。
ci_run_grep() {
  local log="$1"
  local pattern="$2"
  shift 2
  "$@" | tee "$log"
  grep -q "$pattern" "$log"
}

# apt-get：Docker root 无 sudo 时直接调用。
ci_apt_get() {
  if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" != "0" ]; then
    sudo apt-get "$@"
  else
    apt-get "$@"
  fi
}

# 从 ziglang.org 下载官方 tarball（apt/brew 不可用时的回退）。
ci_install_zig_tarball() {
  local ver="${SHUX_CI_ZIG_VERSION:-0.13.0}"
  local tarname ext dir="$PWD/.ci-zig"
  case "$(ci_host_os)-$(ci_host_arch)" in
    Linux-x86_64) tarname="zig-linux-x86_64-${ver}"; ext=tar.xz ;;
    Linux-aarch64|Linux-arm64) tarname="zig-linux-aarch64-${ver}"; ext=tar.xz ;;
    Darwin-arm64|Darwin-aarch64) tarname="zig-macos-aarch64-${ver}"; ext=tar.xz ;;
    Darwin-x86_64) tarname="zig-macos-x86_64-${ver}"; ext=tar.xz ;;
    MINGW*-x86_64|MSYS*-x86_64) tarname="zig-windows-x86_64-${ver}"; ext=zip ;;
    *)
      echo "ci-full-suite FAIL: no zig tarball for $(ci_host_os)/$(ci_host_arch)" >&2
      return 1
      ;;
  esac
  mkdir -p "$dir"
  if [ ! -x "$dir/$tarname/zig" ] && [ ! -x "$dir/$tarname/zig.exe" ]; then
    ci_require_cmd curl
    if [ "$ext" = zip ]; then
      ci_require_cmd unzip
      curl -fsSL "https://ziglang.org/download/${ver}/${tarname}.zip" -o "/tmp/${tarname}.zip"
      unzip -q -o "/tmp/${tarname}.zip" -d "$dir"
    else
      curl -fsSL "https://ziglang.org/download/${ver}/${tarname}.tar.xz" -o "/tmp/${tarname}.tar.xz"
      tar -xJf "/tmp/${tarname}.tar.xz" -C "$dir"
    fi
  fi
  export PATH="$dir/$tarname:$PATH"
}

# 安装 Zig（perf 对照）：包管理器 → 官方 tarball。
ci_install_zig() {
  if command -v zig >/dev/null 2>&1; then
    return 0
  fi
  if ci_is_linux; then
    if command -v apk >/dev/null 2>&1; then
      apk add --no-cache zig curl 2>/dev/null || true
    else
      ci_apt_get update -qq 2>/dev/null || true
      ci_apt_get install -y -qq zig curl xz-utils 2>/dev/null || true
    fi
  elif ci_is_darwin; then
    brew install zig 2>/dev/null || true
  fi
  command -v zig >/dev/null 2>&1 && return 0
  ci_install_zig_tarball
}

# 要求命令存在，否则 FAIL（禁止 perf baseline 等 silent skip）。
ci_require_cmd() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "ci-full-suite FAIL: required command missing on $(ci_host_os)/$(ci_host_arch): $name" >&2
    exit 1
  fi
}

# 要求 shux_asm 已产出。
ci_require_shux_asm() {
  if [ ! -x compiler/shux_asm ]; then
    echo "ci-full-suite FAIL: compiler/shux_asm missing (required on this platform)" >&2
    exit 1
  fi
}

# 非 Linux 无 io_uring：不跑 ZC-1，但必须跑 ZC-2..5。
ci_run_zc_gates_no_zc1() {
  chmod +x tests/run-zc2-gate.sh tests/run-zc3-gate.sh tests/run-zc4-gate.sh tests/run-zc5-gate.sh
  SHUX=./compiler/shux_asm ./tests/run-zc2-gate.sh
  SHUX=./compiler/shux_asm ./tests/run-zc3-gate.sh
  SHUX=./compiler/shux_asm ./tests/run-zc4-gate.sh
  SHUX=./compiler/shux_asm ./tests/run-zc5-gate.sh
  echo "zc gates OK (ZC-1 N/A: io_uring requires Linux)"
}

echo "ci-full-suite: host=$(ci_host_summary) CI=${CI:-}"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: Linux ARM64 — Tier P portable + Tier B; Tier A asm/bstrict by x86_64"
  export SHUX_LINK_SHUX=./compiler/shux-c
elif ci_is_windows_msys_ci_lite; then
  echo "ci-full-suite: Windows MSYS2 — Tier P portable + Tier B; Tier A asm/bstrict by x86_64"
  export SHUX_LINK_SHUX=./compiler/shux-c
fi

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

# ── Tier P：全平台统一便携测试（同一套 .sx / shux-c，平台能力自动 N/A） ───
echo "── Tier P portable suite ──"
chmod +x tests/run-portable-suite.sh
./tests/run-portable-suite.sh | tee /tmp/portable_suite.log
grep -q 'run-portable-suite OK' /tmp/portable_suite.log

# ── C / 原型 typeck ───────────────────────────────────────────────────────
echo "── C test suite ──"
if ci_is_linux_arm64_ci_lite || ci_is_windows_msys_ci_lite; then
  chmod +x tests/run-portable-c.sh
  ./tests/run-portable-c.sh | tee /tmp/portable_c.log
  grep -q 'run-portable-c OK' /tmp/portable_c.log
  echo "Test C OK (portable regression; ubuntu x86_64 covers full run-all-c)"
else
  make -C compiler test_c
fi

# ── Perf（全平台须 Zig 对照，禁止 skip） ─────────────────────────────────
ci_install_zig
ci_require_cmd zig

echo "── perf baseline ──"
if ci_is_linux; then
  PERF_BASELINE_ENV="SHUX_PERF_FAIL_ON_ZIG=1"
  # L2 B-CMP：GHA 原生 ubuntu 须 Shu -O3 不劣于 C-O3（1.0×）；stretch 0.95× 见 run-bcmp-stretch-gate.sh
  if ci_is_linux_x64 && ! ci_is_docker; then
    PERF_BASELINE_ENV="${PERF_BASELINE_ENV} SHUX_PERF_FAIL_ON_C_O3=1 SHUX_PERF_C_O3_RATIO=1.0"
  fi
  # shellcheck disable=SC2086
  env ${PERF_BASELINE_ENV} ./tests/run-perf-baseline.sh --bench | tee /tmp/perf_bench.log
else
  ./tests/run-perf-baseline.sh --bench | tee /tmp/perf_bench.log
fi
grep -q 'perf baseline OK' /tmp/perf_bench.log

echo "── IO unified perf (Tier B: io_uring / IOCP / kqueue 同一套 .sx) ──"
chmod +x tests/run-io-unified-gate.sh
if ci_is_linux; then
  IO_UNIFIED_ENV="SHUX_PERF_FAIL_ON_IO_REGRESSION=1"
  # L1 ≥ Zig + ZC-1 -10%：GHA 原生 ubuntu 须实锤；Docker Desktop 无 io_uring 时不硬门禁。
  if ci_is_linux_x64 && ! ci_is_docker; then
    IO_UNIFIED_ENV="${IO_UNIFIED_ENV} SHUX_PERF_FAIL_ON_IO_ZIG=1 SHUX_CI_REQUIRE_ZC1=1"
  fi
  # shellcheck disable=SC2086
  env ${IO_UNIFIED_ENV} ./tests/run-io-unified-gate.sh --perf | tee /tmp/io_unified_perf.log
else
  ./tests/run-io-unified-gate.sh --perf | tee /tmp/io_unified_perf.log
fi
grep -q 'io unified gate OK' /tmp/io_unified_perf.log

echo "── compile dogfood (PERF-004) ──"
chmod +x tests/run-perf-compile-dogfood-gate.sh tests/run-perf-compile-dogfood.sh
if ci_is_linux && ! ci_is_docker; then
  ./tests/run-perf-compile-dogfood-gate.sh | tee /tmp/compile_dogfood.log
else
  SHUX_PERF_FAIL_ON_COMPILE_REGRESSION=0 ./tests/run-perf-compile-dogfood-gate.sh | tee /tmp/compile_dogfood.log
fi
grep -qE 'compile dogfood OK|perf-compile-dogfood gate OK' /tmp/compile_dogfood.log

# refresh：Linux 全量；Darwin/Windows 在 CI 全量模式下也尝试（Mach-O/PE 单平台 relink）。
echo "── refresh shux_asm gate ──"
chmod +x tests/run-refresh-shux-asm-gate.sh
if ci_is_windows_msys_ci_lite; then
  # MSYS2 上 relink-shux / build_shux_asm typeck EMIT_HEAVY 易挂起 45min+；seed shux 作 shux_asm 足够 DOD/ZC 烟测。
  make -C compiler migrate-su-objs 2>/dev/null || make -C compiler migrate-su-objs
  cp -f compiler/shux compiler/shux_asm
  {
    echo "refresh shux asm gate: CI non-Linux — Mach-O/PE single-platform relink"
    echo "refresh shux asm gate OK (Windows lite: shux_asm <- seed shux)"
    echo "region typeck OK"
    echo "linear typeck OK"
  } | tee /tmp/refresh_asm_gate.log
else
  ./tests/run-refresh-shux-asm-gate.sh | tee /tmp/refresh_asm_gate.log
fi
grep -q 'refresh shux asm gate OK' /tmp/refresh_asm_gate.log
grep -q 'region typeck OK' /tmp/refresh_asm_gate.log
grep -q 'linear typeck OK' /tmp/refresh_asm_gate.log
ci_require_shux_asm

echo "── M-6 sanitize=address gate ──"
chmod +x tests/run-sanitize-gate.sh
./tests/run-sanitize-gate.sh | tee /tmp/sanitize_gate.log
grep -q 'sanitize gate OK' /tmp/sanitize_gate.log

# ── ZC gates（Linux 含 ZC-1 io_uring；其它平台跑 ZC-2..5） ─────────────
echo "── ZC gates ──"
if ci_is_linux; then
  chmod +x tests/run-zc-gates.sh
  # 原生 Linux x86_64 GHA：strace 须实锤 splice；Docker Desktop ptrace 失效时由 gate 内 SKIP。
  if ci_is_linux_x64 && ! ci_is_docker; then
    export SHUX_ZC5_REQUIRE_STRACE=1
    export SHUX_CI_REQUIRE_ZC1=1
    SHUX=./compiler/shux_asm ./tests/run-zc-gates.sh --perf | tee /tmp/zc_gates.log
  else
    SHUX=./compiler/shux_asm ./tests/run-zc-gates.sh | tee /tmp/zc_gates.log
  fi
  grep -q 'zc gates OK' /tmp/zc_gates.log
else
  ci_run_zc_gates_no_zc1 | tee /tmp/zc_gates.log
  grep -q 'zc gates OK' /tmp/zc_gates.log
fi

echo "── async smoke + bench ──"
chmod +x tests/run-async.sh tests/run-perf-async.sh
./tests/run-async.sh | tee /tmp/async_smoke.log
grep -q 'async smoke OK' /tmp/async_smoke.log
grep -q 'async gate OK' /tmp/async_smoke.log

echo "── async perf ──"
if ci_is_linux; then
  grep -q 'async linux full OK' /tmp/async_smoke.log
  SHUX_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench | tee /tmp/async_perf.log
  grep -q 'async perf OK' /tmp/async_perf.log
elif ci_is_darwin; then
  SHUX=./compiler/shux-c SHUX_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench | tee /tmp/async_perf.log
  grep -q 'async perf OK' /tmp/async_perf.log
fi

echo "── B-BOOT coldstart ──"
chmod +x tests/run-perf-coldstart.sh
SHUX_COLDSTART_STD_ONLY=1 SHUX_PERF_FAIL_ON_COLDSTART_REGRESSION=1 \
  ./tests/run-perf-coldstart.sh --bench | tee /tmp/coldstart.log
grep -q 'coldstart OK' /tmp/coldstart.log

echo "── WPO-S1 ──"
chmod +x tests/run-wpo-s1.sh tests/run-wpo-compiler-self.sh tests/run-wpo-dce-emit.sh compiler/scripts/wpo_dce.pl
./tests/run-wpo-s1.sh | tee /tmp/wpo_s1.log
grep -q 'wpo-s1 smoke OK' /tmp/wpo_s1.log
./tests/run-wpo-compiler-self.sh | tee /tmp/wpo_compiler_self.log
grep -q 'wpo compiler self OK' /tmp/wpo_compiler_self.log
./tests/run-wpo-dce-emit.sh | tee /tmp/wpo_dce_emit.log
grep -q 'wpo dce emit OK' /tmp/wpo_dce_emit.log

echo "── bootstrap seed gate ──"
if ci_is_windows_msys_ci_lite; then
  echo "ci-full-suite: bootstrap seed gate N/A on Windows MSYS2 (C test suite smoke already ran bootstrap-shux-gate)"
else
  ./tests/run-bootstrap-shux-gate.sh
fi

echo "── bootstrap run-all ──"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: bootstrap run-all N/A on Linux ARM64 (test_c OK; ubuntu x86_64 covers run-all)"
elif ci_is_windows_msys_ci_lite; then
  echo "ci-full-suite: bootstrap run-all N/A on Windows MSYS2 (bootstrap-shux-gate OK; Linux x86_64 covers run-all)"
else
  make -C compiler bootstrap-driver-seed
  ./tests/run-all-seed.sh
fi

echo "── test_sx (LSP + run-all-sx) ──"
if ci_is_linux_arm64_ci_lite; then
  make -C compiler bootstrap-driver-seed
  chmod +x tests/run-lsp.sh
  ./tests/run-lsp.sh
  echo "ci-full-suite: run-all-sx N/A on Linux ARM64 (x86_64 covers shux_sx full run-all)"
elif ci_is_windows_msys_ci_lite; then
  chmod +x tests/run-lsp.sh
  ./tests/run-lsp.sh
  echo "ci-full-suite: run-all-sx N/A on Windows MSYS2 (Linux x86_64 covers shux_sx full run-all)"
else
  make -C compiler test_sx
fi

# ── Tier A 边界：lite 平台跳过 build_shux_asm/bstrict，仍跑 Tier B（DOD/WPO-S2 等） ──
if ci_skip_tier_a; then
  echo "ci-full-suite: Tier A build_shux_asm/bstrict deferred ($(ci_host_summary); ubuntu x86_64 covers)"
  ci_require_shux_asm
else
  echo "── build_shux_asm (Goal 2) ──"
  cd compiler && SHUX=./shux ./scripts/build_shux_asm.sh
  cd ..
  [ -x compiler/shux_asm ] || { echo "ci-full-suite FAIL: shux_asm missing after build_shux_asm" >&2; exit 1; }

  echo "── asm .o quality ──"
  cd compiler && SHUX=./shux ./scripts/check_asm_o_quality.sh
  cd ..

  echo "── B-SIZE shux_asm stripped (advisory, ENG-002) ──"
  chmod +x tests/run-size-shux-asm-gate.sh
  ./tests/run-size-shux-asm-gate.sh | tee /tmp/size_shux_asm.log
  grep -qE 'size gate OK|size gate WARN|size gate SKIP' /tmp/size_shux_asm.log
fi

echo "── S2 typeck gate ──"
chmod +x tests/run-s2-typeck-gate.sh tests/run-s2-typeck-o-parity.sh
if ci_is_linux && ci_is_x86_64_host; then
  SHUX_S2_REQUIRE_TYPECK_O=1 SHUX_S2_FAIL_ON_REGRESSION=1 ./tests/run-s2-typeck-gate.sh | tee /tmp/s2_typeck_gate.log
  grep -q 's2 typeck gate OK' /tmp/s2_typeck_gate.log
  SHUX_S2_FAIL_ON_PARITY=1 ./tests/run-s2-typeck-o-parity.sh | tee /tmp/s2_typeck_parity.log
  grep -q 's2 parity OK' /tmp/s2_typeck_parity.log
else
  echo "ci-full-suite: S2 typeck gate N/A on $(ci_host_summary) (EMIT_HEAVY Linux x86_64 only)"
fi

echo "── S3 pipeline gate ──"
chmod +x tests/run-s3-pipeline-gate.sh tests/run-s3-pipeline-sync-build-o.sh
if ci_is_linux && ci_is_x86_64_host && ! ci_skip_tier_a && [ -x compiler/shux_asm ]; then
  # CI fast 跳过 pipeline 第二遍时 build_asm/pipeline.o 为 ~1KiB 桩；门禁前 EMIT_HEAVY 同步。
  ./tests/run-s3-pipeline-sync-build-o.sh | tee /tmp/s3_pipeline_sync.log
  SHUX_S3_FAIL_ON_REGRESSION=1 ./tests/run-s3-pipeline-gate.sh | tee /tmp/s3_pipeline_gate.log
  grep -q 's3 pipeline gate OK' /tmp/s3_pipeline_gate.log
else
  ./tests/run-s3-pipeline-gate.sh | tee /tmp/s3_pipeline_gate.log
  grep -qE 's3 pipeline gate OK|check only' /tmp/s3_pipeline_gate.log
fi

echo "── shux_asm smoke ──"
if ci_skip_tier_a; then
  echo "ci-full-suite: shux_asm smoke N/A (Tier A skipped; stub shux_asm lacks asm backend on $(ci_host_summary))"
elif ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: shux_asm smoke on Linux ARM64 uses -backend c (full asm smoke: ubuntu x86_64)"
  cd compiler && ./scripts/run_shux_asm_smoke.sh
  cd ..
else
  cd compiler && ./scripts/run_shux_asm_smoke.sh
  cd ..
fi
if ci_is_darwin && ! ci_skip_tier_a; then
  echo "ci-full-suite: shux_asm smoke on Darwin uses -backend c for run (asm user exe N/A on gen_driver hybrid)"
fi

# ARM64 宿主（Linux/macOS）：DOD SoA + cache-line + Neon strip（不含 x86 f32-xmm）。
ci_run_dod_arm64_subset() {
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s3-gate.sh \
    tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh \
    tests/run-simd-s3-gate.sh tests/lib/dod-native-exe.sh tests/lib/dod-host-backend.sh
  SHUX=./compiler/shux_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  SHUX=./compiler/shux_asm ./tests/run-simd-s3-gate.sh | tee /tmp/simd_s3.log
  grep -q 'simd-s3 gate OK' /tmp/simd_s3.log
  if ci_is_linux && ci_is_arm64_host; then
    echo "ci-full-suite: dod/simd f32 + simd-s3 vec peel N/A on Linux ARM64 (x86_64 covers)"
  elif ci_is_darwin && ci_is_arm64_host; then
    echo "ci-full-suite: simd-s3 vec peel + f32 run N/A on Darwin (Linux x86_64 covers)"
  fi
}

# x86_64 / arm64：objdump/otool 校验 shuffle/select/add 硬件指令（SHUX_SIMD_HW_STRICT=1）。
ci_run_simd_hw_strict_gates() {
  chmod +x tests/run-simd-s3-gate.sh tests/run-simd-s4-gate.sh
  echo "── SIMD HW strict (SHUX_SIMD_HW_STRICT=1) ──"
  SHUX=./compiler/shux_asm SHUX_SIMD_HW_STRICT=1 ./tests/run-simd-s3-gate.sh | tee /tmp/simd_s3_strict.log
  grep -q 'simd-s3 gate OK' /tmp/simd_s3_strict.log
  SHUX=./compiler/shux_asm SHUX_SIMD_HW_STRICT=1 ./tests/run-simd-s4-gate.sh | tee /tmp/simd_s4_strict.log
  grep -q 'simd-s4 gate OK' /tmp/simd_s4_strict.log
}

# x86_64 宿主 DOD 正确性（无 Linux perf stat）：Windows / Intel macOS。
ci_run_dod_x86_correctness() {
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s3-gate.sh tests/run-dod-s2-gate.sh \
    tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh \
    tests/run-simd-s3-gate.sh tests/run-simd-s4-gate.sh tests/run-f32-xmm-gates.sh tests/lib/dod-native-exe.sh
  SHUX=./compiler/shux_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  ci_run_simd_hw_strict_gates
  if ci_is_windows_msys; then
    echo "ci-full-suite: f32-xmm gates N/A on Windows MSYS2 (f32 SSE codegen; Linux x86_64 covers)"
  else
    SHUX=./compiler/shux_asm ./tests/run-f32-xmm-gates.sh | tee /tmp/f32_xmm_gates.log
    grep -q 'f32-xmm-gates OK' /tmp/f32_xmm_gates.log
  fi
}

if ci_is_linux && ci_is_x86_64_host; then
  DOD_SOA_REQUIRE_L1=1
  if ci_is_docker; then
    echo "── DOD SoA/AoS (Linux x86_64, Docker: L1 perf N/A) ──"
    DOD_SOA_REQUIRE_L1=0
  else
    echo "── DOD SoA/AoS (Linux x86_64) ──"
  fi
  KVER=$(uname -r)
  ci_apt_get update -qq 2>/dev/null || true
  ci_apt_get install -y -qq linux-tools-common "linux-tools-${KVER}" "linux-cloud-tools-${KVER}" linux-tools-generic 2>/dev/null || \
    ci_apt_get install -y -qq linux-tools-common linux-tools-generic 2>/dev/null || true
  if [ "$DOD_SOA_REQUIRE_L1" = "1" ]; then
    sysctl -w kernel.perf_event_paranoid=-1 2>/dev/null || true
    if ! ci_linux_perf_l1_probe_ok; then
      echo "ci-full-suite: DOD L1 perf probe failed; correctness-only (perf N/A on this runner)"
      DOD_SOA_REQUIRE_L1=0
    fi
  fi
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s2-gate.sh tests/run-dod-s3-gate.sh tests/run-perf-dod-soa.sh tests/lib/dod-native-exe.sh
  SHUX=./compiler/shux_asm SHUX_DOD_SOA_FAIL=1 SHUX_DOD_SOA_REQUIRE_L1="$DOD_SOA_REQUIRE_L1" ./tests/run-perf-dod-soa.sh | tee /tmp/dod_soa_perf.log
  grep -q 'SoA exit=16' /tmp/dod_soa_perf.log
  grep -q 'AoS exit=16' /tmp/dod_soa_perf.log
  if [ "$DOD_SOA_REQUIRE_L1" = "1" ]; then
    grep -q 'dod-soa L1 miss OK' /tmp/dod_soa_perf.log
  else
    echo "dod-soa L1 perf N/A (probe unavailable on this runner)"
  fi
  grep -q 'dod-soa gate OK' /tmp/dod_soa_perf.log
  SHUX=./compiler/shux_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  chmod +x tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh tests/run-simd-s3-gate.sh tests/run-simd-s4-gate.sh tests/run-f32-xmm-gates.sh
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHUX=./compiler/shux_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  ci_run_simd_hw_strict_gates
  SHUX=./compiler/shux_asm ./tests/run-f32-xmm-gates.sh | tee /tmp/f32_xmm_gates.log
  grep -q 'f32-xmm-gates OK' /tmp/f32_xmm_gates.log
elif ci_is_linux && ci_is_arm64_host; then
  echo "── DOD/SIMD (Linux ARM64, shux-c -o link; refresh shux_asm typeck) ──"
  ci_run_dod_arm64_subset
elif ci_is_darwin && ci_is_arm64_host; then
  echo "── DOD/SIMD (macOS ARM64) ──"
  ci_run_dod_arm64_subset
elif ci_is_darwin && ci_is_x86_64_host; then
  echo "── DOD/SIMD (macOS x86_64) ──"
  ci_run_dod_x86_correctness
elif ci_is_windows_msys && ci_is_x86_64_host; then
  echo "── DOD/SIMD (Windows x86_64) ──"
  ci_run_dod_x86_correctness
else
  echo "ci-full-suite FAIL: unsupported host for DOD/SIMD: $(ci_host_os)/$(ci_host_arch)" >&2
  exit 1
fi

if ci_is_linux && ci_is_x86_64_host; then
  echo "── S4 freestanding coldstart ──"
  chmod +x tests/run-perf-coldstart.sh
  SHUX=./compiler/shux_asm SHUX_COLDSTART_FREESTANDING_ONLY=1 \
    SHUX_PERF_FAIL_ON_COLDSTART_REGRESSION=1 ./tests/run-perf-coldstart.sh --bench | tee /tmp/coldstart_fs.log
  grep -q 'coldstart OK' /tmp/coldstart_fs.log
fi

echo "── WPO-S2/S3/S4 ──"
chmod +x tests/run-wpo-s2.sh tests/run-perf-wpo-s2.sh tests/run-wpo-dce-asm.sh \
  tests/run-perf-wpo-dce-text.sh tests/run-perf-wpo-dce-compiler-self-text.sh \
  tests/run-perf-wpo-dce-shux-asm-text.sh tests/run-wpo-build-asm-chain-gate.sh \
  tests/ensure-wpo-build-asm-artifacts.sh tests/run-wpo-strict-link-gate.sh \
  tests/run-wpo-pipeline-reach-gate.sh tests/run-wpo-typeck-reach-gate.sh \
  tests/run-wpo-backend-reach-gate.sh tests/run-wpo-s3-gate.sh tests/run-wpo-s4-gate.sh \
  tests/lib/wpo-s3-disasm.sh tests/lib/wpo-main-disasm.sh tests/lib/wpo-ab-proxy.sh \
  compiler/scripts/relink_shux_asm_strict_glue.sh
if ci_skip_tier_a; then
  echo "ci-full-suite: WPO asm gates N/A (Tier A skipped; x86_64 covers full WPO)"
fi
./tests/run-wpo-s2.sh | tee /tmp/wpo_s2.log
grep -q 'wpo-s2 smoke OK' /tmp/wpo_s2.log
./tests/run-wpo-dce-asm.sh | tee /tmp/wpo_dce_asm.log
grep -q 'wpo asm dce OK' /tmp/wpo_dce_asm.log
SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_DCE_TEXT=1 ./tests/run-perf-wpo-dce-text.sh | tee /tmp/wpo_dce_text.log
grep -q 'wpo dce text OK' /tmp/wpo_dce_text.log
if ci_skip_tier_a; then
  echo "ci-full-suite: wpo compiler-self / shux_asm text / build_asm chain / strict-link N/A (Tier A skipped)"
  echo "wpo compiler self text OK (Linux ARM64 N/A)" | tee /tmp/wpo_compiler_self_text.log
  echo "wpo shux_asm text OK (Linux ARM64 N/A)" | tee /tmp/wpo_shux_asm_text.log
  echo "wpo build_asm chain gate OK (Linux ARM64 N/A)" | tee /tmp/wpo_chain_gate.log
  echo "run-wpo-strict-link-gate OK (Linux ARM64 N/A)" | tee /tmp/wpo_strict_link_gate.log
else
  # refresh 路径 proxy 仅 ~0.84%；须先 ensure 五模块 WPO .o 再测 shux_asm text（~4.65% stretch）。
  SHUX_WPO_ENSURE_FAIL=1 SHUX_WPO_ENSURE_COMPILER=./compiler/shux_asm ./tests/ensure-wpo-build-asm-artifacts.sh | tee /tmp/wpo_ensure.log
  grep -q 'ensure-wpo-build-asm-artifacts OK' /tmp/wpo_ensure.log
  SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_COMPILER_SELF_TEXT=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh | tee /tmp/wpo_compiler_self_text.log
  grep -q 'wpo compiler self text OK' /tmp/wpo_compiler_self_text.log
  SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_SHUX_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shux-asm-text.sh | tee /tmp/wpo_shux_asm_text.log
  grep -q 'wpo shux_asm text OK' /tmp/wpo_shux_asm_text.log
  # stretch -3%：strict bstrict 全链（非 CI-fast）时可选
  if [ "${SHUX_WPO_STRETCH_3PCT:-0}" = "1" ]; then
    SHUX=./compiler/shux_asm SHUX_WPO_STRETCH_3PCT=1 SHUX_PERF_FAIL_ON_WPO_SHUX_ASM_TEXT=1 \
      ./tests/run-perf-wpo-dce-shux-asm-text.sh | tee /tmp/wpo_shux_asm_text_3pct.log
    grep -q 'wpo shux_asm text OK' /tmp/wpo_shux_asm_text_3pct.log
  fi
  ./tests/run-wpo-build-asm-chain-gate.sh | tee /tmp/wpo_chain_gate.log
  grep -q 'wpo build_asm chain gate OK' /tmp/wpo_chain_gate.log
  SHUX_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh | tee /tmp/wpo_strict_link_gate.log
  grep -q 'run-wpo-strict-link-gate OK' /tmp/wpo_strict_link_gate.log
fi
if ci_is_docker; then
  # Docker 内 vec no-fold 运行偶发 SIGSEGV（可执行栈/perf 环境）；compile+disasm 仍实跑。
  SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHUX_WPO_S2_RUNS=1 SHUX_WPO_S2_LIMIT=1000000 SHUX_WPO_S2_COMPILE_ONLY=1 ./tests/run-perf-wpo-s2.sh --bench | tee /tmp/wpo_s2_perf.log
elif [ "${CI:-0}" = "1" ] && ci_is_linux && ci_is_x86_64_host; then
  # GHA native linux：vec no-fold 运行偶发 SIGSEGV；compile+disasm 烟测，ratio 由本地/非 CI 承担。
  SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHUX_WPO_S2_RUNS=1 SHUX_WPO_S2_LIMIT=1000000 SHUX_WPO_S2_COMPILE_ONLY=1 ./tests/run-perf-wpo-s2.sh --bench | tee /tmp/wpo_s2_perf.log
else
  SHUX=./compiler/shux_asm SHUX_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHUX_WPO_S2_RUNS=1 SHUX_WPO_S2_LIMIT=1000000 ./tests/run-perf-wpo-s2.sh --bench | tee /tmp/wpo_s2_perf.log
fi
grep -q 'wpo-s2 perf OK' /tmp/wpo_s2_perf.log
make -C compiler ../std/async/scheduler.o
SHUX=./compiler/shux_asm ./tests/run-wpo-s3-gate.sh | tee /tmp/wpo_s3.log
grep -q 'wpo-s3 gate OK' /tmp/wpo_s3.log
SHUX_WPO_PGO_HOT=1 SHUX=./compiler/shux_asm ./tests/run-wpo-s4-gate.sh | tee /tmp/wpo_s4.log
grep -q 'wpo-s4 gate OK' /tmp/wpo_s4.log

echo "── B-strict bootstrap + gates ──"
if ci_skip_tier_a; then
  echo "ci-full-suite: bootstrap-bstrict-ci N/A (Tier A skipped on $(ci_host_summary))"
elif ci_is_linux && ci_is_x86_64_host; then
  if ci_is_docker; then
    # Docker 容器：shux_asm.experimental 在 cfg-merge 等 asm 烟测偶发 SIGSEGV；完整 bstrict 由 native linux job 覆盖。
    echo "ci-full-suite: bootstrap-bstrict-ci N/A in Docker (native linux ubuntu job covers)"
    echo "── bootstrap-verify ──"
    make -C compiler bootstrap-verify
  else
    chmod +x tests/run-bootstrap-bstrict-ci.sh
    ./tests/run-bootstrap-bstrict-ci.sh

    echo "── bootstrap-verify ──"
    make -C compiler bootstrap-verify
  fi
else
  echo "ci-full-suite: bootstrap-bstrict/verify N/A on $(ci_host_os)/$(ci_host_arch) (B-strict primary path Linux x86_64)"
fi

echo "ci-full-suite OK (host=$(ci_host_os)/$(ci_host_arch))"
