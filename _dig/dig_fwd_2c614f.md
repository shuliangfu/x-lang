# DIG SoftCap 10.60 — `fwd_2c614f`

**2026-10-30 ~18:08 CST (Asia/Shanghai)** · tip base `646f3361a` · Isol `9378df517f96` · host plant `cmk0_irdx_sub20` sha12 `3f43f1609d70`

## 闸
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 `ecdb5cc1e` **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／假绿／整树／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278／join／epi／mega glue／+0x478／`[4b0]=1`／LIVE spill：遵守
- 先验：`fwd_gs_root`＝`return SoftCapCallExpr`→GS；`fwd_let` OK；stub 后 Capless `@5766ec→@2c614f` lastHIT `@2c61c1`

## DIG 钉死

### A) Real host vs stub 分界
| 探针 | fwd | let | lit |
|---|---|---|---|
| INT3 SoftCap `@2be519` | INT3 | INT3 | — |
| INT3 Capless `@5766ec` call `@2c614f` | **GS** | INT3 | — |
| INT3 `@2c614f` | **GS** | INT3 | INT3 |
| SoftCap scs_ret0 stub | GS | OK/AV | OK/AV |

**钉**：real SoftCap_site **入**但对 return-CallExpr **不返回**（Capless `@576697` store＝GS）。`@2c614f` **仅 stub 后继**；非 real-host fwd GS 落点。

### B) SoftCap_site（real）：kind＝`0x30`；miss→epi GS
1. SoftCap 只认 kind ∈ `{0x36,0x33,3}`；`@2be734` miss `eax=0`→`@2be90a` epi。
2. kind eq probe `@2be6cf`：fwd/let/**lit** 皆 **eax＝`0x30`**（非 0x36/0x33/3）。
3. INT3：miss `@2be734`/`@2be739` fwd+let HIT；epi `@2be90a` add rsp HIT；**`@2be911` pop：fwd=GS／let=INT3`**.
4. force SoftCap kind→`0x36`/`0x33`/`3`：fwd compile OK 但 lit USER 变（`78015bac7508`→`316d87f04203`）run=1 — **假绿／坏 lit**；禁作 plant。
5. SoftCap frame `0x150→0x180/190/1a0/1b0`（cover homes `rbp+0xe0..+0xf8`）：lit 仍 `78015bac7508` run0；**fwd 仍 GS** → **证伪**「仅 home 溢出 SoftCap 框」为 fwd 根。

### C) Capless `@2c614f`（scs_ret0 stub）
1. prol `sub rsp,0x190`；kind call `@2c61bc→@20cd98`；accept kind `0x30/0x31`.
2. kind eq：fwd/let 皆 **`0x30`**；lastHIT `@2c61c1`；其后 fwd GS.
3. `@20cd98`：双方 HIT 至 `@20cdd0`；其后 fwd GS（happy path）。
4. `force30+epi`（skip `@20cd98`＋`eax=0x30`＋jmp epi）：compile OK 但是 Capless 见 **eax>0 early-exit** — **假绿**（run=1；非 real SoftCap_site／USER）。
5. skip kind＋`eax=0`＋epi／jmp miss：fwd 仍 GS（Capless 续走后继）。

### D) 总钉（一句话）
`fwd_2c614f` 单点下：real GS＝SoftCap_site 对 kind=`0x30` 的 **miss-epi**（`@2be90a`/`pop`）在 `return SoftCapCallExpr` 上；let/lit 同 kind 可过 epi。`@2c614f` 是 stub 后继，内 GS 于 `@20cd98` 路径；**不是** call-mk sub20／imm→rdx／SoftCap frame 短／force kind 0x36。

## Plant
本拍 **无 Isol plant**（force kind／force30+epi＝假绿；frame 扩＝fwd 仍红；未获可保 lit 的 fwd 绿字节）。

## SoftCap 门（对照 host `3f43f1609d70`；未改 plant）
| | lit | fwd | local |
|---|---|---|---|
| cmk0_irdx_sub20 | OK `78015bac7508` run0 | **GS** | OK run1 |
| scs frame 0x190（诊） | OK 同 lit sha | GS | OK |
| force kind 0x36（诊） | OK 但 sha/run 坏 | OK run1 假 | OK run1 |

## 下一单点（唯一）
- **`fwd_scs_epi`**：DIG SoftCap kind=`0x30` miss-epi 上 return-CallExpr vs let／lit 分歧（Capless 调用参数／栈槽／cookie／是否二次入站）→可 Isol 单点。禁 tip@121278／join／epi-raise／LIVE／mega／`[4b0]=1`／字母堆／假绿 force-kind。
- fwd 未绿 → **勿收刀／勿升 PROD／勿请批**。

## 残留
- 脚本／log：`_dig/dig_fwd_2c614f{,2..7}.py`／`.log`／本 md
- Win cave temps 已清；`p_ret_fwd.x` 已恢复；PROD／钉 **未动**
