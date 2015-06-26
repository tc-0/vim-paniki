
let g:paniki_filter_dir = expand('<sfile>:p:h') . '/paniki-links'

function paniki_links#LinkFilter()
  return g:paniki_filter_dir
endfunction

function paniki_links#OpenLinkUnderCursor()
  let link = paniki_links#getLink()
  if link =~ '\(\(http\|https\|ftp\)://\)\|\(mailto:\)'
    silent execute '!xdg-open "' . link . '"&'
  elseif link =~ 'file://'
    " strip 'file://'-prefix and expand filename 
    let link = expand(strpart(link,7))
    silent execute '!xdg-open "' .link . '"&'
  elseif link != ''
    silent execute "edit ". expand("%:p:h") . "/" . link
  endif
endfunction

function! paniki_links#getLink()
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
