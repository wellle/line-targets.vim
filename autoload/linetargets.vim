" our factory args constructor
"
" The parameter args comes straigt from the targets#mappings#extend call,
" either from the plugins default mapping, or from what the user chose.
" Here we transform it a bit to rename 'c' to 'count' with default value of 1.
" This will then be available in our gen and mod funcs, see below.
" If you don't need any arguments, you don't need to assign it here.
"
" genFuncs is a required dictionary which needs to have a generator function
" for the keys 'c', 'n', 'l', see comment below.
function! linetargets#new(args)
    return {
                \ 'args': {
                \     'count': get(a:args, 'c', 1),
                \ },
                \ 'genFuncs': {
                \     'c': function('linetargets#current'),
                \     'n': function('linetargets#next'),
                \     'l': function('linetargets#last'),
                \ },
                \ 'modFuncs': {
                \     'i': function('targets#modify#keep'),
                \     'a': function('linetargets#extend'),
                \     'I': function('targets#modify#keep'),
                \     'A': function('linetargets#extend'),
                \ }}
endfunction

" The next three functions are the generator functions, one for the
" current target (around the cursor), on for next (after cursor) and one for
" last/previous (before cursor).
"
" They all need to take the following three arguments:
" - args is coming straight from the args you populated in the constructor
"   function above. If you left it out it will be an empty dictionary.
" - opts is a dictionary coming from targets.vim. currently its only value is
"   opts.first which has value 1 (true) if it's called for the first time on
"   this invocation and 0 (false) otherwise. This is often useful to control
"   growing behavior on targets that can be nested. On the first invocation
"   it's fine to select a target having start/end at the cursor position, on
"   later invocations it should select a bigger target (otherwise it wouldn't
"   grow)
" - state is a dictionary which can be used by this generator to keep state
"   between multiple calls on the same invocation. For example you can set up
"   some values in there on the first call and refer to them again on follow
"   up calls. For example the builtin pairs source uses this to check if the
"   cursor is initially within quotes or not, and remembers how to seek
"   forward. So if you do d5in", on the first call of #next we check the
"   surrounding, and on the subsequent four calls we refer to that state.
"
" In this example they use visual mode to select the proper target. In one
" case an empty return is used to indicate that no target was found, without
" specifying any details
" Some alternative ways are supported which can be more convenient in some
" cases. If no target was found an error message can be provided. This is
" currently only visible in some debug logging which is currently not
" configurable yet, but might be in the future. To use them you can either
" just return the error message as string, or an error target object:
"     return 'message'
"     return targets#target#withError('message')
" If you know the coordinates (line, column) of your target start and end
" position (from getpos() calls for example), you can return them either as a
" list of ints [startline, startcol, endline, endcol] or a target from values:
"     return [1, 2, 3, 4]
"     return targets#target#fromValues(1, 2, 3, 4)
function! linetargets#current(args, opts, state)
    if !a:opts.first
        " can only be called once (can't be nested, can't grow)
        return
    endif

    " select from first to last non blank on current line
    normal! ^vg_

    " NOTE: to keep this implementation simple we don't use args.count here.
    " but it could be used like this to select that many lines:
    " execute 'normal! ^v' . a:args.count . 'g_'
endfunction

function! linetargets#next(args, opts, state)
    " go to first non blank on next line and select to last non blank on that
    " line
    normal! +^vg_
endfunction

function! linetargets#last(args, opts, state)
    " go to previous non blank on next line and select to last non blank on that
    " line
    normal! -^vg_
endfunction

" This is an example of a mod func. It takes a target and the generator args
" from the constructor. Some mod funcs like targets#modify#keep are available,
" check the targets.vim util.vim file.
"
" If you want to build your own, like here, you can just go and update the
" target here. Again, check the util.vim file for example modifications or the
" target.vim file (in the targets.vim repo) to see what's available. Here are
" some useful fields/functions available on the passed in target:
"
" fields (int)
"   sl:       start line
"   sc:       start column
"   el:       end line
"   ec:       end column
"   linewise: 1 if linewise, 0 if character wise
"  
" functions
"   equal:      compare to other target struct
"   setS:       set start position (pass in values, or empty for current cursor pos)
"   setE:       set start position (pass in values, or empty for current cursor pos)
"   s:          return start position as [sl, sc]
"   e:          return end position as [el, ec]
"   searchposS: search for a pattern with flags and set start position to match
"   searchposE: search for a pattern with flags and set end position to match
"   getcharS:   return character at target start position
"   getcharE:   return character at target end position
"   getposS:    return getpos() from target start position
"   getposE:    return getpos() from target end position
"   cursorS:    set cursor position to target start
"   cursorE:    set cursor position to target end
"   string:     return string representation, useful for debugging
"
" Please note that I might need/want to change some of those field names
" later, I can't guarantee them to be 100% stable. If you use them feel free
" to let me know, so I'll try to tell you when changes are needed.
function! linetargets#extend(target, args)
    let a:target.linewise = 1
endfunction
