" filetype plugin for javascript
" David Wilhelm
" dewilhelm@gmail.com
" 15 July 2010
" Note: this must precede $VIMRUNTIME in runtimepath
" or it will not load.. the default javascript ftplugin will load

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" ******************* copied from system ftplugin ***********************
" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal formatoptions-=t formatoptions+=croql

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal commentstring=//%s

" Change the :browse e filter to primarily show Javascript-related files.
if has("gui_win32")
    let  b:browsefilter="Javascript Files (*.js)\t*.js\n"
		\	"All Files (*.*)\t*.*\n"
endif

" ******************* end copy paste from system ftplugin ******************

"default compiler
:compiler jslint

"DOM docs
let g:HTMLSpecUrl = "http://html5/index.html"
let g:ExtDocUrl = "http://extdocs/docs/?class="

"used in templates, default to false
let s:class_singleton = 0
let s:global = 0

"tab stuff should be in .vimrc
"expand tabs to 4 spaces
"setlocal noexpandtab
"setlocal shiftwidth=4
"setlocal shiftround
"setlocal tabstop=4

"js(b)eautify -- for some reason this opens folded comments
nnoremap <silent> <leader>b :call JSBeautify()<cr>

"cleanAndSave

if !hasmapto('<Plug>JSOpenDomDoc')
	map <Leader>d <Plug>JSOpenDomDoc
endif

noremap <script> <Plug>JSOpenDomDoc <SID>OpenDomDoc
noremap <SID>OpenDomDoc :call <SID>OpenDomDoc(expand("<cword>"))<CR>


if !exists(":JSOpenDomDoc")
	command -nargs=1 JSOpenDomDoc :call s:OpenDomDoc(<q-args>)
endif

function! s:OpenDomDoc(word)
	let tagmatches = taglist('^'.a:word.'$')
	if len(tagmatches) > 0
		let tagDct = get(tagmatches, 0)
		let docurl = get(tagDct, "link")
		if len(docurl) > 1
			let docurl =  escape (docurl, "#?&;|%")
			if has("macunix")
				execute "!open " . g:HTMLSpecUrl . docurl
			elseif has("unix")
				execute "!gnome-open " . g:HTMLSpecUrl . docurl 
			endif
		endif
	endif
endfunction

"Ext Docs
if !hasmapto('<Plug>JSOpenExtDoc')
	map <Leader>e <Plug>JSOpenExtDoc
endif

noremap <script> <Plug>JSOpenExtDoc <SID>OpenExtDoc
noremap <SID>OpenExtDoc :call <SID>OpenExtDoc(expand("<cword>"))<CR>


if !exists(":JSOpenExtDoc")
	command -nargs=1 JSOpenExtDoc :call s:OpenExtDoc(<q-args>)
endif

function! s:OpenExtDoc(word)
	let tagmatches = taglist('^'.a:word.'$')
	if len(tagmatches) > 0
		let tagDct = get(tagmatches, 0)
        let link = get(tagDct, "link")
		let docurl = g:ExtDocUrl . link
		if len(docurl) > 1
			let docurl =  escape (docurl, "#?&;|%")
			if has("macunix")
				execute "!open " . docurl
			elseif has("unix")
				execute "!gnome-open " . docurl
			endif
		endif
	endif
endfunction

"Ext Class
if !hasmapto('<Plug>ExtClass')
	map <Leader>c <Plug>ExtClass
endif

noremap <script> <Plug>ExtClass <SID>ExtClass
noremap <SID>ExtClass :call <SID>ExtClass()<CR>

if !exists(":ExtClass")
	command ExtClass :call s:ExtClass()
endif

function! s:ExtClass()

    let s:class_name = input("fully qualified class name: ")
	if s:class_name == "Global"
		let s:global = 1
		let s:singleton = 1
		"ie: don't allow global symbols as members of other objects 
	endif
    let s:class_descr = input("description: ")
	"skip extends and singleton questions for Global vars / functions
	if !s:global
		let s:class_extends = input("extends class: ")
		let s:class_singleton = input("is singleton ? [No]: ")
	endif

    "set cursor for appending lines
    let s:linenum = line(".")

    "start comment
    call s:AppendLine("/**")
    call s:AppendLine(" * @class ".s:class_name)

	"description
    if len(s:class_descr) > 0
        call s:AppendLine(" * ".s:class_descr)
    endif

	"singleton: default is no
	if len(s:class_singleton) > 0
		let s:class_singleton = 1
		call s:AppendLine(" * @singleton")
	else
		let s:class_singleton = 0
	endif

	"inheritance
    if len(s:class_extends) > 0
        "allow shortcut types for extends
        let s:class_extends = s:ExpandTypeName(s:class_extends)
        call s:AppendLine(" * @extends " . s:class_extends)
    else
        "all 'classes' implement Object.prototype
        call s:AppendLine(" * @extends Object")
    endif

	"close doc comment
    call s:AppendLine(" */")
	
    "constructor function
	"default = Object
    if len(s:class_extends) == 0
		let s:class_extends = "Object"
	endif

	"singletons are simply object literals
	if s:global
		"do not insert a constructor or container object literal
	elseif s:class_singleton
		call s:AppendLine(s:class_name . " = {")
		call s:AppendLine("     <++>")
		call s:AppendLine("};")
	else
		"using Ext.extend ..
		"TODO: allow library to be
		"configurable, to use Dojo, YUI, JQuery, or whatever
		"native inheritance is a bit awkward to templatize :(
		call s:AppendLine(s:class_name . " = Ext.extend(" . s:class_extends .", {") 
		call s:AppendLine("     <++>")
		call s:AppendLine("});")
	endif

endfunction
"/**
 "* @class Ext.CompositeElement
 "* @extends Ext.CompositeElementLite
 "* <p>This class encapsulates a <i>collection</i> of DOM elements, providing methods to filter
"Ext Property
if !hasmapto('<Plug>ExtProperty')
	map <Leader>p <Plug>ExtProperty
endif

noremap <script> <Plug>ExtProperty <SID>ExtProperty
noremap <SID>ExtProperty :call <SID>ExtProperty()<CR>

if !exists(":ExtProperty")
	command ExtProperty :call s:ExtProperty()
endif

"var which is a considered a property
if !hasmapto('<Plug>ExtVar')
	map <Leader>v <Plug>ExtVar
endif

noremap <script> <Plug>ExtVar <SID>ExtVar
noremap <SID>ExtVar :call <SID>ExtVar()<CR>

if !exists(":ExtVar")
	command ExtVar :call s:ExtVar()
endif

"global functions to be used in snippets
function! JSExtMethod()
	call s:ExtMethod()
	return ""
endfunction

function! JSExtProperty()
	call s:ExtProperty()
	return ""
endfunction

function! JSExtVar()
	call s:ExtVar()
	return ""
endfunction

"this function should be invoked after entering a property declaration with
"type-annotations, eg 
"	foo:s : "foo",

function! s:ExtProperty()

    "set cursor for appending lines
    let s:linenum = line(".")
	let s:curline = getline(s:linenum)
	"now set the insert position to the line above the current one
	let s:linenum -= 1
	"get the first name:Type occurrence -- note the type must not be separated from the
	"name by any white space
	let pml = matchlist(s:curline, '^\(\s*\)\([A-Za-z0-9_$]*\):\([A-Za-z_$]*\)')

	if len(pml) == 0

		echo "line does not match property template"
		return
	endif

	let s:indent = pml[1]
	let s:prop_name = pml[2]
    let s:prop_type = pml[3]
    
    "expand type shortcuts
    let s:prop_type = s:ExpandTypeName(s:prop_type)

    "start comment
	call s:AppendLine("")
    call s:AppendLine(s:indent . "/**")
    call s:AppendLine(s:indent . " * <+description+>")
    call s:AppendLine(s:indent . " * @type ".s:prop_type)
	"properties are static by default in singletons
	if s:class_singleton
		call s:AppendLine(s:indent . " * @static ")
	endif
    call s:AppendLine(s:indent . " */")

	"remove type annotations
	let line = getline(line("."))
	let newline = substitute(line, '\([A-Za-z0-9_$]\+\):[A-Za-z_$]\+', '\1','g')
	call setline(line("."),newline)

endfunction

function! s:ExtVar()

    "set cursor for appending lines
    let s:linenum = line(".")
	let s:curline = getline(s:linenum)
	"now set the insert position to the line above the current one
	let s:linenum -= 1
	"get the first name:Type occurrence -- note the type must not be separated from the
	"name by any white space
	let pml = matchlist(s:curline, '^\(\s*\)var\s\+\([A-Za-z_0-9$]*\):\([A-Za-z_$]*\)')

	if len(pml) == 0

		echo "line does not match var template"
		return
	endif

	let s:indent = pml[1]
	let s:prop_name = pml[2]
    let s:prop_type = pml[3]
    
    "expand type shortcuts
    let s:prop_type = s:ExpandTypeName(s:prop_type)

    "start comment
	call s:AppendLine("")
    call s:AppendLine(s:indent . "/**")
    call s:AppendLine(s:indent . " * <+description+>")
    call s:AppendLine(s:indent . " * @type ".s:prop_type)
	"properties are static by default in singletons
	if s:class_singleton
		call s:AppendLine(s:indent . " * @static ")
	endif
    call s:AppendLine(s:indent . " */")

	"remove type annotations
	let line = getline(line("."))
	let newline = substitute(line, '\([A-Za-z0-9_$]\+\):[A-Za-z_$]\+', '\1','g')
	call setline(line("."),newline)

endfunction

"Ext Method
if !hasmapto('<Plug>ExtMethod')
	map <Leader>m <Plug>ExtMethod
endif

noremap <script> <Plug>ExtMethod <SID>ExtMethod
noremap <SID>ExtMethod :call <SID>ExtMethod()<CR>

if !exists(":ExtMethod")
	command ExtMethod :call s:ExtMethod()
endif

function! s:ExtMethod()
	
    "set cursor for appending lines
    let s:linenum = line(".")
	let s:curline = getline(line("."))
	"now set the insert position to the line above the current one
	let s:linenum -= 1
	"match the method template pattern
	let mml = matchlist(s:curline, '^\(\s*\)\([A-Za-z0-9_$]*\)\s*[:=]\s*function\s\?(\([^)]*\)):\([A-Za-z_$]*\)')
	"check that we got a match, otherwise return
	if len(mml) == 0

		"try an old fashioned function declaration
		let mml = matchlist(s:curline, '^\(\s*\)function\s\?\([A-Za-z0-9_$]*\)\s\?(\([^)]*\)):\([A-Za-z_$]*\)')

		if len(mml) == 0
			"give up
			echo "line does not match method template"
			return
		endif

	endif

    let s:indent = mml[1]
    let s:meth_name = mml[2]
	let s:meth_sig = mml[3]
	let s:return_type = mml[4]

    "start comment
	call s:AppendLine("")
    call s:AppendLine(s:indent . "/**")
	call s:AppendLine(s:indent . " * <+description+>")

	"if we have any params
	if len(s:meth_sig) 
		"if we have multiple params
		if stridx(s:meth_sig, ',') > -1

			"split signature into parameters
			let s:params = split(s:meth_sig, ',\s\?')

			"append parameters
			for p in range(0, len(s:params) - 1)
				call s:ProcessParam(s:params[p])
			endfor
		else
			"single param
			call s:ProcessParam(s:meth_sig)
		endif
			
	endif
    let s:return_type = s:ExpandTypeName(s:return_type)
    call s:AppendLine(s:indent . " * @return {".s:return_type."} <+description+>")
	"properties are static by default if class is singleton 
	if s:class_singleton
		call s:AppendLine(s:indent . " * @static")
	endif
    "end comment
    call s:AppendLine(s:indent . " */")

	"strip off  type annotations and ? or *
	let line = getline(line("."))
	let newline = s:CleanLine(line)
	call setline(line("."),newline)

endfunction

"remove type annotations and quantifiers (make legal JavaScript)
function! s:CleanLine(line)
	let newline = substitute(a:line, '\([A-Za-z0-9_$]\+\)\?[?*]\?:[A-Za-z_$]\+', '\1','g')
	let newline = substitute(newline, ')\zs:[A-Za-z_$]\+', '','g')
	return newline

endfunction

function! s:ProcessParam(param)
	let param = a:param	
	let pl = split(param, ':')
	if len(pl) == 2
		let s:param_name = pl[0]

		"if name ends in ? it is optional
		if match(s:param_name, "?$") > -1
			let s:param_optional = "(optional)"
		else
			let s:param_optional = ""
		endif
		"leavae * on end of name for rest params
		"if name ends in * it is multiple
		"if match(s:param_name, "\*$") > -1
			"let s:param_multiple = "..."
		"else
			"let s:param_multiple = ""
		"endif

		"get type
		let s:param_type = pl[1]
	else
		echo "parameter does not have type annotation"
		return
	endif
	"expand type shortcuts
	let s:param_type = s:ExpandTypeName(s:param_type)
	"append line with param
	"call s:AppendLine(s:indent . " * @param {".s:param_type."} ".s:param_name.s:param_multiple.' '.s:param_optional.' <+description+>')
	call s:AppendLine(s:indent . " * @param {".s:param_type."} ".s:param_name.' '.s:param_optional.' <+description+>')
endfunction

function! s:AppendLine(newline)
 
    call append(s:linenum, a:newline)
    let s:linenum += 1

endfunction

function! s:ExpandTypeName(type_name)
        let t = a:type_name
        if t == "a"
            let t = "Array"
        elseif t == "b"
            let t = "Boolean"
        elseif t == "n"
            let t = "Number"
        elseif t == "o"
            let t = "Object"
        elseif t == "s"
            let t = "String"
        elseif t == "f"
            let t = "Function"
        elseif t == "u"
            let t = "undefined"
        elseif t == "*"
            let t = "any"
        endif
        return t
endfunction

function! s:JSSelectBlockComment()
	let startComment = search('/\*','bcW')
	if startComment
		"start linewise visual mode
		normal v
		"if we found a start of a multiline comment, find the end
		call search('\*/','cWe')
	endif

endfunction

if !exists(":JSSelectBlockComment")
	command JSSelectBlockComment :call s:JSSelectBlockComment()
endif

noremap <script> <Plug>JSSelectBlockComment <SID>JSSelectBlockComment
noremap <SID>JSSelectBlockComment :call <SID>JSSelectBlockComment()<CR>

if !hasmapto('<Plug>JSSelectBlockComment')
	map <Leader>cs <Plug>JSSelectBlockComment
endif

function! s:JSDeleteBlockComment()
	call s:JSSelectBlockComment()
	normal d
endfunction

if !exists(":JSDeleteBlockComment")
	command JSDeleteBlockComment :call s:JSDeleteBlockComment()
endif

if !hasmapto('<Plug>JSDeleteBlockComment')
	map <Leader>cd <Plug>JSDeleteBlockComment
endif

noremap <script> <Plug>JSDeleteBlockComment <SID>JSDeleteBlockComment
noremap <SID>JSDeleteBlockComment :call <SID>JSDeleteBlockComment()<CR>

setlocal fillchars="vert:,fold:"

"customize folds
function! JSFoldComment()
	"return getline(v:foldstart + 1);
    let line = getline(v:foldstart + 1)
    "let sub = substitute(line, '@', '', 'g')
    "return v:folddashes . sub
    return line
endfunction

function! JSFoldBlock()
	"return getline(v:foldstart + 1);
    let line = getline(v:foldstart + 0)
    "let sub = substitute(line, '@', '', 'g')
    "return v:folddashes . sub
    return line
endfunction

setl foldtext=JSFoldBlock()

if !hasmapto('<Plug>JSFoldDocComments')
	map <Leader>cc <Plug>JSFoldDocComments
endif

noremap <script> <Plug>JSFoldDocComments <SID>JSFoldDocComments
noremap <SID>JSFoldDocComments :call <SID>JSFoldDocComments()<CR>

if !exists(":JSFoldDocComments")
	command JSFoldDocComments :call s:JSFoldDocComments()
endif

function! s:JSFoldDocComments() 

	setl foldtext=JSFoldComment()

	"remember position
	normal mp
	normal gg
	"cannot create or erase folds with syntax folding
	normal zR

	"search forwards
	let s:startComment =  search('^\s*\/\*\*','cW')
	while  s:startComment
		"NB must be at end of line
		"this is to avoid matching this pattern in regexp
		let s:endComment = search('^\s*\*\/\s*$','W')
		"dont fold single lines
		if s:endComment && s:endComment > s:startComment 
			"with syntax folding (in syntax/javascript.vim)
			"all we have to do is close the fold
			normal zc
			"exec s:startComment . ',' . s:endComment . 'fold'
		endif
		"look for next one
		let s:startComment = search('^\s*\/\*\*\s*$','W')
	endwhile

	"restore pos
	normal 'p

	"unset fold func
	setl foldtext=JSFoldBlock()

endfunction

if !hasmapto('<Plug>JSFoldFunctions')
	map <Leader>ff <Plug>JSFoldFunctions
endif

noremap <script> <Plug>JSFoldFunctions <SID>JSFoldFunctions
noremap <SID>JSFoldFunctions :call <SID>JSFoldFunctions()<CR>

if !exists(":JSFoldFunctions")
	command JSFoldFunctions :call s:JSFoldFunctions()
endif

function! s:JSFoldFunctions()
	normal mp
	normal gg
	while search('function', 'W')
		"don't fold constructors
		let lineStr = getline('.')
		"this will work for function Xxx () {} constructors
		if match(lineStr, 'function [A-Z]\w\+([^)]*)') >= 0
			"do not fold
		else
			normal zc
		endif
	endwhile
	"restore pos
	normal 'p
endfunction

if !exists(":JSBeautify")
	command! -range=% -nargs=0 JSBeautify <line1>,<line2>!$JSBEAUTIFY/bin/beautify_js
endif

noremap <script> <Plug>JSBeautify <SID>JSBeautify
noremap <SID>JSBeautify :JSBeautify<CR>

if !hasmapto('<Plug>JSBeautify')
	map <Leader>b <Plug>JSBeautify
endif


"no longer used since the jslint compiler does all I need
"JSBeautify was a bit slow, and sometimes causes unwanted line-wrapping
"so it is only available as the command JSBeautify or its mapping <leader>b
"
"when saving file, run jsbeautify and jslint
function! JSSave()
	"JSBeautify loses position in file, removes markers :(
	"have to do some Vim gymnastics to save and restore position
	"using linenumbers only
	let curlinenum = line('.')
	normal H
	let toplinenum = line('.')

	exec ':JSBeautify'

	"call :JSFoldDocComments()

	"apply current tab settings
	exec ':retab'
	exec "normal ".toplinenum.'G'
	normal zt
	exec "normal ".curlinenum.'G'
	silent write
	
endfunction

let b:undo_ftplugin = "setl fo< ofu< com< cms<" 

"Search for references to current word
"requires grep_project script
"and that the project code is in a 'src' directory
"and that the current directory is beneath it
setlocal grepprg=grep_project\ $*
"TODO: make a command to search for current word
"this may require either a contextual lookup to infer the parent class
"of the word, or presenting the user with a list of tags to search for

"cscope mappings
"needs jscope bash script
"needs bash function in .bashrc :
"get_src_dir()
"{
"local PWD=$(pwd)
"echo "${PWD%src*}src"
"}
" (u)pdate db
if !hasmapto('<Plug>JSUpdateDB')
	map <Leader>u <Plug>JSUpdateDB
endif

noremap <script> <Plug>JSUpdateDB <SID>JSUpdateDB
noremap <SID>JSUpdateDB :call <SID>JSUpdateDB()<CR>

if !exists(":JSUpdateDB")
	command JSUpdateDB :call s:JSUpdateDB()
endif
function! s:JSUpdateDB()
	call system("jscope $(get_src_dir)")
endfunction

" (a)dd db
if !hasmapto('<Plug>JSAddDB')
	map <Leader>a <Plug>JSAddDB
endif

noremap <script> <Plug>JSAddDB <SID>JSAddDB
noremap <SID>JSAddDB :call <SID>JSAddDB()<CR>

if !exists(":JSAddDB")
	command JSAddDB :call s:JSAddDB()
endif
function! s:JSAddDB()

	"add db in case it does not exist 
	let db = system("find_cscope_db $(pwd)")
	"strip off ^J char that seems to be appended to shell output
	let db = strpart(db, 0, len(db) - 1)
	exec "cs add " . db 

endfunction

"find (r)eferences to current symbol (calls cscope)
"uses (t)ext search as others do not seem to work very well
nmap <Leader>r :scs find t <C-R>=expand("<cword>")<CR><CR>	

"****************** InstrumentClass (d = debug) ***********
if !hasmapto('<Plug>AS3InstrumentClass')
	map <Leader>d <Plug>AS3InstrumentClass
endif
noremap <script> <Plug>AS3InstrumentClass <SID>InstrumentClass
noremap <SID>InstrumentClass :call <SID>InstrumentClass()<CR>

"add trace statements after each function signature to trace the function
"calls and argument values
function! s:InstrumentClass()
	"get Class name to prepend 
	let cls = expand("%:t:r")
	"remember position 
	normal mp
	"goto start
	normal gg

	while search('function','W') > 0
		"1 copy function signature into variable"
		let sig = getline(".")
		"2 construct trace statement"
		let sig = matchstr(sig, '\w\+([^)]*)')
		let fn = matchstr(sig, '\w\+')
		let st = stridx(sig, "(") + 1
		let en = stridx(sig, ")")
		"args is everything in brackets"
		let args = strpart(sig, st, en-st)
		"niceargs is formatted for tracing"
		let niceargs = ""
		let argslist = matchlist(args, '\(\w\+\)')
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

		let trace = "console.log(\"" . cls .":" . fn . niceargs ."\" );"
		"find start brace -- will be on same or next line
		if match(getline("."),"{") !~ -1 
			"opening brace is on same line..."
			"open new line"
			normal o
			"add previously constructed trace statement
			call setline(".", trace)
		endif
	endwhile
endfunction

if !hasmapto('<Plug>JSNoLog')
	map <Leader>n <Plug>JSNoLog
endif
noremap <script> <Plug>JSNoLog <SID>NoLog
noremap <SID>NoLog :call <SID>NoLog()<CR>

function! s:NoLog()
	"to confirm
	":%s/^.*console\.log(.*).*$\n//gc
	:%s/^\s*console\.log(.*);\s*$\n//g
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
