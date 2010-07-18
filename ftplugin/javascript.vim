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

" Set completion with CTRL-X CTRL-O to autoloaded function.
if exists('&ofu')
    setlocal omnifunc=javascriptcomplete#CompleteJS
endif

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal commentstring=//%s

" Change the :browse e filter to primarily show Java-related files.
if has("gui_win32")
    let  b:browsefilter="Javascript Files (*.js)\t*.js\n"
		\	"All Files (*.*)\t*.*\n"
endif

" ******************* end copy paste from system ftplugin ******************

"error format for JSLint
set efm=Lint\ at\ line\ %l\ character\ %c:\ %m
"use bash script to filter unwanted errors
set makeprg=jslint\ %

"DOM docs
let g:HTMLSpecUrl = "http://html5/index.html"
let g:ExtDocUrl = "http://extdocs/docs/?class="

"used in templates, default to false
let s:class_singleton = 0

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
    let s:class_descr = input("description: ")
    let s:class_extends = input("extends class: ")
    let s:class_singleton = input("is singleton ? [No]: ")


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
		call s:AppendLine(" * @singeleton")
	else
		let s:class_singleton = 0
	endif

	"inheritance
    if len(s:class_extends) > 0
        "allow shortcut types for extends
        let s:class_extends = s:ExpandTypeName(s:class_extends)
        call s:AppendLine(" * @extends ".s:class_extends)
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
	if s:class_singleton
		call s:AppendLine(s:class_name . " = {" 
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

function! s:ExtProperty()

    let s:prop_name = input("prop name: ")
    let s:prop_descr = input("'" . s:prop_name . "' description: ")
    let s:prop_type = input("'" . s:prop_name . "' type: ")

	"properties are static by default if class is singleton
	if s:class_singleton
		let s:prop_static = 1
		"any input changes the default (typically this will be 'n' or 'no')
		let s:prop_static_in = input("'" . s:prop_name . "' is static property? [Yes]: ")
		if len(s:prop_static)
			let s:prop_static = 0
		endif
	else
		let s:prop_static = 0
		"any input changes the default (typically this will be 'y' or 'yes')
		let s:prop_static_in = input("'" . s:prop_name . "' is static property? [No]: ")
		if len(s:prop_static_in)
			let s:prop_static = 1
		endif
	endif
    
    "expand type shortcuts
    let s:prop_type = s:ExpandTypeName(s:prop_type)

    "set cursor for appending lines
    let s:linenum = line(".")

    "start comment
    call s:AppendLine("    /**")
    call s:AppendLine("     * ".s:prop_descr)
    call s:AppendLine("     * @type ".s:prop_type)
    call s:AppendLine("     */")

    call s:AppendLine("    " . s:prop_name . " :<++>,<++>")

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
    let s:meth_name = input("method name: ")
    let s:meth_descr = input("description: ")
    let s:num_params = input("# params: ")
    "set cursor for appending lines
    let s:linenum = line(".")
    "start comment
    call s:AppendLine("    /**")
    "append description
    if len(s:meth_descr) > 0
        call s:AppendLine("     * ".s:meth_descr)
    endif
    "append parameters
    let s:params = []
    for p in range(1, s:num_params)
        let s:param_name = input("param ".p." name: ")
        "if name ends in ? it is optional
        if match(s:param_name, "?$") > -1
            let s:param_optional = "(optional)"
            "strip off ? so it is not added in generated function
            let s:param_name = strpart(s:param_name, 0, len(s:param_name) - 1)
        else
            let s:param_optional = ""
        endif
        "get type
        let s:param_type = input("param '".s:param_name."' type: ")

        "expand type shortcuts
        let s:param_type = s:ExpandTypeName(s:param_type)

        call add(s:params, {'name' : s:param_name, 'type' : s:param_type})

        "get description 
        let s:param_descr = input("param '". s:param_name."' description: ")

        "append line with param
        call s:AppendLine("     * @param {".s:param_type."} ".s:param_name.' '.s:param_optional.' '.s:param_descr)
    endfor
    "append return type
    let s:return_type = input("return type: ")
    let s:return_type = s:ExpandTypeName(s:return_type)
    call s:AppendLine("     * @return {".s:return_type."}")

	"properties are static by default if class is singleton
	"it is very rare one would override the default
	if s:class_singleton
		let s:meth_static = 1
		"any input changes the default (typically this will be 'n' or 'no')
		let s:meth_static_in = input("'" . s:meth_name . "' is static method? [Yes]: ")
		if len(s:meth_static)
			let s:meth_static = 0
		else
			call s:AppendLine("     * @static")
		endif
	else
		let s:meth_static = 0
		"any input changes the default (typically this will be 'y' or 'yes')
		let s:meth_static_in = input("'" . s:meth_name . "' is static method? [No]: ")
		if len(s:meth_static_in)
			let s:meth_static = 1
			call s:AppendLine("     * @static")
		endif
	endif

    "end comment
    call s:AppendLine("     */")
    "construct method declaration
    let s:method = "    ".s:meth_name." : function ("
    let isfirst = 1
    for param in s:params
        if isfirst
            let s:method .= param['name']
            let isfirst = 0
        else
            let s:method =  s:method . ', ' . param['name'] 
        endif
    endfor
    let s:method .= ") {"
    "append first line of declaration
    call s:AppendLine(s:method)
    "append line with jump marker
    call s:AppendLine("     <++>")
    "end function -- 
    call s:AppendLine("    },")
    call s:AppendLine("	 <++>")
    
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

       
let b:undo_ftplugin = "setl fo< ofu< com< cms<" 

let &cpo = s:cpo_save
unlet s:cpo_save
