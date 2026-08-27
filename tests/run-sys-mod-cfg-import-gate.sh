#!/usr/bin/env bash
# B-19: std.sys/mod.x #[cfg] import prune smoke (Darwin/Linux).
#
# Honesty: soft SKIP→OK when no native xlang retired; soft FAIL=0 silent
# exit0 on compile/run miss retired (FAIL=0 → obs). Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. Unsupported host = skip. Report run=/obs=/skip=.
#
# Usage: ./tests/run-sys-mod-cfg-import-gate.sh
# Env:   XLANG_SYS_MOD_CFG_IMPORT_FAIL=1 (default) hard on product miss;
#        =0 → obs (still status=ok, counted).
# wave (2026-08-25): nested leaf sys_linux／sys_macos formal mangle + needles;
# soft T001 residual closed for product -o cfg import.
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED formal_mod／labi — Darwin + Linux gold; other OS = skip.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SYS_MOD_CFG_IMPORT_PREFIX:-xlang: [XLANG_SYS_MOD_CFG_IMPORT]}"
FAIL=${XLANG_SYS_MOD_CFG_IMPORT_FAIL:-1}
X="tests/sys/sys_mod_cfg_import_smoke.x"
OUT="/tmp/xlang_sys_mod_cfg_import.$$.out"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "sys-mod-cfg-import-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
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

obs_or_die() {
  local msg="$1"
  if [ "$FAIL" = "1" ]; then
    die "$msg"
  fi
  echo "sys-mod-cfg-import-gate OBS: $msg" >&2
  OBS=$((OBS + 1))
}

echo "=== B-19: std.sys #[cfg] import prune ==="
[ -f "$X" ] || die "missing $X"

OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) ;;
  *)
    SKIP=$((SKIP + 1))
    echo "sys-mod-cfg-import-gate: SKIP (unsupported host $OS)"
    echo "sys-mod-cfg-import-gate OK"
    ok_report
    exit 0
    ;;
esac

XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

rm -f "$OUT" 2>/dev/null || true

if ! "$XLANG_ABS" build -o "$OUT" "$X" 2>/tmp/xlang_sys_mod_cfg_import.log; then
  echo "sys-mod-cfg-import-gate: compile failed on $OS" >&2
  tail -n 10 /tmp/xlang_sys_mod_cfg_import.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  obs_or_die "compile $X on $OS"
  echo "sys-mod-cfg-import-gate OK"
  ok_report
  exit 0
fi

if [ ! -x "$OUT" ]; then
  obs_or_die "no executable $OUT"
  echo "sys-mod-cfg-import-gate OK"
  ok_report
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 0 ]; then
  obs_or_die "expected exit 0, got $rc on $OS"
  echo "sys-mod-cfg-import-gate OK"
  ok_report
  exit 0
fi

RUN_OK=$((RUN_OK + 1))
echo "sys-mod-cfg-import-gate OK (std.sys #[cfg] import prune on $OS)"
ok_report
