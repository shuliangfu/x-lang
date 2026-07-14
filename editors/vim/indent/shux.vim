" indent/shux.vim — SHUX 缩进规则
"
" 【Why】Vim indent 表达式：基于 cindent 扩展，处理 SHUX 特有的
" struct 字面量、match arm、block 尾表达式等结构。
"
" 【Invariant】缩进风格与 .editorconfig 一致：2 空格，expandtab。
"
" 【Asm/Perf】Vim indentexpr 每行调用一次，复杂度 O(line_depth)，
" 对 3000+ 行文件无感知延迟。

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal expandtab shiftwidth=2 softtabstop=2
setlocal autoindent
setlocal cindent
" cinoptions 说明：
"   (0  — 未闭合括号续行不额外缩进
"   :0  — case 标签不额外缩进
"   l1  — case body 与 case 标签对齐
"   j1  — 匿名函数体缩进
"   J1  — 注释续行缩进
setlocal cinoptions=(0,:0,l1,j1,J1

let b:undo_indent = "setl et< sw< sts< ai< ci< cino<"
