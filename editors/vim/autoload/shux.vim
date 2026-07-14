" autoload/shux.vim — SHUX 插件核心函数库
"
" 【Why 逻辑根源】补全候选/文本对象/状态栏等功能的实现层。
" 关键字列表权威来源为 lexer.x try_keyword，不引入新关键字。
"
" 【Invariant】所有函数无副作用，不修改 buffer 内容（文本对象除外）。
" 补全候选 = 关键字 + 原始类型 + buffer-local 符号（function/struct/enum/let）。
"
" 【Asm/Perf】补全扫描 buffer 仅在 omnifunc 调用时触发（用户按 <C-x><C-o>），
" O(n) 扫描当前文件，缓存到 b:shux_symbols 直到 buffer 修改。

" ==================== 关键字与类型（权威来源：lexer.x try_keyword） ====================

" 【Why】用 split() 而非多行 [...] 列表：Vim 9.1 在 -S 脚本模式下
" \ 行继续符不可靠，单行 split() 兼容所有 Vim 版本
let s:keywords = split('function let const if else while for loop break continue return defer match struct enum trait impl type import extern export packed soa align unsafe region with_arena as goto await async run spawn self panic true false')

let s:types = split('i8 i16 i32 i64 isize u8 u16 u32 u64 usize f32 f64 bool void i32x4 i32x8 i32x16 u32x4 u32x8 u32x16')

" ==================== 补全 ====================

" shux#Complete — omnifunc 入口
" 【Why】Vim 补全过程：findstart 阶段返回补全起点 col，base 阶段返回候选列表
function! shux#Complete(findstart, base) abort
  if a:findstart
    " 向左查找非单词字符，确定补全起点
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\w'
      let start -= 1
    endwhile
    return start
  endif

  let result = []

  " 1. 关键字补全
  for kw in s:keywords
    if kw =~ '^' . escape(a:base, '.*[]~\')
      call add(result, {'word': kw, 'kind': 'k', 'menu': 'keyword'})
    endif
  endfor

  " 2. 原始类型补全
  for ty in s:types
    if ty =~ '^' . escape(a:base, '.*[]~\')
      call add(result, {'word': ty, 'kind': 't', 'menu': 'type'})
    endif
  endfor

  " 3. buffer-local 符号补全（function/struct/enum/let/const）
  for sym in shux#ScanSymbols()
    if sym.word =~ '^' . escape(a:base, '.*[]~\')
      call add(result, sym)
    endif
  endfor

  return result
endfunction

" shux#ScanSymbols — 扫描当前 buffer 的符号定义
" 【Why】提供函数名/类型名/变量名补全，无需编译器
" 【Asm/Perf】O(n) 扫描，结果缓存到 b:shux_symbols，b:changedtick 变化时重扫
function! shux#ScanSymbols() abort
  if exists('b:shux_symbols') && exists('b:shux_symbols_tick') && b:shux_symbols_tick == b:changedtick
    return b:shux_symbols
  endif

  let symbols = []
  let lnum = 1
  while lnum <= line('$')
    let line = getline(lnum)

    " function name(...)
    let m = matchlist(line, '^\s*\(export\s\+\)\?\(extern\s\+\)\?function\s\+\(\w\+\)')
    if !empty(m)
      call add(symbols, {'word': m[3], 'kind': 'f', 'menu': 'function'})
    endif

    " struct Name
    let m = matchlist(line, '^\s*\(allow\s*(\s*padding\s*)\s*\)\?struct\s\+\(\u[A-Za-z0-9_]*\)')
    if !empty(m)
      call add(symbols, {'word': m[2], 'kind': 's', 'menu': 'struct'})
    endif

    " enum Name
    let m = matchlist(line, '^\s*enum\s\+\(\u[A-Za-z0-9_]*\)')
    if !empty(m)
      call add(symbols, {'word': m[1], 'kind': 'e', 'menu': 'enum'})
    endif

    " trait Name
    let m = matchlist(line, '^\s*trait\s\+\(\u[A-Za-z0-9_]*\)')
    if !empty(m)
      call add(symbols, {'word': m[1], 'kind': 't', 'menu': 'trait'})
    endif

    " let name / const name
    let m = matchlist(line, '^\s*let\s\+\(\w\+\)')
    if !empty(m)
      call add(symbols, {'word': m[1], 'kind': 'v', 'menu': 'let'})
    endif
    let m = matchlist(line, '^\s*const\s\+\(\w\+\)')
    if !empty(m)
      call add(symbols, {'word': m[1], 'kind': 'c', 'menu': 'const'})
    endif

    let lnum += 1
  endwhile

  let b:shux_symbols = symbols
  let b:shux_symbols_tick = b:changedtick
  return symbols
endfunction

" ==================== 文本对象 ====================

" shux#TextObject — function/block 文本对象
" 【Why】af（含 function 声明行）、if（仅 body）、ab（含括号）、ib（仅括号内）
" 用法：nnoremap <silent> af :<C-U>call shux#TextObject('af')<CR>
function! shux#TextObject(type) abort
  if a:type ==# 'af' || a:type ==# 'if'
    " 向上查找 function 声明行
    let start = search('^\s*\(export\s\+\)\?\(extern\s\+\)\?function\s\+\w\+', 'bnW')
    if start == 0
      " 没有 function，退化为 block 文本对象
      call shux#TextObject(a:type ==# 'af' ? 'ab' : 'ib')
      return
    endif
    " 从 function 行的 { 开始查找匹配的 }
    let brace_line = search('{', 'nW')
    if brace_line == 0 | return | endif
    " 用 searchpair 找配对的 }
    call cursor(brace_line, 1)
    let end_line = searchpair('{', '', '}', 'nW')
    if end_line == 0 | return | endif

    if a:type ==# 'af'
      execute 'normal! ' . start . 'GV' . end_line . 'G'
    else
      " if：仅 body（{ 行 + 1 到 } 行 - 1）
      let body_start = brace_line + 1
      let body_end = end_line - 1
      if body_start > body_end | return | endif
      execute 'normal! ' . body_start . 'GV' . body_end . 'G'
    endif
  elseif a:type ==# 'ab' || a:type ==# 'ib'
    " block 文本对象：基于 {} 配对
    let start = search('{', 'bcnW')
    if start == 0
      let start = search('{', 'nW')
      if start == 0 | return | endif
    endif
    call cursor(start, 1)
    let end_line = searchpair('{', '', '}', 'nW')
    if end_line == 0 | return | endif

    if a:type ==# 'ab'
      execute 'normal! ' . start . 'GV' . end_line . 'G'
    else
      let body_start = start + 1
      let body_end = end_line - 1
      if body_start > body_end | return | endif
      execute 'normal! ' . body_start . 'GV' . body_end . 'G'
    endif
  endif
endfunction

" ==================== 状态栏 ====================

" shux#CurrentFunction — 状态栏显示当前所在函数名
" 【Why】配合 lightline/airline，状态栏显示 fn:main 等上下文信息
function! shux#CurrentFunction() abort
  let pos = getpos('.')
  " 向上查找最近的 function 声明
  let line = search('^\s*\(export\s\+\)\?\(extern\s\+\)\?function\s\+\zs\w\+', 'bnW')
  if line == 0
    return ''
  endif
  let name = matchstr(getline(line), 'function\s\+\zs\w\+')
  return empty(name) ? '' : 'fn:' . name
endfunction

" shux#CurrentContext — 状态栏显示函数 + struct 上下文
function! shux#CurrentContext() abort
  let fn = shux#CurrentFunction()
  if !empty(fn)
    return fn
  endif
  " 不在函数内，检查是否在 struct/enum/trait 内
  let line = search('^\s*struct\s\+\zs\u[A-Za-z0-9_]*', 'bnW')
  if line > 0
    return 'st:' . matchstr(getline(line), 'struct\s\+\zs\u[A-Za-z0-9_]*')
  endif
  let line = search('^\s*enum\s\+\zs\u[A-Za-z0-9_]*', 'bnW')
  if line > 0
    return 'en:' . matchstr(getline(line), 'enum\s\+\zs\u[A-Za-z0-9_]*')
  endif
  return ''
endfunction

" ==================== 折叠文本 ====================

" shux#FoldText — 自定义折叠显示文本
" 【Why】默认折叠显示第一行，这里显示声明 + 行数，更清晰
function! shux#FoldText() abort
  let line = getline(v:foldstart)
  " 去除注释和多余空格
  let sub = substitute(line, '^\s*', '', '')
  let sub = substitute(sub, '/\*.*\*/', '', '')
  " 截断过长的行
  if strlen(sub) > 50
    let sub = strpart(sub, 0, 47) . '...'
  endif
  let lines = v:foldend - v:foldstart + 1
  return sub . ' (' . lines . ' lines) '
endfunction

" ==================== 注释切换 ====================

" shux#ToggleComment — 切换当前行/选区的 // 注释
" 【Why】不依赖 vim-commentary，提供内置注释切换
" 用法：nnoremap <buffer> gcc :call shux#ToggleComment()<CR>
"       vnoremap <buffer> gc :call shux#ToggleComment('v')<CR>
function! shux#ToggleComment(...) abort
  if a:0 > 0 && a:1 ==# 'v'
    let start = line("'<")
    let end = line("'>")
  else
    let start = line('.')
    let end = line('.')
  endif

  " 检查是否所有行都已注释
  let all_commented = 1
  for lnum in range(start, end)
    if getline(lnum) !~ '^\s*//'
      let all_commented = 0
      break
    endif
  endfor

  if all_commented
    " 取消注释
    for lnum in range(start, end)
      let line = getline(lnum)
      let line = substitute(line, '^\(\s*\)//\s\?', '\1', '')
      call setline(lnum, line)
    endfor
  else
    " 添加注释
    let indent = matchstr(getline(start), '^\s*')
    for lnum in range(start, end)
      let line = getline(lnum)
      if line !~ '^\s*$'
        call setline(lnum, indent . '// ' . substitute(line, '^\s*', '', ''))
      endif
    endfor
  endif
endfunction

" ==================== 跳转 ====================

" shux#JumpFunction — 跳转到下一个/上一个 function 声明
" 【Why】]f/[f 快速在函数间跳转
" 用法：nnoremap <buffer> ]f :call shux#JumpFunction('next')<CR>
"       nnoremap <buffer> [f :call shux#JumpFunction('prev')<CR>
function! shux#JumpFunction(direction) abort
  if a:direction ==# 'next'
    let line = search('^\s*\(export\s\+\)\?\(extern\s\+\)\?function\s\+\w\+', 'W')
  else
    let line = search('^\s*\(export\s\+\)\?\(extern\s\+\)\?function\s\+\w\+', 'bW')
  endif
  if line == 0
    echo 'No more functions'
  endif
endfunction

" shux#JumpStruct — 跳转到下一个/上一个 struct 声明
function! shux#JumpStruct(direction) abort
  if a:direction ==# 'next'
    let line = search('^\s*\(allow\s*(\s*padding\s*)\s*\)\?struct\s\+\u', 'W')
  else
    let line = search('^\s*\(allow\s*(\s*padding\s*)\s*\)\?struct\s\+\u', 'bW')
  endif
  if line == 0
    echo 'No more structs'
  endif
endfunction
