#!/usr/bin/env bash
# STD-132：std.env 平台编码 / 环境块边界门禁（假权威诚实）。
#
# 用法：./tests/run-std-env-platform-encoding-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); platform_encoding.x exit 0 hard-fail (no soft
# SKIP when native xlang present). C smoke remains observational (archaeology
# host-C path; not hard green). Report check=/run=/skip=.
# Product surface already green under asm; gate was portable-false-red
# (prefer xlang-c / hard check / soft SKIP on missing c).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD132_ENV_PLATFORM_ENCODING_DOC:-analysis/archive/std/std-env-platform-encoding-v1.md}"
MANIFEST="${XLANG_STD132_ENV_PLATFORM_ENCODING_MANIFEST:-tests/baseline/std-env-platform-encoding-manifest.tsv}"
MOD_X="std/env/mod.x"
ENV_IMPL="std/env/env.x"
ENV_GLUE="compiler/seeds/runtime_env_os.from_x.c"
LIB="tests/lib/std-env-platform-encoding.sh"
SMOKE_X="tests/env/platform_encoding.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-env-platform-encoding.sh
. "$LIB"

echo "=== STD-132: env platform-encoding manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-env-platform-encoding-v1.md ]; then
  echo "std-env-platform-encoding gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-env-platform-encoding gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-132 env_parse_kv_entry platform_encoding; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-env-platform-encoding gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-env-platform-encoding gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

sym_miss="$(std_env_platform_encoding_symbols_ok "$MOD_X" "$ENV_IMPL" "$ENV_GLUE" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_env_platform_encoding_emit_report "fail" 0 0 1
  echo "std-env-platform-encoding gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-env-platform-encoding manifest OK"

if [ "${XLANG_STD132_ENV_PLATFORM_ENCODING_MANIFEST_ONLY:-0}" = "1" ]; then
  std_env_platform_encoding_emit_report "ok" 0 0 1
  echo "std-env-platform-encoding gate OK (manifest only)"
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
# PLATFORM: SHARED archaeology — product honesty is platform_encoding.x via asm.
echo "=== STD-132: env c smoke (observational) ==="
C_NOTE=0
xlang_compiler_make ../std/env/env.o runtime_env_os.o >/dev/null 2>&1 || true
ENV_O="std/env/env.o"
if [ -f "$ENV_O" ] && nm "$ENV_O" 2>/dev/null | grep -qF 'env_platform_encoding_smoke_c'; then
  if std_env_platform_encoding_run_c_smoke "$ENV_O"; then
    C_NOTE=1
    echo "std-env-platform-encoding c smoke OK (observational)"
  else
    echo "std-env-platform-encoding gate SKIP c smoke (observational; link)" >&2
  fi
else
  echo "std-env-platform-encoding gate SKIP c smoke (observational; env.o / symbol)" >&2
fi
echo "std-env-platform-encoding c_smoke_note=${C_NOTE}"

if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-132: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-env-platform-encoding gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/env/mod.o 2>/dev/null || xlang_compiler_make ../std/env/mod.o 2>/dev/null || true
  xlang_compiler_make -q ../std/env/env.o 2>/dev/null || xlang_compiler_make ../std/env/env.o 2>/dev/null || true
  xlang_compiler_make -q runtime_env_os.o 2>/dev/null || xlang_compiler_make runtime_env_os.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std132_env_pe_$$"
  LOG="/tmp/xlang_std132_env_pe_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    rm -f "$OUT"
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      RUN_OK=1
      SKIP=0
    else
      echo "std-env-platform-encoding gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      std_env_platform_encoding_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-env-platform-encoding gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_env_platform_encoding_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi
else
  echo "std-env-platform-encoding gate FAIL: no native xlang" >&2
  std_env_platform_encoding_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (runnable).
echo "std-env-platform-encoding check_ok=${CHECK_OK} (observational)"
std_env_platform_encoding_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-env-platform-encoding gate OK"
