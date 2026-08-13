
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
    if !exists(':Rg')
        echohl WarningMsg
        echomsg '[Bookmarker] :Rg is not available'
        echohl None
        return
    endif

    let l:directory = get(
                \ b:,
                \ 'bookmarker_path_directory',
                \ getcwd()
                \ )

    execute 'lcd ' . fnameescape(l:directory)
    Rg
endfunction
