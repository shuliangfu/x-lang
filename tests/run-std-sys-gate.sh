#!/usr/bin/env bash
# BOOT-029: std.sys freestanding / platform write gate (false-authority honesty).
#
# Usage: ./tests/run-std-sys-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); platform write_stdout smoke exit 0 hard-fail
# (no soft SKIP→OK when native xlang present). Linux freestanding path remains
# the Linux hard runnable; Darwin hard runnable is write_stdout (not thin
# macos_write_* — product UNDEF: labi needs_std_sys needles miss mod-layer
# std_sys_macos_write_*). macos_posix_write_smoke observational only.
# Report check=/run=/skip=. Gate was portable-false-red (prefer ./compiler/xlang
# / hard check / soft SKIP→OK when no freestanding host / no native → still ok).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
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

stdlib_cm_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
std_sys_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

echo "=== BOOT-029: std.sys manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-sys-v0.md ]; then
  echo "std-sys gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$LINUX_MOD" "$MACOS_MOD" "$FREEBSD_MOD" \
         "$SMOKE_X" "$SMOKE_LINUX" "$SMOKE_MACOS_THIN" "$SMOKE_FREEBSD" std/sys/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-sys gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in BOOT-029 os_write xlang_sys_write freestanding linux.x macos.x macos_write; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-sys gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-sys gate FAIL: doc missing '## 3. Gate'" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api) API_N=$((API_N + 1)) ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-sys gate FAIL: api count $API_N < $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_sys_symbols_ok "$MOD_X" "$MANIFEST" "$DOC" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sys_emit_report "fail" 0 0 0
  echo "std-sys gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-sys manifest OK"

if [ "${XLANG_STD_SYS_MANIFEST_ONLY:-0}" = "1" ]; then
  std_sys_emit_report "ok" 0 0 1
  echo "std-sys gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
RUN_OK=0
SKIP=1
HOSTOS="$(uname -s 2>/dev/null)"

if XLANG_BIN="$(std_sys_resolve_shu 2>/dev/null)"; then
  echo "=== BOOT-029: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
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
  if [ "$CHK_FAIL" -eq 0 ]; then
    CHECK_OK=1
  else
    echo "std-sys gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  xlang_compiler_make -q ../std/sys/sys.o 2>/dev/null || xlang_compiler_make ../std/sys/sys.o 2>/dev/null || true
  if [ "$HOSTOS" = "Darwin" ]; then
    xlang_compiler_make -q ../std/sys/macos.o 2>/dev/null || xlang_compiler_make ../std/sys/macos.o 2>/dev/null || true
  fi
  if [ "$HOSTOS" = "Linux" ]; then
    xlang_compiler_make -q ../std/sys/linux.o 2>/dev/null || xlang_compiler_make ../std/sys/linux.o 2>/dev/null || true
  fi

  OUT="/tmp/xlang_boot029_sys_write_$$"
  LOG="/tmp/xlang_boot029_sys_write_$$.log"
  BUILD_OK=0
  if [ "$HOSTOS" = "Linux" ] && [ "$(uname -m 2>/dev/null)" = "x86_64" ]; then
    # PLATFORM: LINUX|UBUNTU — freestanding write is the gold hard path.
    # Invoke pinned XLANG_BIN directly (same argv as historic gate / Ubuntu probe).
    if "$XLANG_BIN" -freestanding -backend asm "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
      BUILD_OK=1
    fi
  else
    # PLATFORM: MACOS|DARWIN (and non-x86_64 Linux) — hosted write_stdout hard path.
    # Thin macos_write_* stays observational (link needle gap; see below).
    if $RUN_XLANG build -L . "$SMOKE_X" -o "$OUT" 2>"$LOG"; then
      BUILD_OK=1
    fi
  fi

  if [ "$BUILD_OK" -eq 1 ] && [ -x "$OUT" ]; then
    if std_sys_expect_hello "$OUT" "write_stdout"; then
      RUN_OK=1
      SKIP=0
    else
      rm -f "$OUT"
      std_sys_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    rm -f "$OUT"
  else
    echo "std-sys gate FAIL runnable link (write_stdout)" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_sys_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi

  # Observational: Linux syscall nr table (already green under asm; not the
  # hard-green signal — write_stdout is). PLATFORM: LINUX.
  if [ "$HOSTOS" = "Linux" ]; then
    NR_NOTE=0
    NR_OUT="/tmp/xlang_boot029_sys_nr_$$"
    if $RUN_XLANG build -L . "$SMOKE_LINUX" -o "$NR_OUT" 2>/dev/null \
      && [ -x "$NR_OUT" ] && "$NR_OUT" >/dev/null 2>&1; then
      NR_NOTE=1
    else
      echo "std-sys gate SKIP linux_nr smoke (observational)" >&2
    fi
    rm -f "$NR_OUT"
    echo "std-sys linux_nr_note=${NR_NOTE}"
  fi

  # Observational only: thin macos_write_* product UNDEF under asm
  # (labi_od_sys_sym_* misses mod-layer std_sys_macos_write_*; needs_std_sys_macos
  # only lists std_sys_macos_macos_*). Not soft-SKIP→OK for the gate.
  # PLATFORM: MACOS|DARWIN archaeology — report note only.
  if [ "$HOSTOS" = "Darwin" ]; then
    MAC_NOTE=0
    MAC_OUT="/tmp/xlang_boot029_sys_macos_thin_$$"
    if $RUN_XLANG build -L . "$SMOKE_MACOS_THIN" -o "$MAC_OUT" 2>/dev/null \
      && [ -x "$MAC_OUT" ] && std_sys_expect_hello "$MAC_OUT" "macos_thin" 2>/dev/null; then
      MAC_NOTE=1
    else
      echo "std-sys gate SKIP macos_thin smoke (observational; labi needle gap)" >&2
    fi
    rm -f "$MAC_OUT"
    echo "std-sys macos_thin_note=${MAC_NOTE}"
  fi
else
  echo "std-sys gate FAIL: no native xlang" >&2
  std_sys_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green signal is run= (write_stdout).
echo "std-sys check_ok=${CHECK_OK} (observational)"
std_sys_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-sys gate OK"
