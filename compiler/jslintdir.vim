"compiler to call jslint on javascript file

if exists('current_compiler')
  finish
endif
let current_compiler = 'jslintdir'

if exists(":CompilerSet") != 2
	command -nargs=* CompilerSet setlocal <args>
endif

if !exists('g:jslintdir_cwindow')
    let g:jslintdir_cwindow = 1
endif

if exists(':JSLintDir') != 2
    command -nargs=1 JSLintDir :call JSLintDir(<args>)
endif

if exists(':JSLintProject') != 2
    command JSLintProject :call JSLintProject()
endif

CompilerSet efm=%f:Lint\ at\ line\ %l\ character\ %c:\ %m
CompilerSet makeprg=lintdir 

function! JSLintDir(dir)
	echo 'linting dir: ' . a:dir
	"shellpipe
    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

    exec 'silent make! ' . a:dir

	if g:jslintdir_cwindow
		cwindow
	endif
	
endfunction

function! JSLintProject()
	
	let dir = system("get_src_dir")
	call JSLintDir(dir)

endfunction
