# DIG SoftCap Isol USER vs LIVE SoftCap semantic parity (`live_isol_parity`)

**Date:** 2026-10-30 ~19:55 CST (Asia/Shanghai)
**Result:** DIG-only — Isol s25 four-gate **GREEN**; no Isol-able plant (shape gap ≠ LIVE transplant).
**Isol host:** `host_967_s25.exe` sha12 `e53841ce0e24`
**LIVE ref:** `lab_LIVE_pret.exe` sha12 `cbc0d8e8d96f` (DIG对照 only)
**PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e`:** untouched.
**Ban:** LIVE SoftCap transplant / tip@121278 / join / epi / mega / arg-loop / hollow-as-close.

## 0) Gate

| src | Isol USER | Isol run | LIVE USER | LIVE run | PROD SoftCap |
|---|---|---|---|---|---|
| p_ret_lit.x | `5c6778769c3c` | **0** | `b1265db940f1` | 0 | compile exit1 / no USER |
| p_ret_fwd.x | `a99121ae7a80` | **0** | `a138cdb6862d` | **AV** | compile exit1 / no USER |
| p_ret_local.x | `36d26fcc9657` | **0** | `a1f688e8e47a` | 1 | — |
| _var_let.x | `d16c78ade1f2` | **0** | `8eddd86645a0` | 1 | — |

Isol cold reconfirm green. PROD SoftCap still cannot emit SoftCap USER for `p_ret_*` (exit1). LIVE SoftCap lit OK; **fwd AV**; local/let exit1.

## 1) Diff list (address / bytes / semantics)

### A. Frame size
| site | LIVE | Isol |
|---|---|---|
| mk / ctor | `sub rsp,0x868` | `sub rsp,0x868` (same) |
| fw (fwd) | `sub rsp,0x868` | `sub rsp,0x868` |
| fw (let) | `sub rsp,0x888` | `sub rsp,0x868` |
| main | `sub rsp,0x878` | `sub rsp,0x868` |

Isol unifies SoftCap-shaped `0x868`; LIVE uses `0x878`/`0x888` on callers. **Not** a run-blocker for Isol (already green). Closing toward LIVE sizes = cosmetic / not Isol-single-point.

### B. rcx = sret (critical)
| site | LIVE | Isol |
|---|---|---|
| main→fw/mk | `lea rax,[rbp-0x28]; mov rcx,rax` ✅ | same ✅ + `sub rsp,0x20` |
| **fwd fw→mk `@0x14f8`** | `lea rax,[x+1]; mov rcx,rax; call mk` — **rcx=value NOT sret** ❌ (root of LIVE fwd AV) | `mov rcx,[caller sret]; sub20; x+1→rdx; call mk` ✅ |
| let fw→mk | `lea rax,[rbp-0x38]; mov rcx,rax` (local sret) + spill x+1→rdx ✅-ish | `mov rcx,[rbp-0x50]` (caller sret) + `inc; mov rdx` ✅ |

**Nail:** LIVE SoftCap fwd path is the **same rcx=value bug** Isol fixed in `fwd_46_967_sret` (Capless plant + let_sret / c1→c2). Isol is **semantically stricter** than LIVE on rcx=sret for fwd.

### C. imm → rdx
| site | LIVE | Isol |
|---|---|---|
| main arg | `mov eax,9; mov [rbp-0x38],rax; reload; mov rdx,rax` (spill) | `mov eax,9; mov rdx,rax; nop; nop` (direct + pad) |
| fw x+1 | `lea rax,[rax+rbx]` (ebx=1) + spill `[rbp-0x48]`/`[rbp-0x68]` → rdx/rcx | `mov rax,[rbp-0x10]; inc rax; mov rdx,rax` |

Both deliver imm/x+1 into the arg register; Isol Capless USER16 + main_imm9 scan = durable Isol shape. LIVE spill is Cap21c8-era emit — **ban transplant**.

### D. sub rsp,0x20 (Win shadow)
- LIVE: **absent** before call-mk / call-fw.
- Isol: **present** (Capless USER16 `sub rsp,0x20` + call-mk path).

Isol keeps Win ABI shadow; LIVE omits. Removing Isol sub20 regresses (prior GS). Do **not** plant-away sub20 to match LIVE.

### E. lit path
- LIVE lit: inlines struct stores in main (`0x878` frame); **no** call-mk / no imm→rdx — different program shape (still run=0).
- Isol lit: SoftCap call-mk with cmk0 imm→rdx path (USER `5c6778769c3c` run=0).

Same test oracle; different emit graph. Not a gap to close toward LIVE.

## 2) Plant decision

**No plant this beat.**

Reasons:
1. Isol s25 already four-gate green (run=0, USER shas stable).
2. Remaining LIVE↔Isol diffs are **emit shape** (spill vs direct, frame 878/888 vs 868, sub20, lit inline vs call-mk).
3. Matching LIVE spill / dropping sub20 / retargeting Cap21c8 = **LIVE SoftCap transplant** (hard ban).
4. LIVE fwd itself is **red (AV)** on current sources because rcx=value — Isol must **not** regress toward that.

## 3) Next single point

**`src_softcap_s25_emit`:** fold Isol s25 semantics into a durable **source-level SoftCap** change (Capless USER16 x+1→rdx + c1→c2 + let_sret caller rcx + main_imm9) so tip SoftCap emits Isol-shaped USER **without** PE Isol plant / without LIVE transplant. Still **no PROD / pin bump** until that source path cold-greens on Win SoftCap cave.

Optional side: Darwin Cap soft / Ubuntu tip-cold after source fold stays green.

## 4) Artifacts

- Script/log: `_dig/dig_live_isol_parity.py` / `.log`
- Isol persist: `_dig/build_isol_967_s25.py` / `host_967_s25.exe` `e53841ce0e24`
- LIVE ref only: `lab_LIVE_pret.exe` (cave)
- PROD SoftCap `7a2cf5da581a` probed compile exit1 — **not bumped**

## 5) Open bans unchanged

CloudAgent / 10.74 / HARD BAN / mega / 假绿 / LIVE SoftCap transplant / arg-loop / tip@121278 / join / epi / hollow·skip_1a0 as close / letter-pile.
