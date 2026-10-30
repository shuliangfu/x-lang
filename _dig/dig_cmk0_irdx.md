# DIG SoftCap 10.60 — call-mk `[4b0]==0` Isol-native imm→rdx (`cmk0_irdx`)

**2026-10-30 ~17:40 CST (Asia/Shanghai)** · tip base `b169312cf` · Isol `9378df517f96` · host_b828 `0977d6fbb472` · plant sha12 `bbe7d9819dfd` · USER lit sha12 `776e855a8cae`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue／+0x478／再搬 LIVE spill：遵守
- 先验：`immrdx_bypass` 强制 `[4b0]=1`→AV；`cmk0_rdx` LIVE16＋`c643`→compile AV（INT3 `@57ba3b` HIT）

## DIG（`[rbp-0x80]` 容量／写窗）
1. `@57ba34` `lea rax,[rbp-0x80]; mov rbx,rax` → plant 入口 rbx 已指向暂存。
2. 原 `@57ba3b..@57ba84`＝74B：Isol `mov eax,imm`＋`88 83 disp32` ×4 写 USER `48 83 ec 20`；`c643`＝0；随后 `mov [rbp-0x68],0x20`；fallthrough `@57ba85` `sub rsp,0x20`（call-mk 自身）→ append `@2a7f07`（len=`@57ba94` eax=4）。
3. 容量：`[rbp-0x80]..[rbp-0x68)`＝**24B**；Isol-native 8B／原 4B／LIVE16 均 ≤24（`cmk0_rdx` AV ≠纯容量）。
4. Isol 全形 `88 83`（≈11B/字节）×8＝88 **>** 74B 窗 → plant 用 `c643`（rbx 已 live）。
5. 目标 hex `b80a0000004889c2`＝**8B**（brief「10B」为口述；`@57ba94` 4→**8**）。

## Plant `cmk0_irdx`（单点）
- `@57ba3b..@57ba84` → `c6 43 i imm` ×8 写 USER8 `b80a0000004889c2`（`mov eax,0xa; mov rdx,rax`；**无** LIVE `[rbp-0x38]` spill）＋保 `[rbp-0x68]=0x20`＋nop；`@57ba94` eax 4→8；`@578266`／`@57ba85` 不动。
- host sha12=`bbe7d9819dfd`（base_828＋plant）

## SoftCap 门（Win cave；≤90s；settle+retry）
| plant | sha12 | lit | fwd | local | USER imm→rdx | call-mk |
|---|---|---|---|---|---|---|
| cmk0_irdx | bbe7d9819dfd | **OK** `776e855a8cae` run=0 | **GS** | **OK** `0728e2d1689c` run=1 | lit/local **有** `b80a…4889c2` 无 spill | 保（`[4b0]` 未抬） |
| INT3 `@57ba3b` | — | **INT3** | — | — | 路径 HIT | — |

lit USER（`@0xb04`）：`lea rcx,[rbp-0x28]; mov eax,0xa; mov rdx,rax; call`（无 sub20／无 LIVE spill）；n868=2。

**绿（lit）**：Isol-native imm→rdx 已进 SoftCap lit USER；run=0。fwd 仍 GS；local compile OK 但 run=1（非 0）。

## 钉死
- `[rbp-0x80]` 24B 够 8B；`c643`＋append len=8 **可**绿 lit（对比 `cmk0_rdx` LIVE16 红）。
- 不抬 `[4b0]`；call-mk `[4b0]==0` 字节拼仍 HIT（INT3）。
- 纯 b828 宿主本拍偶发 AV（环境／Defender settle）；irdx 宿主 sleep 后 lit 稳定 OK。

## 下一单点
- **`cmk0_irdx_sub20`**：同窗 USER 拼 Isol-native imm→rdx **并**保留 `sub rsp,0x20` 影空（fwd GS 疑缺 shadow；8+4=12B ≤24／`c643` 仍贴进 74B）；或单 DIG fwd GS 根因。
- 禁 `[4b0]=1`／LIVE spill／mega glue／+0x478／tip@121278／join／epi。
- fwd 未绿 → **勿收刀／勿升 PROD／勿请批**（lit 单门绿不收刀）。

## 残留
- Win：`_dig_cmk0i_*`／`_tmp_*`／`_gate_*`／`_retry_*`／`_confirm_*`／`cave2` 已清；`host_cmk0_irdx.exe`／`proof_cmk0_irdx_lit.exe`／`xlang_hirdx.exe` 可留对照（非 PROD）。
- 脚本／log：`_dig/dig_cmk0_irdx.py`／`.log`／本 md。
