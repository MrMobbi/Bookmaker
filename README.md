# Bookmaker
command! BookmarkerReload
\ source ~/project/Bookmarker/bookmarker.vim/plugin/bookmarker.vim |
\ source ~/project/Bookmarker/bookmarker.vim/autoload/bookmarker.vim |
\ source ~/project/Bookmarker/bookmarker.vim/autoload/bookmarker/ui.vim |
\ source ~/project/Bookmarker/bookmarker.vim/autoload/bookmarker/finder.vim |
\ source ~/project/Bookmarker/bookmarker.vim/autoload/bookmarker/cursor.vim |
\ source ~/project/Bookmarker/bookmarker.vim/autoload/bookmarker/bookmarks.vim |
\ echo 'Bookmarker Start reloaded'

nnoremap <leader>br :BookmarkerReload<CR>
nnoremap <leader>bm :Bookmarker<CR>

let g:bookmarker_quick_bookmarks = [
      \ { 'z' : '~/.zshrc' },
      \ { 'v' : '~/.vimrc' },
      \ { 'n' : '~/.config/nvim/init.lua'},
      \ { 'i' : '~/.config/i3/config' },
      \ { 't' : '~/.config/terminator/config' },
      \ { 'c' : '~/.vim/plugin/cheatsheet.vim' },
      \ ]
