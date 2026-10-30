# DIG SoftCap pre_last `@567a30` 后半／`[rbp+0x260]` USER imm→rdx (`prelast_immrdx`)

**2026-10-30 ~16:50 CST Asia/Shanghai** · tip `48a23b747` · Isol alt_frame2 `9378df517f96` · `base_828` sha12 `0977d6fbb472` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- `base_828` lit OK n868=2 sha `61afec45d7ff` run exit1
- USER: `lea→rcx; sub rsp,0x20; call mk` — **call mk 在**；**无** true imm→rdx（假 `has_imm10`＝后继 cmp expect 0xa）

## 1) DIG — pre_last 后半／`[rbp+0x260]`
| site | result |
|---|---|
| `@578071` zero `[rbp+0x260]` qword | **HIT**（走廊清缓冲） |
| `@5781f4`/`@578250` lea buf→pre_last／call-mk | AV（序偶发；不以 off-path 论） |
| `@578238` `mov rdx,[rbp+0x498]` | **HIT**（call-mk 宿主 rdx＝`[498]`，非 USER imm） |
| `@576583` store `[rbp+0x498],rdx` / `@57658b` store `[4a0]` | **HIT** |
| pre_last 序：零局缓 `@567b36`..`@568144` → post-zero `@56814a` | 实界 |
| `@568183`/`@5681b5` pz_je | **HIT** |
| `@56822a` call `@1933d8` / `@568587` call `@205068` | **HIT** |
| `@56888d` call `@2a62c9`（len `[rbp-0x30]`） | **HIT** |
| `@5688b7` `je` idx≥len → skip get-elem | **HIT**（**跳过**） |
| `@5688d2` call `@2a5ca8` get-elem | **OK＝miss** |
| `@5688d2` 路径 | SoftCap lit **len==0** ⇒ 不取 arg0 元素 ⇒ 无 imm→rdx 源 |

⇒ `[rbp+0x260]` 只是走廊／call-mk 共享缓冲；**缺 imm→rdx** 钉在 pre_last 后半：**`@2a62c9` 得 len=0 → `@5688b7` 跳过 `@2a5ca8`**，不是 zero_260／edx=nargs。

## 2) Plants（红）
| plant | patch | lit | fwd | local | USER |
|---|---|---|---|---|---|
| `rbp260_rdx` | nop `@578071` zero qword sha `e5b069f409b1` | OK n868=2 sha **`61afec45d7ff`＝base** exit1 | GS | OK exit1 | **保 call-mk**；无 mov rdx；假 imm10 |
| `prelast_immrdx` | nop `@5688b7` je（强制进 `@2a5ca8`）sha `32cd7130045d` | **AV** | **GS** | **AV** | **不可隔离**（空集合上 get-elem） |

⇒ 红。强制越过空 len **不可隔离**；须先让 SoftCap lit 的 arg 容器 **len>0**。

## 3) Next single-point
Under `base_828`：dig **为何 `@2a62c9`([rbp-0x30]) len=0**（谁应填 CallExpr args／`@201f36` 后半写容器；`[rbp-0x30]` 在 HIT 时指向何）；单点 plant 使 len≥1 且走 `@2a5ca8`＋保 call-mk（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 4) Scripts
`_dig/dig_prelast_immrdx.py`／`immrdx2.py`／`immrdx3.py`＋logs（Win cave SoftCap；BUDGET≤85s）
