#!/usr/bin/env bash
# PLATFORM: WINDOWS — host-cc parser_gen.c → parser_x.o without PE -E.
# Strips sys/uio + libc extern clashes; stubs readv/writev (unused on cold path).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${1:-parser_x.o}"
SRC="${2:-parser_gen.c}"
TMPDIR="${TMPDIR:-/tmp}"
tmp="$(mktemp "${TMPDIR}/parser_gen_win.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
# BusyBox/w64 sed: avoid fancy regex; python for readv stub if available.
if command -v python3 >/dev/null 2>&1; then
  python3 - "$SRC" "$tmp" <<'PY'
import sys, re
from pathlib import Path
src = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
src = src.replace("#include <sys/uio.h>", "/* WIN: skip sys/uio.h */")
src = re.sub(
    r"static inline ssize_t xlang_sys_readv\(int32_t fd, uint8_t \*iov, int32_t iovcnt\) \{\n  return readv\([^;]+;\n\}",
    "static inline ssize_t xlang_sys_readv(int32_t fd, uint8_t *iov, int32_t iovcnt) {\n  (void)fd; (void)iov; (void)iovcnt; return (ssize_t)-1;\n}",
    src, count=1)
src = re.sub(
    r"static inline ssize_t xlang_sys_writev\(int32_t fd, uint8_t \*iov, int32_t iovcnt\) \{\n  return writev\([^;]+;\n\}",
    "static inline ssize_t xlang_sys_writev(int32_t fd, uint8_t *iov, int32_t iovcnt) {\n  (void)fd; (void)iov; (void)iovcnt; return (ssize_t)-1;\n}",
    src, count=1)
out = []
for line in src.splitlines(True):
    if line.startswith("extern uint8_t * calloc("):
        continue
    if line.startswith("extern void free("):
        continue
    if line.startswith("extern uint8_t * malloc("):
        continue
    out.append(line)
Path(sys.argv[2]).write_text("".join(out), encoding="utf-8")
PY
else
  sed -e 's|#include <sys/uio.h>|/* WIN: skip sys/uio.h */|' \
      -e '/^extern uint8_t \* calloc(/d' \
      -e '/^extern void free(/d' \
      -e '/^extern uint8_t \* malloc(/d' \
      "$SRC" >"$tmp"
fi
CC="${CC:-gcc}"
# shellcheck disable=SC2086
$CC ${BASE_CFLAGS:--Wall -I. -Iinclude -Isrc} -std=c11 -O0 -g \
  -D_WIN32 -include include/win32_compat.h \
  -Wno-pointer-sign -Wno-incompatible-pointer-types -Wno-implicit-function-declaration \
  -c -o "$OUT" "$tmp"
echo "win_host_cc_parser_x: $OUT OK ($(wc -c <"$OUT" | tr -d ' ')B)"
