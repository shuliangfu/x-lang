# DIG Capless-alt SoftCap-site early → calt_args / calt_miss — falsified (AV)

Date: 2026-10-30 ~13:45 CST Asia/Shanghai
Tip at plant: `65710507d` (= origin/dev; dig-only)
Isol-TT baseline sha12 `1f836615e0fc`
Isol-calt_args sha12 `c65741a41b67`
Isol-calt_miss sha12 `6927bb640c22`

## USER gap (reconfirmed)

LIVE SoftCap lit CallExpr: `mov eax,imm; spill; mov rdx,rax; near E8 call-mk` + frame `0x868`/`0x878`.
Isol-TT / calt_*: host AV during SoftCap `p_ret_*` compile (no emit) or prior emit=TT thin `0x1b8`.

## DIG (Isol-native; ban LIVE SoftCap transplant)

1. SoftCap CallExpr **is** Capless-alt `@57656c` (kind 0x30). INT3 Capless-alt callers:
   only `cc_12377c` TIMEOUT; other 8 Capless-alt callers OK (off SoftCap lit path).
2. Capless-alt `@576692` → SoftCap-site `@2be519` (=LIVE `@28e9c0`, 0x150).
   Isol SoftCap-site has 4× `mov eax,1; jmp exit` early-claims; LIVE SoftCap-site
   isomorphic sites return `eax=0` (no claim). Capless-alt `@5766b9`: site>0 →
   `mov eax,0; jmp EXIT` — Capless SoftCap early-claim **without** lit call-mk.
3. SoftCap-full / SoftCap twin / SoftMega INT3 → SoftCap lit still TT (off-path).
4. Tip SoftCap `@121278` (`sub rsp,0x868`) unwired to Capless user emit (1 caller `@1215b9`).
5. `calt_twin` (`@12377c`→SoftCap twin `@57ef78`, sha `da6a097340ff`) → **CG002**
   asm_codegen failed (Isol SoftCap twin=SoftMega stub ≠ LIVE SoftCap body).

## Plants (semantic short-name; ban letter pile)

| Isol | sha12 | plant |
|------|-------|-------|
| calt_args | `c65741a41b67` | Capless-alt `@5766b9` early-success → jmp arg-loop `@5770da` |
| calt_miss | `6927bb640c22` | Capless-alt 20× early-success → fallthrough (force miss/next helper) |

Builders: `_dig/build_isol_calt_args.py`, `_dig/build_isol_calt_miss.py`.

## Win SoftCap cave (2026-10-30 ~13:44 CST Asia/Shanghai)

| Isol | probe | compile | emit / frame / run |
|------|-------|---------|-------------------|
| calt_args | p_ret_lit/fwd/local | **AV** `0xC0000005` | no emit |
| calt_miss | p_ret_lit | **AV** | no emit |
| calt_miss | p_ret_fwd | crc=`-1073740791` (`0xC0000409` stack buffer overrun) | no emit |
| calt_miss | p_ret_local | **AV** | no emit |

⇒ Forcing Capless-alt past SoftCap-site early-claim into arg-loop / miss fallthrough
**AV**s the host — Capless mid-body after early[2] still needs LIVE-shaped SoftCap-site
state / helpers Isol Capless-alt does not set up when site early-claimed or when
forced past without site claim setup. Capless emit_args path ≠ SoftCap `0x868` writer.

## Next DIG (single-site; ban transplant / letter pile)

Isol SoftCap-site early-claim (`mov eax,1`) vs LIVE (`mov eax,0`): neutralize Isol
site claim to LIVE-shaped return-0 **and** keep SoftCap-site body state, **or** find
Isol-native SoftCap lit call-mk writer reachable after a non-AV Capless continue —
not Capless arg-loop force, not SoftCap twin retarget (CG002), not LIVE SoftCap tree.
