# 自举：全面实现与 C 扩展约定

> **目标**：全面实现自举，**编译器业务逻辑一律不用 C 实现**；若自举过程中因 shuc 能力不足而受阻，**允许且仅允许通过修改 C 代码、重新编译 shuc 来补齐能力**，再继续在 .sx 中实现自举。

---

## 一、原则

### 1.1 全面自举 = 不用 C 方法

- **「不用 C 方法」**：不在自举主路径中调用 C 的**业务逻辑**。  
  即：**不**使用 C 的 `parse()`、`typeck_module()`、`codegen_module_to_c()`、`codegen_library_module_to_c()`、C 的 lexer 驱动（`lexer_new`/`lexer_next` 用于 C 的 parser）等实现「解析 / 类型检查 / 代码生成」。
- **整条编译流水线**：从「读入 .sx 源码」到「写出 C 代码」的**全部语义与算法**均在 .sx 中实现（lexer.sx → parser.sx → ast.sx → typeck.sx → codegen.sx → pipeline.sx）。
- **C 的角色**：只做**最小运行时与接口**（见 §二），不做任何「如何解析 / 如何类型检查 / 如何生成 C」的决策。

### 1.2 遇阻时：改 C、重编 shuc、再继续 .sx

- 自举过程中若出现：  
  - **语言/语法不支持**（例如 .sx 缺少某种语法或类型），或  
  - **shuc 行为不符合预期**（bug、缺失特性、无法编译某段 .sx 代码），  
  则允许**修改 shuc 的 C 源码**（如 `parser.c`、`lexer.c`、`typeck.c`、`codegen.c`、`ast.c`、`main.c`、`preprocess.c` 等），**重新编译得到新的 shuc**，用新 shuc 继续自举。
- **原则**：  
  - 修改 C 的**目的**是「让 shuc 支持自举所需的语言能力或修复阻碍自举的缺陷」，而不是在 C 里实现新的编译器业务逻辑。  
  - 业务逻辑**仍然只在 .sx 里实现**；C 的修改只是**扩展编译器前端/后端的能力**，使 .sx 写的编译器能编译通过并正确运行。

---

## 二、C 的允许范围（自举完成后）

自举「全面实现」后，C 只保留以下职责，**不包含**任何「如何解析 / 如何类型检查 / 如何生成 C」的逻辑。

| 类别 | 允许的 C 职责 | 说明 |
|------|----------------|------|
| **进程与入口** | 过渡期：`main()`、命令行解析（见 §七 目标：build.sx + 无 main.c） | 最终由 .sx 提供入口 |
| **文件与内存** | 读文件到内存（`read_file`）、预处理（可选，直至 .sx 实现） | 为 .sx 流水线提供「源码字符串」；分配 arena/module 缓冲区（或由 .sx 侧声明，C 只传指针） |
| **写出一字节** | `codegen_sx_emit_byte(out, b)` | 唯一与「写出 C 代码」直接相关的 C：把一字节写到 `out`（如 FILE*）；其余输出逻辑全在 codegen.sx |
| **调用外部 cc** | `invoke_cc()`（或等价） | 把生成的 .c 交给系统 cc 编译/链接；不参与「生成什么 C」 |
| **可选：预处理** | `preprocess()` | 在 .sx 未实现预处理前，可由 C 做；实现后可在 .sx 中替代 |

**禁止**：  
- C 中**不再**实现：递归下降解析、类型推导、类型检查规则、C 代码生成（函数体、表达式、语句等）。  
- 即：不通过 C 的 `parse`/`typeck_module`/`codegen_module_to_c` 等来驱动或实现编译语义。

---

## 三、何时可以修改 C（「遇问题时」）

当出现以下情况时，**允许**修改 shuc 的 C 代码并重新编译 shuc，以继续自举：

| 情况 | 可修改的 C 位置 | 目的 |
|------|------------------|------|
| **.sx 语法/语义 shuc 不支持** | parser.c, lexer.c, include/ast.h, ast.c | 增加新关键字、新 AST 节点、新语法规则，使 shuc 能解析并生成对应 AST |
| **类型或 IR 表示缺失** | ast.h, ast.c, typeck.c | 增加类型种类、表达式种类、块/函数表示，使 .sx 前端能表达自举所需结构 |
| **代码生成缺某种形式** | codegen.c | 增加对新 AST/类型的 C 输出（仅作「能正确输出」的占位或最小实现），使 .sx 生成的 AST 能被当前 shuc 正确编成 C |
| **标准库/运行时缺失** | core/*.sx, std/*.sx 或 C 运行时胶水 | 增加 .sx 可调用的 API 或 C 胶水，使 compiler/*.sx 能编译通过并运行 |
| **构建/驱动缺失** | main.c, Makefile | 增加 -sx 分支、pipeline 调用、sizeof 获取等，使「纯 .sx 流水线」能被 C 驱动正确调用 |
| **明显 bug 阻碍自举** | 任意相关 .c/.h | 修 bug，使 shuc 行为符合语言规范或自举所需 |

修改后必须：  
1. **重新编译 shuc**（`make` 或 `make shuc-sx-pipeline` 等）；  
2. 用**新 shuc** 继续在 .sx 中实现/扩展编译器逻辑；  
3. **不**把「本应在 .sx 里实现的算法」写回 C（C 只做能力扩展与修 bug）。

---

## 四、实施阶段（全面自举路线）

### 阶段 1：纯 .sx 流水线成为唯一主路径

- **目标**：默认或通过 `-su` 走「parse_into → typeck_su_ast → codegen_sx_ast」；不再用 C 的 parse/typeck/codegen 做业务。
- **C 可改**：main.c 中默认使用 run_sx_pipeline；若缺 arena/module 分配或 sizeof，在 C 或生成 C 中提供；若需 `-su` 以外选项，在 main.c 中加。
- **验收**：对最小程序（如 `function main(): i32 { return 0; }`），整条链路仅用 .sx 逻辑即可生成可编译的 C。

### 阶段 2：.sx 覆盖完整语法与类型

- **目标**：parser.sx 支持自举所需全部语法（多函数、参数、let/const、控制流、表达式、import 等）；typeck.sx 覆盖全部类型规则；AST 仅用 ast.sx 定义。
- **遇阻时改 C**：若某语法/类型 shuc 当前不支持（如新关键字、新 AST 节点），在 parser.c/lexer.c/ast.h 等中扩展，重编 shuc，再在 .sx 中使用。
- **验收**：compiler 下所有 .sx 源码能由当前 shuc 编译通过（类型与语法无缺漏）。

### 阶段 3：.sx 覆盖完整代码生成

- **目标**：codegen.sx 支持所有已用到的 ExprKind、块内语句、函数/模块输出；不调用 C 的 codegen 业务接口。
- **遇阻时改 C**：若 shuc 生成的 C 某处错误或缺失（如某 AST 节点未在 codegen.c 中处理），在 codegen.c 中补最小输出或修 bug，重编 shuc；逻辑扩展仍以 .sx 为主。
- **验收**：用 .sx 流水线生成 compiler 自身所需 C，再经 cc 得到可执行 shuc。

### 阶段 4：驱动与可选预处理迁入 .sx

- **目标**：命令行解析、读文件、调用 pipeline、调用 cc 等尽可能在 .sx 中实现；若保留 C 的 main，则只做「调 .sx 入口 + 最小 I/O」。
- **遇阻时改 C**：若 .sx 侧需要新的运行时接口（如读文件、执行子进程），在 C 或 core/std 中增加最小实现，重编 shuc。
- **验收**：从「命令行 + 输入文件」到「生成可执行文件」的流程由 .sx 主导；C 仅提供约定好的最小接口。

### 阶段 5：自举验证与收尾

- **目标**：用宿主编出 shuc₁，用 shuc₁ 编出 shuc₂；两代对同一测试套件行为一致；文档/CI 记录自举通过。
- **遇阻时改 C**：若某测试暴露的是 shuc 的 bug 或缺失特性，按 §三 修改 C 并重编，再验证。

---

## 五、检查清单（全面自举）

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | 主路径无 C 业务逻辑 | 默认或 -sx 仅调用 run_sx_pipeline；不调用 C 的 parse/typeck_module/codegen_module_to_c |
| 2 | 词法、语法、AST 全在 .sx | lexer.sx, parser.sx, ast.sx 覆盖自举所需；不依赖 C 的 AST 结构做语义 |
| 3 | 类型检查全在 .sx | typeck.sx 实现全部类型规则；不依赖 C 的 typeck 逻辑 |
| 4 | 代码生成全在 .sx | codegen.sx 实现全部 C 输出；C 仅保留 codegen_sx_emit_byte（及可选最小胶水） |
| 5 | 遇阻只扩 C 能力不写业务 | 修改 C 仅用于：新语法/类型/输出形式、bug 修复、运行时/构建接口 |
| 6 | 两代 shuc 行为一致 | shuxc₁、shuc₂ 对同一测试套件结果一致 |

---

## 六、与「自举实现-逐步计划」的关系

- **自举实现-逐步计划.md**：侧重「参考 C 一一实现 .sx」的步骤与当前模块状态。  
- **本文档**：侧重**原则与边界**——  
  - **全面自举 = 不用 C 方法**（业务逻辑 100% .sx）；  
  - **遇问题时 = 可改 C 重编 shuc**，仅用于扩展能力或修 bug，不把业务逻辑写回 C。  

两文档可同时使用：按「逐步计划」推进实现，按本文档约束 C 的角色与修改方式。

---

## 七、目标：build.sx 与「不要 Makefile、不要 main.c」

**结论：是。** 全面自举的最终形态应包含 **build.sx**，从而**不再依赖 Makefile**；编译器入口放在 .sx，从而**不再依赖 main.c** 实现驱动逻辑。

### 7.1 build.sx（替代 Makefile）

- **职责**：用 .sx 实现的**构建脚本/程序**，负责  
  - 决定要编译哪些 .sx（compiler 下 lexer、parser、ast、typeck、codegen、pipeline、driver 等）；  
  - 调用当前已有的 shuc（或上一代 shuc）编译这些 .sx 为 C；  
  - 调用系统 cc 链接（并链接最小 C 运行时，若需要）；  
  - 产出新的 shuc 可执行文件。
- **使用方式**：在已有 shuc 的前提下，执行「shuc 编译 build.sx → 得到构建工具 → 运行该工具」即可完成一次编译器构建，无需执行 Makefile。
- **过渡**：在 build.sx 未就绪前，仍用 Makefile 构建；build.sx 就绪后，可逐步弃用 Makefile，或保留 Makefile 仅作「首次用系统 cc 编出初始 shuc」的兜底。

### 7.2 不要 main.c（入口在 .sx）

- **含义**：**不再用 main.c 实现**「命令行解析、读文件、调 pipeline、调 cc」等驱动逻辑；这些逻辑全部放在 .sx（例如 **driver.sx** 的 `function main(): i32`）。
- **入口从何而来**：由 shuc 编译「含 main 的 .sx 模块」（如 driver.sx）时，生成的 C 中会包含 `main()`，该 `main()` 即程序入口；链接时只需再链接提供 `codegen_sx_emit_byte`、`read_file`、`invoke_cc` 等 **extern** 的最小 C 运行时（如 **runtime.c**），无需 main.c。
- **C 仅保留**：最小运行时（实现 extern 的 I/O、写字节、调 cc 等），**不包含**任何编译器业务或驱动决策；若将来 .sx 标准库能完全覆盖这些能力，也可不再需要 C 运行时。

### 7.3 实施顺序建议

1. 先完成「纯 .sx 流水线 + C 仅做壳」（main.c 调 run_sx_pipeline，Makefile 构建）。  
2. 再实现 **driver.sx** 作为真正入口：把 main.c 里的命令行解析、读文件、调 pipeline、调 cc 迁到 driver.sx，保留最小 main.c 仅「调用 driver_main()」或改为由生成 C 的 main 直接调 driver 逻辑。  
3. 实现 **build.sx**：用 .sx 描述「如何编 compiler 下所有 .sx、如何调 cc、产出 shuc」；用现有 shuc 编译并运行 build.sx，替代 Makefile。  
4. 最终：**不要 Makefile**（由 build.sx 负责构建），**不要 main.c**（入口与驱动全在 .sx；C 仅保留最小运行时，若仍需 extern）。
