function GetMinimapShape() return "SQUARE" end

local EPMinimap = CreateFrame("Frame")
EPMinimap:RegisterEvent("PLAYER_LOGIN");
EPMinimap:RegisterEvent("MINIMAP_PING");

local frames = {
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

local currentZoom = 0
local maxZoom = 0

function EPMinimap:MessageOutput(name, x, y)
	ChatFrame1:AddMessage(string.format("|cffDAFF8A[Minimap]|r %s pinged the map at %d, %y", name, x, y));
end;

function EPMinimap:MouseZoom(self, z)
	currentZoom = Minimap:GetZoom()
	if(z > 0 and currentZoom < maxZoom) then
		Minimap:SetZoom(currentZoom + 1)
	elseif(z < 0 and currentZoom > 0) then
		Minimap:SetZoom(currentZoom - 1)
	end
end

EPMinimap:SetScript("OnEvent", function(self, event, ...)

	-- we only care about PLAYER_LOGIN
	if(event == "PLAYER_LOGIN") then

		maxZoom = Minimap:GetZoomLevels()

		-- Enable mouse zoom, we keep this
		Minimap:EnableMouseWheel(true)
		Minimap:SetScript("OnMouseWheel", self:MouseZoom(self, z))

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
		for _, frame in pairs(frames) do
			frame:Hide()
		end

		-- clear out the table for garbage collection
		frames = nil
	elseif (event == "MINIMAP_PING")
		self:MessageOutput(arg1, arg2, arg3)
	end
end
