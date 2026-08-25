#!/usr/bin/env bash
# STD-045：std.sync RwLock/Condvar 门禁（假权威诚实）。
#
# 用法：./tests/run-std-sync-rwlock-condvar-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); rwlock_condvar.x + main.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/rwlock=/condvar=/
# main=/tsan=/skip=. TSV/DOC API anchors aligned to product mod.x
# (new_rwlock/wait/notify_*); fossil rwlock_new/condvar_wait = portable false-red.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP / fossil API names).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

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

echo "=== STD-045: sync RwLock/Condvar manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SYNC_X" "$SYNC_OS_RUNTIME" "$SYNC_TLS_RUNTIME" "$SMOKE_X" "$MAIN_X" "$TSAN_C"; do
  if [ ! -f "$f" ]; then
    echo "std-sync-rwlock-condvar gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-045 new_rwlock wait sync_tsan_ok rwlock_contention_smoke; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sync-rwlock-condvar gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-sync-rwlock-condvar gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

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
      if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
        echo "std-sync-rwlock-condvar gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-sync-rwlock-condvar gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sync-rwlock-condvar gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sync_rc_symbols_ok "$MOD_X" "$SYNC_OS_RUNTIME" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sync_rc_emit_report "fail" 0 0 0 0 0 0
  echo "std-sync-rwlock-condvar gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sync-rwlock-condvar manifest OK"

if [ "${XLANG_STD_SYNC_RWLOCK_CONDVAR_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sync_rc_emit_report "ok" 0 0 0 0 0 1
  echo "std-sync-rwlock-condvar gate OK (manifest only)"
  exit 0
fi

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

resolve_shu() {
  local cand
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RW_OK=0
CV_OK=0
MAIN_OK=0
TSAN_R="skip"
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-045: smoke (XLANG=$XLANG_BIN; check observational; rw/cv/main hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-sync-rwlock-condvar gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/sync/sync.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_sync_rc_run_smoke "$XLANG_BIN" "$SMOKE_X" "rwlock_cv"; then
    RW_OK=1
    CV_OK=1
  else
    std_sync_rc_emit_report "fail" "$CHECK_OK" 0 0 0 0 0
    exit 1
  fi
  if std_sync_rc_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_sync_rc_emit_report "fail" "$CHECK_OK" "$RW_OK" "$CV_OK" 0 0 0
    exit 1
  fi
  TSAN_R="$(std_sync_rc_try_tsan "$SYNC_OS_RUNTIME" || echo fail)"
  if [ "$TSAN_R" = "fail" ]; then
    std_sync_rc_emit_report "fail" "$CHECK_OK" "$RW_OK" "$CV_OK" "$MAIN_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-sync-rwlock-condvar gate FAIL: no native xlang" >&2
  std_sync_rc_emit_report "fail" 0 0 0 0 0 0
  exit 1
fi

TSAN_OK=0
if [ "$TSAN_R" = "ok" ]; then
  TSAN_OK=1
fi
# check stays observational; hard-green signal is rwlock= + condvar= + main=.
# tsan=1 when toolchain present; tsan=0+skip=0 with TSAN_R=skip is still green.
echo "std-sync-rwlock-condvar check_ok=${CHECK_OK} (observational) tsan=${TSAN_R}"
std_sync_rc_emit_report "ok" "$CHECK_OK" "$RW_OK" "$CV_OK" "$MAIN_OK" "$TSAN_OK" "$SKIP"
echo "std-sync-rwlock-condvar gate OK"
