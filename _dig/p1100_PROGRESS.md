# P1100 PROGRESS — softcap_capsoft_tiphead_dig07_raise

Time: 2026-11-03 ~16:51 Asia/Shanghai · Mac.lan + Win `ssh windows-server`
HOLD Soft Cap **09fe181dbd0e**／nail ecdb／tiphead Prefer-M2 **9ecd26ea44ab**／Cap tip **10470224**／code tip Prefer-M2 SoftCap **13fec616d**
Never self-CLOSE. Day3 usage ~57.6%＜60%.

## SoftCap four-gate (Prefer.o / run) — re-prove + plant

| host | sha12 | lit | fwd | local | _var_let |
|---|---|---|---|---|---|
| Soft Cap Prefer PROD | **09fe181dbd0e** | Prefer.o=58775 run=**0** | 58805/**0** | 58233/**0** | 58774/**0** |
| CapSoft Prefer dig w1521 | **1f78def393fc** | Prefer.o>0 run=**0** | **0** | **0** | **0** |
| CapSoft Prefer dig base 1e59 | **1e59c5261663** | Prefer.o>0 run=**0** | **0** | **0** | **0** |
| tiphead Prefer-M2 HOLD | **9ecd26ea44ab** | **CG002** Prefer.o=0 | CG002 | CG002 | CG002 |
| DIG07 10.66 plant | **07eadd3fe8bf** | **CG002** Prefer.o=0 | CG002 | CG002 | CG002 |
| P1100 DIG07+p1074 param_home | **ba369a618c27** | **CG002** Prefer.o=0 | CG002 | CG002 | CG002 |

Exact fail: `codegen error[CG002]: asm_codegen failed` / `elf ctx code_len=0 num_labels=0 num_patches=0`

## Plant attempt
Adapted `tools/dig/p1074_*` CapSoft Prefer w1521 param_home onto DIG07 SRC **07eadd**:
- tool: `tools/dig/p1100_dig07_capsoft_prefer_w1521_param_home_plant.py` (local; Win ran from `C:\xlang_tmp\p1100\`)
- OUT dig PE **ba369a618c27** size 7997440 (≠ DIG07/9ecd/1f78/09fe)
- Soft Cap／tiphead／DIG07 HOLD hosts pre=post untouched

## Read
1. CapSoft Prefer dig SoftCap four-gate green is **1e59 lineage already SoftCap-green** before param_home; param_home does **not** create SoftCap four-gate on tiphead Prefer-M2 SoftCap dig class.
2. DIG07／9ecd／ba36 share Cap soft tiphead Prefer-M2 SoftCap **CG002／code_len=0** class (named-struct parse-skip residual; p1069／p1090／p1097).
3. No honest SoftCap Prefer plant delta this knife without SoftCap-parity same-body empty／fake-green／host-swap 1f78-as-DIG07／tip hollow／Cap tip poison／raise tiphead-before-green — all **banned**.
4. Do **not** raise tiphead Prefer-M2 product to 9ecd (four-gate not GREEN).

## HARD-STOP residual HOLD
Ask manager CLOSE 11.00＝HARD-STOP residual HOLD (not ACCEPT). Never self-CLOSE.
