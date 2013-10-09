"Vim color file
"
"Author: David Wilhelm <dewilhelm@gmail.com>
"
"Note: highlights function scopes in JavaScript
"hence not suitable as a multilingual colorscheme
"includes logic to parse the function scopes
"only supports terminal colors at this time	
"use XtermColorTable plugin to see what colors are available

"this colorsheme acts as an overlay over the existing highlighting

if exists('g:funcjs_colors')
	let s:fun_colors = g:funcjs_colors
else
	let s:fun_colors = [ 252, 10, 11, 172, 1, 161, 63 ]
endif


hi clear

set background=dark
if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
		syntax reset
    endif
endif
let g:colors_name="funcjs"

if exists("g:molokai_original")
    let s:molokai_original = g:molokai_original
else
    let s:molokai_original = 0
endif


hi Boolean         guifg=#AE81FF
hi Character       guifg=#E6DB74
hi Number          guifg=#AE81FF
hi String          guifg=#E6DB74
hi Conditional     guifg=#F92672               gui=bold
hi Constant        guifg=#AE81FF               gui=bold
hi Cursor          guifg=#000000 guibg=#F8F8F0
hi Debug           guifg=#BCA3A3               gui=bold
hi Define          guifg=#66D9EF
hi Delimiter       guifg=#8F8F8F
hi DiffAdd                       guibg=#13354A
hi DiffChange      guifg=#89807D guibg=#4C4745
hi DiffDelete      guifg=#960050 guibg=#1E0010
hi DiffText                      guibg=#4C4745 gui=italic,bold

hi Directory       guifg=#A6E22E               gui=bold
hi Error           guifg=#960050 guibg=#1E0010
hi ErrorMsg        guifg=#F92672 guibg=#232526 gui=bold
hi Exception       guifg=#A6E22E               gui=bold
hi Float           guifg=#AE81FF
hi FoldColumn      guifg=#465457 guibg=#000000
hi Folded          guifg=#465457 guibg=#000000
hi Function        guifg=#A6E22E
hi Identifier      guifg=#FD971F
hi Ignore          guifg=#808080 guibg=bg
hi IncSearch       guifg=#C4BE89 guibg=#000000

hi Keyword         guifg=#F92672               gui=bold
hi Label           guifg=#E6DB74               gui=none
hi Macro           guifg=#C4BE89               gui=italic
hi SpecialKey      guifg=#66D9EF               gui=italic

hi MatchParen      guifg=#000000 guibg=#FD971F gui=bold
hi ModeMsg         guifg=#E6DB74
hi MoreMsg         guifg=#E6DB74
hi Operator        guifg=#F92672

" complete menu
hi Pmenu           guifg=#66D9EF guibg=#000000
hi PmenuSel                      guibg=#808080
hi PmenuSbar                     guibg=#080808
hi PmenuThumb      guifg=#66D9EF

hi PreCondit       guifg=#A6E22E               gui=bold
hi PreProc         guifg=#A6E22E
hi Question        guifg=#66D9EF
hi Repeat          guifg=#F92672               gui=bold
hi Search          guifg=#FFFFFF guibg=#455354
" marks column
hi SignColumn      guifg=#A6E22E guibg=#232526
hi SpecialChar     guifg=#F92672               gui=bold

hi Special         guifg=#66D9EF guibg=bg      gui=italic
hi SpecialKey      guifg=#888A85               gui=italic
if has("spell")
    hi SpellBad    guisp=#FF0000 gui=undercurl
    hi SpellCap    guisp=#7070F0 gui=undercurl
    hi SpellLocal  guisp=#70F0F0 gui=undercurl
    hi SpellRare   guisp=#FFFFFF gui=undercurl
endif
hi Statement       guifg=#F92672               gui=bold
hi StatusLine      guifg=#455354 guibg=fg
hi StatusLineNC    guifg=#808080 guibg=#080808
hi StorageClass    guifg=#FD971F               gui=italic
hi Structure       guifg=#66D9EF
hi Tag             guifg=#F92672               gui=italic
hi Title           guifg=#ef5939
hi Todo            guifg=#FFFFFF guibg=bg      gui=bold

hi Typedef         guifg=#66D9EF
hi Type            guifg=#66D9EF               gui=none
hi Underlined      guifg=#808080               gui=underline

hi VertSplit       guifg=#808080 guibg=#080808 gui=bold
hi VisualNOS                     guibg=#403D3D
hi Visual                        guibg=#403D3D
hi WarningMsg      guifg=#FFFFFF guibg=#333333 gui=bold
hi WildMenu        guifg=#66D9EF guibg=#000000

if s:molokai_original == 1
   hi Normal          guifg=#F8F8F2 guibg=#272822
   hi Comment         guifg=#75715E
   hi CursorLine                    guibg=#3E3D32
   hi CursorColumn                  guibg=#3E3D32
   hi ColorColumn                   guibg=#3B3A32
   hi LineNr          guifg=#BCBCBC guibg=#3B3A32
   hi NonText         guifg=#75715E
   hi SpecialKey      guifg=#75715E
else
   hi Normal          guifg=#F8F8F2 guibg=#1B1D1E
   hi Comment         guifg=#7E8E91
   hi CursorLine                    guibg=#293739
   hi CursorColumn                  guibg=#293739
   hi ColorColumn                   guibg=#232526
   hi LineNr          guifg=#465457 guibg=#232526
   hi NonText         guifg=#465457
   hi SpecialKey      guifg=#465457
end

"
" Support for 256-color terminal
"
if &t_Co > 255
   hi Normal       ctermfg=252 ctermbg=NONE
   hi CursorLine               ctermbg=18   cterm=none
   hi Boolean         ctermfg=162
   hi Character       ctermfg=144
   "hi Number          ctermfg=162
   hi Number          ctermfg=214
   "hi String          ctermfg=76
   hi String          ctermfg=112
   hi Conditional     ctermfg=141               cterm=bold
   hi Constant        ctermfg=11               cterm=bold
   
   hi Debug           ctermfg=225               cterm=bold
   hi Define          ctermfg=134
   hi Delimiter       ctermfg=141

   hi DiffAdd ctermfg=231 ctermbg=28 cterm=bold guifg=#f8f8f2 guibg=#46830c gui=bold
   hi DiffDelete ctermfg=88 ctermbg=52 cterm=NONE guifg=#8b0807 guibg=NONE gui=NONE
   hi DiffChange ctermfg=231 ctermbg=25 cterm=NONE guifg=#f8f8f2 guibg=#243955 gui=NONE
   hi DiffText ctermfg=231 ctermbg=166 cterm=bold guifg=#f8f8f2 guibg=#204a87 gui=bold

   hi Directory       ctermfg=118               cterm=bold
   hi Error           ctermfg=219 ctermbg=89
   hi ErrorMsg        ctermfg=199 ctermbg=16    cterm=bold
   hi Exception       ctermfg=118               cterm=bold
   hi Float           ctermfg=135
   hi FoldColumn      ctermfg=67  ctermbg=16
   hi Folded          ctermfg=67  ctermbg=16
   hi Function        ctermfg=81
   hi Identifier      ctermfg=162               cterm=none
   hi Ignore          ctermfg=244 ctermbg=232
   hi IncSearch       ctermfg=193 ctermbg=16

   hi Keyword         ctermfg=12              cterm=bold
   hi Label           ctermfg=252               cterm=none
   hi Macro           ctermfg=193
   hi SpecialKey      ctermfg=1

   hi MatchParen      ctermfg=162  ctermbg=none cterm=bold
   hi ModeMsg         ctermfg=229
   hi MoreMsg         ctermfg=229
   hi Operator        ctermfg=171
   "hi Operator        ctermfg=170

   " complete menu
   hi Pmenu           ctermfg=81  ctermbg=16
   hi PmenuSel        ctermfg=233 ctermbg=162
   hi PmenuSbar                   ctermbg=81
   hi PmenuThumb      ctermfg=81

   hi PreCondit       ctermfg=118               cterm=bold
   hi PreProc         ctermfg=118
   hi Question        ctermfg=81
   hi Repeat          ctermfg=141               cterm=bold
   hi Search          ctermfg=232 ctermbg=39

   " marks column
   hi SignColumn      ctermfg=118 ctermbg=235
   hi SpecialChar     ctermfg=168               cterm=bold
   hi SpecialComment  ctermfg=245               cterm=bold
   "hi Special         ctermfg=214 
   hi Special         ctermfg=141 

   "this is the color of HTML tags
   hi Statement       ctermfg=141               cterm=bold
   hi StatusLine      ctermfg=238 ctermbg=253
   hi StatusLineNC    ctermfg=244 ctermbg=232
   hi StorageClass    ctermfg=208
   hi Structure       ctermfg=12
   hi Tag             ctermfg=168
   hi Title           ctermfg=166
   hi Todo            ctermfg=231 ctermbg=232   cterm=bold

   hi Typedef         ctermfg=12
   hi Type            ctermfg=12               cterm=bold
   hi Underlined      ctermfg=244               cterm=underline

   hi VertSplit       ctermfg=207 ctermbg=232   cterm=bold
   hi VisualNOS                   ctermbg=238
   hi Visual                      ctermbg=52
   hi WarningMsg      ctermfg=231 ctermbg=238   cterm=bold
   hi WildMenu        ctermfg=81  ctermbg=16

   "hi Comment         ctermfg=241
   hi Comment         ctermfg=243
   hi CursorColumn                ctermbg=234
   hi ColorColumn                 ctermbg=234
   hi LineNr          ctermfg=250 ctermbg=234
   hi NonText         ctermfg=59
   hi SpecialKey      ctermfg=59

end
"parse functions
function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! HighlightRange(higroup, start, end, priority)
	let group = a:higroup
	let startpos = a:start
	let endpos = a:end
	let priority = a:priority
	"single line regions
	if startpos[0] == endpos[0]
		call matchadd(group, '\%' . startpos[0] . 'l\%>' . (startpos[1] - 1) . 'c.*\%<' . (endpos[1] + 1) . 'c' , priority) 

	elseif (startpos[0] + 1) == endpos[0]
		"two line regions
		call matchadd(group, '\%' . startpos[0] . 'l\%>' . (startpos[1] - 1) . 'c.*', priority) 
		call matchadd(group, '\%' . endpos[0] . 'l.*\%<' . (endpos[1] + 1) . 'c' , priority) 
	else
		"multiline regions
		call matchadd(group, '\%' . startpos[0] . 'l\%>' . (startpos[1] - 1) . 'c.*', priority) 
		call matchadd(group, '\%>' . startpos[0] . 'l.*\%<' . endpos[0] . 'l', priority) 
		call matchadd(group, '\%' . endpos[0] . 'l.*\%<' . (endpos[1] + 1) . 'c' , priority) 
	endif

endfunction

"parse the next function after start pos
function! ParseFunction(start_pos, depth, stopline)
	"set position to start
	call cursor(a:start_pos[0], a:start_pos[1])
	let depth = a:depth

"TODO: exclude comments

	if search('\<function\>', 'W', a:stopline) > 0
		let start_function_pos = getpos('.')
		let start_function_line = start_function_pos[1]
		let start_function_col = start_function_pos[2]
"ignore comments
		if synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name") == 'Comment'
				return ParseFunction([start_function_line, start_function_col + 8] , depth, a:stopline)
		endif

		"get function name
		let function_def_line = getline(start_function_line)
		"ignore commented out lines

		let function_name = Strip(matchstr(function_def_line, '\v[^(]*', start_function_col + 8))

		if len(function_name) > 0
			let anonymous = 0
		else
			let anonymous = 1
		endif

		"find matching parens
		let start_paren_pos = searchpos('(', 'cW')
		"echom "open paren at [" . start_paren_pos[0] . ", " . start_paren_pos[1] . "]"
		let end_paren_pos = searchpairpos('(', '', ')')
		"find start brace
		let start_brace_pos = searchpos('{', 'cW')
		let end_brace_pos = searchpairpos('{', '', '}')

		"echom "function block start: [" . start_brace_pos[0] . ", " . start_brace_pos[1] . "]"
		"echom "function block end: [" . end_brace_pos[0] . ", " . end_brace_pos[1] . "]"

		"parse functions inside function block
		let inner_functions = []

		let inner_func = ParseFunction([start_brace_pos[0], start_brace_pos[1]], depth + 1, end_brace_pos[0])

		while !empty(inner_func) 
			"echom 'parsing inner function'
			call add(inner_functions, inner_func)
			let inner_func = ParseFunction([inner_func.block_end[0],inner_func.block_end[1]], depth + 1, end_brace_pos[0])
		endwhile

		let s:js_functions += inner_functions

		return { 'start': [start_function_line, start_function_col],
					\	'anonymous': anonymous,
					\	'name': function_name,
					\	'paren_start': copy(start_paren_pos),
					\	'paren_end': copy(end_paren_pos),
					\	'block_start': copy(start_brace_pos),
					\	'block_end': copy(end_brace_pos),
					\	'depth': depth, 
					\	'inner_functions': inner_functions 	}
	else
		return {}
	endif

endfunction

function! FunScope()

	let c = 0
	for colr in s:fun_colors
		exe 'highlight F' . c . '  ctermfg=' . colr . 'ctermbg=none cterm=none'
		let c += 1
	endfor
    "save and restore cursor pos
	let save_cursor = getpos(".")

	let depth = 1

	let s:js_functions = []

	let func = ParseFunction([1,1], depth, 0)

	while !empty(func)
		call add(s:js_functions, func)
		let func = ParseFunction([func.block_end[0],func.block_end[1]], depth, 0)
	endwhile

	"highlight functions
	"remove old matches
	call clearmatches()

	"match all global text
	call matchadd('F0', '\%>0l.*\%<' . line('$') . 'l', 10) 

	for fn in s:js_functions

		call HighlightRange('F' . (fn.depth), fn.start, fn.block_end, fn.depth + 10)

	endfor

	call matchadd('Comment', '\/\/.*', 100) 

	"block comments
	call cursor(1,1)

	while search('\/\*', 'cW') != 0

		let startbc_pos = getpos('.')
		let startbc = [startbc_pos[1], startbc_pos[2]]

		"echom 'found block comment at ' . startbc[0] . ',' . startbc[1]

		if search('\*\/', 'cWe')

				let endbc_pos = getpos('.')
				let endbc = [endbc_pos[1], endbc_pos[2]]

				"echom 'ends at ' . endbc[1]
				call cursor(endbc[0], endbc[1])

				call HighlightRange('Comment', startbc, endbc, 100)
		endif

	endwhile

	call setpos('.', save_cursor)
endfunction

call FunScope()

hi Comment         ctermfg=243
