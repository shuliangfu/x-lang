# DIG `fwd_scs_epi` — SoftCap kind=`0x30` miss-epi GS for `return SoftCapCallExpr`

**2026-10-30 ~18:22 CST Asia/Shanghai** · tip parent `c9250629a`

## Nail

1. SoftCap_site `@2be519`：`push; sub rsp,0x150; lea rbp,[rsp+0x80]`（非 classic `mov rbp,rsp`）。
2. kind=`0x30` → miss `@2be734` → epi `@2be90a add rsp,0x150; @2be911 pop; @2be912 ret`。
3. BASE：`@2be90a` fwd+let HIT；**`@2be911` pop：fwd=GS／let=INT3**（本拍起点）。
4. **根因（本拍钉死）**：SoftCap arg-home `@2be53e mov [rbp+0xf8], r9`。
   - SoftCap_rbp = call_rsp − 0xd8 → `[rbp+0xf8]` = **call_rsp+0x20** = Capless `[rsp+0x20]`（刚写入的 5th-arg/`[4b0]` 槽）。
   - Capless 在 SoftCap call 前：`r9 ← [rbp+0x460]`（`call @55d730(incoming_r9, 0x10)` 分配结果），再 `call SoftCap`。
   - 该 home 写对 `return SoftCapCallExpr`（fwd）在 SoftCap miss-epi 上触发 GS；let／lit 同 kind 过 epi。
5. 证伪／对照：
   - `postlea_miss`（`@2be529→miss`，跳过 homes）：SoftCap epi 双 INT3；GS 迁到 `@2c614f`。
   - `miss@545`（跑完 homes 再 miss）：epi pop fwd=GS。
   - nop rdx／r8 home **alone**：epi 仍 fwd=GS。
   - **nop r9 home alone**（`@2be53e` → 7×`90`）：epi pop fwd=INT3＝let；lit／local／let 常绿（USER lit=`78015bac7508`）但 **cave 上偶发 AV**（环境抖，非稳定 Isol）。
   - force-kind／frame enlarge／epi-raise／lea-epi：已禁／已证伪（前拍）。
6. Capless_alt 调用：fwd 经 `@12377c`（`cmp [rbp+0x1f4],0x30` 门）入 Capless→SoftCap；SoftCap 仅两处 E8 调用者 `@576692`／`@2be40f`。
7. 诊断 dual（SoftCap nopr9 + `@2c6174` `@2c614f` r9 home nop，**未作 plant**）：Capless `@5766f1` store-after-2c 对 fwd 变 INT3；`@123781` caller_after 仍 GS。`@2c614f` 同 lea 帧，`[rbp+0x138]`＝call_rsp+0x20 **同构 smash**。

## Plants

| plant | sha12 | lit | fwd | local | 注 |
|---|---|---|---|---|---|
| cmk0_irdx_sub20（对照） | 3f43f1609d70 | OK run0 | **GS** | OK run1 | |
| host_scs_nopr9（诊） | f52f77a7ffb1 | OK∽AV 抖 | GS（epi 已对齐） | OK∽AV 抖 | SoftCap `@2be53e` nop；**非稳定 Isol** |
| host_scs_r9b0（诊） | e8e372731782 | OK∽AV 抖 | GS（epi 对齐） | OK∽AV 抖 | r9 home→`[rbp+0xb0]` |

无稳定 Isol 可收；p_ret_fwd 仍 GS。

## 下一单点

- **`fwd_2c6174`**：在 SoftCap epi 已可对齐（nopr9 诊）前提下，DIG `@2c614f` r9 home `@2c6174→call_rsp+0x20` 同构 smash／Capless `@5766f1` 后至 `@123781` 的 GS →可 Isol。禁 tip@121278／join／epi-raise／LIVE／mega／字母堆／假绿 force-kind／`[4b0]=1`。

## 脚本／log

`_dig/dig_fwd_scs_epi{,2..13}.py`／`.log`；笔记本文件。

PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**。
