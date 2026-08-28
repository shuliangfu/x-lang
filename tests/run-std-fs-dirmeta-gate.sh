#!/usr/bin/env bash
# STD-123: std.fs directory/metadata API gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c / soft ensure). Product
# dirmeta_roundtrip.x -o exit0 = hard run (run=1). check / C smoke = obs.
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-fs-dirmeta-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
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

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-fs-dirmeta gate FAIL: $*" >&2
  std_fs_dirmeta_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; refuse soft auto-make / prefer-c.
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-fs-dirmeta-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-123: std.fs dir/meta manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$FS_IMPL" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

# F-03 v2: host C fs.c must stay deleted. Formal product std/fs/fs.o (from
# mod.x+posix.x via xlang_compile_std_fs_formal.sh / LABI_STD_OP_STD) is the
# on-demand object name — do NOT ban its presence (that conflates deleted C
# with the formal .o path and false-reds after product smoke).
# PLATFORM: SHARED — dual-authority ban is on fs.c only; posix.x is authority.
[ ! -f std/fs/fs.c ] || die "fs.c should be deleted (F-03 v2)"

for kw in STD-123 dir_open stat; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

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

sym_miss="$(std_fs_dirmeta_symbols_ok "$MOD_X" "$FS_IMPL" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-fs-dirmeta manifest OK"

if [ "${XLANG_STD_FS_DIRMETA_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_fs_dirmeta_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-fs-dirmeta gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-123: smoke (XLANG=$XLANG_BIN; check/C obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std123_dirmeta_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-fs-dirmeta OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make / soft ensure (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_fs_dirmeta_run_x_smoke "$XLANG_BIN" "$SMOKE_X"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-fs-dirmeta OK: product -o"
else
  die "dirmeta_roundtrip.x exit!=0 (refuse soft SKIP→OK)"
fi

# Observational C smoke (existing posix.o only; never soft rebuild).
# PLATFORM: SHARED — archaeology; .x runnable is the hard signal.
if [ -f "$SMOKE_C" ]; then
  if [ -f std/fs/posix.o ] && std_fs_dirmeta_run_c_smoke std/fs/posix.o; then
    echo "std-fs-dirmeta OK smoke_c (observational)"
  else
    echo "std-fs-dirmeta OBS c smoke (existing .o only / no soft ensure)" >&2
    OBS=$((OBS + 1))
  fi
fi

std_fs_dirmeta_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-fs-dirmeta gate OK"
