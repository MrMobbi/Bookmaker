
function! bookmarker#open() abort

	" Remeber the current file buffer.
	let l:previous_buffer = bufnr('%')

	" Create and enter a distinct dashboard buffer.
	let l:dashboard_buffer = bufadd('')

	call setbufvar(l:dashboard_buffer, '&buftype', 'nofile')
	call setbufvar(l:dashboard_buffer, '&bufhidden', 'wipe')
	call setbufvar(l:dashboard_buffer, '&swapfile', 0)
	call setbufvar(l:dashboard_buffer, '&buflisted', 0)

	call bufload(l:dashboard_buffer)
	execute 'hide buffer ' . l:dashboard_buffer

	" Set the file type for syntax highlighting
	setfiletype bookmarker

	" Save the previous buffer number in the dashboard.
	let b:bookmarker_previous_buffer = l:previous_buffer

	" Rember the starting directory.
	let b:bookmarker_path_directory = get(
		\ g:,
		\ 'bookmarker_path_directory',
		\ getcwd()
		\ )

	" Changine status line
	let w:bookmarker_previous_statusline = &l:statusline

	setlocal statusline=\ Bookmarker

	" Turn in into a plugin-controller scratch buffer.
	setlocal noswapfile
	setlocal nobuflisted
	setlocal nonumber
	setlocal norelativenumber
	setlocal nowrap
	setlocal nocursorline

	" Give the buffer a recognizable name.
	execute 'file [Bookmarker]'

	" Get the bookmarks
	let l:bookmarks = bookmarker#bookmarks#get()

	" Render the Home page
	call setline(1, bookmarker#ui#layout(
		\ b:bookmarker_path_directory,
		\ l:bookmarks))

	" Protect the dashboard from accidental editing.
	setlocal nomodifiable
	setlocal nomodified

	" Move the cursor to the first selectable item.
	call bookmarker#cursor#setup()

	" Set up the mapping for the bookmarks
	call bookmarker#bookmarks#mappings()

	augroup bookmarker_cursor
		autocmd!
		autocmd CursorMoved <buffer> call bookmarker#cursor#lock()
	augroup END

	"this mapping only exists in the dashboard buffer
	nnoremap <silent><buffer> q :call bookmarker#close()<CR>

endfunction

function! bookmarker#close() abort
    " Find all listed buffers.
    let l:listed_buffers = filter(
                \ range(1, bufnr('$')),
                \ 'buflisted(v:val)'
                \ )

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
