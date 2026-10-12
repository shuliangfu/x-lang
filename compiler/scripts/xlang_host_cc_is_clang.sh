#!/bin/sh
# xlang_host_cc_is_clang.sh — is the host C compiler clang?
#
# One authority for that fact. Callers source this file. They must not
# run `$CC -v` or `cc -v` to answer the same question.
#
# Does not execute the compiler. PLATFORM: SHARED.
#
# Apple ships /usr/bin/cc, /usr/bin/gcc, and /usr/bin/c++ as the same file
# as /usr/bin/clang. Their version text contains "clang", but the file
# name does not. Linux /usr/bin/cc is a symlink to gcc. The final file
# name does not contain clang, and the inode is not clang's.
#
# A basename that contains "clang" is clang. Otherwise the resolved file
# is clang only when it is the same inode as the `clang` on PATH.
# A renamed copy that is neither a symlink nor that inode is not treated
# as clang. Product hosts are the two cases above.
#
# Return 0 when the compiler is clang, 1 otherwise. Echo nothing.
# When this file is executed, print "clang" and exit 0, or exit 1.

# Resolve a compiler name or path to a final file. Follow symlinks.
# Do not execute the file. PLATFORM: SHARED.
xlang_host_cc_resolve() {
  # local is supported by bash, dash, and Git bash. Keep names inside
  # the function so a sourced caller does not lose its own p/i/w.
  local p i w t d b
  p="$1"
  i=0
  if [ ! -e "$p" ]; then
    w=$(command -v "$p" 2>/dev/null || true)
    if [ -z "$w" ]; then
      printf '%s\n' "$p"
      return 0
    fi
    p="$w"
  fi
  while [ -L "$p" ] && [ "$i" -lt 16 ]; do
    t=$(readlink "$p" 2>/dev/null || true)
    if [ -z "$t" ]; then
      break
    fi
    case "$t" in
      /*) p="$t" ;;
      *)
        d=$(dirname "$p")
        d=$(CDPATH= cd -- "$d" 2>/dev/null && pwd) || break
        p="$d/$t"
        ;;
    esac
    i=$((i + 1))
  done
  if [ -e "$p" ]; then
    d=$(dirname "$p")
    d=$(CDPATH= cd -- "$d" 2>/dev/null && pwd) || d=""
    b=$(basename "$p")
    if [ -n "$d" ]; then
      printf '%s/%s\n' "$d" "$b"
      return 0
    fi
  fi
  printf '%s\n' "$p"
}

# Return 0 when $1 (default $CC, else cc) is clang. PLATFORM: SHARED.
xlang_host_cc_is_clang() {
  local bin resolved base clang_bin clang_res id_cc id_cl
  bin="${1:-${CC:-cc}}"
  resolved=$(xlang_host_cc_resolve "$bin")
  base=$(basename "$resolved")
  case "$base" in
    *clang*|*Clang*|*CLANG*) return 0 ;;
  esac
  clang_bin=$(command -v clang 2>/dev/null || true)
  if [ -z "$clang_bin" ]; then
    return 1
  fi
  clang_res=$(xlang_host_cc_resolve "$clang_bin")
  if [ ! -e "$resolved" ] || [ ! -e "$clang_res" ]; then
    return 1
  fi
  case "$(uname -s 2>/dev/null || echo Unknown)" in
    Darwin)
      id_cc=$(stat -f '%d:%i' "$resolved" 2>/dev/null || true)
      id_cl=$(stat -f '%d:%i' "$clang_res" 2>/dev/null || true)
      ;;
    *)
      id_cc=$(stat -c '%d:%i' "$resolved" 2>/dev/null || true)
      id_cl=$(stat -c '%d:%i' "$clang_res" 2>/dev/null || true)
      ;;
  esac
  if [ -n "$id_cc" ] && [ "$id_cc" = "$id_cl" ]; then
    return 0
  fi
  return 1
}

# Executed, not sourced: $0 is this file. Sourced callers keep their own $0.
case "${0##*/}" in
  xlang_host_cc_is_clang.sh)
    if xlang_host_cc_is_clang "${1:-${CC:-cc}}"; then
      printf 'clang\n'
      exit 0
    fi
    exit 1
    ;;
esac
