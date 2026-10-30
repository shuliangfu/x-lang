# DIG SoftCap 10.60 — `fwd_gs_root`（p_ret_fwd compile GS）

**2026-10-30 ~17:57 CST (Asia/Shanghai)** · tip base `52e87ea52` · Isol `9378df517f96` · host plant `cmk0_irdx_sub20` sha12 `3f43f1609d70`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue／+0x478／`[4b0]=1`／LIVE spill：遵守
- 先验：`cmk0_irdx_sub20` lit 绿（USER sub20→imm→rdx）；fwd **仍 GS**（已证伪「仅缺 call-mk sub20」）

## DIG 钉死（compile GS 根）

### A) 构造钉（DIG1–2）
| 变体 | 构造 | sub20 host |
|---|---|---|
| lit / main_bin / two_lit / fwd_nocal | 无 `return SoftCapCallExpr` | **OK** |
| fwd / fwd_lit_inner / fwd_pass | `return mk(...)` / `return SoftCapCall(...)` | **GS** |
| **fwd_let** | `let v = mk(...); return v` | **OK** `98c9714985ed` |

**根因构造**：`return SoftCapCallExpr`（直接 return Call）→ compile GS；`let` 绑定再 return → OK。  
证伪：BinaryExpr／非 lit／缺 sub20／imm→rdx／SoftMega body（`@59b170` lit=OK／fwd=GS 未入）。

### B) 阶段／路径（DIG1–4；real host）
1. GS＝`0xC0000409` STATUS_STACK_BUFFER_OVERRUN（cookie／__fastfail）。
2. 阶段＝**compile**（host 编 `p_ret_fwd.x` 即崩；call-mk `@57ba3b` **fwd 未 HIT**）。
3. Capless_alt `@57656c` → SoftCap_site `@2be519` via `@576692`：**fwd 与 lit/let 均 HIT SoftCap_site 入口**。
4. SoftCap_site 内 kind∉{`0x36`,`0x33`,`3`} → `@2be734 mov eax,0; jmp epi`（kind-miss）。
5. **real host**：Capless `@576697`（SoftCap 返回后 store）fwd＝**GS**／let＝INT3 → SoftCap_site **未正常返回**（GS 在 SoftCap_site 内／返回路径）。

### C) 诊断 stub SoftCap_site（DIG5–7；非 plant）
- SoftCap_site `@2be519` → `xor eax,eax; ret`（scs_ret0）：**stub fwd=GS／let=OK／lit=OK**。
- Capless 在 stub 下继续：fwd/let 均 HIT 至 `@5766ec call 0x2c614f`；  
  **`@5766f1` store：fwd=GS／let=INT3** → last_fwd_HIT＝`@5766ec`。
- 证伪：GS ≠ SoftCap_site 体独有副作用（stub 后 lit/let 仍绿；fwd 仍 GS 于下一 helper）。

### D) Capless helper `@2c614f`（DIG8；scs_ret0 下）
- prol：`push rbp; sub rsp,0x190; …`；null 检后 `@2c61bc call 0x20cd98`（kind）。
- INT3 walk：fwd/let 同 HIT 至 `@2c61c1`（store kind）；**last_HIT＝`@2c61c1`**；其后 fwd＝GS。
- 钉：return-CallExpr 路径下 GS 落在 **`@2c614f` 内 kind 取得之后**（相对 let）。

## 总钉（一句话）
`p_ret_fwd` compile GS＝**直接 `return SoftCapCallExpr`** 触发的 Capless 后继路径；real host 先在 SoftCap_site 返回前 GS；stub SoftCap 后仍在 Capless `@5766ec→@2c614f`（lastHIT `@2c61c1` post-`@20cd98`）GS。**不是** call-mk sub20／imm→rdx／SoftMega／BinaryExpr。

## Plant
本拍 **无 Isol plant**（根已钉；下一刀需 DIG `@2c614f` 内 kind／args fwd≠let，尚未成单点字节 plant）。

## SoftCap 门（本拍未改 plant；对照 host `3f43f1609d70`）
| | lit | fwd | local |
|---|---|---|---|
| cmk0_irdx_sub20 | OK | **GS** | OK run1 |
| scs_ret0 stub（诊） | OK | GS | — |
| fwd_let 构造 | — | OK | — |

## 下一单点（唯一）
- **`fwd_2c614f`**：DIG Capless `@2c614f` 内 return-CallExpr vs let 分歧（kind＠`@20cd98`／args rcx·rdx·r8·r9／cookie）；求可 Isol 单点。禁 tip@121278／join／epi／LIVE／mega／`[4b0]=1`／字母堆／LIVE SoftCap 移植。
- fwd 未绿 → **勿收刀／勿升 PROD／勿请批**。

## 残留
- 脚本／log：`_dig/dig_fwd_gs_root{,2,3,4,5,6,7,8}.py`／`.log`／本 md
- Win cave temps 已清；`p_ret_fwd.x` 已恢复；PROD／钉 **未动**
