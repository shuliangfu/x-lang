# DIG SoftCap base_828 + Isol-native CallExpr call-mk (`b828_cmk` / `callmk_b828`)

**2026-10-30 ~16:30 CST Asia/Shanghai** · tip `59c0badd5` · Isol alt_frame2 `9378df517f96` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Rebuild `base_828` `@24b9c1` → `mov eax,0x828; nop` sha12 `0977d6fbb472`
- SoftCap `p_ret_*` under base_828: lit/local **OK** n868=2 run **exit 1**; fwd **GS**

## 1) DIG — USER gap under base_828 (钉死)
LIVE SoftCap lit main (`lab_LIVE_pret` sha `dbaab1c7ce70`):
```
lea rax,[rbp-0x28]; mov rcx,rax
mov eax,0xa; mov [rbp-0x38],rax; mov rax,[rbp-0x38]; mov rdx,rax
call mk@0xa90
```
Isol base_828 lit (sha `61afec45d7ff`):
```
lea rax,[rbp-0x28]; mov rcx,rax
sub rsp,0x20
call mk@0xa90          ; call present — NO imm→rdx
add rsp,0x20
lea + 488b00 field reads → exit 1
```
⇒ SoftCap-shaped frame (n868=2) + **call mk 已写出**；剩余缺口＝**imm→rdx**（mk 读 rdx 得垃圾）。

## 2) On-path Capless / call-mk (under base_828 lit)
| site | result |
|---|---|
| Capless-alt `@576692` / SoftCap-site `@2be519` / kind-gate `@2be734` | HIT（gate 已 `eax=0` miss） |
| Capless continue `@5766c3` / join `@577681` / kind3 `@577c47`→`@1ff2ef` | HIT |
| Capless try3 `@55483c`；je_try1/2/3 | HIT（try ret 0 → continue） |
| call-mk `@578273`→`@57b98c`→`@57bb30`；cmp eax,2 `@575645` | HIT |
| skip `@575786` jns / `@57578c` cmp `[rbp+0x990],1` | HIT；`[990]!=1` → `@575fa3` |
| enc `@524944` / `@521f10` / `@521d78` | HIT |
| SoftCap-site `@2be734` 已 `mov eax,0`（非 `eax=1` claim） | SoftCap miss → Capless 续 |

## 3) Plants（均红／不可绿）
| plant | patch | lit / fwd / local |
|---|---|---|
| `b828_cmk` | `@577cb3` je→jmp（force try1 continue） | OK exit1 / GS / OK exit1；USER sha 同 base_828（无 imm→rdx） |
| `b828_cmk_t2` / `t12` | try2 / try1+2 force continue | **AV** / GS / **AV** |
| `callmk_b828` | nop jne `@575648`（force eax==2） | **AV** / GS / **AV** |
| force `cmp eax,eax` `@575645` | force eax==2 path | **AV** / GS / **AV** |
| force Capless `@5766b7` jle→jmp | always Capless continue | **AV** / GS / **AV** |

⇒ Isol-native call-mk **imm→rdx** 未绿；`call mk`  alone ≠ 绿。

## 4) Next single-point
Under `base_828`：Capless／call-mk **arg0 imm→rdx** before existing `call mk`（sret 后 user arg→rdx；追 `@575fa3` skip 链／CallExpr arg emit；禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 5) Scripts
`_dig/dig_b828_cmk.py` … `_dig/dig_b828_cmk5.py`（Win cave SoftCap；BUDGET≤85s）
