
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

	" This mapping open the fzf finder
	nnoremap <silent><buffer> f :call bookmarker#finder#file()<CR>

	" This mapping open reggrep
	nnoremap <silent><buffer> / :call bookmarker#finder#grep()<CR>

	" Open the item under the cursor.
	nnoremap <silent><buffer> <CR> :call bookmarker#open_selected()<CR>

	augroup bookmarker_cursor
		autocmd!
		autocmd CursorMoved <buffer> call bookmarker#cursor#lock()
	augroup END

	"this mapping only exists in the dashboard buffer
	nnoremap <silent><buffer> q :call bookmarker#close()<CR>

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
        nnoremap <silent><buffer> q :call bookmarker#close()<CR>
        return
    endif

    call bookmarker#start(l:directory)
endfunction

function! bookmarker#close() abort
    " Find all listed buffers.
    let l:listed_buffers = filter(
                \ range(1, bufnr('$')),
                \ 'buflisted(v:val)')

    " There are real/listed buffers available.
    if !empty(l:listed_buffers)

        " Prefer Vim's alternate buffer.
        let l:alternate_buffer = bufnr('#')

        if l:alternate_buffer > 0
                    \ && bufloaded(l:alternate_buffer)
                    \ && buflisted(l:alternate_buffer)

            execute 'buffer ' . l:alternate_buffer

        else
            bnext
        endif

        if exists(':AirlineRefresh')
            silent! AirlineRefresh
        endif

        return
    endif
    quit
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
