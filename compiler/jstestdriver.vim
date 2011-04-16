"compiler to call jslint on javascript file

if exists('current_compiler')
  finish
endif
let current_compiler = 'jstestdriver'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:jstestdriver_onwrite')
    let g:jstestdriver_onwrite = 1
endif

if !exists('g:jstestdriver_lwindow')
    let g:jstestdriver_lwindow = 1
endif

if exists(':JSRunTestDriver') != 2
    command JSRunTestDriver :call JSRunTestDriver(0)
endif

CompilerSet efm=%m:%f:%l 
CompilerSet makeprg=run_jstests

if g:jstestdriver_onwrite
    augroup javascript
        au!
        au BufWritePost * call JSRunTestDriver(1)
    augroup end
endif


function! JSRunTestDriver(saved)

    if !a:saved && &modified
        " Save before running
        write
    endif	

	"shellpipe
    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

      silent make!

	if g:jstestdriver_lwindow
		:cope
	endif
	
endfunction
