# DIG SoftCap lit `@27fbc5` ec small / plant `ec_400`

**2026-10-30 ~16:15 CST (Asia/Shanghai)** · Base Isol alt_frame2 `9378df517f96`. Short timeout INT3 (≤5s/site, budget≤85s). Ban tip`@121278` / join/epi / LIVE SoftCap transplant / arg-loop / mega.

## Question

Why lit `@27fbc5` (`ec` spill) stays small (no natural `0x800` clamp)? Can forcing `ec>0x3ff` Isol-green SoftCap `p_ret_*`?

## DIG nails

1. Sole caller E8`@24b8bc` → `mov [rbp+0xec],eax` `@24b8c1` — both **HIT**.
2. `@27fbc5` walks worklist (seed `edx=mode`); per-node **`@27ea1e` HIT** accumulates spill bytes into **globals**.
3. Ret `@2804dc` **HIT**: `mov eax,[rip+0x8f51ca]` → global spill counter **RVA `0xb756ac`**. **ec＝compute／global，非 imm。**
4. Sum `@24b49d` f8←ec: `0`｜`ec+0x100`｜**CLAMP `0x800`** if `ec>0x3ff && f8≤0x7ff`.
5. On-path `jle_ec_le0@24b97e` **HIT**（enter f8-from-ec）；`clamp@24b998` not clean Isol HIT（AV this beat／prior OK off-path）— lit does **not** take SoftCap pad. Thin `0x28`/`0x178` ↔ missing `0x800` clamp.
6. Capless SoftCap lit：`@27ea1e` adds little／no spill ⇒ global ec ≤`0x3ff` ⇒ no clamp. SoftCap／LIVE path that feeds large spill pool **omitted** on Isol Capless lit.

## Plant

### `ec_400` (`@2804dc` `mov eax,[rip+…]` → `mov eax,0x400; nop`) sha12 `ea3d1963e3ff`

Force natural clamp path (`ec>0x3ff`).

| probe | compile | n868 | run |
|---|---|---|---|
| p_ret_lit | **AV** | — | — |
| p_ret_fwd | **GS** | — | — |
| p_ret_local | **AV** | — | — |

⇒ **不可隔离**（AV/GS）. Contrast prior `base_828`（n868=2／exit1）：frame force at sum-return cleaner than forcing ec at `@27fbc5` ret.

Baseline lit OK sha `332eed5f048b` n68=1 n1b8=1 n868=0 run exit1.

Probe hosts removed.

## Next single-point (ban tip`@121278`/join/epi/LIVE/mega)

Under `base_828`-sized frame（n868 plantable／run still exit1）：**Isol-native CallExpr call-mk** — imm→rdx＋E8 mk（Capless thin today＝`mov eax,imm; call mk` 无 `mov rdx`）. Short timeout.

PROD SoftCap `7a2cf5da581a` / pin `ecdb5cc1e` untouched.
