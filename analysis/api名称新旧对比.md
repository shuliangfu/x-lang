# std API 名称新旧对比

更新时间：2026-06-29

## 说明

这份文档不是简单抄录 `std/标准库api命名规范.md`，而是把四件事放在一起对照：

1. 规范表里的旧名称
2. 一轮规范简化名
3. 按这轮重新分析后的二轮目标名
4. 当前 `std/**/mod.sx` 里实际导出的名称

这样可以直接看出：

- 哪些模块已经按规范收口
- 哪些模块只是“部分简化”
- 哪些模块的当前实现已经偏离规范，需要继续优化
- 哪些一轮规范名本身还可以再压一轮
- 这轮最终准备采用的新目标名是什么

## 本轮口径

这份文档现在不再只是“分析还能不能优化”，而是直接采用二轮优化后的目标名作为新的建议命名。

也就是说：

- `一轮规范简化名`：来自 `std/标准库api命名规范.md`
- `二轮目标名`：这次重新分析后，认为更适合继续推进的名字
- `当前 std 实际名称`：仓库现在真实导出的名字

后续如果继续改源码，应该优先参考这里的 `二轮目标名`，而不是停留在一轮规范名。

## 二轮优化原则

这次在原先“旧名称 -> 规范简化名 -> 当前实际名”的基础上，再继续往下推一层。

判定一条规范简化名还能不能继续优化，主要看下面几条：

1. 模块语义是否已经足够明确  
   如果已经在 `std.db.arrow` 模块里，`column_` 这种对象前缀通常还能继续去掉。

2. 参数类型是否足够承载语义  
   如果语言已经支持重载，那么 `sum_valid_i32` 这类类型后缀通常还可以继续进参数或重载，不必留在函数名上。

3. 是否会引入构造歧义  
   像 `new_mutex` 这种名字虽然还可以想象继续压短，但如果压成 `new()` 会因为返回类型歧义或原语并存而变差，这种就不建议继续缩。

4. `Context` / `hook` / `stmt` / `column` 这类赘词是不是已经由模块或参数表达  
   如果已经表达出来，则优先考虑继续删除。

## 判定口径

| 状态 | 含义 |
| --- | --- |
| 已对齐 | 当前 `std` 实际导出名已经等于二轮目标名 |
| 部分偏移 | 有一部分 API 已按二轮目标名收口，但仍有成组残留未收口 |
| 明显偏移 | 当前实现大量保留旧前缀、类型后缀或兼容门面 |
| 二次改名 | 当前实现不是旧名，也不是二轮目标名，而是走了另一套命名 |

## 总览结论

当前 `std` 的情况不是“全部完成”，而是明显分成三层：

1. 已经基本收口到二轮目标名的模块
2. 主要功能已收口，但仍有少量旧名/兼容层残留的模块
3. 命名风格仍明显偏离二轮目标名、还需要继续优化的模块

目前最值得继续做优化的重点模块是：

- `std.string`
- `std.db.arrow`
- `std.db.sqlite`
- `std.trace`
- `std.runtime`
- `std.db`
- `std.io`

其次是仍然带较多对象前缀/类型前缀的大模块：

- `std.net`
- `std.http`
- `std.socketio`
- `std.error`

## 一、优先继续优化的模块

### 1. std.string

`std.string` 是当前最明显没有按目标命名彻底压短的模块之一，仍保留大量 `string_` / `string_view_` 前缀；但反过来看，它里面也有几条一轮规范名已经接近极限，不必为了更短而更短。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.string` | `string_new` | `new` | `new` | `string_new` | 明显偏移 | `new` 已经是较优终点，不建议再缩 |
| `std.string` | `string_len` | `len` | `len` | `string_len` | 明显偏移 | `len` 已经是较优终点 |
| `std.string` | `string_is_empty` | `is_empty` | `is_empty` | `string_is_empty` | 明显偏移 | `is_empty` 已经是较优终点 |
| `std.string` | `string_trim_space` | `trim_space` | `trim` | `string_trim_space` | 明显偏移 | 模块内可省略 `space` 语义赘词 |
| `std.string` | `string_replace_char` | `replace_char` | `replace` | `string_replace_char` | 明显偏移 | 参数类型已能表达“char” |
| `std.string` | `string_view` | `from_raw_parts` | `view` | `string_view` | 明显偏移 | 在 `string` 模块内可进一步压成 `view` |
| `std.string` | `string_view_len` | `len` | `len` | `string_view_len` | 明显偏移 | 可通过 `StringView` 重载承载 |
| `std.string` | `string_view_is_empty` | `is_empty` | `is_empty` | `string_view_is_empty` | 明显偏移 | 可通过 `StringView` 重载承载 |

结论：

- 这个模块还远远没有收口
- 后续值得单独开一轮，把 `string_*` / `string_view_*` 成批统一
- 本轮正式采用的二轮目标名，主要是 `trim_space -> trim`、`replace_char -> replace`、`from_raw_parts -> view`

### 2. std.db.arrow

`std.db.arrow` 当前主要问题不是没改，而是“改了一半”：名字比旧版短了，但没有完全按二轮目标名利用重载/统一语义名。并且这块确实像你指出的那样，`column_` 前缀在模块内大多还能继续去掉。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.db.arrow` | `column_i32_new` | `column_new` | `new` | `new_i32` | 部分偏移 | 若把类型信息移入参数，可彻底去掉 `column_` |
| `std.db.arrow` | `column_f32_new` | `column_new` | `new` | `new_f32` | 部分偏移 | 同上 |
| `std.db.arrow` | `column_f64_new` | `column_new` | `new` | `new_f64` | 部分偏移 | 同上 |
| `std.db.arrow` | `column_adopt_f32` | `column_adopt` | `adopt` | `adopt_f32` | 部分偏移 | 模块内 `column_` 可去，类型信息进重载/参数 |
| `std.db.arrow` | `column_adopt_i32` | `column_adopt` | `adopt` | `adopt_i32` | 部分偏移 | 同上 |
| `std.db.arrow` | `column_i32_data` | `column_data` | `data` | `data_i32` | 部分偏移 | 数据访问不必保留对象前缀 |
| `std.db.arrow` | `column_f32_data` | `column_data` | `data` | `data_f32` | 部分偏移 | 同上 |
| `std.db.arrow` | `column_i32_append` | `column_append` | `append` | `append` | 已部分对齐 | 这里其实已经比规范更接近最终态 |
| `std.db.arrow` | `column_i32_append_nullable` | `column_append_nullable` | `append_null` | `append_null` | 二次改名 | 当前实际名比规范更短更自然 |
| `std.db.arrow` | `column_i32_sum_valid` | `column_sum_valid` | `sum_valid` | `sum_valid_i32` | 部分偏移 | `column_` 和类型后缀都可去 |
| `std.db.arrow` | `column_f32_sum` | `column_sum` | `sum` | `sum_f32` | 部分偏移 | 模块内可直接 `sum` |
| `std.db.arrow` | `column_f32_dot` | `column_dot` | `dot` | `dot_f32` | 部分偏移 | 模块内可直接 `dot` |

结论：

- 这块已经能用，但还没到“最终纯净命名”
- 继续优化空间很大，尤其是 `column_*` 族统一
- 本轮正式采用的二轮目标名里，`column_` 这个对象前缀大部分都继续去掉
- 这块新的目标名字就是：`new/adopt/data/append/append_null/sum/sum_valid/dot`

### 3. std.db.sqlite

`std.db.sqlite` 已经做过一轮压短，但和二轮目标名相比仍有部分明显偏移；同时这里也有几处是“当前实际名已经比一轮规范名更短”的情况。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.db.sqlite` | `db_query_rows` | `rows` | `rows` | `rows` | 已对齐 | 规范名已接近终点 |
| `std.db.sqlite` | `db_query_begin` | `begin` | `begin` | `begin` | 已对齐 | 规范名已接近终点 |
| `std.db.sqlite` | `db_query_end` | `end` | `end` | `end` | 已对齐 | 规范名已接近终点 |
| `std.db.sqlite` | `db_stmt_bind_i32` | `bind` | `bind` | `bind` | 已对齐 | 已用重载收口 |
| `std.db.sqlite` | `db_stmt_bind_text` | `bind_text` | `bind` | `bind` | 二次改名 | 当前实际名比规范更优 |
| `std.db.sqlite` | `db_last_error` | `last_os_error` | `last_error` | `last_error` | 部分偏移 | `os` 赘词在模块内可去 |
| `std.db.sqlite` | `db_stmt_cache_clear` | `cache_clear` | `cache_clear` | `stmt_cache_clear` | 部分偏移 | 规范名基本合理，不建议再缩成 `clear` |
| `std.db.sqlite` | `db_pool_open` | `open` | `open` | `open` | 已对齐 | 通过重载承载 |
| `std.db.sqlite` | `db_pool_close` | `close` | `close` | `close` | 已对齐 | 通过重载承载 |
| `std.db.sqlite` | `db_pool_acquire` | `acquire` | `acquire` | `acquire` | 已对齐 | 已完成 |
| `std.db.sqlite` | `db_pool_release` | `release` | `release` | `release` | 已对齐 | 已完成 |

结论：

- 主流程 API 已经大体收口
- 还可以继续修细节名，尤其是 `stmt_cache_clear`
- 本轮正式采用的二轮目标名里，`bind_text -> bind`、`last_os_error -> last_error`

### 4. std.trace

`std.trace` 当前实现和一轮规范分歧比较大，属于“已经改过一轮，但最终命名没有按规范落下来”。而且这块很典型地说明：一轮规范名自己也还能再压一轮。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.trace` | `attach_to_context` | `attach_to_context` | `attach` | `attach` | 二次改名 | 当前实际名比规范更优 |
| `std.trace` | `from_context` | `from_context` | `from_ctx` | `from_ctx` | 二次改名 | 当前实际名比规范更短且可读 |
| `std.trace` | `hook_io_read_ctx` | `io_read_ctx` | `io_read` | `hook_io_read` | 二次改名 | `hook_` 与 `ctx` 都还能继续去 |
| `std.trace` | `hook_io_write_ctx` | `io_write_ctx` | `io_write` | `hook_io_write` | 二次改名 | 同上 |
| `std.trace` | `hook_net_connect_ctx` | `net_connect_ctx` | `net_connect` | `hook_net_connect` | 二次改名 | 同上 |
| `std.trace` | `hook_async_drain_ctx` | `async_drain_ctx` | `async_drain` | `hook_async_drain` | 二次改名 | 同上 |

结论：

- 这块不是“没改”，而是改成了另一套更短但不完全遵从一轮规范的名字
- 如果按二轮优化看，`attach` / `from_ctx` 的方向其实是对的
- 真正还没走到位的是 `hook_io_read` 这一类，本轮正式采用的目标名是 `io_read` / `io_write` / `net_connect` / `async_drain`

### 5. std.runtime

`std.runtime` 还保留一层明确的兼容门面，属于应当继续清理的 P0；但就二轮目标名本身来说，这块反而已经比较接近终点。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.runtime` | `runtime_ready` | `ready` | `ready` | `ready` + `runtime_ready` | 部分偏移 | 真正的问题是旧别名还在 |
| `std.runtime` | `runtime_diag_enabled` | `diag_enabled` | `diag_enabled` | `diag_enabled` + `runtime_diag_enabled` | 部分偏移 | `diag_enabled` 已基本合理 |
| `std.runtime` | `runtime_diag_collect` | `diag_collect` | `diag_collect` | `diag_collect` + `runtime_diag_collect` | 部分偏移 | 重点是删兼容层，不是继续缩名 |

结论：

- 这块不是命名没想清楚，而是兼容层还没删干净
- 这块本轮目标名不再继续变化，优化重点是删除 `runtime_*` 旧包装

### 6. std.db

`std.db` 顶层门面现在本质上还是 deprecated wrapper；这块同样不是“目标名还不够短”，而是“模块层级本身是否还该存在”。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.db` | `db_open` | `open` | `open` | `open` | 已对齐但不建议保留 | 名字已够短，问题在模块定位 |
| `std.db` | `db_close` | `close` | `close` | `close` | 已对齐但不建议保留 | 同上 |
| `std.db` | `db_exec` | `exec` | `exec` | `exec` | 已对齐但不建议保留 | 同上 |
| `std.db` | `db_changes` | `changes` | `changes` | `changes` | 已对齐但不建议保留 | 同上 |
| `std.db` | `is_deprecated` | `is_deprecated` | `is_deprecated` | `is_deprecated` | 明显偏移 | 这不是命名问题，是兼容层问题 |

结论：

- 这块不是名字长短问题，而是“模块是否还应存在”的问题
- 所以这块没有“继续优化目标名”的价值，优化点是直接删兼容门面

### 7. std.io

`std.io` 主体 API 已经比较短，但仍残留旧形态兼容重载。这里的结论和 `runtime` 很像：真正要做的是删兼容形态，而不是继续硬缩名字。

| 模块 | 旧名称 | 一轮规范名 | 二轮目标名 | 当前 std 实际名称 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| `std.io` | `complete_read_async` | `complete_read` | `complete_read` | `complete_read()` | 部分偏移 | 名字本身已经合理，问题是无参兼容形态仍在 |
| `std.io` | `complete_read_async_slot` | `complete_read` | `complete_read` | `complete_read(slot)` | 已对齐 | 这里已经接近终点 |
| `std.io` | `complete_write_async` | `complete_write` | `complete_write` | `complete_write()` | 部分偏移 | 同上 |
| `std.io` | `complete_write_async_slot` | `complete_write` | `complete_write` | `complete_write(slot)` | 已对齐 | 同上 |

结论：

- 这里已经接近完成
- 真正要不要继续收，就看你是否要彻底去掉“单 in-flight 兼容形态”
- 这块本轮目标名不再继续变化，重点是只保留 `complete_read(slot)` / `complete_write(slot)`

## 二、已经基本收口的模块

下面这些模块，至少从主流程 API 来看，已经和二轮目标名比较接近；但我也顺手标了一下其中还有没有继续优化空间。

| 模块 | 代表旧名称 | 当前 std 实际名称 | 还可继续优化吗 | 结论 |
| --- | --- | --- | --- | --- |
| `std.time` | `timer_start` / `timer_reset` / `timer_elapsed_ms` | `start` / `reset` / `elapsed_ms` | 基本不能 | 已基本收口 |
| `std.queue` | `sync_queue_len` / `sync_queue_is_empty` | `sync_len` / `sync_is_empty` | 可以 | 如果用 `SyncQueue` 重载，理论上还能到 `len` / `is_empty` |
| `std.sync` | `mutex_new` / `mutex_lock` / `mutex_unlock` | `new_mutex` / `lock` / `unlock` | 基本不建议 | 多原语并存，构造器不宜再缩成 `new` |
| `std.result` | `result_ok_i32` / `result_err_i32` | `ok` / `err` | 基本不能 | 已接近终点 |
| `std.schema` | `schema_get_i32` / `schema_get_bool` / `schema_get_f64` | `get` 重载 | 基本不能 | 已接近终点 |
| `std.db.kv` | `db_kv_open` / `db_kv_get` / `db_kv_compact` | `open` / `get` / `compact` | 基本不能 | 已接近终点 |
| `std.net` 主流程 | `net_tcp_connect` / `net_tcp_listen` / `net_accept` | `connect` / `listen` / `accept` | 主流程基本不能 | 主流程已短，但辅助 API 仍很多 |

## 三、还可以继续优化的方向

如果下一轮继续做，我建议按下面顺序推进：

### P0：先清兼容层

- `std.runtime` 的 `runtime_*` 包装
- `std.db` 顶层 deprecated 门面
- `std.io` 的无参 `complete_read()` / `complete_write()` 兼容形态

### P1：再清“二轮目标名已经确定，但源码还没跟上”的模块

- `std.string`
- `std.db.arrow`
- `std.trace`

### P2：修已经大体收口、但还有几个刺的模块

- `std.db.sqlite`
- `std.net`
- `std.error`

### P3：删兼容层而不是继续改名字

- `std.runtime`
- `std.db`
- `std.io`

## 四、直接结论

结论很明确：还能继续做优化，而且空间还不小。

如果只看“能不能用”，很多模块已经能用了；但如果按我们现在这轮的标准，即：

- 真正去模块前缀
- 真正去类型后缀
- 真正利用重载
- 不保留旧兼容门面

那目前至少下面几块还没有完全做干净：

- `std.string`
- `std.db.arrow`
- `std.db.sqlite`
- `std.trace`
- `std.runtime`
- `std.db`
- `std.io`

如果进一步只看“本轮已经确定的新目标名”，那么最典型的几组是：

- `column_new -> new`
- `column_adopt -> adopt`
- `column_data -> data`
- `column_sum -> sum`
- `column_sum_valid -> sum_valid`
- `column_dot -> dot`
- `attach_to_context -> attach`
- `io_read_ctx -> io_read`
- `io_write_ctx -> io_write`
- `net_connect_ctx -> net_connect`
- `async_drain_ctx -> async_drain`
- `trim_space -> trim`
- `replace_char -> replace`
- `from_raw_parts -> view`

所以这份文档现在的结论不是“还在讨论要不要优化”，而是：

- 二轮目标名已经定出来了
- 剩下的问题主要变成“源码什么时候跟上”

也就是说，这份对比已经可以直接拿来指导下一轮真实改名。

最终结论是：

**已经完成了一大批，但还远没有完全收口，后面仍可以继续做一轮真正的纯化。**
