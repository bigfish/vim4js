" jstagcomplete.vim -- Context-sensitive tag completion
" @Author:      David Wilhelm after Thomas Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-02.
" @Last Change: 2007-11-04.
" @Revision:    0.1.19
" GetLatestVimScripts: 0 0 jstagcomplete.vim

if &cp || exists("loaded_jstagcomplete")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 19
    echoerr 'tlib >= 0.19 is required'
    finish
endif
let loaded_jstagcomplete = 1

let s:save_cpo = &cpo
set cpo&vim


" A dictionnary of constraints that tags have to satisfy.
TLet g:jstagcomplete_constraints = {}

" If true, use extra tags (see |g:tlib_tags_extra|).
"TLet g:ttagecho_use_extra = 1

" Number of chars, the user has to type before we allow invoking the 
" completion. If you set this to 0, it's possible that all tags will be 
" returned.
TLet g:ttagecho_min_chars = 1
" TLet g:ttagecho_min_chars = 2

command! -nargs=* JSTagCompleteOn  call jstagcomplete#On(<f-args>)
command! -nargs=* JSTagCompleteOff call jstagcomplete#Off(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo


finish
CHANGES:
0.1
- Initial release

