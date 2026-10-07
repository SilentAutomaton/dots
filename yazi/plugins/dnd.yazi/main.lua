-- Drag files out of yazi into another window, or receive files dropped into the current folder.
-- Runs in an async context: dragon-drop is waited on without freezing the file manager.

local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, url in pairs(tab.selected) do
		paths[#paths + 1] = tostring(url)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

local current_dir = ya.sync(function()
	return tostring(cx.active.current.cwd)
end)

local function notify(content, level)
	ya.notify({ title = "Drag and drop", content = content, level = level or "info", timeout = 5 })
end

-- Starts dragon-drop and returns its output, or nil after reporting why it failed.
local function run(args, capture_stdout)
	local child, err = Command("dragon-drop")
		:arg(args)
		:stdin(Command.NULL)
		:stdout(capture_stdout and Command.PIPED or Command.NULL)
		:stderr(Command.PIPED)
		:spawn()
	if not child then
		notify("Cannot start dragon-drop: " .. tostring(err), "error")
		return nil
	end
	local output, wait_err = child:wait_with_output()
	if not output or not output.status.success then
		notify("dragon-drop failed: " .. (output and output.stderr or tostring(wait_err)), "error")
		return nil
	end
	return output
end

local function drag_out()
	local paths = selected_or_hovered()
	if #paths == 0 then
		return notify("Nothing to drag", "warn")
	end
	ya.emit("escape", { visual = true })
	notify("Drag from the small window in the middle of the screen", "info")
	-- -a: one handle for the whole selection; -x: exit after the drop
	local args = { "-x", "-a" }
	for _, path in ipairs(paths) do
		args[#args + 1] = path
	end
	run(args, false)
end

local function drop_in()
	local cwd = current_dir()
	notify("Drop files on the small window in the middle of the screen", "info")
	local output = run({ "--target", "--and-exit", "--print-path" }, true)
	if not output then
		return
	end
	local args = { "-an", "--" }
	for path in output.stdout:gmatch("[^\n]+") do
		args[#args + 1] = path
	end
	if #args == 2 then
		return notify("Nothing was dropped", "warn")
	end
	args[#args + 1] = cwd
	local status, err = Command("cp"):arg(args):status()
	if status and status.success then
		notify(("Copied %d item(s) here"):format(#args - 3))
	else
		notify("Copy failed: " .. tostring(err or status and status.code), "error")
	end
end

return {
	entry = function(_, job)
		if job.args[1] == "in" then
			drop_in()
		else
			drag_out()
		end
	end,
}
