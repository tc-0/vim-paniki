
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
  let stack = map(synstack(line("."), col(".")), 'synIDattr(v:val, "name")')

  let i = max( [
        \ index(stack, "pandocReferenceLabel"),
        \ index(stack, "pandocReferenceURL"),
        \ index(stack, "Operator")
        \ ] )
  if i == -1
    return ''
  endif

  if stack[i] == "Operator"
    " might happen, when on a closing bracket
    let stack = map(synstack(line("."), col(".")), 'synIDattr(v:val, "name")')
    let i = max( [
          \ index(stack, "pandocReferenceLabel"),
          \ index(stack, "pandocReferenceURL"),
          \ ] )
    if i == -1
      return ''
    endif
  endif

  let matches = []

  if stack[i] == "pandocReferenceLabel"
    " match next ](
    let [lnum,cnum] = searchpos( '\](', 'cnW', line('.') )
    let matches = matchlist( getline('.'), '(\s*\([^) "]*\)\s*\()\|"\)', cnum )
  elseif stack[i] == "pandocReferenceURL"
    " match previous ](
    let [lnum,cnum] = searchpos( '\](', 'bcnW', line('.') )
    let matches = matchlist( getline('.'), '(\s*\([^) "]*\)\s*\()\|"\)', cnum )
  else
    " should not happen?!
    return ''
  endif
  if len(matches) >= 1
    return matches[1]
  else
    " this might happen if the link name is not correct
    return ''
  endif
endfunction
