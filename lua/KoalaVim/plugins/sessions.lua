local M = {}

-- TODO: restore fugitive
-- TODO: handle zombie files

KOALA_AUTOSAVE_SESSION = true

-- Disables auto session saving if a session already exists
function KoalaDisableAutoSession()
	local cwd_session = require('KoalaVim.utils.session').cwd_session()

	if require('possession.session').exists(cwd_session) then
		KOALA_AUTOSAVE_SESSION = false
		vim.notify('AutoSession Saving Disabled! (:SaveSession to override)')
	end
end

-- Disables auto session saving at all
function KoalaDisableSession()
	KOALA_AUTOSAVE_SESSION = false
end

-- Enables auto session saving
function KoalaEnableSession()
	if KOALA_AUTOSAVE_SESSION == false then
		KOALA_AUTOSAVE_SESSION = true
		vim.notify('AutoSession Saving Enabled!')
	end
end

-- Delete current session and disable suto saving
function KoalaDeleteCurrentSession()
	local cwd_session = require('KoalaVim.utils.session').cwd_session()

	require('possession.session').delete(cwd_session, {})
	vim.notify('Session Deleted! AutoSession Saving Disabled!')
	KOALA_AUTOSAVE_SESSION = false
end

table.insert(M, {
	'jedrzejboczar/possession.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
	},
	opts = {
		silent = true,
		-- Auto-session with possession.nvim
		autosave = {
			current = true,
			tmp = function()
				return KOALA_AUTOSAVE_SESSION
			end,
			tmp_name = function()
				return require('KoalaVim.utils.session').cwd_session()
			end,
		},
		commands = {
			save = 'SaveNamedSession',
			load = 'LoadNamedSession',
			rename = 'RenameSession',
			close = nil,
			delete = 'DeleteNamedSession',
			show = nil,
			list = nil,
			migrate = nil,
		},
		hooks = {
			before_save = function(_)
				local data = {}
				data.build = require('KoalaVim.utils.build').get_session_data()

				return data
			end,
			after_load = function(_, user_data)
				require('KoalaVim.utils.build').restore_session_data(user_data.build or {})
			end,
		},
	},
	config = function(_, opts)
		local auto_load_session = vim.env.KOALA_RESTART

		-- Disable session saving if files passed in argline
		-- Load session only if dirs passed at the cmdline
		for i, arg in ipairs(vim.v.argv) do
			-- Skip first arg (nvim bin) and flags
			local skip = i == 1 or arg:sub(1, 1) == '-'
			if not skip then
				if vim.fn.isdirectory(arg) ~= 1 then
					KoalaDisableSession()
					auto_load_session = false
					break
				else
					auto_load_session = true
					vim.api.nvim_set_current_dir(arg)
				end
			end
		end

		require('possession').setup(opts)
		require('telescope').load_extension('possession')

		vim.api.nvim_create_user_command('SessionList', function()
			require('KoalaVim.utils.session').list_sessions()
		end, {})

		vim.api.nvim_create_user_command('SaveSession', function()
			KoalaEnableSession()
			local cwd_session = require('KoalaVim.utils.session').cwd_session()
			require('possession.session').save(cwd_session, { no_confirm = true })
		end, {})

		vim.api.nvim_create_user_command('LoadSession', function()
			require('KoalaVim.utils.session').load_cwd_session()

			KoalaEnableSession()
		end, {})

		vim.api.nvim_create_user_command('DeleteSession', function()
			KoalaDeleteCurrentSession()
		end, {})

		if auto_load_session then
			vim.api.nvim_create_autocmd('VimEnter', {
				callback = function()
					vim.schedule(function()
						require('KoalaVim.utils.session').load_cwd_session()
					end)
				end,
			})
		end
	end,
})

return M
