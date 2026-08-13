function! bookmarker#recent#get(directory) abort
    let l:recent_file = []

    let l:directory = fnamemodify(
                \ a:directory,
                \ ':p')

    for l:file in v:oldfiles
        let l:path = fnamemodify(
                    \ resolve(l:file),
                    \ ':p')

        " Ignore NEERDTree buffers.
        if stridx(l:path, 'NERD_tree_') == 0
            continue
        endif

        " Ignore files that no longer exist
        if !filereadable(l:path)
            continue
        endif

        " Keep only file inside the current directory.
        if stridx(l:path, l:directory) != 0
            continue
        endif

        " Avoid duplicates.
        if index(l:recent_file, l:path) >= 0
            continue
        endif

        call add(l:recent_file, l:path)

        " Maximum of 10 files.
        if len(l:recent_file) >= 10
            break
        endif
    endfor

    return l:recent_file
endfunction

function! bookmarker#recent#mappings() abort
    if !exists('b:bookmarker_recent_files')
        return
    endif

    let l:index = 0

    for l:file in b:bookmarker_recent_files
        " Entries 0-8 use 1-9 key
        " Entry 9 uses 0 key
        let l:key = l:index == 9 ? '0' : string(l:index + 1)

        execute 'nnoremap <silent><nowait><buffer> '
                    \ . l:key
                    \ . ' :call bookmarker#bookmarks#open("'
                    \ . l:index
                    \ . '")<CR>'

        let l:index += 1
    endfor
endfunction

function! bookmarker#recent#open(index) abort
    if !exists(b: bookmarker_recent_files)
        return
    endif

    if a:index < 0 || a:index >= len(b:bookmarker_recent_files)
        return
    endif

    let l:path = b:bookmarker_recent_files[a:index]

    if !filereadable(l:path)
        echohl WarningMsg
        echomsg '[Bookmarker] File not found: ' . l:path
        echohl None
        return
    endif

    execute 'edit ' . fnameescape(l:path)
endfunction
