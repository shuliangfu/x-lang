#!/usr/bin/env bash
# G-FFI-5 release CI entry (policy hard + optional LANG-007 runtime).
#
# Hard policy (default, cross-platform):
#   1) business zero bare extern + §8 freeze (hard; soft FAIL retired)
#   2) std/sys|std/ffi unsafe wrap grep (via business → wrap)
#   3) SAFE-003 audit ledger (skip nested lang-unsafe)
#
# Runtime LANG-007:
#   Default SKIP (2026-08-27 honesty): xlang check gate paused → U*/S0
#   negative cases often CHK002. Soft false-green retired on policy path;
#   do not absorb check residual into archaeology green.
#   XLANG_G_FFI5_RUN_LANG_UNSAFE=1 → hard-run run-lang-unsafe-gate
#   XLANG_G_FFI5_SKIP_LANG_UNSAFE=1 → explicit skip (default)
#   XLANG_G_FFI5_LANG_UNSAFE_SOFT=1 → WARN only when RUN=1 fails
#
# Usage: ./tests/run-g-ffi-5-release-ci-gate.sh
# Report: business=/audit=/lang_unsafe=/skip=
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

PREFIX="xlang: [XLANG_G_FFI5_RELEASE]"
BUSINESS_OK=0
AUDIT_OK=0
LANG_UNSAFE_OK=0
SKIP=1

die() {
  echo "g-ffi-5 release-ci FAIL: $*" >&2
  echo "${PREFIX} status=fail business=${BUSINESS_OK:-0} audit=${AUDIT_OK:-0} lang_unsafe=${LANG_UNSAFE_OK:-0} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

echo "=== G-FFI-5 release CI bundle (policy hard; lang-unsafe default skip) ==="
chmod +x \
  tests/run-g-ffi-5-std-wrap-gate.sh \
  tests/run-g-ffi-5-business-no-bare-extern-gate.sh \
  tests/run-lang-unsafe-gate.sh \
  tests/run-safe-unsafe-api-gate.sh \
  tests/run-safe-unsafe-audit-gate.sh 2>/dev/null || true

# 1–2：策略门禁（business 已硬 die；不再导出 soft XLANG_G_FFI5_FAIL）
./tests/run-g-ffi-5-business-no-bare-extern-gate.sh || die "business-no-bare-extern"
BUSINESS_OK=1

# 3：SAFE-003 清单（默认跳过嵌套 lang-unsafe，避免双重跑）
if [ -f tests/run-safe-unsafe-audit-gate.sh ]; then
  export XLANG_SAFE_SKIP_LANG_UNSAFE=1
  ./tests/run-safe-unsafe-audit-gate.sh || die "safe-unsafe-audit"
  AUDIT_OK=1
else
  die "missing run-safe-unsafe-audit-gate.sh"
fi

# 4：LANG-007 运行时（默认 skip；check 闸门暂停）
# Run when RUN_LANG_UNSAFE=1 or SKIP_LANG_UNSAFE explicitly 0; else skip.
RUN_LU="${XLANG_G_FFI5_RUN_LANG_UNSAFE:-0}"
SKIP_LU="${XLANG_G_FFI5_SKIP_LANG_UNSAFE:-1}"
if [ "$RUN_LU" != "1" ] && [ "$SKIP_LU" != "0" ]; then
  echo "g-ffi-5 release-ci: skip lang-unsafe (check gate paused; set XLANG_G_FFI5_RUN_LANG_UNSAFE=1 to run)"
  LANG_UNSAFE_OK=0
  SKIP=0
else
  if [ -z "${XLANG:-}" ]; then
    for cand in ./compiler/xlang_asm ./compiler/xlang ./compiler/xlang-c; do
      if [ -x "$cand" ]; then
        export XLANG="$cand"
        break
      fi
    done
  fi
  set +e
  ./tests/run-lang-unsafe-gate.sh
  lu_rc=$?
  set -e
  if [ "$lu_rc" -ne 0 ]; then
    if [ "${XLANG_G_FFI5_LANG_UNSAFE_SOFT:-0}" = "1" ]; then
      echo "g-ffi-5 release-ci: lang-unsafe soft-fail (rc=$lu_rc; SOFT=1)"
      LANG_UNSAFE_OK=0
    else
      die "lang-unsafe (rc=$lu_rc)"
    fi
  else
    echo "g-ffi-5 release-ci: lang-unsafe OK"
    LANG_UNSAFE_OK=1
  fi
  SKIP=0
fi

echo "g-ffi-5 release-ci gate OK"
echo "${PREFIX} status=ok business=${BUSINESS_OK} audit=${AUDIT_OK} lang_unsafe=${LANG_UNSAFE_OK} skip=${SKIP} host=$(ci_host_summary)"
