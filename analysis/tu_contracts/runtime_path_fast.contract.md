# TU Contract: runtime_path_fast

## 1. 当前权威源
- x 源：`src/asm/runtime_path_fast.x`
- seed 源：`seeds/runtime_path_fast.from_x.c`
- prove 工件目录：`../tests/probes/prove_x_o/runtime_path_fast`

## 2. 当前目标
- 当前阶段：Phase 2（thin+rest 切割完成）
- 本次目标：已证明该 TU 具备 L1/L2/L3 闭环（含 ld -r 合并）
- 当前角色判断：
  - `thin/.x provider`：src/asm/runtime_path_fast.x（path_sep/is_sep/last_sep/last_dot_c pure helpers）
  - `seed/rest provider`：seeds/runtime_path_fast.from_x.c（std_path_* 系列 C 尾段）

## 3. 导出符号合同
- thin/.x 当前导出数：4
- seed/rest 当前导出数：13
- thin/.x 独有导出：0
- seed/rest 残余导出：13

### 3.1 必须由 thin/.x 提供
- `path_sep_c`
- `path_is_sep_c`
- `path_last_sep_c`
- `path_last_dot_c`

### 3.2 当前仍由 seed/rest 提供
- `std_path_empty_len`
- `std_path_sep`
- `std_path_join`
- `std_path_dirname`
- `std_path_basename`
- `std_path_is_absolute`
- `std_path_is_sep`
- `std_path_extension`
- `std_path_stem`
- `std_path_extension_and_stem`
- `std_path_clean`
- `std_path_resolve`

### 3.3 thin/.x 独有导出（若非空，后续需审计）
- （空）

## 4. ABI Manifest（试点版）
- 当前阶段先锁定：
  - symbol 集
  - thin/.x 与 seed/rest 的 provider 边界
  - _impl 残余列表：N/A（本 TU 使用 #ifndef/extern 模式，非 _impl 模式）
  - thin+rest 宏边界：`XLANG_RUNTIME_PATH_FAST_FROM_X`
  - 语义差异：.x path_sep_c 总是返回 '/'（47，posix 验收路径）；seed Win 分支返回 '\'（92）保留但 rest 模式下不生效（Win 非当前验收平台）
  - rest 跨调用依赖：std_path_* 调用 path_sep_c/path_is_sep_c/path_last_sep_c/path_last_dot_c（thin 提供，rest 模式下 extern 声明）
- 下一步补充：
  - arg_count / arg_shapes
  - ret_shape
  - struct_size_snapshot
  - critical_field_offsets

## 5. 验证状态
- prove_x_o.sh：已跑通最小 L1/L2
- 已完成：
  - bootstrap-safe lint
  - .x -> -E
  - cc -c
  - nm
  - seed 符号对照
  - ld -r thin+rest 合并：✅ 已通过（macOS arm64 + Ubuntu x86_64 双平台验证，17 T 符号）
- 待补：
  - smoke / probe：pending
  - canonical snapshot compare：pending

## 6. 删除 seed 的门槛
- 当前阶段：**不允许删 seed**
- 必须补齐：
  - provider 边界稳定
  - ld -r 闭环
  - smoke / probe 一致
  - 连续构建不回退 seed

## 7. 备注
- 本文件由 compiler/scripts/gen_tu_contract.sh 生成
- 当前只作为试点 TU 的最小合同，不代表最终 ABI 审计已完成
