" filetype plugin for javascript
" David Wilhelm
" dewilhelm@gmail.com
" 28 April 2010

set efm=Lint\ at\ line\ %l\ character\ %c:\ %m
"use bash script to filter unwanted errors
set makeprg=jslint\ %

"DOM docs
let g:HTMLSpecUrl = "http://html5/index.html"
let g:ExtDocUrl = "http://extdocs/docs/?class="

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
    call s:AppendLine("     * ".s:meth_descr)
    "append parameters
    let s:params = []
    for p in range(1, s:num_params)
        let s:param_name = input("param ".p." name: ")
        let s:param_type = input("param ".p." type: ")
        call add(s:params, {'name' : s:param_name, 'type' : s:param_type})
        "expand type shortcuts
        let s:param_type = s:ExpandTypeName(s:param_type)
        "append line with param
        call s:AppendLine("     * @param {".s:param_type."} ".s:param_name)
    endfor
    "append return type
    let s:return_type = input("return type: ")
    let s:return_type = s:ExpandTypeName(s:return_type)
    call s:AppendLine("     * @return {".s:return_type."}")
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
    call s:AppendLine("     },")
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
        endif
        return t
endfunction

