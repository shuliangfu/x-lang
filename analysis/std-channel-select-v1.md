# STD-098/STD-102/STD-104/STD-108：std.channel select v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`tests/baseline/std-channel-select.tsv`、`tests/channel/select_*.sx`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§3 |
| 2 | `tests/baseline/std-channel-select.tsv` |
| 3 | `./tests/run-std-channel-select-gate.sh` |
| 4 | 烟测：`select_2.sx`、`select_n.sx`、`select_send_2.sx`、`select_send_n.sx`、`select_mixed_2.sx`、`select_mixed_n.sx` |

---

## 2. select 语义

### 2.1 recv 双路（STD-098）

| API | 说明 |
|-----|------|
| `channel_select_try_recv_2(ch0, ch1, out_val, out_index)` | 非阻塞；**ch0 优先**于 ch1 |
| `channel_select_recv_2(ch0, ch1, out_val, out_index)` | 阻塞直至任一路有数据 |

### 2.2 recv N 路（STD-102）

| API | 说明 |
|-----|------|
| `channel_select_chs_set(slots, idx, ch)` | 将句柄写入 `i64` 槽（64 位 LE 与 C `void**` 布局兼容） |
| `channel_select_try_recv_n(chs_slots, n, out_val, out_index)` | 非阻塞；**index 升序优先**（0 最高） |
| `channel_select_recv_n(chs_slots, n, out_val, out_index)` | 阻塞直至任一路有数据 |
| `channel_select_max()` | 最大路数 `8`（`CHANNEL_SELECT_MAX`） |

### 2.3 send 双路 / N 路（STD-104）

| API | 说明 |
|-----|------|
| `channel_select_try_send_2(ch0, ch1, val, out_index)` | 非阻塞 send；**ch0 优先** |
| `channel_select_send_2(ch0, ch1, val, out_index)` | 阻塞 send 直至任一路可写 |
| `channel_select_try_send_n(chs_slots, n, val, out_index)` | 非阻塞 N 路 send |
| `channel_select_send_n(chs_slots, n, val, out_index)` | 阻塞 N 路 send |

### 2.4 双向混合 recv+send（STD-108）

| API | 说明 |
|-----|------|
| `SELECT_DIR_RECV` / `SELECT_DIR_SEND` | 方向常量 `0` / `1` |
| `channel_select_dirs_set(dirs, idx, dir)` | 与 `chs_set` 平行的方向槽 |
| `channel_select_try_mixed_2(recv_ch, send_ch, send_val, out_val, out_is_send)` | 非阻塞；**recv 优先**于 send |
| `channel_select_mixed_2(...)` | 阻塞混合双路 |
| `channel_select_try_mixed_n(chs_slots, dirs, n, send_val, out_val, out_index, out_is_send)` | 非阻塞 N 路混合；**index 升序优先** |
| `channel_select_mixed_n(...)` | 阻塞 N 路混合 |

**返回值（try mixed）**：

| 值 | 含义 |
|----|------|
| `0` | 成功；`*out_is_send=0` 时 `*out_val` 有效，`=1` 时 send 成功 |
| `1` | 暂不可执行，且至少一个 case 仍可能 |
| `-1` | 全部 case 不可用 |

**返回值（阻塞 mixed）**：`0` 成功；`-1` 全部不可用。

**返回值（try recv / try recv_n）**：

| 值 | 含义 |
|----|------|
| `0` | 成功；`*out_index` 为选中下标 |
| `1` | 暂无数据，且至少一路 channel 仍未关闭 |
| `-1` | 皆已关闭且无缓冲数据 |

**返回值（try send / try send_n）**：

| 值 | 含义 |
|----|------|
| `0` | 成功；`*out_index` 为选中下标 |
| `1` | 皆有界满且至少一路仍未关闭 |
| `-1` | 皆已关闭 |

**返回值（阻塞 recv/send/mixed）**：`0` 成功；`-1` 皆已关闭或不可用。

---

## 3. 实现要点

- C 层：`channel_select_*_c`（`std/channel/channel.c`）
- 阻塞路径：轮询 try + `pthread_cond_timedwait`（`SELECT_TIMEDWAIT_MS = 5`），避免多 mutex 死锁
- Unix 需 `-lpthread`（与现有 channel 一致）；**Windows 为 stub**（返回 `-1`，烟测 skip）

---

## 4. 验证与门禁

```bash
make -C compiler ../std/channel/channel.o
./tests/run-std-channel-select-gate.sh
```
