# DIG SoftCap Capless `@578071`..`@578273` arg0 imm→rdx (`immrdx_578`)

**2026-10-30 ~16:45 CST Asia/Shanghai** · tip `181d30631` · Isol alt_frame2 `9378df517f96` · `base_828` sha12 `0977d6fbb472` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- `base_828` lit OK n868=2 sha `61afec45d7ff` run exit1
- USER: `lea→rcx; sub rsp,0x20; call mk` — **call mk 在**；**无** `mov eax,imm`→`mov rdx,rax`（假 `has_imm10`＝后继 cmp expect 0xa）

## 1) DIG — Capless corridor
| site | result |
|---|---|
| `@578071` zero buf | **HIT** |
| `@5781ec` imm 0x100 / `@578200` / `@578214` store 3d4 | **HIT** |
| `@578221` jg 3d4 / `@57822a` / `@578231` mov r8d,[4a0] / `@57825c` | **HIT** ⇒ pre_last **ret>0** 且进 call-mk 参数装载 |
| `@567a30` pre_last / `@567aea` pl_je_stk | **HIT** |
| `@5781df` mov edx,[4a0] / `@57820f` call / `@578273` call-mk | INT3 **AV**（序上与 HIT 矛盾→偶发；不以 off-path 论） |
| pre_last first 0x800 E8 | **无** emit_raw`@2a7f07`／enc 带；无 byte-imm `b8`/`ba`/`4889c2` 模板 |
| Capless store `[rbp+0x4a0]` `@57658b` | **HIT** |

⇒ 走廊 **走到** pre_last 成功＋call-mk 装载；call-mk 仍只写 sub+E8；arg0 USER 字节 **不** 由走廊 edx/r8d＝nargs 单独决定。

## 2) Plant `immrdx_578`（红）
| plant | patch | lit | fwd | local | USER |
|---|---|---|---|---|---|
| `immrdx_578` | `@5781df` `mov edx,[4a0]`→`mov edx,1; nop` sha `c0ddee6ef1d4` | OK n868=2 sha **`61afec45d7ff`＝base** run exit1 | **GS** | OK n868=2 exit1 | **call mk 在**；**无** mov rdx；假 imm10＝cmp |

⇒ force edx=1 **无改** USER（与 base 同 sha）⇒ SoftCap lit 已喂 edx≥1 **或** edx 非 USER arg0 源；**保 call-mk**；imm→rdx **仍缺**。红。

## 3) Next single-point
Under `base_828`：dig **pre_last `@567a30` 后半**／走廊缓冲 `[rbp+0x260]` 谁写 USER `lea→rcx` 与应写的 imm→rdx（emit_raw／byte 模板 HIT）；单点 plant 强制该 emit 且 **保 call-mk**（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。备选确认 HIT 的 `@578231` `arg0_rdx`（r8d=1）仅当与 edx 正交。

## 4) Scripts
`_dig/dig_immrdx_578.py`＋`.log`（Win cave SoftCap；BUDGET≤85s）
