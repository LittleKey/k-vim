-- 引导 lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 插件配置表
require("lazy").setup({
	checker = { enabled = true },

	-- ==========================================
	-- 核心功能与依赖
	-- ==========================================
	"nvim-lua/plenary.nvim", -- 许多 Lua 插件的依赖库

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- 【关键修复】确保安装 json 解析器
				-- 建议加上你常用的所有语言，防止打开其他文件也报错
				ensure_installed = {
					"bash",
					"c",
					"cmake",
					"cpp",
					"css",
					"csv",
					"dart",
					"diff",
					"dockerfile",
					"fish",
					"git_config",
					"git_rebase",
					"gitcommit",
					"gitignore",
					"go",
					"gomod",
					"gosum",
					"gotmpl",
					"gowork",
					"gpg",
					"graphql",
					"html",
					"ini",
					"javascript",
					"jinja",
					"json",
					"kotlin",
					"lua",
					"make",
					"markdown",
					"markdown_inline",
					"nginx",
					"ninja",
					"nix",
					"proto",
					"python",
					"query",
					"requirements",
					"ruby",
					"rust",
					"sql",
					"ssh_config",
					"tmux",
					"toml",
					"typescript",
					"typespec",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
					"zig",
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
					enable = true, -- 强制启用 matchup
					disable_virtual_text = true, -- 可选
				},

				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- 自动跳转到下一个匹配项
						keymaps = {
							-- 定义你的文本对象快捷键
							["af"] = "@function.outer", -- 选中整个函数
							["if"] = "@function.inner", -- 选中函数体
							["ac"] = "@class.outer", -- 选中整个类
							["ic"] = "@class.inner", -- 选中类内部
							["aa"] = "@parameter.outer", -- 选中参数
							["ia"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- 加入跳转表
						goto_next_start = {
							["]f"] = "@function.outer", -- 跳转到下一个函数开始
							["]c"] = "@class.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer", -- 跳转到上一个函数开始
							["[c"] = "@class.outer",
						},
					},
				},
			})
		end,
	},

	-- ==========================================
	-- Lua 开发增强 (自动解决 vim 全局变量问题)
	-- ==========================================
	{
		"folke/lazydev.nvim",
		ft = "lua", -- 仅在 lua 文件加载
		opts = {
			library = {
				-- 让 lua_ls 能够识别 lazy.nvim 的配置语法 (plugins.lua)
				{ path = "lazy.nvim", words = { "LazyVim" } },
			},
		},
	},

	-- ==========================================
	-- LSP 完整生态 (无 cmp 版)
	-- ==========================================

	-- 1. Mason: 管理器
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason Installer" } },
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- 2. LSP Config: 核心配置
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			vim.opt.updatetime = 300

			-- 1. 初始化 Mason
			-- 这步至关重要：它会将 mason/bin 加入到 Neovim 的 PATH 中
			-- 所以我们不需要手动拼接路径，直接用命令名即可
			require("mason").setup()

			-- 2. 准备 Capabilities
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- 如果有 cmp: capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

			-- 3. 定义服务器配置 (只写你需要修改的部分)
			local servers = {
				-- === Gopls ===
				gopls = {
					-- 不需要写 cmd，默认就是 {"gopls"}，Mason 会让它生效
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
					root_markers = { "go.work", "go.mod", ".git" },
					settings = {
						gopls = {
							-- 【配置生效】
							buildFlags = { "-tags=meteor_robot" },
							analyses = {
								unusedparams = true,
								unreachable = true,
							},
							staticcheck = true,
							usePlaceholders = true,
							completeUnimported = true,
						},
					},
				},

				-- === Python ===
				pyright = {
					settings = {
						python = { analysis = { typeCheckingMode = "off" } },
					},
				},

				-- === 其他服务器 (空表代表使用默认配置) ===
				rust_analyzer = {},
				ts_ls = {},
				bashls = {},
				jsonls = {},
				lua_ls = {},
				tsp_server = {},
			}

			-- 4. 确保安装 (Mason-LSPConfig 仅用于安装，不负责 setup)
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
				automatic_installation = true,
			})

			-- 5. 显式注册配置 (不依赖 Mason 回调，绝对稳健)
			for name, config in pairs(servers) do
				-- 合并 capabilities
				config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})

				-- 【核心】直接注册到 Nvim 0.11
				-- vim.lsp.config 会自动查找 nvim-lspconfig 提供的默认配置(包含默认cmd)
				-- 并将你的 config 合并进去
				vim.lsp.config(name, config)

				-- 启用服务
				vim.lsp.enable(name)
			end
		end,
	},

	-- 3. None-ls: Linting & Formatting
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-null-ls.nvim",
			"davidmh/cspell.nvim",
		},
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"cspell",
					"ruff",
					"gofumpt",
					"goimports",
					"prettier",
					"shfmt",
					"clang_format",
					"rust_analyzer",
					"black",
					"stylua",
				},
				automatic_installation = true,
			})

			local null_ls = require("null-ls")
			local formatting = null_ls.builtins.formatting
			local diagnostics = null_ls.builtins.diagnostics
			local code_actions = null_ls.builtins.code_actions
			local cspell = require("cspell")

			-- CSpell 配置路径查找
			local cspell_config = {
				find_json = function(cwd)
					local project_conf = vim.fn.glob(cwd .. "/cspell.json")
					if project_conf ~= "" then
						return project_conf
					end
					return vim.fn.expand("~/.vim/spell/cspell.json")
				end,
			}

			null_ls.setup({
				debug = false,
				sources = {
					-- CSpell
					cspell.diagnostics.with({
						config = cspell_config,
						diagnostics_postprocess = function(diagnostic)
							diagnostic.severity = vim.diagnostic.severity.WARN
						end,
					}),
					cspell.code_actions.with({ config = cspell_config }),

					-- Formatting
					formatting.gofumpt,
					formatting.goimports,
					formatting.black,
					formatting.clang_format,
					formatting.prettier.with({ filetypes = { "html", "json", "yaml", "markdown" } }),
					formatting.shfmt,
					formatting.stylua,
				},
			})
		end,
	},

	-- 4. Trouble: 诊断列表
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble", -- 懒加载命令变了
		keys = {
			-- 使用新的 v3 命令格式
			{
				"<leader>x",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		},
		opts = {}, -- v3 版本必须有这个 opts 空表或者配置表
		config = function()
			require("trouble").setup({})

			-- 依然保留你的图标配置
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end
		end,
	},

	-- ==========================================
	-- 自动补全 (Codeium)
	-- ==========================================

	-- Codeium
	{
		"Exafunction/codeium.vim",
		branch = "main",
		init = function()
			vim.g.codeium_disable_bindings = 1
			vim.keymap.set(
				"i",
				"<C-E>",
				"codeium#Accept()",
				{ expr = true, script = true, nowait = true, silent = true }
			)
			vim.keymap.set("i", "<C-R>", "<Cmd>call codeium#Clear()<CR>")
			vim.keymap.set("i", "<C-N>", "<Cmd>call codeium#CycleCompletions(1)<CR>")
			vim.keymap.set("i", "<C-P>", "<Cmd>call codeium#CycleCompletions(-1)<CR>")
			vim.keymap.set("i", "<C-C>", "<Cmd>call codeium#Complete()<CR>")
		end,
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
		end,
	},
	"kshenoy/vim-signature",

	{
		"wellle/targets.vim",
		init = function()
			vim.g.targets_nl = "nN"
			vim.g.targets_seekRanges = "cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB"
		end,
	},
	"machakann/vim-sandwich",

	-- 快速编辑
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},

	-- 复制到系统剪贴板(OSC52)
	{
		"ojroques/nvim-osc52",
		config = function()
			require("osc52").setup({
				max_length = 0, -- 0 表示不限制长度 (Tmux >= 3.2 支持大块数据)
				silent = true, -- true 表示复制时不显示 "Copied..." 消息，保持清爽
				trim = false, -- 是否去除首尾空格
				tmux_passthrough = true, -- 重点：使用 Tmux 的直通模式 (依赖你刚才设置的 allow-passthrough)
			})
		end,
	},

	-- ==========================================
	-- 搜索与导航 (FZF, CtrlSF)
	-- ==========================================

	-- ==========================================
	-- 模糊查找与全局替换 (Telescope + Spectre)
	-- ==========================================
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			-- 安装 fzf-native 扩展，提供极速的 C 语言排序算法
			-- 注意：这需要你的电脑上有 make 和 gcc/clang
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			-- 全局替换插件 (替代 CtrlSF 的替换功能)
			"nvim-pack/nvim-spectre",
		},
		cmd = "Telescope",
		-- 定义常用的快捷键
		keys = {
			-- === 文件搜索 (替代 FZF) ===
			{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<C-f>", "<cmd>Telescope find_files<cr>", desc = "Find Files (Alias)" }, -- 兼容你原来的习惯
			{ "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },

			-- === 文本搜索 (替代 CtrlSF 的搜索功能) ===
			-- 实时 grep (输入什么搜什么)
			{ "<leader>f", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			-- 搜索光标下的单词 (相当于 CtrlSF 的默认行为)
			{ "\\", "<cmd>Telescope grep_string<cr>", desc = "Grep Word Under Cursor" },

			-- === 辅助功能 ===
			{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
			{ "<leader>s", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" }, -- 恢复上一次搜索窗口

			-- === 全局替换 (替代 CtrlSF 的替换功能) ===
			-- 开启替换窗口
			{ "<C-g>", '<cmd>lua require("spectre").toggle()<CR>', desc = "Global Replace (Spectre)" },
			-- 搜索当前光标下的单词并准备替换
			{
				"<leader>\\",
				'<cmd>lua require("spectre").open_visual({select_word=true})<CR>',
				desc = "Replace Word Under Cursor",
			},
		},
		config = function()
			require("spectre").setup({
				default = {
					replace = {
						-- Switch from 'sed' to 'sd' so regex syntax matches 'rg'
						-- Make sure to install 'sd' via brew/pacman/cargo first! (brew install sd)
						cmd = "sd",
					},
				},
			})
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					-- 默认布局配置
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},

					-- 忽略文件模式 (grep和find_files都会生效)
					file_ignore_patterns = {
						"node_modules",
						"%.git/",
						"%.DS_Store",
						"target/",
						"build/",
						"dist/",
						"__pycache__",
					},

					-- 路径显示方式: "tail" (文件名), "absolute", "smart", "truncate"
					path_display = { "truncate" },

					-- 默认按键映射 (在弹窗中)
					mappings = {
						i = {
							-- 插入模式下
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-c>"] = actions.close,
							["<Esc>"] = actions.close,
							-- 预览滚动
							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,
						},
						n = {
							-- 普通模式下
							["q"] = actions.close,
							["<Esc>"] = actions.close,
						},
					},
				},
				pickers = {
					-- 针对特定选取器的配置
					find_files = {
						-- find_files 默认包含隐藏文件, 但排除 .git
						hidden = true,
					},
				},
				extensions = {
					-- fzf 扩展配置
					fzf = {
						fuzzy = true, -- 开启模糊匹配
						override_generic_sorter = true, -- 覆盖默认排序器
						override_file_sorter = true, -- 覆盖文件排序器
						case_mode = "smart_case", -- 智能大小写 (ignore_case, respect_case, smart_case)
					},
				},
			})

			-- 加载扩展
			telescope.load_extension("fzf")
		end,
	},

	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
		},
		config = function()
			require("aerial").setup({
				-- 优先使用 LSP，其次 Treesitter，最后 Markdown
				backends = { "lsp", "treesitter", "markdown", "man" },
				on_attach = function(bufnr)
					-- 跳转快捷键
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,
			})
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		opts = {},
		-- 定义快捷键
		keys = {
			{
				"r",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"R",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
		},
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
		},
	},

	-- ==========================================
	-- Git 与 版本控制
	-- ==========================================
	{
		"lewis6991/gitsigns.nvim",
		-- 【修正】使用标准的读取文件事件，而不是自定义事件
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				-- 开启行内 blame (可选，显示这行代码是谁写的)
				current_line_blame = true,
				current_line_blame_opts = { delay = 500 },

				-- 确保符号列一直显示，防止屏幕跳动
				signcolumn = true,

				-- 自定义图标 (可选，让界面更像你截图右边的风格)
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
			})

			-- 快捷键
			vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "Git Blame Line" })
		end,
	},

	-- ==========================================
	-- 界面与主题
	-- ==========================================
	-- "mhinz/vim-startify",
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({
				-- config
			})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
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
				},
				custom_highlights = function(colors)
					return {
						["@module.go"] = { bg = "NONE" },
						["@module.python"] = { bg = "NONE" },
						["@module.ssh_config"] = { bg = "NONE" },
					}
				end,
			})
			-- 加载配色
			vim.cmd.colorscheme("catppuccin-latte")
		end,
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
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = false, -- 建议开启：只在底部显示一个全局状态栏，而不是每个窗口一个
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filename", file_status = true, newfile_status = true, path = 1 },
					},
					-- 在这里添加你想要的信息，比如文件编码、文件类型等
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│", -- 使用细竖线
				tab_char = "│",
			},
			scope = { enabled = true }, -- 高亮当前作用域
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
		},
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

	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPre",
		config = function()
			require("treesitter-context").setup({
				enable = true,
				max_lines = 7, -- 最多显示 7 行上下文，防止占据太多屏幕
				trim_scope = "outer",
			})
		end,
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

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300 -- 按下前缀键 300ms 后显示提示
		end,
		opts = {
			-- 你的个性化配置
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (Which-Key)",
			},
		},
	},
})

-- ==========================================
-- 全局 LSP 配置 (快捷键 + 自动格式化)
-- ==========================================

-- 1. 创建一个自动命令组
local user_lsp_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

-- 2. 注册 LspAttach 事件 (当任何 LSP 启动时触发)
vim.api.nvim_create_autocmd("LspAttach", {
	group = user_lsp_group,
	callback = function(ev)
		-- A. 快捷键配置
		local opts = { buffer = ev.buf, noremap = true, silent = true }

		-- === 常用跳转 ===
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", opts)

		-- gl: 强制显示错误详情
		vim.keymap.set("n", "gl", function()
			vim.diagnostic.open_float({ border = "rounded", scope = "line", source = true })
		end, opts)

		-- B. 自动悬停显示错误 (300ms 延迟)
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = ev.buf,
			callback = function()
				local float_opts = {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = "rounded",
					source = "always",
					prefix = " ",
					scope = "cursor",
				}
				vim.diagnostic.open_float(nil, float_opts)
			end,
		})

		-- 保存时自动格式化
		-- 获取当前 LSP 客户端
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- 如果该 LSP 支持格式化 (gopls, null-ls 等)
		if client.supports_method("textDocument/formatting") then
			-- 创建保存前的自动命令
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = ev.buf,
				group = user_lsp_group, -- 使用同一个组，避免重复
				callback = function()
					-- 执行同步格式化 (2000ms 超时)
					vim.lsp.buf.format({
						async = false,
						timeout_ms = 2000,
						-- 可选: 如果你只想用 null-ls (cspell/ruff/gofumpt) 格式化，不想用 gopls 原生格式化
						filter = function(c)
							return c.name == "null-ls"
						end,
					})
				end,
			})
		end
	end,
})
