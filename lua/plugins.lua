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
vim.opt.rtp:prepend(lazypath)

-- 插件配置表
require("lazy").setup({

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
					"latex",
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
			-- 1. 全局配置
			vim.opt.updatetime = 300

			-- 2. 准备 Capabilities
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- 3. 定义服务器配置表 (Data Driven)
			-- 将所有特定服务器的 settings 放在这里，而不是散落在 handlers 里
			local servers = {
				-- Go
				gopls = {
					settings = {
						gopls = {
							analyses = { unusedparams = true },
							staticcheck = true,
						},
					},
				},

				-- Python
				pyright = {
					settings = {
						python = {
							analysis = {
								-- typeCheckingMode = "off",
							},
						},
					},
				},

				-- 其他没有任何特殊配置的服务器，留空即可
				rust_analyzer = {},
				ts_ls = {}, -- 注意: tsserver 已更名为 ts_ls
				bashls = {},
				jsonls = {},
				lua_ls = {},
				tsp_server = {},
			}

			-- 4. Mason-LSPConfig 自动配置
			require("mason-lspconfig").setup({
				-- 自动从上面的 servers 表中获取键名作为安装列表
				ensure_installed = vim.tbl_keys(servers),
				automatic_installation = true,

				-- 5. 使用 Handlers 统一处理启动逻辑
				handlers = {
					function(server_name)
						-- 获取 servers 表中的自定义配置，如果为空则默认为空表
						local server_config = servers[server_name] or {}

						-- 强制注入 capabilities
						server_config.capabilities =
							vim.tbl_deep_extend("force", capabilities, server_config.capabilities or {})

						-- 启动 LSP
						-- 注意: 在 Mason 场景下，这里调用 setup 是必须的，
						-- 它负责将 Mason 下载的二进制路径注入到 cmd 中。
						require("lspconfig")[server_name].setup(server_config)
					end,
				},
			})
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

	-- 4. Trouble: 诊断列表 (保留，用于查看所有错误)
	-- 5. Trouble: 诊断列表 (修复 v3 版本命令)
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Trouble", -- 懒加载命令变了
		keys = {
			-- 使用新的 v3 命令格式
			{ "<C-x>", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
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
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
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
					globalstatus = true, -- 建议开启：只在底部显示一个全局状态栏，而不是每个窗口一个
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
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
