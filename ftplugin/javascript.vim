" filetype plugin for javascript
" David Wilhelm
" dewilhelm@gmail.com
" 28 April 2010

set efm=Lint\ at\ line\ %l\ character\ %c:\ %m
"use bash script to filter unwanted errors
set makeprg=jslint\ %

let g:HTMLSpecUrl = "http://html5/index.html"

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

