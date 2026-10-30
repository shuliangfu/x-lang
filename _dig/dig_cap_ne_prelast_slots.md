# DIG SoftCap Cap≠Capless／pre_last 另槽异源已填 `@2a62c9` 容器？

**2026-10-30 ~17:25 CST Asia/Shanghai** · tip `101ee7449`（本拍前）· Isol alt_frame2 `9378df517f96` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop / CloudAgent／造 glue＝mega.

## 0) Gate
- Prior（`dig_filled_vec.md`）：Isol SoftCap lit **证伪无容器**——唯 Capless 空壳 `0x568→+0x478`；fill∩push＝0；无单 E8 fill+push；plant 不可隔离。
- Frontier＝**Cap≠Capless** 分派／pre_last **另槽**是否已有异源**已填** `@2a62c9`-兼容容器可单点改消费；否则钉死「无非空壳供给」。

## 1) DIG — Cap≠Capless（SoftCap-site／pre_last 入口）

| 路径 | 证据 | SoftCap lit 已填供给？ |
|---|---|---|
| Capless `@576692`→site `@2be519`→…→`@57820f` pre_last | `+0x478`＝`@55d730(0x568)` **空壳**（先验 HIT） | **否** — 空壳 only |
| 非 Capless site 调用方 `@2be40f`（fn `@2be0cd`） | parents=`@2be27b`/`@2c04cb`；E8∩{PRE_LAST／ALLOC／PUSH／fill}＝**0**；无 `+0x478` | **否** — 异 ABI 状态闸，不产 args 容器 |
| SoftCap-site 仅上述 2 调用方 | Capless 外 **无** 第二 SoftCap lit 入口造已填 vec | **无 Cap≠Capless 已填旁路** |

Capless 外入点（`@57656c`×9 等）皆进 **同一** Capless 空壳走廊；无异源已填 `+0x478`。

## 2) DIG — pre_last 另槽／异源已填？

| 探针 | 结果 |
|---|---|
| `@2a62c9` in pre_last | **仅** `@56888d` |
| `@2a5ca8` in pre_last | `@5688d2`／`@5690a0` — **皆** 读 `[rbp-0x30]` |
| 其它 local（`-0x10/-18/-20/-28/-38/-40`）喂 len／get | **0** |
| `[rbp-0x30]` STORE | **仅** prologue `@567a60`←`[rbp+0x30]`＝**arg5**；pre_last 内永不回填 |
| push／unwrap in pre_last | **0** |

⇒ SoftCap lit 消费点 **唯一**＝arg5；无「另槽已填容器」可改消费。

## 3) DIG — 非 Capless pre_last 调用方（异源？）

| caller | 区 | flags | SoftCap lit？ |
|---|---|---|---|
| `@57820f` | Capless | `+0x478`→arg5 空壳 | **是**（HIT 空壳） |
| `@0f2108`（fn `@0f19d8`） | 非 Capless | 仅 PRE_LAST；无 SITE／ALLOC／PUSH／FILL；parent `@20ef2f` | **否** — 异路径；未见 `+0x478`／`0x568` 已填 |
| `@5a0dd2` | SoftMega-ish `@5a0*` | arg5←`[rbp-0x50]`；≠ Capless SoftCap lit 走廊 | **否** — 非 SoftCap lit 空壳供给源 |

⇒ 异源 pre_last 调用方 **不** 为 SoftCap lit 提供可单点改接的已填 `@2a62c9` 容器。

## 4) VERDICT — **钉死：Isol SoftCap lit 无非空壳 args 供给**

1. **Cap≠Capless**：无已填旁路（非 Capless site 不产容器／不进 pre_last）。
2. **pre_last 另槽**：无；唯一 `@2a62c9`＝空 arg5。
3. 异源 pre_last 调用方 ≠ SoftCap lit 已填供给。
4. Plant **不可隔离**；造 fill glue＝**mega 禁**。

## 5) Plant
**无。** 无可语义单点 plant；无 `p_ret_*`。

## 6) Next single-point
Isol-native **imm→rdx 旁路**（**不经** filled args 容器／不造 mega glue）：在 SoftCap lit 已 HIT 的 call-mk 走廊上，寻 Isol 内可单点劫持的 imm→rdx 发射点（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。未绿勿收刀／勿升 PROD／钉。

## 7) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`；`_dig/dig_cap_ne_prelast_slots.py`／`_slots2.py`／`_slots3.py`＋logs（≤85s）；无新 Win 跑；PROD／钉未动。
