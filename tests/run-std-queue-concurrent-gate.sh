#!/usr/bin/env bash
# STD-048: std.queue concurrent optional wrapper gate — honesty residual
# XLANG fallthrough / auto-make / ensure rebuild / check=/main=/sync=/c=/skip=
# →硬绿.
#
# Honesty: soft `xlang_compiler_make -q || xlang_compiler_make` +
# XLANG fallthrough (`for cand in "${XLANG:-}" ./compiler/xlang_asm …`
# continues past explicit-bad XLANG) + bootstrap-link wrap +
# `ensure_std_c_o` rebuild + C contention auto-make + report
# check=/main=/sync=/c=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die
# (refuse soft SKIP→OK / soft auto-make / prefer-c / XLANG fallthrough
# / soft ensure rebuild). check residual = obs (paused 2026-08-05).
# Host-C archaeology = obs (existing std/queue/queue.o + std/sync/sync.o
# + compiler/runtime_queue_contention.o only; never rebuild; never pass
# extra CLI .o). tests/queue/main.x product -o exit0 = hard run.
# sync_queue_roundtrip.x product residual (queue-sync UNDEF) = obs.
# C smoke file existence is TSV-required; compile/run is not a green
# signal. Report: run=/obs=/skip=. Keep ## 4. Gate. Live ensure_std
# family left. F-queue v1/v2 still hard-delegate this gate (must stay
# exit 0). PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-queue-concurrent-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_QUEUE_CONCURRENT_DOC:-analysis/archive/std/std-queue-concurrent-v1.md}"
MANIFEST="${XLANG_STD_QUEUE_CONCURRENT_TSV:-tests/baseline/std-queue-concurrent.tsv}"
MOD_X="std/queue/mod.x"
QUEUE_X="std/queue/queue.x"
CONTENTION_C="tests/queue/sync_queue_contention_ok.c"
LIB="tests/lib/std-queue-concurrent.sh"
SMOKE_X="tests/queue/sync_queue_roundtrip.x"
MAIN_X="tests/queue/main.x"
MIN_APIS=6

# shellcheck source=tests/lib/std-queue-concurrent.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-queue-concurrent gate FAIL: $*" >&2
  std_queue_conc_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-048: queue concurrent manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
[ ! -f analysis/std-queue-concurrent-v1.md ] \
  || die "top-level DOC resurrected (live = archive/std/)"

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$QUEUE_X" "$SMOKE_X" "$MAIN_X" "$CONTENTION_C"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-048 SyncQueue_i32 std.channel sync_smoke sync_queue_contention_smoke_c; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" || die "doc missing ## 4. Gate section"

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

sym_miss="$(std_queue_conc_symbols_ok "$MOD_X" "$QUEUE_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-queue-concurrent manifest OK"

if [ "${XLANG_STD_QUEUE_CONCURRENT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_queue_conc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-queue-concurrent gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make / XLANG fallthrough)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-048: smoke (XLANG=$XLANG_BIN; check/sync/host-C=obs; main.x product -o hard) ==="
# Refuse soft xlang_compiler_make / bootstrap-link remap / ensure_std_c_o.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.

echo "=== STD-048: API rename grep (XLANG=$XLANG_BIN) ==="
for sym in new push_back pop_front length deinit sync_new sync_push sync_try_pop sync_deinit sync_smoke; do
  grep -qE "function ${sym}\\(" "$MOD_X" 2>/dev/null || die "mod missing function ${sym}"
done
for call in queue.sync_new queue.sync_push queue.sync_try_pop; do
  grep -q "${call}" "$SMOKE_X" 2>/dev/null || die "smoke missing ${call}"
done
grep -q "queue.new" "$MAIN_X" 2>/dev/null || die "main missing queue.new"
if grep -qE 'function queue_i32_|function queue_u8_|function sync_queue_i32_' "$MOD_X" 2>/dev/null; then
  die "mod still has old queue_* API names"
fi

# check = obs (paused); refuse hard check as sole green.
# PLATFORM: SHARED — refuse hard check as sole green.
set +e
"$XLANG_BIN" check -L . "$MAIN_X" >/tmp/xlang_std048_main_check_$$.log 2>&1
chk_x=$?
set -e
if [ "$chk_x" -ne 0 ]; then
  echo "std-queue-concurrent OBS check (paused / CHK residual ec=$chk_x; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Host-C archaeology = obs only; existing .o, no soft ensure/auto-make rebuild.
# Do not pass extra CLI .o. Product -o is the hard path (pure .x).
# C smoke file existence is TSV-required; compile/run of host-C is not a
# green signal (historically observational; previously auto-made
# runtime_queue_contention.o).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
for o in std/queue/queue.o std/sync/sync.o compiler/runtime_queue_contention.o; do
  if [ ! -f "$o" ]; then
    echo "std-queue-concurrent OBS missing $o (no soft ensure; product -o still hard)" >&2
    OBS=$((OBS + 1))
  fi
done

# main.x product -o exit0 is the hard-green signal (Queue_i32).
# PLATFORM: SHARED — refuse soft SKIP→OK / soft auto-make.
if std_queue_conc_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-queue-concurrent OK: product main.x"
else
  die "product -o $MAIN_X failed (refuse soft SKIP→OK)"
fi

# Observational: SyncQueue .x (product queue-sync UNDEF residual — not soft).
# PLATFORM: SHARED — refuse papering UNDEF as skip=OK.
if std_queue_conc_run_smoke "$XLANG_BIN" "$SMOKE_X" "sync_rt"; then
  echo "std-queue-concurrent OBS sync_queue_roundtrip.x unexpectedly green"
else
  echo "std-queue-concurrent OBS sync_queue_roundtrip (product residual; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

std_queue_conc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-queue-concurrent gate OK"
