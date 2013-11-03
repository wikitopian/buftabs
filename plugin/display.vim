"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" buftabs
"
" Copyright 2013 Jacek Szarski <jacek.szarski@gmail.com>
" Copyright 2006 - 2011 Ico Doornekamp
"
" This file is part of buftabs, released under GNU General Public License,
" please see LICENSE.md for details.
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:buftabs_original_statusline = matchstr(&statusline, "%=.*")

let s:Pecho=''
function! s:Pecho(msg)
  " Persistent echo to avoid overwriting of status line when 'hidden' is enabled
  if &ut!=1|let s:hold_ut=&ut|let &ut=1|en
  let s:Pecho=a:msg
  aug Pecho
    au CursorHold * if s:Pecho!=''|echo s:Pecho |let s:Pecho=''|let &ut=s:hold_ut|en |aug Pecho|exe 'au!'|aug END|aug! Pecho
  aug END
endf

function s:DrawInStatusline(content)
  " Only overwrite the statusline if g:BuftabsStatusline() has not been
  " used to specify a location
  if match(&statusline, "%{g:BuftabsStatusline()}") == -1
    let &l:statusline = a:content . g:buftabs_original_statusline
  end
endfunction

function s:JoinedContent(content, current_index)
  let l:index=1
  let l:output_before = ''
  let l:output_after = ''
  let l:output_active = 0
  for name in a:content
    if l:index < a:current_index
      let l:output_before .= ' ' . name . ' '
    elseif l:index == a:current_index
      let l:output_active = g:BuftabsConfig()['formatter_pattern']['start_marker'] . name . g:BuftabsConfig()['formatter_pattern']['end_marker']
    else
      let l:output_after .= ' ' . name . ' '
    endif
    let l:index += 1
  endfor

  let l:width = winwidth(0) - 5 - strlen(l:output_active)

  if strlen(l:output_after) > l:width
    let l:output_after = strpart(l:output_after, 0, l:width)
  endif

  let l:width -= strlen(l:output_after)

  if strlen(l:output_before) > l:width
    let l:output_before = strpart(l:output_before, strlen(l:output_before) - l:width , l:width)
  endif

  return [l:output_before, l:output_active, l:output_after]
endfunction

function! g:BuftabsDisplay(content, current_index)
  let l:joined_content = s:JoinedContent(a:content, a:current_index)
         
  let l:output = g:BuftabsConfig()['formatter_pattern']['list_prefix'] . l:joined_content[0]
  if l:joined_content[1] != ''
    let l:output .= g:BuftabsConfig()['formatter_pattern']['active_prefix'] . l:joined_content[1] . g:BuftabsConfig()['formatter_pattern']['active_suffix']
  endif
  let l:output .= l:joined_content[2] . g:BuftabsConfig()['formatter_pattern']['list_suffix']

  " Show the list. The s:config['display']['statusline'] setting determines of the list
  " is displayed in the command line (volatile) or in the statusline
  " (persistent)

  if g:BuftabsConfig()['display']['statusline']
    call s:DrawInStatusline(l:output)
  else
    redraw
    call s:Pecho(l:output)
  end
endfunction


"
" Optional function returning the current buftabs list string which can
" be used inside the statusline string using the %{g:BuftabsStatusline()}
" syntax
"

function! g:BuftabsStatusline(...)
	return s:list
endfunction
