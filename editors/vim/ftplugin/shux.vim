" ftplugin/shux.vim — SHUX 文件类型设置
"
" 【Why 逻辑根源】Vim filetype plugin：集成缩进、注释、折叠、补全、文本对象、
" 跳转、matchit 等功能。仅在 filetype=shux 时加载。
"
" 【Invariant】所有 buffer-local 设置必须有 b:undo_ftplugin 恢复，
" 避免切换 filetype 时残留。
"
" 【Asm/Perf】omnifunc 仅在用户按 <C-x><C-o> 时触发；折叠仅在 foldmethod=syntax 时激活。

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" ==================== 注释格式 ====================
" 【Why】// 行注释，vim-commentary / nerdcommenter 自动识别 commentstring
setlocal commentstring=//\ %s
setlocal comments=://,:/*,:*\

" ==================== 缩进 ====================
" SHUX 用 2 空格缩进（与 .editorconfig 一致）
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent

" ==================== 语法折叠 ====================
" 【Why】foldmethod=syntax 利用 syntax/shux.vim 的 fold region
" foldlevel=1 默认折叠顶层 function，展开看细节
setlocal foldmethod=syntax
setlocal foldlevel=1
setlocal foldtext=shux#FoldText()

" ==================== 文本宽度 ====================
setlocal textwidth=0
setlocal formatoptions-=t
setlocal formatoptions+=croql

" ==================== 匹配括号 ====================
setlocal matchpairs+=<:>

" ==================== 补全 ====================
" 【Why】omnifunc 提供关键字 + 类型 + buffer 符号补全
" 触发：<C-x><C-o> 或 coc.nvim/LSP 接管后自动降级
setlocal omnifunc=shux#Complete

" ==================== matchit 增强 ====================
" 【Why】% 在 if/else、{}/[]/() 之间跳转
let b:match_words = '\<if\>:\<else\>,\<for\>:\<break\>:\<continue\>,\<while\>:\<break\>:\<continue\>,\<loop\>:\<break\>:\<continue\>,{:},(:),[:],/\*:\*/'

" ==================== 文本对象映射 ====================
" 【Why】af/if 操作 function，ab/ib 操作 block
" 用法：daf（删整个函数）、cif（改函数体）、vab（选整个 block）
vnoremap <buffer> <silent> af :<C-U>call shux#TextObject('af')<CR>
vnoremap <buffer> <silent> if :<C-U>call shux#TextObject('if')<CR>
vnoremap <buffer> <silent> ab :<C-U>call shux#TextObject('ab')<CR>
vnoremap <buffer> <silent> ib :<C-U>call shux#TextObject('ib')<CR>
onoremap <buffer> <silent> af :<C-U>call shux#TextObject('af')<CR>
onoremap <buffer> <silent> if :<C-U>call shux#TextObject('if')<CR>
onoremap <buffer> <silent> ab :<C-U>call shux#TextObject('ab')<CR>
onoremap <buffer> <silent> ib :<C-U>call shux#TextObject('ib')<CR>

" ==================== 注释切换映射 ====================
" 【Why】gcc 切换当前行注释，gc 切换选区注释（类似 vim-commentary）
nnoremap <buffer> <silent> gcc :call shux#ToggleComment()<CR>
vnoremap <buffer> <silent> gc :call shux#ToggleComment('v')<CR>

" ==================== 跳转映射 ====================
" 【Why】]f/[f 在函数间跳转，]s/[s 在 struct 间跳转
nnoremap <buffer> <silent> ]f :call shux#JumpFunction('next')<CR>
nnoremap <buffer> <silent> [f :call shux#JumpFunction('prev')<CR>
nnoremap <buffer> <silent> ]s :call shux#JumpStruct('next')<CR>
nnoremap <buffer> <silent> [s :call shux#JumpStruct('prev')<CR>

" ==================== 新建文件自动加载 skeleton ====================
" 【Why 逻辑根源】新建空 *.x 文件时自动插入版权头 + main 函数模板，
" 避免每次手动复制。路径解析走 &rtp，兼容 Vim packages / vim-plug / packer。
" 【Invariant】仅在 line('$')==1 且第 1 行为空时触发一次，不破坏已有内容。
" 【Asm/Perf】仅在 BufRead 新文件时执行一次，O(1) 开销。
if line('$') == 1 && empty(getline(1))
  let s:shux_skeleton = globpath(&rtp, 'skeleton/shux.x', 0, 1)
  if !empty(s:shux_skeleton)
    execute '0r ' . s:shux_skeleton[0]
    " 删除原空行（现已位于 buffer 末尾）
    execute line('$') . 'delete _'
    " 光标置于 main 函数体 return 行，便于用户立即编辑
    call cursor(5, 3)
  endif
endif

" ==================== 撤销设置 ====================
let b:undo_ftplugin = "setl sw< ts< sts< et< ai< tw< fo< cms< com< mps< fdm< fdl< fdt< ofu<| silent! vunmap <buffer> af | silent! vunmap <buffer> if | silent! vunmap <buffer> ab | silent! vunmap <buffer> ib | silent! ounmap <buffer> af | silent! ounmap <buffer> if | silent! ounmap <buffer> ab | silent! ounmap <buffer> ib | silent! nunmap <buffer> gcc | silent! vunmap <buffer> gc | silent! nunmap <buffer> ]f | silent! nunmap <buffer> [f | silent! nunmap <buffer> ]s | silent! nunmap <buffer> [s | unlet! b:match_words b:shux_symbols b:shux_symbols_tick"
