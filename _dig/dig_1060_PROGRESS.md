# 10.60 PROGRESS — Win single-stmt `return` / RETURN / sret

**2026-10-29 ~21:00 CST (Asia/Shanghai)** · SoftCap Isol-KK..PP **未运行绿** → **硬 blocker 收口**；勿请批／勿升 PROD／钉 ecdb5cc1e **不升**；停开新 cave

**2026-10-29 ~20:46 CST (Asia/Shanghai)** · tip mid-step push per hard contract · SoftCap **未绿** → 勿升 PROD／钉 ecdb5cc1e **不升**／勿收刀；DIG＋tip isol-A/C 步进推 `dev`


**2026-10-29 15:40 CST (Asia/Shanghai)** · tip `a8bea2bd0` · SoftCap PROD `7a2cf5da581a` · I=`48139a4fa0b8` size 7945801 · 钉盘 ecdb5cc1e **不升** · 未绿勿 push

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
