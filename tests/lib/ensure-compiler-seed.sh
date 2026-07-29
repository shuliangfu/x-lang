#!/usr/bin/env bash
# 门禁脚本共用：仅保证 seed xlang 存在。
# 勿跑 make all（C-only 会覆盖 xlang_asm 门禁前提）；缺 seed 时只跑 bootstrap-driver-seed。
# 用法：在仓库根目录 source tests/lib/ensure-compiler-seed.sh
# wave728 · 11.2.3: bootstrap via tests/lib/compiler-make.sh (G.7 single path).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
if [ ! -x compiler/xlang ]; then
  xlang_compiler_make bootstrap-driver-seed
fi
