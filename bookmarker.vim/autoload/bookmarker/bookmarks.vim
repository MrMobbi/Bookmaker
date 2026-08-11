function! bookmarker#bookmarks#get() abort
    let l:raw_bookmarks = get(
                \ g:,
                \ 'bookmarker_quick_bookmarks',
                \ []
                \ )

    let l:bookmarks = []

    for l:item in l:raw_bookmarks
        if type(l:item) != v:t_dict
            continue
        endif

        let l:keys = keys(l:item)

        " Each dictionary must contain exactly one key.
        if len(l:keys) != 1
            continue
        endif

        let l:key = l:keys[0]
        let l:path = l:item[l:key]

        if type(l:path) != v:t_string
            continue
        endif

        call add(
                    \ l:bookmarks,
                    \ {
                    \     'key': l:key,
                    \     'path': l:path,
                    \ }
                    \ )
    endfor

    return l:bookmarks
endfunction

function! bookmarker#bookmarks#icon(path) abort
    " vim-devicons is optional.
    if !exists('*WebDevIconsGetFileTypeSymbol')
        return ''
    endif

    let l:path = fnamemodify(
                \ expand(a:path),
                \ ':p'
                \ )

    return WebDevIconsGetFileTypeSymbol(l:path)
endfunction
