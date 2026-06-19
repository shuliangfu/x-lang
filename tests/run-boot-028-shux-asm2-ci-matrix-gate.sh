#!/usr/bin/env bash
# BOOT-028：parser C6 shux_asm2 CI 矩阵门禁
#
# 用法：./tests/run-boot-028-shux-asm2-ci-matrix-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_BOOT028_DOC:-analysis/boot-028-shux-asm2-ci-matrix-v1.md}"
MANIFEST="${SHUX_BOOT028_TSV:-tests/baseline/boot-028-shux-asm2-ci-matrix.tsv}"
WAVE="${SHUX_BOOT028_WAVE_TSV:-tests/baseline/shux-asm2-ci-matrix-wave.tsv}"
PLAT_MATRIX="${SHUX_BOOT028_PLAT_TSV:-tests/baseline/shux-asm2-ci-platform-matrix.tsv}"
CI_MATRIX="tests/baseline/ci-platform-matrix.tsv"
MATRIX="tests/baseline/comp-parser-mega7-matrix.tsv"
REPRO="tests/baseline/bootstrap-repro.tsv"
LIB="tests/lib/boot-028-shux-asm2-ci-matrix.sh"
MIN_HOOKS=4
MIN_ROWS=4
MIN_LINUX_MUST=1
MIN_MACOS_MUST=1

# shellcheck source=tests/lib/boot-028-shux-asm2-ci-matrix.sh
. "$LIB"

echo "=== BOOT-028: shux_asm2 CI matrix manifest ==="
for f in "$DOC" "$MANIFEST" "$WAVE" "$PLAT_MATRIX" "$LIB" "$MATRIX" "$REPRO" "$CI_MATRIX" \
  tests/run-shux-asm2-cross-smoke.sh \
  tests/run-boot-027-shux-asm2-cross-gate.sh \
  tests/run-bootstrap-crossplatform-gate.sh \
  tests/run-eng-crossplatform-ci-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "boot-028-shux-asm2-ci-matrix gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_c6_hooks) MIN_HOOKS="$c2" ;;
    min_wave_rows) MIN_ROWS="$c2" ;;
    min_linux_must) MIN_LINUX_MUST="$c2" ;;
    min_macos_must) MIN_MACOS_MUST="$c2" ;;
  esac
done < "$MANIFEST"

for kw in c6_matrix_ok c6_smoke boot028_shux_asm2_ci_matrix shux_asm2_ci_target; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "boot-028-shux-asm2-ci-matrix gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'boot028_shux_asm2_ci_matrix' "$REPRO" 2>/dev/null; then
  echo "boot-028-shux-asm2-ci-matrix gate FAIL: bootstrap-repro missing boot028" >&2
  exit 1
fi

# ci-platform-matrix 须含 linux + mac job（ENG-003 双平台 CI）
for req in linux mac; do
  if ! awk -F'\t' -v j="$req" '$3==j && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CI_MATRIX"; then
    echo "boot-028 FAIL: ci-platform-matrix missing job $req" >&2
    exit 1
  fi
done

ROW_N=0
MISS=0
echo "=== BOOT-028: C6 CI wave rows ==="
while IFS=$'\t' read -r c6_id hook _role _notes; do
  [ -z "${c6_id:-}" ] && continue
  case "$c6_id" in \#*|min_*) continue ;; esac
  ROW_N=$((ROW_N + 1))
  if ! grep -qF "$c6_id" "$DOC" 2>/dev/null; then
    echo "boot-028 FAIL: doc missing $c6_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "tests/$hook" ]; then
    echo "boot-028 FAIL: missing tests/$hook" >&2
    MISS=$((MISS + 1))
  else
    echo "boot-028 OK $c6_id -> $hook"
  fi
done < "$WAVE"

if [ "$ROW_N" -lt "$MIN_ROWS" ]; then
  echo "boot-028-shux-asm2-ci-matrix gate FAIL: rows=${ROW_N} < min ${MIN_ROWS}" >&2
  exit 1
fi

HOOK_N=0
while IFS=$'\t' read -r item_id kind anchor _target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    hook_gate|hook_ref)
      HOOK_N=$((HOOK_N + 1))
      if [ ! -f "tests/$anchor" ]; then
        echo "boot-028 FAIL: manifest missing tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$HOOK_N" -lt "$MIN_HOOKS" ]; then
  echo "boot-028-shux-asm2-ci-matrix gate FAIL: hooks=${HOOK_N} < min ${MIN_HOOKS}" >&2
  exit 1
fi

LINUX_M=0
MACOS_M=0
while IFS=$'\t' read -r case_id script linux_p macos_p _win_p _pat _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  if [ ! -f "tests/$script" ]; then
    echo "boot-028 FAIL: platform matrix missing tests/$script" >&2
    MISS=$((MISS + 1))
  fi
  [ "$linux_p" = "must" ] && LINUX_M=$((LINUX_M + 1))
  [ "$macos_p" = "must" ] && MACOS_M=$((MACOS_M + 1))
done < "$PLAT_MATRIX"

if [ "$LINUX_M" -lt "$MIN_LINUX_MUST" ]; then
  echo "boot-028 FAIL: linux_must=${LINUX_M} < ${MIN_LINUX_MUST}" >&2
  MISS=$((MISS + 1))
fi
if [ "$MACOS_M" -lt "$MIN_MACOS_MUST" ]; then
  echo "boot-028 FAIL: macos_must=${MACOS_M} < ${MIN_MACOS_MUST}" >&2
  MISS=$((MISS + 1))
fi

if ! grep -F 'C7_shux_asm2_ci_matrix' "$MATRIX" 2>/dev/null | grep -qF 'run-boot-028-shux-asm2-ci-matrix-gate.sh'; then
  echo "boot-028 FAIL: C7_shux_asm2_ci_matrix not wired to boot-028 gate" >&2
  MISS=$((MISS + 1))
fi

if [ "$MISS" -gt 0 ]; then
  boot028_emit_report "fail" 0 0 0
  exit 1
fi
echo "boot-028-shux-asm2-ci-matrix manifest OK (rows=${ROW_N} hooks=${HOOK_N} linux_must=${LINUX_M} macos_must=${MACOS_M})"

echo "=== BOOT-028: parent BOOT-027 manifest ==="
chmod +x tests/run-boot-027-shux-asm2-cross-gate.sh
SHUX_BOOT027_MANIFEST_ONLY=1 ./tests/run-boot-027-shux-asm2-cross-gate.sh

if [ "${SHUX_BOOT028_MANIFEST_ONLY:-0}" = "1" ]; then
  boot028_emit_report "ok" 0 0 1
  echo "boot-028-shux-asm2-ci-matrix gate OK (manifest only)"
  exit 0
fi

PLAT="$(boot028_current_platform)"
MUST_OK=0
MAN_OK=0
FAILS=0
C6_SMOKE=0
SMOKE_LOG=""

echo "=== BOOT-028: platform matrix host=${PLAT} ==="
while IFS=$'\t' read -r case_id script linux_p macos_p win_p ok_pat _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  pol="$(boot028_row_policy "$linux_p" "$macos_p" "$win_p")"
  case "$pol" in
    skip)
      echo "boot-028 SKIP $case_id (policy skip on ${PLAT})"
      continue
    ;;
  esac

  script_path="tests/$script"
  chmod +x "$script_path" 2>/dev/null || true
  log="/tmp/boot028_${case_id}_$$.log"
  extra_env=()
  if [ "$case_id" = "boot027_parent" ]; then
    extra_env=(SHUX_BOOT027_MANIFEST_ONLY=1)
  fi
  set +e
  env "${extra_env[@]}" "$script_path" >"$log" 2>&1
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    echo "boot-028 FAIL $case_id: exit=$ec" >&2
    tail -15 "$log" >&2
    FAILS=$((FAILS + 1))
    rm -f "$log"
    continue
  fi
  if ! grep -qE "$ok_pat" "$log"; then
    echo "boot-028 FAIL $case_id: output mismatch (want /${ok_pat}/)" >&2
    tail -10 "$log" >&2
    FAILS=$((FAILS + 1))
    rm -f "$log"
    continue
  fi

  if [ "$case_id" = "shux_asm2_cross_smoke" ]; then
    SMOKE_LOG="$log"
    C6_SMOKE="$(boot028_parse_smoke_log "$log")"
  fi

  case "$pol" in
    must) MUST_OK=$((MUST_OK + 1)); echo "boot-028 OK $case_id (must)" ;;
    manifest) MAN_OK=$((MAN_OK + 1)); echo "boot-028 OK $case_id (manifest)" ;;
  esac
  rm -f "$log"
done < "$PLAT_MATRIX"

if [ "$FAILS" -gt 0 ]; then
  boot028_emit_report "fail" 0 "$C6_SMOKE" 0
  exit 1
fi

C6_MATRIX_OK=0
if [ "$MUST_OK" -gt 0 ] || [ "$MAN_OK" -gt 0 ]; then
  C6_MATRIX_OK=1
fi

SKIP=0
if [ -n "$SMOKE_LOG" ] && grep -qF 'shux-asm2-cross-smoke SKIP' "$SMOKE_LOG" 2>/dev/null; then
  SKIP=1
fi

boot028_emit_report "ok" "$C6_MATRIX_OK" "$C6_SMOKE" "$SKIP"
echo "boot-028-shux-asm2-ci-matrix gate OK"
