function GetMinimapShape() return 'SQUARE' end

local EPMinimap = CreateFrame('Frame')
EPMinimap:RegisterEvent('ADDON_LOADED')

local objects = {
	MinimapBorderTop,
	MiniMapBattlefieldBorder,
	MiniMapMailBorder,
	MiniMapTrackingBackground,
	MiniMapTrackingButtonBorder,
	MinimapBorder,
	MinimapBorder,
	GameTimeFrame,
	MinimapZoneTextButton,
	MiniMapWorldMapButton,
	MinimapToggleButton,
	MiniMapVoiceChatFrame,
	MinimapZoomIn,
	MinimapZoomOut,
}

EPMinimap:SetScript('OnEvent', function(self, event, name)
	if name ~= 'EP_Minimap' then return end

	-- Enable mouse zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript('OnMouseWheel', function(self, z)
		local maxZoom = Minimap:GetZoomLevels()
		local currentZoom = Minimap:GetZoom()

		if z > 0 and currentZoom < maxZoom then
			Minimap:SetZoom(currentZoom + 1)
		elseif z < 0 and currentZoom > 0 then
			Minimap:SetZoom(currentZoom - 1)
		end
	end)

	-- Adjust the Instance Difficulty flag
	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, 0)

	-- Adjust the tracking icon position
	MiniMapTracking:SetParent(Minimap)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, 0)

	-- Adjust the LFD icon position
	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint('TOP', Minimap, 'BOTTOM', 0, 0)

	-- Adjust the PvP icon position
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint('TOP', Minimap, 'BOTTOM', 0, 0)

	-- Adjust the mail icon position
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, 0)
	MiniMapMailFrame:SetScale(1.2)

	-- Apply mask so that the square map looks right
	Minimap:SetMaskTexture([=[Interface\AddOns\EP_Minimap\textures\Mask]=])

	-- Change minimap scale
	Minimap:SetScale(0.8)

	-- Move the minimap
	Minimap:ClearAllPoints()
	Minimap:SetPoint('TOPRIGHT', 'UIParent', 'TOPRIGHT', -25, -30)

	-- Set the background
	Minimap:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		insets = {
			left = -1 * (768 / 1080),
			right = -1 * (768 / 1080),
			top = -1 * (768 / 1080),
			bottom = -1 * (768 / 1080)
		}
	})
	Minimap:SetBackdropColor(0, 0, 0)

	-- Hide all the items we do not want to see
	for _, object in pairs(objects) do
		if object:IsObjectType('Frame') then
			object:UnregisterAllEvents()
		end
		object:Hide()
	end
	-- Empty the table to reduce memory
	objects = nil

	-- unregister as we no longer need this event
	self:UnregisterEvent('ADDON_LOADED')
	self:SetScript('OnEvent', nil)
end)
