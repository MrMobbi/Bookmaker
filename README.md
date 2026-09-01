# Bookmarker

A lightweight Vim dashboard for quickly opening bookmarks, directory bookmarks, recent files, and project search tools.

Bookmarker is inspired by dashboard plugins such as Startify, but focuses on a small home screen built around your own project navigation shortcuts.

```text
                    .
                   ":"
                 ___:____     |"\/"|
               ,'        `.    \  /
               |  O        \___/  |
             ~^~^~^~^~^~^~^~^~^~^~^~^~

                         BOOKMARKER

  [f] Find file with FZF in the current directory
  [/] Search text with ripgrep in the current directory


                Quick bookmarks

  [v] ~/.vimrc
  [z] ~/.zshrc
  [n] ~/.config/nvim/init.lua


                Bookmark folders

  [C] Configuration              ~/.config/
  [P] Projects                   ~/projects/
  [D] Documents                  ~/Documents/


                Recent files in current directory

                PWD: [~/projects/my-project]

  [1] README.md
  [2] autoload/bookmarker.vim
  [3] plugin/bookmarker.vim

        <CR> open    ? help    q close
```

## Features

Bookmarker currently provides:

* A dedicated Vim dashboard buffer
* Configurable quick file bookmarks
* Configurable directory bookmarks
* Folder-specific dashboard pages with their own file and child-folder bookmarks
* Directory bookmarks open another Bookmarker page rooted at that directory
* Recent files from the active dashboard directory, based on `v:oldfiles`
* Numbered recent-file shortcuts, from `1` through `9` and then `0`
* `<CR>` to open the item under the cursor
* One-key opening for quick bookmarks, directory bookmarks, and recent files
* File searching with FZF
* Text searching with ripgrep through `:Rg`
* Searches rooted in the active dashboard directory
* Buffer-local mappings that do not replace your normal Vim mappings
* Syntax highlighting for the Bookmarker dashboard
* Optional file icons with `vim-devicons`
* Optional vim-airline integration
* `q` to return to another buffer or quit Vim when no useful buffer remains

Bookmarker is still under development. Directory bookmarks now navigate to nested Bookmarker pages; richer directory browsing can still be added later.

## Requirements

Bookmarker is written for Vim.

Required:

* Vim with `+eval`

For file searching:

* [fzf](https://github.com/junegunn/fzf)
* [fzf.vim](https://github.com/junegunn/fzf.vim)

For text searching:

* [ripgrep](https://github.com/BurntSushi/ripgrep)
* `:Rg`, provided by fzf.vim's ripgrep integration

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

" File finder and :Rg
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

For local development with vim-plug, point Vim directly at the cloned runtime directory:

```vim
Plug '~/projects/Bookmarker/bookmarker.vim'
```

Adjust the path to match where you cloned the repository.

## Usage

Open Bookmarker with:

```vim
:Bookmarker
```

Open Bookmarker directly on a folder page with:

```vim
:Bookmarker ~/Documents
```

You can also create a mapping in your `.vimrc`:

```vim
nnoremap <silent> <leader>bm :Bookmarker<CR>
```

Bookmarker opens automatically when Vim starts without file arguments. To
disable automatic startup and open it only with `:Bookmarker` or your mapping,
add this to your `.vimrc`:

```vim
let g:bookmarker_disable_at_vimenter = 1
```

Set it to `0` to enable the automatic Bookmarker dashboard again.

To display Bookmarker help:

```vim
:Bookmarker help
```

## Dashboard mappings

Inside the Bookmarker dashboard:

| Key                     | Action                       |
| ----------------------- | ---------------------------- |
| `<CR>`                  | Open the item under cursor   |
| `f`                     | Find a file with FZF         |
| `/`                     | Search text with ripgrep     |
| configured file key     | Open that quick bookmark     |
| configured directory key | Open that directory bookmark |
| recent file number      | Open that recent file        |
| `q`                     | Close Bookmarker             |

All mappings are buffer-local to the Bookmarker dashboard.

## Quick file bookmarks

Quick file bookmarks are configured in your `.vimrc` with `g:bookmarker_quick_bookmarks`.

Each bookmark is a dictionary with one key-value pair:

```text
key -> file path
```

Example:

```vim
let g:bookmarker_quick_bookmarks = [
      \ { 'z': '~/.zshrc' },
      \ { 'v': '~/.vimrc' },
      \ { 'n': '~/.config/nvim/init.lua' },
      \ { 'i': '~/.config/i3/config' },
      \ { 't': '~/.config/terminator/config' },
      \ ]
```

Bookmarker displays them as:

```text
Quick bookmarks

[z] ~/.zshrc
[v] ~/.vimrc
[n] ~/.config/nvim/init.lua
[i] ~/.config/i3/config
[t] ~/.config/terminator/config
```

Open a quick bookmark by pressing its key, or by moving the cursor onto its line and pressing `<CR>`.

If the file does not exist, Bookmarker shows a warning:

```text
[Bookmarker] File not found: ...
```

## Directory bookmarks

Directory bookmarks are configured in your `.vimrc` with `g:bookmarker_directory_bookmarks`.

Each directory bookmark may use a label and a path:

```vim
let g:bookmarker_directory_bookmarks = [
      \ { 'C': { 'label': 'Configuration', 'path': '~/.config/' } },
      \ { 'P': { 'label': 'Projects', 'path': '~/projects/' } },
      \ { 'D': { 'label': 'Documents', 'path': '~/Documents/' } },
      \ ]
```

A shorthand string form is also accepted:

```vim
let g:bookmarker_directory_bookmarks = [
      \ { 'P': '~/projects/' },
      \ ]
```

If no directory bookmarks are configured, Bookmarker defaults to:

```vim
let g:bookmarker_directory_bookmarks = [
      \ { 'C': { 'label': 'Configuration', 'path': '~/.config/' } },
      \ { 'P': { 'label': 'Projects', 'path': '~/projects/' } },
      \ { 'D': { 'label': 'Documents', 'path': '~/Documents/' } },
      \ ]
```

Open a directory bookmark by pressing its key, or by moving the cursor onto its line and pressing `<CR>`.

Directory bookmarks open another Bookmarker page rooted at that directory. That folder page keeps the same dashboard layout, but its file bookmarks, child folder bookmarks, recent files, FZF, and ripgrep are all scoped to that folder.

## Folder-specific pages

Folder-specific pages are configured with `g:bookmarker_folder_bookmarks`. The dictionary key is the folder path. Each value can contain:

* `bookmarks`: quick file bookmarks for that folder page
* `directories`: child folder bookmarks for that folder page

Paths inside a folder page can be absolute, `~`-based, or relative to that folder.

Example:

```vim
let g:bookmarker_folder_bookmarks = {
      \ '~/Documents/': {
      \   'bookmarks': [
      \     { 'n': 'notes/today.md' },
      \     { 'r': 'resume.pdf' },
      \   ],
      \   'directories': [
      \     { 'w': { 'label': 'Work', 'path': 'Work/' } },
      \     { 'p': { 'label': 'Personal', 'path': 'Personal/' } },
      \   ],
      \ },
      \ '~/Documents/Work/': {
      \   'bookmarks': [
      \     { 'm': 'meeting-notes.md' },
      \   ],
      \   'directories': [
      \     { 'a': { 'label': 'Archive', 'path': 'Archive/' } },
      \   ],
      \ },
      \ }
```

With this setup, opening the `D` directory bookmark for `~/Documents/` shows a Bookmarker page for Documents. Pressing `w` there opens another Bookmarker page for `~/Documents/Work/`, with the Work-specific bookmarks.

If a folder is not listed in `g:bookmarker_folder_bookmarks`, it uses the global `g:bookmarker_quick_bookmarks` and `g:bookmarker_directory_bookmarks`.

If the directory does not exist, Bookmarker shows a warning:

```text
[Bookmarker] Directory not found: ...
```

## Recent files

Bookmarker shows recent files from Vim's `v:oldfiles`, filtered to the active dashboard directory.

Recent files behavior:

* Only readable files are shown
* Files outside the startup directory are ignored
* Duplicate paths are skipped
* At most 10 recent files are shown
* Recent files use number keys `1` through `9`, then `0` for the tenth entry

Open a recent file by pressing its number, or by moving the cursor onto its line and pressing `<CR>`.

## File finder

Press `f` inside Bookmarker to open FZF.

The search starts from the active dashboard directory.

For example:

```sh
cd ~/projects/my-project
vim
```

The first dashboard opens at:

```text
~/projects/my-project
```

If you then enter a child folder page, FZF searches from that child folder instead.

Selecting a file opens it in Vim.

## Text search

Press `/` inside Bookmarker to search the current project using ripgrep and FZF.

The search is rooted in the active dashboard directory. Bookmarker temporarily changes the local working directory for the dashboard window before running `:Rg`.

## Dashboard directory

Bookmarker stores the active dashboard directory in `b:bookmarker_path_directory`.

For example:

```sh
cd ~/projects/bookmarker
vim
```

The first dashboard uses:

```text
~/projects/bookmarker
```

and folder pages update `b:bookmarker_path_directory` to the folder you opened.

File finding, text searching, and recent-file filtering use the active dashboard directory as the project context.

## Syntax highlighting

Bookmarker's syntax highlighting is intentionally close to vim-startify: the title and selected keys are highlighted like titles, sections like statements, rows like identifiers, numbers as numbers, paths as directories, and slashes/brackets as delimiters. You can customize the look by overriding the `Bookmarker*` highlight groups in your colorscheme or `.vimrc`.

Useful groups:

* `BookmarkerHeader`
* `BookmarkerSection`
* `BookmarkerFile`
* `BookmarkerBracket`
* `BookmarkerNumber`
* `BookmarkerSelect`
* `BookmarkerPath`
* `BookmarkerSlash`
* `BookmarkerFooter`

## Optional file icons

If `vim-devicons` is installed, Bookmarker displays an icon beside quick bookmarks and recent files.

Without `vim-devicons`:

```text
[v] ~/.vimrc
```

With `vim-devicons`:

```text
[v]  ~/.vimrc
```

Bookmarker does not require icons to work.

## Statusline

Bookmarker supports vim-airline and uses a dashboard-style Airline section when Airline is available.

vim-airline is optional; Bookmarker can still be used without it.

## Development

Clone the repository:

```sh
git clone git@github.com:MrMobbi/Bookmaker.git Bookmarker
cd Bookmarker
```

A development reload command can be useful while working on the plugin:

```vim
command! BookmarkerReload
      \ source ~/projects/Bookmarker/bookmarker.vim/plugin/bookmarker.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/ui.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/finder.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/cursor.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/bookmarks.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/directories.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/help.vim |
      \ source ~/projects/Bookmarker/bookmarker.vim/autoload/bookmarker/recent.vim |
      \ echo 'Bookmarker reloaded'

nnoremap <leader>br :BookmarkerReload<CR>
```

Adjust the path to match where you cloned the repository.

## Project structure

```text
Bookmarker/
├── README.md
├── bookmarker.vim/
│   ├── autoload/
│   │   ├── bookmarker.vim
│   │   └── bookmarker/
│   │       ├── bookmarks.vim
│   │       ├── cursor.vim
│   │       ├── directories.vim
│   │       ├── finder.vim
│   │       ├── help.vim
│   │       ├── recent.vim
│   │       └── ui.vim
│   ├── plugin/
│   │   └── bookmarker.vim
│   └── syntax/
│       └── bookmarker.vim
└── docs/
```

The different modules are responsible for separate parts of Bookmarker:

* `plugin/bookmarker.vim` — plugin initialization and `:Bookmarker`
* `autoload/bookmarker.vim` — dashboard lifecycle and selected-item dispatch
* `autoload/bookmarker/bookmarks.vim` — quick file bookmark configuration, mappings, and opening
* `autoload/bookmarker/cursor.vim` — dashboard cursor navigation and selected-key detection
* `autoload/bookmarker/directories.vim` — directory bookmark configuration, mappings, and Explore opening
* `autoload/bookmarker/finder.vim` — FZF and ripgrep integration
* `autoload/bookmarker/help.vim` — `:Bookmarker help` output
* `autoload/bookmarker/recent.vim` — recent-file collection, mappings, and opening
* `autoload/bookmarker/ui.vim` — dashboard layout
* `syntax/bookmarker.vim` — Bookmarker syntax highlighting

## Roadmap

Bookmarker is still under development. Possible next steps include:

* Richer directory browsing inside folder pages
* Nested bookmark navigation
* Reserved-key validation for file and directory bookmarks
* Better handling for duplicate keys across quick bookmarks, directory bookmarks, and recent files
* More customization options
* Automated test scripts for the headless Vim smoke checks

## License

A license has not been added yet.
