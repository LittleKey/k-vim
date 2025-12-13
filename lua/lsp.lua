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
