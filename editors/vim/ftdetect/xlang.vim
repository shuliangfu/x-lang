" ftdetect/xlang.vim — XLANG 文件类型检测
" 【Why】*.x 默认被 Vim 内置 filetype.vim 关联到 rpcgen（RPC 编译器），
" 用 setlocal filetype=xlang 强制覆盖，确保 XLANG 语法高亮优先。
au BufRead,BufNewFile *.x setlocal filetype=xlang
