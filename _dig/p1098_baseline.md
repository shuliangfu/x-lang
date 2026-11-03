# p1098 baseline — Soft Cap Prefer tip-alone before / after PROD Soft Cap bake

## HOLD hosts (pre-raise)

| host | sha12 | size |
|---|---|---|
| PROD Soft Cap 74d0 | `74d0bd9c9fbf` | 8082432 |
| DIG call_arg P1091 | `3f6ad9910c48` | 8089600 |
| DIG nested_let P1092 | `09fe181dbd0e` | 8091136 |
| tiphead Prefer-M2 | `9ecd26ea44ab` | 7989831 |
| Cap tip Prefer-M2b | size **10470224** | HOLD |

## Expected dig-align (post bake tip-alone ≡ DIG09fe)

| fixture | Prefer.o | run |
|---|---|---|
| softcap_lit | 463 | 0 |
| call_arg | 553 | 0 |
| nested_let | 387 | 0 |
| n_no_assign | 379 | 0 |
| call_arg_direct | 500 | 0 |

Historical Soft Cap Prefer 74d0 tip-alone lag: call_arg Prefer.o=**537** run=1; nested_let Prefer.o=387 run=1.
