# dig_1054_PROGRESS

## Beat 1 — SoftCap call_elf cave（已钉，勿重开）
- 根因：SoftCap pipeline_asm_emit_call_elf_c 被盖成错 E9→call_args+4784+INT3，真薄包装（→w1521_sret_wrap）毁掉，误入 FMT 中部→elf_ctx 乱→SEGV139；浮点是真 CALL 症候（WPO 折叠假绿）
- ISOL 回填 I 的 132B 薄包装后：Win f32_ignore/as/opaque、f64_ignore、local、call0 全绿；Darwin/Ubuntu 同案绿；产物 XMM0+cvtt 正确
- PROD 未动；未 push；钉盘 ecdb5cc1e 不升；tip/dev＝f884603bb
- 产物：C:/xlang_tmp/p1054/p1054_isol_call_elf_restore.exe sha12 72d82678c5d0

## Beat 2 — i32 GPR 00 00 e9 residual (2026-10-29 15:16:23 CST(Asia/Shanghai))

### i32 根因（一句）
SoftCap arch_x86_64_enc_enc_mov_rax_to_arg_reg@0x140519b4c 的 Win/SysV 操作码表 LEA 误指进 skip_named_bytes_eq+373 函数体（字节恰为 00 00 e9…），x86_enc_bytes 原样拷进产物 → i32 调点腐蚀 SEGV；浮点走另一条 XMM 栈构路径故已绿。

### 最小隔离补丁
- 基：p1054_isol_call_elf_restore.exe（call_elf 132B 回填仍在）
- 新：C:/xlang_tmp/p1054/p1054_isol_gpr_table_fix.exe sha12 59560be0128f
- WORK 副本：C:/xlang_tmp/p1054/p1054_work_gpr_table_fix.exe（同内容侧验）
- 在编码器尾 INT3@0x140519d36 植入 30B 正确表：
  - Win64：48 89 c1 | 48 89 c2 | 49 89 c0 | 49 89 c1（rcx/rdx/r8/r9）
  - SysV：48 89 c7 | 48 89 c6 | 48 89 c2 | 48 89 c1 | 49 89 c0 | 49 89 c1
- 改写 12 处 LEA rip-disp 指向新表；未改 PROD；未 push；钉盘 ecdb5cc1e 不升；tip f884603bb
- 扫：0 剩余 LEA 落入 skip_named_bytes_eq 区；mov_rdx_to_arg_reg 为栈构路径，无同类洞

### 侧验表（XLANG_WPO_NO_FOLD=1；期望 exit）

| case | expect | Win ISOL | Win WORK | Darwin tip | Ubuntu tip |
|------|--------|----------|----------|------------|------------|
| i32_call | 7 | 7 | 7 | 7 | 7 |
| i32_opaque | 7 | 7 | 7 | 7 | 7 |
| sanity_i32 | 7 | 7 | 7 | 7 | 7 |
| i32_two | 3 | 3 | 3 | 3 | 3 |
| f32_ignore | 7 | 7 | 7 | 7 | 7 |
| f32_as | 1 | 1 | 1 | 1 | 1 |
| f32_opaque | 1 | 1 | 1 | 1 | 1 |
| f64_ignore | 7 | 7 | 7 | 7 | 7 |
| local | 1 | 1 | 1 | 1 | 1 |
| call0 | 7 | 7 | 7 | 7 | 7 |

产物抽查 i32_call main：mov %rax,%rcx; call take（无 00 00 e9）。

### PROD / 钉
- PROD compiler/xlang.exe sha12 cca095a70725 size 7961399 未动
- 钉盘 ecdb5cc1e 不升；禁 CloudAgent／HARD BAN／10.74／mega／LEGACY

### RC 判定
- 条件「三端浮点传参都对（含相关 i32 调用不崩）」：已满足（ISOL+WORK 满绿；Darwin/Ubuntu tip 同案不回归）
- 可否进正式 RC：可 RC 候选——正式升 PROD／push 仍需 manager 拍板（本拍仅 ISOL／WORK；未动 PROD／未 push）
- CLOSE：见 dig_1054_CLOSE.md；正式落地＝call_elf 薄包装 + GPR 操作码表补丁合入 SoftCap 重建／或等价源修

## Closeout（经理批 ✅）
- WORK→PROD sha12 `59560be0128f`；bak `cca095a70725`；钉盘不升；正式 10.54✅
