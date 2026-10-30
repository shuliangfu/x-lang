#!/usr/bin/env python3
"""DIG SoftCap 10.60: Capless @1ff2ef / @201eeb|@201f36 parent/slot → +0x478 single-point?
Deadline ≤85s. Isol alt_frame2 only. No plant yet.
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

def e8_dests_in(rva, n=0x200):
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

def find_e8_callers(target, scan_lo, scan_hi):
    """Find E8 sites in [scan_lo, scan_hi) that call target."""
    hits = []
    off0 = rva2off(secs, scan_lo)
    span = scan_hi - scan_lo
    chunk = buf[off0:off0 + span]
    i = 0
    while i < len(chunk) - 5:
        if chunk[i] == 0xE8:
            rel = struct.unpack_from("<i", chunk, i + 1)[0]
            abs_rva = (scan_lo + i + 5) + rel
            if abs_rva == target:
                hits.append(scan_lo + i)
            i += 5
            continue
        i += 1
    return hits

def window_before(call_rva, back=0x40):
    """Disasm back ~back bytes ending at call."""
    start = max(call_rva - back, va)
    insns = disasm_range(start, call_rva - start + 8)
    return [i for i in insns if i.address <= call_rva]

CAPLESS_LO, CAPLESS_HI = 0x576000, 0x578280
FILLS = {0x1f9619, 0x1f9768, 0x1f99b2, 0x1fa9d9, 0x207462, 0x20760b, 0x207aef}
CHAIN = {0x1f70cf, 0x1f93e3, 0x2a5410, 0x2a4f6a, 0x2a5ca8, 0x205068, 0x20374e,
         0x20a948, 0x5d276c, 0x55d730, 0x2a62c9} | FILLS

print(f"=== Isol sha12={sha12} Capless [{hex(CAPLESS_LO)}..{hex(CAPLESS_HI)}) ===\n")

# ---- A) Capless E8 callers of @1ff2ef / @201eeb / @201f36 ----
TARGETS = {
    "1ff2ef_num_args": 0x1ff2ef,
    "201eeb": 0x201eeb,
    "201f36_emit_memcpy": 0x201f36,
}
print("=== A) Capless call sites + arg setup ===")
for name, tgt in TARGETS.items():
    sites = find_e8_callers(tgt, CAPLESS_LO, CAPLESS_HI)
    print(f"\n--- @{tgt:06x} ({name}) Capless E8 sites={ [hex(s) for s in sites] } ---")
    for s in sites:
        print(f"  window @{s:06x}:")
        for insn in window_before(s, 0x50):
            mark = " <<<" if insn.address == s else ""
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# ---- B) @1ff2ef body: ensure side-effect; what is rcx? return? ----
print("\n=== B) @1ff2ef body role (ensure side-effect / rcx / ret) ===")
insns = disasm_range(0x1ff2ef, 0x180)
e8s = e8_dests_in(0x1ff2ef, 0x180)
print(f"  E8 dests={[hex(d) for _,d in e8s]}")
for insn in insns[:40]:
    interesting = any(k in insn.op_str for k in ("rcx", "rax", "0x274", "0x270", "0x100", "0x478")) \
                  or insn.mnemonic in ("call", "ret", "je", "jne", "jmp") \
                  or insn.address in {s for s,_ in e8s}
    if interesting or insn.address < 0x1ff2ef + 0x30:
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Pin: does @1ff2ef call ensure @1f70cf with what rcx?
print("\n  ensure call sites inside @1ff2ef:")
for s, d in e8s:
    if d == 0x1f70cf:
        print(f"  window ensure @{s:06x}:")
        for insn in window_before(s, 0x30):
            mark = " <<<" if insn.address == s else ""
            print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}{mark}")

# ---- C) @201eeb / @201f36 body: parent? slot? kinded? ----
print("\n=== C) @201eeb / @201f36 ABI + kinded touch? ===")
for fn, label in [(0x201eeb, "201eeb"), (0x201f36, "201f36")]:
    print(f"\n--- @{fn:06x} ({label}) ---")
    e8s = e8_dests_in(fn, 0x120)
    print(f"  E8={[hex(d) for _,d in e8s[:12]]}")
    print(f"  chain∩={[hex(d) for _,d in e8s if d in CHAIN]}")
    for insn in disasm_range(fn, 0x60)[:20]:
        print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    # scan for 0x100 / 0x478 / kinded imm
    hits_imm = []
    for insn in disasm_range(fn, 0x120):
        if any(x in insn.op_str for x in ("0x100", "0x478", "0x274", "0x270", "0x568")):
            hits_imm.append(f"@{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
    print(f"  imm hits={hits_imm if hits_imm else 'NONE'}")

# ---- D) Capless +0x478 lifecycle vs these calls ----
print("\n=== D) Capless +0x478 STORE vs call order of targets ===")
# find +0x478 stores and the call sites; order them
events = []
# 0x478 stores in Capless
off_c = rva2off(secs, CAPLESS_LO)
chunk_c = buf[off_c:off_c + (CAPLESS_HI - CAPLESS_LO)]
# scan for disp 0x478 in Capstone
for insn in md.disasm(chunk_c, CAPLESS_LO):
    if "0x478" in insn.op_str:
        events.append((insn.address, f"478:{insn.mnemonic} {insn.op_str}"))
    if insn.mnemonic == "call":
        # resolve
        if insn.bytes[0] == 0xE8 and len(insn.bytes) >= 5:
            rel = struct.unpack_from("<i", insn.bytes, 1)[0]
            dest = insn.address + 5 + rel
            if dest in TARGETS.values() or dest in (0x55d730, 0x2be519, 0x57b98c):
                events.append((insn.address, f"call @{dest:06x}"))

events.sort()
for a, s in events:
    print(f"  @{a:06x}: {s}")

# ---- E) After @1ff2ef ensure: is CallExpr node now kinded? usable for fill? ----
print("\n=== E) Post-@1ff2ef: does Capless use ensure result / kinded slot? ===")
# Capless after each @1ff2ef call: next 0x40 bytes
sites_1ff = find_e8_callers(0x1ff2ef, CAPLESS_LO, CAPLESS_HI)
for s in sites_1ff:
    print(f"\n  after @{s:06x}+5:")
    for insn in disasm_range(s + 5, 0x40)[:14]:
        print(f"    @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# ---- F) Can single plant connect? Check for:
# 1) existing fill E8 near Capless that we could retarget
# 2) existing push @2a4f6a near
# 3) whether @201f36 output buffer IS a kinded slot (NO — it's memcpy to node+0x20)
# 4) whether rcx at @1ff2ef is the SoftCap lit CallExpr (yes from prior) and has slot after ensure
print("\n=== F) Single-point feasibility checks ===")

# F1: Capless E8 ∩ CHAIN (full)
cap_e8 = e8_dests_in(CAPLESS_LO, CAPLESS_HI - CAPLESS_LO)
cap_chain = [(hex(s), hex(d)) for s, d in cap_e8 if d in CHAIN]
print(f"  Capless E8∩CHAIN={cap_chain if cap_chain else 'NONE (expected: only alloc/num_args etc outside CHAIN set?)'}")
# broaden: any Capless E8 to fill-ish / push / unwrap
MORE = set(range(0x1f6000, 0x210000)) | set(range(0x2a4000, 0x2a8000)) | {0x5d276c, 0x20a948}
cap_more = [(hex(s), hex(d)) for s, d in cap_e8 if d in MORE or d in CHAIN]
# filter to interesting
interesting_dests = []
for s, d in cap_e8:
    if d in CHAIN or d in FILLS or (0x1f7000 <= d <= 0x1fb000) or (0x2a4000 <= d <= 0x2a8000):
        interesting_dests.append((hex(s), hex(d)))
print(f"  Capless E8∩(fill/ensure/push/unwrap band)={interesting_dests}")

# F2: @201f36 — is rcx SoftCap CallExpr node? What does it write?
# From prior: lea rcx,[rbp+0x60] buf; edx=idx; rcx=[rbp+0x490] node; r8=buf; memcpy node+0x20 size+0x120
# That is FIELD memcpy into node, NOT kinded-slot fill, NOT +0x478 push
print("""
  @201f36 (prior+this): memcpy into CallExpr node fields (+0x20/+0x120) — NOT kinded fill, NOT +0x478.
  @201eeb: sibling helper (see E8/imm) — expect same class (field/size), not fill.
  @1ff2ef: num_args_at(+0x274); side-effect ensure @1f70cf on parent=CallExpr node.
           Returns count/status; Capless uses return as gate (cmp/jcc), NEVER feeds fill/push/+0x478.
""")

# F3: Does ensure on SoftCap lit CallExpr create a slot that fill could use?
# ensure @1f70cf only ensures kinded table entry exists; does NOT write [slot+0x100] size.
# fill is separate. Capless never calls fill after ensure.
print("  ensure≠fill: @1f70cf creates/looks up kinded entry; [slot+0x100] written ONLY by fill-fam.")
print("  Capless post-ensure: no fill E8, no unwrap, no push, no +0x478 mutate.")

# F4: Is there a single cave that could: take ensure'd parent + SoftCap lit imm → fill → push +0x478?
# That would be multi-API mega/arg-loop — banned.
print("  Single-point plant needing fill+unwrap+push = mega/arg-loop (BAN).")
print("  Hijack existing Capless E8 to fill: Capless has ZERO fill E8 to hijack.")
print("  Retarget @201f36 output into +0x478: output is in-node field memcpy, wrong shape for @2a62c9 vec.")

# ---- G) Slot existence on SoftCap lit CallExpr parent after ensure ----
print("\n=== G) SoftCap lit CallExpr as kinded parent — slot usable? ===")
# Look at @1f70cf briefly: what it returns / whether Capless could read a slot
e8s_ens = e8_dests_in(0x1f70cf, 0x100)
print(f"  @1f70cf E8={[hex(d) for _,d in e8s_ens[:10]]}")
for insn in disasm_range(0x1f70cf, 0x50)[:16]:
    print(f"  @{insn.address:06x}: {insn.mnemonic} {insn.op_str}")

# Capless: any load of kinded slot after @1ff2ef? (look for call @20374e / @1f77e1 / [+0x100])
print("\n  Capless loads of kinded-slot APIs:")
slot_apis = {0x20374e, 0x1f77e1, 0x1f61f7, 0x1f93e3, 0x1f70cf}
for s, d in cap_e8:
    if d in slot_apis:
        print(f"    @{s:06x} → @{d:06x}")
print(f"  Capless→slot_apis count={sum(1 for _,d in cap_e8 if d in slot_apis)}")

# +0x100 stores in Capless?
plus100 = []
for insn in md.disasm(chunk_c, CAPLESS_LO):
    if "0x100" in insn.op_str and insn.mnemonic in ("mov", "lea", "cmp", "add", "sub"):
        plus100.append(f"@{insn.address:06x}: {insn.mnemonic} {insn.op_str}")
print(f"  Capless 0x100 refs (first 12)={plus100[:12]}")

print("\n=== VERDICT ===")
print("""
Q: Capless-already-called @1ff2ef gate / @201eeb|@201f36 parent/slot → single-point +0x478 fill?

1. @1ff2ef: Capless calls it (num_args gate). Side-effect ensure @1f70cf on CallExpr parent.
   - Parent IS SoftCap lit CallExpr (kinded-capable after ensure).
   - BUT Capless NEVER reads kinded slot / NEVER fill / NEVER push into +0x478.
   - ensure alone ≠ filled emit-arg; [slot+0x100] still empty without fill-fam.
   - Return value used only as gate (count/status). Cannot single-point "connect ensure→+0x478".

2. @201eeb / @201f36: Capless calls them; they memcpy SoftCap lit fields into CallExpr node
   (+0x20/+0x120 class). NOT kinded-slot fill. NOT +0x478 vec push. Wrong object shape
   for @2a5ca8/@2a62c9. Retargeting their dst into +0x478 = wrong ABI (BAN-adjacent / red).

3. Capless E8∩fill/unwrap/push/@2a5410/@2a4f6a = 0. No hijackable E8.
   Wiring ensure'd parent → fill → unwrap → push +0x478 = multi-call mega/arg-loop (BAN).

⇒ plant slot_478 / f36_push: NOT isolatable.
⇒ Capless parent MAY be kinded-capable after @1ff2ef ensure, but has NO filled slot and
   NO single-point path from existing Capless calls into +0x478.
⇒ Frontier still RED. Next: find Isol-native SoftCap path that already produces a
   @2a62c9-compatible filled vec (or single Isol E8 that does fill+push for lit CallExpr),
   without Capless mega glue. Or falsify that such Isol-native path exists at all for SoftCap lit.
""")
print(f"DONE {time.time()-T0:.1f}s")
if time.time() > DEADLINE:
    print("WARN over deadline")
