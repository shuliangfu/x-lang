#!/usr/bin/env bash
# knife256/10.2: patch tip-linked ./xlang in-place until lexer.o carries
# store-not-return. (1) park: PAGEZERO tbz + sticky-max len
# (2) lexer_next_buf(_into): keep full len, skip 1024 BSS deep-copy.
# PLATFORM: MACOS arm64. Idempotent-ish: expects tip layout of tip 5dabafd79+.
set -euo pipefail
BIN="${1:-./xlang}"
[[ -f "$BIN" ]] || { echo "missing $BIN" >&2; exit 1; }
python3 - "$BIN" <<'PY'
import struct,sys,shutil
path=sys.argv[1]
shutil.copy(path, path+".pre_1024_clamp_patch")
data=bytearray(open(path,"rb").read())
text_off,text_va=0x638,0x100000638
def enc_b(frm,to): return 0x14000000|(((to-frm)>>2)&0x03ffffff)
def enc_adrp(rd,pc,page):
    imm=(((page-(pc&~0xfff))>>12)&((1<<21)-1))
    return 0x90000000|((imm&3)<<29)|((imm>>2)<<5)|rd
def enc_ldr_x(rt,rn,imm): return 0xF9400000|((imm//8)<<10)|(rn<<5)|rt
def enc_str_x(rt,rn,imm): return 0xF9000000|((imm//8)<<10)|(rn<<5)|rt
def enc_b_cond(c,off): return 0x54000000|((off&((1<<19)-1))<<5)|c
def enc_sxtw(rd,rn): return 0x93407C00|(rn<<5)|rd
def enc_ret(): return 0xD65F03C0
def enc_tbz(rt,bit,off):
    return 0x36000000|((1 if bit>=32 else 0)<<31)|((bit&31)<<19)|((off&((1<<14)-1))<<5)|rt
def patch(va,words):
    off=text_off+(va-text_va)
    blob=b"".join(struct.pack("<I",w) for w in words)
    data[off:off+len(blob)]=blob
park_va,page,LE=0x100000d38,0x1004b9000,13
# Prefer ignore-1024-when-longer (matches hollow_fill) if we have room;
# 9-insn sticky-max+tbz fits current hollow slot.
patch(park_va,[
    enc_tbz(0,32,8), enc_adrp(2,park_va+4,page), enc_ldr_x(3,2,0xea0),
    enc_sxtw(1,1), 0xEB03003F, enc_b_cond(LE,3),
    enc_str_x(0,2,0xe98), enc_str_x(1,2,0xea0), enc_ret(),
])
patch(0x1001cb060,[enc_b(0x1001cb060,0x1001cb070)])
patch(0x1001cb078,[enc_b(0x1001cb078,0x1001cb144)])
patch(0x1001caea0,[enc_b(0x1001caea0,0x1001caeb0)])
patch(0x1001caeb8,[enc_b(0x1001caeb8,0x1001caf84)])
open(path,"wb").write(data)
print("patched",path)
PY
codesign -s - -f "$BIN" >/dev/null 2>&1 || true
