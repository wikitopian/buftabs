"let t:buftab_filters=[{'pattern':'[root_tail]', 'value':'buftabs'}]

function s:GetFilters()
  let l:filters = []
  if exists("g:buftab_filters")
    let l:filters = l:filters + g:buftab_filters
  endif
  if exists("t:buftab_filters")
    let l:filters = l:filters + t:buftab_filters
  endif
  if exists("w:buftab_filters")
    let l:filters = l:filters + w:buftab_filters
  endif
  if exists("b:buftab_filters")
    let l:filters = l:filters + b:buftab_filters
  endif
  return l:filters
endfunction

function! g:BuftabsFilterFile(i)
  for filter in s:GetFilters()
    let l:pattern = filter['pattern']
    let l:value = filter['value']
    let l:actual_value = g:FormatFileName(l:pattern, a:i)
    if l:actual_value != l:value
      return 1
    endif
  endfor
  return 0
endfunction

function! g:BuftabsFilterTabProjectRootTail(root_tail)
  let l:filter = {'pattern':'[root_tail]', 'value':a:root_tail} 
  if !exists('t:buftab_filters')
    let t:buftab_filters=[]
  endif
  let t:buftab_filters = t:buftab_filters + [l:filter]
endfunction
