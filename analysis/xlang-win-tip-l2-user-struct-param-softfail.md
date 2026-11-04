# Win tip L2 user-struct param soft-fail → P012（刀 11.58）

> Gate：`tests/run-win-tip-l2-user-struct-param-softfail-gate.sh`。
> Beat：`win_tip_l2_user_struct_param_softfail`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族＋11.57 DIG 勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。
> tip PE 产品 **`cf0d6200…`**（本刀未改 PE）。

## 从 11.57 继承

- IF／WH／match10／paren／ident OK；`check core/fmt` tip EXIT0。
- hello 仍 P012／XP008；真位点钉 **`Context` 值参** soft-fail → body let top_level → P012（SC OK）。
- mirror_p2 类 **exit0＋.o=0**＝假绿陷阱。

## DIG（本刀钉死）

| probe | tip（`xlang_asm.exe`） | Soft Cap Prefer（只读；`…09fe181dbd0e.exe`） |
|-------|------------------------|-----------------------------------------------|
| `param_ctx` Context 值参×2 + body let | **P012**＠第二 `_rc`；osz=0 | **OK** osz=252 |
| `param_ctx_one`／`nolet` | **CG002** code_len=0 | **OK** |
| `param_S` 同形用户 struct 值参 | **P012** | **OK** |
| `param_i64` 标量值参 | OK | OK |
| `param_ctx_ptr` `*Context` | P012 | **P012**（非 tip-unique） |
| IF_min／match10 | OK 非空 | IF OK；match10 SC CG002 |

根因（相对「仅 Context 名」）：

1. tip **`parser_asm_parse_named_type_ref_c`** → 直调 **`__stale_parser_asm_parse_named_type_x_into_c`＠`0x1405ca248`**。
2. tip 该 stale＝**空心体**（`push %rbp`…；**非** `e9` trampoline）；**无** live `parser_asm_parse_named_type_x_into_c` 符号（nm＠bak_pre_1155／当前 tip 字节同形）。
3. Soft Cap Prefer：同名 stale＝**`e9` → live** `parser_asm_parse_named_type_x_into_c`＠`0x140652d78`（stack `0x628` 大体）→ 值参 OK。
4. tip≠SC；用户 struct **值参** soft-fail → fail-leave → body let 顶层泄漏 → P012／单 fn CG002。
5. **无 tip-local live 靶**可做 11.55／11.56 级 5–8B jmp stub；移植 Soft Cap named_type 体＝**Soft Cap 混 tip（禁）**；假成功 stub＝假绿。

## 产品修

- **无** tip PE 产品修（缺 tip-local live named_type_x；禁 Soft Cap 字节／假绿）。
- PE 仍 **`cf0d6200f15f962a4a5e039bbc17a5be`**。

## 正式 CLOSE residual HOLD

| 项 | 结果 |
|----|------|
| 11.56 IF／match10 | **不 regress**（非空 .o） |
| param_ctx／param_S／hello | 仍 P012／CG002／XP008 |
| tip-only PE patch | **未做** |
| L2 | 未重跑；基线 **1/5**＠`58e34910f` |
| Soft Cap G05 | **无** |

**Verdict：CLOSE residual HOLD** — 移交 **11.59** `win_tip_l2_named_type_x_live_missing`（tip 缺 live `parse_named_type_x_into_c`；禁 SC 混 tip）。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56／11.57；CloudAgent；CheckSubscriptionUsage；杀另账号 xlang(check)；`_dig` 入 git；exit0 空 .o 假绿。
