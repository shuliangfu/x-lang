# P1099 Soft Cap 09fe four-gate + tip-alone protect baseline

Time: 2026-11-03 Asia/Shanghai · Win `ssh windows-server`

## HOLD hosts (sha12 confirmed)
| host | path | sha12 | size |
|---|---|---|---|
| Soft Cap Prefer PROD | `C:\xlang_tmp\prod_softcap\lab_SoftCap_76795.exe` | **09fe181dbd0e** | 8091136 |
| cave Soft Cap | `C:\xlang_tmp\p1060\cave\lab_SoftCap_76795.exe` | **09fe181dbd0e** | 8091136 |
| DIG09fe nested_let plant | `...\P1092_09fe181dbd0e.exe` | **09fe181dbd0e** | 8091136 |
| tiphead Prefer-M2 HOLD | `lab_CapSoftWin_tiphead.exe` | **9ecd26ea44ab** | 7989831 |
| bak Soft Cap | `...74d0bd9c9fbf_pre_1098_raise.exe` | **74d0bd9c9fbf** | 8082432 |

## Fixtures
- four-gate: `p_ret_lit`／`p_ret_fwd`／`p_ret_local`／`_var_let` @ `C:\xlang_tmp\p1097\`
- tip-alone: softcap_lit／call_arg／nested_let／n_no_assign／call_arg_direct @ `C:\xlang_tmp\p1092\`
