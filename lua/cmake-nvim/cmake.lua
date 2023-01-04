local M = {}

local configurations = {}
configurations["ShowConfig"] = true
configurations["ShowBuild"] = true
configurations["ShowRun"] = true

local buffers = {}
buffers["Config"] = nil
buffers["Build"] = nil
buffers["Run"] = nil

local build_dir = nil
local source_dir = nil
local project = nil

local function add_to_buffer(buf, stdout, stderr, name, append)
	if #stdout ~= 0 then
		if append then
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Stdout of " .. name .. ":"})
		else
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Stdout of " .. name .. ":"})
		end
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, stdout)
		if #stderr == 0 then
			local to_highlight = #stdout
			local num_lines = vim.api.nvim_buf_line_count(buf)
			for i = num_lines - to_highlight, num_lines, 1 do
				vim.api.nvim_buf_add_highlight(buf, -1, "DevIconCsv", i, 0, -1)
			end
		end
	end
	if #stderr ~= 0 then
		if append then
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Stderr of " .. name .. ":"})
		else
			if #stdout == 0 then
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Stderr of " .. name .. ":"})
			else
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Stderr of " .. name .. ":"})
			end
		end
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, stderr)
		local to_highlight = #stderr
		local num_lines = vim.api.nvim_buf_line_count(buf)
		for i = num_lines - to_highlight, num_lines, 1 do
			vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", i, 0, -1)
		end
	end
end

local function isValidData(data)
	for _, value in ipairs(data) do
		if value ~= "" then
			return true
		end
	end
	return false
end

local function cmake_command(buf, command, append, name, on_exit_function)
	local stdout, stderr = {}, {}
	local error = false
	local ch = vim.fn.jobstart(command, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				local is_valid = isValidData(data)
				if not is_valid then
					return
				end
				for _, value in ipairs(data) do
					table.insert(stdout, value)
				end
				if not append then
					add_to_buffer(buf, stdout, stderr, name, append)
				end
			end
		end,
		on_stderr = function(_, data)
			if data then
				local is_valid = isValidData(data)
				if not is_valid then
					return
				end
				for _, value in ipairs(data) do
					table.insert(stderr, value)
				end
				error = true
				if not append then
					add_to_buffer(buf, stdout, stderr, name, append)
				end
			end
		end,
		on_exit = function(_)
			if error == false then
				print(name .. " successful!")
				add_to_buffer(buf, stdout, stderr, name, append)
			else
				print(name .. " terminated!")
				add_to_buffer(buf, stdout, stderr, name, append)
			end
			if on_exit_function then
				on_exit_function()
			end
		end
	})
	return ch
end

local function config_settings(buf)
	vim.api.nvim_buf_set_keymap(buf, 'n', "<leader>q", ":bw!<CR>", {silent = true})
end

function M.enter_cmake()
	local current_dir = vim.fn.getcwd() .. '/'
	local source_directory = vim.fn.input({
		prompt = "Enter your source directory: ",
		default = current_dir,
		completion = "dir"
	})
	vim.api.nvim_set_current_dir(source_directory)
	local build_directory = vim.fn.input({
		prompt = "Enter your build directory: ",
		default = source_directory,
		completion = "dir"
	})
	vim.api.nvim_set_current_dir(build_directory)
	local project_file = vim.fn.input({
		prompt = "Enter your executable that will be run: ",
		default = build_directory,
		completion = "file"
	})
	vim.api.nvim_set_current_dir(current_dir)

	source_dir = source_directory
	build_dir = build_directory
	project = project_file
end

function M.cmake_build(on_exit_function)
	local buf = nil
	local split = false
	if buffers["Build"] then
		buf = buffers["Build"]
		if not vim.api.nvim_buf_is_valid(buf) then
			buf = vim.api.nvim_create_buf(true, false)
			buffers["Build"] = buf
			split = true
		end
	else
		buf = vim.api.nvim_create_buf(true, false)
		buffers["Build"] = buf
		split = true
	end
	config_settings(buf)
	local command = {"cmake", "--build", build_dir}
	cmake_command(buf, command, false, "Build", on_exit_function)
	if split and configurations["ShowBuild"] then
		vim.cmd(":vert belowright sb " .. tostring(buf))
	end
end

function M.cmake_config(on_exit_function)
	local buf = nil
	local split = false
	if buffers["Config"] then
		buf = buffers["Config"]
		if not vim.api.nvim_buf_is_valid(buf) then
			buf = vim.api.nvim_create_buf(true, false)
			buffers["Config"] = buf
			split = true
		end
	else
		buf = vim.api.nvim_create_buf(true, false)
		buffers["Config"] = buf
		split = true
	end
	config_settings(buf)
	local command = {"cmake", "-B", build_dir, "-S", source_dir}
	cmake_command(buf, command, true, "Configuration", on_exit_function)
	if split and configurations["ShowConfig"] then
		vim.cmd(":vert belowright sb " .. tostring(buf))
	end
end

function M.cmake_run()
	if buffers["Run"] then
		vim.cmd(":bw! " .. buffers["Run"])
	end
	local buf = vim.api.nvim_create_buf(true, false)
	buffers["Run"] = buf
	config_settings(buf)
	vim.cmd(":vert belowright sb " .. tostring(buf))
	vim.cmd(":terminal ")
	vim.api.nvim_paste(project .. '\n', true, 3)
	vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 0, 0, -1)
end

function M.user_commands()
	vim.api.nvim_create_user_command("EnterProject", M.enter_cmake, {})
	vim.api.nvim_create_user_command("ConfigBuildProject", function() M.cmake_config(M.cmake_build) end, {})
	vim.api.nvim_create_user_command("BuildProject", function() M.cmake_build(nil) end, {})
	vim.api.nvim_create_user_command("ConfigProject", function() M.cmake_config(nil) end, {})
	vim.api.nvim_create_user_command("RunProject", function() M.cmake_run() end, {})
	vim.api.nvim_create_user_command("BuildRunProject", function() M.cmake_build(M.cmake_run) end, {})
	vim.api.nvim_create_user_command("CmakeWorks", function() print("YEP!") end, {})
end

return M

