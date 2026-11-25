# Win tip L2 named_type_x live missing（刀 11.59）

> Gate：`tests/run-win-tip-l2-named-type-x-live-missing-gate.sh`。
> Beat：`win_tip_l2_named_type_x_live_missing`。
> 基线：Win tip L2 **1/5**＠`58e34910f` **勿 regress**；11.48／11.55／11.56 绿族勿 regress。
> 闸位 HOLD；禁 Soft Cap G05 混 tip；禁假绿／CloudAgent／exit0 空 .o。

## CLOSE ACCEPT

- tip-local C twin：`compiler/seeds/win_tip_pe_overrides/stale_named_type_x_into_override.c`
  （自 `pthin_type_ref.x` named_type_x＋static consume_qualified；只调 tip PE 符号）。
- inject：`compiler/scripts/win_tip_pe_inject_named_type_x_override.py`
  PLACE=`0x140647800`（11.55 cave 后）、grow RawSize＋0x600（VA gap→.data）、
  `__stale_parser_asm_parse_named_type_x_into_c`＠`0x1405ca248` → `e9` live＠`0x140647830`。
- **无 Soft Cap 字节拷贝**；consume 文件内 static（tip stale consume 仍误 jmp，本刀不混改）。
- Gate OK：param_ctx `-c` 非空；IF／match10 OK；11.55／11.56 gates OK。
- 复验：param_S／param_ctx `check`＋`-c` OK（无 P012）；paren／ident／if_arm stubs 仍 `e9`。
- PE `cf0d6200…` → **`a16d6822cf868b2aac2ad07ac18bb184`**（local tip；gitignore）。
- L2 未重跑；hello 仍 XP008（std.io.backend parse skip）→ OPEN 11.60。

## Residual（移交 11.60）

- examples/hello／L2 hello：XP008 dep prerun／parse skip＠std.io.backend；非本刀 named_type 残。
- tip `__stale_parser_asm_consume_qualified_type_ident_name_into_c` 仍误 `jmp copy_slice…`（本刀 static 覆盖 named 路径）。
- param_S 字段读 `s.x` 仍 T001（值参字段；非本刀）。
- L2 1/5＠`58e34910f`。

## 非目标／禁

- Soft Cap G05 混 tip；升钉／tiphead／Soft Cap；回滚 11.48／11.55／11.56；CloudAgent；CheckSubscriptionUsage。
