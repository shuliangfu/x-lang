# STD-111：std.sync 调试模式锁诊断 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-sync-lock-diag.tsv`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-sync-lock-diag.tsv` |
| 3 | `./tests/run-std-sync-lock-diag-gate.sh` |

---

## 2. 诊断语义

调试模式**默认关闭**；开启后 `mutex_lock` / `mutex_try_lock` / `mutex_unlock` 附加检查：

| API | 说明 |
|-----|------|
| `lock_diag_set_enabled` | 开启/关闭诊断 |
| `lock_diag_is_enabled` | 查询开关 |
| `lock_diag_mutex_set_id` | 为 mutex 绑定锁序 id（越小越先获取；0=跳过锁序检查） |
| `lock_diag_last_err` | 最近错误：`-1` 递归、`-2` 锁序、`-3` unlock 顺序、`-4` 表满 |
| `lock_diag_clear` | 清空元数据与线程持有栈 |
| `lock_diag_snapshot` | 文本快照（enabled/held/acquires/contentions/last_err） |
| `lock_diag_smoke` | 内置 C 烟测（`sync_lock_diag_smoke_c`） |

**锁序规则**：同线程已持有 id 为 `A` 的锁时，再获取 id `B` 须满足 `B > A`，否则拒绝加锁并返回 `-1`（避免 AB-BA 潜在死锁）。

关闭诊断后，mutex 行为与 STD-045 一致（零开销快路径）。

---

## 3. 烟测场景

1. id=1/2 顺序 lock → OK  
2. 先 lock id=2 再 lock id=1 → `lock_diag_err_order`  
3. 同 mutex 二次 lock → `lock_diag_err_recursive`  
4. 关闭诊断后正常 lock/unlock  

---

## 4. 验证与门禁

```bash
make -C compiler ../std/sync/sync.o
./tests/run-std-sync-lock-diag-gate.sh
```
