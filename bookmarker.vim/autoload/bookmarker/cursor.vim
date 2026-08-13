function! bookmarker#cursor#setup() abort
    let b:bookmarker_selectable_lines = []

    for l:line_number in range(1, line('$'))
        let l:text = getline(l:line_number)
        if l:text =~# '^\s*\[[^]]\+\]'
            call add(b:bookmarker_selectable_lines,
                    \ l:line_number)
        endif
    endfor

    if empty(b:bookmarker_selectable_lines)
        return
    endif
    let b:bookmarker_last_line = b:bookmarker_selectable_lines[0]
    call bookmarker#cursor#move(
                \ b:bookmarker_last_line)
endfunction

function! bookmarker#cursor#move(line_number) abort
    let l:text = getline(a:line_number)
    let l:column = match(l:text, '^\s*\[[^]]\+\]')
    if l:column < 0
        return
    endif

    call cursor(a:line_number, l:column + 4)
endfunction

function! bookmarker#cursor#lock() abort
    if !exists('b:bookmarker_selectable_lines')
                \ || empty(b:bookmarker_selectable_lines)
        return
    endif

    let l:current_line = line('.')
    let l:previous_line = get(
                \ b:,
                \ 'bookmarker_last_line',
                \ b:bookmarker_selectable_lines[0])

    " Already on a valid selectable line.
    if index(b:bookmarker_selectable_lines,
                \ l:current_line) >= 0

        let b:bookmarker_last_line = l:current_line
        call bookmarker#cursor#move(l:current_line)
        return
    endif

    " Moving down.
    if l:current_line > l:previous_line
        for l:line_number in b:bookmarker_selectable_lines
            if l:line_number > l:current_line

                let b:bookmarker_last_line = l:line_number
                call bookmarker#cursor#move(l:line_number)
                return
            endif
        endfor

        " Do not go below the last selectable item.
        let l:last = b:bookmarker_selectable_lines[-1]
        let b:bookmarker_last_line = l:last
        call bookmarker#cursor#move(l:last)

        return
    endif

    " Moving up.
    for l:line_number in reverse(
                \ copy(b:bookmarker_selectable_lines))

        if l:line_number < l:current_line
            let b:bookmarker_last_line = l:line_number
            call bookmarker#cursor#move(l:line_number)
            return
        endif
    endfor

    " Do not go above the first selectable item.
    let l:first = b:bookmarker_selectable_lines[0]
    let b:bookmarker_last_line = l:first
    call bookmarker#cursor#move(l:first)
endfunction

function! bookmarker#cursor#selected_key() abort
    return matchstr(
                \ getline('.'),
                \ '^\s*\[\zs[^]]\+\ze\]')
endfunction
