# DIG SoftCap base_828 arg0 imm→rdx (`b828_immrdx`)

**2026-10-30 ~16:35 CST Asia/Shanghai** · tip `1000beca8` · Isol alt_frame2 `9378df517f96` · `base_828` sha12 `0977d6fbb472` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- Rebuild `base_828` `@24b9c1` → `mov eax,0x828; nop` sha12 `0977d6fbb472`
- Prior nail (kept): under base_828 USER has `lea→rcx; sub rsp,0x20; call mk` — **call mk 在**；**无** `mov eax,imm`→`mov rdx,rax`（LIVE SoftCap lit `dbaab1c7ce70` 有）
- Cave note: bare `host_b828` lit 本拍偶发 AV（3×）；plant 主机仍可 OK n868=2

## 1) DIG — where imm→rdx should come from
| site | result |
|---|---|
| LIVE lit sret | `lea→rcx; mov eax,0xa; spill; mov rdx,rax; call mk` |
| Capless-ish `ba0a` imm templates | **0** in Capless range |
| Capless-ish `4889c2` | many (745) — host ABI moves, not USER imm arg |
| Isol imm10-ish `@51f0d9` | SoftCap lit **HIT** — `mov eax,0xa` then `call @51d22c` (r8=0xa)；**≠** USER arg0→rdx |
| `@57012f` / `@5acf27` / `@5ad405` | mid-insn / compare-0xa / other；非 USER call-arg |
| Capless `@57803d`→`@20203f` | size/kind prep；zeros `@578071..` spill block |
| call-mk `@57b98c` | on `[rbp-0x30]==0` emits USER `48 83 ec 20` then `@57bafe`→`call @5752bc`；**body 无** `ba0a`/`4889c2` USER arg write |
| enc `@524944`/`@521f10`/`@521d78` | HIT under b828，但 Capless callers of `@524944` **未** HIT（OK/AV）→ enc 非本拍 USER rdx 源 |

⇒ call-mk **只**写 shadow `sub rsp,0x20`＋E8；**arg0 imm→rdx 须在 Capless 调 `@57b98c` 之前**由 Isol-native CallExpr arg emit 写出。

## 2) Plant `b828_immrdx`（红）
| plant | patch | lit | fwd | local | USER |
|---|---|---|---|---|---|
| `b828_immrdx` (immrdx) | nop je `@1ff316`（post_kind3 null-check）sha `ac53351068c4` | **AV** | **GS** | **AV** | — |
| `b828_immrdx` (immrdx2) | nop je `@57800e`→`@57802d`（try-continue）sha `de71ff525453` | OK n868=2 run **exit1** sha `316d87f04203` | **GS** | OK n868=2 run **exit1** | sret 后 **直字段读**；`mov eax,0xa`＝**cmp expect**（假 imm10）；**无 call mk**／**无 mov rdx** |

⇒ nop try-continue **打断** call-mk 路径（相对 base_828 回退）；不可当绿。假 `has_imm10`＝字段期望 0xa，非 arg0。

## 3) Next single-point
Under `base_828`：**Capless CallExpr arg0 emit before `@578273` call-mk**（走廊 `@578071`..`@578273`；保持 call mk；Isol-native 写出 `mov eax,imm`＋`mov rdx,rax`；禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 4) Scripts
`_dig/dig_b828_immrdx.py`／`_dig/dig_b828_immrdx2.py`＋logs（Win cave SoftCap；BUDGET≤85s）
