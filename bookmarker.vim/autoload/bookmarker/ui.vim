function! bookmarker#ui#layout(start_directory,
    \ bookmarks,
    \ recent_files) abort
    " Display ~/projects instead of /home/user/projects.
    let l:directory = fnamemodify(
                \ a:start_directory,
                \ ':~')

    let l:lines = [
                \ '',
                \ '                         BOOKMARKER',
                \ '',
                \ '  [f] Find file with FZF in the current directory',
                \ '  [/] Search text with ripgrep in the current directory',
                \ '',
                \ '',
                \ '		Quick bookmarks',
                \ '']

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
                \ '',
                \ '  [C] Configuration              ~/.config/',
                \ '  [P] Projects                   ~/projects/',
                \ '  [D] Documents                  ~/Documents/',
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
