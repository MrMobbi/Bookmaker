function! bookmarker#help#open() abort
    echo join([
                \ 'Bookmarker',
                \ '',
                \ 'Commands:',
                \ '  :Bookmarker        Open Bookmarker',
                \ '  :Bookmarker help   Show this help',
                \ '',
                \ 'Dashboard:',
                \ '  f                  Find files with FZF',
                \ '  /                  Search text with ripgrep',
                \ '  q                  Close Bookmarker',
                \ '',
                \ 'Quick bookmarks:',
                \ '  Press the key shown inside [ ] to open the bookmark.',
                \ '  Example: [v] ~/.vimrc -> press v',
                \ '',
                \ 'Search directory:',
                \ '  FZF and ripgrep search from the directory where Vim',
                \ '  was started.',
                \ '',
                \ ], "\n")
endfunction
