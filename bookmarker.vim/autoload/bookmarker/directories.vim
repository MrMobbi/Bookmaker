function! bookmarker#directories#get() abort
    let l:raw_directories = get(
                \ g:,
                \ 'bookmarker_directory_bookmarks', [
                \     {'C': {'label': 'Configuration', 'path': '~/.config/'}},
                \     {'P': {'label': 'Projects', 'path': '~/projects/'}},
                \     {'D': {'label': 'Documents', 'path': '~/Documents/'}},
                \ ])

    let l:directories = []

    for l:item in l:raw_directories
        if type(l:item) != v:t_dict
            continue
        endif

        let l:keys = keys(l:item)

        " Each dictionary must contain exactly one key.
        if len(l:keys) != 1
            continue
        endif

        let l:key = l:keys[0]
        let l:value = l:item[l:key]
        let l:label = ''
        let l:path = ''

        if type(l:value) == v:t_dict
            let l:label = get(l:value, 'label', '')
            let l:path = get(l:value, 'path', '')
        elseif type(l:value) == v:t_string
            let l:path = l:value
        else
            continue
        endif

        if type(l:path) != v:t_string || empty(l:path)
            continue
        endif

        if type(l:label) != v:t_string || empty(l:label)
            let l:label = fnamemodify(expand(l:path), ':~')
        endif

        call add(l:directories, {
                \ 'key': l:key,
                \ 'label': l:label,
                \ 'path': l:path,})
    endfor

    return l:directories
endfunction

function! bookmarker#directories#open(key) abort
    if !exists('b:bookmarker_directory_bookmarks')
        return
    endif

    for l:directory in b:bookmarker_directory_bookmarks
        if l:directory.key !=# a:key
            continue
        endif

        let l:path = fnamemodify(
                    \ expand(l:directory.path),
                    \ ':p')

        if !isdirectory(l:path)
            echohl WarningMsg
            echomsg '[Bookmarker] Directory not found: ' . l:path
            echohl None
            return
        endif

        " Open directory bookmarks in netrw for now. This keeps the feature
        " useful while leaving room for richer directory navigation later.
        if !exists(':Explore')
            silent! runtime plugin/netrwPlugin.vim
        endif

        if exists(':Explore')
            execute 'Explore ' . fnameescape(l:path)
        else
            execute 'edit ' . fnameescape(l:path)
        endif
        return
    endfor
endfunction

function! bookmarker#directories#mappings() abort
    if !exists('b:bookmarker_directory_bookmarks')
        return
    endif

    for l:directory in b:bookmarker_directory_bookmarks
        execute 'nnoremap <silent><buffer> '
                    \ . l:directory.key
                    \ . ' :call bookmarker#directories#open('
                    \ . string(l:directory.key)
                    \ . ')<CR>'
    endfor
endfunction
