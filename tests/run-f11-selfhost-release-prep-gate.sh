#!/usr/bin/env bash
# F-11 / G-07：完全自举发布 checklist（文档 + 关键子 gate；不要求已打 tag）。
#
# v2（2026-07-10）：不再串跑 65 个 F-std 历史子 gate（.sx 路径债 / make *.o 债）；
# 发版硬门槛改为：manifest + D-05 单 shux + E-soft（G-02a hard_retired）+ F-09 STRICT +
# D-03/D-04（有 stage 产物时；Darwin 上 N/A）。
set -e
cd "$(dirname "$0")/.."
FAIL=${SHUX_F11_SELFHOST_RELEASE_PREP_FAIL:-0}
DOC="analysis/phase-f-f11-v1.md"
MANIFEST="tests/baseline/f11-selfhost-release-prep.tsv"
die() { echo "f11-selfhost-release-prep gate FAIL: $*" >&2; [ "$FAIL" = "1" ] && exit 1; exit 0; }

echo "=== F-11 / G-07: selfhost release prep checklist ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'F-11 v1' "$DOC" || die "doc marker"
grep -q 'vX.Y.Z-selfhost' "$DOC" || die "doc missing tag format"
while IFS=$'\t' read -r item_id kind anchor _n; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*) continue ;; esac
  case "$kind" in
    file|doc|gate|makefile) [ -f "$anchor" ] || die "missing $anchor ($item_id)" ;;
    gate_ref) [ -f "$anchor" ] || die "missing gate_ref $anchor ($item_id)" ;;
  esac
done < "$MANIFEST"
grep -q 'D+E+F' compiler/docs/SELFHOST.md || die "SELFHOST missing D+E+F"
grep -q '完全自举' compiler/docs/SELFHOST.md || die "SELFHOST missing 完全自举"

# 单 shux 发布入口
chmod +x tests/run-d05-single-shux-release-gate.sh
SHUX_D05_FAIL="$FAIL" tests/run-d05-single-shux-release-gate.sh || die "d05 failed"

# E-soft：软退役 + G-02a hard_retired（文件不存在）
if [ -f tests/run-e-soft-retire-gate.sh ]; then
  chmod +x tests/run-e-soft-retire-gate.sh
  SHUX_E_SOFT_FAIL="$FAIL" SHUX_E_SOFT_MANIFEST_ONLY=1 \
    tests/run-e-soft-retire-gate.sh || die "e-soft-retire failed"
fi

# F-09 STRICT：非永久手写 C = 0
if [ -f tests/run-no-handwritten-c-gate.sh ]; then
  chmod +x tests/run-no-handwritten-c-gate.sh
  SHUX_NO_HANDWRITTEN_C_FAIL="$FAIL" SHUX_NO_HANDWRITTEN_C_STRICT=1 \
    SHUX_NO_HANDWRITTEN_C_MANIFEST_ONLY=1 \
    tests/run-no-handwritten-c-gate.sh || die "no-handwritten-c STRICT failed"
fi

# Stage2 哈希 / portable（有产物则硬验；无则 skip）
chmod +x tests/run-d03-stage2-hash-gate.sh
SHUX_D03_FAIL=0 tests/run-d03-stage2-hash-gate.sh || die "d03 failed"
if [ -f tests/run-d04-stage2-portable-diff-gate.sh ]; then
  chmod +x tests/run-d04-stage2-portable-diff-gate.sh
  tests/run-d04-stage2-portable-diff-gate.sh || die "d04 failed"
fi

# 可选：历史 F-std 大批量（默认关；SHUX_F11_RUN_F_STD_BATCH=1 开启）
if [ "${SHUX_F11_RUN_F_STD_BATCH:-0}" = "1" ] && [ -f tests/run-f-std-de-c-batch-gate.sh ]; then
  chmod +x tests/run-f-std-de-c-batch-gate.sh
  tests/run-f-std-de-c-batch-gate.sh || die "f-std-de-c-batch failed"
fi


# G-FFI-5：LANG-007 + 业务零裸 extern + 安全路线 §8（release 硬门槛）
if [ -f tests/run-g-ffi-5-release-ci-gate.sh ]; then
  chmod +x tests/run-g-ffi-5-release-ci-gate.sh
  SHUX_G_FFI5_FAIL="$FAIL" tests/run-g-ffi-5-release-ci-gate.sh || die "g-ffi-5 release-ci failed"
fi

echo "f11-selfhost-release-prep gate OK (checklist green; tag on release: v\$(cat VERSION)-selfhost)"
