#!/bin/bash
# Overlay host-cc slot sizers onto a Linux tip ELF.
#
# PLATFORM: LINUX|UBUNTU — no-op on Darwin / Windows (those tip frames
# already separate `u8[4]` from `Option_ptr_u8`).
# Authority stays in the `.x` thins. Host cc is only the code generator
# because tip `-backend asm` emits `sub $0x1038` / `sub $0x8a8`.
# -fno-jump-tables keeps relocs as PLT32 to named tip symbols.
# G.7: do not copy a third C body; -E the existing thins.
# Pin is not touched.
#
# Usage (from compiler/):
#   bash scripts/overlay_tip_slot_bytes_gcc.sh [tip_elf]
#   bash scripts/overlay_tip_slot_bytes_gcc.sh --force xlang_asm
# Default tip_elf is ./xlang_asm. --force replaces an existing jmp
# trampoline (hand-planted warm blob). A good prologue is never rewritten.
set -euo pipefail
cd "$(dirname "$0")/.."

FORCE=0
TIP="xlang_asm"
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    *) TIP="$arg" ;;
  esac
done

if [ "$(uname -s)" != "Linux" ]; then
  echo "overlay_tip_slot_bytes_gcc: skip non-Linux ($(uname -s))"
  exit 0
fi
if [ ! -f "$TIP" ]; then
  echo "overlay_tip_slot_bytes_gcc: no $TIP" >&2
  exit 0
fi

PROBE=(python3 scripts/overlay_tip_slot_bytes_gcc.py --probe)
if [ "$FORCE" = "1" ]; then
  PROBE+=(--force)
fi
set +e
"${PROBE[@]}" "$TIP"
probe_rc=$?
set -e
if [ "$probe_rc" = "2" ]; then
  echo "overlay_tip_slot_bytes_gcc: unchanged $TIP"
  exit 0
fi
if [ "$probe_rc" != "0" ]; then
  exit "$probe_rc"
fi

# Prefer the host-cc frontend. Tip xlang_asm is the binary being patched.
XL_E=""
if [ -x ./xlang ]; then
  XL_E=./xlang
elif [ -x ./xlang-c ]; then
  XL_E=./xlang-c
elif [ -x ./xlang_asm ] && [ "$TIP" != "xlang_asm" ] && [ "$TIP" != "./xlang_asm" ]; then
  XL_E=./xlang_asm
fi
if [ -z "$XL_E" ]; then
  echo "overlay_tip_slot_bytes_gcc: no host frontend for -E" >&2
  exit 1
fi

SLOT_X=src/runtime_pipeline_abi_slot_bytes_thin.x
GLUE_X=src/runtime_pipeline_abi_fnptr_array_esz_thin.x
[ -f "$SLOT_X" ] && [ -f "$GLUE_X" ] || {
  echo "overlay_tip_slot_bytes_gcc: missing thin .x" >&2
  exit 1
}

WORK="$(mktemp -d "${TMPDIR:-/tmp}/slot_bytes_gcc.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

"$XL_E" -E "$SLOT_X" >"$WORK/slot.c"
"$XL_E" -E "$GLUE_X" >"$WORK/glue.c"
# PLATFORM: LINUX x86_64. No PIC, no jump tables, no unwind side tables.
CFLAGS="-O2 -fno-pic -fno-stack-protector -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-jump-tables -Iinclude -Isrc -I."
# shellcheck disable=SC2086
cc -c $CFLAGS -o "$WORK/slot.o" "$WORK/slot.c"
# shellcheck disable=SC2086
cc -c $CFLAGS -o "$WORK/glue.o" "$WORK/glue.c"
ld -r -o "$WORK/donor.o" "$WORK/slot.o" "$WORK/glue.o"

OUT="$WORK/tip.out"
PY=(python3 scripts/overlay_tip_slot_bytes_gcc.py)
if [ "$FORCE" = "1" ]; then
  PY+=(--force)
fi
"${PY[@]}" "$TIP" "$WORK/donor.o" "$OUT"
if [ -f "$OUT" ]; then
  chmod +x "$OUT"
  mv -f "$OUT" "$TIP"
  echo "overlay_tip_slot_bytes_gcc: updated $TIP"
else
  echo "overlay_tip_slot_bytes_gcc: unchanged $TIP"
fi
