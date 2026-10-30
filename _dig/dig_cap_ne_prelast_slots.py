#!/usr/bin/env python3
"""DIG SoftCap 10.60: Cap≠Capless path OR pre_last other slots with hetero FILLED @2a62c9-compat containers?
Deadline ≤85s. Isol alt_frame2 only. Ban tip@121278/join/epi/LIVE/mega/arg-loop/glue=mega.
Verdict: if none → nail 'no non-empty-shell supply'.
"""
from pathlib import Path
import struct, hashlib, time, sys
from capstone import Cs, CS_ARCH_X86, CS_MODE_64

T0 = time.time()
DEADLINE = T0 + 85

ISOL = Path("/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe")
buf = ISOL.read_bytes()
sha12 = hashlib.sha256(buf).hexdigest()[:12]
assert sha12 == "9378df517f96", sha12

def pe_secs(b):
    e = struct.unpack_from("<I", b, 0x3C)[0]
    nsec = struct.unpack_from("<H", b, e + 6)[0]
    opt = struct.unpack_from("<H", b, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(b[o:o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", b, o + 8)
        out[n] = (va, vs, ro, rs)
    return out

def rva2off(secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))

secs = pe_secs(buf)
va, vs, ro, rs = secs[b".text"]
raw = buf[ro:ro + rs]
md = Cs(CS_ARCH_X86, CS_MODE_64)
md.detail = True

def disasm_range(rva, n=0x80):
    off = rva2off(secs, rva)
    return list(md.disasm(buf[off:off + n], rva))

def find_e8_callers_all(target):
    hits = []
    i = 0
    while i < len(raw) - 5:
        if raw[i] == 0xE8:
            rel = struct.unpack_from("<i", raw, i + 1)[0]
            abs_rva = (va + i + 5) + rel
            if abs_rva == target:
                hits.append(va + i)
            i += 5
            continue
        i += 1
    return hits

def e8_dests_in(rva, n):
    off = rva2off(secs, rva)
    chunk = buf[off:off + n]
    out = []
    i = 0
    while i < len(chunk) - 5:
        if chunk[i] == 0xE8:
            rel = struct.unpack_from("<i", chunk, i + 1)[0]
            abs_rva = (rva + i + 5) + rel
            if va <= abs_rva < va + vs:
                out.append((rva + i, abs_rva))
            i += 5
            continue
        i += 1
    return out

def window_before(call_rva, back=0x40):
    start = max(call_rva - back, va)
    insns = disasm_range(start, call_rva - start + 8)
    return [i for i in insns if i.address <= call_rva]

def time_ok():
    return time.time() < DEADLINE

# Known
LEN = 0x2a62c9
GETELEM = 0x2a5ca8
PUSH = 0x2a4f6a
UNWRAP = 0x2a5410
ALLOC_568 = 0x55d730
SOFTCAP_SITE = 0x2be519
PRE_LAST = 0x567a30
CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
# Cap region guesses from prior DIGs (SoftCap CapFN / Cap path)
# Capless entry @57656c; SoftCap-site callers @2be40f + Capless @576692
FILL_FAM = {0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9, 0x207462, 0x20760b, 0x207aef}
ENSURE = 0x1f70cf

print(f"=== Isol sha12={sha12} DIG Cap≠Capless / pre_last other filled slots ===\n")

# ========== A) Cap≠Capless: SoftCap-site callers + Cap dispatch ==========
print("=== A) Cap≠Capless — SoftCap-site @2be519 callers / Cap vs Capless ===")
site_callers = find_e8_callers_all(SOFTCAP_SITE)
print(f"  SoftCap-site callers={[hex(c) for c in site_callers]} count={len(site_callers)}")
for c in site_callers:
    in_capless = CAPLESS_LO <= c < CAPLESS_HI
    print(f"  --- caller @{c:06x} Capless?={in_capless} ---")
    for insn in window_before(c, 0x50):
        mark = " <<<" if insn.address == c else ""
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
    # who calls this caller?
    parents = find_e8_callers_all(c) if not in_capless else []
    # for Capless caller, find Capless entry callers instead
    if in_capless:
        print(f"    (inside Capless; skip parent of mid-site)")
    else:
        print(f"    parents of non-Capless caller: {[hex(p) for p in parents[:20]]} count={len(parents)}")
        for p in parents[:8]:
            print(f"    --- parent @{p:06x} ---")
            for insn in window_before(p, 0x30):
                mark = " <<<" if insn.address == p else ""
                print(f"      @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# Capless entry external callers
print("\n=== A2) Capless entry @57656c external callers (Cap≠Capless dispatch?) ===")
# Find Capless function start: look for push rbp near 57656c
capless_entry = 0x57656c
# Scan for push rbp / common prologue near Capless
for cand in [0x57656c, 0x576000, 0x576500, 0x576550]:
    insns = disasm_range(cand, 0x20)
    print(f"  @{cand:06x}: {insns[0].mnemonic} {insns[0].op_str}" if insns else f"  @{cand:06x}: empty")

# Find E8→@57656c and nearby Capless prologues
for entry_guess in [0x57656c, 0x576519, 0x5764f0, 0x576480]:
    callers = find_e8_callers_all(entry_guess)
    if callers:
        print(f"  E8→@{entry_guess:06x}: {[hex(c) for c in callers[:25]]} count={len(callers)}")

# Broader: any external jump/call into Capless that is NOT from Capless itself
print("\n=== A3) All external E8 into Capless band (entry points) ===")
ext_into = []
i = 0
while i < len(raw) - 5:
    if raw[i] == 0xE8:
        rel = struct.unpack_from("<i", raw, i + 1)[0]
        src = va + i
        dst = src + 5 + rel
        if CAPLESS_LO <= dst < CAPLESS_HI and not (CAPLESS_LO <= src < CAPLESS_HI):
            ext_into.append((src, dst))
        i += 5
        continue
    i += 1
# group by dest
from collections import Counter, defaultdict
by_dst = defaultdict(list)
for s, d in ext_into:
    by_dst[d].append(s)
print(f"  unique Capless entry dests={len(by_dst)} total_ext_calls={len(ext_into)}")
for d, srcs in sorted(by_dst.items(), key=lambda x: -len(x[1]))[:15]:
    print(f"  Capless-entry @{d:06x} from {[hex(s) for s in srcs[:12]]} n={len(srcs)}")

# ========== B) Cap path that reaches SoftCap lit WITHOUT Capless? ==========
print("\n=== B) Does non-Capless SoftCap-site caller (@2be40f) fill +0x478 / push / fill-fam? ===")
# Disasm @2be40f function body roughly 0x200
fn = 0x2be40f
# find prologue back
for back in range(0, 0x80, 4):
    ins = disasm_range(fn - back, 8)
    if ins and ins[0].mnemonic == "push" and "rbp" in ins[0].op_str:
        fn = fn - back
        break
print(f"  approx fn start @{fn:06x}")
e8s = e8_dests_in(fn, 0x300)
dests = sorted({d for _, d in e8s})
print(f"  E8 dests in @2be40f±0x300: {[hex(d) for d in dests]}")
interesting = [d for d in dests if d in FILL_FAM or d in (PUSH, UNWRAP, LEN, GETELEM, ALLOC_568, ENSURE, SOFTCAP_SITE, 0x55d730)]
print(f"  ∩ fill/push/unwrap/len/get/alloc/ensure/site: {[hex(d) for d in interesting]}")
# Also check if @2be40f stores anything like +0x478 or prepares args vec
print("  body sample (first 40):")
for insn in disasm_range(fn, 0x120)[:40]:
    print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# ========== C) pre_last: ALL @2a62c9 / get-elem / arg-slot STOREs ==========
print("\n=== C) pre_last @567a30..@569000 — ALL @2a62c9 / @2a5ca8 / arg slot stores ===")
PRE_LO, PRE_HI = 0x567a30, 0x569800
pre_len_calls = [c for c in find_e8_callers_all(LEN) if PRE_LO <= c < PRE_HI]
pre_get_calls = [c for c in find_e8_callers_all(GETELEM) if PRE_LO <= c < PRE_HI]
pre_push = [c for c in find_e8_callers_all(PUSH) if PRE_LO <= c < PRE_HI]
pre_unwrap = [c for c in find_e8_callers_all(UNWRAP) if PRE_LO <= c < PRE_HI]
print(f"  @2a62c9 in pre_last={[hex(c) for c in pre_len_calls]}")
print(f"  @2a5ca8 in pre_last={[hex(c) for c in pre_get_calls]}")
print(f"  push in pre_last={[hex(c) for c in pre_push]}")
print(f"  unwrap in pre_last={[hex(c) for c in pre_unwrap]}")

for c in pre_len_calls:
    print(f"  --- len @{c:06x} ---")
    for insn in window_before(c, 0x50):
        mark = " <<<" if insn.address == c else ""
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# Scan pre_last for mov from [rbp+N] that look like arg slots (arg0..arg5 = +0x10..+0x30?)
# and STOREs to [rbp-0xXX] locals that later feed @2a62c9
print("\n=== C2) pre_last arg-slot loads (rbp+0x10..+0x38) and local container stores ===")
# Disassemble pre_last first 0x200 for arg copies
arg_loads = []
local_stores = []
for insn in disasm_range(PRE_LAST, 0x200):
    op = insn.op_str
    if insn.mnemonic == "mov" and "rbp +" in op:
        # load from arg area?
        if any(f"rbp + 0x{k:x}" in op or f"rbp + {k}" in op for k in range(0x10, 0x40, 8)):
            arg_loads.append((insn.address, op))
    if insn.mnemonic == "mov" and op.startswith("qword ptr [rbp") and ", " in op:
        # store to local
        dst, src = op.split(", ", 1)
        if "rbp -" in dst or "rbp +" in dst:
            local_stores.append((insn.address, op))

print(f"  arg-area loads (first 30):")
for a, op in arg_loads[:30]:
    print(f"    @{a:06x}: mov {op}")
print(f"  local stores in first 0x200 (first 40):")
for a, op in local_stores[:40]:
    print(f"    @{a:06x}: mov {op}")

# ========== D) Hetero filled containers: who produces FILLED vec that SoftCap lit could retarget? ==========
print("\n=== D) Hetero sources — callers of @2a62c9 whose rcx is NOT Capless +0x478 empty shell ===")
# For SoftCap lit path, the ONLY consumer in pre_last is @56888d with [rbp-0x30]<-arg5<-+0x478
# Question: are there OTHER slots in pre_last frame that ALSO call len/get-elem on a DIFFERENT container?
# Expand: scan ALL mov rcx, [rbp±X] before @2a62c9 in pre_last band — only one known.
# Also check if pre_last has other @2a62c9 outside the softcap-lit arg0 path (e.g. for other kinds)

# Broader pre_last E8 inventory
print("\n=== D2) pre_last E8 inventory (classify) ===")
all_e8 = e8_dests_in(PRE_LO, PRE_HI - PRE_LO)
dest_counts = Counter(d for _, d in all_e8)
# print top dests
print(f"  pre_last E8 count={len(all_e8)} unique_dests={len(dest_counts)}")
for d, n in dest_counts.most_common(25):
    tag = ""
    if d == LEN: tag = " LEN"
    elif d == GETELEM: tag = " GETELEM"
    elif d == PUSH: tag = " PUSH"
    elif d == UNWRAP: tag = " UNWRAP"
    elif d in FILL_FAM: tag = " FILL"
    elif d == ALLOC_568: tag = " ALLOC568"
    elif d == ENSURE: tag = " ENSURE"
    print(f"    dest @{d:06x} n={n}{tag}")

# ========== E) Cap path CapFN / SoftCap Cap that bypasses Capless empty shell ==========
print("\n=== E) Cap≠Capless — CapFN / Cap CallExpr emitters that reach pre_last with filled args? ===")
# Prior knowledge: Capless @578200 calls pre_last. Who else calls pre_last?
pre_callers = find_e8_callers_all(PRE_LAST)
print(f"  E8→pre_last@567a30: {[hex(c) for c in pre_callers]} count={len(pre_callers)}")
for c in pre_callers:
    in_c = CAPLESS_LO <= c < CAPLESS_HI
    print(f"  --- @{c:06x} Capless?={in_c} ---")
    for insn in window_before(c, 0x60):
        mark = " <<<" if insn.address == c else ""
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")
    # What is loaded into arg5 (rsp+0x20) before call?
    # Look for mov to [rsp+0x20] or similar in window

# Also find callers that jump (E9) to pre_last
print("\n=== E2) E9 jmp → pre_last ===")
e9_hits = []
i = 0
while i < len(raw) - 5:
    if raw[i] == 0xE9:
        rel = struct.unpack_from("<i", raw, i + 1)[0]
        src = va + i
        dst = src + 5 + rel
        if dst == PRE_LAST:
            e9_hits.append(src)
        i += 5
        continue
    i += 1
print(f"  E9→pre_last: {[hex(c) for c in e9_hits]}")

# ========== F) pre_last OTHER slots: scan [rbp-0xXX] that feed len — is only -0x30? ==========
print("\n=== F) All rcx sources into @2a62c9 in pre_last — hetero? ===")
for c in pre_len_calls:
    win = window_before(c, 0x80)
    rcx_srcs = []
    for insn in win:
        if insn.mnemonic == "mov" and insn.op_str.startswith("rcx,"):
            rcx_srcs.append((insn.address, insn.op_str))
        if insn.mnemonic == "mov" and "rax," in insn.op_str and "rbp" in insn.op_str:
            rcx_srcs.append((insn.address, insn.op_str + " (maybe via rax)"))
    print(f"  @{c:06x} rcx/rax-from-rbp chain:")
    for a, op in rcx_srcs[-8:]:
        print(f"    @{a:06x}: {op}")

# Scan entire pre_last for OTHER containers: look for mov rcx,[rbp-XX] then call len/get elsewhere
print("\n=== F2) pre_last: every call @2a62c9/@2a5ca8 with preceding [rbp±] load (full band) ===")
# Already have pre_len_calls and pre_get_calls
for kind, calls in [("LEN", pre_len_calls), ("GET", pre_get_calls)]:
    for c in calls:
        # find nearest preceding mov rcx / mov rax from mem
        win = list(disasm_range(c - 0x40, 0x48))
        mems = []
        for insn in win:
            if insn.address >= c:
                break
            if "rbp" in insn.op_str and insn.mnemonic in ("mov", "lea"):
                mems.append(f"@{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
        print(f"  {kind} @{c:06x} nearby rbp ops:")
        for m in mems[-6:]:
            print(f"    {m}")

# ========== G) Cap path: is there a Cap (non-Capless) that stores filled vec to a pre_last arg slot? ==========
print("\n=== G) Who STOREs into pre_last arg slots (caller-side [rsp+0x20]=arg5 etc)? ===")
# Capless @578200 known. Any Cap/other caller of pre_last that stores different arg5?
for c in pre_callers:
    print(f"  caller @{c:06x}: looking for [rsp+0x20]/[rsp+0x28] stores in ±0x80")
    for insn in disasm_range(max(c - 0x80, va), 0x90):
        if insn.address > c:
            break
        if "rsp +" in insn.op_str and insn.mnemonic == "mov" and insn.op_str.startswith("qword ptr [rsp"):
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
        if "rbp +" in insn.op_str and "0x478" in insn.op_str:
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}  <<+0x478")

# ========== H) VERDICT ==========
print("\n=== H) VERDICT ===")
non_capless_site = [c for c in site_callers if not (CAPLESS_LO <= c < CAPLESS_HI)]
capless_site = [c for c in site_callers if CAPLESS_LO <= c < CAPLESS_HI]
pre_callers_non_capless = [c for c in pre_callers if not (CAPLESS_LO <= c < CAPLESS_HI)]
print(f"  SoftCap-site Capless callers={[hex(c) for c in capless_site]}")
print(f"  SoftCap-site NON-Capless callers={[hex(c) for c in non_capless_site]}")
print(f"  pre_last callers Capless={[hex(c) for c in pre_callers if CAPLESS_LO <= c < CAPLESS_HI]}")
print(f"  pre_last callers NON-Capless={[hex(c) for c in pre_callers_non_capless]}")
print(f"  @2a62c9 sites in pre_last={[hex(c) for c in pre_len_calls]} (expect only softcap-lit empty)")
print(f"  @2a5ca8 sites in pre_last={[hex(c) for c in pre_get_calls]}")
print(f"  elapsed={time.time()-T0:.1f}s")
print("=== DONE ===")
sys.stdout.flush()
