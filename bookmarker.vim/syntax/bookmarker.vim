if exists('b:current_syntax')
    finish
endif

syntax sync fromstart


" Title
syntax match BookmarkerTitle
            \ /^\s*BOOKMARKER\s*$/


" Section titles
syntax match BookmarkerSection
            \ /^\s*\%(Quick bookmarks\|Bookmark folders\|Recent files in current directory\)\s*$/


" General keys: [v] [C] [/] [f]
syntax match BookmarkerKey
            \ /\[[^]]\+\]/


" Paths beginning with ~/
syntax match BookmarkerPath
            \ /\~\/\S*/


" PWD
syntax match BookmarkerPWD
            \ /^\s*PWD:.*$/


" Bottom help
syntax match BookmarkerHelp
            \ /^\s*<CR>.*$/


" --------------------------------------------------
" Recent files - Startify style
" --------------------------------------------------

syntax match BookmarkerRecentFile
            \ /^\s*\[[0-9]\].*$/
            \ contains=BookmarkerRecentBracket,
            \          BookmarkerRecentPath

syntax match BookmarkerRecentBracket
            \ /^\s*\[[0-9]\]/
            \ contained
            \ contains=BookmarkerRecentNumber

syntax match BookmarkerRecentNumber
            \ /\[\zs[0-9]\ze\]/
            \ contained

syntax match BookmarkerRecentPath
            \ /\S*\/\ze[^\/[:space:]]\+$/
            \ contained
            \ contains=BookmarkerRecentSlash

syntax match BookmarkerRecentSlash
            \ /\//
            \ contained


" --------------------------------------------------
" Highlights
" --------------------------------------------------

highlight default link BookmarkerTitle   Title
highlight default link BookmarkerSection Statement
highlight default link BookmarkerKey     Special
highlight default link BookmarkerPath    Directory
highlight default link BookmarkerPWD     Comment
highlight default link BookmarkerHelp    Comment

highlight default link BookmarkerRecentFile     Identifier
highlight default link BookmarkerRecentBracket  Delimiter
highlight default link BookmarkerRecentNumber   Number
highlight default link BookmarkerRecentPath     Directory
highlight default link BookmarkerRecentSlash    Delimiter


let b:current_syntax = 'bookmarker'
