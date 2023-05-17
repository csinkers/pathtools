let g:Lf_CommandMap = {
            \ '<Tab>': ['<C-K>'],
            \ '<C-J>': ['<Tab>'],
            \ '<C-K>': ['<S-Tab>']
            \ }

let g:Lf_ShortcutF = '<C-T>'
let g:Lf_WildIgnore = {
            \ 'dir': ['.idea', '.gradle', 'build', 'bin', 'obj'],
            \ 'file': [ '*.exe', '*.dll', '*.obj', '*.class' ]
            \ }

let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_RootMarkers = ['.git', '.hg', 'Build' ]
