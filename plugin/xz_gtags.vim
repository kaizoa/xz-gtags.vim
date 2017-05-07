"=============================================================================
"" File: xz-gtags.vim
" Author: kaizoa
" " Created: 2017-05-06
" "=============================================================================
scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


if !exists("g:xz_gtags#load_preset_plugin")
  let g:xz_gtags#load_preset_plugin = 1
endif


if !exists('g:xz_gtags#prog')
  let g:xz_gtags#prog = exepath("gtags")
endif


if g:xz_gtags#prog == ""
  finish
endif


function! s:load_preset_plugin() abort
  :execute "source " . fnamemodify(resolve(g:xz_gtags#prog), ":p:h:h"). "/share/gtags/gtags.vim"
  let g:xz_gtags#preset_plugin_loaded = 1
endfunction


if g:xz_gtags#load_preset_plugin && !exists('g:xz_gtags#preset_plugin_loaded')
  let g:xz_gtags#preset_plugin_loaded = 0
  call s:load_preset_plugin()
endif


augroup xz_gtags
  autocmd!
  autocmd BufWritePost * call xz_gtags#auto_update()
augroup END


command! -nargs=* XZGtags call xz_gtags#gtags(<q-args>)
command! XZGtagsUpdate call xz_gtags#update()
let &cpo = s:save_cpo
unlet s:save_cpo
" vim: ts=2 sw=2 sts=2 et foldenable foldmethod=marker foldcolumn=1
