#!/bin/sh
# L6: Send/Sync contract gate — verify #[send] and #[sync] attributes.
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHUX_C="$SCRIPT_DIR/../../compiler/shux-c"
WORKDIR="${TMPDIR:-/tmp}"
PASS=0
FAIL=0

echo "=== L6: Send/Sync contract gate ==="

cat > "$WORKDIR/send_sync_test.x" << 'XEOF'
#[repr(C)]
#[send]
#[sync]
struct SafeBuffer {
  data: *u8;
  len: u32;
}
#[repr(C)]
#[send]
struct Message {
  id: u32;
}
#[repr(C)]
struct RawPtr {
  ptr: *u8;
}
function main(): i32 {
  let buf: SafeBuffer = { data: 0 as *u8, len: 0 };
  let msg: Message = { id: 42 };
  return msg.id as i32;
}
XEOF

XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$WORKDIR/send_sync_test.x" > "$WORKDIR/send_sync.c" 2>/dev/null

echo "  Check: #[send] #[sync] emits shux_thread_safety:send+sync"
if grep -q 'shux_thread_safety:send+sync' "$WORKDIR/send_sync.c"; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

echo "  Check: #[send] only emits shux_thread_safety:send"
if grep -q 'shux_thread_safety:send ' "$WORKDIR/send_sync.c"; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

echo "  Check: struct without attributes has no thread safety comment"
RAWPTR_LINE=$(grep 'struct RawPtr' "$WORKDIR/send_sync.c" | head -1)
if echo "$RAWPTR_LINE" | grep -q 'shux_thread_safety'; then
    echo "    FAIL: unexpected comment on RawPtr"
    FAIL=$((FAIL + 1))
else
    echo "    PASS"
    PASS=$((PASS + 1))
fi

echo "  Check: compilation succeeds"
if cc -c -o "$WORKDIR/send_sync.o" "$WORKDIR/send_sync.c" 2>/dev/null; then
    echo "    PASS"
    PASS=$((PASS + 1))
else
    echo "    FAIL"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== SEND/SYNC SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
