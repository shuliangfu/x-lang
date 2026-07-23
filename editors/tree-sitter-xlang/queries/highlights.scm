; Tree-sitter highlight queries for Xlang
; 适用于 Neovim / Helix / Emacs (tree-sitter-mode) / Zed
;
; 【Why 逻辑根源】命名约定与 editors/vscode/grammars/x.tmLanguage.json
; 的 scope name 对齐，便于跨编辑器主题统一。

(line_comment) @comment.line
(hash_comment) @comment.line
(block_comment) @comment.block

; 属性
(attribute_item) @attribute
(attribute_name) @attribute

; 字符串
(string_literal) @string
(escape_sequence) @string.escape

; 数字
(integer_literal) @constant.numeric
(float_literal) @constant.numeric.float

; 布尔
(boolean_literal) @constant.builtin

; 关键字
[
  "function" "let" "const" "struct" "enum" "trait" "impl" "type"
] @keyword.storage.type

[
  "extern" "export" "packed" "soa" "align"
] @keyword.storage.modifier

[
  "if" "else" "match" "while" "for" "loop" "break" "continue" "return"
] @keyword.control

[
  "defer" "goto" "import" "as"
  "await" "region" "with_arena" "unsafe"
] @keyword

; panic / self 在 grammar 中是表达式节点（匿名 token），单独捕获
(panic_expression) @keyword
(self_expression) @keyword

; 基础类型
(primitive_type) @type.builtin

; 类型名
(type_name) @type

; 函数名
(function_declaration
  name: (identifier) @function)

; 调用
(call_expression
  function: (identifier) @function.call)

(method_call_expression
  method: (identifier) @function.method.call)

; 字段
(field_expression
  field: (identifier) @variable.other.member)

(struct_field
  name: (identifier) @variable.other.member)

; 参数
(parameter
  name: (identifier) @variable.parameter)

; 变量
(let_declaration
  name: (identifier) @variable)
(const_declaration
  name: (identifier) @constant)

; 标点
[
  "(" ")" "[" "]" "{" "}"
] @punctuation.bracket

[
  "," ";" ":" "."
] @punctuation.delimiter

[
  "=>"
] @punctuation.special

; 运算符
[
  "!" "*" "&" "-" "+"
  "/" "%" "<<" ">>"
  "==" "!=" "<" ">" "<=" ">="
  "&&" "||" "&" "|" "^"
  "=" "+=" "-=" "*=" "/=" "%="
] @operator

; abi 字符串
(abi_string) @string.special

; escape
(escape_sequence) @string.escape
