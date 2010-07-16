" Vim indent file
" Language:	Javascript
" Maintainer:	David Wilhelm
" Last Change:	2010 July 15

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" C indenting is not too bad.
setlocal cindent

" lets try and make it better...
"add with, remove switch
setlocal cinwords="if,else,while,do,for,with"

"default cinoptions
"cinoptions=>s,e0,n0,f0,{0,}0,^0,:s,=s,l0,b0,gs,hs,ps,ts,is,+s,c3,C0,/0,(2s,us,U0,w0,W0,m0,j0,)20,*30,#0
"do not indent case statements within switch statements
"align break statements with case statements so it is easier to see
"fall-throughs
setlocal cinoptions=:0,b1


let b:undo_indent = "setl cin<"
