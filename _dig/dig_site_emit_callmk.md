# DIG 10.60 SoftCap — site_emit_pass / call-mk / Cap@0024e6-class

**2026-10-30 ~14:20 CST Asia/Shanghai**

## Plants (semantic short names; ban letter-pile)

| Isol | sha12 | plant | SoftCap p_ret_* |
|---|---|---|---|
| site_emit_pass | `a102ef425fc1` | SoftCap-site kind-gates je→jmp (force body) | lit/fwd/local **crc=0x1** |
| calt_h3miss | `415edc74fca0` | site_abi_c36 + Capless `@576746` call h3 → `xor eax,eax;nop*3` | lit/fwd **TIMEOUT**；local **AV** |
| calt_h234miss | `3ed962026de8` | c36 + force-miss h2+h3+h4 | TIMEOUT／AV |
| tip_scfull | `ca90e6fd3276` | tip `@12377c` Capless→SoftCap-full `@121278` | **crc=0x1** |
| tip_scfull0 | `32648e18e9bb` | tip→SoftCap-full `@121230` | **crc=0x1** |
| tip_sc50f | `038f55a434ca` | tip→SoftCap-full `@50f8a0` | OK＝TT thin `5b173cef1205`（非 LIVE） |

## DIG nails

1. **site_emit_pass**：force kind-gates → SoftCap lit **enters** SoftCap-site body（INT3：`k3`/`after_disp`/`call_kind2`/`nest_ok`/`call_sz`/`sz_bad@2be7bb`）。`@2be7bb` size∉1..255 → `eax=-1` exit；`call_name@2be7dc`／emit／`@2bd6ed` **未达**。SoftCap-site ≠ SoftCap CallExpr lit emitter（size query on CallExpr shape fails）。
2. **Capless SoftCap-site LIVE-shaped miss**（c36）：site→h2→h3。h3 SoftCap lit reaches `@46a71c je`；equal-path／unequal AV window around `@46a71e`..`@46a741 call @1fb0ec`。`calt_h3miss`（force h3 miss）→ Capless continues h4/h5/`@201d9f`/`@200ff7` then **arg_loop TIMEOUT**（ban arg-loop force）／`post_args` INT3 but no emit。
3. **Isol Cap@0024e6-class**：**0** prologue match `push rbp; sub rsp,0x180; lea rbp,[rsp+0x80]`。Isol 12× `sub rsp,0x180` — **none** have kind `0x30`。tip SoftCap kind`0x30` → Capless `@57656c` only（≠ LIVE Cap`@0024e6`→Cap21c8`@0021c8`）。
4. **tip SoftCap-full retarget**：`@121278`＝near-empty stub（`call @21b5fa` rdx=0）→ crc=0x1；`@50f8a0`→TT thin。非 Isol Cap`@0024e6` SoftCap dispatch。
5. Capless callers of SoftCap-site emit writers：only SoftCap-site itself + `@201f36` name lookup mid-Capless — **no** Capless→`@2bd6ed`／`@524944` SoftCap call-mk。
6. Prior falsified：site_abi_r8／c36／calt_args／calt_miss／full_chain／smega_le／callsz_le／scap0。

## Hard blocker

- Isol lacks Cap`@0024e6` SoftCap lit dispatch；SoftCap-site body rejects SoftCap lit（sz_bad）；Capless miss→h3 AV／arg_loop hang — no Isol-native SoftCap lit call-mk yet。
- Ban LIVE SoftCap transplant／arg-loop强跳／twin retarget／letter-pile。

## Next beat (minimal; single-site)

1. Isol-native SoftCap lit call-mk：fix Capless h3 SoftCap lit path past `@46a71c` **without AV** and reach Capless emit／`0x868`；**or** Isol-native Cap`@0024e6`-class SoftCap dispatch（not tip→SoftCap-full stub／TT thin）。
2. Win SoftCap `p_ret_*` run green before Darwin／Ubuntu／PROD／pin／close。
