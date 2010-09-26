local pingFrame = CreateFrame('Frame', nil, MinimapPing)
pingFrame:RegisterEvent('ADDON_LOADED')

local format = string.format
local min = math.min

function pingFrame:ADDON_LOADED(event, name)
	if name ~= 'EP_Minimap' then return end

	self:SetBackdrop({
		bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
		insets = {
			left = -1 * (768 / 1080),
			right = -1 * (768 / 1080),
			top = -1 * (768 / 1080),
			bottom = -1 * (768 / 1080)
		}
	})
	self:SetBackdropColor(0, 0, 0, 0.75)

	self:SetWidth(1)
	self:SetHeight(1)
	self:SetPoint('BOTTOM', Minimap, 'BOTTOM', 0, 1)

	local text = self:CreateFontString(nil, 'ARTWORK')
	text:SetFont([=[Interface\AddOns\EP_Minimap\fonts\DroidSans.ttf]=], 12, 'THINOUTLINE')
	text:SetAllPoints(self)
	text:SetJustifyH('LEFT')
	self.text = text

	self:Show()

	-- Replace the default routines to cope with a square minimap
	Minimap_SetPing = function(x, y, playSound)
		x = x * Minimap:GetWidth()
		y = y * Minimap:GetHeight()

		local radius = Minimap:GetWidth() / 2

		if x > radius or x < -radius or y > radius or y < -radius then
			MinimapPing:Hide()
			return
		end

		MinimapPing:SetPoint('CENTER', Minimap, 'CENTER', x, y)
		MinimapPing:SetAlpha(1)
		MinimapPing:Show()

		if playSound then
			PlaySound('MapPing')
		end
	end

	Minimap:SetScript('OnMouseUp', function()
		local x, y = GetCursorPosition()
		x = x / Minimap:GetEffectiveScale()
		y = y / Minimap:GetEffectiveScale()

		local cx, cy = Minimap:GetCenter()
		x = x - cx
		y = y - cy

		local radius = Minimap:GetWidth() / 2

		if x > radius or x < -radius or y > radius or y < -radius then
			return
		end

		Minimap:PingLocation(x, y)
	end)

	self:UnregisterEvent('ADDON_LOADED')
	self:RegisterEvent('MINIMAP_PING')
end

function pingFrame:MINIMAP_PING(event, unit, x, y)
	if UnitIsUnit('player', unit) then
		self:Hide()
		return
	end

	local name, server = UnitName(unit)
	if server and server ~= '' then
		name = format('%s-%s', name, server)
	end
	self.text:SetText(name)

	self:SetWidth(min(self.text:GetWidth() + 1, Minimap:GetWidth()))
	self:SetHeight(self.text:GetHeight() + 1)

	self:Show()
end

pingFrame:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)