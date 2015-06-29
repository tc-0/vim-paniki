if ( exists('g:loaded_paniki') && g:loaded_paniki ) || &cp
  finish
endif

let g:loaded_paniki = 1

au Syntax pandoc nnoremap <buffer> <silent> <localleader>gl :call paniki_links#OpenLinkUnderCursor('edit')<CR>
au Syntax pandoc nnoremap <buffer> <silent> <localleader>sl :call paniki_links#OpenLinkUnderCursor('split')<CR>
au Syntax pandoc nnoremap <buffer> <silent> <BS> :call paniki_links#BackLink()<CR>

au Syntax pandoc command! Wiki2Html call pandoc_exec#PandocExecute( 'pandoc -o '
      \ . expand('%:p:h') . '/html/' . expand('%:t:r') . '.html '
      \ . '-Ss --filter ' . paniki_links#LinkFilter() . ' --csl ' . expand(g:pandoc_cslfile) . ' PANDOC#P_BIBS %%', 'html', 0 )

au Syntax pandoc nnoremap <buffer> <silent> <localleader>wh :Wiki2Html<CR>
