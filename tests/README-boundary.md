# 边界测试覆盖说明

> 本文件汇总各 `run-*.sh` 对应的**边界/负例/异常**测试情况：是否包含「必须失败」或「边界行为」的用例。已全面补全边界用例并接入对应 `run-*.sh`。

---

## 已有较全边界/负例的测试

| 测试 | 边界/负例内容 |
|------|----------------|
| **preprocess** | 已写全：`unclosed #if`、`#else/#endif/#elseif` 无 `#if`、`#elseif` 在 `#else` 后、重复 `#else`、多 `#endif` 等 7 类，均断言 stderr 含预期错误信息。 |
| **parser** | 正例 `semicolon_required.sx`；负例 `semicolon_missing.sx`（缺分号）、`if_missing_paren.sx`（if 后缺 `(`）。 |
| **lexer** | 正例与 expected.txt 比对；负例 `invalid_char.sx`（含 `$` 等非法字符，须编译失败）。 |
| **typeck** | 正例 lexer/main.sx；负例 `type_mismatch_assign.sx`、`if_condition_not_bool.sx`、`undefined_name.sx`、`return_implicit.sx`、`ternary_condition_not_bool.sx`、`ternary_branches_mismatch.sx`，均断言 stderr 含 `typeck error`。`SHUX=shux_sx` 时脚本仅对 `return_implicit.sx` 自动加 `-sx`（与 .sx typeck 隐式返回检查对齐）；其余负例仍走 shux_sx 内嵌的 C 前端。设 `TYPECK_SX=all` 可令所有负例带 `-sx`（.sx typeck 未全覆盖前慎用）。 |
| **struct** | 正例 `padding_allow` + 负例 `padding_no_allow.sx`（无 allow(padding) 时隐式 padding 报 typeck error）。 |
| **float** | 正例多文件 + `boundary.sx` + 负例 `init_non_zero_int.sx`（f32=1 非字面量/0 报 typeck error）。 |
| **while** | 正例多文件 + 负例 `break_outside.sx`（break 不在循环内报 typeck error）。 |
| **for** | 正例 simple.sx；负例 `continue_outside.sx`（continue 在 while 条件中，非循环体，报 only allowed inside a loop）。 |
| **let-const** | 正例多文件；负例 `const_non_const.sx`（const 初始化为非常量表达式）。 |
| **import** | 正例 main.sx；负例 `missing_module.sx`（import 不存在的模块，报 cannot open import 等）。 |
| **match** | 正例 main.sx；负例 `enum_no_variant.sx`（match 分支使用枚举不存在的变体）。 |
| **array** | 正例 main/literal；负例 `subscript_not_array.sx`（下标基类型非数组/切片）。 |
| **slice** | 正例 main/len；负例 `subscript_not_slice.sx`（同上）。 |
| **generic** | 正例 main.sx；负例 `wrong_type_args.sx`（泛型调用类型实参数量错误）。 |
| **trait** | 正例 main.sx；负例 `method_no_impl.sx`（对无 impl 的类型调用方法）。 |
| **ub** | 边界/异常行为：`div_zero`、`bounds_array`、`bounds_slice` 预期 panic，`div_ok` 预期正常退出码。 |
| **panic** | 预期非零退出（abort），`with_msg.sx` 带消息。 |
| **pool-limits** | grow 池边界：20 形参、65 实参、30 局部、100 block stmt、260 函数（fn259→42 避 exit 截断）、40 层 #if、20 struct 字段、6/8 层嵌套 loop、10 项 import select（`run-pool-limits.sh`）。 |
| **compound-assign** | 复合赋值 +=/-=/*= 等（`run-compound-assign.sh`）。 |

---

## 已补边界、待编译器支持的用例

| 测试 | 说明 |
|------|------|
| **return-expr** | `return_type_mismatch.sx`（return true 而函数声明 i32）已保留；当前 typeck 未检查 return 表达式类型与声明是否一致，脚本中对应断言已注释，待 typeck 补全后启用。 |

---

## 小结

- **已写全或已补边界/负例**：preprocess、parser、lexer、typeck、struct、float、while、for、let-const、import、match、array、slice、generic、trait、ub、panic。
- 更新本表时请同步修改对应 `run-*.sh` 与用例文件。
