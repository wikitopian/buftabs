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

function! g:BuftabsDisplay(content)
  " Show the list. The s:config['display']['statusline'] setting determines of the list
  " is displayed in the command line (volatile) or in the statusline
  " (persistent)

  if g:BuftabsConfig()['display']['statusline']
    call s:DrawInStatusline(a:content)
  else
    redraw
    call s:Pecho(a:content)
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
