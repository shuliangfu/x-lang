# Win tip L2 hello／fmt P012 after IF unlock（刀 11.57）

> Gate：`tests/run-win-tip-l2-hello-p012-after-if-gate.sh`。
> Beat：`win_tip_l2_hello_p012_after_if`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent。
> tip PE 产品 **`cf0d6200…`**（11.56 realign；本刀未改 PE）。

## 从 11.56 继承

- IF_min／IF_else／IF_ret_only `check`＋`-c` 已绿（realign stub tip-only）。
- WH／paren／ident／match10／call_main／vlet OK。
- hello／`examples/hello.x` 仍 **P012**／XP008。

## DIG（本刀钉死）

| probe | tip | Soft Cap（只读对照） |
|-------|-----|----------------------|
| classic e_fmtstyle／match10／one_arr／star_u8 | OK（非空 dual 已过） | — |
| `check core/fmt/mod.x` | **EXIT0** | parse skip／fail |
| hello `check` | XP008 `std.io.backend`＠952（`#[cfg]` inactive 后 tip≈SC） | 同形 fail backend／cfg |
| hello `-o`／`-c` | **P012** hang＠hello:127＋XP008 `std.context` | P012 更早＠core.fmt |
| `std/context` `-c` | **P012** `let _rc`＠deadline_ns:127 | P012 更后＠get_value:164（仍 leak） |
| min `param_ctx`：`export function (ctx: Context)`×2 + body `let` | **P012**／单 fn **CG002** `code_len=0` | **OK** |
| `param_i64` 同形 | OK | OK |
| Context-return＋unsafe＋extern（mirror_p2） | **exit0 但 .o 0 字节（假绿陷阱）** | 非空产物 |

根因升级（相对「仅 fmt while／array」）：

1. **tip-unique**：用户 struct **值参／\*T 参** 路径 soft-fail → body `let` 未吃干净 → 当 module top_level 注册 → 第二同名 local **P012**（11.46 *T／pointee 同族续；本刀钉 **Context 值参**）。
2. tip `check core/fmt` 已绿（IF／while 解锁后）；hello 产品残移到 **std.context／std.io.backend cfg** 链。
3. Soft Cap 同形 param_ctx **OK** → tip≠SC；**禁** Soft Cap G05 混 tip。
4. `type_ref_token_starts`／`type_ref_ident_span_ok` tip≈SC 同形；**无** 11.55／11.56 级 5–8B tip-only stub 证据。
5. `primary_lbrace` 仍 stale `jmp suffix_loop`（已知）— 非本刀 Context-param nolet 充分根。

## 产品修

- **无** tip PE 产品修（证据不够／禁假绿／禁 Soft Cap 混 tip）。
- PE 仍 **`cf0d6200f15f962a4a5e039bbc17a5be`**。

## 正式 CLOSE residual HOLD

| 项 | 结果 |
|----|------|
| 11.56 IF／WH／match10／paren／ident | **不 regress**（非空 .o） |
| tip `check core/fmt` | EXIT0 |
| hello／param_ctx／std.context | 仍 P012／XP008／CG002 |
| tip-only PE patch | **未做** |
| L2 | 未重跑；基线 **1/5**＠`58e34910f` |
| Soft Cap G05 | **无** |

**Verdict：CLOSE residual HOLD** — 移交 **11.58** `win_tip_l2_user_struct_param_softfail`（用户 struct 形参 soft-fail／fail-leave→P012；拒 exit0 空 .o 假绿）。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56；CloudAgent；CheckSubscriptionUsage；杀另账号 xlang(check)；`_dig` 入 git。
