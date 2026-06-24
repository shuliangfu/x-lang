#!/usr/bin/env bash
# Shux 硬切验收：禁止 .su / shu / shux / SHU_ 等遗留品牌与后缀（§12、§13）。
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

# 2) 旧 CLI 二进制名（生产路径）
for legacy_bin in compiler/shu compiler/shu-c compiler/shux; do
  if [ -e "$legacy_bin" ]; then
    bad "legacy binary still exists: $legacy_bin"
  fi
done

# 3) 级联误替换 / 旧 env 名（排除本 gate）
if rg -q 'SHUXX_' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts tools editors 2>/dev/null; then
  bad "SHUXX typo remains (use SHUX)"
  rg -n 'SHUXX_' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts tools editors 2>/dev/null | head -10 | sed 's/^/  /'
fi

# 4) 硬切禁止：路径/脚本中的 shu-asm、vscode-shux 等
scan_dirs=(compiler core std tests scripts tools editors)
if rg -q '\bshux\b|SHULANG_|\bshu-c\b|/compiler/shu\b|boot-[0-9]+-shu-' \
  --glob '!tests/run-no-legacy-shux-gate.sh' --glob '!editors/vscode/package-lock.json' \
  "${scan_dirs[@]}" 2>/dev/null; then
  bad "legacy shu/shux references in scan tree"
  rg -n '\bshux\b|SHULANG_|\bshu-c\b|/compiler/shu\b|boot-[0-9]+-shu-' \
    --glob '!tests/run-no-legacy-shux-gate.sh' --glob '!editors/vscode/package-lock.json' \
    "${scan_dirs[@]}" 2>/dev/null | head -20 | sed 's/^/  /'
fi

# 5) shux-c / shux 为合法名；禁止 shuxxx 级联
if rg -q 'shux{3,}' --glob '!tests/run-no-legacy-shux-gate.sh' compiler tests scripts 2>/dev/null; then
  bad "shux cascade typo (shuxxx+)"
  rg -n 'shux{3,}' compiler tests scripts 2>/dev/null | head -10 | sed 's/^/  /'
fi

# 6) 旧 IO/async ABI（shu_io_ / __shu_frame / shu_async_）；排除生成 C 与 baseline
if rg -q '\bshu_io_|\b__shu_frame\b|\bshu_async_' \
  --glob '!*_gen*.c' --glob '!*.base' --glob '!tests/baseline/*' --glob '!tests/run-no-legacy-shux-gate.sh' \
  compiler core std tests scripts tools editors 2>/dev/null; then
  bad "legacy shu_io / __shu_frame / shu_async ABI names remain"
  rg -n '\bshu_io_|\b__shu_frame\b|\bshu_async_' \
    --glob '!*_gen*.c' --glob '!*.base' --glob '!tests/baseline/*' --glob '!tests/run-no-legacy-shux-gate.sh' \
    compiler core std tests scripts tools editors 2>/dev/null | head -20 | sed 's/^/  /'
fi

# 7) VS Code 扩展：禁止 vscode-shux / 旧 grammar su.tmLanguage
if rg -q 'vscode-shux|su\.tmLanguage|snippets/su\.json' \
  --glob '!tests/run-no-legacy-shux-gate.sh' \
  editors 2>/dev/null; then
  bad "legacy vscode-shux / su.tmLanguage in editors/"
  rg -n 'vscode-shux|su\.tmLanguage|snippets/su\.json' editors 2>/dev/null | head -10 | sed 's/^/  /'
fi
if [ -f editors/vscode/grammars/su.tmLanguage.json ] || [ -f editors/vscode/snippets/su.json ]; then
  bad "legacy su.tmLanguage.json or snippets/su.json still on disk"
fi

# 8) 测试脚本/目录名：禁止 run-*-sx-*、tests/sx-pipeline（迁移扫尾）
legacy_test_paths=(
  tests/run-all-sx.sh
  tests/run-parser-sx-strict-gate.sh
  tests/run-migrate-sx-gen-gate.sh
  tests/run-parser-parse-bootstrap-sx-emit-gate.sh
  tests/sx-pipeline
)
for p in "${legacy_test_paths[@]}"; do
  if [ -e "$p" ]; then
    bad "legacy test path still exists: $p"
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "run-no-legacy-shux-gate: FAILED" >&2
  exit 1
fi
note "OK (no .su / no legacy shu paths in scan tree)"
exit 0
