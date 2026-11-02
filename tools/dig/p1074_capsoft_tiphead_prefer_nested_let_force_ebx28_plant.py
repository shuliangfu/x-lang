
# -*- coding: utf-8 -*-
"""10.74 dig — nested_let force ebx=0x28 at emit_let_init tip clamp (store→Prefer home).

Base 1f78 SoftCap 8/8 nested=1. Guest assign Prefer @-0x28 vs init/load @-0x20.
Hypothesis: forcing store home ebx=0x28 aligns init with Prefer assign; load via
find/scoped should then also see 0x28 if table coheres (or load stays 0x20→still fail).
Soft Cap 74d0 + tip 9ecd HOLD. No Prefer disasm plant — emit_let_init tip only.
"""
from __future__ import annotations
import hashlib, struct, subprocess
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_force_ebx28.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC, EXPECT_PROD, EXPECT_TIP = "1f78def393fc", "74d0bd9c9fbf", "9ecd26ea44ab"
HOOK_VA, CONT_VA, STEAL_LEN = 0x140016B4B, 0x140016B54, 9
STEAL_HEX = "4489742420895c2428"
BANNED = {
    "1e59c5261663","a1491a74c08b","5dff12e7772e","74d0bd9c9fbf","9ecd26ea44ab",
    "1f78def393fc","b995aaae2126","e96f6a63596a","623e3ba86574","460444eac7a9",
    "5013ec743970","9dcf964ea01a","625427ca12f3","fd7ec408609c","e9d0ff140add",
    "e625fd49c2ce","7872142a2558","7864b74d2857","7905d0ae3e81","7ef06c5e5746",
    "9796e9644d54","71fa8aac44f3","ed58b661db52","108c501987b0",
}

def sha12(p):
    if isinstance(p,(bytes,bytearray)): return hashlib.sha256(bytes(p)).hexdigest()[:12]
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]

def parse_pe(data):
    e=struct.unpack_from("<I",data,0x3C)[0]; coff=e+4
    nsec=struct.unpack_from("<H",data,coff+2)[0]
    optsz=struct.unpack_from("<H",data,coff+16)[0]; opt=coff+20
    assert struct.unpack_from("<H",data,opt)[0]==0x20B
    ib=struct.unpack_from("<Q",data,opt+24)[0]; sec=opt+optsz; secs=[]
    for i in range(nsec):
        o=sec+i*40
        name=bytes(data[o:o+8]).split(b"\0",1)[0].decode("ascii","replace")
        vsz,sva,rsz,rdo=struct.unpack_from("<IIII",data,o+8)
        secs.append({"i":i,"o":o,"name":name,"sva":sva,"rdo":rdo,"rsz":rsz,"vsz":vsz})
    return {"ib":ib,"secs":secs}

def file_of_va(pe,va):
    rva=va-pe["ib"]
    for s in pe["secs"]:
        if s["sva"]<=rva<s["sva"]+s["rsz"]:
            return s["rdo"]+(rva-s["sva"])
    raise KeyError(hex(va))

def main():
    assert sha12(SRC)==EXPECT_SRC
    assert sha12(PROD)==EXPECT_PROD and sha12(CAVE)==EXPECT_PROD and sha12(TIP)==EXPECT_TIP
    data=bytearray(SRC.read_bytes()); pe=parse_pe(data); ib=pe["ib"]
    hook_off=file_of_va(pe,HOOK_VA)
    assert bytes(data[hook_off:hook_off+STEAL_LEN]).hex()==STEAL_HEX
    assert data[hook_off+STEAL_LEN]==0xE8
    tpad=next(s for s in pe["secs"] if s["name"].startswith(".tpad"))
    free=tpad["rsz"]-tpad["vsz"]; cave_file=tpad["rdo"]+tpad["vsz"]
    assert data[cave_file:cave_file+free]==b"\x00"*free
    cave_va=ib+tpad["sva"]+tpad["vsz"]
    wb=bytearray()
    # redo stolen
    wb += bytes.fromhex("4489742420895c2428")
    # mov ebx, 0x28
    wb += bytes.fromhex("bb28000000")
    # rewrite stolen slot with new ebx
    wb += bytes.fromhex("895c2428")
    # jmp CONT
    rel=CONT_VA-(cave_va+len(wb)+5)
    wb += b"\xe9"+struct.pack("<i",rel)
    assert len(wb)<=free,(len(wb),free)
    rel_hook=cave_va-(HOOK_VA+5)
    data[hook_off:hook_off+5]=b"\xe9"+struct.pack("<i",rel_hook)
    data[hook_off+5:hook_off+STEAL_LEN]=b"\x90"*(STEAL_LEN-5)
    data[cave_file:cave_file+len(wb)]=wb
    struct.pack_into("<I",data,tpad["o"]+8,tpad["vsz"]+len(wb))
    h=sha12(data); assert h not in BANNED and h!=EXPECT_SRC
    OUT.write_bytes(data)
    tagged=DIGDIR/f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_force_ebx28_{h}.exe"
    tagged.write_bytes(data)
    print("PLANTED",tagged); print("SHA",h); print("wb_len",len(wb),"free",free)
    print("HOLD_OK",EXPECT_PROD,EXPECT_TIP,EXPECT_SRC)

if __name__=="__main__":
    main()
