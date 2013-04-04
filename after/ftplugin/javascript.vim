" set whitespace for javascript to always use 4 spaces instead of tabs
setlocal expandtab
setlocal shiftwidth=4
setlocal shiftround
setlocal tabstop=4

"shortcuts to add semicolon or comma at end of line
imap <Leader>; <Esc>A;<CR>
nmap <Leader>; A;<Esc>

imap <Leader>, <Esc>A,<CR>
nmap <Leader>, A,<Esc>

compiler jshint

"****************** MAPS ***************************************

if !hasmapto('<Plug>JSAppendSemicolon')
map <localleader>; <Plug>JSAppendSemicolon
endif

nnoremap <script> <Plug>JSAppendSemicolon <SID>AppendSemicolon
nnoremap <SID>AppendSemicolon :call <SID>AppendSemicolon()<CR>

function! s:AppendSemicolon()
execute "normal! mqA;\<esc>`q"
endfunction

function! s:OneVar(start, end)

        for lineNo in range(a:start, a:end)
                if lineNo == a:start && lineNo != a:end
                        exec lineNo . ":s/;/,/"
                elseif lineNo == a:end
                        exec lineNo . ":s/var/   /"
                else
                        exec lineNo . ":s/var/   /"
                        exec lineNo . ":s/;/,/"
                endif
        endfor
endf

:command! -range -nargs=0 JSOneVar call <SID>OneVar(<line1>,<line2>)

vnoremap <buffer> <localleader>o :JSOneVar<CR>

"****************** log function call **************************
"
if !hasmapto('<Plug>JSLogFunctionCall')
map <Leader>i <Plug>JSLogFunctionCall
endif

noremap <script> <Plug>JSLogFunctionCall <SID>LogFunctionCall
noremap <SID>LogFunctionCall :call <SID>LogFunctionCall()<CR>

"add trace statements after each function signature to trace the function
"calls and argument values
function! s:LogFunctionCall()

	"get file name to prepend 
	let filename = expand("%:t:r")

"find method style functions , ie. myMethod: function (arg) { ...
	if search('^\s\+\S\+:\s*function\s*(','bc') > 0
		"get line as string
		let line = getline(".")
		"strip multiline comments
		let cleanline = ""
		let startpos = 0
		let comment_start = match(line, '\v/\*', startpos)
		while comment_start > 0
				let cleanline = cleanline . strpart(line, startpos, comment_start - startpos) 
				let after_comment_start = comment_start + 2
				let comment_end = match(line, '\v\*/', after_comment_start)

				"if we found an end of the comment, set the pos to start after
				if comment_end > 0
					let startpos = comment_end + 2
				else
					"no end found ...
					"break out of while and stop adding to string
					break
				endif
			    "try to find another start of comment
				let comment_start = match(line, '\v/\*', startpos)
		endwhile	

		"add rest of line after last comment
		let cleanline = cleanline . strpart(line, startpos) 

        "get function name
		let fn = matchlist(line, '^\s\+\(\S\+\)\s*:')[1]

		"args is everything in brackets"
		let args = matchstr(cleanline, '(.*)')

		let niceargs = ""
		let argslist = matchlist(args, '\(\S\+\)')
		if len(argslist) > 0

			if stridx(args, ",") > 0 
				let commapos = 0
				let niceargs = niceargs . "(\" + "
				while match(args, ',', commapos + 1) != -1
					let oldcommapos = commapos
					let commapos = match(args, ',', oldcommapos + 1) 
					let myarg = strpart(args, oldcommapos, commapos - oldcommapos)
					let argname = matchlist(myarg, '\(\w\+\)')[1]
					let niceargs = niceargs . argname . " + \", \" + "
					"let niceargs = niceargs . argname
				endwhile
				"get the last one
				let lastarg = strpart(args, commapos, len(args)-commapos)
				let lastargname = matchlist(lastarg, '\(\w\+\)')[1]
				let niceargs = niceargs . lastargname . " + \")"

			else
				"only one argument
				let niceargs = "(\" + " . argslist[1] . " + \")"
			endif
		else
			let niceargs = "()"
		endif
	    "construct JSDev style log statement
		let log = "/*sig \"" . filename . "#" . fn . niceargs ."\" */"
		"find start brace -- will be on same or next line
		if match(getline("."),"{") !~ -1 
			"opening brace is on same line..."
			"open new line"
			normal o
			"add previously constructed log statement
			call setline(".", log)
		endif
	end
endfunction
