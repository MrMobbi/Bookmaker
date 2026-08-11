
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
command! Bookmarker call bookmarker#open()
