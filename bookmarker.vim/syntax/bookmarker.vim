if exists('b:current_syntax')
    finish
endif

syntax sync fromstart

" --------------------------------------------------
" Startify-style dashboard regions
" --------------------------------------------------

" Main ASCII/title line.
syntax match BookmarkerHeader
            \ /^\s*BOOKMARKER\s*$/

" Section headers.
syntax match BookmarkerSection
            \ /^\s*\%(Quick bookmarks\|Bookmark folders\|Recent files in current directory\)\s*$/

" Current dashboard directory line.
syntax match BookmarkerPWD
            \ /^\s*PWD:.*$/
            \ contains=BookmarkerPath,BookmarkerBracket

" Bottom help/footer.
syntax match BookmarkerFooter
            \ /^\s*<CR>.*$/
            \ contains=BookmarkerSpecial

" Selectable rows, similar to StartifyFile.
syntax match BookmarkerFile
            \ /^\s*\[[^]]\+\].*$/
            \ contains=BookmarkerBracket,
            \          BookmarkerNumber,
            \          BookmarkerSelect,
            \          BookmarkerPath,
            \          BookmarkerSlash,
            \          BookmarkerSpecial

" Brackets are dim delimiters; the text inside gets its own group.
syntax match BookmarkerBracket
            \ /^\s*\[[^]]\+\]/
            \ contained
            \ contains=BookmarkerNumber,BookmarkerSelect

" Numbered recent-file entries.
syntax match BookmarkerNumber
            \ /\[\zs[0-9]\ze\]/
            \ contained

" Action keys and common letter bookmark keys.
syntax match BookmarkerSelect
            \ /\[\zs[^0-9\]]\+\ze\]/
            \ contained

" Paths are muted like StartifyPath.  This covers absolute paths, ~/ paths,
" drive-letter paths, and relative entries containing a slash.
syntax match BookmarkerPath
            \ /\%([~.]\=\/\|[A-Za-z]:[\\/]\|\S\+\/\)\S*/
            \ contained
            \ contains=BookmarkerSlash

syntax match BookmarkerSlash
            \ /\//
            \ contained

" Things that should be quiet, like StartifySpecial.
syntax match BookmarkerSpecial
            \ /<CR>\|PWD:\|Find file with FZF\|Search text with ripgrep\|open\|help\|close/
            \ contained

" --------------------------------------------------
" Highlights
" --------------------------------------------------
" These links intentionally mirror vim-startify's default feel:
" header/footer = Title, sections = Statement, entries = Identifier,
" numbers = Number, paths/slashes = Directory/Delimiter.
highlight default link BookmarkerBracket Delimiter
highlight default link BookmarkerFile    Identifier
highlight default link BookmarkerFooter  Title
highlight default link BookmarkerHeader  Title
highlight default link BookmarkerNumber  Number
highlight default link BookmarkerPath    Directory
highlight default link BookmarkerPWD     Comment
highlight default link BookmarkerSection Statement
highlight default link BookmarkerSelect  Title
highlight default link BookmarkerSlash   Delimiter
highlight default link BookmarkerSpecial Comment

" Backwards-compatible group names from the first syntax version.
highlight default link BookmarkerTitle         BookmarkerHeader
highlight default link BookmarkerHelp          BookmarkerFooter
highlight default link BookmarkerKey           BookmarkerSelect
highlight default link BookmarkerRecentFile    BookmarkerFile
highlight default link BookmarkerRecentBracket BookmarkerBracket
highlight default link BookmarkerRecentNumber  BookmarkerNumber
highlight default link BookmarkerRecentPath    BookmarkerPath
highlight default link BookmarkerRecentSlash   BookmarkerSlash

let b:current_syntax = 'bookmarker'
