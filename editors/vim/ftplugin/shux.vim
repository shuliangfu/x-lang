" ftplugin/shux.vim — SHUX 文件类型设置
"
" 【Why】Vim filetype plugin：设置缩进、注释格式、匹配规则等。
" 仅在 filetype=shux 时加载，与 syntax/shux.vim 配合。

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ==================== 注释格式 ====================
" // 行注释（gcc 风格），支持 cindent 自动注释续行
setlocal commentstring=//\ %s
setlocal comments=://,:/*,:*\

" ==================== 缩进 ====================
" SHUX 用 2 空格缩进（与 .editorconfig 一致）
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

" 自动缩进：cindent 对 C 风格语言效果较好（SHUX 语法接近 C）
setlocal autoindent
setlocal cindent
" cindent 参数：对齐括号内续行，不额外缩进 case 标签
setlocal cinoptions+=(0,:0,l1

" ==================== 文本宽度 ====================
" 代码不自动换行，注释 100 字符
setlocal textwidth=0
setlocal formatoptions-=t
setlocal formatoptions+=croql

" ==================== 匹配括号 ====================
" % 跳转到配对的括号
setlocal matchpairs+=<:>

" ==================== 撤销设置 ====================
" 每次离开插入模式创建一个撤销点
let b:undo_ftplugin = "setl sw< ts< sts< et< ai< ci< cino< tw< fo< cms< com< mps<"
