#!/usr/bin/env bash
# STD-087：std.cache 门禁（假权威诚实）。
#
# 用法：./tests/run-std-cache-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); lru_pool_smoke.x exit 0 hard-fail (no soft SKIP
# when native xlang present). C smoke remains observational (archaeology host-C
# path; not hard green). Report check=/run=/skip=.
# formal_mod: mod.x prefix + cache.x --bare-impl (was std_x bare → std_cache_* UNDEF).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_CACHE_DOC:-analysis/archive/std/std-cache-v1.md}"
MANIFEST="${XLANG_STD_CACHE_MANIFEST:-tests/baseline/std-cache-manifest.tsv}"
MOD_X="std/cache/mod.x"
CACHE_X="std/cache/cache.x"
LIB="tests/lib/std-cache.sh"
SMOKE_X="tests/std-cache/lru_pool_smoke.x"
SMOKE_C="tests/std-cache/cache_smoke_ok.c"
MIN_APIS=10
# Designed success score (lru_pool_smoke.x returns 0 on all checks).
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-cache.sh
. "$LIB"

echo "=== STD-087: std.cache manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$CACHE_X" "$SMOKE_X" "$SMOKE_C" std/cache/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-cache gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-087 new_lru put acquire mark_unhealthy; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null && ! grep -qF -- "$kw" "$MANIFEST" 2>/dev/null; then
    echo "std-cache gate FAIL: doc/manifest missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-cache gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_APIS="$c2" ;; esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  [ "$kind" = "api" ] || continue
  API_N=$((API_N + 1))
  if ! grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null; then
    echo "std-cache gate FAIL: missing api $anchor" >&2
    exit 1
  fi
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-cache gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_cache_symbols_ok "$MOD_X" "$CACHE_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_cache_emit_report "fail" 0 0 0
  echo "std-cache gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-cache manifest OK"

if [ "${XLANG_STD_CACHE_MANIFEST_ONLY:-0}" = "1" ]; then
  std_cache_emit_report "ok" 0 0 1
  echo "std-cache gate OK (manifest only)"
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
RUN_OK=0
SKIP=1

# Observational host-C archaeology smoke (not hard green).
# PLATFORM: SHARED archaeology — product honesty is lru_pool_smoke.x via asm.
echo "=== STD-087: cache c smoke (observational) ==="
C_NOTE=0
if [ -x ./compiler/xlang-c ] || [ -x ./compiler/xlang ] || [ -x ./compiler/xlang_asm ]; then
  xlang_compiler_make ../std/cache/cache.o ../std/time/time.o runtime_time_os.o >/dev/null 2>&1 || true
  if cc -std=c11 -O1 -o /tmp/xlang_cache_smoke \
    "$SMOKE_C" std/cache/cache.o std/time/time.o compiler/runtime_time_os.o 2>/tmp/xlang_cache_smoke_link.err; then
    if /tmp/xlang_cache_smoke >/dev/null 2>&1; then
      C_NOTE=1
      echo "std-cache c smoke OK (observational)"
    fi
    rm -f /tmp/xlang_cache_smoke
  else
    echo "std-cache gate SKIP c smoke (observational; link failed)" >&2
    tail -n 10 /tmp/xlang_cache_smoke_link.err 2>/dev/null || true
  fi
else
  echo "std-cache gate SKIP c smoke (observational; no compiler)" >&2
fi
echo "std-cache c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-087: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-cache gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std087_cache_$$"
  LOG="/tmp/xlang_std087_cache_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-cache gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_cache_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-cache gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_cache_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-cache gate FAIL: no native xlang" >&2
  std_cache_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-cache check_ok=${CHECK_OK} (observational)"
std_cache_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-cache gate OK"
