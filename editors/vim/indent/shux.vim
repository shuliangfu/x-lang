" indent/shux.vim — SHUX 缩进规则（indentexpr）
"
" 【Why 逻辑根源】基于 cindent 扩展，处理 SHUX 特有的 struct 字面量、
" match arm =>、block 尾表达式等结构。cindent 对 C 风格 block 缩进良好，
" 但不理解 SHUX 的 match/struct literal 语义，需要 indentexpr 覆盖。
"
" 【Invariant】缩进风格与 .editorconfig 一致：2 空格，expandtab。
" indentexpr 返回负数表示用自动缩进，返回 0 表示不缩进。
"
" 【Asm/Perf】indentexpr 每行调用一次，O(line_depth) 查找上下文，
" 对 3000+ 行文件无感知延迟（Vim 仅在可见区域计算缩进）。

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal expandtab shiftwidth=2 softtabstop=2
setlocal autoindent
setlocal cindent
" cindent 基础参数（indentexpr 会覆盖部分行为）
setlocal cinoptions=(0,:0,l1,j1,J1
" 用 indentexpr 接管，cindent 作为 fallback
setlocal indentexpr=ShuxIndent()
setlocal indentkeys-=0{,0}
setlocal indentkeys+=0=},0=else,0=},0=),0=],0=>>,0=//

let b:undo_indent = "setl et< sw< sts< ai< ci< cino< inde< indk<"

" ==================== ShuxIndent 主函数 ====================

function! ShuxIndent() abort
  let prev_lnum = prevnonblank(v:lnum - 1)
  if prev_lnum == 0
    return 0
  endif

  let prev_line = getline(prev_lnum)
  let curr_line = getline(v:lnum)
  let prev_indent = indent(prev_lnum)

  " 1. 当前行以 } ) ] 开头：回退一级
  if curr_line =~ '^\s*[})\]]'
    return prev_indent - &shiftwidth
  endif

  " 2. 当前行以 else 开头：与对应 if 对齐
  if curr_line =~ '^\s*else'
    return prev_indent
  endif

  " 3. 当前行是 match arm（pattern => ...）：与 match 关键字对齐或 +1
  if curr_line =~ '^\s*\S.*=>'
    " 检查是否在 match 块内
    let match_line = s:FindEnclosingMatch(prev_lnum)
    if match_line > 0
      return indent(match_line) + &shiftwidth
    endif
  endif

  " 4. 上一行以 { ( [ 结尾：缩进一级
  if prev_line =~ '[{(\[]\s*$'
    return prev_indent + &shiftwidth
  endif

  " 5. 上一行是 match => 后的值续行
  if prev_line =~ '=>\s*$'
    return prev_indent + &shiftwidth
  endif

  " 6. 上一行是 struct literal 字段（Type { field: value,）
  if prev_line =~ '^\s*\w\+:\s*.*,\s*$' && s:InStructLiteral(prev_lnum)
    return prev_indent
  endif

  " 7. 上一行是 => 后的表达式续行（match arm 值换行）
  if s:InMatchArmContinuation(prev_lnum)
    let match_line = s:FindEnclosingMatch(prev_lnum)
    if match_line > 0
      return indent(match_line) + &shiftwidth * 2
    endif
  endif

  " 8. 链式方法调用续行（.method() 换行）
  if curr_line =~ '^\s*\.'
    return prev_indent + &shiftwidth
  endif

  " 9. fallback：用 cindent
  return cindent(v:lnum)
endfunction

" ==================== 辅助函数 ====================

" s:FindEnclosingMatch — 向上查找最近的未闭合 match 语句
function! s:FindEnclosingMatch(lnum) abort
  let lnum = a:lnum
  while lnum > 0
    let line = getline(lnum)
    if line =~ '^\s*match\s\+'
      return lnum
    endif
    if line =~ '^\s*}'
      " 遇到闭合 }，可能已离开 match 块
      let lnum = s:SkipClosedBlock(lnum)
      if lnum == 0 | break | endif
      continue
    endif
    let lnum -= 1
  endwhile
  return 0
endfunction

" s:SkipClosedBlock — 从 } 行向上跳到对应的 {
function! s:SkipClosedBlock(lnum) abort
  let depth = 1
  let lnum = a:lnum - 1
  while lnum > 0 && depth > 0
    let line = getline(lnum)
    let depth -= count(line, '}')
    let depth += count(line, '{')
    if depth <= 0
      return lnum - 1
    endif
    let lnum -= 1
  endwhile
  return 0
endfunction

" s:InStructLiteral — 判断当前行是否在 struct literal 内
" 【Why】struct literal 的字段换行应与首字段对齐，而非额外缩进
function! s:InStructLiteral(lnum) abort
  let lnum = a:lnum
  while lnum > 0
    let line = getline(lnum)
    " struct literal: Type { field: value
    if line =~ '\u[A-Za-z0-9_]*\s*{'
      return 1
    endif
    if line =~ '^\s*}'
      return 0
    endif
    " 遇到 function/struct 等声明，不在 literal 内
    if line =~ '^\s*\(function\|struct\|enum\|trait\|impl\|let\|const\|if\|else\|while\|for\|match\)\>'
      return 0
    endif
    let lnum -= 1
  endwhile
  return 0
endfunction

" s:InMatchArmContinuation — 判断当前行是否是 match arm 值的续行
function! s:InMatchArmContinuation(lnum) abort
  let line = getline(a:lnum)
  " 当前行不以 => 开头，但前一行有 =>
  if line =~ '=>'
    return 0
  endif
  let prev = getline(prevnonblank(a:lnum - 1))
  " 前一行有 => 且不以 ; 或 , 结尾
  if prev =~ '=>' && prev !~ '[;,]\s*$'
    return 1
  endif
  return 0
endfunction
