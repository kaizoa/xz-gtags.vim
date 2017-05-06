scriptencoding utf-8

if exists('g:xz_gtags_loaded')
  finish
endif

let g:xz_gtags_loaded = 1

if !exists('g:xz_gtags_bin')
  let g:xz_gtags_bin = exepath("gtags")
endif


if g:xz_gtags_bin != ""
  :execute "source " . fnamemodify(resolve(g:xz_gtags_bin), ":p:h:h"). "/share/gtags/gtags.vim"
endif


" vim: ts=2 sw=2 sts=2 et foldenable foldmethod=marker foldcolumn=1
