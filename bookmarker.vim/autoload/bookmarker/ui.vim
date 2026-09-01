let s:whale_path = fnamemodify(expand('<sfile>:p'), ':h:h:h:h')
            \ . '/asset/whale.txt'

function! bookmarker#ui#whale() abort
    if !filereadable(s:whale_path)
        return []
    endif

    let l:lines = []

    for l:line in readfile(s:whale_path)
        call add(l:lines, '             ' . l:line)
    endfor

    return l:lines
endfunction

function! bookmarker#ui#layout(start_directory,
    \ bookmarks,
    \ directory_bookmarks,
    \ recent_files) abort
    " Display ~/projects instead of /home/user/projects.
    let l:directory = fnamemodify(
                \ a:start_directory,
                \ ':~')

    let l:lines = ['']
    let l:whale = bookmarker#ui#whale()

    if !empty(l:whale)
        call extend(l:lines, l:whale)
        call add(l:lines, '')
    endif

    call extend(l:lines, [
                \ '                         BOOKMARKER',
                \ '',
                \ '  [f] Find file with FZF in the current directory',
                \ '  [/] Search text with ripgrep in the current directory',
                \ '',
                \ '',
                \ '		Quick bookmarks',
                \ ''])

    for l:bookmark in a:bookmarks
        let l:icon = bookmarker#bookmarks#icon(l:bookmark.path)
        let l:path = fnamemodify(expand(l:bookmark.path), ':~')

        if empty(l:icon)
            let l:line = printf('  [%s] %s', l:bookmark.key, l:path)
        else
            let l:line = printf('  [%s] %s %s', l:bookmark.key, l:icon, l:path)
        endif

        call add(l:lines, l:line)
    endfor

    call extend(l:lines, [
                \ '',
                \ '		Bookmark folders',
                \ ''])

    for l:directory_bookmark in a:directory_bookmarks
        let l:path = fnamemodify(expand(l:directory_bookmark.path), ':~')
        let l:line = printf('  [%s] %-26s %s',
                    \ l:directory_bookmark.key,
                    \ l:directory_bookmark.label,
                    \ l:path)

        call add(l:lines, l:line)
    endfor

    call extend(l:lines, [
                \ '',
                \ '		Recent files in current directory',
                \ '',
                \ '		PWD: [' . l:directory . ']',
                \ '',
                \ ])

    let l:root = fnamemodify(
                \ a:start_directory,
                \ ':p')
    let l:index = 1

    for l:file in a:recent_files
        let l:key = l:index == 10 ? '0' : string(l:index)
        " Remove the startup directory from the path
        let l:path = strpart(l:file, strlen(l:root))
        let l:icon = bookmarker#bookmarks#icon(l:file)

        if empty(l:icon)
            let l:line = printf('  [%s] %s',l:key,l:path)
        else
            let l:line = printf('  [%s] %s %s', l:key, l:icon, l:path)
        endif

        call add(l:lines, l:line)

        let l:index += 1
    endfor
    call extend(l:lines, [
                \ '',
                \ '        <CR> open    ? help    q close',
                \ '',
                \ ])
    return l:lines
endfunction
