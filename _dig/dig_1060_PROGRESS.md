# 10.60 SoftCap DIG PROGRESS

**2026-10-30 ~15:50 CST (Asia/Shanghai)** · DIG Capless post-success→USER `0x868`：**falsified** tip`@127212` diag-only；kind`0x31` SoftMega off-path／0×`0x868`；Capless-band imm 未 HIT；**plant 不可隔离** → 勿升 PROD／钉 **不升**／勿收刀 · 下一单点：Capless-**internal** USER enc `frame_sz`→`enc_prologue`（禁 tip@121278／join／epi／LIVE／mega）

## 2026-10-30 ~15:50 CST Asia/Shanghai — DIG Capless post-success → USER 0x868

### 0) 闸
- tip HEAD `fd9961038`＝origin/dev（本拍前；commit 后见 tip）
- Base alt_frame2 `9378df517f96`；短超时 INT3；cave `_dig_host_ps*` 已清
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／tip@121278 再跳／join／epi：遵守

### 1) DIG 钉死（本拍）
1. Capless epi `@578278`／tip post `@127212` **HIT**；tip post＝diag only → **无** SoftCap USER `frame_sz`／`enc_prologue(0x868)` 接线。
2. Capless-miss `@521f10/@521d78/@524944` **HIT**＝≤16 size-dispatch ≠ USER `0x868`。
3. kind`0x31` SoftMega `@57ef78` lit **OK**(off-path)；SoftMega band **0×** `sub rsp,0x868`；HOST `0x868` 仍 tip／`0xec` 带。
4. Capless body `mov eax,0x68/0x1b8/0x868` n=0；Capless-band `0x68` 未 HIT；baseline lit 薄 `0x68+0x1b8`。
5. Capless 内调 CapFN／post_args／clc68／last`@57b98c`；薄帧在 Capless **内部** enc 完成，post-success 不再抬帧。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| alt_frame2 | `9378df517f96` | compile OK／GS／OK；emit 薄；run rc=1 |
| 本拍 plant | — | **不可隔离**（无 on-path imm HIT） |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. Capless post-success 无 SoftCap USER 帧选路；`0x868` 仍 HOST SoftCap 模板、未进 Capless-internal enc arg。
2. Ban tip@121278／join／epi／LIVE／mega／arg-loop。

### 5) 下一拍最小刀
1. 单点 DIG／Isol：Capless-**internal** USER enc（`frame_sz`→`enc_prologue` for mk/main）；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_post_succ_868.md`；脚本 `_dig/dig_post_succ_868.py`（+b/c）
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**



# DIG 10.60 SoftCap PROGRESS

**2026-10-30 ~15:55 CST (Asia/Shanghai)** · DIG Capless→SoftCap lit wire：tip kind`0x30`→Capless thin `enc_prologue`；tip`@121278` off-path（tip_scfull crc=0x1）；`@21b5fa` 簇 HIT＝Cap-decode≠USER `0x868`；Isol `mov eax,0x868` n=0；**plant 本拍不可隔离** → 勿升 PROD／钉 **不升**／勿收刀 · 下一单点：Capless post-success→SoftCap USER frame_sz／enc（禁 tip@121278 再跳／join／移植／arg-loop）


## 2026-10-30 ~15:55 CST Asia/Shanghai — DIG Capless→SoftCap lit wire；plant 不可隔离

### 0) 闸
- tip HEAD `4e0f1d6c3`＝origin/dev（本拍前；commit 后见 tip）
- Base alt_frame2 `9378df517f96`；短超时 INT3；已清 cave `_dig_host_lw*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／join／epi：遵守

### 1) DIG 钉死（本拍）
1. tip SoftCap `@121278`：`sub rsp,0x868`；sole E8 `@1215b9`；call `@21b5fa` rdx=0；**≠** Capless USER emit 写者；tip_scfull 仍 **crc=0x1**。
2. lit 走 tip kind **`0x30`→Capless `@57656c`**（INT3 TIMEOUT on-path）；baseline 薄 **`0x68`/`0x1b8`**、`0x868=False`。
3. SoftCap flag SoftCap=0／≠0 **已证伪**（scap0）；Isol **`mov eax,0x868` n=0**。
4. `@21b5fa` 簇 `@1203ae`…**HIT**＝Cap-decode mid-body，**非** USER `enc_prologue(0x868)`；tip `@1212aa` **未 HIT**。
5. 接线缺口＝**kind/site**：Capless 薄帧选路；tip`@121278` 族未接 USER SoftCap lit。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| alt_frame2（基） | `9378df517f96` | compile OK／GS／OK；emit 薄；**无新 plant** |
| tip_scfull（先验） | `ca90e6fd3276` | **crc=0x1** |
| lit_wire／enc_868 | — | **本拍不可隔离**（无 on-path imm HIT） |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿**（emit≠LIVE `0x868`） |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. Capless→SoftCap USER lit `0x868` 接线缺口（kind`0x30`→Capless thin；无 Isol SoftCap USER frame 写者）。
2. Ban tip`@121278` 再跳／join／epi／移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG／Isol：Capless post-success → SoftCap USER `frame_sz`／`enc_prologue(0x868)`（或 kind`0x31` Isol-native USER 写者）；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_lit_wire.md`；脚本 `_dig/dig_lit_wire.py`（+wire2/3/4）
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~15:40 CST Asia/Shanghai — DIG join→epi／0x868 writer；Isol join_epi 红

### 0) 闸
- tip HEAD `afc930226`＝origin/dev（本拍前；commit 后见 tip）
- Base alt_frame2 `9378df517f96`；短超时 INT3；已清 cave `_dig_host_je_*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. Join `@576523`：`eax=[rbp+0x934]; cmp [rbp+0x998]; jl @5763e5` → fall `@576535 call @24b022` → epi `@576555 add rsp,0x9e0`。
2. Force-exit `@5763d6` clear-934＋jmp join：count>0 时 **jl 再入**；真退环 land＝`@576535`／`@576555`。
3. INT3：clr934／jl／post_jl／inc934 **HIT**；baseline lit OK 仍 **薄 `0x68/0x1b8`**、`0x868=False`。
4. **`0x868` 写者＝SoftCap tip `@121278` 族**（HOST 29×；sole E8 `@1215b9`），≠ Cap FN `0x9e0`／≠ join-epi；Capless `enc_prologue`／`compute_frame_size` → 薄帧。
5. Isol `join_epi` `ff46f731435d`（`@5763e0→@576535`）：lit/fwd/local **AV/GS/AV**；**非运行绿**。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| alt_frame2 | `9378df517f96` | compile OK／GS／OK；emit 薄；run rc=1 |
| join_epi | `ff46f731435d` | **AV／GS／AV** |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿**（emit≠LIVE `0x868`） |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit 用户 emit 未接 tip `0x868` 写者；join/epi 再跳无效。
2. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG／Isol：**Capless→SoftCap lit emit 接线**（tip `@121278`／`0x868` vs Capless `enc_prologue` 薄帧）；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_join_epi_868.md`；脚本 `_dig/dig_join_epi.py`；cave Isol `join_epi`
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~15:55 CST Asia/Shanghai — DIG alt bad-frame／rbp；Isol alt_frame2 编译假过

### 0) 闸
- tip HEAD `e9a1367bd`＝origin/dev（本拍前；commit 后见 tip）
- Base post_fa3 `453f3e66f96c`／alt `e1c45031fb92`；短超时 INT3；已清 cave `_dig_host_*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. Cap FN `@5752bc`：`sub rsp,0x9e0; lea rbp,[rsp+0x80]`；alt 槽 `+0x8fc/+0x904/+0x934` 在帧内；`+0x970..998`＝arg home／count。
2. **`@5603b8`＝合法 prol＋epi `@560dc7`**（`lea rsp,[rbp-8]; pop rbx; pop rbp; ret`）——**证伪**「缺 rbp 保存／恢复」。
3. 先前 `add [rbp+0x934]` AV＝**mid-insn／loop 误读**；skip 后 inc／post_loop 可达；`934=0<[rbp+0x998]` → `jl` 再入环。
4. SoftCap lit `0x868`／Capless `0x1b8`＝**用户 emit** 差距，≠ host Cap FN 帧。
5. Isol `alt_frame2` `9378df517f96`：jmp `@57629b→@5763d6` → join HIT；lit／local **compile OK** 但 emit **薄 `0x68/0x1b8`**、运行 **rc=1**；fwd **GS**；**非运行绿**。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| alt_57619e | `e1c45031fb92` | AV／GS／AV |
| alt_frame | `313533ca3651` | TIMEOUT／GS／TIMEOUT |
| alt_frame2 | `9378df517f96` | compile OK／GS／OK；**run rc=1／—／rc=1** |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿**（emit≠LIVE `0x868`） |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit 仍无 LIVE 形 `0x868/0x878` 写出；alt skip 后 join／epi 路径未稳。
2. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG join `@576523`→`@576555`／谁在 SoftCap lit 写帧 `0x868`（相对 Capless 薄包装）；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_alt_badframe.md`；plant `_dig/build_isol_alt_frame2.py`；cave alt_frame2／fix_rbp
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~15:50 CST Asia/Shanghai — DIG @57619e alt；@56fa68 mid-insn；@5603b8 bad frame；Isol alt_57619e 红

### 0) 闸
- tip HEAD `407d51bdc`＝origin/dev（本拍前；commit 后见 tip）
- Base post_fa3 `453f3e66f96c`／h3_jesk `cfb0fae4f5d9`；短超时 INT3；已清 cave `_dig_host_*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. `@57619e` alt 可达（`je @576134`；`call @5603b8`／`@56fa68` 位点 **HIT**）。
2. **`@56fa68`＝mid-insn**（`mov [rbx+disp],al` clear；无 prol）——同 `@5862f8/@5863c9` 类。
3. **`@5603b8`＝合法 prol**（entry INT3 HIT）；after-call／body 仍 AV ⇒ **坏帧／rbp**，非缺 call-mk 单因。
4. Isol `alt_57619e` `e1c45031fb92`：`jmp @5761c2→@57629b` → inc **HIT**；loop／exit 仍 AV（inc store 触坏 rbp）；p_ret **AV／GS／AV**。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| post_fa3 | `453f3e66f96c` | AV／GS／AV |
| alt_57619e | `e1c45031fb92` | AV／GS／AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit AV 在 `@57619e` alt：mid-insn `@56fa68` + `@5603b8`/skip 后 **坏帧**。
2. 无稳定 Isol-native SoftCap lit `0x868` 写出／p_ret 运行绿。
3. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG alt **坏帧／rbp** 根（post_fa3 skip 副作用／`@5603b8` body）；短超时；勿只再 skip mid-call。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_alt_57619e.md`；plant `_dig/build_isol_alt_57619e.py`；cave alt_57619e／post_57619e
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


**2026-10-30 ~15:40 CST (Asia/Shanghai)** · SoftCap lit post-`@575fa3`：clear+`@5762a2` loop **HIT** · AV根＝`@5760c2→@5862f8`／`@5760fb→@5863c9` **mid-insn**（非合法入口）· Isol `post_fa3` `453f3e66f96c` jmp-skip → `@57619e` HIT；p_ret **AV／GS／AV** · SoftCap **未绿** → 勿升 PROD／钉 **不升**／勿收刀 · 下一拍：`@57619e` alt（`@5603b8`／`@56fa68`）→`@57629b`；禁长挂／移植／arg-loop／twin／字母堆


## 2026-10-30 ~15:40 CST Asia/Shanghai — DIG post-@575fa3／@5762a2；AV＝mid-insn call；Isol post_fa3 红

### 0) 闸
- tip HEAD `ab6639cf1`＝origin/dev（本拍前；commit 后见 tip）
- Base h3_jesk `cfb0fae4f5d9`；短超时 INT3；已清 cave `_dig_host_*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. post-fa3 clear `@575fa3..@576052` HIT；`jmp @5762a2` loop cond／body head／`call @1ff2a3` HIT。
2. **AV root**：`@5760c2 call @5862f8`／`@5760fb call @5863c9` 落在 clear 序列 **mid-insn**（`@5862f0 mov [rbx+0x104],eax` 中部），非合法入口。
3. Isol `post_fa3` `453f3e66f96c`：`jmp @5760c2→@576110` 跳过坏 call 块 → `@576110`／`@576132`／`@57619e` HIT；仍 AV 于 alt→`@57629b` 前。
4. SoftCap p_ret lit／fwd／local ＝ **AV／GS／AV**（非绿）。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| h3_jesk | `cfb0fae4f5d9` | AV／GS／AV |
| post_fa3 | `453f3e66f96c` | AV／GS／AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit AV 在 call-mk loop alt `@57619e` 后（坏 mid-insn call 已跳过仍红）。
2. 无稳定 Isol-native SoftCap lit `0x868` 写出／p_ret 运行绿。
3. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG `@57619e` alt／`@5603b8`／`@56fa68` → `@57629b`；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_post_fa3.md`；plant `_dig/build_isol_post_fa3.py`；logs post_fa3／5862f8／post_fa3b
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~15:25 CST Asia/Shanghai — DIG SoftCap lit post-@201f36；AV ≠ @201ddf；入 call-mk→@575fa3

### 0) 闸
- tip HEAD `8c3fcd91a`＝origin/dev（本拍前；commit 后见 tip）
- Base h3_jesk `cfb0fae4f5d9`；短超时 INT3；已清 cave `_dig_host_*`
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. Capless post-`@201f36`：`@201ea0`／`@201ddf` **entry→ret HIT** ⇒ **AV ≠ `@201ddf`／+0x150**（证伪）。
2. Cap join `@577681`→kind3 `@577c37`→`@1ff2ef`→`@578273 call @57b98c`：**入 call-mk**（`@57bb30` HIT）。
3. `@5752bc`：`@563e0c` HIT；**eax==2 fallthrough**→`@5aaf18` HIT；loop `@5755a9`／join `@575778` HIT。
4. Loop exit `@575793 jne @575fa3` **HIT**；`@575fa3` clear 路径体 HIT（`@575fb7`／`@575fcc`／`@575fe3`／`@575fef`…）。
5. Frontier＝post-fa3 clear／`@57605c jmp @5762a2`（未全 densed）。
6. Plants：skip_ddf→T001；kind_ft→仍 AV；非绿。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| h3_jesk | `cfb0fae4f5d9` | AV／GS／AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit AV 在 call-mk `@5752bc` post-`@575fa3` clear（非 `@201ddf`）。
2. 无稳定 Isol-native SoftCap lit `0x868` 写出／p_ret 运行绿。
3. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG `@575fa3` post-clear／`@5762a2`；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_post_f36.md`；logs post_jmp／post_loop／fa3＋既有
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~15:15 CST Asia/Shanghai — DIG SoftCap lit post-@201f36；AV ≠ @201ddf/+0x150；入 call-mk

### 0) 闸
- tip HEAD `8c3fcd91a`＝origin/dev（本拍前；commit 后见 tip）
- Base h3_jesk `cfb0fae4f5d9`；短超时 INT3；已清 cave `_dig_host_*`（盘满）
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. Capless post-`@201f36`：`call @201ea0`（size +0x250）**entry→ret HIT**；`call @201ddf`（memcpy +0x150）**entry→memcpy→ret HIT**。
2. ⇒ **AV root ≠ inside `@201ddf`／+0x150**（证伪本拍前假设）。
3. Cap join `@577681` HIT → kind3 exit `@577c37` HIT → `@1ff2ef` HIT → `@578273 call @57b98c` **入 call-mk**。
4. call-mk：`@57bb30 call @5752bc` HIT；`@5752bc` 深 HIT（`@5754ed`／`@1ff2a3` 全 HIT／`@563e0c` HIT／`@575645`／`@575648` HIT）。
5. Frontier＝post-`@575648`（`@575667 call @5aaf18`／skip `@575778` plant AV）。
6. Plants：skip_ddf→T001；kind_ft→仍 AV；非绿。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| h3_jesk | `cfb0fae4f5d9` | AV／GS／AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit AV 在 call-mk `@5752bc` post-`@575648`（非 `@201ddf`）。
2. 无稳定 Isol-native SoftCap lit `0x868` 写出／p_ret 运行绿。
3. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG call-mk `@5752bc` post-`@575648`（`@5aaf18`／skip／eax==2 分支）；短超时。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_post_f36.md`；logs post_f36／post_ddf／post_kind／k3_epi／callmk*／5752bc／5754c1／1ff2a3／post_1ff
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


**2026-10-30 ~15:10 CST (Asia/Shanghai)** · SoftCap lit emit `call @201f36` **AV root 钉死：非 @201f36 内**（entry→ret HIT；args `node@+0x490`／`idx@+0x424`／`buf@+0x60` OK）· AV＝Capless **返回后**（`@201ea0`／`@201ddf`）· SoftCap **未绿** → 勿升 PROD／钉 **不升**／勿收刀 · 下一拍：post-`@201f36` SoftCap lit AV（`@201ddf`/+0x150）单点；禁长挂／移植／arg-loop／twin／字母堆


## 2026-10-30 ~15:10 CST Asia/Shanghai — DIG SoftCap lit emit @201f36 AV root；完成非内 AV

### 0) 闸
- tip HEAD `a783501e1`＝origin/dev（本拍前；commit 后见 tip）
- Base h3_jesk `cfb0fae4f5d9`；短超时 INT3（已杀 run_scsite 长挂）
- PROD SoftCap `7a2cf5da581a` **未动**／钉 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop／twin：遵守

### 1) DIG 钉死（本拍）
1. Caller `@576f47`：`buf=[rbp+0x60]`／`idx=[rbp+0x424]`／`node=[rbp+0x490]` → `call @201f36`。
2. SoftCap lit `@201f36`：**entry→save args→lookup→load+120→memset→memcpy+20→ret 全 HIT**。
3. Call-site `@576f5e`／after `@576f63` INT3→AV＝plant／返回后现象；**非** `@201f36` 体内 AV。
4. ⇒ SoftCap lit Cap emit copy **成功**；blocker＝Capless post-return（`@201ddf` `node+0x150`／size`+0x250` 先前 DIG AV；skip→T001≠绿）。
5. 已杀卡住 `run_scsite`／ssh；勿再开长挂探测。

### 2) Win SoftCap 门
| Isol | sha12 | lit |
|---|---|---|
| h3_jesk | `cfb0fae4f5d9` | AV（基；@201f36 内完成） |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit Capless AV **after** `@201f36`（`@201ddf` 路径）。
2. 无 Isol-native SoftCap lit call-mk／`0x868` 写出。
3. Ban 移植／arg-loop／twin／字母堆／长挂。

### 5) 下一拍最小刀
1. 单点 DIG SoftCap lit post-`@201f36` AV（`@201ddf`／+0x150）；短超时；禁长挂。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_f36_av.md`；log f36root.log／f36.log
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


**2026-10-30 ~15:00 CST (Asia/Shanghai)** · Capless SoftCap lit **原生入** Cap`@0024e6`-class `@576d5a`（post_alt jne；kind`@+0x45c==0x2c`）· helpers `@201eeb`/`@20cd98`/`@20203f` HIT · emit call `@201f36` **AV** · SoftCap **未绿** → 勿升 PROD／钉 **不升**／勿收刀 · 下一拍：`@201f36` SoftCap lit 无 AV（禁移植／arg-loop／twin／字母堆）


## 2026-10-30 ~15:00 CST Asia/Shanghai — DIG Capless SoftCap lit native Cap@0024e6-class @576d5a；emit @201f36 AV

### 0) 闸
- tip HEAD `fe3bef32d`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit `dbaab1c7ce70`；TT lit `5b173cef1205`
- Base h3_jesk `cfb0fae4f5d9`；plants：h4_gate `7e97f37cb781`；exit_ret `299d81d804e7`（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop 强跳／twin retarget：遵守

### 1) DIG 钉死（本拍）
1. Capless SoftCap lit（h3_jesk）：h5 early-fail→after_h5→`@200ff7`→jle `@576b7b` post_alt。
2. post_alt：`[rbp+0x444]≠0x2c` → **jne `@576b82` HIT** → `@576d5a`（**非** std_fmt `@56d014`／`println` 路径；该路径 SoftCap lit 未走；dense INT3 多 TIMEOUT／AV，已杀）。
3. **`@576d5a` Cap`@0024e6`-class（Isol-native SoftCap lit）**：
   - `[rbp+0x460]≠0`；`[rbp+0x45c]==0x2c`（异于 `+0x444`）
   - `@201eeb`（0x2c→`+0x14c`）INT3 HIT through ret
   - `@20cd98`（kind==3）HIT ok3 `@20cdfa`
   - `@20203f`（kind3→size `+0x120`）HIT through ret
4. Buffer clear `@576df3..@576f47`；`call @201f36` `@576f5e` SoftCap lit **AV**；后续 `@201ea0`/`@201ddf`/`@6354f0` 未稳达。
5. **h4_gate**（跳 `@2b49f3`）→ SoftCap lit **TIMEOUT**（禁形）。**exit_ret**（`@578273` force eax=1）仍 AV（epilogue／`@57b98c`）。post_sz 未建成（ssh 卡；已杀）。
6. ⇒ tip_c21k 死 ABI `@28f496` 证伪后，**Capless SoftCap lit 原生抵达** 同族 Cap helpers；blocker＝emit `@201f36` AV（非 arg-loop）。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| h3_jesk | `cfb0fae4f5d9` | AV／GS／AV（基） |
| h4_gate | `7e97f37cb781` | TIMEOUT（禁） |
| exit_ret | `299d81d804e7` | AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. SoftCap lit Cap`@0024e6`-class emit `call @201f36` AV。
2. 无 Isol-native SoftCap lit call-mk／`0x868` 写出。
3. Ban 移植／arg-loop／twin／字母堆。

### 5) 下一拍最小刀
1. 单点 DIG `@201f36` SoftCap lit AV root（args／buf `@rbp+0x60`／idx）；禁 arg-loop／移植。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_post_d5a.md`；logs d5a.log／d5a2.log／d5a3.log／post_alt.log
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


**2026-10-30 ~14:50 CST (Asia/Shanghai)** · Capless h3 SoftCap lit **过 `@46a71c`／`@46a837` AV 窗**（h3_jesk）· h3 **ret**＋Capless h3_ok／call_h4；**AV 移 h4 `@493d31`** · SoftCap **未绿** → 勿升 PROD／钉 **不升**／勿收刀 · 下一拍：Capless h4 SoftCap lit 无 AV（禁移植／arg-loop／twin／字母堆）


## 2026-10-30 ~14:50 CST Asia/Shanghai — DIG Capless h3 SoftCap lit past @46a71c；h3_jesk 证伪（AV→h4）

### 0) 闸
- tip HEAD `cb9d77daa`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit `dbaab1c7ce70`；TT lit `5b173cef1205`
- Base site_abi_c36 `29a8ae206733`；plants：h3_je `a4461bae5d62`；h3_jesk `cfb0fae4f5d9`（语义短名）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop 强跳／twin retarget：遵守

### 1) DIG 钉死（本拍）
1. Capless h3 SoftCap lit（c36 SoftCap-site miss→h3）：**已走** `@46a71c` equal→`@46a756`；不等 AV 窗 `@46a71e..@46a741 @1fb0ec` **本拍 lit 未走**。
2. Equal 后续：至 `@46a82b je @46a8a5`；fallthrough `@46a837..@46a8a0` **AV／TIMEOUT**（h3_eq_path DIG）。
3. **h3_je**：`@46a82b je→jmp @46a8a5`。INT3：eq_land／je_force／exit_alt／kind3／after_kind／Capless jns／h3_ok／call_h4。lit／local **AV**；fwd **GS**。`@46a837` 未命中（跳过）。
4. **h3_jesk**：h3_je＋`@46a90c jne→jmp`（跳 `@2a3d37`）。SoftCap lit INT3：**h3_ret**／after_h3／jns／**h3_ok**／**call_h4**／post_args／`@201d9f`／`@200ff7`；**h4 `@493d31` AV**；calt_exit AV。lit／local AV；fwd GS。
5. ⇒ Capless h3 SoftCap lit **过 `@46a71c` 无 AV 且 h3 返回**；AV **前移至 Capless h4**（非 arg-loop）。tip_c21k Cap`@0024e6`-class 本拍前已证伪（见 dig_tip_c21k）。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| h3_je | `a4461bae5d62` | AV／GS／AV |
| h3_jesk | `cfb0fae4f5d9` | AV／GS／AV |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. Capless SoftCap lit 过 h3 后 AV 于 h4 `@493d31`（或 calt_exit）。
2. 无 Isol-native SoftCap lit call-mk／`0x868`。
3. Ban 移植／arg-loop／twin／字母堆。

### 5) 下一拍最小刀
1. Capless h4 SoftCap lit 无 AV（单点 DIG AV root＠h4；禁 arg-loop／移植）→ 续 Capless emit／call-mk。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_h3_jesk.md`；cave h3_je／h3_jesk；logs h3_je.log／h3_jesk.log／h3_eq_path.log
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**



**2026-10-30 ~14:45 CST (Asia/Shanghai)** · Isol Cap`@0024e6`-class tip_c21k／tip_c21b **证伪** （Cap21 入 body→CG002；c0=r8→TIMEOUT）· Capless h3 SoftCap lit 下一拍 · SoftCap **未绿** → 勿升 PROD／钉 ecdb5cc1e **不升**／勿收刀 · 下一拍：h3 SoftCap lit 过 `@46a71c` 无 AV（禁移植／arg-loop／twin／字母堆）


## 2026-10-30 ~14:45 CST Asia/Shanghai — DIG Isol Cap@0024e6-class tip_c21k／tip_c21b；证伪（CG002／TIMEOUT）

### 0) 闸
- tip HEAD `cc89f7de1`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit `dbaab1c7ce70`；TT lit `5b173cef1205`
- Plants：tip_c21k `81295b0d64f9`；tip_c21r `9dda65be01c5`；tip_c21b `7c8ca171e2bc`；tip_c21z（eax=0）（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop 强跳／twin retarget：遵守

### 1) DIG 钉死（本拍）
1. LIVE Cap`@0024e6` SoftCap：kind`0x30`→Cap21c8 `@0021c8`；args `rcx=node`／`edx=idx`／`r8`／`r9=buf`（4 参；prologue 存 `f8=r9`）。
2. Isol 死 Cap21-ABI `@28f496`：prologue **3 参**（`e0=rcx`／`e8=edx`／`f0=r8`；**无** r9）；gate `kind==3` `@28f6c5`／size `@20203f` 1..255；`[rbp+0xc0]`←`@24af8b` alloc；成功路径可 `eax=1`。**无 callers**（除本拍 tip 强接）。
3. **tip_c21k**：tip SoftCap kind`0x30` Cap21 ABI→`@28f496`＋`@28f6cc je→jmp`（force kind）＋`@28f70d→@28f712`（force size）。SoftCap lit **入 Cap21 body**（INT3：kind_ok／sz_ok／`@201f36`／`@24b171`／`@23030e`／`@204732`／path_alt／tip_after）。Compile **CG002** asm_codegen（code_len=123）；**非** LIVE；无 `0x868`。
4. **tip_c21r**（tip_after force `eax=1`）仍 CG002 ⇒ Cap21 未写出 SoftCap 帧；假成功只跳 Capless miss，emit 仍坏。
5. **tip_c21z**（force `eax=0` miss→Capless）仍 crc=0x1（不同 CG／patch note）。
6. **tip_c21b**：`@28f661` 后强制 `c0=r8`（`@24af8b` 常 null）→ SoftCap lit／fwd／local **TIMEOUT**（arg-loop 形；**禁**）。INT3：set_c0 命中；其后 mid-path TIMEOUT。
7. ⇒ Isol `@28f496` Cap`@0024e6`-class **入门可证**、**SoftCap lit emit 不可用**（死 ABI／缺 r9／alloc null／无 LIVE emit_1d8cf4 链）。禁继续 c0／arg-loop 强跳。
8. Prior：site_claim（OK≠LIVE／run AV）／site_callmk／site_emok／site_abi_r8／calt_h3miss 证伪。Capless h3 SoftCap lit 仍至 `@46a71c`；不等路径 `@46a71e..@46a741 call @1fb0ec` AV 窗。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| tip_c21k | `81295b0d64f9` | CG002／CG002／crc=0x1 |
| tip_c21r | `9dda65be01c5` | CG002／CG002／crc=0x1 |
| tip_c21b | `7c8ca171e2bc` | TIMEOUT／TIMEOUT／TIMEOUT |
| tip_c21z | — | crc=0x1（miss Capless） |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. Isol Cap21 `@28f496` ≠ LIVE Cap21c8 SoftCap emit（3 参／死／alloc null→path_alt）。
2. Capless h3 SoftCap lit AV 窗 `@46a71c` 不等→`@1fb0ec`；force h3-miss→arg_loop（禁）。
3. Ban 移植／arg-loop／twin／字母堆。

### 5) 下一拍最小刀
1. Capless h3 SoftCap lit：过 `@46a71c` **无 AV**（Isol-native 单点 equal／skip-AV；禁 arg-loop／移植）达 call-mk／`0x868`。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_tip_c21k.md`；cave tip_c21k／tip_c21r／tip_c21b／tip_c21z；logs tip_c21k.log／c21_ret.log／c21_24af.log
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**



**2026-10-30 ~14:20 CST (Asia/Shanghai)** · Isol SoftCap lit call-mk／Cap`@0024e6`-class **未绿** · site_emit_pass `a102ef425fc1` 证伪（sz_bad→crc=0x1）· calt_h3miss `415edc74fca0` 证伪（TIMEOUT arg_loop）· tip_scfull／sc50f 证伪（crc=0x1／TT thin）· Isol **0** Cap`@0024e6` prologue；12×`sub rsp,0x180` none kind0x30 · tip kind0x30→Capless only · SoftCap **未绿** → 勿升 PROD／钉 ecdb5cc1e **不升**／勿收刀 · 下一拍：h3 SoftCap lit 无 AV call-mk 或 Isol 自建 Cap`@0024e6` 类（禁移植／arg-loop／twin／字母堆）


## 2026-10-30 ~14:20 CST Asia/Shanghai — DIG SoftCap lit call-mk／Cap@0024e6-class；证伪

### 0) 闸
- tip HEAD `c708f0bbf`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit `dbaab1c7ce70`；TT lit `5b173cef1205`
- Plants：site_emit_pass `a102ef425fc1`；calt_h3miss `415edc74fca0`；tip_scfull `ca90e6fd3276`；tip_sc50f `038f55a434ca`（语义短名）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／字母堆／LIVE SoftCap 移植／arg-loop 强跳／twin retarget：遵守

### 1) DIG 钉死（本拍）
1. site_emit_pass force SoftCap-site kind-gates → SoftCap lit 入 body 至 `@2be7bb sz_bad`（size∉1..255）→`eax=-1`；emit `@2bd6ed`／`@524944` **未达**。SoftCap-site ≠ SoftCap CallExpr lit emitter。
2. Capless SoftCap-site LIVE-shaped miss（c36）→h2→h3；h3 SoftCap lit 至 `@46a71c`；calt_h3miss force h3-miss → Capless 续 h4/h5 后 **arg_loop TIMEOUT**（禁强跳）。
3. Isol Cap`@0024e6` 类：**0** `push;sub rsp,0x180;lea rbp` 匹配；12×`sub rsp,0x180` 无 kind`0x30`。tip SoftCap kind`0x30`→Capless only（≠ LIVE Cap→Cap21c8）。
4. tip→SoftCap-full `@121278` stub→crc=0x1；`@50f8a0`→TT thin。非 Cap`@0024e6` SoftCap dispatch。
5. Prior：site_abi_r8／c36／calt_args／calt_miss／full_chain 证伪。

### 2) Win SoftCap 门
| Isol | sha12 | lit／fwd／local |
|---|---|---|
| site_emit_pass | `a102ef425fc1` | crc=0x1／crc=0x1／crc=0x1 |
| calt_h3miss | `415edc74fca0` | TIMEOUT／TIMEOUT／AV |
| tip_scfull | `ca90e6fd3276` | crc=0x1 |
| tip_sc50f | `038f55a434ca` | OK＝TT thin／OK／OK；**非** LIVE |

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap p_ret_* | **未运行绿** |
| Darwin／Ubuntu | **未扩** |
| PROD／钉 | **未动** |

### 4) 硬 blocker
1. Isol 无 Cap`@0024e6` SoftCap lit 调度；SoftCap-site 拒 SoftCap lit（sz_bad）。
2. Capless miss→h3 AV／arg_loop hang；无 Isol-native SoftCap lit call-mk。
3. Ban 移植／arg-loop／twin／字母堆。

### 5) 下一拍最小刀
1. Capless h3 SoftCap lit 过 `@46a71c` **无 AV** 达 call-mk／`0x868`；或 Isol 自建 Cap`@0024e6` 类 SoftCap dispatch。
2. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- 笔记 `_dig/dig_site_emit_callmk.md`；cave plants site_emit_pass／calt_h3miss／tip_scfull／tip_sc50f
- PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e **未动**


## 2026-10-30 ~14:03 CST Asia/Shanghai — DIG Isol SoftCap-site site_abi_r8；证伪（TT thin）

### 0) 闸
- tip HEAD `a3e194958`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-site_abi_r8 sha12 **`de066e24b417`**（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆／LIVE SoftCap 移植／arg-loop 强跳／twin retarget：遵守

### 1) DIG 钉死（本拍）
1. SoftCap lit → Capless-alt `@57656c` → SoftCap-site `@2be519`（Cap21c8-pro ≅ LIVE `@0021c8`／`@28e9c0`）。
2. Isol SoftCap-site entry stores **swapped** vs LIVE＋Capless ABI：Isol `f0=r8(q)`／`f8=r9d(d)`；LIVE `f0=r8d(d)`／`f8=r9(q)`。Isol null 查 `f8` → SoftCap lit 命中 `@2be6b0 eax=1` early-claim → TT。
3. Plant `site_abi_r8`：stores LIVE-shaped＋null claim `eax=0`＋body slot retarget（保留 site state）。SoftCap lit **入 body**；命中 kind-gate `@2be734`（`kind∉{0x36,0x33,3}` → `eax=1`）→ Capless early → 仍 TT thin。
4. `site_abi_c36`（`@2be734→0`）→ Capless fallthrough → **AV**（无 emit）。`site_abi_unk3`／`kany` 过 c8 → `@2be781` nested kind≠3 `eax=1` → TT；`@2be781→0` → **AV**。
5. LIVE SoftCap lit SoftCap-site：validate **miss `eax=0`** → Capless continue；另走 Cap`@0024e6` kind`0x30`→`@0021c8`。
6. Isol SoftCap-site callers：唯 Capless `@576692`＋wrapper `@2be40f`。**无** Isol Cap`@0024e6`-like（cmp`0x40`＋kind`0x30`→SoftCap-site）调度。
7. Prior falsified: calt_args／calt_miss／calt_twin／full_chain／smega_le／callsz_le／scap0。

### 2) Win SoftCap 门（cave `out_abi`）
| Isol | sha12 | plant | lit／fwd／local |
|---|---|---|---|
| site_abi_r8 | `de066e24b417` | SoftCap-site ABI LIVE-shaped＋null `eax=0`＋state | OK＝TT thin／OK／OK；**非** LIVE；run rc=1 |
| site_abi_c36 | `29a8ae206733` | abi_r8＋`@2be734→0` | **AV**／—／—（无 emit） |
| site_abi_unk3／kany | `ce727252c3d6`／`bafead692405` | force kind3-like | TT／`@2be781→0` AV |

- ⇒ ABI 修 null-claim 不够；kind-gate false-claim 中和＝Capless AV；未达帧／call-mk／`0x868`。

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-site_abi_r8 `p_ret_*` | compile OK＝TT thin；**未运行绿** |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. Isol SoftCap-site kind-gates `@2be734`／`@2be781` `eax=1` false-claim SoftCap lit；中和→Capless continue **AV**。
2. Isol SoftCap-site body ≠ LIVE SoftCap-site（kind dispatch vs validate／miss-`eax=0`）。
3. Isol 缺 LIVE Cap`@0024e6` SoftCap lit 调度；单靠 Capless SoftCap-site miss 不够。
4. Ban LIVE SoftCap 移植／arg-loop／twin。

### 5) 下一拍最小刀（单点；禁字母堆／禁移植）
1. Isol-native SoftCap lit call-mk writer：LIVE 形 SoftCap-site miss 后 Capless continue **无 AV** 且写出 call-mk／`0x868`；或 Isol 自建 Cap`@0024e6` 类 SoftCap dispatch（Isol-native；禁 LIVE SoftCap 移植／arg-loop 强跳／twin retarget）。
2. 通后再验帧＋Darwin Cap soft＋Ubuntu tip-cold。未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-site_abi_r8 `de066e24b417`＋`_dig/build_isol_site_abi_r8.py`；笔记 `dig_site_abi_r8.md`
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged


## 2026-10-30 ~13:45 CST Asia/Shanghai — DIG Capless-alt SoftCap-site；calt_args／calt_miss 证伪（AV）

### 0) 闸
- tip HEAD `65710507d`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-calt_args sha12 **`c65741a41b67`**；Isol-calt_miss sha12 **`6927bb640c22`**（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆／LIVE SoftCap 移植：遵守

### 1) DIG 钉死（本拍）
1. SoftCap CallExpr **是** Capless-alt `@57656c`（kind 0x30）。Capless-alt callers INT3：唯 **`cc_12377c` TIMEOUT**；其余 8× OK（非 SoftCap lit 路径）。
2. Capless-alt `@576692`→SoftCap-site `@2be519`（＝LIVE `@28e9c0` 0x150）。Isol SoftCap-site 4× `mov eax,1; jmp exit` early-claim；LIVE 同位 `mov eax,0`（不 claim）。Capless-alt `@5766b9`：site>0 → `mov eax,0; jmp EXIT` — **无** lit call-mk。
3. SoftCap-full／twin／SoftMega INT3 → SoftCap lit 仍 TT（off-path）。tip SoftCap `@121278`（`sub rsp,0x868`）未接 Capless 用户 emit。
4. `calt_twin`（`@12377c`→SoftCap twin `@57ef78` `da6a097340ff`）→ **CG002**（Isol twin＝SoftMega stub ≠ LIVE SoftCap）。
5. Prior falsified: full_chain／smega_le／callsz_le／scap0／AAA／DDD／YY155／YY164。

### 2) Win SoftCap 门（cave `out_calt_args`／`out_calt_miss`）
| Isol | sha12 | plant | lit／fwd／local |
|---|---|---|---|
| calt_args | `c65741a41b67` | `@5766b9` early→jmp arg-loop `@5770da` | **AV**／**AV**／**AV**（无 emit） |
| calt_miss | `6927bb640c22` | Capless-alt 20× early-success→fallthrough | **AV**／`0xC0000409`／**AV**（无 emit） |

- ⇒ 强跳 SoftCap-site early-claim 进 arg-loop／miss fallthrough **主机 AV**；Capless emit_args ≠ SoftCap `0x868` writer；未达帧／call-mk。

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-calt_args／calt_miss `p_ret_*` | **主机 AV／stack overrun**；无 emit；未运行绿 |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin／Ubuntu | **未扩**（Win 未绿） |

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. SoftCap CallExpr：Capless-alt→SoftCap-site Isol `eax=1` early-claim → 无 imm→rdx＋call-mk；帧 thin≠`0x868`/`0x878`。
2. calt_args／calt_miss／calt_twin／full_chain／smega_le／callsz_le／scap0 **均**未 SoftCap 运行绿。
3. Isol SoftCap twin≠LIVE SoftCap `@289dcb`；LIVE SoftCap 整树／mega **禁**。

### 5) 下一拍最小刀（单点；禁字母堆／禁移植）
1. Isol SoftCap-site early-claim `mov eax,1`→LIVE 形 `mov eax,0`（保留 site body state）后验 Capless continue 是否非 AV 且写出 call-mk／`0x868`；或另寻 Isol-native SoftCap lit call-mk 真到达点（禁 arg-loop 强跳／禁 twin retarget／禁 LIVE SoftCap 移植）。
2. 通后再验帧＋Darwin Cap soft＋Ubuntu tip-cold。未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-calt_args `c65741a41b67`＋`_dig/build_isol_calt_args.py`；Isol-calt_miss `6927bb640c22`＋`_dig/build_isol_calt_miss.py`；笔记 `dig_calt_args_miss.md`（续 `dig_full_chain.md`）
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged


## 题面
Windows 单句函数体 `return` 不走 RETURN 节点（w1521 在 call_dispatch 补转交）；单句 return 走正常 RETURN 路径才 ✅。

## DIG 结论（本拍）

### 1. 单句为何「跳过」RETURN 发射路径
Parser（`parser.x` ~3024–3027）：`return …;` 后下一 token 是 `}` 时 **只** 写 `b.final_expr_ref = EXPR_RETURN`，**不** `append_stmt_order`。
中段 `return`（后面还有语句）才进 stmt_order kind=2。

因此单句 `{ return expr; }` 的 RETURN **只活在 final_expr**，不在 stmt_order。

### 2. 发射分叉（与双端差在哪）
| 路径 | 入口 | sret／转交 |
|------|------|------------|
| stmt_order RETURN | `pipeline_asm_emit_expr_*` → kind41 → `pipeline_asm_emit_return_elf_impl` | return_sret overlay（copy／fwd call） |
| final_expr | `glue_emit_block_final_expr_elf` → `emit_expr_elf_rec` | tip 源码里 kind41 **也会**调 emit_return；但 **egg mega／comment（w1521）** 记载 SoftCap mega 对 `{return f();}` **直接发 result expr**（剥掉 RETURN），return_sret **永不跑** |
| 补偿 | `w1521_win_fwd_ret_call`（`backend_call_dispatch.x` ~7477） | **仅 Windows**：call_dispatch 把本函数 sret dest 转交 callee（>16B） |

题面「不走 RETURN 节点」＝ SoftCap／mega 单句体 **不经** return_sret overlay；i32 单句「假绿」因标量自然落 eax／x0，缺 jmp-RETURN 仅痕迹。

对照反汇编（Win SoftCap PROD）：
- `ret_lit`：`mov $7,%eax` → epilogue → `ret`（**无** `jmp`）
- `ret_multi`：add 后 **`e9 00 00 00 00 jmp`** → epilogue（emit_return 标号路径痕迹）

### 3. 大结构体探针逼显（对照 I／w1521）
`tests/probes/p_big_struct/p_ret_{fwd,lit,local,anon}` 与 `compiler/p1060_probe/sret_*_min`：

| probe | expect | Win PROD SoftCap | Win I tipcold | Darwin tip | Ubuntu tip |
|-------|--------|------------------|---------------|------------|------------|
| ret_lit／ret_call／ret_call_only／ret_multi (i32) | 7 | **7** | — | — | — |
| sret_8／sret_ii／sret_16／sret_fwd／lit／local／chk | 字段对 | **CG002** code_len=0 | **CG002** | 编过但 **exit≠0** | 编过但 **exit≠0** |
| p_ret_fwd／lit／local／anon／p_ret32 | 0 | **CG002** | — | **exit=1** | **exit=1** |
| struct_local_only（仅本地 lit，不 return 结构体） | 10 | **CG002** | — | — | — |

**Darwin tip `p_ret_fwd` 反汇编（铁证）**：
- `main`：`mov x8, &w` 后 `bl fw`（调用方 sret 正确）
- `fw`：`bl mk` **前不设 x8**；算 `x+1` 后直接 call（**无** win_fwd／rs_fwd）
- `mk`：STRUCT_LIT 写入 **本地** `fp+0x18`，收尾 **无** 拷到 `*x8`；prologue **未** 保存入参 x8

**Ubuntu tip `p_ret_fwd_fw`**：把 `x+1` 放进 `%rdi` 再 `call mk`，**覆盖** 调用方传入的 sret 指针（同病）。

结论：双端 tip 大结构体 **语义已坏**（sret 未 park／未转交／未 copy）；Win SoftCap／I 连 named struct 都 **CG002**（探针 blocker，见下），尚未能在 SoftCap 上 runtime 验证 `w1521_win_fwd_ret_call`。但 SoftCap **已链上**该符号：
`backend_call_dispatch_w1521_win_fwd_ret_call` @ SoftCap；并有全套 `pipeline_w1521_rs_*`。同时残留 `glue_emit_block_final_expr_elf_SCAPDEAD`／`w1009_emit_let_SCAPDEAD` 等 SCAPDEAD。

### 4. SoftCap／I CG002（探针债，非本题根因但挡门）
任意 `struct` lit／return（含 8B、仅 local）→ `asm_codegen failed` `code_len=0`。i32 路径正常。疑 SoftCap PE 结构体布局／let-init 残桩（SCAPDEAD）或 frame 在 struct 上早退清空缓冲。I tipcold（7945801）同样 CG002 → **非** 10.58 回归独有。双端 tip 可编，作 DIG 主证据源。

## isol／cave 候选（最小；禁 mega／HARD BAN／LEGACY）

### isol-A（题面对齐 · 首选）
`glue_emit_block_final_expr_elf`（`runtime_pipeline_abi_block_final_expr_thin.x`）：
- `fref` kind==41 → **显式** `pipeline_asm_emit_return_elf_impl`（不依赖 rec／mega 是否剥 RETURN）
- 已有 `fref_ko==41` 时 `allow_tail_join=0`，与 emit_return 自带 jmp tail_join 不双跳

**cave**：改的是 SHARED thin — 必须双端门 i32 ret_* + p_ret_*；禁牵坏 10.54／10.58（stack arg／shadow）。

### isol-B（Win 旁路加固 · 非 ✅ 定义）
保持／收紧 `w1521_win_fwd_ret_call` + 确认 SoftCap mega 单句仍走 call_dispatch。题面写明 ✅＝走正常 RETURN，**B  alone 不够收刀**。

### isol-C（sret frame park · 双端已显）
prologue 对 >16B 返回 park x8／rcx→home；emit_return／lit 路径 `rs_copy_to_dest`。Darwin／Ubuntu tip 无 park 是 p_ret_* exit=1 的直接因。可与 A 同拍或紧随，仍须隔离、双端门。

### 不做
- 升钉／CloudAgent／10.74／mega 大改／假绿 push
- 顺手扩 arg_idx>5（10.58 债，非本刀门禁）

## 产物
- `_dig/dig_1060_PROGRESS.md`（本文件）
- `_dig/p1060_OPEN.md`（首拍基线）
- 探针：`compiler/p1060_probe/{ret_*,sret_*}` · `C:/xlang_tmp/p1060/`（Win 镜像 + logs）
- 既有：`tests/probes/p_big_struct/p_ret_*.x`

## 下一步
1. **isol-A 落点**：改 `block_final_expr_thin` kind41→emit_return；本地／双端 tip 跑 `p_ret_{lit,fwd,local}` + i32 ret_*（期望 Darwin／Ubuntu p_ret_* →0；i32 仍7）。
2. 若 tip 仍缺 park：最小 **isol-C**（frame sret home）再门一次。
3. SoftCap CG002 named-struct：另记债或本刀末拍轻挖（SCAPDEAD／struct let）；**未绿勿 push**；PROD 仍 `7a2cf5da581a`。
4. Win SoftCap 绿后：反汇编确认单句 sret 有 RETURN／rs_copy 或合法 fwd；再谈 WORK→PROD。

## 禁令复核
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿／未绿 push ✕

---

## 本拍结论（2026-10-29 ≈16:50 CST Asia/Shanghai）

**tip** `a8bea2bd0` · **PROD SoftCap** `7a2cf5da581a` · 钉盘 ecdb5cc1e **不升** · **未 push**

### 1. DIG：谁把 SoftCap named-struct 打成 CG002

| 二进制 | sha12 | `struct_8`（仅 local lit） | `p_ret_local` | 备注 |
|--------|-------|---------------------------|---------------|------|
| SoftCap PROD | `7a2cf5da581a` | **CG002 code_len=0** | **CG002 code_len=0** | i32 ret_*＝7 |
| I tipcold | `48139a4fa0b8` | **CG002 code_len=0** | （同） | 非 10.58 独有 |
| LIVE | `cbc0d8e8d96f` | **r=10** ✅ | 编过（r≠0 语义另议） | 无 SCAPDEAD |
| Darwin tip | `a8bea2bd0` | — | **r=0** ✅ | isolc2 曾 CG002 **code_len=168**（已清） |
| Ubuntu tip | relink `ea9ddf4e…` | — | **r=0** ✅ | FA Path D defer＋call_dispatch |

**根因（对照 I／LIVE／tip）**：
- SoftCap／I 对 **任意 named-struct 本地使用**（含 8B、仅 `let q: Q = Q{…}`、不 return 结构体）在 asm 阶段 **空缓冲** → CG002 `code_len=0`。
- SoftCap 独有／残留 **`w1009_emit_let_SCAPDEAD`**、**`backend_ensure_block_local_slots_SCAPDEAD`**、`glue_emit_block_final_expr_elf_SCAPDEAD`；LIVE **无** 这些 SCAPDEAD。
- `struct` **仅声明**／形参类型不实例化 → SoftCap **c=0**；失败点＝ **let＋STRUCT_LIT／local slot** 路径撞 SCAPDEAD／空 emit，**非** 10.60 return_sret／fwd 本身。
- 题面所说 **code_len=168**＝ Darwin tip isolc2 中段（isol-A 后、Path D 未齐）的 **tip** CG002；**现 tip 已绿**。SoftCap 实况是 **code_len=0**（与 15:40 表一致）。

### 2. 最小 isol／硬 blocker

- tip：**isol-A＋isol-C 已落**（block_final kind41→emit_return；FA thin CALL/METHOD sret→prev Path D；SysV sret f32_xmm park）。**禁 mega／HARD BAN／升钉** — 本拍 **不再** 对 SoftCap 做 tip 源码 isol（清不了 PE SCAPDEAD）。
- SoftCap CG002：**硬 blocker**＝需 SoftCap PE cave（自 LIVE 恢复 `emit_let`／`ensure_block_local_slots`）或另开 SoftCap 结构体债刀；**本刀 tip 双端门已可独立验收**，Win SoftCap sret 运行时验证 **挡在 struct let**。

### 3. 双端 tip 闸（本拍实测）

| probe | expect | Darwin tip | Ubuntu tip |
|-------|--------|------------|------------|
| `p_ret_lit` | 0 | **0** | **0** |
| `p_ret_fwd` | 0 | **0** | **0** |
| `p_ret_local` | 0 | **0** | **0** |
| `ret_lit/call/call_only/multi` | 7 | **7** | **7** |
| `p_ret32` | 0 | **2**（字段 dig＝0；`sum(Q)` by-value 残） | **0** |

### 4. 可否升 WORK／push

- **双端 tip `p_ret_*`＋i32 已绿** → tip 侧可报绿侧验。
- SoftCap named-struct **未绿** → **未绿勿 push**；PROD 仍 `7a2cf5da581a`；钉不升。
- 残：Darwin `p_ret32` r=2（by-value `sum`）；SoftCap struct SCAPDEAD 债。

### 禁令
CloudAgent ✕ · 升钉 ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕

---

## 本拍增量（2026-10-29 ≈17:30 CST Asia/Shanghai）— SoftCap CG002 DIG 纠偏

**PROD** `7a2cf5da581a` 未动 · **LIVE** `cbc0d8e8d96f` · tip `a8bea2bd0` 未动 · 钉不升 · **未 push** · 无绿 cave 可请批

### A. INT3 路径（Mac 跳板 → windows-server；ASLR 用 CREATE_PROCESS base）

`struct_8` SoftCap ORDER（mega 内）:
```
wpo_prep → wpo_count → modlet_prepare (eax=0) → loop_cond k=0 emit_n=0 → ret0 → fill_cg002
```
**不进** `loop_body` / `wpo_pgo_at` / `sync_elf` / `block_inits` / fat `struct_let_init`。

`i32_let` 同机:
```
… → loop_cond k=0 emit_n=1 → loop_body → wpo_at → sync_elf → ret0  (codegen OK)
```

### B. 硬根因（具体 RVA／符号）— **不是** SCAPDEAD emit_let 写点

| 位点 | SoftCap VA / RVA | 观测 |
|------|------------------|------|
| `pipeline_module_num_funcs` | `0x14023030e` / **`0x23030e`** | **`struct_8` → 返回 0**；`i32_let`/`only_decl` → 1 |
| `pipeline_asm_wpo_pgo_emit_order_prepare`（fat，mega 所调） | `0x14015c900` / `0x15c900` | 按 nf 填 order；nf=0 → 空 |
| `pipeline_asm_wpo_pgo_emit_order_count` | `0x14015ca50` / `0x15ca50` | **`emit_n=0`**（struct_8） |
| `mega_body` loop_cond | `mega+0xed5` / `0x20f8e1` | k=0, emit_n=0 → 直接 `mov eax,0; ret` |
| `rt_ab_fill_code_cg002` | `0x1402e5128` / `0x2e5128` | code_len=0 |

**LIVE** 同源 `struct_8`：`num_funcs=1` → emit_n≥1 → 绿（r=10）。

推论：CG002 发生在 **emit 之前**——SoftCap 模块在 named-struct **STRUCT_LIT 本地 let** 后 **`num_funcs` 字段为 0**（`main` 未登记或被清）。`only_decl`（仅 type、无 lit）与 `struct_param_only` SoftCap **OK** → 触发条件＝**函数体内 STRUCT_LIT**，非「任意 named-struct 声明」。

SCAPDEAD `w1009_emit_let` / `backend_ensure_block_local_slots_SCAPDEAD`：**本路径零调用**（emit_n=0 根本进不了 block body）。先前「清 SCAPDEAD emit_let／local_slots」假设对本 CG002 **不成立**；清法须上移到 **parse／typeck／module 登记 `num_funcs`**（SoftCap vs LIVE 差），或等价 PE 把 STRUCT_LIT 模块的 `num_funcs`／emit_order 修到 ≥1。

### C. 已试 ISOL（均未绿 · 勿请批）

| cave sha12 | 手法 | struct_8 |
|------------|------|----------|
| `25706913e907` | mega `modlet!=0` 闸 `74→eb`（后证 modlet 已返回 0，无关） | 仍 CG002 |
| `96fda3d4b78f` | mega 内 fat `wpo_pgo_{prepare,count,at}` CALL → Cap 孪生 `0x2c5ffa/609c/60db` | 仍 CG002（Cap 路径 `after_nf` 仍 0） |

### D. SoftCap 探针表（本拍）

| probe | SoftCap PROD | 备注 |
|-------|--------------|------|
| `struct_8` | CG002 code_len=0 | nf=0 |
| `named_empty_let` | CG002 code_len=0 | 同 |
| `only_decl` | codegen OK | nf=1 |
| `struct_param_only` | codegen OK | |
| `i32_let` / `i64_let` | codegen OK | |

### E. 闸门／请批

- 回归 10.54／10.58：**未跑**（无绿 cave）。
- **不可请批**；无 WORK 晋升。
- **硬不可清 blocker（当前层）**：`pipeline_module_num_funcs@RVA 0x23030e` 对 STRUCT_LIT 模块返回 0 → `emit_order_count`/`mega+0xed5` 空转 → CG002。下一刀 DIG：LIVE vs SoftCap **谁在 STRUCT_LIT 路径漏写／清 `pipe_mod_off_num_funcs`**（parse/typeck/module_add_func），再最小 PE cave。

### 禁令
CloudAgent ✕ · 升钉 ✕ · mega ✕ · 未绿 push ✕ · box 直连 Win ✕（仅 Mac `b93fb82c-…` 跳板）

## 2026-10-29 ~18:20 CST — num_funcs 写点定性 + Isol-A..E + hard blocker

### 1) 谁漏写／清 `pipe_mod_off_num_funcs`（对照 LIVE）

**结论：不是**对 `pipe_mod_off_num_funcs` 的直接 store/clear。症状是 SoftCap 在 **函数体内 STRUCT_LIT** 路径 parse 不完整 → `main` 未有效登记 → `pipeline_module_num_funcs@RVA 0x23030e` **返回 0** → fat wpo emit_order 空 → mega `emit_n=0` → CG002。LIVE 同探针 `nf=1`。

| 探针 | SoftCap PROD `7a2cf5da581a` | LIVE `cbc0d8e8d96f` |
|------|------------------------------|---------------------|
| i32_let / only_decl / struct_param_only | OK（nf≥1） | OK |
| let＋STRUCT_LIT / lit7 / s8 / retP | **CG002**（nf=0） | lit7 typeck `expected Point`；letP/s8/retP **run OK** |

**相对 LIVE 的漏点（10.46 类比，符号＋RVA）：**

| # | 符号／位点 | SoftCap RVA | STRUCT_LIT vs i32_let | LIVE |
|---|------------|-------------|------------------------|------|
| A | `consume_into_c` stub 错误 JMP | stub `0x5c1d08` → 应进 cave `0x559400` | STRUCT 路径 named 类型消费失败 → 后续 nf=0；i32 不经此 | LIVE 消费完整 |
| B | `parser_primary_ident` cave 缺 LBRACE→finish_struct | cave `0x558e9f`（stub `0x5dd6dc`）；缺 →`finish_struct_lit_ptr@0x5d7869` | 仅 STRUCT_LIT body；i32_let 无 LBRACE 后缀 | tip/`primary_ident_x` LBRACE→finish |

Isol-A（仅 retarget consume）+ Isol-B（+LBRACE→finish）→ **past CG002**，证实上表即 num_funcs=0 根因写点（漏注册／漏 parse），非字段清零。

### 2) 最小 PE cave 试跑（Isol-A..E）

| Isol | sha12 | 内容 | 侧验 |
|------|-------|------|------|
| A | `28a236a829b1` | consume→`0x559400` | 部分 past CG002 |
| B | `760ad23b22f0` | A + LBRACE→`0x5d7869` | past CG002；typeck **`expected ?`** |
| C | `a96114213093` | B + init_named name_len 132→260 | 仍 `?` |
| D | `c03ca2483467` | C + 其余 132→260 | 仍 `?` |
| **E** | **`9324fa12f437`** | B + **一处 imm**：Cap `0x5c1dc8` `mov eax,0x11`→`0x08` | lit7=`expected Point`（对齐 LIVE）；letP/s8/retP **typeck 过、built**；**run `0xC0000096`** |
| E2 | `d38cb8213b17` | E + `0x5bdf35` `mov [rax],0x11`→`0x08` | 同 E：typeck 绿、run 仍特权指令 |

**`?` 根因（Isol-B→E 已钉）：** Cap ensure／clone 路径 `0x5c1d10` 在 `kind_ord==8`（NAMED，`init_named@0x2a40e1` 写入）时因与期望判别 **`0x11`(17)** 不等而 `type_alloc@0x2b4a9a` 克隆，经 `0x5bdee7` 写 **`kind=0x11`**（`mov dword [rax],0x11`）→ tip typeck `fmt` 只认 NAMED=**8** → `?`。`named_name_into@0x2a35c7`／`kind_ord@0x2a3d37` 本身对 tyref2(=8,Point) 正常；tyref3 kind=17 名仍为 Point。Isol-E 改 reuse 条件 17→8 后 lit7 与 LIVE 同文。

### 3) 硬 blocker（当前层，不可请批）

- CG002／num_funcs=0：**已用 Isol-B/E 越过**（根因表见上）。
- **现 blocker**：Isol-E（`9324fa12f437`）对 `d_letP`／`d_s8`／`d_retP_i` **typeck+link OK**，运行 **`STATUS_PRIVILEGED_INSTRUCTION (0xC0000096)`**；LIVE 同探针 exit 1/4/1。非 kind=17  alone（E2 仍崩）。下一刀：SoftCap STRUCT_LIT **codegen／调用约定**（Isol-B primary_ident／finish_struct 降级 vs LIVE），RVA 待 DIG；**勿**再空转 SSH await／重复 CopyToBox。
- PROD 钉 **`7a2cf5da581a`** 不升；未绿勿 push；禁 mega／CloudAgent。
- **不可请批**。

---

## 2026-10-29 ~18:40 CST Asia/Shanghai — STRUCT_LIT runtime DIG + Isol-G（s8 绿）

**PROD** `7a2cf5da581a` 未动 · tip `a8bea2bd0` 双端未毁 · 钉 ecdb5cc1e **不升** · **未 push** · **不可请批**（p_ret_* SoftCap 仍崩）

### 1) DIG：谁发特权指令／谁发 `add rax,8`（对照 LIVE）

| 层 | SoftCap（Isol-E/F） | LIVE `cbc0d8e8d96f` |
|----|---------------------|---------------------|
| FA@RVA `0x14a0` | Cap lea stubs → mid-insn（非 kind） | — |
| 修复 | Isol-F：5× E8 → 好 orphan（mov_rax_rbx／push／pop_rax／rbx） | — |
| STRUCT_LIT **store** field | `+0`／`+4` ✅ | `+0`／`+4` |
| field **load**（`p.y`） | **`add rax,8`** → s8 exit **4** | **`add rax,4`** → s8 exit **7** |

**imm=8 调用链（INT3）：**
```
emit_add_rax_imm32@0x5182ac ← dispatcher@0x524198(edx=8)
  ← 0x1f26b2 in 0x1f2341
  ← get_field_offset@0x26bd38 → 0x26b771 → 0x26adfc → 0x26a64c
```

**`0x26a64c` 对 Point.y（bc=1）实测：**
- `0x29e4a0` → **a8=8**（错误；ABI／slot 或预存 offset）
- `0x27488a` → **a4=4**（正确 layout）
- 偏好逻辑：`cmp [rbp+0xa8],0; je …` **先取 a8** → 发射 imm=8

非 emit_struct／memcpy／sret 本拍主崩点；特权指令 FA 已由 Isol-F 清。剩 field-load offset 偏好。

### 2) Isol cave（叠 Isol-E）

| Isol | sha12 | 内容 |
|------|-------|------|
| E | `9324fa12f437` | consume＋LBRACE＋kind imm 0x11→8 |
| F | `2ee9bf3d12bc` | E + 5 E8 retarget（清 FA） |
| **G** | **`7701dac5b813`** | F + **1B** `@RVA 0x26a956`：`74→EB`（跳过 a8，走 a4＝`27488a`） |

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_G.exe`

### 3) SoftCap 探针表（Isol-G）

| probe | expect | Isol-F | **Isol-G** |
|-------|--------|--------|------------|
| d_i32 | 7 | 7 | **7** |
| d_letP | 1 | 1 | **1** |
| **d_s8** | **7** | **4** | **7** ✅ |
| d_retP | 5 | 5 | **5** |
| d_retP_i | 1 | 1 | **1** |
| d_nested | 1 | 1 | **1** |
| d_only | 7 | 7 | **7** |
| d_lit7 | typeck Point | typeck | typeck（同 LIVE） |
| p_ret_lit／fwd／local（24B sret） | 0 | 编译器 AV | **仍 AV** `0xC0000005` |

### 4) 回归／tip

- **10.58**（XLANG_WPO_NO_FOLD=1）：reg4／stack5／stack6／stack5_sum = **7／7／7／7**
- **10.54 sample**：i32_sanity=7、i32_two=3、call0=7、local=1
- **tip Darwin** `a8bea2bd0`：`p_ret_{lit,fwd,local}=0`、`ret_lit=7`（本拍未改 tip）

### 5) 下一硬 blocker（不可请批）

**SoftCap `p_ret_*`（>16B sret）编译期 AV**：
- EX `0xC0000005` **RIP=`0x10000`**（非镜像执行）；`rax=-1`
- 栈回边 RVA **`0x21b984`**（`call 0x21b5fa` 后；`21b5fa`＝按 idx×8 读 8B 拼 u64）← **`0x2a47ca`**（`call 0x21b94b` edx=2）
- LIVE 同探针 **c=0 r=0**
- letP／s8／retP（8B Point）已运行时合理；**整刀 SoftCap 运行时绿仍缺 p_ret_*** → **不可请批**／不升 WORK／不 push

### 禁令
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕


---

## 2026-10-29 ~19:40 CST Asia/Shanghai — SoftCap `p_ret_*` DIG + Isol-H／I 侧验（仍 AV）

**PROD** `7a2cf5da581a` 未动 · tip `a8bea2bd0` 未毁 · 钉 ecdb5cc1e **不升** · **未 push** · **不可请批**

### 1) DIG：谁把 CF 送到 RIP=`0x10000`／rax=-1（对照 LIVE）

**现象（Isol-G 编译 `p_ret_lit`）：**
- EX `0xC0000005`，**RIP=`0x10000`**（非镜像），`rax=-1`，`rbp=0x100000000`
- 栈回边常见：`0x21b984`（`call 0x21b5fa` 后）← `0x2a47ca`（slot2 getter 路径）
- LIVE 同探针：`c=0 r=0`（`lab_LIVE_pret.exe` `cbc0d8e8d96f`）；PROD SoftCap 同探针＝CG002（未走到本 AV）

**机制（已钉，非根因 RVA）：**
- Cap base-256 decode `@0x21b5fa` 在帧内写 powers：`[rbp-0x10]=0x100`，`[rbp-0x18]=0x10000`，`[rbp-0x20]=0x100000000`，`[rbp-0x28]=acc`
- AV 时 **rsp = 某次 decode 的 `rbp−0x20`**：随后等价 `pop`／`ret` 吃掉 power 槽 → RIP=`0x10000`、RBP=`0x100000000`
- 崩溃帧常为**更早、已遗弃的 decode 帧**（非最新 epi；data-watch touch=0）；确定性约 ~11812 decode epi 后崩
- crash 栈上 acc 常见 `0x4c8`；**n_neg@`21b758`=0** → crash 时 `rax=-1` **不是** decode 返回 −1
- LIVE Cap decode `@0x93b0c` 同 power／epi 布局；LIVE 不走此坏 pop

**已排除：**
| 假说 | 证据 |
|------|------|
| Cap 被当 call 目标 | 否；call 目标仍是 `21b5fa`／wrapper |
| `21b5fa` 自身 epi 少 `add rsp` | **Isol-I** `lea rsp,[rbp]` 替换 `add rsp,0x30` → **仍 AV** |
| 仅最新 decode 帧被 pop | watch 最新 `0x10000` 槽 touch=0；崩用旧帧 |
| 全 `.text` 立即 `5D C3` 为坏 pop | INT3 4570 点／167k hit **bad=0**，经典 AV 仍在 |
| 窄域 all-pop INT3 | 改变崩点（如 mid-insn `@0x21b669`／`@0x215c3f`），未抓住 power-on-[rsp] |

**未钉（硬 blocker 根因 RVA 仍开）：** 谁在 decode 返回之后，以 `rsp=decode_rbp−0x20` 执行 pop／等价物（可能非立即 `5DC3`；可疑大 caller／sret+arg SoftCap 独有路径：`0x1212aa` 等 framebal MISMATCH 待审）。culprit 日志见 `cave/culprit_log.txt`（decode 内 power 读写 + wrapper 入口，**无**最终坏 pop 位点）。

### 2) Isol-H／I 侧验表（叠 Isol-G；**均未清 AV**）

| Isol | sha12 | 内容 | `p_ret_lit` 编译 | AV 形态 |
|------|-------|------|------------------|---------|
| **G** | `7701dac5b813` | E+F+`0x26a956` 74→EB | **AV** rc=`0xC0000005` | RIP=`0x10000` rax=-1 rbp=`0x100000000` |
| **H** | `0b3dc027b3e5` | G + epi cave：**zero** `[rbp-0x10/-18/-20]` 后再 leave | **AV** rc=`0xC0000005` | RIP=`0` rax=-1 rbp=`0`（证明被 pop 的就是 power 槽） |
| **I** | `fdd747bacb16` | G + `@0x21b75c` `add rsp,0x30`→`lea rsp,[rbp]` | **AV** rc=`0xC0000005` | 仍崩（**证 21b5fa epi 不是坏 popper**） |

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_{G,H,I_leasp}.exe`  
GvsH ndiff=42；GvsI ndiff=3。无新绿 production cave。

**对照探针（既有）：** `m_ret_call`（无 arg／非本路径）Isol-G／H／I 可过；`t1_arg_nofield`／`p_ret_{lit,fwd,local}` SoftCap 编译期 AV。LIVE `p_ret_lit` 绿。

### 3) 回归（Isol-G 基线，本拍未毁）

| 项 | 状态 |
|----|------|
| letP／s8／retP／retP_i／i32／only／lit7 | 1／7／5／1／7／7／typeck＝LIVE |
| 10.58 stack／reg4 | 7 |
| 10.54 sample | 过 |
| tip Darwin `p_ret_*`／ret_lit | 0／7 |

### 4) 硬 blocker（不可请批）

- SoftCap `p_ret_{lit,fwd,local}`（24B sret）**编译期 AV**；Isol-H／I **未清**
- RIP／RVA：`0xC0000005` @ **RIP=`0x10000`**（H 验证为 pop 自 Cap power 槽）；链 `0x21b984`←`0x2a47ca`；**坏 pop 指令 RVA 未钉**
- LIVE：同探针 r=0；PROD：CG002
- **不可请批**／不升钉／不 push／无 CloudAgent／无 mega

### 禁令
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕


---

## 2026-10-29 ~20:05 CST Asia/Shanghai — 坏 pop RVA 已钉；`0x1212aa` 证伪；cave M–R 未绿

**PROD** `7a2cf5da581a` 未动 · tip `a8bea2bd0` 未毁 · 钉 ecdb5cc1e **不升** · **未 push** · **不可请批**

### 1) 坏 pop RVA（已钉，对照 LIVE Isol-G）

| 项 | 值 |
|----|-----|
| **pop RVA** | **`0x58e99c`**（`pop rbp`） |
| 完整 epi | `@0x58e997` `lea rsp,[rbp-8]` → `pop rbx` → **`pop rbp`** → `ret` |
| 所属函数 | SoftCap／WPO mega-fn **`@0x57effc`** … epi `@0x58e99d`；frame probe `mov eax,0x94e8`；串 `XLANG_WPO_MONO`／`XLANG_WPO_NO_FOLD`；唯一 E8 调用点 `0x59ab11` |
| 证据 | `dig_allpop.py`：全 `.text` Capstone `pop rbp`×7459 INT3；STRICT `[rsp]∈{0x10000,0x100000000}` **hits=1** 仅 `@0x58e99c`；随即 AV `rip=0x10000 rbp=0x100000000 rax=-1`；`[rsp]=0x100000000` `[rsp+8]=0x10000` |
| 机制对齐 | 执行时 **rbp＝旧 Cap decode_rbp−0x20** → `lea rsp,[rbp-8]` 后 pop 链吃掉 powers → RIP=`0x10000` |

**非** `0x21b5fa` epi；**非** 立即全 `.text` `5DC3`（先前 plant 带未盖本址：`0x58e99c` 在 `0x2c0000` 外）。

### 2) `0x1212aa` framebal — **证伪（不是坏 pop）**

- `@0x1212aa`＝`call 0x21b5fa`（Cap decode 调用点），fn `@0x121278` `sub rsp,0x868`
- 自身 epi `@0x1212b4`：`lea rsp,[rbp-8]; pop rbx; pop rbp; ret` — **allpop STRICT 未命中**
- 结论：framebal MISMATCH 可疑点可另审，但 **执行 power→RIP=0x10000 的 pop 已钉为 `0x58e99c`**，不是 `0x1212aa`

### 3) 最小 cave 试刀（叠 Isol-G；**均未清 p_ret AV**）

| Isol | sha12 | 内容 | `p_ret_*` |
|------|-------|------|-----------|
| J／K／L | （既有） | mid-decode／zero powers／plant | 仍 AV |
| M | `52fe87b3edfa` | Cap epi 克隆 saved rbp／ret→power 槽 | `0xC0000409`／AV（cave 曾出 VS） |
| N | `3bea82d8f0d0` | 坏 epi 守卫；in-place 修 `[rbp]/[+8]` | recover 命中后 rsp 低 0x20 → AV |
| O／P | `977b3dcc`／`acf1528f` | jmp Cap wrapper `0x21b984`；rsp ±8 | P 偏 8；O 后链路 AV |
| **Q** | `1059d35a5af4` | recover：`lea rsp,[rbp+0x30]`→`jmp 0x21b984`（rsp=wrapper_rbp−0x30 **对齐**） | wrapper→`2a47cf`→`2a4f36`→… 后 **AV rip=0**（−1 重入 slot2 路径炸） |
| R | `f2001fceee73` | 试图从 SoftCap 直接 ret 给 caller | 仍 AV（rbp 链到不了 SoftCap 帧） |

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_{M,N,O,P,Q,R}.exe` + `dig_allpop.py`／`allpop_log.txt`

**Q 证明：** 坏 pop 可拦截并安全回到 Cap wrapper；**不能**把 `rax=-1` 当 Cap 结果重喂 slot2／SoftCap——需另策（修 SoftCap 写坏 rbp 的根因，或 recover 后接 SoftCap 真帧）。

### 4) 探针表（本拍）

| 探针 | Isol-G | Isol-Q／R |
|------|--------|-----------|
| `p_ret_{lit,fwd,local}` | AV `0xC0000005` rip=`0x10000` | 仍 AV（Q 改形态 rip=0） |
| `m_ret_call` | 绿（既有） | （路径未复跑／缺文件时 skip） |

### 5) 回归／tip

本拍 **未重跑** letP／s8／retP／10.54／10.58（cave 未绿；Isol-G 基线仍为准）。tip `a8bea2bd0` 未改。

### 6) 硬 blocker（不可请批）

- **坏 pop RVA 已钉：`0x58e99c`**（mega-fn `@0x57effc`／WPO SoftCap 路径 epi）
- SoftCap `p_ret_{lit,fwd,local}` **仍编译期 AV**；cave M–R **无绿**
- 下一刀（停工后）：(a) 谁把 SoftCap **rbp 写成 decode_rbp−0x20**（根因）；或 (b) recover 后定位 SoftCap 真帧再 −1 返回 caller，勿重入 Cap wrapper
- LIVE 同探针绿；PROD CG002
- **不可请批**／不升钉／不 push／无 CloudAgent／无 mega／无 10.74

### 禁令
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕


---

## 2026-10-29 ~20:32 CST Asia/Shanghai — DIG 写坏 SoftCap rbp 根因；cave S–AA 未绿；硬 blocker

**PROD** `7a2cf5da581a` 未动 · tip `a8bea2bd0` 未毁 · 钉 ecdb5cc1e **不升** · **未 push** · **不可请批**

### 1) 写坏 SoftCap rbp —— 根因（对照 LIVE）

**结论：没有人在 SoftCap 中途「写坏」rbp。** SoftCap 共享 epi `@0x58e997`（坏 pop **`0x58e99c`**）被 **无 SoftCap prologue 的 mid-insn 外部 call** 直接进入；rbp 一直停在调用方 lea-rbp 帧，恰＝ Cap decode_rbp−0x20；Cap power 常量已落在 `[rbp]/[+8]/[+0x10]`，epi 当 saved rbx/rbp/ret 弹出 → RIP=`0x10000`。

| 项 | 值 |
|----|-----|
| **「写 rbp」符号** | **无**（非 store-to-rbp；是 **缺 prologue**） |
| 真 SoftCap 入口 | `0x59ab11` → `call 0x57effc`（mega 头，有 prologue） |
| 坏路径调用方 | fn **`@0x5752bc`**（`push rbp; sub rsp,0x9e0; lea rbp,[rsp+0x80]`；epi `@0x576555`；saved_rbp `@[rbp+0x960]`；retaddr `@[rbp+0x968]`→`0x57bb35`） |
| 坏 mid-call 位点（RVA→目标，目标多为 **mid-insn**） | `0x5760c2`→`0x5862f8`；`0x5760fb`→`0x5863c9`；`0x5759ba`→`0x5862f8`；`0x57598f`→`0x5863c9`；`0x5761d5`/`0x5756a9`/`0x575908`→`0x56fa68`；`0x575471`→`0x5895d5`；`0x574192`→`0x584152` |
| SoftCap 内 mid 落点 | `0x5862f8`／`0x5863c9`／`0x5895d5`／`0x584152` 等（共享 epi 出口，**无** push rbp） |
| LIVE 对照 | `lab_LIVE_pret.exe` sha `cbc0d8e8d96f`（5.1MB）**无** SoftCap mega；同探针 `p_ret_*` **绿**；PROD SoftCap 路径＝CG002，Isol 开 STRUCT 路径才撞 mid-entry |

**机制链：** Isol-E/F 打开 STRUCT_LIT 路径 → fn`@0x5752bc` 跑起来 → mid-call SoftCap 内块 → 共享 epi 见 Cap powers 当帧 → AV。PROD SoftCap 更早 CG002，碰不到这条。

### 2) 本拍 cave（叠 Isol-G；均未清 `p_ret_*` 运行绿）

| Isol | sha12 | 策略 | `p_ret_lit/fwd` | `p_ret_local` |
|------|-------|------|-----------------|---------------|
| U／U_acc | `40aeaa8f…` | SoftCap power→`ret` 0／acc；CONT@`5760c7` | AV（2nd mid `586501`） | AV |
| V | `1eda63e69592` | power→unwind fn`@5752bc` rax=−1 | **CG002** | AV |
| **V0** | **`361145c82f68`** | power→unwind fn rax=**0** | **编译绿**／**运行 AV**（codegen≠LIVE `dbaab1c7ce70`，差 171B） | 编译 AV |
| W_fb／all | — | nop／retarget mid-calls | 仍 AV（另 mid `56fa6b` 等） | AV |
| Z／Z2 | `5979bee3`／`5e4ce30a` | power→acc ret ＋ retarget mid→`xor eax;ret` | 仍 AV（Cap 路径 SoftCap epi 吃 powers→rip=`0x10000`；栈见 `0x21b984`） | AV |
| AA | `791db687d1b0` | power→unwind fn＋**acc** | CG002 | AV |

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_{U,V,V0,W*,Z,Z2,AA}.exe` + `build_isol_{u,v,v0,w,z,z2,aa}.py` + `dig_{u,v,w,z,z2av}.py`

**最佳半绿：Isol-V0** — lit／fwd **编译过**但运行 AV（假绿禁 push）。local 仍编译 AV。

### 3) 探针／回归

| 探针 | Isol-G | Isol-V0 | Isol-AA／Z2 |
|------|--------|---------|-------------|
| `p_ret_lit` | AV rip=`0x10000` | compile OK／run AV | CG002／AV |
| `p_ret_fwd` | AV | compile OK／run AV | CG002／AV |
| `p_ret_local` | AV | 编译 AV | AV |
| Isol-G 基线／10.54／10.58 | （既有绿基线未毁） | **未宣称绿**；本拍未重跑全回归（cave 未运行绿） | — |

### 4) 硬 blocker（**不可请批**）

1. **无「写 rbp」store RVA** — 根因是 **mid-entry SoftCap**（调用方 `@0x5752bc` 上列 call RVA；目标 mid-insn SoftCap 内块）。
2. SoftCap `p_ret_{lit,fwd,local}` **无运行绿**；V0 仅 lit／fwd 编译半绿＋运行红。
3. 下一刀（22:00 收口后／下拍）：(a) 修／禁 mid-insn 外呼 SoftCap（对齐 LIVE 无此路径）；或 (b) SoftCap **真帧** recover（勿重入 Cap wrapper；勿仅拦 pop；V0 类 unwind 需正确 emit 而非 rax=0 偷过）。
4. LIVE 同探针绿；PROD CG002；tip／钉／PROD **不动**。

### 禁令
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕ · **未绿勿请批**


---

## 2026-10-29 ~20:46 CST Asia/Shanghai — 禁 mid-insn 外呼 cave DD–JJ；未运行绿；**硬 blocker 收口**

**PROD** `7a2cf5da581a` 未动 · Isol-G `7701dac5b813` 基线仍在 · tip `a8bea2bd0` 未毁 · 钉 ecdb5cc1e **不升** · **未 push** · **不可请批**

### 0) 已钉（本拍勿再挖写-rbp store）

- 坏 pop `0x58e99c`；机制＝**无 prologue mid-insn call** 入 SoftCap mega `@0x57effc`；rbp＝decode_rbp−0x20
- 真入口 `0x59ab11`→`call 0x57effc`；坏调用方 **fn `@0x5752bc`**
- LIVE `lab_LIVE_pret.exe` **无** SoftCap mega；同 fn LIVE `@0x28764c` 的 mid 位点 **1:1 对齐** 到 **有 prologue** 的 helpers

### 1) LIVE↔Isol mid 映射（禁 mid-insn 的正确目标）

| Isol mid（无 prol） | LIVE helper（有 prol） | Isol call-site 例 |
|---------------------|------------------------|-------------------|
| `0x56fa68` | `0x281df8`（cmp ecx,0x10；27B 无外呼） | `0x5756a9`/`0x575908`/`0x5761d5` |
| `0x5862f8` | `0x298688` | `0x5759ba`/`0x5760c2` |
| `0x5863c9` | `0x298759` | `0x57598f`/`0x5760fb` |
| `0x56ede1` | `0x281171` | `0x575c9f`/`0x575d5c` |
| `0x56ee2c` | `0x2811bc` | `0x575d2c`/`0x575e18` |
| `0x56ff52` | `0x2822e2` | `0x575ba7`/`0x57638a` |
| `0x570069` | `0x2823f9` | `0x575f68`/`0x57650c` |
| `0x5895d5` | `0x29b965` | `0x575471` |

call-site 相对 fn 起点 **offset 与 LIVE 完全一致**（16 处）。Isol 把本应进独立 helper 的 E8 链进 SoftCap mega 中段。

### 2) 本拍 cave 运行表

| Isol | sha12 | 策略 | lit | fwd | local | 备注 |
|------|-------|------|-----|-----|-------|------|
| **DD** | `52419bda2a2c` | 16 mid→`xor eax;ret` + SoftCap epi + epi2@`57beb2` | **CG002** | CG002 | CG002 | 无 AV；stub 丢 helper 语义 |
| **EE** | `15f26abd0038` | 16 mid→Isol `0x5aaf18`（有 prol） | compile／**run AV** | 同 | 同 | 首次 **三件全编译**；emit≠LIVE |
| FF | `5d48231d1342` | 16 mid→SoftCap 入口 `0x57effc` | 编译 AV | AV | AV | 错 ABI 入 mega |
| GG | `a95272dc7e1e` | LIVE helpers 植入 `.text` 尾洞；内呼 `xor eax` | compile／run AV | 同 | 同 | emit sha＝EE |
| HH | `720b37a859d9` | 同 + 浅 callee 树 | 同 EE emit | 同 | 同 | cave 0x800 不够 |
| II | `43b4d99c0829` | 新节 `.cave` 16KB；96 LIVE fn 树 | 同 EE emit `0ddf9b1751b1` | `b7f17d0f89d2` | `83fb1ce8ab76` | 大量 xor fallback（含 IAT）→ 与 EE 同控流 |
| JJ | `6f122ff51e53` | `.cave` 64KB 更深树 | **编译 AV** | AV | AV | 半残树更差 |
| V0（对照） | `361145c82f68` | SoftCap power→unwind fn rax=0 | compile／run AV（sha `ebf309c574db`≠EE） | 同 | 编译 AV | 真帧 recover 半绿；emit 仍错 |

**LIVE 对照 emit（绿）：** `out_LIVE_pret.exe` sha **`dbaab1c7ce70`**；frames `sub rsp,0x868` / `0x878`。  
**EE/II 错 emit：** frames `0x68` / `0x1b8`（少 ~2KB SoftCap 结构帧）→ 运行 AV；171B 级 diff。

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_{DD,EE,FF,GG,HH,II,JJ}.exe` + `build_isol_{dd,ee,ff,gg,hh,ii,jj}.py` + `isol_*_log.txt`

### 3) 探针／回归

| 探针 | Isol-G `7701dac5b813` | Isol-EE／II | Isol-DD | Isol-V0 | LIVE pret |
|------|----------------------|-------------|---------|---------|-----------|
| `p_ret_lit` | 编译 AV（rip=`0x10000`） | compile／**run AV** sha `0ddf9b1751b1` | CG002 | compile／run AV | **绿** `dbaab1c7ce70` |
| `p_ret_fwd` | AV | compile／run AV `b7f17d0f89d2` | CG002 | compile／run AV | 绿 |
| `p_ret_local` | AV | compile／run AV `83fb1ce8ab76` | CG002 | 编译 AV | 绿 |
| Isol-G 基线 | **保持**（本拍未改 G） | — | — | — | — |
| 10.54／10.58 | **未重跑全量**（cave 未运行绿；禁假绿） | — | — | — | — |

### 4) 硬 blocker 收口（**不可请批** · 22:00 开停）

1. **禁 mid-insn 外呼**已验证可消 AV（DD/EE），但：
   - stub／错 helper → **CG002** 或 **错 emit**（帧 `0x68`≠LIVE `0x868`）→ **运行仍红**。
   - LIVE helper 整树移植（II/JJ）因 Isol 缺同构 callee／IAT 槽不同，xor-fallback 后控流塌回 EE 同 sha；加深树 → 再 AV。
2. SoftCap **真帧 recover**（V0）仅 lit／fwd **编译半绿**，运行 AV 且 local 编译 AV；**不算请批条件**。
3. SoftCap `p_ret_{lit,fwd,local}` **运行时未绿** → **不可请批**／不升钉／不 push。
4. **下一拍最小刀**（勿重挖写-rbp）：
   - (A) 把上表 8 个 LIVE helper 的 **Isol 原生克隆**（已 reloc 的 callee，如 `0x27e73b≈298688` 形）逐站点 retarget，禁止 LIVE 字节移植；或
   - (B) SoftCap 真帧 recover **且**保留 sizing/store 副作用（勿仅 rax=0 unwind）；或
   - (C) 从 Isol Cap decode 对齐 LIVE Cap `@0x1d80` 调用图，绕开 SoftCap mega。
5. tip／钉 ecdb5cc1e／PROD／CloudAgent／mega／10.74：**不动**。

### 禁令
CloudAgent ✕ · 升钉 ecdb5cc1e ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · 假绿 push ✕ · **未绿勿请批** · V0 编译半绿不算


---

## 2026-10-29 ~21:00 CST Asia/Shanghai — Isol 原生／reloc helper 试刀 KK–PP；**硬 blocker 收口停 cave**

**PROD** `7a2cf5da581a` 未动 · tip `1e480ff6a`（本拍 docs 前）· Isol-G `7701dac5b813` 基线未改 · 钉 ecdb5cc1e **不升** · SoftCap `p_ret_*` **运行时未绿** → **不可请批** · **停开新 cave**

### 0) 本拍 DIG 钉点（相对 20:46 收口续挖）

- SoftCap mega `@0x57effc`→epi `@0x58e99c`：**整段无嵌套 prologue**（仅入口 prol；下一 prol=`0x58e9a0`）。8 个 mid 目标全落 mega 体内。
- Isol Cap FN `@0x5752bc` ≡ LIVE `@0x28764c`（同 prol `sub rsp,0x9e0`／`lea rbp,[rsp+0x80]`）；Δ=`0x2edc70`。
- LIVE emit 绿帧：`sub rsp,0x868` @ emit+2712；`0x878` @+2816。EE／II／NN／PP 错帧：`0x68`／`0x1b8`（sha lit=`0ddf9b1751b1`）。
- Isol **无** LIVE `0x281df8`（cmp10）exact body；prefix 假阳性多（h965@`0x2859ae` 52B 同头但 callee 图不同 → 禁作 EXIST）。
- LIVE `0x281e48` 在 h965 sizing 链上；stub 后 emit 塌回 EE 同 sha。

### 1) cave 运行表（本拍）

| Isol | sha12 | 策略 | lit | fwd | local | 备注 |
|------|-------|------|-----|-----|-------|------|
| **KK** | `7428532169d0` | mid→指纹 Isol 克隆＋cave 手写 cmp10 leaf | **编译 AV** | AV | AV | 指纹 ABI 错 |
| **LL** | `b4bb373afaeb` | `.cave` reloc 15 LIVE helpers；EXIST=prefix | compile／**run AV** sha `2405c664581d` | run AV | run AV | 首次非-EE emit；帧仍≠`0x868`；h965 EXIST 假阳 |
| MM | — | force-plant 全树 | **abort** | — | — | 递归爆 LIVE 树（`no ret 0x109ba0`）；触禁 |
| **NN** | `dff799ef6aed` | force 8 roots；depth≤2；stub 深 callee | compile／run AV | 同 | 同 | emit **=EE** `0ddf9b1751b1`；`281e48` stub→sizing 丢 |
| OO | `8672793f675a` | depth≤6／sz≤800；106 plants | **编译 AV** | AV | AV | 深树＋残 stub 回 AV |
| **PP** | `e89db10ee6e1` | force roots+`281e48`；depth≤2 | compile／run AV | 同 | 同 | emit 再塌 **=EE**；`1098a0`／`108e97` 等仍 stub |

产物：`C:/xlang_tmp/p1060/cave/xlang_isol1060_{KK,LL,NN,OO,PP}.exe` + `build_isol_{kk,ll,nn,oo,pp}.py` + `isol_*_log.txt` + `dig_{native_map,clone_exact,find_isol_helpers,helper_calls,frame_and_cap,v0_and_sizing,callee_map,exact_isol_helpers,ll_emit,store688}.py`

### 2) (A)／(B) 结论

| 路径 | 结果 |
|------|------|
| **(A) Isol 原生 helper 克隆 retarget** | Isol **无** 8 helper 的 full-exact 体（cmp10=0 hit）。prefix／指纹 → 假阳或 ABI 错（KK AV）。 |
| **(A′) LIVE 语义 reloc＋Isol callee**（LL/NN/PP） | 等价触「禁 LIVE 字节树」边界：浅树→emit 错帧／塌 EE；深树→编译 AV。非可请批绿。 |
| **(B) 真帧 recover** | 本拍未新开 V0 变体；既有 V0 仍仅编译半绿＋运行 AV；且 **无** sizing/store 副作用保留方案落地。 |

### 3) 探针／回归

| 探针 | Isol-G | 本拍最佳（LL） | EE/NN/PP | LIVE pret |
|------|--------|----------------|----------|-----------|
| `p_ret_lit` | 编译 AV | compile／run AV `2405c664581d`；帧≠`0x868` | compile／run AV `0ddf9b1751b1` | **绿** `dbaab1c7ce70` |
| `p_ret_fwd` | AV | run AV | run AV `b7f17d0f89d2` | 绿 |
| `p_ret_local` | AV | run AV | run AV `83fb1ce8ab76` | 绿 |
| Isol-G／10.54／10.58 | 基线未改 | **未宣称绿**；禁假绿全回归 | — | — |

### 4) 硬 blocker 收口（**不可请批** · **停开新 cave**）

1. SoftCap `p_ret_{lit,fwd,local}` **运行时未绿**（本拍 KK–PP 全红／半红）。
2. **根因仍钉**：Cap FN `@0x5752bc` 16× E8 → SoftCap mega **mid-insn**（无 prol）；LIVE 同位点进独立 helpers → emit 帧 `0x868`。
3. **(A) 堵死本层**：Isol 无原生 full-exact helper 克隆；LIVE reloc 树越深越 AV，越浅越 EE 错帧 — **非**「再多一个 cave 号」可清。
4. **(B) 未清**：真帧＋保留 h965／store688 sizing 副作用仍缺可运行方案；V0 rax=0 unwind **不算**。
5. **不可请批**／不升钉 ecdb5cc1e／不升 PROD `7a2cf5da581a`／不 push SoftCap 二进制／不 CloudAgent／不 mega／不 10.74／不假绿。
6. **下一拍最小刀**（新会话；勿在本收口后再开 cave）：
   - 从 **Isol Cap tip／egg 未吞区** 找回与 LIVE Cap `@0x28764c` 同构的 **已 reloc callee 图**（非 SoftCap+Δ）；或
   - SoftCap mega **拆回** 8 helper 入口（在 mega 内插入 prol／跳板，禁 LIVE 整树）；或
   - Cap decode 对齐 LIVE `@0x1d80` 绕开 SoftCap mega（路径 C）。
7. tip isol-A/C 双端绿 **保持**；本拍仅 docs 收口。

### 禁令
CloudAgent ✕ · 升钉 ✕ · 10.74 ✕ · mega ✕ · HARD BAN／LEGACY ✕ · LIVE 字节树 ✕ · 假绿 ✕ · **未绿勿请批** · **停开新 cave**

---

## 2026-10-30 ~08:40 CST Asia/Shanghai — DIG Isol Cap tip/egg isomorphic + Path-C Cap decode@0x1d80

**PROD** `7a2cf5da581a` 未动 · Isol-G `7701dac5b813` 基线未改 · LIVE pret `cbc0d8e8d96f` · tip HEAD（本拍 docs 前）· 钉 ecdb5cc1e **不升** · SoftCap `p_ret_*` **仍未运行绿** → **不可请批** · **无新 cave**

### 0) 本拍范围
- 优先：(A) Isol Cap tip／egg 未吞区 vs LIVE Cap `@0x28764c` 同构 callee
- 或：(C) Path-C Cap decode 对齐 LIVE `@0x1d80` 绕 SoftCap mega
- 禁：CloudAgent／mega 主刀／LIVE 整树 plant／假绿／10.74／HARD BAN

### 1) Cap FN call-graph（钉死）
- Isol Cap FN `@0x5752bc` ≡ LIVE `@0x28764c`（prol 字节同构；`sub rsp,0x9e0`）
- 已知 16× E8 位点：**全部** `Isol_dst = LIVE_dst + Δ(0x2edc70)`（纯 delta，无 tip 重标定）
- 其中 **5** 落入 SoftCap mega mid（无 prol）；**11** 落入 pre-Cap 无 prol mid（同属被吞 helper 体，非独立入口）
- SoftCap mega `[0x57effc,0x58e9a0)` pushrbp≈**1**（仅入口）；Cap..Soft pushrbp≈7

### 2) (A) tip／egg 同构 callee 结果
| LIVE helper | tip 同构结论 |
|-------------|-------------|
| cmp10 `@0x281df8` | **无 exact**。近克隆 Isol `@0x2b49f3` masked 25/27，但 imm `0x10→0` 且 jcc `7e→75`——**语义非 drop-in** |
| store688 `@0x298688` | 无 ≥55% masked tip 命中；旧友 `0x27e73b` 仅 ~38%，callee 图异（禁当 EXIST） |
| store759／h1171／h11bc／h22e2／h23f9／h965 | **full exact＝0**；唯一指纹无稀疏 tip prol 命中；前缀命中＝假阳 |
| 8 helper full exact in Isol | **0／8**（重证 KK–PP 结论） |

**结论 (A) 本层仍堵：** tip／egg 未吞区 **没有** 可安全 retarget 的 8-helper 同构 callee 集；仅 cmp10 近克隆且语义错。

### 3) (C) Path-C Cap decode `@0x1d80`
| 项 | 值 |
|----|-----|
| LIVE `@0x1d80` | 真函数 prol；crude size≈205；sole caller `0x55c6`（fn `@0x53cb`）；**不**直接 call Cap FN |
| Isol strict body-match | **无**（plen≥24 hits＝0；abs／表常量不同） |
| Isol 结构近亲 | `@0x22ed10`／`@0x22f84a`／`@0x28de10`（loose `837d10007413…`）；ABI 偏 4-arg，**非** Cap decode drop-in |
| Isol 已有 `sub rsp,0x868` | tip 多处（含先验 `@0x121278`）；LIVE pret 仅 2 处——**帧模板在 tip，不在 SoftCap 错 emit** |
| Isol Cap FN callers | `0x576a98`（fn `@0x57656c`，≡LIVE `@0x2967b4` 头同构，`sub rsp,0x500`，**无** SoftCap 外呼）等；**非** LIVE+Δ 一一对应 |

**结论 (C) 本层：** LIVE Cap decode `@0x1d80` **无法**在 Isol 找到同构体可直接绕 mega；Path-C 需改盯「tip 已有 0x868 Cap decode 路径如何接到 SoftCap `p_ret_*` emit」而非植物 `@0x1d80`。

### 4) 硬 blocker（不可请批）
1. SoftCap `p_ret_{lit,fwd,local}` **运行时未绿**（本拍仅 DIG，无新 isol 二进制）。
2. tip／egg 同构 callee **未就绪**（exact 0／8；cmp10 近克隆语义错）。
3. Path-C `@0x1d80` 同构 **缺席**；绕 mega 需另挖 tip `0x868` decode→emit 接线（下拍）。
4. PROD SoftCap `7a2cf5da581a`／钉 ecdb5cc1e／Isol-G：**不动**。

### 5) 下一拍最小刀
1. **Path-C′**：从 Isol tip `sub rsp,0x868`（尤 `@0x121278`）与 Cap-less caller fn `@0x57656c` 追 `p_ret_*` emit 调用链，对齐 LIVE 绿 emit `dbaab1c7ce70` 帧，**绕开** Cap FN mid→SoftCap mega。
2. 或：cmp10 单点语义补丁（`@0x2b49f3` imm/jcc）仅作探针——**不算**请批绿，须另解 store* 七件。
3. 仍禁：LIVE 整树 plant／mega 主刀／CloudAgent／假绿／未绿请批。

### 禁令
CloudAgent ✕ · 升钉 ✕ · 10.74 ✕ · mega 主刀 ✕ · HARD BAN／LEGACY ✕ · LIVE 整树 ✕ · 假绿 ✕ · **未绿勿请批** · **无新 cave**

## 2026-10-30 ~08:41 CST Asia/Shanghai — Path-C′ DIG tip 0x868 / Capless wiring vs SoftCap mega

### 0) 闸
- Isol-G sha12 `7701dac5b813`（未动）／LIVE pret `cbc0d8e8d96f`
- PROD SoftCap `7a2cf5da581a` **勿动**／钉盘 ecdb5cc1e **不升**
- 无新 cave／无 isol 二进制／无假绿／禁 mega 主刀

### 1) tip `sub rsp,0x868` 对照
| 端 | count | 关键位点 |
|---|---|---|
| Isol tip | **29** | 含 `@0x121278`（prol `55 48 89 e5 53 48 81 ec 68 08 00 00`） |
| LIVE pret | **2** | `@0x140d00`／`@0x140d58`（同 prol；绿 emit 帧） |

**Isol `@0x121278` ≅ LIVE emit `@0x140d00`**（帧模板同构）。但 Isol tip 该 fn **仅自呼** `E8 @0x1215b9`；LIVE emit `@0x140d00` **0 外部 E8 caller**（入口由更大 dispatch／尾调用／非 E8 路径进入，待下拍）。

### 2) Capless 接线（Path-C′ 新硬点）
| | Isol Capless `@0x57656c` | LIVE Capless `@0x2967b4` |
|---|---|---|
| prol | 同构 `55 48 81 ec 00 05 00 00 …` | 同 |
| E8 callers | **0（孤儿）** | **6**（`@0x5067e` `@0x50880` `@0x50903` `@0x511a2` `@0x54700` `@0xe84a6`） |
| 同 prol 克隆 | Isol 另 5 处有 caller | LIVE 另 5 处 |

Isol CapFN `@0x5752bc` 仍有 7 caller（含 sig `89 4c 24 20 48 89 c1 e8` → CapFN @`0x576a91`／`5775a0`／`577b71`，落在 Capless 邻区）。**结论：Isol SoftCap 路径只走 CapFN→mega mid，Capless 未挂上。**

### 3) Path-C `@0x1d80` 假友
- Isol tip 首呼 `@0x21b5fa`（自 `@0x1212aa`）与 LIVE `@0x1d80` **仅前 16B 同**（prol+arg store），+20 起分叉。
- Isol `@0x21b5fa` callers **130+**；LIVE `@0x1d80` sole `@0x55c6`。
- **不可**把 `@0x21b5fa` 当 Cap-decode 同构体；上拍「`@0x1d80` 缺席」仍成立。

### 4) CapFN→mega（复证）
Isol CapFN 体内 E8 入 SoftCap mega `[0x57effc,0x58e9a0)`：**5** 处；−Δ`0x2edc70` 落 LIVE 真 prol helpers（`@0x29b965`／`@0x298759`／`@0x298688`）。mid→mega 仍是 SoftCap 错 emit 根因之一。

### 5) 硬 blocker（不可请批）
1. Isol Capless `@0x57656c` **0 caller** — LIVE 绿路径用的 Capless 在 Isol **未接线**。
2. tip `0x868` 帧模板在 `@0x121278`，**未**接到 SoftCap `p_ret_*` emit（对 CapFN／mega）。
3. tip／egg 8-helper 同构仍 0／8；`@0x1d80` 真同构仍缺席。

### 6) 下一拍最小刀
1. **Path-C′′**：在 Isol tip 低 RVA 找回 LIVE Capless 6 caller 的同构 call-site，把调用从 CapFN 改挂 **已有** Capless `@0x57656c`（或证伪无同构）。
2. 或：追 LIVE emit `@0x140d00` 非 E8 入口，对齐 Isol `@0x121278` 如何进入 SoftCap `p_ret_*` 绿帧。
3. 仍禁 mega 主刀／LIVE 整树 plant／未绿请批／新 cave 除非上两项给出可 reloc 单点。

### 7) open
- Path-C′ DIG done; no isol binary; PROD／nail untouched
- next: Capless rewire dig or LIVE emit non-E8 entry
- bans unchanged

## 2026-10-30 ~08:45 CST Asia/Shanghai — Path-C′′ DIG Capless-slot retarget + emit non-E8

### 0) 闸
- tip HEAD was `375b31488`＝origin/dev（父已推通）
- Isol-G `7701dac5b813`／LIVE pret `cbc0d8e8d96f`／PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 无新 isol 二进制／无 cave／无假绿

### 1) 目标1：LIVE Capless 6 call-site → Isol 同构

**Tip-dispatch 同构：** Isol `@0x1d9710` ≅ LIVE `@0x50305`（exact 前 64B；first_diff@75＝首个 E8 rel32）。

**双槽位（pair→Capless，间距 0x24；pre24 marshal **全等**）：**

| 槽 | LIVE site → tgt | Isol site → tgt | pre24 |
|---|---|---|---|
| PAIR | `@0x5065a` → `@0x289dcb` | `@0x1d9a65` → **`@0x57ef78`** | eq |
| Capless | `@0x5067e` → **`@0x2967b4`** | `@0x1d9a89` → **`@0x59aa08`** | eq |
| PAIR | `@0x5085c` → `@0x289dcb` | `@0x1d9c67` → `@0x57ef78` | eq |
| Capless | `@0x50880` → `@0x2967b4` | `@0x1d9c8b` → `@0x59aa08` | eq |
| PAIR | `@0x508d6` → `@0x289dcb` | `@0x1d9ce1` → `@0x57ef78` | eq |
| Capless | `@0x50903` → `@0x2967b4` | `@0x1d9d0e` → `@0x59aa08` | eq |

另 LIVE Capless `@0xe84a6` 所在 fn `@0xe815b` ≅ Isol `@0x26ffcc`（同 prol）；Isol 同源槽同样打到 `57ef78`／`59aa08`。

**错挂靶：**
- `@0x57ef78`／`@0x59aa08`：同构 thin SoftCap stub（`sub rsp,0xa8`），**不是** Capless；`@0x57ef78` 完整短函数，ret 后紧贴 mega `@0x57effc`（Δ`0x84`）。
- Isol Capless `@0x57656c` ≅ LIVE Capless `@0x2967b4`（exact 前 **121B**）但 **E8 callers=0**（孤儿）。
- LIVE PAIR `@0x289dcb` prol `55 b8 70 10 00 00 e8` 在 Isol **0 hit**（PAIR 同构体缺席／改编码）。

**Capless-slot 全图（打到 `@0x59aa08` 的 9 caller）：**  
`0x12377c 0x126cda 0x128402 0x1d9a89 0x1d9c8b 0x1d9d0e 0x1da455 0x1dd9b3 0x270317`  
**PAIR-slot 全图（打到 `@0x57ef78` 的 9 caller）：**  
`0x1237be 0x126c0a 0x12849e 0x1d9a65 0x1d9c67 0x1d9ce1 0x1da497 0x1dd8e3 0x270344`

**结论1（最小根因）：** Isol tip 已具备 LIVE Capless 调用点同构，但 **Capless-slot 被改挂 SoftCap stub `@0x59aa08`**，致使 `@0x57656c` 孤儿、路径落入 SoftCap 薄桩／邻 mega 区，而非 Capless→CapFN 绿图。

### 2) 目标2：LIVE emit `@0x140d00` 非 E8 入口

- E8／E9／FF15／FF25／abs64／.pdata Begin：**全 0** xref。
- emit16 仅两处 `.text` 代码（`@0x140d00`／`@0x140d58`），无表项／无 lea rip。
- Isol tip `@0x121278` 与 LIVE emit **非**同体（masked-E8 first_diff@14）；29×`0x868` 帧模板≠emit 接线。
- **结论2：** pret 内 emit 无发现可跟入口（疑 codegen 模板／死码）；本拍 **不**以 emit 入口为主刀。

### 3) 硬 blocker（不可请批）
1. Capless-slot→`@0x59aa08` 错挂（9 site）；Capless 本体在但 0 caller。
2. LIVE PAIR `@0x289dcb` Isol 同构 **缺席**（改挂 `@0x57ef78`）。
3. 未做二进制 retarget／未跑 `p_ret_*` → **无运行绿**。

### 4) 下一拍最小刀
1. **Isol retarget（首选）：** 将 Capless-slot 9× E8 `@0x59aa08` → `@0x57656c`（单点 rel32；禁 mega 主刀／禁 LIVE 整树 plant）。
2. 同步 DIG PAIR-slot：为 `@0x289dcb` 找替代同构或证伪可暂留 stub。
3. Win SoftCap／Isol 跑 `p_ret_*`；Darwin Cap soft + Ubuntu tip-cold 真 RC。未绿勿收刀／勿升 PROD。

### 5) open
- Path-C′′ DIG root cause nailed; no isol binary this shot
- next: Capless-slot E8 retarget 9 sites → `@0x57656c` + run gates
- PROD／nail untouched; bans unchanged

## 2026-10-30 ~08:51 CST Asia/Shanghai — Isol-QQ/RR Capless-slot retarget + gates

### 0) 闸
- tip HEAD `b764da9c8`＝origin/dev（开拍）
- Isol-G `7701dac5b813` → Isol-QQ `ddcedcc6d596` → Isol-RR `1c3119231383`
- PROD SoftCap `7a2cf5da581a` **未动**（p_ret_lit 仍 CG002 code_len=0）／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／LEGACY：遵守

### 1) Isol-QQ：Capless-slot 9× `@0x59aa08`→`@0x57656c`
- sites：`0x12377c 0x126cda 0x128402 0x1d9a89 0x1d9c8b 0x1d9d0e 0x1da455 0x1dd9b3 0x270317`
- 改挂后 Capless callers=9；stub `@0x59aa08` callers=0
- **p_ret_{lit,fwd,local} 编译仍 AV `0xC0000005`**（与 Isol-G 同形）

### 2) DIG：Capless 本体内部盲 Δ 错靶（QQ 后 AV 根因）
- Capless `@0x57656c` ≅ LIVE `@0x2967b4`：**整段 span `0x1d10` 除 E8/E9 rel32 外 0 mismatch**
- 外部 helper 多数已 remap 到 Isol 真 prol（match_delta=False, prolish）
- **盲 +DELTA 错靶（落非 prol／非 Capless 内标）7：**

| LIVE tgt | Isol broken | Capless call site | RR remap → Isol iso |
|---|---|---|---|
| `@0x28e9c0` | `@0x56e778` | `@0x576692` | `@0x231334` |
| `@0x28eeb6` | `@0x56ec6e` | `@0x5766ec` | `@0x2c614f` |
| `@0x28fb43` | `@0x56f8fb` | `@0x576746` | `@0x46a4db` |
| `@0x291256` | `@0x57100e` | `@0x5767a0` | `@0x29aefb` |
| `@0x293080` | `@0x572e38` | `@0x5767fa` | `@0x49c90f` |
| `@0x2822e2` | `@0x56209a` | `@0x576a47` | `@0x5e5d7d` |
| `@0x29ac14` | `@0x57a9cc` | `@0x577405` | `@0x495fa7` |

- Isol gap `@0x56e778..@0x57656c`（span=`0x7df4`＝LIVE 家族窗）**非 CC 空洞**，禁整树 plant 覆盖。

### 3) Isol-RR：Capless-slot + 7× internal callee E8 改挂
- sha12 **`1c3119231383`**（Win `C:/xlang_tmp/p1060/cave/xlang_isol1060_RR.exe`）
- **编译门：p_ret_lit/fwd/local 全 c=0**（AV 清）
- **运行门（未绿）：**

| probe | compile | emit sha12 | run |
|---|---|---|---|
| p_ret_lit | 0 | `cf747d6b5129`（≠LIVE `dbaab1c7ce70`） | exit `0x6ea2f8a8`（非 0/1/2/3） |
| p_ret_fwd | 0 | `426aec23c78d` | AV `0xC0000005` |
| p_ret_local | 0 | `301576854809` | illegal `0xC000001D` |

- LIVE 同探针：c=0 r=0 emit `dbaab1c7ce70` size 58766；RR lit size 58254；entry@0x1440 头近同（仅一处 jmp disp 异）。

### 4) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-RR `p_ret_*` | **编译绿／运行未绿**（上表） |
| Win PROD SoftCap `7a2cf5da581a` | p_ret_lit **仍 CG002**（未动） |
| Darwin tip Cap soft | p_ret_lit/fwd/local **r=0**；i32 ret_* **7** ✅ |
| Ubuntu tip（`compiler/xlang` sha12 `ea9ddf4eb937`，HEAD `b764da9c8`） | p_ret_* **r=0**；i32 **7** ✅；`./xbuild build` tip-cold **FAIL**（`pipeline_asm_emit_return_elf_impl_prev` undef）— 真 RC 用既有 tip 二进制，非纯-ld 冷链 |

### 5) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. Isol-RR 运行未绿：lit 错 exit／fwd AV／local illegal；emit ≠ LIVE。
2. Capless 家族窗 helper 未 plant；RR remap 为弱同构（score 29–89B）— 可能仍错 ABI／语义。
3. PAIR-slot 9× 仍挂 SoftCap stub `@0x57ef78`；LIVE PAIR `@0x289dcb` Isol **缺席**（本拍未主刀）。
4. Ubuntu tip-cold pure-ld 断链（`_prev` undef）— 与 SoftCap 运行绿无关，另记。

### 6) 下一拍最小刀
1. **emit DIG：** Isol-RR vs LIVE `p_ret_lit` 反汇编差（sret park／rs_copy／fwd）；定位错 emit 是否仍经 PAIR-slot／mega。
2. 或：**PAIR-slot** 9× 寻替代同构／最小补（禁 mega 主刀／禁 LIVE 整树）。
3. 或：Capless 盲 Δ 靶改为 **高分同构校验 + 单点 plant 缺口 helper**（仅缺的 7，非整树）。
4. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 7) open
- Isol-QQ/RR 二进制在 Win cave；PROD／nail untouched
- Darwin／Ubuntu tip p_ret 仍绿；Win SoftCap 运行门红
- bans unchanged

## 2026-10-30 ~08:58 CST Asia/Shanghai — Isol-RR vs LIVE `p_ret_lit` emit DIG

### 0) 闸
- tip HEAD `c4049ed7e`＝origin/dev；DIG tip `397d0ef0a`
- Isol-RR `1c3119231383`／LIVE SoftCap emit lit `dbaab1c7ce70`（58766）／RR lit `cf747d6b5129`（58254）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／LEGACY：遵守
- 本拍 **无新 Isol 二进制**；仅 emit DIG＋移植证伪

### 1) 结构差（PE）
| | LIVE | Isol-PP（EE…PP 同形） | Isol-RR |
|---|---|---|---|
| size / sha12 | 58766 / `dbaab1c7ce70` | 58766 / `0ddf9b1751b1` | 58254 / `cf747d6b5129` |
| .text vs | 0x2e30（raw 0x3000） | 同 LIVE | **−0xa0**（raw 0x2e00） |
| CRT `call` @0x10d5 | → **0x14f8** | → 0x14f8 | → **0x14f8**（未随 shrink 改） |
| `sub rsp,0x868/0x878` | mk／main 各 1 | **0** | **0** |
| sret park `lea+mov rcx` | ✅ | ✅ | **❌** |
| mk `mov [rbx],rax` stores | ✅ | ✅ | **❌**（mk 体消失） |

### 2) LIVE SoftCap 绿形（对照）
- **mk @0x1490**：`push rbp; mov rbp,rsp; push rbx; sub rsp,0x868`；`rax←rcx`（sret）／`rax←rdx`（值）；三字段 `mov [rbx(+0/+8/+10)],rax`；`mov rax,rbx`（`48 89 d8`）；epilogue。
- **main @0x14f8**：`sub rsp,0x878`；`lea rax,[rbp-0x28]; mov rcx,rax`；imm10→`[rbp-0x38]`→**`mov rdx,rax`**；`call mk`；三字段 `lea`＋**`mov rax,[rax]`（`48 8b 00`）**＋cmp 10/11/12。
- LIVE chk 运行 **r=0**。

### 3) Isol-PP（编译能出、运行 AV）— 同尺寸非 SoftCap 形
- mk 帧 **0x68**（非 0x868）；main 帧 **0x1b8**（非 0x878）。
- main 调用：`sub rsp,0x20; mov eax,10; call mk; add rsp,0x20` — **无 `mov rdx`**（mk 仍读 rdx→值垃圾）。
- **系统 3B 错码（源码 encoder 为正确立即数，Isol 产物却写错）：**
  - `48 89 d8`（mov rax,rbx）→ **`e9 00 00`**（mk 返回前）
  - `48 8b 00`（mov rax,[rax]）→ **`a8 fe ff`**（main 三字段 load）
- 单改 `a8feff→488b00` **仍 AV**；根因不止 load。
- PP lit 运行 **AV `0xC0000005`**（与 DIG EE 记一致）。

### 4) Isol-RR（本拍主 DIG）— 编译绿／emit 坍缩
- 用户区 **无** mk SoftCap／thin 体；`@0x1490` 起即为残缺 main 检查片段（无 prol／无 call mk／无 store）。
- CRT 仍 `call 0x14f8` → 落在残缺 main **中部**（`a8feff…`）→ lit exit `0x6ea2f8a8`／local `0xC000001D`（illegal）／fwd AV。
- .text −0xa0 与缺 mk＋缺 SoftCap 帧一致；**RR 的 7× Capless 内盲 Δ remap 在 QQ 清 AV 后进一步打坏 user emit**。

### 5) 证伪／最小证明（移植）
- 将 LIVE `0x1490..0x15d0`（mk+main，0x140B）**原样写入** PP lit 同偏移 → 运行 **exit=0**。
- ⇒ emit≠LIVE／运行红的充要落点＝**用户 mk+main codegen**；CRT／其余 PE 在 SoftCap 形 mk/main 下可绿。
- RR 仅改 load 3B → 行为变 AV（仍红）；无完整 mk/main 不可绿。

### 6) 根因（最小路径）
1. **Isol Capless／thin PE 用户 codegen ≠ LIVE SoftCap 形**（帧 0x868/0x878、rdx 封送、`48 8b 00`／`48 89 d8`）。自 EE/PP 起 emit≠LIVE；PP 已 AV。
2. **Isol-RR 7× 弱同构 internal remap** 使 Capless 编译门绿，但 **坍缩 mk/main**，CRT 仍钉 0x14f8 → 运行 illegal／错 exit；sha `cf747d6b5129`≠`dbaab1c7ce70`。
3. **PAIR-slot 9× 仍挂 SoftCap stub `@0x57ef78`**（LIVE PAIR `@0x289dcb` Isol 缺席）— SoftCap 双槽未复原，疑与未走 SoftCap 用户 emit 同源结构缺口（本拍未主刀，列为下一最小刀候选）。

### 7) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. Win SoftCap Isol-RR `p_ret_*` **运行未绿**；emit ≠ LIVE SoftCap。
2. Capless 用户 emit 缺 SoftCap 形；RR remap 不可当作绿路径保留。
3. PAIR-slot 仍 stub；PROD／钉未动。

### 8) 下一拍最小刀
1. **PAIR-slot** 9×：寻 LIVE `@0x289dcb` 替代同构或最小 retarget（禁 mega／禁整树 plant）— 优先验证是否拉回 SoftCap 用户 emit（0x868/0x878）。
2. 或：撤销／替换 RR 7× 弱 remap → **高分同构校验 + 单点 plant** 真 helper（仅缺的 7）。
3. 或：定点修 Capless thin emit（rdx 封送 + `enc_load_64_from_rax`／`enc_mov_rbx_to_rax` 产物须为 `48 8b 00`／`48 89 d8` + SoftCap 帧）— 需先 DIG 清 Isol 内 encoder 实际落点（疑 Capless 错挂／错 append，源码立即数本身正确）。
4. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 9) open
- DIG 完成；移植证明在 Win cave `out_pp/p_ret_lit_live_mkmain.exe`（仅 DIG，非收刀）
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~09:10 CST Asia/Shanghai — PAIR-slot falsify + Isol-SS high-score retarget + encoder sink start

### 0) 闸
- tip HEAD `0661ee6fb`＝origin/dev（本拍自 tip DIG `0661ee6fb` 续）
- LIVE SoftCap host `lab_LIVE_pret.exe` sha12 `cbc0d8e8d96f`；LIVE lit emit `dbaab1c7ce70`
- Isol-G `7701dac5b813`／Isol-RR `1c3119231383`／**Isol-SS `4e35dff4d102`**（Win `C:/xlang_tmp/p1060/cave/xlang_isol1060_SS.exe`）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／未绿请批／LEGACY：遵守
- 本拍：PAIR DIG 证伪 → Isol-SS（Capless 9×＋7× 高分 exact-prol remap；PAIR 留 stub）→ encoder 落点初 DIG；未运行绿 → 勿收刀

### 1) PAIR-slot 同构／retarget — **证伪**
| | LIVE SoftCap | Isol-G／SS |
|---|---|---|
| PAIR 入口 | `@0x289dcb` SoftCap prol `55 b8 70 10 00 00 e8`（frame **0x1070**） | **0 hit** 同 prol |
| PAIR 调用点 | SoftCap 形（含 `[rbp+0x1000..]` 大帧布局） | 9× 仍 E8→**`@0x57ef78`** thin SoftCap stub |
| stub 体 | — | `@0x57ef78` head `55 48 89 e5 53 48 81 ec a8 00 00 00…`；内 E8→mega `@0x59b170`（禁 mega 主刀） |
| SoftCap PAIR 整树 plant | — | **禁**（LIVE 家族窗／整树 plant ban） |

- 结论：**无 Isol 内 SoftCap PAIR 同构可挂**；retarget 无目标；不可用 PAIR 拉回 SoftCap `0x868` 用户 emit。
- 动作：Isol-SS **刻意保留** PAIR 9×→`@0x57ef78`（不改挂／不 plant）。

### 2) Isol-SS：Capless-slot 9× + 7× **高分 exact-prol** internal remap
- 相对 RR 弱 remap，本拍改挂为 exact-8B-prol＋最大 masked 同构（唯一；避开 Capless／PAIR／mega）：

| Capless call | RR dest（弱） | SS dest（高分） | LIVE 对照 prol |
|---|---|---|---|
| `@0x576692` | `@0x231334` | **`@0x2be519`** | LIVE `@0x28e9c0` 0x150 |
| `@0x5766ec` | `@0x2c614f` | `@0x2c614f` | LIVE `@0x28eeb6` 0x190 |
| `@0x576746` | `@0x46a4db` | `@0x46a4db` | LIVE `@0x28fb43` 0x1f0 |
| `@0x5767a0` | `@0x29aefb` | **`@0x493d31`** | LIVE `@0x291256` 0x260 |
| `@0x5767fa` | `@0x49c90f` | `@0x49c90f` | LIVE `@0x293080` 0x220 |
| `@0x576a47` | `@0x5e5d7d` sc32 | **`@0x2b55e7`** | LIVE `@0x2822e2` thin 0x30 |
| `@0x577405` | `@0x495fa7` | **`@0x27a89b`** | LIVE `@0x29ac14` 0x240 |

- 构建脚本：`_dig/build_isol_ss.py`（cave 同跑）；log `_dig/p1060_ss/isol_ss_log.txt`

### 3) Isol-SS 门（Win SoftCap）— **编译绿／运行红／SoftCap 帧仍 0**
| probe | compile | emit sha12 | SoftCap `0x868`/`0x878` | `a8feff` | run |
|---|---|---|---|---|---|
| p_ret_lit | 0 | `5c640540c9be`（≠LIVE `dbaab1c7ce70`） | **0／0** | 4 | AV `0xC0000005` |
| p_ret_fwd | 0 | `e4d84ced387f` | 0／0 | 4 | AV `0xC0000005` |
| p_ret_local | 0 | `2660750dcd7e` | 0／0 | 4 | AV `0xC0000005` |

- emit 形 ≅ Isol-PP thin：帧 `sub rsp,0x1b8` 现；**无** SoftCap `0x868`/`0x878`；仍见 corrupt `e9 00 00`／`a8 fe ff`（同时 PE 内亦有 `48 89 d8`／`48 8b 00` 计数字面，非用户 mk/main SoftCap 落点）。
- ⇒ **高分 Capless callee retarget 不能恢复 SoftCap `0x868` emit**；与 PAIR 证伪一并关闭「双槽 remap 即 SoftCap 用户形」假说。

### 4) encoder／frame 落点初 DIG（未收刀）
- Isol HOST **已有**正确 `48 89 d8` 模板写入器 `@0x5156ec`（`mov al,0x48/0x89/0xd8` → `[rbx+0/1/2]`）。
- Isol／LIVE **未**见同风格 imm8 三连写入器构建真 `48 8b 00`（emit 风格不同；非本地缓冲填）。
- Isol HOST 内 `sub rsp,0x868` **29×**（HOST SoftCap 路径存在），但 Capless 用户路径帧走 **0x68／0x1b8**（`arch_x86_64_enc_enc_prologue(frame_sz)`／compute_frame_size 分支 ≠ SoftCap）。
- Capless 用户 emit 仍写出 `e9 00 00`（本应 `48 89 d8`）→ **调用链／append 路径错挂或缓冲损坏**，非源码立即数本身错。
- tip 源：`backend_enc_dispatch_thin.x`／`x86_64_enc.x`（prologue／enc helpers）— 下一拍 DIG 清 Capless call 实际用的 mov_rbx／load_64／prologue vs SoftCap 路径分叉。

### 5) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-SS `p_ret_*` | **编译绿／运行 AV**；SoftCap 帧 0；emit≠LIVE |
| Win PROD SoftCap `7a2cf5da581a` | **未动**（勿升） |
| Darwin tip Cap soft | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/xlang`（sha12 `ea9ddf4eb937`，旧 tip 二进制仍绿） | p_ret_* **r=0** ✅；`./xbuild build` tip-cold **FAIL** pure-ld（`pipeline_asm_emit_return_elf_impl_prev` undef）— 真 RC＝既有 tip 二进制，非纯-ld 冷链 |

### 6) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. PAIR-slot **证伪**：Isol 无 SoftCap PAIR 体；9× 仍 stub；禁 mega／整树。
2. Isol-SS 高分 Capless remap **未**恢复 SoftCap `0x868` emit；运行仍 AV。
3. Capless／thin 用户 codegen ≠ LIVE SoftCap 形（帧／rdx／`48 8b 00`／`48 89 d8` 产物）；encoder 落点未钉死调用链。
4. Ubuntu tip-cold pure-ld 断链另记（与 SoftCap 运行绿无关）。

### 7) 下一拍最小刀
1. **encoder／frame_size 落点 DIG**：Isol Capless 用户路径实际调用的 prologue／mov_rbx／load_64／append vs SoftCap 路径分叉；验证 `@0x5156ec` 是否在用户 emit 链上、谁写出 `e9 00 00`／`a8 fe ff`。
2. 或：定点 plant／retarget **缺的 SoftCap 用户 emit helper**（仅缺口，非整树；禁 mega）。
3. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 8) open
- Isol-SS `4e35dff4d102`＋`_dig/build_isol_ss.py`／`_dig/p1060_ss/`；PAIR 证伪记录在案
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~09:13 CST Asia/Shanghai — encoder／frame_size 落点 DIG + Isol-TT LEA plant

### 0) 闸
- tip HEAD `eed82f362`＝origin/dev（本拍自 tip 续）
- LIVE SoftCap host `lab_LIVE_pret.exe` sha12 `cbc0d8e8d96f`；LIVE lit emit sha12 `dbaab1c7ce70`
- Isol-G `7701dac5b813`／Isol-SS `4e35dff4d102`／**Isol-TT `1f836615e0fc`**（Win `C:/xlang_tmp/p1060/cave/xlang_isol1060_TT.exe`）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／未绿请批／LEGACY／整树／cave 字母堆：遵守
- 本拍：encoder／frame_size 落点 DIG 钉死；最小缺口 → 单点 LEA opcode-blob plant（Isol-TT）；未 SoftCap 运行绿 → **勿收刀**

### 1) tip 源 vs Isol／LIVE 二进制 encoder 形
| 层 | mov_rbx_to_rax | load_64_from_rax |
|---|---|---|
| tip 源 `x86_64_enc.x` | `buf=[72,137,216]` + `append_elf_bytes` | `buf=[72,139,0]` + append |
| LIVE SoftCap 薄包装 | `@0x26ceeb`：`lea rdx,[rip+0xfc472]` → **.rdata** `48 89 d8`；`x86_enc_bytes(...,3)` | `@0x26d4b5`：`lea rdx,[rip+0xfbede]` → **.rdata** `48 8b 00` |
| Isol Capless 同形薄包装 | `@0x513828`：**同 displ `0xfc472`** → **.text** `@0x60fcbb`＝**`e9 00 00`** | `@0x5149d4`：**同 displ `0xfbede`** → **.text** `@0x6108d3`＝**`a8 fe ff`** |
| Isol tmpl 写入器 | `@0x51569c`／`@0x5156ec` 正确 imm→`[rbx]`（Capless **不**直调作用户 emit） | — |

- Isol `.rdata` **无** LIVE 同位 opcode 池（LIVE rdata off `0x2437e` 超出 Isol rdata 尺寸）→ 冻结 RIP displ 落进 .text 中部（同 10.54 SoftCap opcode-table LEA 误指症候）。
- Capless `@0x57656c` BFS：**depth 2 即达** `@0x513828`／`@0x5149d4` → **用户 emit 链确走坏 LEA 薄包装**（非 tip 源立即数错）。
- Isol 全库 `lea rdx,[rip]; mov r8d,3; call append` 扫描：len=3 目标中 **仅 2 处 BAD**（`e90000`／`a8feff`）；LIVE 同位 0 BAD／3 GOOD。

### 2) frame_size 路径分叉（钉死）
| 路径 | 入口 | 用户帧 | rdx 封送 | 备注 |
|---|---|---|---|---|
| LIVE SoftCap | Cap decode → SoftCap helpers（含 tip `@0x121278` 形 `sub rsp,0x868`） | **`0x868`／`0x878`** | 有（值←rdx） | HOST Isol 内 `0x868` 模板 29×，**未**接到 Capless 用户 emit |
| Isol Capless | `@0x57656c`（`sub rsp,0x500`）→ Capless 族 helpers | **`0x68`／`0x1b8`** | mk 有 rdx 存；**main 未 call mk**（直 lea 未初始化局部再 `488b00`） | PAIR／高分 remap **不能**改帧；`compute_frame_size`／Capless 分支 ≠ SoftCap |
| tip Darwin Cap soft | tip 源 prologue(`frame_sz`) | SoftCap 形（本拍 Darwin r=0） | 正常 | 证明 tip 源路径绿；Isol SoftCap 二进制布局／Capless 槽红 |

- `arch_x86_64_enc_enc_prologue(frame_sz)` 本身按传入 `frame_sz` 编码；分叉在 **上游 `pipeline_asm_compute_frame_size_c`／Capless vs SoftCap 选路**，非 prologue 编码器写死错立即数。

### 3) 谁写出 `e90000`／`a8feff`（钉死）
1. **根因（用户 mk／main 腐蚀位）**：Isol `@0x513828`／`@0x5149d4` LEA→错 blob → `x86_enc_bytes` 原样拷 3B 进产物。
2. **非根因假阳**：emit 内其余 `e9 00 00 00 00`＝`jmp +0` 落空桩；`a8 fe ff ff` 可作 CRT `jmp rel32` 立即数（TT 后仅余 CRT 位）。
3. Isol **无** imm8 三连写入器发 `e9/00/00` 或 `a8/fe/ff`；坏字节来自 **错 LEA 目标内存**，非独立「坏常量 writer」。

### 4) 单点 helper plant — Isol-TT
- 脚本：`_dig/build_isol_tt.py`（＝SS Capless 9×＋7× 高分 remap ＋ LEA plant；PAIR stub 保留；禁 mega／整树）
- Plant：
  - INT3 cave `@0x513861` ← `48 89 d8`；LEA `@0x513842` displ `0xfc472`→**`0x18`**
  - INT3 cave `@0x514a0d` ← `48 8b 00`；LEA `@0x5149ee` displ `0xfbede`→**`0x18`**
- Isol-TT sha12 **`1f836615e0fc`**

### 5) Isol-TT 门（Win SoftCap）— **编译绿／运行 exit=1／SoftCap 帧仍 0**
| probe | compile | emit sha12 | SoftCap `0x868`/`0x878` | mk `4889d8` | field `488b00` | run |
|---|---|---|---|---|---|---|
| p_ret_lit | 0 | `5b173cef1205` | **0／0**（仍 `0x68`／`0x1b8`） | **✅ @0x14ec** | **✅ @0x150f/44/79** | **exit 1**（非 AV） |
| p_ret_fwd | 0 | `546a4c6d02df` | 0／0 | ✅ | ✅ | exit 1 |
| p_ret_local | 0 | `018c76562e9e` | 0／0 | ✅ | ✅ | exit 1 |

- vs Isol-SS：运行 **AV `0xC0000005` → exit 1**；用户位 `e90000`／`a8feff` **已消除**（假阳 CRT／jmp+0 除外）。
- main 仍 **未 call mk**：`lea [rbp-0x28]` 后直接 load → 与期望 0xa/0xb/0xc 比较失败 → exit 1。帧仍 thin。

### 6) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-TT `p_ret_*` | 编译绿／**exit 1**；encoder 腐蚀位已修；SoftCap 帧 0；≠LIVE |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937` | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 7) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. Capless 用户路径 **帧／call-mk／rdx 封送** ≠ LIVE SoftCap（encoder 3B 腐蚀已钉＋plant；**不足以** SoftCap 运行绿）。
2. Isol SoftCap `@0x121278`（0x868）**未**接到 Capless `@0x57656c` 用户 emit；PAIR 已证伪；禁 mega／整树。
3. Ubuntu tip-cold pure-ld 断链另记（与 SoftCap 运行绿无关）。

### 8) 下一拍最小刀
1. **Capless→SoftCap 用户 emit 接线**：从 Capless `@0x57656c`／main 缺 `call mk`＋`compute_frame_size` 分支追 LIVE SoftCap 等价 helpers（禁 mega／禁整树；可新 Isol 试验槽）。
2. 或：定点补 main lit init／frame 缺口 helper（单点；验证 Win SoftCap `p_ret_*` r=0＋帧 `0x868`/`0x878`）。
3. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 9) open
- Isol-TT `1f836615e0fc`＋`_dig/build_isol_tt.py`／`_dig/p1060_tt/`；LEA plant 证明 encoder 缺口闭合
- Isol-SS `4e35dff4d102` 保留作对照
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~09:30 CST Asia/Shanghai — Capless→SoftCap user emit wiring DIG（UU／VV／WW）

### 0) 闸
- tip HEAD `69e461bf3`＝origin/dev（DIG 主 `c58c9c0da`）
- Isol-TT `1f836615e0fc` 基线；LIVE SoftCap host `cbc0d8e8d96f`；LIVE lit emit `dbaab1c7ce70`
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／未绿请批／LEGACY／整树／cave 字母堆：遵守
- 本拍：Capless→SoftCap 用户 emit 接线（frame＋call-mk；rdx／sret 对齐 LIVE SoftCap mk@0x1490／main@0x14f8）；最小 isol／plant；**未运行绿 → 勿收刀**

### 1) LIVE vs Isol-TT emit 钉死（call-mk／frame）
| | LIVE SoftCap lit `dbaab1c7ce70` | Isol-TT／UU／VV／WW lit `5b173cef1205` |
|---|---|---|
| mk frame | `sub rsp,0x868` @0x1495 | `sub rsp,0x68` @0x1495 |
| main frame | `sub rsp,0x878` @0x14fd | `sub rsp,0x1b8` @0x14fd |
| main call-mk | `lea rcx,[rbp-0x28]`；imm10→`[rbp-0x38]`→`mov rdx,rax`；**`call mk`**；再 `488b00` 读字段 | `lea rcx,[rbp-0x28]` 后 **直接** `lea`＋`488b00`（**无** imm10／rdx／call） |
| mk body | rcx=sret／rdx=值；`4889d8` 返 | 同形（TT LEA plant 后） |

- tip SoftCap floor（`w1500_fs_core`）：`call_spill>=1024` → scratch floor **2048**（`0x800`）；叶／无 call 不抬。mk 叶 LIVE 仍 `0x868` ⇒ SoftCap 宿主另有固定 spill 策略，非仅 tip w1032 floor。
- Capless main **已**做 sret `lea→rcx` 但 **跳过** call-mk ⇒ 部分 CallExpr／sret 发射（exit 1 根因）。

### 2) SoftCap／Capless 分叉 DIG
| 入口 | Isol | LIVE | 形 |
|---|---|---|---|
| Capless emit | `@0x57656c`（`sub rsp,0x500`） | `@0x2967b4` | CaplessΔ=`0x2dfdb8` |
| SoftCap twin | `@0x57ef78` **薄包装** → `mov eax,1`（mode）→ **`call 0x59b170`**；ret `@0x57eff8`（~0x80B） | `@0x289dcb` SoftCap-style chkstk prol（`mov eax,0x1070`）；体 ~`0x4bf5`；93 unique E8 | SoftCapΔ=`0x2f51ad` **≠** CaplessΔ |
| SoftCap mega | `@0x59b170`（~calls CapFN`@5752bc`／`@56d014`；**不**达 call-emitter`@514434` depth≤4） | — | Isol SoftCap mega ≠ LIVE SoftCap 体 |
| kind 分派 | `cmp [rbp-0x2c],0x31` → SoftCap twin／jne Capless（9× 对称 callers） | 同形 6× | — |

- Isol SoftCap twin **≠** LIVE SoftCap：仅 1 call／薄 prol；强制 0x31 不能拉回 LIVE 形。
- LIVE SoftCap 93 callees：CapΔ／SCFΔ／CFNΔ **均无** Isol push-rbp 同构（masked diff~40+）；**整树 plant 禁**；单 plant LIVE SoftCap 体会落入 mid-insn callee。

### 3) Isol-UU — CapFN mid→mega SoftCap size-helper plant
- 脚本：`_dig/build_isol_uu.py`（基 TT）
- Plant LIVE SoftCap helpers `{0x29b965,0x298759,0x298688,0x298627,0x281df8,0x281e13,0x281dca}` → cave `@0x116998+`；Capstone 按 LIVE RVA 解码后改写 E8；CapFN 5× retarget
- Isol-UU sha12 **`54ed284b17dc`**
- 门：`p_ret_lit` compile 0；emit sha **`5b173cef1205`＝TT**；SoftCap 帧 **0／0**；run exit 1
- ⇒ CapFN mid→mega size plant **不改** 用户 emit（Capless 路径未吃 SoftCap size）

### 4) Isol-VV — Capless SoftCap mode force
- 脚本：`_dig/build_isol_vv.py`（基 UU）
- Capless 入口 trampoline：复 prol16＋`mov dword [rbp+0x4b0],1`（mode＝SoftCap size 闸）→ jmp Capless+16；cave `@0x116e30`
- Isol-VV sha12 **`34e7bd40413a`**
- 门：emit sha **仍 `5b173cef1205`**；帧 0；run exit 1
- ⇒ Capless mode＝1 **不足以** 改 SoftCap 用户帧／call-mk（size 闸非本探针主路径，或 mode 已无关）

### 5) Isol-WW — force kind 0x31 → SoftCap twin
- 脚本：`_dig/build_isol_ww.py`（基 TT；NOP 3× `jne` after `cmp …,0x31` @`0x1d9a49`／`0x1d9c4b`／`0x1d9cc5`）
- Isol-WW sha12 **`20357ddfefe8`**
- 门：emit sha **仍 `5b173cef1205`**；n868=0；n1b8=1；run exit 1
- ⇒ SoftCap twin→`@59b170` mode=1 **仍** Capless 形用户 emit；Isol SoftCap mega 与 Capless 同产 thin／无 call-mk

### 6) 接线结论（本拍）
1. **Capless→SoftCap 开关（kind 0x31／mode 0x4b0／CapFN size plant）均证伪**：emit sha 不变＝`5b173cef1205`。
2. Isol SoftCap twin／mega **非** LIVE SoftCap `@289dcb` 同构；LIVE SoftCap plant 需 93 callee 树 → **禁整树／禁 mega 主刀**。
3. 剩余硬缺口：**Capless／Isol-SoftMega CallExpr／sret 发射跳过 call-mk**（已 lea rcx）；修 call-mk 后 tip SoftCap floor／HOST spill 才有机会抬帧。
4. Capless BFS depth 4 可达 call-emitter `@0x514434`；SoftMega `@59b170` depth≤4 **不可达** — SoftCap 路径甚至更缺 call emit 链。

### 7) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-UU／VV／WW `p_ret_*` | 编译绿／**exit 1**；SoftCap 帧 0；emit＝TT ≠LIVE |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft `./compiler/xlang` | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937`（HEAD `b764da9c8`） | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 8) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. Capless／Isol-SoftMega **跳过 call-mk**（sret lea 后直读字段）→ exit 1；帧 thin。
2. Isol SoftCap ≠ LIVE SoftCap；开关／CapFN size plant／mode force **不能**接线；LIVE SoftCap 整树 plant **禁**。
3. Ubuntu tip-cold pure-ld 断链另记（与 SoftCap 运行绿无关）。

### 9) 下一拍最小刀
1. **CallExpr／sret call-mk 缺口**：从 Capless `@0x57656c`／`@0x56d014` 追 LIVE SoftCap 等价「imm→rdx＋E8 call」helper；定点 plant／retarget **仅缺口**（禁 mega／整树）。
2. 验证：Win SoftCap `p_ret_*` r=0 ＋帧 `0x868`/`0x878`（call-mk 通后 SoftCap floor／spill 应跟随或再单点抬帧）。
3. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 10) open
- Isol-UU `54ed284b17dc`／VV `34e7bd40413a`／WW `20357ddfefe8`＋`_dig/build_isol_{uu,vv,ww}.py`；TT 对照保留
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~09:47 CST Asia/Shanghai — Isol-XX Capless `@56d014` call-mk plant 证伪

### 0) 闸
- tip HEAD `2174df838`＝origin/dev（DIG 前；本拍后 tip 见 commit）
- Isol-TT `1f836615e0fc` 基线；Isol-XX sha12 **`4687a4112204`**
- LIVE SoftCap lit emit `dbaab1c7ce70`；TT／XX lit emit **`5b173cef1205`**
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega 主刀／假绿／未绿请批／LEGACY／整树／cave 字母堆：遵守
- 本拍：Capless `@57656c`／`@56d014` 定点 call-mk（imm→rdx＋E8）缺口 plant／retarget；最小 isol；**未运行绿 → 勿收刀**

### 1) Isol-XX plant（最小）
- 脚本：`_dig/build_isol_xx.py`（基 TT；cave `@0x116998`）
- Plant LIVE `{@284d24, @2984c9, @29bac6}` → cave `@0x1169a0`／`@0x1171d0`／`@0x117330`
  - L2I exact twins + role-parallel；chkstk／memset 用 Isol 既有
  - Capstone 按 LIVE RVA 改写 plant 内 E8
- Retarget **全部 7×** Isol E8→`@56d014` → plant `@0x1169a0`：
  - Capless fo+`0x702`／`+0x7bd`／`+0xf09`（＝LIVE Capless fo 同形）
  - SoftMega 3×（`@0x59d14a`／`@0x59d2c5`／`@0x59ed31`）
  - 另 1× `@0x5859f1`
- Isol-XX sha12 **`4687a4112204`**

### 2) Win SoftCap 门（out_xx）
| probe | crc | emit sha | vs TT counterpart | n868／n878 | run |
|---|---|---|---|---|---|
| p_ret_lit | 0 | `5b173cef1205` | **＝TT** | **0／0** | **exit 1** |
| p_ret_fwd | 0 | `546a4c6d02df` | **＝TT** | 0／0 | exit 1 |
| p_ret_local | 0 | `018c76562e9e` | **＝TT** | 0／0 | exit 1 |

- SoftCap 帧仍 thin（mk／main `0x68`／`0x1b8`）；call-mk 仍缺（main 仍 `lea→rcx` 后直 `lea`＋`488b00`）
- ⇒ **`@56d014`／LIVE `@284d24` plant＋7× retarget 不改 SoftCap `p_ret_*` 用户 emit**

### 3) `@56d014`／`@284d24` 角色钉死（非 SoftCap CallExpr call-mk）
1. Capless→helper fo+702／7bd／f09 LIVE↔Isol **同构**；prev＝`lea`＋`mov [rsp+0x20],ecx`＋`mov rcx,rax`（println／spill 形 shared helper），**无** imm10→rdx。
2. LIVE SoftCap **1×** E8→`@284d24` @`0x28be7f`（SoftCap+~`0x20b4`）：prev 同样 spill／`mov rcx,rax`；**±0x200 无 imm10** ⇒ **不是** lit `mk(10)` 的 imm→rdx＋E8。
3. lit SoftCap CallExpr call-mk 在 LIVE 用户 emit 内联：
   ```
   lea rax,[rbp-0x28]; mov rcx,rax;
   mov eax,0xa; mov [rbp-0x38],rax; mov rax,[rbp-0x38]; mov rdx,rax;
   call mk;  lea rax,[rbp-0x28]; mov rax,[rax] …
   ```
   Isol／XX 同点：`lea→rcx` 后 **跳过** imm／rdx／call，直字段读 → exit 1。
4. SoftMega 可达 `@56d014`／CapFN，**仍**产 Capless 形 thin emit（WW 已证 SoftCap twin→mega 同形）。

### 4) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-XX `p_ret_*` | 编译绿／**exit 1**；SoftCap 帧 0；emit＝TT ≠LIVE |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft `./compiler/xlang` | p_ret_lit/fwd/local **r=0** ✅（ARM64；无 x86 SoftCap 帧） |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937` | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 5) 硬 blocker（不可请批／勿收刀／勿升 PROD）
1. Capless／Isol-SoftMega SoftCap CallExpr：**sret `lea→rcx` 后跳过 imm→rdx＋`call mk`** → exit 1；帧 thin。
2. `@56d014`／`@284d24`＝shared Capless SoftCap-site helper（非 lit CallExpr call-mk）→ plant／retarget **证伪**。
3. Isol SoftCap twin／mega ≠ LIVE SoftCap `@289dcb`；LIVE SoftCap 整树 plant **禁**；mega 主刀 **禁**。
4. Ubuntu tip-cold pure-ld 断链另记（与 SoftCap 运行绿无关）。

### 6) 下一拍最小刀
1. **SoftCap CallExpr call-mk 真缺口**（非 `@56d014`）：Isol Capless／SoftMega 上「`lea→rcx` 后 early-out」单点 — tip leftover `glue_emit_struct_type_let_init` CALL＞16B／Windows SoftCap 路径，或 Capless SoftCap CallExpr 发射点定点 plant（imm→rdx＋E8；禁 mega／整树）。
2. 通后再验 SoftCap 帧 `0x868`／`0x878`（call-mk 后 SoftCap floor／HOST spill 或再单点抬帧）。
3. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 7) open
- Isol-XX `4687a4112204`＋`_dig/build_isol_xx.py`；TT／UU／VV／WW 对照保留
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~12:25 CST Asia/Shanghai — YY155／YY164＋Isol-AAA／DDD Win plant；Capless CapFN 证伪

### 0) 闸
- tip HEAD `38f5d2045`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-AAA sha12 **`9326cde5b6af`**；Isol-DDD sha12 **`a9e70ef1595b`**
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆：遵守；本拍 **只跑既有 AAA＋DDD**，未新开 isol 字母

### 1) 已钉 DIG 续用
- Isol-XX `@56d014` **证伪**（上拍）
- **YY155**：SoftCap twin→SoftMega→bridge `@59ab11`→SoftCap-full `@57effc`：**无** CALL kind=3／CE／h_emit（真缺口非 XX）
- **YY164**：Capless CapFN SoftCap SoftCap `@576b71` `mov eax,0; jmp exit`——kind∈{0x33,0x34} 非 kind=3；Isol-ZZ kind==3 fallthrough **证伪**；YY SoftCap-full→Capless 撞 CapFN SoftCap early-out
- USER：Isol `lea→rcx` 后直字段读；LIVE `lea→rcx; mov edx,0xa; call mk@0x1490`；帧 thin≠`0x868`/`0x878`

### 2) Win SoftCap 门（cave；本拍实跑）
| Isol | sha12 | plant | lit emit | n868／n878 | run |
|---|---|---|---|---|---|
| AAA | `9326cde5b6af` | YY `@59ab11`→Capless ＋ `@576b71`→CALL body `@577c37` | `5b173cef1205`＝TT | **0／0** | **exit 1** |
| DDD | `a9e70ef1595b` | `@576b71`＋`@576b7b`→h_emit `@578184` | `5b173cef1205`＝TT | **0／0** | **exit 1** |

- fwd／local 同形 emit＝TT；`n1b8=1` thin；`ba0a=0`
- ⇒ Capless CapFN SoftCap→CALL/VAR body／→h_emit **不改** SoftCap `p_ret_*` 用户 emit

### 3) 角色钉死（续）
1. LIVE Capless `@2967b4` 与 Isol Capless **同** kind 集（0x33／0x34／0x2c／0x3）——**无 kind=0x30**；CapFN SoftCap early-out LIVE≡Isol。Capless **不是** lit SoftCap CallExpr call-mk 权威。
2. Tip CallExpr kind=48 → CALL handler → Capless（kind≠0x31 SoftCap twin）。AAA 的 `@577c37`＝kind==3 后 **VAR** body，非 CallExpr。
3. Windows leftover `glue_emit_struct_type_let_init` CALL＞16（`windows_link_stubs.c`）：lea＋mov_arg＋sret_shift＋`emit_expr` —— Isol 停在 sret `lea→rcx`；LIVE 续 imm→rdx＋call mk。
4. Capless early-out **单独**解释不了 LIVE 绿（LIVE Capless 同构）。

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. SoftCap CallExpr：**sret `lea→rcx` 后跳过 imm→rdx＋`call mk`** → exit 1；帧 thin。
2. XX／YY／ZZ／AAA／DDD Capless／SoftMega／CapFN plants **均** emit＝TT。
3. LIVE SoftCap 整树／mega／新 cave 字母堆 **禁**。

### 5) 下一拍最小刀（单点；禁字母堆）
1. Dig **一处**：emit_expr SoftCap flag／fast-path（Isol `@1cf074`／LIVE `@464cb`），或 CALL handler post-Capless encode（Isol `@1e20b1`／LIVE `@59ad9`）＋`cmp …,0x10`／`0xa` 选路 —— 谁在 LIVE 于 Capless 返回 0 之后写出 imm→rdx＋E8，Isol 为何不写。见 `_dig/p1060_uu/dig_earlyout_aaa_ddd_gap.md`。
2. 仅该单点 plant Isol-TT；通后再验帧 `0x868`/`0x878`＋Darwin Cap soft＋Ubuntu tip-cold。
3. 未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-AAA `9326cde5b6af`／DDD `a9e70ef1595b`＋`_dig/build_isol_{aaa,ddd}.py`；笔记 `dig_earlyout_{yy155_gap,yy164_capfn,aaa_ddd_gap}.md`
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~12:40 CST Asia/Shanghai — DIG SoftCap flag／encode 同构钉死；Isol-scap0 SoftCap=0 证伪

### 0) 闸
- tip HEAD `fd99fd5b6`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-scap0 sha12 **`a147a2410f84`**（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆：遵守

### 1) DIG 钉死（本拍）
1. **emit_expr SoftCap flag** Isol `@1cf074`／LIVE `@464cb`：**同构**；flag 本身不写 call-mk。SoftCap≠0→twin(0x30\|0x31)；SoftCap=0→alt `@272bde`。
2. **CALL post-Capless encode** Isol `@1e20b1`／LIVE `@59ad9`：**同构**；仅 type==`0xa` 且 SoftCap／Capless 成功后调用。SoftCap twin `cmp [rbp-4],0x10`：**>16** 路径 SoftCap 后 **`mov eax,0; ret`**，**不**进 encode。
3. **LIVE call-mk 权威**：SoftCap twin kind==`0x31` → LIVE SoftCap `@289dcb`；Isol 同槽 SoftMega `@57ef78`→SoftCap-full（YY155 无 CALL／CE／h_emit）。
4. Capless 非 SoftCap CallExpr call-mk 权威（AAA／DDD／LIVE Capless 无 kind=0x30）仍持。

### 2) Win SoftCap 门（cave `out_scap0`）
| Isol | sha12 | plant | lit emit | n868／n878 | run |
|---|---|---|---|---|---|
| scap0 | `a147a2410f84` | SoftCap flag `@1cf0a8` jne→nop → SoftCap=0 alt | `5b173cef1205`＝TT | **0／0** | **exit 1** |

- fwd／local 同形 emit＝TT；`n1b8=1` thin；`ba0a=0`
- ⇒ SoftCap=0 alt **亦不**装 SoftCap lit call-mk

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-scap0 `p_ret_*` | 编译绿／**exit 1**；帧 thin；emit＝TT |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft `./compiler/xlang` sha12 `0c0a41335a35` | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937` | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. SoftCap CallExpr：sret `lea→rcx` 后缺 imm→rdx＋`call mk` → exit 1；帧 thin≠`0x868`/`0x878`。
2. SoftCap flag／encode／SoftCap=0／Capless CapFN／SoftMega plants **均** emit＝TT。
3. Isol SoftCap twin kind==0x31 → SoftMega ≠ LIVE SoftCap `@289dcb`；LIVE SoftCap 整树／mega **禁**。

### 5) 下一拍最小刀（单点；禁字母堆）
1. SoftCap twin `cmp [rbp-4],0x10`：试 `callsz_le`（强制 ≤0x10 路径＝SoftCap＋post helpers）或 >16 成功后落入 ≤0x10 helper 链（禁 early `mov eax,0; ret`）—— DIG helpers 是否写 call-mk。
2. 或 SoftCap-full early success 后注入 Isol 内真实 imm→rdx＋E8 helper（先证 Isol 有该 helper；禁 LIVE SoftCap 移植）。
3. 通后再验帧 `0x868`/`0x878`＋Darwin Cap soft＋Ubuntu tip-cold。未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-scap0 `a147a2410f84`＋`_dig/build_isol_scap0.py`；笔记 `dig_scap0_flag_encode.md`（续 `dig_earlyout_aaa_ddd_gap.md`）
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~12:45 CST Asia/Shanghai — DIG SoftCap twin callsz_le；≤16 helper 链证伪

### 0) 闸
- tip HEAD `50e9001d2`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-callsz_le sha12 **`96b155a04a14`**（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆：遵守

### 1) DIG 钉死（本拍）
1. SoftCap twin size gate Isol `@1d9b91`／LIVE `@50786`：**同构** `cmp [rbp-4],0x10; jle +0x126`。
2. ≤16 → SoftCap/SoftMega + Capless + post helpers Isol `@521f10`/`@521d78`/`@524944`/`@1cd1e5`（LIVE SoftCap `@289dcb` + isomorphic helpers）。
3. >16 → SoftCap/SoftMega + Capless + early `mov eax,0`（无 ≤16 helper 尾）。
4. LIVE call-mk 在 SoftCap `@289dcb` 内写出（两路径皆调 SoftCap）；Isol 同槽 SoftMega `@57ef78` **不**写 imm→rdx＋E8。
5. 强制 ≤16 仍先调 SoftMega，再跑 helper —— helper **无** `ba0a`／call-mk 进用户 emit。

### 2) Win SoftCap 门（cave `out_callsz_le`）
| Isol | sha12 | plant | lit emit | n868／n878 | run |
|---|---|---|---|---|---|
| callsz_le | `96b155a04a14` | jle@1d9b95→jmp ≤16 @1d9cc1 | `5b173cef1205`＝TT | **0／0** | **exit 1** |

- fwd／local 同形 emit＝TT；`n1b8=1` thin；`ba0a=0`
- ⇒ SoftCap twin ≤16 helper 链 **亦不**装 SoftCap lit call-mk

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-callsz_le `p_ret_*` | 编译绿／**exit 1**；帧 thin；emit＝TT |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft `./compiler/xlang` sha12 `0c0a41335a35` | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937` | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. SoftCap CallExpr：sret `lea→rcx` 后缺 imm→rdx＋`call mk` → exit 1；帧 thin≠`0x868`/`0x878`。
2. SoftCap flag／encode／SoftCap=0／Capless CapFN／SoftMega／**callsz_le ≤16 helpers** plants **均** emit＝TT。
3. Isol SoftCap twin kind==0x31 → SoftMega ≠ LIVE SoftCap `@289dcb`；LIVE SoftCap 整树／mega **禁**。

### 5) 下一拍最小刀（单点；禁字母堆）
1. DIG Isol 内是否已有真实 imm→rdx＋E8 emit helper（禁 LIVE SoftCap 移植）；SoftMega／SoftCap-full 成功后单点 call 该 helper，或 >16 early `mov eax,0` 改落入该 helper。
2. 或 glue leftover `call_ret_sz>16` sret 路径后补：在 Isol emit_expr 返回成功处单点补 call-mk（先证 Isol 有该编码 helper）。
3. 通后再验帧 `0x868`/`0x878`＋Darwin Cap soft＋Ubuntu tip-cold。未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-callsz_le `96b155a04a14`＋`_dig/build_isol_callsz_le.py`；笔记 `dig_callsz_le.md`（续 `dig_scap0_flag_encode.md`）
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

## 2026-10-30 ~13:10 CST Asia/Shanghai — DIG SoftMega smega_le；ARM egg／≤16 SoftCap-full 证伪

### 0) 闸
- tip HEAD `c12201522`＝origin/dev（本拍前；commit 后见 tip）
- Isol-TT `1f836615e0fc`；LIVE lit emit `dbaab1c7ce70`；TT lit emit `5b173cef1205`
- Isol-smega_le sha12 **`984e58dc6677`**（语义短名；禁字母堆）
- PROD SoftCap `7a2cf5da581a` **未动**／钉盘 ecdb5cc1e **不升**
- 禁 CloudAgent／10.74／HARD BAN／mega／整树／假绿／未绿请批／LEGACY／cave 字母堆／LIVE SoftCap 整树移植：遵守

### 1) DIG 钉死（本拍）
1. **真实 USER 缺口**（非 ba0a）：LIVE `mov eax,0xa; spill; mov rdx,rax; call mk`＋帧 `0x868`/`0x878`；Isol-TT `lea→rcx` 后直字段读＋帧 thin `0x1b8`。
2. SoftMega body `@59b170`：early SoftCap-full `@59b4e0`／`@59b911`；size gate `@59b608` `je@59b617→@59b85d`（≤16）；>16 → **Isol-only** ARM egg `@59b6a9→@57426c`（LIVE egg const **0**）。
3. SoftCap-full 调 Isol `@1fff*` ≅ LIVE SoftCap `@77cbe` 族，仍 **无** lit CallExpr call-mk；LIVE SoftCap 独有 callee（`@2818c1` 等）Isol **无** body。
4. callsz_le 证伪 twin helpers；本拍证伪 SoftMega 内 ≤16（跳过 ARM egg）—— emit 仍＝TT ⇒ SoftCap CallExpr 已走 SoftCap-full，非 ARM egg。

### 2) Win SoftCap 门（cave `out_smega_le`）
| Isol | sha12 | plant | lit emit | n868／n878 | run |
|---|---|---|---|---|---|
| smega_le | `984e58dc6677` | SoftMega je@59b617→jmp ≤16 @59b85d | `5b173cef1205`＝TT | **0／0** | **exit 1** |

- fwd／local 同形；`n1b8=1` thin；`b80a=1`（仅 if 比较，非 call-arg）

### 3) 三端门
| 端 | 结果 |
|---|---|
| Win SoftCap Isol-smega_le `p_ret_*` | 编译绿／**exit 1**；帧 thin；emit＝TT |
| Win PROD SoftCap `7a2cf5da581a` | **未动** |
| Darwin tip Cap soft `./compiler/xlang` sha12 `0c0a41335a35` | p_ret_lit/fwd/local **r=0** ✅ |
| Ubuntu tip `compiler/bootstrap_xlangc` sha12 `ea9ddf4eb937` | p_ret_* **r=0** ✅；tip-cold pure-ld 既有断链另记 |

### 4) 硬 blocker（勿收刀／勿升 PROD／勿请批）
1. SoftCap CallExpr：sret `lea→rcx` 后缺 imm→rdx＋`call mk` → exit 1；帧 thin≠`0x868`/`0x878`。
2. SoftCap flag／encode／scap0／Capless CapFN／callsz_le／**smega_le** plants **均** emit＝TT。
3. Isol SoftMega≠LIVE SoftCap `@289dcb`；LIVE SoftCap 整树／mega **禁**。

### 5) 下一拍最小刀（单点；禁字母堆／禁移植）
1. DIG Isol 内真实写出 `mov eax,imm`＋`mov rdx,rax`＋E8 的 helper（CE／Capless CALL encode／仍链上的 `emit_call_*`）；SoftCap-full 或 glue >16 sret 成功后 **单点 call** 该 helper。
2. 通后再验帧 `0x868`/`0x878`＋Darwin Cap soft＋Ubuntu tip-cold。未运行绿 → **勿收刀／勿升 PROD／勿请批**。

### 6) open
- Isol-smega_le `984e58dc6677`＋`_dig/build_isol_smega_le.py`；笔记 `dig_smega_le.md`（续 `dig_callsz_le.md`）
- PROD SoftCap `7a2cf5da581a`／钉盘 ecdb5cc1e **未动**
- bans unchanged

