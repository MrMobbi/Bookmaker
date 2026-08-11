
function! bookmarker_start#open() abort

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
	let b:bookmarker_start_previous_buffer = l:previous_buffer

	" Rember the starting directory.
	let b:bookmarker_path_start_directory = get(
		\ b:,
		\ 'bookmarker_path_start_directory',
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

	" Render the Home page
	call setline(1, bookmarker_start#ui#layout(
		\ b:bookmarker_path_start_directory))

	" Protect the dashboard from accidental editing.
	setlocal nomodifiable
	setlocal nomodified

	"this mapping only exists in the dashboard buffer
	nnoremap <silent><buffer> q :call bookmarker_start#close()<CR>

endfunction

function! bookmarker_start#close() abort
	let l:dashboard_buffer = bufnr('%')
	let l:previous_buffer = get(
		\ b:,
		\ 'bookmarker_start_previous_buffer',
		\ -1
		\ )

	let l:previous_statusline = get(
		\ w:,
		\ 'bookmarker_previous_statusline',
		\ ''
		\ )

	if l:previous_buffer > 0
				\ && l:previous_buffer != l:dashboard_buffer
				\ && bufexists(l:previous_buffer)

		" Restore the previous status line
		let &l:statusline = l:previous_statusline

		" Let airline redraw the status line
		if exists(':AirlineRefresh')
			silent! AirlineRefresh
		endif

		" Go back to the previous buffer
		execute 'buffer ' . l:previous_buffer
	else
		" No valid previous buffer, delete the dashboard buffer
		execute 'bdelete! ' . l:dashboard_buffer
	endif
endfunction
