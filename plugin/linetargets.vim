" This is a simple plugin which extends the targets.vim plugin by adding a new
" source with a default mapping.

" register our source
autocmd User targets#sources call targets#sources#register('line', function('linetargets#new'))

" add default mappings
" NOTE: We pass args {'c':1} here, to show how args can be used. They will be
" passed to our constructor linetargets#new and can be accessed in gen funcs
" and mod funcs (see autoload file for details)
autocmd User targets#mappings#plugin call targets#mappings#extend({'-': {'line': [{'c': 1}]}})
