" Vim syntax file
" Language:     Albion Script

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn case ignore
syn match       albNumber       "\<\d\+\>"
syn match       albNumber       "\<0x\x\+\>"
syn case match

syn keyword     albStatement    goto break return continue
syn keyword     albConditional  if else
syn keyword     albRepeat       while do
syn region      albBlock        start="{" end="}" transparent fold

syn match       albUserLabel    display "\I\i*" contained
syn cluster     albLabelGroup   contains=albUserLabel
syn match       albUserCont     display "^\s*\zs\I\i*\s*:" contains=@albLabelGroup

syn match       albParenError   display ")"
syn cluster     albParenGroup   contains=albParenError,albUserLabel
syn region      albParen        transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,albBlock,@albParenGroup
syn match       albErrInParen   display contained "[{}]\|<%\|%>"

syn region      albBadBlock     keepend start="{" end="}" contained containedin=albParen,albBracket,albBadBlock transparent fold

syn keyword albConstant true false None
syn match albComment ";.*"

hi def link albLabel            Label
hi def link albUserLabel        Label
hi def link albConditional      Conditional
hi def link albRepeat           Repeat
hi def link albNumber           Number
hi def link albOperator         Operator
hi def link albStatement        Statement
hi def link albConstant         Constant
hi def link albParenError       Error
hi def link albErrInParen       Error
hi def link albComment          Comment

let b:current_syntax = "albion"

" vim: ts=8
