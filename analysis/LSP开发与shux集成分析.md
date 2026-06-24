# LSP 开发与 shux 集成分析

> 采用「方案 2：shux 提供 LSP 模式」+ **路线 A**：LSP 内置于 shux，**LSP 协议层用 .sx（Shux）编写**，从 stdin 读 JSON-RPC、调现有 parse/typeck、向 stdout 写响应；单进程、单二进制，VSCode 扩展仅作客户端。本文档分析 LSP 是什么、怎么写、以及如何用 .sx 在 compiler 内实现 LSP。

---

## 一、LSP 是什么、怎么工作

### 1.1 协议角色

- **Language Server Protocol (LSP)**：微软主导的开放协议，让 IDE/编辑器（Client）与语言服务（Server）通过统一接口通信，实现诊断、跳转定义、查找引用、悬停、补全等。
- **Client（客户端）**：VSCode、Cursor、Vim/Neovim 等。我们使用 VSCode 时，由 **vscode-languageclient** 担任客户端，负责启动 Server 进程、发请求、收响应、把结果呈现在编辑器中。
- **Server（服务端）**：我们实现的部分。接收 Client 的请求（如「请给这份文档发诊断」「请返回这个符号的定义位置」），内部调用解析/类型检查/符号表，按 LSP 约定返回 JSON 结果。

### 1.2 通信方式

- **传输**：通常用 **stdio**（标准输入/输出）。Client 启动 Server 进程，向 stdin 写请求，从 stdout 读响应；错误日志可写 stderr。
- **消息格式**：**JSON-RPC 2.0**。每条消息形如：
  - 请求：`{"jsonrpc":"2.0","id":1,"method":"textDocument/diagnostics","params":{...}}`
  - 响应：`{"jsonrpc":"2.0","id":1,"result":[...]}`
  - 通知（无 id）：`{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{...}}`
- **编码**：消息以 `Content-Length: ...\r\n\r\n` + 正文（UTF-8 JSON）形式发送；LSP 规范规定必须带 Content-Length 头。

### 1.3 典型流程

1. Client 启动 Server（路线 A 下为 `shux --lsp`，单进程）。
2. Client 发 **initialize** 请求（含 rootUri、capabilities 等），Server 返回 **InitializeResult**（capabilities、serverInfo）。
3. Client 发 **initialized** 通知。
4. 用户打开/保存 .sx 文件时，Client 发 **textDocument/didOpen**、**didChange**、**didSave** 等通知，Server 可据此维护文档内容。
5. Client 需要诊断时发 **textDocument/diagnostics**（或用 **textDocument/publishDiagnostics** 由 Server 主动推送），Server 返回 `Diagnostic[]`（range、message、severity）。
6. 用户「转到定义」时，Client 发 **textDocument/definition**，Server 返回 `Location | Location[]`（uri、range）。
7. 用户「查找引用」时，Client 发 **textDocument/references**，Server 返回 `Location[]`。

我们要写的是 **Server 端**：实现上述请求/通知的 handler，并在内部依赖 shux 的 parse/typeck 与符号信息。

---

## 二、LSP 要写哪一端、需要哪些方法

### 2.1 我们只写 Server

- **Client**：使用 VSCode 官方 **vscode-languageclient**，在 `editors/vscode` 扩展里配置「用哪种方式启动 Server、传什么参数」即可，无需手写 JSON-RPC。
- **Server**：需要我们自己实现（或用现有库封装 + 调 shux）。Server 必须：
  - 从 stdin 读 JSON-RPC 请求/通知；
  - 解析 method 与 params；
  - 调用后端逻辑（见下文「与 shux 的集成」）；
  - 向 stdout 写 JSON-RPC 响应（带 Content-Length）。

### 2.2 建议实现的 LSP 方法子集


| 方法 / 通知                                               | 用途              | 优先级 |
| ----------------------------------------------------- | --------------- | --- |
| **initialize**                                        | 握手，声明 Server 能力 | 必须  |
| **initialized**                                       | 握手后通知           | 必须  |
| **textDocument/didOpen**                              | 打开文件时同步文档内容     | 必须  |
| **textDocument/didChange**                            | 增量编辑时更新文档       | 必须  |
| **textDocument/didSave**                              | 保存时可选触发诊断       | 建议  |
| **textDocument/diagnostics** 或 **publishDiagnostics** | 返回语法/类型错误列表     | 必须  |
| **textDocument/definition**                           | 跳转到定义           | 高   |
| **textDocument/references**                           | 查找引用            | 中   |
| **textDocument/hover**                                | 悬停显示类型/文档       | 中   |
| **shutdown** / **exit**                               | 优雅退出            | 必须  |


先实现 **initialize + 文档同步 + diagnostics + definition**，再补 references、hover。

---

## 三、采用路线 A：LSP 协议层用 .sx 写、内置于 shux

### 3.1 选定方案

**我们采用路线 A**：LSP Server 与 shux 同一进程、同一二进制；**LSP 协议层（JSON-RPC 读/写、请求分发、Diagnostic/Location 组装）用 .sx（Shux）实现**，不放在 C 里。这样既保留单进程单二进制、与 typeck 完全一致的优势，又避免在 C 里写 JSON 解析与 LSP 消息封装，便于维护与跟进 LSP 规范。

### 3.2 路线 A 的具体做法

- **入口**：shux 支持 `--lsp`。启动后进入 **.sx 实现的 LSP 主循环**（或由 C 入口调 .sx 的 `lsp_main`）。
- **.sx 侧职责**：
  - 从 **stdin** 按 LSP 约定读消息（Content-Length + JSON 正文），解析 JSON-RPC 的 method、id、params；
  - 根据 method 分发：initialize、initialized、textDocument/didOpen/didChange、textDocument/diagnostics、textDocument/definition、shutdown/exit 等；
  - 调用**现有编译器接口**（parse_into、typeck_sx_ast 等，通过现有 C/.sx 调用约定）获取诊断与符号信息；
  - 将错误、符号位置组装成 LSP 的 Diagnostic、Location 等结构，序列化为 JSON，按 Content-Length + 正文写入 **stdout**。
- **C / 现有编译器**：不实现 LSP 协议本身，只提供「可被 .sx 调用的」parse/typeck 及**结构化错误与定义位置**的接口（见第四节）；必要时在 C 侧增加错误收集器或定义查询 API，供 .sx LSP 层使用。

### 3.3 .sx 实现 LSP 的前提条件

| 条件 | 说明 |
|------|------|
| **stdin / stdout** | .sx 能读 stdin、写 stdout。可通过 `std.io` 或 C 的 read/write 经 `extern` 暴露给 .sx。 |
| **JSON 解析与生成** | .sx 侧需解析 LSP 请求中的 JSON（method、params、id），并生成响应 JSON。可先在 .sx 里实现**最小 JSON 解析**（仅解析 LSP 用到的几种结构），或由 C 提供小型 `json_parse` 供 .sx 调用；LSP 消息结构相对固定，不必上完整通用 JSON 库。 |
| **调用 parse/typeck** | 当前 pipeline 已是 .sx 调 C/su 的 parse_into、typeck；LSP 层同样通过现有接口调用即可。 |
| **错误与符号数据** | parse/typeck 的错误需能以**结构化形式**返回给 .sx（例如错误列表：line、col、message、severity），而非仅写 stderr；定义位置需能按「文件+行列」查询并返回。这需要在 C 或现有 .sx 流水线中增加「诊断收集」与「定义查询」的接口（见第四节）。 |

### 3.4 路线 B（备选）

若暂不采用路线 A，可退而采用 **路线 B**：shux 只提供 `--lsp-diagnostics`、`--lsp-definition` 等子命令并输出 JSON，由**外层 Node/TypeScript LSP Server** 子进程调 shux、解析 stdout、实现完整 LSP。详见下文「五、路线 B 的替代形态」；当前以路线 A + .sx 为主。

---

## 四、compiler 暴露给 .sx LSP 层的能力

路线 A 下，.sx 写的 LSP 层会**直接调用** parse/typeck 等现有接口；为支撑 diagnostics 与 definition，compiler 需向 .sx 暴露以下能力（可在 C 或 .sx 中实现，供 LSP 层调用）。

### 4.1 诊断（diagnostics）

- **触发**：.sx LSP 层在 didOpen/didSave 或收到 diagnostics 请求时，对当前文档（或工作区内相关 .sx 文件）调用 parse + typeck。
- **需求**：parse/typeck 产生的错误不能只写 stderr，而要以**结构化列表**返回给调用方（.sx LSP 层），例如每条含：file（或 uri）、line、col、message、severity。AST 与 Token 已有 line/col（见 `compiler/include/ast.h`、`token.h`）。
- **实现要点**：在 parser 的 `fail()`、typeck 的错误路径上，增加「诊断收集器」：在 LSP 模式下将错误写入该收集器，由 .sx 在调用 parse/typeck 后读取并转成 LSP 的 Diagnostic[] 再序列化为 JSON 写 stdout。或由 C 提供 `lsp_collect_diagnostics(arena, module, source, &out_list)`，.sx 调用后把 out_list 转成 JSON。

### 4.2 定义位置（definition）

- **触发**：用户对某标识符执行「转到定义」时，.sx LSP 层收到 `textDocument/definition`，参数含文档 uri 与 position（0-based line、character）。
- **需求**：compiler 需提供「按文件+行列查询定义位置」的接口，供 .sx 调用，例如：给定 (uri 或 path, line, col)，返回定义处的 (uri, line, col) 或 range。LSP 使用 0-based line/character；内部 1-based 的 line/col 在 .sx 层做转换即可。
- **实现要点**：需要**符号表或 AST 上的定义位置**。当前 typeck 已有作用域与名称解析；需在解析/typeck 时记录「每个符号定义对应的 line/col」，并暴露查询 API（如 C 的 `lsp_definition_at(path, line, col, out_location)` 或 .sx 中封装）。若 AST 未直接存定义处 line/col，可先在 function/let/const 等节点上补齐（parser 已有 set_expr_loc，可类比 set_def_loc）。

### 4.3 引用（references，可选）

- **需求**：给定文件+行列，返回引用该符号的所有位置（uri + range）。可与 definition 共用符号解析逻辑，遍历 AST 收集引用位置并暴露为 API 供 .sx LSP 层调用。

### 4.4 小结

| 能力 | compiler 暴露给 .sx 的接口形态 | 编译器现有可复用 |
|------|--------------------------------|------------------|
| 诊断 | 诊断收集器或 `lsp_collect_diagnostics(...)`，返回结构化错误列表 | parse/typeck 错误路径 + Token/AST 的 line/col |
| 定义 | `lsp_definition_at(path, line, col)` 或 .sx 封装，返回 (uri, range) | typeck 符号解析；需在 AST/符号表记定义位置 |
| 引用 | `lsp_references_at(...)` 或 .sx 封装，返回 Location[] | AST 遍历 + 符号解析 |


---

## 五、路线 A：.sx LSP 层实现形态与放置位置

### 5.1 技术形态

- **语言**：LSP 协议层全部用 **.sx（Shux）** 编写：JSON-RPC 消息的读取与解析、method 分发、调用 parse/typeck/定义查询、组装 Diagnostic/Location、序列化 JSON 并写 stdout。
- **入口**：shux 解析到 `--lsp` 时，不进入常规编译流程，而是调用 .sx 中的 **lsp_main**（或等价入口），进入「读 stdin → 解析 → 分发 → 调编译器接口 → 写 stdout」循环。
- **依赖**：.sx 侧需要（1）stdio 读/写（std.io 或 extern C），（2）最小 JSON 解析/生成（仅覆盖 LSP 用到的结构），（3）调用现有 parse_into、typeck 及第四节中的诊断/定义接口。

### 5.2 放置位置

- **LSP 相关 .sx 源码**：放在 **compiler 仓库内**，与现有 pipeline、driver 同仓，例如 `compiler/src/lsp/` 或 `compiler/src/driver/lsp.sx`，随 shux 一起编译进同一二进制。
- **VSCode 扩展**：`editors/vscode` 仅负责启动 LSP Server。扩展的 languageclient 配置为：**启动命令 = `shux --lsp`**（或用户配置的 shux 路径 + `--lsp`），无需再起 Node 进程。工作区根、文档内容由 LSP 协议通过 initialize、didOpen/didChange 传给 shux，shux 内 .sx 层维护文档状态并调 compiler 接口。

### 5.3 路线 B 的替代形态（备选）

若不采用路线 A，可改为：shux 仅提供 `--lsp-diagnostics`、`--lsp-definition` 等子命令并输出 JSON；**外层用 Node/TypeScript + vscode-languageserver** 实现 LSP，子进程调 shux、解析 stdout。LSP Server 可放在 `editors/vscode/server/`，扩展通过 languageclient 启动该 Node 进程。详见 LSP 规范与 [vscode-languageserver](https://github.com/microsoft/vscode-languageserver)。

---

## 六、开发步骤与阶段建议（路线 A + .sx）

### 6.1 阶段 1：.sx 侧 LSP 主循环与最小 JSON

1. 在 compiler 中增加 `--lsp` 分支：解析到该参数时调 .sx 的 **lsp_main**（或 C 先读一条消息再交给 .sx）。
2. .sx 侧实现：从 stdin 按 LSP 约定读取一条消息（Content-Length + 正文）；用**最小 JSON 解析**取出 `method`、`id`、`params`；对 `initialize` 返回固定 InitializeResult（capabilities、serverInfo），并写回 stdout（Content-Length + JSON）。
3. 实现 `shutdown`、`exit` 通知处理，使 Client 能正常退出。
4. 验证：VSCode 扩展配置 `shux --lsp` 后，打开 .sx 文件能完成握手、无崩溃。

### 6.2 阶段 2：文档同步与诊断

1. .sx 侧实现 **textDocument/didOpen**、**didChange**：维护 uri → 文档内容的映射（或只保留当前打开文件，视需求而定）。
2. **Compiler 侧**：增加诊断收集接口（见 4.1），使 parse/typeck 在 LSP 模式下把错误写入收集器并返回给调用方。
3. .sx 侧实现 **textDocument/diagnostics**（或 **publishDiagnostics**）：用当前文档内容调 parse/typeck（或传入临时文件路径），从收集器取结构化错误列表，转为 LSP Diagnostic[]（注意 0-based line/character），序列化为 JSON 写 stdout。
4. 在扩展中确认打开/编辑 .sx 文件后，问题面板能显示 shux 报出的语法/类型错误。

### 6.3 阶段 3：定义位置（definition）

1. **Compiler 侧**：在 AST/符号表记录定义位置，暴露 **lsp_definition_at(path, line, col)** 或 .sx 可调用的等价接口（见 4.2）。
2. .sx 侧实现 **textDocument/definition**：从 params 取 uri 与 position，调定义查询接口，将结果转为 LSP Location，写回 stdout。
3. 在 VSCode 中验证「转到定义」可用。

### 6.4 阶段 4：引用与悬停（可选）

1. Compiler 暴露 **lsp_references_at**（及可选 **lsp_hover**）；.sx 侧实现 **textDocument/references**、**textDocument/hover**，同样组 JSON 写 stdout。
2. 扩展侧无需改代码，languageclient 已支持上述方法。

---

## 七、与现有文档和项目的关系

- **VSCode 扩展**：`analysis/VSCode插件分析与实现指南.md` 中的「方案 2」+ 路线 A 即本文实现路径；P0（高亮+语言配置）已完成，P1/P2 按本文分阶段做；扩展仅需配置 languageclient 启动 `shux --lsp`。
- **编译器**：不改变现有「编译产出」行为；新增 `--lsp` 入口与 .sx 实现的 LSP 协议层，以及供 .sx 调用的诊断收集、定义查询接口；错误与符号信息与 typeck/parser 一致。
- **用 .sx 写、轻量级**：LSP 协议层用 .sx 编写，便于维护与自举；无额外运行时，单二进制；仅需 .sx 侧最小 JSON 与 stdio 能力。

---

## 八、LSP 与文档规模（行数/大小）、性能与限制

### 8.1 为什么「大模型几十 G 能读，我们几 M 就不行？」

- **大模型读几十 G**：多是**顺序/流式读权重**或内存映射，按块加载，**不做整份数据的全量语义解析**，也不对整份数据做「依赖图 + 类型解析 + 按位置查符号」。
- **LSP 对几 M 源码**：要对**整份文件**做 **parse → 整棵 AST → 全量 typeck**，且 **definition/references/hover 每次都可能遍历整棵 AST**。瓶颈是「解析 + 图遍历」的复杂度，不只是「能不能读几 MB」。
- 因此：**可以优化**——既能提高「能加载多大」的上限，也能通过索引/增量等手段减少「整图遍历」的开销。

### 8.2 用户代码行数/文件大小对性能的影响

| 环节 | 与规模关系 | 说明 |
|------|------------|------|
| 文档缓冲 | 按需分配 | 已改为 C 侧堆分配（`lsp_set_document_from_body`），单条 body 安全上限 64MB。 |
| 哈希校验 | O(文档字节数) | 缓存命中前对整份文档 djb2；已做 4 字节展开优化；先比 len 再 hash。 |
| Parse + Typeck | O(文档) / O(AST 节点数) | 整文件解析与类型检查，文档变更时全量 re-parse（增量解析为后续可做）。 |
| 定义/悬停 | O(当前函数) | 已做**行/区间索引**：按行定位到包含该行的函数，只遍历该函数 body（及顶层 let）。 |
| 引用 references | O(全模块) | 当前 `collect_refs_to_func` 遍历所有函数 body 收集调用点；可做「引用索引」预计算或按函数缩小范围。 |
| 诊断 JSON 缓存 | 动态扩容 | 已做：缓存区按需 realloc，上限 2MB，避免诊断极多时截断。 |

### 8.3 已做优化：支持「几 M」级单文件

- **单文件/单请求体**：文档与 body 由 C 侧堆分配，单条消息安全上限 64MB；**几 M 单文件可支持**。  
- **行/区间索引**：`build_line_index` 为每个函数建立 `[start_line, end_line]`，definition / references（目标函数查找）/ hover 先 `get_function_at_line` 再只遍历该函数（及顶层 let），大文件下显著减少遍历量。  
- **诊断缓存**：诊断结果 JSON 使用动态缓冲区（初始 8KB，按需扩容至 2MB），诊断条数很多时不再截断。

### 8.4 建议与后续可做

- **推荐**：单文件 **&lt; 64MB** 可完整使用；行索引使 definition/hover 在大文件中只扫当前函数；references 仍为全模块遍历。  
- **后续可做（进一步压榨）**：  
  - **懒加载 typeck**：仅对光标所在函数或当前可见区域做 typeck，其余按需再算（需 typeck 支持单函数/区间）。  
  - **增量解析**：文档变更时仅对编辑区间 re-parse，复用未改部分 AST（需 parser 支持部分解析与合并）。  
  - **References 索引**：在 `build_line_index` 时或首次 references 请求时，为「每个函数」预计算被引用位置（谁调谁），references 请求变为 O(目标函数) 查找，避免每次全模块遍历。  
  - **读头优化**：`lsp_read_line` 当前逐字节读 Header；可改为「先读一块（如 256B）再在块内找 `\r\n` 和 Content-Length」，减少 syscall。  
  - **哈希**：大文档缓存校验用 djb2 已 4 字节展开；若仍为热点可换 xxHash 等更快哈希（需引入小依赖或手写 32/64 位版本）。  
  - **didChange 增量**：LSP 支持 `contentChanges` 的 range + text；若解析 range 并只替换文档片段，可避免整份 body 提取 + 整份文档替换（需 C 侧或 .sx 维护文档并支持 range 更新）。

---

## 九、参考

- [LSP 官方规范](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/)
- [vscode-languageserver (Node)](https://github.com/microsoft/vscode-languageserver)
- [VSCode 语言服务器扩展指南](https://code.visualstudio.com/api/language-extensions/language-server-extension-guide)
- 本项目：`analysis/VSCode插件分析与实现指南.md`、`compiler/include/ast.h`、`compiler/include/token.h`、`compiler/src/typeck/typeck.c`、`compiler/src/parser/parser.c`、`compiler/src/pipeline/pipeline.sx`（.sx 调用 parse/typeck 的现有入口）

