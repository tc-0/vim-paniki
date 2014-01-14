if ( exists('g:loaded_paniki') && g:loaded_paniki ) || &cp
  finish
endif

let g:loaded_paniki = 1

function! s:OpenLinkUnderCursor()
  let link = s:getLink()
  if link =~ '\(\(http\|https\|ftp\)://\)\|\(mailto:\)'
    silent execute '!xdg-open "' . link . '"&'
  elseif link =~ 'file://'
    " strip 'file://'-prefix and expand filename 
    let link = expand(strpart(link,7))
    silent execute '!xdg-open "' .link . '"&'
  elseif link != ''
    let directory = expand("%:p:h") . "/"
    silent execute "edit " . link . ".pdc"
  endif
endfunction

function! s:getLink()
  let stack = synstack(line("."), col("."))
  if len(stack) < 1
    return ''
  endif
  let matches = []

  " Catch case where the cursor is at the very last paranthesis of the link.
  if synIDattr(stack[0], "name") == "Operator"
    let stack = synstack(line("."), col(".")-1)
  endif

  if synIDattr(stack[0], "name") == "pandocReferenceLabel"
    " match next ](
    let [lnum,cnum] = searchpos( '\](', 'cnW', line('.') )
    let matches = matchlist( getline('.'), '(\s*\([^) "]*\)\s*\()\|"\)', cnum )
  elseif synIDattr(stack[0], "name") == "pandocReferenceURL"
    " match previous ](
    let [lnum,cnum] = searchpos( '\](', 'bcnW', line('.') )
    let matches = matchlist( getline('.'), '(\s*\([^) "]*\)\s*\()\|"\)', cnum )
  else
    return ''
  endif
  if len(matches) >= 1
    return matches[1]
  else
    " this might happen if the link name is not correct
    return ''
  endif
endfunction

au Syntax pandoc nnoremap <buffer> <silent> <CR> :call <SID>OpenLinkUnderCursor()<CR>

