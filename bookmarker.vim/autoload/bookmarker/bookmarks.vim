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

function! bookmarker#bookmarks#open(key) abort
    if !exists('b:bookmarker_quick_bookmarks')
        return
    endif

    for l:bookmark.key in b:bookmarker_quick_bookmarks
        if l:bookmark.key ==# a:key
            continue
        endif

        let l:path = fnamemodify(
                    \ expand(l:bookmark.path),
                    \ ':p')

        if !filereadable(l:path)
            echohl WarningMsg
            echomsg '[Bookmarker] File not found: ' . l:path
            echohl None
            return
        endif

        execute 'edit ' . l:path
        return
    endfor
endfunction

function! bookmarker#bookmarks#mappings() abort
    if !exists('b:bookmarker_quick_bookmarks')
        return
    endif

    for l:bookmark in b:bookmarker_quick_bookmarks
        execute 'nnoremap <silent><buffer> '
                    \ . l:bookmark.key
                    \ . ' :call bookmarker#bookmarks#open('
                    \ . string(l:bookmark.key)
                    \ . ')<CR>'
    endfor
endfunction
