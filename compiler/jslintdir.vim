"compiler to call jslint on javascript file

if exists('current_compiler')
  finish
endif
let current_compiler = 'jslintdir'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:jslintdir_lwindow')
    let g:jslintdir_lwindow = 1
endif

if exists(':JSLintDir') != 2
    command JSLintDir :call JSLintDir()
endif

CompilerSet efm=%f:Lint\ at\ line\ %l\ character\ %c:\ %m
CompilerSet makeprg=lint_project 

function! JSLintDir()

	"shellpipe
    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

    silent lmake!

	if g:jslintdir_lwindow
		lwindow
	endif
	
endfunction
