
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

    " FZF was cancelled, so we're back on Bookmarker.
    call bookmarker#restore()
endfunction
