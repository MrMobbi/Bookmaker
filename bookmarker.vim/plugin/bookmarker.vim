
" Prevent the plugin from loading twice
if exists("g:loaded_bookmarker")
	finish
endif

let g:loaded_bookmarker = 1

" Remeber the directory where vim started.
if !exists("g:bookmarker_path_directory")
	let g:bookmarker_path_directory = getcwd()
endif

" Register the :Bookmarker command
command! -nargs=? -complete=dir Bookmarker call bookmarker#command(<q-args>)

" Open Bookmarker automatically when Vim starts without file arguments.
" Set g:bookmarker_disable_at_vimenter to 1 to open it manually instead.
augroup bookmarker_startup
	autocmd!
	autocmd VimEnter * if argc() == 0
			\ && !get(g:, 'bookmarker_disable_at_vimenter', 0)
			\ | call bookmarker#start() | endif
augroup END
