# -*- coding: utf-8 -*-
"""10.74 dig — Prefer nested_let find_offset first-wins ONLY (no scoped patch).

Base 1f78 SoftCap 8/8 nested=1. Prior:
  scoped-only first-wins 9796 SoftCap 8/8 nested=1 (Prefer uses find_offset)
  scoped+find first_wins 7872 SoftCap 4/8 Prefer FAIL CG002 OUT
  scoped_hit 7ef0 SoftCap 8/8 nested=1
  set_offset/all SoftCap 8/8 nested=1 no-op; force_ebx28 d4d6 OUT

Grain: tip.x find is last→first; Prefer assign hits fill-tree shadow y@0x28
while init/load keep decl 0x20. Flip asm_ctx_local_find_offset ONLY to
first-wins so Prefer-find hits store home. Soft Cap 74d0 + tip 9ecd HOLD.
"""
from __future__ import annotations
import hashlib, struct
from pathlib import Path

DIGDIR = Path(r"C:\xlang_tmp\p1060\g05th_dig")
SRC = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_w1521_param_home_1f78def393fc.exe"
OUT = DIGDIR / "lab_CapSoftWin_tiphead_P1074_prefer_nested_let_find_first_wins.exe"
PROD = Path(r"C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe")
CAVE = Path(r"C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe")
TIP = Path(r"C:\xlang_tmp\p1060\cave\lab_CapSoftWin_tiphead.exe")

EXPECT_SRC, EXPECT_PROD, EXPECT_TIP = "1f78def393fc", "74d0bd9c9fbf", "9ecd26ea44ab"
FIND_START_VA = 0x1402D16AC  # sub eax,1 ; mov [rbp-4],eax
FIND_FOOT_VA = 0x1402D176E  # last-wins footer

BANNED = {
    "1e59c5261663","a1491a74c08b","5dff12e7772e","74d0bd9c9fbf","9ecd26ea44ab",
    "1f78def393fc","b995aaae2126","e96f6a63596a","623e3ba86574","460444eac7a9",
    "5013ec743970","9dcf964ea01a","625427ca12f3","fd7ec408609c","e9d0ff140add",
    "e625fd49c2ce","7872142a2558","7864b74d2857","7905d0ae3e81","7ef06c5e5746",
    "9796e9644d54","71fa8aac44f3","ed58b661db52","108c501987b0","d4d673e28788",
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

def fo(pe,va):
    rva=va-pe["ib"]
    for s in pe["secs"]:
        if s["sva"]<=rva<s["sva"]+max(s["vsz"],s["rsz"]):
            return s["rdo"]+(rva-s["sva"])
    raise KeyError(hex(va))

def main():
    assert sha12(SRC)==EXPECT_SRC
    assert sha12(PROD)==EXPECT_PROD and sha12(CAVE)==EXPECT_PROD and sha12(TIP)==EXPECT_TIP
    data=bytearray(SRC.read_bytes()); pe=parse_pe(data)

    off=fo(pe, FIND_START_VA)
    assert data[off:off+6]==bytes.fromhex("83e8018945fc"), data[off:off+6].hex()
    data[off:off+6]=bytes.fromhex("31c0908945fc")  # xor eax,eax; nop; mov [rbp-4],eax

    off=fo(pe, FIND_FOOT_VA)
    expect=bytes.fromhex("836dfc01837dfc000f893bffffffb8ffffffff")
    assert data[off:off+19]==expect, data[off:off+19].hex()
    # add [rbp-4],1; mov ecx,[rbp-0x14]; cmp [rbp-4],ecx; jl body; or eax,-1
    patch=bytes.fromhex("8345fc018b4dec394dfc0f8c39ffffff83c8ff")
    assert len(patch)==19
    data[off:off+19]=patch

    h=sha12(data)
    assert h not in BANNED and h!=EXPECT_SRC
    OUT.write_bytes(data)
    tagged=DIGDIR/f"lab_CapSoftWin_tiphead_P1074_prefer_nested_let_find_first_wins_{h}.exe"
    tagged.write_bytes(data)
    assert sha12(PROD)==EXPECT_PROD and sha12(CAVE)==EXPECT_PROD and sha12(TIP)==EXPECT_TIP
    print("PLANTED", tagged)
    print("SHA", h)
    print("HOLD_OK", EXPECT_PROD, EXPECT_TIP, EXPECT_SRC)

if __name__=="__main__":
    main()
