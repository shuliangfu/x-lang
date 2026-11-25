# Win tip L2 hello XP008 user-struct ptr param（刀 11.62）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-user-struct-ptr-param-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_user_struct_ptr_param`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59／11.60／**11.61** 绿族勿 regress。
> tip PE **`867330ba…`**（pre `453c9b1e…`）。

## DIG

- tip：`*i32`／`*u8` OK；值参 `IoBatchBuf` OK；`*IoBatchBuf`／`*A`／ret／local `*UserStruct` **parse skip**；Soft Cap Prefer 全 OK。
- 真根＝`__stale_parser_asm_consume_qualified_type_ident_name_into_c`＠`0x1405c78c8` Prefer peel **e9→`parser_asm_copy_slice_to_name64_at_end_buf_c`**（错 arity／语义）。star_type IDENT 臂与 live `consume_qualified_c` wrapper 皆 call 此误线；builtin 臂不走 → `*i32` 绿。
- Soft Cap Prefer trampoline stale→live into；tip 无 live into；**禁 Soft Cap 字节混 tip**。named_type plant（11.59）已自带 static consume → 值参绿。

## 修

- tip-local C twin `compiler/seeds/win_tip_pe_overrides/stale_consume_qualified_into_override.c`（host-gcc `-Os`）。
- inject `compiler/scripts/win_tip_pe_inject_consume_qualified_into_override.py` PLACE5 `0x140647E10`（11.61 PLACE4 后 0x1f0 洞）；stub＠`0x1405c78c8`→live。
- 无 Soft Cap G05；未动 array-let／allow／named／IF／vlet。

## 验收

- gate62 OK：`*IoBatchBuf` 形参＋array-let＋allow1。
- 隔离：`ptr_user`／`ptr_named_alias`／ret／local ptr-user OK；`let_arr`／val_user／`*i32` OK。
- 11.59 named／11.60 parse-skip／11.61 array-let／vlet／IF／param_ctx gates OK。
- win32：原＠5774 **parse 清**；现 typeck `T001` `bufs.ptr`（`*UserStruct` 字段；SC batch_body OK／tip fail）→非本刀 parse 靶。
- hello／backend：**新残** XP008＠`std.io.backend` `io_read_ptr_slice`≈byte **7561**＝返回型 **`u8[]<io_read_ptr>`**（postfix array／generic）→移交 **11.63**。

## Residual（移交 11.63）

- hello XP008＠backend `io_read_ptr_slice`：`u8[]<io_read_ptr>` 返回 parse skip。
- 旁注：win32 tip typeck `*IoBatchBuf` 字段访问 T001（parse 已绿）。
- L2 1/5＠`58e34910f`；P012 本刀未新开；PE `867330ba…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.61；CloudAgent；CheckSubscriptionUsage；假绿。
