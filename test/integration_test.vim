exec 'source ' . getcwd() . '/plugin/buftabs.vim'
exec 'source ' . getcwd() . '/plugin/config.vim'
exec 'source ' . getcwd() . '/plugin/formatter.vim'
exec 'source ' . getcwd() . '/plugin/rooter.vim'
exec 'source ' . getcwd() . '/plugin/display.vim'

function! TestBasics()
  let g:buftabs_in_statusline = 1
  call Describe("when set to display in statusline")
  call Buftabs_enable()
  call Buftabs_show(-1)
  call AssertEquals(&statusline, ' 1- [2-TestOutput]')
endf
