#!/usr/bin/env bash
# Cap tip leftover: true-cold wipe drops std/fs/fs.o (not rebuildable by Cap
# tip product). Rebuild formal mod+posix with LEGACY bak, Darwin ___error
# retarget, merge runtime_dir_cap pure-asm. Prefer asm; no FORCE_CC / new .c.
# PLATFORM: MACOS|DARWIN arm64 Cap tip.
# cwd: compiler/
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
out="${1:-../std/fs/fs.o}"
OC="${LLVM_OBJCOPY:-}"
[ -n "$OC" ] || { [ -x /opt/homebrew/opt/llvm/bin/llvm-objcopy ] && OC=/opt/homebrew/opt/llvm/bin/llvm-objcopy; }
[ -n "$OC" ] || { [ -x /usr/local/opt/llvm/bin/llvm-objcopy ] && OC=/usr/local/opt/llvm/bin/llvm-objcopy; }
[ -n "$OC" ] || { echo "cap_tip_ensure_fs_leave: need llvm-objcopy" >&2; exit 1; }

XLANG_BIN=""
if [ -x ./xlang.product_legacy_bak ]; then
  XLANG_BIN=$PWD/xlang.product_legacy_bak
elif [ -n "${XLANG:-}" ] && [ -x "${XLANG}" ]; then
  XLANG_BIN=$XLANG
else
  echo "cap_tip_ensure_fs_leave: need xlang.product_legacy_bak" >&2
  exit 1
fi

mkdir -p "$(dirname "$out")" build_asm/selfhost_pabi
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

"$XLANG_BIN" -backend asm -c -L .. -o "$tmp/mod.o" ../std/fs/mod.x
"$XLANG_BIN" -backend asm -c -L .. -o "$tmp/posix.o" ../std/fs/posix.x
# Darwin libc errno is ___error; LEGACY may emit __error.
if nm "$tmp/posix.o" 2>/dev/null | grep -q ' U __error$'; then
  "$OC" --redefine-sym=__error=___error "$tmp/posix.o"
fi
if nm "$tmp/posix.o" 2>/dev/null | grep -q ' U ____error$'; then
  "$OC" --redefine-sym=____error=___error "$tmp/posix.o"
fi

dir_o=runtime_dir_cap.o
if [ ! -s "$dir_o" ] || ! nm -gU "$dir_o" 2>/dev/null | grep -q 'T _xlang_dir_readdir$'; then
  bash scripts/ensure_host_cc_seed_o.sh dir-cap-pure "$dir_o"
fi
[ -s "$dir_o" ] || { echo "cap_tip_ensure_fs_leave: missing $dir_o" >&2; exit 1; }

ld -r -o "$out.tmp" "$tmp/mod.o" "$tmp/posix.o" "$dir_o"
mv -f "$out.tmp" "$out"
nm -gU "$out" 2>/dev/null | grep -q 'T _std_fs_invalid$' \
  || { echo "cap_tip_ensure_fs_leave: missing _std_fs_invalid" >&2; exit 1; }
echo "cap_tip_ensure_fs_leave: OK $out" >&2
