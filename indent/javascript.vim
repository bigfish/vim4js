" Vim indent file
" Language:	Javascript
" Maintainer:	David Wilhelm
" Last Change:	2010 July 15

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

"cindent causes problems with common js idioms like object literals
setlocal smartindent

let b:undo_indent = "setl cin<"
