
function! bookmaker_start#open() abort

	" Remeber the current file buffer.
	let l:previous_buffer = bufnr('%')

	" Create and enter a distinct dashboard buffer.
	let l:dashboard_buffer = bufadd('[Bookmaker]')
	call bufload(l:dashboard_buffer)
	execute 'hide buffer ' . l:dashboard_buffer

	" Save the previous buffer number in the dashboard.
	let b:bookmaker_start_previous_buffer = l:previous_buffer

	" Turn in into a plugin-controller scratch buffer.
	setlocal buftype=nofile
	setlocal bufhidden=wipe
	setlocal noswapfile
	setlocal nobuflisted

	" Dasboard apparence.
	setlocal nonumber
	setlocal norelativenumber
	setlocal nowrap
	setlocal nocursorline

	" Give the buffer a recognizable name.
	execute 'file [Bookmaker]'

	" Write the first Dasboard.
	call setline(1, [
				\ '',
				\ '		Bookmaker',
				\ '',
				\ '		This is a test text',
				\ '',
				\ '		Press q to exit',
				\ ''
				\ ])

	" Protect the dashboard from accidental editing.
	setlocal nomodifiable
	setlocal nomodified

	"this mapping only exists in the dashboard buffer
	nnoremap <silent><buffer> q :call bookmaker_start#close()<CR>

endfunction

function! bookmaker_start#close() abort
	let l:dashboard_buffer = bufnr('%')
	let l:previous_buffer = get(
		\ b:,
		\ 'bookmaker_start_previous_buffer',
		\ -1
		\ )

	if l:previous_buffer > 0
				\ && l:previous_buffer != l:dashboard_buffer
				\ && bufexists(l:previous_buffer)

		" Go back to the previous buffer
		execute 'buffer ' . l:previous_buffer
	else
		" No valid previous buffer, delete the dashboard buffer
		execute 'bdelete! ' . l:dashboard_buffer
	endif
endfunction
