-- ==========================================================================
-- Neovim Modern Configuration (Migrated from vimrc)
-- ==========================================================================

-- 0. 性能优化 & Leader 键 (必须最先设置)
vim.loader.enable() -- 开启 Lua 字节码缓存，加快启动
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==========================================================================
-- 1. General Settings (基础设置)
-- ==========================================================================
local opt = vim.opt

-- 历史与内存
opt.history = 2000
-- opt.maxmempattern = 4096 -- Neovim 默认通常足够，可省略

-- 文件处理
opt.autoread = true -- 文件外部修改自动重载
opt.shortmess:append("atI") -- 启动时不显示乌干达儿童提示
opt.backup = false -- 禁止备份
opt.swapfile = false -- 禁止交换文件
opt.wildignore = { "*.swp", "*.bak", "*.pyc", "*.class", ".svn", "__pycache__", "*.o", "*~" }
opt.wildmenu = true -- 命令行补全增强
opt.wildmode = "list:longest"

-- 界面显示
opt.termguicolors = true -- 开启真彩色
opt.scrolloff = 7 -- 光标保留行数
opt.number = true -- 显示行号
opt.relativenumber = false -- 默认不开启相对行号
opt.wrap = false -- 禁止折行
opt.showmode = true -- 左下角显示模式
opt.showcmd = true -- 显示输入命令
opt.ruler = true
opt.title = true -- 修改终端标题
opt.cursorline = false -- 默认关闭高亮行 (你的vimrc中注释了)
opt.cursorcolumn = false -- 默认关闭高亮列

-- 搜索设置
opt.hlsearch = true -- 高亮搜索结果
opt.incsearch = true -- 增量搜索
opt.ignorecase = true -- 忽略大小写
opt.smartcase = true -- 智能大小写

-- 缩进设置 (默认配置，后续会有 Autocmd 覆盖)
opt.smartindent = true
opt.autoindent = true
opt.cindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true -- 将 Tab 转为空格
opt.shiftround = true -- 缩进取整

-- 行为微调
opt.mouse = "" -- 禁用鼠标
opt.selection = "inclusive"
opt.backspace = { "eol", "start", "indent" }
opt.whichwrap:append("<,>,h,l")
opt.hidden = true -- 允许隐藏 buffer (不保存切换)
opt.ttyfast = true
opt.lazyredraw = true -- 宏执行时不重绘，加速
opt.re = 1 -- 正则引擎兼容模式 (旧配置保留)
opt.updatetime = 300 -- 加快响应时间 (LSP 需要)

-- 铃声与格式
opt.errorbells = false
opt.visualbell = false
opt.formatoptions:append("B") -- 合并中文不加空格

-- ==========================================================================
-- 2. Custom Functions (自定义函数移植)
-- ==========================================================================

-- 2.1 设置 Tab 宽度的辅助函数
local function set_tab_size(size)
	vim.opt_local.tabstop = size
	vim.opt_local.shiftwidth = size
	vim.opt_local.softtabstop = size
end

-- 2.2 F7: 切换 Tab/Space
local function toggle_tab_expand()
	if vim.opt_local.expandtab:get() then
		vim.opt_local.expandtab = false
		vim.cmd("retab!")
		print("ExpandTab: OFF (Tabs)")
	else
		vim.opt_local.expandtab = true
		vim.cmd("retab")
		print("ExpandTab: ON (Spaces)")
	end
end

-- 2.3 F2: 切换行号显示模式
local function toggle_number()
	local nu = vim.opt_local.number:get()
	local rnu = vim.opt_local.relativenumber:get()

	if nu and rnu then
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	elseif nu then
		vim.opt_local.relativenumber = true
	else
		vim.opt_local.number = true
		vim.opt_local.relativenumber = false
	end
end

-- 2.4 ZoomToggle (最大化/恢复窗口)
local zoomed = false
local function zoom_toggle()
	if zoomed then
		vim.cmd(vim.t.zoom_winrestcmd or "=")
		zoomed = false
	else
		vim.t.zoom_winrestcmd = vim.fn.winrestcmd()
		vim.cmd("resize")
		vim.cmd("vertical resize")
		zoomed = true
	end
end

-- 2.5 清除高亮
local function clear_highlight()
	vim.cmd("nohlsearch")
	-- 兼容其他插件
	if vim.fn.exists(":QuickhlManualReset") == 1 then
		vim.cmd("QuickhlManualReset")
	end
	if vim.fn.exists(":BookmarkClear") == 1 then
		vim.fn.BookmarkClear()
	end
end

-- ==========================================================================
-- 3. Keymappings (快捷键设置)
-- ==========================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 移动增强
map({ "n", "v" }, "k", "gk", opts)
map({ "n", "v" }, "gk", "k", opts)
map({ "n", "v" }, "j", "gj", opts)
map({ "n", "v" }, "gj", "j", opts)
map({ "n", "v" }, "H", "^", opts)
map({ "n", "v" }, "L", "$", opts)

-- 命令行增强
map("c", "<C-j>", "<Down>", { noremap = true })
map("c", "<C-k>", "<Up>", { noremap = true })
map("c", "<C-a>", "<Home>", { noremap = true })
map("c", "<C-e>", "<End>", { noremap = true })

-- 功能键 F1-F6
map("n", "<F1>", "<Esc>", opts)
map("n", "<F2>", toggle_number, opts)
map("n", "<F3>", ":set list! list?<CR>", opts)
map("n", "<F4>", ":set wrap! wrap?<CR>", opts)
map("n", "<F6>", function()
	if vim.g.syntax_on then
		vim.cmd("syntax off")
	else
		vim.cmd("syntax on")
	end
end, opts)
map("n", "<F7>", toggle_tab_expand, opts)

-- 窗口操作
map("n", "<leader>z", zoom_toggle, opts)
map("n", "<leader>bd", ":bd<CR>", opts)

-- 缩进调整后保持选中
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- 系统剪贴板
map("v", "<leader>y", '"+y', opts)

-- 搜索高亮清除
map("n", "<leader>/", clear_highlight, opts)

-- 快速保存退出误触修正
vim.api.nvim_create_user_command("Q", "q<bang>", { bang = true })
vim.api.nvim_create_user_command("Qa", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("QA", "qa<bang>", { bang = true })
vim.api.nvim_create_user_command("W", "w<bang>", { bang = true })
vim.api.nvim_create_user_command("Wa", "wa<bang>", { bang = true })
vim.api.nvim_create_user_command("WA", "wa<bang>", { bang = true })

-- Python 自动输入 # (注释不回跳)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.py",
	callback = function()
		map("i", "#", "X<c-h>#", { buffer = true, noremap = true })
	end,
})

-- Map S to split the line at the cursor position
vim.keymap.set("n", "S", "i<CR><Esc>k$:s/\\s\\+$//e<CR>$", { desc = "Split line and strip trailing space" })

-- ==========================================================================
-- 4. Autocommands (自动命令)
-- ==========================================================================
local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

-- 4.1 自动定位到最后编辑位置
au("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- 4.2 退出插入模式自动关闭 paste
au("InsertLeave", {
	command = "set nopaste",
})

-- 4.3 文件类型缩进设置 (批量处理)
local indent_group = ag("IndentSettings", { clear = true })

local indent_rules = {
	{ pattern = { "python", "c", "h", "cpp", "hpp", "cc", "rust", "go" }, size = 4 },
	{
		pattern = {
			"ruby",
			"vim",
			"html",
			"javascript",
			"typescript",
			"typescriptreact",
			"javascriptreact",
			"vue",
			"java",
			"yaml",
			"toml",
			"lua",
			"json",
			"typespec",
			"sql",
		},
		size = 2,
	},
}

for _, rule in ipairs(indent_rules) do
	au("FileType", {
		group = indent_group,
		pattern = rule.pattern,
		callback = function()
			set_tab_size(rule.size)
		end,
	})
end

-- 4.4 特殊文件类型修正
au({ "BufRead", "BufNewFile" }, {
	group = indent_group,
	pattern = { "*.md", "*.mkd", "*.markdown" },
	command = "set filetype=markdown",
})
au({ "BufRead", "BufNewFile" }, {
	group = indent_group,
	pattern = "*.vue",
	callback = function()
		vim.opt_local.filetype = "vue"
		set_tab_size(2)
	end,
})

-- ==========================================================================
-- 5. Plugins Loading (插件加载)
-- ==========================================================================

-- 加载你的 Lua 插件配置 (lua/plugins.lua)
require("plugins")

-- ==========================================================================
-- 6. Theme (主题设置)
-- ==========================================================================

-- 防止 tmux 颜色异常
if vim.env.TERM and vim.env.TERM:match("256color") then
	-- vim.opt.t_ut = ""
	vim.cmd("set t_ut=")
end

-- 设置主题 (放在最后，确保插件加载完成后执行)
vim.opt.background = "light"
-- 尝试加载主题，如果失败不报错
pcall(vim.cmd.colorscheme, "catppuccin-latte")
