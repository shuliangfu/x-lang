#!/usr/bin/env bash
# Shux 硬切验收：禁止 .su / Shulang / shu-c / SHU_ 等遗留品牌（§12、§13）。
# 合法名：Shux、.sx、compiler/shux、shux-c、SX 流水线 gate（run-all-sx 等）。
# 纳入 run-all；失败即 exit 1。

set -e
cd "$(dirname "$0")/.."

fail=0
note() { echo "run-no-legacy-shux-gate: $*"; }
bad() { note "FAIL: $*"; fail=1; }

# 1) 源文件后缀：仅 .sx
su_files=$(find . -name '*.su' -not -path './.git/*' 2>/dev/null | head -20)
if [ -n "$su_files" ]; then
  bad "found .su files (expect 0):"
  echo "$su_files" | sed 's/^/  /'
fi

# 2) 旧 CLI 二进制名（Shulang 时代 shu/shu-c；勿与 compiler/shux 混淆）
for legacy_bin in compiler/shu compiler/shu-c; do
  if [ -e "$legacy_bin" ]; then
    bad "legacy binary still exists: $legacy_bin"
  fi
done

# 3) 级联误替换 / 旧 env 名（排除本 gate）
if rg -q 'SHUXX_' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts tools editors 2>/dev/null; then
  bad "SHUXX typo remains (use SHUX)"
  rg -n 'SHUXX_' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts tools editors 2>/dev/null | head -10 | sed 's/^/  /'
fi

# 4) 硬切禁止：Shulang / shu-c / 旧路径 / boot-*-shu-（合法 shux / shux-c 不在此列）
scan_dirs=(compiler core std tests scripts tools editors)
if rg -q 'SHULANG_|\bshu-c\b|/compiler/shu\b|boot-[0-9]+-shu-' \
  --glob '!tests/run-no-legacy-shux-gate.sh' --glob '!editors/vscode/package-lock.json' \
  "${scan_dirs[@]}" 2>/dev/null; then
  bad "legacy Shulang/shu paths in scan tree"
  rg -n 'SHULANG_|\bshu-c\b|/compiler/shu\b|boot-[0-9]+-shu-' \
    --glob '!tests/run-no-legacy-shux-gate.sh' --glob '!editors/vscode/package-lock.json' \
    "${scan_dirs[@]}" 2>/dev/null | head -20 | sed 's/^/  /'
fi

# 5) shux-c / shux 为合法名；禁止 shuxxx 级联
if rg -q 'shux{3,}' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts 2>/dev/null; then
  bad "shux cascade typo (shuxxx+)"
  rg -n 'shux{3,}' compiler tests scripts 2>/dev/null | head -10 | sed 's/^/  /'
fi

# 6) 旧 IO/async ABI（shu_io_ / __shu_frame / shu_async_）；排除生成 C、baseline、命名规范文档
  if rg -q '\bshu_io_|\b__shu_frame\b|\bshu_async_' \
  --glob '!*_gen*.c' --glob '!*.base' --glob '!tests/baseline/*' --glob '!tests/run-no-legacy-shux-gate.sh' \
  --glob '!std/标准库api命名规范.md' --glob '!core/核心库api命名规范.md' \
  --glob '!std/async/mod.sx' --glob '!compiler/src/asm/runtime_scheduler_glue.c' \
  compiler core std tests scripts tools editors 2>/dev/null; then
  bad "legacy shu_io / __shu_frame / shu_async ABI names remain (non-doc)"
  rg -n '\bshu_io_|\b__shu_frame\b|\bshu_async_' \
    --glob '!*_gen*.c' --glob '!*.base' --glob '!tests/baseline/*' --glob '!tests/run-no-legacy-shux-gate.sh' \
    --glob '!std/标准库api命名规范.md' --glob '!core/核心库api命名规范.md' \
    --glob '!std/async/mod.sx' --glob '!compiler/src/asm/runtime_scheduler_glue.c' \
    compiler core std tests scripts tools editors 2>/dev/null | head -20 | sed 's/^/  /'
fi

# 7) VS Code 扩展：禁止旧 grammar su.tmLanguage（vscode-shux 包名为合法 Shux 扩展）
if rg -q 'su\.tmLanguage|snippets/su\.json' \
  --glob '!tests/run-no-legacy-shux-gate.sh' \
  editors 2>/dev/null; then
  bad "legacy su.tmLanguage / snippets/su.json in editors/"
  rg -n 'su\.tmLanguage|snippets/su\.json' editors 2>/dev/null | head -10 | sed 's/^/  /'
fi
if [ -f editors/vscode/grammars/su.tmLanguage.json ] || [ -f editors/vscode/snippets/su.json ]; then
  bad "legacy su.tmLanguage.json or snippets/su.json still on disk"
fi

# 8) 旧 SU 流水线路径（SU→SX 后应不存在 su-pipeline / run-all-su 等）
legacy_test_paths=(
  tests/run-all-su.sh
  tests/run-parser-su-strict-gate.sh
  tests/run-migrate-su-gen-gate.sh
  tests/su-pipeline
  compiler/tests/su-pipeline
)
for p in "${legacy_test_paths[@]}"; do
  if [ -e "$p" ]; then
    bad "legacy SU test path still exists: $p"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "run-no-legacy-shux-gate: FAILED" >&2
  exit 1
fi
note "OK (no .su / no legacy Shulang paths in scan tree)"
exit 0
