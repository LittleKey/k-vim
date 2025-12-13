-- 引导 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.termguicolors = true
vim.opt.rtp:prepend(lazypath)

-- 插件配置表
require("lazy").setup({

  -- ==========================================
  -- 核心功能与依赖
  -- ==========================================
  "nvim-lua/plenary.nvim", -- 许多 Lua 插件的依赖库

  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- 【关键修复】确保安装 json 解析器
        -- 建议加上你常用的所有语言，防止打开其他文件也报错
        ensure_installed = {
            "bash", "c", "cmake", "cpp", "css", "csv",
            "dart", "diff", "dockerfile", "fish",
            "git_config", "git_rebase", "gitcommit", "gitignore", "go", "gomod", "gosum", "gotmpl", "gowork", "gpg", "graphql",
            "html", "ini", "javascript", "jinja", "json", "kotlin",
            "latex", "lua", "make", "markdown", "markdown_inline",
            "nginx", "ninja", "nix", "proto", "python", "query",
            "requirements", "ruby", "rust", "sql", "ssh_config",
            "tmux", "toml", "typescript", "typespec",
            "vim", "vimdoc", "xml", "yaml", "zig"
        },

        -- 如果遇到未安装的语言，自动尝试安装
        auto_install = true,

        -- 启用高亮模块
        highlight = {
          enable = true,
          -- 如果你想保留 vim 原生的正则高亮作为后备，可以设为 true
          -- 但通常建议 false 以获得更精确的 treesitter 高亮
          additional_vim_regex_highlighting = false,
        },

        -- 启用 vim-matchup 的集成
        matchup = {
            enable = true,              -- 强制启用 matchup
            disable_virtual_text = true, -- 可选
        },
      })
    end
  },

  -- 异步 Lint 组件 (ALE)
  {
    "dense-analysis/ale",
    build = "python3 spell/cspell.json && mv cspell.json ./spell/",
    init = function()
      -- 你的 ALE 配置 (保留 Vimscript 以确保逻辑完全一致)
      vim.cmd([[
        let g:ale_linters_explicit = 1
        let g:ale_warn_about_trailing_whitespace = 1
        let g:ale_linters = {
              \  'go': ['gopls', 'golangci-lint'],
              \  'proto': ['buf'],
              \  'python': ['ruff', 'pyright', 'flake8'],
              \  'c': ['clang'],
              \  'cpp': ['clang'],
              \  'json': ['jsonlint'],
              \  'sh': ['shellcheck'],
              \  'rust': ['analyzer', 'cargo', 'rls'],
              \  'mardown': ['cspell'],
              \  'jinja': ['cspell'],
              \  'javascript': ['jshint', 'eslint', 'standard'],
              \}

        " 自动添加 cspell
        for k in keys(g:ale_linters)
          let g:ale_linters[k] += ['cspell']
        endfor

        func! s:define_cspell_linter(ft) abort
          if !has_key(g:ale_linters, a:ft)
            let g:ale_linters[a:ft] = ['cspell']
            call ale#handlers#cspell#DefineLinter(a:ft)
          endif
        endfunc

        augroup ale_linter_cspell_extend_group
          autocmd!
          autocmd FileType bt,yaml,toml,json,text,jinja,markdown call s:define_cspell_linter(&filetype)
        augroup END

        let g:ale_cspell_options = '--show-suggestions --config ~/.vim/spell/cspell.json --cache --cache-strategy metadata --no-gitignore --no-color'
        let g:ale_python_vulture_options = '--min-confidence 80 --ignore-names "_ign*" --exclude "*py2.py,*py2_grpc.py"'
        let g:ale_go_gopls_init_options = { 'build.buildFlags': ["-tags=meteor_robot,mage,wireinject"] }
        let g:ale_go_golangci_lint_options = '-c="~/.vim/config/golangci.yaml"'
        let g:ale_go_golangci_lint_package = 1
        let g:ale_markdown_vale_options = '--config ~/.vim/config/.vale.ini'
        let g:ale_jshint_config_loc = '/Users/littlekey/.vim/config/.jshintrc'

        let g:ale_fixers_explicit = 1
        let g:ale_fixers = {
          \   'python': ['ruff', 'ruff_format'],
          \   'go': ['gofmt'],
          \   'rust': ['rustfmt'],
          \   'javascript': ['prettier'],
          \}
        let g:ale_fix_on_save = 1
        let g:ale_sign_column_always = 1
        let g:ale_sign_error = "\uf05e"
        let g:ale_sign_warning = "\uf071"
        let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
        let g:ale_echo_msg_error_str = 'E'
        let g:ale_echo_msg_warning_str = 'W'
        let g:ale_echo_msg_format = '[%linter%]% code:% %s [%severity%] '
        let g:ale_rust_rls_toolchain = 'stable'
        let g:ale_lint_on_text_changed = 'normal'
        let g:ale_lint_delay = 200
        let g:ale_lint_on_enter = 1
        let g:ale_lint_on_insert_leave = 1
        let g:ale_lint_on_save = 1
        let g:ale_set_highlights = 1
        highlight link ALEErrorSign  error
        highlight link ALEWarningSign Exception

        augroup ale_hightlight_group
          autocmd!
          autocmd ColorScheme * highlight ALEWarning cterm=bold,underline ctermbg=none ctermfg=none
          autocmd ColorScheme * highlight ALEErrorSign cterm=bold ctermbg=none  ctermfg=red
          autocmd ColorScheme * highlight ALEWarningSign cterm=bold ctermbg=none  ctermfg=darkmagenta
        augroup END
      ]])
    end
  },

  -- Icons & UI
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "folke/trouble.nvim", ft = { 'python', 'go', 'c', 'cpp', 'rust' } },

  -- ==========================================
  -- 自动补全 (Jedi / Codeium)
  -- ==========================================

  -- Python Jedi
  {
    "davidhalter/jedi-vim",
    ft = "python",
    init = function()
      -- Jedi 配置放在 init 中，因为有些变量需要在加载前设置
      vim.g['jedi#usages_command'] = 0
      vim.g['jedi#completions_enabled'] = 0
      -- Python Host 逻辑
      if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
        vim.g.python3_host_prog = vim.env.VIRTUAL_ENV .. '/bin/python'
      elseif vim.fn.executable('python3') == 1 then
        vim.g.python3_host_prog = vim.fn.exepath('python3')
      else
        vim.g.python3_host_prog = '/usr/bin/python3'
      end
    end,
    init = function()
      vim.cmd([[
        augroup redefined_goto_directive_for_python
          autocmd!
          autocmd FileType python nnoremap gd :call g:jedi#goto()<CR>
        augroup END
      ]])
    end
  },

  -- Codeium
  {
    "Exafunction/codeium.vim",
    branch = "main",
    init = function()
      vim.g.codeium_disable_bindings = 1
      vim.keymap.set('i', '<C-E>', 'codeium#Accept()', { expr = true, script = true, nowait = true, silent = true })
      vim.keymap.set('i', '<C-R>', '<Cmd>call codeium#Clear()<CR>')
      vim.keymap.set('i', '<C-N>', '<Cmd>call codeium#CycleCompletions(1)<CR>')
      vim.keymap.set('i', '<C-P>', '<Cmd>call codeium#CycleCompletions(-1)<CR>')
      vim.keymap.set('i', '<C-C>', '<Cmd>call codeium#Complete()<CR>')
    end
  },

  -- ==========================================
  -- 编辑体验增强
  -- ==========================================
  "markonm/traces.vim",

  -- 匹配增强
  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_transmute_enabled = 1
      vim.g.matchup_matchparen_enabled = 0
      vim.g.matchup_motion_enabled = 0
      vim.g.matchup_text_obj_enabled = 0
    end
  },
  "kshenoy/vim-signature",

  {
      "wellle/targets.vim",
      init = function()
          vim.g.targets_nl = 'nN'
          vim.g.targets_seekRanges = 'cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB'
      end
  },
  "machakann/vim-sandwich",

  -- ==========================================
  -- 搜索与导航 (FZF, CtrlSF)
  -- ==========================================
  {
    "junegunn/fzf",
    build = "./install --all",
    init = function()
       vim.g.fzf_action = { ['ctrl-t'] = 'tab split', ['ctrl-x'] = 'split', ['ctrl-v'] = 'vsplit' }
       vim.g.fzf_layout = { down = '~30%' }
       vim.g.fzf_buffers_jump = 1
       vim.g.fzf_history_dir = '~/.local/share/fzf-history'
       vim.api.nvim_set_keymap('n', '<c-f>', ':FZF<CR>', { noremap = true })
       -- FZF 颜色配置 (建议保留 Vimscript)
       vim.cmd([[
            let g:fzf_colors = { 'fg': ['fg', 'Normal'], 'bg': ['bg', 'Normal'], 'hl': ['fg', 'Comment'], 'fg+': ['fg', 'CursorLine', 'CursorColumn', 'Normal'], 'bg+': ['bg', 'CursorLine', 'CursorColumn'], 'hl+': ['fg', 'Statement'], 'info': ['fg', 'PreProc'], 'border': ['fg', 'Ignore'], 'prompt': ['fg', 'Conditional'], 'pointer': ['fg', 'Exception'], 'marker': ['fg', 'Keyword'], 'spinner': ['fg', 'Label'], 'header': ['fg', 'Comment'] }
            nnoremap <c-f> :FZF<CR>
       ]])
    end
  },
  {
    "dyng/ctrlsf.vim",
    init = function()
      vim.keymap.set('n', '\\', '<Plug>CtrlSFCwordPath<CR>')
      vim.g.ctrlsf_auto_close = 0
      vim.g.ctrlsf_confirm_save = 0
      vim.g.ctrlsf_default_vim_mode = 'compact'
      vim.g.ctrlsf_ignore_dir = {'node_modules', '__mocks__', 'target', 'dist', 'build', '__pycache__', '.git', 'assets'}
      vim.g.ctrlsf_extra_backend_args = {
          rg = '-g "!*.jsbundle" -g "!*.bundle.js" -g "!*.bundle" -g "!*.pyc" -g "!*.bt.json"',
          ag = '--ignore "*.jsbundle" --ignore "*.bundle.js" --ignore "*.bundle" --ignore "*.pyc" --ignore "*.bt.json"',
      }
      vim.g.ctrlsf_mapping = { open = "<Space>", openb = "O", tab = "<C-t>", tabb = "<C-T>", prevw = "p", quit = "q", next = "<C-J>", prev = "<C-K>", pquit = "q" }
    end
  },

  -- ==========================================
  -- Git 与 版本控制
  -- ==========================================
  {
    "mhinz/vim-signify",
    init = function()
      vim.g.signify_sign_add = '+'
      vim.g.signify_sign_delete = '-'
      vim.g.signify_sign_delete_first_line = '‾'
      vim.g.signify_sign_change = '~'
      vim.g.signify_sign_changedelete = vim.g.signify_sign_change
      -- 颜色高亮
      vim.cmd([[
        augroup signify_colors
          autocmd!
          autocmd ColorScheme * hi SignifySignAdd cterm=bold ctermbg=none  ctermfg=119
          autocmd ColorScheme * hi SignifySignDelete cterm=bold ctermbg=none  ctermfg=167
          autocmd ColorScheme * hi SignifySignChange cterm=bold ctermbg=none  ctermfg=227
        augroup END
      ]])
    end
  },

  -- ==========================================
  -- 界面与主题
  -- ==========================================
  "mhinz/vim-startify",
  "flazz/vim-colorschemes",
  "chriskempson/base16-vim",
  "jonathanfilip/vim-lucius",
  "jacoborus/tender.vim",
  "liuchengxu/space-vim-dark",
  { "littlekey/rose-pine.vim", name = "rose-pine" },
  { "nordtheme/vim", name = "nord" },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- 确保最先加载
    config = function()
      require("catppuccin").setup({
        flavour = "latte",
        background = {
            light = "latte",
            dark = "mocha",
        },
        integrations = {
            cmp = true,
            gitsigns = true,
            nvimtree = true,
            treesitter = true,
            notify = false,
            mini = false,
            -- 这里让 catppuccin 自动适配 lualine
            -- 虽然 lualine 内部也会找 theme, 但这里开启集成更稳
        }
      })
      -- 加载配色
      vim.cmd.colorscheme "catppuccin-latte"
    end
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "catppuccin/nvim",
    },
    config = function()
      require("lualine").setup({
        options = {
          -- 现在这里可以正确识别了
          theme = "catppuccin",
          -- 如果你不喜欢它的默认分隔符，可以换回类似 airline 的三角形
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          globalstatus = true, -- 建议开启：只在底部显示一个全局状态栏，而不是每个窗口一个
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          -- 在这里添加你想要的信息，比如文件编码、文件类型等
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end,
  },

  -- ==========================================
  -- 侧边栏与导航
  -- ==========================================

  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>n", ":NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
    },
    config = function()
        require("nvim-tree").setup({
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = true,
            },
            -- 自动同步 tmux 窗口需要额外配置，或者使用 nvim-tree 的 api
        })
    end,
  },

  -- ==========================================
  -- 语言支持 (Syntax & Utils)
  -- ==========================================
  { "tpope/vim-git", ft = "git" },
  { "uarun/vim-protobuf", ft = "proto" },
  { "cespare/vim-toml", ft = "toml" },
  {
      "rust-lang/rust.vim",
      ft = "rust",
      init = function()
          vim.g.rust_clip_command = 'pbcopy'
          vim.cmd([[
            augroup goto_directive_for_rust
            autocmd!
            autocmd FileType rust nnoremap gd :ALEGoToDefinition()<CR>
            augroup END
          ]])
      end
  },

  -- 特殊路径/本地插件 (注意: 如果这些是本地文件，需要改用 dir="...")
  -- 假设这些是 git 仓库，只是你以前用 rtp 指定了子目录。Lazy 默认拉取整个仓库。
  -- { "yogoswarm/bitproto", ft = "bitproto" },
  -- { "yogoswarm/behaviortree", ft = "bt" }, -- 对应原来的 'yogoswarm/behaviortree/dsl'，如果是子目录可能需要特殊处理

  -- TMUX
  {
    "christoomey/vim-tmux-navigator",
    lazy = false, -- 关键：禁用懒加载，确保启动时立即生效
  },

  -- Go Lang
  {
    "fatih/vim-go",
    ft = "go",
    branch = "master",
    init = function()
      vim.g.go_highlight_extra_types = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_methods = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_structs = 1
      vim.g.go_highlight_types = 1
      vim.g.go_highlight_build_constraints = 1
      vim.g.go_highlight_generate_tags = 1
      vim.g.go_highlight_format_strings = 1
      vim.g.go_highlight_variable_declarations = 1
      vim.g.go_highlight_variable_assignments = 1
      vim.g.go_fmt_fail_silently = 1
      vim.g.go_fmt_command = "gopls"
      vim.g.go_def_mode = "gopls"
      vim.g.go_info_mode = "gopls"
      vim.g.go_implements_mode = "gopls"
      vim.g.go_rename_mode = "gopls"
      vim.g.go_imports_mode = "gopls"
      vim.g.go_referrers_mode = "gopls"
      vim.g.go_gopls_enabled = 1
      vim.g.go_mod_fmt_autosave = 1
      vim.g.go_build_tags = 'mage,meteor_robot'

      vim.g.go_gopls_fuzzy_matching = 0
      vim.g.go_gopls_matcher = nil
      vim.g.go_fmt_autosave = 0
      vim.g.go_imports_autosave = 0
      vim.g.go_doc_keywordprg_enabled = 0 -- disable GoDoc
      vim.g.go_template_autocreate = 0 -- disable GoTemplate
      vim.g.go_code_completion_enabled = 0 -- disable, use coc
      vim.g.go_gopls_deep_completion = 0
      vim.g.go_highlight_string_spellcheck = 0
      vim.g.go_highlight_array_whitespace_error = 0
      vim.g.go_highlight_chan_whitespace_error = 0
      vim.g.go_highlight_space_tab_error = 0
      vim.g.go_highlight_trailing_whitespace_error = 0
      vim.g.go_highlight_function_parameters = 0
      vim.g.go_highlight_function_calls = 0
      vim.g.go_highlight_fields = 0
    end
  },
})
