
if exists("b:current_syntax")
	finish
endif

" Title
syntax match BookmarkerTitle
            \ /^\s*BOOKMARKER\s*$/


" Section titles
syntax match BookmarkerSection
            \ /^\s*\%(Quick bookmarks\|Bookmark folders\|Recent files in current directory\)\s*$/


" Keys: [v] [C] [1] [/] [f]
syntax match BookmarkerKey
            \ /\[[^]]\+\]/


" Paths beginning with ~/
syntax match BookmarkerPath
            \ /\~\/\S*/


" PWD line
syntax match BookmarkerPWD
            \ /^\s*PWD:.*$/


" Bottom help text
syntax match BookmarkerHelp
            \ /^\s*<CR>.*$/


" Use standard Vim highlight groups.
highlight default link BookmarkerTitle   Title
highlight default link BookmarkerSection Statement
highlight default link BookmarkerKey     Special
highlight default link BookmarkerPath    Directory
highlight default link BookmarkerPWD     Comment
highlight default link BookmarkerHelp    Comment


let b:current_syntax = 'bookmarker'
