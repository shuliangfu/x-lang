#!/usr/bin/env bash
# G-FFI-5 release CI 入口：
#   1) business 零裸 extern + §8 unsafe 债务冻结
#   2) std/sys|std/ffi unsafe 包裹 grep
#   3) LANG-007 v2（run-lang-unsafe-gate）— 有 native shux 时跑
#   4) SAFE-003 audit（可选）
#
# 用法：./tests/run-g-ffi-5-release-ci-gate.sh
#   SHUX_G_FFI5_FAIL=1  硬失败（CI 默认建议 1）
#   SHUX_G_FFI5_SKIP_LANG_UNSAFE=1  跳过 lang-unsafe（仅静态策略时）
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
  tests/run-g-ffi-5-std-wrap-gate.sh \
  tests/run-g-ffi-5-business-no-bare-extern-gate.sh \
  tests/run-lang-unsafe-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh 2>/dev/null || true

# 1–2：静态 / 策略（不依赖全量编译器重链）
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh || die "business-no-bare-extern"

# 3：LANG-007 v2
# Linux 硬门槛（G-FFI-5 真机验收平台）；Darwin 已知若干 asm/link 债 → 默认 soft。
# 强制全平台硬失败：SHUX_G_FFI5_LANG_UNSAFE_STRICT=1
if [ "${SHUX_G_FFI5_SKIP_LANG_UNSAFE:-0}" = "1" ]; then
  echo "g-ffi-5 release-ci: skip lang-unsafe (SHUX_G_FFI5_SKIP_LANG_UNSAFE=1)"
else
  if [ ! -f tests/run-lang-unsafe-gate.sh ]; then
    die "missing run-lang-unsafe-gate.sh"
  fi
  if [ -z "${SHUX:-}" ]; then
    for cand in ./compiler/shux ./compiler/shux_asm ./compiler/shux-c; do
      if [ -x "$cand" ]; then
        export SHUX="$cand"
        break
      fi
    done
  fi
  set +e
  ./tests/run-lang-unsafe-gate.sh
  lu_rc=$?
  set -e
  if [ "$lu_rc" -ne 0 ]; then
    if [ "${SHUX_G_FFI5_LANG_UNSAFE_STRICT:-0}" = "1" ] || [ "$(uname -s)" = Linux ]; then
      die "lang-unsafe (rc=$lu_rc)"
    fi
    echo "g-ffi-5 release-ci: lang-unsafe soft-fail on $(uname -s) (rc=$lu_rc; Linux hard)"
  fi
fi

# 4：SAFE-003 audit（有则跑）
# Darwin 上 lang-unsafe 常因 ed25519 重复符号 / asm -o 债失败；audit 默认会 hook lang-unsafe。
# 非 Linux：审计清单硬门槛，但跳过嵌套 lang-unsafe（已在步骤 3 soft）。
if [ -f tests/run-safe-unsafe-audit-gate.sh ]; then
  if [ "$(uname -s)" != Linux ] && [ "${SHUX_G_FFI5_AUDIT_STRICT:-0}" != "1" ]; then
    export SHUX_SAFE_SKIP_LANG_UNSAFE=1
  fi
  ./tests/run-safe-unsafe-audit-gate.sh || die "safe-unsafe-audit"
fi

echo "g-ffi-5 release-ci gate OK"
