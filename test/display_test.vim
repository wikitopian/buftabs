exec 'source ' . getcwd() . '/plugin/display.vim'

let s:fake_config = {}
function FakeConfig(k1,k2,v)
  let s:fake_config[a:k1] = {}
  let s:fake_config[a:k1][a:k2] = a:v
endf

function g:BuftabsConfig()
  return s:fake_config
endf

function! TestBuftabsDisplay()
  let l:test_string = 'test_value'

  call Describe("when g:BuftabsConfig()['display']['statusline'] is true")
  let &statusline = ''
  call FakeConfig('display','statusline',1)
  call g:BuftabsDisplay(l:test_string)
  call AssertEquals(&statusline, l:test_string)

  call Describe("when g:BuftabsConfig()['display']['statusline'] is false")
  let &statusline = ''
  call FakeConfig('display','statusline',0)
  call g:BuftabsDisplay(l:test_string)
  call AssertEquals(&statusline, '')
endf
