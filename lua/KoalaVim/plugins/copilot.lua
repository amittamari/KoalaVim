local M = {}

table.insert(M, {
	'zbirenbaum/copilot.lua',
	command = 'Copilot',
	event = 'BufReadPre',
	opts = {
		panel = { enabled = false },
		suggestion = { enabled = false },
	},
	config = function(_, opts)
		require('copilot').setup(opts)
	end,
})

return M
