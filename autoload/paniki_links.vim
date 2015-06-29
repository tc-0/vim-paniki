
let g:paniki_filter_dir = expand('<sfile>:p:h') . '/paniki-links'

function paniki_links#LinkFilter()
  return g:paniki_filter_dir
endfunction

function paniki_links#OpenLinkUnderCursor( editcmd )
  let link = paniki_links#getLink()
  if link =~ '\(\(http\|https\|ftp\)://\)\|\(mailto:\)'
    silent execute '!xdg-open "' . link . '"&'
  elseif link =~ 'file://'
    " strip 'file://'-prefix and expand filename 
    let link = expand(strpart(link,7))
    silent execute '!xdg-open "' .link . '"&'
  elseif link != ''
    if exists('+modified') && exists('+modifiable') && g:paniki_autowrite != 0
      silent execute "write"
    endif
    if a:editcmd != 'split' || a:editcmd != 'edit'
      echoerr 'editcmd should be either "split" or "edit".'
    endif
    if a:editcmd == 'edit'
      if exists('w:paniki_link_stack')
        add(w:paniki_link_stack, expand("%:p"))
      else
        w:paniki_link_stack = [expand("%:p")]
      endif
    endif
    silent execute a:editcmd . " " . expand("%:p:h") . "/" . link
  endif
endfunction

function paniki_links#BackLink()
  if exists('w:paniki_link_stack')
    let prev = remove(w:paniki_link_stack, -1)
    if exists('+modified') && exists('+modifiable') && g:paniki_autowrite != 0
      silent execute "write"
    endif
    silent execute "edit " . prev
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
