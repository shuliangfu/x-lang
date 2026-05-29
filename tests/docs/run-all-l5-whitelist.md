# run-all L5：seed / shu_asm / shu-c 白名单矩阵

`tests/run-all.sh` 在 `SHULANG_RUN_ALL_BOOTSTRAP_SHU` 或 `SHULANG_BSTRICT_RUN_ALL` 下，**白名单内**脚本用 `SHU`（seed 或 `shu_asm`），其余仍用 `shu-c`。

**L5 真 parity（2026-05-27）**：不设上述 env，全脚本均用 seed：

```bash
CI=1 SHU=./compiler/shu SHULANG_LINK_SHU=./compiler/shu ./tests/run-all.sh   # all tests OK (~87s)
```

验收：本地 `SHU=./compiler/shu_asm SHULANG_SKIP_SUBSCRIPT_MAKE=1 SHU_SKIP_PARSE_SMOKE=1 ./tests/<script>.sh`。

| 脚本 | seed | shu_asm | shu-c | 白名单（run-all） | 备注 |
|------|:----:|:-------:|:-----:|:-----------------:|------|
| run-lexer.sh | ✅ | ✅ | — | ✅ | typeck 子集 |
| run-typeck.sh | ✅ | ✅ | — | ✅ | |
| run-check.sh | ✅ | ✅ | — | ✅ | |
| run-hello.sh | ✅ | ✅ | — | ✅ | import std.io |
| run-import.sh | ✅ | ✅ | — | ✅ | 偶发重试见 gate |
| run-stdlib-import.sh | ✅ | ✅ | — | ✅ | 勿在注释写 `placeholder<T>` |
| run-while.sh | ✅ | ✅ | — | ✅ | |
| run-option.sh | ✅ | ✅ | — | ✅ | core.option |
| run-compound-assign.sh | ✅ | ✅ | — | ✅ | |
| run-multi-file.sh | ✅ | ✅ | — | ✅ | |
| run-struct.sh | ✅ | ✅ | — | ✅ | struct let 后须 `;` |
| run-return-value.sh | ✅ | ✅ | — | ✅ | |
| run-return-expr.sh | ✅ | ✅ | — | ✅ | |
| run-parser.sh | ✅ | ✅ | — | ✅ | L5 新增 |
| run-for.sh | ✅ | ✅ | — | ✅ | L5 新增 |
| run-array.sh | ✅ | ✅ | — | ✅ | L5 新增 |
| run-pointer.sh | ✅ | ✅ | — | ✅ | L5 新增 |
| run-if-expr.sh | ✅ | ✅ | ✅ | ✅ | SU parse_if_expr_into + let=if 勿吞 return |
| run-enum-asm.sh | ✅ | ✅ | — | ✅ | enum 变体登记 + asm tag；minimal/simple（无 return match） |
| run-enum.sh | ✅ | ✅ | ✅ | ✅ | return match / enum tag |
| run-dual-chain-struct-return.sh | ✅ | ✅ | — | ✅ | struct/packed/return 双链 seed + shu_asm |
| run-fmt-cmd.sh | ✅ | ✅ | — | ✅ | |
| run-test-cmd.sh | ✅ | ✅ | — | ✅ | |
| run-bool.sh | ✅ | ✅ | — | ✅ | |
| run-ternary.sh | ✅ | ✅ | — | ✅ | |
| run-boundary-encodings.sh | ✅ | ✅ | — | ✅ | |
| run-multi-func.sh | ✅ | ✅ | — | ✅ | 已在白名单 |
| run-toplevel-let.sh | ✅ | ✅ | — | ✅ | |
| run-preprocess.sh | ✅ | ✅ | — | ✅ | L5 新增：-D/#if；SU parse_directive 与 C is_ws_or_eol(p[2]) 对齐 |
| run-goto.sh | ✅ | ✅ | — | ✅ | L5 新增：label: return（parser_try_label_return_expr） |
| run-let-const.sh | ✅ | ✅ | — | ✅ | |
| run-generic.sh | ✅ | ✅ | ✅ | ✅ | wrong_type_args 注释勿断行 |
| run-trait.sh | ✅ | ✅ | ✅ | ✅ | |
| run-encoding.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o encoding.o |
| run-base64.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o base64.o |
| run-time.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o time.o |
| run-sync.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o sync.o |
| run-atomic.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o atomic.o |
| run-ffi.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o ffi.o |
| run-float.sh | ✅ | ✅ | ✅ | ✅ | arm64 MOVZ/MOVK 基址 + slice ptr load |
| run-match.sh | ✅ | ✅ | ✅ | ✅ | SU `parse_match_into` 勿在 `init_match_enum` 后清零 matched_ref；match 臂 arm64 `beq` |
| run-slice.sh | ✅ | ✅ | ✅ | ✅ | `[]T` parser + INDEX 从 slice 槽 load ptr |
| run-defer.sh | ✅ | ✅ | ✅ | ✅ | SU parser 消费 `defer { }`（emit 待补） |
| run-vector.sh | ✅ | ✅ | ✅ | ✅ | i32x16：TYPE_VECTOR 解析 + 栈槽 64B + frame |
| run-panic.sh | ✅ | ✅ | — | ✅ | panic 路径 |
| run-result.sh | ✅ | ✅ | — | ✅ | Result 类型 |
| run-binary-expr.sh | ✅ | — | ✅ | ✅ | bool 算术→i32（2026-05-27） |
| run-csv.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o csv.o |

**L5 本轮**：run-all 白名单 **52 项**；`run-all-bstrict.sh` **52 项**（+run-enum、run-dual-chain-struct-return）。

**固定命令**：

```bash
./tests/run-all-bstrict.sh
SHULANG_BSTRICT_RUN_ALL=1 SHU=./compiler/shu_asm CI=1 ./tests/run-all.sh   # 白名单走 shu_asm，非白名单 SKIP
```
