
function! bookmarker#finder#file() abort
    if !exists(':FZF')
        echohl WarningMsg
        echomsg '[Bookmarker] FZF is not installed'
        echohl None
        return
    endif

    let l:directory = get(
                \ b:,
                \ 'bookmarker_path_directory',
                \ getcwd()
                \ )

    execute 'FZF ' . fnameescape(l:directory)
endfunction

function! bookmarker#finder#grep() abort
    if !exists(':FZF')
        echohl WarningMsg
        echomsg '[Bookmarker] FZF is not installed'
        echohl None
        return
    endif

    if !executable('rg')
        echohl WarningMsg
        echomsg '[Bookmarker] ripgrep is not installed'
        echohl None
        return
    endif

    let l:directory = get(
                \ b:,
                \ 'bookmarker_path_directory',
                \ getcwd()
                \ )

    let l:query = input('Ripgrep> ')

    if empty(l:query)
        return
    endif

    let l:command =
                \ 'rg'
                \ . ' --column'
                \ . ' --line-number'
                \ . ' --no-heading'
                \ . ' --color=never'
                \ . ' --smart-case'
                \ . ' --with-filename'
                \ . ' -e ' . shellescape(l:query)
                \ . ' .'

    let l:spec = {
                \ 'source': l:command,
                \ 'dir': l:directory,
                \ 'sink': function(
                \     'bookmarker#finder#open_grep_result',
                \     [l:directory]
                \ ),
                \ 'options': [
                \     '--prompt',
                \     'Ripgrep> ',
                \ ],
                \ }

    call fzf#run(
                \ fzf#wrap(
                \     'bookmarker-ripgrep',
                \     l:spec
                \ )
                \ )
endfunction

function! bookmarker#finder#open_grep_result(directory, result) abort
    let l:match = matchlist(
                \ a:result,
                \ '^\(.\{-}\):\(\d\+\):\(\d\+\):'
                \ )

    if empty(l:match)
        return
    endif

    let l:path = fnamemodify(
                \ a:directory . '/' . l:match[1],
                \ ':p'
                \ )

    let l:line = str2nr(l:match[2])
    let l:column = str2nr(l:match[3])

    execute 'edit ' . fnameescape(l:path)

    call cursor(
                \ l:line,
                \ l:column
                \ )

    normal! zz
endfunction
