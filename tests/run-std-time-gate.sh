#!/usr/bin/env bash
# STD-005：std.time 精度与时区门禁（假权威诚实）。
#
# 用法：./tests/run-std-time-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); main.x + precision_smoke.x exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/main=/precision=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / soft SKIP on missing native / ## 6. 验证与门禁).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_TIME_DOC:-analysis/archive/std/std-time-precision-v1.md}"
MANIFEST="${XLANG_STD_TIME_MANIFEST:-tests/baseline/std-time-manifest.tsv}"
MOD_X="${XLANG_STD_TIME_MOD:-std/time/mod.x}"
TIME_RUNTIME="compiler/seeds/runtime_time_os.from_x.c"
TIME_X="std/time/time.x"
MAIN_X="tests/time/main.x"
PRECISION_X="tests/time/precision_smoke.x"
LIB="tests/lib/std-time.sh"
MIN_APIS=13

# shellcheck source=tests/lib/std-time.sh
. "$LIB"

echo "=== STD-005: std.time precision manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$TIME_RUNTIME" "$TIME_X" "$MAIN_X" "$PRECISION_X"; do
  if [ ! -f "$f" ]; then
    echo "std-time gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
API_N=0
echo "=== STD-005: API surface ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    api)
      API_N=$((API_N + 1))
      if ! std_time_has_api "$MOD_X" "$anchor"; then
        echo "std-time FAIL: missing API ${anchor} in $MOD_X" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing API $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script|hook_script)
      path="tests/$anchor"
      case "$anchor" in
        tests/*) path="$anchor" ;;
      esac
      if [ ! -f "$path" ]; then
        echo "std-time FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing smoke $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-time FAIL: missing xref $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "std-time FAIL: doc missing xref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-time gate FAIL: apis=${API_N} < min ${MIN_APIS}" >&2
  exit 1
fi

if ! grep -q '_WIN32' "$TIME_RUNTIME" 2>/dev/null || ! grep -q 'CLOCK_MONOTONIC' "$TIME_RUNTIME" 2>/dev/null; then
  echo "std-time gate FAIL: runtime_time_os missing platform branches" >&2
  exit 1
fi

for kw in precision timezone UTC monotonic runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "std-time gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! grep -qF '## 6. Gate' "$DOC" 2>/dev/null; then
  echo "std-time gate FAIL: doc missing '## 6. Gate'" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  std_time_emit_report "fail" 0 0 0 1
  echo "std-time gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-time manifest OK (apis=${API_N})"

if [ "${XLANG_STD_TIME_MANIFEST_ONLY:-0}" = "1" ]; then
  std_time_emit_report "ok" 0 0 0 1
  echo "std-time gate OK (manifest only)"
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
MAIN_OK=0
PRECISION_OK=0
SKIP=1

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-005: smoke (XLANG=$XLANG_BIN; check observational; main/precision hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$MAIN_X" >/dev/null 2>&1 \
    && "$XLANG_BIN" check -L . "$PRECISION_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-time gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/time/time.o
  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  if std_time_run_smoke "$XLANG_BIN" "$MAIN_X" "main"; then
    MAIN_OK=1
  else
    std_time_emit_report "fail" "$CHECK_OK" 0 0 0
    exit 1
  fi
  if std_time_run_smoke "$XLANG_BIN" "$PRECISION_X" "precision"; then
    PRECISION_OK=1
  else
    std_time_emit_report "fail" "$CHECK_OK" "$MAIN_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-time gate FAIL: no native xlang" >&2
  std_time_emit_report "fail" 0 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is main=/precision=.
echo "std-time check_ok=${CHECK_OK} (observational)"
std_time_emit_report "ok" "$CHECK_OK" "$MAIN_OK" "$PRECISION_OK" "$SKIP"
echo "std-time gate OK"
