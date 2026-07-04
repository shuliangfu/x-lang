# std.context — 取消、超时与 deadline 传播

> **设计文档**：`analysis/std-context-v1.md`  
> **门禁**：`./tests/run-std-context-gate.sh`

- `background` / `with_cancel` / `with_deadline` / `with_timeout`
- `cancel` / `is_cancelled`（原子、可重复查询）
- `deadline_ns` / `remaining_ns`
- 轻量键值 bag：`set_value` / `get_value`
- `free` — 释放派生上下文
- 烟测：`tests/std-context/cancel_smoke.x`
