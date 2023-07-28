
-- Shrek 2 (GBA) info utility
-- Author: RetroEdit
-- Version: 0.1.1 (2023-07-28)
-- Tested on BizHawk version 2.9.1

package.loaded.retro_tas = nil
local retro_tas = require "retro_tas"
local PIX_FONT_X, PIX_FONT_Y = retro_tas.PIX_FONT_X, retro_tas.PIX_FONT_Y
local SCREEN_PIX_WIDTH, SCREEN_PIX_HEIGHT = retro_tas.SCREEN_PIX_WIDTH, retro_tas.SCREEN_PIX_HEIGHT
local pix, pix_row = retro_tas.pix, retro_tas.pix_row
local ptr_chain = retro_tas.ptr_chain

local in_game_root = 0x02002E94
local prev_active = false
local NUM_CHARS, num_coins = 0, 0
local chars = {{prev_x=0, prev_y=0}, {prev_x=0, prev_y=0}, {prev_x=0, prev_y=0}}
local x, y, diff_x, diff_y = 0, 0, 0, 0
local frames, prev_frames = 0, 0

local misc_entity = {prev_x=0, prev_y=0}

event.onexit(function() gui.clearGraphics() end)

while true do
	gui.clearGraphics()
	frames = emu.framecount()

	local screen_id = memory.read_u32_le(0x02007CE8+0x20, "System Bus")
	pix(SCREEN_PIX_WIDTH - 2, SCREEN_PIX_HEIGHT, string.format("%2X", screen_id), 0xFFFFFFFF, 0x5F000000)
	NUM_CHARS = ptr_chain(in_game_root, {0, 4, 4, 0xC})
	if NUM_CHARS == nil then
		prev_active = false
	else
		num_coins = memory.read_u32_le(0x02002E9C+0x1C, "System Bus")
		pix(SCREEN_PIX_WIDTH - 5, 0, string.format('%2u/40', num_coins), 0xFFFFEF10, 0x5F000000)
		pix(SCREEN_PIX_WIDTH - 29, 3, " hp       x  /\\x       y  /\\y", 0xFF00FF00, 0x5F000000)
		for i = 0, NUM_CHARS - 1 do
			local char_addr = ptr_chain(in_game_root, {0, 4, 4, 4, i * 4})
			if char_addr then
				local char_row = pix_row(SCREEN_PIX_WIDTH - 29, i + 4, 0xFF00FF00, 0x5F000000)
				local curr_char = chars[i+1]
				x = memory.read_u32_le(char_addr + 0x178, "System Bus")
				y = memory.read_u32_le(char_addr + 0x17C, "System Bus")
				diff_x, diff_y = x - curr_char.prev_x, y - curr_char.prev_y
				curr_char.prev_x, curr_char.prev_y = x, y
				if not prev_active or prev_frames + 1 ~= frames then
					diff_x, diff_y = "    ?", "    ?"
				else
					diff_x = string.format('%5s', diff_x)
					diff_y = string.format('%5s', diff_y)
				end
				char_row(memory.read_u32_le(char_addr + 0x1FC, "System Bus") .. "/"
					.. memory.read_u32_le(char_addr + 0x200, "System Bus"))
				char_row(string.format('%8u', x))
				char_row(diff_x)
				char_row(string.format('%8u', y))
				char_row(diff_y)
			end
		end
		prev_active = true
	end
	prev_frames = frames
	emu.frameadvance()
end
