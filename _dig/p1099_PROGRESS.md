# P1099 PROGRESS — softcap_prefer_prod09fe_four_gate_protect

Knife: Mac.lan `b93fb82c-3bf3-4127-baa9-c1c63f355789` + Win `ssh windows-server`
Time: 2026-11-03 Asia/Shanghai
Gate≠CLOSE · Never self-CLOSE · `_dig/p1099_*` local only

## Step 1 — Soft Cap 09fe four-gate + tip-alone protect (DONE this turn)

Tool (local Win): `C:\xlang_tmp\p1099_four_gate_tipalone_protect.py`
Table: `C:\xlang_tmp\p1099\protect_table.txt`

### Soft Cap Prefer dig SoftCap four-gate on Soft Cap 09fe
| host | p_ret_lit | p_ret_fwd | p_ret_local | _var_let | score |
|---|---|---|---|---|---|
| PROD09fe | Prefer.o=461 run=0 | Prefer.o=563 run=0 | Prefer.o=363 run=0 | Prefer.o=542 run=0 | **4/4 GREEN** |
| DIG09fe | Prefer.o=461 run=0 | Prefer.o=563 run=0 | Prefer.o=363 run=0 | Prefer.o=542 run=0 | **4/4 GREEN** |

### tip-alone protect (PROD09fe ≡ DIG09fe)
| stem | tipAlone Prefer.o/run | dig Prefer.o/run | expect |
|---|---|---|---|
| softcap_lit | 463/0 | 463/0 | 463/0 |
| call_arg | 553/0 | 553/0 | 553/0 |
| nested_let | 387/0 | 387/0 | 387/0 |
| n_no_assign | 379/0 | 379/0 | 379/0 |
| call_arg_direct | 500/0 | 500/0 | 500/0 |

**PROTECT_SMOKE_OK** four-gate=4/4 tip-alone=ALIGN

## HOLD (NOT raised)
nail ecdb／tiphead Prefer-M2 **9ecd26ea44ab**／Cap tip Prefer-M2b **10470224**／code tip Prefer-M2 SoftCap **13fec616d**／DIG07 **07eadd** Cap soft tiphead CG002 Ban-as-primary

## Status
Protect smoke **ACCEPT-ready**. Waiting manager CLOSE＝(1). **NOT self-CLOSE**.
Docs tip after CLOSE 10.98 ship: **4e0f7ab48**.
