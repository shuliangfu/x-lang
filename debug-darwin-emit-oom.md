# Debug Session: darwin-emit-oom
- **Status**: [OPEN]
- **Issue**: macOS 上运行 `asm_seed_full.x -E` 时资源异常膨胀，导致系统卡死/重启
- **Debug Server**: pending
- **Log File**: .dbg/trae-debug-log-darwin-emit-oom.ndjson

## Reproduction Steps
1. 在 macOS 上触发 `asm_seed_full.x -E` 路径
2. 实时监听目标进程的 RSS / CPU / 子进程状态
3. 若 RSS 超过安全阈值，立即终止并保存证据

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | `asm_seed_full.x -E` 错误走 transitive closure，导致依赖图重复展开 | High | Med | Pending |
| B | dep prerun 对每个依赖重复分配大对象，形成平方级资源放大 | High | Med | Pending |
| C | large-stack pthread 默认栈保留过大并被高频创建，放大内存占用 | High | Low | Pending |
| D | 某个特定依赖在 `load/typeck` 阶段不收敛，出现异常重入 | Med | Med | Pending |

## Log Evidence
- `build-seed-watch.err`
- `0s: rss=6 MiB, out=0 bytes`
- `2s: rss=690 MiB, out=0 bytes`
- `rss limit hit (706656 KiB >= 262144 KiB), terminate and fallback`
- `asm_seed_full.x -E 失败，沿用已有 build_asm/seed_host/asm_backend_partial.o`
- `shux-x` 旧行为日志仍出现 `collect parse dep=...` / `dep prerun begin ...`，说明它会展开 transitive closure
- 以新源码重建的 `shux-c` 运行同一路径时不再出现 closure 展开日志，但当前直接解析 `asm_seed_full.x` 会在 `#[cfg]` 处失败

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | `asm_seed_full.x -E` 错误走 transitive closure，导致依赖图重复展开 | High | Med | Confirmed on old `shux-x` |
| B | dep prerun 对每个依赖重复分配大对象，形成平方级资源放大 | High | Med | Supported by closure + dep prerun logs |
| C | large-stack pthread 默认栈保留过大并被高频创建，放大内存占用 | High | Low | Confirmed in source; default fixed from 512MiB to 256MiB |
| D | 某个特定依赖在 `load/typeck` 阶段不收敛，出现异常重入 | Med | Med | Not yet isolated; closure explosion is already sufficient cause |

## Verification Conclusion
- 已确认这不是机器性能问题，而是 `asm_seed_full.x -E` 路径的资源放大 bug。
- 已加入两类修复：
  1. 源码侧：`asm_seed_full.x` 纳入 direct-import-only；large-stack 默认值修正为 256MiB。
  2. 脚本侧：`build_seed_asm_host.sh` 内建 RSS watchdog，Darwin 默认可限制高风险 `-E` 进程的 RSS，并在超限后自动 kill + fallback。
- 当前仍有一个独立问题：`shux-x` 重新构建受 `_pipeline_typeck_after_parse_ok` 缺口阻塞，导致新源码尚未完全体现在 `shux-x` 二进制上。

## Parser Runaway Follow-up
- `sample` 与源码映射已收敛到 `parser_asm_parse_if_stmt_into_slice_c`、`parser_asm_parse_primary_into_slice_c`、`parser_asm_primary_ident_suffix_loop_c`。
- 二进制反汇编已确认 `PARSER_ASM_STRETCH_AUDIT_CALL(...)` 在当前 `shux-x` 中未实际执行，`SHUX_PARSER_STRETCH_AUDIT` 不是运行时 runaway 根因。
- 新怀疑点改为 `parser_asm_parse_if_stmt_into_slice.c` 的 `lex_out` 对齐：
  - 旧逻辑仅基于可能被污染的 `lex_cur` 做 `parser_asm_realign_lex_after_if_arm_c(...)`；
  - 若误回扫到当前 `if`，外层 block/onefunc 可重复解析同一条 `if`，持续分配 AST 节点直到 RSS 失控。
- 已实施最小修复：`parse_if_stmt_into_slice_c` 结束时优先调用 `parser_asm_scan_sync_after_if_stmt_c(lex_at_if, source)`，从当前 `if` 起点重扫整句 `if/else` 后的位置；仅当扫描失败时才回退到旧 realign 路径。
- 当前验证状态：
  - `make parser_asm_thin_glue.o` 已成功，说明该修复可被 thin parser 对象编译接受；
  - 已继续修复 `shux-x` 在 Darwin 上错误复用未过滤 `pipeline_x.o` / `USER_ASM_LINK` 的链接输入，现已改为复用现成 filtered 对象；
  - `make shux-x` 已成功，带 parser 修复的新二进制已重链完成。

## Latest Runtime Evidence
- 新 `shux-x` 在 watchdog 下复跑：
  - `python3 ../.dbg/watch_shuxx_emit.py ./shux-x ... -E src/asm/asm_seed_full.x`
  - 结果仍为 `rc=-15 limit_hit=1 peak_kb≈3.2GiB out=0 err=0`，说明 `if lex_out` 修复不是主根因。
- 新 sample 栈与旧证据一致，热点仍集中在：
  - `parser_asm_parse_if_stmt_into_slice_c`
  - `parser_asm_parse_cond_expr_into_slice_c`
  - `parser_asm_parse_primary_into_slice_c`
  - `parser_asm_primary_ident_suffix_loop_c`
- 进一步对照 C parser 后发现一个明确差异：
  - C parser 在 `base[index]` 路径上会先消费 `'['`，再从 bracket 内部起点解析 `index`；
  - asm slice 之前直接从 `'['` 自身起点递归 `parse_expr_into(...)`。
- 已实施第二个最小修复：
  - 在 `parser_asm_primary_ident_suffix_loop_c` 的 `TOKEN_LBRACKET` 分支中，改为 `*lex = r->next_lex` 后再解析索引表达式。
- 验证结果：
  - 新二进制已重编成功；
  - 但同一 watchdog 复跑后仍然 `limit_hit=1`，RSS 仍上涨到约 `3.1GiB`。
- 为排除“原地不前进”的假设，又在 `parser_asm_primary_ident_suffix_loop_c` 中加入 stall instrumentation：
  - 若同一 `lex.pos + token kind` 连续重复超限则打印坐标并失败退出；
  - 该 instrumentation 在复现中未触发，说明当前更像是“持续前进但沿错误递归路径无限展开”，而非同一 token 原地死循环。
