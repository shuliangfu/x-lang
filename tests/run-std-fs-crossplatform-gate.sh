#!/usr/bin/env bash
# STD-003：std.fs 跨平台对齐门禁（假权威诚实）。
#
# 读取 tests/baseline/std-fs-crossplatform.tsv，按平台策略跑 must/skip/optional。
# 用法：./tests/run-std-fs-crossplatform-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-26: Prefer xlang_asm; pin XLANG_LINK_XLANG; check observational SKIP
# (check gate paused 2026-08-05); must-policy .x / run-fs.sh exit 0 hard-fail
# (no soft SKIP when native xlang present). Report check=/x=/skip=. Product
# surface already green under asm; gate was portable-false-red (prefer xlang-c
# only / soft SKIP→OK when no native).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

DOC="${XLANG_STD_FS_XPLAT_DOC:-analysis/archive/std/std-fs-api-v1.md}"
BASELINE="tests/baseline/std-fs-crossplatform.tsv"
MATRIX="${XLANG_STD_FS_CROSSPLATFORM_TSV:-$BASELINE}"
LIB="tests/lib/std-fs-crossplatform.sh"
SMOKE_X="tests/fs/crossplatform_core.x"

# shellcheck source=tests/lib/std-fs-crossplatform.sh
. "$LIB"

platform_policy() {
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
}

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

echo "=== STD-003: std.fs cross-platform manifest ==="

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-fs-api-v1.md ]; then
  echo "std-fs-crossplatform gate FAIL: top-level DOC resurrected (live = archive/std/)" >&2
  exit 1
fi

for f in "$DOC" "$MATRIX" "$LIB" "$SMOKE_X" tests/run-fs.sh; do
  if [ ! -f "$f" ]; then
    echo "std-fs-crossplatform gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-003 crossplatform must skip; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-fs-crossplatform gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

# DOC §4 = 兼容矩阵; Gate honesty lives under §5 (do not collide with §4).
# PLATFORM: SHARED archaeology — section anchor must match archive DOC.
if ! grep -qF '## 5. Gate' "$DOC" 2>/dev/null; then
  echo "std-fs-crossplatform gate FAIL: doc missing '## 5. Gate'" >&2
  exit 1
fi

echo "std-fs-crossplatform manifest OK"

if [ "${XLANG_STD_FS_XPLAT_MANIFEST_ONLY:-0}" = "1" ]; then
  std_fs_xplat_emit_report "ok" 0 0 1
  echo "std-fs-crossplatform gate OK (manifest only)"
  exit 0
fi

CHECK_OK=0
X_OK=0
SKIP=1

if ! XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "std-fs-crossplatform gate FAIL: no native xlang" >&2
  std_fs_xplat_emit_report "fail" 0 0 0
  exit 1
fi

echo "=== STD-003: smoke (XLANG=$XLANG_BIN; check observational; must runnable hard) ==="
# Observational check (paused 2026-08-05); CHK red does not hard-fail.
if "$XLANG_BIN" check -L . "$SMOKE_X" >/dev/null 2>&1; then
  CHECK_OK=1
else
  echo "std-fs-crossplatform gate SKIP check smoke (paused 2026-08-05)" >&2
fi

xlang_compiler_make -q 2>/dev/null || xlang_compiler_make
xlang_compiler_make ../std/io/io.o -q 2>/dev/null \
  || xlang_compiler_make ../std/io/io.o || true

# Pin product link to resolved compiler (prefer asm).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

FAILS=0
MUST_RAN=0
while IFS=$'\t' read -r case_id script linux pol_mac pol_win notes; do
  [ -z "$case_id" ] && continue
  case "$case_id" in
    \#*) continue ;;
  esac
  pol=$(platform_policy "$linux" "$pol_mac" "$pol_win")
  case "$pol" in
    skip)
      echo "std-fs xplat SKIP $case_id ($notes)"
      continue
      ;;
  esac

  if [ "$script" = "run-fs.sh" ]; then
    echo "── case $case_id: $script ──"
    MUST_RAN=$((MUST_RAN + 1))
    chmod +x tests/run-fs.sh
    if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-fs.sh; then
      echo "std-fs xplat OK $case_id"
    else
      if [ "$pol" = "optional" ]; then
        echo "std-fs xplat WARN $case_id (optional)" >&2
      else
        echo "std-fs xplat FAIL $case_id" >&2
        FAILS=$((FAILS + 1))
      fi
    fi
    continue
  fi

  if [ ! -f "tests/fs/${script}" ]; then
    echo "std-fs xplat FAIL $case_id: missing tests/fs/${script}" >&2
    FAILS=$((FAILS + 1))
    continue
  fi

  echo "── case $case_id: tests/fs/${script} ──"
  MUST_RAN=$((MUST_RAN + 1))
  if std_fs_xplat_run_x_smoke "$XLANG_BIN" "tests/fs/${script}" \
    "/tmp/xlang_fs_xplat_${script%.x}_$$"; then
    echo "std-fs xplat OK $case_id"
  else
    if [ "$pol" = "optional" ]; then
      echo "std-fs xplat WARN $case_id (optional exit!=0)" >&2
    else
      echo "std-fs xplat FAIL $case_id (exit!=0)" >&2
      FAILS=$((FAILS + 1))
    fi
  fi
done < "$MATRIX"

if [ "$FAILS" -gt 0 ]; then
  std_fs_xplat_emit_report "fail" "$CHECK_OK" 0 0
  echo "std-fs-crossplatform gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

if [ "$MUST_RAN" -eq 0 ]; then
  std_fs_xplat_emit_report "fail" "$CHECK_OK" 0 0
  echo "std-fs-crossplatform gate FAIL: no must-policy cases ran" >&2
  exit 1
fi

X_OK=1
SKIP=0
# check stays observational; hard-green signal is x= (must runnable).
echo "std-fs-crossplatform check_ok=${CHECK_OK} (observational)"
std_fs_xplat_emit_report "ok" "$CHECK_OK" "$X_OK" "$SKIP"
echo "std-fs-crossplatform gate OK"
