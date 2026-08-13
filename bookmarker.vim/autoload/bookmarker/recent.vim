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
