include'themer/iconbrowser.lua'
include'themer/spawnmenu.lua'

--[[
File: themer/main.lua
Info: This file loads everything and contains the main code of stuff
--]]

--cvars
local themer_enabled = CreateClientConVar("themer_enabled", "1",           true)
local derma_skinname    = CreateClientConVar("derma_skinname",    "gmoddefault", true)

local themer_tweaks_uselabel = CreateClientConVar("themer_tweaks_uselabel", "1", true)
local themer_options_gear    = CreateClientConVar("themer_options_gear",    "0", true)
local themer_spawnlist_icons = CreateClientConVar("themer_spawnlist_icons", "0", true)

local themer_icon_spawnlists = CreateClientConVar("themer_icon_spawnlists", "icon16/application_view_tile.png", true)
local themer_icon_weapons    = CreateClientConVar("themer_icon_weapons",    "icon16/gun.png",                   true)
local themer_icon_ents       = CreateClientConVar("themer_icon_ents",       "icon16/bricks.png",                true)
local themer_icon_npcs       = CreateClientConVar("themer_icon_npcs",       "icon16/group.png",                 true)
local themer_icon_cars       = CreateClientConVar("themer_icon_cars",       "icon16/car.png",                   true)
local themer_icon_pp         = CreateClientConVar("themer_icon_pp",         "icon16/image.png",                 true)
local themer_icon_dupes      = CreateClientConVar("themer_icon_dupes",      "icon16/brick_link.png",            true)
local themer_icon_saves      = CreateClientConVar("themer_icon_saves",      "icon16/disk.png",                  true)

--Main loading
local function ColorHack()
	local DMenuOption = table.Copy(vgui.GetControlTable("DMenuOption"))
	local DTextEntry = table.Copy(vgui.GetControlTable("DTextEntry"))
	if themer_tweaks_uselabel:GetBool() then
		DMenuOption.Init = function(self)
			self:SetContentAlignment(4)
			self:SetTextInset(30,0)
			self:SetTextColor(self:GetSkin().Colours.Label.Dark)
			self:SetChecked(false)
		end
		DTextEntry.GetTextColor = function(self)
			return self.m_colText || self:GetSkin().Colours.Label.Dark
		end
		DTextEntry.GetCursorColor = function(self)
			return self.m_colCursor || self:GetSkin().Colours.Label.Dark
		end

		derma.DefineControl( "DMenuOption", "Menu Option Line", DMenuOption, "DButton" )
		derma.DefineControl( "DMenuOptionCVar", "", vgui.GetControlTable("DMenuOptionCVar"), "DMenuOption" ) --need to reregister for colors to apply, that's all
		derma.DefineControl( "DTextEntry", "A simple TextEntry control", DTextEntry, "TextEntry" )
	end
end

hook.Add("ForceDermaSkin","Themer",function()
	if themer_enabled:GetBool() then return "themer" end
end)
concommand.Add("themer_refresh_derma",function()
	include'skins/themer.lua'
	derma.RefreshSkins()
	ColorHack()

	for k,v in pairs(hook.GetTable()["ForceDermaSkin"]) do
		if k ~= "Themer" then
			hook.Remove("ForceDermaSkin", k)
		end
	end
end)

hook.Add("SpawnMenuOpen","Themer.IconHack",function()
	local ToolMenu = g_SpawnMenu.ToolMenu
	for k,v in pairs(ToolMenu.Items) do
		if v.Name == "Options" then
			v.Tab.Image:SetImage(themer_options_gear:GetBool() and "icon16/cog.png" or "icon16/wrench.png")
		end
	end

	local SpawnTabs = g_SpawnMenu.CreateMenu.Items
	for k,v in pairs(SpawnTabs) do
		if v.Name == "#spawnmenu.content_tab" then
			v.Tab.Image:SetImage(Material(themer_icon_spawnlists:GetString()):IsError() and "icon16/application_view_tile.png" or themer_icon_spawnlists:GetString())

			--While we're here
			local spawnlists = v.Panel:GetChildren()[1].ContentNavBar.Tree.RootNode.ChildNodes:GetChildren()
			for _,n in pairs(spawnlists) do
				if n:GetText() == "Your Spawnlists" then
					n:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_page.png" or "icon16/folder.png")
				end
				if n:GetText() == "Browse" then
					n:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_brick.png" or "icon16/cog.png")
				end
				if n:GetText() == "Browse Materials" then
					n:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_image.png" or "icon16/picture_empty.png")
				end
				if n:GetText() == "Browse Sounds" then
					n:SetIcon(themer_spawnlist_icons:GetBool() and "icon16/folder_bell.png" or "icon16/sound.png")
				end
			end
		end

		if v.Name == "#spawnmenu.category.weapons" then
			v.Tab.Image:SetImage(Material(themer_icon_weapons:GetString()):IsError() and "icon16/gun.png" or themer_icon_weapons:GetString())
		end

		if v.Name == "#spawnmenu.category.entities" then
			v.Tab.Image:SetImage(Material(themer_icon_ents:GetString()):IsError() and "icon16/bricks.png" or themer_icon_ents:GetString())
		end

		if v.Name == "#spawnmenu.category.npcs" then
			v.Tab.Image:SetImage(Material(themer_icon_npcs:GetString()):IsError() and "icon16/group.png" or themer_icon_npcs:GetString())
		end

		if v.Name == "#spawnmenu.category.vehicles" then
			v.Tab.Image:SetImage(Material(themer_icon_cars:GetString()):IsError() and "icon16/car.png" or themer_icon_cars:GetString())
		end

		if v.Name == "#spawnmenu.category.postprocess" then
			v.Tab.Image:SetImage(Material(themer_icon_pp:GetString()):IsError() and "icon16/image.png" or themer_icon_pp:GetString())
		end

		if v.Name == "#spawnmenu.category.dupes" then
			v.Tab.Image:SetImage(Material(themer_icon_dupes:GetString()):IsError() and "icon16/brick_link.png" or themer_icon_dupes:GetString())
		end

		if v.Name == "#spawnmenu.category.saves" then
			v.Tab.Image:SetImage(Material(themer_icon_saves:GetString()):IsError() and "icon16/disk.png" or themer_icon_saves:GetString())
		end
	end
end)

hook.Add("PlayerInitialSpawn","Themer.ColorTweaks",function()
	timer.Simple(0,function()
		ColorHack()
		for k,v in pairs(hook.GetTable()["ForceDermaSkin"]) do
			if k ~= "Themer" then
				hook.Remove("ForceDermaSkin", k)
			end
		end
	end)
end)

for k,v in pairs(hook.GetTable()["ForceDermaSkin"]) do
	if k ~= "Themer" then
		hook.Remove("ForceDermaSkin", k)
	end
end

if hook.GetTable()["OnGamemodeLoaded"] and hook.GetTable()["OnGamemodeLoaded"]["CreateMenuBar"] then
	local oldCreateMenuBar = oldCreateMenuBar or hook.GetTable()["OnGamemodeLoaded"]["CreateMenuBar"]
	hook.Add( "OnGamemodeLoaded", "CreateMenuBar", function()
		ColorHack()
		oldCreateMenuBar()
	end)
end