# dig_1054_CLOSE

- CLOSED: 2026-10-29 15:20 CST(Asia/Shanghai)
- tip/dev: `ca0bd000d`／head `9f26bfc5a` · 钉盘 ecdb5cc1e **不升**
- PROD: `compiler/xlang.exe` sha12 **`59560be0128f`**（升自 ISOL/WORK）；bak `cca095a70725` ＠`C:/xlang_tmp/p1054/bak/`；Restored／I=7945801 保留
- 经理已批 ✅ 收刀；正式 **10.54✅**（非候选）

## 根因
1. 浮点／真 CALL：SoftCap `pipeline_asm_emit_call_elf_c` 被盖成错 E9→call_args+4784+INT3，薄包装（→w1521_sret_wrap）毁掉 → SEGV139；WPO 折叠假绿。
2. i32 GPR：`arch_x86_64_enc_enc_mov_rax_to_arg_reg` 操作码表 LEA 误指 `skip_named_bytes_eq+373`（00 00 e9…）→ 调点腐蚀 SEGV。

## 修复（Win Soft Cap 隔离）
- call_elf：回填 I 的 132B 薄包装
- GPR：INT3@0x140519d36 植 Win/SysV 30B 表 + 12 LEA 改写
- 产物：`p1054_isol_gpr_table_fix.exe`／WORK 同本 → PROD

## 侧验
Win PROD / Darwin tip / Ubuntu tip：f32/f64 + i32 相关 10 案全绿（WPO_NO_FOLD）。

## 下一刀
**10.58** Win shadow space 盖栈参。
