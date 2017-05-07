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


if !exists("g:xz_gtags#auto_update_ft")
  let g:xz_gtags#auto_update_ft = ['*']
endif


let s:gpath_name  = 'GPATH'
let s:grtags_name = 'GRTAGS'
let s:gtags_name  = 'GTAGS'
let s:auto_update = g:xz_gtags#auto_update


function! s:gpath(objpath)
  return a:objpath . '/' . s:gpath_name
endfunction


function! s:grtags(objpath)
  return a:objpath . '/' . s:grtags_name
endfunction


function! s:gtags(objpath)
  return a:objpath . '/' . s:gtags_name
endfunction


function! s:is_objpath(objpath)
  return filereadable(s:gpath(a:objpath))
        \&& filereadable(s:grtags(a:objpath))
        \&& filereadable(s:gtags(a:objpath))
endfunction


function! s:clean(objpath)
  silent! execute '!rm ' . s:gpath(a:objpath) . ' 2>/dev/null'
  silent! execute '!rm ' . s:grtags(a:objpath) . ' 2>/dev/null'
  silent! execute '!rm ' . s:gtags(a:objpath) . ' 2>/dev/null'
endfunction


function! s:is_gitwd_enabled()
  let l:dotgit = getcwd().'/.git'
  if exepath('git') != '' && isdirectory(l:dotgit)
    return getcwd() == substitute(system('git rev-parse --show-toplevel 2> /dev/null'), '\n\+$', '', '')
  endif
  return 0
endfunction


function! s:set_objdir()
  if s:is_gitwd_enabled()
    let $MAKEOBJDIR = '.git'
  endif
endfunction


let s:Updater = {}

function s:Updater.echomsg(msg) dict
  if !self.is_single_update
    echohl WarningMsg | echomsg a:msg | echohl None
  endif
endfunction

function s:Updater.on_stdout(id, data) dict
  " no-op
endfunction

function s:Updater.on_stderr(id, data) dict
  call add(self.errors, join(a:data))
endfunction

function s:Updater.on_exit(id, data) dict
  if len(self.errors) > 0
    for l:err in self.errors
      if l:err != ''
        echoerr '[xz-gtags] ' . l:err
      endif
    endfor
    return
  endif
  call self.echomsg("[xz-gtags] Done")
endfunction

function s:Updater.run() dict abort
  if match(system('ps'), 'gtags.*-v') != -1
    call l:job.echomsg("[xz-gtags] Already started")
    return
  endif
  call s:set_objdir()
  if self.is_single_update
    silent! execute join(l:job.argv, ' ')
  else
    let l:job.id = jobstart(l:job.argv, l:job)
    call l:job.echomsg("[xz-gtags] Update started")
  endif
endfunction

function s:Updater.new(objpath, is_single_update) dict abort

  let l:job = copy(extend(s:Updater, {
        \'id': -1,
        \'objpath': a:objpath,
        \'argv': [],
        \'errors': [],
        \'is_single_update': 0
        \}))

  if s:is_objpath(a:objpath)
    let l:job.argv = ['global', '-q', '-u']
    if a:is_single_update
      call add(l:job.argv, "--single-update=\"" . expand("%") . "\"")
      let l:job.is_single_update = 1
      "echomsg join(l:job.argv, ' ')
    endif
  else
    let l:job.argv = ['gtags', '-O']
  endif
  return l:job
endfunction


function! xz_gtags#objpath()
  let l:path = getcwd()
  if s:is_objpath(l:path)
    return l:path
  endif
  if s:is_gitwd_enabled()
    return getcwd().'/.git'
  endif
  return l:path
endfunction


function! xz_gtags#gtags(...)
  if a:0 < 1
    return
  endif
  call s:set_objdir()
  silent! execute "Gtags " . a:{1}
endfunction


function! xz_gtags#clean()
  call s:clean(xz_gtags#objpath())
endfunction


function! xz_gtags#update()
  let l:job = s:Updater.new(xz_gtags#objpath(), 0)
  call l:job.run()
endfunction


function! xz_gtags#auto_update()
  if g:xz_gtags#auto_update
    if len(g:xz_gtags#auto_update_ft) == 0
      return
    endif
    if index(g:xz_gtags#auto_update_ft, '*') == -1 &&
          \ index(g:xz_gtags#auto_update_ft, expand("%:e")) == -1
      return
    endif
    let l:job = s:Updater.new(xz_gtags#objpath(), 1)
    call l:job.run()
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et foldenable foldmethod=marker foldcolumn=1
