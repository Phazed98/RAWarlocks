local ADDON_NAME, RAW = ...

RAW_Summons = {}

-- Frame for the summons tab
RAW.UI.OptionsFrame = CreateFrame("SCROLLFRAME", "RAW_OptionsFrame", RAWarlocks_OptionsFrame)
RAW.UI.OptionsFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.OptionsFrame:SetSize(400, 400)
RAW.UI.OptionsFrame:EnableMouseWheel(false)

-- Name of the person requesting a summon
RAW.UI.OptionsFrame.ComingSoon = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameSoonText"), "OVERLAY", "GameFontHighlightLarge")
RAW.UI.OptionsFrame.ComingSoon:SetPoint("TOP", 0, -2)
RAW.UI.OptionsFrame.ComingSoon:SetText("Coming Soon!")