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
        "if exists('b:jstagcomplete_collect')
            "Decho("found collector function")
            "call call(b:jstagcomplete_collect, [constraints, a:base, context])
        "endif
        call jstagcomplete#JavaScript(constraints, a:base, context)
        "if exists('*TTagcomplete_collect_'. &filetype)
            "call TTagcomplete_{&filetype}(constraints, a:base, context)
        "endif
        " TLogVAR constraints
        let tags = tlib#tag#Collect(constraints, g:ttagecho_use_extra, 0)
        "augment tags with preview and kind info
        "Decho( keys(tags[1]))
        let results = []
        for tag in tags
            let result = {}
            let result['word'] = tag['name']
            if len(tag['signature']) > 0
                let result['word'] = tag['name'].tag['signature']
                let result['abbr'] = tag['name'].tag['signature']
            endif
            call add(results, result)
        endfor
        return results
    endif
endf

"Javascript Complete
function! jstagcomplete#JavaScript(constraints, base, context) 
    Decho("jstagcomplete#JavaScript")
    "base is everything after last .
    "context is everything up to and including last dot
"Decho("base: " . a:base)
"Decho("context: " . a:context)
    ""trim whitespace (eg leading tab)
    let context = matchstr(a:context, '\s*\zs\S*')

    "override the name to be the fully qualified name (context)
    let fullname = context . a:base
    let name_rx = tlib#rx#Escape(a:base)
    let a:constraints.name = name_rx
    
    let class = ""
    "when called as tagComplete, we get the context without the base
    "when called as skeletonComplete, we do not.. 
    if stridx(context, '.') > 0
        "remove everything after the last dot (including dot)
        let class = strpart(context, 0, strridx(context, '.') - 1)
        "no the class is the last portion
        let class = strpart(class, strridx(class, '.') + 1)
    else
        "global var
    endif
    "Decho("class: " . class)
    if class != ""
        let class_rx = tlib#rx#Escape(class)
        let a:constraints.class = class_rx
    endif

    let a:constraints.kind = 'mf'
    return a:constraints

endfunction

