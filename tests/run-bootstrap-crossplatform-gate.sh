#!/usr/bin/env bash
# BOOT-011：自举链路跨平台基线门禁 + 宿主报告
#
# 读取 bootstrap-crossplatform-matrix.tsv，按 linux/macos/windows 策略跑 gate，
# 输出当前平台稳定报告摘要。
#
# 用法：./tests/run-bootstrap-crossplatform-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_BOOT_CROSSPLATFORM_TSV:-tests/baseline/bootstrap-crossplatform-matrix.tsv}"
CI_MATRIX="${SHU_CI_PLATFORM_MATRIX:-tests/baseline/ci-platform-matrix.tsv}"
MIN_LINUX_MUST=4
MIN_MACOS_MUST=3
MIN_MANIFEST=4

# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

current_platform() {
  if ci_is_linux; then
    echo linux
  elif ci_is_darwin; then
    echo macos
  elif ci_is_windows_msys; then
    echo windows
  else
    echo unknown
  fi
}

# 读取矩阵列策略（linux/macos/windows）→ 当前宿主策略
row_policy() {
  local linux_p="$1"
  local macos_p="$2"
  local win_p="$3"
  case "$(current_platform)" in
    linux) echo "$linux_p" ;;
    macos) echo "$macos_p" ;;
    windows) echo "$win_p" ;;
    *) echo skip ;;
  esac
}

echo "=== BOOT-011: bootstrap cross-platform manifest ==="
for f in \
  analysis/boot-crossplatform-v1.md \
  analysis/eng-crossplatform-ci-v1.md \
  "$MATRIX" \
  "$CI_MATRIX"; do
  if [ ! -f "$f" ]; then
    echo "bootstrap-crossplatform gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_linux_must) MIN_LINUX_MUST="$c2" ;;
    min_macos_must) MIN_MACOS_MUST="$c2" ;;
    min_manifest_rows) MIN_MANIFEST="$c2" ;;
  esac
done < "$MATRIX"

# ci-platform-matrix 须含 linux + mac job
for req in linux mac; do
  if ! awk -F'\t' -v j="$req" '$3==j && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$CI_MATRIX"; then
    echo "bootstrap-crossplatform gate FAIL: ci-platform-matrix missing job $req" >&2
    exit 1
  fi
done

# 矩阵 gate 脚本存在 + 平台列计数
LINUX_M=0
MACOS_M=0
MANIFEST_N=0
MISS=0
while IFS=$'\t' read -r case_id script linux_p macos_p win_p _pat _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  path="tests/${script}"
  if [ ! -f "$path" ]; then
    echo "bootstrap-crossplatform FAIL: missing $path ($case_id)" >&2
    MISS=$((MISS + 1))
  fi
  [ "$linux_p" = "must" ] && LINUX_M=$((LINUX_M + 1))
  [ "$linux_p" = "linux_only" ] && LINUX_M=$((LINUX_M + 1))
  [ "$macos_p" = "must" ] && MACOS_M=$((MACOS_M + 1))
  case "$linux_p" in manifest) MANIFEST_N=$((MANIFEST_N + 1)) ;; esac
  case "$macos_p" in manifest) MANIFEST_N=$((MANIFEST_N + 1)) ;; esac
done < "$MATRIX"

if [ "$MISS" -gt 0 ]; then
  echo "bootstrap-crossplatform gate FAIL: missing scripts=${MISS}" >&2
  exit 1
fi
if [ "$LINUX_M" -lt "$MIN_LINUX_MUST" ]; then
  echo "bootstrap-crossplatform gate FAIL: linux_must+linux_only=${LINUX_M} < ${MIN_LINUX_MUST}" >&2
  exit 1
fi
if [ "$MACOS_M" -lt "$MIN_MACOS_MUST" ]; then
  echo "bootstrap-crossplatform gate FAIL: macos_must=${MACOS_M} < ${MIN_MACOS_MUST}" >&2
  exit 1
fi
echo "bootstrap-crossplatform manifest OK (linux_rows=${LINUX_M} macos_must=${MACOS_M})"

# ── 当前宿主报告 ──
PLAT="$(current_platform)"
MUST_OK=0
MUST_TOTAL=0
MAN_OK=0
MAN_TOTAL=0
SKIP_N=0
LINUX_SKIP=0
FAILS=0

echo "=== BOOT-011: report host=$(ci_host_summary) platform=${PLAT} ==="
while IFS=$'\t' read -r case_id script linux_p macos_p win_p ok_pat notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  pol="$(row_policy "$linux_p" "$macos_p" "$win_p")"
  case "$pol" in
    skip)
      SKIP_N=$((SKIP_N + 1))
      echo "bootstrap-crossplatform SKIP $case_id (policy skip on ${PLAT})"
      continue
    ;;
    linux_only)
      if [ "$PLAT" != linux ]; then
        LINUX_SKIP=$((LINUX_SKIP + 1))
        echo "bootstrap-crossplatform SKIP $case_id (linux_only on ${PLAT})"
        continue
      fi
      pol=must
    ;;
  esac

  script_path="tests/${script}"
  chmod +x "$script_path" 2>/dev/null || true
  log="/tmp/boot_xplat_${case_id}.$$.log"
  set +e
  "$script_path" >"$log" 2>&1
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    echo "bootstrap-crossplatform FAIL $case_id: exit=$ec" >&2
    tail -20 "$log" >&2
    FAILS=$((FAILS + 1))
    rm -f "$log"
    continue
  fi
  if ! grep -qE "$ok_pat" "$log"; then
    echo "bootstrap-crossplatform FAIL $case_id: output mismatch (want /${ok_pat}/)" >&2
    tail -10 "$log" >&2
    FAILS=$((FAILS + 1))
    rm -f "$log"
    continue
  fi
  rm -f "$log"

  case "$pol" in
    must)
      MUST_OK=$((MUST_OK + 1))
      MUST_TOTAL=$((MUST_TOTAL + 1))
      echo "bootstrap-crossplatform OK $case_id (must)"
      ;;
    manifest)
      MAN_OK=$((MAN_OK + 1))
      MAN_TOTAL=$((MAN_TOTAL + 1))
      echo "bootstrap-crossplatform OK $case_id (manifest)"
      ;;
  esac
done < "$MATRIX"

echo "BOOT-011 report: host=$(ci_host_summary) platform=${PLAT}"
echo "  must OK: ${MUST_OK}/${MUST_TOTAL}  manifest OK: ${MAN_OK}/${MAN_TOTAL}  policy_skip: ${SKIP_N}  linux_only_skip: ${LINUX_SKIP}"

if [ "$FAILS" -gt 0 ]; then
  echo "bootstrap-crossplatform gate FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "bootstrap-crossplatform gate OK"
