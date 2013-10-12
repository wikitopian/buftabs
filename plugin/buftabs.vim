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

"
" Don't bother when in diff mode
"

if &diff                                      
	finish
endif     


"
" Called on VimEnter event
"

function! Buftabs_enable()
	let w:buftabs_enabled = 1
endfunction

function! s:GetFormatterPattern()
  if exists("g:buftabs_formatter_pattern") 
    return g:buftabs_formatter_pattern
  else
    return "[bufnum]-[bufname]"
  endif
endfunction


"
" Persistent echo to avoid overwriting of status line when 'hidden' is enabled
" 

let s:Pecho=''
function! s:Pecho(msg)
	if &ut!=1|let s:hold_ut=&ut|let &ut=1|en
	let s:Pecho=a:msg
	aug Pecho
		au CursorHold * if s:Pecho!=''|echo s:Pecho
					\|let s:Pecho=''|let &ut=s:hold_ut|en
				\|aug Pecho|exe 'au!'|aug END|aug! Pecho
	aug END
endf


"
" Draw the buftabs
"

function! Buftabs_show(deleted_buf)

	let l:i = 1
	let s:list = ''
	let l:start = 0
	let l:end = 0
	if ! exists("w:from") 
		let w:from = 0
	endif

	if ! exists("w:buftabs_enabled")
		return
	endif

	let l:buftabs_marker_modified = "!"
	if exists("g:buftabs_marker_modified")
		let l:buftabs_marker_modified = g:buftabs_marker_modified
	endif

	let l:buftabs_separator = "-"
	if exists("g:buftabs_separator")
		let l:buftabs_separator = g:buftabs_separator
	endif

	let l:buftabs_marker_start = "["
	if exists("g:buftabs_marker_start")
		let l:buftabs_marker_start = g:buftabs_marker_start
	endif

	let l:buftabs_marker_end = "]"
	if exists("g:buftabs_marker_end")
		let l:buftabs_marker_end = g:buftabs_marker_end
	endif

	" Walk the list of buffers

	while(l:i <= bufnr('$'))

		" Only show buffers in the list, and omit help screens
	
		if buflisted(l:i) && getbufvar(l:i, "&modifiable") && a:deleted_buf != l:i

			" Get the name of the current buffer, and escape characters that might
			" mess up the statusline

      let l:name = g:FormatFileName(s:GetFormatterPattern(), l:i)
			let l:name = substitute(l:name, "%", "%%", "g")
			
			" Append the current buffer number and name to the list. If the buffer
			" is the active buffer, enclose it in some magick characters which will
			" be replaced by markers later. If it is modified, it is appended with
			" an appropriate symbol (an exclamation mark by default)

			if winbufnr(winnr()) == l:i
				let l:start = strlen(s:list)
				let s:list = s:list . "\x01"
			else
				let s:list = s:list . ' '
			endif
				
			let s:list = s:list . l:name

			if getbufvar(l:i, "&modified") == 1
				let s:list = s:list . l:buftabs_marker_modified
			endif
			
			if winbufnr(winnr()) == l:i
				let s:list = s:list . "\x02"
				let l:end = strlen(s:list)
			else
				let s:list = s:list . ' '
			endif
		end

		let l:i = l:i + 1
	endwhile

	" If the resulting list is too long to fit on the screen, chop
	" out the appropriate part

	let l:width = winwidth(0) - 12

	if(l:start < w:from) 
		let w:from = l:start - 1
	endif
	if l:end > w:from + l:width
		let w:from = l:end - l:width 
	endif
		
	let s:list = strpart(s:list, w:from, l:width)

	" Replace the magic characters by visible markers for highlighting the
	" current buffer. The markers can be simple characters like square brackets,
	" but can also be special codes with highlight groups
  
	if exists("g:buftabs_active_highlight_group")
		if exists("g:buftabs_in_statusline")
			let l:buftabs_marker_start = "%#" . g:buftabs_active_highlight_group . "#" . l:buftabs_marker_start
			let l:buftabs_marker_end = l:buftabs_marker_end . "%##"
		end
	end

	if exists("g:buftabs_inactive_highlight_group")
		if exists("g:buftabs_in_statusline")
			let s:list = '%#' . g:buftabs_inactive_highlight_group . '#' . s:list
			let s:list .= '%##'
			let l:buftabs_marker_end = l:buftabs_marker_end . '%#' . g:buftabs_inactive_highlight_group . '#'
		end
	end

	let s:list = substitute(s:list, "\x01", l:buftabs_marker_start, 'g')
	let s:list = substitute(s:list, "\x02", l:buftabs_marker_end, 'g')

	" Show the list. The buftabs_in_statusline variable determines of the list
	" is displayed in the command line (volatile) or in the statusline
	" (persistent)

	if exists("g:buftabs_in_statusline")
		" Only overwrite the statusline if buftabs#statusline() has not been
		" used to specify a location
		if match(&statusline, "%{buftabs#statusline()}") == -1
			let &l:statusline = s:list . g:buftabs_original_statusline
		end
	else
		redraw
		call s:Pecho(s:list)
	end

endfunction


"
" Optional function returning the current buftabs list string which can
" be used inside the statusline string using the %{buftabs#statusline()}
" syntax
"

function! buftabs#statusline(...)
	return s:list
endfunction


"
" Hook to events to show buftabs at startup, when creating and when switching
" buffers
"

autocmd VimEnter,WinEnter * call Buftabs_enable()
autocmd VimEnter,BufNew,BufEnter,BufWritePost * call Buftabs_show(-1)
autocmd BufDelete * call Buftabs_show(expand('<abuf>'))
if version >= 700
	autocmd InsertLeave,VimResized * call Buftabs_show(-1)
end

" vi: ts=2 sw=2

