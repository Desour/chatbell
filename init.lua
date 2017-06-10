--[[
       .__            __ ___.          .__  .__
  ____ |  |__ _____ _/  |\_ |__   ____ |  | |  |
_/ ___\|  |  \\__  \\   __\ __ \_/ __ \|  | |  |
\  \___|   Y  \/ __ \|  | | \_\ \  ___/|  |_|  |__
 \___  >___|  (____  /__| |___  /\___  >____/____/
     \/     \/     \/         \/     \/
--]]

local load_time_start = os.clock()
local modname = minetest.get_current_modname()


local on = true
local own_name = ""
local blocked = {}

local function get_msg(msg)
	if msg:sub(1, 1) ~= "<" then
		return msg
	end
	local f = msg:find(">")
	if not f then
		return msg
	end
	local name = msg:sub(2, f-1)
	if blocked[name] then
		return false
	end
	msg = msg:sub(f+1) -- The space before is wanted.
	return msg
end

local function is_special_char(c)
	local abc = "abcdefghijklmnopqrstuvwxyzüöäß"
	return (tonumber(c) or abc:find(c)) == nil
end

minetest.register_on_connect(function()
	own_name = minetest.localplayer:get_name()
	blocked[own_name] = true
end)

minetest.register_on_receiving_chat_message(function(omsg)
	local msg = get_msg(omsg)
	if not msg then
		return
	end
	local lmsg, loname = msg:lower(), own_name:lower()
	for i = 1, #lmsg do
		local f
		f, i = lmsg:find(loname, i)
		if not f then
			return
		end
		if is_special_char(lmsg:sub(f-1, f-1)) and
				(is_special_char(lmsg:sub(i+1, i+1)) or i >= #lmsg) then
			break
		end
	end
	minetest.sound_play("chatbell_bell", {gain = 0.5})
	minetest.display_chat_message(minetest.colorize("#52DA2D", omsg))
	return true
end)

minetest.register_chatcommand("chatbell", {
	params = "get | toggle | block <player>",
	description = "Control the chatbell:n"..
	"  toggle: Toggle the bell on/off. (Default)\n"..
	"  block <player>: Block/unblock a specific player.",
	func = function(param)
		local cmd = param
		do
			local f = param:find(" ")
			if f then
				cmd = param:sub(1, f-1)
				param = param:sub(f+1)
			else
				param = ""
			end
		end
		cmd = cmd:lower()

		if cmd == "toggle" or cmd == "" then
			on = not on
			return true, "Chatbell "..((on and "enabled") or "disabled").."."

		elseif cmd == "block" then
			blocked[param] = not blocked[param]
			return true, param.." "..((blocked[param] and "") or "not ").."blocked."

		elseif cmd == "get" then
			if not on then
				return true, "Chatbell is disabled."
			end
			return true, "Blocked players: "..dump(blocked)

		else
			return false, "Invalid arguments."
		end
	end,
})


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "["..modname.."] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
