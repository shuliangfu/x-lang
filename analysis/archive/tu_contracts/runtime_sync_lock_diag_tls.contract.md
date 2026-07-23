# TU Contract: runtime_sync_lock_diag_tls

## 1. 当前权威源
- x 源：`src/asm/runtime_sync_lock_diag_tls.x`（G-02f-19 文档锚点 + G-02f-101/102 门闩 + G-02f-119 真迁）
- seed 源：`seeds/runtime_sync_lock_diag_tls.from_x.c`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色：thin/.x 提供 2 个 IMPL wrapper + 3 个 DIRECT 函数 + 1 doc_anchor，seed/rest 提供 2 个 `_impl` + 17 个 rest 函数

## 3. 导出符号合同
- thin/.x 导出：6（doc_anchor + 2 IMPL wrapper + 3 DIRECT）
- seed/rest 导出：19（2 `_impl` + 17 个 sync_lock_diag_*_c 函数）
- only_x：1（doc_anchor）

### 3.1 必须由 thin/.x 提供
- `runtime_sync_lock_diag_tls_x_doc_anchor`（only_x）
- `sync_lock_diag_find_meta_idx`（IMPL，调用 `_impl`）
- `sync_lock_diag_get_order`（IMPL，调用 `_impl`）
- `sync_lock_diag_append_byte`（DIRECT，G-02f-119 真迁 .x 完整实现）
- `sync_lock_diag_append_lit`（DIRECT，G-02f-119 真迁 .x 完整实现）
- `sync_lock_diag_append_i32`（DIRECT，G-02f-119 真迁 .x 完整实现）

### 3.2 当前仍由 seed/rest 提供
- `sync_lock_diag_find_meta_idx_impl`（查找 mutex 元数据索引）
- `sync_lock_diag_get_order_impl`（读取 mutex 锁序 id，调用 `sync_lock_diag_find_meta_idx`）
- TLS 栈：`sync_lock_diag_tls_push_c` / `tls_pop_c` / `tls_has_c` / `tls_max_order_c` / `tls_count_c` / `tls_clear_c`
- 诊断生命周期：`sync_lock_diag_before_lock`（调用 `sync_lock_diag_get_order`）/ `after_lock`（调用 `sync_lock_diag_get_order`）/ `before_unlock` / `after_unlock`
- 配置与状态：`sync_lock_diag_set_enabled_c` / `is_enabled_c` / `mutex_set_id_c`（调用 `sync_lock_diag_find_meta_idx`）/ `last_err_c` / `clear_c`
- 快照与烟测：`sync_lock_diag_snapshot_c`（调用 `sync_lock_diag_append_lit` + `sync_lock_diag_append_i32`）/ `smoke_c`

## 4. ABI Manifest
- _impl 残余列表：`sync_lock_diag_find_meta_idx_impl`、`sync_lock_diag_get_order_impl`
- DIRECT 符号列表：`sync_lock_diag_append_byte`、`sync_lock_diag_append_lit`、`sync_lock_diag_append_i32`
- thin+rest 宏边界：`XLANG_RUNTIME_SYNC_LOCK_DIAG_TLS_FROM_X`
- 前向声明：4 个 thin 函数（`sync_lock_diag_find_meta_idx` / `sync_lock_diag_get_order` / `sync_lock_diag_append_lit` / `sync_lock_diag_append_i32`），rest 模式下供 rest 函数调用
- 内部调用更新：
  - `sync_lock_diag_get_order_impl` 调用 `sync_lock_diag_find_meta_idx`（IMPL thin wrapper）
  - `sync_lock_diag_before_lock` / `after_lock` 调用 `sync_lock_diag_get_order`（IMPL thin wrapper）
  - `sync_lock_diag_mutex_set_id_c` 调用 `sync_lock_diag_find_meta_idx`（IMPL thin wrapper）
  - `sync_lock_diag_snapshot_c` 调用 `sync_lock_diag_append_lit` + `sync_lock_diag_append_i32`（DIRECT thin wrapper）

## 5. 验证状态
- prove_x_o：ok（.x 生成 + thin.o 编译通过，macOS 完整流程含 merged.o）
- ld -r：ok（macOS merged 完整符号集 + Ubuntu merged 25 T/W，U 仅 sync_mutex_*_c 外部 TU 依赖）
- smoke/probe：pending

## 6. 备注
- 混合 IMPL+DIRECT 模式：2 个 IMPL wrapper（find_meta_idx / get_order）+ 3 个 DIRECT（append_byte / append_lit / append_i32，G-02f-119 真迁 .x 完整实现）
- 类型擦除：.x 侧 `find_meta_idx`/`get_order` 参数为 `*u8`（`void *` 在 .x 无法表达）；seed 前向声明用 `void *` 与调用处一致，thin.o 实际签名 `uint8_t *`，C 链接器不看类型，ABI 兼容
- `sync_lock_diag_append_byte` 无前向声明：rest 函数不直接调用它，只有 thin.o 内的 `append_lit` / `append_i32` 调用
- 已知预存行为：Linux 上 thin wrapper 为 W（weak）符号——prove_x_o.sh 默认 G05_X_O_WEAK=1，macOS Mach-O 忽略 weak 均为 T。非本次切割引入
- 依赖：外部 TU `sync_mutex_new_c` / `sync_mutex_lock_c` / `sync_mutex_unlock_c` / `sync_mutex_free_c`（runtime_sync_os.c）
