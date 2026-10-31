# has_implicit_return_tail dig — OPEN (dig-only)

**2026-10-31 ~15:37 CST Asia/Shanghai** · manager refined: **not** SoftCap PROD raise.

## Baselines (do not break)
- tip after 10.60 close: **c3f3a2d21** (= origin/dev at open)
- PROD Soft Cap: **d263fe8c312b** size 8062464 — **unchanged this beat**
- nail: **ecdb5cc1e** — never raise
- w1778 SoftCap cold green: **9c4746d5b5d7**
- Darwin Cap soft / Ubuntu tip SoftCap true RC: keep

## First measurement
tip SoftCap USER `main` **0x88** (a-only) vs W1778 **0xe8** (a/b/c) on `p_ret_fwd` / `p_ret_lit` F9 unify_cold products. Gap still present on tip SoftCap `d263fe8c312b`.

## Plan
See `_dig/dig_1060_PROGRESS.md` §2026-10-31 ~15:37. Prefer-M2; no PE thrash first; no PROD/nail raise.
