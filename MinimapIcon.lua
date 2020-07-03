local ADDON_NAME, RAW = ...

-- MinimapIcon setup
RAW.UI.ldb = LibStub("LibDataBroker-1.1")

RAW.UI.MinimapButton = RAW.UI.ldb:NewDataObject(RAW.addon_name, 
{
	type = "data source",
	icon = 134336, -- Soulstone Icon
	OnClick = function(self, button)
		if button == "RightButton" then
			-- Standard workaround call OpenToCategory twice
			-- https://www.wowinterface.com/forums/showpost.php?p=319664&postcount=2
			InterfaceOptionsFrame_OpenToCategory(RAW.addon_name)
			InterfaceOptionsFrame_OpenToCategory(RAW.addon_name)
		else
			RAW.UI.Toggle()
		end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then 
			return 
		end

		tooltip:AddLine(RAW.addon_name)
	end,
})

-- Minimap Icon, will be Registered in OnInitialize
RAW.UI.MinimapIcon = LibStub("LibDBIcon-1.0")

-- Shows or hides the RAWarlocks Panel
function RAW.UI.Toggle()
	if RAWarlocks then
		if RAWarlocks:IsVisible() then
			RAWarlocks:Hide()
		else
			RAWarlocks:Show()
		end
	end
end