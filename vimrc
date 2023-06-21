syntax on
filetype plugin on
filetype indent on

color default

set bs=indent,eol,start
set relativenumber
set number
set incsearch
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set splitright
set splitbelow
set listchars=tab:>-,trail:~,nbsp:_
set wildmenu
set timeoutlen=0
set ttimeoutlen=0
set notimeout
set ttimeout
set hidden
set omnifunc=syntaxcomplete#Complete
set mouse=
set guicursor=a:hor20
set ignorecase
set smartcase
set smartindent
set autoindent
set smarttab
set statusline=\ %f\ %m\ %r%=%y\ 
set linebreak
set breakindent
set showbreak=+++\ 
set spellfile=$HOME/.vim/spell/en.utf-8.add
set undofile
set completeopt=menu,preview,noselect

autocmd! WinLeave,BufWinLeave * set norelativenumber
autocmd! WinEnter * if &number | set relativenumber | endif

let g:mapleader=" "
let g:maplocalleader='\'

nnoremap <c-l> :<c-u>redraw<cr>:<c-u>noh<cr>
nnoremap <leader>e :e 
nnoremap <leader>hh :h 
nnoremap <leader>w <c-w>
nnoremap <leader>bd :<c-u>bd<cr>
nnoremap <leader>bb :<c-u>ls<cr>:b
nnoremap <leader>fs :<c-u>write<cr>
noremap Y yg_
noremap Q <nop>
nnoremap <leader>rr :%s/\%(\C\)
nnoremap <leader>rl :s/\%(\C\)
vnoremap <leader>rr :s/\%(\C\%V\)


function OldFiles()
    let idx = 0
    for f in v:oldfiles[:9]
        echo printf("%2d: %s",  idx, f)
        let idx += 1
    endfor
    echo ">"
    try
        let idx = getchar() - 48
        if idx >= 0 && idx <=9
            exe "e " .. v:oldfiles[idx]
            redraw
            echo printf("%2d: %s",  idx, v:oldfiles[idx])
        else
            redraw
        endif
    endtry
endfunction

nnoremap <leader>fr :<c-u>call OldFiles()<cr>

function InsertPair(left, right)
    return getline(".")[col(".")] =~ '\i' ? a:left : a:left .. a:right .. "\<C-G>U\<left>"
endfunction

function SkipPair(right)
    return getline(".")[col(".") - 1] == a:right ? "\<C-G>U\<right>" : a:right
endfunction

function InsertQuote(quote)
    if getline(".")[col(".") - 1] == a:quote
        return "\<C-G>U\<right>"
    elseif getline(".")[col(".")] =~ '\i' || getline(".")[col(".")-2] =~ '\i'
        return a:quote
    else
        return a:quote .. a:quote .. "\<C-G>U\<left>"
    endif
endfunction

function Backspace()
    let left = getline(".")[col(".") - 2]
    let right = getline(".")[col(".")-1]
    for pair in [["(", ")"], ["[", "]"], ["{", "}"], ["'", "'"], ['"', '"']]
        if left == pair[0] && right == pair[1]
            return "\<backspace>\<delete>"
        endif
    endfor
    return "\<backspace>"
endfunction

inoremap <expr> ( InsertPair("(", ")")
inoremap <expr> ) SkipPair(")")
inoremap <expr> [ InsertPair("[", "]")
inoremap <expr> ] SkipPair("]")
inoremap <expr> { InsertPair("{", "}")
inoremap <expr> } SkipPair("}")
inoremap <expr> ' InsertQuote("'")
inoremap <expr> " InsertQuote('"')
inoremap <expr> <backspace> Backspace()

function StrInsert(str, chr, pos)
    return (a:pos ? a:str[0: a:pos-1] : "") . a:chr . a:str[a:pos:]
endfunction

function Surround(vt, ...)
    let pair = GetSurroundChar()
    if len(pair) > 0
        let [left, right] = pair
        let left_pos = getpos(a:0 ? "'<" : "'[")[1:2]
        let right_pos = getpos(a:0 ? "'>" : "']")[1:2]
        let left_line = getline(left_pos[0])
        if a:vt ==# 'line' || a:vt ==# 'V'
            call append(right_pos[0], right[len(right)-1])
            call append(left_pos[0]-1, left[0])
            normal gvjok=
        elseif a:vt ==# 'block' || a:vt ==# "\<c-v>"
            exe '''<,''>s/\%V.*\%V.\?/' . left . '\0' . right
        else
            call setline(left_pos[0], StrInsert(left_line, left, max([left_pos[1]-1, 0])))
            let right_line = getline(right_pos[0])
            call setline(right_pos[0], StrInsert(right_line, right,(right_pos[1]+len(left))))
        endif
    endif
endfunction

function DeleteSurround()
    let pair = GetSurroundChar()
    if len(pair) > 0
        let left = pair[0][0]
        exe 'normal vi' . left . 'vl"_xgvovh"_x'
    endif
endfunction

function ChangeSurround()
    let pair1 = GetSurroundChar()
    let new = nr2char(getchar())
    if len(pair1) > 0 && len(Char2Pair(new)) > 0
        let left = pair1[0][0]
        exe 'normal vi' . left . 'v"_lxgvovh"_xgvhohS' . new
    endif
endfunction

function Char2Pair(char)
    if a:char == '('
        return ['( ', ' )']
    elseif a:char == ')'
        return ['(', ')']
    elseif a:char == '['
        return ['[ ', ' ]']
    elseif a:char == ']'
        return ['[', ']']
    elseif a:char == '{'
        return ['{ ', ' }']
    elseif a:char == '}'
        return ['{', '}']
    elseif a:char == '<'
        return ['< ', ' >']
    elseif a:char == '>'
        return ['<', '>']
    elseif a:char == '"'
        return ['"', '"']
    elseif a:char == "'"
        return ["'", "'"]
    else
        return []
    endif
endfunction

function GetSurroundChar()
    try
        let char = nr2char(getchar())
        return Char2Pair(char)
    endtry
endfunction

nnoremap <silent> ys :set opfunc=Surround<cr>g@
nnoremap <silent> yss ^:set opfunc=Surround<cr>g@g_
vnoremap  S :<c-u>call Surround(visualmode(), 1)<cr>

nnoremap <silent> ds :call DeleteSurround()<cr>
nnoremap <silent> cs :call ChangeSurround()<cr>

function Comment(vt, ...) range
    let marks = a:0 ? ["'<", "'>",] : ["'[", "']"]
    let content_pat = substitute(&commentstring, '%s', '\\s\\?\\(\\s*\\)\\(.*\\)\\s*', '')
    let comment_strs = split(&commentstring, "%s")
    let line_pattern = '^\s*' . content_pat . '\s*$\|^\s*$'
    let lines = getline(marks[0], marks[1])
    let is_commented = len(filter(copy(lines), "v:val !~# line_pattern")) == 0
    if is_commented
        exe marks[0] . "," . marks[1] . 'substitute/^\(\s*\)' . content_pat . '/\1\2\3'
    else
        let comment_pos = min(map(copy(lines), "matchend(v:val, '\\s*')"))
        exe marks[0] . "," . marks[1] . 'v /^\s*$/ substitute/^\(\s\{' . comment_pos . '}\)\(\s*\)\(.*\)/\1' . comment_strs[0] . '\2 \3' . (len(comment_strs) > 1 ? ' ' . comment_strs[1] : '')
    endif
endfunction

nnoremap <silent> gc :set opfunc=Comment<cr>g@
nnoremap <silent> gcc :set opfunc=Comment<cr>g@$
vnoremap <silent> gc :call Comment(visualmode(), 1)<cr>

hi clear
syntax reset
hi! Normal ctermfg=7 ctermbg=None
for syn in ["preproc", "Constant", "Macro", "statement", "specialkey", "identifier", "Special", "Type"]
    exe "hi! link " . syn . " Normal"
endfor
hi! Statement ctermfg=7 cterm=bold
hi! Comment ctermfg=237 ctermbg=None
hi! String ctermfg=243 ctermbg=None
hi! Conceal ctermfg=234
hi! NonText ctermfg=234
hi! EndOfBuffer ctermfg=234
hi! LineNr ctermfg=237
hi! CursorLineNr ctermfg=237 cterm=bold
hi! Visual ctermfg=0 ctermbg=4
hi! IncSearch ctermfg=0 ctermbg=2 cterm=bold
hi! Search ctermfg=0 ctermbg=244 cterm=none
