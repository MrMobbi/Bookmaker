
" Prevent the plugin from loading twice
if exists("g:loaded_bookmaker")
	finish
endif
let g:loaded_bookmaker = 1

" Register the :Bookmaker command
command! Bookmaker call bookmaker_start#open()
