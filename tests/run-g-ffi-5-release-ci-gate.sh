#!/usr/bin/env bash
# G-FFI-5 release CI 入口：LANG-007 v2 + std wrap + 业务零裸 extern + 安全路线 §8。
#
# 用法：./tests/run-g-ffi-5-release-ci-gate.sh
#   SHUX_G_FFI5_FAIL=1  硬失败（CI 默认建议 1）
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_G_FFI5_FAIL:-1}
export SHUX_G_FFI5_FAIL="$FAIL"

die() {
  echo "g-ffi-5 release-ci FAIL: $*" >&2
  exit 1
}

echo "=== G-FFI-5 release CI bundle ==="
chmod +x \
  tests/run-lang-unsafe-gate.sh \
  tests/run-g-ffi-5-std-wrap-gate.sh \
  tests/run-g-ffi-5-business-no-bare-extern-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh 2>/dev/null || true

./tests/run-lang-unsafe-gate.sh || die "lang-unsafe"
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh || die "business-no-bare-extern"
if [ -f tests/run-safe-unsafe-audit-gate.sh ]; then
  ./tests/run-safe-unsafe-audit-gate.sh || die "safe-unsafe-audit"
fi

echo "g-ffi-5 release-ci gate OK"
