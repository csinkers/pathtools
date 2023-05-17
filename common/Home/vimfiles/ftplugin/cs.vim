nnoremap <buffer> ]m :<c-u>call <SID>JumpMethod('{', 'W',  'n')<cr>
nnoremap <buffer> [m :<c-u>call <SID>JumpMethod('{', 'Wb', 'n')<cr>
nnoremap <buffer> ]M :<c-u>call <SID>JumpMethod('}', 'W',  'n')<cr>
nnoremap <buffer> [M :<c-u>call <SID>JumpMethod('}', 'Wb', 'n')<cr>

xnoremap <buffer> ]m :<c-u>call <SID>JumpMethod('{', 'W',  'v')<cr>
xnoremap <buffer> [m :<c-u>call <SID>JumpMethod('{', 'Wb', 'v')<cr>
xnoremap <buffer> ]M :<c-u>call <SID>JumpMethod('}', 'W',  'v')<cr>
xnoremap <buffer> [M :<c-u>call <SID>JumpMethod('}', 'Wb', 'v')<cr>

onoremap <buffer> ]m :<c-u>call <SID>JumpMethod('{', 'W',  'o')<cr>
onoremap <buffer> [m :<c-u>call <SID>JumpMethod('{', 'Wb', 'o')<cr>
onoremap <buffer> ]M :<c-u>call <SID>JumpMethod('}', 'W',  'o')<cr>
onoremap <buffer> [M :<c-u>call <SID>JumpMethod('}', 'Wb', 'o')<cr>

function! s:JumpMethod(char, flags, mode)
  let original_cursor = getpos('.')

  if a:mode == 'v'
    normal! gv
  elseif a:mode == 'o'
    normal! v
  endif

  while search(a:char, a:flags) > 0
    if a:char == '}'
      " jump to the opening one to analyze the definition
      normal! %
    endif

    let current_line = line('.')

    if getline(current_line) =~ '^\s*{'
      " it's alone on the line, check the above one
      let method_line = current_line - 1
    else
      let method_line = current_line
    endif

    let method_line_body = getline(method_line)

    if method_line_body =~ '\k\+\s*(.*)' && method_line_body !~ '\<\(for\|foreach\|if\|while\|switch\|using\|catch\|get\|set\|lock\|new\)\>'
      " it's probably a function call

      if a:char == '}'
        " we need to go back to the closing bracket
        normal! %
      endif

      echo
      return
    else
      if a:char == '}'
        " we still need to go back to the closing bracket
        normal! %
      endif
    endif
  endwhile

  " if we're here, the search has failed, restore cursor position
  echo
  call setpos('.', original_cursor)
endfunction
