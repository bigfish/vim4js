" jstagcomplete.vim
"
" @Author:      David Wilhelm 
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" modified from:
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-02.
" @Last Change: 2007-11-11.
" @Revision:    0.0.197

if &cp || exists("loaded_jstagcomplete_autoload")
    finish
endif
let loaded_jstagcomplete_autoload = 1

"take note of paths to check for in tag results to use as constraints
"obviously these environment vars must be set to the same values as in the
"tags themselves
let g:DOMPath = $HTML5_HOME
let g:ExtSourcePath = $EXT_HOME


" function! jstagcomplete#On(?option="omni")
" If option is "complete", set 'completefunc' instead of 'omnifunc' (the 
" default).
function! jstagcomplete#On(...) 
    TVarArg ['option', 'omni']
    let var = 'option_'. option
    if option == 'omni'
        let b:jstagcomplete_option_{option} = &omnifunc
		setlocal omnifunc=jstagcomplete#Complete
    elseif option == 'complete'
        let b:jstagcomplete_option_{option} = &completefunc
        setlocal completefunc=jstagcomplete#Complete
    else
        echoerr 'Unknown option: '. option
    endif
endf


function! jstagcomplete#Off(...) 
    TVarArg ['option', 'omni']
    let var = 'option_'. option
    if option == 'omni'
        if exists('b:jstagcomplete_option_'.option)
            let &l:omnifunc=b:jstagcomplete_option_{option}
        endif
    elseif option == 'complete'
        if exists('b:jstagcomplete_option_'.option)
            let &l:completefunc=b:jstagcomplete_option_{option}
        endif
    else
        echoerr 'Unknown option: '. option
    endif
endf

function! jstagcomplete#Complete(findstart, base) 
    let line = getline('.')
    let start = col('.')
    if a:findstart
        let start -= 1
        while start > 0 && line[start - 1] =~ '\a'
            let start -= 1
        endwhile
        return start
    else
        let constraints = copy(tlib#var#Get('jstagcomplete_constraints', 'bg'))
        let constraints.name = tlib#rx#Escape(a:base)
        let context = strpart(line, 0, start)

        "1. attempt to do a contextual tag search by getting constraints
        let constraints = jstagcomplete#JavaScript(constraints, a:base, context)
        "get matching tags using constraints
		let tags = tlib#tag#Collect(constraints, g:ttagecho_use_extra, 0)

        "if we don't get any results, try DOM or JSCore lookup without any constraints 
        if len(tags) == 0
            let constraints = copy(tlib#var#Get('jstagcomplete_constraints', 'bg'))
            let constraints.name = tlib#rx#Escape(a:base)
            let tags = tlib#tag#Collect(constraints, g:ttagecho_use_extra, 0)
        endif

        "augment tags with preview and kind info
        let results = []
        for tag in tags
            let result = {}
            let result['word'] = tag['name']
            let result['abbr'] = tag['name']
            let tag_meta = ''
            " show type info
            if has_key(tag, 'type')
                let tag_meta .= tag['type']
            endif
            "show class where tag is defined
            "this is done differently depending on library used
            if stridx(tag['filename'], g:DOMPath) > -1
                if has_key(tag, 'class')
                    let tag_meta = tag_meta . ' > '. tag['class']
                endif
            elseif stridx(tag['filename'], g:ExtSourcePath) > -1
                if has_key(tag, 'link')
                    "help link is actually fully qualified class name
                    let tag_meta = tag_meta .  '    : ' . tag['link']
                endif
            endif
            "add method signature if exists
            if has_key(tag, 'signature')
                let result['word'] = tag['name'].tag['signature']
                let result['abbr'] = tag['name'].tag['signature']
            endif
			"add description info for preview
			if has_key(tag, 'descr')
				let result['info'] = tag['descr']
			endif

            "add tag metadata
            let result['abbr'] = result['abbr'] . '   '.tag_meta

            call add(results, result)
        endfor
        return results
    endif
endf

"Javascript Complete
function! jstagcomplete#JavaScript(constraints, base, context) 
	let cons = a:constraints
    "Decho("jstagcomplete#JavaScript")
    "base is everything after last .
    "context is everything up to and including last dot
	"Decho("base: " . a:base)
	"Decho("context: " . a:context)
    ""trim whitespace (eg leading tab)
    let context = matchstr(a:context, '\s*\zs\S*')

    "override the name to be the fully qualified name (context)
    let fullname = context . a:base
    let name_rx = tlib#rx#Escape(a:base)
    let cons.name = name_rx
    
    let baseObj = ""
    "get the last portion of a dotted word
    if stridx(context, '.') > 0
		let baseObj = s:GetLastWord(context)
    else
        " no base: global 
		" TODO: constrain to Global members
		" or constructors
		"let a:constraints.kind = 'f'
    endif

    if len(baseObj) 
		"if it starts with a capital letter
		"it is probably a singleton (aka global) 
		"but this has the risk of over constraining results
		if match(baseObj, '^[A-Z]') > -1
			let class_rx = tlib#rx#Escape(baseObj)
			let cons.class = class_rx
		else
			"TODO: attempt to infer type of baseObj from context
			"find the most recent assignment to this var
			let assignRE = baseObj . '\s*=\s*\(.*\)'
			"bn : search backwards and do not move cursor
			let alnum = search(assignRE, 'bn')
			"debug shortcut
			let alnum = 0
			if alnum
				let aline = getline(alnum)
				let assign = matchlist(aline, assignRE) 
				if len(assign)
					"figure out the type which was assigned to the variable 
					let val = assign[1]
					"if the assingment value is an instantiation
					"get the class which was instantiated
					let rl = matchlist(val, 'new\s\([^(]*\)(')
					if len(rl)
						let full_class = rl[1]
						"get last portion of class name in case it is compound
						"eg Ext.Ajax.Request
						let class_name = s:GetLastWord(full_class)
						"we have found the class
						"let class_rx = tlib#rx#Escape(class_name)
						let cons.class = class_name
						"we are NOT interested in static methods in this case
					endif
				endif
			endif
		endif

		"Note: if no results are found
		"we will do another search on all tags
    endif

    let cons.kind = 'mfv'
    return cons

endfunction

function! s:GetLastWord(dottedword)
	let dotword = a:dottedword
    if stridx(dotword, '.') > 0
        "remove everything after the last dot (including dot)
        let base = strpart(dotword, 0, strridx(dotword, '.'))
        "now the last portion is the base object 
        let lastword = strpart(base, strridx(base, '.') + 1)
	else
		let lastword = dotword
	endif
	return lastword
endfunction
