"==========================================
" Initial Plugin 加载插件
"==========================================

" 修改leader键
let mapleader = ' '
let g:mapleader = ' '

" install bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
elseif filereadable(expand("~/.config/nvim/vimrc.bundles")) " neovim
  source ~/.config/nvim/vimrc.bundles
endif

"==========================================
" General Settings 基础设置
"==========================================

" 设置最大模式匹配使用内存 (KB)
set maxmempattern=4096

" history存储容量
set history=2000

" 检测文件类型
filetype on
" 针对不同的文件类型采用不同的缩进格式
filetype indent on
" 允许插件
filetype plugin on
" 启动自动补全
filetype plugin indent on

" 文件修改之后自动载入
set autoread
" 启动的时候不显示那个援助乌干达儿童的提示
set shortmess=atI

" 备份,到另一个位置. 防止误删, 目前是取消备份
"set backup
"set backupext=.bak
"set backupdir=/tmp/vimbk/

" 取消备份。 视情况自己改
set nobackup
" 关闭交换文件
set noswapfile

set wildignore=*.swp,*.bak,*.pyc,*.class,.svn,__pycache__

" very lag when move cursor
" 突出显示当前列
" set cursorcolumn
" 突出显示当前行
" set cursorline
let g:long_line_length = 88
" execute "set colorcolumn=".(g:long_line_length + 1)

" 设置 退出vim后，内容显示在终端屏幕, 可以用于查看和复制, 不需要可以去掉
" 好处：误删什么的，如果以前屏幕打开，可以找回
set t_ti= t_te=


" 禁用鼠标
set mouse=
" 启用鼠标
" set mouse=a
" Hide the mouse cursor while typing
set mousehide


" 修复ctrl+m 多光标操作选择的bug，但是改变了ctrl+v进行字符选中时将包含光标下的字符
set selection=inclusive
set selectmode=mouse,key

" change the terminal's title
set title
" 去掉输入错误的提示声音
set novisualbell
set noerrorbells
set t_vb=
set tm=500

" Remember info about open buffers on close
set viminfo^=%

" For regular expressions turn magic on
" set magic

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

"==========================================
" Display Settings 展示/排版等界面格式设置
"==========================================

" 显示当前的行号列号
set ruler
" 在状态栏显示正在输入的命令
set showcmd
" 左下角显示当前vim模式
set showmode

" 在上下移动光标时，光标的上方或下方至少会保留显示的行数
set scrolloff=7
" keep cursor always in the middle of screen
" set scrolloff=9999

" set winwidth=79

" 显示行号
set number
" 取消换行
set nowrap

" 括号配对情况, 跳转并高亮一下匹配的括号
set showmatch
" How many tenths of a second to blink when matching brackets
set matchtime=2

" 设置文内智能搜索提示
" 高亮search命中的文本
set hlsearch
" 打开增量搜索模式,随着键入即时搜索
set incsearch
" 搜索时忽略大小写
set ignorecase
" 有一个或以上大写字母时仍大小写敏感
set smartcase

" 缩进配置
" Smart indent
"set smartindent   " Smart indent
"set autoindent    " 打开自动缩进
set cindent
" never add copyindent, case error   " copy the previous indentation on autoindenting
set autoindent

" tab相关变更
" 设置Tab键的宽度        [等同的空格个数]
set tabstop=4
" 每一次缩进对应的空格数
set shiftwidth=4
" 按退格键时可以一次删掉 4 个空格
set softtabstop=4
" insert tabs on the start of a line according to shiftwidth, not tabstop 按退格键时可以一次删掉 4 个空格
set smarttab
" 将Tab自动转化成空格[需要输入真正的Tab键时，使用 Ctrl+V + Tab]
set expandtab
" 缩进时，取整 use multiple of shiftwidth when indenting with '<' and '>'
set shiftround

function! TAB(size)
  " 设置Tab键的宽度        [等同的空格个数]
  execute "set tabstop=".a:size
  " 每一次缩进size个空格数
  execute "set shiftwidth=".a:size
  " 按退格键时可以一次删掉 size 个空格
  execute "set softtabstop=".a:size
endfunc

" 使用F7切换是否使用空格代替tab(或tab代替空格)
function! TabToggle()
  if(&expandtab == 1)
    set noexpandtab
    retab!
  else
    set expandtab
    retab
  endif
endfunc
nnoremap <F7> :call TabToggle()<CR>

" A buffer becomes hidden when it is abandoned
set hidden
set wildmode=list:longest
set ttyfast

" 00x增减数字时使用十进制
" set nrformats=

"==========================================
" FileEncode Settings 文件编码,格式
"==========================================
" 设置新文件的编码为 UTF-8
set encoding=utf-8
" 自动判断编码时，依次尝试以下编码：
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set helplang=cn
"set langmenu=zh_CN.UTF-8
"set enc=2byte-gb18030
" 下面这句只影响普通模式 (非图形界面) 下的 Vim
set termencoding=utf-8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" 合并两行中文时，不在中间加空格
set formatoptions+=B


"==========================================
" others 其它设置
"==========================================

" 自动补全配置
" 让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
set completeopt=longest,menu

" 增强模式中的命令行自动完成操作
set wildmenu
" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.class

" 离开插入模式后自动关闭预览窗口
autocmd! InsertLeave * if pumvisible() == 0|pclose|endif
" 回车即选中当前项
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"

augroup quickfix_group
  autocmd!
  " In the quickfix window, <CR> is used to jump to the error under the
  " cursor, so undefine the mapping there.
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
  " quickfix window  s/v to open in split window,  ,gd/,jd => quickfix window => open it
  autocmd BufReadPost quickfix nnoremap <buffer> v <C-w><Enter><C-w>L
  autocmd BufReadPost quickfix nnoremap <buffer> s <C-w><Enter><C-w>K
augroup END

" 上下左右键的行为 会显示其他信息
inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <PageDown> pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<PageDown>"
inoremap <expr> <PageUp>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<PageUp>"

" 打开自动定位到最后编辑的位置, 需要确认 .viminfo 当前用户可写
if has("autocmd")
  au! BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

"==========================================
" HotKey Settings  自定义快捷键设置
"==========================================

" 主要按键重定义

"Treat long lines as break lines (useful when moving around in them)
"se swap之后，同物理行上线直接跳
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j

" replace Ex mode keymap from 'Q' tp 'QEx'
nnoremap QEx Q
nnoremap Q <Esc>

" F1 - F6 设置

" F1 废弃这个键,防止调出系统帮助
" I can type :help on my own, thanks.  Protect your fat fingers from the evils of <F1>
noremap <F1> <Esc>"

" F2 行号开关，用于鼠标复制代码用
" 为方便复制，用<F2>开启/关闭行号显示:
function! HideNumber()
  if(&relativenumber == &number)
    set relativenumber! number!
  elseif(&number)
    set number!
  else
    set relativenumber!
  endif
  set number?
endfunc
nnoremap <F2> :call HideNumber()<CR>
" F3 显示可打印字符开关
nnoremap <F3> :set list! list?<CR>
" F4 换行开关
nnoremap <F4> :set wrap! wrap?<CR>

" F6 语法开关，关闭语法可以加快大文件的展示
nnoremap <F6> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>

set pastetoggle=<F5>            "    when in insert mode, press <F5> to go to
                                "    paste mode, where you can paste mass data
                                "    that won't be autoindented

" disbale paste mode when leaving insert mode
au! InsertLeave * set nopaste

" 分屏窗口移动, Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l


" http://stackoverflow.com/questions/13194428/is-better-way-to-zoom-windows-in-vim-than-zoomwin
" Zoom / Restore window.
function! s:ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction
command! ZoomToggle call s:ZoomToggle()
nnoremap <silent> <Leader>z :ZoomToggle<CR>


" Go to home and end using capitalized directions
noremap H ^
noremap L $


" 命令行模式增强，ctrl - a到行首， -e 到行尾
cnoremap <C-j> <t_kd>
cnoremap <C-k> <t_ku>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>

" 去掉搜索高亮
function! ClearHighlight()
  if exists(":QuickhlManualReset")
    QuickhlManualReset
  endif
  if exists(":BookmarkClear")
    call BookmarkClear()
  endif
endfunction
noremap <silent><leader>/ :nohls<CR>:call ClearHighlight()<CR>

" for # indent, python文件中输入新行时#号注释不切回行首
autocmd! BufNewFile,BufRead *.py inoremap # X<c-h>#

" 关闭buffer和window
nnoremap <Leader>bd :bd<CR>


" => 选中及操作改键

" 调整缩进后自动选中，方便再次操作
vnoremap < <gv
vnoremap > >gv

" 复制选中区到系统剪切板中
vnoremap <leader>y "+y

" remap write command for quit typo
command-bang Q :q<bang>
command-bang Qa :qa<bang>
command-bang QA :qa<bang>

" remap write command for write typo
command-bang W :w<bang>
command-bang Wa :wa<bang>
command-bang WA :wa<bang>

" remap write-and-quit command for typo
cnoreabbrev <expr> X (getcmdtype() is# ':' && getcmdline() is# 'X') ? 'x' : 'X'
"cnoremap <expr> X (getcmdtype() is# ':' && empty(getcmdline())) ? 'x' : 'X'

" split line 快速分割一行
nnoremap S :keeppatterns substitute@\s*\%#\s*@\r@e <bar> normal! ==<CR>

" erase trailing space
function EraseTrailingSpace()
  let b:save_view = winsaveview()
  keeppatterns %substitute@\s*$@@eg
  call winrestview(b:save_view)
endfunction
nnoremap <leader>t :call EraseTrailingSpace()<CR>

" augroup erase_trailing_space
"   au!
"   au BufWritePre * silent! :call EraseTrailingSpace()
" augroup END


"==========================================
" FileType Settings  文件类型设置
"==========================================

augroup indent_settings_group
  autocmd!
  autocmd FileType * :call TAB(4)                        " default Tabsize
  autocmd FileType py,python :call TAB(4)                " python Tabsize
  autocmd FileType ruby :call TAB(2)                     " ruby Tabsize
  autocmd FileType vim :call TAB(2)                      " vimrc Tabsize
  autocmd FileType html :call TAB(2)                     " html Tabsize
  autocmd FileType javascript,typescript :call TAB(2)    " typescript javascript Tabsize
  autocmd FileType js,ts,cs,coffee,jsx :call TAB(2)      " typescript javascript coffeescript Tabsize
  autocmd FileType c,h :call TAB(4)                      " c Tabsize
  autocmd FileType cpp,hpp,cc,cxx :call TAB(4)           " cpp Tabsize
  autocmd FileType java :call TAB(2)                     " java Tabsize
  autocmd FileType rust :call TAB(4)                     " rust Tabsize
  autocmd FileType go :call TAB(4)                       " golang Tabsize

  autocmd FileType python,ruby,javascript,html,css,xml,go set expandtab ai
  autocmd BufRead,BufNewFile *.md,*.mkd,*.markdown set filetype=markdown.mkd
  autocmd BufRead,BufNewFile *.part set filetype=html
  autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript expandtab ai
  autocmd BufRead,BufNewFile *.vue :call TAB(2)
augroup END

" 设置可以高亮的关键字
if has("autocmd")
  " Highlight TODO, FIXME, NOTE, TIPS, etc.
  if v:version > 701
    augroup highlight_keyword_group
      autocmd!
      autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|DONE\|XXX\|BUG\|OPTIMIZE\|HACK\|TIPS\|DEPRECATED\|REFACTOR\)')
      autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\|NOTICE\)')
      autocmd Syntax * call matchadd('Error', '\W\zs\(!!!\)')
      autocmd Syntax * call matchadd('ErrorMsg', '\W\zs\(IMPORTANT\)')
      autocmd Syntax * call matchadd('Question', '\W\zs\(QUESTION\|HOWTO\)')
    augroup END
  endif
endif


"==========================================
" Theme Settings  主题设置
"==========================================

" theme主题
set background=dark
set t_Co=256
" colorscheme onedark
" colorscheme molokai
" colorscheme Tomorrow-Night
" colorscheme Tomorrow-Night-Eighties
" colorscheme Tomorrow-Night-Bright
" colorscheme monokai
" colorscheme hybrid
" colorscheme jellybeans
" colorscheme kolor
" colorscheme lucius
" colorscheme iceberg
colorscheme tender
" colorscheme gruvbox
" colorscheme Apprentice
" colorscheme space-vim-dark

" 设置标记一列的背景颜色和数字一行颜色一致
hi! link SignColumn   LineNr
hi! link ShowMarksHLl DiffAdd
hi! link ShowMarksHLu DiffChange

" 解决terminal使用tender配色时, 选择模式背景色看不见得问题
hi Visual ctermfg=NONE ctermbg=16 cterm=NONE

" for error highlight，防止错误整行标红导致看不清
highlight clear SpellBad
highlight SpellBad term=standout ctermfg=1 term=underline cterm=underline
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline


" 防止tmux下vim的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;lu;%lum"
  let &t_8b = "\<Esc>[48;2%lu;%lu;%lum"
  " set termguicolors
endif

" Speed UP!
set re=1
set lazyredraw

" Debug
augroup long_lines
  au!
  "au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>'.g:long_line_length.'v.\+', -1)
augroup END
