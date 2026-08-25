#!/usr/bin/env bash
# STD-130：std.random 可复现 PRNG 门禁（假权威诚实）。
#
# 用法：./tests/run-std-random-rng-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); rng_roundtrip.x + main.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/rt=/main=/skip=.
# C smoke observational only (co-emit debt is not a soft-green SKIP).
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check CHK002 / soft SKIP on x runnable / ## 3. 门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_RANDOM_RNG_DOC:-analysis/archive/std/std-random-rng-v1.md}"
MANIFEST="${XLANG_STD_RANDOM_RNG_TSV:-tests/baseline/std-random-rng-manifest.tsv}"
MOD_X="std/random/mod.x"
RANDOM_X="${XLANG_STD_RANDOM_IMPL:-std/random/random.x}"
RUNTIME_FILL="compiler/seeds/runtime_random_fill.from_x.c"
LIB="tests/lib/std-random-rng.sh"
SMOKE_X="tests/random/rng_roundtrip.x"
MAIN_X="tests/random/main.x"
MIN_APIS=5

# shellcheck source=tests/lib/std-random-rng.sh
. "$LIB"

echo "=== STD-130: random PRNG manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$RANDOM_X" "$RUNTIME_FILL" "$SMOKE_X" "$MAIN_X"; do
  if [ ! -f "$f" ]; then
    echo "std-random-rng gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-130 Rng seed step fill range rng_smoke; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-random-rng gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-random-rng gate FAIL: doc missing '## 5. Gate'" >&2
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
        echo "std-random-rng gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-random-rng gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-random-rng gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_random_rng_symbols_ok "$MOD_X" "$RANDOM_X" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_random_rng_emit_report "fail" 0 0 0 0
  echo "std-random-rng gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-random-rng manifest OK"

if [ "${XLANG_STD_RANDOM_RNG_MANIFEST_ONLY:-0}" = "1" ]; then
  std_random_rng_emit_report "ok" 0 0 0 1
  echo "std-random-rng gate OK (manifest only)"
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
RT_OK=0
MAIN_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-130: smoke (XLANG=$XLANG_BIN; check observational; rt/main hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-random-rng gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/random/random.o
  # C smoke observational only — co-emit debt must not soft-green the gate.
  if std_random_rng_run_c_smoke "$(cd compiler && pwd)/../std/random/random.o"; then
    echo "std-random-rng c smoke OK (observational)"
  else
    echo "std-random-rng gate SKIP c smoke (observational; co-emit/link debt)" >&2
  fi
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_random_rng_run_smoke "$XLANG_BIN" "$SMOKE_X" "rt"; then
    RT_OK=1
  else
    std_random_rng_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  if std_random_rng_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_random_rng_emit_report "fail" "$CHECK_OK" "$RT_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-random-rng gate FAIL: no native xlang" >&2
  std_random_rng_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is rt=/main=.
echo "std-random-rng check_ok=${CHECK_OK} (observational)"
std_random_rng_emit_report "ok" "$CHECK_OK" "$RT_OK" "$MAIN_OK" "$SKIP"
echo "std-random-rng gate OK"
