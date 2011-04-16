"compiler to call jslint on javascript file

if exists('current_compiler')
  finish
endif
let current_compiler = 'jslint_jstestdriver'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:jslint_jstestdriver_onwrite')
    let g:jslint_jstestdriver_onwrite = 1
endif

"config option to not open window automatically
if !exists('g:jslint_jstestdriver_window')
	let g:jslint_jstestdriver_window = 1
endif

if exists(':JSLintAndTest') != 2
    command JSLintAndTest :call JSLintAndTest(0)
endif

CompilerSet efm=Lint\ at\ line\ %l\ character\ %c:\ %m,%m:%f:%l 
CompilerSet makeprg=lint_and_test.pl\ %\ $JSLINT_HOME/options/my_options.js 

if g:jslint_jstestdriver_onwrite
    augroup javascript
        au!
        au BufWritePost * call JSLintAndTest(1)
    augroup end
endif


function! JSLintAndTest(saved)

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

    " If check is executed by buffer write - do not jump to first error
	"if !a:saved
      silent make!
	"else
      "silent lmake!
	"endif

	if g:jslint_jstestdriver_window
		"lwindow
		:cwindow
	endif
	
endfunction
