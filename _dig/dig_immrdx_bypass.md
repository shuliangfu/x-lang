# DIG SoftCap 10.60 — Isol-native imm→rdx bypass (`immrdx_bypass`)

**2026-10-30 ~17:26 CST (Asia/Shanghai)** · tip base `baadfa029` · Isol `9378df517f96` · host_b828 `0977d6fbb472`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue：遵守
- 先验钉死：Cap≠Capless／pre_last 另槽无异源已填 `@2a62c9`；call-mk 已在 base_828；缺 imm→rdx；arg 容器证伪

## DIG（Isol-native；不经 +0x478 fill）
1. Capless `@578266`：`mov ecx,[rbp+0x4b0]` → `@57826c` `[rsp+0x20]` → call-mk `@57b98c`；call-mk 把 5th stack arg 写入 `[rbp-0x30]` → `@5752bc` 的 `[990]`。
2. call-mk `[4b0]==0`：`@57ba0f` 落 `@57ba3b..` **字节拼** USER `48 83 ec 20`（sub rsp,0x20）→ append `@2a7f07` → `@57bafe`→`@5752bc`（`[990]=0`）。SoftCap lit USER＝`lea→rcx; sub rsp,0x20; call`（保 call-mk）。
3. call-mk `[4b0]!=0`：跳过 sub20 拼装，直 `@57bafe`→`@5752bc`（`[990]=N`）。`[990]==1` 体 `@575799`；`[990]==0` 环后 `jne @575fa3` skip。
4. base_828 SoftCap lit USER 已有 **call 后** `mov eax,0xa`（比较常量），**无** call 前 `mov eax,0xa; mov rdx,rax`。`has_imm10=True mov_rdx=False sub20=True call=True`；run=`crc=1`。
5. Capless pre `@567a30`：含 get-elem `@56888d→@2a62c9`（空壳 skip）；**零** B8/BA/`0xa` opcode-imm builder。rdx builders `@516b34/@529761/@52a5e4/@53606b`／B8 `@1b9b5b/@18f0cc`：Capless/call-mk 窗 caller＝**0**。

## Plant `immrdx_bypass`（单点）
- 位点：`@578266` `8b8db0040000` → `b90100000090`（`mov ecx,1; nop`）；保 `@57826c` store＋call-mk；**不**触 +0x478／get-elem／mega glue。
- host sha12=`c2356eb95682`（base_828＋plant）

## SoftCap 门（Win cave；≤90s）
| plant | sha12 | lit | fwd | local | USER imm→rdx | call-mk |
|---|---|---|---|---|---|---|
| immrdx_bypass | c2356eb95682 | **AV** | **GS** | **AV** | — | —（未成 USER） |
| INT3 `@575799`（[990]==1 体） | — | AV（非 INT3） | — | — | AV 在体前 | — |
| INT3 `@575fa3`（skip） | — | AV（非 INT3） | — | — | 同上 | — |

**红**：强制 `[4b0]=1` → call-mk/`@5752bc` 在空容器上进 `[990]==1` 走廊，**compile AV**；旁路 get-elem 失败。`[990]==1` 体未 HIT（AV 更早）。

## 钉死
- 单点抬 `[4b0]/[990]` **不可**在 SoftCap lit 空壳下激活 Isol-native arg emit（AV）。
- Imm→rdx 仍缺；call-mk（`[4b0]==0` sub20）仍在 base_828 下可用。

## 下一单点
- **`cmk0_rdx`**：钉在 call-mk **`[4b0]==0`** 路径（保 sub20／call-mk）：寻 Isol-native gate／`@5752bc` 残迹／pre-call B8 姐妹，使 SoftCap lit 在 **不抬 argcount、不填 +0x478、禁 mega glue** 下发出 arg0 imm→rdx。备选：`@567a30` post-`@5688b7` skip 的 literal-imm 闸。
- 禁 tip@121278／join／epi／LIVE／mega／arg-loop／mega glue。
- 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

## 残留
- Win：`_dig_ibyp_*`／`_tmp_host_immrdx*`／probes 已清；`host_immrdx_bypass.exe`／`host_b828.exe` 可留作对照（非 PROD）。
- Mac：本笔记＋`_dig/dig_immrdx_bypass.py`／log。
