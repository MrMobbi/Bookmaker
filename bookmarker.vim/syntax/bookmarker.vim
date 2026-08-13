
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

" Entire recent-file entry.
syntax region BookmarkerRecentLine
            \ start=/^\s*\[[0-9]\]/
            \ end=/$/
            \ contains=BookmarkerKey,
            \          BookmarkerRecentDirectory,
            \          BookmarkerRecentFile

" Everything ending with / is the directory part.
syntax match BookmarkerRecentDirectory
            \ /\%(\~\/\)\?\%([^[:space:]\/]\+\/\)\+/
            \ contained

" The final component is the filename.
syntax match BookmarkerRecentFile
            \ /[^\/[:space:]]\+$/
            \ contained



" Use standard Vim highlight groups.
highlight default link BookmarkerTitle			 Title
highlight default link BookmarkerSection		 Statement
highlight default link BookmarkerKey    		 Special
highlight default link BookmarkerPath   		 Directory
highlight default link BookmarkerPWD    		 Comment
highlight default link BookmarkerHelp   		 Comment
highlight default link BookmarkerRecentDirectory Directory
highlight default link BookmarkerRecentFile      String


let b:current_syntax = 'bookmarker'
