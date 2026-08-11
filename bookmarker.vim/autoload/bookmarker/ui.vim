function! bookmarker#ui#layout(start_directory) abort
    " Display ~/projects instead of /home/user/projects.
    let l:directory = fnamemodify(
                \ a:start_directory,
                \ ':~'
                \ )

    return [
                \ '',
                \ '                         BOOKMARKER',
                \ '',
                \ '  [f] Find file with FZF in the current directory',
                \ '  [/] Search text with ripgrep in the current directory',
                \ '',
                \ '',
                \ '		Quick bookmarks',
                \ '',
                \ '  [v] Vim configuration          ~/.vimrc',
                \ '  [z] Zsh configuration          ~/.zshrc',
                \ '  [g] Git configuration          ~/.gitconfig',
                \ '  [c] Curl configuration         ~/.curlrc',
                \ '',
                \ '',
                \ '		Bookmark folders',
                \ '',
                \ '  [C] Configuration              ~/.config/',
                \ '  [P] Projects                   ~/projects/',
                \ '  [D] Documents                  ~/Documents/',
                \ '',
                \ '',
                \ '		Recent files in current directory',
                \ '',
                \ '		PWD: [' . l:directory . ']',
                \ '',
                \ '  [1] Recent file placeholder',
                \ '  [2] Recent file placeholder',
                \ '  [3] Recent file placeholder',
                \ '',
                \ '',
                \ '        <CR> open    ? help    q close',
                \ '',
                \ ]
endfunction
