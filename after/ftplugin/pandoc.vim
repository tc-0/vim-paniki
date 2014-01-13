
nnoremap <CR> :call <SID>OpenLinkUnderCursor()<CR>

function! s:OpenLinkUnderCursor()
  let link = s:getLink()
  " if link does not start with any scheme http://, file://, it is treated as a wiki link.
  if link =~ 'http://\|file://\|https://'
    execute '!xdg-open ' . link . '&'
  else
    let directory = expand("%:p:h") . "/"
    execute "edit " . link
  endif
endfunction

function! s:getLink()
  let stack = synstack(line("."), col("."))
  let matches = []
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

