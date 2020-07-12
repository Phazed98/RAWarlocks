local ADDON_NAME, RAW = ...

RAW_Options = {}

RAW_Options.Debug = false

-- Frame for the summons tab
RAW.UI.OptionsFrame = CreateFrame("SCROLLFRAME", "RAW_OptionsFrame", RAWarlocks_OptionsFrame)
RAW.UI.OptionsFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.OptionsFrame:SetSize(400, 400)
RAW.UI.OptionsFrame:EnableMouseWheel(false)

-- Name of the person requesting a summon
RAW.UI.OptionsFrame.ComingSoon = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameSoonText"), "OVERLAY", "GameFontHighlightLarge")
RAW.UI.OptionsFrame.ComingSoon:SetPoint("TOP", 0, -2)
RAW.UI.OptionsFrame.ComingSoon:SetText("Coming Soon!")

 -- Should Cast Corruption CheckBox 
RAW.UI.OptionsFrame.DebugCheckBox = CreateFrame("CHECKBUTTON", "RAW_DebugCheckBox", RAW.UI.OptionsFrame, "UICheckButtonTemplate")
RAW.UI.OptionsFrame.DebugCheckBox:SetPoint("TOPLEFT", 10, -15)
RAW.UI.OptionsFrame.DebugCheckBox:SetSize(20, 20)
RAW.UI.OptionsFrame.DebugCheckBox:SetChecked(RAW_Options.Debug)
RAW.UI.OptionsFrame.DebugCheckBox:SetScript("OnClick", function()
	RAW_Options.Debug = RAW.UI.OptionsFrame.DebugCheckBox:GetChecked()
	
	if (RAW_Options.Debug) then
		RAW.UI.RosterScrollFrame.TestFeatureButton:Show()
	else
		RAW.UI.RosterScrollFrame.TestFeatureButton:Hide()
	end

end);

-- Corruption Text
RAW.UI.OptionsFrame.DebugText = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameDebugText"), "OVERLAY", "GameFontNormal")
RAW.UI.OptionsFrame.DebugText:SetPoint("TOPLEFT", 40, -20)
RAW.UI.OptionsFrame.DebugText:SetText("Debug")