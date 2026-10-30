# DIG SoftCap 10.60 — call-mk `[4b0]==0` Isol-native imm→rdx (`cmk0_rdx`)

**2026-10-30 ~17:32 CST (Asia/Shanghai)** · tip base `6c0e76d01` · Isol `9378df517f96` · host_b828 `0977d6fbb472` · plant sha12 `3a6ac64a6dc0`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue／+0x478 fill：遵守
- 先验钉死：无非空壳 args；`immrdx_bypass` 强制 `[4b0]=1`→红 AV；Frontier＝`cmk0_rdx`（保 call-mk／不抬 `[4b0]`）

## DIG（Isol-native；`[4b0]` 保持 0）
1. call-mk `@57b98c`：`[rbp-0x30]←Capless [4b0]`。`[4b0]==0`：`@57ba0f` 落 `@57ba3b` 字节拼 USER `48 83 ec 20`（`88 83 disp32`＋每字节 `lea rbx,[rbp-0x80]`）→ `@57ba85` `sub rsp,0x20` → setup → append `@2a7f07`（len=`@57ba94` eax=4）→ `@57bafe`。
2. `[4b0]!=0`：je `@57bafe` 跳过字节拼；本拍 **未** 强制 `[4b0]=1`（`@578266` 完好 `8b8db0040000`）。
3. base_828 lit：`lea→rcx; sub20; call`；`has_imm10=True mov_rdx=False sub20=True call=True`；run=`crc=1`（call 后比较常量 `mov eax,0xa`，非 call 前 imm→rdx）。
4. 原窗 `@57ba3b..@57ba84`＝74B 恰落 `@57ba85`（`sub rsp,0x20`）指令边界；`c643` 计数＝0（Isol 用 `88 83` 非 `c6 43`）。

## Plant `cmk0_rdx`（单点）
- `@57ba3b..@57ba84`（74B）→ compact `c6 43 disp imm` ×16 写 LIVE 形 USER16 `b80a000000488945c8488b45c84889c2`＋保 `[rbp-0x68]=0x20`＋nop；`@57ba94` eax 4→16；`@578266` 不动。
- host sha12=`3a6ac64a6dc0`（base_828＋plant）

## SoftCap 门（Win cave `windows-server`；≤90s；elapsed 1.4s）
| plant | sha12 | lit | fwd | local | USER imm→rdx | call-mk |
|---|---|---|---|---|---|---|
| cmk0_rdx | 3a6ac64a6dc0 | **AV** | **GS** | **AV** | — | —（未成 USER） |
| INT3 `@57ba3b`（plant／`[4b0]==0`） | — | **INT3** | — | — | 路径 HIT | — |
| INT3 `@575799`（`[990]==1` 体） | — | **AV**（非 INT3） | — | — | `[4b0]` 保持 0 | — |

**红**：`[4b0]==0` 字节拼路径确认 HIT；将 USER 换 LIVE 形 16B＋`c643` 紧凑写 → **compile AV**。未抬 `[4b0]`／`[990]==1` 体未 HIT。疑点：`[rbp-0x80]` 暂存容量／append 目标按 4B 假设；或 `c643`≠Isol `88 83` 写风格；LIVE spill 形近禁区。

## 钉死
- 不抬 `[4b0]` 时 call-mk `[4b0]==0` 字节拼 **可达**（INT3）。
- 直接把 call-mk USER blob 换成 LIVE 形 imm→rdx（16B／`c643`）**不可**绿（compile AV）。
- Imm→rdx 仍缺；base_828 call-mk（sub20／len=4）仍可用。

## 下一单点
- **`cmk0_irdx`**：同 `[4b0]==0` 窗，改发 **Isol-native** 10B `b80a0000004889c2`（`mov eax,0xa; mov rdx,rax`；**无** LIVE `[rbp-0x38]` spill）；先 DIG `[rbp-0x80]` 容量／append 上限；写风格优先 Isol `88 83` 或确认容量后 `c643`；`@57ba94` 4→10；fallthrough 保持 `@57ba85`；**禁** `[4b0]=1`／LIVE spill／mega glue／+0x478／tip@121278／join／epi。
- 容量＜10 → 改钉 Capless `@567a30` post-`@5688b7` literal-imm 闸（不延长 call-mk USER blob）。
- 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

## 残留
- Win：`_dig_cmk0_*`／`_tmp_host_cmk0*`／`host_cmk0_rdx.exe` 已清；`host_b828.exe` 可留对照（非 PROD）。
- 脚本／log：`_dig/dig_cmk0_rdx.py`／`.log`／本 md。
