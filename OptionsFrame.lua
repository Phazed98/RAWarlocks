local ADDON_NAME, RAW = ...

RAW_Options = {}

RAW_Options.Debug = false
RAW_Options.SummonSessionText = "Starting Summons, Press X To Be Added to the Queue"
RAW_Options.SummonChatText = "Summoning %t"
RAW_Options.AnnounceChannel = "RAID"

RAW_Core:DebugPrint(RAW_Options.SummoningText)

-- Frame for the summons tab
RAW.UI.OptionsFrame = CreateFrame("SCROLLFRAME", "RAW_OptionsFrame", RAWarlocks_OptionsFrame)
RAW.UI.OptionsFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.OptionsFrame:SetSize(400, 400)
RAW.UI.OptionsFrame:EnableMouseWheel(false)

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
 -- Enable or Disable Debug Mode
RAW.UI.OptionsFrame.DebugText = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameDebugText"), "OVERLAY", "GameFontNormal")
RAW.UI.OptionsFrame.DebugText:SetPoint("TOPLEFT", 40, -20)
RAW.UI.OptionsFrame.DebugText:SetText("Debug")

--Text For Summons Session text
RAW.UI.OptionsFrame.SummonSessionText = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameSummonSessionText"), "OVERLAY", "GameFontNormal")
RAW.UI.OptionsFrame.SummonSessionText:SetPoint("TOPLEFT", 10, -50)
RAW.UI.OptionsFrame.SummonSessionText:SetText("Summon Session Start Text")

-- Text For Summon Session
RAW.UI.OptionsFrame.SummonSessionTextBox = CreateFrame("EditBox", nil, RAW.UI.OptionsFrame)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetPoint("TOPLEFT", 10, -70)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetFontObject(ChatFontNormal)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetTextInsets(10, 10, 10, 20)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetWidth(380)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetHeight(40)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetText(RAW_Options.SummonSessionText)
RAW.UI.OptionsFrame.SummonSessionTextBox:HighlightText()

RAW.UI.OptionsFrame.SummonSessionTextBox:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
													edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
													tile = true, tileSize = 16, edgeSize = 16, 
													insets = { left = 0, right = 0, top = 0, bottom = 0 }});
RAW.UI.OptionsFrame.SummonSessionTextBox:SetBackdropColor(0, 0, 0, 1)
RAW.UI.OptionsFrame.SummonSessionTextBox:SetBackdropBorderColor(1, 1, 1 , 1)

RAW.UI.OptionsFrame.SummonSessionTextBox:SetScript("OnTextChanged", function()
  RAW_Options.SummonSessionText = RAW.UI.OptionsFrame.SummonSessionTextBox:GetText()
end)

--Text For Summons Session text
RAW.UI.OptionsFrame.SummonChatText = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameSummonSessionText"), "OVERLAY", "GameFontNormal")
RAW.UI.OptionsFrame.SummonChatText:SetPoint("TOPLEFT", 10, -140)
RAW.UI.OptionsFrame.SummonChatText:SetText("Summon Message Text")

-- Text For Summon Session
RAW.UI.OptionsFrame.SummonChatTextBox = CreateFrame("EditBox", nil, RAW.UI.OptionsFrame)
RAW.UI.OptionsFrame.SummonChatTextBox:SetPoint("TOPLEFT", 10, -160)
RAW.UI.OptionsFrame.SummonChatTextBox:SetFontObject(ChatFontNormal)
RAW.UI.OptionsFrame.SummonChatTextBox:SetTextInsets(10, 10, 10, 20)
RAW.UI.OptionsFrame.SummonChatTextBox:SetWidth(380)
RAW.UI.OptionsFrame.SummonChatTextBox:SetHeight(40)
RAW.UI.OptionsFrame.SummonChatTextBox:SetText(RAW_Options.SummonSessionText)
RAW.UI.OptionsFrame.SummonChatTextBox:HighlightText()

RAW.UI.OptionsFrame.SummonChatTextBox:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
													edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
													tile = true, tileSize = 16, edgeSize = 16, 
													insets = { left = 0, right = 0, top = 0, bottom = 0 }});
RAW.UI.OptionsFrame.SummonChatTextBox:SetBackdropColor(0, 0, 0, 1)
RAW.UI.OptionsFrame.SummonChatTextBox:SetBackdropBorderColor(1, 1, 1 , 1)

RAW.UI.OptionsFrame.SummonChatTextBox:SetScript("OnTextChanged", function()
  RAW_Options.SummonChatText = RAW.UI.OptionsFrame.SummonChatTextBox:GetText()
end)

--Text For Curse Assignment Channel
RAW.UI.OptionsFrame.CurseAssignmentText = RAW.UI.OptionsFrame:CreateFontString(tostring("RAW_OptionsFrameSummonSessionText"), "OVERLAY", "GameFontNormal")
RAW.UI.OptionsFrame.CurseAssignmentText:SetPoint("TOPLEFT", 10, -220)
RAW.UI.OptionsFrame.CurseAssignmentText:SetText("Curse Assignment Channel")

-- Dropdown with Available Channels
RAW.UI.OptionsFrame.AnnounceChannelDropDown = CreateFrame("FRAME", "RAW_PlayerRoleDropdown", RAW.UI.OptionsFrame, "UIDropDownMenuTemplate")
RAW.UI.OptionsFrame.AnnounceChannelDropDown:SetPoint("TOPLEFT", 0, -240)
RAW.UI.OptionsFrame.displayMode = "MENU"
UIDropDownMenu_SetWidth(RAW.UI.OptionsFrame.AnnounceChannelDropDown, 150)
UIDropDownMenu_SetText(RAW.UI.OptionsFrame.AnnounceChannelDropDown, "RAW_Options.AnnounceChannel")

-- Initialize the dropdown menu
UIDropDownMenu_Initialize(RAW.UI.OptionsFrame.AnnounceChannelDropDown, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()

	local NumChannels = GetNumDisplayChannels();
	for Index = 0, NumChannels, 1  do
		name, header, collapsed, channelNumber, count, active, category, voiceEnabled, voiceActive = GetChannelDisplayInfo(Index);

		--filter chat channels for better use (Group is Party, Remove "Custom"")
		if name =="Group" then
			name = "Party"
		elseif name == "Custom" then
			name = nil
		end
		
		if name ~= nil then
			info.text = name
			info.arg1 = name
			info.arg2 = channelNumber
			info.func = self.SetValue
		
			UIDropDownMenu_AddButton(info)
		end
	end
end)

-- Implement the function to change the favoriteNumber
function RAW.UI.OptionsFrame.AnnounceChannelDropDown:SetValue(arg1, arg2)
 RAW_Options.AnnounceChannel = arg1
 UIDropDownMenu_SetText(RAW.UI.OptionsFrame.AnnounceChannelDropDown, RAW_Options.AnnounceChannel)
end