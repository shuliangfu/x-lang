#!/usr/bin/env bash
# STD-123: std.fs directory/metadata API gate (false-authority honesty).
#
# Usage: ./tests/run-std-fs-dirmeta-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); dirmeta_roundtrip.x exit 0 hard-fail (no soft
# SKIP when native xlang present). C smoke observational. Report
# check=/run=/skip=. Product smoke already green under asm on Ubuntu; Darwin
# was red only because posix.x DIRENT_D_NAME_OFF hardcoded Linux 19 (Darwin=21)
# — root-fixed same wave. Gate was portable-false-red (prefer xlang-c / hard
# check / soft SKIP→OK when no native).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_FS_DIRMETA_DOC:-analysis/archive/std/std-fs-dirmeta-v1.md}"
MANIFEST="${XLANG_STD_FS_DIRMETA_TSV:-tests/baseline/std-fs-dirmeta-manifest.tsv}"
MOD_X="std/fs/mod.x"
FS_IMPL="std/fs/posix.x"
LIB="tests/lib/std-fs-dirmeta.sh"
SMOKE_X="tests/fs/dirmeta_roundtrip.x"
SMOKE_C="tests/fs/dirmeta_smoke_ok.c"
MIN_APIS=10

# shellcheck source=tests/lib/std-fs-dirmeta.sh
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
std_fs_dirmeta_resolve_shu() {
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-fs-dirmeta-v1.md ]; then
  echo "std-fs-dirmeta gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

echo "=== STD-123: std.fs dir/meta manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$FS_IMPL" "$SMOKE_X"; do
  if [ ! -f "$f" ]; then
    echo "std-fs-dirmeta gate FAIL: missing $f" >&2
    exit 1
  fi
done

# F-03 v2: host C fs.c must stay deleted. Formal product std/fs/fs.o (from
# mod.x+posix.x via xlang_compile_std_fs_formal.sh / LABI_STD_OP_STD) is the
# on-demand object name — do NOT ban its presence (that conflates deleted C
# with the formal .o path and false-reds after product smoke).
# PLATFORM: SHARED — dual-authority ban is on fs.c only; posix.x is authority.
[ ! -f std/fs/fs.c ] || {
  echo "std-fs-dirmeta gate FAIL: fs.c should be deleted (F-03 v2)" >&2
  exit 1
}

for kw in STD-123 dir_open stat; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-fs-dirmeta gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF '## 3. Gate' "$DOC" 2>/dev/null; then
  echo "std-fs-dirmeta gate FAIL: doc missing '## 3. Gate'" >&2
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
        echo "std-fs-dirmeta gate FAIL: missing api $anchor" >&2
        exit 1
      fi
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-fs-dirmeta gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-fs-dirmeta gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_fs_dirmeta_symbols_ok "$MOD_X" "$FS_IMPL" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_fs_dirmeta_emit_report "fail" 0 0 0
  echo "std-fs-dirmeta gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-fs-dirmeta manifest OK"

CHECK_OK=0
RUN_OK=0
SKIP=1

if XLANG_BIN="$(std_fs_dirmeta_resolve_shu 2>/dev/null)"; then
  echo "=== STD-123: smoke (XLANG=$XLANG_BIN; check observational; .x runnable hard) ==="
  # Observational check (paused 2026-08-05); CHK red does not hard-fail.
  if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-fs-dirmeta gate SKIP check smoke (paused 2026-08-05)" >&2
  fi

  xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  echo "── smoke_x ──"
  if std_fs_dirmeta_run_x_smoke "$XLANG_BIN" "$SMOKE_X"; then
    RUN_OK=1
    echo "std-fs-dirmeta OK smoke_x"
  else
    std_fs_dirmeta_emit_report "fail" "$CHECK_OK" 0 0
    echo "std-fs-dirmeta gate FAIL: dirmeta_roundtrip.x exit!=0" >&2
    exit 1
  fi

  # Observational C smoke (seed/host fs.o path; never hard-green this wave).
  # PLATFORM: SHARED — archaeology; .x runnable is the hard signal.
  if [ -f "$SMOKE_C" ]; then
    echo "── smoke_c (observational) ──"
    if [ -f std/fs/posix.o ] && std_fs_dirmeta_run_c_smoke std/fs/posix.o; then
      echo "std-fs-dirmeta OK smoke_c (observational)"
    else
      echo "std-fs-dirmeta gate SKIP c smoke (observational)" >&2
    fi
  fi

  SKIP=0
else
  echo "std-fs-dirmeta gate FAIL: no native xlang" >&2
  std_fs_dirmeta_emit_report "fail" 0 0 0
  exit 1
fi

# check stays observational; hard-green = run= (.x exit0).
echo "std-fs-dirmeta check_ok=${CHECK_OK} (observational)"
std_fs_dirmeta_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-fs-dirmeta gate OK"
