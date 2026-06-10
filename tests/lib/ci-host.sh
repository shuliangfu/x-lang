#!/usr/bin/env bash
# ci-host.sh — 全平台 CI 宿主探测与 IO 能力探测（供 run-ci-full-suite / run-io-unified-gate 等 source）。
#
# 用法：
#   # shellcheck source=tests/lib/ci-host.sh
#   . "$(dirname "$0")/lib/ci-host.sh"
#   ci_host_os && io_uring_available && echo ok

# 返回宿主 OS 名称（Linux / Darwin / MINGW64_NT-... 等）。
ci_host_os() { uname -s 2>/dev/null || echo Unknown; }

# 返回宿主 CPU 架构（x86_64 / arm64 / aarch64 等）。
ci_host_arch() { uname -m 2>/dev/null || echo unknown; }

# 是否为 Linux（含 ARM64）。
ci_is_linux() {
  [ "$(ci_host_os)" = "Linux" ]
}

# 是否为 macOS。
ci_is_darwin() {
  [ "$(ci_host_os)" = "Darwin" ]
}

# 是否为 Windows MSYS2/MINGW 环境。
ci_is_windows_msys() {
  if [ -n "${MSYSTEM:-}" ]; then
    return 0
  fi
  case "$(ci_host_os)" in
    MINGW*|MSYS*) return 0 ;;
  esac
  return 1
}

# 是否为 ARM64/AArch64 宿主。
ci_is_arm64_host() {
  case "$(ci_host_arch)" in
    arm64|aarch64) return 0 ;;
  esac
  return 1
}

# 是否为 x86_64 宿主。
ci_is_x86_64_host() {
  case "$(ci_host_arch)" in
    x86_64|amd64) return 0 ;;
  esac
  return 1
}

# 是否为 Linux x86_64。
ci_is_linux_x64() {
  ci_is_linux && ci_is_x86_64_host
}

# 是否在 Docker 容器内。
ci_is_docker() {
  [ -f /.dockerenv ] || [ -n "${SHU_CI_DOCKER:-}" ]
}

# Linux：当前内核是否可用 io_uring（非 Linux 恒返回 1=不可用）。
ci_io_uring_available() {
  if ! ci_is_linux; then
    return 1
  fi
  # shellcheck source=tests/lib/io-uring-probe.sh
  . "${BASH_SOURCE%/*}/io-uring-probe.sh"
  io_uring_available
}

# Windows MSYS2：是否应走 IOCP 后端专测（perf 等）；非 Windows 返回 1。
iocp_backend_expected() {
  ci_is_windows_msys
}

# 打印当前宿主摘要（日志用）。
ci_host_summary() {
  echo "$(ci_host_os)/$(ci_host_arch)"
}
