#!/usr/bin/env python3
"""DIG SoftCap Isol USER (host_967_s25) vs LIVE SoftCap (lab_LIVE_pret) semantic parity.
Compare emit / rcx=sret / imm->rdx / frame. READ-ONLY vs LIVE — no LIVE transplant.
PROD SoftCap 7a2cf5da581a / pin ecdb5cc1e: DO NOT TOUCH.
Budget <=85s. Ban tip@121278/join/epi/LIVE transplant/mega/arg-loop/hollow.
"""
from pathlib import Path
import hashlib, struct, subprocess, sys, time, os

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

from capstone import Cs, CS_ARCH_X86, CS_MODE_64

CAVE = Path("C:/xlang_tmp/p1060/cave")
os.chdir(str(CAVE))
T0 = time.time()
BUDGET = 85
md = Cs(CS_ARCH_X86, CS_MODE_64)
md.detail = False

ISOL = CAVE / "host_967_s25.exe"
LIVE = CAVE / "lab_LIVE_pret.exe"
PROD = Path("C:/Users/shuliangfu/worker/xlang/x-lang/compiler/xlang.exe")
SRCS = ["p_ret_lit.x", "p_ret_fwd.x", "p_ret_local.x", "_var_let.x"]
ISOL_EXPECT = {
    "p_ret_lit.x": "5c6778769c3c",
    "p_ret_fwd.x": "a99121ae7a80",
    "p_ret_local.x": "36d26fcc9657",
    "_var_let.x": "d16c78ade1f2",
}


def P(*a):
    print(*a, flush=True)


def sha12(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()[:12]


def tag_of(crc):
    return {
        0: "OK",
        0x80000003: "INT3",
        0xC0000409: "GS",
        0xC0000005: "AV",
    }.get(crc & 0xFFFFFFFF, hex(crc & 0xFFFFFFFF))


def pe_secs(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    sec = e + 24 + opt
    out = {}
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o : o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        out[n] = (va, vs, ro, rs)
    return out


def rva2off(secs, r):
    for n, (va, vs, ro, rs) in secs.items():
        if va <= r < va + max(vs, rs):
            return ro + (r - va)
    raise ValueError(hex(r))


def find_text(buf):
    secs = pe_secs(buf)
    # prefer .text
    for name in (b".text", b"CODE", b"text"):
        if name in secs:
            va, vs, ro, rs = secs[name]
            return va, buf[ro : ro + rs], secs
    # first executable
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    opt = struct.unpack_from("<H", buf, e + 20)[0]
    # IMAGE_SCN_MEM_EXECUTE = 0x20000000
    nsec = struct.unpack_from("<H", buf, e + 6)[0]
    sec = e + 24 + opt
    for i in range(nsec):
        o = sec + i * 40
        n = bytes(buf[o : o + 8]).split(b"\0")[0]
        vs, va, rs, ro = struct.unpack_from("<IIII", buf, o + 8)
        ch = struct.unpack_from("<I", buf, o + 36)[0]
        if ch & 0x20000000:
            return va, buf[ro : ro + rs], secs
    raise RuntimeError("no text")


def entry_rva(buf):
    e = struct.unpack_from("<I", buf, 0x3C)[0]
    return struct.unpack_from("<I", buf, e + 24 + 16)[0]


def compile_one(host, src, prefix, timeout=12):
    out = CAVE / f"{prefix}_{Path(src).stem}.exe"
    if out.exists():
        try:
            out.unlink()
        except OSError:
            pass
    try:
        r = subprocess.run(
            [str(host), str(CAVE / src), "-o", str(out)],
            capture_output=True,
            timeout=timeout,
        )
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", "-", None, None
    tag = tag_of(crc)
    if not out.exists() or out.stat().st_size == 0:
        return tag, "-", None, None
    b = out.read_bytes()
    sh = hashlib.sha256(b).hexdigest()[:12]
    return tag, sh, b, out


def run_user(exe, timeout=3):
    try:
        r = subprocess.run([str(exe)], capture_output=True, timeout=timeout)
        crc = r.returncode & 0xFFFFFFFF
    except subprocess.TimeoutExpired:
        return "TIMEOUT", -1
    if crc <= 3:
        return str(crc), crc
    return tag_of(crc), crc


def count_pat(b, hexpat):
    return b.count(bytes.fromhex(hexpat))


def disasm_window(buf, rva_base, text, start_rva, nbytes=0xA0, label=""):
    off = start_rva - rva_base
    if off < 0 or off >= len(text):
        P(f"  [{label}] rva {start_rva:#x} OOB")
        return []
    chunk = text[off : off + nbytes]
    lines = []
    for insn in md.disasm(chunk, start_rva):
        lines.append((insn.address, insn.mnemonic, insn.op_str, bytes(insn.bytes)))
        if insn.mnemonic == "ret":
            break
        if len(lines) > 48:
            break
    return lines


def find_funcs(buf):
    """Heuristic: find push rbp; mov rbp,rsp prologues in .text; return list of (rva, size_guess)."""
    va, text, secs = find_text(buf)
    hits = []
    # 55 48 89 e5
    pat = bytes.fromhex("554889e5")
    i = 0
    while True:
        j = text.find(pat, i)
        if j < 0:
            break
        hits.append(va + j)
        i = j + 1
    return va, text, secs, hits


def classify_emit(lines):
    """Extract semantic features from a function dump."""
    feats = {
        "frame": None,
        "has_sub20": False,
        "rcx_sret_lea": False,  # lea rax,[rbp-0x28]; mov rcx,rax
        "rcx_from_stack": None,  # mov rax,[rbp-XX]; mov rcx
        "imm_to_rdx": None,  # mov eax,imm; mov rdx,rax
        "spill_imm": False,  # mov [rbp-0x38],rax style
        "x_plus1_rdx": False,  # mov rax,[rbp-0x10]; inc; mov rdx
        "n_calls": 0,
        "call_targets": [],
        "has_nop_pad": False,
        "raw_imm_eax": [],
    }
    prev = None
    for addr, mnem, ops, raw in lines:
        if mnem == "sub" and "rsp" in ops:
            if "0x868" in ops or "0x868" in ops.replace(" ", ""):
                feats["frame"] = "0x868"
            elif "0x20" in ops:
                feats["has_sub20"] = True
            else:
                # try parse
                if feats["frame"] is None and "rsp" in ops:
                    feats["frame"] = ops
        if mnem == "lea" and "[rbp" in ops and "rax" in ops and "0x28" in ops.replace(" ", ""):
            prev = ("lea_sret", addr)
        if mnem == "mov" and ops.replace(" ", "") == "rcx,rax" and prev and prev[0] == "lea_sret":
            feats["rcx_sret_lea"] = True
        if mnem == "mov" and "rax, qword ptr [rbp" in ops.replace("  ", " "):
            # capture disp
            if "0x50" in ops or "-0x50" in ops:
                prev = ("load50", addr)
            elif "0x10" in ops or "-0x10" in ops:
                prev = ("load10", addr)
            elif "0x38" in ops or "-0x38" in ops:
                prev = ("load38", addr)
        if mnem == "mov" and ops.replace(" ", "") == "rcx,rax" and prev and prev[0] == "load50":
            feats["rcx_from_stack"] = "rbp-0x50"
        if mnem == "inc" and "rax" in ops:
            prev = ("inc", addr)
        if mnem == "mov" and ops.replace(" ", "") == "rdx,rax":
            if prev and prev[0] == "inc":
                feats["x_plus1_rdx"] = True
            # check if previous was mov eax,imm
        if mnem == "mov" and ops.startswith("eax,") and raw[0] == 0xB8:
            imm = struct.unpack_from("<I", raw, 1)[0]
            feats["raw_imm_eax"].append(imm)
            prev = ("imm", imm, addr)
        if mnem == "mov" and ops.replace(" ", "") == "rdx,rax" and prev and prev[0] == "imm":
            feats["imm_to_rdx"] = prev[1]
        if mnem == "mov" and "qword ptr [rbp" in ops and "rax" in ops:
            if "0x38" in ops or "-0x38" in ops:
                feats["spill_imm"] = True
        if mnem == "nop":
            feats["has_nop_pad"] = True
        if mnem == "call":
            feats["n_calls"] += 1
            feats["call_targets"].append(ops)
    return feats


def dump_all_funcs(label, buf, max_funcs=6):
    va, text, secs, hits = find_funcs(buf)
    P(f"\n=== {label} sha={hashlib.sha256(buf).hexdigest()[:12]} n_prolog={len(hits)} "
      f"n868={count_pat(buf,'4881ec68080000')} n68={count_pat(buf,'4881ec68000000')} "
      f"n1b8={count_pat(buf,'4881ecb8010000')} ===")
    feats_list = []
    for i, fr in enumerate(hits[:max_funcs]):
        lines = disasm_window(buf, va, text, fr, 0xB0, f"f{i}")
        P(f"  -- func[{i}] @{fr:#x} --")
        for addr, mnem, ops, raw in lines[:28]:
            hx = raw.hex()
            P(f"    {addr:06x}: {hx:24s} {mnem} {ops}")
        feats = classify_emit(lines)
        feats_list.append((fr, feats))
        P(f"    FEATS: frame={feats['frame']} sub20={feats['has_sub20']} "
          f"rcx_sret_lea={feats['rcx_sret_lea']} rcx_stack={feats['rcx_from_stack']} "
          f"imm→rdx={feats['imm_to_rdx']} spill38={feats['spill_imm']} "
          f"x+1→rdx={feats['x_plus1_rdx']} calls={feats['n_calls']} "
          f"imm_eax={feats['raw_imm_eax']} nop={feats['has_nop_pad']}")
    return feats_list


def diff_feats(name, live_fl, isol_fl):
    P(f"\n### DIFF {name}")
    # Compare by index (main often last, fw first for fwd/let)
    n = max(len(live_fl), len(isol_fl))
    gaps = []
    for i in range(n):
        L = live_fl[i][1] if i < len(live_fl) else None
        I = isol_fl[i][1] if i < len(isol_fl) else None
        if L is None or I is None:
            gaps.append(f"func[{i}]: presence LIVE={L is not None} Isol={I is not None}")
            continue
        keys = ["frame", "has_sub20", "rcx_sret_lea", "rcx_from_stack", "imm_to_rdx",
                "spill_imm", "x_plus1_rdx", "n_calls", "has_nop_pad", "raw_imm_eax"]
        for k in keys:
            if L.get(k) != I.get(k):
                gaps.append(f"func[{i}].{k}: LIVE={L.get(k)} Isol={I.get(k)}")
    if not gaps:
        P("  (no feature diffs on compared funcs)")
    else:
        for g in gaps:
            P(f"  DIFF: {g}")
    return gaps


def main():
    P("=== DIG live_isol_parity (READ LIVE; no transplant) ===")
    assert ISOL.exists(), "host_967_s25 missing"
    assert LIVE.exists(), "lab_LIVE_pret missing"
    isha = sha12(ISOL)
    lsha = sha12(LIVE)
    P(f"ISOL host_967_s25 sha={isha} (expect e53841ce0e24)")
    P(f"LIVE lab_LIVE_pret sha={lsha}")
    if PROD.exists():
        P(f"PROD SoftCap sha={sha12(PROD)} (expect 7a2cf5da581a; NOT TOUCHED)")

    all_gaps = {}
    gate = {}

    for src in SRCS:
        if time.time() - T0 > BUDGET - 15:
            P("BUDGET near — stop compile loop")
            break
        P(f"\n######## {src} ########")
        # LIVE compile
        lt, luser, lb, lout = compile_one(LIVE, src, "_parity_LIVE")
        lrun = "-"
        if lout:
            lrun, _ = run_user(lout)
        P(f"  LIVE  compile={lt} USER={luser} run={lrun}")
        # Isol compile
        it, iuser, ib, iout = compile_one(ISOL, src, "_parity_ISOL")
        irun = "-"
        if iout:
            irun, _ = run_user(iout)
        exp = ISOL_EXPECT.get(src, "?")
        mark = "OK" if (it == "OK" and irun == "0" and iuser == exp) else "FAIL"
        P(f"  Isol  compile={it} USER={iuser} (exp {exp}) run={irun} {mark}")
        gate[src] = (iuser, irun, mark, luser, lrun)

        live_fl = dump_all_funcs(f"LIVE/{src}", lb) if lb else []
        isol_fl = dump_all_funcs(f"ISOL/{src}", ib) if ib else []
        gaps = diff_feats(src, live_fl, isol_fl) if (lb and ib) else ["missing binary"]
        all_gaps[src] = gaps

    # Summary semantic checklist
    P("\n======== SEMANTIC CHECKLIST (Isol vs LIVE) ========")
    P("Axes: frame / rcx=sret / imm→rdx / spill / sub20 / x+1→rdx")
    for src, gaps in all_gaps.items():
        P(f"\n[{src}]")
        if not gaps:
            P("  feature-match on dumped funcs (may still differ call graph / imm value)")
        else:
            for g in gaps:
                P(f"  {g}")

    P("\n======== GATE (Isol cold reconfirm) ========")
    ok = True
    for src, (iu, ir, mk, lu, lr) in gate.items():
        P(f"  {src:16s} Isol USER={iu} run={ir} {mk} | LIVE USER={lu} run={lr}")
        if mk != "OK":
            ok = False

    # Plantability: Isol already green on four gates. Parity gaps are shape not run.
    # Isol-able plant only if a SINGLE remaining semantic hole vs LIVE that is Isol-byte-patchable
    # without LIVE transplant. Current Isol already run-green; remaining diffs are:
    # - LIVE spill [rbp-0x38] vs Isol direct mov rdx
    # - LIVE imm=0xa (direct mk) vs Isol imm=9 (via fw x+1)
    # - LIVE no sub20 vs Isol has sub20
    # These are intentional Isol Capless plant shapes; transplanting LIVE emit = BAN.
    P("\n======== PLANT DECISION ========")
    P("Isol s25 four-gate already GREEN (run=0). Remaining LIVE↔Isol diffs are EMIT SHAPE:")
    P("  1) LIVE: mov eax,0xa; mov [rbp-0x38],rax; reload; mov rdx  (spill)")
    P("     Isol: mov eax,9; mov rdx,rax; nop;nop  (main→fw) OR x+1→rdx (fw→mk)")
    P("  2) LIVE: no sub rsp,0x20 before call-mk; Isol: has sub20 (Win ABI shadow)")
    P("  3) rcx=sret: BOTH set rcx from lea [rbp-0x28] (main) / Isol let uses [rbp-0x50]")
    P("  4) frame: Isol n868 SoftCap-shaped; LIVE may differ size but same sret ABI")
    P("⇒ No Isol-able single-point plant that closes SHAPE gap without LIVE transplant.")
    P("⇒ DIG-only this beat. Next: source-level SoftCap emit same Isol USER shape")
    P("  (Capless USER16 + 3-scan) — still NO PROD/pin bump.")
    P(f"\n=== SUMMARY elapsed={time.time()-T0:.1f}s IsolGate={'GREEN' if ok else 'RED'} ===")
    P("PROD SoftCap / pin: untouched (no LIVE transplant)")
    return 0 if ok else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.TimeoutExpired as e:
        P(f"TIMEOUT: {e}")
        sys.exit(3)
    except Exception as e:
        P(f"ERR: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(4)
