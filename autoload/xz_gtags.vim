"=============================================================================
"" File: xz-gtags.vim
" Author: kaizoa
" " Created: 2017-05-06
" "=============================================================================
scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:xz_gtags#auto_update")
  let g:xz_gtags#auto_update = 0
endif


let s:gpath_name  = 'GPATH'
let s:grtags_name = 'GRTAGS'
let s:gtags_name  = 'GTAGS'
let s:auto_update = g:xz_gtags#auto_update


function! s:gpath(dbpath)
  return a:dbpath . '/' . s:gpath_name
endfunction


function! s:grtags(dbpath)
  return a:dbpath . '/' . s:grtags_name
endfunction


function! s:gtags(dbpath)
  return a:dbpath . '/' . s:gtags_name
endfunction


function! s:is_dbpath(dbpath)
  return filereadable(s:gpath(a:dbpath))
        \&& filereadable(s:grtags(a:dbpath))
        \&& filereadable(s:gtags(a:dbpath))
endfunction


function! s:clean(dbpath)
  silent! execute '!rm ' . s:gpath(a:dbpath) . ' 2>/dev/null'
  silent! execute '!rm ' . s:grtags(a:dbpath) . ' 2>/dev/null'
  silent! execute '!rm ' . s:gtags(a:dbpath) . ' 2>/dev/null'
endfunction


function! s:update(dbpath)
  if match(system('ps'), 'gtags.*-v') != -1
    return
  endif

  if s:is_dbpath(a:dbpath)
    silent!  execute '!sh -c "global -uv ' . a:dbpath . '" 2>/dev/null &'
  else
    call s:clean(a:dbpath)
    silent!  execute '!sh -c "gtags -v ' . a:dbpath . '" 2>/dev/null &'
    redraw!
  endif
endfunction


function! xz_gtags#dbpath()
  let l:path = getcwd()
  if s:is_dbpath(l:path)
    return l:path
  endif
  if exepath('git') != ''
    let l:repos_root = substitute(system('git rev-parse --show-toplevel 2> /dev/null'), '\n\+$', '', '')
    if l:repos_root != ''
      return l:repos_root . '/.git'
    endif
  endif
  return l:path
endfunction


function! xz_gtags#clean()
  call s:clean(xz_gtags#dbpath())
endfunction


function! xz_gtags#update()
  call s:update(xz_gtags#dbpath())
endfunction


function! xz_gtags#auto_update()
  if g:xz_gtags#auto_update
    call s:update(xz_gtags#dbpath())
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et foldenable foldmethod=marker foldcolumn=1
