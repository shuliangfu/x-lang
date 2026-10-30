# DIG SoftCap lit arg container `@2a62c9` len=0 (`arglen` / `fill_args`)

**2026-10-30 ~17:05 CST Asia/Shanghai** · tip `8d282da2f` · Isol alt_frame2 `9378df517f96` · `base_828` sha12 `0977d6fbb472` · lit sha `61afec45d7ff` · PROD SoftCap `7a2cf5da581a` **未动** · 钉盘 ecdb5cc1e **不升**

Ban tip@121278 / join / epi / LIVE SoftCap 移植 / mega / arg-loop.

## 0) Gate
- `base_828` lit OK n868=2 sha `61afec45d7ff` run exit1（偶发 AV；plant 宿主仍可 OK）
- USER: call-mk **在**；**无** true imm→rdx

## 1) DIG — 谁写／清 len；为何空

### 1.1 `@2a62c9` = container len(rcx)
- null rcx → eax=0；否则 `@215c68` 读 len（可经 `@2a5410`/`@2a52c7`/`@2a4750` 校正）
- `@2a5ca8` = get-elem(rcx, edx=idx)；越界／空 → null

### 1.2 pre_last 消费点（已钉）
| site | role |
|---|---|
| `@567a5c`/`@567a60` | `[rbp-0x30] ← [rbp+0x30]`＝**arg5**（唯一 STORE 到 local 容器） |
| `@56885c`..`@568870` | null 检 `[rbp-0x30]` |
| `@56888d` call `@2a62c9` | **HIT**；len → `[rbp-0x178]` |
| `@5688b7` je idx≥len | **HIT 跳过** |
| `@5688d2` `@2a5ca8` | **miss** |

⇒ SoftCap lit **容器非必 null，但 len=0** → 无 arg0 元素 → 无 imm→rdx 源。

### 1.3 Capless 供给：`[rbp+0x478]` → pre_last arg5
Caller `@578200`：`mov rcx,[rbp+0x478]` → `[rsp+0x20]`＝arg5 → pre_last `[rbp+0x30]`。

**谁写 `+0x478`（Capless 内仅此）：**
| site | what |
|---|---|
| `@57662c` call `@55d730`(arena=`[rbp+0x4a8]`, **edx=0x568**) | **新分配**空对象 |
| `@576631` STORE `[rbp+0x478],rax` | **HIT** |
| `@576642`/`@576647` | null 时 fallback `@24afe0` 再 STORE |

**谁清／填 len：** Capless `@57664e`..`@578200` **无** call `@2a62c9`／`@2a5ca8`／`@215c68`／`@215bd0`／`@2a4750`。  
⇒ **不是「写了又清」**；是 **只 alloc 空壳、从不 push CallExpr args**。`@201f36` 是 name/emit 旁路，**不**写 `+0x478` 元素。

### 1.4 根因（结论）
SoftCap lit CallExpr：Capless 用 `@55d730(0x568)` 造空容器进 `+0x478` → pre_last `@2a62c9` **len=0** → 跳过 get-elem → 缺 imm→rdx。  
要 len≥1：须在 pre_last 前把 **真实 CallExpr args 向量** 填进／换成 `+0x478`（或等价 push 元素），禁空壳上强制 je。

## 2) Plants（红）
| plant | patch | lit | USER |
|---|---|---|---|
| `arglen_force1` | call`@56888d`→`mov eax,1` | OK sha＝base | 保 call-mk；无 mov rdx；exit1 |
| `fill_args_tok0` | nop je`@568273` | OK sha＝base | 同上 |
| `fill478_nop_576640` | nop jne fallback | OK sha＝base | 同上 |
| `fill_nop_576b82` | nop jne`@576b82` | OK sha＝base | 同上 |
| `fill_args_ast20` | `+0x478←[node+0x20]` 替 alloc | **AV** | — |
| `fill_args_ast28` | `+0x478←[node+0x28]` | OK sha＝base | 保 call-mk；无 mov rdx；exit1 |
| `fill_args_ast18` | `+0x478←[node+0x18]` | **AV** | — |

⇒ 红。强制假 len／盲猜 AST offs **不可**变 USER；须钉 **真 args 字段／push 点**。

## 3) Next single-point
Under `base_828`：钉 SoftCap lit CallExpr **AST args 向量**（node=`[rbp+0x490]` 何字段 len≥1 经 `@2a62c9`）或 Capless 缺失的 **push-into-`+0x478`**；单点 plant 使 len≥1→`@2a5ca8`＋保 call-mk（禁 tip@121278／join／epi／LIVE／mega／arg-loop）。

## 4) Scripts
`_dig/dig_arglen_2a62.py`／`_store.py`／`_478.py`／`_fill.py`／`_plant.py`＋logs（Win cave；BUDGET≤85s）
