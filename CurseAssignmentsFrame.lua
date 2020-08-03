local ADDON_NAME, RAW = ...

RAW_WarlockList = {}

-- Frame for the Curse assiignment tab
RAW.UI.RosterScrollFrame = CreateFrame("SCROLLFRAME", "RAW_RosterScrollframe", RAWarlocks_RosterFrame)
RAW.UI.RosterScrollFrame:SetPoint("TOPLEFT", 16, -86)
RAW.UI.RosterScrollFrame:SetSize(400, 400)
RAW.UI.RosterScrollFrame:EnableMouseWheel(false)

-- Button to message the raid handing out assignments
RAW.UI.RosterScrollFrame.MessageRaidButton = CreateFrame("BUTTON", "RAW_MessageRaidButton", RAW.UI.RosterScrollFrame, "UIPanelButtonTemplate")
RAW.UI.RosterScrollFrame.MessageRaidButton:SetPoint("TOPLEFT", 200, 25)
RAW.UI.RosterScrollFrame.MessageRaidButton:SetText("Send To Raid")
RAW.UI.RosterScrollFrame.MessageRaidButton:SetSize(100, 22)

-- TODO Move this to its own function
RAW.UI.RosterScrollFrame.MessageRaidButton:SetScript("OnClick", function()

	-- Send to Raid
	SendChatMessage(" ---- Curse Assignments Start  ------", "RAID", nil, nil)

	-- Go through the warlocks and announce thier curse in raid
	for k, Warlock in ipairs(RAW_Core.WarlockList) do
		if Warlock ~= nil and Warlock.Name ~= nil then

			-- build a basic string to inform them
			local TextString = Warlock.Name .." Your Curse is: "..Warlock.Curse

			-- TODO: Improve this display
			-- Tack on corruption info
			if (Warlock.CanCorruption)
			then
				TextString = TextString..", You May Cast Corruption!"
			end

			-- Send to Raid
			SendChatMessage(TextString, "RAID", nil, nil)
		end
	end

	-- Send to Raid
	SendChatMessage(" ---- Curse Assignments End    ------", "RAID", nil, nil)
end)

-- Button to message the Warlocks via Whisper
RAW.UI.RosterScrollFrame.WhisperWarlocksButton = CreateFrame("BUTTON", "RAW_WhisperWarlocksButton", RAW.UI.RosterScrollFrame, "UIPanelButtonTemplate")
RAW.UI.RosterScrollFrame.WhisperWarlocksButton:SetPoint("TOPLEFT", 300, 25)
RAW.UI.RosterScrollFrame.WhisperWarlocksButton:SetText("Send Whispers")
RAW.UI.RosterScrollFrame.WhisperWarlocksButton:SetSize(100, 22)
RAW.UI.RosterScrollFrame.WhisperWarlocksButton:SetScript("OnClick", function()

	-- Go through the warlocks and tell them thier assignment
	for k, Warlock in ipairs(RAW_Core.WarlockList) do
		RAW_Core:WhisperWarlockCurse(Warlock)
	end

end)


-- Button to message the Warlocks via Whisper
RAW.UI.RosterScrollFrame.TestFeatureButton = CreateFrame("BUTTON", "RAW_TestFeatureButton", RAW.UI.RosterScrollFrame, "UIPanelButtonTemplate")
RAW.UI.RosterScrollFrame.TestFeatureButton:SetPoint("TOPLEFT", 100, 25)
RAW.UI.RosterScrollFrame.TestFeatureButton:SetText("Test")
RAW.UI.RosterScrollFrame.TestFeatureButton:SetSize(100, 22)
RAW.UI.RosterScrollFrame.TestFeatureButton:SetScript("OnClick", function()
end)

-- Scroll Bar used to navigate the Warlock list
RAW.UI.RosterScrollBar = CreateFrame("Slider", "RAW_RosterScrollBar", RAW.UI.RosterScrollFrame, "UIPanelScrollBarTemplate")
RAW.UI.RosterScrollBar:SetPoint("TOPLEFT", RAW.UI.RosterScrollFrame, "TOPRIGHT", -16, -22)
RAW.UI.RosterScrollBar:SetPoint("BOTTOMLEFT", RAW.UI.RosterScrollFrame, "BOTTOMRIGHT", -16, 8)
RAW.UI.RosterScrollBar:SetMinMaxValues(0, 5)
RAW.UI.RosterScrollBar:SetValueStep(1)
RAW.UI.RosterScrollBar.scrollStep = 1
RAW.UI.RosterScrollBar:SetStepsPerPage(4)
RAW.UI.RosterScrollBar:SetObeyStepOnDrag(true)
RAW.UI.RosterScrollBar:SetValue(0)
RAW.UI.RosterScrollBar:SetWidth(16)
RAW.UI.RosterScrollBar:SetScript("OnValueChanged", function(self, delta)
	RAW_WarlockList:UpdateWarlockListViewItems()
end)

RAW.UI.WarlockListViewItems = {}
function RAW.UI.BuildWarlockListView()
	for i = 1, 5 do

		-- Base frame holds the rest
		local WarlockInfoFrameEntry = CreateFrame("FRAME", tostring("RAW_WarlockListViewItem"..i), RAW.UI.RosterScrollFrame)
		WarlockInfoFrameEntry:SetPoint("TOPLEFT", 12, ((80 * (i - 1)) * -1) - 2)
		WarlockInfoFrameEntry:SetSize(370, 80)
		WarlockInfoFrameEntry:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 1, right = 1, top = 1, bottom = 1 } })
		WarlockInfoFrameEntry:SetBackdropColor(0, 0, 0, 1.0)
		WarlockInfoFrameEntry:EnableMouse(true)

		-- Name of the warlock associated with this entry
		WarlockInfoFrameEntry.Name = WarlockInfoFrameEntry:CreateFontString(tostring("RAW_WarlockListViewItem"..i.."_NameText"), "OVERLAY", "GameFontNormalLarge")
		WarlockInfoFrameEntry.Name:SetPoint("TOPLEFT", 0, -2)
		WarlockInfoFrameEntry.Name:SetText("Warlock Name")

		-- Talents Of The Warlock
		WarlockInfoFrameEntry.Talents = WarlockInfoFrameEntry:CreateFontString(tostring("RAW_WarlockListViewItem"..i.."_TalentsText"), "OVERLAY", "GameFontNormal")
		WarlockInfoFrameEntry.Talents:SetPoint("TOPLEFT", 0, -20)
		WarlockInfoFrameEntry.Talents:SetText("(0/0/0)")

		 -- Should Cast Corruption CheckBox 
		WarlockInfoFrameEntry.CheckBox = CreateFrame("CHECKBUTTON", "RAW_CorruptionCheckBox", WarlockInfoFrameEntry, "UICheckButtonTemplate")
		WarlockInfoFrameEntry.CheckBox:SetPoint("TOPLEFT", 65, -15)
		WarlockInfoFrameEntry.CheckBox:SetSize(20, 20)
		WarlockInfoFrameEntry.CheckBox:SetScript("OnClick", function()
			if (RAW_Core.WarlockList[i] ~= nil) then
				RAW_Core.WarlockList[i].CanCorruption = WarlockInfoFrameEntry.CheckBox:GetChecked()
				RAW_Core:SendAllWarlockData()
			end
		end);

		-- Corruption Text
		WarlockInfoFrameEntry.CorruptionText = WarlockInfoFrameEntry:CreateFontString(tostring("RAW_WarlockListViewItem"..i.."_CorruptionText"), "OVERLAY", "GameFontNormal")
		WarlockInfoFrameEntry.CorruptionText:SetPoint("TOPLEFT", 85, -20)
		WarlockInfoFrameEntry.CorruptionText:SetText("Corruption")

		-- Whisper button to remind specific warlocks of their Curse
		WarlockInfoFrameEntry.WhisperWarlockButton = CreateFrame("BUTTON", tostring("RAW_WarlockListViewItem"..i.."_WhisperButton"), WarlockInfoFrameEntry, "UIPanelButtonTemplate")
		WarlockInfoFrameEntry.WhisperWarlockButton:SetPoint("TOPLEFT", 5, -40)
		WarlockInfoFrameEntry.WhisperWarlockButton:SetText("Remind")
		WarlockInfoFrameEntry.WhisperWarlockButton:SetSize(60, 22)
		WarlockInfoFrameEntry.WhisperWarlockButton:SetScript("OnClick", function()
			if (RAW_Core.WarlockList[i] ~= nil) then
				RAW_Core:WhisperWarlockCurse(RAW_Core.WarlockList[i])
			end
		end)

		-- Icon that shows the current curse
		WarlockInfoFrameEntry.CurseIcon = CreateFrame("FRAME", tostring("RAW_WarlockListViewItem"..i.."_CurseIcon"), WarlockInfoFrameEntry)
		WarlockInfoFrameEntry.CurseIcon:SetPoint("RIGHT", -10, 0)
		WarlockInfoFrameEntry.CurseIcon:SetSize(56, 56)
		WarlockInfoFrameEntry.CurseIcon.Texture = WarlockInfoFrameEntry.CurseIcon:CreateTexture("$parent_Background", "BACKGROUND")
		WarlockInfoFrameEntry.CurseIcon.Texture:SetAllPoints(WarlockInfoFrameEntry.CurseIcon)

		-- Icon that shows the if the Warlock Should Corruption
		WarlockInfoFrameEntry.CorruptionIcon = CreateFrame("FRAME", tostring("RAW_WarlockListViewItem"..i.."_CorruptionIcon"), WarlockInfoFrameEntry)
		WarlockInfoFrameEntry.CorruptionIcon:SetPoint("RIGHT", -70, 0)
		WarlockInfoFrameEntry.CorruptionIcon:SetSize(56, 56)
		WarlockInfoFrameEntry.CorruptionIcon.Texture = WarlockInfoFrameEntry.CorruptionIcon:CreateTexture("$parent_Background", "BACKGROUND")
		WarlockInfoFrameEntry.CorruptionIcon.Texture:SetAllPoints(WarlockInfoFrameEntry.CorruptionIcon)
		WarlockInfoFrameEntry.CorruptionIcon.Texture:SetTexture(RAW.Types.SpellIcons["Corruption"]) 
		WarlockInfoFrameEntry.CorruptionIcon:Hide()

		-- Dropdown used to assign curses
		WarlockInfoFrameEntry.CurseDropDown = CreateFrame("FRAME", "RAW_PlayerRoleDropdown", WarlockInfoFrameEntry, "UIDropDownMenuTemplate")
		WarlockInfoFrameEntry.CurseDropDown:SetPoint("TOPLEFT", 50, -35)
		WarlockInfoFrameEntry.CurseDropDown.displayMode = "MENU"
		UIDropDownMenu_SetWidth(WarlockInfoFrameEntry.CurseDropDown, 150)
		UIDropDownMenu_SetText(WarlockInfoFrameEntry.CurseDropDown, "No Curse")

		-- Initialize the dropdown menu
		UIDropDownMenu_Initialize(WarlockInfoFrameEntry.CurseDropDown, function(self, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			for k, Curse in ipairs(RAW.Types.Curses) do
				info.text = Curse.Text
				info.arg1 = Curse.Id
				info.arg2 = nil
				info.func = function()
					if (RAW_Core.WarlockList[i] ~= nil) then
						RAW_Core.WarlockList[i].Curse = Curse.Text
						RAW_Core:SendAllWarlockData()
					end
				end
				UIDropDownMenu_AddButton(info)
			end
		end)

		RAW.UI.WarlockListViewItems[i] = WarlockInfoFrameEntry
	end
end

-- Refreshes the WarlockListViewItems Entries
function RAW_WarlockList:UpdateWarlockListViewItems()

	--Scrollbar Determines which Index to start at
	local WarlockListIndex = RAW.UI.RosterScrollBar:GetValue()

	-- Iterate over all the ListViewItems and try to find a Summon TO Show
	for k, Entry in ipairs(RAW.UI.WarlockListViewItems) do

		-- Flag  set if we find a valid SummonInfo to display
		local ShouldShowEntry = false

		-- Find the Next WarlockListItem to show
		for Index = WarlockListIndex + 1, #RAW_Core.WarlockList, 1 do
			if (RAW_Core.WarlockList[Index] ~= nil) then
				WarlockListIndex = Index
				ShouldShowEntry = true
				break
			end
		end

		-- There is an entry in this summon index that we wish to show
		if (ShouldShowEntry) then

			--Cache it locally
			local WarlockInfo = RAW_Core.WarlockList[WarlockListIndex]

			local CurseText = WarlockInfo.Curse
			local IconValue = RAW.Types.SpellIcons[CurseText]
			
			Entry.Name:SetText(WarlockInfo.Name)

			Entry.Talents:SetText(WarlockInfo.Spec)

			-- Sets the dropdown to the correct text
			UIDropDownMenu_SetText(Entry.CurseDropDown, CurseText)
			Entry.CurseIcon.Texture:SetTexture(IconValue)	
			Entry.CheckBox:SetChecked(WarlockInfo.CanCorruption)

			-- If the warlock is specced to use corruption show here
			if (WarlockInfo.CanCorruption) then
				Entry.CorruptionIcon:Show()
			else
				Entry.CorruptionIcon:Hide()
			end

			-- Show current entry
			Entry:Show()

			-- Update curse makro
			if (WarlockInfo.Name == UnitName("player")) then
				RAW_Core:UpdateCurseMakro(WarlockInfo)
			end
		else
			-- Hide current entry
			Entry:Hide()
		end
	end
end
