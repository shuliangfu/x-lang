# run-all L5：seed / shux_asm / shux-c 白名单矩阵

`tests/run-all.sh` 在 `SHUX_RUN_ALL_BOOTSTRAP_SHUX` 或 `SHUX_BSTRICT_RUN_ALL` 下，**白名单内**脚本用 `SHU`（seed 或 `shux_asm`），其余仍用 `shux-c`。

**L5 真 parity（2026-05-27）**：不设上述 env，全脚本均用 seed：

```bash
CI=1 SHUX=./compiler/shux SHUX_LINK_SHUX=./compiler/shux ./tests/run-all.sh   # all tests OK (~87s)
```

验收：本地 `SHUX=./compiler/shux_asm SHUX_SKIP_SUBSCRIPT_MAKE=1 SHUX_SKIP_PARSE_SMOKE=1 ./tests/<script>.sh`。

| 脚本 | seed | shux_asm | shux-c | 白名单（run-all） | 备注 |
|------|:----:|:-------:|:-----:|:-----------------:|------|
| run-lexer.sh | ✅ | ✅ | — | ✅ | typeck 子集 |
| run-typeck.sh | ✅ | ✅ | — | ✅ | |
| run-check.sh | ✅ | ✅ | — | ✅ | |
| run-hello.sh | ✅ | ✅ | — | ✅ | import("std.io") |
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
| run-dual-chain-struct-return.sh | ✅ | ✅ | — | ✅ | struct/packed/return 双链 seed + shux_asm |
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
| run-asm-binop-var.sh | ✅ | ✅ | — | ✅ | 7.3：VAR+VAR binop 直 ldr（无 push/pop） |
| run-asm-binop-block-var.sh | ✅ | ✅ | — | ✅ | 7.3：块内 VAR cache + return 四～七元链 x10/x11/x12 spill |
| run-asm-binop-cfg-merge.sh | ✅ | ✅ | — | ✅ | 7.3：live ∪ + if/loop 最小 φ + break/continue；ldur b |
| run-asm-binop-field-index.sh | ✅ | ✅ | — | ✅ | 7.3：FIELD/INDEX+VAR binop 直 ldr（无 push/pop） |
| run-asm-binop-nested-var.sh | ✅ | ✅ | — | ✅ | 7.3：嵌套 VAR 返回链免 x2 暂存 rax |
| run-asm-binop-index-lit.sh | ✅ | ✅ | — | ✅ | 7.3：字面量下标 INDEX binop 免 x2 暂存 rbx |
| run-asm-index-var.sh | ✅ | ✅ | — | ✅ | 7.3：VAR+VAR INDEX 直 lea/ldr（无 push/pop） |
| run-asm-vector-var.sh | ✅ | ✅ | — | ✅ | 7.3：VAR+VAR 向量 lane binop 直 ldr |
| run-asm-assign-var.sh | ✅ | ✅ | — | ✅ | 7.3：字段/INDEX 赋值免 push 保存左值址 |
| run-asm-assign-index-binop.sh | ✅ | ✅ | — | ✅ | 7.3：arr[i]=binop 右值先 emit，INDEX 址→rbx |
| run-asm-assign-index-lit.sh | ✅ | ✅ | — | ✅ | 7.3：arr[lit]=value 字面量下标免 x2 暂存 |
| run-asm-assign-index-lit-to-index.sh | ✅ | ✅ | — | ✅ | 7.3：arr[lit]=arr[lit] 双字面量 INDEX 赋值 |
| run-asm-assign-index-var.sh | ✅ | ✅ | — | ✅ | 7.3：arr[i]=arr[j] / arr[lit]=arr[j] 变量下标免 x2 |
| run-asm-assign-index-expr.sh | ✅ | ✅ | — | ✅ | 7.3：INDEX 单层±/MUL + 嵌套 add/mul 链 assign+read |
| run-asm-assign-index-block.sh | ✅ | ✅ | — | ✅ | 7.3：块内 INDEX assign（复用/失效/let 读址 cache/rhs 读/seq）无 mov x2 |
| run-asm-assign-index-param.sh | ✅ | ✅ | — | ✅ | 7.3：*i32 形参 / struct 字段 p.arr[i] assign |
| run-asm-binop-div-index.sh | ✅ | ✅ | — | ✅ | 7.3：div 非交换 preserve rbx/rax；块内 INDEX assign |
| run-asm-cmp-index-binop.sh | ✅ | ✅ | — | ✅ | 7.3：cmp 左 INDEX + 右 binop 须 preserve rbx |
| run-panic.sh | ✅ | ✅ | — | ✅ | panic 路径 |
| run-result.sh | ✅ | ✅ | — | ✅ | Result 类型 |
| run-binary-expr.sh | ✅ | — | ✅ | ✅ | bool 算术→i32（2026-05-27） |
| run-csv.sh | ✅ | ✅ | ✅ | ✅ | ensure_std_c_o csv.o |

| run-io.sh | ✅ | ✅ | — | ✅ | F1：bstrict + run-all 白名单（M7 shux 下含 read_ptr 全绿） |
| run-http.sh | ✅ | ✅ | — | ✅ | F2：ensure_std_c_o http.o |
| run-tar.sh | ✅ | ✅ | — | ✅ | F2：ensure_std_c_o tar.o |
| run-json.sh | ✅ | ✅ | ✅ | ✅ | F2：ensure_std_c_o json.o |
| run-net.sh | ✅ | ✅ | — | ✅ | std.net Ipv4/Tcp/Udp batch；P0 扩 bstrict |
| run-process.sh | ✅ | ✅ | — | ✅ | std.process spawn/zerocopy；修复注释折行 parse |
| run-set.sh | ✅ | ✅ | — | ✅ | P0 扩 bstrict：std.set |
| run-queue.sh | ✅ | ✅ | — | ✅ | std.queue |
| run-vec.sh | ✅ | ✅ | — | ✅ | std.vec |
| run-heap.sh | ✅ | ✅ | — | ✅ | std.heap |
| run-fs.sh | ✅ | ✅ | — | ✅ | std.fs |
| run-path.sh | ✅ | ✅ | — | ✅ | std.path |
| run-map.sh | ✅ | ✅ | — | ✅ | std.map |
| run-error.sh | ✅ | ✅ | — | ✅ | std.error |
| run-compress.sh | ✅ | ✅ | — | ✅ | std.compress |
| run-thread.sh | ✅ | ✅ | — | ✅ | std.thread |
| run-fmt.sh | ✅ | ✅ | — | ✅ | std.fmt |
| run-debug.sh | ✅ | ✅ | — | ✅ | std.debug |
| run-io-driver.sh | ✅ | ✅ | — | ✅ | std.io.driver |
| run-multi-file-generic.sh | ✅ | ✅ | — | ✅ | 多文件 generic |
| run-fmt-std.sh | ✅ | ✅ | — | ✅ | F6：std.fmt 全量；修复 main.sx 注释折行 |
| run-ub.sh | ✅ | ✅ | — | ✅ | F6：asm 整数除/模除零 → shux_panic_(1,0) |
| run-pool-limits.sh | ✅ | ✅ | — | ✅ | F6：grow 池边界（嵌套 while / many_locals / many_funcs 等） |

**L5 本轮**：run-all 白名单 **110 项**；`run-all-bstrict.sh` **110 项**（含 `run-std` / `run-target` / `run-types-gate`）。

### asm 计算门禁（非 run-all 白名单，CI / push 前）

| 脚本 | 内容 | 接入 |
|------|------|------|
| `run-asm-73-gate.sh` | 8× binop + `run-asm-vector-var.sh` + `run-asm-call-inline.sh` | `run-bootstrap-bstrict-ci.sh`、`run-pre-push-p0.sh` |
| `run-asm-call-inline.sh` | struct mk/field/sum + `inc_while` + vec add/sub/mul/div；**11 例**；`_main` 无用户 `bl`（div 允许 panic） | 见上 |
| `run-asm-binop-cfg-merge.sh` 等 | 7.3 spill / φ / cfg 汇合 | 73-gate 子集 |

验收：`SHUX=./compiler/shux_asm ./tests/run-asm-73-gate.sh`；改 `pipeline_glue.c` / `ast_pool_bootstrap_glue.c` 后须 `touch ast_pool.c && make -C compiler relink-shux` 并 `cp shux shux_asm`。

### F6：永久 shux-c 脚本

`SHUX_BSTRICT_RUN_ALL=1` 下 **无** 永久 shux-c 脚本（`run-pool-limits.sh` 已于 2026-05 迁入 shux_asm 白名单）。

验收：`SHUX_BSTRICT_RUN_ALL=1 SHUX=./compiler/shux_asm CI=1 ./tests/run-all.sh` — 白名单全绿。

**固定命令**：

```bash
./tests/run-all-bstrict.sh
SHUX_BSTRICT_RUN_ALL=1 SHUX=./compiler/shux_asm CI=1 ./tests/run-all.sh   # 白名单走 shux_asm，非白名单 SKIP
```
