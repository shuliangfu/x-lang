#!/usr/bin/env bash
# Windows cold-base smoke — alternative entry while leftover-PE cannot mint a
# full product PE without an egg (void*/struct* dual-decl blocks cold full
# pabi seed; FROM_X leftover hybrid omits .x-only bodies → phase1 UNDEF).
#
# Green means: host is Windows_NT/MinGW, g05/select recognize the host,
# crt0_mingw.o builds from seeds/crt0_mingw.from_x.c via cc_inc_tu --auto.
# Does NOT claim hybrid/L2 product matrix green.
#
# Usage (repo root, Git Bash on windows-server):
#   bash tests/run-windows-cold-base-smoke.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

if ! ci_is_windows_msys; then
  echo "windows-cold-base-smoke: skip (not Windows/MSYS host)"
  exit 0
fi

ci_windows_pin_tmpdir || exit 1
export PATH="/c/Program Files/Git/usr/bin:/c/w64devkit/bin:${PATH:-}"
export CC="${CC:-gcc}"
export XLANG_LEGACY_C_FRONTEND="${XLANG_LEGACY_C_FRONTEND:-1}"
export XLANG_ALLOW_HOST_CC="${XLANG_ALLOW_HOST_CC:-1}"

uname_s="$(uname -s 2>/dev/null || echo unknown)"
case "$uname_s" in
  Windows_NT*|MINGW*|MSYS*|CYGWIN*) ;;
  *)
    echo "windows-cold-base-smoke FAIL: unexpected uname -s=$uname_s" >&2
    exit 1
    ;;
esac
echo "windows-cold-base-smoke: host=$uname_s tip=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

cd compiler
# g05 must not say unsupported host
if bash scripts/g05_relink_env.sh 2>&1 | tee /tmp/win_cold_g05_probe.log | grep -qi 'unsupported host'; then
  echo "windows-cold-base-smoke FAIL: g05_relink_env unsupported host" >&2
  exit 1
fi
echo "windows-cold-base-smoke: g05 host gate OK"

# crt0 cold --auto
rm -f src/asm/crt0_mingw.o
XLANG_CC_INC_TU_FORCE=1 sh scripts/cc_inc_tu.sh --auto src/asm/crt0_mingw.o
if [ ! -s src/asm/crt0_mingw.o ]; then
  echo "windows-cold-base-smoke FAIL: crt0_mingw.o missing/empty" >&2
  exit 1
fi
if ! nm src/asm/crt0_mingw.o 2>/dev/null | grep -q ' T main$'; then
  echo "windows-cold-base-smoke FAIL: crt0_mingw.o missing T main" >&2
  exit 1
fi
echo "windows-cold-base-smoke: crt0_mingw.o OK ($(wc -c <src/asm/crt0_mingw.o | tr -d ' ')B, T main)"

echo "windows-cold-base-smoke OK (cold base; not hybrid/L2 product)"
exit 0
