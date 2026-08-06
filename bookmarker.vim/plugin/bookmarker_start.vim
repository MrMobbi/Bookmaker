
" Prevent the plugin from loading twice
if exists("g:loaded_bookmarker")
	finish
endif
let g:loaded_bookmarker = 1

" Register the :Bookmarker command
command! Bookmarker call bookmarker_start#open()
