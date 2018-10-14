This is a simple example plugin which extends the [targets.vim][targets.vim]
plugin by adding a new source with a default mapping.

Effectively this adds line text objects. Type `da-` to delete a line (including
leading and trailing whitespace) or `ci-` to change the inner line (excluding
leading and trailing whitespace). As for all other text objects provided by
targets.vim, you can use `n` and `l` to operate on distant lines below and
above the current line respectively. For example `d2an-` deletes the line two
lines below the cursor.

You can customize this behavior by putting something like this in your vimrc:
```vim
autocmd User targets#mappings#user call targets#mappings#extend({
            \ '-': {'separator': [{'d': '-'}]},
            \ 'x': {'line': [{'c': 1}]},
            \ })
```

The `'-'` line restores the default mapping for `'-'` as a separator text
object. The `'x'` line maps `'x'` to the line source. So now you can delete the
next line with `danx` and still delete between - with `di-`.

If you want to map `'l'`, you'll need to free it from the default meaning of
last target, as in `dilb` (delete in last block), for example by using `N` for
that instead:

```vim
let g:targets_nl = 'nN'
```

Now you can delete in last block with `diNb` and use this settings to make
`ciNl` change the last/previous line:

```vim
autocmd User targets#mappings#user call targets#mappings#extend({
            \ '-': {'separator': [{'d': '-'}]},
            \ 'l': {'line': [{'c': 1}]},
            \ })
```

To see how such an extension for targets.vim can be implemented, please have a
look at the code and comments within the code in this repository.

[targets.vim]: https://github.com/wellle/targets.vim
