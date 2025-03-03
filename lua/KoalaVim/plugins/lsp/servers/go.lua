local M = {}

LSP_SERVERS['gopls'] = {}

table.insert(M, {
	'ray-x/go.nvim',
	dependencies = {
		'ray-x/guihua.lua',
		'neovim/nvim-lspconfig',
	},
	ft = { 'go', 'gomod' },
	build = ':lua require("go.install").update_all_sync()',
	config = function()
		require('go').setup({
			-- No keymaps
			lsp_keymaps = false,
			lsp_codelens = false,
			dap_debug_keymap = false,
			textobjects = false,
			lsp_on_attach = LSP_ON_ATTACH,
			lsp_diag_hdlr = false, -- Disable go.nvim diagnostics viewer
			lsp_inlay_hints = {
				enable = false, -- Using inlay-hints.nvim instead
			},

			lsp_cfg = {
				capabilities = LSP_CAPS,
				settings = {
					gopls = {
						analyses = {
							ST1003 = false, -- Disable variables format https://staticcheck.io/docs/checks#ST1003
							ST1005 = false, -- Disable error string format https://staticcheck.io/docs/checks#ST1005
							QF1008 = false, -- Disable Hints for Omit embedded fields from selector expression
						},
						usePlaceholders = false,
						hints = {
							-- For inlay hints
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
						symbolMatcher = 'FastFuzzy',
					},
					codelenses = {
						generate = false,
						gc_details = false,
						test = false,
						tidy = false,
						vendor = false,
						regenerate_cgo = false,
						upgrade_dependency = false,
					},
				},
			},
		})

		-- setup lspconfig
		require('lspconfig').gopls.setup(require('go.lsp').config())

		local map_buffer = require('KoalaVim.utils.map').map_buffer
		local add_new_line = 'i\\n<Esc>'

		vim.api.nvim_create_autocmd('FileType', {
			pattern = 'go',
			callback = function(events)
				-- TODO: improve GoIfErr
				-- map_buffer(events.buf, 'n', '<leader>e', '<cmd>GoIfErr<cr>', 'Golang: create if err')
				-- stylua: ignore
				map_buffer(events.buf, 'n', '<leader>e', 'oif err != nil {<CR>return<CR>}<Esc>', 'Golang: create if err')
				-- stylua: ignore
				map_buffer(events.buf, 'n', '<leader>fln', '<cmd>s/Println/Printf/<cr>$F"' .. add_new_line, 'Golang: change println to printf')
			end,
		})
	end,
})

return M
