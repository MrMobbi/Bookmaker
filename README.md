
 # Bookmarker

A lightweight Vim dashboard for quickly opening bookmarks, finding files, and searching inside your current project.

Bookmarker is inspired by dashboard plugins such as Startify, but focuses on providing a simple home screen built around your own file bookmarks and project navigation.

```text
                         BOOKMARKER

  [f] Find file with FZF in the current directory
  [/] Search text with ripgrep in the current directory


                Quick bookmarks

  [v] ~/.vimrc
  [z] ~/.zshrc
  [n] ~/.config/nvim/init.lua


                Bookmark folders

  [C] ~/.config/
  [P] ~/projects/
  [D] ~/Documents/


                Recent files in current directory

                PWD: [~/projects/my-project]

  [1] Recent file...
  [2] Recent file...
  [3] Recent file...


        <CR> open    ? help    q close
```

## Features

Bookmarker currently provides:

* A dedicated Vim dashboard buffer
* Configurable quick file bookmarks
* One-key bookmark opening
* Optional file icons with `vim-devicons`
* File searching with FZF
* Text searching with ripgrep and FZF
* Searches rooted in the directory where Vim was started
* Buffer-local mappings that do not replace your normal Vim mappings
* Syntax highlighting for the Bookmarker dashboard
* vim-airline integration
* `q` to return to another buffer or quit Vim when no useful buffer remains

More features are planned, including bookmark folders and recent files.

## Requirements

Bookmarker is written for Vim.

For file searching:

* [fzf](https://github.com/junegunn/fzf)
* [fzf.vim](https://github.com/junegunn/fzf.vim)

For text searching:

* [ripgrep](https://github.com/BurntSushi/ripgrep)

Optional:

* [vim-devicons](https://github.com/ryanoasis/vim-devicons) for file icons
* [vim-airline](https://github.com/vim-airline/vim-airline) for statusline integration
* A Nerd Font if you want file icons to display correctly

## Installation

### vim-plug

Because the Vim runtime files live inside the `bookmarker.vim` directory, specify it as the runtime path:

```vim
call plug#begin()

Plug 'MrMobbi/Bookmaker', {
      \ 'rtp': 'bookmarker.vim',
      \ }

" File finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Optional icons
Plug 'ryanoasis/vim-devicons'

call plug#end()
```

Then run:

```vim
:PlugInstall
```

## Usage

Open Bookmarker with:

```vim
:Bookmarker
```

You can also create a mapping in your `.vimrc`:

```vim
nnoremap <silent> <leader>bm :Bookmarker<CR>
```

For example, if your leader key is Space:

```text
Space b m
```

opens the dashboard.

To display Bookmarker help:

```vim
:Bookmarker help
```

## Quick bookmarks

Quick bookmarks are configured in your `.vimrc`.

Each bookmark contains:

```text
key → file path
```

For example:

```vim
let g:bookmarker_quick_bookmarks = [
      \ { 'z': '~/.zshrc' },
      \ { 'v': '~/.vimrc' },
      \ { 'n': '~/.config/nvim/init.lua' },
      \ { 'i': '~/.config/i3/config' },
      \ { 't': '~/.config/terminator/config' },
      \ ]
```

Bookmarker will display them as:

```text
Quick bookmarks

[z] ~/.zshrc
[v] ~/.vimrc
[n] ~/.config/nvim/init.lua
[i] ~/.config/i3/config
[t] ~/.config/terminator/config
```

Press the key shown inside `[]` to open the corresponding file.

For example:

```text
v
```

opens:

```text
~/.vimrc
```

These mappings only exist inside the Bookmarker buffer. Your normal Vim mappings remain unchanged everywhere else.

## File finder

Press:

```text
f
```

inside Bookmarker to open FZF.

The search starts from the directory where Vim was originally launched.

For example:

```sh
cd ~/projects/my-project
vim
```

Bookmarker remembers:

```text
~/projects/my-project
```

and FZF searches from that directory.

Selecting a file opens it in Vim.

## Text search

Press:

```text
/
```

inside Bookmarker to search the current project using ripgrep and FZF.

The search is also rooted in the directory where Vim was originally started.

This keeps project searching independent from bookmarks and future bookmark-folder navigation.

## Dashboard mappings

Inside Bookmarker:

| Key                     | Action                   |
| ----------------------- | ------------------------ |
| `f`                     | Find a file with FZF     |
| `/`                     | Search text with ripgrep |
| configured bookmark key | Open that bookmark       |
| `q`                     | Close Bookmarker         |

Additional navigation and actions will be added as the plugin develops.

## Optional file icons

If `vim-devicons` is installed, Bookmarker automatically displays an icon beside quick bookmarks.

Without `vim-devicons`:

```text
[v] ~/.vimrc
```

With `vim-devicons`:

```text
[v]  ~/.vimrc
```

Bookmarker does not require icons to work.

## Startup directory

Bookmarker remembers the working directory from which Vim was started.

For example:

```sh
cd ~/projects/bookmarker
vim
```

The dashboard keeps:

```text
PWD: [~/projects/bookmarker]
```

File finding, text searching, and future recent-file functionality use this directory as the project context.

## Statusline

Bookmarker supports vim-airline and uses a dashboard-style Airline section similar to Startify when Airline is available.

vim-airline is optional; Bookmarker can still be used without it.

## Development

Clone the repository:

```sh
git clone https://github.com/MrMobbi/Bookmaker.git
cd Bookmaker
```

For local development with vim-plug, point Vim directly at the cloned runtime directory:

```vim
Plug '~/projects/Bookmaker/bookmarker.vim'
```

A development reload command can also be useful while working on the plugin:

```vim
command! BookmarkerReload
      \ source ~/projects/Bookmaker/bookmarker.vim/plugin/bookmarker.vim |
      \ source ~/projects/Bookmaker/bookmarker.vim/autoload/bookmarker.vim |
      \ source ~/projects/Bookmaker/bookmarker.vim/autoload/bookmarker/ui.vim |
      \ source ~/projects/Bookmaker/bookmarker.vim/autoload/bookmarker/finder.vim |
      \ source ~/projects/Bookmaker/bookmarker.vim/autoload/bookmarker/cursor.vim |
      \ source ~/projects/Bookmaker/bookmarker.vim/autoload/bookmarker/bookmarks.vim |
      \ echo 'Bookmarker reloaded'

nnoremap <leader>br :BookmarkerReload<CR>
```

Adjust the path to match where you cloned the repository.

## Project structure

```text
Bookmaker/
├── bookmarker.vim/
│   ├── autoload/
│   │   ├── bookmarker.vim
│   │   └── bookmarker/
│   │       ├── bookmarks.vim
│   │       ├── cursor.vim
│   │       ├── finder.vim
│   │       └── ui.vim
│   ├── plugin/
│   │   └── bookmarker.vim
│   └── syntax/
│       └── bookmarker.vim
└── README.md
```

The different modules are responsible for separate parts of Bookmarker:

* `plugin/bookmarker.vim` — plugin initialization and `:Bookmarker`
* `autoload/bookmarker.vim` — dashboard lifecycle
* `autoload/bookmarker/bookmarks.vim` — bookmark configuration and opening
* `autoload/bookmarker/cursor.vim` — dashboard cursor navigation
* `autoload/bookmarker/finder.vim` — FZF and ripgrep integration
* `autoload/bookmarker/ui.vim` — dashboard layout
* `syntax/bookmarker.vim` — Bookmarker syntax highlighting

## Roadmap

Bookmarker is still under development.

Planned features include:

* Bookmark folders
* Nested bookmark navigation
* Recent files from the startup directory
* Numbered recent-file shortcuts
* Improved help screen
* Reserved-key validation
* More customization options

## License

A license has not been added yet.

# Bookmaker
``` text
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
```
