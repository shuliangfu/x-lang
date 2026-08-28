#!/usr/bin/env bash
# BOOT-029: std.sys freestanding / platform write — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary /
# prefer-c) + soft auto-make + check=/run=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard
# die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product
# write_stdout (Linux freestanding / Darwin hosted) = hard run (run+=).
# check + linux_nr / macos_thin = obs. Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sys-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SYS_DOC:-analysis/archive/std/std-sys-v0.md}"
MANIFEST="${XLANG_STD_SYS_TSV:-tests/baseline/std-sys-manifest.tsv}"
MOD_X="std/sys/mod.x"
LIB="tests/lib/std-sys.sh"
SMOKE_X="tests/sys/sys_write_freestanding.x"
SMOKE_LINUX="tests/sys/linux_syscall_nr_smoke.x"
SMOKE_MACOS_THIN="tests/sys/macos_posix_write_smoke.x"
SMOKE_FREEBSD="tests/sys/freebsd_posix_write_smoke.x"
LINUX_MOD="std/sys/linux.x"
MACOS_MOD="std/sys/macos.x"
FREEBSD_MOD="std/sys/freebsd.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-sys.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sys gate FAIL: $*" >&2
  std_sys_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
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
  # Prefer product asm; refuse soft auto-make / prefer-c fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

echo "=== BOOT-029: std.sys manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sys-v0.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$LINUX_MOD" "$MACOS_MOD" "$FREEBSD_MOD" \
         "$SMOKE_X" "$SMOKE_LINUX" "$SMOKE_MACOS_THIN" "$SMOKE_FREEBSD" std/sys/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in BOOT-029 os_write xlang_sys_write freestanding linux.x macos.x macos_write; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < $MIN_APIS"

sym_miss="$(std_sys_symbols_ok "$MOD_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sys manifest OK"

if [ "${XLANG_STD_SYS_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sys_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sys gate OK (manifest only)"
  exit 0
fi

HOSTOS="$(uname -s 2>/dev/null)"
XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== BOOT-029: smoke (XLANG=$XLANG_BIN; check/linux_nr/macos_thin obs; write_stdout product hard) ==="

# Observational check (paused 2026-08-05); CHK red → obs, not soft SKIP→OK.
# PLATFORM: SHARED — host picks cfg-available smokes for check only.
CHK_FAIL=0
if ! "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
  CHK_FAIL=1
fi
if [ "$HOSTOS" = "Linux" ]; then
  if ! "$XLANG_BIN" check -L . "$SMOKE_LINUX" >/dev/null 2>&1; then
    CHK_FAIL=1
  fi
fi
if [ "$HOSTOS" = "Darwin" ]; then
  if ! "$XLANG_BIN" check -L . "$SMOKE_MACOS_THIN" >/dev/null 2>&1; then
    CHK_FAIL=1
  fi
fi
if [ "$CHK_FAIL" -ne 0 ]; then
  echo "std-sys OBS check (paused / CHK residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

OUT="/tmp/xlang_boot029_sys_write_$$"
LOG="/tmp/xlang_boot029_sys_write_$$.log"
BUILD_OK=0
if [ "$HOSTOS" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
  # PLATFORM: LINUX|UBUNTU — freestanding write is the gold hard path.
  if "$XLANG_BIN" -freestanding -backend asm "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    BUILD_OK=1
  fi
else
  # PLATFORM: MACOS|DARWIN (and non-x86_64 Linux) — hosted write_stdout hard path.
  if "$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    BUILD_OK=1
  fi
fi

if [ "$BUILD_OK" -eq 1 ] && [ -x "$OUT" ]; then
  if std_sys_expect_hello "$OUT" "write_stdout"; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-sys OK: write_stdout"
  else
    rm -f "$OUT"
    die "write_stdout exit/stdout (refuse soft SKIP→OK)"
  fi
  rm -f "$OUT"
else
  tail -20 "$LOG" 2>/dev/null >&2 || true
  die "write_stdout link (refuse soft SKIP→OK)"
fi

# Observational: Linux syscall nr table. PLATFORM: LINUX.
if [ "$HOSTOS" = "Linux" ]; then
  NR_OUT="/tmp/xlang_boot029_sys_nr_$$"
  if "$XLANG_BIN" -L . "$SMOKE_LINUX" -o "$NR_OUT" 2>/dev/null \
    && [ -x "$NR_OUT" ] && "$NR_OUT" >/dev/null 2>&1; then
    echo "std-sys linux_nr smoke OK (observational)"
  else
    echo "std-sys OBS linux_nr smoke (refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$NR_OUT"
fi

# Observational only: thin macos_write_* product UNDEF under asm.
# PLATFORM: MACOS|DARWIN archaeology — report via obs=.
if [ "$HOSTOS" = "Darwin" ]; then
  MAC_OUT="/tmp/xlang_boot029_sys_macos_thin_$$"
  if "$XLANG_BIN" -L . "$SMOKE_MACOS_THIN" -o "$MAC_OUT" 2>/dev/null \
    && [ -x "$MAC_OUT" ] && std_sys_expect_hello "$MAC_OUT" "macos_thin" 2>/dev/null; then
    echo "std-sys macos_thin smoke OK (observational)"
  else
    echo "std-sys OBS macos_thin smoke (labi needle gap; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
  rm -f "$MAC_OUT"
fi

std_sys_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sys gate OK (host=$(ci_host_summary))"
