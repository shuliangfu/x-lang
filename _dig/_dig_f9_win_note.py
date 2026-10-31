#!/usr/bin/env python3
"""F9 Prefer-M2: plant w1521_win_note_func_c call in dig emit_param_home
immediately before sret_active_get, mirroring W1778.

Host: copy of F8 (sha was 0013593f2db0).
Trampoline in dead body after emit_struct_lit F8 hook jmp @ 0x1402db1df.
Hook: replace call sret_active_get @ 0x140262ecd with jmp trampoline.
"""
import hashlib
import shutil
import struct
import sys

SRC = r"C:/xlang_tmp/p1060/g05th_dig/lab_CapSoftWin_tiphead_FACE_OKKEEP_dig_UNIFY_F8.exe"
DST = r"C:/xlang_tmp/p1060/g05th_dig/lab_CapSoftWin_tiphead_FACE_OKKEEP_dig_UNIFY_F9.exe"

# VAs
EMIT_PARAM_CALL = 0x140262ECD  # call sret_active_get (5 bytes)
CONT_AFTER = 0x140262ED2       # mov [rbp-0x2c], eax
TRAMP = 0x1402DB1DF            # dead body after F8 jmp at emit_struct_lit
WIN_NOTE = 0x1405B1A48
SRET_ACTIVE_GET = 0x1402AF954


def pe_text_map(data: bytearray):
    e = struct.unpack_from("<I", data, 0x3C)[0]
    nsec = struct.unpack_from("<H", data, e + 6)[0]
    opt = struct.unpack_from("<H", data, e + 20)[0]
    so = e + 24 + opt
    for i in range(nsec):
        o = so + i * 40
        name = bytes(data[o : o + 8]).split(b"\0")[0]
        vsz, rva, rsz, roff = struct.unpack_from("<IIII", data, o + 8)
        if name == b".text":
            base = 0x140000000 + rva
            return base, roff, rsz
    raise SystemExit("no .text")


def fo(base, roff, va):
    return roff + (va - base)


def i32(x):
    return struct.pack("<i", x & 0xFFFFFFFF if x < 0x80000000 else x - 0x100000000)


def rel32(from_va, to_va):
    # from_va is address of next instruction after the rel32 insn (call/jmp end)
    return to_va - from_va


def main():
    dry = "--dry" in sys.argv
    shutil.copy2(SRC, DST)
    data = bytearray(open(DST, "rb").read())
    base, roff, rsz = pe_text_map(data)

    # Verify hook site is still call sret_active_get
    off_hook = fo(base, roff, EMIT_PARAM_CALL)
    hook_bytes = bytes(data[off_hook : off_hook + 5])
    expect_rel = rel32(EMIT_PARAM_CALL + 5, SRET_ACTIVE_GET)
    expect = b"\xe8" + struct.pack("<i", expect_rel)
    print("hook@%x have=%s expect=%s" % (EMIT_PARAM_CALL, hook_bytes.hex(), expect.hex()))
    if hook_bytes != expect:
        # tolerate if already our jmp (re-run)
        if hook_bytes[0] == 0xE9:
            print("WARN: already patched (jmp); will rewrite tramp+hook")
        else:
            raise SystemExit("unexpected hook bytes")

    # Build trampoline @ TRAMP
    # 48 8b 4d 20       mov rcx, [rbp+0x20]     ; module (r8)
    # 48 63 55 28       movsxd rdx, [rbp+0x28]  ; func index (r9d)
    # e8 rel            call win_note
    # e8 rel            call sret_active_get
    # e9 rel            jmp CONT_AFTER
    tramp = bytearray()
    tramp += b"\x48\x8b\x4d\x20"
    tramp += b"\x48\x63\x55\x28"
    call1_va = TRAMP + len(tramp)
    tramp += b"\xe8" + struct.pack("<i", rel32(call1_va + 5, WIN_NOTE))
    call2_va = TRAMP + len(tramp)
    tramp += b"\xe8" + struct.pack("<i", rel32(call2_va + 5, SRET_ACTIVE_GET))
    jmp_va = TRAMP + len(tramp)
    tramp += b"\xe9" + struct.pack("<i", rel32(jmp_va + 5, CONT_AFTER))
    print("tramp len=%d @%x: %s" % (len(tramp), TRAMP, tramp.hex()))
    assert len(tramp) <= 0x40, "tramp too big for dead body"

    off_tramp = fo(base, roff, TRAMP)
    print("overwrite dead body was:", bytes(data[off_tramp : off_tramp + len(tramp)]).hex())

    # Hook: jmp TRAMP
    hook = b"\xe9" + struct.pack("<i", rel32(EMIT_PARAM_CALL + 5, TRAMP))
    print("new hook:", hook.hex())

    if dry:
        print("DRY — no write")
        return

    data[off_tramp : off_tramp + len(tramp)] = tramp
    data[off_hook : off_hook + 5] = hook
    open(DST, "wb").write(data)
    h = hashlib.sha256(open(DST, "rb").read()).hexdigest()
    print("WROTE", DST)
    print("sha256", h[:12], h)


if __name__ == "__main__":
    main()
