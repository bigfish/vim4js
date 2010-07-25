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

"error format for JSLint
set efm=Lint\ at\ line\ %l\ character\ %c:\ %m
set makeprg=jslint\ %

"DOM docs
let g:HTMLSpecUrl = "http://html5/index.html"
let g:ExtDocUrl = "http://extdocs/docs/?class="

"used in templates, default to false
let s:class_singleton = 0
let s:global = 0

"expand tabs to 4 spaces
setlocal expandtab
setlocal shiftwidth=4

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
	let pml = matchlist(s:curline, '^\(\s*\)\([A-Za-z_$]*\):\([A-Za-z_$]*\)')

	if len(pml) == 0

		Decho("line does not match property template")
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
	let newline = substitute(line, '\([A-Za-z_$]\+\):[A-Za-z_$]\+', '\1','g')
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
	let pml = matchlist(s:curline, '^\(\s*\)var\s\+\([A-Za-z_$]*\):\([A-Za-z_$]*\)')

	if len(pml) == 0

		Decho("line does not match var template")
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
	let newline = substitute(line, '\([A-Za-z_$]\+\):[A-Za-z_$]\+', '\1','g')
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
	let mml = matchlist(s:curline, '^\(\s*\)\([A-Za-z_$]*\)\s*[:=]\s*function\s\?(\([^)]*\)):\([A-Za-z_$]*\)')
	"check that we got a match, otherwise return
	if len(mml) == 0

		"try an old fashioned function declaration
		let mml = matchlist(s:curline, '^\(\s*\)function\s\?\([A-Za-z_$]*\)\s\?(\([^)]*\)):\([A-Za-z_$]*\)')

		if len(mml) == 0
			"give up
			Decho("line does not match method template")
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

	let newline = substitute(a:line, '\([A-Za-z_$]\+\)?\?\*\?:[A-Za-z_$]\+', '\1','g')
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
		Decho("parameter does not have type annotation")
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

function! JSSelectBlockComment()
	let s:startComment = search('^\s*/\*','bcW')
	if s:startComment
		"start linewise visual mode
		normal V
		"if we found a start of a multiline comment, find the end
		call search('\*/','cW')
	endif

endfunction

function! JSDeleteBlockComment()
	call JSSelectBlockComment()
	normal d
endfunction

setlocal fillchars="vert:,fold:"

"customize folds
function! JSFoldText()
	"return getline(v:foldstart + 1);
    let line = getline(v:foldstart + 1)
    "let sub = substitute(line, '@', '', 'g')
    "return v:folddashes . sub
    return line
endfunction

setl foldtext=JSFoldText()

if !hasmapto('<Plug>JSFoldDocComments')
	map <Leader>cc <Plug>JSFoldDocComments
endif

noremap <script> <Plug>JSFoldDocComments <SID>JSFoldDocComments
noremap <SID>JSFoldDocComments :call <SID>JSFoldDocComments()<CR>

if !exists(":JSFoldDocComments")
	command JSFoldDocComments :call s:JSFoldDocComments()
endif

function! s:JSFoldDocComments() 
	
	"remember position
	normal mp
	normal gg
	"cannot create or erase folds with syntax folding
	"normal zE

	"search forwards
	let s:startComment =  search('/\*\*','cW')
	while  s:startComment
		"set foldtext to next line of comment, usually a description
		"find matching end of comment
		"NB must be at end of line
		"this is to avoid matching this pattern in regexp
		let s:endComment = search('\*/\s*$','W')
		"dont fold single lines
		if s:endComment && s:endComment > s:startComment 
			"with syntax folding (in syntax/javascript.vim)
			"all we have to do is close the fold
			normal zc
			"exec s:startComment . ',' . s:endComment . 'fold'
		endif
		"look for next one
		let s:startComment = search('/\*\*','W')
	endwhile

	"restore pos
	normal 'p

endfunction

"when saving file, run jsbeautify and jslint
function! JSSave()
	call JSBeautify()
	call JSLint()
	"replace all hard tabs with spaces
	retab
	exec 'w'
endfunction
"wrapper to run jslint temporarily as make program 
"in case makeprg is being used for something else
function! JSLint()
	let s:save_makeprg = &makeprg
	let s:save_efm = &efm
	set efm=Lint\ at\ line\ %l\ character\ %c:\ %m
	set makeprg=jslint\ %
	:make
	let &makeprg = s:save_makeprg 
	let &efm = s:save_efm
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

let &cpo = s:cpo_save
unlet s:cpo_save
