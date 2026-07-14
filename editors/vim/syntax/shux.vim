" syntax/shux.vim — SHUX 语法高亮（传统 Vim 正则语法）
"
" 【Why 逻辑根源】关键字列表权威来源为 compiler/src/lexer/lexer.x 的 try_keyword
" （字节码匹配）。本文件不引入新关键字，与 tree-sitter-shux/grammar.js 同源派生。
"
" 【Invariant】关键字 / 类型 / 运算符与 lexer.x 同步演进；禁止双权威。
"
" 【Asm/Perf】Vim syntax 采用正则逐行匹配，无增量解析；大文件高亮延迟 O(n)，
" 但 Vim 的 syntax 引擎有缓存，编辑时仅重算可见区域。

" 退出已有语法加载（防止重复加载）
if exists("b:current_syntax")
  finish
endif

" ==================== 关键字 ====================
" 【权威来源】lexer.x try_keyword 字节码匹配（line 132-490+）
" 控制流
syn keyword shuxConditional if else match
syn keyword shuxRepeat while for loop break continue
syn keyword shuxKeyword return defer goto
" 声明
syn keyword shuxDecl function struct enum trait impl type import const let
" 修饰符
syn keyword shuxModifier export extern packed soa align
" 其他
syn keyword shuxKeyword region with_arena unsafe as await async run spawn
syn keyword shuxBoolean true false
syn keyword shuxConstant self panic

" ==================== 类型 ====================
" 原始类型（lexer.x 无对应 token，typeck 直接按 name 识别）
syn keyword shuxType i8 i16 i32 i64 isize u8 u16 u32 u64 usize f32 f64 bool void i32x4 i32x8 i32x16 u32x4 u32x8 u32x16

" 大写开头的类型名（struct/enum/trait 名）
syn match shuxTypeName "\<\u[A-Za-z0-9_]*\>"

" ==================== 注释 ====================
" 行注释 //
syn match shuxComment "//.*$" contains=shuxTodo
" 块注释 /* */（支持嵌套，Vim 正则不支持递归，仅匹配单层）
syn region shuxComment start="/\*" end="\*/" contains=shuxTodo
" hash 注释 #（非 #[ 属性）
syn match shuxComment "#\[^[].*$" contains=shuxTodo

syn keyword shuxTodo TODO FIXME XXX HACK NOTE contained

" ==================== 属性 ====================
" #[name] 或 #[name(args)]
syn region shuxAttribute start="#\[" end="\]" contains=shuxAttributeArgs
syn match shuxAttributeArgs "[^[\]]*" contained

" ==================== 字符串 ====================
syn region shuxString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=shuxEscape
syn match shuxEscape "\\." contained

" ==================== 字符 ====================
syn region shuxChar start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=shuxEscape

" ==================== 数字 ====================
" 整数（十进制、十六进制、八进制、二进制）+ 可选类型后缀
syn match shuxNumber "\<0[xX][0-9a-fA-F]\+\>"
syn match shuxNumber "\<0[oO][0-7]\+\>"
syn match shuxNumber "\<0[bB][01]\+\>"
syn match shuxNumber "\<[0-9]\+\>"
" 浮点数
syn match shuxFloat "\<[0-9]\+\.[0-9]\+\([eE][+-]\?[0-9]\+\)\?\>"
syn match shuxFloat "\<[0-9]\+\.[0-9]\+[fF]\>"

" ==================== 运算符 ====================
syn match shuxOperator "[-+*/%&|^!~=<>]"
syn match shuxOperator "<<\|>>"
syn match shuxOperator "==\|!=\|<=\|>="
syn match shuxOperator "&&\|||"
syn match shuxOperator "+=\|-=\|*=\|/=\|%="
syn match shuxOperator "=>"

" ==================== 标点 ====================
syn match shuxDelimiter "[,;:.]"
syn match shuxBracket "[(){}\[\]]"

" ==================== allow(padding) ====================
" 特殊前缀（struct 前），不作为关键字单独高亮
syn match shuxModifier "\<allow\s*(\s*padding\s*)\>"

" ==================== extern ABI ====================
syn region shuxString start=+"C\|X"+ end=+"+ contained contains=shuxEscape

" ==================== 高亮链接 ====================
hi def link shuxConditional  Conditional
hi def link shuxRepeat       Repeat
hi def link shuxKeyword      Keyword
hi def link shuxDecl         Keyword
hi def link shuxModifier     StorageClass
hi def link shuxBoolean      Boolean
hi def link shuxConstant     Constant
hi def link shuxType         Type
hi def link shuxTypeName     Type
hi def link shuxComment      Comment
hi def link shuxTodo         Todo
hi def link shuxAttribute    PreProc
hi def link shuxAttributeArgs PreProc
hi def link shuxString       String
hi def link shuxChar         Character
hi def link shuxEscape       SpecialChar
hi def link shuxNumber       Number
hi def link shuxFloat        Float
hi def link shuxOperator     Operator
hi def link shuxDelimiter    Delimiter
hi def link shuxBracket      Delimiter

" ==================== 语法折叠 ====================
" 【Why】foldmethod=syntax 时，这些 fold region 提供按语法结构折叠能力
" 【Invariant】fold region 必须与 block {} 配对，不破坏高亮
" 【Asm/Perf】fold 仅在 foldmethod=syntax 时激活，无性能影响
syn region shuxFunctionFold start="^\s*\(export\s\+\)\?\(extern\s\+\(\("[CX]" \)\?\)\)\?function\s\+\w\+.*{$" end="^\s*}$" fold transparent keepend extend
syn region shuxBlockFold start="{" end="}" fold transparent
syn region shuxCommentFold start="/\*" end="\*/" fold transparent keepend extend

" 同步：用 function 声明作为同步点，避免大文件从头扫描
syn sync fromstart

let b:current_syntax = "shux"
