# DIG SoftCap Isol SoftCap lit：`@2a62c9`-兼容**已填** vec／单 E8 fill+push？

**2026-10-30 ~17:20 CST Asia/Shanghai** · tip `0cafb2f26`（本拍前）· Isol alt_frame2 `9378df517f96` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop / CloudAgent.

## 0) Gate
- Prior（`dig_slot_478.md`）：`@1ff2ef` Capless CFG **无** ensure；`@201eeb|@201f36`＝字段 memcpy／size`0x100`≠slot；**不可**单点接 `+0x478`；plant 不可隔离。
- Frontier＝Isol-native SoftCap lit **是否已有** `@2a62c9`-兼容**已填** vec，或可单点 E8 fill+push 进 `+0x478`；否则证伪无容器。

## 1) DIG — Isol-wide `0x568` alloc（SoftCap lit args 类）

| site | edx | STORE | SoftCap lit？ |
|---|---|---|---|
| `@57662c`（Capless） | `0x568` | `[rbp+0x478]` | **是** — 空壳 only（先验） |
| `@59c3bf` | `0x568` | `[rbp-0x50]`（`@58e*` 帧） | **否** — ≠ Capless args；链 `@58e9a0`／`@20cd98`；Capless **零** E8→此 |

Isol `mov edx,0x568` 全仓 **仅** `@576624`（→Capless alloc）。  
⇒ SoftCap lit **唯一** `0x568` args 容器＝Capless 空壳；**无**第二已填源可 retarget。

## 2) DIG — push `@2a4f6a`／fill∩push／`+0x478`

| 探针 | 结果 |
|---|---|
| Capless E8→`@2a4f6a` | **0** |
| Capless E8→`@2a4xxx`–`@2a6xxx`（unwrap／push 带） | **0** |
| push callers（全仓 10）∩ SoftCap-site／pre_last／`0x568` | **0** |
| push±0x200 ∩ fill-fam | **0** |
| fill-fam 调用点±窗／fwd∩ push | **0**（`fill∩push co-window=0`） |
| `@2a4f6a` body ∩ fill-fam | **0**（仅 vec 内部 grow／`@63b200`） |
| `[rbp+0x478]` STORE | Capless `@576631`／`@576647` 空壳；`@4d84b4` spill≠args；无 SoftCap-site STORE |

⇒ **无**「单 E8 fill+push」；**无**已填 `+0x478`；push 仅 `@2a5xxx`／`@2b4xxx` 内子系统，与 SoftCap lit Capless **无边**。

## 3) DIG — SoftCap lit 路径＝Capless-only（args 容器）

- SoftCap-site `@2be519` callers＝`@2be40f`＋**Capless `@576692`**（仅此 SoftCap lit 入口用 site）。
- Capless 入口 `@57656c`（外部 E8×9→同入口；另 `@3b6*` 进 Capless 中段）。
- Capless 造空壳→site→…→`@578200` load `+0x478`→pre_last；`@2a62c9` SoftCap lit 消费点＝pre_last `@56888d`（len=0，先验）。

⇒ Isol SoftCap lit **不**经其它 Cap 产已填 `@2a62c9` 容器。

## 4) VERDICT — **证伪无容器**

1. Isol SoftCap lit **无** `@2a62c9`-兼容**已填** vec（唯一 `0x568`＝Capless 空壳；`@59c3bf` 异帧不可接）。
2. **无**单点 E8 fill+push 进 `+0x478`（fill∩push＝0；Capless 零 push／unwrap）。
3. Plant **`filled_vec`／`e8_fillpush` 不可隔离**；无 `p_ret_*`。

## 5) Plant
**无。** 证伪无容器 → 无可语义单点 plant。Frontier 仍红。

## 6) Next single-point
Isol SoftCap lit：**Cap≠Capless** 分派／pre_last 另槽是否已有异源已填 `@2a62c9` 容器可单点改消费（禁 tip@121278／join／epi／LIVE Cap21c8／mega／arg-loop）；否则钉死「Isol SoftCap lit 无非空壳 args 供给」→缺口＝造 fill glue（＝mega 禁）须另寻 Isol-native imm→rdx 旁路。未绿勿收刀／勿升 PROD／钉。

## 7) Evidence
静态 Capstone：Isol `/tmp/p1060_dig/bins/xlang_isol1060_alt_frame2.exe`；`_dig/dig_filled_vec.py`＋`.log`（≤85s）；无新 Win 跑；PROD／钉未动。
