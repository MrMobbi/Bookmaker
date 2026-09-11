
function! bookmarker#command(command) abort
	if empty(a:command)
		call bookmarker#start()
		return
	endif

	if a:command ==# 'help'
		call bookmarker#help#open()
		return
	endif

	if isdirectory(expand(a:command))
		call bookmarker#start(a:command)
		return
	endif

	echohl WarningMsg
	echomsg '[Bookmarker] Unknown command or directory: ' . a:command
	echohl None
endfunction

function! bookmarker#start(...) abort

	" Remember the current file buffer
	let l:previous_buffer = bufnr('%')
	let l:directory = a:0 > 0
			\ ? a:1
			\ : get(g:, 'bookmarker_path_directory', getcwd())

	" Create and enter a distinct dashboard buffer
	let l:dashboard_buffer = bufadd('')

	call setbufvar(l:dashboard_buffer, '&buftype', 'nofile')
	call setbufvar(l:dashboard_buffer, '&bufhidden', 'wipe')
	call setbufvar(l:dashboard_buffer, '&swapfile', 0)
	call setbufvar(l:dashboard_buffer, '&buflisted', 0)

	call bufload(l:dashboard_buffer)
	execute 'hide buffer ' . l:dashboard_buffer

	" Set the file type for syntax highlighting
	setlocal filetype=bookmarker

	" Save the previous buffer number in the dashboard
	let b:bookmarker_previous_buffer = l:previous_buffer

	" Remember the directory represented by this dashboard page.
	let b:bookmarker_path_directory = simplify(fnamemodify(expand(l:directory), ':p'))


	" Turn in into a plugin-controller scratch buffer
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nonumber
	setlocal norelativenumber
	setlocal nowrap
	setlocal nocursorline

	" Give the buffer a recognizable name
	execute 'file [Bookmarker]'

	" Make Airline display
	if exists(':AirlineRefresh')
		if !exists('g:airline_filetype_overrides')
			let g:airline_filetype_overrides = {}
		endif

		let g:airline_filetype_overrides['bookmarker'] = [
					\ 'Bookmarker',
					\ '']

		silent! AirlineRefresh
	endif

	" Get the bookmarks for this dashboard page.
	let b:bookmarker_quick_bookmarks = bookmarker#bookmarks#get(
		\ b:bookmarker_path_directory)

	" Get the directory bookmarks for this dashboard page.
	let b:bookmarker_directory_bookmarks = bookmarker#directories#get(
		\ b:bookmarker_path_directory)

	" Get the recent files
	let b:bookmarker_recent_files = bookmarker#recent#get(
		\ b:bookmarker_path_directory)

	" Render the Home page
	call setline(1, bookmarker#ui#layout(
		\ b:bookmarker_path_directory,
		\ b:bookmarker_quick_bookmarks,
		\ b:bookmarker_directory_bookmarks,
		\ b:bookmarker_recent_files))

	" Protect the dashboard from accidental editing.
	setlocal nomodifiable
	setlocal nomodified

	" Move the cursor to the first selectable item.
	call bookmarker#cursor#setup()

	" Set up the mapping for the bookmarks
	call bookmarker#bookmarks#mappings()

	" Set up the mappings for the directory bookmarks
	call bookmarker#directories#mappings()

	" Set up the mappings for the recent files
	call bookmarker#recent#mappings()

	" Let external file openers reuse this dashboard window instead of
	" splitting around a protected nofile buffer.
	call bookmarker#external_openers_setup()

	" This mapping open the fzf finder
	nnoremap <silent><buffer> f :call bookmarker#finder#file()<CR>

	" This mapping open reggrep
	nnoremap <silent><buffer> / :call bookmarker#finder#grep()<CR>

	" Open the item under the cursor.
	nnoremap <silent><buffer> <CR> :call bookmarker#open_selected()<CR>

	" Show Bookmarker help.
	nnoremap <silent><buffer> ? :call bookmarker#help#open()<CR>

	augroup bookmarker_cursor
		autocmd!
		autocmd CursorMoved <buffer> call bookmarker#cursor#lock()
	augroup END

	"this mapping only exists in the dashboard buffer
	nnoremap <silent><buffer> q :call bookmarker#close()<CR>

endfunction

function! bookmarker#external_openers_setup() abort
    augroup bookmarker_external_openers
        autocmd! * <buffer>
        autocmd CmdlineLeave <buffer> call bookmarker#external_openers_prepare(getcmdline())
        autocmd WinLeave <buffer> let g:bookmarker_pending_external_window = win_getid()
    augroup END

    augroup bookmarker_external_targets
        autocmd!
        autocmd BufEnter * call bookmarker#external_openers_prepare_pending()
    augroup END
endfunction

function! bookmarker#external_openers_prepare(command) abort
    if &filetype !=# 'bookmarker'
        return
    endif

    let l:command = substitute(a:command, '^\s*', '', '')

    while l:command =~# '^\%(silent!\?\|vertical\|tab\|botright\|belowright\|rightbelow\|aboveleft\|leftabove\|topleft\|keepalt\|keepjumps\|noautocmd\)\s\+'
        let l:command = substitute(l:command, '^\%(silent!\?\|vertical\|tab\|botright\|belowright\|rightbelow\|aboveleft\|leftabove\|topleft\|keepalt\|keepjumps\|noautocmd\)\s\+', '', '')
    endwhile

    if l:command =~# '^\%(edit\|e\|split\|sp\|vsplit\|vsp\|tabedit\|tabe\)\%($\|\s\|!\)'
                \ || l:command =~# '^\%(Explore\|Sexplore\|Vexplore\|Texplore\|Startify\)\%($\|\s\|!\)'
        call bookmarker#external_openers_empty_current_buffer()
    endif
endfunction

function! bookmarker#external_openers_prepare_pending() abort
    let l:window = get(g:, 'bookmarker_pending_external_window', 0)

    if l:window <= 0 || win_id2win(l:window) == 0
        unlet! g:bookmarker_pending_external_window
        return
    endif

    " Entering NERDTree itself should not consume the Bookmarker window: keep
    " the home page visible until a real file is chosen from the tree.
    if &filetype ==# 'nerdtree' || bufname('%') =~# '^NERD_tree_'
        let g:bookmarker_pending_external_seen_tree = 1
        return
    endif

    if !get(g:, 'bookmarker_pending_external_seen_tree', 0)
        return
    endif

    let l:path = expand('%:p')

    if &buftype !=# '' || empty(l:path) || !filereadable(l:path)
        return
    endif

    let l:source_window = win_getid()

    call win_execute(l:window, 'call bookmarker#external_openers_empty_current_buffer()')
    call win_execute(l:window, 'execute ''edit '' . fnameescape(' . string(l:path) . ')')
    unlet! g:bookmarker_pending_external_window
    unlet! g:bookmarker_pending_external_seen_tree

    if l:source_window !=# l:window && win_id2win(l:source_window) > 0 && winnr('$') > 1
        call win_gotoid(l:source_window)
        silent! close
    endif

    call win_gotoid(l:window)
endfunction

function! bookmarker#external_openers_empty_current_buffer() abort
    if &filetype !=# 'bookmarker'
        return
    endif

    let l:current_buffer = bufnr('%')

    silent! nunmap <buffer> f
    silent! nunmap <buffer> /
    silent! nunmap <buffer> <CR>
    silent! nunmap <buffer> ?
    silent! nunmap <buffer> q

    for l:key in split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '\zs')
        silent! execute 'nunmap <buffer> ' . l:key
    endfor

    augroup bookmarker_cursor
        autocmd! * <buffer>
    augroup END

    augroup bookmarker_external_openers
        autocmd! * <buffer>
    augroup END

    setlocal modifiable
    silent! %delete _
    silent! 0file
    setlocal buftype=
    setlocal filetype=
    setlocal bufhidden=hide
    setlocal swapfile
    setlocal buflisted
    setlocal nomodified

    for l:buffer in range(1, bufnr('$'))
        if l:buffer != l:current_buffer && bufname(l:buffer) ==# '[Bookmarker]'
            silent! execute 'bwipeout ' . l:buffer
        endif
    endfor
endfunction

function! bookmarker#folder_config(directory) abort
    let l:pages = get(g:, 'bookmarker_folder_bookmarks', {})

    if type(l:pages) != v:t_dict
        return {}
    endif

    let l:directory = simplify(fnamemodify(expand(a:directory), ':p'))

    for l:key in keys(l:pages)
        if simplify(fnamemodify(expand(l:key), ':p')) ==# l:directory
            let l:config = l:pages[l:key]
            return type(l:config) == v:t_dict ? l:config : {}
        endif
    endfor

    return {}
endfunction

function! bookmarker#resolve_path(path, directory) abort
    if a:path[0] ==# '~' || a:path[0] ==# '/'
                \ || a:path =~# '^[A-Za-z]:[\\/]'
        return simplify(fnamemodify(expand(a:path), ':p'))
    endif

    return simplify(fnamemodify(
                \ expand(a:directory) . '/' . a:path,
                \ ':p'))
endfunction

function! bookmarker#dashboard(directory) abort
    let l:directory = simplify(fnamemodify(expand(a:directory), ':p'))

    if !isdirectory(l:directory)
        echohl WarningMsg
        echomsg '[Bookmarker] Directory not found: ' . l:directory
        echohl None
        return
    endif

    if &filetype ==# 'bookmarker'
        let b:bookmarker_path_directory = l:directory
        let b:bookmarker_quick_bookmarks = bookmarker#bookmarks#get(l:directory)
        let b:bookmarker_directory_bookmarks = bookmarker#directories#get(l:directory)
        let b:bookmarker_recent_files = bookmarker#recent#get(l:directory)

        setlocal modifiable
        silent! %delete _
        call setline(1, bookmarker#ui#layout(
                    \ b:bookmarker_path_directory,
                    \ b:bookmarker_quick_bookmarks,
                    \ b:bookmarker_directory_bookmarks,
                    \ b:bookmarker_recent_files))
        setlocal nomodifiable
        setlocal nomodified

        silent! nunmap <buffer> f
        silent! nunmap <buffer> /
        silent! nunmap <buffer> <CR>
        silent! nunmap <buffer> ?
        silent! nunmap <buffer> q
        for l:key in split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '\zs')
            silent! execute 'nunmap <buffer> ' . l:key
        endfor

        call bookmarker#cursor#setup()
        call bookmarker#bookmarks#mappings()
        call bookmarker#directories#mappings()
        call bookmarker#recent#mappings()
        nnoremap <silent><buffer> f :call bookmarker#finder#file()<CR>
        nnoremap <silent><buffer> / :call bookmarker#finder#grep()<CR>
        nnoremap <silent><buffer> <CR> :call bookmarker#open_selected()<CR>
        nnoremap <silent><buffer> ? :call bookmarker#help#open()<CR>
        nnoremap <silent><buffer> q :call bookmarker#close()<CR>
        return
    endif

    call bookmarker#start(l:directory)
endfunction

function! bookmarker#close() abort
    " Find real/listed buffers. Vim's initial empty unnamed buffer can remain
    " listed behind Bookmarker; do not treat that placeholder as a file to
    " return to when Bookmarker is the only useful window.
    let l:listed_buffers = filter(
                \ range(1, bufnr('$')),
                \ 'buflisted(v:val)')
    let l:real_buffers = filter(copy(l:listed_buffers),
                \ '!empty(bufname(v:val))'
                \ . ' || getbufvar(v:val, "&modified")'
                \ . ' || getbufvar(v:val, "&buftype") !=# ""')

    if empty(l:real_buffers)
        quit
        return
    endif

    " Prefer Vim's alternate buffer when it is a real/listed buffer.
    let l:alternate_buffer = bufnr('#')

    if index(l:real_buffers, l:alternate_buffer) >= 0
                \ && bufloaded(l:alternate_buffer)
        execute 'buffer ' . l:alternate_buffer
    else
        execute 'buffer ' . l:real_buffers[0]
    endif

    if exists(':AirlineRefresh')
        silent! AirlineRefresh
    endif
endfunction

function! bookmarker#open_selected() abort
    let l:key = bookmarker#cursor#selected_key()

    if empty(l:key)
        return
    endif

    let l:current_line = line('.')
    let l:quick_bookmarks_line = 0
    let l:bookmark_folders_line = 0
    let l:recent_files_line = 0

    for l:line_number in range(1, line('$'))
        let l:text = getline(l:line_number)

        if l:text =~# '^\s*Quick bookmarks\s*$'
            let l:quick_bookmarks_line = l:line_number
        elseif l:text =~# '^\s*Bookmark folders\s*$'
            let l:bookmark_folders_line = l:line_number
        elseif l:text =~# '^\s*Recent files in current directory\s*$'
            let l:recent_files_line = l:line_number
        endif
    endfor

    let l:on_quick_bookmark = l:quick_bookmarks_line > 0
                \ && l:current_line > l:quick_bookmarks_line
                \ && (l:bookmark_folders_line == 0
                \     || l:current_line < l:bookmark_folders_line)

    if l:on_quick_bookmark
        call bookmarker#bookmarks#open(l:key)
        return
    endif

    if l:bookmark_folders_line > 0
                \ && l:current_line > l:bookmark_folders_line
                \ && (l:recent_files_line == 0
                \     || l:current_line < l:recent_files_line)

        call bookmarker#directories#open(l:key)
        return
    endif

    if l:recent_files_line > 0
                \ && l:current_line > l:recent_files_line
                \ && l:key =~# '^\d$'

        let l:index = l:key ==# '0' ? 9 : str2nr(l:key) - 1
        call bookmarker#recent#open(l:index)
        return
    endif

    if l:key ==# 'f'
        call bookmarker#finder#file()
        return
    endif

    if l:key ==# '/'
        call bookmarker#finder#grep()
        return
    endif

    call bookmarker#bookmarks#open(l:key)
endfunction
