#!/usr/bin/env bash
# STD-045: std.sync RwLock/Condvar gate — honesty residual
# XLANG fallthrough / auto-make / ensure rebuild / check=/rwlock=/condvar=/main=/tsan=/skip=
# →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` rebuild + TSAN ensure/auto-make + report
# check=/rwlock=/condvar=/main=/tsan=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native
# = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c / XLANG
# fallthrough / soft ensure rebuild). check residual = obs (paused
# 2026-08-05). Host-C archaeology = obs (existing std/sync/sync.o +
# compiler/runtime_sync_os.o + compiler/runtime_sync_lock_diag_tls.o
# only; never rebuild; never pass extra CLI .o). tests/sync/rwlock_condvar.x
# + tests/sync/main.x product -o exit0 = hard run. TSAN C file existence
# is TSV-required; compile/run is not a green signal. Report:
# run=/obs=/skip=. Keep ## 5. Gate. Live ensure_std family left.
# F-sync v1 still hard-delegates this gate (must stay exit 0).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-sync-rwlock-condvar-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SYNC_RWLOCK_CONDVAR_DOC:-analysis/archive/std/std-sync-rwlock-condvar-v1.md}"
MANIFEST="${XLANG_STD_SYNC_RWLOCK_CONDVAR_TSV:-tests/baseline/std-sync-rwlock-condvar.tsv}"
MOD_X="std/sync/mod.x"
SYNC_OS_RUNTIME="${XLANG_STD_SYNC_OS_IMPL:-compiler/seeds/runtime_sync_os.from_x.c}"
SYNC_X="std/sync/sync.x"
SYNC_TLS_RUNTIME="${XLANG_STD_SYNC_TLS_IMPL:-compiler/seeds/runtime_sync_lock_diag_tls.from_x.c}"
LIB="tests/lib/std-sync-rwlock-condvar.sh"
SMOKE_X="tests/sync/rwlock_condvar.x"
MAIN_X="tests/sync/main.x"
TSAN_C="tests/sync/sync_tsan_ok.c"
MIN_APIS=12

# shellcheck source=tests/lib/std-sync-rwlock-condvar.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-sync-rwlock-condvar gate FAIL: $*" >&2
  std_sync_rc_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c / XLANG fallthrough.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
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

echo "=== STD-045: sync RwLock/Condvar manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-sync-rwlock-condvar-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_OS_RUNTIME" "$SYNC_TLS_RUNTIME" "$SMOKE_X" "$MAIN_X" "$TSAN_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-045 new_rwlock wait sync_tsan_ok rwlock_contention_smoke; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qE '^## 5\. Gate' "$DOC" || die "doc missing ## 5. Gate section"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_sync_rc_symbols_ok "$MOD_X" "$SYNC_OS_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-sync-rwlock-condvar manifest OK"

if [ "${XLANG_STD_SYNC_RWLOCK_CONDVAR_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_sync_rc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-sync-rwlock-condvar gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-045: smoke (XLANG=$XLANG_BIN; check/TSAN/host-C=obs; rwlock_condvar.x+main.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

echo "=== STD-045: API rename grep (XLANG=$XLANG_BIN) ==="
for sym in new_rwlock free_rwlock read_lock write_lock read_unlock write_unlock new_condvar wait notify_one notify_all free_condvar rwlock_contention_smoke condvar_contention_smoke; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "mod missing function ${sym}"
done
grep -q "sync.new_rwlock" "$SMOKE_X" 2>/dev/null || die "smoke missing sync.new_rwlock"
grep -q "sync.new_mutex" "$MAIN_X" 2>/dev/null || die "main missing sync.new_mutex"
if grep -qE 'function rwlock_new\(|function condvar_wait\(|function condvar_signal\(|function condvar_broadcast\(' "$MOD_X" 2>/dev/null; then
  die "mod still has fossil rwlock_new/condvar_wait API names"
fi

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std045_rw_check_$$.log 2>&1
chk_rw=$?
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std045_main_check_$$.log 2>&1
chk_main=$?
set -e
if [ "$chk_rw" -ne 0 ] || [ "$chk_main" -ne 0 ]; then
  echo "std-sync-rwlock-condvar OBS check (paused / CHK residual rw=$chk_rw main=$chk_main; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o. Product -o is the hard path (pure .x).
# TSAN C file existence is TSV-required; compile/run of host-C is not a
# green signal (historically optional; previously ensure_std_c_o +
# ensure_runtime_sync_os_o).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in std/sync/sync.o compiler/runtime_sync_os.o compiler/runtime_sync_lock_diag_tls.o; do
  if [ ! -f "$o" ]; then
    echo "std-sync-rwlock-condvar OBS missing $o (no soft ensure; product -o still hard)" >&2
    OBS=$((OBS + 1))
  fi
done

# rwlock_condvar.x + main.x product -o exit0 is the hard-green signal.
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_sync_rc_run_smoke "$XLANG_BIN" "$SMOKE_X" "rwlock_cv"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sync-rwlock-condvar OK: product rwlock_condvar.x"
else
  die "product -o $SMOKE_X failed (refuse soft SKIP→OK)"
fi
if std_sync_rc_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-sync-rwlock-condvar OK: product main.x"
else
  die "product -o $MAIN_X failed (refuse soft SKIP→OK)"
fi

std_sync_rc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-sync-rwlock-condvar gate OK"
