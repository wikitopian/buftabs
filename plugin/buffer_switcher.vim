function! s:CycleBuffers(increment)
  call s:CycleBuffersFrom(bufnr('%') + a:increment, a:increment, 1)
endfunction

function! s:BufferOverflowTo(newIndex, increment, allowCycle)
  echo 'You reached the last buffer!'
  if a:allowCycle 
    call s:CycleBuffersFrom(a:newIndex, a:increment, 0)
  else
    echo 'No more buffers!'
  end
endfunction

function! s:CycleBuffersFrom(start, increment, allowCycle)
  let l:min = 1
  let l:max = bufnr('$')
  let l:current = a:start
  let l:i = l:current

  if(l:i > l:max)
    call s:BufferOverflowTo(l:min, a:increment, a:allowCycle)
  elseif(l:i < l:min)
    call s:BufferOverflowTo(l:max, a:increment, a:allowCycle)
  elseif(buflisted(l:i) && g:BuftabsFilterFile(l:i)==0)
    exec 'b! ' . l:i
    return 0
  else
    call s:CycleBuffersFrom(l:i + a:increment, a:increment, a:allowCycle)
  endif
endfunction

function! g:BuftabsNext()
  call s:CycleBuffers(1)
endfunction

function! g:BuftabsPrevious()
  call s:CycleBuffers(-1)
endfunction
