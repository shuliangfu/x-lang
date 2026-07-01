# Debug Session: relink-strict-glue-hang
- **Status**: [OPEN]
- **Issue**: `./compiler/scripts/relink_shux_asm_strict_glue.sh` 运行卡住/反复失败，无法定位停点（需要最小侵入的运行时证据）
- **Debug Server**: (pending)
- **Log File**: .dbg/trae-debug-log-relink-strict-glue-hang.ndjson

## Reproduction Steps
1. `cd /home/shu/shux/compiler`
2. `./scripts/relink_shux_asm_strict_glue.sh`

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | 卡在脚本内部某个子命令（例如生成 companion objs / 某个 cc -c）导致“看起来像卡死” | High | Low | Pending |
| B | 卡在最终 link（ld/collect2）阶段，属于链接器耗时或等待输入/资源 | Med | Low | Pending |
| C | 卡在某个 make 子过程/依赖生成（脚本间接调用 make） | Med | Low | Pending |
| D | 其实不是卡死，是持续输出被吞了（stderr 重定向/tee），需要把 stop point 用事件链还原 | Med | Low | Pending |
| E | 某一步进入了死循环（脚本逻辑/循环），需要用“步进事件 + 耗时”证明 | Low | Low | Pending |

## Log Evidence
(pending)

## Verification Conclusion
(pending)
