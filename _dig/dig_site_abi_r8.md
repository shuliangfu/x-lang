# DIG 10.60 SoftCap — Isol-site_abi_r8

**2026-10-30 ~14:03 CST Asia/Shanghai** · tip parent `a3e194958` · Isol-TT `1f836615e0fc`

## Plant
- Isol-site_abi_r8 sha12 **`de066e24b417`** · builder `_dig/build_isol_site_abi_r8.py`
- SoftCap-site ABI: Capless-passed `r8d`/`r9` slots LIVE-shaped (`f0=r8d`, `f8=r9`) + null claim `eax=0` + body slot retarget (keep state)
- Ban: LIVE SoftCap transplant / letter-pile / arg-loop force / twin retarget

## DIG nails
1. SoftCap lit → Capless-alt `@57656c` → SoftCap-site `@2be519` (Cap21c8-pro isomorphic to LIVE `@0021c8`).
2. Isol SoftCap-site entry stores **swapped** vs LIVE / Capless ABI:
   - Isol: `f0=r8(q)`, `f8=r9d(d)`; null checks `f8` (r9d)
   - LIVE: `f0=r8d(d)`, `f8=r9(q)`; null checks `f0` (r8d); miss → `eax=0`
3. Pre-ABI: SoftCap lit hit `@2be6b0` null `eax=1` → Capless early EXIT → TT thin `5b173cef1205`.
4. Post-ABI (`site_abi_r8`): null NOT hit; SoftCap lit **enters body**; hits kind-gate `@2be734` (`kind∉{0x36,0x33,3}` → `eax=1`) → Capless early → still TT.
5. `site_abi_c36` (`@2be734→0`): Capless fallthrough reaches h1–h3 then **AV** (no emit).
6. `site_abi_unk3` / `kany` (unknown→kind3-like): pass c8 check; hit second kind-gate `@2be781` (`c4≠3` → `eax=1`) → Capless early TT; `@2be781→0` → **AV**.
7. LIVE SoftCap lit SoftCap-site: body validate **miss** `eax=0` (not null; not final `eax=1`) → Capless continue. LIVE also Cap`@0024e6` kind`0x30`→`@0021c8`.
8. Isol SoftCap-site callers: only Capless `@576692` + wrapper `@2be40f`. **No** Isol Cap`@0024e6`-like (cmp`0x40`+kind`0x30`→SoftCap-site) dispatcher found.

## Win SoftCap gate (`site_abi_r8`)
| probe | result |
|---|---|
| p_ret_lit | OK compile sha=`5b173cef1205` TT thin; run rc=1 |
| p_ret_fwd | OK sha=`546a4c6d02df` |
| p_ret_local | OK sha=`018c76562e9e` |
| LIVE gold | `dbaab1c7ce70` **not** matched |

## Blocker (do not close knife / bump PROD / pin)
1. Isol SoftCap-site kind-gates `@2be734`/`@2be781` `eax=1` false-claim SoftCap lit; neutralize → Capless continue **AV**.
2. Isol SoftCap-site body ≠ LIVE SoftCap-site (kind dispatch vs validate/size/kind miss-`eax=0`).
3. Isol lacks LIVE Cap`@0024e6` SoftCap lit dispatcher; Capless SoftCap-site path alone insufficient after miss.
4. Ban LIVE SoftCap transplant / arg-loop / twin.

## Next beat
Isol-native SoftCap lit call-mk writer after SoftCap-site LIVE-shaped miss without Capless AV — or restore Isol Cap`@0024e6`-class SoftCap dispatch Isol-natively. Win SoftCap `p_ret_*` run green first; then Darwin Cap soft + Ubuntu tip-cold.
