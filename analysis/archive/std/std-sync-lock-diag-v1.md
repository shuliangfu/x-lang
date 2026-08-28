# STD-111：std.sync 调试模式锁诊断 v1

> 状态：**定版（v1；逻辑在 sync.x，TLS 在 tls glue）**
> 关联：`tests/baseline/std-sync-lock-diag.tsv`

## 1. API

调试模式**默认关闭**；开启后 `mutex_lock` / `mutex_try_lock` / `mutex_unlock` 附加检查：

| API | 说明 |
|-----|------|
| `lock_diag_set_enabled` | 开启/关闭诊断 |
| `lock_diag_is_enabled` | 查询开关 |
| `lock_diag_mutex_set_id` | 为 mutex 绑定锁序 id（越小越先获取；0=跳过锁序检查） |
| `lock_diag_last_err` | 最近错误：`-1` 递归、`-2` 锁序、`-3` unlock 顺序、`-4` 表满 |
| `lock_diag_clear` | 清空元数据与线程持有栈 |
| `lock_diag_snapshot` | 文本快照（enabled/held/acquires/contentions/last_err） |
| `lock_diag_smoke` | 内置烟测包装（底层 `sync_lock_diag_smoke_c`） |
| `lock_diag_err_order` | 锁序错误码（`-2`） |
| `lock_diag_err_recursive` | 递归错误码（`-1`） |

**锁序规则**：同线程已持有 id 为 `A` 的锁时，再获取 id `B` 须满足 `B > A`，否则拒绝加锁并返回 `-1`（避免 AB-BA 潜在死锁）。

关闭诊断后，mutex 行为与 STD-045 一致（零开销快路径）。

## 2. 关联

- 烟测：`tests/sync/lock_diag.x`
- Manifest：`tests/baseline/std-sync-lock-diag.tsv`
- Gate：`./tests/run-std-sync-lock-diag-gate.sh`
- Lib：`tests/lib/std-sync-lock-diag.sh`

## 3. Gate

Honesty (2026-08-28 soft fallthrough residual): prefer `xlang_asm` + pin
`XLANG_LINK_XLANG`; explicit-bad `XLANG` / missing native → hard die (refuse
soft fallthrough / prefer-c / soft auto-make / soft SKIP→OK). check
observational (paused 2026-08-05). `lock_diag.x` exit 0 hard-fail (`run+=`).
Report `run=` / `obs=` / `skip=`. Refuse top-level DOC resurrect
(live = `analysis/archive/std/`).

PLATFORM: SHARED archaeology.
