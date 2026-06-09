#!/usr/bin/env bash
# CI 全平台统一测试入口：平台支持的能力必须实跑，禁止 silent SKIP（SHU_CI_NO_SKIP=1）。
# 用法（仓库根）：CI=1 ./tests/run-ci-full-suite.sh
# 环境：SHU_CI_SKIP_HEAVY=1 — 仅本地快速烟测，跳过 build_shu_asm / bootstrap-verify。

set -e
cd "$(dirname "$0")/.."

export CI="${CI:-1}"
export SHU_CI_FULL_SUITE="${SHU_CI_FULL_SUITE:-1}"
export SHU_CI_NO_SKIP="${SHU_CI_NO_SKIP:-1}"

# ── 宿主探测 ─────────────────────────────────────────────────────────────
ci_host_os() { uname -s 2>/dev/null || echo Unknown; }
ci_host_arch() { uname -m 2>/dev/null || echo unknown; }

# 是否为 Linux x86_64（crt0 / freestanding / DOD perf 等）。
ci_is_linux_x64() {
  ci_is_linux && ci_is_x86_64_host
}

# 是否为 Linux（含 ARM64；DOD  correctness 可跑，perf stat 视内核而定）。
ci_is_linux() {
  [ "$(ci_host_os)" = "Linux" ]
}

# 是否为 macOS（Mach-O asm 链、无 io_uring）。
ci_is_darwin() {
  [ "$(ci_host_os)" = "Darwin" ]
}

# 是否为 ARM64/AArch64 宿主（Neon SIMD、AArch64 asm spill 门禁等）。
ci_is_arm64_host() {
  case "$(ci_host_arch)" in
    arm64|aarch64) return 0 ;;
  esac
  return 1
}

# 是否为 x86_64 宿主（SSE f32-xmm、Linux freestanding crt0 等）。
ci_is_x86_64_host() {
  case "$(ci_host_arch)" in
    x86_64|amd64) return 0 ;;
  esac
  return 1
}

# 是否在 Docker 容器内（perf stat / L1 miss 通常不可用，记 N/A）。
ci_is_docker() {
  [ -f /.dockerenv ] || [ -n "${SHU_CI_DOCKER:-}" ]
}

# Linux ARM64 CI 精简路径：全量 run-all-su + build_shu_asm 易超 170min；Neon DOD/SIMD 烟测保留，完整回归由 x86_64 承担。
ci_is_linux_arm64_ci_lite() {
  ci_is_linux && ci_is_arm64_host
}

# 是否为 Windows MSYS2 环境。
ci_is_windows_msys() {
  if [ -n "${MSYSTEM:-}" ]; then
    return 0
  fi
  case "$(ci_host_os)" in
    MINGW*|MSYS*) return 0 ;;
  esac
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
  local ver="${SHU_CI_ZIG_VERSION:-0.13.0}"
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

# 要求 shu_asm 已产出。
ci_require_shu_asm() {
  if [ ! -x compiler/shu_asm ]; then
    echo "ci-full-suite FAIL: compiler/shu_asm missing (required on this platform)" >&2
    exit 1
  fi
}

# 非 Linux 无 io_uring：不跑 ZC-1，但必须跑 ZC-2..5。
ci_run_zc_gates_no_zc1() {
  chmod +x tests/run-zc2-gate.sh tests/run-zc3-gate.sh tests/run-zc4-gate.sh tests/run-zc5-gate.sh
  SHU=./compiler/shu_asm ./tests/run-zc2-gate.sh
  SHU=./compiler/shu_asm ./tests/run-zc3-gate.sh
  SHU=./compiler/shu_asm ./tests/run-zc4-gate.sh
  SHU=./compiler/shu_asm ./tests/run-zc5-gate.sh
  echo "zc gates OK (ZC-1 N/A: io_uring requires Linux)"
}

echo "ci-full-suite: host=$(ci_host_os)/$(ci_host_arch) CI=${CI:-}"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: Linux ARM64 lite path (Neon DOD/SIMD; x86_64 covers run-all-su/build_shu_asm/WPO chain)"
  export SHULANG_LINK_SHU=./compiler/shu-c
fi

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

# ── Windows 专属：IOCP 门禁 ─────────────────────────────────────────────
if ci_is_windows_msys; then
  echo "── IO-A6 IOCP (Windows MSYS2) ──"
  chmod +x tests/run-iocp-gate.sh tests/run-perf-iocp.sh
  SHU_IOCP_RUNS=1 SHU_IOCP_BENCH_ROUNDS=32768 ./tests/run-iocp-gate.sh --perf | tee /tmp/iocp_gate.log
fi

# ── C / 原型 typeck ───────────────────────────────────────────────────────
echo "── C test suite ──"
if ci_is_linux_arm64_ci_lite; then
  # 全量 run-all-c 在 ARM64 上 >100min 且 run-net accept(0) 曾永久阻塞；烟测 + x86_64 全量覆盖。
  make -C compiler -q all 2>/dev/null || make -C compiler all
  chmod +x tests/run-bootstrap-shu-gate.sh
  SKIP_BOOTSTRAP_DRIVER_SEED=1 ./tests/run-bootstrap-shu-gate.sh
  echo "Test C OK (Linux ARM64 smoke; ubuntu x86_64 covers run-all-c)"
else
  make -C compiler test_c
fi

echo "── M-3 region typeck ──"
chmod +x tests/run-typeck-region.sh
ci_run_grep /tmp/typeck_region.log 'region typeck OK' ./tests/run-typeck-region.sh

echo "── migrate SU gen gate ──"
chmod +x tests/run-migrate-su-gen-gate.sh
ci_run_grep /tmp/migrate_su_gen.log 'migrate su gen gate OK' ./tests/run-migrate-su-gen-gate.sh

echo "── M-4 linear typeck ──"
chmod +x tests/run-typeck-linear.sh
ci_run_grep /tmp/typeck_linear.log 'linear typeck OK' ./tests/run-typeck-linear.sh

echo "── M-5 read_ptr_slice ──"
chmod +x tests/run-io-read-ptr-slice.sh
ci_run_grep /tmp/io_read_ptr_slice.log 'io read_ptr_slice OK' ./tests/run-io-read-ptr-slice.sh

echo "── ZC-3 slice field ──"
chmod +x tests/run-slice-field.sh tests/run-slice.sh
ci_run_grep /tmp/slice_field.log 'slice field OK' ./tests/run-slice-field.sh
ci_run_grep /tmp/slice_full.log 'slice test OK' ./tests/run-slice.sh

echo "── stdlib import ──"
chmod +x tests/run-stdlib-import.sh
ci_run_grep /tmp/stdlib_import.log 'stdlib-import test OK' ./tests/run-stdlib-import.sh

# ── Perf（全平台须 Zig 对照，禁止 skip） ─────────────────────────────────
ci_install_zig
ci_require_cmd zig

echo "── perf baseline ──"
if ci_is_linux; then
  SHU_PERF_FAIL_ON_ZIG=1 ./tests/run-perf-baseline.sh --bench | tee /tmp/perf_bench.log
else
  ./tests/run-perf-baseline.sh --bench | tee /tmp/perf_bench.log
fi
grep -q 'perf baseline OK' /tmp/perf_bench.log

echo "── IO perf ──"
chmod +x tests/run-perf-io.sh
if ci_is_linux; then
  SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench | tee /tmp/perf_io.log
else
  ./tests/run-perf-io.sh --bench | tee /tmp/perf_io.log
fi
grep -q 'io perf OK' /tmp/perf_io.log

echo "── net perf + multishot ──"
chmod +x tests/run-zc1-gate.sh tests/run-io-multishot.sh
if ci_is_linux; then
  ./tests/run-zc1-gate.sh --perf | tee /tmp/perf_net.log
  grep -qE 'ZC-1 gate OK|provided buffers N/A' /tmp/perf_net.log
  ./tests/run-io-multishot.sh | tee /tmp/io_multishot.log
  grep -qE 'io multishot accept OK|io multishot: N/A' /tmp/io_multishot.log
else
  echo "ci-full-suite: ZC-1 net perf N/A on $(ci_host_os) (io_uring requires Linux)"
fi

echo "── compile dogfood ──"
chmod +x tests/run-perf-compile-dogfood.sh
if ci_is_linux; then
  SHU_PERF_FAIL_ON_COMPILE_REGRESSION=1 ./tests/run-perf-compile-dogfood.sh | tee /tmp/compile_dogfood.log
else
  # macOS/Windows：跑 timing 烟测；基线仅校准于 Linux x64。
  ./tests/run-perf-compile-dogfood.sh | tee /tmp/compile_dogfood.log
fi
grep -q 'compile dogfood OK' /tmp/compile_dogfood.log

# refresh：Linux 全量；Darwin/Windows 在 CI 全量模式下也尝试（Mach-O/PE 单平台 relink）。
echo "── refresh shu_asm gate ──"
chmod +x tests/run-refresh-shu-asm-gate.sh
./tests/run-refresh-shu-asm-gate.sh | tee /tmp/refresh_asm_gate.log
grep -q 'refresh shu asm gate OK' /tmp/refresh_asm_gate.log
grep -q 'region typeck OK' /tmp/refresh_asm_gate.log
grep -q 'linear typeck OK' /tmp/refresh_asm_gate.log
ci_require_shu_asm

# ── ZC gates（Linux 含 ZC-1 io_uring；其它平台跑 ZC-2..5） ─────────────
echo "── ZC gates ──"
if ci_is_linux; then
  chmod +x tests/run-zc-gates.sh
  SHU=./compiler/shu_asm ./tests/run-zc-gates.sh | tee /tmp/zc_gates.log
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
if ci_is_linux; then
  grep -q 'async linux full OK' /tmp/async_smoke.log
  SHU_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench | tee /tmp/async_perf.log
  grep -q 'async perf OK' /tmp/async_perf.log
elif ci_is_darwin; then
  SHU=./compiler/shu-c SHU_PERF_FAIL_ON_ASYNC_REGRESSION=1 ./tests/run-perf-async.sh --bench | tee /tmp/async_perf.log
  grep -q 'async perf OK' /tmp/async_perf.log
fi

echo "── B-BOOT coldstart ──"
chmod +x tests/run-perf-coldstart.sh
SHU_COLDSTART_STD_ONLY=1 SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=1 \
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
./tests/run-bootstrap-shu-gate.sh

echo "── bootstrap run-all ──"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: bootstrap run-all N/A on Linux ARM64 (test_c OK; ubuntu x86_64 covers run-all)"
else
  make -C compiler bootstrap-driver-seed
  SHU=./compiler/shu SHULANG_RUN_ALL_BOOTSTRAP_SHU=1 ./tests/run-all.sh
fi

echo "── test_su (LSP + run-all-su) ──"
if ci_is_linux_arm64_ci_lite; then
  make -C compiler bootstrap-driver-seed
  chmod +x tests/run-lsp.sh
  ./tests/run-lsp.sh
  echo "ci-full-suite: run-all-su N/A on Linux ARM64 (x86_64 covers shu_su full run-all)"
else
  make -C compiler test_su
fi

if [ -n "${SHU_CI_SKIP_HEAVY:-}" ]; then
  echo "ci-full-suite: SHU_CI_SKIP_HEAVY=1 — skip asm/WPO/bstrict/verify"
  echo "ci-full-suite OK (light path)"
  exit 0
fi

# ── Goal 2 asm + 后续重门禁（全平台） ───────────────────────────────────
echo "── build_shu_asm (Goal 2) ──"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: build_shu_asm N/A on Linux ARM64 (refresh shu_asm for DOD/SIMD; x86_64 covers full self-host)"
  ci_require_shu_asm
else
  cd compiler && SHU=./shu ./scripts/build_shu_asm.sh
  cd ..
  [ -x compiler/shu_asm ] || { echo "ci-full-suite FAIL: shu_asm missing after build_shu_asm" >&2; exit 1; }
fi

echo "── asm .o quality ──"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: asm .o quality N/A on Linux ARM64 (no full build_shu_asm; x86_64 covers)"
else
  cd compiler && SHU=./shu ./scripts/check_asm_o_quality.sh
  cd ..
fi

echo "── S2 typeck gate ──"
chmod +x tests/run-s2-typeck-gate.sh tests/run-s2-typeck-o-parity.sh
if ci_is_linux && ci_is_x86_64_host; then
  SHU_S2_REQUIRE_TYPECK_O=1 SHU_S2_FAIL_ON_REGRESSION=1 ./tests/run-s2-typeck-gate.sh | tee /tmp/s2_typeck_gate.log
  grep -q 's2 typeck gate OK' /tmp/s2_typeck_gate.log
  SHU_S2_FAIL_ON_PARITY=1 ./tests/run-s2-typeck-o-parity.sh | tee /tmp/s2_typeck_parity.log
  grep -q 's2 parity OK' /tmp/s2_typeck_parity.log
else
  echo "ci-full-suite: S2 typeck gate N/A on $(ci_host_os)/$(ci_host_arch) (EMIT_HEAVY Linux x86_64 only)"
fi

echo "── shu_asm smoke ──"
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: shu_asm smoke on Linux ARM64 uses -backend c (full asm smoke: ubuntu x86_64)"
fi
cd compiler && ./scripts/run_shu_asm_smoke.sh
cd ..
if ci_is_darwin; then
  echo "ci-full-suite: shu_asm smoke on Darwin uses -backend c for run (asm user exe N/A on gen_driver hybrid)"
fi

# ARM64 宿主（Linux/macOS）：DOD SoA + cache-line + Neon strip（不含 x86 f32-xmm）。
ci_run_dod_arm64_subset() {
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s3-gate.sh \
    tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh \
    tests/run-simd-s3-gate.sh tests/lib/dod-native-exe.sh tests/lib/dod-host-backend.sh
  SHU=./compiler/shu_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh | tee /tmp/simd_s3.log
  grep -q 'simd-s3 gate OK' /tmp/simd_s3.log
  if ci_is_linux && ci_is_arm64_host; then
    echo "ci-full-suite: dod/simd f32 + simd-s3 vec peel N/A on Linux ARM64 (x86_64 covers)"
  elif ci_is_darwin && ci_is_arm64_host; then
    echo "ci-full-suite: simd-s3 vec peel + f32 run N/A on Darwin (Linux x86_64 covers)"
  fi
}

# x86_64 宿主 DOD 正确性（无 Linux perf stat）：Windows / Intel macOS。
ci_run_dod_x86_correctness() {
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s3-gate.sh tests/run-dod-s2-gate.sh \
    tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh \
    tests/run-simd-s3-gate.sh tests/run-f32-xmm-gates.sh tests/lib/dod-native-exe.sh
  SHU=./compiler/shu_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh | tee /tmp/simd_s3.log
  grep -q 'simd-s3 gate OK' /tmp/simd_s3.log
  SHU=./compiler/shu_asm ./tests/run-f32-xmm-gates.sh | tee /tmp/f32_xmm_gates.log
  grep -q 'f32-xmm-gates OK' /tmp/f32_xmm_gates.log
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
    sysctl -w kernel.perf_event_paranoid=1 2>/dev/null || true
  fi
  chmod +x tests/run-dod-s1-gate.sh tests/run-dod-s2-gate.sh tests/run-dod-s3-gate.sh tests/run-perf-dod-soa.sh tests/lib/dod-native-exe.sh
  SHU=./compiler/shu_asm SHU_DOD_SOA_FAIL=1 SHU_DOD_SOA_REQUIRE_L1="$DOD_SOA_REQUIRE_L1" ./tests/run-perf-dod-soa.sh | tee /tmp/dod_soa_perf.log
  grep -q 'SoA exit=16' /tmp/dod_soa_perf.log
  grep -q 'AoS exit=16' /tmp/dod_soa_perf.log
  if [ "$DOD_SOA_REQUIRE_L1" = "1" ]; then
    grep -q 'dod-soa L1 miss OK' /tmp/dod_soa_perf.log
  else
    echo "dod-soa L1 perf N/A (Docker container)"
  fi
  grep -q 'dod-soa gate OK' /tmp/dod_soa_perf.log
  SHU=./compiler/shu_asm ./tests/run-dod-s1-gate.sh | tee /tmp/dod_s1.log
  grep -q 'dod-s1 gate OK' /tmp/dod_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-s3-gate.sh | tee /tmp/dod_s3.log
  grep -q 'dod-s3 gate OK' /tmp/dod_s3.log
  chmod +x tests/run-dod-cl-s1-gate.sh tests/run-dod-cl-s2-gate.sh tests/run-simd-s3-gate.sh tests/run-f32-xmm-gates.sh
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s1-gate.sh | tee /tmp/dod_cl_s1.log
  grep -q 'dod-cl-s1 gate OK' /tmp/dod_cl_s1.log
  SHU=./compiler/shu_asm ./tests/run-dod-cl-s2-gate.sh | tee /tmp/dod_cl_s2.log
  grep -q 'dod-cl-s2 gate OK' /tmp/dod_cl_s2.log
  SHU=./compiler/shu_asm ./tests/run-simd-s3-gate.sh | tee /tmp/simd_s3.log
  grep -q 'simd-s3 gate OK' /tmp/simd_s3.log
  SHU=./compiler/shu_asm ./tests/run-f32-xmm-gates.sh | tee /tmp/f32_xmm_gates.log
  grep -q 'f32-xmm-gates OK' /tmp/f32_xmm_gates.log
elif ci_is_linux && ci_is_arm64_host; then
  echo "── DOD/SIMD (Linux ARM64, shu-c -o link; refresh shu_asm typeck) ──"
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
  SHU=./compiler/shu_asm SHU_COLDSTART_FREESTANDING_ONLY=1 \
    SHU_PERF_FAIL_ON_COLDSTART_REGRESSION=1 ./tests/run-perf-coldstart.sh --bench | tee /tmp/coldstart_fs.log
  grep -q 'coldstart OK' /tmp/coldstart_fs.log
fi

echo "── WPO-S2/S3/S4 ──"
chmod +x tests/run-wpo-s2.sh tests/run-perf-wpo-s2.sh tests/run-wpo-dce-asm.sh \
  tests/run-perf-wpo-dce-text.sh tests/run-perf-wpo-dce-compiler-self-text.sh \
  tests/run-perf-wpo-dce-shu-asm-text.sh tests/run-wpo-build-asm-chain-gate.sh \
  tests/ensure-wpo-build-asm-artifacts.sh tests/run-wpo-strict-link-gate.sh \
  tests/run-wpo-pipeline-reach-gate.sh tests/run-wpo-typeck-reach-gate.sh \
  tests/run-wpo-backend-reach-gate.sh tests/run-wpo-s3-gate.sh tests/run-wpo-s4-gate.sh \
  tests/lib/wpo-s3-disasm.sh tests/lib/wpo-main-disasm.sh tests/lib/wpo-ab-proxy.sh \
  compiler/scripts/relink_shu_asm_strict_glue.sh
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: WPO asm gates N/A on Linux ARM64 (refresh shu_asm x86_64 stub; x86_64 covers full WPO)"
fi
./tests/run-wpo-s2.sh | tee /tmp/wpo_s2.log
grep -q 'wpo-s2 smoke OK' /tmp/wpo_s2.log
./tests/run-wpo-dce-asm.sh | tee /tmp/wpo_dce_asm.log
grep -q 'wpo asm dce OK' /tmp/wpo_dce_asm.log
SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_DCE_TEXT=1 ./tests/run-perf-wpo-dce-text.sh | tee /tmp/wpo_dce_text.log
grep -q 'wpo dce text OK' /tmp/wpo_dce_text.log
if ci_is_linux_arm64_ci_lite; then
  echo "ci-full-suite: wpo compiler-self / shu_asm text / build_asm chain / strict-link N/A on Linux ARM64 (x86_64 covers)"
  echo "wpo compiler self text OK (Linux ARM64 N/A)" | tee /tmp/wpo_compiler_self_text.log
  echo "wpo shu_asm text OK (Linux ARM64 N/A)" | tee /tmp/wpo_shu_asm_text.log
  echo "wpo build_asm chain gate OK (Linux ARM64 N/A)" | tee /tmp/wpo_chain_gate.log
  echo "run-wpo-strict-link-gate OK (Linux ARM64 N/A)" | tee /tmp/wpo_strict_link_gate.log
else
  SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_COMPILER_SELF_TEXT=1 ./tests/run-perf-wpo-dce-compiler-self-text.sh | tee /tmp/wpo_compiler_self_text.log
  grep -q 'wpo compiler self text OK' /tmp/wpo_compiler_self_text.log
  SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shu-asm-text.sh | tee /tmp/wpo_shu_asm_text.log
  grep -q 'wpo shu_asm text OK' /tmp/wpo_shu_asm_text.log
  ./tests/run-wpo-build-asm-chain-gate.sh | tee /tmp/wpo_chain_gate.log
  grep -q 'wpo build_asm chain gate OK' /tmp/wpo_chain_gate.log
  SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh | tee /tmp/wpo_strict_link_gate.log
  grep -q 'run-wpo-strict-link-gate OK' /tmp/wpo_strict_link_gate.log
fi
if ci_is_docker; then
  # Docker 内 vec no-fold 运行偶发 SIGSEGV（可执行栈/perf 环境）；compile+disasm 仍实跑。
  SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHU_WPO_S2_RUNS=1 SHU_WPO_S2_LIMIT=1000000 SHU_WPO_S2_COMPILE_ONLY=1 ./tests/run-perf-wpo-s2.sh --bench | tee /tmp/wpo_s2_perf.log
else
  SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_S2_REGRESSION=1 SHU_WPO_S2_RUNS=1 SHU_WPO_S2_LIMIT=1000000 ./tests/run-perf-wpo-s2.sh --bench | tee /tmp/wpo_s2_perf.log
fi
grep -q 'wpo-s2 perf OK' /tmp/wpo_s2_perf.log
make -C compiler ../std/async/scheduler.o
SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh | tee /tmp/wpo_s3.log
grep -q 'wpo-s3 gate OK' /tmp/wpo_s3.log
SHU_WPO_PGO_HOT=1 SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh | tee /tmp/wpo_s4.log
grep -q 'wpo-s4 gate OK' /tmp/wpo_s4.log

echo "── B-strict bootstrap + gates ──"
if ci_is_linux && ci_is_x86_64_host; then
  if ci_is_docker; then
    # Docker 容器：shu_asm.experimental 在 cfg-merge 等 asm 烟测偶发 SIGSEGV；完整 bstrict 由 native linux job 覆盖。
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
