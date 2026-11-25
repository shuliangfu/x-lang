# Win tip L2 hello XP008 slice generic return（刀 11.63）· **CLOSE ACCEPT**

> Gate：`tests/run-win-tip-l2-hello-xp008-slice-generic-return-gate.sh`。
> Beat：`win_tip_l2_hello_xp008_slice_generic_return`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56／11.59–**11.62** 绿族勿 regress。
> tip PE **`6772521c…`**（pre `867330ba…`）。

## DIG

- tip：`[4]i32`／`i32[4]` OK；`T[]`／`T[]<Named>`／`u8[]<io_read_ptr>` **parse skip**；Soft Cap Prefer `u8[]<R>` parse 到 typeck。
- 真根＝`__stale_parser_asm_parse_postfix_slice_x_into_c`＠`0x1405c7b08` Prefer peel **e9→`pipeline_type_init_slice_c`**（错 arity／语义；仅 8 字节 thunk）。live tip `postfix_array`＠`0x1405c7b10` 在 `T[]` 臂 e8→此误线；`T[N]` 不走 slice → 绿。
- Soft Cap Prefer 有 live `parser_asm_parse_postfix_slice_x_into_c`＠`0x1403bbc88`；tip 无 live body；**禁 Soft Cap 字节混 tip**。
- `.text` 尾洞耗尽（PLACE5 后仅 0x50）→ 本刀新 PE RX 节 `.c63slc`＠VA `0xa259000`／PLACE `0x14a259000`。

## 修

- tip-local C twin `compiler/seeds/win_tip_pe_overrides/stale_postfix_slice_x_into_override.c`（host-gcc `-O2`，`.text` 0x1f0）。
- inject `compiler/scripts/win_tip_pe_inject_postfix_slice_override.py`：追加 `.c63slc`（CODE|EXECUTE|READ）；stub＠`0x1405c7b08`→live；`--nm-exe` bak_pre_1155。
- gate 夹具：`let out: u8[]<io_read_ptr>; return out;`（`return 0` 仅 typeck 错，非 parse 靶）。
- 无 Soft Cap G05；未动 consume／primary_array／allow／named／IF／vlet。

## 验收

- gate63 OK：slice generic return＋`*IoBatchBuf`＋array-let。
- 隔离：`postfix_slice_bare`／`slice_param`／`u8[]<Named>` parse→typeck；`postfix_arr4`／`prefix_arr4`／`ptr_user` OK。
- 11.59–11.62／vlet／IF／named／parse-skip gates OK。
- hello／backend：pre XP008＠`io_read_ptr_slice`≈**7561** **清**；post hello XP008 迁 `std.context` parse skip＠≈1973／2059（name=background 归位）→移交 **11.64**。
- backend：过 `io_read_ptr_slice`；现 typeck＠`io_read_batch_buf`（bufs 旁注族）。

## Residual（移交 11.64）

- hello XP008＠`std.context` parse skip≈byte **1973**／**2059**（name=background 归位；dep prerun）。
- 旁注：win32／backend tip typeck `bufs.ptr`／batch_buf T001／XT001（parse 已绿）。
- L2 1/5＠`58e34910f`；P012 本刀未新开；PE `6772521c…`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48–11.62；CloudAgent；CheckSubscriptionUsage；假绿。
