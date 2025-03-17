source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload


# relative line numbers
# hook global BufCreate .* %[
#     add-highlighter buffer/ number-lines -hlcursor
#     add-highlighter buffer/ wrap
# ]
#

# Set the colour scheme
colorscheme gruvbox-dark

hook global BufSetOption filetype=javascript %{
        set-option buffer formatcmd "prettier --stdin-filepath=%val{buffile}"
}

hook global BufSetOption filetype=markdown %{
        set-option buffer formatcmd 'pandoc -f commonmark -t commonmark'
}

# Softwrap long lines
add-highlighter global/ wrap -word -indent

# Display line numbers
add-highlighter global/ number-lines -hlcursor

add-highlighter global/ show-matching

# Add a TODO highlighter
add-highlighter global/ regex (TODO:)[^\n]* 0:cyan 1:black,yellow

add-highlighter global/ regex <!--(?:.|\n|\r)*?--> 0:cyan 1:cyan


# Disable clippy
set-option global ui_options ncurses_assistant=off

# Set jumpclient
set-option global jumpclient jump
# Set toolsclient
set-option global toolsclient tools

# Set docsclient
set-option global docsclient docs

# Create client with name
define-command -docstring "Open a new client with the given name" \
new-client -params 1 %{
    new rename-client %arg{1}
}

# softwrap
hook global WinSetOption filetype=mail %{
    set window autowrap_column 80
    autowrap-enable
}

map global normal = '|fmt -w $kak_opt_autowrap_column<ret>'

# indentation
set-option global tabstop     4
set-option global indentwidth 4

# tabs to spaces
hook global InsertChar \t %{
    exec -draft h@
}

hook global NormalKey <ret> w

# case insensitive search
map global prompt <a-i> "<home>(?i)<end>"

# clipboard interaction
map global user p -docstring 'Paste from clipboard' ': paste<ret>'
map global user y -docstring 'yank to clipboard' '<a-|>pbcopy<ret>'
map global user c -docstring 'cut to clipboard' '|pbcopy<ret>'

# Always keep one line and three columns displayed around the cursor
set-option global scrolloff 1,3

# Highlight trailing whitespace
add-highlighter global/ regex \h+$ 0:Error

# Shortcut to quickly save and exit the editor
define-command -docstring "Save and quit" x "write-all; quit"

# Display the status bar on top
set-option global ui_options ncurses_status_on_top=true

hook global WinSetOption filetype=markdown %{
    set window formatcmd 'prettier --parser markdown'
}
#PLUGINS
# Filetree
plug "andreyorst/kaktree" config %{
    hook global WinSetOption filetype=kaktree %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
        remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
    kaktree-enable
}

# Markdown Preview
plug 'delapouite/kakoune-livedown' %{ }

plug "basbebe/pandoc.kak" %{
   hook global WinSetOption filetype=(asciidoc|fountain|html|latex|markdown) %{
       require-module pandoc
       set-option global pandoc_options '-d default'
   }
}

plug "lePerdu/kakboard" %{
    hook global WinCreate .* %{ kakboard-enable }
}

# toggle todos
plug "kkga/todo.kak" config %{
    hook global WinSetOption filetype=markdown %{
        require-module todo
        add-highlighter buffer/ regex '\[ \]' 0:blue
        add-highlighter buffer/ regex '\[x\]' 0:comment
        map buffer normal <ret> ': todo-toggle<ret>' -docstring "toggle checkbox"
    }
}

plug "krornus/kakoune-git" config %{ }

plug "ftonneau/wordcount.kak" config %{ }

# ui
plug "kkga/ui.kak" config %{ }


plug "kak-lsp/kak-lsp" do %{
   cargo install --locked --force --path .
   # optional: if you want to use specific language servers
   mkdir -p ~/.config/kak-lsp
   cp -n kak-lsp.toml ~/.config/kak-lsp/
}
