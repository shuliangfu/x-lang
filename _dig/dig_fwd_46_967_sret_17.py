"""DIG fwd_46_967_sret #17: post-5752bc fixup with CORRECT append data offset
(2a7725=0x2790030 default / 2a7730 ALT); read u32 len at field; patch 4889c1e8→c2.
Plant @57bbae (INT3 HIT after 5752bc+57464c). Gate lit/fwd/local/let.
"""
from pathlib import Path
import struct, hashlib, subprocess, time, sys

CAVE = Path("C:/xlang_tmp/p1060/cave")
BASE = CAVE / "host_967_sret_tr460.exe"
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]

def P(*a): print(*a, flush=True)
def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e+6)[0]
    opt = struct.unpack_from("<H", buf, e+20)[0]
    sec = e+24+opt; secs = {}
    for i in range(nsec):
        o = sec+i*40; n = bytes(buf[o:o+8]).split(b"\0")[0]
        vs,va,rs,ro = struct.unpack_from("<IIII", buf, o+8)
        secs[n] = (va,vs,ro,rs)
    return secs
def rva2off(buf, secs, r):
    for n,(va,vs,ro,rs) in secs.items():
        if va <= r < va+max(vs,rs): return ro+(r-va)
    raise ValueError(hex(r))
def tag_of(crc):
    return {0: "OK", 0x80000003: "INT3", 0xC0000409: "GS", 0xC0000005: "AV"}.get(crc & 0xffffffff, hex(crc & 0xffffffff))
def run(h, src, timeout=8, prefix="_t17"):
    out = CAVE / f"{prefix}_{Path(src).stem}.exe"
    r = subprocess.run([str(h), str(CAVE/src), "-o", str(out)], capture_output=True, timeout=timeout)
    return r.returncode & 0xffffffff, out if out.exists() and out.stat().st_size > 0 else None
def run_bin(exe, timeout=3):
    r = subprocess.run([str(exe)], capture_output=True, timeout=timeout)
    return r.returncode & 0xffffffff
def save(pe, name):
    p = CAVE/name; p.write_bytes(bytes(pe))
    return p
def gate(h, label):
    rows = []
    out_fwd = None
    for s in SRCS:
        crc, outx = run(h, s, prefix=f"_g17_{label}")
        tag = tag_of(crc)
        user = "n/a"
        run_t = "-"
        if outx:
            raw = outx.read_bytes()
            user = hashlib.sha256(raw).hexdigest()[:12]
            if s == "p_ret_fwd.x":
                out_fwd = outx
            rc = run_bin(outx)
            run_t = tag_of(rc)
            if run_t == "OK" and s == "p_ret_fwd.x":
                # check stdout? just OK
                pass
        # USER sha of known shapes
        known = {"f4839df16ab1": "VAL", "e411d7260d78": "HOLLOW", "be679e1a2242": "BE67",
                 "5c6778769c3c": "LIT_OK", "36d26fcc9657": "LOC_OK", "5676e979af61": "LET_GS"}
        mark = known.get(user, "")
        P(f"  {label}/{s:16s} {tag:8s} USER={user} run={run_t} {mark}")
        rows.append((s, tag, user, run_t))
    return rows, out_fwd
def dump_fw(buf, label):
    P(f"  dump {label}:")
    # find .text of USER PE and show near call
    try:
        secs = pe_secs(buf)
        va,vs,ro,rs = secs[b".text"]
        w = buf[ro:ro+rs]
        # show around 4889c1e8 and 4889c2
        for pat, name in [(bytes.fromhex("4889c1e8"), "c1e8"), (bytes.fromhex("4889c2e8"), "c2e8"),
                          (bytes.fromhex("4889c2"), "c2"), (bytes.fromhex("4889c1"), "c1")]:
            idx = 0; hits = []
            while True:
                j = w.find(pat, idx)
                if j < 0: break
                hits.append(j); idx = j+1
                if len(hits) > 6: break
            P(f"    {name} hits@{[hex(x) for x in hits]}")
        # disasm near last c1 or c2 before a call-ish
        from capstone import Cs, CS_ARCH_X86, CS_MODE_64
        md = Cs(CS_ARCH_X86, CS_MODE_64)
        for anchor in [w.rfind(bytes.fromhex("4889c1e8")), w.rfind(bytes.fromhex("4889c2e8")),
                       w.rfind(bytes.fromhex("4889c1")), w.rfind(bytes.fromhex("4889c2"))]:
            if anchor < 0: continue
            start = max(0, anchor-0x20)
            P(f"    near@{anchor:#x}:")
            for insn in md.disasm(w[start:anchor+0x20], start):
                P(f"      {insn.address:06x}: {insn.bytes.hex():20s} {insn.mnemonic} {insn.op_str}")
            break
        if bytes.fromhex("4889c1e8") in w:
            P("  ** still 4889c1e8 **")
        if bytes.fromhex("4889c2e8") in w:
            P("  ** HAS 4889c2e8 (patched!) **")
    except Exception as ex:
        P(f"  dump err: {ex}")

t0 = time.time()
base = bytearray(BASE.read_bytes())
secs = pe_secs(base)
P(f"BASE={BASE.name} sha={hashlib.sha256(base).hexdigest()[:12]}")

# ---- build fixup plant @57bbae ----
# Correct append layout:
#   default: data=ctx+2a7725()=ctx+0x2790030; len_field=2a765f()=0
#   ALT if 2a7b6e: data=ctx+2a7730()=ctx+0x2fe0030; len_field=2a7704()=0x2790028
# Read u32 len at ctx+len_field (215bd0 writes 4 bytes).
# Scan [data, data+len) for 48 89 C1 E8; patch C1→C2.
# Also try scan last 0x100 from data+len regardless.

def build_fixup(base_r=0x57bbae, end_r=0x57bd4e, use_alt=False, scan_back=0x100):
    fixup = bytearray()
    def E(h):
        fixup.extend(bytes.fromhex(h) if isinstance(h, str) else h)
    def call_abs(target):
        at = base_r + len(fixup)
        E("e8" + struct.pack("<i", target - (at+5)).hex())
    # sub rsp,0x20 for shadow
    E("4883ec20")
    # rcx = emit_ctx = [rbp-0x18]
    # Choose offsets
    if use_alt:
        # len_field = 0x2790028, data_off = 0x2fe0030
        E("b828007902")          # mov eax, 0x2790028
        E("8985e0fdffff")        # mov [rbp-0x220], eax  ; len_field
        E("b83000fe02")          # mov eax, 0x2fe0030
        E("8985dcfdffff")        # mov [rbp-0x224], eax  ; data_off (reuse stack)
    else:
        E("b800000000")          # mov eax, 0
        E("8985e0fdffff")
        E("b830007902")          # mov eax, 0x2790030
        E("8985dcfdffff")
    # data = ctx + data_off
    E("488b45e8")                # mov rax, [rbp-0x18]
    E("8b95dcfdffff")            # mov edx, [rbp-0x224]
    E("4863d2")                  # movsxd rdx, edx
    E("4801d0")                  # add rax, rdx
    E("488985d8fdffff")          # mov [rbp-0x228], rax  ; data_start
    # len = u32 [ctx + len_field]
    E("488b45e8")                # mov rax, [rbp-0x18]
    E("8b95e0fdffff")            # mov edx, len_field
    E("4863d2")
    E("4801d0")
    E("8b00")                    # mov eax, [rax]  ; u32 len
    E("8985e4fdffff")            # mov [rbp-0x21c], eax ; len
    # if len < 4, skip
    E("3d04000000")              # cmp eax, 4
    jl_small = len(fixup); E("0f8c00000000")
    # end = data + len
    E("488b85d8fdffff")          # rax = data
    E("8b95e4fdffff")            # edx = len
    E("4863d2")
    E("488d3410")                # rsi = data+len = end
    # rdi = max(data, end - scan_back)
    E("4889f7")                  # rdi = end
    E("4881ef" + struct.pack("<I", scan_back).hex())  # sub rdi, scan_back
    E("488b85d8fdffff")          # rax = data
    E("4839c7")                  # cmp rdi, rax
    E("480f42f8")                # cmovb rdi, rax
    # loop
    loop = len(fixup)
    E("4839f7")                  # cmp rdi, rsi
    jae_at = len(fixup); E("0f8300000000")
    E("803f48"); j1 = len(fixup); E("7500")
    E("807f0189"); j2 = len(fixup); E("7500")
    E("807f02c1"); j3 = len(fixup); E("7500")
    E("807f03e8"); j4 = len(fixup); E("7500")
    E("c64702c2")                # mov byte [rdi+2], 0xC2  PATCH
    E("eb00"); js = len(fixup)-1 # jmp skip (done)
    nxt = len(fixup)
    E("48ffc7")                  # inc rdi
    jl_loop = len(fixup); E("eb00")
    sk = len(fixup)
    E("4883c420")                # add rsp,0x20
    e9_at = len(fixup); E("e900000000")
    # fixups
    def p32(at, tgt):
        struct.pack_into("<i", fixup, at+2, tgt - (at+6))
    def p8(at, tgt):
        fixup[at+1] = (tgt - (at+2)) & 0xff
    p32(jl_small, sk)
    p32(jae_at, sk)
    p8(j1, nxt); p8(j2, nxt); p8(j3, nxt); p8(j4, nxt)
    fixup[js] = (sk - (js+1)) & 0xff
    fixup[jl_loop+1] = (loop - (jl_loop+2)) & 0xff
    struct.pack_into("<i", fixup, e9_at+1, end_r - (base_r + e9_at + 5))
    return fixup

P("\n=== A default-path fixup @57bbae (data=ctx+0x2790030, u32 len) ===")
fix = build_fixup(use_alt=False, scan_back=0x100)
pad = 0x57bd4e - 0x57bbae - len(fix)
P(f"  plant len={len(fix)} pad={pad}")
assert pad >= 0, pad
pe = bytearray(base)
pe[rva2off(pe,secs,0x57bbae):rva2off(pe,secs,0x57bd4e)] = fix + b"\x90"*pad
h = save(pe, "host_967_fix17a.exe")
rows, outx = gate(h, "fix17a")
if outx: dump_fw(outx.read_bytes(), "fix17a")

P("\n=== B ALT-path fixup @57bbae (data=ctx+0x2fe0030, len@0x2790028) ===")
fix = build_fixup(use_alt=True, scan_back=0x100)
pad = 0x57bd4e - 0x57bbae - len(fix)
P(f"  plant len={len(fix)} pad={pad}")
assert pad >= 0, pad
pe = bytearray(base)
pe[rva2off(pe,secs,0x57bbae):rva2off(pe,secs,0x57bd4e)] = fix + b"\x90"*pad
h = save(pe, "host_967_fix17b.exe")
rows, outx = gate(h, "fix17b")
if outx: dump_fw(outx.read_bytes(), "fix17b")

# C: try BOTH — run default then also scan ALT region (two scans in one plant)
P("\n=== C dual-scan fixup (default then ALT) ===")
fixup = bytearray()
base_r = 0x57bbae; end_r = 0x57bd4e
def E(h): fixup.extend(bytes.fromhex(h) if isinstance(h,str) else h)
def call_abs(target):
    at = base_r+len(fixup); E("e8"+struct.pack("<i",target-(at+5)).hex())
E("4883ec20")
# helper: scan region — inline twice
def emit_scan(data_off_imm, len_field_imm, scan_back=0x100):
    E("488b45e8")                            # rax=ctx
    E("ba"+struct.pack("<I", data_off_imm).hex())  # mov edx, data_off
    E("4863d2"); E("4801d0")                 # data=ctx+off
    E("488985d8fdffff")                      # save data
    E("488b45e8")
    E("ba"+struct.pack("<I", len_field_imm).hex())
    E("4863d2"); E("4801d0")
    E("8b00")                                # eax=[ctx+len_field]
    E("8985e4fdffff")
    E("3d04000000"); jl_s=len(fixup); E("0f8c00000000")
    E("488b85d8fdffff"); E("8b95e4fdffff"); E("4863d2"); E("488d3410")  # rsi=end
    E("4889f7"); E("4881ef"+struct.pack("<I",scan_back).hex())
    E("488b85d8fdffff"); E("4839c7"); E("480f42f8")
    loop=len(fixup)
    E("4839f7"); jae=len(fixup); E("0f8300000000")
    E("803f48"); j1=len(fixup); E("7500")
    E("807f0189"); j2=len(fixup); E("7500")
    E("807f02c1"); j3=len(fixup); E("7500")
    E("807f03e8"); j4=len(fixup); E("7500")
    E("c64702c2")
    # continue scanning (patch all) — fall through
    nxt=len(fixup); E("48ffc7"); jl=len(fixup); E("eb00")
    sk=len(fixup)
    def p32(at,tgt): struct.pack_into("<i",fixup,at+2,tgt-(at+6))
    def p8(at,tgt): fixup[at+1]=(tgt-(at+2))&0xff
    p32(jl_s,sk); p32(jae,sk)
    p8(j1,nxt); p8(j2,nxt); p8(j3,nxt); p8(j4,nxt)
    fixup[jl+1]=(loop-(jl+2))&0xff
    return sk

emit_scan(0x2790030, 0)
emit_scan(0x2fe0030, 0x2790028)
# also try: data = qword[ctx+0] / qword[ctx+8] common layouts (cheap)
# scan if qword looks like pointer (above 0x10000): 
for off in (0, 8, 0x10, 0x18):
    E("488b45e8")
    if off:
        E("488b80"+struct.pack("<I",off).hex())  # mov rax,[rax+off]
    else:
        E("488b00")                              # mov rax,[rax]
    E("488985d8fdffff")
    # sanity: ptr > 0x10000
    E("488b85d8fdffff")
    E("48b91000000000000000")  # mov rcx, 0x10000
    E("4839c8"); jb_at=len(fixup); E("7200")
    # len guess: use dword at ctx+off_len; try ctx+4 or ctx+0x10
    # just scan 0x200 bytes from ptr
    E("488b85d8fdffff"); E("4889c7")          # rdi=start
    E("488dB000020000")                       # rsi=start+0x200
    loop=len(fixup)
    E("4839f7"); jae=len(fixup); E("0f8300000000")
    E("803f48"); j1=len(fixup); E("7500")
    E("807f0189"); j2=len(fixup); E("7500")
    E("807f02c1"); j3=len(fixup); E("7500")
    E("807f03e8"); j4=len(fixup); E("7500")
    E("c64702c2")
    nxt=len(fixup); E("48ffc7"); jl=len(fixup); E("eb00")
    sk=len(fixup)
    def p32(at,tgt): struct.pack_into("<i",fixup,at+2,tgt-(at+6))
    def p8(at,tgt): fixup[at+1]=(tgt-(at+2))&0xff
    fixup[jb_at+1]=(sk-(jb_at+2))&0xff
    p32(jae,sk)
    p8(j1,nxt); p8(j2,nxt); p8(j3,nxt); p8(j4,nxt)
    fixup[jl+1]=(loop-(jl+2))&0xff

E("4883c420")
e9=len(fixup); E("e900000000")
struct.pack_into("<i", fixup, e9+1, end_r-(base_r+e9+5))
pad = end_r - base_r - len(fixup)
P(f"  dual plant len={len(fixup)} pad={pad}")
if pad < 0:
    P("  TOO BIG — trim qword scans")
else:
    pe = bytearray(base)
    pe[rva2off(pe,secs,base_r):rva2off(pe,secs,end_r)] = fixup + b"\x90"*pad
    h = save(pe, "host_967_fix17c.exe")
    rows, outx = gate(h, "fix17c")
    if outx: dump_fw(outx.read_bytes(), "fix17c")

# D: runtime dump of emit_ctx — write first 0x40 bytes of ctx + tried pointers to cave file
P("\n=== D dump emit_ctx via plant (fwrite-ish: write to fixed cave path using CreateFile?) ===")
P("  (skip full dump if A/B/C green; else note for next)")
# Quick: INT3-less probe — plant that sets a global. Skip if time.

P(f"\n=== SUMMARY elapsed={time.time()-t0:.1f}s ===")
