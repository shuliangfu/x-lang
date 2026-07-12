# TU Contract: runtime_random_fill

## 1. 当前权威源
- x 源：`src/asm/runtime_random_fill.x`
- seed 源：`seeds/runtime_random_fill.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_random_fill`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 当前角色判断：
  - `thin/.x provider`：src/asm/runtime_random_fill.x（random_get_alg public wrapper）
  - `seed/rest provider`：seeds/runtime_random_fill.from_x.c（_impl 实现 + random_fill_bytes_c）

## 3. 导出符号合同
- thin/.x 当前导出数：2
- seed/rest 当前导出数：2
- thin/.x 独有导出：1
- seed/rest 残余导出：2

### 3.1 必须由 thin/.x 提供
- `runtime_random_fill_x_doc_anchor`
- `random_get_alg`

### 3.2 当前仍由 seed/rest 提供
- `random_get_alg_impl`（Windows only，#if defined(_WIN32)）
- `random_fill_bytes_c`（全平台）

### 3.3 thin/.x 独有导出
- `runtime_random_fill_x_doc_anchor`

## 4. ABI Manifest
- _impl 残余列表：`random_get_alg_impl`
- thin+rest 宏边界：`SHUX_RUNTIME_RANDOM_FILL_FROM_X`
- 平台注意：`random_get_alg`/`_impl` 仅 Windows 有定义；.x thin wrapper 在非 Windows 平台引用 `_impl`（U 符号），但不被引用故不影响链接

## 5. 验证状态
- prove_x_o.sh：ok
- ld -r：ok（macOS merged 3 T + 2 U；Ubuntu rest 1 T + 2 U libc）
- smoke/probe：pending
- snapshot_compare：pending

## 6. 备注
- IMPL 模式：.x wrapper 调用 `_impl`，seed 重命名 `random_get_alg` → `random_get_alg_impl`
- 内部调用点 `random_fill_bytes_c`（Windows 分支）更新为调用 `_impl`
- `random_get_alg` 返回 `*u8`（.x）vs `BCRYPT_ALG_HANDLE`（seed），ABI 兼容（均为指针）
