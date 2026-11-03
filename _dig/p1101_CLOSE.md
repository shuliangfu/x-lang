# CLOSE 11.01 softcap_xuban_10_4_build_x_eat_g05＝(1) ACCEPT

Manager APPROVED CLOSE 11.01＝(1) ACCEPT / OPEN 11.02.

## Result
ACCEPT PRODUCT_SCHEDULE export ABI plant @ tip `1948f0023b64fe99e91a28b9a4c857ce0cb3a4d0`＝origin/dev.

## Evidence (Asia/Shanghai Mac.lan ~16:59–17:02)
- `build.x`: `build_product_schedule_count(): i32` → 5; `build_product_schedule_id_at(i): *u8` ordered ids
  (`ensure_migrate_gen` → `ensure_driver_gen` → `ensure_lsp_pipeline_gen` → `migrate_x_objs` → `g05_prepare_and_relink`)
- `compiler/scripts/product_build_dag.sh --check`: source-parse ABI vs bash `PRODUCT_SCHEDULE`; note
  `build.x PRODUCT_SCHEDULE ABI matches bash (5 nodes · 10.4/11.01)`
- Mismatch probe: bogus id → FAIL then restored
- Soft Cap Prefer follow-on §6 🟡 **10.4** still open (ABI subgrain only; bash schedule still live runner authority)

## Not this knife
- No g05 body rewrite; bash `PRODUCT_SCHEDULE` not demoted
- No Soft Cap／nail／tiphead／Cap tip／code tip raise
- Full `product_build_dag.sh --check` EXIT0 still blocked by pre-existing `leaf_pattern_residual` wave899 (+ ensure post_ship seed residual) → OPEN 11.02

## HOLD (NOT raised)
PROD Soft Cap **09fe181dbd0e** (bak **74d0bd9c9fbf**)／nail ecdb／tiphead Prefer-M2 **9ecd26ea44ab**／Cap tip Prefer-M2b **10470224**／code tip Prefer-M2 SoftCap **13fec616d**

## Ship
`_dig/p1101_{OPEN,PROGRESS,CLOSE}.md` manager CLOSE exception into repo.
Never self-CLOSE — manager APPROVED＝(1).

## Hand-off
OPEN **11.02** `softcap_xuban_10_4_leaf_pattern_residual` — clear leaf_pattern_residual wave899 so `product_build_dag.sh --check` full EXIT0 (honest leaf／gate align to mk count 4; ensure post_ship seed-retired honesty). Then plan demote bash PRODUCT_SCHEDULE→build.x (same knife or ask).
NOT tiphead DIG07／Cap tip poison／SoftCap-parity／tip hollow／tip-cold／block_* as primary.
