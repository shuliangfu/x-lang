# DIG SoftCap 10.60 — call-mk `[4b0]==0` Isol-native imm→rdx **+** sub20 (`cmk0_irdx_sub20`)

**2026-10-30 ~17:45 CST (Asia/Shanghai)** · tip base `0a0c910c8` · Isol `9378df517f96` · host_b828 `0977d6fbb472` · plant sha12 `3f43f1609d70` · USER lit sha12 `78015bac7508`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue／+0x478／`[4b0]=1`／LIVE spill：遵守
- 先验：`cmk0_irdx` lit 绿 USER8 `b80a…4889c2`（无 sub20；fwd GS／local run=1）

## DIG（序／容量）
1. 承接 `cmk0_irdx`：lit USER `lea→rcx; mov eax,0xa; mov rdx,rax; call; add rsp,0x20`（**缺** call 前 `sub rsp,0x20`；影空失衡假说→fwd GS）。
2. 容量：`[rbp-0x80]..[rbp-0x68)`＝24B；USER12＝12B ≤24；`c643`×12＝48＋tail8＋pad17＝74B 窗。
3. **序钉死**：
   - imm→rdx **然后** sub20（`b80a…4889c24883ec20`）→ lit/local **AV**／fwd GS；INT3 `@57ba3b`＝AV（未成 USER）。
   - sub20 **然后** imm→rdx（`4883ec20b80a…4889c2`）→ lit **OK** run0；local OK run1；fwd **仍 GS**；INT3 **HIT**。
4. 对照：绿 host `cmk0_irdx` `bbe7d9819dfd` 本拍 lit 仍 OK（环境非崩）。

## Plant `cmk0_irdx_sub20`（单点；canonical＝sub20-first）
- `@57ba3b..@57ba84` → `c6 43 i imm` ×12 写 USER12 `4883ec20b80a0000004889c2`＋保 `[rbp-0x68]=0x20`＋nop；`@57ba94` eax 8→**12**；`@578266`／`@57ba85` 不动。
- host sha12=`3f43f1609d70`（base_828＋plant）

## SoftCap 门（Win cave；≤90s）
| plant | sha12 | lit | fwd | local | USER |
|---|---|---|---|---|---|
| cmk0_irdx_sub20 (imm+sub) | 1060073517a5 | **AV** | GS | AV | 未成；红（序） |
| cmk0_irdx_sub20 (sub+imm) | **3f43f1609d70** | **OK** `78015bac7508` run0 | **GS** | OK `021c621d2143` run1 | sub20＋imm→rdx 无 spill |
| INT3 `@57ba3b` | — | **INT3** | — | — | 路径 HIT |

lit USER（`@0xb04`）：`lea rcx; sub rsp,0x20; mov eax,0xa; mov rdx,rax; call; add rsp,0x20`。

**绿（lit）**：sub20-first＋imm→rdx 进 SoftCap lit；run=0。fwd 仍 GS（**证伪**「fwd GS＝仅缺 call-mk sub20」）。local 同 irdx：compile OK／run=1。

## 钉死
- USER 序：**必须** `sub20 → imm→rdx`；反序 compile AV。
- 12B／append=12／`c643` 可绿 lit（对比 `cmk0_rdx` LIVE16 红）。
- 恢复 sub20 **不**消 fwd compile GS → fwd 另根。

## 下一单点
- **`fwd_gs_root`**：单 DIG SoftCap `p_ret_fwd` compile GS 根因（lit/local 同 plant 可编；fwd 独 GS）。禁 tip@121278／join／epi／LIVE／mega／`[4b0]=1`／字母堆。
- fwd 未绿 → **勿收刀／勿升 PROD／勿请批**。

## 残留
- Win：temps 已清；`host_cmk0_irdx_sub20.exe`／`proof_cmk0_irdx_sub20_lit.exe`／`host_cmk0_irdx.exe` 可留对照（非 PROD）。
- 脚本／log：`_dig/dig_cmk0_irdx_sub20.py`／`.log`／本 md。
