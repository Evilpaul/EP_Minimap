function GetMinimapShape() return "SQUARE" end

local EPMinimap = CreateFrame("Frame")
EPMinimap:RegisterEvent("PLAYER_LOGIN")
EPMinimap:RegisterEvent("MINIMAP_PING")

local currentZoom = 0
local maxZoom = 0
local lastPingTime = 0
local lastPingPerson = ""
local frames = { -- table of stuff we want to disable and hide
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapToggleButton,
	MinimapBorderTop,
	MiniMapWorldMapButton,
	MinimapBorder,
	MiniMapVoiceChatFrame,
	MinimapBorder,
	GameTimeFrame,
	MinimapZoneTextButton,
	MiniMapMailBorder,
	MiniMapBattlefieldBorder,
	MiniMapTrackingButtonBorder,
	MiniMapTrackingBackground,
}

local MouseZoom = function(self, z)
	currentZoom = Minimap:GetZoom()

	if(z > 0 and currentZoom < maxZoom) then
		Minimap:SetZoom(currentZoom + 1)
	elseif(z < 0 and currentZoom > 0) then
		Minimap:SetZoom(currentZoom - 1)
	end
end

function EPMinimap:MessageOutput(name)
	ChatFrame1:AddMessage(string.format("|cffDAFF8A[Minimap]|r %s pinged the map", name))
end

function EPMinimap:MINIMAP_PING(event, unitID, x, y)

	-- do not print message if we pinged the map
	if (unitID == "player") or (unitID == "pet") or (unitID == "vehicle") then return end

	local currentTime = GetTime()

	-- do not print message more than once every 3 seconds if someone is spamming the map
	if (unitID == lastPingPerson) and ((currentTime - lastPingTime) < 3) then return end

	-- store the details of who pinged the map and when
	lastPingTime = currentTime
	lastPingPerson = unitID

	-- print out the name of who pinged the map
	local pingPlayer, _ = UnitName(unitID)
	EPMinimap:MessageOutput(pingPlayer)
end

function EPMinimap:PLAYER_LOGIN()

	-- Enable mouse zoom
	maxZoom = Minimap:GetZoomLevels()
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", MouseZoom)

	-- Adjust the tracking icon to be within the minimap frame
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("TOPLEFT", -2, -2)

	-- Adjust the PvP icon to be within the minimap frame
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", -2, -2)

	-- Adjust the mail icon to be within the minimap frame
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("BOTTOMRIGHT", 0, 0)

	-- Apply mask so that the square map looks right
	Minimap:SetMaskTexture("Interface\\AddOns\\EP_Minimap\\textures\\Mask")

	-- Use scaled blip texture as we are scaling the minimap
	Minimap:SetBlipTexture("Interface\\Addons\\EP_Minimap\\textures\\scaled80")

	-- Change minimap scale
	Minimap:SetScale(0.8)

	-- Move the minimap
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -25, -30)

	-- Set the background
	Minimap:SetBackdrop({ 
		bgFile ="Interface\\ChatFrame\\ChatFrameBackground",
		insets = {left = -1, right = -1, top = -1, bottom = -1},
	}) 
	Minimap:SetBackdropColor(0, 0, 0, .4)

	-- Hide all the items we do not want to see
	for i, frame in pairs(frames) do
		frame:Hide()
	end

	frames = nil

	-- unregister as we no longer need this event
	EPMinimap:UnregisterEvent("PLAYER_LOGIN")
end

EPMinimap:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)
