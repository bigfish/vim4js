"compiler to call jslint on javascript file

if exists('current_compiler')
  finish
endif
let current_compiler = 'jslint'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:jslint_onwrite')
    let g:jslint_onwrite = 1
endif

if !exists('g:jslint_lwindow')
    let g:jslint_lwindow = 1
endif

if exists(':JSLint') != 2
    command JSLint :call JSLint(0)
endif

CompilerSet efm=Lint\ at\ line\ %l\ character\ %c:\ %m
CompilerSet makeprg=jslint\ %\ $JSLINT_HOME/my_options.js 

if g:jslint_onwrite
    augroup javascript
        au!
        au BufWritePost * call JSLint(1)
    augroup end
endif


function! JSLint(saved)

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
      silent lmake
	"else
      "silent lmake!
	"endif

	if g:jslint_lwindow
		lwindow
	endif
	
endfunction
